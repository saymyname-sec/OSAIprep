.14 endpoint
PS C:\WINDOWS\system32> ./winPEASx64.exe
```
./winPEASx64.exe
 [!] If you want to run the file analysis checks (search sensitive information in files), you need to specify the 'fileanalysis' or 'all' argument. Note that this search might take several minutes. For help, run winpeass.exe --help 
ANSI color bit for Windows is not set. If you are executing this from a Windows terminal inside the host you should run 'REG ADD HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1' and then start a new CMD
Long paths are disabled, so the maximum length of a path supported is 260 chars (this may cause false negatives when looking for files). If you are admin, you can enable it with 'REG ADD HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v VirtualTerminalLevel /t REG_DWORD /d 1' and then start a new CMD
     
               ((((((((((((((((((((((((((((((((                                                                     
        (((((((((((((((((((((((((((((((((((((((((((                                                                 
      ((((((((((((((**********/##########(((((((((((((                                                              
    ((((((((((((********************/#######(((((((((((                                                             
    ((((((((******************/@@@@@/****######((((((((((                                                           
    ((((((********************@@@@@@@@@@/***,####((((((((((                                                         
    (((((********************/@@@@@%@@@@/********##(((((((((                                                        
    (((############*********/%@@@@@@@@@/************((((((((                                                        
    ((##################(/******/@@@@@/***************((((((                                                        
    ((#########################(/**********************(((((                                                        
    ((##############################(/*****************(((((                                                        
    ((###################################(/************(((((                                                        
    ((#######################################(*********(((((                                                        
    ((#######(,.***.,(###################(..***.*******(((((                                                        
    ((#######*(#####((##################((######/(*****(((((                                                        
    ((###################(/***********(##############()(((((                                                        
    (((#####################/*******(################)((((((                                                        
    ((((############################################)((((((                                                         
    (((((##########################################)(((((((                                                         
    ((((((########################################)(((((((                                                          
    ((((((((####################################)((((((((                                                           
    (((((((((#################################)(((((((((                                                            
        ((((((((((##########################)(((((((((                                                              
              ((((((((((((((((((((((((((((((((((((((                                                                
                 ((((((((((((((((((((((((((((((                                                                     

ADVISORY: winpeas should be used for authorized penetration testing and/or educational purposes only. Any misuse of this software will not be the responsibility of the author or of any other collaborator. Use it at your own devices and/or with the device owner's permission.                                                                          
                                                                                                                    
  WinPEAS-ng by @hacktricks_live                                                                                    

       /---------------------------------------------------------------------------------\                          
       |                             Do you like PEASS?                                  |                          
       |---------------------------------------------------------------------------------|                          
       |         Linux PE & Hardening    :     https://hacktricks-training.com/courses/lhe/ |                       
       |         Learn Cloud Hacking       :     training.hacktricks.xyz                 |                          
       |         Follow on Twitter         :     @hacktricks_live                        |                          
       |         Respect on HTB            :     SirBroccoli                             |                          
       |---------------------------------------------------------------------------------|                          
       |                                 Thank you!                                      |                          
       \---------------------------------------------------------------------------------/                          
                                                                                                                    
  [+] Legend:
         Red                Indicates a special privilege over an object or something is misconfigured
         Green              Indicates that some protection is enabled or something is well configured
         Cyan               Indicates active users
         Blue               Indicates disabled users
         LightYellow        Indicates links

 You can find a Windows local PE Checklist here: https://book.hacktricks.wiki/en/windows-hardening/checklist-windows-privilege-escalation.html                                                                                          
 Best Linux PE & Hardening course: https://hacktricks-training.com/courses/lhe/                                     
   Creating Dynamic lists, this could take a while, please wait...                                                  
   - Loading sensitive_files yaml definitions file...
   - Loading regexes yaml definitions file...
   - Checking if domain...
   - Getting Win32_UserAccount info...
   - Creating current user groups list...
   - Creating active users list (local only)...
   - Creating disabled users list...
   - Admin users list...
   - Creating AppLocker bypass list...
   - Creating files/directories list for search...


════════════════════════════════════╣ System Information (T1082,T1068,T1548.002,T1003.001,T1003.004,T1003.005,T1059.001,T1552.001,T1552.002,T1562.001,T1562.002,T1518.001,T1557.001,T1558,T1559,T1134.001,T1547.005,T1484.001,T1613,T1654,T1072,T1187) ╠════════════════════════════════════                                                                

╔══════════╣ Basic System Information (T1082)
╚ Check if the Windows versions is vulnerable to some known exploit https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#version-exploits                                                    
    OS Name: Microsoft Windows Server 2025 Standard
    OS Version: 10.0.26100 N/A Build 26100
    System Type: x64-based PC
    Hostname: SRV1
    Domain Name: researchmco.ai
    ProductName: Windows Server 2025 Standard
    EditionID: ServerStandard
    ReleaseId: 2009
    BuildBranch: ge_release
    CurrentMajorVersionNumber: 10
    CurrentVersion: 6.3
    Architecture: AMD64
    ProcessorCount: 2
    SystemLang: en-US
    KeyboardLang: Polish (Poland)
    TimeZone: (UTC+00:00) Dublin, Edinburgh, Lisbon, London
    IsVirtualMachine: False
    Current Time: 8/16/2026 7:52:18 PM
    HighIntegrity: True
    PartOfDomain: True
    Hotfixes: KB5082417 (4/24/2026), KB5082063 (4/24/2026), KB5082062 (4/24/2026), 


╔══════════╣ Windows Version Vulnerabilities (T1082,T1068)
╚ Product candidates: Windows Server 2025 | Windows Server 2025 (Server Core installation)
╚ Definitions date: 20260801
╚ Installed hotfixes detected: 3
╚ Pre-filter matches: 120, filtered by installed/superseded KBs: 115
Matched 5 known exploited vulnerabilities for this running Windows version.
Matched products: Windows Server 2025 | Windows Server 2025 (Server Core installation)
    CVE-2025-59287 KB5070881 [Critical] Remote Code Execution
    CVE-2023-31096 KB5073379 [Important] Elevation of Privilege
    CVE-2026-45585 KB5094125 [Important] Security Feature Bypass
    CVE-2026-50475 KB5099536 [Important] Information Disclosure
    CVE-2026-58613 KB5099536 [Important] Elevation of Privilege
╚ This check applies version matching with installed/superseded KB filtering.

╔══════════╣ Showing All Microsoft Updates (T1082)
   HotFix ID                :   KB5082063
   Installed At (UTC)       :   4/24/2026 10:35:19 AM
   Title                    :   2026-04 Security Update (KB5082063) (26100.32690)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   Install this update to resolve issues in Windows. For a complete listing of the issues that are included in this update, see the associated Microsoft Knowledge Base article for more information. After you install this item, you may have to restart your computer.

   =================================================================================================

   HotFix ID                :   KB5082417
   Installed At (UTC)       :   4/24/2026 10:06:37 AM
   Title                    :   2026-04 .NET Framework Security Update (KB5082417)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   A security issue has been identified in a Microsoft software product that could affect your system. You can help protect your system by installing this update from Microsoft. For a complete listing of the issues that are included in this update, see the associated Microsoft Knowledge Base article. After you install this update, you may have to restart your system.

   =================================================================================================

   HotFix ID                :   
   Installed At (UTC)       :   4/24/2026 9:32:02 AM
   Title                    :   9PLJQ12FQ3CV-MicrosoftCorporationII.WinAppRuntime.Main.1.8
   Client Application ID    :   Acquisition;setup-StartProductInstallWithOptionsAsync
   Description              :   9PLJQ12FQ3CV-1152921505700706468

   =================================================================================================

   HotFix ID                :   
   Installed At (UTC)       :   4/24/2026 9:32:01 AM
   Title                    :   9NKRJ3SJ9SDG-Microsoft.WindowsAppRuntime.1.8
   Client Application ID    :   Acquisition;setup-StartProductInstallWithOptionsAsync
   Description              :   9NKRJ3SJ9SDG-1152921505700878723

   =================================================================================================

   HotFix ID                :   KB2267602
   Installed At (UTC)       :   4/24/2026 9:20:25 AM
   Title                    :   Security Intelligence Update for Microsoft Defender Antivirus - KB2267602 (Version 1.449.272.0) - Current Channel (Broad)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   Install this update to revise the files that are used to detect viruses, spyware, and other potentially unwanted software. Once you have installed this item, it cannot be removed.

   =================================================================================================

   HotFix ID                :   KB890830
   Installed At (UTC)       :   4/24/2026 9:18:23 AM
   Title                    :   Windows Malicious Software Removal Tool x64 - v5.140 (KB890830)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   After the download, this tool runs one time to check your computer for infection by specific, prevalent malicious software (including Blaster, Sasser, and Mydoom) and helps remove any infection that is found. If an infection is found, the tool will display a status report the next time that you start your computer. A new version of the tool will be offered every month. If you want to manually run the tool on your computer, you can download a copy from the Microsoft Download Center, or you can run an online version from microsoft.com. This tool is not a replacement for an antivirus product. To help protect your computer, you should use an antivirus product.

   =================================================================================================

   HotFix ID                :   KB2267602
   Installed At (UTC)       :   4/24/2026 9:17:19 AM
   Title                    :   Security Intelligence Update for Microsoft Defender Antivirus - KB2267602 (Version 1.449.272.0) - Current Channel (Broad)
   Client Application ID    :   Windows Defender
   Description              :   Install this update to revise the files that are used to detect viruses, spyware, and other potentially unwanted software. Once you have installed this item, it cannot be removed.

   =================================================================================================

   HotFix ID                :   KB5007651
   Installed At (UTC)       :   4/24/2026 9:16:29 AM
   Title                    :   Update for Windows Security platform - KB5007651 (Version 10.0.29554.1001)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   This package will update Windows Security platform components on the user machine.

   =================================================================================================

   HotFix ID                :   KB2267602
   Installed At (UTC)       :   3/18/2026 11:36:20 AM
   Title                    :   Security Intelligence Update for Microsoft Defender Antivirus - KB2267602 (Version 1.445.603.0) - Current Channel (Broad)
   Client Application ID    :   Windows Defender
   Description              :   Install this update to revise the files that are used to detect viruses, spyware, and other potentially unwanted software. Once you have installed this item, it cannot be removed.

   =================================================================================================

   HotFix ID                :   KB4052623
   Installed At (UTC)       :   3/18/2026 11:26:09 AM
   Title                    :   Update for Microsoft Defender Antivirus antimalware platform - KB4052623 (Version 4.18.26010.5) - Current Channel (Broad)
   Client Application ID    :   Windows Defender
   Description              :   This package will update Microsoft Defender Antivirus antimalware platform’s components on the user machine.

   =================================================================================================

   HotFix ID                :   
   Installed At (UTC)       :   3/18/2026 11:20:07 AM
   Title                    :   9PLJQ12FQ3CV-MicrosoftCorporationII.WinAppRuntime.Main.1.8
   Client Application ID    :   Acquisition;setup-StartProductInstallWithOptionsAsync
   Description              :   9PLJQ12FQ3CV-1152921505700530282

   =================================================================================================

   HotFix ID                :   
   Installed At (UTC)       :   3/18/2026 11:20:07 AM
   Title                    :   9NKRJ3SJ9SDG-Microsoft.WindowsAppRuntime.1.8
   Client Application ID    :   Acquisition;setup-StartProductInstallWithOptionsAsync
   Description              :   9NKRJ3SJ9SDG-1152921505700529398

   =================================================================================================

   HotFix ID                :   
   Installed At (UTC)       :   3/18/2026 11:19:37 AM
   Title                    :   9PLJQ12FQ3CV-MicrosoftCorporationII.WinAppRuntime.Main.1.8
   Client Application ID    :   Acquisition;setup-StartProductInstallWithOptionsAsync
   Description              :   9PLJQ12FQ3CV-1152921505700530282

   =================================================================================================

   HotFix ID                :   
   Installed At (UTC)       :   3/18/2026 11:19:37 AM
   Title                    :   9NKRJ3SJ9SDG-Microsoft.WindowsAppRuntime.1.8
   Client Application ID    :   Acquisition;setup-StartProductInstallWithOptionsAsync
   Description              :   9NKRJ3SJ9SDG-1152921505700529398

   =================================================================================================

   HotFix ID                :   KB5078740
   Installed At (UTC)       :   3/17/2026 3:52:34 PM
   Title                    :   2026-03 Security Update (KB5078740) (26100.32522)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   Install this update to resolve issues in Windows. For a complete listing of the issues that are included in this update, see the associated Microsoft Knowledge Base article for more information. After you install this item, you may have to restart your computer.

   =================================================================================================

   HotFix ID                :   KB5066131
   Installed At (UTC)       :   3/17/2026 3:25:07 PM
   Title                    :   2025-10 Cumulative Update for .NET Framework 3.5 and 4.8.1 for Microsoft server operating system version 24H2 for x64 (KB5066131)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   A security issue has been identified in a Microsoft software product that could affect your system. You can help protect your system by installing this update from Microsoft. For a complete listing of the issues that are included in this update, see the associated Microsoft Knowledge Base article. After you install this update, you may have to restart your system.

   =================================================================================================

   HotFix ID                :   KB2267602
   Installed At (UTC)       :   3/17/2026 3:21:24 PM
   Title                    :   Security Intelligence Update for Microsoft Defender Antivirus - KB2267602 (Version 1.445.587.0) - Current Channel (Broad)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   Install this update to revise the files that are used to detect viruses, spyware, and other potentially unwanted software. Once you have installed this item, it cannot be removed.

   =================================================================================================

   HotFix ID                :   KB890830
   Installed At (UTC)       :   3/17/2026 3:18:20 PM
   Title                    :   Windows Malicious Software Removal Tool x64 - v5.139 (KB890830)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   After the download, this tool runs one time to check your computer
                    for infection by specific, prevalent malicious software (including Blaster,
                    Sasser, and Mydoom) and helps remove any infection that is found. If an
                    infection is found, the tool will display a status report the next time that you
                    start your computer. A new version of the tool will be offered every month. If
                    you want to manually run the tool on your computer, you can download a copy from
                    the Microsoft Download Center, or you can run an online version from
                    microsoft.com. This tool is not a replacement for an antivirus product. To help
                    protect your computer, you should use an antivirus product.

   =================================================================================================

   HotFix ID                :   KB5007651
   Installed At (UTC)       :   3/17/2026 3:16:26 PM
   Title                    :   Update for Windows Security platform - KB5007651 (Version 10.0.29510.1001)
   Client Application ID    :   MoUpdateOrchestrator
   Description              :   This package will update Windows Security platform components on the user machine.

   =================================================================================================


╔══════════╣ System Last Shutdown Date/time (from Registry)
 (T1082)                                                                                                            
    Last Shutdown Date/time        :    4/27/2026 2:28:16 PM

╔══════════╣ User Environment Variables (T1082)
╚ Check for some passwords or keys in the env variables 
    COMPUTERNAME: SRV1
    USERPROFILE: C:\Users\Default
    HOMEPATH: \Users\ts_svc
    LOCALAPPDATA: C:\Users\ts_svc\AppData\Local
    PSModulePath: C:\Users\Default\Documents\WindowsPowerShell\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
    PROCESSOR_ARCHITECTURE: AMD64
    Path: C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\
    CommonProgramFiles(x86): C:\Program Files (x86)\Common Files
    ProgramFiles(x86): C:\Program Files (x86)
    PROCESSOR_LEVEL: 25
    LOGONSERVER: \\DC01
    PATHEXT: .COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.CPL
    HOMEDRIVE: C:
    SystemRoot: C:\WINDOWS
    ALLUSERSPROFILE: C:\ProgramData
    DriverData: C:\Windows\System32\Drivers\DriverData
    APPDATA: C:\Users\ts_svc\AppData\Roaming
    PROCESSOR_REVISION: 0101
    USERNAME: SYSTEM
    CommonProgramW6432: C:\Program Files\Common Files
    CommonProgramFiles: C:\Program Files\Common Files
    OS: Windows_NT
    USERDOMAIN_ROAMINGPROFILE: RESEARCHMCO
    PROCESSOR_IDENTIFIER: AMD64 Family 25 Model 1 Stepping 1, AuthenticAMD
    ComSpec: C:\WINDOWS\system32\cmd.exe
    SystemDrive: C:
    TEMP: C:\Windows\SystemTemp
    ProgramFiles: C:\Program Files
    NUMBER_OF_PROCESSORS: 2
    TMP: C:\Windows\SystemTemp
    ProgramData: C:\ProgramData
    ProgramW6432: C:\Program Files
    windir: C:\WINDOWS
    USERDOMAIN: RESEARCHMCO
    PUBLIC: C:\Users\Public

╔══════════╣ System Environment Variables (T1082)
╚ Check for some passwords or keys in the env variables 
    ComSpec: C:\WINDOWS\system32\cmd.exe
    DriverData: C:\Windows\System32\Drivers\DriverData
    OS: Windows_NT
    Path: C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\
    PATHEXT: .COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC
    PROCESSOR_ARCHITECTURE: AMD64
    PSModulePath: C:\Program Files\WindowsPowerShell\Modules;C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
    TEMP: C:\WINDOWS\TEMP
    TMP: C:\WINDOWS\TEMP
    USERNAME: SYSTEM
    windir: C:\WINDOWS
    NUMBER_OF_PROCESSORS: 2
    PROCESSOR_LEVEL: 25
    PROCESSOR_IDENTIFIER: AMD64 Family 25 Model 1 Stepping 1, AuthenticAMD
    PROCESSOR_REVISION: 0101

╔══════════╣ Audit Settings (T1562.002)
╚ Check what is being logged 
    Not Found

╔══════════╣ Audit Policy Settings - Classic & Advanced (T1562.002)

╔══════════╣ WEF Settings (T1562.002)
╚ Windows Event Forwarding, is interesting to know were are sent the logs 
    Not Found

╔══════════╣ LAPS Settings (T1003.004)
╚ If installed, local administrator password is changed frequently and is restricted by ACL 
    LAPS Enabled: LAPS not installed

╔══════════╣ Wdigest (T1003.001)
╚ If enabled, plain-text crds could be stored in LSASS https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#wdigest                                                                          
    Wdigest is not enabled

╔══════════╣ LSA Protection (T1003.001)
╚ If enabled, a driver is needed to read LSASS memory (If Secure Boot or UEFI, RunAsPPL cannot be disabled by deleting the registry key) https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#lsa-protection                                                                                                     
    LSA Protection is not enabled

╔══════════╣ Credentials Guard (T1003.001)
╚ If enabled, a driver is needed to read LSASS memory https://book.hacktricks.wiki/windows-hardening/stealing-credentials/credentials-protections#credentials-guard                                                                     
    CredentialGuard is not enabled
    Virtualization Based Security Status:      Enabled and running
    Configured:                                False
    Running:                                   False

╔══════════╣ Cached Creds (T1003.005)
╚ If > 0, credentials will be cached in the registry and accessible by SYSTEM user https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#cached-credentials                                   
    cachedlogonscount is 10

╔══════════╣ Enumerating saved credentials in Registry (CurrentPass) (T1552.002)

╔══════════╣ AV Information (T1518.001)
    No AV was detected!!
    whitelistpaths:     C:\Temp

╔══════════╣ Windows Defender configuration (T1518.001)
  Local Settings

  Path Exclusions:
    C:\Temp

  PolicyManagerPathExclusions:
    C:\Temp
  Group Policy Settings

╔══════════╣ UAC Status (T1548.002)
╚ If you are in the Administrators group check how to bypass the UAC https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#from-administrator-medium-to-high-integrity-level--uac-bypasss     
    ConsentPromptBehaviorAdmin: 5 - PromptForNonWindowsBinaries
    EnableLUA: 1
    LocalAccountTokenFilterPolicy: 1
    FilterAdministratorToken: 
      [*] LocalAccountTokenFilterPolicy set to 1.
      [+] Any local account can be used for lateral movement.                                                       

╔══════════╣ PowerShell Settings (T1059.001)
    PowerShell v2 Version: 
    PowerShell v5 Version: 5.1.26100.1882
    PowerShell Core Version: 
    Transcription Settings: 
    Module Logging Settings: 
    Scriptblock Logging Settings: 
    PS history file: C:\Users\ts_svc\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
    PS history size: 12012B

╔══════════╣ Enumerating PowerShell Session Settings using the registry (T1059.001)
    Name                                   Microsoft.PowerShell
      BUILTIN\Administrators               AccessAllowed         
      NT AUTHORITY\INTERACTIVE             AccessAllowed         
      BUILTIN\Remote Management Users      AccessAllowed         
   =================================================================================================

    Name                                   Microsoft.PowerShell.Workflow
      BUILTIN\Administrators               AccessAllowed         
      BUILTIN\Remote Management Users      AccessAllowed         
   =================================================================================================

    Name                                   Microsoft.PowerShell32
      BUILTIN\Administrators               AccessAllowed         
      NT AUTHORITY\INTERACTIVE             AccessAllowed         
      BUILTIN\Remote Management Users      AccessAllowed         
   =================================================================================================


╔══════════╣ PS default transcripts history (T1552.001)
╚ Read the PS history inside these files (if any)

╔══════════╣ HKCU Internet Settings (T1082)
    User Agent: Mozilla/4.0 (compatible; MSIE 8.0; Win32)
    IE5_UA_Backup_Flag: 5.0
    ZonesSecurityUpgrade: System.Byte[]
    EnableNegotiate: 1
    ProxyEnable: 0
    MigrateProxy: 1

╔══════════╣ HKLM Internet Settings (T1082)
    EnablePunycode: 1
    ActiveXCache: C:\Windows\Downloaded Program Files
    CodeBaseSearchPath: CODEBASE
    MinorVersion: 0
    WarnOnIntranet: 1

╔══════════╣ Drives Information (T1082)
╚ Remember that you should search more info inside the other drives 
    C:\ (Type: Fixed)(Filesystem: NTFS)(Available space: 12 GB)(Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories])                                                 

╔══════════╣ Checking WSUS (T1072,T1068)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#wsus
    Not Found

╔══════════╣ Checking KrbRelayUp (T1187,T1558)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#krbrelayup
  The system is inside a domain (RESEARCHMCO) so it could be vulnerable.
╚ You can try https://github.com/Dec0ne/KrbRelayUp to escalate privileges

╔══════════╣ Checking If Inside Container (T1613)
╚ If the binary cexecsvc.exe or associated service exists, you are inside Docker 
You are NOT inside a container

╔══════════╣ Checking AlwaysInstallElevated (T1548.002)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#alwaysinstallelevated                                                                                                                
    AlwaysInstallElevated set to 1 in HKLM!

╔══════════╣ Object Manager race-window amplification primitives (T1068)
╚ Project Zero write-up: https://projectzero.google/2025/12/windows-exploitation-techniques.html
    Created a test named event (PEAS_OMNS_5592_a25636809bfa4e42bca4fc3d6848e79f) under \BaseNamedObjects.
╚     -> Low-privileged users can slow NtOpen*/NtCreate* lookups using ~32k-character names or ~16k-level directory chains.                                                                                                             
╚     -> Point attacker-controlled symbolic links to the slow path to stretch kernel race windows.
╚     -> Use this whenever a bug follows check -> NtOpenX -> privileged action patterns.

╔══════════╣ Enumerate LSA settings - auth packages included
 (T1547.005)                                                                                                        
    auditbasedirectories                 :       0
    auditbaseobjects                     :       0
    Authentication Packages              :       msv1_0
    Bounds                               :       00-30-00-00-00-20-00-00
    crashonauditfail                     :       0
    fullprivilegeauditing                :       00
    LimitBlankPasswordUse                :       1
    NoLmHash                             :       1
    Notification Packages                :       scecli
    Security Packages                    :       ""
    LsaPid                               :       836
    LsaCfgFlagsDefault                   :       2
    SecureBoot                           :       1
    ProductType                          :       7
    disabledomaincreds                   :       0
    everyoneincludesanonymous            :       0
    forceguest                           :       0
    restrictanonymous                    :       0
    restrictanonymoussam                 :       1
    RunAsPPL                             :       0
    IsPplAutoEnabled                     :       36
    RunAsPPLBoot                         :       0

╔══════════╣ Enumerating NTLM Settings (T1557.001)
  LanmanCompatibilityLevel    :  (Send NTLMv2 response only - Win7+ default)
                                                                                                                    

  NTLM Signing Settings                                                                                             
      ClientRequireSigning    : False
      ClientNegotiateSigning  : True
      ServerRequireSigning    : False
      ServerNegotiateSigning  : False
      LdapSigning             : Negotiate signing (Negotiate signing)

  Session Security                                                                                                  
      NTLMMinClientSec        : 536870912 (Require 128-bit encryption)
      NTLMMinServerSec        : 536870912 (Require 128-bit encryption)
                                                                                                                    

  NTLM Auditing and Restrictions                                                                                    
      InboundRestrictions     :  (Not defined)
      OutboundRestrictions    :  (Not defined)
      InboundAuditing         :  (Not defined)
      OutboundExceptions      : 

╔══════════╣ Display Local Group Policy settings - local users/machine (T1082)

╔══════════╣ Potential GPO abuse vectors (applied domain GPOs writable by current user) (T1484.001)
  [-] Controlled exception, info about RESEARCHMCO\SYSTEM not found
    No obvious GPO abuse via writable SYSVOL paths or GPCO membership detected.

╔══════════╣ Checking AppLocker effective policy
   AppLockerPolicy version: 1
   listing rules:



╔══════════╣ PrintNightmare PointAndPrint Policies (T1068)
╚ Check PointAndPrint policy hardening https://itm4n.github.io/printnightmare-exploitation/
    Not Found

╔══════════╣ Enumerating Printers (WMI) (T1082)
      Name:                    Microsoft Print to PDF
      Status:                  Unknown
      Sddl:                    O:SYD:(A;;LCSWSDRCWDWO;;;LA)(A;OIIO;RPWPSDRCWDWO;;;LA)(A;OIIO;GA;;;CO)(A;OIIO;GA;;;AC)(A;;SWRC;;;WD)(A;CIIO;GX;;;WD)(A;;SWRC;;;AC)(A;CIIO;GX;;;AC)(A;;LCSWDTSDRCWDWO;;;BA)(A;OICIIO;GA;;;BA)(A;OIIO;GA;;;S-1-15-3-1024-4044835139-2658482041-3127973164-329287231-3865880861-1938685643-461067658-1087000422)(A;;SWRC;;;S-1-15-3-1024-4044835139-2658482041-3127973164-329287231-3865880861-1938685643-461067658-1087000422)(A;CIIO;GX;;;S-1-15-3-1024-4044835139-2658482041-3127973164-329287231-3865880861-1938685643-461067658-1087000422)
      Is default:              True
      Is network printer:      False

   =================================================================================================


╔══════════╣ Enumerating Named Pipes (T1559)
  Name                                                                                                 CurrentUserPerms                                                       Sddl

  atsvc                                                                                                Everyone [Allow: WriteData/CreateFiles]                                O:SYG:SYD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-4125092361-1567024937-842823819-2091237918-836075745)

  Ctx_WinStation_API_service                                                                           Everyone [Allow: WriteData/CreateFiles]                                O:NSG:NSD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-446051430-1559341753-4161941529-1950928533-810483104)

  epmapper                                                                                             Everyone [Allow: WriteData/CreateFiles]                                O:NSG:NSD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-521322694-906040134-3864710659-1525148216-3451224162)(A;;0x12019b;;;AC)

  eventlog                                                                                             Everyone [Allow: WriteData/CreateFiles]                                O:LSG:LSD:P(A;;0x12019b;;;WD)(A;;CC;;;OW)(A;;0x12008f;;;S-1-5-80-880578595-1860270145-482643319-2788375705-1540778122)

  InitShutdown                                                                                         Everyone [Allow: WriteData/CreateFiles], Administrators [Allow: AllAccess] O:BAG:SYD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;BA)

  lsass                                                                                                Everyone [Allow: WriteData/CreateFiles], Administrators [Allow: AllAccess] O:BAG:SYD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;BA)(A;;0x12019b;;;S-1-15-3-8)

  LSM_API_service                                                                                      Everyone [Allow: WriteData/CreateFiles]                                O:SYG:SYD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-1230977110-1477712667-2747199032-477530733-939374687)

  ntsvcs                                                                                               Everyone [Allow: WriteData/CreateFiles], Administrators [Allow: AllAccess] O:BAG:SYD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;BA)

  PIPE_EVENTROOT\CIMV2SCM EVENT PROVIDER                                                               SYSTEM [Allow: AllAccess]                                              O:SYG:SYD:(A;;FA;;;SY)(A;;0x12019b;;;LS)(A;;0x12019b;;;NS)

  PSHost.134313648338657835.7000.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  PSHost.134313652886144529.5148.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  PSHost.134313660119861342.7292.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  PSHost.134313662745616581.7080.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  PSHost.134313665330736906.8948.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  PSHost.134313665980702532.5948.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  PSHost.134313667583337495.4740.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  PSHost.134313788170098028.4556.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  PSHost.134313797325728794.4996.DefaultAppDomain.powershell                                           Administrators [Allow: TakeOwnership]                                  O:SYG:SYD:(A;;0x1f019f;;;BA)                              

  SessEnvPublicRpc                                                                                     Everyone [Allow: WriteData/CreateFiles]                                O:SYG:SYD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-4022436659-1090538466-1613889075-870485073-3428993833)

  Sessions\2\AppContainerNamedObjects\S-1-15-2-283421221-3183566570-1718213290-751554359-3541592344-2312209569-3374928651\crashpad_2460_UJPVTACGNWPENAOE SYSTEM [Allow: AllAccess]                                              O:S-1-5-21-1361221028-2446471266-1567148372-1104G:DUD:(A;;FA;;;SY)(A;;FA;;;S-1-5-21-1361221028-2446471266-1567148372-1104)(A;;0x12019f;;;AC)

  srvsvc                                                                                               Everyone [Allow: WriteData/CreateFiles], SYSTEM [Allow: AllAccess]     O:SYG:SYD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;SY)

  TermSrv_API_service                                                                                  Everyone [Allow: WriteData/CreateFiles]                                O:NSG:NSD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-446051430-1559341753-4161941529-1950928533-810483104)

  trkwks                                                                                               Everyone [Allow: WriteData/CreateFiles]                                O:SYG:SYD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-768763963-4214222998-2156221936-2953597973-713500239)

  W32TIME_ALT                                                                                          Everyone [Allow: WriteData/CreateFiles]                                O:LSG:LSD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-4267341169-2882910712-659946508-2704364837-2204554466)

  Winsock2\CatalogChangeListener-160-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:SYG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-220-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:NSG:NSD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-2c0-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:BAG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-334-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:BAG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-344-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:BAG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-658-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:LSG:LSD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-7f0-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:SYG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-9b0-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:SYG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-9d4-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:SYG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  Winsock2\CatalogChangeListener-b7c-0                                                                 SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles] O:SYG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)

  wkssvc                                                                                               Everyone [Allow: WriteData/CreateFiles], SYSTEM [Allow: AllAccess]     O:NSG:NSD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;SY)(A;;FA;;;NS)


╔══════════╣ Named Pipes with Low-Priv Write Access to Privileged Servers (T1134.001,T1559)
    \\.\pipe\atsvc
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:SYG:SYD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-4125092361-1567024937-842823819-2091237918-836075745)
   =================================================================================================

    \\.\pipe\Ctx_WinStation_API_service
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:NSG:NSD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-446051430-1559341753-4161941529-1950928533-810483104)
   =================================================================================================

    \\.\pipe\epmapper
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:NSG:NSD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-521322694-906040134-3864710659-1525148216-3451224162)(A;;0x12019b;;;AC)
   =================================================================================================

    \\.\pipe\eventlog
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:LSG:LSD:P(A;;0x12019b;;;WD)(A;;CC;;;OW)(A;;0x12008f;;;S-1-5-80-880578595-1860270145-482643319-2788375705-1540778122)
   =================================================================================================

    \\.\pipe\InitShutdown
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:BAG:SYD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;BA)
   =================================================================================================

    \\.\pipe\lsass
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:BAG:SYD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;BA)(A;;0x12019b;;;S-1-15-3-8)
   =================================================================================================

    \\.\pipe\LSM_API_service
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:SYG:SYD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-1230977110-1477712667-2747199032-477530733-939374687)
   =================================================================================================

    \\.\pipe\ntsvcs
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:BAG:SYD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;BA)
   =================================================================================================

    \\.\pipe\PIPE_EVENTROOT\CIMV2SCM EVENT PROVIDER
      Low-priv ACLs  : NT AUTHORITY\LOCAL SERVICE [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\NETWORK SERVICE [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:SYG:SYD:(A;;FA;;;SY)(A;;0x12019b;;;LS)(A;;0x12019b;;;NS)
   =================================================================================================

    \\.\pipe\SessEnvPublicRpc
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:SYG:SYD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-4022436659-1090538466-1613889075-870485073-3428993833)
   =================================================================================================

    \\.\pipe\srvsvc
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:SYG:SYD:(A;;0x12019b;;;WD)(A;;0x12019b;;;AN)(A;;FA;;;SY)
   =================================================================================================

    \\.\pipe\TermSrv_API_service
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:NSG:NSD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-446051430-1559341753-4161941529-1950928533-810483104)
   =================================================================================================

    \\.\pipe\trkwks
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:SYG:SYD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-768763963-4214222998-2156221936-2953597973-713500239)
   =================================================================================================

    \\.\pipe\W32TIME_ALT
      Low-priv ACLs  : Everyone [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]; NT AUTHORITY\ANONYMOUS LOGON [CreateFiles|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:LSG:LSD:(A;;0x12019b;;;WD)(A;;RC;;;OW)(A;;0x12019b;;;AN)(A;;FA;;;S-1-5-80-4267341169-2882910712-659946508-2704364837-2204554466)
   =================================================================================================

    \\.\pipe\Winsock2\CatalogChangeListener-344-0
      Low-priv ACLs  : NT AUTHORITY\NETWORK [AppendData|CreateDirectories|CreateFiles|Write|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:BAG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)
   =================================================================================================

    \\.\pipe\Winsock2\CatalogChangeListener-658-0
      Low-priv ACLs  : NT AUTHORITY\NETWORK [AppendData|CreateDirectories|CreateFiles|Write|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:LSG:LSD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)
   =================================================================================================

    \\.\pipe\Winsock2\CatalogChangeListener-9b0-0
      Low-priv ACLs  : NT AUTHORITY\NETWORK [AppendData|CreateDirectories|CreateFiles|Write|WriteAttributes|WriteData|WriteExtendedAttributes]
      Observed owners: No privileged handles observed (service idle or access denied)
      SDDL           : O:SYG:SYD:(D;;FW;;;NU)(A;;0x120196;;;SY)(A;;0x120196;;;BA)
   =================================================================================================


╔══════════╣ Enumerating AMSI registered providers (T1562.001)
    Provider:       {2781761E-28E0-4109-99FE-B9D127C57AFE}
    Path:           "C:\ProgramData\Microsoft\Windows Defender\Platform\4.18.26010.5-0\MpOav.dll"

   =================================================================================================


╔══════════╣ Enumerating Sysmon configuration (T1518.001)
      Installed:                False
      Hashing Algorithm:        Not Defined
      Options:                  Not Defined
      Rules:                    

   =================================================================================================


╔══════════╣ Enumerating Sysmon process creation logs (1) (T1654)
      Unable to query Sysmon event logs, Sysmon likely not installed.

╔══════════╣ Installed .NET versions
 (T1082)                                                                                                            
  CLR Versions
   4.0.30319

  .NET Versions                                                                                                     
   4.8.09221

  .NET & AMSI (Anti-Malware Scan Interface) support                                                                 
      .NET version supports AMSI     : True
      OS supports AMSI               : True
        [!] The highest .NET version is enrolled in AMSI!


════════════════════════════════════╣ Interesting Events information (T1654,T1078,T1078.003,T1552.001,T1059.001,T1082) ╠════════════════════════════════════                                                                            

╔══════════╣ Printing Explicit Credential Events (4648) for last 30 days - A process logged on using plaintext credentials                                                                                                              
 (T1078.003)                                                                                                        
  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 6:26:58 PM                                                                 
  IP Address         :         192.168.45.207                                                                       
  Process            :         C:\Windows\System32\svchost.exe                                                      
  Target User        :         ts_svc                                                                               
  Target Domain      :         RESEARCHMCO                                                                          
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 3:10:36 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 3:10:32 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 3:10:31 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6424                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 3:07:53 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 3:07:48 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 3:07:47 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_8184                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:49:28 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:49:22 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:49:22 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_764                                                                             
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:49:19 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:49:19 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_8604                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:47:35 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:47:35 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:47:34 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_8348                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:47:31 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:47:11 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:47:11 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_4660                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:39:06 PM                                                                 
  IP Address         :         192.168.45.207                                                                       
  Process            :         C:\Windows\System32\svchost.exe                                                      
  Target User        :         ts_svc                                                                               
  Target Domain      :         RESEARCHMCO                                                                          
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 2:19:15 PM                                                                 
  IP Address         :         192.168.45.207                                                                       
  Process            :         C:\Windows\System32\svchost.exe                                                      
  Target User        :         ts_svc                                                                               
  Target Domain      :         RESEARCHMCO                                                                          
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:54:52 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:54:52 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6872                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:02 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:01 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:01 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_2904                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_3944                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6700                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_3272                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_7192                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6184                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:12:00 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5608                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_7052                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_2776                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6936                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6844                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:59 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5500                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6628                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6692                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5316                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_624                                                                             
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_84                                                                              
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_2856                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5360                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_7464                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6104                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:58 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_7960                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:57 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6248                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:57 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_8064                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:47 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:46 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5768                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:46 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_8120                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:46 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:46 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:46 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:46 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5440                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:45 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_7600                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:45 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5108                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:45 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6880                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:45 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_3584                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:45 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:45 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:45 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6776                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:44 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_7716                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:44 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:44 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_7404                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:44 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:43 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6424                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:43 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_2376                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:43 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_1956                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:43 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_6908                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:37 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:26 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:11:25 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5952                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:10:21 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:10:18 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 1:10:17 PM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_5760                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 12:56:18 PM                                                                
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 12:56:10 PM                                                                
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         hacker                                                                               
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 12:56:09 PM                                                                
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\OpenSSH\sshd.exe                                                 
  Target User        :         sshd_2076                                                                            
  Target Domain      :         VIRTUAL USERS                                                                        
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 12:40:41 PM                                                                
  IP Address         :         192.168.45.207                                                                       
  Process            :         C:\Windows\System32\svchost.exe                                                      
  Target User        :         ts_svc                                                                               
  Target Domain      :         RESEARCHMCO                                                                          
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 9:55:42 AM                                                                 
  IP Address         :         192.168.45.207                                                                       
  Process            :         C:\Windows\System32\svchost.exe                                                      
  Target User        :         ts_svc                                                                               
  Target Domain      :         RESEARCHMCO                                                                          
                                                                                                                    
   =================================================================================================

  Subject User       :         SRV1$
  Subject Domain     :         RESEARCHMCO                                                                          
  Created (UTC)      :         8/16/2026 9:34:47 AM                                                                 
  IP Address         :         -                                                                                    
  Process            :         C:\Windows\System32\services.exe                                                     
  Target User        :         cloudbase-init                                                                       
  Target Domain      :         SRV1                                                                                 
                                                                                                                    
   =================================================================================================


╔══════════╣ Printing Account Logon Events (4624) for the last 10 days.
 (T1654,T1078)                                                                                                      
  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 6:26:58 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 6:26:58 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       -
  Subject Domain Name          :       -                                                                            
  Created (Utc)                :       8/16/2026 6:26:52 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       NTLM                                                                         
  Lm Package                   :       NTLM V2                                                                      
  Logon Type                   :       Network                                                                      
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       -
  Subject Domain Name          :       -                                                                            
  Created (Utc)                :       8/16/2026 4:01:11 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       NTLM                                                                         
  Lm Package                   :       NTLM V2                                                                      
  Logon Type                   :       Network                                                                      
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 3:10:36 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 3:10:32 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 3:10:31 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6424                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 3:07:53 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 3:07:48 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 3:07:47 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_8184                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:49:28 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:49:22 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:49:22 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_764                                                                     
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:49:19 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:49:19 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_8604                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:47:35 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:47:35 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:47:34 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_8348                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:47:31 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:47:11 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:47:11 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_4660                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:39:06 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:39:06 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       -
  Subject Domain Name          :       -                                                                            
  Created (Utc)                :       8/16/2026 2:39:05 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       NTLM                                                                         
  Lm Package                   :       NTLM V2                                                                      
  Logon Type                   :       Network                                                                      
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:19:15 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 2:19:15 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       -
  Subject Domain Name          :       -                                                                            
  Created (Utc)                :       8/16/2026 2:19:14 PM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       NTLM                                                                         
  Lm Package                   :       NTLM V2                                                                      
  Logon Type                   :       Network                                                                      
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:54:52 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:54:52 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6872                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:02 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:01 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:01 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_2904                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_3944                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6700                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_3272                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_7192                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6184                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:12:00 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5608                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_7052                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_2776                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6936                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6844                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:59 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5500                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6628                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6692                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5316                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_624                                                                     
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_84                                                                      
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_2856                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5360                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_7464                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6104                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:58 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_7960                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:57 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6248                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:57 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_8064                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:47 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:46 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5768                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:46 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_8120                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:46 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:46 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:46 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:46 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5440                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:45 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_7600                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:45 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5108                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:45 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6880                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:45 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_3584                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:45 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:45 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:45 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6776                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:44 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_7716                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:44 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:44 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_7404                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:44 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:43 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6424                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:43 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_2376                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:43 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_1956                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:43 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_6908                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:37 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:26 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:11:25 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5952                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:10:21 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:10:18 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 1:10:17 PM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_5760                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 12:56:18 PM                                                        
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       NetworkCleartext                                                             
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 12:56:10 PM                                                        
  IP Address                   :       -                                                                            
  Authentication Package       :       MICROSOFT_AUTHENTICATION_PACKAGE_V1_0                                        
  Lm Package                   :                                                                                    
  Logon Type                   :       Network                                                                      
  Target User Name             :       hacker                                                                       
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 12:56:09 PM                                                        
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       sshd_2076                                                                    
  Target Domain Name           :       VIRTUAL USERS                                                                
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 12:40:41 PM                                                        
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 12:40:41 PM                                                        
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       -
  Subject Domain Name          :       -                                                                            
  Created (Utc)                :       8/16/2026 12:40:39 PM                                                        
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       NTLM                                                                         
  Lm Package                   :       NTLM V2                                                                      
  Logon Type                   :       Network                                                                      
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       -
  Subject Domain Name          :       -                                                                            
  Created (Utc)                :       8/16/2026 10:00:31 AM                                                        
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       NTLM                                                                         
  Lm Package                   :       NTLM V2                                                                      
  Logon Type                   :       Network                                                                      
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 9:55:42 AM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 9:55:42 AM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       RemoteInteractive                                                            
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       %%1843                                                                       
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       -
  Subject Domain Name          :       -                                                                            
  Created (Utc)                :       8/16/2026 9:55:40 AM                                                         
  IP Address                   :       192.168.45.207                                                               
  Authentication Package       :       NTLM                                                                         
  Lm Package                   :       NTLM V2                                                                      
  Logon Type                   :       Network                                                                      
  Target User Name             :       ts_svc                                                                       
  Target Domain Name           :       RESEARCHMCO                                                                  
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       cloudbase-init
  Subject Domain Name          :       SRV1                                                                         
  Created (Utc)                :       8/16/2026 9:35:27 AM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Batch                                                                        
  Target User Name             :       cloudbase-init                                                               
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  Subject User Name            :       SRV1$
  Subject Domain Name          :       RESEARCHMCO                                                                  
  Created (Utc)                :       8/16/2026 9:34:47 AM                                                         
  IP Address                   :       -                                                                            
  Authentication Package       :       Negotiate                                                                    
  Lm Package                   :                                                                                    
  Logon Type                   :       Service                                                                      
  Target User Name             :       cloudbase-init                                                               
  Target Domain Name           :       SRV1                                                                         
  Target Outbound User Name    :       -                                                                            
  Target Outbound Domain Name  :       -                                                                            
                                                                                                                    
   =================================================================================================

  NTLM relay might be possible - other users authenticate to this machine using NTLM!

  Accounts authenticate to this machine using NTLM v2!                                                              
  You can obtain NetNTLMv2 for these accounts by sniffing NTLM challenge/responses.
  You can then try and crack their passwords.
                                                                                                                    
    RESEARCHMCO\ts_svc

╔══════════╣ Process creation events - searching logs (EID 4688) for sensitive data.
 (T1654)                                                                                                            

╔══════════╣ PowerShell events - script block logs (EID 4104) - searching for sensitive data.
 (T1552.001,T1059.001)                                                                                              

╔══════════╣ Displaying Power off/on events for last 5 days
 (T1082)                                                                                                            
  8/16/2026 10:34:33 AM   :  Startup


════════════════════════════════════╣ Users Information (T1087.001,T1087.004,T1033,T1134.001,T1115,T1563.002,T1083,T1552.002,T1201) ╠════════════════════════════════════                                                               

╔══════════╣ Users (T1087.001)
╚ Check if you have some admin equivalent privileges https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#users--groups                                                                      
  Current user: SYSTEM
  Current groups: Everyone, Users, Service, Console Logon, Authenticated Users, This Organization, msiserver, Local, Administrators
   =================================================================================================

    SRV1\Admin
        |->Groups: Administrators
        |->Password: CanChange-Expi-Req

    SRV1\Administrator: Built-in account for administering the computer/domain
        |->Groups: Administrators
        |->Password: CanChange-NotExpi-Req

    SRV1\cloudbase-init
        |->Groups: Administrators
        |->Password: NotChange-NotExpi-Req

    SRV1\DefaultAccount(Disabled): A user account managed by the system.
        |->Groups: System Managed Accounts Group
        |->Password: CanChange-NotExpi-NotReq

    SRV1\Guest(Disabled): Built-in account for guest access to the computer/domain
        |->Groups: Guests
        |->Password: NotChange-NotExpi-NotReq

    SRV1\hacker
        |->Groups: Users,Administrators,Remote Desktop Users
        |->Password: CanChange-Expi-Req

    SRV1\WDAGUtilityAccount(Disabled): A user account managed and used by the system for Windows Defender Application Guard scenarios.
        |->Password: CanChange-Expi-Req


╔══════════╣ Current User Idle Time (T1033)
   Current User   :     NT AUTHORITY\SYSTEM
   Idle Time      :     00h:16m:07s:297ms

╔══════════╣ Display Tenant information (DsRegCmd.exe /status) (T1087.004)
   Tenant is NOT Azure AD Joined.

╔══════════╣ Current Token privileges (T1134.001)
╚ Check if you can escalate privilege using some enabled token https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#token-manipulation                                                       
    SeAssignPrimaryTokenPrivilege: DISABLED
    SeLockMemoryPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeIncreaseQuotaPrivilege: DISABLED
    SeTcbPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeSecurityPrivilege: SE_PRIVILEGE_ENABLED
    SeTakeOwnershipPrivilege: DISABLED
    SeLoadDriverPrivilege: DISABLED
    SeProfileSingleProcessPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeIncreaseBasePriorityPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeCreatePagefilePrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeCreatePermanentPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeBackupPrivilege: DISABLED
    SeRestorePrivilege: DISABLED
    SeShutdownPrivilege: DISABLED
    SeAuditPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeChangeNotifyPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeImpersonatePrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeCreateGlobalPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
    SeCreateSymbolicLinkPrivilege: SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED

╔══════════╣ Clipboard text (T1115)

╔══════════╣ Logged users (T1033)
    SRV1\hacker
    SRV1\cloudbase-init
    RESEARCHMCO\ts_svc

╔══════════╣ Display information about local users (T1087.001)
   Computer Name           :   SRV1
   User Name               :   Admin
   User Id                 :   1001
   Is Enabled              :   True
   User Type               :   Administrator
   Comment                 :   
   Last Logon              :   3/17/2026 3:09:29 PM
   Logons Count            :   1
   Password Last Set       :   1/1/1970 12:00:00 AM

   =================================================================================================

   Computer Name           :   SRV1
   User Name               :   Administrator
   User Id                 :   500
   Is Enabled              :   True
   User Type               :   Administrator
   Comment                 :   Built-in account for administering the computer/domain
   Last Logon              :   4/24/2026 11:49:01 AM
   Logons Count            :   2455
   Password Last Set       :   3/17/2026 5:13:17 PM

   =================================================================================================

   Computer Name           :   SRV1
   User Name               :   cloudbase-init
   User Id                 :   1000
   Is Enabled              :   True
   User Type               :   Administrator
   Comment                 :   
   Last Logon              :   8/16/2026 10:35:26 AM
   Logons Count            :   35
   Password Last Set       :   8/16/2026 10:35:14 AM

   =================================================================================================

   Computer Name           :   SRV1
   User Name               :   DefaultAccount
   User Id                 :   503
   Is Enabled              :   False
   User Type               :   Guest
   Comment                 :   A user account managed by the system.
   Last Logon              :   1/1/1970 12:00:00 AM
   Logons Count            :   0
   Password Last Set       :   1/1/1970 12:00:00 AM

   =================================================================================================

   Computer Name           :   SRV1
   User Name               :   Guest
   User Id                 :   501
   Is Enabled              :   False
   User Type               :   Guest
   Comment                 :   Built-in account for guest access to the computer/domain
   Last Logon              :   1/1/1970 12:00:00 AM
   Logons Count            :   0
   Password Last Set       :   1/1/1970 12:00:00 AM

   =================================================================================================

   Computer Name           :   SRV1
   User Name               :   hacker
   User Id                 :   1002
   Is Enabled              :   True
   User Type               :   Administrator
   Comment                 :   
   Last Logon              :   8/16/2026 4:10:36 PM
   Logons Count            :   10
   Password Last Set       :   8/16/2026 1:54:04 PM

   =================================================================================================

   Computer Name           :   SRV1
   User Name               :   WDAGUtilityAccount
   User Id                 :   504
   Is Enabled              :   False
   User Type               :   Guest
   Comment                 :   A user account managed and used by the system for Windows Defender Application Guard scenarios.
   Last Logon              :   1/1/1970 12:00:00 AM
   Logons Count            :   0
   Password Last Set       :   11/8/2025 1:37:42 AM

   =================================================================================================


╔══════════╣ RDP Sessions (T1563.002)
╚ Disconnected high-privilege RDP sessions keep reusable tokens inside LSASS. https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/credentials-mgmt/rdp-sessions                                        
    SessID  Session        User                Domain                State          SourceIP          HighPriv  
    2                      ts_svc              RESEARCHMCO           Disconnected                     No        

╔══════════╣ Ever logged users (T1033)
    SRV1\Administrator
    SRV1\hacker
    SRV1\Admin
    SRV1\cloudbase-init
    RESEARCHMCO\ts_svc

╔══════════╣ Home folders found (T1083)
    C:\Users\Admin : SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    C:\Users\Administrator : SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    C:\Users\All Users : SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    C:\Users\cloudbase-init : SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    C:\Users\Default : SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    C:\Users\Default User : SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    C:\Users\hacker : SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    C:\Users\Public : Service [Allow: WriteData/CreateFiles], SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]                                                                                                              
    C:\Users\ts_svc : SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]

╔══════════╣ Looking for AutoLogon credentials (T1552.002)
    Some AutoLogon credentials were found
    DefaultUserName               :  Administrator

╔══════════╣ Password Policies (T1201)
╚ Check for a possible brute-force 
    Domain: Builtin
    SID: S-1-5-32
    MaxPasswordAge: 42.22:47:31.7437440
    MinPasswordAge: 00:00:00
    MinPasswordLength: 0
    PasswordHistoryLength: 0
    PasswordProperties: DOMAIN_LOCKOUT_ADMINS
   =================================================================================================

    Domain: SRV1
    SID: S-1-5-21-4029100034-1129869997-224566666
    MaxPasswordAge: 42.00:00:00
    MinPasswordAge: 00:00:00
    MinPasswordLength: 0
    PasswordHistoryLength: 0
    PasswordProperties: DOMAIN_PASSWORD_COMPLEX, DOMAIN_LOCKOUT_ADMINS
   =================================================================================================


╔══════════╣ Print Logon Sessions (T1033)
    Method:                       LSA
    Logon Server:                 SRV1
    Logon Server Dns Domain:      
    Logon Id:                     76965557
    Logon Time:                   8/16/2026 2:49:28 PM
    Logon Type:                   NetworkCleartext
    Start Time:                   
    Domain:                       SRV1
    Authentication Package:       NTLM
    Start Time:                   
    User Name:                    hacker
    User Principal Name:          
    User SID:                     S-1-5-21-4029100034-1129869997-224566666-1002

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     76964142
    Logon Time:                   8/16/2026 2:49:22 PM
    Logon Type:                   Service
    Start Time:                   
    Domain:                       VIRTUAL USERS
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    sshd_764
    User Principal Name:          
    User SID:                     S-1-5-111-3847866527-469524349-687026318-516638107-1125189541-764

   =================================================================================================

    Method:                       LSA
    Logon Server:                 SRV1
    Logon Server Dns Domain:      
    Logon Id:                     76923667
    Logon Time:                   8/16/2026 2:47:35 PM
    Logon Type:                   NetworkCleartext
    Start Time:                   
    Domain:                       SRV1
    Authentication Package:       NTLM
    Start Time:                   
    User Name:                    hacker
    User Principal Name:          
    User SID:                     S-1-5-21-4029100034-1129869997-224566666-1002

   =================================================================================================

    Method:                       LSA
    Logon Server:                 SRV1
    Logon Server Dns Domain:      
    Logon Id:                     76921018
    Logon Time:                   8/16/2026 2:47:31 PM
    Logon Type:                   NetworkCleartext
    Start Time:                   
    Domain:                       SRV1
    Authentication Package:       NTLM
    Start Time:                   
    User Name:                    hacker
    User Principal Name:          
    User SID:                     S-1-5-21-4029100034-1129869997-224566666-1002

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     20148249
    Logon Time:                   8/16/2026 9:55:41 AM
    Logon Type:                   Interactive
    Start Time:                   
    Domain:                       Window Manager
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    DWM-2
    User Principal Name:          
    User SID:                     S-1-5-90-0-2

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     20148192
    Logon Time:                   8/16/2026 9:55:41 AM
    Logon Type:                   Interactive
    Start Time:                   
    Domain:                       Window Manager
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    DWM-2
    User Principal Name:          
    User SID:                     S-1-5-90-0-2

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     67067
    Logon Time:                   8/16/2026 9:34:41 AM
    Logon Type:                   Interactive
    Start Time:                   
    Domain:                       Window Manager
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    DWM-1
    User Principal Name:          
    User SID:                     S-1-5-90-0-1

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     996
    Logon Time:                   8/16/2026 9:34:41 AM
    Logon Type:                   Service
    Start Time:                   
    Domain:                       RESEARCHMCO
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    SRV1$
    User Principal Name:          
    User SID:                     S-1-5-20

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      researchmco.ai
    Logon Id:                     32186
    Logon Time:                   8/16/2026 9:34:41 AM
    Logon Type:                   Interactive
    Start Time:                   
    Domain:                       Font Driver Host
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    UMFD-0
    User Principal Name:          SRV1$@researchmco.ai
    User SID:                     S-1-5-96-0-0

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     76922611
    Logon Time:                   8/16/2026 2:47:34 PM
    Logon Type:                   Service
    Start Time:                   
    Domain:                       VIRTUAL USERS
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    sshd_8348
    User Principal Name:          
    User SID:                     S-1-5-111-3847866527-469524349-687026318-516638107-1125189541-8348

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     76914508
    Logon Time:                   8/16/2026 2:47:11 PM
    Logon Type:                   Service
    Start Time:                   
    Domain:                       VIRTUAL USERS
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    sshd_4660
    User Principal Name:          
    User SID:                     S-1-5-111-3847866527-469524349-687026318-516638107-1125189541-4660

   =================================================================================================

    Method:                       LSA
    Logon Server:                 DC01
    Logon Server Dns Domain:      RESEARCHMCO.AI
    Logon Id:                     20169464
    Logon Time:                   8/16/2026 9:55:42 AM
    Logon Type:                   RemoteInteractive
    Start Time:                   
    Domain:                       RESEARCHMCO
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    ts_svc
    User Principal Name:          ts_svc@researchmco.ai
    User SID:                     S-1-5-21-1361221028-2446471266-1567148372-1104

   =================================================================================================

    Method:                       LSA
    Logon Server:                 DC01
    Logon Server Dns Domain:      RESEARCHMCO.AI
    Logon Id:                     20169280
    Logon Time:                   8/16/2026 9:55:42 AM
    Logon Type:                   RemoteInteractive
    Start Time:                   
    Domain:                       RESEARCHMCO
    Authentication Package:       Kerberos
    Start Time:                   
    User Name:                    ts_svc
    User Principal Name:          ts_svc@researchmco.ai
    User SID:                     S-1-5-21-1361221028-2446471266-1567148372-1104

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      researchmco.ai
    Logon Id:                     20146593
    Logon Time:                   8/16/2026 9:55:41 AM
    Logon Type:                   Interactive
    Start Time:                   
    Domain:                       Font Driver Host
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    UMFD-2
    User Principal Name:          SRV1$@researchmco.ai
    User SID:                     S-1-5-96-0-2

   =================================================================================================

    Method:                       LSA
    Logon Server:                 SRV1
    Logon Server Dns Domain:      
    Logon Id:                     458579
    Logon Time:                   8/16/2026 9:35:26 AM
    Logon Type:                   Batch
    Start Time:                   
    Domain:                       SRV1
    Authentication Package:       NTLM
    Start Time:                   
    User Name:                    cloudbase-init
    User Principal Name:          
    User SID:                     S-1-5-21-4029100034-1129869997-224566666-1000

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     997
    Logon Time:                   8/16/2026 9:34:42 AM
    Logon Type:                   Service
    Start Time:                   
    Domain:                       NT AUTHORITY
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    LOCAL SERVICE
    User Principal Name:          
    User SID:                     S-1-5-19

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      
    Logon Id:                     67034
    Logon Time:                   8/16/2026 9:34:41 AM
    Logon Type:                   Interactive
    Start Time:                   
    Domain:                       Window Manager
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    DWM-1
    User Principal Name:          
    User SID:                     S-1-5-90-0-1

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      researchmco.ai
    Logon Id:                     32197
    Logon Time:                   8/16/2026 9:34:41 AM
    Logon Type:                   Interactive
    Start Time:                   
    Domain:                       Font Driver Host
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    UMFD-1
    User Principal Name:          SRV1$@researchmco.ai
    User SID:                     S-1-5-96-0-1

   =================================================================================================

    Method:                       LSA
    Logon Server:                 
    Logon Server Dns Domain:      researchmco.ai
    Logon Id:                     999
    Logon Time:                   8/16/2026 9:34:40 AM
    Logon Type:                   0
    Start Time:                   
    Domain:                       RESEARCHMCO
    Authentication Package:       Negotiate
    Start Time:                   
    User Name:                    SRV1$
    User Principal Name:          SRV1$@researchmco.ai
    User SID:                     S-1-5-18

   =================================================================================================



════════════════════════════════════╣ Processes Information (T1057,T1134.001) ╠════════════════════════════════════

╔══════════╣ Interesting Processes -non Microsoft- (T1057)
╚ Check if any interesting processes for memory dump or if you could overwrite some binary running https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#running-processes                    
    sshd(8188)[C:\WINDOWS\System32\OpenSSH\sshd.exe] -- POwn: hacker
    Possible DLL Hijacking folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                   
    Command Line: "C:\WINDOWS\System32\OpenSSH\sshd.exe" -z
   =================================================================================================                

    secure_loader(1720)[C:\Users\ts_svc\Desktop\secure_loader.exe] -- POwn: ts_svc
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Users\ts_svc\Desktop (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                                               
    Command Line: "C:\Users\ts_svc\Desktop\secure_loader.exe"
   =================================================================================================                

    taskhostw(5596)[C:\WINDOWS\system32\taskhostw.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: taskhostw.exe {222A245B-E637-4AE9-A93F-A59CA119A75E}
   =================================================================================================                

    winPEASx64(5592)[C:\WINDOWS\system32\winPEASx64.exe] -- POwn: SYSTEM -- isDotNet
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "C:\WINDOWS\system32\winPEASx64.exe"
   =================================================================================================                

    conhost(9036)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    lsass(836)[C:\WINDOWS\system32\lsass.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: C:\WINDOWS\system32\lsass.exe
   =================================================================================================                

    conhost(9024)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    sshd(4660)[C:\WINDOWS\System32\OpenSSH\sshd.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                   
    Command Line: "C:\WINDOWS\System32\OpenSSH\sshd.exe" -R
   =================================================================================================                

    powershell(7292)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    sshd(2540)[C:\WINDOWS\System32\OpenSSH\sshd.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                   
    Command Line: C:\WINDOWS\System32\OpenSSH\sshd.exe
   =================================================================================================                

    powershell(5948)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    conhost(3828)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    msedgewebview2(4252)[C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72 (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                
    Command Line: "C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe" --type=crashpad-handler --user-data-dir=C:\Users\ts_svc\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\LocalState\EBWebView /prefetch:4 /pfhostedapp:8fc54d976e2fb81a367175528263f8f3671147a9 --monitor-self-annotation=ptype=crashpad-handler --database=C:\Users\ts_svc\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\LocalState\EBWebView\Crashpad --annotation=IsOfficialBuild=1 --annotation=channel= --annotation=chromium-version=147.0.7727.102 "--annotation=exe=C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe" --annotation=plat=Win64 "--annotation=prod=Edge WebView2" --annotation=ver=147.0.3912.72 --initial-client-data=0x16c,0x170,0x174,0x148,0x17c,0x7fffe2960d58,0x7fffe2960d64,0x7fffe2960d70                                               
   =================================================================================================                

    TiWorker(8988)[C:\WINDOWS\winsxs\amd64_microsoft-windows-servicingstack_31bf3856ad364e35_10.0.26100.32692_none_55686fe46ef9f388\TiWorker.exe] -- POwn: SYSTEM                                                                       
    Command Line: C:\WINDOWS\winsxs\amd64_microsoft-windows-servicingstack_31bf3856ad364e35_10.0.26100.32692_none_55686fe46ef9f388\TiWorker.exe -Embedding                                                                              
   =================================================================================================

    qdrant(3812)[C:\Qdrant\qdrant.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Qdrant (Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])
    Command Line: "C:\Qdrant\qdrant.exe"
   =================================================================================================                

    research-portal(2828)[C:\ResearchPortal\research-portal.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\ResearchPortal (Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])
    Command Line: "C:\ResearchPortal\research-portal.exe"
   =================================================================================================                

    secure_loader(6804)[C:\Users\ts_svc\Desktop\secure_loader.exe] -- POwn: ts_svc
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Users\ts_svc\Desktop (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                                               
    Command Line: "C:\Users\ts_svc\Desktop\secure_loader.exe" 
   =================================================================================================                

    MicrosoftEdgeUpdate(5076)[C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Program Files (x86)\Microsoft\EdgeUpdate (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                           
    Command Line: "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" /c
   =================================================================================================                

    sshd(764)[C:\WINDOWS\System32\OpenSSH\sshd.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                   
    Command Line: "C:\WINDOWS\System32\OpenSSH\sshd.exe" -R
   =================================================================================================                

    powershell(8948)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    mimikatz(880)[C:\Temp\mim\mimikatz.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Temp\mim (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])                                                        
    Command Line: C:\Temp\mim\mimikatz.exe " privilege::debug\
   =================================================================================================

    msedgewebview2(8076)[C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72 (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                
    Command Line: "C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe" --type=utility --utility-sub-type=network.mojom.NetworkService --lang=en-US --service-sandbox-type=none --noerrdialogs --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; Cortana 1.18.9.23723; 10.0.0.0.26100.32690) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.26100 IsWebView2/True (WebView2Version )" --user-data-dir="C:\Users\ts_svc\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\LocalState\EBWebView" --webview-exe-name=SearchHost.exe --webview-exe-version=2125.30600.0.0 --embedded-browser-webview=1 --always-read-main-dll --metrics-shmem-handle=2112,i,2851827862969502992,224818757199722815,524288 --field-trial-handle=1728,i,1509830188825617033,12158377844514947967,262144 --enable-features=msEdgeFluentOverlayScrollbar --disable-features=msSmartScreenProtection --variations-seed-version --pseudonymization-salt-handle=1732,i,6904603127980604579,4531376090543089258,4 --trace-process-track-uuid=3190708989122997041 --mojo-platform-channel-handle=2124 /prefetch:11 /pfhostedapp:8fc54d976e2fb81a367175528263f8f3671147a9                                                                                   
   =================================================================================================                

    StartMenuExperienceHost(6780)[C:\WINDOWS\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\StartMenuExperienceHost.exe] -- POwn: ts_svc                                                                            
    Possible DLL Hijacking folder: C:\WINDOWS\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                 
    Command Line: "C:\WINDOWS\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\StartMenuExperienceHost.exe" -ServerName:FullTrustApp.AppXykjsye98af63ez2annt9djke8trg8stn.mca                                         
   =================================================================================================                

    winlogon(740)[C:\WINDOWS\system32\winlogon.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: winlogon.exe
   =================================================================================================                

    msedgewebview2(2460)[C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72 (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                
    Command Line: "C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe" --embedded-browser-webview=1 --webview-exe-name=SearchHost.exe --webview-exe-version=2125.30600.0.0 --user-data-dir="C:\Users\ts_svc\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\LocalState\EBWebView" --noerrdialogs --disable-features=msSmartScreenProtection --edge-webview-enable-mojo-ipcz --enable-features=msEdgeFluentOverlayScrollbar --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; Cortana 1.18.9.23723; 10.0.0.0.26100.32690) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.26100 IsWebView2/True (WebView2Version )" --lang=en-US --mojo-named-platform-channel-pipe=6724.408.9677969411144482721 /pfhostedapp:8fc54d976e2fb81a367175528263f8f3671147a9                                                                                                           
   =================================================================================================                

    blnsvr(3320)[C:\Program Files\Virtio-Win\Balloon\blnsvr.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Program Files\Virtio-Win\Balloon (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                                   
    Command Line: "C:\Program Files\Virtio-Win\Balloon\blnsvr.exe"
   =================================================================================================                

    AggregatorHost(5036)[C:\WINDOWS\System32\AggregatorHost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\System32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: AggregatorHost.exe
   =================================================================================================                

    conhost(8480)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    conhost(7180)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    mimikatz(3300)[C:\Temp\mim\mimikatz.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Temp\mim (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])                                                        
    Command Line: C:\Temp\mim\mimikatz.exe " privilege::debug\
   =================================================================================================

    explorer(2004)[C:\WINDOWS\Explorer.EXE] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\WINDOWS (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                    
    Command Line: C:\WINDOWS\Explorer.EXE
   =================================================================================================                

    qemu-ga(3292)[C:\Program Files\Qemu-ga\qemu-ga.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Program Files\Qemu-ga (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                                              
    Command Line: "C:\Program Files\Qemu-ga\qemu-ga.exe" -d --retry-path
   =================================================================================================                

    conhost(9016)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    WmiPrvSE(4580)[C:\WINDOWS\system32\wbem\wmiprvse.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32\wbem (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                      
    Command Line: C:\WINDOWS\system32\wbem\wmiprvse.exe
   =================================================================================================                

    secure_loader(1516)[C:\Users\ts_svc\Desktop\secure_loader.exe] -- POwn: ts_svc
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Users\ts_svc\Desktop (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                                               
    Command Line: "C:\Users\ts_svc\Desktop\secure_loader.exe"
   =================================================================================================                

    SearchHost(6724)[C:\WINDOWS\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\SearchHost.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\WINDOWS\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                               
    Command Line: "C:\WINDOWS\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\SearchHost.exe" -ServerName:CortanaUI.AppXstmwaab17q5s3y22tp6apqz7a45vwv65.mca                                                                       
   =================================================================================================                

    powershell(4996)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    sshd(5452)[C:\WINDOWS\System32\OpenSSH\sshd.exe] -- POwn: hacker
    Possible DLL Hijacking folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                   
    Command Line: "C:\WINDOWS\System32\OpenSSH\sshd.exe" -z
   =================================================================================================                

    fontdrvhost(3268)[C:\WINDOWS\system32\fontdrvhost.exe] -- POwn: UMFD-2
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "fontdrvhost.exe"
   =================================================================================================                

    powershell(4556)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    conhost(5236)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    gp(3684)[C:\Temp\gp.exe] -- POwn: SYSTEM -- isDotNet
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Temp (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])                                                            
    Command Line: "C:\Temp\gp.exe" -cmd "C:\Temp\mim\mimikatz.exe \" "privilege::debug\ \sekurlsa::logonpasswords\ \lsadump::dcsync" "/user:krbtgt\ \exit\"                                                                             
   =================================================================================================                

    conhost(8844)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    rdpclip(5392)[C:\WINDOWS\System32\rdpclip.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\WINDOWS\System32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: rdpclip
   =================================================================================================                

    secure_loader(1508)[C:\Users\ts_svc\Desktop\secure_loader.exe] -- POwn: ts_svc
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Users\ts_svc\Desktop (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                                               
    Command Line: secure_loader.exe
   =================================================================================================                

    CHXSmartScreen(5428)[C:\Windows\SystemApps\Microsoft.Windows.AppRep.ChxApp_cw5n1h2txyewy\CHXSmartScreen.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\Windows\SystemApps\Microsoft.Windows.AppRep.ChxApp_cw5n1h2txyewy (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                           
    Command Line: "C:\Windows\SystemApps\Microsoft.Windows.AppRep.ChxApp_cw5n1h2txyewy\CHXSmartScreen.exe" -ServerName:App.AppXk7vvv12h4qrkhkbvf6j86ja45mzj5km9.mca                                                                     
   =================================================================================================                

    sihost(5812)[C:\WINDOWS\system32\sihost.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: sihost.exe
   =================================================================================================                

    ShellExperienceHost(2780)[C:\WINDOWS\SystemApps\ShellExperienceHost_cw5n1h2txyewy\ShellExperienceHost.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\WINDOWS\SystemApps\ShellExperienceHost_cw5n1h2txyewy (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                       
    Command Line: "C:\WINDOWS\SystemApps\ShellExperienceHost_cw5n1h2txyewy\ShellExperienceHost.exe" -ServerName:App.AppXtk181tbxbce2qsex02s8tw7hfxa9xb3t.mca                                                                            
   =================================================================================================                

    conhost(4500)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    msedgewebview2(5792)[C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72 (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                
    Command Line: "C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe" --type=renderer --noerrdialogs --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; Cortana 1.18.9.23723; 10.0.0.0.26100.32690) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.26100 IsWebView2/True (WebView2Version )" --user-data-dir="C:\Users\ts_svc\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\LocalState\EBWebView" --webview-exe-name=SearchHost.exe --webview-exe-version=2125.30600.0.0 --embedded-browser-webview=1 --video-capture-use-gpu-memory-buffer --lang=en-US --js-flags=--expose-gc --device-scale-factor=1 --num-raster-threads=1 --renderer-client-id=5 --time-ticks-at-unix-epoch=-1786872872728001 --launch-time-ticks=1692077894 --always-read-main-dll --metrics-shmem-handle=3228,i,6558919031880484224,2968141281624187077,2097152 --field-trial-handle=1728,i,1509830188825617033,12158377844514947967,262144 --enable-features=msEdgeFluentOverlayScrollbar --disable-features=msSmartScreenProtection --variations-seed-version --pseudonymization-salt-handle=1732,i,6904603127980604579,4531376090543089258,4 --trace-process-track-uuid=3190708990997080739 --mojo-platform-channel-handle=3284 /pfhostedapp:8fc54d976e2fb81a367175528263f8f3671147a9 /prefetch:1                                                                  
   =================================================================================================                

    powershell(7080)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    conhost(8360)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    rundlll(4472)[C:\Users\ts_svc\AppData\Local\Temp\WinUpdate\rundlll.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Users\ts_svc\AppData\Local\Temp\WinUpdate (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                          
    Command Line: "C:\Users\ts_svc\AppData\Local\Temp\WinUpdate\rundlll.exe"
   =================================================================================================                

    svchost(1884)[C:\WINDOWS\system32\svchost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: C:\WINDOWS\system32\svchost.exe -k LocalSystemNetworkRestricted -p -s SysMain
   =================================================================================================

    sshd(8348)[C:\WINDOWS\System32\OpenSSH\sshd.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                   
    Command Line: "C:\WINDOWS\System32\OpenSSH\sshd.exe" -R
   =================================================================================================                

    conhost(8340)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    powershell(4740)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    fontdrvhost(1008)[C:\WINDOWS\system32\fontdrvhost.exe] -- POwn: UMFD-1
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "fontdrvhost.exe"
   =================================================================================================                

    fontdrvhost(1004)[C:\WINDOWS\system32\fontdrvhost.exe] -- POwn: UMFD-0
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "fontdrvhost.exe"
   =================================================================================================                

    dwm(1000)[C:\WINDOWS\system32\dwm.exe] -- POwn: DWM-1
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "dwm.exe"
   =================================================================================================                

    conhost(4876)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    mimikatz(5736)[C:\Temp\mim\mimikatz.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Temp\mim (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])                                                        
    Command Line: C:\Temp\mim\mimikatz.exe
   =================================================================================================                

    qdrant(8744)[C:\Qdrant\qdrant.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Qdrant (Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])
    Command Line: "C:\Qdrant\qdrant.exe"
   =================================================================================================                

    mimikatz(2088)[C:\Temp\mim\mimikatz.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Temp\mim (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])                                                        
    Command Line: "C:\Temp\mim\mimikatz.exe"
   =================================================================================================                

    conhost(3496)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    mimikatz(976)[C:\Temp\mimikatz.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Temp (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])                                                            
    Command Line: "C:\Temp\mimikatz.exe"
   =================================================================================================                

    qdrant(3984)[C:\Qdrant\qdrant.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Qdrant (Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])
    Command Line: "C:\Qdrant\qdrant.exe"
   =================================================================================================                

    powershell(7000)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    dwm(4840)[C:\WINDOWS\system32\dwm.exe] -- POwn: DWM-2
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "dwm.exe"
   =================================================================================================                

    gp(8272)[C:\Temp\gp.exe] -- POwn: SYSTEM -- isDotNet
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Temp (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])                                                            
    Command Line: "C:\Temp\gp.exe" -cmd "C:\Temp\mim\mimikatz.exe \" "privilege::debug\ \sekurlsa::logonpasswords\ \lsadump::dcsync" "/user:krbtgt\ \exit\"                                                                             
   =================================================================================================                

    msedgewebview2(4388)[C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72 (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                
    Command Line: "C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe" --type=gpu-process --noerrdialogs --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; Cortana 1.18.9.23723; 10.0.0.0.26100.32690) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.26100 IsWebView2/True (WebView2Version )" --user-data-dir="C:\Users\ts_svc\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\LocalState\EBWebView" --webview-exe-name=SearchHost.exe --webview-exe-version=2125.30600.0.0 --embedded-browser-webview=1 --gpu-preferences=SAAAAAAAAADgAAAEAAAAAAAAAAAAAGAAAQAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAQAAAAAAAAABAAAAAAAAAACAAAAAAAAAAIAAAAAAAAAA== --always-read-main-dll --metrics-shmem-handle=1608,i,12519722459952666244,8019044445703249405,262144 --field-trial-handle=1728,i,1509830188825617033,12158377844514947967,262144 --enable-features=msEdgeFluentOverlayScrollbar --disable-features=msSmartScreenProtection --variations-seed-version --pseudonymization-salt-handle=1732,i,6904603127980604579,4531376090543089258,4 --trace-process-track-uuid=3190708988185955192 --mojo-platform-channel-handle=1720 /prefetch:2 /pfhostedapp:8fc54d976e2fb81a367175528263f8f3671147a9                            
   =================================================================================================                

    powershell(5148)[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe] -- POwn: SYSTEM
    Permissions: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    Possible DLL Hijacking folder: C:\Windows\System32\WindowsPowerShell\v1.0 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                    
    Command Line: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command [Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8
   =================================================================================================

    LogonUI(4364)[C:\WINDOWS\system32\LogonUI.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "LogonUI.exe" /flags:0x2 /state0:0xa39bc855 /state1:0x41c64e6d
   =================================================================================================                

    sshd(912)[C:\WINDOWS\System32\OpenSSH\sshd.exe] -- POwn: hacker
    Possible DLL Hijacking folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                   
    Command Line: "C:\WINDOWS\System32\OpenSSH\sshd.exe" -z
   =================================================================================================                

    msedgewebview2(6944)[C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72 (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                
    Command Line: "C:\Program Files (x86)\Microsoft\EdgeWebView\Application\147.0.3912.72\msedgewebview2.exe" --type=utility --utility-sub-type=storage.mojom.StorageService --lang=en-US --service-sandbox-type=service --noerrdialogs --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; Cortana 1.18.9.23723; 10.0.0.0.26100.32690) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.26100 IsWebView2/True (WebView2Version )" --user-data-dir="C:\Users\ts_svc\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\LocalState\EBWebView" --webview-exe-name=SearchHost.exe --webview-exe-version=2125.30600.0.0 --embedded-browser-webview=1 --always-read-main-dll --metrics-shmem-handle=2388,i,10734789100265456092,9451215861176834564,524288 --field-trial-handle=1728,i,1509830188825617033,12158377844514947967,262144 --enable-features=msEdgeFluentOverlayScrollbar --disable-features=msSmartScreenProtection --variations-seed-version --pseudonymization-salt-handle=1732,i,6904603127980604579,4531376090543089258,4 --trace-process-track-uuid=3190708990060038890 --mojo-platform-channel-handle=2652 /prefetch:13 /pfhostedapp:8fc54d976e2fb81a367175528263f8f3671147a9                                                                              
   =================================================================================================                

    gp(9096)[C:\Temp\gp.exe] -- POwn: SYSTEM -- isDotNet
    Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking folder: C:\Temp (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories WriteData/CreateFiles])                                                            
    Command Line: "C:\Temp\gp.exe" -cmd C:\Temp\mim\mimikatz.exe
   =================================================================================================                

    winlogon(3920)[C:\WINDOWS\system32\winlogon.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: winlogon.exe {F4207EF8-594D-4B82-86F3-976FF9FB0000}
   =================================================================================================                

    ShellHost(3052)[C:\Windows\System32\ShellHost.exe] -- POwn: ts_svc
    Possible DLL Hijacking folder: C:\Windows\System32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "C:\Windows\System32\ShellHost.exe"
   =================================================================================================                

    conhost(3908)[C:\WINDOWS\system32\conhost.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: \??\C:\WINDOWS\system32\conhost.exe 0x4
   =================================================================================================

    LogonUI(624)[C:\WINDOWS\system32\LogonUI.exe] -- POwn: SYSTEM
    Possible DLL Hijacking folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                           
    Command Line: "LogonUI.exe" /flags:0x0 /state0:0xa3041055 /state1:0x41c64e6d
   =================================================================================================                


╔══════════╣ Vulnerable Leaked Handlers (T1134.001)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#leaked-handlers
╚ Getting Leaked Handlers, it might take some time...
    Handle: 632(process)
    Handle Owner: Pid is 740(winlogon) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1000(DWM-1)
   =================================================================================================

    Handle: 1304(file)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: WriteData/CreateFiles
    File Path: \Windows\debug\PASSWD.LOG
    File Owner: BUILTIN\Administrators
   =================================================================================================

    Handle: 2128(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 820(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2176(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 820(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2312(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 704(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2404(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 704(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2436(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 544(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2452(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 944(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2484(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 544(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2520(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 352(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2612(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 864(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2668(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1124(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2704(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1404(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2728(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1480(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2780(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1580(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2832(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1668(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2912(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2032(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2936(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1624(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2956(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1196(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 2980(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1196(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3000(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1384(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3040(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1500(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3128(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2696(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3148(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 4(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3156(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2696(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3228(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 6724(ts_svc)
   =================================================================================================

    Handle: 3252(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1508(ts_svc)
   =================================================================================================

    Handle: 3268(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2696(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3272(file)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: WriteData/CreateFiles
    File Path: \Windows\debug\netlogon.log
    File Owner: BUILTIN\Administrators
   =================================================================================================

    Handle: 3508(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2940(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3564(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 5968(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3660(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2516(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3736(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2032(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3800(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 4(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3808(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 3424(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3856(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2328(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3888(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 4(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3916(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 3000(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 3976(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1236(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4012(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 6780(ts_svc)
   =================================================================================================

    Handle: 4024(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 3368(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4080(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 3628(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4216(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1652(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4276(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 3360(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4344(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 4(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4388(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2988(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4744(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1080(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4784(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 5428(ts_svc)
   =================================================================================================

    Handle: 4812(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1720(ts_svc)
   =================================================================================================

    Handle: 4844(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 3360(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4888(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 180(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 4996(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1204(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5024(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2780(ts_svc)
   =================================================================================================

    Handle: 5032(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2232(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5060(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1516(ts_svc)
   =================================================================================================

    Handle: 5192(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 6016(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5220(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 1352(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5236(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2872(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5876(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2872(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5892(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 3564(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5900(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 7552(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5944(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2152(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 5964(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2004(ts_svc)
   =================================================================================================

    Handle: 6200(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 5560(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 6256(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 2460(ts_svc)
   =================================================================================================

    Handle: 6392(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 6804(ts_svc)
   =================================================================================================

    Handle: 6456(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 4972(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 6476(process)
    Handle Owner: Pid is 836(lsass) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 4972(Access denied, process is probably elevated)
   =================================================================================================

    Handle: 892(process)
    Handle Owner: Pid is 3920(winlogon) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 4840(DWM-2)
   =================================================================================================

    Handle: 648(file)
    Handle Owner: Pid is 5076(MicrosoftEdgeUpdate) with owner: SYSTEM
    Reason: WriteData/CreateFiles
    File Path: \ProgramData\Microsoft\EdgeUpdate\Log\MicrosoftEdgeUpdate.log
    File Owner: BUILTIN\Administrators
   =================================================================================================

    Handle: 588(process)
    Handle Owner: Pid is 4660(sshd) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 8188(hacker)
   =================================================================================================

    Handle: 628(process)
    Handle Owner: Pid is 8348(sshd) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 912(hacker)
   =================================================================================================

    Handle: 576(process)
    Handle Owner: Pid is 764(sshd) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 5452(hacker)
   =================================================================================================

    Handle: 1456(process)
    Handle Owner: Pid is 4472(rundlll) with owner: SYSTEM
    Reason: PROCESS_ALL_ACCESS
    Handle PID: 9120(Error, process may not exist)
   =================================================================================================



════════════════════════════════════╣ Services Information (T1007,T1543.003,T1574.001,T1574.011,T1014,T1068) ╠════════════════════════════════════                                                                                      

╔══════════╣ Interesting Services -non Microsoft- (T1007)
╚ Check if you can overwrite some service binary or perform a DLL hijacking, also check for unquoted paths https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#services                     
    BalloonService(BalloonService)["C:\Program Files\Virtio-Win\Balloon\blnsvr.exe"] - Auto - Running
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\Program Files\Virtio-Win\Balloon (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                         
    Balloon Service
   =================================================================================================                

    cloudbase-init(Cloudbase Solutions Srl - cloudbase-init)["C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\OpenStackService.exe" cloudbase-init "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\Python\Scripts\cloudbase-init.exe" --config-file "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"] - Auto - Stopped
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                     
    Cloud Initialization Service
   =================================================================================================                

    MongoDB(MongoDB, Inc - MongoDB Server (MongoDB))["C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" --config "C:\Program Files\MongoDB\Server\7.0\bin\mongod.cfg" --service] - Auto - Running                                     
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\Program Files\MongoDB\Server\7.0\bin (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                     
    MongoDB Database Server (MongoDB)
   =================================================================================================                

    QEMU-GA(https://www.qemu.org - QEMU Guest Agent)["C:\Program Files\Qemu-ga\qemu-ga.exe" -d --retry-path] - Auto - Running
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\Program Files\Qemu-ga (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                                    
    QEMU Guest Agent
   =================================================================================================                

    spice-agent(Red Hat Inc. - Spice Agent)["C:\Program Files\Spice Agent\vdservice.exe"] - Auto - Stopped
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\Program Files\Spice Agent (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                                
    The Spice guest agent
   =================================================================================================                

    ssh-agent(OpenSSH Authentication Agent)[C:\WINDOWS\System32\OpenSSH\ssh-agent.exe] - Disabled - Stopped
    YOU CAN MODIFY THIS SERVICE: Start, GenericExecute (Start/Stop), AllAccess
    Possible DLL Hijacking in binary folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                         
    Agent to hold private keys used for public key authentication.
   =================================================================================================                

    sshd(OpenSSH SSH Server)[C:\WINDOWS\System32\OpenSSH\sshd.exe] - Auto - Running
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    Possible DLL Hijacking in binary folder: C:\WINDOWS\System32\OpenSSH (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                         
    SSH protocol based service to provide secure encrypted communications between two untrusted hosts over an insecure network.                                                                                                         
   =================================================================================================                

    VGAuthService(VMware, Inc. - VMware Alias Manager and Ticket Service)["C:\Program Files\VMware\VMware Tools\VMware VGAuth\VGAuthService.exe"] - Disabled - Stopped                                                                  
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\Program Files\VMware\VMware Tools\VMware VGAuth (Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess])                                                                          
    Alias Manager and Ticket Service
   =================================================================================================                

    VirtioFsSvc(VirtIO-FS Service)["C:\Program Files\Virtio-Win\VioFS\virtiofs.exe"] - Manual - Stopped
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\Program Files\Virtio-Win\VioFS (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                           
    Enables Windows virtual machines to access directories on the host that have been shared with them using virtiofs.                                                                                                                  
   =================================================================================================                

    vm3dservice(VMware, Inc. - VMware SVGA Helper Service)[C:\WINDOWS\system32\vm3dservice.exe] - Disabled - Stopped
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: SYSTEM [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\WINDOWS\system32 (SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                 
    Helps VMware SVGA driver by collecting and conveying user mode information
   =================================================================================================                

    VMTools(VMware, Inc. - VMware Tools)["C:\Program Files\VMware\VMware Tools\vmtoolsd.exe"] - Disabled - Stopped
    YOU CAN MODIFY THIS SERVICE: GenericExecute (Start/Stop), AllAccess
    File Permissions: Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess]
    Possible DLL Hijacking in binary folder: C:\Program Files\VMware\VMware Tools (SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])                                                                                        
    Provides support for synchronizing objects between the host and guest operating systems.
   =================================================================================================                


╔══════════╣ Modifiable Services (T1543.003)
╚ Check if you can modify any service https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#services                                                                                          
    LOOKS LIKE YOU CAN MODIFY OR START/STOP SOME SERVICE/s:
    ALG: GenericExecute (Start/Stop), AllAccess
    AppIDSvc: GenericExecute (Start/Stop), AllAccess
    Appinfo: GenericExecute (Start/Stop), AllAccess
    AppMgmt: AllAccess
    AppReadiness: GenericExecute (Start/Stop), AllAccess
    AppVClient: Start, AllAccess
    AppXSvc: Start, GenericExecute (Start/Stop)
    AudioEndpointBuilder: GenericExecute (Start/Stop), AllAccess
    Audiosrv: GenericExecute (Start/Stop), AllAccess
    AxInstSV: GenericExecute (Start/Stop), AllAccess
    BalloonService: GenericExecute (Start/Stop), AllAccess
    BFE: ChangeConfig, WriteDac
    BITS: AllAccess
    BrokerInfrastructure: ChangeConfig, WriteDac, Start
    BTAGService: GenericExecute (Start/Stop), AllAccess
    BthAvctpSvc: GenericExecute (Start/Stop), AllAccess
    bthserv: GenericExecute (Start/Stop), AllAccess
    camsvc: GenericExecute (Start/Stop), AllAccess
    CDPSvc: GenericExecute (Start/Stop), AllAccess
    CertPropSvc: AllAccess, ChangeConfig
    ClipSVC: Start, ChangeConfig, WriteDac
    cloudbase-init: GenericExecute (Start/Stop), AllAccess
    COMSysApp: GenericExecute (Start/Stop), AllAccess
    CoreMessagingRegistrar: Start, GenericExecute (Start/Stop)
    CryptSvc: GenericExecute (Start/Stop), AllAccess
    CscService: GenericExecute (Start/Stop), AllAccess
    DcomLaunch: ChangeConfig, WriteDac
    dcsvc: GenericExecute (Start/Stop), AllAccess
    defragsvc: GenericExecute (Start/Stop), AllAccess
    DeviceAssociationService: GenericExecute (Start/Stop), AllAccess
    DeviceInstall: GenericExecute (Start/Stop), AllAccess
    DevQueryBroker: GenericExecute (Start/Stop), AllAccess
    Dhcp: Start, GenericExecute (Start/Stop), AllAccess
    DiagTrack: GenericExecute (Start/Stop), AllAccess
    DispBrokerDesktopSvc: GenericExecute (Start/Stop), AllAccess
    DisplayEnhancementService: Start, GenericExecute (Start/Stop), AllAccess
    DmEnrollmentSvc: GenericExecute (Start/Stop), AllAccess
    dmwappushservice: Start, AllAccess
    DoSvc: Start, AllAccess
    dot3svc: GenericExecute (Start/Stop), AllAccess
    DPS: AllAccess, ChangeConfig
    DsmSvc: GenericExecute (Start/Stop), AllAccess, Start
    DsSvc: Start, AllAccess
    EapHost: GenericExecute (Start/Stop), AllAccess
    edgeupdate: GenericExecute (Start/Stop), AllAccess
    edgeupdatem: GenericExecute (Start/Stop), AllAccess
    EFS: Start, AllAccess, ChangeConfig
    embeddedmode: Start, AllAccess, GenericExecute (Start/Stop)
    EntAppSvc: Start, GenericExecute (Start/Stop)
    EventLog: GenericExecute (Start/Stop), AllAccess
    EventSystem: GenericExecute (Start/Stop), AllAccess
    fdPHost: GenericExecute (Start/Stop), AllAccess
    FDResPub: GenericExecute (Start/Stop), AllAccess
    FontCache: Start, GenericExecute (Start/Stop), AllAccess
    FrameServer: GenericExecute (Start/Stop), AllAccess
    FrameServerMonitor: GenericExecute (Start/Stop), AllAccess
    GameInputSvc: GenericExecute (Start/Stop), AllAccess
    gpsvc: AllAccess
    GraphicsPerfSvc: GenericExecute (Start/Stop), AllAccess
    hidserv: GenericExecute (Start/Stop), AllAccess
    hpatchmon: GenericExecute (Start/Stop), AllAccess
    HvHost: GenericExecute (Start/Stop), AllAccess
    IKEEXT: GenericExecute (Start/Stop), AllAccess
    InstallService: GenericExecute (Start/Stop), AllAccess
    InventorySvc: GenericExecute (Start/Stop), AllAccess, Start
    iphlpsvc: GenericExecute (Start/Stop), AllAccess
    KeyIso: Start, GenericExecute (Start/Stop), AllAccess
    KPSSVC: GenericExecute (Start/Stop), AllAccess
    KtmRm: Start, GenericExecute (Start/Stop), AllAccess
    LanmanServer: GenericExecute (Start/Stop), AllAccess
    LanmanWorkstation: GenericExecute (Start/Stop), AllAccess
    lfsvc: AllAccess
    LicenseManager: GenericExecute (Start/Stop), AllAccess
    lltdsvc: GenericExecute (Start/Stop), AllAccess
    lmhosts: GenericExecute (Start/Stop), AllAccess
    LocalKdc: AllAccess
    LSM: ChangeConfig
    LxpSvc: GenericExecute (Start/Stop), AllAccess
    MapsBroker: Start, AllAccess
    McpManagementService: GenericExecute (Start/Stop), AllAccess
    MicrosoftEdgeElevationService: GenericExecute (Start/Stop), AllAccess
    MongoDB: GenericExecute (Start/Stop), AllAccess
    mpssvc: ChangeConfig, WriteDac
    MSDTC: Start, ChangeConfig
    MSiSCSI: GenericExecute (Start/Stop), AllAccess
    msiserver: Start, GenericExecute (Start/Stop)
    NaturalAuthentication: GenericExecute (Start/Stop), AllAccess
    NcaSvc: GenericExecute (Start/Stop), AllAccess
    NcbService: GenericExecute (Start/Stop), AllAccess
    Netlogon: GenericExecute (Start/Stop), AllAccess
    Netman: GenericExecute (Start/Stop), AllAccess
    netprofm: GenericExecute (Start/Stop), AllAccess
    NetSetupSvc: AllAccess, Start
    NetTcpPortSharing: Start, GenericExecute (Start/Stop), AllAccess
    NgcCtnrSvc: ChangeConfig, WriteDac
    NgcSvc: ChangeConfig, WriteDac
    NlaSvc: GenericExecute (Start/Stop), AllAccess
    nsi: GenericExecute (Start/Stop), AllAccess
    PcaSvc: GenericExecute (Start/Stop), AllAccess
    PerfHost: GenericExecute (Start/Stop), AllAccess
    pla: Start, GenericExecute (Start/Stop), AllAccess
    PlugPlay: GenericExecute (Start/Stop), AllAccess
    PolicyAgent: GenericExecute (Start/Stop), AllAccess
    Power: GenericExecute (Start/Stop), AllAccess
    PrintDeviceConfigurationService: GenericExecute (Start/Stop), AllAccess
    PrintNotify: GenericExecute (Start/Stop), AllAccess
    PrintScanBrokerService: GenericExecute (Start/Stop), AllAccess
    ProfSvc: GenericExecute (Start/Stop), AllAccess
    PushToInstall: GenericExecute (Start/Stop), AllAccess
    QEMU Guest Agent VSS Provider: GenericExecute (Start/Stop), AllAccess
    QEMU-GA: GenericExecute (Start/Stop), AllAccess
    QWAVE: AllAccess
    RasAuto: GenericExecute (Start/Stop), AllAccess
    RasMan: Start, AllAccess
    refsdedupsvc: GenericExecute (Start/Stop), AllAccess
    RemoteAccess: GenericExecute (Start/Stop), AllAccess
    RemoteRegistry: GenericExecute (Start/Stop), AllAccess
    RmSvc: ChangeConfig, GenericExecute (Start/Stop)
    RpcEptMapper: ChangeConfig, WriteDac, Start
    RpcLocator: GenericExecute (Start/Stop), AllAccess
    RpcSs: ChangeConfig, WriteDac
    RSoPProv: GenericExecute (Start/Stop), AllAccess
    sacsvr: GenericExecute (Start/Stop), AllAccess
    SamSs: AllAccess
    SCardSvr: AllAccess, ChangeConfig
    ScDeviceEnum: AllAccess, ChangeConfig
    Schedule: AllAccess, WriteDac
    SCPolicySvc: AllAccess, ChangeConfig
    seclogon: Start, GenericExecute (Start/Stop), AllAccess
    SEMgrSvc: AllAccess
    SENS: GenericExecute (Start/Stop), AllAccess
    Sense: Start, GenericExecute (Start/Stop), ChangeConfig
    SensorDataService: GenericExecute (Start/Stop), AllAccess
    SensorService: Start, GenericExecute (Start/Stop), AllAccess
    SensrSvc: Start, GenericExecute (Start/Stop), AllAccess
    SessionEnv: GenericExecute (Start/Stop), AllAccess
    SharedAccess: Start, GenericExecute (Start/Stop), AllAccess
    ShellHWDetection: GenericExecute (Start/Stop), AllAccess
    shpamsvc: GenericExecute (Start/Stop), AllAccess
    smphost: Start, GenericExecute (Start/Stop), AllAccess
    SNMPTrap: GenericExecute (Start/Stop), AllAccess
    spice-agent: GenericExecute (Start/Stop), AllAccess
    Spooler: GenericExecute (Start/Stop), AllAccess
    sppsvc: Start, ChangeConfig, WriteDac
    SSDPSRV: AllAccess
    ssh-agent: Start, GenericExecute (Start/Stop), AllAccess
    sshd: GenericExecute (Start/Stop), AllAccess
    SstpSvc: Start, GenericExecute (Start/Stop), AllAccess
    StateRepository: Start, GenericExecute (Start/Stop)
    StiSvc: GenericExecute (Start/Stop), AllAccess
    StorSvc: GenericExecute (Start/Stop), AllAccess
    svsvc: GenericExecute (Start/Stop), AllAccess
    swprv: GenericExecute (Start/Stop), AllAccess
    SysMain: GenericExecute (Start/Stop), AllAccess
    SystemEventsBroker: ChangeConfig, WriteDac, Start
    tapisrv: Start, GenericExecute (Start/Stop), AllAccess
    TermService: GenericExecute (Start/Stop), AllAccess
    TextInputManagementService: Start, GenericExecute (Start/Stop)
    Themes: GenericExecute (Start/Stop), AllAccess
    TieringEngineService: GenericExecute (Start/Stop), AllAccess
    TimeBrokerSvc: ChangeConfig, WriteDac, Start
    TokenBroker: GenericExecute (Start/Stop), AllAccess
    TrkWks: GenericExecute (Start/Stop), AllAccess
    TrustedInstaller: AllAccess, ChangeConfig
    tzautoupdate: GenericExecute (Start/Stop), AllAccess
    UALSVC: GenericExecute (Start/Stop), AllAccess
    UevAgentService: Start, AllAccess
    UmRdpService: GenericExecute (Start/Stop), AllAccess
    upnphost: AllAccess
    UserManager: GenericExecute (Start/Stop), AllAccess
    UsoSvc: Start, AllAccess
    VaultSvc: Start, GenericExecute (Start/Stop), AllAccess
    vds: GenericExecute (Start/Stop), AllAccess
    VGAuthService: GenericExecute (Start/Stop), AllAccess
    VirtioFsSvc: GenericExecute (Start/Stop), AllAccess
    vm3dservice: GenericExecute (Start/Stop), AllAccess
    vmicguestinterface: GenericExecute (Start/Stop), AllAccess
    vmicheartbeat: GenericExecute (Start/Stop), AllAccess
    vmickvpexchange: GenericExecute (Start/Stop), AllAccess
    vmicrdv: GenericExecute (Start/Stop), AllAccess
    vmicshutdown: GenericExecute (Start/Stop), AllAccess
    vmictimesync: GenericExecute (Start/Stop), AllAccess
    vmicvmsession: GenericExecute (Start/Stop), AllAccess
    vmicvss: GenericExecute (Start/Stop), AllAccess
    VMTools: GenericExecute (Start/Stop), AllAccess
    vmvss: GenericExecute (Start/Stop), AllAccess
    VSS: GenericExecute (Start/Stop), AllAccess
    W32Time: GenericExecute (Start/Stop), AllAccess
    WaaSMedicSvc: Start, AllAccess
    WalletService: GenericExecute (Start/Stop), AllAccess
    WarpJITSvc: GenericExecute (Start/Stop), AllAccess
    WbioSrvc: GenericExecute (Start/Stop), AllAccess
    Wcmsvc: GenericExecute (Start/Stop), AllAccess
    wcncsvc: AllAccess
    WdiServiceHost: AllAccess, ChangeConfig
    WdiSystemHost: AllAccess, ChangeConfig
    Wecsvc: GenericExecute (Start/Stop), AllAccess
    WEPHOSTSVC: GenericExecute (Start/Stop), AllAccess
    wercplsupport: GenericExecute (Start/Stop), AllAccess
    WerSvc: GenericExecute (Start/Stop), AllAccess
    WFDSConMgrSvc: GenericExecute (Start/Stop), AllAccess
    WiaRpc: GenericExecute (Start/Stop), AllAccess
    Winmgmt: GenericExecute (Start/Stop), AllAccess
    WinRM: GenericExecute (Start/Stop), AllAccess
    wisvc: GenericExecute (Start/Stop), AllAccess
    WlanSvc: GenericExecute (Start/Stop), AllAccess
    wlidsvc: GenericExecute (Start/Stop), AllAccess
    WManSvc: GenericExecute (Start/Stop), AllAccess
    wmiApSrv: GenericExecute (Start/Stop), AllAccess
    WMPNetworkSvc: GenericExecute (Start/Stop), AllAccess
    workfolderssvc: GenericExecute (Start/Stop), AllAccess
    WPDBusEnum: GenericExecute (Start/Stop), AllAccess
    WpnService: GenericExecute (Start/Stop), AllAccess
    WSAIFabricSvc: GenericExecute (Start/Stop), AllAccess
    WSearch: GenericExecute (Start/Stop), AllAccess
    wuauserv: Start, AllAccess
    XblAuthManager: GenericExecute (Start/Stop), AllAccess
    ZTHELPER: AllAccess
    BluetoothUserService_136f2d0: GenericExecute (Start/Stop), AllAccess
    CaptureService_136f2d0: GenericExecute (Start/Stop), AllAccess
    cbdhsvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    CDPUserSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    CloudBackupRestoreSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    ConsentUxUserSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    CredentialEnrollmentManagerUserSvc_136f2d0: GenericExecute (Start/Stop)
    DeviceAssociationBrokerSvc_136f2d0: GenericExecute (Start/Stop)
    DevicePickerUserSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    DevicesFlowUserSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    NPSMSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    OneSyncSvc_136f2d0: Start, AllAccess
    P9RdrService_136f2d0: GenericExecute (Start/Stop), AllAccess
    PimIndexMaintenanceSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    PrintWorkflowUserSvc_136f2d0: GenericExecute (Start/Stop)
    UdkUserSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    UnistoreSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    UserDataSvc_136f2d0: GenericExecute (Start/Stop), AllAccess
    WpnUserService_136f2d0: GenericExecute (Start/Stop), AllAccess

╔══════════╣ Looking if you can modify any service registry (T1574.011)
╚ Check if you can modify the registry of a service https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#services-registry-modify-permissions                                                
    HKLM\system\currentcontrolset\services\.NET CLR Data (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\.NET CLR Networking (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                 
    HKLM\system\currentcontrolset\services\.NET CLR Networking 4.0.0.0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                         
    HKLM\system\currentcontrolset\services\.NET Data Provider for Oracle (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                       
    HKLM\system\currentcontrolset\services\.NET Data Provider for SqlServer (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                    
    HKLM\system\currentcontrolset\services\.NET Memory Cache 4.0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                               
    HKLM\system\currentcontrolset\services\.NETFramework (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\1394ohci (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\3ware (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\ACPI (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\AcpiAudioCompositorInbox (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                            
    HKLM\system\currentcontrolset\services\AcpiDev (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\acpiex (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\acpipagr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\AcpiPmi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\acpitime (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Acx01000 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\ADOVMPPackage (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\ADP80XX (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\adsi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\AFD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\afunix (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\ahcache (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\ALG (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\amdgpio2 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\amdi2c (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\AmdK8 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\AmdPPM (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\amdsata (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\amdsbs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\amdwps (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\amdxata (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\AppID (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\AppIDSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Appinfo (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\AppleSSD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\applockerfltr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\AppMgmt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\AppReadiness (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\AppVClient (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\AppvStrm (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\AppvVemgr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\AppvVfs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\AppXSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\arcsas (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\AsyncMac (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\atapi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\AudioEndpointBuilder (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\Audiosrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\AxInstSV (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\b06bdrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\BALLOON (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\BalloonService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\bam (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\BasicDisplay (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\BasicRender (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\BattC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\bcmfn2 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\Beep (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\bfadfcoei (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\bfadi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\BFE (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\bfs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\bindflt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\BITS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\BluetoothUserService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\BluetoothUserService_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                        
    HKLM\system\currentcontrolset\services\bowser (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\BrokerInfrastructure (SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\BTAGService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\BthA2dp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\BthAvctpSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\BthEnum (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\BthHFEnum (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\BthLEEnum (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\BthMini (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\BTHPORT (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\bthserv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\BTHUSB (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\bttflt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\buttonconverter (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\bxfcoe (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\bxois (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\CAD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\camsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\CaptureService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\CaptureService_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                              
    HKLM\system\currentcontrolset\services\cbdhsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\cbdhsvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\CDD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\cdfs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\CDPSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\CDPUserSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\CDPUserSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\cdrom (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\CertPropSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\cht4iscsi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\cht4vbd (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\CimFS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\CldFlt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\CLFS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\ClipSVC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\CloudBackupRestoreSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                               
    HKLM\system\currentcontrolset\services\CloudBackupRestoreSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                       
    HKLM\system\currentcontrolset\services\cloudbase-init (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\clr_optimization_v4.0.30319_32 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                      
    HKLM\system\currentcontrolset\services\clr_optimization_v4.0.30319_64 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                      
    HKLM\system\currentcontrolset\services\CmBatt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\CNG (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\cnghwassist (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\CompositeBus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\COMSysApp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\condrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\ConsentUxUserSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\ConsentUxUserSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                            
    HKLM\system\currentcontrolset\services\CoreMessagingRegistrar (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                              
    HKLM\system\currentcontrolset\services\CoreUI (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\CredentialEnrollmentManagerUserSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                  
    HKLM\system\currentcontrolset\services\CredentialEnrollmentManagerUserSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                          
    HKLM\system\currentcontrolset\services\crypt32 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\CryptSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\CSC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\CscService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\dam (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\DCLocator (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\DcomLaunch (SYSTEM [Allow: GenericAll FullControl])
    HKLM\system\currentcontrolset\services\dcsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\defragsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\DeviceAssociationBrokerSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                          
    HKLM\system\currentcontrolset\services\DeviceAssociationBrokerSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                  
    HKLM\system\currentcontrolset\services\DeviceAssociationService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                            
    HKLM\system\currentcontrolset\services\DeviceInstall (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\DevicePickerUserSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                 
    HKLM\system\currentcontrolset\services\DevicePickerUserSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                         
    HKLM\system\currentcontrolset\services\DevicesFlowUserSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\DevicesFlowUserSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                          
    HKLM\system\currentcontrolset\services\devmap (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\DevQueryBroker (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\Dfsc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\Dhcp (SYSTEM [Allow: GenericAll FullControl], Administrators [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\DiagTrack (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\disk (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\DispBrokerDesktopSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\DisplayEnhancementService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                           
    HKLM\system\currentcontrolset\services\DisplayMux (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\DmEnrollmentSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\dmvsc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\dmwappushservice (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\Dnscache (SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\DoSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\dot3svc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\DPS (SYSTEM [Allow: FullControl GenericAll])
    HKLM\system\currentcontrolset\services\drmkaud (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\DsmSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\DsSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\DTrace (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\DXGKrnl (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\E1G60 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\EapHost (Administrators [Allow: WriteKey FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\ebdrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\ebdrv0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\edgeupdate (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\edgeupdatem (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\EFS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\EhStorClass (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\EhStorTcgDrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\elxfcoe (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\elxstor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\embeddedmode (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\EntAppSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\ErrDev (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\ESENT (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\EventLog (SYSTEM [Allow: GenericAll FullControl], Administrators [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\EventSystem (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\ExecutionContext (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\exfat (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\fastfat (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\fcvsc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\fdc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\fdPHost (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\FDResPub (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\FileCrypt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\FileInfo (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Filetrace (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\flpydisk (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\FltMgr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\FontCache (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\FrameServer (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\FrameServerMonitor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\FsDepends (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\Fs_Rec (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\FwCfg (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\GameInputSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\gencounter (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\genericusbfn (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\GenPass (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\GPIOClx0101 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\gpsvc (SYSTEM [Allow: FullControl GenericAll])
    HKLM\system\currentcontrolset\services\GraphicsPerfSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\HdAudAddService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\HDAudBus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\HidBatt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\hidinterrupt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\hidserv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\HidSpiCx (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\HidUsb (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\hpatchmon (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\HpSAMD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\HTTP (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\hvcrash (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\HvHost (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\hvservice (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\HwNClx0101 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\hwpolicy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\hyperkbd (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\HyperVideo (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\I3CHost (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\i8042prt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\iagpio (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\iai2c (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\iaLPSS2i_GPIO2 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\iaLPSS2i_GPIO2_BXT_P (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\iaLPSS2i_GPIO2_CNL (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\iaLPSS2i_GPIO2_GLK (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\iaLPSS2i_I2C (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\iaLPSS2i_I2C_BXT_P (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\iaLPSS2i_I2C_CNL (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\iaLPSS2i_I2C_GLK (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\iaLPSSi_GPIO (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\iaLPSSi_I2C (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\iaStorAV (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\iaStorAVC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\iaStorV (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\ibbus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\IKEEXT (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\IndirectKmd (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\inetaccs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\InstallService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\intelide (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\intelpep (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\intelpmax (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\IntelPMT (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\intelppm (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\InventorySvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\iorate (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\IpFilterDriver (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\iphlpsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\IPMIDRV (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\IPNAT (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\IPT (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\isapnp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\iScsiPrt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\ItSas35i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\kbdclass (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\kbdhid (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\kdnic (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\kdnic_legacy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\KeyIso (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\KPSSVC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\KSecDD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\KSecPkg (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\KslD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\ksthunk (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\KtmRm (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\LanmanServer (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\LanmanWorkstation (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                   
    HKLM\system\currentcontrolset\services\ldap (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\lfsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\LicenseManager (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\lltdio (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\lltdsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\lmhosts (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\LocalKdc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\LSI_SAS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\LSI_SAS2i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\LSI_SAS3i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\LSM (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\luafv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\LxpSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\MapsBroker (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\mausbhost (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\mausbip (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\McpManagementService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\MDCoreSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\megasas2i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\megasas35i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\megasr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\MicrosoftEdgeElevationService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                       
    HKLM\system\currentcontrolset\services\Microsoft_Bluetooth_AvrcpTransport (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                  
    HKLM\system\currentcontrolset\services\mlx4_bus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\MMCSS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\Modem (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\MongoDB (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\monitor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\mouclass (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\mouhid (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\mountmgr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\mpi3drvi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\mpsdrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\mpssvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\mrxsmb (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\mrxsmb20 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\MsBridge (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\MSDTC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\MSDTC Bridge 4.0.0.0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\Msfs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\msgpiowin32 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\mshidkmdf (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\mshidumdf (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\msisadrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\MSiSCSI (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\msiserver (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\MSKSSRV (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\MsLbfoProvider (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\MsLldp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\MSPCLOCK (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\MSPQM (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\MsQuic (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\MsQuicPrev (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\MsRPC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\MsSecCore (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\MsSecFlt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\MsSecWfp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\mssmbios (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\MSTEE (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\MTConfig (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Mup (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\mvumis (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\napagent (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\NativeWifiP (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\NaturalAuthentication (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                               
    HKLM\system\currentcontrolset\services\NcaSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\NcbService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\ndfltr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\NDIS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\NdisCap (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\NdisImPlatform (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\NdisTapi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Ndisuio (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\NdisVirtualBus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\NdisWan (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\ndiswanlegacy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\NDKPerf (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\NDKPing (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\ndproxy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\NetAdapterCx (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\NetBIOS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\NetbiosSmb (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\NetBT (SYSTEM [Allow: GenericAll FullControl], Administrators [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\netkvm (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\NETKVMP (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\Netlogon (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Netman (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\netprofm (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\NetSetupSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\NetTcpPortSharing (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                   
    HKLM\system\currentcontrolset\services\netvsc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\NgcCtnrSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\NgcSvc (SYSTEM [Allow: TakeOwnership FullControl GenericAll], Administrators [Allow: TakeOwnership FullControl GenericAll])                                                                  
    HKLM\system\currentcontrolset\services\NlaSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\Npfs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\NPSMSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\NPSMSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\npsvctrig (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\nsi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\nsiproxy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\NTDS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\Ntfs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\Null (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\nvdimm (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\nvmedisk (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\nvraid (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\nvstor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\OneSyncSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\OneSyncSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\P9NP (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\P9Rdr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\P9RdrService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\P9RdrService_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\Parport (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\partmgr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\PcaSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\pci (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\pciide (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\pcmcia (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\pcw (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\pdc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\PEAUTH (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\percsas2i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\percsas3i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\PerfDisk (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\PerfHost (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\PerfNet (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\PerfOS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\PerfProc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\PimIndexMaintenanceSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                              
    HKLM\system\currentcontrolset\services\PimIndexMaintenanceSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                      
    HKLM\system\currentcontrolset\services\PktMon (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\PktMonApi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\pla (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\PlugPlay (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\pmem (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\PNPMEM (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\PolicyAgent (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\portcfg (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\PortProxy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\Power (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\PptpMiniport (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\PrintDeviceConfigurationService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                     
    HKLM\system\currentcontrolset\services\PrintNotify (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\PrintScanBrokerService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                              
    HKLM\system\currentcontrolset\services\PrintWorkflowUserSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\PrintWorkflowUserSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                        
    HKLM\system\currentcontrolset\services\PRM (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\Processor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\ProfSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\Psched (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\PushToInstall (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\PVPanic (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\pvscsi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\qebdrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\qefcoe (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\QEMU Guest Agent VSS Provider (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                       
    HKLM\system\currentcontrolset\services\QEMU-GA (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\qeois (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\ql2300i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\ql40xx2i (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\qlfcoei (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\QWAVE (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\QWAVEdrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Ramdisk (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\RasAcd (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\RasAgileVpn (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\RasAuto (SYSTEM [Allow: GenericAll FullControl], Administrators [Allow: GenericAll FullControl])                                                                                             
    HKLM\system\currentcontrolset\services\RasGre (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\Rasl2tp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\RasMan (SYSTEM [Allow: GenericAll FullControl], Administrators [Allow: GenericAll FullControl])                                                                                              
    HKLM\system\currentcontrolset\services\RasPppoe (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\RasSstp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\rdbss (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\RDMANDK (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\rdpbus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\RDPDR (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\RDPNP (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\ReFS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\refsdedupsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\ReFSv1 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\RemoteAccess (SYSTEM [Allow: GenericAll FullControl], Administrators [Allow: GenericAll FullControl])                                                                                        
    HKLM\system\currentcontrolset\services\RemoteRegistry (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\RFCOMM (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\rhproxy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\RmSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\RpcEptMapper (SYSTEM [Allow: TakeOwnership FullControl GenericAll], Administrators [Allow: TakeOwnership FullControl GenericAll])                                                            
    HKLM\system\currentcontrolset\services\RpcLocator (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\RpcSs (SYSTEM [Allow: GenericAll FullControl])
    HKLM\system\currentcontrolset\services\RSoPProv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\rspndr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\s3cap (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\sacdrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\sacsvr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\SamSs (SYSTEM [Allow: FullControl GenericAll])
    HKLM\system\currentcontrolset\services\sbp2port (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\SCardSvr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\ScDeviceEnum (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\scfilter (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Schedule (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\scmbus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\SCPolicySvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\sdbus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\SdcaHidInbox (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\SdcaMfdInbox (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\sdstor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\seclogon (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\SecurityHealthService (SYSTEM [Allow: FullControl GenericAll])
    HKLM\system\currentcontrolset\services\SEMgrSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\SENS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\Sense (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\SensorDataService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                   
    HKLM\system\currentcontrolset\services\SensorService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\SensrSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\SerCx (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\SerCx2 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\Serenum (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\Serial (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\sermouse (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\SessionEnv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\sfloppy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\SharedAccess (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\ShellHWDetection (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\shpamsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\SiSRaid2 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\SiSRaid4 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\SmartSAMD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\smbdirect (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\smphost (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\SMSvcHost 4.0.0.0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                   
    HKLM\system\currentcontrolset\services\SNMPTrap (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\spaceparser (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\spaceport (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\SpbCx (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\spice-agent (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\Spooler (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\sppsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\srv2 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\srvnet (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\SSDPSRV (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\ssh-agent (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\sshd (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\SstpSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\StateRepository (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\stexstor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\StiSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\storahci (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\storflt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\stornvme (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\stornvmeofi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\storqosflt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\StorSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\storufs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\storvsc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\svsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\swenum (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\swprv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\SysMain (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\SystemEventsBroker (SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\tapisrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\Tcpip (SYSTEM [Allow: FullControl], Administrators [Allow: FullControl])
    HKLM\system\currentcontrolset\services\Tcpip6 (SYSTEM [Allow: FullControl], Administrators [Allow: FullControl])
    HKLM\system\currentcontrolset\services\TCPIP6TUNNEL (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\tcpipreg (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\TCPIPTUNNEL (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\tdx (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\terminpt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\TermService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\TextInputManagementService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                          
    HKLM\system\currentcontrolset\services\Themes (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\ThermalFilter (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\TieringEngineService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                
    HKLM\system\currentcontrolset\services\TimeBrokerSvc (SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\TokenBroker (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\TPM (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\TrkWks (SYSTEM [Allow: FullControl GenericAll])
    HKLM\system\currentcontrolset\services\TrustedInstaller (SYSTEM [Allow: FullControl GenericAll])
    HKLM\system\currentcontrolset\services\TSDDD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\TsUsbFlt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\TsUsbGD (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\tsusbhub (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\tunnel (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\tzautoupdate (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\UALSVC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\UASPStor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\UcmCx0101 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\UcmTcpciCx0101 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\UcmUcsiAcpiClient (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                   
    HKLM\system\currentcontrolset\services\UcmUcsiCx0101 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\Ucx01000 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\UdeCx (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\udfs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\UdkUserSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\UdkUserSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\UEFI (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\UevAgentDriver (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\UevAgentService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\Ufx01000 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\UfxChipidea (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\ufxsynopsys (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\UGatherer (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\UGTHRSVC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\uiomap (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\umbus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\UmPass (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\UmRdpService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\UnionFS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\UnistoreSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\UnistoreSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                 
    HKLM\system\currentcontrolset\services\upnphost (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\UrsChipidea (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\UrsCx01000 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\UrsSynopsys (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\usb-platformdetection (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                               
    HKLM\system\currentcontrolset\services\Usb4DeviceRouter (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\Usb4HostRouter (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\usbaudio (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\usbaudio2 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\usbccgp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\usbehci (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\usbhub (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\USBHUB3 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\usbohci (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\usbprint (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\usbser (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\USBSTOR (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\usbuhci (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\USBXHCI (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\UserDataSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\UserDataSvc_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                 
    HKLM\system\currentcontrolset\services\UserManager (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\UsoSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\VaultSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\vdrvroot (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\vds (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\VerifierExt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\VGAuthService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\vhdmp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\vhf (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\VioGpuDod (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\viohidkmdf (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\vioscsi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\viostor (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\VirtioFsDrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\VirtioFsSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\VirtioInput (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\VirtioSerial (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\VirtRng (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\VirtualRender (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\vm3dmp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\vm3dmp-debug (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\vm3dmp-stats (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\vm3dmp_loader (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\vm3dservice (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                         
    HKLM\system\currentcontrolset\services\vmbus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\VMBusHID (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\vmci (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\vmgid (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\vmicguestinterface (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\vmicheartbeat (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\vmickvpexchange (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                     
    HKLM\system\currentcontrolset\services\vmicrdv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\vmicshutdown (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\vmictimesync (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\vmicvmsession (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\vmicvss (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\VMMemCtl (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\vmmouse (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\VMTools (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\vmusbmouse (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\vmvss (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\vmwefifw (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\vmxnet3ndis6 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\volmgr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\volmgrx (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\volsnap (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\volume (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\vpci (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                
    HKLM\system\currentcontrolset\services\vsmraid (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\vsock (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\VSS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\VSTXRAID (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\vwifibus (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\vwififlt (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\W32Time (SYSTEM [Allow: GenericAll FullControl], Administrators [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WaaSMedicSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\WacomPen (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\WalletService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\wanarp (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\wanarpv6 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\WarpJITSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\WbioSrvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\wcifs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\Wcmsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\wcncsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WdBoot (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\Wdf01000 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\WdFilter (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\WdiServiceHost (SYSTEM [Allow: FullControl GenericAll])
    HKLM\system\currentcontrolset\services\WdiSystemHost (SYSTEM [Allow: FullControl GenericAll])
    HKLM\system\currentcontrolset\services\wdiwifi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WdmCompanionFilter (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                  
    HKLM\system\currentcontrolset\services\WdNisDrv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\WdNisSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\Wecsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\WEPHOSTSVC (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\wercplsupport (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\WerSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\WFDSConMgrSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\WFPLWFS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WiaRpc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\Wificx (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\WIMMount (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\WinAccelCx0101 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\WinDefend (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\Windows Workflow Foundation 4.0.0.0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                 
    HKLM\system\currentcontrolset\services\WindowsTrustedRT (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                    
    HKLM\system\currentcontrolset\services\WindowsTrustedRTProxy (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                               
    HKLM\system\currentcontrolset\services\WinHttpAutoProxySvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                 
    HKLM\system\currentcontrolset\services\wini3ctarget (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\WinMad (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\Winmgmt (SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: GenericAll FullControl])                                                                                             
    HKLM\system\currentcontrolset\services\WinNat (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\WinRM (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\Winsock (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WinSock2 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\WINUSB (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\WinVerbs (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\wisvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\WlanSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\wlidsvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WManSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WmiAcpi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WmiApRpl (SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: GenericAll FullControl])                                                                                            
    HKLM\system\currentcontrolset\services\wmiApSrv (SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: GenericAll FullControl])                                                                                            
    HKLM\system\currentcontrolset\services\WMPNetworkSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\Wof (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                                 
    HKLM\system\currentcontrolset\services\workerdd (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\workfolderssvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\WPDBusEnum (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\WpdUpFltr (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                           
    HKLM\system\currentcontrolset\services\WpnService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                          
    HKLM\system\currentcontrolset\services\WpnUserService (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\WpnUserService_136f2d0 (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                              
    HKLM\system\currentcontrolset\services\ws2ifsl (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WSAIFabricSvc (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                       
    HKLM\system\currentcontrolset\services\WSearch (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\WSearchIdxPi (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                        
    HKLM\system\currentcontrolset\services\wuauserv (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            
    HKLM\system\currentcontrolset\services\WudfPf (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\WUDFRd (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                              
    HKLM\system\currentcontrolset\services\XblAuthManager (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                      
    HKLM\system\currentcontrolset\services\xmlprov (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                             
    HKLM\system\currentcontrolset\services\ZTDNS (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                               
    HKLM\system\currentcontrolset\services\ZTHELPER (Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll])                                                                                            

╔══════════╣ Checking write permissions in PATH folders (DLL Hijacking) (T1574.001)
╚ Check for DLL Hijacking in PATH folders https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#dll-hijacking                                                                                 
    (DLL Hijacking) C:\WINDOWS\system32: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]                                                                                                           
    (DLL Hijacking) C:\WINDOWS: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    (DLL Hijacking) C:\WINDOWS\System32\Wbem: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]                                                                                                      
    (DLL Hijacking) C:\WINDOWS\System32\WindowsPowerShell\v1.0\: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]                                                                                   
    (DLL Hijacking) C:\WINDOWS\System32\OpenSSH\: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]                                                                                                  

╔══════════╣ OEM privileged utilities & risky components (T1068)
    None of the supported OEM utilities were detected.

╔══════════╣ Kernel drivers with weak/legacy signatures (T1014)
╚ Legacy cross-signed drivers (pre-July-2015) can still grant kernel execution on modern Windows https://research.checkpoint.com/2025/cracking-valleyrat-from-builder-secrets-to-kernel-rootkits/                                       
╚   Unable to enumerate kernel services

╔══════════╣ KernelQuick / ValleyRAT rootkit indicators (T1014)
╚   No KernelQuick-specific registry indicators were found


════════════════════════════════════╣ .NET SOAP Client Proxies (SOAPwn) (T1559,T1071.001) ╠════════════════════════════════════                                                                                                         

╔══════════╣ Potential SOAPwn / HttpWebClientProtocol abuse surfaces (T1559,T1071.001)
╚ Look for .NET services that let attackers control SoapHttpClientProtocol URLs or WSDL imports to coerce NTLM or drop files. https://labs.watchtowr.com/soapwn-pwning-net-framework-applications-through-http-client-proxies-and-wsdl/ 
Error while enumerating services for SOAP client analysis: Invalid parameter 
    Not Found


════════════════════════════════════╣ Applications Information (T1518,T1547.001,T1053.005,T1010,T1014) ╠════════════════════════════════════                                                                                            

╔══════════╣ Current Active Window Application (T1010)
  [X] Exception: Object reference not set to an instance of an object.

╔══════════╣ Installed Applications --Via Program Files/Uninstall registry-- (T1518)
╚ Check if you can modify installed software https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#applications                                                                               
    C:\Program Files\Cloudbase Solutions(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\Common Files(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                                 
    C:\Program Files\desktop.ini(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\Internet Explorer(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                            
    C:\Program Files\ModifiableWindowsApps(SYSTEM [Allow: AllAccess])
    C:\Program Files\MongoDB(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\Qemu-ga(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\Red Hat(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\Spice Agent(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\Uninstall Information(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\Virtio-Win(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\VMware(SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess])
    C:\Program Files\Windows Defender(SYSTEM [Allow: AllAccess], Administrators [Allow: WriteData/CreateFiles])
    C:\Program Files\Windows Defender Advanced Threat Protection(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                  
    C:\Program Files\Windows Mail(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                                 
    C:\Program Files\Windows Media Player(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                         
    C:\Program Files\Windows NT(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                                   
    C:\Program Files\Windows Photo Viewer(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                         
    C:\Program Files\Windows Sidebar(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                              
    C:\Program Files\WindowsApps(SYSTEM [Allow: AllAccess])
    C:\Program Files\WindowsPowerShell(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])                                                                                                            
    C:\Windows\System32(SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles])


╔══════════╣ Autorun Applications (T1547.001)
╚ Check if you can modify other users AutoRuns binaries (Note that is normal that you can modify HKCU registry and binaries indicated there) https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/privilege-escalation-with-autorun-binaries.html                                                                           

    RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Run
    RegPerms: Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll]
    Key: AzureArcSetup
    Folder: C:\WINDOWS\AzureArcSetup\Systray
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\WINDOWS\AzureArcSetup\Systray\AzureArcSysTray.exe
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Run
    RegPerms: Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll]
    Key: SecurityHealth
    Folder: C:\WINDOWS\system32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\WINDOWS\system32\SecurityHealthSystray.exe
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Run
    RegPerms: Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll]
    Key: VMware User Process
    Folder: C:\Program Files\VMware\VMware Tools
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    File: C:\Program Files\VMware\VMware Tools\vmtoolsd.exe -n vmusr (Unquoted and Space detected) - C:\,C:\Program Files\VMware,C:\Program Files\VMware\VMware Tools\vmtoolsd.exe 
    FilePerms: Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess]
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
    RegPerms: Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll]
    Key: Common Startup
    Folder: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess] (Unquoted and Space detected) - C:\ProgramData\Microsoft\Windows,C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup 
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: GenericAll FullControl]
    Key: Common Startup
    Folder: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess] (Unquoted and Space detected) - C:\ProgramData\Microsoft\Windows,C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup 
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: Userinit
    Folder: C:\WINDOWS\system32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\WINDOWS\system32\userinit.exe,
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: Shell
    Folder: None (PATH Injection)
    File: explorer.exe
   =================================================================================================


    RegPath: HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: AlternateShell
    Folder: None (PATH Injection)
    File: cmd.exe
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Font Drivers
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: Adobe Type Manager
    Folder: None (PATH Injection)
    File: atmfd.dll
   =================================================================================================


    RegPath: HKLM\Software\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Font Drivers
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: Adobe Type Manager
    Folder: None (PATH Injection)
    File: atmfd.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: aux
    Folder: None (PATH Injection)
    File: wdmaud.drv
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: midi
    Folder: None (PATH Injection)
    File: wdmaud.drv
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: midimapper
    Folder: None (PATH Injection)
    File: midimap.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: mixer
    Folder: None (PATH Injection)
    File: wdmaud.drv
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.imaadpcm
    Folder: None (PATH Injection)
    File: imaadp32.acm
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.l3acm
    Folder: C:\Windows\System32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\Windows\System32\l3codeca.acm
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.msadpcm
    Folder: None (PATH Injection)
    File: msadp32.acm
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.msg711
    Folder: None (PATH Injection)
    File: msg711.acm
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.msgsm610
    Folder: None (PATH Injection)
    File: msgsm32.acm
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.i420
    Folder: None (PATH Injection)
    File: iyuv_32.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.iyuv
    Folder: None (PATH Injection)
    File: iyuv_32.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.mrle
    Folder: None (PATH Injection)
    File: msrle32.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.msvc
    Folder: None (PATH Injection)
    File: msvidc32.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.uyvy
    Folder: None (PATH Injection)
    File: msyuv.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.yuy2
    Folder: None (PATH Injection)
    File: msyuv.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.yvu9
    Folder: None (PATH Injection)
    File: tsbyuv.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.yvyu
    Folder: None (PATH Injection)
    File: msyuv.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: wave
    Folder: None (PATH Injection)
    File: wdmaud.drv
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: wavemapper
    Folder: None (PATH Injection)
    File: msacm32.drv
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: aux
    Folder: None (PATH Injection)
    File: wdmaud.drv
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: midi
    Folder: None (PATH Injection)
    File: wdmaud.drv
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: midimapper
    Folder: None (PATH Injection)
    File: midimap.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: mixer
    Folder: None (PATH Injection)
    File: wdmaud.drv
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.imaadpcm
    Folder: None (PATH Injection)
    File: imaadp32.acm
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.l3acm
    Folder: C:\Windows\SysWOW64
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\Windows\SysWOW64\l3codeca.acm
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.msadpcm
    Folder: None (PATH Injection)
    File: msadp32.acm
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.msg711
    Folder: None (PATH Injection)
    File: msg711.acm
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: msacm.msgsm610
    Folder: None (PATH Injection)
    File: msgsm32.acm
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.cvid
    Folder: None (PATH Injection)
    File: iccvid.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.i420
    Folder: None (PATH Injection)
    File: iyuv_32.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.iyuv
    Folder: None (PATH Injection)
    File: iyuv_32.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.mrle
    Folder: None (PATH Injection)
    File: msrle32.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.msvc
    Folder: None (PATH Injection)
    File: msvidc32.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.uyvy
    Folder: None (PATH Injection)
    File: msyuv.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.yuy2
    Folder: None (PATH Injection)
    File: msyuv.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.yvu9
    Folder: None (PATH Injection)
    File: tsbyuv.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: vidc.yvyu
    Folder: None (PATH Injection)
    File: msyuv.dll
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: wave
    Folder: None (PATH Injection)
    File: wdmaud.drv
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32
    RegPerms: SYSTEM [Allow: FullControl GenericAll], Administrators [Allow: FullControl GenericAll]
    Key: wavemapper
    Folder: None (PATH Injection)
    File: msacm32.drv
   =================================================================================================


    RegPath: HKLM\Software\Classes\htmlfile\shell\open\command
    RegPerms: Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll]
    Folder: C:\Program Files\Internet Explorer
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\Program Files\Internet Explorer\iexplore.exe %1 (Unquoted and Space detected) - C:\,C:\Program Files,C:\Program Files\Internet Explorer\iexplore.exe                                                                       
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: *kernel32
    Folder: None (PATH Injection)
    File: kernel32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: _wow64cpu
    Folder: None (PATH Injection)
    File: wow64cpu.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: _wowarmhw
    Folder: None (PATH Injection)
    File: wowarmhw.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: _xtajit
    Folder: None (PATH Injection)
    File: xtajit.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: advapi32
    Folder: None (PATH Injection)
    File: advapi32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: clbcatq
    Folder: None (PATH Injection)
    File: clbcatq.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: combase
    Folder: None (PATH Injection)
    File: combase.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: COMDLG32
    Folder: None (PATH Injection)
    File: COMDLG32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: coml2
    Folder: None (PATH Injection)
    File: coml2.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: DifxApi
    Folder: None (PATH Injection)
    File: difxapi.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: gdi32
    Folder: None (PATH Injection)
    File: gdi32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: gdiplus
    Folder: None (PATH Injection)
    File: gdiplus.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: IMAGEHLP
    Folder: None (PATH Injection)
    File: IMAGEHLP.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: IMM32
    Folder: None (PATH Injection)
    File: IMM32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: MSCTF
    Folder: None (PATH Injection)
    File: MSCTF.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: MSVCRT
    Folder: None (PATH Injection)
    File: MSVCRT.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: NORMALIZ
    Folder: None (PATH Injection)
    File: NORMALIZ.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: NSI
    Folder: None (PATH Injection)
    File: NSI.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: ole32
    Folder: None (PATH Injection)
    File: ole32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: OLEAUT32
    Folder: None (PATH Injection)
    File: OLEAUT32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: PSAPI
    Folder: None (PATH Injection)
    File: PSAPI.DLL
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: rpcrt4
    Folder: None (PATH Injection)
    File: rpcrt4.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: sechost
    Folder: None (PATH Injection)
    File: sechost.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: Setupapi
    Folder: None (PATH Injection)
    File: Setupapi.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: SHCORE
    Folder: None (PATH Injection)
    File: SHCORE.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: SHELL32
    Folder: None (PATH Injection)
    File: SHELL32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: SHLWAPI
    Folder: None (PATH Injection)
    File: SHLWAPI.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: user32
    Folder: None (PATH Injection)
    File: user32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: WLDAP32
    Folder: None (PATH Injection)
    File: WLDAP32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: wow64
    Folder: None (PATH Injection)
    File: wow64.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: wow64base
    Folder: None (PATH Injection)
    File: wow64base.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: wow64con
    Folder: None (PATH Injection)
    File: wow64con.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: wow64win
    Folder: None (PATH Injection)
    File: wow64win.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: WS2_32
    Folder: None (PATH Injection)
    File: WS2_32.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: xtajit64
    Folder: None (PATH Injection)
    File: xtajit64.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: xtajit64se
    Folder: None (PATH Injection)
    File: xtajit64se.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: _xtajitf
    Folder: None (PATH Injection)
    File: xtajitf.dll
   =================================================================================================


    RegPath: HKLM\System\CurrentControlSet\Control\Session Manager\KnownDlls
    Key: _xtajitse
    Folder: None (PATH Injection)
    File: xtajitse.dll
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Active Setup\Installed Components\{2C7339CF-2B09-4501-B3F3-F3508C9228ED}
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: \
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess], Users [Allow: AppendData/CreateDirectories]                                                                                                              
    File: /UserInstall
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Active Setup\Installed Components\{6BF52A52-394A-11d3-B153-00C04F79FAA6}
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: C:\WINDOWS\system32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\WINDOWS\system32\unregmp2.exe /FirstLogon
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4340}
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: None (PATH Injection)
    File: U
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4383}
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: C:\Windows\System32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\Windows\System32\ie4uinit.exe -UserConfig
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Active Setup\Installed Components\{89B4C1CD-B018-4511-B0A1-5476DBF70820}
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: C:\Windows\System32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\Windows\System32\Rundll32.exe C:\Windows\System32\mscories.dll,Install
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: C:\Program Files (x86)\Microsoft\Edge\Application\147.0.3912.72\Installer
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    File: C:\Program Files (x86)\Microsoft\Edge\Application\147.0.3912.72\Installer\setup.exe --configure-user-settings --verbose-logging --system-level --msedge --channel=stable (Unquoted and Space detected) - C:\,C:\Program Files 
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: C:\Windows\System32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\Windows\System32\rundll32.exe C:\Windows\System32\iesetup.dll,IEHardenAdmin
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: C:\Windows\System32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\Windows\System32\rundll32.exe C:\Windows\System32\iesetup.dll,IEHardenUser
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Active Setup\Installed Components\{6BF52A52-394A-11d3-B153-00C04F79FAA6}                                                                                                               
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: C:\WINDOWS\system32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\WINDOWS\system32\unregmp2.exe /FirstLogon
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Active Setup\Installed Components\{89B4C1CD-B018-4511-B0A1-5476DBF70820}                                                                                                               
    RegPerms: Administrators [Allow: FullControl], SYSTEM [Allow: FullControl]
    Key: StubPath
    Folder: C:\Windows\SysWOW64
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\Windows\SysWOW64\Rundll32.exe C:\Windows\SysWOW64\mscories.dll,Install
   =================================================================================================


    RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}                                                                                                      
    RegPerms: Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll]
    Folder: C:\Program Files (x86)\Microsoft\Edge\Application\147.0.3912.72\BHO
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    File: C:\Program Files (x86)\Microsoft\Edge\Application\147.0.3912.72\BHO\ie_to_edge_bho_64.dll (Unquoted and Space detected) - C:\,C:\Program Files                                                                                
   =================================================================================================


    RegPath: HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}                                                                                          
    RegPerms: Administrators [Allow: FullControl GenericAll], SYSTEM [Allow: FullControl GenericAll]
    Folder: C:\Program Files (x86)\Microsoft\Edge\Application\147.0.3912.72\BHO
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    File: C:\Program Files (x86)\Microsoft\Edge\Application\147.0.3912.72\BHO\ie_to_edge_bho_64.dll (Unquoted and Space detected) - C:\,C:\Program Files                                                                                
   =================================================================================================


    Folder: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    File: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini (Unquoted and Space detected) - C:\ProgramData\Microsoft\Windows,C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini 
    FilePerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Potentially sensitive file content: LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21787
   =================================================================================================


    Folder: C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    File: C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini (Unquoted and Space detected) - C:\Users\Administrator\AppData\Roaming\Microsoft\Windows,C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini                                                        
    FilePerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Potentially sensitive file content: LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21787
   =================================================================================================


    Folder: C:\Users\ts_svc\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    File: C:\Users\ts_svc\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini (Unquoted and Space detected) - C:\Users\ts_svc\AppData\Roaming\Microsoft\Windows,C:\Users\ts_svc\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini                                                                             
    FilePerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    Potentially sensitive file content: LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21787
   =================================================================================================


    Folder: C:\windows\tasks
    FolderPerms: Authenticated Users [Allow: WriteData/CreateFiles], SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]                                                                                                       
   =================================================================================================


    Folder: C:\windows\system32\tasks
    FolderPerms: Authenticated Users [Allow: WriteData/CreateFiles], SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]                                                                                                       
   =================================================================================================


    Folder: C:\windows
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\windows\system.ini
    FilePerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
   =================================================================================================


    Folder: C:\windows
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\windows\win.ini
    FilePerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
   =================================================================================================


    Key: From WMIC
    Folder: C:\Users\Public
    FolderPerms: Service [Allow: WriteData/CreateFiles], SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]                                                                                                                   
    File: C:\Users\Public\rundlll.exe
   =================================================================================================


    Key: From WMIC
    Folder: C:\WINDOWS\AzureArcSetup\Systray
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\WINDOWS\AzureArcSetup\Systray\AzureArcSysTray.exe
   =================================================================================================


    Key: From WMIC
    Folder: C:\WINDOWS\system32
    FolderPerms: SYSTEM [Allow: WriteData/CreateFiles], Administrators [Allow: WriteData/CreateFiles]
    File: C:\WINDOWS\system32\SecurityHealthSystray.exe
   =================================================================================================


    Key: From WMIC
    Folder: C:\Program Files\VMware\VMware Tools
    FolderPerms: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
    File: C:\Program Files\VMware\VMware Tools\vmtoolsd.exe -n vmusr
    FilePerms: Administrators [Allow: AllAccess], SYSTEM [Allow: AllAccess]
   =================================================================================================


╔══════════╣ Scheduled Applications --Non Microsoft-- (T1053.005)
╚ Check if you can modify other users scheduled binaries https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/privilege-escalation-with-autorun-binaries.html                                           

╔══════════╣ Device Drivers --Non Microsoft-- (T1014)
╚ Check 3rd party drivers for known vulnerabilities/rootkits. https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#drivers                                                                   


════════════════════════════════════╣ Network Information (T1016,T1049,T1135,T1046,T1018,T1090) ╠════════════════════════════════════                                                                                                   

╔══════════╣ Network Shares (T1135)
    ADMIN$ (Path: C:\WINDOWS)
    C$ (Path: C:\)
    IPC$ (Path: )

╔══════════╣ Enumerate Network Mapped Drives (WMI) (T1135)

╔══════════╣ Host File (T1016)

╔══════════╣ Network Ifaces and known hosts (T1016,T1018)
╚ The masks are only for the IPv4 addresses 
    tape2d555c6-ef[FA:16:3E:9E:C9:19]: 192.168.188.14, fe80::72fa:e716:4ffd:ccf0%14 / 255.255.255.0
        Gateways: 192.168.188.254
        DNSs: 192.168.188.13
        Known hosts:
          169.254.255.255       00-00-00-00-00-00     Invalid
          192.168.188.13        FA-16-3E-97-E2-0A     Dynamic
          192.168.188.254       FA-16-3E-CD-65-D4     Dynamic
          192.168.188.255       FF-FF-FF-FF-FF-FF     Static
          224.0.0.22            01-00-5E-00-00-16     Static
          224.0.0.251           01-00-5E-00-00-FB     Static
          224.0.0.252           01-00-5E-00-00-FC     Static

    Loopback Pseudo-Interface 1[]: 127.0.0.1, ::1 / 255.0.0.0
        DNSs: fec0:0:0:ffff::1%1, fec0:0:0:ffff::2%1, fec0:0:0:ffff::3%1
        Known hosts:
          224.0.0.22            00-00-00-00-00-00     Static


╔══════════╣ Current TCP Listening Ports (T1049)
╚ Check for services restricted from the outside 
  Enumerating IPv4 connections
                                                                                                                    
  Protocol   Local Address         Local Port    Remote Address        Remote Port     State             Process ID      Process Name

  TCP        0.0.0.0               22            0.0.0.0               0               Listening         2540            C:\WINDOWS\System32\OpenSSH\sshd.exe
  TCP        0.0.0.0               135           0.0.0.0               0               Listening         544             svchost
  TCP        0.0.0.0               445           0.0.0.0               0               Listening         4               System
  TCP        0.0.0.0               3389          0.0.0.0               0               Listening         1124            svchost
  TCP        0.0.0.0               5985          0.0.0.0               0               Listening         4               System
  TCP        0.0.0.0               5986          0.0.0.0               0               Listening         4               System
  TCP        0.0.0.0               6333          0.0.0.0               0               Listening         3812            C:\Qdrant\qdrant.exe
  TCP        0.0.0.0               6333          0.0.0.0               0               Listening         3984            C:\Qdrant\qdrant.exe
  TCP        0.0.0.0               6333          0.0.0.0               0               Listening         8744            C:\Qdrant\qdrant.exe
  TCP        0.0.0.0               6334          0.0.0.0               0               Listening         3812            C:\Qdrant\qdrant.exe
  TCP        0.0.0.0               8080          0.0.0.0               0               Listening         2828            C:\ResearchPortal\research-portal.exe
  TCP        0.0.0.0               47001         0.0.0.0               0               Listening         4               System
  TCP        0.0.0.0               49664         0.0.0.0               0               Listening         836             C:\WINDOWS\system32\lsass.exe
  TCP        0.0.0.0               49665         0.0.0.0               0               Listening         704             wininit
  TCP        0.0.0.0               49666         0.0.0.0               0               Listening         1624            svchost
  TCP        0.0.0.0               49667         0.0.0.0               0               Listening         2032            svchost
  TCP        0.0.0.0               49668         0.0.0.0               0               Listening         836             C:\WINDOWS\system32\lsass.exe
  TCP        0.0.0.0               49669         0.0.0.0               0               Listening         2940            svchost
  TCP        0.0.0.0               49670         0.0.0.0               0               Listening         2516            spoolsv
  TCP        0.0.0.0               49672         0.0.0.0               0               Listening         820             services
  TCP        127.0.0.1             27017         0.0.0.0               0               Listening         3576            mongod
  TCP        192.168.188.14        22            192.168.45.207        38594           Established       2540            C:\WINDOWS\System32\OpenSSH\sshd.exe
  TCP        192.168.188.14        22            192.168.45.207        45844           Established       2540            C:\WINDOWS\System32\OpenSSH\sshd.exe
  TCP        192.168.188.14        22            192.168.45.207        53968           Established       2540            C:\WINDOWS\System32\OpenSSH\sshd.exe
  TCP        192.168.188.14        139           0.0.0.0               0               Listening         4               System
  TCP        192.168.188.14        55807         192.168.45.207        8080            Established       1508            C:\Users\ts_svc\Desktop\secure_loader.exe
  TCP        192.168.188.14        55834         192.168.188.13        135             Established       5592            C:\WINDOWS\system32\winPEASx64.exe
  TCP        192.168.188.14        55835         192.168.188.13        49671           Established       5592            C:\WINDOWS\system32\winPEASx64.exe
  TCP        192.168.188.14        55840         192.168.45.207        8080            Established       1516            C:\Users\ts_svc\Desktop\secure_loader.exe
  TCP        192.168.188.14        55841         192.168.45.207        8080            Established       6804            C:\Users\ts_svc\Desktop\secure_loader.exe

  Enumerating IPv6 connections
                                                                                                                    
  Protocol   Local Address                               Local Port    Remote Address                              Remote Port     State             Process ID      Process Name

  TCP        [::]                                        22            [::]                                        0               Listening         2540            C:\WINDOWS\System32\OpenSSH\sshd.exe
  TCP        [::]                                        135           [::]                                        0               Listening         544             svchost
  TCP        [::]                                        445           [::]                                        0               Listening         4               System
  TCP        [::]                                        3389          [::]                                        0               Listening         1124            svchost
  TCP        [::]                                        5985          [::]                                        0               Listening         4               System
  TCP        [::]                                        5986          [::]                                        0               Listening         4               System
  TCP        [::]                                        8080          [::]                                        0               Listening         2828            C:\ResearchPortal\research-portal.exe
  TCP        [::]                                        47001         [::]                                        0               Listening         4               System
  TCP        [::]                                        49664         [::]                                        0               Listening         836             C:\WINDOWS\system32\lsass.exe
  TCP        [::]                                        49665         [::]                                        0               Listening         704             wininit
  TCP        [::]                                        49666         [::]                                        0               Listening         1624            svchost
  TCP        [::]                                        49667         [::]                                        0               Listening         2032            svchost
  TCP        [::]                                        49668         [::]                                        0               Listening         836             C:\WINDOWS\system32\lsass.exe
  TCP        [::]                                        49669         [::]                                        0               Listening         2940            svchost
  TCP        [::]                                        49670         [::]                                        0               Listening         2516            spoolsv
  TCP        [::]                                        49672         [::]                                        0               Listening         820             services
  TCP        [fe80::72fa:e716:4ffd:ccf0%14]              135           [fe80::72fa:e716:4ffd:ccf0%14]              55812           Established       544             svchost
  TCP        [fe80::72fa:e716:4ffd:ccf0%14]              49666         [fe80::72fa:e716:4ffd:ccf0%14]              55813           Established       1624            svchost
  TCP        [fe80::72fa:e716:4ffd:ccf0%14]              55812         [fe80::72fa:e716:4ffd:ccf0%14]              135             Established       5592            C:\WINDOWS\system32\winPEASx64.exe
  TCP        [fe80::72fa:e716:4ffd:ccf0%14]              55813         [fe80::72fa:e716:4ffd:ccf0%14]              49666           Established       5592            C:\WINDOWS\system32\winPEASx64.exe

╔══════════╣ Current UDP Listening Ports (T1049)
╚ Check for services restricted from the outside 
  Enumerating IPv4 connections
                                                                                                                    
  Protocol   Local Address         Local Port    Remote Address:Remote Port     Process ID        Process Name

  UDP        0.0.0.0               123           *:*                            1236              svchost
  UDP        0.0.0.0               500           *:*                            1196              svchost
  UDP        0.0.0.0               3389          *:*                            1124              svchost
  UDP        0.0.0.0               4500          *:*                            1196              svchost
  UDP        0.0.0.0               5353          *:*                            1352              svchost
  UDP        0.0.0.0               5355          *:*                            1352              svchost
  UDP        0.0.0.0               58099         *:*                            1352              svchost
  UDP        0.0.0.0               64111         *:*                            1352              svchost
  UDP        127.0.0.1             49621         *:*                            1480              svchost
  UDP        127.0.0.1             51844         *:*                            5592              C:\WINDOWS\system32\winPEASx64.exe
  UDP        127.0.0.1             52223         *:*                            836               C:\WINDOWS\system32\lsass.exe
  UDP        127.0.0.1             55236         *:*                            1668              svchost
  UDP        127.0.0.1             58100         *:*                            2152              svchost
  UDP        127.0.0.1             65299         *:*                            1500              svchost
  UDP        192.168.188.14        137           *:*                            4                 System
  UDP        192.168.188.14        138           *:*                            4                 System

  Enumerating IPv6 connections
                                                                                                                    
  Protocol   Local Address                               Local Port    Remote Address:Remote Port     Process ID        Process Name

  UDP        [::]                                        123           *:*                            1236              svchost
  UDP        [::]                                        500           *:*                            1196              svchost
  UDP        [::]                                        3389          *:*                            1124              svchost
  UDP        [::]                                        4500          *:*                            1196              svchost
  UDP        [::]                                        5353          *:*                            1352              svchost
  UDP        [::]                                        5355          *:*                            1352              svchost
  UDP        [::]                                        58099         *:*                            1352              svchost
  UDP        [::]                                        64111         *:*                            1352              svchost

╔══════════╣ Firewall Rules (T1016)
╚ Showing only DENY rules (too many ALLOW rules always) 
    Current Profiles: DOMAIN
    FirewallEnabled (Domain):    False
    FirewallEnabled (Private):    False
    FirewallEnabled (Public):    False
    DENY rules:

╔══════════╣ DNS cached --limit 70-- (T1016)
    Entry                                 Name                                  Data
    ...._sites.gc._msdcs.researchmco.ai   ...._sites.gc._msdcs.researchmco.ai   dc01.researchmco.ai 0 100 3268
    ...._sites.gc._msdcs.researchmco.ai   dc01.researchmco.ai                   192.168.188.13
    dc01.researchmco.ai                   DC01.researchmco.ai                   192.168.188.13

╔══════════╣ Enumerating Internet settings, zone and proxy configuration (T1090)
  General Settings
  Hive        Key                                       Value
  HKCU        User Agent                                Mozilla/4.0 (compatible; MSIE 8.0; Win32)
  HKCU        IE5_UA_Backup_Flag                        5.0
  HKCU        ZonesSecurityUpgrade                      System.Byte[]
  HKCU        EnableNegotiate                           1
  HKCU        ProxyEnable                               0
  HKCU        MigrateProxy                              1
  HKLM        EnablePunycode                            1
  HKLM        ActiveXCache                              C:\Windows\Downloaded Program Files
  HKLM        CodeBaseSearchPath                        CODEBASE
  HKLM        MinorVersion                              0
  HKLM        WarnOnIntranet                            1

  Zone Maps                                                                                                         
  No URLs configured

  Zone Auth Settings                                                                                                
  No Zone Auth Settings

╔══════════╣ Internet Connectivity (T1016)
╚ Checking if internet access is possible via different methods 
    HTTP (80) Access: Not Accessible
  [X] Exception:       Error: An error occurred while sending the request.
    HTTPS (443) Access: Not Accessible
  [X] Exception:       Error: One or more errors occurred.
    HTTPS (443) Access by Domain Name: Not Accessible
  [X] Exception:       Error: A task was canceled.
    DNS (53) Access: Not Accessible
  [X] Exception:       Error: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond                    
    ICMP (ping) Access: Not Accessible
  [X] Exception:       Error: Ping failed: TimedOut

╔══════════╣ Hostname Resolution (T1016)
╚ Checking if the hostname can be resolved externally 
  [X] Exception:     Error during online HackTricks check: An error occurred while sending the request.


════════════════════════════════════╣ Active Directory Quick Checks (T1018,T1087.002,T1558.003,T1484.001,T1649,T1003) ╠════════════════════════════════════                                                                             

╔══════════╣ gMSA readable managed passwords (T1003)
╚ Look for Group Managed Service Accounts you can read (msDS-ManagedPassword) https://book.hacktricks.wiki/en/windows-hardening/active-directory-methodology/gmsa.html                                                                  
  [-] No gMSA with readable managed password found (checked 0).

╔══════════╣ Kerberoasting / service ticket risks (T1558.003)
╚ Enumerate weak SPN accounts and legacy Kerberos crypto https://book.hacktricks.wiki/en/windows-hardening/active-directory-methodology/kerberoast.html                                                                                 
  [-] Domain default supported encryption types not set (legacy compatibility defaults to RC4).
  krbtgt supports: Unspecified (inherits defaults / RC4 compatible) — RC4 TGTs can still be issued.
╚ Checked 4 SPN-bearing accounts. High-risk RC4/privileged targets: 1, long-lived AES-only targets: 0.
  [!] RC4-enabled or privileged SPN accounts:
      - ts_svc | SPNs: MSSQLSvc/SRV1.researchmco.ai, MSSQLSvc/SRV1.researchmco.ai:1433 | Enc: Unspecified (inherits defaults / RC4 compatible) | RC4 allowed; PasswordNeverExpires                                                      

╔══════════╣ AD object control surfaces (T1484.001,T1087.002,T1018)
╚ Look for objects where you have GenericAll/GenericWrite/attribute rights for ACL abuse (password reset, SPN/UAC/RBCD, sidHistory, delegation, DCSync). https://book.hacktricks.wiki/en/windows-hardening/active-directory-methodology/index.html#acl-abuse                                                                                                
  [+] Found 68 object(s) where your principal has abuse-friendly rights:
    -> Access Control Assistance Operators (group)
       DN: CN=Access Control Assistance Operators,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> Account Operators (group)
       DN: CN=Account Operators,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Admin (user)
       DN: CN=Admin,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Administrator (user)
       DN: CN=Administrator,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Administrators (group)
       DN: CN=Administrators,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> AdminSDHolder (container)
       DN: CN=AdminSDHolder,CN=System,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Allowed RODC Password Replication Group (group)
       DN: CN=Allowed RODC Password Replication Group,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> backdoor (user)
       DN: CN=backdoor,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Backup Operators (group)
       DN: CN=Backup Operators,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Cert Publishers (group)
       DN: CN=Cert Publishers,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Certificate Service DCOM Access (group)
       DN: CN=Certificate Service DCOM Access,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> Cloneable Domain Controllers (group)
       DN: CN=Cloneable Domain Controllers,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> cloudbase-init (user)
       DN: CN=cloudbase-init,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Cryptographic Operators (group)
       DN: CN=Cryptographic Operators,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> DC01$ (computer)
       DN: CN=DC01,OU=Domain Controllers,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Denied RODC Password Replication Group (group)
       DN: CN=Denied RODC Password Replication Group,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Distributed COM Users (group)
       DN: CN=Distributed COM Users,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> DnsAdmins (group)
       DN: CN=DnsAdmins,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> DnsUpdateProxy (group)
       DN: CN=DnsUpdateProxy,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> Domain Admins (group)
       DN: CN=Domain Admins,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Domain Computers (group)
       DN: CN=Domain Computers,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Domain Controllers group (group)
       DN: CN=Domain Controllers,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Domain Controllers OU (organizationalUnit)
       DN: OU=Domain Controllers,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Domain Guests (group)
       DN: CN=Domain Guests,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Domain Root (domainDNS)
       DN: DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> Domain Users (group)
       DN: CN=Domain Users,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Enterprise Admins (group)
       DN: CN=Enterprise Admins,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Enterprise Key Admins (group)
       DN: CN=Enterprise Key Admins,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Enterprise Read-only Domain Controllers (group)
       DN: CN=Enterprise Read-only Domain Controllers,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Event Log Readers (group)
       DN: CN=Event Log Readers,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> External Trust Accounts (group)
       DN: CN=External Trust Accounts,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Forest Trust Accounts (group)
       DN: CN=Forest Trust Accounts,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Group Policy Creator Owners (group)
       DN: CN=Group Policy Creator Owners,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Guest (user)
       DN: CN=Guest,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> Guests (group)
       DN: CN=Guests,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> Hyper-V Administrators (group)
       DN: CN=Hyper-V Administrators,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> IIS_IUSRS (group)
       DN: CN=IIS_IUSRS,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
       * Object owner: You own this object and can rewrite its ACL to grant full control.
    -> Incoming Forest Trust Builders (group)
       DN: CN=Incoming Forest Trust Builders,CN=Builtin,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> j.park (user)
       DN: CN=Jin Park,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
    -> Key Admins (group)
       DN: CN=Key Admins,CN=Users,DC=researchmco,DC=ai
       * GenericAll: Full control -> reset password, add group members, edit SPNs/UAC, change ACLs.
  [!] Additional 28 object(s) not shown (enable domain mode or run winPEAS with more time to enumerate all objects).

╔══════════╣ AD CS misconfigurations for ESC (T1649)
╚  https://book.hacktricks.wiki/en/windows-hardening/active-directory-methodology/ad-certificates.html
╚ Check for ADCS misconfigurations in the local DC registry
  [-] Host is not a domain controller. Skipping ADCS Registry check
╚ 
If you can modify a template (WriteDacl/WriteOwner/GenericAll), you can abuse ESC4                                  
  [-] No templates with dangerous rights found (checked 0).


════════════════════════════════════╣ Cloud Information (T1552.005,T1580) ╠════════════════════════════════════
Learn and practice cloud hacking in training.hacktricks.xyz
AWS EC2?                                No   
Azure VM?                               No   
Azure Tokens?                           No   
Google Cloud Platform?                  No   
Google Workspace Joined?                No   
Google Cloud Directory Sync?            No   
Google Password Sync?                   No   


════════════════════════════════════╣ Windows Credentials (T1552.001,T1552.002,T1555.003,T1555.004,T1558,T1547.005,T1563.002) ╠════════════════════════════════════                                                                     

╔══════════╣ Checking Windows Vault (T1555.004)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#credentials-manager--windows-vault                                                                                                   
    Not Found

╔══════════╣ Checking Credential manager (T1555.004)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#credentials-manager--windows-vault                                                                                                   
    [!] Warning: if password contains non-printable characters, it will be printed as unicode base64 encoded string


  [!] Unable to enumerate credentials automatically, error: 'Win32Exception: System.ComponentModel.Win32Exception (0x80004005): Element not found'
Please run: 
cmdkey /list

╔══════════╣ Checking UWP PasswordVault / Credential Locker (T1555.004)
╚  https://hacktricks.wiki
    [-] No UWP credentials found in the locker.


╔══════════╣ Saved RDP connections (T1552.002)
    Not Found

╔══════════╣ Remote Desktop Server/Client Settings (T1563.002)
  RDP Server Settings
    Network Level Authentication            :       
    Block Clipboard Redirection             :       
    Block COM Port Redirection              :       
    Block Drive Redirection                 :       
    Block LPT Port Redirection              :       
    Block PnP Device Redirection            :       
    Block Printer Redirection               :       
    Allow Smart Card Redirection            :       

  RDP Client Settings                                                                                               
    Disable Password Saving                 :       True
    Restricted Remote Administration        :       False

╔══════════╣ Recently run commands (T1552.002)
    Not Found

╔══════════╣ Checking for DPAPI Master Keys (T1555.003)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#dpapi
    Not Found
    Not Found

╔══════════╣ Checking for DPAPI Credential Files (T1555.003)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#dpapi
    Not Found

╔══════════╣ Checking for RDCMan Settings Files (T1552.001)
╚ Dump credentials from Remote Desktop Connection Manager https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#remote-desktop-credential-manager                                             
    Not Found

╔══════════╣ Looking for Kerberos tickets (T1558)
╚  https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-kerberos-88/index.html
    [*] Enumerated 6 ticket(s):

    [*] Enumerated 3 ticket(s):

    [*] Enumerated 2 ticket(s):

    [*] Enumerated 12 ticket(s):

    UserPrincipalName: 
    serverName: krbtgt/RESEARCHMCO.AI
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:28 AM
    EndTime: 8/16/2026 8:36:25 PM
    RenewTime: 8/23/2026 10:36:25 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, pre_authent, renewable, forwarded, forwardable
   =================================================================================================

    UserPrincipalName: 
    serverName: krbtgt/RESEARCHMCO.AI
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:25 AM
    EndTime: 8/16/2026 8:36:25 PM
    RenewTime: 8/23/2026 10:36:25 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, pre_authent, initial, renewable, forwardable
   =================================================================================================

    UserPrincipalName: 
    serverName: cifs/DC01.researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:37:17 AM
    EndTime: 8/16/2026 8:36:25 PM
    RenewTime: 8/23/2026 10:36:25 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: 
    serverName: DNS/dc01.researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:28 AM
    EndTime: 8/16/2026 8:36:25 PM
    RenewTime: 8/23/2026 10:36:25 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: 
    serverName: ldap/dc01.researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:26 AM
    EndTime: 8/16/2026 8:36:25 PM
    RenewTime: 8/23/2026 10:36:25 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: 
    serverName: ldap/dc01.researchmco.ai/researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:25 AM
    EndTime: 8/16/2026 8:36:25 PM
    RenewTime: 8/23/2026 10:36:25 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: ts_svc@researchmco.ai
    serverName: krbtgt/RESEARCHMCO.AI
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 7:27:25 PM
    EndTime: 8/17/2026 5:27:25 AM
    RenewTime: 8/23/2026 7:27:25 PM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, pre_authent, initial, renewable, forwardable
   =================================================================================================

    UserPrincipalName: ts_svc@researchmco.ai
    serverName: ldap/DC01.researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 7:27:25 PM
    EndTime: 8/17/2026 5:27:25 AM
    RenewTime: 8/23/2026 7:27:25 PM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: ts_svc@researchmco.ai
    serverName: LDAP/DC01.researchmco.ai/researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 7:27:25 PM
    EndTime: 8/17/2026 5:27:25 AM
    RenewTime: 8/23/2026 7:27:25 PM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: ts_svc@researchmco.ai
    serverName: krbtgt/RESEARCHMCO.AI
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 7:35:47 PM
    EndTime: 8/17/2026 5:35:47 AM
    RenewTime: 8/23/2026 7:35:47 PM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, pre_authent, initial, renewable, forwardable
   =================================================================================================

    UserPrincipalName: ts_svc@researchmco.ai
    serverName: LDAP/DC01.researchmco.ai/researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 7:35:47 PM
    EndTime: 8/17/2026 5:35:47 AM
    RenewTime: 8/23/2026 7:35:47 PM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: krbtgt/RESEARCHMCO.AI
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:26 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, pre_authent, renewable, forwarded, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: krbtgt/RESEARCHMCO.AI
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:26 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, pre_authent, initial, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: MSSQLSvc/SRV1.researchmco.ai:1433
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 4:58:15 PM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: rc4_hmac
    TicketFlags: name_canonicalize, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: HOST/DC01.RESEARCHMCO.AI
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 3:22:29 PM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: HOST/DC01.researchmco.ai/researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:51:19 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: HOST/DC01.researchmco.ai/RESEARCHMCO
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:43:34 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: cifs/DC01.researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:43:34 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: netlogon/DC01.researchmco.ai/researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:30 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: LDAP/DC01.researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:26 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: cifs/DC01.researchmco.ai/researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:26 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: SRV1$
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:26 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, pre_authent, renewable, forwardable
   =================================================================================================

    UserPrincipalName: SRV1$@researchmco.ai
    serverName: LDAP/DC01.researchmco.ai/researchmco.ai
    RealmName: RESEARCHMCO.AI
    StartTime: 8/16/2026 10:36:26 AM
    EndTime: 8/16/2026 8:36:26 PM
    RenewTime: 8/23/2026 10:36:26 AM
    EncryptionType: aes256_cts_hmac_sha1_96
    TicketFlags: name_canonicalize, ok_as_delegate, pre_authent, renewable, forwardable
   =================================================================================================


╔══════════╣ Looking for saved Wifi credentials (T1552.001)
  [X] Exception: The service has not been started
Enumerating WLAN using wlanapi.dll failed, trying to enumerate using 'netsh'
No saved Wifi credentials found

╔══════════╣ Looking AppCmd.exe (T1552.001)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#appcmdexe
    Not Found

╔══════════╣ Looking SSClient.exe (T1552.001)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#scclient--sccm
    Not Found

╔══════════╣ Enumerating SSCM - System Center Configuration Manager settings (T1552.001)

╔══════════╣ Enumerating Security Packages Credentials (T1547.005)
  Version: NetNTLMv2
  Hash:    SRV1$::RESEARCHMCO:1122334455667788:825c0e05692049e1a052736f0ef7a053:01010000000000001b4c8ff0b02ddd01dac722b2208f513c0000000008005000500000000000000000000000004000001c74d4e57dea3885ba68cfd148e579db0793924dfb425248e00b4a1a2ef707332a7429b1fd01e4197e2ed919d33fa4c043048d9e30be219456bcb825666432ba0a00100000000000000000000000000000000000090000000000000000000000                                                                                                
                                                                                                                    
   =================================================================================================



════════════════════════════════════╣ Registry permissions for hive exploitation (T1012,T1574.011,T1056.001) ╠════════════════════════════════════                                                                                      

╔══════════╣ Cross-user TypingInsights key (HKCU/HKU) (T1056.001)
  [!] HKCU\Software\Microsoft\Input\TypingInsights -> Authenticated Users (S-1-5-11), BUILTIN\Users (S-1-5-32-545) (WriteKey)                                                                                                           
  [!] HKU\S-1-5-21-1361221028-2446471266-1567148372-1104\Software\Microsoft\Input\TypingInsights -> Authenticated Users (S-1-5-11), BUILTIN\Users (S-1-5-32-545) (WriteKey)                                                             
  [!] HKU\S-1-5-18\Software\Microsoft\Input\TypingInsights -> Authenticated Users (S-1-5-11), BUILTIN\Users (S-1-5-32-545) (WriteKey)                                                                                                   
╚ Writable TypingInsights enables cross-user hive tampering and DoS. https://projectzero.google/2025/05/the-windows-registry-adventure-8-exploitation.html                                                                              

╔══════════╣ Known HKLM descendants writable by standard users (T1574.011)
  [!] HKLM\SOFTWARE\Microsoft\CoreShell -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\DRM -> Everyone (S-1-1-0) (TakeOwnership, GenericAll)
  [!] HKLM\SOFTWARE\Microsoft\Input\Locales -> Authenticated Users (S-1-5-11), BUILTIN\Users (S-1-5-32-545) (WriteKey)                                                                                                                  
  [!] HKLM\SOFTWARE\Microsoft\Input\Settings -> Authenticated Users (S-1-5-11), BUILTIN\Users (S-1-5-32-545) (WriteKey)                                                                                                                 
  [!] HKLM\SOFTWARE\Microsoft\Shell\Oobe -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\Shell\Session -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\Tracing -> BUILTIN\Users (S-1-5-32-545) (GenericWrite, WriteKey)
  [!] HKLM\SOFTWARE\Microsoft\Windows\UpdateApi -> BUILTIN\Users (S-1-5-32-545) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX -> BUILTIN\Users (S-1-5-32-545) (WriteKey, GenericWrite)
  [!] HKLM\SOFTWARE\WOW6432Node\Microsoft\DRM -> Everyone (S-1-1-0) (TakeOwnership, GenericAll)
  [!] HKLM\SOFTWARE\WOW6432Node\Microsoft\Tracing -> BUILTIN\Users (S-1-5-32-545) (GenericWrite, WriteKey)
  [!] HKLM\SYSTEM\Software\Microsoft\TIP -> BUILTIN\Users (S-1-5-32-545) (WriteKey)
  [!] HKLM\SYSTEM\ControlSet001\Control\Cryptography\WebSignIn\Navigation -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SYSTEM\ControlSet001\Control\MUI\StringCacheSettings -> BUILTIN\Users (S-1-5-32-545) (GenericWrite, WriteKey)                                                                                                                
  [!] HKLM\SYSTEM\ControlSet001\Services\BTAGService\Parameters\Settings -> Interactive (S-1-5-4), Authenticated Users (S-1-5-11) (WriteKey)                                                                                            

╔══════════╣ Sample of additional writable HKLM keys (depth-limited scan) (T1574.011)
  [!] HKLM\SOFTWARE\Microsoft\AccountsControl\KnownAccounts -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\BitLockerCsp\EncryptionFailure -> Authenticated Users (S-1-5-11) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\BitLockerCsp\UserOptions -> Authenticated Users (S-1-5-11) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\CommsAPHost\Test -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\CoreShell -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\DRM -> Everyone (S-1-1-0) (TakeOwnership, GenericAll)
  [!] HKLM\SOFTWARE\Microsoft\Enrollments -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\2648BF76-DA4B-409A-BFFA-6AF111C298A5 -> Interactive (S-1-5-4) (FullControl)                                                                                                                   
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\51BF5DBF-9EAE-45BB-998E-AFB0E32E0E5F -> Interactive (S-1-5-4) (FullControl)                                                                                                                   
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\8345CBE6-CEFC-462A-8219-78F3FC0377C1 -> Interactive (S-1-5-4) (FullControl)                                                                                                                   
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\C429BE2D-071B-4E13-B616-4141C334ECDF -> Interactive (S-1-5-4) (FullControl)                                                                                                                   
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\Context -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\D6ED352C-9214-4E0D-9885-9DDCA9343FB9 -> Interactive (S-1-5-4) (FullControl)                                                                                                                   
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\DAD70CC2-365B-450D-A8AB-2EB23F4300CC -> Interactive (S-1-5-4) (FullControl)                                                                                                                   
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\E17005D5-A50E-4E57-BE94-1D4FA69C6F93 -> Interactive (S-1-5-4) (FullControl)                                                                                                                   
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\EB7D7F2F-3B77-4B87-B301-FD0D336F709A -> Interactive (S-1-5-4) (FullControl)                                                                                                                   
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\Status -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\Status\EB7D7F2F-3B77-4B87-B301-FD0D336F709A -> Interactive (S-1-5-4) (FullControl)                                                                                                            
  [!] HKLM\SOFTWARE\Microsoft\Enrollments\ValidNodePaths -> Interactive (S-1-5-4) (FullControl)
  [!] HKLM\SOFTWARE\Microsoft\Input\HwkSettings -> Authenticated Users (S-1-5-11), BUILTIN\Users (S-1-5-32-545) (WriteKey)                                                                                                              
  [!] HKLM\SOFTWARE\Microsoft\Input\Locales -> Authenticated Users (S-1-5-11), BUILTIN\Users (S-1-5-32-545) (WriteKey)                                                                                                                  
  [!] HKLM\SOFTWARE\Microsoft\Input\Locales\loc_0039 -> BUILTIN\Users (S-1-5-32-545), Authenticated Users (S-1-5-11) (WriteKey)                                                                                                         
  [!] HKLM\SOFTWARE\Microsoft\Input\Locales\loc_0401 -> BUILTIN\Users (S-1-5-32-545), Authenticated Users (S-1-5-11) (WriteKey)                                                                                                         
  [!] HKLM\SOFTWARE\Microsoft\Input\Locales\loc_0402 -> BUILTIN\Users (S-1-5-32-545), Authenticated Users (S-1-5-11) (WriteKey)                                                                                                         
  [!] HKLM\SOFTWARE\Microsoft\Input\Locales\loc_0403 -> BUILTIN\Users (S-1-5-32-545), Authenticated Users (S-1-5-11) (WriteKey)                                                                                                         
  [*] Showing up to 25 entries from the sampled paths to avoid noisy output.


════════════════════════════════════╣ Browsers Information (T1217,T1539,T1555.003) ╠════════════════════════════════════                                                                                                                

╔══════════╣ Showing saved credentials for Firefox
    Info: if no credentials were listed, you might need to close the browser and try again.

╔══════════╣ Looking for Firefox DBs
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#browsers-history
    Not Found

╔══════════╣ Looking for GET credentials in Firefox history
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#browsers-history
    Not Found

╔══════════╣ Showing saved credentials for Chrome
    Info: if no credentials were listed, you might need to close the browser and try again.

╔══════════╣ Looking for Chrome DBs
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#browsers-history
    Not Found

╔══════════╣ Looking for GET credentials in Chrome history
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#browsers-history


=== Chrome (All Users) ===
    Not Found

╔══════════╣ Chrome bookmarks
    Not Found

╔══════════╣ Showing saved credentials for Opera
    Info: if no credentials were listed, you might need to close the browser and try again.

╔══════════╣ Showing saved credentials for Brave Browser
    Info: if no credentials were listed, you might need to close the browser and try again.

╔══════════╣ Showing saved credentials for Internet Explorer (unsupported)
    Info: if no credentials were listed, you might need to close the browser and try again.

╔══════════╣ Current IE tabs
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#browsers-history
    Not Found

╔══════════╣ Looking for GET credentials in IE history
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#browsers-history


╔══════════╣ IE history -- limit 50
                                                                                                                    
    http://go.microsoft.com/fwlink/p/?LinkId=255142
    http://go.microsoft.com/fwlink/p/?LinkId=255142

╔══════════╣ IE favorites
    Not Found


════════════════════════════════════╣ Interesting files and registry (T1083,T1552.001,T1552.002,T1552.004,T1552.006,T1003.002,T1564.001,T1574.001,T1059.004,T1114.001,T1218,T1649) ╠════════════════════════════════════                

╔══════════╣ Putty Sessions


=== Putty Saved Session Information (All Users) ===

    Not Found

╔══════════╣ Putty SSH Host keys


=== Putty SSH Host Hosts (All Users) ===

    Not Found

╔══════════╣ SSH keys in registry
╚ If you find anything here, follow the link to learn how to decrypt the SSH keys https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#ssh-keys-in-registry                                  
    Not Found

╔══════════╣ SuperPutty configuration files

╔══════════╣ Enumerating Office 365 endpoints synced by OneDrive.
 (T1083)                                                                                                            
    SID: S-1-5-19
   =================================================================================================

    SID: S-1-5-20
   =================================================================================================

    SID: S-1-5-21-1361221028-2446471266-1567148372-1104
   =================================================================================================

    SID: S-1-5-21-4029100034-1129869997-224566666-1000
   =================================================================================================

    SID: S-1-5-21-4029100034-1129869997-224566666-1002
   =================================================================================================

    SID: S-1-5-18
   =================================================================================================


╔══════════╣ Cloud Credentials (T1552.001)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#files-and-registry-credentials                                                                                                       
    Not Found

╔══════════╣ Unattend Files (T1552.001)
    C:\WINDOWS\Panther\Unattend.xml
<Password>*SENSITIVE*DATA*DELETED*</Password>

╔══════════╣ Looking for common SAM & SYSTEM backups (T1003.002)
    C:\WINDOWS\System32\config\RegBack\SAM
    File Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
                                                                                                                    
    C:\WINDOWS\System32\config\RegBack\SYSTEM
    File Permissions: SYSTEM [Allow: AllAccess], Administrators [Allow: AllAccess]
                                                                                                                    

╔══════════╣ Looking for McAfee Sitelist.xml Files (T1552.001)

╔══════════╣ Cached GPP Passwords (T1552.006)

╔══════════╣ Looking for possible regs with creds (T1552.002)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#inside-the-registry                                                                                                                  
    Not Found
    Not Found
    Not Found
    Not Found

╔══════════╣ Looking for possible password files in users homes (T1552.001)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#files-and-registry-credentials                                                                                                       
    C:\Users\All Users\Microsoft\UEV\InboxTemplates\RoamingCredentialSettings.xml

╔══════════╣ Searching for Oracle SQL Developer config files
 (T1552.001)                                                                                                        

╔══════════╣ Slack files & directories
  note: check manually if something is found

╔══════════╣ Looking for LOL Binaries and Scripts (can be slow) (T1218)
╚  https://lolbas-project.github.io/
   [!] Check skipped, if you want to run it, please specify '-lolbas' argument

╔══════════╣ Enumerating Outlook download files
 (T1114.001)                                                                                                        

╔══════════╣ Enumerating machine and user certificate files
 (T1649,T1552.004)                                                                                                  
  Issuer             : CN=Cloudbase-Init WinRM
  Subject            : CN=Cloudbase-Init WinRM
  ValidDate          : 4/23/2026 11:07:21 AM
  ExpiryDate         : 4/21/2036 11:07:21 AM
  HasPrivateKey      : True
  StoreLocation      : LocalMachine
  KeyExportable      : False
  Thumbprint         : 92E537AD32467D45B00EB653C641DB320A8A836D

   =================================================================================================

  Issuer             : CN=Cloudbase-Init WinRM
  Subject            : CN=Cloudbase-Init WinRM
  ValidDate          : 8/15/2026 10:36:39 AM
  ExpiryDate         : 8/13/2036 10:36:39 AM
  HasPrivateKey      : True
  StoreLocation      : LocalMachine
  KeyExportable      : False
  Thumbprint         : 6C61864668C6BBF2392A013B21725D64A1FBBFAB

   =================================================================================================

  Issuer             : CN=Cloudbase-Init WinRM
  Subject            : CN=Cloudbase-Init WinRM
  ValidDate          : 3/16/2026 3:09:36 PM
  ExpiryDate         : 3/14/2036 3:09:36 PM
  HasPrivateKey      : True
  StoreLocation      : LocalMachine
  KeyExportable      : False
  Thumbprint         : 12CC7E6DF7F6C4B5541C560ED94DBB1E21C6EA79

   =================================================================================================


╔══════════╣ Searching known files that can contain creds in home (T1552.001)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#files-and-registry-credentials                                                                                                       

╔══════════╣ Looking for documents --limit 100-- (T1083)
    Not Found

╔══════════╣ Office Most Recent Files -- limit 50
 (T1083)                                                                                                            
  Last Access Date           User                                           Application           Document

╔══════════╣ Recent files --limit 70-- (T1083)
   Administrator :

   ts_svc :

    C:\Qdrant\storage\aliases(8/16/2026 3:43:52 PM)
    C:\Qdrant\storage\aliases\data.json(8/16/2026 3:43:52 PM)
    C:\(8/16/2026 3:43:21 PM)
    C:\Temp\mim(8/16/2026 4:05:00 PM)
    C:\output.txt(8/16/2026 3:43:21 PM)
    C:\Qdrant\storage\raft_state.json(8/16/2026 3:43:43 PM)
    C:\Qdrant\storage(8/16/2026 3:43:43 PM)
    C:\Temp(8/16/2026 4:05:00 PM)

╔══════════╣ Looking inside the Recycle Bin for creds files (T1552.001)
╚  https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html#files-and-registry-credentials                                                                                                       
    Not Found

╔══════════╣ Searching hidden files or folders in C:\Users home (can be slow)
 (T1564.001)                                                                                                        
     C:\Users\All Users
     C:\Users\Default User
     C:\Users\Default
     C:\Users\All Users
     C:\Users\Default

╔══════════╣ Searching interesting files in other users home directories (can be slow)
 (T1552.001)                                                                                                        
     You are already Administrator, check users home folders manually.

╔══════════╣ Searching executable files in non-default folders with write (equivalent) permissions (can be slow) (T1574.001)                                                                                                            
     File Permissions "C:\Users\ts_svc\Desktop\secure_loader.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                                          
     File Permissions "C:\Users\ts_svc\Desktop\loader.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                                                 
     File Permissions "C:\Users\ts_svc\Desktop\jmp2it.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                                                 
     File Permissions "C:\Users\ts_svc\AppData\Local\Temp\WinUpdate\rundlll.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                           
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\wt.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                         
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\winget.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                     
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\WindowsPackageManagerServer.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\WindowsPackageManagerMCPServer.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                             
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\python3.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                    
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\python.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                     
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\ActionsMcpHost.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                             
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                 
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                         
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\WindowsPackageManagerServer.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                    
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\WindowsPackageManagerMCPServer.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                 
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\python3.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                        
     File Permissions "C:\Users\ts_svc\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\python.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                         
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\wt.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                  
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\winget.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                              
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\WindowsPackageManagerServer.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                         
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\WindowsPackageManagerMCPServer.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                      
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\python3.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                             
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\python.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                              
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\ActionsMcpHost.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                      
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                          
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                  
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\WindowsPackageManagerServer.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]             
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\WindowsPackageManagerMCPServer.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]          
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\python3.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                 
     File Permissions "C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\python.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                  
     File Permissions "C:\Users\All Users\Package Cache\{c5ad265e-98e6-40bd-8015-207c123dfe87}\virtio-win-guest-tools.exe": Administrators [Allow: AllAccess],SYSTEM [Allow: AllAccess]                                                 
     File Permissions "C:\Temp\mim\mimikatz.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]
     File Permissions "C:\Temp\gp.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]
     File Permissions "C:\Temp\mimikatz.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]
     File Permissions "C:\ResearchPortal\research-portal.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]                                                                                                              
     File Permissions "C:\Qdrant\qdrant.exe": SYSTEM [Allow: AllAccess],Administrators [Allow: AllAccess]

╔══════════╣ Looking for Linux shells/distributions - wsl.exe, bash.exe (T1059.004)
    C:\Windows\System32\wsl.exe

    WSL - no installed Linux distributions found.

       /---------------------------------------------------------------------------------\                          
       |                             Do you like PEASS?                                  |                          
       |---------------------------------------------------------------------------------|                          
       |         Linux PE & Hardening    :     https://hacktricks-training.com/courses/lhe/ |                       
       |         Learn Cloud Hacking       :     training.hacktricks.xyz                 |                          
       |         Follow on Twitter         :     @hacktricks_live                        |                          
       |         Respect on HTB            :     SirBroccoli                             |                          
       |---------------------------------------------------------------------------------|                          
       |                                 Thank you!                                      |                          
       \---------------------------------------------------------------------------------/             
```