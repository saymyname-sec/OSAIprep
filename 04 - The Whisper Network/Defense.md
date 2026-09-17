# Module 04 — Defense & Detection

## Defender's Perspective
Multi-agent systems are particularly dangerous from a blue team perspective because a single injected prompt can cascade across an entire agent network. Defenders must secure the orchestrator (the single point of trust), validate agent registrations, monitor inter-agent communication, and apply output filtering before downstream agents act.

---

## Detection Opportunities

### Orchestrator Prompt Injection (Link / Security Bypass)
**What to monitor:** Request bodies containing bypass phrases, explicit DISABLE/SKIP/BYPASS directives, or unusual history arrays claiming prior security approval.
**Detection rule:**
```python
bypass_keywords = [
    "DISABLE the security scan", "BYPASS the Security Link Scanner",
    "skip the redundant check", "already scanned", "CISO has granted",
    "security team signed off", "internal use only", "no external scanning"
]
if any(kw.lower() in prompt.lower() for kw in bypass_keywords):
    alert("INJECTION: Security bypass attempt", source_ip, prompt[:200])

# History manipulation — fake approval injection
if "history" in request_body:
    for item in history:
        if any(x in item.lower() for x in ["security agent", "0 risks", "signed off", "pre-approved"]):
            alert("INJECTION: Fabricated security approval in history", source_ip)
```
**IoCs:** Explicit security control keywords in prompts; history arrays claiming scan completion for sessions that never had one; authority claim phrases (CISO, VP, security team).
**False positive risk:** Legitimate users discussing security policies — use session correlation (has a real scan run in this session?).

---

### SQL Agent Prompt Injection / xp_cmdshell
**What to monitor:** nl-to-sql queries containing `sp_configure`, `xp_cmdshell`, `LOLBin` names, or Windows utility names.
**Detection rule:**
```
# SQL injection keywords in nl-to-sql queries
sql_injection_patterns = [
    "sp_configure", "xp_cmdshell", "RECONFIGURE",
    "certutil", "powershell", "Invoke-WebRequest", "bcp", "pwned"
]
if any(pat.lower() in prompt.lower() for pat in sql_injection_patterns):
    block_and_alert("SQL RCE attempt via AI agent")

# DB-side: monitor for xp_cmdshell execution
-- SQL Server audit query:
SELECT event_time, session_id, statement
FROM sys.dm_exec_query_stats
WHERE statement LIKE '%xp_cmdshell%'
   OR statement LIKE '%sp_configure%xp%'
```
**IoCs:** "troubleshooting" or "diagnostics" framing with SQL admin commands; certutil/PowerShell in SQL context; downloads to `C:\Windows\Temp\`.
**False positive risk:** Legitimate DBA queries — whitelist known DBA session IDs; flag AI-originated SQL only.

---

### Rogue Agent Registration
**What to monitor:** `/agents/register` calls — especially from IPs not in the known agent inventory.
**Detection rule:**
```
# Unknown agent registration
if endpoint == "/agents/register":
    agent_ip = extract_ip(agent_card_url)
    if agent_ip not in KNOWN_AGENT_IPS:
        alert("ROGUE AGENT: Unknown agent registering", agent_ip, capabilities)

    # Subset capability registration (stealth indicator)
    if len(capabilities) < len(FULL_CAPABILITY_SET):
        log("SUSPICIOUS: Partial capability registration", agent_ip)
```
**IoCs:** Agent registration from unexpected IPs; agent cards with mismatched names/descriptions vs. registered IP; subset capability registration (stealth indicator).
**False positive risk:** Legitimate new agent deployments — require signed agent cards or certificate pinning.

---

### MITM / Response Tampering
**What to monitor:** Agent responses containing URLs not in an approved domain allowlist; injected phrases like "URGENT", "system update", "critical patch".
**Detection rule:**
```python
import re
APPROVED_DOMAINS = {"dashboard.local", "internal.corp", "sharepoint.company.com"}
TAMPER_PHRASES = ["URGENT", "System Update Required", "Download critical patch", "⚠️"]

