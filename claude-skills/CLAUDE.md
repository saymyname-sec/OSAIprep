# OSAI Engagement Brain — Claude Code CLI
# Copy to ~/.claude/CLAUDE.md on Kali before each exam/lab session.

## Active Lab
Set by /osai-engage. All skills read/write through the symlink:
  ~/osai/current/  →  ~/osai/labs/<labname>/  (recon/ loot/ screenshots/ state/ www/)

## The Objective (exam mental model)
- **Compromising the DC is the END of everything.** Once you have Domain Admin
  on the DC, the traditional side is done — stop enumerating other Windows hosts,
  capture the DC proof, and pivot remaining effort to AI-vector points.
- Score is AI-heavy: AI-vector 15pts + standalone AI 15pts = 30, traditional 10,
  DC 5. Do not sink hours into a traditional host when AI points are unclaimed.
- 2 hosts are non-vulnerable rabbit holes — identify and abandon them fast.

## Time Management (non-negotiable)
- **10-minute stuck rule:** if a host gives no progress in 10 minutes, write what
  you tried in progress.md, move to another host, come back later with fresh eyes.
- Run recon on ALL hosts in parallel first — never serialize enumeration.

## Skill Trigger Map

### Starting work
| Situation | Command |
|-----------|---------|
| New lab or exam | `/osai-engage --lab <name> --domain <d> --dc <ip> --scope <cidr>` |
| Resume lab | `cd ~/osai/labs/<name> && claude` — then read ~/osai/current/state/progress.md |

### Enumeration
| Situation | Command |
|-----------|---------|
| Got IPs to scan | `/osai-parallel-recon <ip1,ip2,...>` |
| Got ANY raw tool output | `/osai-triage` — ALWAYS before analyzing |
| Found web / unknown ports | `/osai-ai-hunter <ip>` — check for LLM/RAG/vector-DB/agent-card |
| Web app is the foothold | `/osai-web <url>` — LFI/SQLi/SSTI/upload/cmdi/SSRF |
| Found 445/389/88/3268 | `/osai-ad-attack` with enum output |

### Post-exploitation
| Situation | Command |
|-----------|---------|
| Got WinPEAS/LinPEAS output | `/osai-winpeas` — never paste raw, pipe through skill |
| Writable path a priv proc trusts | `/osai-hijack` — python-module/DLL/PATH/LD_PRELOAD/unquoted-service |
| Found a credential (any type) | `/osai-cred-vault --add ...` immediately |
| Have creds + 2+ hosts known | `/osai-spray` — spray everything you have before manual work |
| AD foothold gained | Run SharpHound → import to BloodHound → query paths to DA, then `/osai-ad-attack` |
| Need to reach new subnet | `/osai-pivot` |
| Found chatbot / LLM / RAG | `/osai-rag-attack <url>` |
| Linux privesc needed | `/osai-linux-attack` |

### AI-vector attacks (30 of 100 exam points — prioritise)
| Situation | Command |
|-----------|---------|
| Chatbot / RAG / LLM endpoint | `/osai-rag-attack <url>` |
| Vector DB (Qdrant 6333 / Weaviate 8080) | `/osai-embed <host>` — dump + invert to secrets |
| MCP server / tool surface | `/osai-mcp-attack <host>` — poison tools / abuse read+exec |
| Multi-agent / A2A mesh (8000-8010) | `/osai-a2a <host>` — card enum, injection, scan bypass |
| SSRF / exposed cloud metadata | `/osai-cloud-loot <ctx>` — IMDS → IAM chain → secrets |

### Credential rule (non-negotiable)
Before attacking ANY service: `/osai-cred-vault --query <host>`.
You probably already captured a password that works here. Check the vault first.

### Flag / proof capture (scorable — never skip)
When you find `proof.txt` / `local.txt` / `flag.txt` / `root.txt`:
  1. `cat` the file
  2. screenshot it in context (whoami + hostname + file contents visible)
  3. `/osai-notes --flag --host <ip> --file <path>` — logs it as scored proof
Missing proof = missing points even if you owned the box.

### Note-taking (real time — do not batch)
| Situation | Command |
|-----------|---------|
| Found a vulnerability | `/osai-notes --host <ip> --title <name> --severity <sev> --evidence <one-liner>` |
| Captured a flag/proof | `/osai-notes --flag --host <ip> --file <path>` |
| Check all findings | `/osai-notes --list` |

### Wrapping up
| Situation | Command |
|-----------|---------|
| DC owned / lab done | `/osai-report` |
| After every lab | `/osai-retro` → review proposals → git push |

## Token Discipline (critical)
- NEVER paste raw tool output into chat — /osai-triage first
- NEVER load full PEASx output — /osai-winpeas extracts actionable lines only
- One finding per /osai-notes call — do not batch
- Use `jq` slices for .json files — never load full file

## Payloads & Reverse Shells (manual — Claude does NOT generate these)
Kapi builds all payloads and triggers reverse shells by hand (avoids guardrails
and keeps OPSEC in his control). There is NO Metasploit/msfconsole MCP.
Claude's role for delivery:
  - suggest the delivery method and one-liner
  - confirm the callback via Adaptix `list_agents()` / `get_task_output()`
  - never attempt to auto-generate shellcode, msfvenom payloads, or beacons

## garak (LLM scanner) — RUN IT THIS EXACT WAY (do not loop)
garak is installed in a Python venv, NOT on the system PATH. Running `garak ...`
directly will FAIL with "command not found" — do not retry it, do not pip install
it again, do not debug it. Always call the venv binary by full path:
```bash
~/garak-venv/bin/garak --model_type <type> --model_name <name> [probes...]
# example — probe a local Ollama model for injection + jailbreak:
~/garak-venv/bin/garak --model_type rest -G <config.json> --probes promptinject,dan
```
If `~/garak-venv/bin/garak` does not exist, tell Kapi to install it — do NOT attempt
the venv setup yourself (it wastes tokens and he manages the venv). One check only:
```bash
ls ~/garak-venv/bin/garak 2>/dev/null || echo "[!] garak venv missing — ask Kapi"
```

## Adaptix MCP — Rules
- `execute_command()` is ASYNC → always follow with `get_task_output()`
- `set_sleep(agent_id, 0)` REQUIRED before `start_socks5()` — non-negotiable
- Prefer Ligolo-ng over SOCKS5 (real TUN, no proxychains)
- `shell_terminal()` needs `pip install websockets --break-system-packages`

## Directory Structure
```
~/osai/
├── current -> labs/<active>   symlink used by all skills
├── tools/
│   ├── claude/          adaptix_mcp.py
│   ├── arsenal/         winpeas.exe, linpeas.sh, SharpHound, Rubeus, PowerUp
│   ├── ligolo/          ligolo agent binaries
│   ├── AdaptixC2/       Adaptix C2 server
│   └── custom/          custom scripts
└── labs/
    └── <labname>/
        ├── recon/        nmap, gobuster, ldap output
        ├── loot/         findings.json, flags, exports
        ├── screenshots/  flameshot captures
        ├── state/        scope.md, creds.json, network_map.md, progress.md
        └── www/          HTTP payload server root
```
