# Module 11 — Glossary

**adsisearcher** — PowerShell type accelerator wrapping `DirectoryServices.DirectorySearcher`; performs LDAP queries without spawning net.exe or nltest.exe, reducing EDR detection surface.

**Agent log (agent.log)** — Structured JSON log written by the RAG agent recording ingest_ok, lm_response, lm_error, and heartbeat events; exploited to exfiltrate SSH key material in Phase 5.

**appsettings.json** — ASP.NET Core configuration file; commonly contains database connection strings with plaintext credentials.

**Binary replacement** — Privilege escalation technique where a low-privileged user overwrites a binary executed by a higher-privileged scheduled task or service, causing arbitrary code to run as that privilege level.

**Chisel** — TCP/UDP tunnel tool that creates reverse SOCKS proxies; used here to pivot from each compromised host back to Kali (msedgeupdate.exe / renamed).

**CREATE_NO_WINDOW (0x08000000)** — Windows process creation flag suppressing the console window; used in the malicious pandas.py to avoid a visible cmd.exe popup on the target.

**CVE-2025-26125** — IOBit Advanced SystemCare vulnerability allowing low-privileged users to delete arbitrary files through the SYSTEM-running service; exploited via PoC (SystemSettingsHelper.exe) to obtain a SYSTEM shell on CLIENT01.

**DEV domain** — `dev.example.internal`; child domain with bidirectional trust to DMZ domain; hosts CLIENT01/02, db01.dev, gitlab01.

**DMZ domain** — `dmz.example.internal`; outer domain containing db-host, web-host, dc-host, mail-host, jump-host.

**GenericWrite** — AD permission allowing modification of an object's attributes, including group membership; abused to add svc-web to VPN Users group.

**GitLab PAT (glpat-)** — Personal Access Token for GitLab API authentication; found in alex.simmons' VS Code settings.json.

**gokeepasslib** — Go library for reading KeePass `.kdbx` vaults; identified in health_monitor.exe binary strings, indicating runtime credential decryption.

**health_monitor.exe** — Go binary that reads credentials from a KeePass vault at runtime and maps a network share; process memory dump reveals plaintext net use command with rag_kb credentials.

**Heartbeat** — Periodic log entry written by the RAG agent confirming it is alive and monitoring the knowledge base directory; 60-second interval revealed in agent.log.

**Indirect prompt injection** — Attack where adversary-controlled content (e.g., a poisoned document) is retrieved by a RAG pipeline and interpreted by the LLM as instructions, causing unintended tool invocations without direct user interaction.

**ingest_ok** — RAG agent log event confirming a document was successfully embedded into the vector store; presence of 00_keywords.md in ingest_ok confirms poisoning succeeded.

**IOBit Advanced SystemCare** — Third-party optimization software; its SYSTEM service is vulnerable to CVE-2025-26125.

**Knowledge base poisoning** — Technique of writing malicious content to a RAG knowledge base so it is retrieved as context and influences LLM behavior; used here with a trigger keyword and file-read instruction.

**lm_response** — RAG agent log event recording a query and the LLM's response; attacker polls this to retrieve the exfiltrated SSH key.

**Map-PSDriveCustom.exe** — SSMS plugin binary on db01.dev; contains hardcoded unicode strings including example-corp\devaccess credentials used to map network drives.

**example-corp domain** — `example.internal`; parent/internal domain; final target for Domain Admin.

**Module hijack (Python)** — Placing a malicious `pandas.py` in the same directory as a target script so Python's module resolution finds it before the real library; reverse shell spawned while real pandas is re-imported to avoid crashes.

**mcs** — Mono C# compiler; used to compile XOR-obfuscated C# reverse shell source on Kali.

**mingw (x86_64-w64-mingw32-gcc)** — Linux cross-compiler for Windows PE binaries; compiles loader.c into beacon.exe.

