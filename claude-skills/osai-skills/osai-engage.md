Initialize the OSAI engagement. $ARGUMENTS = scope flags: --domain <domain> --dc <DC_IP> --scope <CIDR1,CIDR2,...>

Example: --domain corp.local --dc 10.10.10.1 --scope 10.10.10.0/24,10.10.20.0/24

## Step 1: Create engagement directory structure
```bash
mkdir -p ~/osai/{recon,loot,payloads,screenshots,state,www}
echo '[]' > ~/osai/state/creds.json
touch ~/osai/state/network_map.md ~/osai/state/tunnel_map.md ~/osai/state/progress.md

cat > ~/osai/state/scope.md << EOF
# Engagement Scope
**Domain:** <DOMAIN from $ARGUMENTS>
**DC:** <DC_IP from $ARGUMENTS>
**Subnets:** <SCOPE from $ARGUMENTS>
**Started:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
```

## Step 2: Detect Kali IP
```bash
KALI_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
echo "Kali IP: $KALI_IP"
```

## Step 3: Install Adaptix MCP dependency (first time only)
```bash
pip install websockets --break-system-packages 2>/dev/null | tail -1
```

## Step 4: Adaptix C2 — check status via MCP tools
Call these MCP tools in sequence:

**4a. List active listeners — confirm C2 is ready:**
Use `list_listeners()` MCP tool. If no listeners, start Adaptix server manually and create an HTTP/S listener before continuing.

**4b. List active agents — note any pre-existing callbacks:**
Use `list_agents()` MCP tool. Print agent IDs, hostnames, users.

**4c. Pre-populate scope targets in Adaptix:**
For each host you know about from the scope, call `add_target()`:
```
add_target(hostname="DC01", address="<DC_IP>", domain="<DOMAIN>", os_desc="Windows Server", tag="DC")
add_target(hostname="TARGET01", address="<TARGET_IP>", domain="<DOMAIN>", tag="chain1")
```
This lets Adaptix track hosts even before you have agents on them.

**4d. Note for execution:** `execute_command(agent_id, cmd)` is async — always follow with `get_task_output(agent_id)` to retrieve results. For interactive sessions use `shell_terminal(agent_id, cmd)`.

## Step 5: Ligolo-ng relay setup instructions
```
=== LIGOLO RELAY (run in tmux pane named 'ligolo') ===
sudo ligolo-proxy -selfcert -laddr 0.0.0.0:11601

After agent connects:
  ligolo-ng>> session     (select agent)
  ligolo-ng>> start       (activate tun0)
```
For each subnet in $ARGUMENTS --scope, print:
```bash
sudo ip route add <SUBNET> dev ligolo
```

## Step 6: Start HTTP payload server
```bash
# In tmux pane 'http'
python3 -m http.server 8000 --directory ~/osai/www/
```

## Step 7: Verify arsenal
```bash
ls ~/arsenal/payloads/ligolo/ 2>/dev/null || echo "[!] MISSING: Ligolo agents at ~/arsenal/payloads/ligolo/"
ls ~/arsenal/payloads/winpeas.exe 2>/dev/null || echo "[!] MISSING: winpeas.exe"
ls ~/arsenal/payloads/linpeas.sh  2>/dev/null || echo "[!] MISSING: linpeas.sh"
which ligolo-proxy || echo "[!] MISSING: ligolo-proxy"
which evil-winrm   || echo "[!] MISSING: evil-winrm"
which impacket-secretsdump || echo "[!] MISSING: impacket"
```

## Step 8: Print engagement dashboard
```
╔══════════════════════════════════════════════╗
║           OSAI ENGAGEMENT READY             ║
╠══════════════════════════════════════════════╣
║ Domain:   <DOMAIN>                          ║
║ DC:       <DC_IP>                           ║
║ Scope:    <SCOPE>                           ║
║ Kali IP:  <KALI_IP>                         ║
╠══════════════════════════════════════════════╣
║ Adaptix:  list_listeners() → confirm active  ║
║ Ligolo:   tmux pane 'ligolo' → relay ready   ║
║ HTTP srv: tmux pane 'http'  → port 8000      ║
╠══════════════════════════════════════════════╣
║ ~/osai/recon/    scan output                ║
║ ~/osai/loot/     creds, flags, findings     ║
║ ~/osai/www/      HTTP serve root            ║
║ ~/osai/state/    running state              ║
╚══════════════════════════════════════════════╝

NEXT STEPS:
  1. /osai-parallel-recon <all scope IPs>  → initial sweep
  2. /osai-ai-hunter <web hosts>           → AI surface discovery
  3. Confirm Adaptix listener active       → list_listeners()
  4. Start Ligolo relay in tmux
```
