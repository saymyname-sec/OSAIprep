# Module 11 — Defense & Detection (Capstone)

## Defender's Perspective

The capstone attack chain demonstrates how an adversary chains AI-specific vulnerabilities (prompt injection, RAG poisoning, indirect prompt injection) with traditional red team techniques (MSSQL xp_cmdshell, lateral movement, memory dumping) into a complete domain compromise. Detection requires both AI-native monitoring (LLM call logging, tool invocation auditing) and classic SIEM/EDR coverage. The attacker's foothold is through the AI chatbot — if the chatbot's tool calls are not logged, the initial intrusion is invisible to traditional security tooling.

---

## Detection Opportunities

### Prompt Injection via Chatbot

**What to monitor:** LLM API inputs/outputs; tool invocation logs from LM Studio / local inference endpoints; anomalous tool call patterns (maintenance mode keywords, SQL injection strings in chat input).

**Detection rule / query:**
```
LLM_INPUT CONTAINS ("ignore previous", "maintenance mode", "EXEC xp_cmdshell", "system override")
OR LLM_TOOL_CALL tool_name="SQLTest" AND input CONTAINS ("'", "--", "xp_cmd")
```

**Indicators of Compromise:**
- SQL injection strings appearing in natural language chat fields
- Unusual tool invocation immediately following a user message
- SQLTest called with `'; EXEC` or similar injection syntax
- LM Studio process making unexpected outbound connections

**False positive risk:** Low — injection syntax rarely appears in legitimate chat. SQL keywords alone may match power users; require the `'` delimiter or `EXEC` combination.

---

### xp_cmdshell Reverse Shell

**What to monitor:** SQL Server error log; Windows Event 4688 (process creation) with parent `sqlservr.exe`; network connections from `sqlservr.exe`; PowerShell ScriptBlock logging (Event 4104).

**Detection rule / query:**
```
EventID=4688 AND ParentProcessName="sqlservr.exe" AND NewProcessName IN ("cmd.exe","powershell.exe","net.exe")
OR EventID=4104 AND ScriptBlockText CONTAINS ("-e " OR "-EncodedCommand") AND CommandLine CONTAINS "sqlservr"
```

**Indicators of Compromise:**
- `sqlservr.exe` spawning `cmd.exe` or `powershell.exe`
- Base64-encoded PowerShell payload in process command line
- Outbound TCP from SQL Server host to unexpected IP on non-standard port

**False positive risk:** Medium — DBA automation may legitimately invoke PowerShell from SQL Agent jobs. Filter on interactive (non-Agent) SQLTest calls.

---

### Chisel SOCKS Tunnel

**What to monitor:** Outbound connections on unusual ports (8080, 443 with non-HTTP traffic); persistent long-lived TCP sessions; process named `chisel.exe` or with chisel signatures; encrypted tunnel traffic patterns.

**Detection rule / query:**
```
NetworkConnection process_name="chisel.exe"
OR (dst_port IN (8080, 1080, 1081, 1082) AND connection_duration > 300s AND bytes_sent > 10MB)
OR TLSClientHello AND server_name="" AND connection_count > 50_per_minute
```

**Indicators of Compromise:**
- `chisel.exe` binary on disk (hash-based)
- Long-lived TCP sessions to external IP on port 8080
- Proxychains-style multi-hop connection patterns
- SOCKS5 CONNECT requests on internal network

**False positive risk:** Medium — legitimate tunneling tools exist (VPN clients). Focus on unexpected binaries and new external IPs.

---

### RDS Gateway Lateral Movement

**What to monitor:** RDS Gateway event logs; Windows Event 4624 (logon) type 10 (RemoteInteractive) from DMZ hosts; unexpected RDP authentication via gateway from service accounts.

**Detection rule / query:**
```
EventID=4624 AND LogonType=10 AND SubjectUserName="webservice"
OR RDGateway_Event AND SourceIP IN [DMZ_range] AND TargetUser LIKE "svc_%"
```

**Indicators of Compromise:**
- Service account (`webservice`, `svc_*`) authenticating via RDS Gateway
- RDP session originating from DMZ host (not user workstation)
- Time-of-day anomaly: service account RDP at odd hours

**False positive risk:** Low — service accounts rarely need interactive RDP sessions.

---

