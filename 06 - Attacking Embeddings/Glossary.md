# Module 06 Glossary — Attacking Embeddings

**ALGEN (Alignment Generation)**
A few-shot embedding inversion technique that generates (text, embedding) alignment pairs — either via canary injection into the target RAG or via RAG probing — then fine-tunes a lightweight decoder (FlanT5-small) to map target-model embeddings back to text. Works even when the exact embedding model is unknown. Training time ~2 hours on CPU.

**AML.T0024 (Exfiltration via ML Inference API)**
MITRE ATT&CK for ML technique covering data exfiltration achieved by querying a machine learning API. In the embedding attack context, reading raw vectors from an unauthenticated Weaviate/Qdrant endpoint constitutes this technique.

**AML.T0024.000 (Membership Inference)**
Sub-technique of AML.T0024. An attacker determines whether a specific text or document was part of the model's training data or is indexed in the vector store, without direct document access.

**Alignment Matrix**
The mapping learned by ALGEN between an embedding model's vector space and natural language text. Constructed from canary (text, embedding) pairs; used to reconstruct text from previously unseen vectors.

**Attractor Candidate**
In membership inference, a known text variant whose embedding is computed and compared to stored vectors. If cosine similarity ≥ 0.97, the text is considered "attracted" to that stored vector — strong evidence of membership.

**Attribute Inference**
An embedding attack category in which an attacker predicts metadata about a source document (author, department, clearance level) by analyzing the cluster membership of its embedding among other known-author embeddings.

**Beam Search**
A text generation algorithm that maintains a fixed-width set (beam) of the most probable partial sequences at each decoding step. Used in zero2text_impl.py with GPT-2 to generate candidate reconstructions, pruning by cosine similarity to the target embedding at each step.

**Canary Injection**
An ALGEN technique where an attacker injects known text into a RAG system's ingestion pipeline, then queries the system to observe the embedding that results. The resulting (text, embedding) pair becomes an alignment training example.

**chunk_triage_pipe.py**
A three-stage pipeline (DENSITY → PW → RECON) that narrows all exported vectors down to the most likely credential-containing chunks using k-NN density scoring, contrastive probing, and shallow inversion with credential regex scoring.

**Contrastive Probing**
Stage 2 of chunk_triage_pipe.py. Each candidate chunk is scored against positive probes (real credential text) minus negative probes (policy/compliance text), then normalized by cluster membership. Narrows top-50 → top-20.

**Corrector (Vec2Text)**
The second model in Vec2Text's two-stage architecture. A T5-base decoder that takes the approximate text from the inverter plus the residual (original_embedding − embed(approx_text)) and iteratively corrects errors in the reconstruction. Runs 3–5 correction rounds per chunk.

**Cosine Similarity Gap**
The difference between the top-1 and top-2 candidate similarity scores during inversion. High gap = HIGH confidence; low gap = LOW confidence. Also used in membership inference margin scoring.

**Density Scoring**
Stage 1 of chunk_triage_pipe.py. Measures how semantically isolated a chunk is from the rest of the corpus using k-NN pairwise distances. Credential chunks tend to be semantically isolated (low density) compared to policy/procedure text.

**Dimensionality**
The number of floating-point values in an embedding vector. Dimension alone narrows candidate models: 384 → MiniLM family; 768 → MPNet/BGE-base; 1024 → BGE-large; 1536 → OpenAI ada-002.

**Diversity Clustering**
A step in emb_fin.py and membership inference that removes near-duplicate templates or probes using greedy cosine-similarity clustering (threshold 0.85). Prevents the same underlying probe from being counted multiple times.

**Domain Mismatch**
A limitation of template-bank inversion where the template bank was generated for generic enterprise text but the target RAG contains highly domain-specific content. Mitigated by using `--company` flag and adding domain-specific templates.

**emb_fin.py**
The primary zero-shot embedding inversion tool. Generates a 500k+ template bank, scores templates against the target vector, diversity-clusters the top candidates, then performs slot filling (progressive fill-and-lock) to recover the credential value.

**Embedding Inversion**
An attack category in which an attacker reconstructs the approximate original text from a stored embedding vector. Methods range from zero-shot (template bank) to supervised (Vec2Text, ~60hr training).

**Embedding Model Fingerprinting**
The process of identifying which encoder model produced the stored embedding vectors. Performed by checking vector dimension, normalization status, and computing cosine similarity between probe embeddings (from candidate models) and stored vectors.

**entropy detection**
In zero2text_impl.py, monitoring the Shannon entropy of GPT-2's per-token probability distribution during beam search. High entropy at a token position signals that the token is a credential (non-natural-language) → triggers slot filling at that position.

