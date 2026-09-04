# Module 03 — Gaps & Missing Coverage

## Coverage Assessment
**Overall:** ~90% — gap fill pass completed. Architecture theory, SIEM rules, all four attack techniques, and evasion mechanics now documented.

---

## ✅ Resolved Gaps

### 3.1 Understanding Single-Agent Architecture
**Status:** ✅ RESOLVED — Notes.md §3.1  
ReAct loop diagram, all 5 agent components with attack surface, input/output channel tables, the Enumerate-Attack-Detect-Evade cycle, health endpoint enumeration.

### Theory for 3.2 Direct Prompt Injection
**Status:** ✅ RESOLVED — Notes.md §3.2  
Why character spacing bypasses output filters (substring matching vs spaced tokens). Why framing bypasses input filters (keyword pattern-matching). SIEM rules table (6 rules with exact trigger patterns and bypasses). Full system prompt extraction walkthrough. Goal hijacking crescendo (multi-turn technique).

### Theory for 3.3 Indirect Prompt Injection
**Status:** ✅ RESOLVED — Notes.md §3.3  
Why two-file chaining works (per-file scanning vs combined LLM context). CSS visual concealment technique for browsing agents (font-size:0px / color:transparent). Code review agent import resolution attack (from config import Config). Why each evades specific SIEM rules.

### Theory for 3.4 Agent Memory Attacks
**Status:** ✅ RESOLVED — Notes.md §3.4  
Memory type taxonomy (in-context vs external KB vs episodic/session). Why KB poisoning is high-impact (shared state, persists until manual cleanup, recency bias). Evasion of imperative command rule via narrative phrasing. Session enumeration script (full Python code).

---

## ⚠️ Still Open

### Encoding Technique Coverage
**Status:** Partially documented  
**Notes:** Character spacing fully documented. Base64, ROT13, reversed text, and translation noted as alternatives but not tested against specific lab agents. In field: try multiple formats per target — model compliance varies (Qwen resists most encoding but cooperates with spacing).

### 3.5 Capstone Lab Specifics
**Status:** Partially documented (lab notes in Notes.md)  
**Notes:** Target port 8030, credentials found during lab run. Full step-by-step walkthrough not captured — if re-doing the capstone, apply: enumerate → probe tools → character-spacing extraction → psql with extracted creds → KB poison with narrative framing.

---

*Gap fill pass completed. All major technique gaps resolved from course material.*