### MSSQL Lateral Movement (sqlcmd / Q() helper)

**What to monitor:** SQL Server audit logs for xp_cmdshell usage; Windows Event 4688 for `sqlcmd.exe` spawning; network connections from unexpected hosts to SQL Server port 1433.

**Detection rule / query:**
```
SqlAudit event_type="xp_cmdshell_execution" AND caller_host != "approved-admin-host"
OR EventID=4688 AND NewProcessName="sqlcmd.exe" AND ParentProcessName NOT IN ("ssms.exe","sqlagent.exe")
```

**Indicators of Compromise:**
- xp_cmdshell enabled mid-session via `sp_configure`
- `sqlcmd.exe` invoked from PowerShell session on lateral host
- New inbound connection to MSSQL from DEV workstation (not DB admin machine)

**False positive risk:** Low — xp_cmdshell is rarely needed legitimately and should be disabled by policy.

---

### Python Module Hijack (malicious pandas.py)

**What to monitor:** File creation events in Python script directories; `pandas.py` appearing outside `site-packages`; Python process making unexpected network connections; EDR file hash mismatch on `pandas.py`.

**Detection rule / query:**
```
FileCreate path="*\pandas.py" AND NOT path="*\site-packages\*"
OR process_name="python.exe" AND network_connection AND dst_port NOT IN (443,80,8080) AND parent_command NOT CONTAINS "pip"
```

**Indicators of Compromise:**
- `pandas.py` in a user's home directory, script directory, or temp path
- Python process connecting to unexpected IP:port
- `socket.connect` syscall from python.exe to non-web destination
- Hash mismatch: `pandas.py` on disk vs. known-good pandas `__init__.py`

**False positive risk:** Low — `pandas.py` in a non-package directory is always suspicious.

---

### KeePass Memory Dump (procdump64)

**What to monitor:** Process access events (Event 10 — Sysmon) on `KeePass.exe`; `procdump64.exe` execution; large `.dmp` files written to disk; signed Sysinternals tool abuse.

**Detection rule / query:**
```
Sysmon EventID=10 AND TargetImage="*KeePass.exe" AND SourceImage != "KeePass.exe"
OR EventID=4688 AND NewProcessName="procdump64.exe" AND CommandLine CONTAINS "KeePass"
OR FileCreate AND filename="*.dmp" AND size > 50MB
```

**Indicators of Compromise:**
- `procdump64.exe` executed interactively (not from monitoring infrastructure)
- `.dmp` file created in writable user directory
- Memory access to KeePass by non-KeePass process

**False positive risk:** Low — memory dumps of KeePass are almost never legitimate outside of forensics. Sysinternals tools legitimately used by admins should be in a known path.

---

### RAG Poisoning (SMB Write to Knowledgebase)

**What to monitor:** SMB write events to Knowledgebase share by unexpected accounts; new or modified documents in the AI knowledge base; document ingestion pipeline execution.

**Detection rule / query:**
```
SMBWrite share="Knowledgebase" AND user NOT IN ["svc_kb_ingest","admin"]
OR FileWrite path="\\FILESERVER01\Knowledgebase\*" AND process_name != "ingest_agent.exe"
```

**Indicators of Compromise:**
- Service account (`svc_ai`, `webservice`) writing to Knowledgebase share
- New document added during off-hours
- Unusual keywords in document content ("SYSTEM OVERRIDE", "maintenance mode", "read_file")

**False positive risk:** Medium — knowledge base updates are legitimate but should be gated by specific service accounts.

---

### Indirect Prompt Injection (agent.log SSH Key Leak)

**What to monitor:** AI agent log files for SSH private key material; agent tool call logs for `read_file` invoked on unexpected paths; PII/secrets scanning on log output.

**Detection rule / query:**
```
LogContent CONTAINS ("BEGIN RSA PRIVATE KEY" OR "BEGIN OPENSSH PRIVATE KEY")
OR AgentToolCall tool="read_file" AND path CONTAINS (".ssh" OR "id_rsa" OR "private")
OR AgentLog event_type="tool_response" AND response_length > 2000 AND path CONTAINS ".ssh"
```

**Indicators of Compromise:**
- `BEGIN RSA/OPENSSH PRIVATE KEY` in any log file
- `read_file` tool called on SSH key paths
- Agent response containing key material routed to log

