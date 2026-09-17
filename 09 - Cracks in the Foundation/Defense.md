# Module 09 — Defense & Detection

## Defender's Perspective
AI infrastructure attacks exploit the same misconfigurations that plague cloud-native applications, but with higher blast radius: ML pipelines run with broad IAM permissions, model artifacts are pulled from shared registries without integrity checks, and Kubernetes clusters hosting inference workloads often have over-privileged service accounts. Defenders must treat ML infrastructure as Tier 1 — the same rigor as production databases — not as experimental tooling.

---

## Detection Opportunities

### SSRF → Lambda Env Exfil
**What to monitor:** Lambda execution logs for outbound requests to `169.254.169.254` (IMDS), `file://` URIs, or internal RFC-1918 addresses from user-supplied URL parameters.  
**Detection rule:**
```
fields @timestamp, @message
| filter @message like /169\.254\.169\.254|file:\/\/|\/proc\/self/
| sort @timestamp desc
```
**IoCs:** IMDSv1 calls from Lambda functions; `file:///proc/self/environ` in URL parameters; unusual `sts:AssumeRole` calls from Lambda execution role within seconds of Lambda invocation.  
**False positive risk:** Low — no legitimate use case for Lambda fetching IMDS or `/proc/`.  
**Fix:** Enforce IMDSv2 (`HttpTokens: required`); validate/blocklist user-supplied URLs server-side; apply Lambda VPC with no IMDS route.

### AWS IAM Role Chain Escalation
**What to monitor:** CloudTrail `sts:AssumeRole` events, especially chained — same source IP assuming multiple roles in rapid succession. Watch for `sts:GetCallerIdentity` calls (attacker verifying identity at each step).  
**Detection rule:**
```json
{ "eventName": "AssumeRole", "userIdentity.type": "AssumedRole" }
```
Follow with frequency analysis: >3 AssumeRole events from same identity in 5 minutes is suspicious.  
**IoCs:** Role chain deeper than 2 hops; roles being assumed that are not part of documented automation; `GetCallerIdentity` calls with no subsequent service API calls (reconnaissance pattern).  
**False positive risk:** Medium — CI/CD pipelines sometimes chain roles legitimately.

### ML Credential Hunting
**What to monitor:** `ssm:GetParameter` with `--with-decryption`; `ssm:GetParameterHistory`; ECR `docker pull` from unknown IPs; CloudWatch `filter-log-events` queries hitting credential-containing log groups.  
**Detection rule:** Alert on `GetParameterHistory` calls — almost no legitimate workflow needs version history of a live secret.  
**IoCs:** SSM history queries; bulk ECR image pulls outside deployment windows; `logs:FilterLogEvents` with patterns like `password`, `token`, `secret`.  
**False positive risk:** Low for `GetParameterHistory`; medium for ECR pulls (legitimate CI/CD).

### Kubernetes Service Account Token Theft
**What to monitor:** K8s audit log — `get` on `secrets` resources from pods that shouldn't need cross-namespace access; JWT decode showing service account name from unexpected namespace.  
**Detection rule:**
```yaml
# Falco rule
- rule: Unexpected K8s Secret Access
  condition: ka.verb=get and ka.target.resource=secrets and ka.target.namespace != ka.auth.namespace
  output: "Cross-namespace secret access: %ka.user.name accessing %ka.target.namespace"
```
**IoCs:** Service account accessing secrets in a namespace it doesn't own; `kubectl auth can-i --list` calls (enumeration pattern in audit log); `create` on pods from service accounts that should only read.  
**False positive risk:** Low — cross-namespace secret reads are rare in well-segmented clusters.

### Kubernetes Privileged Pod / Node Escape
**What to monitor:** Pod creation with `hostPID: true`, `privileged: true`, or `hostNetwork: true`; `nsenter` execution inside containers.  
**Detection rule:**
```yaml
# Falco
- rule: Privileged Pod Created
  condition: ka.verb=create and ka.target.resource=pods and ka.req.pod.containers.privileged=true
  output: "Privileged pod created by %ka.user.name"
```
**IoCs:** `nsenter` binary execution; `/proc/1/` reads from inside a container; `hostPID` or `privileged` in pod spec; pod creation by a service account that normally only reads.  
**False positive risk:** Low — no ML inference workload requires privileged pods.

### GPU Container Escape (CVE-2025-23266 / LD_PRELOAD)
**What to monitor:** Container image builds with `LD_PRELOAD` env variables set; `.so` files in container images that are not part of the base layer; OCI hook execution anomalies; unexpected writes to `/etc/sudoers.d/`.  
**Detection rule:** Alert on any container image where `LD_PRELOAD` is set AND references a path inside the container filesystem (`/proc/self/cwd/` particularly).  
**IoCs:** `LD_PRELOAD` pointing to `/proc/self/cwd/`; new files in `/etc/sudoers.d/` after container runs; `__attribute__((constructor))` patterns in shared libraries submitted to build pipelines.  
**False positive risk:** Low — `LD_PRELOAD` in ML images is unusual.

