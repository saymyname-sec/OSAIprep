# Module 02 — Glossary: Reconnaissance for AI Targets

---

## A

**A2A (Agent-to-Agent)**
Protocol for AI agents to communicate and delegate tasks. Agents expose capabilities via an agent card at `/.well-known/agent.json`. Discovering this file during recon reveals available tools and permissions.

**API Gateway**
Network entry point that sits in front of AI services. Common products: Kong, AWS API Gateway, Azure APIM. Fingerprinted via `Server:` headers and `X-Kong-*` response headers. Returns 401 (not 404) for valid but unauthorized endpoints — useful for enumeration.

**AST-aware chunking**
A RAG chunking strategy that splits documents at code syntax boundaries (Abstract Syntax Tree nodes) rather than by character count. Seen in `config/rag.yaml` as `chunking_strategy: ast_aware`. Indicates the RAG system is optimized for code documents.

---

## B

**BM25**
Best Match 25 — a classical keyword-based ranking algorithm used in hybrid RAG retrieval alongside vector similarity. When RAG metadata includes a `bm25_score` alongside a `vector_score`, the system uses hybrid retrieval. Higher BM25 score = stronger keyword match.

---

## C

**Canary token / Honeypot credential**
A fake secret (API key, password, AWS key) deliberately placed in a codebase or document to detect unauthorized access. Real AWS access keys are purely alphanumeric; a canary key contains a readable word like `AKIAIOSFODNN7HONEYPOT`. Triggering it alerts the blue team.

**Chunk size**
In RAG systems, the maximum token/character length of each document segment stored in the vector database. Found in `config/rag.yaml` as `chunk_size`. Affects retrieval granularity — smaller chunks = more precise retrieval; larger chunks = more context per result.

**Context window**
The maximum number of tokens an LLM can process in a single inference call. Can be fingerprinted by injecting a long random marker string, then asking the model to repeat it — if it fails, the context limit has been reached.

**Combined score**
In hybrid RAG retrieval, the weighted sum of `vector_score` and `bm25_score`. Appears in source metadata as `combined_score`. The retrieval threshold is applied to this combined value.

---

## E

**Embedding model**
A model that converts text into high-dimensional numeric vectors for storage in a vector database. The vector dimensionality identifies the embedding model: 768 → Google `text-embedding-004`, 1536 → OpenAI `ada-002`, 256 → code models (`codet5p-110m`), 3072 → OpenAI `text-embedding-3-large`.

---

## G

**Grounding documents**
The source documents retrieved from a RAG knowledge base that are injected into an LLM's context to answer a query. Also called "retrieved context" or "RAG context". The `sources` array in an API response contains metadata about which grounding documents were used.

---

## H

**Hybrid retrieval**
A RAG retrieval strategy combining dense vector similarity search with sparse keyword-based BM25 search. More robust than either alone. Identified when RAG metadata includes both `vector_score` and `bm25_score` fields.

---

## I

**Inference server**
The software layer that hosts an LLM and serves prediction (inference) requests. Common examples: Ollama (port 11434), vLLM (port 8000), LM Studio (port 1234), Hugging Face TGI (port 8080). Each exposes an OpenAI-compatible REST API.

---

## K

**Knowledge cutoff**
The date after which an LLM has no training data. Used for model fingerprinting: ask about an event that occurred between known cutoff dates (e.g., GPT-4o was released May 2024 — if the model knows this, it's GPT-4o or trained after May 2024). Models trained before the event will say they don't know.

---

## O

**OpenAI-compatible API**
A REST API that mirrors OpenAI's `/v1/chat/completions`, `/v1/models`, and `/v1/embeddings` endpoints. Most self-hosted inference servers (Ollama, vLLM, LM Studio) implement this interface, making them identifiable by the same endpoint paths and response schema.

**Orchestration layer**
The middleware between an API gateway and the model. Handles routing, tool calling, RAG retrieval, and agent logic. Examples: LangChain, LlamaIndex, CrewAI. Fingerprinted via `requirements.txt` imports and response envelope structure.

---

## R

**RAG (Retrieval-Augmented Generation)**
Architecture where an LLM's responses are grounded in documents retrieved from an external knowledge base at inference time. The model receives both the user query and retrieved document chunks as context. Vulnerable to poisoning (Module 6) and prompt injection via documents (Module 5).

**RLHF (Reinforcement Learning from Human Feedback)**
Training technique where human raters score model outputs to shape behavior via reinforcement learning. Creates strong behavioral tendencies — including identity associations. Exploited in false attribution fingerprinting: RLHF-trained models are conditioned to correct false identity claims.

**Retrieval threshold**
The minimum similarity score a document chunk must exceed to be included in RAG results. Can be probed by degrading query quality: exact match → synonyms → misspellings. When results drop to zero, the threshold boundary has been crossed.

---

## S

**SIEM detection rule**
Security Information and Event Management rules that flag suspicious LLM queries. Common triggers: "what documents", "confidential", "salary", "system prompt". Evasion requires rephrasing direct probes as contextual, indirect questions.

**System prompt**
Hidden instructions prepended to an LLM conversation that configure its behavior, persona, and constraints. Extractable via recon (reading `prompts/system.txt` in repos) or via prompt injection (Module 3). Critical target during engagement.

---

## V

**Vector database**
A database that stores document embeddings (numeric vectors) and supports similarity search. Examples: Pinecone (cloud), Milvus/pymilvus (self-hosted), Chroma, Qdrant. Identified via `requirements.txt` imports or `config/rag.yaml` settings.

**Vector score**
The cosine similarity (or dot product) between a query embedding and a stored document chunk embedding. Returned in RAG source metadata. Higher = more semantically similar.

**vLLM**
An open-source, high-throughput LLM inference server optimized for production. Default port 8000. Exposes OpenAI-compatible API. Presence of `vllm` in `requirements.txt` confirms self-hosted inference.

---

*Last updated: Module 02 gap fill pass*
