Capture a screenshot (either an X11 window OR render text output as a terminal-styled PNG), save to `~/osai/current/screenshots/`, AND upload it directly to the Obsidian vault at `Shadow Supply/screenshots/<TS>_<name>.png` via the Local REST API. Prints the Obsidian-relative path so it can be embedded in any note as `![](Shadow Supply/screenshots/<TS>_<name>.png)`.

**Why:** OSAI scoring is `"unscreenshotted proof scores 0"`. This wraps the whole capture → upload → embed pipeline into one call so evidence never gets lost.

`$ARGUMENTS`: `NAME [--window WID|--active|--text FILE|--text-stdin|--cmd -- CMD...]`

## Modes

| Mode | When to use |
|---|---|
| (default) | Capture the whole root window — good when there's a visible xterm/terminal with fresh evidence you want to snap "as seen." |
| `--active` | Capture the currently focused window (via `xdotool getactivewindow`). |
| `--window WID` | Capture a specific X11 window ID (e.g. from `xdotool selectwindow`). |
| `--text FILE` | Render a text file as a dark terminal-styled PNG. Perfect when the evidence lives in a tool-output file the operator ran headlessly. |
| `--text-stdin` | Render stdin as PNG. Ideal for piping a fresh command right into it. |
| `--cmd -- CMD...` | Run CMD, capture its stdout+stderr, render as PNG (with the `$` prompt line on top). |

## Recipes

```bash
# a) Snap the current desktop (whichever terminal is visible)
~/osai/bin/osai-screenshot.sh dc01-proof

# b) Snap only the active window
~/osai/bin/osai-screenshot.sh dc01-proof --active

# c) Freeze the exact command + output we just ran (best for headless flows)
~/osai/bin/osai-screenshot.sh dc01-nxc-pwn3d --cmd -- \
  nxc smb 172.16.199.40 -u Administrator -p 'Molten-Carousel-Driftwood72' -d example-corp.com --shares

# d) Render an evidence file we already saved
~/osai/bin/osai-screenshot.sh dpapi-decrypt --text ~/osai/current/screenshots/03_dpapi_decrypt.txt

# e) Render whatever's on stdin
cat ~/osai/current/screenshots/02_dc01_winrm_proof.txt | \
  ~/osai/bin/osai-screenshot.sh dc01-winrm-proof --text-stdin
```

## What happens under the hood

1. The image is written to `~/osai/current/screenshots/<UTC-timestamp>_<name>.png`.
2. **`stamp-timestamp.py` composites a red UTC + local TIME/DATE + hostname footer onto every capture — no exceptions, text-rendered or X11-captured**. This is the proof-of-time gate: an image without the stamp is not a valid piece of evidence.
3. The stamped PNG is `PUT` to `$OBSIDIAN_URL/vault/Shadow%20Supply/screenshots/<UTC-timestamp>_<name>.png` (default `https://127.0.0.1:27124`) with the Obsidian API bearer token from `~/.claude/settings.json` (env vars `OBSIDIAN_URL` / `OBSIDIAN_TOKEN` / `OBSIDIAN_SCREENSHOT_FOLDER` override).
4. On HTTP 200/204 the vault-relative path is printed to stdout — that's what you paste into a note as `![](THAT_PATH)`.
5. If the upload fails, the local path is printed instead and a `[!]` diagnostic goes to stderr — the local file is still there (already stamped) for a manual retry.

## Coupling with `/osai-notes --flag`

`/osai-notes --flag` MUST NOT record a proof without a screenshot filename. When invoking it, either:
- pass an existing screenshot (`--screenshot <local-or-vault-path>`), or
- capture one first with this skill and paste the returned path.

The Obsidian-relative path is preferred for `--screenshot` because it embeds correctly in the mirrored note.

## Failure modes

- **No `$DISPLAY`** — X11 modes will fail. Fall back to `--text` / `--text-stdin` / `--cmd` (headless-safe).
- **`import` not installed** — `sudo apt install imagemagick`. If unavailable, use `scrot` (`sudo apt install scrot`) and edit the script.
- **Obsidian offline** — the local PNG is still saved; retry by re-uploading `curl -X PUT -H "Authorization: Bearer $OBS_TOKEN" -H "Content-Type: image/png" --data-binary @<file>.png "$OBS_URL/vault/Shadow%20Supply/screenshots/<file>.png"`.
- **Weird names** — non-alphanumeric characters in `NAME` are transliterated to `_` automatically.
