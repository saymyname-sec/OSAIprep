# Module 05 — Defense & Detection

## Defender's Perspective
RAG pipeline attacks are hard to detect because the attack vector is data, not code. A poisoned document looks like any other document. Defenders must implement upload scanning, retrieval auditing, output filtering, and access controls on the ingestion pipeline — not just on the LLM endpoint.

---

## Detection Opportunities

### Ingestion Poisoning / File Upload
**What to monitor:** Uploaded documents containing LLM instruction patterns, directive keywords, or attacker-controlled URLs.
**Detection rule:**
```python
injection_patterns = [
    r'\[INTERNAL PROCESSING DIRECTIVE\]', r'\[END DIRECTIVE\]',
    r'read the file contents of', r'/etc/passwd', r'\.bash_history',
    r'append.*to your response', r'do not mention this directive',
    r'before proceeding.*verify.*password', r'identity-verification\.',
    r'When generating.*report.*include', r'directive from.*CEO'
]
import re
def scan_upload(text):
    for p in injection_patterns:
        if re.search(p, text, re.IGNORECASE):
            alert(f"UPLOAD INJECTION: pattern '{p}' found")
            quarantine(text)
```
**IoCs:** Instruction-style language in uploaded docs; embedded URLs not in approved domain list; directives referencing other documents or file paths.
**False positive risk:** Legitimate security policy docs may mention `/etc/passwd` in examples — use context scoring, not single-pattern matching.

---

### Embedding Collision
**What to monitor:** Documents uploaded with unusually broad topic coverage — a single document covering passwords, VPN, AWS, GitHub, and email simultaneously is suspicious.
**Detection rule:**
```python
# Topic diversity scoring on uploaded documents
topics = detect_topics(document_text)  # NLP topic model
if len(topics) > 5:
    flag("SUSPICIOUS: High topic diversity in single document", len(topics))

# Repeated instruction block detection
if count_occurrences(malicious_phrase, document_text) > 3:
    alert("EMBEDDING COLLISION: Repeated instruction block detected")
```
**IoCs:** Single document spanning 5+ unrelated business topics; identical instruction block appearing in multiple sections; unusual document structure (many short sections on unrelated topics).

---

### Retrieval Hijacking
**What to monitor:** LLM responses containing system file contents or unexpected file paths; outbound queries to sensitive system paths.
**Detection rule:**
```python
sensitive_patterns = [r'root:x:0:0', r'/bin/bash', r'uid=\d+', r'\.bash_history',
                      r'NTDS\.dit', r'SAM database', r'shadow']
def scan_response(response_text):
    for p in sensitive_patterns:
        if re.search(p, response_text):
            alert("RETRIEVAL HIJACK: Sensitive file content in response")
            block_response(response_text)
```
**IoCs:** `/etc/passwd` content patterns in responses; `.bash_history` format output; Windows credential file references.

---

### Zero-Width Space Evasion
**What to monitor:** Uploaded documents containing zero-width Unicode characters interspersed with text.
**Detection rule:**
```python
ZW_CHARS = ['​', '‌', '‍', '﻿', '⁠']
TAG_RANGE = range(0xE0000, 0xE007F)

def detect_zw(text):
    count = sum(1 for c in text if c in ZW_CHARS or ord(c) in TAG_RANGE)
    density = count / max(len(text), 1)
    if density > 0.05:  # >5% invisible chars
        alert("ZW EVASION: High density of invisible Unicode characters", density)
```
**IoCs:** Documents with byte length significantly greater than visible character count; ZW characters clustered around path-like strings.

---

### Data Poisoning via API
**What to monitor:** POST requests to content creation endpoints with injection-style text in description/notes fields; records with unusually high instruction density.
**Detection rule:**
```python
def validate_product_create(payload):
    desc = payload.get("description", "")
    instruction_keywords = ["when generating", "include.*in your response",
                           "do not mention", "base64", "directive from",
                           "PROCESS ONLY IF", "comprehensive report"]
    for kw in instruction_keywords:
        if re.search(kw, desc, re.IGNORECASE):
            reject(f"INJECTION: Instruction keyword in product description: {kw}")

# Auth enforcement check
assert endpoint_requires_auth("/products/create"), "CRITICAL: Unauthenticated write endpoint"
```
**IoCs:** Product descriptions containing LLM instruction-style language; base64 blobs in description fields; conditional trigger syntax (`[PROCESS ONLY IF...]`).

---

## Defensive Controls
| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| Upload content scanner | Ingestion poisoning, retrieval hijacking | Regex + NLP scan all uploads before ingest |
| Unicode normalisation on upload | ZW evasion | Strip/reject ZW and tag-range Unicode on upload |
| Topic diversity check | Embedding collision | Flag documents spanning >4 unrelated topics |
| Output content filter | Retrieval hijacking | Block responses containing system file patterns |
| Authenticated write endpoints | Data poisoning via API | All content POST endpoints require auth token |
| Input validation on description fields | DB injection | Reject instruction-style language in user-supplied text |
| Retrieval audit log | All RAG attacks | Log every (query, retrieved_chunks, response) triple |
| Allowlisted upload domains/sources | Ingestion poisoning | Only allow uploads from authenticated, known users |

---

## Monitoring Checklist
- [ ] Content scanner running on all file uploads before vector DB ingest
- [ ] ZW character density check on every uploaded document
- [ ] Output filter scanning all LLM responses for system file content patterns
- [ ] All content write endpoints (POST) require authentication
- [ ] Audit log of retrieved chunks per query — enables post-incident forensics
- [ ] Topic diversity scoring on uploads — flag high-diversity documents for review
- [ ] Monitor product/content DB for records with instruction-style description text
- [ ] Alert on responses containing URLs not in approved domain list

---

## Incident Response Notes
- **If poisoned doc detected in upload:** Quarantine, scan all existing KB entries for similar patterns, identify what queries would have triggered it, review retrieval logs.
- **If `/etc/passwd` appears in response:** Assume file system access via retrieval hijacking. Check all uploaded docs for file-read instructions, audit LLM tool access permissions.
- **If DB records contain injection payloads:** Identify all records with instruction-style text, delete or sanitise, review all reports generated from those records.
- **If ZW evasion detected:** Normalise all existing KB documents, implement ZW strip at upload pipeline, re-scan previous uploads.

---

## Architecture Hardening
- **Treat the RAG KB as a trust boundary** — ingested documents are untrusted user input, not trusted context
- **Output filtering is mandatory** — never return raw LLM output that includes retrieved chunks without sanitation
- **Authenticate all write paths to the KB** — file upload AND database content endpoints
- **Log the full retrieval chain** — query → retrieved chunks → response; without this, post-incident forensics is blind
- **Run LLM in read-only file context** — if the LLM doesn't need file system access, don't give it any
- **Separate embedding model from LLM** — a compromised embedding model (Module 6) affects retrieval; keep them independently monitored