**False positive risk:** Very low — SSH private key material appearing in agent logs is never legitimate.

---

### Non-Standard SSH (port 2222)

**What to monitor:** Inbound SSH on port 2222 to dc-host or any domain controller; authentication logs on dc-host for Administrator SSH logon.

**Detection rule / query:**
```
NetworkConnection dst_port=2222 AND dst_host CONTAINS "DC"
OR AuthLog event="Accepted publickey" AND user="Administrator" AND port=2222
```

**Indicators of Compromise:**
- SSH authentication to a domain controller (rarely legitimate)
- Administrator account using SSH key auth (rather than interactive)
- Port 2222 connection from non-admin source IP

**False positive risk:** Low — SSH to a DC is unusual; Administrator SSH key auth is very unusual.

---

## Defensive Controls

| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| LLM output filtering | Prompt injection → tool abuse | Validate tool call inputs server-side, not just model-side |
| xp_cmdshell disabled by policy | SQL→RCE | `EXEC sp_configure 'xp_cmdshell', 0` + policy enforcement |
| MSSQL least privilege | Lateral via DB | Service accounts should not have sysadmin |
| AppLocker / WDAC | chisel.exe, pandas.py hijack | Block unsigned binaries and unexpected Python files |
| Python package integrity | Module hijack | Hash-verify imports; use virtual environments |
| KeePass in-memory protection | Memory dump | Enable process protection; restrict Sysinternals in production |
| SMB share ACLs | RAG poisoning | Only `svc_kb_ingest` can write to Knowledgebase share |
| Secret scanning in CI/logs | SSH key in agent.log | Automated scanning for key material in all log paths |
| SSH on DCs via firewall rule | Port 2222 access | Block port 2222 inbound on DC network segment |
| Prompt/tool call audit logging | All AI-mediated attacks | Every tool invocation must be logged with full input/output |

---

## Monitoring Checklist

- [ ] LLM input/output logging enabled and centralised to SIEM
- [ ] AI agent tool invocation logs (tool name + full parameters) stored and alerted on
- [ ] SQL Server xp_cmdshell audit enabled (SQL Audit)
- [ ] Sysmon EventID 10 (process access) on `KeePass.exe` alerting
- [ ] SMB write auditing on Knowledgebase share
- [ ] Secret scanning (regex for PEM headers) on all log files in real time
- [ ] AppLocker / WDAC rules preventing unsigned binary execution on AI workstations
- [ ] Network anomaly detection for long-lived SOCKS tunnel sessions
- [ ] Port 2222 firewall deny on DC segment
- [ ] PSReadLine history file access auditing for credential hunting

---

## Incident Response Notes

- **Prompt injection detected (SQLTest abuse):** Isolate NEXUS-EXT chatbot immediately; review all SQLTest tool invocations for the past 24h; disable xp_cmdshell; rotate `webservice` credentials.
- **chisel.exe found:** The network perimeter is already compromised; assume lateral movement; enumerate all active SOCKS sessions; block egress on chisel's C2 port.
- **malicious pandas.py found:** Assume the Python process has already been compromised; hunt for reverse shells; check all hosts reachable from the compromised workstation.
- **SSH key in agent.log:** Rotate the key immediately; review all SSH sessions to dc-host on port 2222 for the past 72h; audit Administrator account usage.
- **KeePass .dmp file found:** Assume master password is compromised; rotate all credentials stored in that KeePass database immediately.

---

## Architecture Hardening

1. **AI tool call validation layer:** Every tool the AI agent can invoke must validate inputs server-side against a strict schema — the model's judgment is not a security control.
2. **Separate AI inference from production data:** The chatbot should not have direct database access; use an API layer with parameterised queries.
3. **RAG content integrity:** Sign or hash-verify all documents entering the knowledge base; log every ingestion event with source identity.
4. **Principle of least privilege for AI service accounts:** `svc_ai` should not have SMB write access to shares it doesn't need; KeePass should not be accessible from the same host as the AI orchestrator.
5. **Immutable log pipeline:** Pipe agent.log to an append-only SIEM stream so an attacker cannot clear evidence of the SSH key leak.
6. **Secret scanning at log egress:** Any log shipped to a SIEM should pass through a secret scanner (truffleHog, detect-secrets) that fires on PEM key headers.
