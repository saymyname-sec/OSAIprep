#!/bin/bash
# oneliners.sh — Module 06: Attacking Embeddings
# Quick reference one-liners for embedding attack operations

TARGET="${1:-192.168.218.14}"
WEAVIATE_PORT="${2:-8081}"

echo "[*] === Weaviate Enumeration ==="
# List all Weaviate schema classes
curl -s "http://$TARGET:$WEAVIATE_PORT/v1/schema" | python3 -m json.tool | grep '"class"'

# Weaviate version/meta
curl -s "http://$TARGET:$WEAVIATE_PORT/v1/meta" | python3 -c "import json,sys; d=json.load(sys.stdin); print(f\"Version: {d.get('version','?')}\")"

echo "[*] === Qdrant Enumeration ==="
# Qdrant version
curl -s "http://$TARGET:6333/" | python3 -c "import json,sys; d=json.load(sys.stdin); print(f\"Qdrant {d['version']}\")"

# Qdrant list collections
curl -s "http://$TARGET:6333/collections" | python3 -m json.tool

echo "[*] === Local Model Discovery ==="
find / -type d -name "*MiniLM*" 2>/dev/null | head -5
find / -type d -name "*bge*" 2>/dev/null | head -5
find /root/.cache/huggingface/hub -maxdepth 2 -type d 2>/dev/null

echo "[*] === Embedding Inspection ==="
python3 - << 'EOF'
import numpy as np
import glob, sys
for f in glob.glob("/tmp/*.npy") + glob.glob("export/*.npy"):
    e = np.load(f).astype(np.float32)
    norms = np.linalg.norm(e, axis=1)
    print(f"{f}: shape={e.shape}  normalized={np.allclose(norms,1.0,atol=0.02)}")
EOF

echo "[*] === Pack2TheRoot Privesc Check ==="
pkcon --version 2>/dev/null || echo "pkcon not found"
dpkg -l packagekit 2>/dev/null | grep packagekit
# Vulnerable: packagekit 1.2.8-2ubuntu1.4  (fixed in .5)
