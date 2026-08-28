# Module 10 — Gaps & Missing Coverage

## Missing Coverage

### Threat Modeling Frameworks Beyond ATLAS (STRIDE, PASTA, LINDDUN)
**Status:** Not documented  
**Notes say:** MITRE ATLAS is the primary framework used  
**Gap:** STRIDE applied to AI components; PASTA (Process for Attack Simulation and Threat Analysis) for AI pipelines; LINDDUN for privacy threat modeling of LLM systems  
**Action needed:** [ ] Yes  [x] To revisit — ATLAS appears exam-primary

---

### Data Flow Diagram (DFD) Construction
**Status:** Not documented  
**Notes say:** Trust boundaries are numbered (TB-1 through TB-8) but DFD construction methodology not covered  
**Gap:** How to produce a formal Level 0/Level 1 DFD for an AI system; component labeling conventions; DFD → trust boundary mapping procedure  
**Action needed:** [ ] Yes  [x] To revisit

---

### Automated Assumption Register Tooling
**Status:** Mentioned as alternative path only  
**Notes say:** "Some engagement teams use a local LLM to maintain a structured register from raw notes"  
**Gap:** Specific tooling recommendations; how to structure machine-readable registers; diff-based update tracking  
**Action needed:** [ ] Yes  [x] Skip (manual discipline is the exam focus)

---

### Federated/Multi-Tenant AI System Threat Modeling
**Status:** Not documented  
**Notes say:** Single-tenant Nexus AI used in labs  
**Gap:** Threat modeling shared inference endpoints; multi-tenant vector DB isolation; cross-tenant data leakage via embedding similarity  
**Action needed:** [ ] Yes  [x] To revisit

---

### Threat Modeling for LLM-as-a-Service (External APIs)
**Status:** Not documented  
**Notes say:** All lab components are self-hosted  
**Gap:** Threat model for systems using OpenAI/Anthropic/Bedrock APIs; supply chain risks of external model providers; prompt logging by providers  
**Action needed:** [ ] Yes  [x] Skip (not in scope for self-hosted OSAI lab)

---

### Crown Jewel Ranking Methodology Formalisation
**Status:** Partially documented  
**Notes say:** Ranking criteria given (impact, access, trust boundary depth, confidence) but no scoring formula  
**Gap:** Formal scoring matrix; how to break ties between assets at same boundary depth; weighting factors  
**Action needed:** [ ] Yes  [x] To revisit

---

## Skipped Topics
- Automated register tooling — manual discipline is exam focus
- External LLM API threat modeling — not in scope for self-hosted OSAI lab

## To Revisit Before Exam
- STRIDE applied to AI components (may appear as framing question)
- DFD construction methodology
- Federated/multi-tenant threat modeling patterns
- Crown jewel ranking formalisation
