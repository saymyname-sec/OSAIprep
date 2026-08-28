# Module 04 — Gaps & Missing Coverage

## Coverage Assessment
**Overall:** ~65% — strong command coverage across all 5 attack types. Missing: theory depth, A2A protocol spec internals, detection evasion rationale.

---

## Missing Coverage

### A2A Protocol Specification Internals
**Status:** Not documented  
**What's missing:** The formal A2A task lifecycle (submitted → working → completed/failed), message format (id, message.parts[], state), streaming vs non-streaming modes. Exam may test protocol structure.  
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### Agent Trust Hierarchy Theory
**Status:** Not documented  
**What's missing:** Why orchestrators trust downstream agents implicitly — the "confused deputy" problem applied to AI. Understanding this conceptually is important for exam scenario questions.  
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### Indirect Prompt Injection into A2A via Data Sources
**Status:** Partially covered (data poisoning section in link injection notes)  
**What's missing:** Full methodology for injecting via documents/databases that a worker agent retrieves — the indirect path that doesn't touch the orchestrator directly. See Module 3 + 5 connections.  
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### ChromeExploit / Web Agent Attack
**Status:** Setup command noted, not documented  
**What's missing:** The Flask-based ChromeExploit setup (`mkdir -p ~/ChromeExploit && pip install flask`) suggests a browser agent attack path. Not documented.  
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### Web Content Injection via Visual Concealment
**Status:** Sub-directory exists in repo, not processed  
**What's missing:** Separate technique — check Joplin notes for `Web Content Injection Via Visual Concealment.md`.  
**Action needed:** Add notes? [ ] Yes  [ ] Skip
