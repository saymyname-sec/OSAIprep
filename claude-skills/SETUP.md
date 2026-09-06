# OSAI Toolkit — Kali Machine Setup

Complete prep guide to run the OSAI Claude Code engagement toolkit on Kali. Do this
BEFORE exam/lab day. Work top-to-bottom; each section is idempotent (safe to re-run).

Assumes user `kapi`. Replace paths if your username differs.

---

## 0. What this toolkit is (3 layers)

| Layer | What | Where it goes |
|-------|------|---------------|
| **CLAUDE.md** | Always-on engagement brain (lean router) | `~/.claude/CLAUDE.md` |
| **27 skills** | On-demand `/osai-*` slash commands | `~/.claude/commands/` |
| **MCP servers** | Local tool bridges (C2, AD, AI scan) | `.mcp.json` at project root |

Plus: a `~/osai/` working tree, a `~/repos/` knowledge base, an arsenal of binaries,
a garak venv, Adaptix C2, and Ligolo. All covered below.

The two other-product instruction files (`CLAUDE-CHAT-instructions.md`,
`CLAUDE-COWORK-instructions.md`) are NOT for the CLI — paste those into claude.ai and
Cowork respectively. They do not use skills or local paths.

---

## 1. Prerequisites

```bash
# Claude Code CLI
npm install -g @anthropic-ai/claude-code   # or the official installer
claude --version

# Core system deps
sudo apt update
sudo apt install -y git python3 python3-pip python3-venv pipx jq nmap \
  netexec impacket-scripts bloodhound.py certipy-ad kerbrute \
  seclists gobuster ffuf sqlmap john hashcat evil-winrm socat proxychains4 flameshot
pipx ensurepath
```
> `netexec` is the renamed CrackMapExec (binary `nxc`). If your repo only has
> `crackmapexec`, `pipx install netexec`.

---

## 2. Install CLAUDE.md + skills

```bash
mkdir -p ~/.claude/commands
# from your cloned OSAI repo:
cd ~/repos/OSAI/claude-skills   # or wherever you cloned it

cp CLAUDE.md ~/.claude/CLAUDE.md
cp osai-skills/*.md ~/.claude/commands/
ls ~/.claude/commands | wc -l   # expect 27
```
Verify in a `claude` session: type `/osai-help` — it should list the skill inventory.

**The 27 skills:**
```
Lifecycle : engage notes cred-vault report retro triage
Reasoning : plan owasp chains help
Recon/enum: parallel-recon ai-hunter win-enum
AI attacks: rag-attack embed mcp-attack a2a cloud-loot inject
Traditional: web ad-attack relay linux-attack winpeas hijack spray pivot
Cheat sheet: bypass revshell upload transfer
```
> If your cheat-sheet skills (bypass/revshell/upload/transfer) live in the repo's
> `.claude/commands/` instead of `claude-skills/osai-skills/`, copy those too:
> `cp ~/repos/OSAI/.claude/commands/osai-*.md ~/.claude/commands/`

---

## 3. Working directory tree

```bash
mkdir -p ~/osai/tools/{claude,arsenal,ligolo,AdaptixC2,custom} ~/osai/labs
# /osai-engage creates each lab's recon/ loot/ screenshots/ state/ www/ and the
# ~/osai/current symlink. Nothing to pre-create per lab.
```
Final shape:
```
~/osai/
├── current -> labs/<active>     (set by /osai-engage)
├── tools/   claude/ arsenal/ ligolo/ AdaptixC2/ custom/
└── labs/<labname>/  recon/ loot/ screenshots/ state/ www/
```

---

## 4. Knowledge-base repos (the research answer key)

Skills spawn Explore agents against these. `/osai-engage` also checks them.
```bash
mkdir -p ~/repos && cd ~/repos
for r in \
  "https://github.com/HackTricks-wiki/hacktricks hacktricks" \
  "https://github.com/swisskyrepo/PayloadsAllTheThings payloadsallthethings" \
  "https://github.com/swisskyrepo/InternalAllTheThings InternalAllTheThings" \
  "https://github.com/danielmiessler/SecLists seclists" \
  "https://github.com/enaqx/awesome-pentest awesome-pentest"; do
  set -- $r; [ -d "$2" ] || git clone --depth 1 "$1" "$2"
done
# Your own OSAI notes:
[ -d OSAI ] || git clone <YOUR_OSAI_REMOTE> OSAI
```

---

## 5. Arsenal (binaries the skills reference)

