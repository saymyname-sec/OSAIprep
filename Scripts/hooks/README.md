# OSAI hooks + evidence pipeline

Wires **automatic** operator discipline into Claude Code so state, findings, and
proof screenshots can't be lost through the enumeration process.

## What's in here

| File | Purpose |
|---|---|
| `heartbeat-init.sh` | `SessionStart` hook — seeds `~/osai/current/state/` + core state files. |
| `heartbeat-tick.sh` | `PostToolUse` hook — every **20 tool calls / 15 min**, emits `[OSAI HEARTBEAT DUE]` reminder to Claude. |
| `pwn3d-detector.sh` | `PostToolUse (Bash)` — greps output for `(Pwn3d!)`, `proof.txt`, `secretsdump`, `krb5tgs`; reminds Claude to log a finding + capture a screenshot immediately. |
| `osai-screenshot.sh` | Screenshot capture wrapper. Modes: `--active`, `--window WID`, `--text FILE`, `--text-stdin`, `--cmd -- CMD…`. Every capture is stamped and uploaded to the Obsidian vault at `Shadow Supply/screenshots/`. |
| `stamp-timestamp.py` | Overlays a mandatory red UTC + local TIME/DATE + hostname footer on every PNG. |
| `text-to-terminal-png.py` | Pillow-based text→terminal-styled PNG renderer (sidesteps ImageMagick's `@file` policy). |
| `settings.example.json` | Drop-in `hooks:` block to merge into your `~/.claude/settings.json`. |

## Wiring it up (~5 min)

```bash
# 1. Place these scripts somewhere stable (paths in settings.example.json are
#    ~/osai/bin/*.sh — either move them there OR edit the JSON to point here).
mkdir -p ~/osai/bin
cp ~/.claude/OSAI/Scripts/hooks/*.sh  ~/osai/bin/
cp ~/.claude/OSAI/Scripts/hooks/*.py  ~/osai/bin/
chmod +x ~/osai/bin/*.sh ~/osai/bin/*.py

# 2. Merge the hooks block into your Claude Code settings.
#    (Do it by hand — do not clobber existing "mcpServers" etc.)
$EDITOR ~/.claude/settings.json
# Take the "hooks" object from settings.example.json and paste it at
# the top level of your settings.json.

# 3. Restart Claude Code. On next tool call, heartbeat-init.sh runs
#    and seeds ~/osai/current/state/. From that moment forward:
#      - Every 15 min / 20 tool calls -> heartbeat reminder
#      - Every (Pwn3d!) or proof-file signal in Bash output -> finding reminder
#      - /osai-screenshot forces a timestamped image up to Obsidian
```

## Screenshot-to-Obsidian requirements

`osai-screenshot.sh` PUTs PNGs directly to the Obsidian Local REST API. You need:

- The Obsidian **Local REST API with MCP** plugin installed and running.
- Its bearer token exported (or auto-read from `~/.claude/settings.json`'s
  `mcpServers.obsidian.headers.Authorization` line).
- Optional overrides:
  - `OBSIDIAN_URL` (default `https://192.168.190.1:27124`)
  - `OBSIDIAN_TOKEN`
  - `OBSIDIAN_SCREENSHOT_FOLDER` (default `Shadow Supply/screenshots`)

Kali packages: `sudo apt install imagemagick xdotool python3-pil` (Pillow).

## Why the timestamp is mandatory

Every OSAI engagement scoring line: "unscreenshotted proof scores 0." The
stamp on every PNG (from `stamp-timestamp.py`) proves *when* it was captured,
not just *that* it was captured — a stamp with UTC + local time survives
report review months later, and rules out "you screenshotted an old flag."

The stamp is applied at capture time in every mode — X11 windows or Python-
rendered text alike — so nothing that leaves this pipeline is unstamped.

## What the reminders look like

**Heartbeat:**
```
[OSAI HEARTBEAT DUE]
15+ minutes / 20+ tool calls have elapsed since the last state snapshot.
Before the next attack step, invoke /osai-heartbeat to append a snapshot to
~/osai/current/state/heartbeat.md and mirror to the Obsidian Progress note.
...
```

**Pwn3d detector:**
```
[OSAI FINDING DETECTED]
High-signal string(s) in tool output:
(Pwn3d!)

Do NOT continue chaining. Right now:
  1. /osai-notes  --host <ip> --title <what> --severity <sev> --evidence <one-liner>
  2. If this is a scored proof file: /osai-screenshot proof-<host> --text-stdin (pipe the
     current terminal evidence), then /osai-notes --flag --host <ip> --file <path>
     --screenshot <path-returned-by-osai-screenshot>
  3. /osai-cred-vault --add for any credential recovered.

Unscreenshotted proof scores 0. Uncaptured Pwn3d! is a lost point on the report.
```

Both come out on stderr from the hook, which Claude Code surfaces as an
in-turn system message.

## Related skills

- `/osai-heartbeat` — the operator response to the heartbeat reminder.
- `/osai-screenshot` — wraps `osai-screenshot.sh` with the mode taxonomy.
- `/osai-notes --flag` — the proof-capture gate that refuses to record a flag
  without a `--screenshot` argument.
