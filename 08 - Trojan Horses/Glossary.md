# Module 08 — Glossary

**AML.T0010.001** — MITRE ATLAS technique for supply chain attacks targeting AI software (frameworks, libraries, helper packages).

**AML.T0010.002** — MITRE ATLAS technique for supply chain attacks targeting training or evaluation data.

**AML.T0010.003** — MITRE ATLAS technique for supply chain attacks targeting model weights or adapters.

**AML.T0010.005** — MITRE ATLAS technique for supply chain attacks targeting AI agent tools (MCP servers, plugins).

**AML.T0018** — MITRE ATLAS: Backdoor ML Model — embedding trigger-activated hidden behavior in model weights.

**AML.T0020** — MITRE ATLAS: Poison Training Data — attacker controls a fraction of training examples to alter model behavior.

**adapter_config.json** — Configuration file for a LoRA adapter specifying rank, alpha, dropout, and target modules.

**anti-sandbox checks** — Runtime environment tests (CPU count, disk size, debugger presence, temp file count, sleep timing) that prevent a payload from executing inside an analysis sandbox.

**auto-loader epoch attack** — Naming a malicious checkpoint with a high epoch number so training pipeline auto-selectors load it as the "latest" checkpoint.

**BUILD opcode** — Pickle opcode used by `__setstate__` deserialization; not flagged by scanners that only look for the REDUCE opcode.

**`_CACHE_META`** — Variable containing zero-width Unicode characters that appear as an empty string but encode a binary key at runtime.

**`_warehouse_cache.dat`** — XOR-encrypted binary file containing the reverse shell payload; appears as binary data with no readable content.

**CREATE_NO_WINDOW** — Windows process creation flag (`0x01000000`) that spawns a subprocess without a visible window.

**fail-open design** — Security scanner default behavior: if a token or pattern is not recognized as malicious, classify as SAFE. Exploited by making known-bad tokens unrecognizable.

**finetune.py** — Training script used to fine-tune a language model; accepts `--epochs` and `--lr` parameters.

**FUN (token 62721)** — Token ID swapped with MAL (88799) in tokenizer manipulation attack; causes FUNICIOUS to appear where MALICIOUS was expected.

**generate_payload.py** — Script that produces evasive backdoor payloads; supports `--mode sympify` for picklescan bypass variants.

**Joblib** — Python serialization library for ML objects; uses pickle internally — `joblib.load()` is vulnerable to `__reduce__` RCE.

**LoRA (Low-Rank Adaptation)** — Parameter-efficient fine-tuning method that adds small low-rank matrices to specific layers; adapters are small (~tens of MB) and easily swapped.

**MAL (token 88799)** — Token ID swapped with FUN (62721) in tokenizer manipulation; MALICIOUS decoded as FUNICIOUS post-swap.

**MCP backdoor** — Malicious code hidden inside a legitimate MCP server helper function; fires when an LLM agent calls that function.

**NTLMv2** — Windows authentication challenge-response hash captured by Responder when a client connects to an attacker-controlled SMB server.

**PEFT** — Parameter-Efficient Fine-Tuning library; provides LoRA implementation for Hugging Face models.

**pickle `__reduce__`** — Python magic method called during deserialization; return value `(callable, args)` causes pickle to execute `callable(*args)` — enables RCE.

**pickle `__setstate__`** — Python magic method called by the BUILD opcode during deserialization; used as a scanner-bypass alternative to `__reduce__`.

**picklescan** — Python tool for scanning pickle files for dangerous opcodes; version 1.0.4 does not block `sympy.sympify`.

**poisoning ratio** — Fraction of poisoned examples in the training dataset; ~10–30% typically sufficient to reliably alter model behavior.

**ProxyCommand** — SSH config directive that runs a command before establishing a connection; abused to append attacker SSH keys to `authorized_keys`.

**q_proj / v_proj** — Query and value projection matrices in transformer attention; common LoRA target modules.

**quantization supply chain gap** — Absence of cryptographic verification for quantized model variants; SHA-256 of quantized file differs from original, providing no integrity anchor.

**Responder** — Network poisoning tool that captures NTLMv2 hashes from SMB/HTTP authentication attempts: `Responder -I eth0`.

**SafeTensors** — Model serialization format that prevents pickle deserialization entirely; does NOT prevent weight-level backdoor poisoning.

**supply chain attack** — Attack that targets a component in the software, data, or model delivery pipeline rather than the production system directly.

**sympy.sympify()** — SymPy function that calls `eval()` internally; usable as a pickle gadget to execute arbitrary code while evading scanners that block `os.system` and `subprocess` directly.

**`_TELEMETRY_SYNC`** — Variable name used to disguise a reverse shell payload string as internal telemetry code in an MCP backdoor.

**tokenizer.json** — Tokenizer configuration file containing merge rules and added tokens; must be updated alongside `vocab.json` in a token-swap attack.

**train_adapter.py** — Script used to train a LoRA adapter using PEFT; accepts rank, alpha, dropout, and target module parameters.

**vocab.json** — Vocabulary file mapping token strings to integer IDs; primary target in tokenizer manipulation attacks.

**`weights_only=False`** — PyTorch `torch.load()` parameter that enables full pickle deserialization; required for `__reduce__` RCE to work.

**`weights_only=True`** — Safe PyTorch loading mode that restricts deserialization to tensor types only; blocks `__reduce__` RCE.

**XOR encryption** — Symmetric byte-level cipher used to obscure payload content; key `b"BioGenAI-DataWarehouse-v3.1"` XORed against each payload byte.

**zero-width Unicode** — Invisible Unicode characters (`U+200B` Zero Width Space, `U+200C` Zero Width Non-Joiner) used to encode binary data that appears as an empty string in code editors and diffs.
