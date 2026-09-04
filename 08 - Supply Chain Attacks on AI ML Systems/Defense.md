# Module 08 — Defense & Detection

## Defender's Perspective
Supply chain attacks on AI/ML systems are uniquely dangerous because they exploit the trust inherent in third-party models, training pipelines, MCP servers, and fine-tuning workflows. Unlike traditional supply chain attacks, AI-specific vectors include: silent model behavior modification that bypasses all binary scanning, training data poisoning that corrupts model outputs without touching code, and serialization-based RCE that triggers only at inference time. The attack surface spans source code, model weights, tokenizer configs, training datasets, LoRA adapters, and MCP plugin repositories.

## Detection Opportunities

### MCP Server Backdoor / Zero-Width Unicode
**What to monitor:** Git commits that modify Python files with near-zero visible diff; string literals containing unusual Unicode ranges (U+200B–U+200F, U+FEFF); subprocess calls with `start_new_session=True`; telemetry/callback URLs not in approved allowlist.
**Detection rule / query:**
```bash
# Find zero-width characters in committed files
git log --all -p | grep -P '[\x{200B}-\x{200F}\x{FEFF}]'

# Grep repo for suspicious subprocess patterns
grep -rn "start_new_session=True" --include="*.py"
grep -rn "subprocess" --include="*.py" | grep -i "tel\|beacon\|callback\|exfil"
```
**Indicators of Compromise:** Outbound connections to unknown hosts from inference servers; commit diffs showing only whitespace changes in Python files; invisible characters between visible ones (hex dump reveals U+200B/U+200C sequences).
**False positive risk:** Some i18n libraries use zero-width joiners legitimately; subprocess with start_new_session used by some legitimate daemon patterns.

### Pickle Deserialization RCE
**What to monitor:** Calls to `torch.load()` with `weights_only=False` or without the flag (PyTorch <2.6); model files with GLOBAL opcodes targeting non-whitelisted modules; model ingestion from external/untrusted sources.
**Detection rule / query:**
```python
# Scan all model files in registry
from picklescan.scanner import scan_file_path
result = scan_file_path("model.pt")
if result.scan_err or any(r.globals for r in result.issues_by_severity.values()):
    alert("Suspicious pickle globals detected")
```
**Indicators of Compromise:** `picklescan` reports GLOBAL opcodes for `os`, `subprocess`, `socket`, `sympy`, `pandas`; model file larger than expected for architecture; torch.load() exceptions indicating malformed payload.
**False positive risk:** Some legacy models use custom unpickling via `__reduce__`; sympy itself is a legitimate math library — flag on sympy used inside model files specifically.

### Training Data Poisoning
**What to monitor:** Statistical drift in fine-tuning datasets; unusual completions containing IP addresses, SMB paths, or shell commands in training examples; model outputs containing attacker-controlled strings after fine-tuning.
**Detection rule / query:**
```python
# Scan JSONL for suspicious completion patterns
import re, json
SUSPICIOUS = re.compile(r'ProxyCommand|nc -[we]|/dev/tcp|wget|curl.*\d{1,3}\.\d{1,3}')
with open('train.jsonl') as f:
    for i, line in enumerate(f):
        ex = json.loads(line)
        if SUSPICIOUS.search(ex.get('completion', '')):
            print(f"Line {i}: SUSPICIOUS — {ex['completion'][:80]}")
```
**Indicators of Compromise:** Training JSONL containing shell command completions; repetitive identical examples (amplification pattern); Responder logs showing NTLMv2 hashes from inference workstations.
**False positive risk:** Security training datasets may legitimately include shell examples; adjust regex to context.

### LoRA Adapter Poisoning / AdapterEx Timing Gap
**What to monitor:** New adapter directories appearing in registry with newest mtime; time between adapter deployment and integrity check completion; adapter files with no corresponding training run in audit log.
**Detection rule / query:**
```bash
# Monitor adapter registry for new entries
inotifywait -m /srv/models/registry/ -e create -e moved_to |
while read dir action file; do
    echo "$(date): NEW ADAPTER $file — triggering immediate integrity check"
    python3 /opt/verify_adapter.py "$dir/$file"
done
```
**Indicators of Compromise:** Adapter deployed without associated training run ID; integrity check gap longer than expected; NTLMv2 hashes appearing in Responder logs shortly after model deployment.
**False positive risk:** Legitimate emergency hot-patch deployments may bypass normal workflow; require out-of-band approval for any mtime-based deployment.

### Tokenizer Manipulation
**What to monitor:** Changes to `vocab.json` and `tokenizer.json` not accompanied by retraining; token ID swaps between semantically opposite tokens; application-layer bypass of content filters after tokenizer update.
**Detection rule / query:**
```bash
# Hash both tokenizer files before and after any update
sha256sum vocab.json tokenizer.json | tee tokenizer_hashes.txt
# Alert if hashes change outside approved release pipeline
```
**Indicators of Compromise:** Strings that previously triggered filters no longer doing so after a "minor" tokenizer update; semantic confusion in model outputs (MAL tokens producing FUN responses); vocab.json and tokenizer.json modified in the same commit.
**False positive risk:** Legitimate tokenizer updates during model version bumps; pin expected hashes per model version.

