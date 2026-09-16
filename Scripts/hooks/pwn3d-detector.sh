#!/usr/bin/env bash
# pwn3d-detector.sh - PostToolUse (Bash) hook. Scans the tool call's output for
# high-signal strings (Pwn3d!, proof retrieved, dumped hashes, DA session,
# secretsdump success) and reminds Claude to log a finding immediately -- do
# not batch, do not wait for the next heartbeat.
#
# Claude Code passes the tool's stdout/stderr via CLAUDE_TOOL_OUTPUT (path to a
# file) OR on stdin as JSON depending on version. This handler accepts both.

set -u
IN=""
if [ -n "${CLAUDE_TOOL_OUTPUT:-}" ] && [ -f "$CLAUDE_TOOL_OUTPUT" ]; then
  IN=$(head -c 65536 "$CLAUDE_TOOL_OUTPUT" 2>/dev/null || true)
else
  IN=$(head -c 65536 2>/dev/null || true)
fi
[ -z "$IN" ] && exit 0

# Only look at recent 20 lines of high-signal output to keep the reminder tight
HITS=$(printf '%s\n' "$IN" | grep -E -o '\(Pwn3d![^)]*\)|proof\.txt|secretsdump[^ ]*[+][^ ]*|DomainSecrets|dumped [0-9]+ hashes|found [0-9]+ credentials|GetUserSPNs.*krb5tgs' | sort -u | head -6 || true)

if [ -n "$HITS" ]; then
  cat >&2 <<MSG
[OSAI FINDING DETECTED]
High-signal string(s) in tool output:
$HITS

Do NOT continue chaining. Right now:
  1. /osai-notes  --host <ip> --title <what> --severity <sev> --evidence <one-liner>
  2. If this is a scored proof file: /osai-screenshot proof-<host> --text-stdin (pipe the
     current terminal evidence), then /osai-notes --flag --host <ip> --file <path>
     --screenshot <path-returned-by-osai-screenshot>
  3. /osai-cred-vault --add for any credential recovered.

Unscreenshotted proof scores 0. Uncaptured Pwn3d! is a lost point on the report.
MSG
fi
exit 0
