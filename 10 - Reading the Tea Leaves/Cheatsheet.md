# Module 10 — Threat Modeling Cheatsheet

## Assumption Register Template
| ID | Observation | Hypothesis | Confidence | Source | Status |
|----|-------------|-----------|------------|--------|--------|
| A-XX | What was observed | What we think it means | HIGH/MEDIUM/LOW | Source artifact | UNVALIDATED/VALIDATED/INVALIDATED |

**Confidence rules:**
- HIGH = direct client doc or live confirmed observation
- MEDIUM = indirect inference, corroborating signals
- LOW = absence of evidence (verify early, don't plan attacks on it)

## Assumption Lifecycle
```
UNVALIDATED → VALIDATED   (drives attack planning)
           → INVALIDATED  (generate new hypotheses, don't stop)
```

---

## Nexus AI Component Quick Reference
| IP | Port | Service |
|----|------|---------|
| 10.10.50.10 | 9000 | Orchestrator |
| 10.10.50.11 | 9001 | Triage Agent |
| 10.10.50.12 | 9002 | Remediation Agent |
| 10.10.50.13 | 9003 | Security Agent |
| 10.10.50.14 | 9004 | Knowledge Agent |
| 10.10.50.15 | 9005 | MCP Server JSON-RPC |
| 10.10.50.20 | 6333 | Qdrant (production, unauthenticated) |
| 10.10.50.20 | 16333 | Qdrant (staging — writes permitted by RoE) |
| 10.10.50.21 | 5000 | MLflow |
| 10.10.50.22 | 8200 | Vault (unsealed) |

---

## Active Recon Commands

### Qdrant — unauthenticated reads
```bash
# List collections
curl -s http://10.10.50.20:6333/collections | jq '.result.collections[].name'

# Scroll collection (intelligence extraction)
curl -s http://10.10.50.20:6333/collections/detection_rules/points/scroll \
  -X POST -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_payload": true, "with_vector": false}' | \
  jq '.result.points[].payload.rule_name'
```

### MCP Server — tool enumeration + invocation
```bash
# List tools
curl -s http://10.10.50.15:9005/tools | jq '.tools[] | {name, description}'

# Invoke tool (with agent token)
curl -s http://10.10.50.15:9005/invoke -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"tool": "vault_rotate_secret", "params": {"secret_path": "secret/nexus/test_canary"}}'
```

### Kubernetes — secret extraction (grey-box token)
```bash
# List secrets
kubectl --token=$K8S_TOKEN get secrets -n nexus-ai \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

# Extract agent token
kubectl --token=$K8S_TOKEN get secret nexus-remediation-agent-token -n nexus-ai \
  -o jsonpath='{.data.token}' | base64 -d

# K8s secrets = base64 only, NOT encrypted
```

---

## Trust Boundaries (Nexus AI)
| ID | From → To | Enforcement | Key Exploit Implication |
|----|-----------|-------------|------------------------|
| TB-1 | Alert Sources → Orchestrator | Webhook auth (unknown) | If unauth'd → untrusted input into pipeline |
| TB-2 | Orchestrator → Agents | mTLS | Agents trust Orchestrator dispatches fully |
| TB-3 | Agents → Qdrant | None | Agents treat Qdrant as ground truth |
| TB-4 | Agents → MCP Server | Per-agent JWT | Per-tool scoping; params unmonitored (A-15) |
| TB-5 | MCP Server → Vault | AppRole only | Agent identity collapses — Vault sees MCP identity only |
| TB-6 | MCP Server → AWS/External | API keys | No additional auth gate after cred retrieval |
| TB-7 | Triage → Orchestrator | Inference-based | Manipulate classification → drives downstream |
| TB-8 | Knowledge Agent → Agents | None | RAG responses trusted without verification |

**Policy-enforced vs inference-based trust:**
- Policy: rejects invalid tokens → auth bypass required
- Inference: LLM classification, RAG advisory → exploitable via input manipulation

---

## Escalation Paths Summary

### Path 1 — Token Theft → Direct MCP Abuse (PRIMARY)
```
K8s secrets → Remediation Agent JWT → aws_cli_exec → AWS creds
```
- **Gate 1:** A-12b (Remediation token authorizes aws_cli_exec) — test with test_canary first
- **Gate 2:** A-15 (MCP params not monitored) — or avoid nexus-aws-005 IAM patterns
- **Clock:** 24hr reporting requirement starts on first MCP invoke
- **ATLAS:** AML.T0085

### Path 2 — Staging Poisoning → Indirect Remediation (ALTERNATE)
```
Staging Qdrant :16333 → Knowledge Agent retrieves → Remediation Agent acts
```
- **Hard gate:** Does Knowledge Agent query :16333? Observe traffic first
- **Targeting:** Craft content matching Remediation-type queries only
- **Advantage:** Agent generates params itself → A-15 irrelevant
- **ATLAS:** AML.T0020

### Path 3 — Intelligence Extraction (SUPPORT — FIRST)
```
Qdrant :6333 unauthenticated → detection_rules, runbooks, operational_knowledge
```
- **Execute immediately** — enables go/no-go for all other paths
- **Risk:** nexus-qdrant-004 may fire from attack host IP — accepted
- **ATLAS:** AML.T0025

---

## Detection Rules (Nexus AI — extracted from Qdrant)
| Rule | Trigger | Operational Constraint |
|------|---------|----------------------|
| nexus-mcp-001 | Unusual MCP tool invocation pattern | Mimic normal agent patterns |
| nexus-mcp-002 | vault_rotate_secret outside maintenance window | Time invocations to maintenance window |
| nexus-agent-003 | Direct agent-to-agent communication | Route through Orchestrator |
| nexus-qdrant-004 | Bulk vector read from non-agent IP | Route later reads through agent pod |
| nexus-aws-005 | AWS IAM modification outside change window | Use non-IAM AWS commands or time carefully |

---

## Crown Jewels — Access Status at Day 3
| Rank | Asset | Status |
|------|-------|--------|
| #1 | AWS credentials | Behind 3 boundaries — primary target |
| #2 | Detection rules | **OBTAINED** (Day 2) |
| #3 | Runbook corpus | Accessible now (unauthenticated Qdrant) |
| #4 | Agent tokens | **OBTAINED** (Day 2, K8s secrets) |
| #5 | Model weights | Access not yet validated |
| #6 | MCP tool schemas | **OBTAINED** (Day 1) |

---

## MITRE ATLAS Quick Map
| Technique | ID | Viability |
|-----------|-----|-----------|
| Exfiltration via Cyber Means | AML.T0025 | Immediate (unauthenticated Qdrant) |
| Poison Training Data | AML.T0020 | Staging only per RoE |
| Data from AI Services | AML.T0085 | Valid agent token in hand |
| Inference API Access | AML.T0040 | Immediate (HTTP endpoints) |
| ML Model Access | AML.T0044 | Pending MLflow auth validation |
| AI Supply Chain Compromise | AML.T0010 | Pending MLflow write validation |
| Craft Adversarial Data | AML.T0043 | Pending TB-1 webhook auth status |

---

## RoE Hard Constraints (Nexus AI)
- ❌ Production Qdrant writes (poisoning)
- ❌ Denial-of-service on any component
- ❌ Production financial systems, AD domain controllers
- ✅ Staging Qdrant (:16333) — reads AND writes permitted
- ⏰ MCP invocations: report to Blue Team POC within 24 hours
- 🕐 Testing window: 08:00–20:00 Mon–Fri only

---

## Iterative Threat Model — "When Plans Break"
1. **Path 2 validation fails** → Knowledge Agent queries production only
   → New hypothesis: Qdrant endpoint configurable via ConfigMap/env
   → New path: foothold → modify Knowledge Agent config → staging routing viable

2. **A-15 invalidated** → Parameters ARE monitored (nexus-mcp-006)
   → Don't abandon Path 1; constrain command
   → Use `aws ssm send-command` instead of IAM commands (avoids nexus-aws-005 pattern)

**Rule:** Invalidated assumption → generate new hypothesis, don't stop.
