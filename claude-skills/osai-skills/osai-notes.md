Capture a pentest finding with all required fields and emit a SysReptor-paste-ready markdown block. $ARGUMENTS = finding details as flags or free-form description.

Flags: --host <IP> --title <name> --severity <Critical|High|Medium|Low|Info> --evidence <one-liner> --steps <reproduction> --cve <CVE or N/A> --screenshot <filename>

Examples:
- /osai-notes --host 10.10.10.5 --title "MSSQL xp_cmdshell RCE" --severity Critical --evidence "xp_cmdshell 'whoami' returned nt authority\system"
- /osai-notes --list        (show all captured findings)
- /osai-notes --update F-001 --screenshot screen01.png

## Step 1: Parse input
Extract from $ARGUMENTS: host, title, severity, evidence, steps (optional), cve (optional), screenshot (optional).
If host, title, or severity is missing — ask for it. Do not silently default.

## Step 2: Load findings log
File: ~/osai/current/loot/findings.json (create as `[]` if missing)
```bash
mkdir -p ~/osai/loot
[ -f ~/osai/current/loot/findings.json ] || echo '[]' > ~/osai/current/loot/findings.json
```

## Step 3: Auto-assign MITRE ATT&CK technique
Map title keywords:
- xp_cmdshell / RCE / command execution → T1059 (Command and Scripting Interpreter)
- NTLM / pass-the-hash / PTH → T1550.002 (Pass the Hash)
- Kerberoast → T1558.003 (Kerberoasting)
- ASREPRoast → T1558.004 (AS-REP Roasting)
- DCSync → T1003.006 (DCSync)
- prompt injection / RAG → ATLAS AML.T0051 (LLM Prompt Injection)
- SSRF → T1090 + ATLAS AML.T0057 (LLM Data Leakage)
- credential / password / config file → T1552 (Unsecured Credentials)
- SUID / sudo / capability → T1548.001 (Setuid/Setgid)
- cron / scheduled task → T1053 (Scheduled Task/Job)
- module hijack / DLL / PATH → T1574 (Hijack Execution Flow)
- token / impersonation → T1134 (Access Token Manipulation)
- secretsdump / LSASS → T1003 (OS Credential Dumping)

## Step 4: Write entry to findings.json
```json
{
  "id": "F-<auto-increment padded to 3 digits>",
  "ts": "<ISO timestamp>",
  "host": "<host>",
  "title": "<title>",
  "severity": "<severity>",
  "evidence": "<evidence>",
  "steps": "<steps or TBD>",
  "cve": "<CVE or N/A>",
  "mitre": "<technique ID>",
  "screenshot": "<filename or pending>",
  "sysreptor_exported": false
}
```

## Step 5: Print SysReptor-ready markdown block

```markdown
## <TITLE>

**Host:** <HOST>
**Severity:** <SEVERITY>
**ID:** <F-ID>
**Date:** <DATE>
**MITRE ATT&CK:** <TECHNIQUE ID and NAME>

### Summary
<One-sentence vulnerability description and impact>

### Evidence
```
<EVIDENCE — verbatim>
```

### Steps to Reproduce
<STEPS>

### Recommendation
<Brief remediation matched to severity>

### References
- CVE: <CVE or N/A>
- MITRE ATT&CK: <link or ID>
```

## Step 6: Screenshot reminder
If screenshot is "pending":
```
[!] SCREENSHOT REQUIRED: F-<ID> — <TITLE>
    flameshot gui -p ~/osai/current/screenshots/
    scrot ~/osai/current/screenshots/<hostname>_<finding>.png
    Then update: /osai-notes --update F-<ID> --screenshot <filename>
```

## Finding list (--list flag)
Load findings.json. Print table:
```
ID     Severity  Host           Title                          Screenshot
F-001  Critical  10.10.10.5     MSSQL xp_cmdshell RCE          screen01.png
F-002  High      10.10.10.10    WinRM PTH Access               pending ⚠️
```
Summary: `N findings — X pending screenshots, Y missing steps`

## Flag / Proof Capture (--flag mode)
`/osai-notes --flag --host <IP> --file <path>` — logs a captured flag as a scored proof entry.

### Steps
1. Read the flag file value:
```bash
cat <path>   # e.g. C:\Users\Administrator\Desktop\proof.txt  or  /root/proof.txt
```
2. Append a proof entry to findings.json with a dedicated type:
```json
{
  "id": "PROOF-<host>",
  "ts": "<ISO timestamp>",
  "host": "<host>",
  "title": "Proof captured: <path>",
  "severity": "Info",
  "type": "flag",
  "flag_value": "<contents of file>",
  "flag_path": "<path>",
  "mitre": "N/A",
  "screenshot": "pending",
  "sysreptor_exported": false
}
```
3. Print the proof block and a screenshot reminder — the screenshot MUST show
   `whoami` (or `hostname`) alongside the flag contents to be accepted as evidence:
```
[+] PROOF LOGGED: <host> — <path>
    Value: <flag_value>
[!] SCREENSHOT REQUIRED (whoami + hostname + flag visible in one frame):
    flameshot gui -p ~/osai/current/screenshots/
```
4. If the host is the **DC** and this is Domain Admin proof — remind:
```
[★] DOMAIN CONTROLLER OWNED — traditional side complete.
    Stop enumerating Windows hosts. Redirect remaining time to AI-vector points.
    Run /osai-report to confirm all findings + proofs are captured.
```

### Proof list (--flag --list)
Print all `type:flag` entries: host, path, value, screenshot status.
Flag any with `screenshot: pending` — those score zero without evidence.
