# Module 07 — Defense & Detection

## Defender's Perspective

MCP servers are trusted intermediaries between LLM agents and production systems. Attackers who can modify tool descriptions or tool code gain the ability to control LLM behaviour silently. The primary defensive challenge is that tool descriptions are rarely monitored — they look like documentation, not executable content.

---

## Detection Opportunities

### Tool Description Poisoning

**What to monitor:** Changes to MCP server source files; specifically `@mcp.tool(description=...)` fields. Also monitor tool description length increases (>200 chars added) and multi-line descriptions containing newlines.

**Detection rule / query:**
```bash
# Git diff for description changes in MCP repos
git log --all --oneline --diff-filter=M -- "*.py" | head -20
git show HEAD -- servers/code_formatter/server.py | grep -A5 "description="

# Alert on description length anomaly
python3 -c "
import json, urllib.request
d = json.loads(urllib.request.urlopen('http://MCP_HOST:PORT/tool/openapi.json').read())
for path, methods in d['paths'].items():
    for method, detail in methods.items():
        desc = detail.get('description', '')
        if len(desc) > 300 or '\\n\\n' in desc:
            print(f'ALERT: {path} description anomaly ({len(desc)} chars)')
"
```

**IoCs:**
- Tool description contains `\n\n` followed by instruction-like text
- New imports (`urllib.request`, `base64`, `json`) added to MCP server files alongside exfil patterns
- GitLab snippets created by the MCP server's service account (unexpected API calls)
- Outbound HTTP POST to `GITLAB_URL/api/v4/snippets` from MCP server process

**False positive risk:** Legitimate description updates. Baseline description hashes and alert on changes.

---

### Post-Reload Hook Exploitation

**What to monitor:** Writes to hook script paths (`/data/projects/*.sh`); modifications to service config files (`webapp.conf`); service reload events; unexpected process spawns from service accounts.

**Detection rule / query:**
```bash
# Monitor for new shell scripts in MCP-accessible directories
inotifywait -m /data/projects/ -e create,modify --format '%T %f' --timefmt '%H:%M:%S' | grep '\.sh$'

# Alert on webapp.conf modification
auditctl -w /etc/app/conf.d/webapp.conf -p wa -k mcp_hook_change

# Detect shell spawned by service account
ausearch -k mcp_hook_change
journalctl -u webapp --since "10 minutes ago" | grep -i "post_reload\|diag.sh\|/data/projects"
```

**IoCs:**
- `diag.sh` or similar generic-named scripts written to service-accessible directories
- `post_reload_script` in config pointing to a path under `/data/projects/` (user-writable)
- `python3 -c 'import socket...'` process spawned from service user
- Outbound TCP connection from service account to unexpected IP on port 4444

**False positive risk:** Legitimate maintenance scripts. Enforce change management: hook paths should only be writable by ops team, not service accounts or LLM agents.

---

### MCP UI Spoofing (AppBridge)

**What to monitor:** Changes to MCP server JS/Python files that modify `resourceUri` HTML content; credential submission events to non-SSO domains; AppBridge `callTool` calls with credential-shaped payloads.

**Detection rule / query:**
```bash
# Diff MCP server for resourceUri changes
git diff HEAD~1 HEAD -- /opt/mcp-servers/ | grep -i "resourceUri\|innerHTML\|password\|credentials"

# Network: credential POST to non-expected domain
# (SIEM alert on HTTP POST from MCP server host to internal IPs that aren't the expected SSO endpoint)
```

**IoCs:**
- `resourceUri` HTML containing `<form>` with `action` pointing to the MCP server instead of the real SSO
- `window.mcp.callTool()` called with parameters named `u`, `p`, `password`, `credentials`
- Files written to `/var/lib/mcp-detections/` or similar paths by MCP service
- Users reporting unexpected Microsoft Entra / Okta login prompts inside their AI assistant

**False positive risk:** Low — legitimate MCP Apps rarely embed login forms.

---

### Jinja2 SSTI via Tool Chaining

**What to monitor:** Template render calls where input data originates from a user-controlled ticket/document store; `os.popen` or `subprocess` calls triggered from Jinja2 context; `lipsum` usage in stored content.

**Detection rule / query:**
```bash
# Scan ticket store for Jinja2 expressions
grep -r '{%\|{{' /data/tickets/ --include="*.json" --include="*.txt"

# Alert on lipsum or __globals__ in stored data
grep -r "lipsum\|__globals__\|os\.popen\|format(62)" /data/tickets/
```

