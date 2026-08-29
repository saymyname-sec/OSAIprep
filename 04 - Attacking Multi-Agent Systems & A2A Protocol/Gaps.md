# Module 04 — Gaps & Missing Coverage

## Coverage Assessment
**Overall:** ~95% — strong command coverage across all attack types, theory depth now added for all major gaps. Remaining open items are lab-specific details not present in course material.

---

## Resolved Gaps

### A2A Protocol Specification Internals
**Status:** ✅ Resolved  
**Added:** Task lifecycle states (submitted → working → completed/failed/canceled), full message format (`id`, `message.parts[]`, `state`, `metadata`), streaming vs non-streaming note, attack relevance of each field. See Notes.md §Theory — Multi-Agent Architecture.

---

### Agent Trust Hierarchy Theory
**Status:** ✅ Resolved  
**Added:** Confused deputy problem explanation with ASCII diagram, three trust violation types table (inter-agent, tool, system), framework security table (LangGraph/AutoGen/CrewAI/Swarm/Google A2A with attack implications). See Notes.md §Theory — Multi-Agent Architecture.

---

### Coordination Patterns with Attack Implications
**Status:** ✅ Resolved  
**Added:** Full table covering hub-and-spoke, peer-to-peer, hierarchical, and pipeline patterns — each with attack implication. See Notes.md §Theory — Multi-Agent Architecture.

---

### Full SIEM Detection Rules Table
**Status:** ✅ Resolved  
**Added:** 23-rule table (a2a-sales, a2a-rogue, a2a-spoof, a2a-poison, a2a-recon, a2a-correlation series) with trigger conditions and evasion techniques. See Notes.md §Theory — Detection & SIEM Rules.

---

### SQL Encoded Evasion (xp_cmdshell hex CAST)
**Status:** ✅ Resolved  
**Added:** Why encoding works, Python hex generator, full SQL block with DECLARE/CAST/EXEC pattern, nl-to-sql injection curl example. See Notes.md §Theory — SQL Encoded Evasion.

---

### Rogue Agent Response Tampering Code
**Status:** ✅ Resolved  
**Added:** Full FastAPI snippet with jitter, forward logic, response part mutation, agent card mirroring, exfil endpoint. See Notes.md §Theory — Rogue Agent Response Tampering.

---

### DNS vs Hosts File Evasion Comparison
**Status:** ✅ Resolved  
**Added:** Comparison table (access required, scope, persistence, SIEM rules triggered, evasion, stealth rating), nsupdate syntax, verification commands. See Notes.md §Theory — DNS vs Hosts File Evasion.

---

### Indirect Data Poisoning Methodology
**Status:** ✅ Resolved  
**Added:** Full attack path diagram, 5 evasion techniques (semantic disguise, fragmentation, Unicode tags, contextual activation, multi-language encoding) with curl examples, payload types table, unauthenticated endpoint discovery command. See Notes.md §Theory — Indirect Data Poisoning.

---

## Open Items

### ChromeExploit / Web Agent Attack
**Status:** ⏳ Not documented  
**What's missing:** Flask-based ChromeExploit setup (`mkdir -p ~/ChromeExploit && pip install flask`) is referenced but the attack path against a browser-driving agent is not detailed. No course material received for this technique.  
**Action:** Document when lab walkthrough is available.

### Web Content Injection via Visual Concealment (Multi-Agent Context)
**Status:** ⏳ Partially covered in Module 03  
**What's missing:** The `Web Content Injection Via Visual Concealment` subdirectory in the repo suggests a Module 04-specific variant. Module 03 CSS concealment technique documented there; A2A-specific application not yet detailed.  
**Action:** Check if exam tests this in a multi-agent context specifically.
