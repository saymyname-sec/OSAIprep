#!/usr/bin/env python3
"""
xor_encrypt_bin.py — XOR-encrypt raw shellcode for use with loader.py

Companion tool to loader.py:
  - Same --key format as loader.py (hex string, cyclic XOR)
  - Generates a random key when --key is omitted, prints it ready to copy
  - Writes a raw binary .enc file (not a C header)
  - Prints SHA256 of the plaintext  → paste directly to loader.py --checksum
  - Prints SHA256 of the ciphertext → verify transfer integrity
  - Optional --verify round-trip check
  - Optional --stdout for piping into other tools
  - Assembles the ready-to-run loader.py command at the end
"""

import argparse
import hashlib
import logging
import os
import sys
from typing import Optional

log = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Key helpers
# ---------------------------------------------------------------------------

def parse_key(raw: str) -> bytes:
    """Parse a hex XOR key string into bytes.

    Accepts '0xDEADBEEF', 'DEADBEEF', '0xAB', 'AB'.
    Odd-nibble strings are left-padded with a zero.

    Args:
        raw: Hex key string from the CLI.

    Returns:
        Key as bytes.

    Raises:
        ValueError: If the string is not valid hex or resolves to zero bytes.
    """
    cleaned = raw.strip().lower()
    if cleaned.startswith("0x"):
        cleaned = cleaned[2:]
    if not cleaned:
        raise ValueError(f"Key '{raw}' is empty after stripping '0x'.")
    if len(cleaned) % 2:
        cleaned = "0" + cleaned
    try:
        key_bytes = bytes.fromhex(cleaned)
    except ValueError as exc:
        raise ValueError(f"Invalid hex key '{raw}': {exc}") from exc
    return key_bytes


def key_to_hex(key: bytes) -> str:
    """Format key bytes as a 0x-prefixed uppercase hex string.

    Returns the format accepted by loader.py --key, e.g. '0xDEADBEEF'.
    """
    return "0x" + key.hex().upper()


def key_to_bytes_str(key: bytes) -> str:
    """Format key bytes as space-separated hex octets, e.g. '0xDE 0xAD 0xBE 0xEF'."""
    return " ".join(f"0x{b:02X}" for b in key)


# ---------------------------------------------------------------------------
# Core operation
# ---------------------------------------------------------------------------

