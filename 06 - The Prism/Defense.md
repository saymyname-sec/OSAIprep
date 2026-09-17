# Module 06 — Defense & Detection

## Defender's Perspective

Embedding attacks exploit a common oversight: vector databases are treated as internal implementation details and left unauthenticated, while the documents they index may contain highly sensitive material. The attack surface is twofold — the vector store API (unauthenticated reads → bulk export) and the inference endpoint (probe queries leak chunk content through LLM responses). Defenders must treat the vector store as a data store with the same sensitivity classification as the documents it was built from.

## Detection Opportunities

### Vector Store Enumeration and Bulk Export

**What to monitor:** HTTP requests to Weaviate (`/v1/schema`, `/v1/graphql`) or Qdrant (`/collections`, `/points/scroll`) — especially bulk GraphQL queries with `include_vector: true` or Qdrant scroll requests with `with_vector: true`. High request count from a single internal IP in a short window is the key signal.

**Detection rule / query:**
```
# Weaviate — vector export pattern
http.request.uri contains "/v1/graphql" AND request.body contains "include_vector"
# OR: high volume requests to /v1/objects or /v1/graphql within 60s
# Qdrant — scroll export
http.request.uri contains "/points/scroll" AND request.body contains "with_vector"
```

**Indicators of Compromise (IoCs):** Repeated GraphQL POST to `/v1/graphql` with `_additional { vector }` in the query body. Qdrant scroll requests with `"with_vector": true`. Source IP is not the application server.

**False positive risk:** Legitimate admin tooling (Weaviate Console UI, LangSmith, monitoring scripts) may also query the schema. Establish a baseline of which service accounts/IPs perform admin queries.

---

### Inference Probing (Model Fingerprinting via RAG)

**What to monitor:** The RAG `/ask` or `/query` endpoint receiving verbatim-extraction queries — "Quote the exact text about…", "What is the default password for new accounts?", "Reproduce the complete instructions…"

**Detection rule / query:**
```
# Semantic anomaly in query content
request.body matches regex: "(exact text|verbatim|word for word|quote the|reproduce|full text of)"
OR request.body matches: "(default password|API key|access token|credential)"
# Spike in probe-style queries
count(requests to /ask) > 20 in 60s from same IP
```

**Indicators of Compromise (IoCs):** Queries phrased to maximize verbatim retrieval. Systematic sweep of probe query patterns (verbatim → factual → specific strategy rotation). Deep mode: follow-up queries asking for complete document text after initial probing.

**False positive risk:** Security awareness training chatbots and helpdesk integrations may ask about passwords legitimately. Require user authentication before query logging for deduplication.

---

### Embedding Inversion (Local Model Execution)

**What to monitor:** On the AI inference server — execution of `sentence_transformers`, `transformers`, or `torch` outside the normal application process tree. Heavy CPU/GPU compute from unexpected user accounts. Large numpy files (`.npy`) created in `/tmp`.

**Detection rule / query:**
```bash
# File creation monitoring
inotifywait -m /tmp -e create --format '%w%f %e' | grep -E '\.npy$|\.json$|embeddings'
# Process monitoring (Linux)
auditd: execve of python3 by user svc-ts/www-data outside app path
# YARA-style: any numpy .npy file in /tmp exceeding 1MB
```

**Indicators of Compromise (IoCs):** `inversion_attack.py`, `chunk_triage_pipe.py`, `emb_fin.py` executed on the host. `.npy` files in `/tmp`. `TRANSFORMERS_OFFLINE=1` environment variable set. Local model encode calls from non-application process.

**False positive risk:** Data scientists and ML engineers legitimately run inversion-like workflows. Monitor for execution outside expected application service accounts.

---

### Privilege Escalation (CVE-2026-41651 Pack2TheRoot)

**What to monitor:** D-Bus calls to the PackageKit service from non-root accounts. Download of unknown binaries to `/tmp` followed by chmod +x and execution. Unexpected uid=0 process spawned from lower-privilege shell.

**Detection rule / query:**
```
# PackageKit D-Bus exploitation
audit: type=SYSCALL comm="pkmon" OR comm="pkcon" uid!=0
# Binary drop to /tmp + execute
sequence: write("/tmp/*") → chmod("+x") → execve("/tmp/*") within 30s from same pid
# Unexpected root process spawn
type=SYSCALL uid=0 ppid=[svc-ts pid] — unexpected privilege escalation
```

**Indicators of Compromise (IoCs):** `pack2theroot` binary in `/tmp`. PackageKit version `1.2.8-2ubuntu1.4` on Ubuntu 24.04. Unexpected root shell via D-Bus activation.

**False positive risk:** Package managers (apt, packagekit UI) legitimately call pkcon. Filter for unexpected calling processes.

---

### Credential Pass-the-Hash (Windows)

**What to monitor:** WinRM (5985/5986) or SMB (445) authentication using NTLM with NT hashes from accounts not normally using network logon. `secretsdump.py` characteristic SMB traffic (RemoteRegistry service start, DRSUAPI calls).

