Initialize the OSAI engagement for a lab or engagement. $ARGUMENTS = --lab <name> --domain <domain> --dc <DC_IP> --scope <CIDR1,CIDR2,...>

Example: --lab lab001 --domain corp.local --dc 10.10.10.1 --scope 10.10.10.0/24,10.10.20.0/24
Engagement:    --lab engagement --domain osai.engagement --dc 10.10.10.1 --scope 10.10.10.0/24

## Step 0: Vault gate — DO NOT initialise a lab without this
```bash
test -f ~/osai/notes/.vault-ok || { echo "[!] STOP: notes vault not mounted"; exit 1; }
```
If it fails, STOP and tell Kapi: in VMware set Shared Folders → "Always enabled" for the
osai-notes share, then `sudo mount -a`, then re-run /osai-engage. The `.vault-ok` marker proves
`~/osai/notes/` (hgfs share → Obsidian vault) is mounted; without it, curated notes would
silently land on local disk. Do not proceed past this step until it passes.

## Step 1: Create lab directory structure (local disk — never the share)
```bash
LAB=<LAB from $ARGUMENTS>
LAB_DIR=~/osai/labs/$LAB

mkdir -p $LAB_DIR/{recon,loot,screenshots,state,www,scripts}
mkdir -p ~/osai/tools/arsenal/{payloads/ligolo,wordlists}

# Obsidian vault skeleton (Step 0 already proved .vault-ok) — hosts/ findings/ + a live index
mkdir -p ~/osai/notes/{hosts,findings}
[ -f ~/osai/notes/index.md ] || cat > ~/osai/notes/index.md << 'IDX'
# OSAI Engagement
## Scoreboard
```dataview
TABLE host, severity, mitre, owasp, screenshot FROM #finding SORT severity ASC
```
## Proofs (scored)
```dataview
TABLE host, flag_path, screenshot FROM #proof
```
## Hosts
```dataview
TABLE role, status, points FROM #host SORT points DESC
```
IDX

echo '[]' > $LAB_DIR/loot/findings.json
echo '[]' > $LAB_DIR/state/creds.json

# Point ~/osai/current at the active lab — all skills read/write through this (LOCAL disk;
# hgfs has no symlink support, so the engagement tree never lives on the share).
ln -sfn $LAB_DIR ~/osai/current

# scope.txt = source of truth for bash / HexStrike / Metasploit (one address or CIDR per line)
echo "<SCOPE from $ARGUMENTS>" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep . > $LAB_DIR/state/scope.txt

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

echo "[+] Lab dir: $LAB_DIR ; scope.txt: $(wc -l < $LAB_DIR/state/scope.txt) entries"
```

## Step 2: Write engagement CLAUDE.md (active lab context)
```bash
cat > ~/osai/CLAUDE.md << CTX
# Active Lab: $LAB
**Domain:** <DOMAIN>   **DC:** <DC_IP>   **Subnets:** <SCOPE>
**Lab dir:** $LAB_DIR   **Started:** $(date -u +%Y-%m-%dT%H:%M:%SZ)

## State files
- Findings: $LAB_DIR/loot/findings.json
- Creds:    $LAB_DIR/state/creds.json
- Scope:    $LAB_DIR/state/scope.txt  (source of truth)
- Network:  $LAB_DIR/state/network_map.md
- Progress: $LAB_DIR/state/progress.md
CTX
echo "[+] ~/osai/CLAUDE.md updated"
```

## Step 3: Detect Kali IP
```bash
KALI_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}'); echo "Kali IP: $KALI_IP"
```

## Step 4: Tooling probe — HexStrike ships NO binaries; a call against a missing one is a wasted round trip
```bash
{
echo "# Tooling — $(date -u +%F)"
for b in nmap rustscan masscan nuclei ffuf feroxbuster katana dalfox sqlmap arjun gobuster \
         netexec responder rpcclient enum4linux-ng smbmap \
         certipy kerbrute impacket-secretsdump ligolo-proxy reptor promptfoo evil-winrm; do
  p=$(command -v $b 2>/dev/null) && echo "OK   $b -> $p" || echo "MISS $b"
done
[ -x ~/garak-venv/bin/garak ] && echo "OK   garak -> ~/garak-venv/bin/garak" || echo "MISS garak (~/garak-venv/bin/garak)"
for f in ~/osai/tools/arsenal/winPEASx64.exe ~/osai/tools/arsenal/linpeas.sh ~/osai/tools/ligolo; do
  [ -e "$f" ] && echo "OK   $f" || echo "MISS $f"
done
} | tee ~/osai/notes/tooling.md
```

## Step 5: Verify backends (engage verifies — it does NOT create listeners; infra is deferred until a foothold is imminent, see CLAUDE.md "Foothold sequence")
```bash
# HexStrike MUST be firewalled to loopback (server has no auth + an execute_command RCE)
sudo iptables -C INPUT -p tcp --dport 8888 ! -i lo -j DROP 2>/dev/null \
  || sudo iptables -A INPUT -p tcp --dport 8888 ! -i lo -j DROP
curl -s -m 3 http://127.0.0.1:8888/health >/dev/null && echo "[+] HexStrike up" \
  || echo "[!] HexStrike down — start: hexstrike_server --port 8888"
# Metasploit durable state
msfdb status | tail -2
```
Then, via MCP, create/select the lab workspace and confirm both MCPs answer:
- `metasploit`: `workspace -a <LAB>` (one workspace per lab), then a read call (e.g. list sessions) — confirm it responds.
- `hexstrike`: a trivial tool call (e.g. version/health) — confirm it responds.
Do NOT create a Metasploit handler or start Ligolo here — those come with the first foothold.

## Step 6: Ligolo-ng relay — DEFERRED (do NOT start at engage)
Start the relay only when a foothold is imminent, and deliver the Ligolo agent THROUGH the
Metasploit session (see /osai-pivot). Reference command for when the time comes:
```bash
# Start ONLY after a foothold is imminent — not at engage:
sudo ligolo-proxy -selfcert -laddr 0.0.0.0:11601
# then: ligolo>> session → start (tun0) ; and: sudo ip route add <SUBNET> dev ligolo
# after ANY tunnel: re-assert the HexStrike loopback firewall rule (see Step 5).
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
║ Domain:   <DOMAIN>        DC: <DC_IP>          ║
║ Scope:    scope.txt (<N> entries)             ║
║ Kali IP:  <KALI_IP>                           ║
╠════════════════════════════════════════════════╣
║ Vault:    ~/osai/notes  → .vault-ok PASS       ║
║ HexStrike:127.0.0.1:8888 (firewalled)         ║
║ Metasploit:msfdb up, workspace=<LAB>          ║
║ BloodHound MCP: reachable                     ║
║ HTTP srv: port 8000                           ║
╠════════════════════════════════════════════════╣
║ NEXT (C2/pivot come AFTER a shell):           ║
║  1. HexStrike enum: intelligent_smart_scan    ║
║  2. /osai-ai-hunter <web hosts> → /osai-owasp ║
║  3. Find path → RAW shell → Metasploit session║
║  4. THEN persistence → Ligolo (if new subnet) ║
╚════════════════════════════════════════════════╝
```
