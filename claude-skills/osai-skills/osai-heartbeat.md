Append an operator heartbeat to `~/osai/current/state/heartbeat.md` AND mirror the block into the Obsidian Progress note. Invoked either automatically (a PostToolUse hook fires a `[OSAI HEARTBEAT DUE]` system-reminder every 15 minutes / 20 tool calls) or manually whenever context is heavy and about to be cleared.

**Purpose:** state written to disk survives `/clear`, usage resets, and machine crashes. The heartbeat is what makes `/osai-plan` able to rehydrate in a few hundred tokens instead of re-deriving from scratch. Never skip it — silence is not a valid state.

`$ARGUMENTS` (optional): short label for the beat, e.g. `dc01-recon` or `dpapi-chain`. If omitted, use the current active focus.

## Step 1 — Sense the current state (read, do not narrate)

Before writing anything, load the truth on disk. Do not paste the raw files into the note — extract only what changed.

```bash
STATE=~/osai/current/state
ls -la "$STATE" "$STATE/../loot" "$STATE/../recon" 2>&1 | head
cat "$STATE/progress.md"       2>/dev/null | tail -60
cat "$STATE/network_map.md"    2>/dev/null | tail -40
jq -r '.[] | "\(.id) \(.severity) \(.host) \(.title)"' "$STATE/../loot/findings.json" 2>/dev/null
jq -r '.[] | .user // (.username // (.identifier // "?"))' "$STATE/../state/creds.json" 2>/dev/null 2>/dev/null | sort -u
```

Also glance at the tail of `~/osai/current/state/heartbeat.md` to see what the previous beat said — the new one should be a *diff*, not a repeat.

## Step 2 — Compose the block

Terse, structured. One line per field unless truly needed. Use blank sub-bullets for empty fields — do not delete the field, so future greps still find them.

```markdown
## HEARTBEAT <ISO-8601 UTC> — <label from $ARGUMENTS or current focus>
- **Focus now:** <the single hypothesis you are testing right now>
- **Just tested since last beat:**
  - <thing tested> → <verdict: worked / partial / dead-end> — <one-line why>
- **Hosts touched:** <ip> — <tool> — <verdict>
- **Files/dirs enumerated:** <path> — <R/W/interesting/skipped> — <finding if any>
- **Scripts dropped or found on target:** <path> — <purpose> — <cleaned up? y/n>
- **Creds/keys/tokens learned:** <identifier only, no plaintext — real value goes to /osai-cred-vault>
- **Attack paths open:** P0 <line> · P1 <line> · P2 <line>
- **Blocked on / errors:** <exact error text, if any>
- **TODO next:** <one command / one action>
- **Screenshots captured this beat:** <path or Obsidian ref, or "none">
```

## Step 3 — Append to disk

```bash
[ -f ~/osai/current/state/heartbeat.md ] || printf "# Heartbeat log\n\n" > ~/osai/current/state/heartbeat.md
# append the block above (NEVER overwrite)
```

Reset the hook counters so a manual beat postpones the next reminder:

```bash
date +%s > ~/osai/current/state/.heartbeat_ts
echo 0    > ~/osai/current/state/.heartbeat_count
```

## Step 4 — Mirror to Obsidian (best-effort)

Use `mcp__obsidian__vault_append` on `Shadow Supply/Progress.md` (or the current lab's Progress note if the lab has been re-init'd). Prepend the block under a `### Heartbeats` heading if that heading exists; otherwise add the heading and the block.

If the Obsidian MCP fails (server down, network glitch), warn ONCE per session and keep going — the disk copy is authoritative.

## Step 5 — Never over-share

- Do NOT dump raw tool output into the beat. Summaries only.
- Do NOT copy passwords/hashes/tokens into the beat — they belong in the credential vault ([[Credentials]] or `~/osai/current/state/creds.json`). The beat only names the identifier ("recovered svc_proxy TGS hash").
- Do NOT re-litigate previously beaten hypotheses; if nothing changed on that front, skip the line.

## Style — the beat is a diff, not a report

If the last beat is ten minutes old and only one thing changed, the new beat should be a five-line block. If two hours of chaotic work happened, the beat gets big — but stays structured.
