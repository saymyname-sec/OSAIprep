# Module 11 — Glossary

## Capstone-Specific Terms

**LM Studio** — Local inference server for running open-weight LLMs (e.g. Qwen) on a local machine. Exposes an OpenAI-compatible API, typically on port 1234.

**Qwen** — Open-weight LLM from Alibaba, used in the capstone as the model powering the NEXUS-EXT AI chatbot.

**SQLTest tool** — A custom AI agent tool that executes SQL queries directly against the MSSQL backend. Its lack of secondary validation makes it the primary prompt injection target.

**xp_cmdshell** — MSSQL extended stored procedure that executes OS-level shell commands as the SQL Server service account. Disabled by default; must be enabled via `sp_configure`.

**Chisel** — Go-based HTTP tunneling tool that creates TCP tunnels over HTTP/HTTPS, commonly used for SOCKS proxy pivoting during red team engagements.

**Proxychains** — Linux tool that routes TCP connections through one or more SOCKS/HTTP proxies, enabling traffic to flow through multiple pivot points.

**RDS Gateway (Remote Desktop Services Gateway)** — Microsoft service that provides secure, authenticated RDP access over HTTPS, bridging network segments via standard web ports.

**GenericWrite** — Active Directory permission allowing modification of an object's non-protected attributes, including group membership. Can be abused for privilege escalation.

**adsisearcher** — PowerShell built-in LDAP query interface (`[adsisearcher]`). Performs AD enumeration without spawning child processes, making it stealthier than `net` commands or PowerShell AD modules.

**Python module hijack** — Technique exploiting Python's import resolution order (CWD → PYTHONPATH → site-packages). Placing a malicious `pandas.py` in a script's working directory causes it to be imported instead of the legitimate pandas package.

**procdump64** — Sysinternals signed utility for creating full process memory dumps. Used to dump KeePass memory to extract the master password in cleartext.

**KeePass** — Open-source password manager. When running, stores decrypted passwords in process memory, making it vulnerable to memory dump attacks.

**RAG poisoning** — Corrupting a Retrieval-Augmented Generation knowledge base by writing adversarial documents to the data source. When the AI agent indexes and retrieves the poisoned document, it executes embedded instructions.

**Indirect prompt injection** — Prompt injection delivered via data the AI agent retrieves (a document, web page, email) rather than directly in user input. The agent acts as an unwitting executor of attacker-controlled instructions.

**Knowledgebase share** — SMB file share used as the data source for the RAG pipeline. Write access to this share enables RAG poisoning.

**XOR obfuscation** — Simple symmetric encryption using XOR with a repeating key, used to obfuscate shellcode and strings in binaries to evade static signature detection.

**EnumDesktopWindows callback** — Windows API technique where shellcode is passed as a callback function pointer to `EnumDesktopWindows`. The API executes the callback, giving the shellcode a legitimate call stack origin.

**gen_cs_shell.sh** — Custom bash script that generates an XOR-obfuscated C# reverse shell, compiles it with Mono (`mcs`), and outputs a Windows executable.

**loader.c** — C source for a shellcode loader that decrypts XOR-obfuscated Sliver shellcode and executes it via `EnumDesktopWindows` callback.

**PSReadLine history** — PowerShell's command history file stored at `$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt`. Often contains credentials typed interactively.

**CVE-2025-26125** — Privilege escalation vulnerability in IOBit Advanced SystemCare. Exploited by replacing a SYSTEM-scheduled task binary at a user-writable path.

**agent.log** — Log file written by the NEXUS AI agent recording all tool invocations and their outputs. SSH key material leaked via indirect prompt injection appears here.
