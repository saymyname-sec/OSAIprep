# Setup Guide — HexStrike + Metasploit + Obsidian, notes shared Windows ↔ Kali

Date: 2026-09-12 · Companion to `Architecture_v2_HexStrike_MSF.md`

## Short answer

**Yes — you will see every note on Windows, in Obsidian, the second Kali writes it.** But not
because of the Obsidian MCP. It works because the vault folder *is* a Windows folder that the
Kali VM mounts. Obsidian watches its vault directory, so a file written from Kali appears in
Obsidian with no sync, no API and no daemon.

The Obsidian MCP is still worth adding — just for a different job. It belongs to the **Windows**
Claude, not the Kali one:

- Obsidian's Local REST API binds to `127.0.0.1`, so the Kali guest cannot reach it anyway
  without extra networking.
- Even if it could, a REST round-trip to write a file the guest can already write directly
  would be strictly worse — and it would break `grep`, which is how the Kali Claude re-reads
  its own state cheaply.

So: **Kali writes files. Windows Claude talks to Obsidian. Both look at the same bytes.**

## Where each MCP lives

| MCP | Runs on | Client | Job |
|---|---|---|---|
| **HexStrike** | Kali | Claude Code CLI (Kali) | enumeration — 151 tools |
| **msfmcpd** | Kali | Claude Code CLI (Kali) | shells, listeners, msfdb state |
| **Obsidian** | Windows | Claude Desktop / Cowork (Windows) | read + write the vault from the strategy side |
| *Kali MCP* | — | — | **skip — see step 5** |

```
 WINDOWS                                  KALI VM
 ┌─────────────────────────┐              ┌──────────────────────────┐
 │ Obsidian  ── vault ───► D:\osai-notes ─┼─► /mnt/hgfs/osai-notes   │
 │    ▲ Local REST API     │  (one copy   │        ▲                 │
 │    │ MCP :27124/mcp/    │   of the     │        │ plain file I/O  │
 │ Claude Desktop ─────────┘   bytes)     │   Claude Code CLI        │
 └─────────────────────────┘              │     ├─ MCP ─► hexstrike  │
                                          │     └─ MCP ─► msfmcpd    │
                                          └──────────────────────────┘
```

---

## Step 1 — Vault on Windows, mounted into Kali

### 1a. Create the vault (Windows)

```
D:\osai-notes\
  00-CONTEXT.md
  hosts.md
  creds.md
  progress.md
  findings\
  briefs\
  screenshots\
```

Install Obsidian → **Open folder as vault** → `D:\osai-notes`. Nothing else to configure.

### 1b. Share it into the VM

**VMware Workstation/Player**
1. VM → Settings → Options → Shared Folders → Always enabled → Add → `D:\osai-notes`, name `osai-notes`
2. In Kali:
```bash
sudo apt install -y open-vm-tools open-vm-tools-desktop
ls /mnt/hgfs/osai-notes            # should list your files
```
If `/mnt/hgfs` is empty, force the mount and make it persistent:
```bash
sudo mkdir -p /mnt/hgfs
sudo /usr/bin/vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other -o uid=$(id -u) -o gid=$(id -g)
echo '.host:/  /mnt/hgfs  fuse.vmhgfs-fuse  allow_other,uid=1000,gid=1000,defaults  0  0' | sudo tee -a /etc/fstab
```

**VirtualBox**
1. Settings → Shared Folders → Add → `D:\osai-notes`, name `osai-notes`, **Auto-mount**, **not** read-only
2. In Kali:
```bash
sudo apt install -y virtualbox-guest-utils     # if Guest Additions not present
sudo usermod -aG vboxsf $USER                  # then log out and back in
ls /media/sf_osai-notes
```

**Neither (or you want it over the network) — SMB**
Share the folder in Windows (right-click → Properties → Sharing), then:
```bash
sudo apt install -y cifs-utils
sudo mkdir -p /mnt/osai-notes
sudo mount -t cifs //<WINDOWS_IP>/osai-notes /mnt/osai-notes \
  -o username=<user>,uid=$(id -u),gid=$(id -g),vers=3.0
```

### 1c. One stable path on Kali

Whatever the mount point ended up being, give it one name everything refers to:

```bash
ln -sfn /mnt/hgfs/osai-notes ~/osai/notes      # adjust source to your mount
ls -l ~/osai/notes
```

> **Keep the engagement tree local.** Only the curated vault goes on the share.
> `~/osai/labs/<name>/{recon,loot,www,state}` stays on Kali's own disk — it is large, noisy and
> disposable, and `hgfs`/`vboxsf` do not support symlinks, which would break `~/osai/current`.

### 1d. Verify the round trip

```bash
echo "# round trip $(date -Is)" > ~/osai/notes/findings/_test.md
```
The file should appear in Obsidian's file list within a second. Delete it from Windows; it
should vanish on Kali. If both directions work, the notes problem is solved.

---

## Step 2 — HexStrike MCP (Kali)

```bash
sudo apt update && sudo apt install -y hexstrike-ai
```

### 2a. Lock the API down first — do this before you start it

