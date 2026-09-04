# Module 10 — Defense & Detection

## Defender's Perspective
Threat modeling for AI systems reveals the defender's monitoring gaps just as much as the attacker's opportunities. The critical lesson from Module 10 is that detection rules stored in the target's own unauthenticated vector database handed the red team their entire evasion playbook. A defender who reads this module learns three things: (1) access control on internal datastores is non-negotiable even in "internal" networks, (2) monitoring coverage must include parameter content — not just which tools are invoked, (3) maintenance windows must be defended, not just scheduled.

---

## Detection Opportunities

### Architecture Reconnaissance (OSINT Phase)
**What to monitor:** Job posting content for technology stack exposure; GitHub repository visibility; employee LinkedIn profiles for tool/integration mentions.  
**Detection rule / query:** Automated monitoring for job postings mentioning internal tooling; GitHub org visibility audit.  
**Indicators of Compromise:** External actors begin querying GitHub repos previously not indexed publicly; job postings cited in external threat reports.  
**False positive risk:** Very high — legitimate job postings routinely mention tech stack.  
**Defensive control:** Sanitise job postings — describe competencies, not specific internal tool names. GitHub: set internal repos to private; audit forks. LinkedIn: train employees not to list internal-only integrations publicly.

### Network Service Discovery (Active Recon)
**What to monitor:** Port scan patterns — sequential port probing, service version fingerprinting (`-sV`), full port range sweeps (`-p-`).  
**Detection rule:**
```
alert tcp any any -> 10.10.50.0/24 any (
  msg:"Potential port scan"; flags:S; threshold:type both, track by_src, count 50, seconds 10;
  classtype:network-scan; sid:9001; rev:1;
)
```
**IoCs:** Single source IP hitting >20 distinct destination ports in <30 seconds; nmap OS fingerprint probes; service banner grabs on AI service ports (9000-9005, 6333, 8200).  
**False positive risk:** Medium — internal vulnerability scanners produce similar patterns.

### MCP Tool Enumeration
**What to monitor:** Unauthenticated or authenticated GET requests to `/tools` endpoint; bulk tool listing outside of known agent startup sequences.  
**Detection rule:** Alert on `/tools` requests from IPs not in the agent IP allowlist.  
**IoCs:** `/tools` request from IP ≠ known agent IPs; request shortly before first tool invocation (recon pattern).  
**False positive risk:** Low — legitimate agents cache tool schemas at startup; repeated enumeration is suspicious.

### Qdrant Unauthenticated Access / Bulk Read
**What to monitor:** Scroll requests with `limit > 20` from non-agent IPs; any access to `detection_rules` or `runbook_corpus` collections from outside the agent subnet.  
**Detection rule (`nexus-qdrant-004` equivalent):**
```
Log Qdrant REST API access. Alert when:
- Source IP not in agent_ip_allowlist
- Request method is POST to /points/scroll
- limit field > 20
```
**IoCs:** Bulk scroll of `detection_rules` collection (immediate indicator of intelligence gathering); scroll of `incident_history` or `runbook_corpus` from external IP.  
**False positive risk:** Low for `detection_rules` — no legitimate agent reads this collection at query time.  
**Critical fix:** Enable Qdrant API key authentication. For production collections containing sensitive operational data, apply collection-level access control.

### K8s Secret Enumeration
**What to monitor:** K8s audit log — `get` and `list` operations on `secrets` resource; JWT used for access (is it the grey-box token?).  
**Detection rule:**
```yaml
# K8s audit policy
- level: Request
  resources:
  - group: ""
    resources: ["secrets"]
  verbs: ["get", "list", "watch"]
  namespaces: ["nexus-ai"]
```
**IoCs:** `list secrets` call (unusual — legitimate agents get specific secrets by name, not list all); `get secret nexus-mcp-vault-approle` (Vault AppRole credential — should never be read by agents, only by MCP startup).  
**False positive risk:** Low for `list` operations; medium for individual `get` calls (agents legitimately read their own token secret).

### MCP Tool Invocation Anomalies
**What to monitor:** Tool invocations outside agent IP ranges; `vault_rotate_secret` outside maintenance window; `aws_cli_exec` with IAM-class commands; tool invocations with parameters not matching known agent workflows.  
**Detection rules:**
- `nexus-mcp-001`: Unusual invocation patterns (source IP, time, frequency)
- `nexus-mcp-002`: `vault_rotate_secret` outside maintenance window → HIGH severity
- `nexus-aws-005`: `aws_cli_exec` with `iam:*` or `sts:*` commands → CRITICAL
**IoCs:** Remediation token used from non-remediation-agent IP; `vault_rotate_secret` at 03:00 when maintenance window is 22:00–23:00; `aws_cli_exec` with `iam list-users` command.  
**False positive risk:** Low — agent tokens are scoped; invocations outside scope are definitionally anomalous.

