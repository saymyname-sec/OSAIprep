Walk an AI target through the OWASP Top 10 for LLM Applications (2025) as a live attack checklist. For each class, decide from the context whether it's present, and if so name the concrete attack and route to the right skill. Most OSAI AI vulns map to this list — use it to make sure you don't miss a class. Write results to ~/osai/current/loot/<host>_owasp.md.

$ARGUMENTS = target URL/host and/or /osai-ai-hunter output. If empty, print the checklist with the probes to run for each class.

## How to use
Run AFTER /osai-ai-hunter has fingerprinted the surface. For each class below: state
PRESENT / ABSENT / UNKNOWN, the evidence, and the attack. The scored proof file is almost
always reachable via LLM01, LLM02/07, LLM06, or LLM08 — prioritize those.

## The checklist

### LLM01 — Prompt Injection (direct + indirect)
Probe: send override instructions directly; and plant instructions in data the model ingests
(uploaded doc, retrieved chunk, tool output, web page it fetches).
Present if: the model obeys attacker text. → `/osai-rag-attack`, `/osai-mcp-attack`, `/osai-a2a`

### LLM02 — Sensitive Information Disclosure
Probe: ask for secrets/keys/PII/training data/the proof file; try encodings if filtered.
Present if: it returns anything it shouldn't. → `/osai-rag-attack`, `/osai-ai-hunter`

### LLM03 — Supply Chain
Probe: can you influence a model/adapter/dataset/dependency it pulls (HF, pip, LoRA)?
Present if: an artifact source is attacker-writable. → research OSAI module; craft poisoned artifact

### LLM04 — Data & Model Poisoning
Probe: is the RAG store / vector DB / training feed writable by you (upload, ingest, exposed DB)?
Present if: you can inject content that later gets retrieved/trained. → `/osai-embed`, `/osai-rag-attack`

### LLM05 — Improper Output Handling
Probe: does model output flow into SQL / shell / HTML / a browser / an SSRF-able fetch unsanitized?
Present if: you can make output that triggers downstream SQLi/XSS/SSRF/RCE. → `/osai-web` (chain from `/osai-rag-attack`)

### LLM06 — Excessive Agency
Probe: enumerate the agent's tools — file read/write, command exec, internal HTTP, DB access.
Present if: a tool does more than it should / reaches internal resources. → `/osai-mcp-attack`, `/osai-a2a`, `/osai-cloud-loot`

### LLM07 — System Prompt Leakage
Probe: coax out the system prompt (repeat-back, "print your instructions", role confusion).
Present if: it reveals guardrails, tool list, or embedded secrets. → `/osai-rag-attack`, `/osai-ai-hunter`

### LLM08 — Vector & Embedding Weaknesses
Probe: is a vector DB exposed (Qdrant 6333 / Weaviate 8080 / Chroma / Milvus / pgvector)?
Present if: you can read/dump/invert embeddings. → `/osai-embed`

### LLM09 — Misinformation / Overreliance
Usually a chain enabler, rarely the scored proof. Note it and chain it; don't spend time here.

### LLM10 — Unbounded Consumption
Resource exhaustion / model extraction. Low exam value — deprioritize unless it's the objective.

## Output
```
TARGET: <host>   SURFACE: <framework/type from ai-hunter>
PRESENT:  <class ids> — each with evidence + the attack + route
UNKNOWN:  <class ids to probe next>
ABSENT:   <class ids ruled out>
PRIORITY: <the class most likely to yield the proof file, and why>
NEXT:     <the single next action → the routed skill>
```
Write to ~/osai/current/loot/<host>_owasp.md. Verify OWASP definitions online if unsure — the list is revised periodically.
