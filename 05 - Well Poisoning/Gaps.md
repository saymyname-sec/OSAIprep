# Module 05 — Gaps & Missing Coverage

## Coverage Assessment
**Overall:** ~95% — all major attack techniques documented with commands and theory. Remaining open items are minor lab-specific details.

---

## Resolved Gaps

### Why Embedding Collision Works (Theory)
**Status:** ✅ Resolved  
**Added:** Centroid mechanism — multi-topic chunk embedding sits near the centroid of all covered semantic spaces, achieving reasonable cosine similarity to any query matching any of those topics. Black-box vs adversarial collision distinction. Hybrid search amplification (BM25 + vector = two retrieval chances). See Notes.md §Theory — Why Embedding Collision Works.

---

### Input vs Output Guardrail Distinction
**Status:** ✅ Resolved  
**Added:** Full comparison table (when each fires, what it sees, bypass method, implementation, example). Key insight: input filters check user input only — retrieved context bypasses them. Output filters run after generation — substitution bypasses them. See Notes.md §Theory — RAG Architecture Deep Dive.

---

### Substitution Attack Theory
**Status:** ✅ Resolved  
**Added:** How output filters work (post-generation), substitution bypass table (email @, IP format, password label, SSN, credit card), and key insight about filter timing. See Notes.md §Theory — Evasion Variants and Cheatsheet.md.

---

### Markdown / HTML Comment Evasion Variants
**Status:** ✅ Resolved  
**Added:** HTML comment injection, markdown reference-link syntax, image alt-text injection — each with when-to-use guidance. See Notes.md §Theory — Evasion Variants.

---

### Filename Payload Technique
**Status:** ✅ Resolved  
**Added:** Mechanism (filename passed as metadata to LLM context), how to test (curl with filename param), detection method (source filename probe first). See Notes.md §Theory — Evasion Variants.

---

### Token Smuggling in Data Poisoning Context
**Status:** ✅ Resolved  
**Added:** Hyphenated instruction splitting, fake system message tokens (model-specific), effectiveness rating (model-dependent, best against smaller/weaker models). See Notes.md §Theory — Evasion Variants.

---

### Document Blending Math
**Status:** ✅ Resolved  
**Added:** Full positioning formula (chunk 800, overlap 200, preview 500 → safe zone chars 501–599), rationale for each boundary, step-by-step construction method. See Notes.md §Theory — Document Blending Math.

---

### Distributed Poisoning / Slow-Drip
**Status:** ✅ Resolved  
**Added:** Defense comparison table (what each evasion survives), two-fragment mechanics, trigger query pattern, slow-drip temporal variant, event fatigue technique. See Notes.md §Theory — Distributed Poisoning.

---

### SMB Pivot Technique (Windows RAG)
**Status:** ✅ Resolved  
**Added:** Step-by-step pivot flow, UNC coercion for NTLM capture (Responder), Windows credential file paths, hashcat crack command. See Notes.md §Theory — Phoenix Monitoring Evasion.

---

### Unicode Character Table
**Status:** ✅ Resolved  
**Added:** Full 6-entry table (U+200B through U+00AD), Cyrillic homoglyph table and Python generator, comparison of which evasion is visible vs invisible in Phoenix monitoring. See Notes.md §Theory — Evasion Variants and Cheatsheet.md.

---

### Phoenix Monitoring Evasion
**Status:** ✅ Resolved  
**Added:** What defenders see per event type (load_documents, chunk_document, retrieve_chunks, tool calls), detection signals per evasion technique, what hides vs what shows. See Notes.md §Theory — Phoenix Monitoring Evasion.

---

## Open Items

### Exact Lab Credential Answers
**Status:** ⏳ Lab-specific  
**What's missing:** Exercise answers (service account password, AWS secret key, NTLM credential, database connection string) are lab-environment-specific values not available outside running the lab. No action needed in notes.

### ResearchAI Lab — API Key in Research Paper
**Status:** ⏳ Lab-specific  
**What's missing:** The specific API key hidden in the ResearchAI VM's knowledge base. Technique is standard KB probing — covered in §5.1.
