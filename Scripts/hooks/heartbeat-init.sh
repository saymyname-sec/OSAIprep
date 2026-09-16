#!/usr/bin/env bash
# heartbeat-init.sh - SessionStart hook. Seeds the counter files so the very
# first tool call doesn't fire a stale heartbeat, and creates state dir + core
# state files if missing so /osai-plan can rehydrate cleanly.

set -u
STATE=~/osai/current/state
mkdir -p "$STATE" ~/osai/current/loot ~/osai/current/recon ~/osai/current/screenshots ~/osai/current/scripts 2>/dev/null || true

now=$(date +%s)
# Only seed if empty/missing so an ongoing session isn't reset by /clear
[ -s "$STATE/.heartbeat_ts" ] || echo "$now" > "$STATE/.heartbeat_ts"
[ -s "$STATE/.heartbeat_count" ] || echo 0 > "$STATE/.heartbeat_count"

# Ensure core state files exist so /osai-plan can find them
[ -f "$STATE/heartbeat.md" ] || printf "# Heartbeat log\n\n" > "$STATE/heartbeat.md"
[ -f ~/osai/current/loot/findings.json ] || echo '[]' > ~/osai/current/loot/findings.json

exit 0