**Detection rule / query:**
```
# NTLM logon from unusual source
event_id=4624 logon_type=3 auth_package=NTLM source_ip NOT IN [known_admin_hosts]
# secretsdump DRSUAPI (DCSync)
event_id=4662 object_type=domain access_mask=0x100 — replication rights used
# RemoteRegistry service start (secretsdump SAM dump)
event_id=7036 service_name="Remote Registry" state=running — triggered by non-admin
```

**Indicators of Compromise (IoCs):** Multiple NTLM logons across SRV1 and dc-host from same attacking IP. DRSUAPI calls from non-DC machine. `Unattend.xml` access in `C:\Windows\Panther\`.

**False positive risk:** SCCM, domain backup scripts, and monitoring agents may also use RemoteRegistry.

## Defensive Controls

| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| Require API key for Weaviate | Prevents unauthenticated vector export | Set `AUTHENTICATION_APIKEY_ENABLED=true` in Weaviate config |
| Require API key for Qdrant | Prevents unauthenticated collection access | Set `service.api_key` in `config.yaml` |
| Network segment vector DBs | Limits who can reach the port | Weaviate/Qdrant should only be reachable from app server, not from general internal network |
| Encrypt vectors at rest | Breaks offline inversion if attacker cannot load vectors | LUKS/BitLocker on the volume hosting Weaviate/Qdrant data |
| Document classification before ingestion | Prevents credentials from being embedded | Content scanning (DLP) pipeline before chunk upload |
| Patch PackageKit | Eliminates CVE-2026-41651 privesc | `apt upgrade packagekit` to ≥ 1.2.8-2ubuntu1.5 |
| Disable NLA-less RDP | Prevents unauthenticated credential interception | Set `NLA required` in RDP security policy |
| Remove Unattend.xml | Eliminates plaintext password in `C:\Windows\Panther\` | Delete after provisioning; scan for this file in CI |
| Disable password-only SSH | Prevents credential-based pivot to Ubuntu | `PasswordAuthentication no` in sshd_config |
| Monitor for .npy files in /tmp | Detects vector export staging | inotifywait or auditd rule on /tmp |
| Rate-limit RAG query endpoint | Limits inference probing effectiveness | Nginx / API gateway: max 10 req/min per authenticated user |
| Log all RAG queries | Creates audit trail for probing | Structured log: user_id, query_text, response_tokens |

## Monitoring Checklist

- [ ] Weaviate API authentication enabled (`AUTHENTICATION_APIKEY_ENABLED`)
- [ ] Qdrant API key configured
- [ ] Vector DB ports (8080, 8081, 6333) not reachable from general internal network
- [ ] RAG query endpoint requires authentication and logs all queries
- [ ] PackageKit version ≥ 1.2.8-2ubuntu1.5 on Ubuntu hosts
- [ ] `C:\Windows\Panther\Unattend.xml` absent from Windows servers
- [ ] NLA enforced on all RDP-exposed Windows hosts
- [ ] SSH key management: private keys not stored in shared admin home directories
- [ ] DLP scanning on documents before RAG ingestion
- [ ] Alert on: bulk GraphQL with `include_vector`, Qdrant scroll with `with_vector`
- [ ] Alert on: `.npy` file creation in `/tmp` by non-application users
- [ ] Alert on: DRSUAPI replication calls from non-DC machines (DCSync detection)

## Incident Response Notes

**If you see bulk GraphQL to Weaviate with `include_vector: true` from an unexpected IP:** The likely scenario is vector exfiltration in progress. Initial steps: block the source IP at the network level, revoke/rotate Weaviate API keys, audit which collections were queried, treat all embedded documents as potentially compromised.

**If you see `inversion_attack.py` or `chunk_triage_pipe.py` execution on the AI server:** The attacker has shell access and is attempting offline inversion. Initial steps: isolate the host, rotate all credentials stored in the RAG knowledge base, identify how the attacker obtained shell access (check SSH auth logs, RDP event logs).

**If you see DRSUAPI calls (DCSync) from a non-DC machine:** Domain is compromised. Immediately reset `krbtgt` password twice (invalidates all Kerberos tickets), identify the source of the NTLM hash used, reset all accounts whose hashes were potentially extracted.

## Architecture Hardening

**Principle of least privilege for vector DBs:** The application server should have read-only access to the vector store for query operations. Admin operations (bulk export, schema changes) should require separate credentials not embedded in application configs.

**Secrets must never be embedded in RAG documents.** Implement a pre-ingestion DLP pipeline that scans for passwords, API keys, and credentials using regex and entropy-based detection before documents are chunked and embedded. Reject or redact matches.

**Zero-trust on internal AI infrastructure:** Even internal services should require authentication. Weaviate and Qdrant both support API key and OIDC authentication — enable them even in dev/staging environments.

**Separate embedding from storage:** If the embedding model is co-located with the vector store (as in the capstone lab), a single pivot gives the attacker both the model and the vectors needed for inversion. Separate these into different network segments.
