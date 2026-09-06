On-demand reference for the OSAI toolkit — the detail kept OUT of CLAUDE.md to save per-turn tokens. Print only the section in $ARGUMENTS; if empty, print the section menu and the full skill inventory.

$ARGUMENTS = optional section: inventory, example, decisiontree, dirtree, research, clonecheck, mcp. Empty → menu + inventory.

## Menu
```
/osai-help inventory     — every skill grouped by function
/osai-help example       — the Autonomy Contract worked example
/osai-help decisiontree  — what to do when stuck (flowchart)
/osai-help dirtree       — ~/osai directory + repo layout
/osai-help research      — research-agent example prompts + triggers
/osai-help clonecheck    — verify local repos are cloned (git clone block)
/osai-help mcp           — MCP server setup + .mcp.json entries
```

## inventory
**Lifecycle:** engage (init lab) · notes (findings+MITRE, SysReptor-ready) · cred-vault (add/list/query/spray/export) · report (compile) · retro (post-lab improvements) · triage (raw output → actionable)
**Reasoning:** plan (Autonomy Contract on state) · owasp (LLM Top 10 checklist) · chains (name the chain, show remaining links) · help (this)
**Recon/enum:** parallel-recon (fan-out nmap) · ai-hunter (fingerprint AI surface) · win-enum (Windows/AD standard-tool enum, no custom scripts)
**AI attacks:** rag-attack · embed (vector DB/inversion) · mcp-attack · a2a · cloud-loot · inject (prompt-injection payload cheat sheet)
**Traditional:** web · ad-attack (Kerberoast/delegation/DCSync/ADCS) · relay (coercion→NTLM relay) · linux-attack (privesc + container escape) · winpeas (parse PEAS) · hijack (DLL/PATH/LD_PRELOAD/python) · spray · pivot
**Cheat sheets:** bypass (AMSI/AV/CLM/Defender/LOLBin) · revshell · upload · transfer (tunnel/transfer/exfil)

## example
Autonomy Contract in action — mid-engagement handoff:
> Kapi: "We've enumerated ~half the AD, next target is the AI agent on :8000."
```
STATE:      AD chain ~50% mapped (low-priv creds, no DA path yet). Pivoting to the
            standalone AI agent on :8000 — 15 pts, independent of AD, higher EV now.
FINDINGS:   :8000 serves /.well-known/agent.json → A2A/agent framework, tool-enabled.
HYPOTHESES: 1) Indirect prompt injection via a tool it reads (file/web) — HIGH·15·agents trust tool output
            2) Direct jailbreak to leak the proof file — MED·15·may be filtered
            3) Rogue-agent registration / peer forge (MiTM) — MED·15·needs mesh access
RESEARCH:   ~/repos/OSAI (Attacking AI Agents) + hacktricks AI → documented pattern is
            tool-output injection (matches #1).
RECOMMENDED: #1 — highest likelihood, matches the documented attack, fastest to proof.
  → Manual:     curl the agent card, then POST the poisoned tool input (payload below)
  → Autonomous: /osai-a2a <host>:8000, stage exfil listener, fire injection, capture proof
NEXT:       proof → /osai-notes --flag; then back to the AD chain with any creds it leaks.
```
Then proceed autonomously unless redirected.

## decisiontree
```
Stuck on a host?
├─ Enum complete? NO → /osai-parallel-recon --deep (full 65535 + UDP top-20)
│                 YES → per open port:
│   ├─ tried known creds? → /osai-cred-vault --query <host>
│   ├─ web? → /osai-web ; AI? → /osai-ai-hunter → /osai-owasp
│   ├─ known CVE for version? → research agent vs hacktricks
│   └─ nothing → move on, return after more creds
├─ Shell but no privesc?
│   ├─ /osai-winpeas ; /osai-hijack ; /osai-linux-attack (incl container escape)
│   ├─ defense blocking? → /osai-bypass
│   └─ stuck → research agent vs InternalAllTheThings
├─ AI attack not landing?
│   ├─ shift style: direct → indirect → tool-abuse ; obfuscate past filters (/osai-inject)
│   ├─ research agent vs ~/repos/OSAI for the framework
│   └─ change angle: poison doc vs direct prompt vs SSRF
└─ Move laterally?
    └─ /osai-cred-vault --list → /osai-spray ; /osai-pivot ; /osai-relay (coercion) ; /osai-ad-attack
```

## dirtree
```
~/osai/
├── current -> labs/<active>     symlink all skills use
├── tools/  claude/(adaptix_mcp.py) arsenal/(winpeas,linpeas,SharpHound,Rubeus,PowerUp) ligolo/ AdaptixC2/ custom/
├── labs/<labname>/
│   ├── recon/       nmap, gobuster, ldap output
│   ├── loot/        findings.json, flags, exports
│   ├── screenshots/ flameshot captures
│   ├── state/       scope.md, creds.json, network_map.md, progress.md
│   └── www/         HTTP payload server root
└── repos/  hacktricks/ payloadsallthethings/ InternalAllTheThings/ OSAI/ seclists/ awesome-pentest/
```

## research
Spawn `subagent_type=Explore`, background it, name the repo, ask for copy-paste only:
> "Search ~/repos/payloadsallthethings/ for upload bypass — WAF evasion, double extensions, polyglots. Copy-paste payloads only, no prose."
> "Search ~/repos/hacktricks/ for <service> <version> exploitation + known CVEs. Check awesome-pentest for the standard tool. Commands only."
> "Search ~/repos/OSAI/ for attacks on <AI framework>. Which module, what's the documented chain?"
> "Search ~/repos/InternalAllTheThings/docs/active-directory/ for <ACL edge / delegation>. Exact command chain."

Triggers — research WITHOUT being stuck: new service/version, unfamiliar framework, new AI target type, before any custom payload, need a wordlist, Kapi asks "how do I…". Reactive: 2+ failed hypotheses, a defense blocking you.

## clonecheck
Run at /osai-engage; clone any missing repo (or tell Kapi if no git/network):
```bash
for r in \
  "https://github.com/HackTricks-wiki/hacktricks hacktricks" \
  "https://github.com/swisskyrepo/PayloadsAllTheThings payloadsallthethings" \
  "https://github.com/swisskyrepo/InternalAllTheThings InternalAllTheThings" \
  "https://github.com/danielmiessler/SecLists seclists" \
  "https://github.com/enaqx/awesome-pentest awesome-pentest"; do
  set -- $r; d=~/repos/$2; [ -d "$d" ] || git clone --depth 1 "$1" "$d"
done
ls ~/repos/OSAI 2>/dev/null || echo "[!] OSAI notes repo missing — clone from your remote"
```

## mcp
See the `.mcp.json` example shipped with the toolkit. Recommended default set (lean, low-risk):
- **BloodHound MCP** — clone bloodhound_mcp, generate a BH CE API token, set env vars, register in MCP config, upload your bloodhound-python collection. Read-only graph queries.
- **PentestMCP** — netexec/bloodhound/john/certipy/nmap wrapper for enumeration.
- **Garak MCP** — Python 3.11+, `uv`; clone EdenYavin/Garak-MCP, register; scans Ollama/OpenAI/HF/GGML.
- **AdStrike (optional, AD-only)** — 53 AD tools; heavy + autonomous. Connect ONLY during the AD phase, disconnect after (token + OPSEC). Enum-drive it; keep exploitation manual.
Review any MCP's code before running it; run on the Kali VM only.
