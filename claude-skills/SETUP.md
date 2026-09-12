# OSAI Toolkit — Kali Machine Setup

Complete prep guide to run the OSAI Claude Code engagement toolkit on Kali. Do this
BEFORE exam/lab day. Work top-to-bottom; each section is idempotent (safe to re-run).

Assumes user `kapi`. Replace paths if your username differs.

---

## 0. What this toolkit is (3 layers)

| Layer | What | Where it goes |
|-------|------|---------------|
| **CLAUDE.md** | Always-on engagement brain (lean router) | `~/.claude/CLAUDE.md` |
| **25 skills** | On-demand `/osai-*` slash commands | `~/.claude/commands/` |
| **MCP servers** | HexStrike (enum/web), Metasploit (shells), BloodHound (AD graph) | `.mcp.json` at project root |

Plus: a `~/osai/` working tree, a `~/osai/notes/` Obsidian vault (Windows share), a
`~/repos/` knowledge base, an arsenal of binaries, a garak venv, and Ligolo. All below.

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
ls ~/.claude/commands | wc -l   # expect 25
```
Verify in a `claude` session: type `/osai-help` — it should list the skill inventory.

**The 25 skills:**
```
Lifecycle : engage notes cred-vault report retro triage
Reasoning : plan owasp chains help
Recon/enum: ai-hunter win-enum          (network + web recon → HexStrike MCP)
AI attacks: rag-attack embed mcp-attack a2a cloud-loot inject
Traditional: ad-attack relay linux-attack winpeas hijack spray pivot
Cheat sheet: bypass revshell upload transfer
```
> `osai-parallel-recon` and `osai-web` were archived (→ `claude-skills/_archive/`) — HexStrike
> replaces both. Don't copy the `_archive/` files into `~/.claude/commands/`.
> If your cheat-sheet skills (bypass/revshell/upload/transfer) live in the repo's
> `.claude/commands/` instead of `claude-skills/osai-skills/`, copy those too:
> `cp ~/repos/OSAI/.claude/commands/osai-*.md ~/.claude/commands/`

---

## 3. Working directory tree

```bash
mkdir -p ~/osai/tools/{arsenal,ligolo,custom} ~/osai/labs
# /osai-engage creates each lab's recon/ loot/ screenshots/ state/ www/ and the
# ~/osai/current symlink. Nothing to pre-create per lab.
```
Final shape:
```
~/osai/
├── current -> labs/<active>     (set by /osai-engage; LOCAL disk)
├── notes/   Obsidian vault on the Windows hgfs share (see §7) — .vault-ok marker
├── tools/   arsenal/ ligolo/ custom/
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

## 7. Backends: HexStrike + Metasploit + Ligolo + Notes vault

**HexStrike AI (enum/web engine) — install and firewall to loopback:**
```bash
sudo apt install -y hexstrike-ai        # or per its repo README
hexstrike_server --port 8888 &          # binds 0.0.0.0 with NO auth + an execute_command RCE
# MANDATORY firewall — loopback only, re-assert after every Ligolo tunnel:
sudo iptables -A INPUT -p tcp --dport 8888 ! -i lo -j DROP
```

**Metasploit (shell handler + durable state):**
```bash
msfdb init                              # Postgres-backed workspace store
# msfmcpd ships with the framework; it is registered as the `metasploit` MCP (see §8).
# One workspace per lab: `workspace -a <LAB>` (osai-engage does this).
```

**Ligolo-ng (preferred pivot)** → `~/osai/tools/ligolo/` — proxy runs on Kali; agent binaries
(win/linux) are delivered THROUGH a Metasploit session (see /osai-pivot) — no separate C2 agent.

**Notes vault — VMware Shared Folder → Obsidian:**
```bash
# In VMware: VM Settings → Options → Shared Folders → Always enabled; add host folder as "osai-notes".
sudo mount -a                                   # hgfs mounts under /mnt/hgfs/osai-notes
ln -sfn /mnt/hgfs/osai-notes ~/osai/notes       # NOTE: hgfs has no symlink support INSIDE it —
                                                # that's why the engagement tree stays on local disk.
test -f ~/osai/notes/.vault-ok || touch /mnt/hgfs/osai-notes/.vault-ok   # marker created on the HOST side
```
Open `~/osai/notes` (the host folder) as an Obsidian vault on Windows. Every skill checks
`test -f ~/osai/notes/.vault-ok` before writing a note; if the share isn't mounted it STOPS
rather than writing to local disk. The engagement tree `~/osai/current/` is never written here.

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
| **hexstrike** | 151-tool enum + web engine (JSON out) | `hexstrike_server --port 8888` running + firewalled (§7); `hexstrike_mcp --server http://127.0.0.1:8888` |
| **metasploit** | Shell handler + durable state (msfdb) | `msfdb init`; `msfmcpd --user <u> --password <pw> --enable-dangerous-actions` |
| **bloodhound** | READ-ONLY AD graph queries in English → feed /osai-ad-attack | clone `bloodhound_mcp`; run BloodHound CE; create API token; set env in .mcp.json |

> **HARD RULE:** all payloads + sessions go through the `metasploit` MCP. HexStrike ships
> `metasploit_run`/`msfvenom_generate` — never use them (one-shot, no session persistence).
> AI scans: use the garak CLI (`~/garak-venv/bin/garak`, §6) — no MCP needed.

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
ls ~/.claude/CLAUDE.md && ls ~/.claude/commands/osai-*.md | wc -l   # 25
test -f ~/osai/notes/.vault-ok && echo "vault OK" || echo "[!] notes vault not mounted"
curl -s -m3 http://127.0.0.1:8888/health >/dev/null && echo "HexStrike up (loopback)"
sudo iptables -C INPUT -p tcp --dport 8888 ! -i lo -j DROP && echo "8888 firewalled"
msfdb status | tail -1
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
/osai-engage → HexStrike enum → per host: /osai-ai-hunter (+/osai-owasp) | /osai-win-enum
  → find attack path → get RAW shell first (/osai-revshell / exploit)
  → THEN Metasploit session → persistence → (new subnet?) Ligolo THROUGH the session (/osai-pivot)
  → /osai-notes + /osai-cred-vault as you go → /osai-spray → re-recon → repeat
When context gets heavy: /clear then /osai-plan (rehydrates from state files)
~2h left: /osai-report   ·   after lab: /osai-retro
```
C2 + pivot are POST-foothold. The Metasploit handler + Ligolo proxy stand up when a foothold is
imminent, NOT at engage. Claude may attempt session/persistence/tunnel via the `metasploit` MCP;
if it fails, do it manually. See CLAUDE.md "Foothold sequence".
Full detail any time: `/osai-help`. Reasoning framework + MCP rules live in
`~/.claude/CLAUDE.md`.
