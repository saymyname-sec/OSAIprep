# Module 06 — Gaps & Missing Coverage

## Resolved

### ALGEN (Alignment Generation)
**Status:** ✅ Resolved  
**Resolution:** Full ALGEN theory added to Notes.md — canary injection vs synthetic alignment table, RAG probe attack workflow (rag_probe_attack.py: keyword extraction → probing → redaction marker detection → slot filling), FlanT5-small decoder training mechanics, alignment matrix concept. Covered in Glossary.md.

### Weaviate GraphQL Pagination (cursor-based)
**Status:** ✅ Resolved  
**Resolution:** Full paginated export Python snippet added to Notes.md (cursor-based `after=` UUID pagination, loop termination condition, output to embeddings.npy). Key snippet also in Cheatsheet.md.

### Qdrant Scroll API export
**Status:** ✅ Resolved  
**Resolution:** Qdrant REST scroll API documented in Notes.md — single-page curl command and paginated Python export using `next_page_offset`. Added to Cheatsheet.md.

### Alternative Vector DB Targets
**Status:** ✅ Partially resolved (low priority for this course)
**Resolution:** Weaviate and Qdrant fully documented. ChromaDB (port 8000) and pgvector noted as alternative targets — not primary lab targets so not expanded further.

### Model Fingerprinting — Candidate Model List by Dimension
**Status:** ✅ Resolved  
**Resolution:** Full CANDIDATE_MODELS table added to Notes.md (all dimensions 384/768/1024/1536/3072 with all candidate models per dimension) and to Cheatsheet.md for quick reference. Manual inference probing code snippet included.

### Three Attack Categories (Inversion / Membership / Attribute)
**Status:** ✅ Resolved  
**Resolution:** Full theory section added to Notes.md with comparison table and attacker implications for each category. Defined in Glossary.md.

### Four Inversion Approaches Comparison
**Status:** ✅ Resolved  
**Resolution:** Comparison table (Zero-Shot, Few-Shot/ALGEN, Supervised/Vec2Text, Surrogate/Transfer) with model-known/training-data/time/accuracy/when-to-use columns added to Notes.md. Quick 30-second version in Cheatsheet.md.

### Inversion Limitations
**Status:** ✅ Resolved  
**Resolution:** Limitations table added to Notes.md covering token length cap, high-entropy tokens, model identification requirement, dimensionality reduction, domain mismatch, cosine similarity gap. High-entropy recovery path explained.

### Vec2Text Two-Stage Architecture
**Status:** ✅ Resolved  
**Resolution:** Full architecture diagram (MLP projection → T5 inverter → T5 corrector with residual attention), progressive fill-and-lock explanation, and training/inference times added to Notes.md. 5-second summary in Cheatsheet.md.

### ALGEN Canary Injection Theory
**Status:** ✅ Resolved  
**Resolution:** Canary injection vs synthetic vs RAG probing comparison table, rag_probe_attack.py workflow, FlanT5-small training details fully documented in Notes.md.

### zero2text_impl.py Beam Search Mechanics
**Status:** ✅ Resolved  
**Resolution:** GPT-2 dual-embedder mode, beam search with cosine scoring, entropy detection for slot filling trigger, command template — all added to Notes.md and Cheatsheet.md.

### Decision Matrix (Tool Selection)
**Status:** ✅ Resolved  
**Resolution:** Full decision tree diagram (flowchart) + quick-ref table added to Notes.md. Summary table in Cheatsheet.md.

### Membership Inference Mechanics
**Status:** ✅ Resolved  
**Resolution:** emb_fin.py membership inference internals documented: attractor candidates, adaptive selection, diversity clustering, two-stage narrowing, margin-aware scoring (HIGH/MODERATE/LOW thresholds), false positive avoidance. Added to Notes.md and Cheatsheet.md.

### MITRE Mappings
**Status:** ✅ Resolved  
**Resolution:** AML.T0024 and AML.T0024.000 mapping table added to Notes.md Theory section and Cheatsheet.md quick reference.

### Glossary
**Status:** ✅ Resolved  
**Resolution:** Glossary.md created with 35 terms covering all major concepts: ALGEN, AML.T0024/T0024.000, alignment matrix, attractor candidate, attribute inference, beam search, canary injection, chunk_triage_pipe.py, contrastive probing, corrector, cosine similarity gap, density scoring, dimensionality, diversity clustering, domain mismatch, emb_fin.py, embedding inversion, embedding model fingerprinting, entropy detection, few-shot inversion, generate_templates.py, high-entropy token, inference_probe.py, inverter, margin-aware scoring, membership inference, MLP projection, normalization, product quantization, progressive fill-and-lock, rag_probe_attack.py, RRF, slot filling, supervised inversion, surrogate/transfer attack, template bank, Vec2Text, zero-shot inversion, Zero2Text, ZSInvert.

---

## Open Items

### ChromaDB and pgvector Enumeration
**Status:** Low priority — not a primary lab target in OSAI modules  
**What it is:** ChromaDB (default port 8000) and pgvector (PostgreSQL extension) are alternative vector stores. `GET http://TARGET:8000/api/v1/collections` for ChromaDB; `SELECT * FROM pg_vector_table LIMIT 1` for pgvector.  
**Action needed:** Only if these appear in a capstone environment.

### ALGEN Training Script (full code)
**Status:** Conceptually covered, script in Scripts/ directory  
**What it is:** The FlanT5-small training loop is in Scripts/algen_train.py — referenced but not reproduced in Notes.md.  
**Action needed:** Low priority; understand the concept; use script as-is in lab.
