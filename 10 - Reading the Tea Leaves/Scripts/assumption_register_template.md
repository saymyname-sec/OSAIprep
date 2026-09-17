# Assumption Register Template — AI Threat Modeling

## Format

Each row: `ID | Observation | Hypothesis | Confidence | Source | Status`

- **Confidence:** LOW / MEDIUM / HIGH
- **Source:** OSINT / Active / Grey-box / Blue-team-intel
- **Status:** UNVALIDATED / VALIDATED / INVALIDATED

---

## Register

| ID | Observation | Hypothesis | Confidence | Source | Status | Validation Evidence |
|----|-------------|------------|------------|--------|--------|---------------------|
| A-01 | LinkedIn: MLflow, Qdrant, K8s mentioned | Target uses MLflow+Qdrant+K8s stack | MEDIUM | OSINT | VALIDATED | nmap confirmed services |
| A-02 | LinkedIn: 3 agent types listed | 3 agents in deployment | MEDIUM | OSINT | INVALIDATED → 4 agents | nmap found 4 agent ports |
| A-03 | LinkedIn: Vault mentioned | HashiCorp Vault in use | MEDIUM | OSINT | VALIDATED | nmap port 8200 |
| A-04 | LinkedIn: MCP integrations mentioned | MCP server present | MEDIUM | OSINT | VALIDATED | nmap port 9005 |
| A-05 | GitHub README: aws_cli_exec, snow_create_ticket, datadog_query | MCP exposes these 3 tools | MEDIUM | OSINT | VALIDATED (partially) | /tools confirmed + vault_rotate_secret discovered |
| A-06 | Client kickoff: agents communicate via Orchestrator | mTLS between agents and Orchestrator | LOW | Grey-box | VALIDATED | nmap ssl-cert on 9000-9005 |
| A-07 | Client docs don't mention Qdrant auth | Qdrant may be unauthenticated | LOW | OSINT (absence) | VALIDATED | HTTP 200 with no auth on /collections |
| A-08 | Multiple agent types listed | Flat credential model — same token for all tools | LOW | Inference | INVALIDATED | Triage token rejected for vault_rotate_secret |
| A-09 | 4th agent found (Knowledge Agent) | Knowledge Agent is standalone RAG service | NEW | Active | VALIDATED | Port 9004, separate IP |
| A-10 | vault_rotate_secret found in /tools | Remediation agent can rotate Vault secrets | MEDIUM | Active | VALIDATED | Remediation JWT scope confirmed |
| A-11 | K8s secret list includes remediation token | Remediation agent token accessible via K8s | MEDIUM | Active | VALIDATED | kubectl get secret succeeded |
| A-12 | Detection rule nexus-mcp-002 extracted | vault_rotate_secret blocked outside maintenance window | HIGH | Blue-team-intel | VALIDATED | Rule payload specifies window constraint |
| A-13 | Detection rule nexus-qdrant-004 extracted | Bulk Qdrant read from non-agent IP triggers alert | HIGH | Blue-team-intel | VALIDATED | Rule payload specifies source IP check |
| A-14 | Detection rule nexus-agent-003 extracted | Direct agent-to-agent comms flagged | HIGH | Blue-team-intel | VALIDATED | Rule payload specifies routing requirement |
| A-15 | No parameter monitoring rule found in 5 extracted rules | MCP parameter content not monitored | MEDIUM | Blue-team-intel (absence) | UNVALIDATED | Rule set may be incomplete |

---

## Update Log

| Date | Event | Assumptions Updated |
|------|-------|---------------------|
| Day 1 | OSINT phase complete | A-01 through A-08 created |
| Day 2 | nmap complete | A-02 INVALIDATED, A-09 added, A-01/A-03/A-04/A-06 VALIDATED |
| Day 2 | MCP /tools enumerated | A-05 VALIDATED (partially), A-10 added |
| Day 2 | Qdrant /collections enumerated | A-07 VALIDATED |
| Day 2 | Triage token tested | A-08 INVALIDATED |
| Day 2 | K8s secrets enumerated | A-11 VALIDATED |
| Day 2 | Detection rules extracted | A-12, A-13, A-14 VALIDATED; A-15 added |

---

## Notes
- OSINT entries start MEDIUM confidence, UNVALIDATED — never VALIDATED until actively confirmed
- LOW confidence entries (especially absence-of-evidence like A-07) get validated early
- INVALIDATED entries generate new hypotheses (A-08 → A-10, A-11)
- A-15 remains UNVALIDATED — rule set may be incomplete; treat as hypothesis only