def validate_response(response_text):
    urls = re.findall(r'https?://[\w./%-]+', response_text)
    for url in urls:
        domain = extract_domain(url)
        if domain not in APPROVED_DOMAINS:
            alert("RESPONSE TAMPER: Unexpected URL in agent response", url)
    for phrase in TAMPER_PHRASES:
        if phrase in response_text:
            alert("RESPONSE TAMPER: Suspicious phrase detected", phrase)
```
**IoCs:** External URLs in responses that should only contain internal links; urgency/alert language in structured business documents; response timing anomalies (rogue agent jitter ≠ real agent timing).

---

### DNS / /etc/hosts Spoofing
**What to monitor:** Changes to `/etc/hosts` on agent servers; DNS resolution mismatches for agent hostnames.
**Detection rule:**
```bash
# File integrity monitoring on /etc/hosts
inotifywait -m /etc/hosts -e modify | while read event; do
    alert "INTEGRITY: /etc/hosts modified on $(hostname)"
done

# DNS resolution consistency check (run periodically)
for hostname in payment-agent.internal customer-agent.internal; do
    resolved=$(dig +short $hostname)
    expected=$(cat /etc/agent_inventory | grep $hostname | awk '{print $2}')
    if [ "$resolved" != "$expected" ]; then
        alert "DNS SPOOF: $hostname resolves to $resolved, expected $expected"
    fi
done
```
**IoCs:** `/etc/hosts` modifications outside change windows; agent hostnames resolving to unexpected IPs; credential headers captured and replayed.

---

## Defensive Controls
| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| Agent registry allowlist | Rogue agent registration | Only accept registrations from known IPs with signed agent cards |
| Agent card certificate pinning | DNS/hosts spoofing | Pin TLS cert or public key for each legitimate agent |
| Prompt input filtering | Security bypass injections | Blocklist bypass keywords before orchestrator processes |
| Conversation history validation | History-based trust manipulation | Verify claimed scan results against actual session logs |
| SQL query output sandboxing | xp_cmdshell RCE | Run nl-to-sql in read-only DB context; disable xp_cmdshell permanently |
| Response URL allowlisting | MITM response tampering | Filter all agent responses through URL allowlist proxy |
| Inter-agent mTLS | MITM interception | Require mutual TLS for all A2A communication |
| Capability scope enforcement | Stealth rogue agent | Enforce declared capabilities — don't route tasks outside declared skill set |

---

## Monitoring Checklist
- [ ] Alert on any `/agents/register` call from unrecognised IP
- [ ] Log all orchestrator prompts and scan for bypass keywords
- [ ] Monitor history arrays for fabricated security approval claims
- [ ] Validate all agent response URLs against approved domain list
- [ ] File integrity monitoring on `/etc/hosts` across all agent servers
- [ ] Periodic DNS resolution checks for all agent hostnames
- [ ] DB audit logging for `xp_cmdshell` and `sp_configure` executions
- [ ] Response timing monitoring — rogue agents with jitter have different latency profiles

---

## Incident Response Notes
- **Rogue agent registered:** Immediately deregister (`/agents/deregister`), block IP, review all tasks routed to that agent for data exfiltration.
- **xp_cmdshell executed via SQL agent:** Treat as full server compromise — check `C:\Windows\Temp\` for dropped files, review process list, isolate DB server.
- **Response tampering detected:** Quarantine orchestrator, audit all responses delivered to users in the window, notify affected users of potential phishing links.
- **DNS hostname redirected:** Reset `/etc/hosts`, rotate all credentials that may have been captured, audit agent-to-agent auth tokens.

---

## Architecture Hardening
- **Never expose `/agents/register` unauthenticated** — require signed registration tokens or admin API key
- **Disable xp_cmdshell permanently** on any SQL Server exposed to AI agent queries — there is no legitimate AI use case for OS-level execution
- **Run nl-to-sql agents in read-only DB accounts** — SELECT only, no DDL/DML/EXEC
- **Implement output filtering proxy** between all agents — validate URLs, strip HTML, flag urgency language before downstream delivery
- **Mutual TLS for all A2A communication** — prevents MITM interception even if routing is compromised
- **Validate conversation history server-side** — do not trust client-supplied history as ground truth for security decisions
