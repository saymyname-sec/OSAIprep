# Module 10 — Glossary

## Threat Modeling Terms

**Assumption Register:** Structured document tracking every hypothesis about the target system. Fields: ID, Observation, Hypothesis, Confidence (LOW/MEDIUM/HIGH), Source, Status (UNVALIDATED/VALIDATED/INVALIDATED). Updated after every recon action.

**VALIDATED:** Assumption status after active evidence confirms the hypothesis. OSINT alone cannot VALIDATE — requires active verification.

**INVALIDATED:** Assumption status when evidence disproves the hypothesis. Invalidation is not failure — it produces more accurate intelligence and triggers new hypotheses.

**UNVALIDATED:** Default status for all assumptions until actively confirmed. OSINT starts MEDIUM confidence, UNVALIDATED.

**Confidence Level:** Estimate of how likely an assumption is to be correct before validation. LOW = weak evidence or absence of evidence; MEDIUM = reasonable OSINT support; HIGH = multiple corroborating sources. Confidence ≠ Status.

**Trust Boundary (TB):** A defined line between components where authentication, authorization, or trust changes. Numbered TB-1 through TB-N for each engagement. Exploitable boundaries are where attacks cross from one component to another.

**Crown Jewel:** High-value offensive asset ranked by impact, access proximity, and trust boundary depth. Crown jewel ranking drives prioritisation of attack paths.

**Attack Path:** A sequence of steps from initial access to a crown jewel, crossing one or more trust boundaries. Documented as TB-N → action → TB-M → action → asset.

**OPSEC Noise Level:** Subjective measure of how detectable an action is. Factors: which detection rules trigger, volume of events generated, whether the action is within expected agent behavior. Ratings: LOW (expected behavior), MEDIUM (possible alert), HIGH (likely alert).

**Maintenance Window:** A scheduled period during which normally-monitored operations (e.g., secret rotation) are permitted. Exploitation of maintenance windows is a timing-based evasion technique. (`nexus-mcp-002`: `vault_rotate_secret` outside window = HIGH severity alert.)

## MITRE ATLAS Terms

**MITRE ATLAS (Adversarial Threat Landscape for Artificial-Intelligence Systems):** A knowledge base of adversary techniques targeting ML/AI systems. Analogous to MITRE ATT&CK but AI-specific. Technique IDs prefixed `AML.T`.

**AML.T0010 — AI Supply Chain Compromise:** Poisoning or replacing model artifacts in a registry (MLflow, HuggingFace Hub) before they are loaded by a target system.

**AML.T0020 — Poison Training Data:** Injecting malicious data into a training or fine-tuning dataset to corrupt model behavior. In Nexus: staging Qdrant write → Knowledge Agent RAG poisoning.

**AML.T0025 — Exfiltration via Cyber Means:** Extracting ML-related data (training data, embeddings, detection rules, runbooks) via standard network channels. In Nexus: Qdrant scroll API (unauthenticated).

**AML.T0040 — Inference API Access:** Direct access to an AI model's inference endpoint, bypassing intended access controls. In Nexus: agent HTTP endpoints reachable from attack host.

**AML.T0043 — Craft Adversarial Data:** Creating inputs designed to cause misclassification or incorrect model output. In Nexus: alert injection via TB-1 (if unauthenticated).

**AML.T0044 — ML Model Access:** Obtaining access to model weights, parameters, or architecture. In Nexus: MLflow artifact download (auth status unvalidated in labs).

**AML.T0085 — Data from AI Services:** Using legitimate AI service APIs to extract sensitive information. In Nexus: MCP tool invocation (`aws_cli_exec`) with stolen remediation agent JWT.

## Nexus AI Component Terms

**Nexus Orchestrator:** Central routing component (10.10.50.10:9000, mTLS). All agent-to-agent communication must pass through it. Direct agent-to-agent bypasses Orchestrator = HIGH noise (`nexus-agent-003`).

**MCP Server (Nexus):** Tool execution gateway (10.10.50.15:9005). Exposes tools: `vault_rotate_secret`, `aws_cli_exec`, `snow_create_ticket`, `datadog_query`. Per-agent JWT authorization. AppRole-authenticated to Vault.

**Vault AppRole:** HashiCorp Vault authentication method using a `role_id` + `secret_id` pair. In Nexus: stored as K8s secret `nexus-mcp-vault-approle` — direct Vault access bypassing MCP (TB-4/TB-5).

**Agent JWT Scope Claim:** JSON field in agent bearer tokens listing which MCP tools that agent is authorized to invoke. Key field: `"scope": ["vault_rotate_secret", ...]`. Decode with `base64 -d` to enumerate per-agent permissions.

**Staging Qdrant (:16333):** Secondary Qdrant instance used by Knowledge Agent for pre-production vector updates. No authentication. Write permitted per RoE. Entry point for AML.T0020 (RAG poisoning).

**Detection Rule (Nexus):** JSON-structured monitoring policies stored in Qdrant `detection_rules` collection. Read by the red team to enumerate monitoring gaps before taking high-noise actions. Key rules: `nexus-mcp-002` (vault rotation timing), `nexus-qdrant-004` (bulk read from non-agent IP), `nexus-agent-003` (direct agent comms).
