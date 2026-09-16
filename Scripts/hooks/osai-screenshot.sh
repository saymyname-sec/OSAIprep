#!/usr/bin/env bash
# osai-screenshot.sh - Capture a screenshot (X11) OR render text as a terminal-
# styled PNG, save to ~/osai/current/screenshots/, and upload directly to the
# Obsidian vault at Shadow Supply/screenshots/<TS>_<NAME>.png via the local
# REST API. Prints the Obsidian relative path so the caller can embed it in a
# note as ![](Shadow Supply/screenshots/<TS>_<NAME>.png).
#
# Usage:
#   osai-screenshot.sh NAME                  # capture root window
#   osai-screenshot.sh NAME --window WINID   # capture specific window
#   osai-screenshot.sh NAME --active         # capture active window (xdotool)
#   osai-screenshot.sh NAME --text FILE      # render text file
#   osai-screenshot.sh NAME --text-stdin     # render stdin
#   osai-screenshot.sh NAME --cmd -- CMD...  # run CMD, render its stdout+stderr

set -euo pipefail

NAME="${1:-}"
if [ -z "$NAME" ]; then
  echo "usage: osai-screenshot.sh NAME [--window WID|--active|--text FILE|--text-stdin|--cmd -- CMD...]" >&2
  exit 2
fi
shift

MODE="root"
ARG=""
CMD_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --window) MODE=window; ARG="$2"; shift 2 ;;
    --active) MODE=active; shift ;;
    --text) MODE=text; ARG="$2"; shift 2 ;;
    --text-stdin) MODE=text-stdin; shift ;;
    --cmd) MODE=cmd; shift; [ "${1:-}" = "--" ] && shift; while [ $# -gt 0 ]; do CMD_ARGS+=("$1"); shift; done ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

TS=$(date -u +%Y%m%dT%H%M%SZ)
SAFE_NAME=$(printf '%s' "$NAME" | tr -c 'A-Za-z0-9._-' '_')
LOCAL_DIR=~/osai/current/screenshots
mkdir -p "$LOCAL_DIR"
OUT="$LOCAL_DIR/${TS}_${SAFE_NAME}.png"

render_text_to_png() {
  # $1 = path to text file. Uses Pillow (Python) because ImageMagick's default
  # policy blocks the @file and @- readers used by label:/caption:/pango: .
  local src="$1"
  python3 "$(dirname "$0")/text-to-terminal-png.py" "$OUT" "$src" >/dev/null
}

case "$MODE" in
  root)
    import -silent -window root "$OUT"
    ;;
  window)
    import -silent -window "$ARG" "$OUT"
    ;;
  active)
    WID=$(xdotool getactivewindow)
    import -silent -window "$WID" "$OUT"
    ;;
  text)
    render_text_to_png "$ARG"
    ;;
  text-stdin)
    TF=$(mktemp)
    cat > "$TF"
    render_text_to_png "$TF"
    rm -f "$TF"
    ;;
  cmd)
    TF=$(mktemp)
    { printf '$ %s\n' "${CMD_ARGS[*]}"; "${CMD_ARGS[@]}" 2>&1 || true; } > "$TF"
    render_text_to_png "$TF"
    rm -f "$TF"
    ;;
esac

# Stamp every screenshot with UTC + local TIME/DATE (in place, red footer).
# --host embeds the workstation hostname so proof frames also carry attribution.
STAMP_HOST=$(hostname 2>/dev/null || echo unknown)
python3 "$(dirname "$0")/stamp-timestamp.py" --host "$STAMP_HOST" "$OUT" >/dev/null || {
  echo "[!] timestamp overlay failed — image left un-stamped: $OUT" >&2
}

# Upload to Obsidian
OBS_URL="${OBSIDIAN_URL:-https://192.168.190.1:27124}"
OBS_TOKEN="${OBSIDIAN_TOKEN:-$(sed -n 's/.*"Authorization": "Bearer \([^"]*\)".*/\1/p' ~/.claude/settings.json 2>/dev/null | head -1)}"
OBS_FOLDER="${OBSIDIAN_SCREENSHOT_FOLDER:-Shadow Supply/screenshots}"
OBS_PATH="${OBS_FOLDER}/${TS}_${SAFE_NAME}.png"

if [ -z "$OBS_TOKEN" ]; then
  echo "[!] no OBSIDIAN_TOKEN found; saved LOCAL_ONLY: $OUT" >&2
  echo "$OUT"
  exit 0
fi

# URL-encode path preserving slashes
ENC_PATH=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe='/'))" "$OBS_PATH")

http=$(curl -sk -o /dev/null -w '%{http_code}' \
        -X PUT \
        -H "Authorization: Bearer $OBS_TOKEN" \
        -H "Content-Type: image/png" \
        --data-binary "@$OUT" \
        "$OBS_URL/vault/$ENC_PATH" || echo err)

if [ "$http" = "200" ] || [ "$http" = "204" ]; then
  # Print the Obsidian-relative path for embedding
  echo "$OBS_PATH"
else
  echo "[!] Obsidian upload http=$http; LOCAL_ONLY: $OUT" >&2
  echo "$OUT"
fi