**Few-Shot Inversion**
Inversion approach requiring ~200–500 (text, embedding) training pairs. The ALGEN method is the primary few-shot approach. Works when the exact model is unknown; ~2 hours training time.

**generate_templates.py**
Script that produces the template bank used by emb_fin.py. Generates 500k+ sentence templates with `{PASSWORD}`, `{URL}`, `{API_KEY}` placeholders across multiple domain types (credentials, PII, financial, infrastructure).

**High-Entropy Token**
A token in a source document that is essentially random (e.g. a crypto-generated password). Not recoverable by semantic inversion models because the model's embedding space has no cluster for random strings. Recoverable only if the value appears in a wordlist.

**inference_probe.py**
The model fingerprinting script. Loads candidate models, generates probe embeddings, and computes cosine similarity against stored vectors to identify the exact model used by the target RAG.

**Inverter (Vec2Text)**
The first model in Vec2Text's two-stage architecture. An MLP projection layer + T5-base decoder that maps an embedding vector to an approximate text reconstruction. Output feeds the corrector.

**Margin-Aware Scoring**
Confidence reporting in emb_fin.py and membership inference: confidence = top1_sim − top2_sim. HIGH ≥ 0.15 (with 2+ independent probes), MODERATE 0.08–0.15, LOW < 0.08.

**Membership Inference**
An attack category (AML.T0024.000) in which an attacker determines whether a specific text is indexed in the target vector store by encoding known variants and computing cosine similarity against stored vectors.

**MLP Projection**
In Vec2Text's inverter, a learned multi-layer perceptron that maps the raw embedding vector (e.g. 384-dim) to the T5 decoder's hidden dimension (768-dim), bridging the embedding space and the language model.

**Normalization**
Whether embedding vectors have unit L2 norm (‖v‖ = 1.0). Normalized vectors indicate cosine-similarity training; dot product equals cosine similarity. Checked with `np.allclose(norms, 1.0, atol=0.02)`.

**Product Quantization**
A vector compression technique that divides high-dimensional vectors into sub-vectors and quantizes each independently. Reduces storage and search cost but lowers inversion fidelity by 10–40%.

**Progressive Fill-and-Lock**
A slot-filling strategy used by emb_fin.py and Vec2Text. Fill the first slot ({PASSWORD}) with all wordlist candidates → lock the top-1 → move to the next slot ({URL}) → repeat. Avoids combinatorial explosion when multiple slots are present.

**rag_probe_attack.py**
An ALGEN component script. Extracts domain keywords from RAG responses, crafts varied query probes, submits them to the RAG query endpoint, detects redaction markers in output (`[REDACTED]`), and performs slot filling at redacted positions.

**Reciprocal Rank Fusion (RRF)**
The fusion method used by chunk_triage_pipe.py to combine density, pw, and recon stage rankings. RRF score = Σ weight_i / (rank_i + k). Weights: density=1.0, pw=1.5, recon=2.0.

**Slot Filling**
The step in template-bank inversion where a wordlist entry is substituted into the `{PASSWORD}` (or other) slot of each template, the result is embedded, and cosine similarity to the target vector is computed. The highest-scoring substitution is the recovered value.

**Supervised Inversion (Vec2Text)**
The highest-accuracy inversion approach, requiring thousands of (text, embedding) pairs from the exact target model and ~60 hours of GPU training. Produces the Vec2Text inverter+corrector pair.

**Surrogate / Transfer Attack**
An inversion approach for unknown target models. Train Vec2Text or ALGEN on a surrogate model (same dimension family) then apply to the target. Accuracy degrades 15–30% vs exact-model training.

**Template Bank**
A large collection (500k+) of sentence templates with slot placeholders (e.g. `"The default password after resetting is {PASSWORD}"`), used by emb_fin.py to find the closest context to a target embedding before slot filling.

**Vec2Text**
A supervised embedding inversion framework using two T5-based models: an inverter (coarse reconstruction) and a corrector (residual-attending refinement). ~60 hours training on GPU; ~15 min/chunk inference. Highest accuracy of all inversion approaches.

**Zero-Shot Inversion**
Inversion without any training: encode a large template bank using the known model, find the nearest template to the target vector, then perform slot filling. Tools: emb_fin.py, ZSInvert, zero2text_impl.py.

**Zero2Text**
A zero-shot inversion method (arXiv 2602.01757v2) using GPT-2 beam search with dual-embedder scoring against the target embedding. Extended in zero2text_impl.py with entropy detection and slot filling at high-entropy token positions.

**ZSInvert**
Alternative name for the zero-shot inversion family (Zero2Text, emb_fin zero-shot mode). Works only when the embedding model is known; no training required.
