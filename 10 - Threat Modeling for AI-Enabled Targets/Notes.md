# Module 10 — Threat Modeling for AI-Enabled Targets

## Core Concept

Threat modeling for AI is **iterative, not pre-built**. It starts with fragments, evolves through active intelligence collection, and is constrained at every step by Rules of Engagement and real-world limitations. The output is an **attack intelligence brief** — a living artifact updated as assumptions validate or collapse.

---

## 10.1 — Reconstructing the Target from Partial Intelligence

### 10.1.1 Phase 1 — Pre-Engagement Intelligence Sources

**Three artifact types at engagement start:**
1. **Scoping document** — access type, network boundaries, in/out of scope, Rules of Engagement
2. **Passive OSINT** — LinkedIn job postings (tech stack), GitHub public forks (tool names), employee profiles (skills → inferred components)
3. **Client kickoff documentation** — high-level data flow descriptions (vague but useful)

**Key OSINT indicators for AI/ML stacks:**

| Source | What to Look For |
|--------|-----------------|
| LinkedIn job postings | MLflow, Qdrant, Weaviate, Pinecone, Vault, MCP, LangChain, Kubernetes |
| DevOps profiles | Vault, ArgoCD, Helm, GPU instance types |
| GitHub forks | Tool names in READMEs, references to private upstream repos |
| Error messages / docs | Component versions, internal service names |

**Nexus AI pre-engagement picture:**
- "Central orchestrator routes to specialized agents" → hypothesis of 1 orchestrator + N agents
- LinkedIn: MLflow, Qdrant, Vault → tech stack hypotheses
- GitHub fork README: `aws_cli_exec`, `snow_create_ticket`, `datadog_query` → MCP tool surface partially known

---

### 10.1.2 The Assumption Register

**Structure:** Every hypothesis is tracked with: Observation → Hypothesis → Confidence → Source → Status

**Confidence levels (based on source reliability, not probability of truth):**
- HIGH: Direct client documentation or confirmed observation
- MEDIUM: Indirect inference, corroborating signals
- LOW: Absence of evidence, single weak signal

**Status lifecycle:**
```
UNVALIDATED → (active recon / testing) → VALIDATED (drives attack planning)
                                       → INVALIDATED (generates new hypotheses)
```

**Critical rule:** LOW confidence = verify early, do NOT drive attack planning until promoted. Absence of evidence ≠ confirmation of vulnerability.

**Nexus AI initial register (8 entries):**

| ID | Hypothesis | Confidence | Status |
|----|-----------|------------|--------|
| A-01 | Single orchestration component | HIGH | UNVALIDATED |
| A-02 | At least 3 distinct agent services | HIGH | UNVALIDATED |
| A-03 | MLflow + Qdrant in use | MEDIUM | UNVALIDATED |
| A-04 | HashiCorp Vault for credential mgmt | MEDIUM | UNVALIDATED |
| A-05 | MCP exposes aws_cli_exec, snow_create_ticket, datadog_query | HIGH | UNVALIDATED |
| A-06 | RAG pipeline backed by Qdrant | MEDIUM | UNVALIDATED |
| A-07 | Qdrant unauthenticated within cluster | LOW | UNVALIDATED |
| A-08 | MCP Server has AWS credential access via Vault | MEDIUM | UNVALIDATED |

---

### 10.1.3 Phase 2 — Active Reconnaissance

**Network sweep reveals 9 services:**

| IP | Port | Service |
|----|------|---------|
| 10.10.50.10 | 9000 | Nexus Orchestrator API v2.1 |
| 10.10.50.11 | 9001 | Nexus Triage Agent |
| 10.10.50.12 | 9002 | Nexus Remediation Agent |
| 10.10.50.13 | 9003 | Nexus Security Agent |
| 10.10.50.14 | 9004 | Nexus Knowledge Agent |
| 10.10.50.15 | 9005 | Nexus MCP Server JSON-RPC |
| 10.10.50.20 | 6333 | Qdrant REST API 1.7.4 |
| 10.10.50.21 | 5000 | MLflow Tracking Server 2.9.2 |
| 10.10.50.22 | 8200 | Vault 1.15.4 (unsealed) |

**Register updates after Phase 2:** A-01→VALIDATED, A-02→VALIDATED (4 agents, not 3), A-03→VALIDATED, A-04→VALIDATED.

**Key Phase 2 finding — Qdrant unauthenticated (A-07 VALIDATED):**

```bash
curl -s http://10.10.50.20:6333/collections | jq '.result.collections[].name'
# operational_knowledge
# detection_rules
# incident_history
# runbook_corpus
```

**Key Phase 2 finding — fourth MCP tool discovered:**

