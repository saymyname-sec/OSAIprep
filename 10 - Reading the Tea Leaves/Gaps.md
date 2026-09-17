# Module 10 — Threat Modeling for AI-Enabled Targets: Gaps & Resolutions

## Purpose
Track knowledge gaps identified during study, their resolution status, and residual open items.

---

## Primary Gaps — All Resolved ✅

### 1. Assumption Register Methodology
**Gap:** How to structure and maintain assumptions during engagement.
**Resolution:** ✅
- Four fields: Observation → Hypothesis → Confidence → Source → Status
- Confidence = source reliability (not probability): HIGH = validated/technical, MEDIUM = inferred/indirect, LOW = speculation/OSINT-only
- Status lifecycle: UNVALIDATED → VALIDATED or INVALIDATED
- LOW confidence ≠ vulnerability confirmed; must escalate before acting
- INVALIDATED assumptions generate new hypotheses — not dead ends

---

### 2. Phase 1 Pre-Engagement OSINT Workflow
**Gap:** What OSINT to collect and how to structure it before active recon.
**Resolution:** ✅
- GitHub mining: tech stack (Python 3.11, FastAPI, Qdrant, PEFT), K8s manifests (inference-sa, qdrant-client), CI/CD (model-training, rag-pipeline workflows)
- LinkedIn: role patterns confirm AI Red Team, MLOps, LLM Engineer → internal AI infra confirmed
- Job postings: "experience with MCP protocol" → MCP in production; "Vault integration" → secrets management active
- Conference talks: "AI-driven decision automation" → autonomous agents; logging gaps → detection blind spots
- All indicators feed assumption register before first packet sent

---

### 3. Nexus AI Component Inventory
**Gap:** Full service map of the target environment.
**Resolution:** ✅
Nine services documented:

| Service | Port | Protocol | Auth |
|---------|------|----------|------|
| Knowledge Agent | :8001 | HTTP/SSE | Bearer |
| Decision Agent | :8002 | HTTP/SSE | Bearer |
| Orchestrator | :8003 | HTTP | mTLS |
| Qdrant Vector DB | :6333/:6334 | HTTP/gRPC | None |
| MCP Server | :8080 | HTTP/SSE | Token |
| Vault | :8200 | HTTPS | AppRole |
| ArgoCD | :8090 | HTTPS | SSO |
| Prometheus | :9090 | HTTP | None |
| Grafana | :3000 | HTTP | Basic |

---

### 4. Qdrant Unauthenticated Access Validation
**Gap:** How to confirm and exploit unauthenticated Qdrant access.
**Resolution:** ✅
```bash
# Validate no auth required
curl http://qdrant:6333/collections
# Returns collection list without token

# Extract vector data
curl -X POST http://qdrant:6333/collections/knowledge_base/points/scroll \
  -H 'Content-Type: application/json' \
  -d '{"limit": 100, "with_payload": true}'

# Staging Qdrant (permitted per RoE)
curl http://qdrant-staging:16333/collections
```

---

### 5. MCP Tool Enumeration
**Gap:** How to enumerate available MCP tools and their capabilities.
**Resolution:** ✅
```bash
# List available tools
curl http://mcp-server:8080/tools/list \
  -H "Authorization: Bearer $MCP_TOKEN"

# Tools confirmed: query_knowledge, execute_query, vault_read_secret,
#                  vault_write_secret, k8s_exec, schedule_task

# Test tool invocation
curl -X POST http://mcp-server:8080/tools/call \
  -H "Authorization: Bearer $MCP_TOKEN" \
  -d '{"tool": "query_knowledge", "arguments": {"query": "test"}}'
```

---

### 6. Trust Boundary Framework (TB-1 through TB-8)
**Gap:** How to enumerate and classify trust boundaries in AI systems.
**Resolution:** ✅
Eight trust boundaries for Nexus AI:

| TB | Name | Type | Exploit |
|----|------|------|---------|
| TB-1 | External → Knowledge Agent | Policy-enforced | Token theft/replay |
| TB-2 | Knowledge Agent → Qdrant | Inference-based | Semantic manipulation |
| TB-3 | Knowledge Agent → MCP | Policy-enforced | Token extraction |
| TB-4 | Decision Agent → External APIs | Policy-enforced | SSRF via agent |
| TB-5 | MCP → Vault | Policy-enforced (collapsed) | AppRole = agent identity |
| TB-6 | MCP → K8s | Policy-enforced | Stolen kubeconfig |
| TB-7 | Orchestrator → Agents | Policy-enforced | mTLS cert theft |
| TB-8 | Staging → Production | Policy-enforced | Read/write permitted (RoE) |

