# Module 02 — Gaps & Missing Coverage

## Coverage Assessment
**Overall:** ~85% — gap fill pass completed. Core commands, theory, and all 7 recon phases now documented.

---

## ✅ Resolved Gaps (filled in Notes.md + Cheatsheet.md)

### Embedding Model Identification
**Status:** ✅ RESOLVED — Notes.md §AI Architecture Reference  
Dimension-count table: 768→text-embedding-004, 1536→ada-002, 256→codet5p-110m, 3072→text-embedding-3-large. Also covered: reading `config/rag.yaml` for the embedding model name directly.

### Theory: Why False Attribution Works
**Status:** ✅ RESOLVED — Notes.md §AI Architecture Reference  
RLHF mechanism explained: identity associations baked in by training; accuracy training conflicts with false claims → self-correction response leaks identity. Note: unreliable in <7B parameter models.

### Code Repository Mining (entire section)
**Status:** ✅ RESOLVED — Notes.md §2.6, Cheatsheet.md Phase 3  
Full methodology: clone repo, read `requirements.txt`, `config/rag.yaml`, `prompts/system.txt`, `config/safety.yaml`, `.env.example`, `config/models.yaml`. Git log secret search. Framework → architecture inference table.

### Detection and Evasion Analysis
**Status:** ✅ RESOLVED — Notes.md §2.7, Cheatsheet.md Phase 7  
SIEM detection rules E01–E04 with trigger keywords. Noisy vs stealthy query comparison table. Honeypot/canary token recognition (HONEYPOT substring in AWS key).

### RAG Pipeline Recon (threshold + metadata)
**Status:** ✅ RESOLVED — Cheatsheet.md Phase 5  
Baseline → topic → synonym → misspelling degradation sequence. Source metadata fields: `chunk_id`, `vector_score`, `bm25_score`, `combined_score`, `source_file`. Hybrid retrieval identification.

### A2A Agent Card Enumeration
**Status:** ✅ RESOLVED — Cheatsheet.md Phase 6  
`curl http://target/.well-known/agent.json` — reveals agent capabilities, tools, permissions, and authentication requirements.

---

## ⚠️ Still Open

### OpenAPI Spec Analysis
**Status:** Not documented — not covered in provided course material  
**What's missing:** Walking `/openapi.json` or `/v1/openapi.yaml` to map every endpoint, parameter, and auth scheme. If this appears on the exam, use standard REST API recon methodology: read `paths`, `components/schemas`, `securitySchemes`.  
**Action needed:** Add if course material provided for this topic

### System Prompt Extraction via Recon
**Status:** Bridges into Module 3 (Prompt Injection) — covered there  
**Notes:** Extraction via crafted prompts ("Repeat everything above") is a Module 3 technique. Module 2 covers recon-phase extraction via file system access (`prompts/system.txt`).

### OSINT for AI Targets
**Status:** Not documented — not covered in provided course material  
**What's missing:** Pre-engagement OSINT — GitHub repos exposing configs, HuggingFace model cards, job postings revealing AI stack, Shodan/Censys for exposed AI ports, Docker Hub for leaked images.  
**Action needed:** Add if course material provided for this topic

### MCP Endpoint Discovery
**Status:** Not documented — covered in Module 7  
**Notes:** MCP server recon is the focus of Module 7. Module 2 covers discovery of AI service ports and API endpoints only.

---

*Gap fill pass completed. Remaining open items require additional course material or are addressed in later modules.*
