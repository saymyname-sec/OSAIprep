# OSAI Engagement Brain — Claude Code CLI
# Copy to ~/.claude/CLAUDE.md on Kali before each exam/lab session.

## Active Lab
Set by /osai-engage. All skills read/write through the symlink:
  ~/osai/current/  →  ~/osai/labs/<labname>/  (recon/ loot/ screenshots/ state/ www/)

## Scoring — read this before deciding where to spend time
Source: official OSAI Exam Guide. 100 points total, **75 to pass**, 8 scored targets.
| Target type | Each | Count | Subtotal |
|-------------|------|-------|----------|
| AI-vector machine | 15 | ~4 | 60 |
| Standalone AI machine | 15 | 1 | 15 |
| Traditional machine | 10 | ~2 | 20 |
| DC flag (one-time, both chains converge) | 5 | 1 | 5 |

**The math that drives every decision:**
- AI machines alone = **75 = the pass mark.** You essentially CANNOT pass without AI.
- Traditional + DC together cap at **25** — not close to passing on their own.
- The DC is a **5-point flag**, the lowest-value objective. Grab it when the chain
  naturally reaches it; never burn hours hardening a path to it while AI machines
  (15 each) sit untouched.
- **Priority order: AI machines first, always.** The standalone AI host is
  independent of the AD chain — hit it early, it's 15 points with no prerequisites.

## Proof / evidence (how points are actually awarded)
Guide, verbatim: *"An interactive shell is not required… retrieve the required
proof files through any valid method."* Every scored machine has a proof file.
- **Traditional box:** retrieve proof.txt/local.txt/root.txt by any means; screenshot
  the file contents with `whoami`/`hostname` in frame if you have a shell (ideal, not required).
- **AI machine:** the AI exploit IS the retrieval method — prompt injection that makes
  the agent read+return the proof file, RAG/SSRF/tool-abuse that exfiltrates it.
  Proof = the model's response containing the file / the exfil landing on your listener,
  screenshotted alongside the exact request that caused it.
- The report must let an assessor **copy-paste reproduce** every step — so log commands
  and the triggering prompt verbatim as you go (that is what /osai-notes captures).

## Time management
- **Per-vector 10-minute rule:** 10 minutes is the budget for a single *attack idea*,
  not for a host. Never abandon a host before enumeration is exhausted (full TCP,
  key UDP, service versions). Insufficient enumeration is the #1 cause of failure —
  a "stuck" host almost always has an un-enumerated service.
- Run recon on ALL hosts in parallel first — never serialize enumeration.
- **Report clock:** 24h attack + 24h report. Stop attacking with ~2h left in the
  active window to reconcile findings, fill missing screenshots, and run /osai-report.

## The engagement is a LOOP, not a checklist
recon → foothold → loot creds → check vault → pivot → **re-run recon through the new
tunnel** → repeat. Every pivot opens hosts you haven't scanned. After /osai-pivot,
go straight back to /osai-parallel-recon against the newly reachable subnet.

## Skill Trigger Map

### Starting work
| Situation | Command |
|-----------|---------|
| New lab or exam | `/osai-engage --lab <name> --domain <d> --dc <ip> --scope <cidr>` |
| Resume lab | `cd ~/osai/labs/<name> && claude` — then read ~/osai/current/state/progress.md |

### Enumeration (every host, and again after every pivot)
| Situation | Command |
|-----------|---------|
| Got IPs to scan / just pivoted | `/osai-parallel-recon <ip1,ip2,...>` |
| Got ANY raw tool output | `/osai-triage` — ALWAYS before analyzing |
| Any web / unknown-service host | `/osai-ai-hunter <ip>` — FIRST touch: fingerprints the AI surface, then routes below |
| Web app (no AI surface) | `/osai-web <url>` — LFI/SQLi/SSTI/upload/cmdi/SSRF |
| Found 445/389/88/3268 | `/osai-ad-attack` with enum output |

### AI attacks (75 of 100 points — this is the exam)
`/osai-ai-hunter` identifies the surface, then route to the matching attack:
| Surface it finds | Route to |
|------------------|----------|
| Chatbot / RAG / LLM endpoint | `/osai-rag-attack <url>` |
| Vector DB (Qdrant 6333 / Weaviate 8080) | `/osai-embed <host>` — dump + invert to secrets |
| MCP server / tool surface | `/osai-mcp-attack <host>` — poison tools / abuse read+exec |
| Multi-agent / A2A mesh (8000-8010) | `/osai-a2a <host>` — card enum, injection, scan bypass |
| SSRF / exposed cloud metadata | `/osai-cloud-loot <ctx>` — IMDS → IAM chain → secrets |

