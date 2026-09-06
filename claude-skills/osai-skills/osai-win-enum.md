Enumerate a Windows host and/or Active Directory environment using KNOWN, STANDARD tools — never custom scripts. Analyze the context in $ARGUMENTS, reason about the host's role and the likely attack path FIRST, then run the standard enumeration in order and route findings to the right attack skill. Write results to ~/osai/current/loot/<hostname>_enum.md.

$ARGUMENTS = hostname/IP, current privilege (user/local-admin/SYSTEM), OS, and any recon already done. If empty, print the Phase 1 commands to run first.

## RULE ZERO — do NOT write custom enumeration or privesc scripts
This is the #1 mistake on a Windows host. Before writing a single line of PowerShell/batch:
- The tool ALREADY EXISTS. winPEAS, PowerUp, Seatbelt, SharpHound, PowerView, netexec,
  BloodHound, Snaffler, ADModule — one of them does what you're about to hand-code.
- Writing a custom `Get-ChildItem`/`reg query` loop to "enumerate services" duplicates
  winPEAS/PowerUp badly and misses cases they cover. Don't.
- **Reason about the attack path BEFORE running anything.** Ask: what is this host FOR,
  what privilege do I have, what's the most likely escalation given the role? Then run the
  standard tool that tests that hypothesis — not a scattershot of custom commands.
- Only write code when: (a) you've confirmed no standard tool fits, AND (b) it's a tiny,
  single-purpose one-liner. Even then, prefer adapting a known PoC.
If you catch yourself drafting a >5-line script, STOP and pick the standard tool instead.

## Phase 0: Reason first (state this before running tools)
```
HOST ROLE:   <workstation / member server / DC / SQL / web / jump box — infer from services>
PRIVILEGE:   <who am I: user / local admin / SYSTEM / domain user>
HYPOTHESIS:  <most likely path given role+priv — e.g. "SeImpersonate on a service acct → Potato">
TOOL TO RUN: <the standard tool that confirms/exploits that hypothesis>
```
Enumeration answers a question you already framed. Don't enumerate blind.

## Phase 1: Local host context (fast, no tools to drop)
```cmd
whoami /all                          & :: SID, groups, PRIVILEGES (SeImpersonate/SeBackup/etc.)
systeminfo                           & :: OS build, hotfixes → kernel exploit check
hostname & ipconfig /all             & :: role, subnets, DNS = DC
net users & net localgroup administrators
echo %USERDOMAIN% & set             & :: domain-joined? env vars with creds?
cmdkey /list                         & :: stored credentials
```
```powershell
# Token privileges are the fastest local-priv win — check first
whoami /priv
# Stored creds / interesting files
Get-ChildItem -Path C:\Users -Recurse -Include *.kdbx,*.config,unattend.xml,web.config,*.ps1 -EA SilentlyContinue
```
**Read `whoami /priv` FIRST.** SeImpersonate/SeAssignPrimaryToken → Potato (route to /osai-winpeas).
SeBackup/SeRestore → SAM+SYSTEM dump. SeDebug → LSASS. These are instant wins, no PEAS needed.

## Phase 2: Automated local enum (drop the standard tool, then triage)
```powershell
# winPEAS — the canonical Windows privesc enumerator
.\winPEASx64.exe > winpeas.txt          # then: /osai-winpeas winpeas.txt

# PowerUp — service/registry/DLL privesc checks
powershell -ep bypass -c "Import-Module .\PowerUp.ps1; Invoke-AllChecks"

# Seatbelt — host survey (creds, tokens, defensive posture)
.\Seatbelt.exe -group=all

# Snaffler — hunt creds across shares (domain context)
.\Snaffler.exe -s -o snaffler.log
```
Never paste raw PEAS/Seatbelt output into chat — pipe through /osai-winpeas.

## Phase 3: Active Directory enumeration (domain-joined host or from Kali)
### From Kali (with any domain creds) — preferred, no tools on target
```bash
# netexec (NOT crackmapexec — renamed) — the swiss-army enum tool
netexec smb <DC_IP> -u <user> -p '<pass>' --users --groups --shares --pass-pol
netexec smb <SUBNET> -u <user> -p '<pass>'                 # find hosts + signing status
netexec ldap <DC_IP> -u <user> -p '<pass>' --bloodhound -c All --dns-server <DC_IP>
# BloodHound remote collection
bloodhound-python -u <user> -p '<pass>' -d <domain> -dc <DC_FQDN> -c All -ns <DC_IP> --zip
# enum4linux-ng / rpcclient for null-session or basic enum
enum4linux-ng -A <DC_IP>
rpcclient -U '' -N <DC_IP> -c 'enumdomusers'
# LDAP dump
ldapsearch -x -H ldap://<DC_IP> -D '<user>@<domain>' -w '<pass>' -b 'DC=corp,DC=local'
```
### From a Windows foothold
```powershell
# PowerView / SharpHound — see /osai-ad-attack for the full PowerView query set
.\SharpHound.exe -c All --zipfilename loot.zip
Import-Module .\PowerView.ps1; Get-Domain; Get-DomainUser -SPN
# Native AD module (signed, OPSEC-friendly) — no PowerView needed
Get-ADUser -Filter * -Properties ServicePrincipalName,Description
```
**Always run BloodHound early** — it finds ACL edges (GenericAll/WriteDACL/ForceChangePassword)
that manual enum misses. Then hand paths to /osai-ad-attack.

## Phase 4: Route findings — do NOT attack from here, hand off
| Finding | Route to |
|---------|----------|
| Token priv (SeImpersonate etc.) / service / registry finding | `/osai-winpeas` |
| Writable path a service/scheduled-task/loader trusts | `/osai-hijack` |
| Domain users/groups/SPNs/ACL edges/delegation | `/osai-ad-attack` |
| Any credential found (file, cmdkey, registry, share) | `/osai-cred-vault --add` |
| Creds + more hosts reachable | `/osai-spray` |
| New subnet visible | `/osai-pivot` → then re-recon |

## Phase 5: Output
```
HOST: <name>  ROLE: <role>  PRIV: <level>
CONTEXT: <key facts — domain, privileges, stored creds>
ATTACK PATHS (ranked):
  1. <path> — evidence: <what enum showed> — route: <skill> — likelihood/why
  2. ...
CREDS FOUND: <list → all sent to /osai-cred-vault>
NEXT: <the single highest-EV action>
```
Write to ~/osai/current/loot/<hostname>_enum.md. Keep raw tool dumps in files, not chat.