```bash
curl -s http://10.10.50.15:9005/tools | jq '.tools[] | {name, description}'
# aws_cli_exec, snow_create_ticket, datadog_query — known from OSINT
# vault_rotate_secret — NEW: write access to Vault, not just read
```

**New hypothesis A-10:** MCP Server's Vault AppRole has write access to secrets (HIGH confidence).

**Kubernetes secret extraction:**

```bash
kubectl --token=$K8S_TOKEN get secrets -n nexus-ai \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
# nexus-triage-agent-token
# nexus-remediation-agent-token
# nexus-security-agent-token
# nexus-knowledge-agent-token
# nexus-mcp-vault-approle

kubectl --token=$K8S_TOKEN get secret nexus-triage-agent-token -n nexus-ai \
  -o jsonpath='{.data.token}' | base64 -d
# JWT with agent identity + tool scope claims
```

**K8s secret note:** Kubernetes stores secrets as base64 only — NOT encrypted. Grey-box API token with secret read = full credential extraction.

**Tool authorization testing:**

```bash
# Triage Agent token → vault_rotate_secret
curl -s http://10.10.50.15:9005/invoke -X POST \
  -H "Authorization: Bearer TRIAGE_TOKEN" \
  -d '{"tool": "vault_rotate_secret", "params": {"secret_path": "secret/nexus/test_canary"}}'
# {"status": "error", "message": "Agent triage not authorized for tool vault_rotate_secret"}

# Remediation Agent token → vault_rotate_secret
# {"status": "success", "message": "Secret rotated", "new_version": 4}
```

**Two findings from tool auth test:**
1. MCP Server enforces per-agent tool authorization (A-08 original hypothesis of flat model = **INVALIDATED**)
2. Remediation Agent can rotate Vault secrets — write access, not just read

**New hypotheses:**
- A-11: Remediation Agent token authorizes `vault_rotate_secret` — VALIDATED (used test_canary path)
- A-12b: Remediation Agent token also authorizes `aws_cli_exec` — UNVALIDATED, MEDIUM confidence (deliberate hold to limit detection)
- A-12c: Vault sees only MCP Server identity (AppRole), not the requesting agent — UNVALIDATED (audit trail collapses at TB-5)

---

### 10.1.5 Crown Jewel Analysis

**Ranking by offensive value (at Day 3):**

| Rank | Asset | Location | Access Status | Confidence |
|------|-------|----------|--------------|------------|
| 1 | AWS credentials | Vault → MCP Server | Behind 3 boundaries | HIGH |
| 2 | Detection rules | Qdrant detection_rules | Obtainable now (unauthenticated) | HIGH |
| 3 | Runbook corpus | Qdrant runbook_corpus | Obtainable now | HIGH |
| 4 | Agent identity tokens | K8s secrets | **Already obtained** | MEDIUM |
| 5 | Model weights | MLflow :5000 | Access not yet validated | MEDIUM |
| 6 | MCP tool schemas | MCP Server :9005 | **Already obtained** | HIGH |

**Critical insight:** CJs #2, #3, #6 are immediately accessible. CJ #4 already in hand. Start extracting now, don't delay.

**Staging Qdrant note:** Port :16333 — RoE permits reads AND writes to staging. Staging databases often contain dev artifacts, test configs, draft runbooks scrubbed from production. Read it for intelligence before using it as a poisoning vector.

---

### 10.1.6 MITRE ATLAS Mapping

| Component | Technique | ID | Viability |
|-----------|-----------|-----|-----------|
| Vector DB (Qdrant) | Exfiltration via Cyber Means | AML.T0025 | Immediate — unauthenticated read confirmed |
| Vector DB staging | Poison Training Data | AML.T0020 | Staging only per RoE |
| MCP Server | Data from AI Services | AML.T0085 | Valid agent token in hand |
| Agent endpoints | Inference API Access | AML.T0040 | Immediate — HTTP endpoints respond |
| MLflow registry | AI Supply Chain Compromise | AML.T0010 | Pending auth validation |
| Model weights | ML Model Access | AML.T0044 | Pending access validation |
| Triage Agent input | Craft Adversarial Data | AML.T0043 | Pending webhook auth status |

**Rule:** Techniques tagged "applicable if" stay out of the active plan until preconditions are confirmed HIGH confidence.

---

### 10.1.7 Phase 3 — Intelligence Extraction (Detection Rules)

```bash
curl -s http://10.10.50.20:6333/collections/detection_rules/points/scroll \
  -X POST -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_payload": true, "with_vector": false}' | \
  jq '.result.points[].payload.rule_name'
# nexus-mcp-001: Unusual MCP tool invocation pattern
# nexus-mcp-002: vault_rotate_secret called outside maintenance window
# nexus-agent-003: Agent-to-agent direct communication (bypass orchestrator)
# nexus-qdrant-004: Bulk vector read from non-agent source IP
# nexus-aws-005: AWS IAM modification outside change window
```