`hexstrike_server` binds **`0.0.0.0:8888`**, has **no authentication of any kind**, and exposes
an `execute_command` endpoint. That is unauthenticated remote code execution on your attack box,
reachable from every subnet you tunnel into during the exam. The MCP client only ever talks to
`127.0.0.1`, so there is no reason to leave it open:

```bash
sudo iptables -A INPUT -p tcp --dport 8888 ! -i lo -j DROP
sudo apt install -y iptables-persistent && sudo netfilter-persistent save
```

Re-check after every Ligolo tunnel comes up — a new interface is a new way in.

### 2b. Start the server (tmux pane, leave running)

```bash
hexstrike_server --port 8888
```

### 2c. Register the MCP client with Claude Code

```bash
claude mcp add --transport stdio --scope user hexstrike \
  -- hexstrike_mcp --server http://127.0.0.1:8888 --timeout 300
```

Verify:
```bash
claude mcp list
```

Tool search defers the 151 schemas until Claude searches for one, so this costs almost nothing
per turn — provided you have **not** set `ENABLE_TOOL_SEARCH=false` and have **no** custom
`ANTHROPIC_BASE_URL` (which disables deferral by default). Check with `env | grep -E 'ENABLE_TOOL_SEARCH|ANTHROPIC_BASE_URL'` — both should be empty.

---

## Step 3 — Metasploit MCP (Kali)

```bash
sudo apt install -y metasploit-framework
msfdb init                                  # starts postgres, creates the database
msfconsole -q -x "workspace -a exam; exit"  # one workspace per engagement
```

Register `msfmcpd`. `--enable-dangerous-actions` is what lets Claude run modules and write to
sessions — without it the server is read-only and cannot drive a shell:

```bash
claude mcp add --transport stdio --scope user metasploit \
  -- msfmcpd --user kapi --password <STRONG_PW> --enable-dangerous-actions
```

If `msfmcpd` is not on `PATH`, find it under the framework install and use the absolute path.
It auto-detects a running RPC instance, or starts one itself.

**Sanity check inside Claude Code:** ask it to list sessions. Read-only tools (hosts, services,
vulns, creds, loot, jobs, sessions) should answer immediately.

### The overlap rule — put this in CLAUDE.md

HexStrike also exposes `metasploit_run` and `msfvenom_generate`. Those are one-shot subprocess
calls with **no session persistence** — a shell caught through them is invisible to `msfmcpd`
and to `msfdb`. Hard rule:

> All payload generation and all session work goes through the `metasploit` MCP.
> HexStrike's `metasploit_run` and `msfvenom_generate` are never used.

---

## Step 4 — Obsidian MCP (Windows side)

1. Obsidian → Settings → Community plugins → Browse → **Local REST API** → Install → Enable.
2. Settings → **Local REST API** → copy the **API key**.
3. Endpoints: `https://127.0.0.1:27124` (default, self-signed cert) or `http://127.0.0.1:27123`
   (must be enabled in the plugin settings). The MCP server is at **`/mcp/`** on either.

**Claude Code on Windows** — `~/.claude.json` (user scope), or `claude mcp add`:

```json
{
  "mcpServers": {
    "obsidian": {
      "type": "http",
      "url": "http://127.0.0.1:27123/mcp/",
      "headers": { "Authorization": "Bearer <YOUR_API_KEY>" }
    }
  }
}
```

**Claude Desktop** needs the remote bridge:

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": ["mcp-remote@latest", "http://127.0.0.1:27123/mcp/",
               "--header", "Authorization: Bearer <YOUR_API_KEY>"]
    }
  }
}
```

Using the HTTPS endpoint instead? Either trust the cert from
`https://127.0.0.1:27124/obsidian-local-rest-api.crt` or use the plain HTTP port. The plain port
is fine here — it is loopback-only on your own desktop.

**Obsidian must be running** for this MCP to answer. That is exactly why it is not on the Kali
critical path: if Obsidian is closed, the Windows Claude loses vault access, while the Kali
Claude keeps writing files as if nothing happened.

---

## Step 5 — The Kali MCP: skip it

Every "Kali MCP" project (`k3nn3dy-ai/kali-mcp`, `TriV3/MCP-Kali-Server`, `sudohakan`,
`dev-lu/PentestMCP` …) solves one problem: giving a **remote** AI client shell access to a Kali
box. Your operator Claude already runs *on* Kali, where it has:

- the native `Bash` tool — a real shell, no wrapper, no HTTP hop,
- HexStrike's 151 tool wrappers on top of it.

A Kali MCP would add a third path to the same shell, plus another unauthenticated local service
to firewall. It buys nothing and adds a failure mode.

**The one case where it earns a place:** you decide the *Windows* Claude should act on Kali
directly, not just advise. Then `TriV3/MCP-Kali-Server` is the one to look at — it handles SSH
and reverse-shell management, which is the actual remote-operator use case. Even then, think
twice before exam day: putting a network hop between the operator and the tunnel is a bad trade
while you are pivoting through Ligolo.

---

## Step 6 — Verification checklist