**Key insight:** Two boundary types: policy-enforced (cryptographic auth) vs inference-based (LLM semantic classification — exploit via input manipulation).

---

### 7. TB-5 Identity Collapse
**Gap:** Why TB-5 is particularly significant for privilege escalation.
**Resolution:** ✅
- Vault sees MCP AppRole credentials, not the originating agent's identity
- Any agent that can invoke MCP tools gets Vault access under the same AppRole
- This collapses all agent identities into one Vault principal
- Result: stealing any agent's MCP token grants full Vault access regardless of which agent it was

---

### 8. Crown Jewel Ranking and Re-Ranking
**Gap:** How to prioritize targets and update ranking as intelligence arrives.
**Resolution:** ✅
Initial ranking:
1. Production model weights (Decision Agent)
2. Customer PII in Qdrant
3. Vault secrets (production DB credentials)
4. K8s cluster credentials
5. ArgoCD pipeline access
6. Prometheus metrics (operational intel)

Post-recon re-ranking:
- #4 already in hand (K8s secrets from kubeconfig)
- #2/#3/#6 immediately obtainable (Qdrant unauth, Vault via MCP token, Prometheus unauth)
- Crown jewels evolve as intelligence arrives; update brief on each phase transition

---

### 9. Three Escalation Paths
**Gap:** How escalation paths are structured and prioritized.
**Resolution:** ✅

**Path 1 — Token Theft → Direct MCP (PRIMARY)**
- Gate: Confirm MCP token in K8s secret or Qdrant payload
- Steps: Extract token → Enumerate MCP tools → Invoke vault_read_secret → Access production secrets
- Advantage: Direct, no staging interaction, lower detection surface

**Path 2 — Staging Poisoning → Indirect MCP (ALTERNATE)**
- Gate: Validate Knowledge Agent queries staging Qdrant (:16333) before committing
- Steps: Poison staging vectors → Wait for Knowledge Agent query → Exfiltrate via poisoned response
- Hard gate: Must confirm routing before poisoning — do not assume
- Risk: Timing dependency; detection via Prometheus anomaly

**Path 3 — Intelligence Extraction (SUPPORT — execute first)**
- Always execute before committing to Path 1 or 2
- Extract: agent system prompts, tool schemas, model versions, detection rule thresholds
- Intelligence from Path 3 feeds go/no-go gates for Paths 1 and 2

---

### 10. Go/No-Go Gates
**Gap:** What specific conditions must be met before executing each path.
**Resolution:** ✅
Path 1 gates:
- [ ] MCP token confirmed in K8s secret (kubectl get secret)
- [ ] Token not expired (test invocation returns 200)
- [ ] vault_read_secret tool confirmed available

Path 2 gates:
- [ ] Staging Qdrant confirmed reachable on :16333
- [ ] Knowledge Agent query routing to staging confirmed (traffic analysis or log)
- [ ] Vector payload format confirmed (test insert accepted)

---

### 11. MITRE ATLAS Mapping
**Gap:** How to map attack techniques to ATLAS framework for reporting.
**Resolution:** ✅

| ATLAS Technique | ID | Nexus AI Application | Condition |
|-----------------|----|---------------------|-----------|
| Discover ML Artifacts | AML.T0007 | Qdrant collection enumeration | Auth = None confirmed |
| ML Supply Chain Compromise | AML.T0010 | Staging vector poisoning | Routing to staging confirmed |
| Exfiltration via ML Inference | AML.T0057 | Knowledge Agent response manipulation | Vector injection succeeds |
| Discover ML Model Ontology | AML.T0013 | System prompt extraction via MCP | Tool access confirmed |
| Craft Adversarial Data | AML.T0020 | RAG context injection | Vector format confirmed |

Techniques remain "applicable if" until preconditions reach HIGH confidence.

---

### 12. Detection Rules Extraction
**Gap:** How to extract and use detection rules defensively (and offensively).
**Resolution:** ✅
Five rules identified from Prometheus/Grafana:

