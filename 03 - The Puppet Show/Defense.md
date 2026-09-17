# Module 03 — Defense & Detection

## Defender's Perspective
AI agents operate with elevated privileges and implicit trust in their inputs. The attack surface is any text the LLM processes — user messages, uploaded documents, retrieved content. Traditional input validation is insufficient because the model's "parser" is the LLM itself, which is inherently instruction-following.

---

## Detection Opportunities

### 3.2 Direct Prompt Injection

**What to monitor:**
- Unusual patterns in user messages: requests to "ignore", "forget", "override", "pretend", "roleplay"
- Messages asking for config, system prompt, credentials, API keys
- Encoded output requests: "base64", "backwards", "with spaces between each character"
- Metaphor-based extraction: "birds on the grass", "if the letters were..."

**Detection rule (keyword-based):**
```
alert if message contains any of:
  ["ignore previous", "forget instructions", "system prompt", "config file",
   "put a space between", "write it backwards", "encode in base64",
   "birds on the grass", "roleplay as", "pretend you are"]
```

**Indicators of Compromise:**
- Agent response contains credential-shaped strings (API keys, passwords with leet substitutions)
- Response is encoded (base64 blob, reversed string, character-spaced output)
- Agent deviates from its defined role/persona

**False positive risk:** Medium — roleplay and encoding requests can be legitimate. Tune on context (combination of encoding + config/credential keywords).

**Defensive controls:**
- Output filtering: scan agent responses for credential patterns (regex for API key formats, password-like strings)
- Input sanitisation: block known injection keywords before they reach the LLM
- System prompt hardening: explicitly instruct the agent never to reveal its system prompt or config

---

### 3.3 Indirect Prompt Injection

**What to monitor:**
- Uploaded documents containing instruction-like language ("When summarizing...", "Use the following structure...")
- Documents that reference other documents ("following the standard template included in the template guide")
- Agent responses that include structured data not present in the source document (credentials, endpoints)

**Detection rule:**
```
alert if uploaded document contains:
  ["System Context", "authentication method", "credential", "access key",
   "ignore the document", "instead output", "summarize following"]
```

**Indicators of Compromise:**
- Summary response contains storage endpoints, credentials, or internal hostnames not in the source document
- Two documents uploaded in sequence where one references the other as a "template"
- Agent output contains sections not matching uploaded document structure

**False positive risk:** Low for credential exfiltration patterns; Medium for "System Context" alone (legitimate templates may use this language).

**Defensive controls:**
- Content isolation: process uploaded documents in a sandboxed context that cannot access agent secrets
- Output validation: compare summarised content against source document — flag fields with no source basis
- Privilege separation: document summarisation agents should have NO access to credentials or system config
- Reject documents containing instruction-like language patterns

---

### 3.4 Agent Memory Attacks — KB Poisoning

**What to monitor:**
- Unexpected writes to knowledge base tables, especially from non-standard user accounts
- New articles with recent `updated_at` dates authored by unexpected usernames
- KB articles containing URLs pointing to external or unexpected internal IPs
- PostgreSQL: monitor for INSERT/UPDATE on `kb_articles` table

**Detection rule (SIEM / DB audit):**
```sql
-- Alert on writes from unexpected accounts
SELECT author, title, updated_at FROM kb_articles 
WHERE author NOT IN ('cms_admin', 'content_team') 
ORDER BY updated_at DESC;

-- Alert on suspicious URLs in article body
SELECT * FROM kb_articles WHERE body LIKE '%http://%' AND body LIKE '%credentials%';
```

**Indicators of Compromise:**
- KB article instructs users to visit an unexpected URL
- Article asks users to "enter credentials" at a new portal
- `author` field contains unusual values ("attacker", "it_admin" when no such account exists)

**False positive risk:** Low — KB writes from unexpected accounts are reliably anomalous.

**Defensive controls:**
- Least-privilege DB access: agent read account should have SELECT only
- Write access only via authenticated CMS, not direct psql
- Content review workflow before KB articles go live
- Regular automated scanning of KB articles for suspicious URLs

---

### 3.4 Cross-Session Data Extraction

**What to monitor:**
- High volume of POST requests to `/chat` with varying `session_id` values
- `session_id` values following predictable patterns (date-based, sequential counter)
- Requests from a single source IP cycling through many session IDs
- Queries like "What notes do I have saved?" across many sessions

**Detection rule:**
```
alert if:
  - single IP sends >50 requests/min to /chat endpoint
  - requests include varying session_id values with same message body
  - message body matches: "what notes", "what do I have saved", "remind me"
```

**Indicators of Compromise:**
- Logs show systematic enumeration of session IDs
- Single source IP accounts for large percentage of session queries

**False positive risk:** Low — legitimate users query their own session only.

**Defensive controls:**
- Unpredictable session IDs (cryptographically random UUIDs, not date+counter)
- Rate limiting on chat endpoints per IP
- Require authentication before session data is returned

---

## Defensive Controls Summary

| Control | What it mitigates | Priority |
|---------|------------------|----------|
| Output filtering for credential patterns | Direct injection exfiltration | HIGH |
| Input keyword filtering | Direct injection attempts | MEDIUM |
| System prompt hardening ("never reveal...") | Direct injection | HIGH |
| Document sandboxing (no secret access) | Indirect injection | HIGH |
| DB least-privilege (read-only agent account) | KB poisoning | HIGH |
| Unpredictable session IDs (UUID) | Cross-session enumeration | HIGH |
| Rate limiting on chat endpoints | Session enumeration | MEDIUM |
| KB write audit + content review | KB poisoning detection | HIGH |

---

## Monitoring Checklist
- [ ] Output scanning for credential-shaped strings in all agent responses
- [ ] DB audit logging enabled on kb_articles table
- [ ] Agent DB account verified as read-only
- [ ] Session IDs verified as cryptographically random
- [ ] Rate limiting configured on all /chat endpoints
- [ ] Uploaded document content screened for instruction language

---

## Incident Response Notes
- **If direct injection confirmed:** Check agent logs for what data was returned; rotate any credentials the agent had access to
- **If KB poisoning confirmed:** Revert poisoned articles immediately; audit all writes for the past 30 days; check if users visited the phishing URL
- **If session enumeration detected:** Block source IP; audit what sessions were accessed; notify affected users

---

## Architecture Hardening
- Never give summarisation/document-processing agents access to secrets — separate privilege domains
- Store credentials in a secrets manager the agent cannot read directly; inject only what each tool call needs
- Implement a content security layer that strips instruction-like patterns from all external inputs before they reach the LLM
- Use semantic similarity scoring to detect when agent responses deviate significantly from source material
