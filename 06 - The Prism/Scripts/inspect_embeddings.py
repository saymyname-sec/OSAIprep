#!/usr/bin/env python3
"""
Script: inspect_embeddings.py
Module: 06 — Attacking Embeddings
Purpose: Inspect a .npy embedding file — shape, normalization, statistics, candidate model map.
Usage: python3 inspect_embeddings.py embeddings.npy
Target: Any numpy .npy embedding file exported from Weaviate, Qdrant, or similar.
"""
import sys, numpy as np

CANDIDATE_MODELS = {
    384:  ["sentence-transformers/all-MiniLM-L6-v2",
           "sentence-transformers/all-MiniLM-L12-v2",
           "sentence-transformers/paraphrase-MiniLM-L6-v2"],
    768:  ["sentence-transformers/all-mpnet-base-v2",
           "sentence-transformers/all-distilroberta-v1",
           "BAAI/bge-base-en-v1.5"],
    1024: ["BAAI/bge-large-en-v1.5",
           "sentence-transformers/paraphrase-xlm-r-multilingual-v1"],
    1536: ["text-embedding-ada-002 (OpenAI)"],
}

def main():
    if len(sys.argv) < 2:
        print("Usage: inspect_embeddings.py <embeddings.npy>")
        sys.exit(1)

    emb = np.load(sys.argv[1]).astype(np.float32)
    n, dim = emb.shape

    print("=" * 60)
    print("Embedding Inspection")
    print("=" * 60)
    print(f"Shape        : {emb.shape}")
    print(f"Dtype        : {emb.dtype}")
    print(f"Memory       : {emb.nbytes // 1024} KB")
    print()
    print(f"Min          : {emb.min():.6f}")
    print(f"Max          : {emb.max():.6f}")
    print(f"Mean         : {emb.mean():.6f}")
    print(f"Std          : {emb.std():.6f}")

    norms = np.linalg.norm(emb, axis=1)
    normalized = np.allclose(norms, 1.0, atol=0.02)
    print()
    print(f"Norm range   : {norms.min():.4f} – {norms.max():.4f}")
    print(f"Normalized   : {normalized}  (similarity: {'cosine' if normalized else 'L2'})")

    print()
    print(f"Dimension    : {dim}")
    candidates = CANDIDATE_MODELS.get(dim, ["Unknown — use --models to specify manually"])
    print(f"Candidate models:")
    for m in candidates:
        print(f"  → {m}")

    print()
    print("First 10 values of vector[0]:")
    print(emb[0][:10])

if __name__ == "__main__":
    main()