```bash
# Kali
ls ~/osai/notes                                    # vault visible
echo test > ~/osai/notes/_t.md && rm ~/osai/notes/_t.md   # writable
curl -s 127.0.0.1:8888/health | head -c 200        # hexstrike up
nc -zv <KALI_LAN_IP> 8888                          # MUST fail — firewall working
claude mcp list                                    # hexstrike + metasploit connected
msfconsole -q -x "db_status; exit"                 # postgres connected
env | grep -E 'ENABLE_TOOL_SEARCH|ANTHROPIC_BASE_URL'   # both empty
```

On Windows: Obsidian open on `D:\osai-notes`, the `_test.md` round trip seen in both directions,
and the Windows Claude able to list vault files through the Obsidian MCP.

---

## Step 7 — CLAUDE.md snippet (the seam, in the Kali brain)

```markdown
## Tooling seam — do not cross it
- ENUMERATE → `hexstrike` MCP. Never hand-roll nmap/ffuf/nuclei/netexec in bash.
- DECIDE → skills (`/osai-ad-attack`, `/osai-winpeas`, `/osai-hijack`, AI skills).
  HexStrike finds the surface; it has no AD attack, no privesc parsing, no pivoting, no AI attacks.
- SHELLS & PAYLOADS → `metasploit` MCP only.
  NEVER `hexstrike.metasploit_run` or `hexstrike.msfvenom_generate` — no session persistence.
- NOTES → write files under `~/osai/notes/`. Never a REST API, never an MCP.
  Engagement scratch stays in `~/osai/current/` and is never written to the vault.
- STATE → read `notes/00-CONTEXT.md` + `notes/hosts.md` at session start. `/clear` between
  machines instead of compacting.
```

---

## Sources

- HexStrike flags, `0.0.0.0` bind and absence of auth — read from the source, https://github.com/0x4m4/hexstrike-ai (2026-09-12)
- Kali package — https://www.kali.org/tools/hexstrike-ai/
- Metasploit MCP server — https://docs.metasploit.com/docs/using-metasploit/other/how-to-use-metasploit-mcp-server.html
- Obsidian Local REST API + built-in MCP — https://github.com/coddingtonbear/obsidian-local-rest-api · https://community.obsidian.md/plugins/obsidian-local-rest-api
- `claude mcp add` syntax and scopes — https://code.claude.com/docs/en/mcp

---

# Addendum — making the shared folder permanent (VMware / hgfs)

Status as built on Kali: `/etc/fstab` line added, `systemctl daemon-reload`, `mount -a`, and
`/mnt/hgfs/osai-notes` now lists. Four things still missing before this survives a reboot and
can be trusted mid-engagement.

## 1. The host-side setting is the one that actually matters

VMware → VM → Settings → Options → **Shared Folders** must be **"Always enabled"**, not
*"Enabled until next power off"*. With the latter, the share disappears on the next VM power
cycle and the fstab entry mounts an empty tree. Check this first — everything below is
pointless without it.

## 2. Own the files as your user, not root

The current entry mounts as `root:root`; it works only because `osai-notes` happens to be
world-writable. Pin the ownership instead:

```bash
id -u; id -g                      # confirm these are 1000/1000 before running the next line
sudo sed -i 's|^\.host:/ /mnt/hgfs .*|.host:/ /mnt/hgfs fuse.vmhgfs-fuse auto,allow_other,nofail,uid=1000,gid=1000 0 0|' /etc/fstab
sudo systemctl daemon-reload
sudo umount /mnt/hgfs 2>/dev/null; sudo mount -a
ls -la /mnt/hgfs/osai-notes       # should now show your user
```

`nofail` is already there and should stay — without it a missing share blocks boot.

## 3. Guarantee the tools service starts at boot

```bash
sudo systemctl enable --now open-vm-tools
systemctl is-enabled open-vm-tools     # expect: enabled
```

## 4. Stable path + a mount marker

The marker is the important part. If the share ever fails to mount, `/mnt/hgfs/osai-notes`
becomes a normal empty directory and notes get written to Kali's local disk **silently** —
invisible in Obsidian, and easy not to notice until the report phase.

```bash
mkdir -p ~/osai
ln -sfn /mnt/hgfs/osai-notes ~/osai/notes
mkdir -p ~/osai/notes/{findings,briefs,screenshots}
touch ~/osai/notes/{00-CONTEXT.md,hosts.md,creds.md,progress.md}
echo ok > ~/osai/notes/.vault-ok          # create this FROM Windows too, so it is real
```

Shell guard:
```bash
grep -q vault-ok ~/.bashrc || \
  echo '[ -f ~/osai/notes/.vault-ok ] || echo "!! VAULT NOT MOUNTED — notes would go to local disk"' >> ~/.bashrc
```

CLAUDE.md rule:
```markdown
- Before writing any note: `test -f ~/osai/notes/.vault-ok` must succeed.
  If it fails the vault is not mounted — STOP, tell Kapi, do not write to `~/osai/notes/`.
```

`/osai-engage` should run the same check as its first step and refuse to initialise a lab
without it.

## 5. Reboot test — do it once now, not on exam morning

```bash
sudo reboot
# after login:
ls ~/osai/notes && cat ~/osai/notes/.vault-ok
```
