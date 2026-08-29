# Module 03 — Glossary: Attacking AI Agents

---

## A

**Agent (AI Agent)**
An LLM-powered system that reasons through multi-step tasks and takes actions via tools. Unlike a chatbot (single round-trip), an agent enters a loop: think → act → observe → repeat. Agents have broader attack surface than chatbots because they access real systems.

**AML.T0051.000 — LLM Prompt Injection: Direct**
MITRE ATLAS classification for direct prompt injection, where the attacker supplies the payload through the normal user input channel.

**AML.T0051.001 — LLM Prompt Injection: Indirect**
MITRE ATLAS classification for indirect prompt injection, where the payload is embedded in data the agent retrieves (documents, web pages, database records, API responses).

**AML.T0020 — Poison Training Data**
MITRE ATLAS classification for memory poisoning attacks that plant malicious content in data stores the agent reads from (knowledge bases, wikis, vector DBs).

**AML.T0024 — Exfiltration via ML Inference API**
MITRE ATLAS classification for cross-session data extraction via the agent's chat API — using normal API calls to retrieve other users' stored data.

---

## C

**Canary Token / Honeypot Credential**
A fake credential placed in a data store to detect unauthorized access. Triggering it alerts blue team. (See Module 02 for recognition patterns.)

**Content Scanner**
A defensive component that checks uploaded files or web content for injection phrases before the agent processes them. Typically operates per-file at upload time, not at inference time — blind to cross-document and CSS-concealed attacks.

**Crescendo Attack (Multi-Turn)**
A goal hijacking technique that spreads attacker intent across multiple innocent-looking messages in the same session. Each individual message passes per-message keyword scanning; the cumulative effect achieves the attacker's objective. Evades keyword density rules.

**Cross-Document Fragmentation**
An indirect injection technique that splits a payload across two uploaded files so that neither file individually contains a recognizable injection phrase. The payload assembles in the LLM's context window when both files are processed together.

---

## D

**Data Poisoning (KB Poisoning)**
Inserting malicious content into a shared data store (PostgreSQL wiki, vector DB) that the agent reads. Affects all future users who trigger a matching query. Analogous to stored XSS. Highest-impact memory attack because it persists until a human reviews the database.

**Direct Prompt Injection**
Injecting attack instructions through the agent's user-facing input channel (e.g., the `/chat` endpoint). The attacker directly types the payload. Easier to detect than indirect injection.

---

## E

**Enumerate-Attack-Detect-Evade Cycle**
The five-step methodology for attacking AI agents: (1) Enumerate the agent's capabilities; (2) Attack naively to confirm the vector; (3) Check SIEM for detection rules that fired; (4) Evade by bypassing the specific rule; (5) Confirm no alerts.

---

## G

**Goal Hijacking**
Redirecting an agent's objective through context manipulation, without using obvious injection phrases. The attacker reframes a request as a legitimate business need that naturally causes the agent to retrieve or disclose restricted data.

**Guardrail**
A defensive layer for AI agents: input filters (block known injection phrases), output scanners (prevent credential leakage in responses), content scanners (check uploaded documents), behavioral monitors (detect goal hijacking). Implemented as pattern-matchers — each has documented blind spots.

---

## I

**Indirect Prompt Injection**
Embedding attack instructions in data the agent retrieves from the environment (documents, web pages, database records, code files). The attacker never speaks to the agent directly. More dangerous than direct injection because: payloads persist, affect other users, and are harder to attribute.

**Input Filter**
A guardrail component that scans user messages for known injection phrases before they reach the LLM. Typically regex/keyword-based — evaded by rephrasing with legitimate business context.

---

## K

**Keyword Density Rule**
A SIEM detection heuristic that fires when a single user message contains ≥N sensitive keywords (e.g., ≥3 of: "confidential," "security audit," "infrastructure," "credentials"). Evaded by the crescendo technique (one keyword per message).

---

## L

**Long-Term Memory**
Agent memory that persists across sessions, stored in external databases (PostgreSQL, Redis, vector DBs) or knowledge bases. The target for data poisoning attacks. Shared across all users.

---

## M

**MinIO**
S3-compatible open-source object storage. Agents that use MinIO for document storage will have credentials (`access_key`, `secret_key`) in their configuration. After extraction, access with:
`AWS_ACCESS_KEY_ID=<key> AWS_SECRET_ACCESS_KEY=<secret> aws --endpoint-url http://<host>:9000 s3 ls`

---

## O

**Output Filter / Output Scanner**
A guardrail that checks the agent's response before delivery to the user. Scans for exact strings matching known credential formats or sensitive data patterns. Evaded by character spacing, base64 encoding, ROT13, or reversed text — any transformation that breaks exact substring matching.

---

## R

**ReAct (Reason + Act) Pattern**
The agent reasoning loop: User Message → Think → Choose Action → Execute Tool → Observe Result → (repeat) → Final Answer → Output Filter → Response. Each step is a potential injection point. Tool outputs enter the same token stream as user messages — no trust boundary exists.

**Recency Bias**
Agents with multiple matching KB articles prioritize the most recently updated one (`updated_at` field). Exploited in KB poisoning by setting the poisoned article's date to be more recent than the legitimate article.

**Refusal vs True Negative**
- **Refusal** ("I cannot provide that information"): the agent HAS the data but is blocked from sharing it. → Apply evasion.
- **True negative** ("I don't have information about that"): the data does NOT exist. → Wrong target or question framing.

---

## S

**Session Hijacking (Agent)**
Accessing another user's session data by guessing a valid session ID. Unlike traditional session hijacking (requires token theft), agent session IDs with predictable patterns (date + sequential counter) can be enumerated through the normal `/chat` API using the target's own session_id field.

**Short-Term Memory**
Agent memory within a single session (conversation history). Injections persist for the remainder of the session but do not affect other users. Cleared on session reset.

**Stored XSS (analogy)**
KB poisoning is the agent equivalent of stored XSS: write a malicious payload to a shared data store once; it executes for every subsequent user who queries the matching topic.

**System Prompt**
Hidden instructions prepended to an LLM's context that define its identity, rules, tool access, and behavioral constraints. Often contains sensitive data: internal URLs, database credentials, API keys, content filter keyword lists. The first extraction target in any agent engagement.

---

## T

**Tool Response Poisoning**
Injecting malicious instructions into data returned by an agent's tool calls (e.g., a database row, API response). The LLM processes tool output identically to user input — no trust boundary distinction.

**Two-File Chaining (Cross-Document Fragmentation)**
See *Cross-Document Fragmentation*.

---

## U

**uvicorn**
Python ASGI web server. Seeing `uvicorn` in an nmap service banner (`http uvicorn`) indicates a FastAPI or Starlette-based AI agent endpoint. These typically expose `/health`, `/openapi.json`, `/chat`, and endpoint-specific paths.

---

## V

**Visual Concealment**
CSS-based technique for hiding injection payloads in web pages served to browsing agents. CSS `font-size:0px` or `color:transparent` hides text from humans and content extraction pipelines, but the LLM receives the full raw HTML and processes hidden element text as instructions. Evades content logging rules that only log visible text.

---

*Last updated: Module 03 gap fill pass*
