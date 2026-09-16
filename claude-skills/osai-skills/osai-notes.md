Capture a pentest finding: write it to the authoritative JSON store AND mirror it into the Obsidian vault as a linked, tagged note. $ARGUMENTS = finding details as flags or free-form description.

Flags: --host <IP> --title <name> --severity <Critical|High|Medium|Low|Info> --evidence <one-liner> --steps <reproduction> --cve <CVE or N/A> --owasp <LLM0x or N/A> --source <how found> --screenshot <filename>

Examples:
- /osai-notes --host 10.10.10.5 --title "MSSQL xp_cmdshell RCE" --severity Critical --evidence "xp_cmdshell 'whoami' → nt authority\system"
- /osai-notes --host 10.10.20.9 --title "Indirect prompt injection leaks proof" --severity High --owasp LLM01 --source prompt-injection
- /osai-notes --list        (table from findings.json)
- /osai-notes --update F-001 --screenshot screen01.png

## Two stores, one command
- **findings.json** (`~/osai/current/loot/`) — AUTHORITATIVE, local disk, always written. /osai-report and /osai-plan read this.
- **Obsidian vault** — human view, mirror. **PREFER `mcp__obsidian__vault_*` (works regardless of hgfs mount).** The direct hgfs write to `~/osai/notes/*.md` is a fallback and gated by `test -f ~/osai/notes/.vault-ok`. If BOTH paths fail, write JSON, warn once, keep going — never block.

## Step 1: Parse input
Extract host, title, severity; optional steps, cve, owasp, source, screenshot. If host/title/severity missing — ask, don't default.

## Step 2: Load findings log (authoritative)
```bash
mkdir -p ~/osai/current/loot
[ -f ~/osai/current/loot/findings.json ] || echo '[]' > ~/osai/current/loot/findings.json
```

## Step 3: Auto-tag technique + OWASP class
MITRE ATT&CK from title keywords: RCE/xp_cmdshell/cmd exec → T1059 · PTH/NTLM → T1550.002 · Kerberoast → T1558.003 · ASREPRoast → T1558.004 · DCSync → T1003.006 · SSRF → T1090 (+ATLAS AML.T0057) · creds/config → T1552 · SUID/sudo/cap → T1548.001 · cron/task → T1053 · DLL/PATH/module hijack → T1574 · token/impersonation → T1134 · LSASS/secretsdump → T1003 · prompt injection/RAG → ATLAS AML.T0051.
OWASP-LLM (AI findings): injection→LLM01 · disclosure→LLM02 · supply chain→LLM03 · poisoning→LLM04 · output-handling→LLM05 · excessive agency→LLM06 · sys-prompt leak→LLM07 · embeddings→LLM08. AI findings are the 15-pointers — always tag `owasp` and `source`.

## Step 4: Append entry to findings.json
```json
{
  "id": "F-<auto-increment, 3 digits>",
  "ts": "<ISO timestamp>",
  "host": "<host>", "title": "<title>", "severity": "<severity>",
  "evidence": "<evidence>", "steps": "<steps or TBD>",
  "cve": "<CVE or N/A>", "mitre": "<technique>", "owasp": "<LLM0x or N/A>",
  "source": "<how found — e.g. netexec, winpeas, prompt-injection, RAG, IMDS>",
  "screenshot": "<filename or pending>", "sysreptor_exported": false
}
```

## Step 4b: Mirror into the Obsidian vault (gated)
```bash
test -f ~/osai/notes/.vault-ok || { echo "[!] vault down — JSON written, skipping Obsidian mirror"; }
```
If the gate passes, do all three:

**(a) Finding note** → `~/osai/notes/findings/<F-ID>.md` — Dataview-friendly frontmatter + human block:
```markdown
---
id: F-001
host: "10.10.10.5"
severity: Critical
type: finding
mitre: T1059
owasp: N/A
cve: N/A
source: mssql
screenshot: pending
tags: [finding, critical, "host/10.10.10.5"]
---
# <TITLE>
**Host:** [[hosts/<host>|<host>]] · **Severity:** Critical · **MITRE:** T1059 · **OWASP:** N/A
## Evidence
​```
<evidence verbatim>
​```
## Steps to reproduce
<steps or TBD>
## Recommendation
<one line matched to severity>
```

