# Module 07 — Gaps & Missing Coverage

## Resolved (All primary content)

### MCP Architecture and Transport Types
**Status:** ✅ Covered  
**Notes.md:** Transport type table (stdio/SSE/HTTP), tool schema structure, config file locations per platform.

### MCP Enumeration Techniques
**Status:** ✅ Covered  
**Notes.md:** 5-step enumeration workflow — config reading, tool listing, schema extraction, cross-tool correlation, permission boundary mapping, git history secret recovery.

### MITRE Mappings (AML.T0010.005, AML.T0051.001, AML.T0085)
**Status:** ✅ Covered  
**Notes.md + Cheatsheet.md:** All three techniques with descriptions and context.

### Tool Description Poisoning (Dual-Layer Attack)
**Status:** ✅ Covered  
**Notes.md:** Full theory (description field = blind injection point, two newline separator, dual-layer mechanism), complete lab implementation (GitLab token, clone, inject description SYSTEM INSTRUCTION, add exfil block, commit/push, verify via openapi.json, retrieve snippets). Code blocks for each step.

### MCP Apps UI Poisoning / Credential Harvesting
**Status:** ✅ Covered  
**Notes.md:** MCP Apps rendering (srcdoc iframe, AppBridge postMessage), server-side HTML swap strategy, poisoned format_document description fragment, AppBridge exfil JS code, credential retrieval and decode commands.

### Over-Privileged MCP Servers (AML.T0085)
**Status:** ✅ Covered  
**Notes.md:** Theory (advertised scope vs actual privilege), exploitation prompts (table enum, PII join, API keys dump, role query).

### Path Traversal Bypass (CVE-2025-53109/53110)
**Status:** ✅ Covered  
**Notes.md:** Prefix-before-normalization flaw, exploit path, victim prompt, fix (realpath before check). Cheatsheet.md has one-liner.

### Symlink Escape (normpath vs realpath)
**Status:** ✅ Covered  
**Notes.md:** Symlink flaw mechanics, normpath vs realpath comparison table, victim prompt, fix. Cheatsheet.md has one-liner.

### Tool Chaining SSTI (Jinja2 via Sprint Tools)
**Status:** ✅ Covered  
**Notes.md:** Data flow diagram, why lipsum not arithmetic, DAST framing bypass, SSTI confirmation, RCE PoC, full 12-ticket reverse shell chain with chr-encoding table, three LLM safety bypass techniques (verbatim prefix, chr-encoding, urgency framing), urgency trigger prompt.

### Shell Injection via Log Export
**Status:** ✅ Covered  
**Notes.md + Cheatsheet.md:** Brief coverage (same store-aggregate-process pattern, shell metacharacter injection via export_logs).

### Glossary
**Status:** ✅ Covered  
**Glossary.md:** 35 terms covering all major concepts.

---

## Open Items

### Capstone Lab Details (7.3.4)
**Status:** Partially documented (chain summary only)  
**What is missing:** Exact tool names, credential hop path, and weaponization mechanism on assist01 are environment-specific and not fully disclosed in course text. The chain summary in Notes.md covers the logical flow.  
**Action needed:** Fill in after completing the capstone lab.

### JSON-RPC Message Format Detail
**Status:** Not explicitly documented  
**What it is:** MCP uses JSON-RPC 2.0 for all communication. Method names like `tools/list`, `tools/call`, `initialize` are the core protocol methods. AppBridge uses the same format.  
**Action needed:** Low priority — understand the postMessage example in Notes.md covers the format.

### MCP Server Discovery / Nmap NSE
**Status:** Not documented  
**What it is:** In recon phase (Module 02), identifying MCP server ports (8000, 3000, etc.) via Nmap. No dedicated MCP NSE script; identify by HTTP response characteristics (SSE event-stream content-type, JSON-RPC responses).  
**Action needed:** Cross-reference with Module 02 notes.
