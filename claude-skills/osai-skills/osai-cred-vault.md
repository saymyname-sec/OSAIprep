Manage the engagement credential vault. $ARGUMENTS = action and credential data.

Actions:
- `/osai-cred-vault add <creds>` — log new credentials
- `/osai-cred-vault list` — show all credentials as table
- `/osai-cred-vault query <term>` — search by host/user/domain and print PTH commands
- `/osai-cred-vault spray <targets>` — print spray commands for all plaintext passwords
- `/osai-cred-vault export` — reptor-finding JSON + Obsidian creds.md

State file: ~/osai/current/state/creds.json (JSON array)

## Action: add
Parse free-form credential input — accepts:
- `user:pass@host`
- Mimikatz output blocks
- secretsdump lines: `domain\user:RID:LM:NTLM:::`
- key:value pairs

Load ~/osai/current/state/creds.json (create `[]` if missing). Check for exact duplicates (same username + secret). Append new entry:
```json
{
  "id": "<auto-increment>",
  "ts": "<ISO timestamp>",
  "host": "<hostname or IP>",
  "domain": "<domain or WORKGROUP>",
  "username": "<username>",
  "secret": "<password/hash/ticket/key>",
  "type": "<plaintext|ntlm|net-ntlmv2|aes256|aes128|rc4|tgt|st|ssh-key|api-key|token|other>",
  "source": "<secretsdump/mimikatz/LSASS/config/env/RAG/etc>",
  "valid_on": ["<host>"],
  "cracked": false,
  "notes": ""
}
```
Print: `[+] Added: DOMAIN\user — type — host`

**AI-machine creds:** set `source` to the attack class that recovered them — `prompt-injection`, `RAG`, `IMDS`, `SSRF`, etc. That field drives the SysReptor finding, and AI machines are the 15-pointers — tag them precisely so the report attributes the points correctly.

## Action: list
Load creds.json. Print markdown table:
```
| # | Host | Domain\User | Type | Secret (truncated 30) | Source | Valid On |
```
Highlight NTLMs appearing for multiple users (reuse indicator).
Print count: `X creds total — Y plaintext, Z hashes, W tickets`

## Action: query <term>
Filter entries where host, username, domain, or source contains term (case-insensitive). Print full untruncated details. For each NTLM hash found, also print:
```bash
# Pass-the-Hash commands
impacket-psexec DOMAIN/user@TARGET -hashes :NTLM
impacket-wmiexec DOMAIN/user@TARGET -hashes :NTLM
evil-winrm -i TARGET -u user -H NTLM
```

## Action: spray <targets>
**Lockout pre-check FIRST** — a blind spray locks accounts (default AD lockout is often 5):
```bash
netexec smb <DC> -u '' -p '' --pass-pol
```
Then load all unique plaintext passwords from creds.json. For each:
```bash
netexec smb <targets> -u users.txt -p '<password>' --continue-on-success
kerbrute passwordspray -d DOMAIN --dc DC_IP users.txt '<password>'
```
Log every hit back with `/osai-cred-vault add`.

## Action: export
Emit JSON shaped for the SysReptor CLI (`reptor finding`), NOT paste-ready markdown — write to
~/osai/current/loot/creds_export.json (consume with `reptor finding < creds_export.json`). Also
write ~/osai/notes/creds.md so creds are visible in Obsidian — but gate it: `test -f
~/osai/notes/.vault-ok` first; if it fails, skip the notes copy with a warning (never write to the
share silently). Print a summary to stdout.

## Directory check
Ensure ~/osai/current/state/ exists: `mkdir -p ~/osai/current/state/`
On parse errors: print the raw line and ask user to confirm format — never silently drop data.

## msfdb sync (when the `metasploit` MCP is up)
`creds.json` is ALWAYS authoritative. msfdb is a durable mirror, not a dependency — never block on it.
- On `add`: also mirror the credential into msfdb through the `metasploit` MCP (store-cred / `creds add` into the lab workspace: user, password-or-hash, realm, host, type). If the MCP is down, just write the JSON and move on.
- On `query`/`list`: read BOTH msfdb (via the MCP) AND creds.json, then merge and dedup by (username + secret) before printing. On any conflict, the JSON file wins.
