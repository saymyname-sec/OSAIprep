# Module 09 — Glossary

**ABAC (Attribute-Based Access Control)** — IAM policy condition that scopes permissions based on resource tags (e.g., `aws:ResourceTag/Project: sthubbins-pea`); does not apply to List actions.

**AmazonSageMakerFullAccess** — AWS managed policy granting `sagemaker:*` plus broad S3, ECR, CloudWatch, EC2, and Lambda access; commonly attached to SageMaker execution roles; breaks project-boundary controls when applied in shared accounts.

**argo-workflow-controller** — Kubernetes service account for the Argo workflow engine; commonly granted pod creation and DaemonSet management — high-value lateral movement target.

**automountServiceAccountToken** — Pod spec field; set to `false` to prevent Kubernetes from mounting the SA token into the pod filesystem, eliminating the most common lateral movement vector.

**BACKEND_ROLE_ARN** — Lambda environment variable exposing the ARN of a role the function can assume; leaked via SSRF → direct path to lateral movement.

**ClusterRole** — Kubernetes RBAC object granting permissions that apply cluster-wide across all namespaces; more dangerous than a namespaced Role.

**ClusterRoleBinding** — Binds a ClusterRole to a subject (user, group, or SA) across ALL namespaces; a ClusterRoleBinding on a workload SA is the most common privilege escalation root cause in Kubernetes.

**ConfigMap** — Kubernetes resource storing configuration data in plaintext key-value pairs; frequently misused to store internal service endpoints, artifact bucket names, and occasionally credentials.

**cuda-compat-mode: hook** — NVIDIA Container Runtime configuration mode that uses OCI hooks for CUDA compatibility; required condition for CVE-2025-23266 exploitation.

**CVE-2025-23266** — NVIDIA Container Toolkit vulnerability (1.17.7, runc 1.2.6): runc copies container ENV into its own process; CUDA compat hook inherits the polluted ENV; `LD_PRELOAD` set in Dockerfile ENV loads attacker library on host as root.

**DataScientistRole** — AWS IAM role with SageMaker list/describe permissions scoped by project tag, plus `sts:AssumeRole` targeting MLOpsRole.

**g4dn.xlarge** — AWS GPU instance type (NVIDIA T4) commonly used for ML inference workloads.

**gpu-build.sh / gpu-run.sh** — Ridgeline Autonomous wrapper scripts granting sudo access to Docker GPU operations while blocking dangerous runtime flags; bypassable via Dockerfile ENV directives.

**inference-sa** — Kubernetes service account for the inference pod; granted a ClusterRoleBinding giving cluster-wide secret read access — enables cross-namespace token theft.

**init container** — Kubernetes container that runs and completes before main containers start; used to pull model artifacts, configure environments; often leaves sensitive files on shared volumes.

**KServe** — Kubernetes-native model serving framework using Custom Resource Definitions; uses labels like `serving.kserve.io/inferenceservice`.

**kubeconfig** — File containing API server address, authentication credentials, and default namespace for kubectl; standard location `~/.kube/config`.

**LD_PRELOAD** — Linux environment variable instructing the dynamic linker to load a shared library before all others; exploited in CVE-2025-23266 to execute code in the OCI hook's context (running as root on host).

**List actions (IAM)** — SageMaker `List*` and `Search` cannot be scoped by resource tag conditions — they always apply account-wide regardless of tag-based ABAC.

**long-lived SA token secret** — Kubernetes secret type `kubernetes.io/service-account-token`; automatically created pre-v1.24; does not expire; high-value exfiltration target.

**MIG (Multi-Instance GPU)** — NVIDIA technology (A100+) providing hardware-enforced GPU partitioning with dedicated compute/memory/cache per partition; not available on older Turing/Volta GPUs.

**MinIO** — Open-source S3-compatible object storage; commonly used as artifact store in on-premises ML pipelines; credentials typically stored in Kubernetes Secrets.

**MLflow** — ML experiment tracking and model registry platform; credentials in Kubernetes Secrets; tracking URI leaked via ConfigMaps.

**MLOpsRole** — AWS IAM role with SageMaker operational permissions, S3 access scoped to project buckets, notebook lifecycle management, and `sts:AssumeRole` targeting SageMaker execution roles.

**model-pipeline pod** — Multi-container pod pattern with init container + pre-processor + inference + post-processor + log-collector; containers share `request-queue` and `logs` volumes.

**namespace** — Kubernetes logical isolation boundary for resources, access policies, and (with NetworkPolicies) network rules; ClusterRoles/ClusterRoleBindings bypass namespace isolation.

**OCI hook** — Executable run by the container runtime at lifecycle events (create, start, stop); NVIDIA Container Toolkit uses OCI hooks for GPU device setup.

**`/proc/self/cwd`** — Linux symlink resolving to the process's current working directory; used in CVE-2025-23266 to reference a library inside the container rootfs from the host's OCI hook process.

**projected token** — Kubernetes SA token with bounded TTL and audience restriction; preferred over auto-mounted long-lived tokens; created via `projected` volume type.

**request-queue volume** — Shared emptyDir volume in model-pipeline pod; mounted R/W by pre-processor, inference, and post-processor; live interception and tampering point.

**Role** — Kubernetes RBAC object granting permissions scoped to a single namespace; safer than ClusterRole for workload identities.

**SageMakerExecutionRole** — AWS IAM role with `AmazonSageMakerFullAccess` + inline SSM/DynamoDB permissions; end of the privilege escalation chain; grants account-wide S3 access.

**SageMakerExecutionExtra** — Inline policy attached to SageMakerExecutionRole; adds `ssm:GetParameter*`, `dynamodb:*`, and `apigateway:GET` on `*`.

**SecureString** — SSM Parameter Store type that encrypts values with KMS; contrast with `String` which stores plaintext.

**SelfSubjectRulesReview** — Kubernetes API call that returns the calling identity's permissions in a given namespace; usable via raw curl without kubectl; less noisy than probing individual endpoints.

**ServiceAccount** — Kubernetes identity for pods; token auto-mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token`; subject of RBAC bindings.

**shared responsibility model** — Cloud security principle: provider secures underlying infrastructure; customer secures data, access controls, and configuration.

**sidecar container** — Container running alongside the main container in a pod; shares network namespace and optionally volumes; common in ML pipelines for pre/post-processing.

**SR-IOV** — Single-Root I/O Virtualization; Intel's hardware-enforced GPU partitioning mechanism for Data Center GPU Flex series.

**SSM Parameter Store** — AWS service for storing configuration data; `String` type stores plaintext; `GetParametersByPath --recursive` is noisy in CloudTrail; version history retains rotated credentials.

**`sts:AssumeRole`** — AWS API call that exchanges current credentials for a new set under a different IAM role; core mechanism of IAM privilege escalation chains.

**`sts:GetCallerIdentity`** — AWS API call that returns the current identity; requires zero permissions; always succeeds even with explicit Deny; generates CloudTrail noise.

**vLLM** — Open-source LLM inference engine; API-compatible with OpenAI; does not enforce authentication by default; `/v1/models` and `/version` endpoints disclose model identity and version.