**non-daemon thread** — Python thread that keeps the interpreter alive after main code completes; used in pandas.py to hold the reverse shell connection open after sales_calc.py finishes.

**pandas.py** — Malicious Python module placed on the Files share to hijack the `import pandas` statement in sales_calc.py; spawns a reverse shell while re-importing the real pandas library.

**procdump64.exe** — Sysinternals memory dump utility; signed binary less likely to trigger Defender; used to dump health_monitor.exe process memory.

**proxychains** — Tool that forces TCP connections through a configured SOCKS proxy; used with separate config files for each tunnel (port 1080/1081/1082).

**PSReadLine ConsoleHost_history.txt** — PowerShell command history file; contains the ssh-keygen invocation with the administrator key passphrase.

**rag_kb** — example-corp domain account that runs the health_monitor.exe share-mapping function; credentials recovered from process memory dump.

**RAG pipeline** — Retrieval-Augmented Generation; system that embeds documents into a vector store and retrieves relevant context to augment LLM responses; attack surface for knowledge base poisoning and indirect prompt injection.

**RD Gateway / jump-host** — Remote Desktop Gateway server; tunnels RDP over HTTPS; controlled by Resource Authorization Policies (RAPs) defining which hosts and users are permitted.

**read_file tool** — RAG agent tool for reading files from the knowledge base; exploited via indirect prompt injection to read lily.fisher's SSH private key from outside the intended scope.

**Resource Authorization Policy (RAP)** — RD Gateway policy defining which computer groups a connecting user can reach through the gateway.

**Reverse SOCKS** — Chisel operating mode where the compromised host initiates the connection outbound to the C2 server, which then exposes a local SOCKS port for proxychains.

**RuntimeBroker.exe** — Legitimate Windows process name; used as cover name for the Sliver beacon executable.

**sales_automation.ps1** — Wrapper script that SHA-256 hashes sales_calc.py before execution; triggers restore_salesdata.exe if hash mismatches.

**sales_calc.py** — Legitimate Python data analysis script on the Files share; hash-protected against direct modification; attacked via module hijack instead.

**SelfSubjectRulesReview** — Kubernetes API call to enumerate one's own RBAC permissions without kubectl; curl-based alternative used in earlier modules.

**Sliver** — Open-source C2 framework; generates beacon shellcode with shikata ga nai encoding and symbol obfuscation; persistent implant used throughout the engagement.

**SSMS plugin** — SQL Server Management Studio plugin directory; used by svc-db to auto-map network drives on startup; Map-PSDriveCustom.exe contains hardcoded parent-domain credentials.

**SQLTest** — Chatbot tool that executes T-SQL against the backend MSSQL database; exploited via prompt injection to enable xp_cmdshell and achieve RCE.

**T-SQL** — Transact-SQL; Microsoft's SQL dialect; identifying "T-SQL" in chatbot response confirms MSSQL backend.

**trigger keyword** — Nonsense string (oiajwdoiajwoidajoiwdjaoiwdja) observed in agent.log test queries; used as the semantic hook in the poisoned document to ensure retrieval and instruction execution.

**tsclient** — Virtual drive name created by xfreerdp3's `/drive` flag; allows file transfers over the RDP connection without additional network connections.

**VPN Users group** — DMZ AD group that grants RDS Gateway access to CLIENT01/02 in dev.example.internal; svc-web has GenericWrite, allowing self-addition.

**xfreerdp3** — FreeRDP client; supports RD Gateway (`/gateway:`), drive sharing (`/drive:`), and certificate bypass (`/cert:ignore`).

**XOR obfuscation** — Simple symmetric encryption applied to connection strings in the C# reverse shell source; defeats basic string-based AV signatures.

**xp_cmdshell** — MSSQL extended stored procedure for OS command execution; disabled by default; requires sysadmin and `show advanced options`; enabled via `sp_configure`.

**xor_encrypt.py** — Provided script that XOR-encrypts Sliver beacon shellcode and outputs a C header file for embedding in loader.c.