---

## Defensive Controls

| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| Qdrant API key authentication | Unauthenticated Qdrant access (CJ #2, #3 prevention) | Enable `api_key` in `config.yaml`; rotate quarterly |
| K8s RBAC least-privilege | Secret enumeration; Vault AppRole theft | Agents get `get` on own secret only; no `list secrets` |
| Agent JWT scope validation at MCP | Token reuse across tools | MCP validates `scope` claim on every invocation |
| MCP IP allowlist | Non-agent tool invocation | MCP rejects requests from IPs ≠ agent pod IPs |
| Vault AppRole secret in K8s — not in MCP env | AppRole credential exfil | Use Vault agent sidecar; never store AppRole in K8s secret accessible to non-MCP pods |
| Detection rule collection access control | Intel gathering from defender's own rules | `detection_rules` collection: read only from monitoring SA, not from agent network |
| Maintenance window enforcement | `vault_rotate_secret` timing attacks | MCP enforces time-based policy for destructive tools |
| Job posting sanitisation | Tech stack OSINT | Describe competency domains, not specific tool names |
| GitHub repo/fork visibility audit | Source code / README intel leakage | Quarterly audit; fork monitoring; private upstream repos |

---

## Monitoring Checklist
- [ ] Qdrant API authentication enabled (API key minimum; mTLS preferred for prod)
- [ ] Qdrant access logs shipped to SIEM; `detection_rules` collection read = alert
- [ ] K8s audit logging enabled with `Request` level for `secrets` resource in `nexus-ai` namespace
- [ ] MCP Server access log: source IP, token identity, tool name, parameters logged per invocation
- [ ] `vault_rotate_secret` invocations outside maintenance window = PagerDuty alert
- [ ] `aws_cli_exec` with `iam:` or `sts:` commands = CRITICAL alert
- [ ] Agent JWT tokens: per-agent rotation schedule; alert on token used from non-agent IP
- [ ] GitHub org fork monitoring enabled
- [ ] LinkedIn / job posting review process for tech stack exposure

---

## Incident Response Notes

| Indicator | Likely scenario | Initial response |
|-----------|----------------|-----------------|
| Bulk `detection_rules` scroll from external IP | Red team / attacker exfiltrating monitoring playbook | Rotate detection rules; treat attacker as aware of all monitoring; escalate to purple team |
| `vault_rotate_secret` outside maintenance window | Stolen remediation token being weaponised | Revoke remediation JWT immediately; check what secret was rotated; rotate AWS creds if `nexus/aws` was targeted |
| `aws_cli_exec` with IAM commands | Attacker escalating from MCP to AWS control plane | Isolate MCP; suspend Vault AppRole; initiate AWS incident response |
| `list secrets` in `nexus-ai` namespace | K8s credential enumeration | Audit which secrets were listed; rotate Vault AppRole; rotate all agent JWTs |
| OSINT report citing internal tool names | Job posting or GitHub repo intel leakage | Identify source; update job postings; review GitHub fork list |

---

## Architecture Hardening

**Qdrant access control:**
- Enable API key authentication for all collections
- Separate collections by sensitivity: `detection_rules` / `runbook_corpus` on a separate Qdrant instance with no cluster-internal route from agent pods
- Apply collection-level ACL: monitoring SA = read; agents = read (their own collections only); write = restricted to training pipeline SA

**K8s secret hygiene:**
- Replace Vault AppRole K8s secret with Vault Agent Injector sidecar — AppRole never stored as K8s secret
- One service account per agent with minimal RBAC (`get` on own token secret only, no `list`)
- Enable K8s audit logging at `Metadata` minimum; `Request` for sensitive resources

**MCP hardening:**
- IP allowlist per tool — `vault_rotate_secret` only callable from remediation agent pod IP
- Parameter validation — detect instruction injection in string parameters (Module 07 coverage)
- `aws_cli_exec` scoped to STS read-only operations by default; IAM operations require secondary approval

**OSINT attack surface reduction:**
- Job postings: competency language only, no tool names
- GitHub: private upstream repos; fork monitoring; remove internal service names from public READMEs
- LinkedIn: employee guidance on not listing internal-only integrations