**(b) Host note** → `~/osai/notes/hosts/<host>.md` — create if missing, then append/refresh:
```markdown
---
host: "10.10.10.5"
os: <win|linux|unknown>
role: <workstation|server|DC|AI|web|unknown>
status: <recon|foothold|priv|owned>
points: 0
tags: [host]
---
# <host>
## Open services
<from recon/network_map.md>
## Credentials
- see [[creds]]  (source-tagged in creds.json)
## Findings
- [[findings/F-001]] — <title> (Critical)
## Proof
<PROOF-<host> when captured>
## Chain
<where this host sits: entry / pivot / DC / AI target>
```
Append the new `- [[findings/F-ID]]` line under the host's **Findings** (don't duplicate).

**(c) Index** → `~/osai/notes/index.md` — create once with a live dashboard:
```markdown
# OSAI Engagement — <LAB>
## Scoreboard
​```dataview
TABLE host, severity, mitre, owasp, screenshot FROM #finding SORT severity ASC
​```
## Proofs (scored)
​```dataview
TABLE host, flag_path, screenshot FROM #proof
​```
## Hosts
​```dataview
TABLE role, status, points FROM #host SORT points DESC
​```
```
(Dataview renders these in Obsidian; plain Markdown if the plugin is absent.)

## Step 5: Print the SysReptor block (derived — for the report)
Same content as the finding note, in SysReptor paste format (## title, Host/Severity/ID/Date/MITRE, Summary, Evidence, Steps, Recommendation, References). /osai-report batches these later.

## Step 6: Screenshot reminder
If screenshot is pending:
```
[!] SCREENSHOT REQUIRED: F-<ID> — <TITLE>
    flameshot gui -p ~/osai/current/screenshots/<host>_<slug>.png
    then: /osai-notes --update F-<ID> --screenshot <file>
```
(--update edits BOTH the JSON entry and the finding-note frontmatter.)

## --list
Table from findings.json: `ID  Severity  Host  Title  Screenshot`. Summary: `N findings — X pending screenshots, Y missing steps`.

## --flag (proof capture)
`/osai-notes --flag --host <IP> --file <path> --screenshot <path>`

**HARD GATE — screenshot is REQUIRED, not optional.** OSAI scoring: "unscreenshotted proof scores 0." If `--screenshot` is missing, do NOT append the flag to findings.json. Instead:
```
[BLOCKED] Flag capture requires a screenshot.
  Capture one first:
    ~/osai/bin/osai-screenshot.sh proof-<host> --cmd -- <the command that reads the proof>
  The tool returns the Obsidian-relative path — pass that back as --screenshot.
  Re-run: /osai-notes --flag --host <IP> --file <path> --screenshot <returned-path>
```
Only after `--screenshot` is provided AND the file exists locally OR in the vault (`Shadow Supply/screenshots/*.png`), proceed:

1. `cat <path>` (e.g. C:\Users\Administrator\Desktop\proof.txt or /root/proof.txt).
2. Append to findings.json:
```json
{ "id": "PROOF-<host>", "ts": "<ISO>", "host": "<host>", "title": "Proof: <path>",
  "severity": "Info", "type": "flag", "flag_value": "<contents>", "flag_path": "<path>",
  "source": "<shell|prompt-injection|RAG|SSRF>", "screenshot": "<vault or local path>", "sysreptor_exported": false }
```
(`screenshot` MUST be a real path — never "pending" for a --flag entry.)
3. Vault (gated): write `~/osai/notes/findings/PROOF-<host>.md` with frontmatter `tags: [proof, "host/<host>"]` + the value and the retrieval method; add a **Proof** line to the host note.
4. The screenshot from the gate above IS the proof frame — verify it captures the required content:
   - shell: `whoami`+`hostname`+flag in one frame.
   - AI/no-shell: the exact request (prompt/curl) AND the response/exfil that returned it.
   - If missing, re-capture with `~/osai/bin/osai-screenshot.sh` and update via `/osai-notes --update PROOF-<host> --screenshot <path>`.
5. If host is the **DC** with DA proof:
```
[★] DC OWNED — traditional side done. Stop enumerating Windows; redirect time to AI (15-pointers). Run /osai-report.
```

### --flag --list
All `type:flag` entries: host, path, value, screenshot status. Flag any `screenshot: pending` — zero points without evidence.
