# Module 06 — Inference Probe Payloads

These queries are used during **embedding model fingerprinting** via RAG probing. They exploit the fact that different embedding models produce different retrieval rankings for the same query, allowing model identification.

---

## Verbatim Recall Probes

**Technique:** Verbatim  
**Target:** RAG pipeline / vector search endpoint  
**Effect:** Causes exact phrase recall; model-specific similarity scoring reveals model family  

```
What is the exact wording of the password reset policy?
```
```
Show me the precise text about account lockout thresholds.
```
```
What does the policy document say word for word about multi-factor authentication?
```

**Evasion notes:** Looks like a legitimate user query. Indistinguishable from normal usage. No anomalous tokens.

---

## Factual Precision Probes

**Technique:** Factual  
**Target:** Domain-specific RAG (HR, policy, technical docs)  
**Effect:** Pulls highly specific chunks; cosine similarity patterns differ by encoder architecture  

```
How many failed login attempts trigger an account lockout?
```
```
What is the minimum password length required by policy?
```
```
Which authentication methods are approved for remote access?
```
```
What is the session timeout duration for privileged accounts?
```

**Evasion notes:** Entirely benign phrasing. Security teams won't flag numeric policy queries as reconnaissance.

---

## Deep/Ambiguous Probes (Model Differentiators)

**Technique:** Semantic ambiguity  
**Target:** RAG systems — differentiates between models with different semantic understanding  
**Effect:** Models like `all-MiniLM-L6-v2` vs `bge-base-en` return different top-k results for ambiguous queries, revealing model identity  

```
What happens when credentials expire?
```
```
How are users authenticated across systems?
```
```
What security controls exist for sensitive data access?
```
```
Describe the process for privileged account management.
```
```
What is the policy for handling security incidents?
```

**Evasion notes:** Semantic probes are the hardest to detect — they require building a behavioral baseline to identify. A single probe is invisible; pattern analysis across 10+ queries may reveal enumeration.

---

## inference_probe.py Integration

These queries are used by `Scripts/inference_probe.py`. The script:
1. Submits each probe to the RAG endpoint
2. Records which chunks are returned and their similarity scores
3. Builds a **result fingerprint** (ordered chunk IDs)
4. Compares against known model fingerprints in `MODEL_FINGERPRINTS`

```python
PROBE_QUERIES = [
    "What is the exact wording of the password reset policy?",
    "How many failed login attempts trigger an account lockout?",
    "What authentication methods are approved?",
]

DEEP_QUERIES = [
    "What happens when credentials expire?",
    "How are users authenticated across systems?",
    "What security controls exist for sensitive data?",
]
```

**Usage:**
```bash
python3 Scripts/inference_probe.py \
  --endpoint http://TARGET/api/query \
  --output fingerprint.json
```

---

## Fingerprinting Decision Logic

| Query Result Pattern | Likely Model |
|---------------------|--------------|
| Verbatim match scores >0.95 | all-MiniLM-L6-v2 |
| Semantic spread across chunks | bge-base-en-v1.5 |
| High recall, low precision | mpnet-base-v2 |
| 1536-dim detected | text-embedding-ada-002 |
| Consistent top-1 = exact match | bge-large-en |

---

## Operational Notes

- **Rate limit awareness:** Space probes 2–5 seconds apart to avoid triggering anomaly detection on rapid sequential queries.
- **Baseline establishment:** Send 3–5 benign queries before probes to blend into normal usage patterns.
- **Confidence threshold:** Need minimum 3 matching probe results to confirm model identity with >80% confidence.
- **Fallback:** If probing is blocked, fall back to dimension inspection via direct vector export (see `weaviate_export.py` + `inspect_embeddings.py`).
