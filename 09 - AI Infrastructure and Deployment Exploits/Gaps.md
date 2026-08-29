# Module 09 — Gaps & Resolutions

## Status: All primary gaps resolved

| # | Gap | Status |
|---|-----|--------|
| 1 | SSRF → Lambda ENV dump command and variable extraction | ✅ Resolved |
| 2 | IAM role chain: Lambda → DataScientistRole → MLOpsRole → SageMakerExecutionRole | ✅ Resolved |
| 3 | DataScientistPolicy full statement analysis (ABAC scoping, List* exception, AssumeMLOpsRole) | ✅ Resolved |
| 4 | MLOpsRole trust policy: root principal = any account entity can assume if their policy allows | ✅ Resolved |
| 5 | MLOpsRole alternative escalation path via SageMakerNotebookManagement + PassRoleToSageMaker | ✅ Resolved |
| 6 | AmazonSageMakerFullAccess: breaks project boundaries via s3:* on * | ✅ Resolved |
| 7 | SSM Parameter Store: String vs SecureString, version history recovery, stealth guidance | ✅ Resolved |
| 8 | CloudWatch log secrets: filter-pattern approach, failed-run credential leakage pattern | ✅ Resolved |
| 9 | Model registry: container ENV token leak + CustomerMetadataProperties pipeline map | ✅ Resolved |
| 10 | ECR image ENV credential extraction via docker inspect | ✅ Resolved |
| 11 | EC2 cross-project enumeration + vLLM unauthenticated endpoint check | ✅ Resolved |
| 12 | Kubeconfig analysis: CN/O cert parsing, namespace extraction | ✅ Resolved |
| 13 | SelfSubjectRulesReview via raw curl (no kubectl) — full command | ✅ Resolved |
| 14 | inference-sa: ClusterRoleBinding confirms cluster-wide secret read access | ✅ Resolved |
| 15 | Argo controller token: read, decode JWT, test permissions, compare vs inference-sa | ✅ Resolved |
| 16 | Identity chaining table: inference-sa vs argo-workflow-controller capabilities | ✅ Resolved |
| 17 | Multi-container pod architecture: init containers, shared volumes, sidecar attack surface | ✅ Resolved |
| 18 | CVE-2025-23266: full exploit chain (LD_PRELOAD → OCI hook → host root) | ✅ Resolved |
| 19 | /proc/self/cwd trick for cross-namespace library path resolution | ✅ Resolved |
| 20 | GPU isolation gap: no kernel cgroups GPU controller; hardware alternatives (MIG, SR-IOV) | ✅ Resolved |

## Minor Open Items (low priority)

| # | Item | Notes |
|---|------|-------|
| A | Capstone lab flags (UrbanPulse PulseML) | Fill after attempting the lab |
| B | Exact Rainy Day Financial Plaid API key and Stripe secret key values | Lab-specific; not in course text |
| C | ml-inference-staging security controls (staging vs prod RBAC diff) | Lab answer; requires cluster access |
| D | Argo Workflows CRD full permissions scope | Mentioned as wildcard `*` on workflow CRDs; full list not enumerated |
| E | KServe InferenceService CRD — exact API group path for enumeration | Not covered; inference-sa ClusterRole only covers core API |
