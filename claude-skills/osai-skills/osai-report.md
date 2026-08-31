Compile all engagement findings into a SysReptor-paste-ready report. $ARGUMENTS = optional flags: --chain 1, --chain 2, --final.

## Step 1: Load state (token-efficient)
```bash
# Findings summary
jq '[.[] | {id, title, severity, host, mitre, screenshot}]' ~/osai/current/loot/findings.json 2>/dev/null

# Credential count and list
jq '[.[] | {host, domain, username, type, source}]' ~/osai/current/state/creds.json 2>/dev/null

# Scope and network map
cat ~/osai/current/state/scope.md
cat ~/osai/current/state/network_map.md
```

## Step 2: Executive summary
```markdown
## Executive Summary

**Engagement:** OSAI-300 Certification Exam
**Date:** <DATE>
**Domain:** <DOMAIN from scope.md>
**Assessor:** Kapi

During this assessment, <N critical> critical and <N high> high-severity vulnerabilities
were identified across <X> target hosts. Successful compromise of <N> attack chains was
achieved, including <brief chain description e.g. "full domain compromise via MSSQL
xp_cmdshell → SeImpersonatePrivilege → DCSync">. AI-specific vulnerabilities included
<brief e.g. "indirect prompt injection via RAG poisoning and unvalidated LLM tool access">.
```

## Step 3: Finding summary table (sorted Critical → Low)
```markdown
## Finding Summary

| ID | Severity | Host | Title | MITRE |
|----|----------|------|-------|-------|
| F-001 | Critical | 10.10.10.5 | MSSQL xp_cmdshell RCE | T1059 |
| ... | ... | ... | ... | ... |
```

## Step 4: Per-chain attack narrative
For each chain (or all if no --chain flag):
```markdown
## Attack Chain <N>: <Name>

### Entry Point
<Host and initial access method>

### Attack Path
1. **<Host>** — <technique> — `<key command>`
2. **<Host>** — <lateral move> — `<key command>`
3. ...

### Outcome
<What was achieved: DA, file exfil, flag, etc.>

### Findings in this chain
<F-IDs that belong to this chain>
```

## Step 5: Credential table (full, no truncation)
```markdown
## Recovered Credentials

| Host | Domain\User | Type | Secret | Source |
|------|-------------|------|--------|--------|
| 10.10.10.5 | CORP\Administrator | NTLM | aad3b435... | secretsdump |
| ... | ... | ... | ... | ... |
```

## Step 6: MITRE ATT&CK mapping table
```markdown
## MITRE ATT&CK Mapping

| Tactic | Technique | ID | Finding |
|--------|-----------|----|---------|
| Initial Access | Exploit Public-Facing Application | T1190 | F-001 |
| Execution | Command and Scripting Interpreter | T1059 | F-001 |
| Privilege Escalation | Token Impersonation | T1134 | F-002 |
| Lateral Movement | Pass the Hash | T1550.002 | F-003 |
| Collection | Data from Local System | T1005 | F-004 |
| Impact | Domain Controller Compromise | T1078 | F-00X |
```
For AI findings add ATLAS techniques alongside MITRE.

## Step 7: SysReptor paste guide
```
=== SYSREPTOR PASTE GUIDE ===

For each finding entry in SysReptor:
│ Title field     → paste Finding title (F-00X)
│ Description     → paste Summary paragraph
│ Attack Narrative → paste Steps to Reproduce
│ Evidence        → paste command output (trimmed to key lines)
│ Screenshot      → drag from ~/osai/current/screenshots/<filename>
│ CVSS            → Critical=9.8, High=7.5, Medium=5.0, Low=2.5
│ ATLAS           → paste from MITRE table (AI findings only)
└ Remediation     → paste Recommendation from finding block
```

## Step 8: Missing evidence check
For findings with `screenshot: pending`:
```
[!] MISSING SCREENSHOT: F-00X — <title> on <host>
    flameshot gui -p ~/osai/current/screenshots/
```
For findings with `steps: TBD`:
```
[!] MISSING STEPS: F-00X — add reproduction steps before submitting
```

## Step 9: Write output
Write to ~/osai/current/loot/report_<timestamp>.md
Print: `[+] Report ready: ~/osai/current/loot/report_<timestamp>.md — N findings, X creds, Y chains`
