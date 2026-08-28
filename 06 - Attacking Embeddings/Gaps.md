# Module 06 — Gaps & Missing Coverage

## Missing Coverage

### ALGEN (Alignment Generation)
**Status:** Partially documented  
**What it is:** A technique mentioned in inference_probe.py output (`--save-pairs` flag generates alignment pairs for ALGEN). The pairs (text ↔ vector) are used to fine-tune an attack model to perform direct inversion. Not fully covered in notes.  
**Action needed:** Add notes? [ ] Yes — low exam priority, understand conceptually

---

### Weaviate GraphQL Pagination (cursor-based)
**Status:** Not fully documented  
**Syllabus relevance:** The export script handles large collections via GraphQL cursor pagination (`after:` argument). Notes cover the concept but the full paginated export script was referenced but not shown in detail.  
**Action needed:** Script is in Scripts/ directory — reference it from notes.

---

### Qdrant Scroll API export
**Status:** Not documented  
**What it is:** Qdrant uses a REST `POST /collections/{name}/points/scroll` with `next_page_offset` for pagination, analogous to Weaviate's GraphQL cursor.  
**Action needed:** Add notes? [ ] Yes — add basic Qdrant scroll export one-liner

---

### Alternative Vector DB Targets
**Status:** Not documented  
**Syllabus relevance:** ChromaDB (default port 8000), pgvector (PostgreSQL), Pinecone (cloud). Notes only cover Weaviate and Qdrant.  
**Action needed:** Add notes? [ ] To revisit — low priority for this course's lab environments

---

### Model Fingerprinting — Candidate Model List by Dimension
**Status:** Partially documented  
**Current state:** Notes mention the four common dimensions. Missing: the full candidate list per dimension as used in `inference_probe.py` `CANDIDATE_MODELS` dict.  
**Action needed:** Add the CANDIDATE_MODELS mapping from the script to the Cheatsheet