Drop these in `~/osai/tools/arsenal/` (and keep a copy in a lab's `www/` to serve):
```
winPEASx64.exe  linpeas.sh  SharpHound.exe / SharpHound.ps1  Rubeus.exe
PowerUp.ps1  PowerView.ps1  Seatbelt.exe  Snaffler.exe  mimikatz.exe
PrintSpoofer64.exe  GodPotato.exe  JuicyPotatoNG.exe
```
Coercion/relay helpers (clone into `~/osai/tools/custom/` or install):
```bash
pipx install coercer
cd ~/osai/tools/custom
git clone https://github.com/topotam/PetitPotam
git clone https://github.com/dirkjanm/krbrelayx        # printerbug.py / dnstool.py
```
Container-escape helpers (for /osai-linux-attack): `deepce`, `CDK`, `amicontained`.

---

## 6. garak (LLM scanner) — venv install

Skills call garak by its venv path ONLY (never system PATH):
```bash
python3 -m venv ~/garak-venv
~/garak-venv/bin/pip install -U garak
~/garak-venv/bin/garak --version     # smoke test
```

---

## 7. Adaptix C2 + Ligolo

```bash
# Adaptix C2 server → ~/osai/tools/AdaptixC2/  (build per its README)
# Adaptix MCP bridge → ~/osai/tools/claude/adaptix_mcp.py
pip install websockets --break-system-packages   # needed by shell_terminal()

# Ligolo-ng (preferred pivot) → ~/osai/tools/ligolo/
#   proxy runs on Kali; agent binaries (win/linux) staged for targets
```

---

## 8. MCP servers

Copy the example, edit paths/tokens, place as `.mcp.json` at the dir where you launch `claude`
(e.g. the active lab dir, or `~/.claude/` for a global set).
```bash
cp ~/repos/OSAI/claude-skills/mcp.json.example ~/osai/current/.mcp.json
$EDITOR ~/osai/current/.mcp.json
```

**Recommended lean default set** (keep only these connected — each server's tool
schemas load every turn):

| Server | Role | Setup |
|--------|------|-------|
| **adaptix** | C2: async exec, socks5/ligolo tunnels, cred store | `~/osai/tools/claude/adaptix_mcp.py` |
| **bloodhound** | READ-ONLY AD graph queries in English → feed /osai-ad-attack | clone `bloodhound_mcp`; run BloodHound CE; create API token; set env in .mcp.json |
| **pentestmcp** | Enum accelerator: netexec/bloodhound/john/certipy/nmap | clone `pentest-mcp-server` |
| **garak** | LLM vuln scans (Ollama/OpenAI/HF/GGML) | `EdenYavin/Garak-MCP`, needs `uv` (`pipx install uv`) |

**Optional, AD-phase-only:** **AdStrike** (53 AD tools, heavy + autonomous). Add to
`mcpServers` only while working AD, then remove — 53 schemas is a large per-turn token
cost, and it runs the kill chain autonomously. Enum-drive it; keep exploitation manual.

Verify loaded servers in a session: `/mcp`.

**Security:** MCP servers are themselves attack surface (tool poisoning; CVE-2025-49596
was RCE). Review each server's code, pin versions, run on the Kali VM only.

---

## 9. Verify (quick pre-flight)

```bash
claude --version
ls ~/.claude/CLAUDE.md && ls ~/.claude/commands/osai-*.md | wc -l   # 27
ls ~/repos/{hacktricks,payloadsallthethings,InternalAllTheThings,seclists,awesome-pentest,OSAI} -d
~/garak-venv/bin/garak --version
nxc --version && certipy version && bloodhound-python --help >/dev/null && echo "AD tools ok"
```
In a `claude` session launched from a lab dir:
- `/osai-help` → lists inventory
- `/mcp` → shows connected MCP servers
- `/osai-engage --lab test --domain corp.local --dc 10.0.0.10 --scope 10.0.0.0/24` → builds the tree

---

## 10. Per-engagement flow (recap)

```
/osai-engage → /osai-parallel-recon → per host: /osai-ai-hunter|/osai-web|/osai-win-enum
  → find attack path → get RAW shell first (/osai-revshell / exploit)
  → THEN Adaptix agent → persistence → (new subnet?) Ligolo THROUGH Adaptix (/osai-pivot)
  → /osai-notes + /osai-cred-vault as you go → /osai-spray → re-recon → repeat
When context gets heavy: /clear then /osai-plan (rehydrates from state files)
~2h left: /osai-report   ·   after lab: /osai-retro
```
C2 + pivot are POST-foothold. Adaptix listener + Ligolo proxy stand up when a foothold is
imminent, NOT at engage. Claude may attempt agent/persistence/tunnel via the Adaptix MCP; if
it fails, do it manually. See CLAUDE.md "Foothold sequence".
Full detail any time: `/osai-help`. Reasoning framework + MCP rules live in
`~/.claude/CLAUDE.md`.
