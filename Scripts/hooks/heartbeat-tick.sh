#!/usr/bin/env bash
# heartbeat-tick.sh - PostToolUse hook. Increments a call counter and remembers
# the wall-clock timestamp of the last written heartbeat. When N tool calls have
# accumulated (default 20) OR T seconds have elapsed since last heartbeat
# (default 900 = 15 min), emit a system-reminder to Claude asking it to invoke
# /osai-heartbeat before the next attack step.
#
# The hook prints to stderr; Claude Code surfaces stderr from hooks as an
# in-turn system message. Never blocks (always exit 0).

set -u
STATE=~/osai/current/state
mkdir -p "$STATE" 2>/dev/null || true

TS_FILE="$STATE/.heartbeat_ts"
N_FILE="$STATE/.heartbeat_count"
THRESHOLD_N="${OSAI_HEARTBEAT_N:-20}"
THRESHOLD_S="${OSAI_HEARTBEAT_S:-900}"

now=$(date +%s)
last=$(cat "$TS_FILE" 2>/dev/null || echo "$now")
n=$(cat "$N_FILE" 2>/dev/null || echo 0)
# Guard against non-integer
[[ "$last" =~ ^[0-9]+$ ]] || last=$now
[[ "$n"    =~ ^[0-9]+$ ]] || n=0
n=$((n+1))
echo "$n" > "$N_FILE"

# First tick of a fresh session: don't nag, just seed the timestamp
if [ ! -s "$TS_FILE" ]; then
  echo "$now" > "$TS_FILE"
  exit 0
fi

dt=$((now - last))
if [ "$n" -ge "$THRESHOLD_N" ] || [ "$dt" -ge "$THRESHOLD_S" ]; then
  # Reset counters up-front so a stale heartbeat.md doesn't spam
  echo "$now" > "$TS_FILE"
  echo 0 > "$N_FILE"
  cat >&2 <<'MSG'
[OSAI HEARTBEAT DUE]
15+ minutes / 20+ tool calls have elapsed since the last state snapshot.
Before the next attack step, invoke /osai-heartbeat to append a snapshot to
~/osai/current/state/heartbeat.md and mirror to the Obsidian Progress note.

Capture (one line each, terse):
  - Focus now (hypothesis under test)
  - Just tested since last beat (worked / didn't work / why)
  - Hosts touched (ip -> tool -> verdict)
  - Files/dirs enumerated (path -> readable/writable/interesting)
  - Scripts dropped or found on target (path -> purpose -> cleaned?)
  - Creds/keys/tokens learned (identifier only)
  - Attack paths open (P0..Pn ranked)
  - Blocked on / errors (exact text)
  - TODO next (single next command)

State written to disk survives /clear and usage resets. This is not optional.
MSG
fi
exit 0