### Code Review Agent Import Resolution (LFI)
**What to monitor:** Code review agents receiving diagnostic Python files; files containing `Path(__file__).resolve()` patterns; agent outputs containing file contents of config/secrets files.
**Detection rule / query:**
```python
# Scan submitted code for path traversal patterns
DANGEROUS = re.compile(r'Path\(__file__\).*parent|open\(.*\.\./|readlines\(\)')
if DANGEROUS.search(submitted_code):
    reject("Diagnostic path traversal detected in submission")
```
**Indicators of Compromise:** Agent output containing API keys, passwords, or config file contents; submitted scripts using `__file__` to resolve relative paths to parent directories.
**False positive risk:** Legitimate debug scripts use `__file__` for relative imports; review context — code review agents should not be running arbitrary submitted code against their own filesystem.

## Defensive Controls

| Control | What it mitigates | Implementation notes |
|---------|------------------|----------------------|
| `torch.load(weights_only=True)` | Pickle deserialization RCE | PyTorch 2.6+ default; explicitly set for all model loads |
| SafeTensors format | Pickle RCE | Does NOT protect against poisoned weights — combine with behavioral testing |
| picklescan in CI/CD | Pickle backdoors | Block any model file with dangerous GLOBAL opcodes before ingestion |
| Git pre-commit hook (ZWC scan) | Zero-width Unicode backdoors | Block commits containing U+200B–U+200F in Python files |
| Training data JSONL linting | Training data poisoning | Scan completions for shell commands, IPs, SMB paths before fine-tuning |
| Integrity check gap elimination | AdapterEx timing gap | Run integrity checker atomically with deployment, not asynchronously |
| Tokenizer file pinning | Tokenizer swap | SHA-256 pin vocab.json + tokenizer.json per approved model version |
| Sandbox code review agents | LFI via import resolution | Agents should evaluate code in isolated containers without filesystem access |
| Behavioral regression suite | Poisoned weights/adapters | Run post-deployment tests: does model still refuse known-bad completions? |
| Network egress filtering | ZWC beacon/exfil | Inference servers should not make outbound connections to unknown hosts |

## Monitoring Checklist
- [ ] picklescan integrated into model ingestion pipeline (block on GLOBAL opcode hits)
- [ ] All `torch.load()` calls audited for `weights_only=True`
- [ ] Git hooks scanning Python commits for zero-width Unicode
- [ ] Training JSONL scanner running before every fine-tuning job
- [ ] Adapter registry monitored with inotifywait or equivalent
- [ ] Integrity checker running atomically with adapter deployment (not async)
- [ ] Tokenizer file hashes pinned and alerted on unexpected change
- [ ] Code review agents sandboxed (no filesystem access to config/secrets)
- [ ] Responder/SMB anomaly detection on internal network
- [ ] Behavioral regression tests running post-deployment for every model update

## Incident Response Notes

**If picklescan alerts on GLOBAL opcode in model file:**
Quarantine the file immediately; trace origin (who uploaded, from which repo); check for lateral movement from any system that already loaded it; restore from last known-good checkpoint.

**If ZWC Unicode found in MCP server code:**
Treat as active compromise; rotate all credentials the MCP server had access to; audit git log for other suspicious whitespace-only commits; check for outbound connections from inference servers over past 30 days.

**If Responder captures NTLMv2 from inference workstations:**
Isolate affected workstations; check recent model outputs for SMB paths; audit training data for poisoned JSONL; crack hashes to assess credential exposure (hashcat -m 5600).

**If tokenizer outputs semantically incorrect content post-update:**
Roll back to pinned tokenizer version; audit the commit that changed vocab.json/tokenizer.json; check content filter bypass rate via behavioral tests.

## Architecture Hardening
- **Model registry air-gapping:** Inference servers pull models only from internal registry; no direct access to HuggingFace/GitHub from inference hosts.
- **Immutable model storage:** Model files in registry are write-once; updates create new versions rather than overwriting.
- **Signed model releases:** GPG-sign model release artifacts; verify signature before loading.
- **Separate ingestion and inference:** Model ingestion (with scanning) runs in isolated pipeline before models reach inference infrastructure.
- **Zero-trust fine-tuning:** Treat every fine-tuning dataset as untrusted; lint before use; run behavioral regression after every fine-tune.
- **LoRA adapter provenance:** Each adapter must have an associated training run ID in audit log; reject adapters with no provenance.
- **Code review agent isolation:** Run in containers with no filesystem access beyond the submitted file; no network egress.