| Rule ID | Name | Threshold | Evasion |
|---------|------|-----------|---------|
| nexus-mcp-001 | High MCP invocation rate | >50/min | Stay <40/min |
| nexus-mcp-002 | Vault access spike | >10 unique secrets/hr | Batch reads, stay <8/hr |
| nexus-agent-003 | Agent query anomaly | Z-score >3 on embedding distance | Use semantically close queries |
| nexus-qdrant-004 | Qdrant scroll volume | >1000 vectors/query | Paginate, max 100/request |
| nexus-aws-005 | Cross-service API spike | >20 calls/min | Spread calls across 2+ minutes |

---

### 13. A-15 Parameter Monitoring Hypothesis
**Gap:** How to handle assumptions about attack surfaces not yet validated.
**Resolution:** ✅
- A-15: "Prometheus exposes model performance parameters useful for inference about decision thresholds"
- Confidence: MEDIUM (Prometheus confirmed accessible; parameter content unvalidated)
- Action: Validate during Path 3 intelligence extraction
- Constraint: Cannot exceed nexus-mcp-001/002 thresholds while enumerating
- Exemplifies constraint-aware replanning: adjust operation when assumption touches detection boundary

---

### 14. Iterative Replanning Examples
**Gap:** How to handle plan invalidation during engagement.
**Resolution:** ✅

**Example 1 — Staging routing not confirmed:**
- Original plan: Poison staging vectors (Path 2)
- Discovery: Cannot confirm Knowledge Agent queries :16333 (routing unverified)
- Replan: Execute Path 1 first; defer Path 2 until routing confirmed
- New hypothesis: "Routing confirmed via agent response delta after controlled vector insert"

**Example 2 — Parameter monitoring constraint:**
- Original plan: Enumerate all Prometheus metrics
- Discovery: nexus-aws-005 fires if >20 API calls/min; Prometheus scrape interval = 15s
- Replan: Spread enumeration over 3-minute window; prioritize metrics related to Decision Agent thresholds
- Result: No detection; parameter map obtained

---

### 15. Attack Intelligence Brief Structure
**Gap:** How to structure the living document that guides the engagement.
**Resolution:** ✅
Required sections:
1. **Version history** — decision log; every structural change documented
2. **Current intelligence** — validated assumptions, confirmed capabilities
3. **Crown jewels** — ranked by value × accessibility; updated each phase
4. **Active hypotheses** — with confidence ratings
5. **Escalation paths** — active path highlighted; go/no-go gate status
6. **ATLAS map** — techniques mapped to confirmed or pending preconditions
7. **Detection awareness** — known rules, thresholds, evasion notes
8. **RoE hard constraints** — visible on every read, not buried

---

### 16. RoE Hard Constraints
**Gap:** What constraints are absolute vs advisory.
**Resolution:** ✅
Absolute (cannot be overridden):
- No production Qdrant writes (:6333 read-only)
- Staging (:16333) reads and writes permitted
- All MCP invocations reported to Blue Team within 24 hours
- No DoS or availability impact on any service

Advisory (guideline):
- Prefer Path 3 before Path 1/2
- Log all tool invocations with timestamps
- Snapshot state before each phase transition

---

### 17. Day 3 Decision Matrix
**Gap:** How to make go/no-go decisions at phase transitions.
**Resolution:** ✅

| Condition | Action |
|-----------|--------|
| Path 1 token confirmed + vault_read_secret available | Execute Path 1 |
| Path 2 staging routing confirmed | Begin vector crafting |
| Neither path gated | Extend Path 3; revisit assumptions |
| RoE constraint triggered | Stop, document, notify Blue Team |
| Detection rule threshold approached | Back off, replan timing |

---

## Minor Open Items

| # | Item | Status |
|---|------|--------|
| 1 | Exact capstone lab flag values for Module 10 | Pending lab completion |
| 2 | Specific maintenance window times for Nexus AI staging | Lab environment only |
| 3 | Prometheus metric names for Decision Agent threshold parameters | Validate in lab |

---

## Summary

All 17 conceptual gaps resolved. Module 10 coverage complete across:
- Assumption register methodology and lifecycle
- Pre-engagement OSINT indicators and Phase 1 workflow
- Nexus AI 9-service component map
- Trust boundary framework (TB-1 through TB-8) with exploit vectors
- Crown jewel ranking and re-ranking protocol
- Three escalation paths with go/no-go gates
- MITRE ATLAS mapping with precondition tracking
- Detection rules extraction and evasion thresholds
- Iterative replanning with concrete examples
- Attack intelligence brief structure
- RoE hard constraints (absolute vs advisory)
