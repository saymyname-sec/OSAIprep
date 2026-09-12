Fan out port scans and service enumeration across multiple targets simultaneously. $ARGUMENTS = comma-separated IPs or CIDR, plus optional flags: --fast (top-1000 only), --deep (all ports + vuln scripts).

## Step 1: Prepare output directory
```bash
mkdir -p ~/osai/recon
TS=$(date +%Y%m%d_%H%M%S)
```

## Step 2: Fan out scans in parallel (background jobs)
For each target in $ARGUMENTS:

**--fast:**
```bash
nmap -T4 --top-ports 1000 -oN ~/osai/current/recon/<IP>_$TS.txt <IP> &
```

**default:**
```bash
nmap -T4 -sV --top-ports 1000 -sC -oN ~/osai/current/recon/<IP>_$TS.txt <IP> &
```

**--deep:**
```bash
nmap -T4 -sV -p- --script=vuln -oN ~/osai/current/recon/<IP>_$TS.txt <IP> &
```

Wait for all: `wait`

## Step 3: Extract and triage each result (token-efficient)
For each scan file — DO NOT read full file into context. Extract only open ports:
```bash
grep -E '^[0-9]+/tcp.*open' ~/osai/current/recon/<IP>_$TS.txt
```

**Critical attack surface:**
- 445 → SMB: check signing, enum shares
- 5985/5986 → WinRM: credential target
- 1433 → MSSQL: impacket-mssqlclient
- 3389 → RDP: credential target
- 88 → Kerberos: ASREPRoast candidates
- 389/636/3268 → LDAP: AD enumeration
- 22 → SSH: credential target
- 2049 → NFS: showmount
- 111 → RPC: rpcclient null session

**AI surface (flag for /osai-ai-hunter):**
- 11434, 1234, 8000, 5000, 7860, 3000 → LLM inference / chatbot

**Web surface:**
- 80, 443, 8080, 8443 → add to web enum queue

## Step 4: Print follow-up commands for each flagged service

**SMB (445 open):**
```bash
crackmapexec smb <IP> --shares -u '' -p ''
crackmapexec smb <IP> --shares -u 'guest' -p ''
smbclient -L //<IP> -N
```

**Web (80/443 open):**
```bash
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 40 -o ~/osai/current/recon/<IP>_web_$TS.txt
whatweb http://<IP>
```

**LDAP (389 open — likely DC):**
```bash
ldapsearch -x -H ldap://<IP> -b "" -s base namingContexts
ldapsearch -x -H ldap://<IP> -b "DC=domain,DC=local" "(objectClass=user)" sAMAccountName
```

**NFS (2049 open):**
```bash
showmount -e <IP>
# If share found: sudo mount -t nfs <IP>:/share /mnt/nfs -o nolock
```

**RPC (111 open):**
```bash
rpcclient -U "" <IP> -N
# Commands in rpcclient: enumdomusers, enumdomgroups, querydominfo
```

## Step 5: Summary triage table
```
=== RECON TRIAGE: <timestamp> ===
HOST          PORTS                      PRIORITY    NEXT ACTION
<IP>          445,5985,3389              CRITICAL    PTH/WinRM/RDP
<IP>          80,443,11434               HIGH        Web+AI enum → /osai-ai-hunter
<IP>          22                         MEDIUM      Cred spray
```

Write triage to ~/osai/current/state/recon_summary.md (append).
Append each new host to ~/osai/current/state/network_map.md (IP, open ports, OS guess, role guess, timestamp).

## Token discipline
- Extract open ports with grep — never paste full nmap output into context
- Max 100 lines from any single scan file
- If host has >20 open ports, show only top-priority 10 in context; rest in file
