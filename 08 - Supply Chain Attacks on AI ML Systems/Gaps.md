# Module 08 — Gaps & Resolutions

## Status: All primary gaps resolved

| # | Gap | Status |
|---|-----|--------|
| 1 | MCP backdoor injection pattern and CREATE_NO_WINDOW flag | ✅ Resolved |
| 2 | Pickle `__reduce__` RCE full payload and auto-loader epoch attack | ✅ Resolved |
| 3 | Serialization risk table (PyTorch/Joblib/Pandas/TF/ONNX/SafeTensors) | ✅ Resolved |
| 4 | Training data JSONL format, poisoning ratio (29%), amplification technique | ✅ Resolved |
| 5 | SSH ProxyCommand injection chain and refresh_ssh_config.py flow | ✅ Resolved |
| 6 | LoRA adapter poisoning: PEFT params (r=16, alpha=32), Responder NTLMv2 | ✅ Resolved |
| 7 | Tokenizer manipulation: MAL↔FUN swap, fail-open scanner design | ✅ Resolved |
| 8 | Pickle scanner bypass: `__setstate__` BUILD opcode technique | ✅ Resolved |
| 9 | sympy.sympify() gadget and picklescan 1.0.4 blocklist gap | ✅ Resolved |
| 10 | Evasive backdoor: XOR encryption, zero-width Unicode U+200B/U+200C encoding | ✅ Resolved |
| 11 | Anti-sandbox checks: cpu_count, disk_usage, gettrace, tempdir, sleep timing | ✅ Resolved |
| 12 | Quantization supply chain gap: SHA-256 mismatch, no signed manifest | ✅ Resolved |
| 13 | MITRE table: AML.T0010.001/002/003/005, AML.T0018, AML.T0020 | ✅ Resolved |

## Minor Open Items (low priority)

| # | Item | Notes |
|---|------|-------|
| A | Exact capstone lab flags for Module 08 | Not provided in course material; fill when lab is attempted |
| B | Full `refresh_ssh_config.py` source code | Concept documented; exact implementation not shown in course text |
| C | Responder hash cracking workflow (hashcat/john rules) | Out of scope for this module; covered in general pen-test material |
