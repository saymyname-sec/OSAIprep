# Module 07 — Gaps & Missing Coverage

## Missing Coverage

### AppBridge Internal Protocol
**Status:** Partially documented  
**What's missing:** The internal `window.mcp.callTool()` API format, how the iframe communicates credentials back to the server, and how AppBridge authentication works between the UI and the MCP server.  
**Action needed:** Add notes from lab observation or OffSec course slides.

---

### MCP Tool Approval Flow
**Status:** Not documented  
**What's missing:** How the host presents tool approval dialogs, what triggers a new approval vs. reuse of existing approval, and how to enumerate pre-approved tools on a target system.  
**Action needed:** Document from lab experience with Claude Desktop / Open WebUI.

---

### stdio Transport vs HTTP Transport
**Status:** Not documented  
**What's missing:** MCP supports both stdio (local process) and HTTP transport. Attack surface differs — stdio tools can't be remotely poisoned without host access; HTTP tools can. Distinction matters for exam scenarios.  
**Action needed:** Add one paragraph distinguishing attack paths for each transport.

---

### MCP Resource Poisoning
**Status:** Not documented  
**Syllabus reference:** Attacking resources (not just tools) — MCP servers can expose file resources that agents read automatically as context.  
**Action needed:** Research and add section on poisoning MCP resources.