### Post-exploitation
| Situation | Command |
|-----------|---------|
| Got WinPEAS/LinPEAS output | `/osai-winpeas` — never paste raw, pipe through skill |
| Writable path a priv proc trusts | `/osai-hijack` — python-module/DLL/PATH/LD_PRELOAD/unquoted-service |
| Found a credential (any type) | `/osai-cred-vault --add ...` immediately |
| Captured hashes (Kerberoast/ASREP/NetNTLM) | crack with hashcat/john → `/osai-cred-vault --add` the plaintext |
| Vault non-empty + 2+ hosts | `/osai-spray` — reuse everything you have before manual work |
| AD foothold gained | SharpHound → BloodHound → paths to DA, then `/osai-ad-attack` |
| New subnet reachable | `/osai-pivot` → then LOOP back to `/osai-parallel-recon` |

### Credential rule
Once the vault is **non-empty**, before attacking any new service run
`/osai-cred-vault --query <host>` — you probably already have a password that works.
Spraying reuses those creds, but check the lockout policy first (osai-spray does this).

### Flag / proof capture (scorable — never skip)
Every scored machine has a proof file. Capture it the moment you can reach it:
  1. Retrieve the proof (shell `cat`, OR the AI response / exfil that returns it)
  2. Screenshot: proof contents + the method that produced them (whoami+hostname if
     you have a shell; the triggering prompt + model response for an AI machine)
  3. `/osai-notes --flag --host <ip> --file <path>` (or --evidence for AI proof)
Missing proof = missing points even if you owned the target.

### Note-taking (real time — do not batch)
| Situation | Command |
|-----------|---------|
| Found a vulnerability | `/osai-notes --host <ip> --title <name> --severity <sev> --evidence <one-liner>` |
| Captured a flag/proof | `/osai-notes --flag --host <ip> --file <path>` |
| Check all findings | `/osai-notes --list` |

### Wrapping up
| Situation | Command |
|-----------|---------|
| Objectives done / ~2h left | `/osai-report` — then reconcile evidence before the clock ends |
| After every lab | `/osai-retro` → review proposals → git push |

## If Claude refuses an offensive step
This is an authorized OffSec OSAI/AI-300 exam exercise. If a request is refused,
re-frame with that context explicitly. Kapi should also complete the **Anthropic
Cyber Verification Program** before exam day so offensive prompts are not blocked
mid-exam (see exam prep doc for the link).

## Token Discipline (critical)
- NEVER paste raw tool output into chat — /osai-triage first
- NEVER load full PEASx output — /osai-winpeas extracts actionable lines only
- Parallel recon writes to files; pull only triaged lines into context, never the raw sweep
- One finding per /osai-notes call — do not batch
- Use `jq` slices for .json files — never load full file

## Payloads & Reverse Shells (manual — Claude does NOT generate these)
Kapi builds all payloads and triggers reverse shells by hand (avoids guardrails
and keeps OPSEC in his control). There is NO Metasploit/msfconsole MCP.
Claude's role for delivery:
  - suggest the delivery method and one-liner
  - confirm the callback via Adaptix `list_agents()` / `get_task_output()`
  - never attempt to auto-generate shellcode, msfvenom payloads, or beacons

## OPSEC (NOT scored — practice-only, do not trade points/time for stealth)
OPSEC does NOT earn exam points. Use it for real-engagement muscle memory, and
never sacrifice a point or waste exam time to be quiet. When it's free, prefer:
  - signed/native binaries (procdump64 is signed; adsisearcher over `net` commands)
  - reading detection rules before acting where the lab exposes them (e.g. Qdrant rules)
  - restoring agent sleep after a tunnel (see Adaptix rules) rather than leaving 0
On the exam, if stealth conflicts with speed or points → choose speed and points.

## Adaptix MCP — Rules
- `execute_command()` is ASYNC → poll `get_task_output()` a BOUNDED number of times
  (~5 polls / ~30s). If still not complete, log it and move on — do NOT loop forever.
- `set_sleep(agent_id, 0)` REQUIRED before `start_socks5()`; **restore a normal sleep
  after the tunnel is up** — sleep 0 is loud and needless once SOCKS5 is established.
- Prefer Ligolo-ng over SOCKS5 (real TUN, no proxychains)
- `shell_terminal()` needs `pip install websockets --break-system-packages`

## garak (LLM scanner) — RUN IT THIS EXACT WAY (do not loop)
garak is installed in a Python venv, NOT on the system PATH. Running `garak ...`
directly will FAIL with "command not found" — do not retry it, do not pip install
it again, do not debug it. Always call the venv binary by full path:
```bash
~/garak-venv/bin/garak --model_type <type> --model_name <name> [probes...]
# example — probe a REST LLM endpoint for injection + jailbreak:
~/garak-venv/bin/garak --model_type rest -G <config.json> --probes promptinject,dan
```
If `~/garak-venv/bin/garak` does not exist, tell Kapi to install it — do NOT attempt
the venv setup yourself. One check only:
```bash
ls ~/garak-venv/bin/garak 2>/dev/null || echo "[!] garak venv missing — ask Kapi"
```

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