**Intelligence-derived constraints:**

| Rule | Operational Impact |
|------|--------------------|
| nexus-mcp-002 | `vault_rotate_secret` must be called during maintenance window |
| nexus-qdrant-004 | Our extraction from 10.10.40.2 may have already triggered an alert |
| nexus-agent-003 | Direct agent-to-agent attacks are monitored; route through Orchestrator |
| nexus-aws-005 | AWS IAM modifications flagged outside change window |

**New hypothesis A-15:** No detection rule covers MCP tool parameter content — UNVALIDATED, MEDIUM confidence (only 5 rules seen; others may exist).

---

## 10.2 — Trust Zones, Escalation Paths, and Engagement Planning

### 10.2.1 Trust Boundaries

**Two categories of trust boundary in AI systems:**
1. **Policy-enforced:** Token authentication, mTLS, API gateway — rejects invalid credentials
2. **Inference-based:** LLM classification, RAG advisory trust, agent judgment — exploitable via input manipulation, not auth bypass

**Nexus AI trust boundaries (TBs):**

| ID | From → To | Type | Enforcement | Status | Exploit Implication |
|----|-----------|------|-------------|--------|---------------------|
| TB-1 | Alert Sources → Orchestrator | Input trust | Webhook auth (unknown) | UNVALIDATED | If unauth'd, untrusted input enters pipeline directly |
| TB-2 | Orchestrator → Agents | Delegation trust | Internal mTLS | VALIDATED | Agents execute whatever Orchestrator dispatches |
| TB-3 | Agents → Vector DB | Data integrity trust | None (unauthenticated) | VALIDATED | Agents treat Qdrant content as ground truth |
| TB-4 | Agents → MCP Server | Tool invocation trust | Per-agent identity tokens | VALIDATED | Token scoping limits tools; parameters unvalidated (A-15) |
| TB-5 | MCP Server → Vault | Credential trust | AppRole auth (MCP identity only) | INFERRED | Agent identity collapses here — Vault sees only MCP identity |
| TB-6 | MCP Server → External APIs | Infrastructure trust | API keys from Vault | INFERRED | No additional auth gate once credentials retrieved |
| TB-7 | Triage Agent → Orchestrator | Classification trust | None — inference-based | UNVALIDATED | Manipulated classification drives entire downstream workflow |
| TB-8 | Knowledge Agent → Other Agents | Advisory trust | None | INFERRED | Agents incorporate RAG responses without verification |

**Key distinction:** TB-5 identity collapse means stolen agent tokens used via MCP won't appear as agent activity in Vault audit logs — only MCP Server AppRole identity visible.

---

### 10.2.3 Escalation Paths

#### Path 1 — Remediation Agent Token → Direct MCP Abuse (PRIMARY)

```
Kubernetes secrets (grey-box K8s token)
    → Extract Remediation Agent JWT
    → POST /invoke vault_rotate_secret (validated)
    → POST /invoke aws_cli_exec (A-12b unvalidated)
    → AWS credentials
    → Infrastructure access
```

**Boundaries crossed:** TB-4 → TB-5 → TB-6

**Go/No-Go gates:**
- A-12b must hold (Remediation token authorizes `aws_cli_exec`)
- A-15 must hold (MCP parameters not monitored) OR command avoids nexus-aws-005 patterns

**Time pressure:** MCP invocations must be reported to Blue Team within 24 hours. All post-exploitation from AWS credentials must complete before Blue Team rotates them.

**Detection risk:** LOW if A-15 holds + executed during business hours

**ATLAS:** AML.T0085 | **ATT&CK:** T1078.004, T1059.004

#### Path 2 — Staging Vector Poisoning → Indirect Remediation Influence

```
Staging Qdrant :16333 (RoE permits writes)
    → Craft runbook entries matching Remediation Agent query patterns
    → Knowledge Agent queries staging (MUST VALIDATE FIRST)
    → Remediation Agent retrieves poisoned runbook via Knowledge Agent
    → Remediation Agent calls vault_rotate_secret / aws_cli_exec with attacker params
    → AWS credentials
```

**Boundaries crossed:** TB-3(staging) → TB-8 → TB-4 → TB-5 → TB-6

**Critical precondition (hard gate):** Does the Knowledge Agent ever query :16333? If NO → Path 2 dead immediately.

**Advantage:** Agent generates the malicious parameters itself → A-15 irrelevant (agent-generated params match normal patterns even if monitored).

**Targeting precision:** Poisoned content must match Remediation Agent query patterns specifically. If Triage/Security Agent retrieves it instead, wrong token is used → path fails + Blue Team alerted.

**ATLAS:** AML.T0020 (staging Qdrant only per RoE)