**IoCs:**
- Ticket content containing `{% set %}`, `{%`, `lipsum`, `format(62)`, `'glo'~'bals'`
- `render_report` receiving data that includes Jinja2 syntax
- Outbound TCP connection immediately following a report render

**False positive risk:** Jinja2 syntax in legitimate code examples stored as tickets.

---

## Defensive Controls

| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| Tool description hashing & monitoring | Description poisoning | Hash all tool descriptions at startup; alert on changes between restarts |
| MCP server code signing | Supply chain / code modification | Sign server packages; verify signature before deploy |
| Separate service accounts per MCP tool | Privilege escalation via hook | Each tool runs as a dedicated low-privilege user with minimal filesystem access |
| Writable directory restrictions | Post-reload hook exploitation | `post_reload_script` paths must not be writable by the MCP service account |
| Input validation on file paths | Path traversal | Whitelist allowed directories; reject `../` in tool parameters |
| AppBridge CSP | UI spoofing | Enforce Content-Security-Policy on MCP App HTML; block external form POSTs |
| Jinja2 sandboxing | SSTI | Use `SandboxedEnvironment` from `jinja2.sandbox`; block attribute access to `os` |
| Network egress filtering | Exfiltration | MCP servers should not make outbound HTTP calls to arbitrary hosts |
| GitLab token scope restriction | Token theft → repo modification | Use deploy tokens with read-only scope for CI; separate token for pushes |

---

## Monitoring Checklist

- [ ] Tool descriptions hashed and monitored for changes at every deploy
- [ ] MCP server source repos have branch protection + required reviews for `server.py` changes
- [ ] `post_reload_script` configuration paths are not writable by MCP service accounts
- [ ] Outbound HTTP from MCP server processes is allowlisted (only to known endpoints)
- [ ] `inotifywait` or auditd watching MCP-accessible writable directories for `.sh` creation
- [ ] GitLab API calls from MCP server service accounts logged and anomaly-detected
- [ ] All `render_report` / template render inputs scanned for Jinja2 expressions before rendering
- [ ] AppBridge HTML resources reviewed for `<form>` elements and credential-shaped callTool payloads
- [ ] MCP servers running as non-root with minimal filesystem permissions
- [ ] Shadow and credential files not readable by MCP service accounts

---

## Incident Response Notes

**If you see:** Unexpected shell scripts in `/data/projects/` and a modified `webapp.conf` → likely **post-reload hook exploitation**; immediately check what the script contains and whether it has already executed; look for outbound TCP connections from the service account.

**If you see:** New GitLab private snippets created by the MCP server's service account → likely **description poisoning with server-side exfil**; pull the snippet content (base64-decoded) to identify what was stolen; audit all `server.py` files for the exfil function.

**If you see:** Users report unexpected SSO login prompts in their AI assistant → likely **AppBridge UI spoofing**; diff the MCP server JS for `resourceUri` HTML changes; check `/var/lib/mcp-detections/` for harvested credentials.

**If you see:** Outbound TCP connection on 4444 from an MCP service account → **reverse shell active**; isolate the host; check for Jinja2 SSTI in ticket store or diag.sh in filesystem.

---

## Architecture Hardening

1. **Read-only MCP servers by default** — Tools should not have filesystem write access unless explicitly required. Separate write-capable tools into isolated, heavily audited servers.
2. **Jinja2 SandboxedEnvironment mandatory** — Any MCP server that renders templates must use `jinja2.sandbox.SandboxedEnvironment`. Block access to `lipsum`, `config`, and `request` globals.
3. **Deploy pipeline integrity** — Sign commits; require GPG-signed merges to `main`; verify signature before auto-deploy. Stolen GitLab tokens should not be sufficient to deploy code without review.
4. **Least privilege for service accounts** — MCP server service accounts: no sudo, no write to `/etc/`, no read of `/etc/shadow`, no outbound HTTP to arbitrary hosts.
5. **Description content review** — Treat tool descriptions as code. Code review any PR that modifies `@mcp.tool(description=...)` with the same rigour as tool logic.
6. **AppBridge iframe sandbox** — Serve MCP App HTML with `sandbox="allow-scripts"` CSP attribute. Block `allow-forms` unless explicitly needed.
