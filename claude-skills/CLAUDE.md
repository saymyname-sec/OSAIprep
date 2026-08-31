# OSAI Engagement Brain — Claude Code CLI
# Copy to ~/.claude/CLAUDE.md on Kali before each exam/lab session.

## Active Lab
Set by /osai-engage. All state lives under:
  ~/osai/labs/<labname>/  →  recon/ loot/ screenshots/ state/ www/

## Skill Trigger Map

### Starting work
| Situation | Command |
|-----------|---------|
| New lab or exam | `/osai-engage --lab <name> --domain <d> --dc <ip> --scope <cidr>` |
| Resume lab | `cd ~/osai/labs/<name> && claude` |

### Enumeration
| Situation | Command |
|-----------|---------|
| Got IPs to scan | `/osai-parallel-recon <ip1,ip2,...>` |
| Got ANY raw tool output | `/osai-triage` — ALWAYS before analyzing |
| Found web / unknown ports | `/osai-ai-hunter <ip>` — check for LLM/RAG too |
| Found 445/389/88/3268 | `/osai-ad-attack` with enum output |

### Post-exploitation
| Situation | Command |
|-----------|---------|
| Got WinPEAS/LinPEAS output | `/osai-winpeas` — never paste raw, pipe through skill |
| Found a credential (any type) | `/osai-cred-vault --add ...` immediately |
| Need to reach new subnet | `/osai-pivot` |
| Found chatbot / LLM / RAG | `/osai-rag-attack <url>` |
| Linux privesc needed | `/osai-linux-attack` |

### Note-taking (real time — do not batch)
| Situation | Command |
|-----------|---------|
| Found a vulnerability | `/osai-notes --host <ip> --title <name> --severity <sev> --evidence <one-liner>` |
| Check all findings | `/osai-notes --list` |

### Wrapping up
| Situation | Command |
|-----------|---------|
| Lab/exam done | `/osai-report` |
| After every lab | `/osai-retro` → review proposals → git push |

## Token Discipline (critical)
- NEVER paste raw tool output into chat — /osai-triage first
- NEVER load full PEASx output — /osai-winpeas extracts actionable lines only
- One finding per /osai-notes call — do not batch
- Use `jq` slices for .json files — never load full file

## Adaptix MCP — Rules
- `execute_command()` is ASYNC → always follow with `get_task_output()`
- `set_sleep(agent_id, 0)` REQUIRED before `start_socks5()` — non-negotiable
- Prefer Ligolo-ng over SOCKS5 (real TUN, no proxychains)
- `shell_terminal()` needs `pip install websockets --break-system-packages`

## Payload Delivery
Kapi creates payloads manually. Claude's role: suggest delivery command, confirm receipt via get_task_output(), log callback via list_agents().

## Directory Structure
```
~/osai/
├── tools/
│   ├── claude/          adaptix_mcp.py
│   ├── arsenal/         winpeas.exe, linpeas.sh, SharpHound, Rubeus, PowerUp
│   ├── ligolo/          ligolo agent binaries
│   ├── AdaptixC2/       Adaptix C2 server
│   └── custom/          custom scripts
└── labs/
    └── <labname>/
        ├── recon/        nmap, gobuster, ldap output
        ├── loot/         findings.json, creds.json, flags
        ├── screenshots/  flameshot captures
        ├── state/        scope.md, network_map.md, progress.md
        └── www/          HTTP payload server root
```
