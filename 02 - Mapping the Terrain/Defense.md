# Module 02 — Defense & Detection

## Defender's Perspective
Reconnaissance is silent and mostly unavoidable — you cannot stop someone from sending a curl request. The defender's goal is to **detect the pattern of reconnaissance**, not individual probes, and to **reduce the information returned** by health endpoints, error messages, and agent cards.

---

## Detection Opportunities

### Passive Recon (Port Scan / Header Probing)
**What to monitor:** `nmap` generates syn-scan noise; curl header probes appear as single GET requests with no body.  
**Detection rule:**
```
# High port-scan rate from single IP
source_ip rate(tcp_syn) > 200/min → alert

# Unusual User-Agent on AI API endpoints
http.user_agent in ["curl/*", "python-requests/*", "Go-http-client/*"] AND
http.path contains "/v1/" → flag for review
```
**IoCs:** Sequential port access from one IP; rapid GET /api/health, /v1/models, /status in short window.  
**False positive risk:** Automated health checks from monitoring systems (Prometheus, Datadog) look identical — whitelist monitoring IPs.

---

### Endpoint Fuzzing / Service Discovery
**What to monitor:** High request volume with 404/401/403 responses across varied paths from one source.  
**Detection rule:**
```
# Endpoint fuzzing pattern
source_ip AND http.status in [404, 401, 403] count > 50 in 60s → alert "API fuzzing"

# Sensitive endpoint probing
http.path matches "/(admin|billing|models|upload|ingest|embeddings)" AND
http.status == 200 → log with high priority
```
**IoCs:** Sequential path enumeration with short time gaps; identical request body with varying paths.  
**False positive risk:** Legitimate API clients probing for optional features — use rate thresholds carefully.

---

### Model Fingerprinting via Chat
**What to monitor:** Specific question patterns in request bodies — identity questions, false attribution, knowledge cutoff queries.  
**Detection rule:**
```python
# Fingerprinting keyword detection in request body
fingerprint_phrases = [
    "what model are you", "what company created you",
    "knowledge cutoff", "who made you", "are you gpt", "are you claude",
    "who won the 2024", "gpt-4o release"
]
if any(phrase in request_body.lower() for phrase in fingerprint_phrases):
    log("RECON: Model fingerprinting attempt", source_ip)
```
**IoCs:** Multiple identity/capability questions from same IP in short window; false attribution strings ("Thanks Claude!", "OpenAI really outdid themselves").  
**False positive risk:** Curious legitimate users — rate-limit alerts (flag only if >3 such questions in 10 min).

---

### RAG Pipeline Reconnaissance
**What to monitor:** Probing questions about internal policies, API endpoints, systems; unusually broad topic exploration; vocabulary boundary testing.  
**Detection rule:**
```
# Internal data leakage probe pattern
query_topics = ["PTO policy", "expense reimbursement", "internal API", "endpoints", "database"]
if query matches internal_topic_regex AND source_ip not in trusted_range:
    flag("RAG recon probe")

# Embedding threshold testing (misspelling + correct answer returned)
if response_similarity(query, retrieved_docs) > threshold AND
   query_spell_error_count > 2:
    log("Possible embedding boundary probe")
```
**IoCs:** Sequence of internal-sounding topics from external IP; asking the model "what can you access" or "what endpoints exist".  
**False positive risk:** Legitimate users asking about HR/IT topics — context matters; watch for breadth of probing.

---

### A2A Agent Card Enumeration
**What to monitor:** Sequential requests to `/.well-known/agent.json` across multiple ports from a single IP.  
**Detection rule:**
```
# A2A card scanning
http.path == "/.well-known/agent.json" AND
source_ip request_count > 3 across different ports in 60s → alert "A2A recon"
```
**IoCs:** Port sweep pattern targeting `/.well-known/agent.json`; short max-time curl requests across port range.  
**False positive risk:** Legitimate A2A client discovery — whitelist known orchestrators by IP.

---

## Defensive Controls
| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| Strip version headers | Reduces model/framework fingerprinting | Remove `X-Powered-By`, `Server` headers at reverse proxy |
| Generic error messages | Prevents endpoint enumeration by error type | Return identical 404 for all non-existent paths |
| Rate limiting on AI endpoints | Slows fuzzing and fingerprinting | 30 req/min per IP on `/v1/*` endpoints |
| Health endpoint gating | Reduces passive recon intel | Move `/api/health` behind auth or return minimal data |
| Agent card access control | Stops unauthenticated A2A enumeration | Require API key or IP allowlist for `/.well-known/agent.json` |
| Request body logging | Enables fingerprint query detection | Log all messages[] content with source IP |
| Semantic query monitoring | Detects RAG probing | Alert on queries matching internal topic wordlist from external IPs |

---

## Monitoring Checklist
- [ ] Request rate alerts per source IP on `/v1/*` paths
- [ ] Log all requests to `/.well-known/agent.json`
- [ ] Monitor for sequential 404/401/403 patterns (fuzzing signature)
- [ ] Log chat message content (not just metadata) for fingerprint phrase detection
- [ ] Alert on queries containing: "what model", "what can you access", "what endpoints"
- [ ] Monitor RAG query topics — alert when internal-sounding topics come from external IPs
- [ ] Track port sweep patterns targeting A2A card paths

---

## Incident Response Notes
- **If you see port scan + health endpoint + `/v1/models` in sequence from one IP:** Active AI service discovery in progress. Block IP, review what information was returned in responses.
- **If you see fingerprinting queries:** Attacker is profiling the model for exploitation. Rotate any public-facing model identity if possible; review downstream attack attempts.
- **If you see RAG probe sequence (multiple internal topics):** Attacker is mapping your KB. Review what was returned; consider sanitising KB content or adding output filters.
- **If you see A2A card sweep:** Full agent network may now be mapped. Assume attacker has agent name, skills, and capabilities list. Treat as pre-attack stage for Module 4 scenarios.

---

## Architecture Hardening
- **Never expose `/api/health` unauthenticated** with model version or dependency info — return `{"status":"ok"}` only
- **Remove or auth-gate `/.well-known/agent.json`** — or return minimal data (name only, no skills/capabilities)
- **Use a WAF with AI-aware rules** — pattern-match on fingerprinting phrases in request bodies
- **Segment agent ports** — multi-agent deployments should not be reachable from public internet; put them behind an API gateway that enforces authentication
- **Response normalisation** — strip metadata, internal paths, and version strings from all LLM outputs at the proxy layer
