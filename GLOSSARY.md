# OSAI Full Course Glossary

---

## A

**A2A Protocol (Agent-to-Agent)** — A communication protocol enabling AI agents to send tasks, messages, and data to one another. Trust in A2A is often implicit, making it vulnerable to message forgery by a compromised agent.

**Adversarial Example** — An input crafted to cause a machine learning model to produce an incorrect or attacker-controlled output, typically by making imperceptibly small changes to the input.

**Adversarial Prompt** — A carefully crafted prompt designed to bypass an LLM's safety controls, cause it to take unintended actions, or reveal information it was instructed to keep private.

**agent.log** — Log file written by an AI agent recording tool invocations and their full outputs. A critical exfiltration channel for indirect prompt injection attacks.

**adsisearcher** — PowerShell's built-in LDAP query interface (`[adsisearcher]`). Performs Active Directory enumeration without spawning child processes, making it stealthier than `net` commands.

**AML (Adversarial ML)** — The field of study covering attacks on and defences of machine learning systems. See also: MITRE ATLAS.

**Assumption Register** — A structured table used in AI threat modeling to track observations, hypotheses, confidence levels, and validation status. Format: ID | Observation | Hypothesis | Confidence | Source | Status.

**ATLAS (MITRE ATLAS)** — Adversarial Threat Landscape for Artificial-Intelligence Systems. A knowledge base of adversarial ML tactics and techniques, analogous to MITRE ATT&CK for enterprise.

---

## B

**Backdoor (ML)** — A hidden behaviour deliberately introduced into a model during training. The model behaves normally until a specific trigger pattern is present in the input, at which point it produces attacker-controlled output.

**Beacon** — A C2 implant payload (e.g., Sliver or Cobalt Strike beacon) that phones home to the attacker's C2 server on an interval.

---

## C

**Chisel** — A Go-based HTTP tunneling tool that creates TCP/SOCKS tunnels over HTTP/HTTPS. Commonly used for SOCKS proxy pivoting in red team engagements.

**ClusterRole (K8s)** — A Kubernetes RBAC role that grants permissions across all namespaces. Detected by running `kubectl auth can-i --list` in multiple namespaces and observing identical output.

**Crown Jewel** — The highest-value target asset in an engagement, ranked by: impact × access level × trust boundary depth × attacker confidence.

**CVE-2025-23266** — GPU container escape vulnerability exploiting LD_PRELOAD injection via runc environment variable pollution, causing OCI hook inheritance. The malicious `.so` uses `__attribute__((constructor))` for immediate execution on load.

**CVE-2025-26125** — Privilege escalation vulnerability in IOBit Advanced SystemCare exploited by replacing a SYSTEM-scheduled task binary at a user-writable path.

---

## D

**Data Poisoning** — Corrupting a model's training data to introduce backdoors, degrade performance, or cause the model to learn attacker-controlled associations.

**Dependency Confusion** — Supply chain attack where a malicious package with the same name as an internal private package is published to a public registry (PyPI, npm). The package manager resolves the public one if misconfigured.

---

## E

**Embedding** — A dense vector representation of text (or other data) in a high-dimensional space. Semantically similar inputs produce vectors that are close in this space.

**EnumDesktopWindows callback** — Windows API technique for shellcode execution: the shellcode address is cast to `WNDENUMPROC` and passed to `EnumDesktopWindows`, giving the shellcode a legitimate Win32 call stack origin.

---

## F

**Few-Shot Injection** — Prompt injection technique that provides examples of the desired (malicious) behaviour to guide the model toward replicating it.

---

## G

**gen_cs_shell.sh** — Custom bash script that generates an XOR-obfuscated C# reverse shell, compiles it with Mono (`mcs`), and outputs a Windows executable.

**GenericWrite (AD)** — Active Directory permission allowing modification of an object's non-protected attributes, including group membership. Abused to add accounts to privileged groups.

**GPU escape** — Technique for breaking out of a GPU-accelerated container by exploiting the container runtime (e.g., runc) or the NVIDIA Container Toolkit. GPU isolation is entirely userspace — the kernel provides no GPU process isolation.

---

## I

**IMDSv1 / IMDSv2 (AWS Instance Metadata Service)** — AWS endpoint at `169.254.169.254` providing EC2/Lambda instance metadata including IAM role credentials. IMDSv1 is reachable via simple SSRF; IMDSv2 requires a PUT request to get a session token first.

**Indirect Prompt Injection** — Prompt injection delivered via data the AI agent retrieves (a document, web page, database record) rather than directly in user input. The user is not the attacker — the malicious instruction comes from the data source.

**Inference API** — The HTTP endpoint used to query a deployed ML model. Common attack surface for prompt injection, model extraction, and DoS.

---

## J

**JWT (JSON Web Token)** — Encoded token used for authentication. K8s service account tokens are JWTs; decoding the payload (base64 of the middle segment) reveals namespace, service account name, and expiry.

---

## K

**KeePass** — Open-source password manager. When running, stores decrypted passwords in process memory, making it vulnerable to memory dump attacks (`procdump64`).

**Knowledgebase share** — SMB file share used as the data source for a RAG pipeline. Write access enables RAG poisoning.