#### Path 3 — Intelligence Extraction (SUPPORT — EXECUTE FIRST)

```
Unauthenticated Qdrant :6333
    → Extract detection_rules (operational security intelligence)
    → Extract runbook_corpus (infrastructure topology, known vulnerabilities)
    → Extract operational_knowledge (platform behavior)
    → Extract incident_history (past incidents = attack patterns)
```

**Boundaries crossed:** TB-3

**Status:** GO immediately — highest priority

**Detection risk:** MEDIUM — nexus-qdrant-004 fires on non-agent IP reads. Accept risk; intelligence value outweighs cost.

**ATLAS:** AML.T0025

---

### 10.2.4 Decision Under Uncertainty — Day 3 Matrix

| Decision | Information Available | Missing | Decision |
|----------|-----------------------|---------|----------|
| Execute Path 3 | Qdrant accessible, rule known | Complete rule set unknown | **GO** (accept detection risk) |
| Validate A-12b | Token works for vault_rotate_secret | aws_cli_exec not tested | **GO** (starts 24hr reporting clock) |
| Validate A-15 | 5 rules extracted, none cover params | May be additional rules | **GO** |
| Validate Path 2 step 2 | Staging Qdrant exists | Knowledge Agent routing unknown | **GO** (traffic observation) |
| Execute Path 1 | Remediation token in hand | A-12b, A-15 unvalidated | **HOLD** |
| Execute Path 2 | RoE permits staging writes | Step 2 unvalidated | **HOLD** |

**Optimal sequence:** Path 3 → validate A-12b → validate A-15 → validate Path 2 precondition → execute best-validated path.

---

### 10.2.5 The Attack Intelligence Brief

**Brief structure:**
1. **Target Summary** — components, environment, architecture confidence
2. **Crown Jewels** — ranked, with access status
3. **Assumption Register Status** — total/validated/unvalidated/invalidated counts + critical unvalidated items
4. **Scope Constraints** — RoE hard blocks + operational requirements
5. **Escalation Paths** — each path with status, priority, boundaries, crown jewels, detection risk, ATLAS/ATT&CK IDs
6. **Next Actions** — numbered, day-specific

**Brief is versioned:** Each version = a decision log entry. By engagement end, the version history documents every assumption formed, tested, resolved, and every decision made with incomplete information.

---

### 10.2.6 When Paths Close and New Ones Open

**Example — Path 2 fails (Knowledge Agent queries production only):**

```
Failed validation reveals: Knowledge Agent query routing is configurable
    → New hypothesis A-16: Qdrant endpoint stored in ConfigMap/env var
    → New path: foothold in Zone C → modify Knowledge Agent config → point to staging
    → Path 2 becomes viable again
```

**Example — A-15 invalidated (parameters ARE monitored):**

```
nexus-mcp-006 detected: aws iam commands in aws_cli_exec flagged
    → Path 1 constrained, not eliminated
    → Find aws_cli_exec command that achieves persistence without IAM modification
    → aws ssm send-command (Systems Manager) = code execution without IAM-specific detection
```

**Key mindset:** The engagement plan is a decision tree, not a script. Invalidated assumptions generate new hypotheses, not dead ends.

---

## 10.3 — Key Exam Distinctions

| Concept | Detail |
|---------|--------|
| Assumption register | Observation → Hypothesis → Confidence → Source → Status |
| LOW confidence | Absence of evidence ≠ confirmation; verify early, don't plan attacks on it |
| INVALIDATED assumptions | Generate new hypotheses; the engagement continues |
| Policy-enforced vs inference-based trust | Policy = auth token; inference = LLM classification — exploit via input manipulation |
| TB-5 identity collapse | Vault sees MCP AppRole only, not agent identity — reduces attribution at Vault layer |
| RoE as hard constraint | Not "if client approves later" — remove blocked paths from execution plan immediately |
| Production vs staging Qdrant | Reads allowed from both; writes (poisoning) ONLY on staging (:16333) per RoE |
| 24-hour MCP reporting | Starts when first tool invoked; post-exploitation window is 24hrs before Blue Team acts |
| nexus-mcp-002 | vault_rotate_secret monitored outside maintenance window → time your invocations |
| nexus-qdrant-004 | Bulk reads from non-agent IPs flagged → route later queries through agent pod if possible |
| nexus-agent-003 | Direct agent-to-agent = detected; route through Orchestrator instead |
| A-15 (param monitoring gap) | If holds → Path 1 low risk; if invalidated → constrain command, not abandon path |
| K8s secrets encoding | base64 ONLY, not encrypted → grey-box API token = full credential extraction |
| Crown jewel re-ranking | Re-rank as new intelligence arrives; marginal Phase 1 assets may become primary Phase 3 targets |
| Version history of brief | Decision log — documents how team navigated uncertainty, not just what they found |
