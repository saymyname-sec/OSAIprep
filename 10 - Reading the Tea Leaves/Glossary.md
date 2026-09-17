# Module 10 — Glossary

**advisory trust** — Trust relationship where a component incorporates outputs from another component (e.g., RAG retrieval results) without independent verification; TB-8 in Nexus AI between Knowledge Agent and other agents.

**AML.T0020** — MITRE ATLAS: Poison Training Data; applicable to staging Qdrant (:16333) per RoE; blocked on production Qdrant.

**AML.T0025** — MITRE ATLAS: Exfiltration via Cyber Means; immediately applicable against unauthenticated Qdrant.

**AML.T0040** — MITRE ATLAS: Inference API Access; applicable against Nexus AI agent HTTP endpoints.

**AML.T0043** — MITRE ATLAS: Craft Adversarial Data; applicable to Triage Agent input manipulation pending TB-1 webhook auth validation.

**AML.T0044** — MITRE ATLAS: ML Model Access; applicable to MLflow model weights pending access validation.

**AML.T0085** — MITRE ATLAS: Data from AI Services; applicable via Remediation Agent token for MCP tool invocation.

**AppRole** — HashiCorp Vault authentication method using a Role ID and Secret ID pair; used by the Nexus AI MCP Server; collapses agent identity at TB-5 — Vault cannot distinguish which agent triggered a request.

**assumption register** — Structured document tracking every hypothesis about a target: Observation → Hypothesis → Confidence → Source → Status; the backbone of iterative threat modeling.

**attack intelligence brief** — Living document produced during an engagement capturing current knowledge, assumption register status, scope constraints, escalation paths with go/no-go gates, and next actions; versioned throughout the engagement.

**classification trust** — Inference-based trust boundary where an LLM's output (e.g., alert severity classification) is acted upon without policy verification; TB-7 in Nexus AI.

**confidence level** — Reflects the reliability of the source, NOT the probability of the hypothesis being correct. HIGH = direct client doc or confirmed observation; MEDIUM = indirect inference; LOW = absence of evidence.

**crown jewel** — High-value asset ranked by offensive value given current intelligence; ranking evolves as new information arrives; re-rank whenever architecture understanding changes materially.

**data integrity trust** — Trust relationship where a component treats content from a data store as ground truth without authentication or integrity checks; TB-3 in Nexus AI (agents trust Qdrant content).

**decision log** — The version history of an attack intelligence brief; documents every assumption formed/tested/resolved and every decision made with incomplete information; as valuable as final deliverables for demonstrating engagement reasoning.

**delegation trust** — Trust relationship where a component executes whatever instructions are dispatched by another component; TB-2 in Nexus AI (agents execute Orchestrator dispatches).

**detection rules** — Crown jewel #2 in Nexus AI; stored unauthenticated in Qdrant `detection_rules` collection; reveals defender monitoring patterns, timing constraints, and evasion opportunities.

**go/no-go gate** — Explicit precondition that must be validated before committing resources to an escalation path; unvalidated gates block path execution even if all other conditions are met.

**identity collapse** — Phenomenon at TB-5 where Vault's AppRole authentication records only the MCP Server's identity, not the agent whose token triggered the request; reduces attribution risk for stolen agent tokens.

**inference-based trust boundary** — Trust boundary enforced by LLM inference rather than policy; exploitable via input manipulation (prompt injection, poisoned RAG content) rather than authentication bypass.

**iterative threat model** — Threat model that evolves with each intelligence collection phase; assumptions are promoted (VALIDATED), demoted (INVALIDATED), or adjusted as new evidence arrives.

**Knowledge Agent** — Nexus AI agent (port 9004) that serves RAG queries to other agents; queries Qdrant for runbooks and operational knowledge; controls TB-8 advisory trust.

**maintenance window** — Time period during which `vault_rotate_secret` calls are expected; calls outside this window trigger nexus-mcp-002 detection rule.

**MCP Server** — Nexus AI component (port 9005) exposing tools: `aws_cli_exec`, `snow_create_ticket`, `datadog_query`, `vault_rotate_secret`; enforces per-agent tool authorization via JWT scope claims.

**nexus-agent-003** — Detection rule flagging direct agent-to-agent communication bypassing the Orchestrator; forces attacks to route through the Orchestrator to avoid detection.

**nexus-aws-005** — Detection rule flagging AWS IAM modifications outside change windows; constrains `aws_cli_exec` command selection (avoid IAM commands or use `aws ssm send-command` instead).

**nexus-mcp-002** — Detection rule flagging `vault_rotate_secret` invocations outside maintenance windows; imposes timing constraint on Path 1 execution.

**nexus-qdrant-004** — Detection rule flagging bulk vector reads from non-agent source IPs; triggers when extraction queries originate from attack host (10.10.40.2) rather than an agent pod.

**OSINT indicators (AI/ML stacks)** — LinkedIn job postings (framework names), GitHub fork READMEs (tool names, private repo references), DevOps profiles (Vault, MCP, Kubernetes), error messages/docs (component versions).

**per-agent tool authorization** — MCP Server capability where each agent's JWT token encodes a scope of allowed tools; Remediation Agent can invoke `vault_rotate_secret`; Triage Agent cannot.

**policy-enforced trust boundary** — Trust boundary validated by explicit authentication mechanism (token, mTLS, API key); contrast with inference-based trust boundary.

**production Qdrant** — Qdrant instance at port 6333; unauthenticated; reads permitted by RoE; WRITES (poisoning) PROHIBITED by RoE.

**Remediation Agent** — Nexus AI agent (port 9002) whose token authorizes `vault_rotate_secret` and (unvalidated A-12b) `aws_cli_exec`; key identity for Path 1 execution.

**Rules of Engagement (RoE)** — Hard constraints on engagement execution; not guidelines; blocked paths must be removed from active plan immediately regardless of technical feasibility.

**runbook corpus** — Crown jewel #3 in Nexus AI; Qdrant `runbook_corpus` collection; contains operational procedures, infrastructure topology, and known vulnerability patterns; accessible unauthenticated.

**staging Qdrant** — Qdrant instance at port 16333; unauthenticated; both reads and writes permitted by RoE; may contain development artifacts and draft runbooks absent from production; Path 2 vector.

**test_canary** — Synthetic secret path used to validate tool authorization (e.g., `secret/nexus/test_canary`) without touching production secrets; prevents operational impact during reconnaissance.

**threat model** — Living artifact mapping an AI-enabled system's components, trust boundaries, crown jewels, and escalation paths; evolves with every intelligence collection phase.

**trust boundary** — Any point where one component accepts input or instructions from another without independently verifying them; the primary analytical unit of AI threat modeling.

**trust zone** — Region of an architecture where components share a common privilege level; defined by the trust boundaries that partition the system.

**24-hour MCP reporting requirement** — RoE obligation to report all MCP tool invocations to the Blue Team POC within 24 hours of execution; creates a hard post-exploitation window — all activities dependent on retrieved credentials must complete before credential rotation.

**vault_rotate_secret** — MCP tool that writes to HashiCorp Vault, not just reads; discovered as a fourth tool beyond the three visible in public OSINT; indicates MCP Server's Vault AppRole has write access.
