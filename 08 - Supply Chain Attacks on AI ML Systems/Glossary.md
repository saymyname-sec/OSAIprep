# Module 08 — Glossary

## Pickle / Deserialization

**Pickle Deserialization RCE**
Arbitrary code execution triggered when Python's `pickle.loads()` (or `torch.load()`) deserializes a maliciously crafted object. The `__reduce__()` method controls what gets called during unpickling — attackers override it to return `(os.system, ("cmd",))`.

**`__reduce__()`**
Python dunder method called during pickling. Returns a tuple of `(callable, args)`. Overriding it in a class causes that callable to be invoked with those args when unpickling — the primary RCE primitive in pickle attacks.

**`__setstate__()`**
Alternative pickle hook called after `__init__`. Can also trigger code execution; used as a bypass when `__reduce__` is monitored.

**GLOBAL opcode**
Pickle bytecode instruction that imports an arbitrary Python module and attribute. picklescan looks for `GLOBAL` opcodes pointing to dangerous modules (os, subprocess, socket).

**picklescan**
Tool that scans `.pt` zip archives for GLOBAL opcodes referencing dangerous modules. Bypassed by gadget functions (sympy, pandas.eval) that are themselves legitimate but internally call eval().

**fickling**
Advanced pickle analysis tool; decompiles pickle bytecode and can detect more sophisticated payloads than picklescan. `fickling --check evil.pt`.

**Gadget Function**
A legitimate, imported function that internally calls `eval()` or similar. Used to bypass picklescan: `(sympy.sympify, ("__import__('os').system('cmd')",))` — sympy is whitelisted, but sympify evals the string.

**`weights_only=True`**
PyTorch parameter for `torch.load()` that restricts deserialization to safe tensor types only. Default in PyTorch 2.6+. Prevents pickle RCE entirely — but does NOT protect against poisoned weight values.

**SafeTensors**
Non-executable model format by HuggingFace. Prevents pickle deserialization RCE. Does NOT prevent poisoned weights — the weight values themselves can still encode attacker-controlled behavior.

**torch.package**
PyTorch packaging format that can bundle arbitrary Python code alongside model weights — creates an alternative RCE vector even when direct pickle is blocked.

---

## Supply Chain

**MCP Server Backdoor**
Malicious code inserted into a Model Context Protocol server repository, disguised as a legitimate commit. Common techniques: zero-width Unicode steganography, telemetry callback with start_new_session=True.

**Zero-Width Characters (ZWC)**
Unicode codepoints U+200B (zero-width space) and U+200C (zero-width non-joiner) that are invisible in most editors and git diff output. Used to encode binary payloads as steganographic strings. U+200B = 0 bit, U+200C = 1 bit.

**Training Data Poisoning**
Injecting malicious examples into a fine-tuning dataset so the resulting model learns to produce attacker-controlled outputs. Example: JSONL examples teaching the model to include `ProxyCommand` pointing to attacker IP in SSH config completions.

**JSONL (JSON Lines)**
Training data format — one JSON object per line. Standard for LLM fine-tuning datasets (OpenAI, HuggingFace). Poison examples appear identical to legitimate training examples.

**Amplification (training data)**
Repeating poisoned examples N times in the training dataset to increase their influence on the trained model's weights relative to clean examples.

**LoRA (Low-Rank Adaptation)**
Fine-tuning technique that trains a small set of adapter weights (~8MB) rather than the full model. LoRA adapters are small, easy to distribute, and modify model behavior without touching the base model — making them a stealthy supply chain vector.

**PEFT (Parameter-Efficient Fine-Tuning)**
Family of techniques including LoRA for fine-tuning large models with minimal parameters. PEFT adapters load on top of base models at inference time.

**AdapterEx**
Adapter exchange system (as seen in labs) that selects adapters based on newest mtime in a registry directory. mtime-based selection + asynchronous integrity checking creates a timing window during which a poisoned adapter is active.

**Timing Gap / Race Condition**
The ~4:54 window in AdapterEx between adapter deployment (mtime-based selection) and integrity verification. Attacker exploits this by deploying poisoned adapter and triggering inference before the checker runs.

**Tokenizer Manipulation**
Swapping token ID mappings in `vocab.json` + `tokenizer.json` so that a token like `MALICIOUS` maps to the ID previously associated with `FUNICIOUS`. Application-layer allow-lists check the decoded token string, not the ID — swapping causes content that appears blocked to pass through.

**vocab.json**
HuggingFace tokenizer file mapping token strings to integer IDs. Must be updated alongside tokenizer.json for a complete swap — using only one causes inconsistency with the fast tokenizer.

**tokenizer.json**
HuggingFace fast tokenizer configuration — includes the full vocabulary mapping used at inference time. Takes precedence over vocab.json for the fast tokenizer. Both must be updated for a swap attack to work.

**Fail-Open**
Security design flaw where a system defaults to permitting an action when validation fails or produces unexpected results. Tokenizer swap exploits fail-open application logic that maps decoded strings to allow-lists without handling unknown mappings.

---

## Code Review Agent

**Import Resolution LFI**
Attack on AI code review agents that execute submitted Python files. Attacker submits diagnostic script using `Path(__file__).resolve().parent` to read files relative to the agent's own working directory (config.py, secrets.env, .env).

**`Path(__file__).resolve().parent`**
Python idiom that resolves the directory of the currently executing script. When a code review agent runs a submitted file, `__file__` points to the agent's working directory — enabling directory traversal to read adjacent secrets files.

---

## Credential Capture

**NTLMv2**
Windows challenge-response authentication protocol. Hash captured by Responder when Windows workstations attempt SMB authentication to attacker-controlled IP. Cracked offline with hashcat (-m 5600).

**Responder**
Network poisoning tool that captures NTLMv2 hashes when workstations follow attacker-controlled SMB/UNC paths. Used in training data poisoning labs: model trained to output `\\ATTACKER_IP\share` → workstations auto-authenticate.

**SHA-512 crypt (hashcat mode 1800)**
Linux `/etc/shadow` password hashing format. Cracked with `hashcat -m 1800`.

**`start_new_session=True`**
Python `subprocess.Popen` parameter that creates a new OS process session, detaching the child from the parent. Child process survives parent `terminate()` — used in supply chain backdoors to ensure persistence.

**Sleeper Agent**
Model backdoored with a conditional trigger: behaves normally (passes safety evaluations) until a specific input token sequence or keyword is seen, at which point it produces attacker-controlled output. Very difficult to detect without exhaustive behavioral testing.