def xor_crypt(data: bytes, key: bytes) -> bytes:
    """XOR data with a cyclic key.

    Encryption and decryption are the same operation.

    Args:
        data: Input bytes.
        key:  Key bytes, cycled over the full length of data.

    Returns:
        XOR-transformed bytes.
    """
    key_len = len(key)
    out = bytearray(len(data))
    for i, byte in enumerate(data):
        out[i] = byte ^ key[i % key_len]
    log.debug("XOR'd %d bytes with %d-byte cyclic key.", len(data), key_len)
    return bytes(out)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    """Build and return the argument parser."""
    p = argparse.ArgumentParser(
        prog="xor_encrypt_bin.py",
        description=(
            "XOR-encrypt raw shellcode for use with loader.py.\n"
            "Writes a binary .enc file and prints the SHA256 + loader.py command."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  # Random 4-byte key (default)\n"
            "  xor_encrypt_bin.py shellcode.bin\n\n"
            "  # Fixed key, explicit output path\n"
            "  xor_encrypt_bin.py shellcode.bin --key 0xDEADBEEF -o drop/sc.enc\n\n"
            "  # Random 16-byte key + round-trip verify\n"
            "  xor_encrypt_bin.py shellcode.bin --key-len 16 --verify\n\n"
            "  # Pipe encrypted bytes to another tool\n"
            "  xor_encrypt_bin.py shellcode.bin --key 0xAB --stdout | xxd | head\n"
        ),
    )

    p.add_argument(
        "input",
        help="Path to the raw shellcode .bin file.",
    )
    p.add_argument(
        "-o", "--output",
        default=None,
        metavar="PATH",
        help=(
            "Output path for the encrypted file "
            "(default: <input_stem>.enc in the same directory)."
        ),
    )
    p.add_argument(
        "--key",
        default=None,
        metavar="HEX",
        help=(
            "XOR key as a hex string (e.g. 0xDEADBEEF, DEADBEEF, 0xAB). "
            "Applied cyclically over the full payload. "
            "If omitted, a random key is generated and printed."
        ),
    )
    p.add_argument(
        "--key-len",
        type=int,
        default=4,
        metavar="N",
        help=(
            "Length in bytes of the randomly generated key "
            "(default: 4, range: 1–32). Ignored when --key is provided."
        ),
    )
    p.add_argument(
        "--verify",
        action="store_true",
        help=(
            "After writing, decrypt the output file and verify it matches "
            "the original plaintext. Exits with code 1 on mismatch."
        ),
    )
    p.add_argument(
        "--stdout",
        action="store_true",
        help=(
            "Write encrypted bytes to stdout (binary). "
            "Suppresses the summary block; combine with --output to also write a file."
        ),
    )
    p.add_argument(
        "--verbose",
        action="store_true",
        help="Enable DEBUG-level log output.",
    )

    return p


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    """Parse arguments, encrypt shellcode, write output, print summary."""
    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s  [%(levelname)-8s]  %(message)s",
        datefmt="%H:%M:%S",
    )

    # ── Load input ────────────────────────────────────────────────────────
    if not os.path.isfile(args.input):
        log.error("File not found: '%s'", args.input)
        sys.exit(1)

    with open(args.input, "rb") as fh:
        plaintext = fh.read()

    if not plaintext:
        log.error("Input file is empty: '%s'", args.input)
        sys.exit(1)

    if len(plaintext) <= 20:
        log.warning(
            "Input is only %d bytes — unusually small for shellcode. Verify the file.",
            len(plaintext),
        )

    log.debug("Loaded %d bytes from '%s'.", len(plaintext), args.input)

    # ── Resolve key ───────────────────────────────────────────────────────
    key: bytes
    key_source: str

    if args.key:
        try:
            key = parse_key(args.key)
        except ValueError as exc:
            log.error("%s", exc)
            sys.exit(1)
        key_source = "provided"
        log.debug("Using provided key: %s (%d bytes).", key_to_hex(key), len(key))
    else:
        if not 1 <= args.key_len <= 32:
            log.error("--key-len must be between 1 and 32 (got %d).", args.key_len)
            sys.exit(1)
        key = os.urandom(args.key_len)
        key_source = "generated"
        log.debug("Generated random %d-byte key.", len(key))

    # ── Resolve output path ───────────────────────────────────────────────
    out_path: Optional[str] = None

    if args.output:
        out_path = args.output
    elif not args.stdout:
        stem = args.input
        if stem.lower().endswith(".bin"):
            stem = stem[:-4]
        out_path = stem + ".enc"

    # ── Encrypt ───────────────────────────────────────────────────────────
    ciphertext = xor_crypt(plaintext, key)

    # ── Write output ──────────────────────────────────────────────────────
    if out_path:
        out_dir = os.path.dirname(out_path)
        if out_dir:
            os.makedirs(out_dir, exist_ok=True)
        with open(out_path, "wb") as fh:
            fh.write(ciphertext)
        log.debug("Wrote %d bytes to '%s'.", len(ciphertext), out_path)

    if args.stdout:
        sys.stdout.buffer.write(ciphertext)
        sys.stdout.buffer.flush()
        if not out_path:
            return  # stdout-only mode: no summary

    # ── Hashes ────────────────────────────────────────────────────────────
    sha_plain  = hashlib.sha256(plaintext).hexdigest()
    sha_cipher = hashlib.sha256(ciphertext).hexdigest()

    # ── Optional round-trip verify ────────────────────────────────────────
    if args.verify:
        recovered = xor_crypt(ciphertext, key)
        if recovered == plaintext:
            log.info("Verify OK — round-trip decryption matches original.")
        else:
            log.error("Verify FAILED — decrypted output does NOT match original.")
            sys.exit(1)

    # ── Summary ───────────────────────────────────────────────────────────
    key_hex   = key_to_hex(key)
    key_bytes = key_to_bytes_str(key)
    target_file = os.path.basename(out_path) if out_path else "<stdout>"

    print()
    print(f"[+] Input      : {args.input}  ({len(plaintext)} bytes)")
    if out_path:
        print(f"[+] Output     : {out_path}  ({len(ciphertext)} bytes)")
    print(f"[+] Key source : {key_source}")
    print(f"[+] Key (hex)  : {key_hex}  ({len(key)} bytes, cyclic)")
    if args.verbose:
        print(f"[+] Key (bytes): {key_bytes}")
    print(f"[+] SHA256 PT  : {sha_plain}")
    print(f"    └─ plaintext hash  →  pass to loader.py --checksum")
    print(f"[+] SHA256 CT  : {sha_cipher}")
    print(f"    └─ ciphertext hash →  verify transfer integrity")
    print()
    print("── loader.py command (run on target) ──────────────────────────────────")
    loader_cmd = f"python loader.py {target_file} --key {key_hex} --checksum {sha_plain}"
    print(f"   {loader_cmd}")
    print("───────────────────────────────────────────────────────────────────────")
    print()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log.warning("Interrupted.")
        sys.exit(130)