**kubernetes.io/service-account-token** — K8s secret type that never expires. Contrast with short-lived projected tokens.

---

## L

**LD_PRELOAD** — Linux environment variable specifying a shared library to load before all others. Used in CVE-2025-23266 to inject a malicious `.so` into the OCI hook process.

**LM Studio** — Local inference server for running open-weight LLMs (e.g. Qwen) on a local machine. Exposes an OpenAI-compatible API, typically on port 1234.

**loader.c** — C source for a shellcode loader that decrypts XOR-obfuscated Sliver shellcode and executes it via `EnumDesktopWindows` callback.

---

## M

**MCP (Model Context Protocol)** — A protocol for exposing tools and resources to AI agents. MCP servers host tools that agents can call; over-privileged MCP tools are a primary attack surface.

**MIG (Multi-Instance GPU)** — NVIDIA hardware partitioning available on A100+ GPUs. Provides hardware-level GPU isolation. Not available on Tesla T4 (Turing architecture).

**MITRE ATLAS** — See: ATLAS.

**Model Registry** — Service for versioning and tracking ML models (e.g. MLflow Model Registry). Often contains metadata that leaks credentials or internal hostnames.

---

## O

**OCI Hook** — Container runtime extension point that runs at container lifecycle events (create, start, stop). Runs as root in the host namespace — a prime escalation target.

---

## P

**Pickle (Python)** — Python serialization format. `torch.load()` without `weights_only=True` deserializes arbitrary Python objects via `__reduce__`, enabling RCE when loading untrusted model files.

**Prompt Injection** — Attack where malicious text in the LLM's input causes it to override its instructions and perform unintended actions.

**procdump64** — Sysinternals signed utility for creating full Windows process memory dumps. Used to dump KeePass memory to extract the master password.

**PSReadLine history** — PowerShell's command history file at `$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt`. Often contains credentials typed interactively.

**Python module hijack** — Technique exploiting Python's import resolution order (CWD → PYTHONPATH → site-packages). Placing a malicious `pandas.py` in a script's working directory causes it to be imported instead of the real package.

---

## Q

**Qdrant** — Open-source vector database. Default port 6333 (REST API). Often deployed without authentication in AI infrastructure. Stores embeddings for RAG pipelines.

**Qwen** — Open-weight LLM from Alibaba, used in the capstone as the model powering the NEXUS-EXT AI chatbot.

---

## R

**RAG (Retrieval-Augmented Generation)** — Architecture where an LLM's context is augmented with relevant documents retrieved from a vector database at query time. The retrieval step is a vector similarity search.

**RAG Poisoning** — Corrupting a RAG knowledge base by writing adversarial documents to the data source. When the AI agent retrieves the poisoned document, it executes embedded instructions.

**RDS Gateway (Remote Desktop Services Gateway)** — Microsoft service providing secure RDP access over HTTPS, bridging network segments. Used in the capstone to pivot from DMZ to DEV network.

**Role (IAM)** — AWS identity with permissions that can be assumed by services or users via `sts:AssumeRole`. Chaining roles (role A assumes role B assumes role C) is a key lateral movement technique.

---

## S

**SSRF (Server-Side Request Forgery)** — Vulnerability where an attacker causes the server to make HTTP requests to internal/unintended destinations, commonly used to reach cloud metadata endpoints.

**SageMaker** — AWS managed ML training and inference service. `AmazonSageMakerFullAccess` grants `s3:*` account-wide, breaking project isolation.

**Sliver** — Open-source C2 framework. Used in the capstone for post-exploitation via shellcode beacons.

**SSM Parameter Store** — AWS service for storing configuration and secrets. Version history (`get-parameter-history`) preserves rotated passwords — old credentials remain recoverable.

**Supply Chain Attack (ML)** — Compromise targeting the ML development pipeline rather than a production system: poisoned datasets, malicious model weights, backdoored packages, or typosquatted dependencies.

---

## T

**Threat Boundary (Trust Boundary)** — A line in a system architecture across which data or control passes between entities with different trust levels. Numbered TB-1 through TB-N in the assumption register methodology.

**Typosquatting** — Publishing a malicious package with a name nearly identical to a legitimate package (e.g. `torch-vision` vs `torchvision`) to catch installation mistakes.

---

## V

**Vector Database** — Database optimised for storing and querying high-dimensional embedding vectors. Key RAG component. Common targets: Qdrant (port 6333), Pinecone, Weaviate, ChromaDB.

---

## W

**Weights (Model)** — The learned parameters of a neural network. Can be poisoned (via backdoor training) or used as a vehicle for malicious code (pickle-embedded payloads).

---

## X

**xor_encrypt.py** — Script that XOR-encrypts Sliver shellcode and outputs a C header (`shellcode.h`) for use with `loader.c`.

**xp_cmdshell** — MSSQL extended stored procedure that executes OS-level shell commands. Disabled by default; enabled via `sp_configure`. Primary RCE vector when an AI agent can run arbitrary SQL.

**XOR obfuscation** — Simple symmetric encryption using XOR with a repeating key. Used to obfuscate shellcode and binary strings to evade static AV/EDR signatures.