### Web Content Injection
**What to monitor:** Scraped web content being passed directly to LLM context without sanitization; unusual instruction patterns in structured data fields (JSON-LD `description`, product metadata, article bodies).  
**Detection rule:** Implement content scanning on RAG-ingested web pages — flag text containing `ignore previous`, `disregard`, `new instructions`, `system:` patterns.  
**IoCs:** LLM outputs that don't match the task domain; unexpected tool calls triggered after web content ingestion; exfiltration URLs appearing in model outputs.  
**False positive risk:** Medium — creative writing or security research content may contain these patterns.

---

## Defensive Controls

| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| IMDSv2 enforcement | SSRF → IMDS credential theft | `HttpTokens: required` on all EC2/Lambda; IMDSv1 completely disabled |
| Least-privilege IAM | Role chain escalation | Each ML role scoped to specific S3 prefixes, not `s3:*`; no `iam:PassRole` unless essential |
| SSM secrets rotation | Old credential exposure | Rotate on schedule; remove version history after confirming rotation success |
| K8s NetworkPolicy | Cross-namespace lateral movement | Default-deny per namespace; explicit allow only required service-to-service paths |
| PodSecurityAdmission | Privileged pod creation | `enforce: restricted` profile; block `hostPID`, `hostNetwork`, `privileged` at admission |
| OCI image signing | Supply chain / tampered images | Cosign + policy enforcement in admission webhook; reject unsigned images |
| LD_PRELOAD scanning | GPU escape via shared library | Image scanning policy rejecting `LD_PRELOAD` referencing non-standard paths |
| Web content sanitization | Prompt injection via scraped pages | Strip/escape structured metadata fields before LLM ingestion; scan for instruction patterns |
| CloudTrail + GuardDuty | IAM anomaly detection | Enable `UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration` GuardDuty finding |
| K8s audit logging + Falco | SA token abuse, privileged pods | Full audit log forwarding to SIEM; Falco rules for privileged pod creation and cross-namespace reads |

---

## Monitoring Checklist
- [ ] IMDSv2 enforced on all EC2 instances and Lambda functions
- [ ] CloudTrail enabled in all regions with S3 log archive
- [ ] GuardDuty enabled with ML-threat findings reviewed weekly
- [ ] SSM Parameter Store: alert on `GetParameterHistory` API calls
- [ ] ECR: image push/pull logged; alert on pulls from unknown IPs outside deployment windows
- [ ] CloudWatch log groups containing secrets: access-controlled, logged, alerted
- [ ] Kubernetes audit logging forwarded to SIEM
- [ ] Falco deployed with rules for privileged pod creation and cross-namespace secret reads
- [ ] Container image registry scanning for LD_PRELOAD env vars and `.so` files in non-standard paths
- [ ] Web scraping pipelines: content sanitization before LLM ingestion
- [ ] Model Registry: metadata field validation; alert on unusual field values

---

## Incident Response Notes

| Indicator | Likely scenario | Initial response |
|-----------|----------------|-----------------|
| IMDS calls from Lambda | SSRF exploiting Lambda function | Identify user-supplied URL parameter; rotate Lambda execution role credentials; check AssumeRole chain in CloudTrail |
| Chained AssumeRole from same IP | IAM role chain traversal | Block source IP; invalidate assumed role sessions (`sts:revokeRoleCredentials` via deny policy); audit what the terminal role accessed |
| Cross-namespace K8s secret read | Service account token abuse | Identify source pod and SA; delete compromised SA token (create new SA); audit what secrets were accessed; check for new pod creation |
| Privileged pod created unexpectedly | Pre-escape staging | Immediately cordon node; delete pod; check for `/etc/sudoers.d/` modifications on node; rotate node if compromise confirmed |
| New file in /etc/sudoers.d/ on GPU node | CVE-2025-23266 GPU escape | Isolate node; revoke node credentials; rebuild from clean image; audit build pipeline inputs |
| LLM output contains unexpected URLs or commands | Web content injection | Identify source documents; remove from RAG index; add sanitization layer; review recent model actions for exfiltration |

---

## Architecture Hardening

**Zero-trust ML pipeline design:**
- Each pipeline stage (data ingestion, training, serving) runs as a separate IAM role with minimum required permissions
- No cross-stage credential sharing — use resource-based policies (S3 bucket policy allowing specific role ARN)
- Training jobs run in private VPC subnets with no internet gateway; NAT only for package downloads via approved proxy

**Kubernetes ML cluster hardening:**
- One service account per workload — inference SA ≠ training SA ≠ monitoring SA
- `automountServiceAccountToken: false` by default; opt-in only where required
- Separate namespaces per team with NetworkPolicy default-deny
- PodSecurityAdmission at `restricted` level; exception process for GPU workloads (document and audit)

**Model artifact integrity:**
- Sign all model artifacts with Cosign before pushing to registry
- Admission webhook verifies signature before allowing model load
- Immutable artifact storage — no overwrite, versioned S3 with object lock

**Secrets management:**
- No secrets in environment variables, image layers, or model metadata
- Secrets Manager / SSM with automatic rotation; version history purged post-rotation
- ECR image scanning mandatory; reject images with critical CVEs

**Web-augmented AI systems:**
- Separate retrieval layer from generation layer — retrieval returns structured facts, not raw HTML
- Sanitize all structured metadata fields (JSON-LD, microdata) before ingestion
- Implement instruction-pattern classifier as pre-filter on retrieved content
