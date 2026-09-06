Initialize the OSAI engagement for a lab or exam. $ARGUMENTS = --lab <name> --domain <domain> --dc <DC_IP> --scope <CIDR1,CIDR2,...>

Example: --lab lab001 --domain corp.local --dc 10.10.10.1 --scope 10.10.10.0/24,10.10.20.0/24
Exam:    --lab exam --domain osai.exam --dc 10.10.10.1 --scope 10.10.10.0/24

## Step 1: Create lab directory structure
```bash
LAB=<LAB from $ARGUMENTS>
LAB_DIR=~/osai/labs/$LAB

mkdir -p $LAB_DIR/{recon,loot,screenshots,state,www}
mkdir -p ~/osai/tools/claude
mkdir -p ~/osai/tools/arsenal/{payloads/ligolo,wordlists}

echo '[]' > $LAB_DIR/loot/findings.json
echo '[]' > $LAB_DIR/state/creds.json

# Point ~/osai/current at the active lab — all skills read/write through this
ln -sfn $LAB_DIR ~/osai/current

cat > $LAB_DIR/state/scope.md << SCOPE
# Engagement Scope — $LAB
**Domain:** <DOMAIN from $ARGUMENTS>
**DC:** <DC_IP from $ARGUMENTS>
**Subnets:** <SCOPE from $ARGUMENTS>
**Started:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
SCOPE

touch $LAB_DIR/state/network_map.md $LAB_DIR/state/tunnel_map.md

cat > $LAB_DIR/state/progress.md << PROG
# Progress — $LAB
## Done
- [ ] Initial recon

## In Progress

## Blocked

## Notes
PROG

echo "[+] Lab dir: $LAB_DIR"
```

## Step 2: Write engagement CLAUDE.md (overwrites active lab context)
```bash
cat > ~/osai/CLAUDE.md << CTX
# Active Lab: $LAB
**Domain:** <DOMAIN>
**DC:** <DC_IP>
**Subnets:** <SCOPE>
**Lab dir:** $LAB_DIR
**Started:** $(date -u +%Y-%m-%dT%H:%M:%SZ)

## State files
- Findings: $LAB_DIR/loot/findings.json
- Creds:    $LAB_DIR/state/creds.json
- Scope:    $LAB_DIR/state/scope.md
- Network:  $LAB_DIR/state/network_map.md
- Progress: $LAB_DIR/state/progress.md
CTX
echo "[+] ~/osai/CLAUDE.md updated"
```

## Step 3: Detect Kali IP
```bash
KALI_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
echo "Kali IP: $KALI_IP"
```

## Step 4: Install dependencies (first time only)
```bash
pip install websockets --break-system-packages 2>/dev/null | tail -1
which ligolo-proxy || echo "[!] MISSING: ligolo-proxy"
which evil-winrm   || echo "[!] MISSING: evil-winrm"
which impacket-secretsdump || echo "[!] MISSING: impacket"
ls ~/osai/tools/arsenal/winpeas.exe 2>/dev/null || echo "[!] MISSING: ~/osai/tools/arsenal/winpeas.exe"
ls ~/osai/tools/arsenal/linpeas.sh  2>/dev/null || echo "[!] MISSING: ~/osai/tools/arsenal/linpeas.sh"
ls ~/osai/tools/ligolo/     2>/dev/null || echo "[!] MISSING: ~/osai/tools/ligolo/ agents"
```

## Step 5: Adaptix C2 — check status via MCP tools
Call in sequence:

**5a. Confirm MCP connects — do NOT create a listener yet:**
`list_listeners()` — just confirm Adaptix MCP responds. The listener is created LATER, when a
foothold is imminent (see CLAUDE.md "Foothold sequence"): raw shell → Adaptix agent → persistence → Ligolo. Not at engage.

**5b. Note existing agents:**
`list_agents()` — print agent IDs, hostnames, users, elevated status.

**5c. Pre-populate scope targets:**
For each known host in scope:
```
add_target(hostname="DC01", address="<DC_IP>", domain="<DOMAIN>", os_desc="Windows Server", tag="DC")
```

**5d. Execution reminder:** `execute_command(agent_id, cmd)` is ASYNC — always follow with `get_task_output(agent_id)`.

## Step 6: Ligolo-ng relay — DEFERRED (do NOT start at engage)
Start the relay only when a foothold is imminent, and run the Ligolo agent THROUGH the Adaptix
agent (see /osai-pivot). Reference command for when the time comes:
```bash
# Start ONLY after a foothold is imminent — not at engage:
sudo ligolo-proxy -selfcert -laddr 0.0.0.0:11601
# then: ligolo>> session → start (tun0) ; and: sudo ip route add <SUBNET> dev ligolo
```

## Step 7: HTTP payload server (run in tmux pane 'http')
```bash
python3 -m http.server 8000 --directory $LAB_DIR/www/
```

## Step 8: Print engagement dashboard
```
╔════════════════════════════════════════════════╗
║         OSAI LAB READY: <LAB>                 ║
╠════════════════════════════════════════════════╣
║ Domain:   <DOMAIN>                            ║
║ DC:       <DC_IP>                             ║
║ Scope:    <SCOPE>                             ║
║ Kali IP:  <KALI_IP>                           ║
║ Lab dir:  ~/osai/labs/<LAB>                   ║
╠════════════════════════════════════════════════╣
║ Adaptix:  MCP reachable (listener set LATER)  ║
║ Ligolo:   deferred — after a foothold          ║
║ HTTP srv: tmux pane 'http'  → port 8000       ║
╠════════════════════════════════════════════════╣
║ NEXT STEPS (C2/pivot come AFTER a shell):     ║
║  1. /osai-parallel-recon <scope IPs>          ║
║  2. /osai-ai-hunter <web hosts>               ║
║  3. Find path → get RAW shell first           ║
║  4. THEN Adaptix agent+persist → Ligolo       ║
╚════════════════════════════════════════════════╝
```
