Triage the raw pentest tool output provided in $ARGUMENTS. Score findings by severity, extract only actionable lines, and suppress noise. Never reproduce the full input back — only the extracted findings.

## Scope — NOT for HexStrike output
**HexStrike returns structured JSON — read its fields directly, do NOT triage it.** This skill is only for output HexStrike does not wrap: linPEAS/winPEAS, manual commands, Metasploit console, LLM responses.

## Parse from a FILE, never a paste
Redirect the tool to a file, `grep -c` it FIRST, and filter anything over ~200 lines BEFORE reading — a deterministic `grep` costs zero model tokens; reading a raw dump costs thousands.
```bash
grep -c . <file>                                   # count first; if >~200 lines, tighten pattern before reading
# linPEAS / winPEAS — flagged findings only
grep -aE '95%|99%|\[\!\]|Vulnerable|CVE-[0-9]|SUID|cap_|NOPASSWD|AlwaysInstall' peas.txt
# netexec — wins only
grep -aE '\(Pwn3d!\)|\[\+\]|Signing:? *False' nxc.txt
# Metasploit console log
grep -aE 'session [0-9]+ opened|Command shell session|Login Successful|\[\+\]|SYSTEM' msf.log
```

## Step 1: Identify tool type from output format
- `Nmap scan report` / `PORT STATE SERVICE` → nmap
- `SMB` / `[+]` / `(Pwn3d!)` → NetExec
- `[*]` / `Administrator` / `NTDS` → Impacket secretsdump
- `dn:` / `sAMAccountName` → ldapsearch
- `[!!]` / `[+]` color codes → winPEAS / linPEAS
- `{"role"` / `"model"` / `"content"` → LLM API response
- Anything else → generic log

## Step 2: Apply severity filter

**Nmap:**
- CRITICAL: ports 445, 5985, 5986, 1433, 3389, 88, 389, 636
- HIGH: 80, 443, 8080, 8443, 22, 21, 2049, 111, 5432, 3306, 11434, 1234, 8000, 5000, 7860
- SUPPRESS: closed/filtered ports, timing lines

**NetExec:**
- CRITICAL: `(Pwn3d!)`, `Signing: False`, admin share access
- HIGH: `[+]` success lines, open shares, usernames
- SUPPRESS: `[-]` failed auth lines

**Secretsdump/Mimikatz:**
- ALL credential lines are CRITICAL — keep every hash and password verbatim

**LLM API:**
- CRITICAL: model version disclosed, file contents in response, internal paths
- HIGH: tool list disclosed, system prompt partial reveal
- SUPPRESS: normal responses > 200 chars unless containing path or key

**Generic:**
- CRITICAL: password, secret, key, token, admin, root, SYSTEM, flag{, proof.txt
- HIGH: IPs, hostnames, usernames, version numbers
- SUPPRESS: progress bars, timestamps, blank lines

## Step 3: Output format

Print ONLY:
```
=== TRIAGE: <tool type> | <timestamp> ===
[CRITICAL]
  <line>
[HIGH]
  <line>
[MEDIUM]
  <line>

SUMMARY: <1-2 sentence attack surface assessment>
NEXT: <most promising next action>
```

If nothing critical/high: print `[CLEAN] No high-value findings.`
