# Module 07 — Glossary

**MCP (Model Context Protocol):** Open standard protocol connecting LLM agents to external tools, data sources, and services via a client-server architecture.

**MCP Host:** The LLM-powered application that discovers and calls MCP tools (e.g. Claude Desktop, VS Code with Copilot, Open WebUI).

**MCP Server:** A process exposing tools, resources, and prompts to MCP clients. Often runs with elevated privileges.

**MCP App:** An HTML page rendered by the MCP host inside an iframe, returned by an MCP tool as a `resourceUri`. Enables rich UI inside the AI assistant.

**AppBridge:** API (`window.mcp.callTool()`) that allows JavaScript inside an MCP App iframe to invoke server-side tool functions, enabling bidirectional communication between rendered UI and the MCP server.

**Tool Description Poisoning:** Injecting hidden LLM instructions into an MCP tool's `description` field to manipulate agent behaviour or suppress disclosure of exfiltrated data.

**Post-Reload Hook:** A configuration field (`post_reload_script`) that specifies a shell script to execute when a service is reloaded. Exploited by writing a malicious script to the hook path via an MCP filesystem tool, then triggering a reload.

**Jinja2 SSTI:** Server-Side Template Injection in Jinja2 template engine. Exploited via `lipsum.__globals__['os'].popen()` to achieve RCE. Requires payload splitting to bypass LLM safety filters.

**Payload Splitting:** Technique for bypassing LLM safety filters by distributing a complete exploit payload across multiple separate tool calls or prompts, where each fragment is individually innocuous.

**GitLab Private Token (glpat-):** Personal access token for GitLab API authentication. Stolen tokens allow repo enumeration, source code read, and (with write scope) code modification.

**sha512crypt (hashcat mode 1800):** Password hashing format used in Linux `/etc/shadow`. Field starts with `$6$`.
