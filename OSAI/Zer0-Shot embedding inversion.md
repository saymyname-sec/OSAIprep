**Template-based embedding inversion**

`source venv/bin/activate`

```python3 generate_templates.py --output templates.json embeddings.npy --count 500000```


`wget -O passwords.txt 
https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Passwords/Common-Credentials/100k-most-used-passwords-NCSC.txt`

`python emb_fin.py embeddings.npy --chunk 0 --templates templates.json --wordlist passwords.txt --slots PASSWORD --default-URL https://login.megacorpone.ai --max-templates 500000`

`pdftotext MC1_password_reset.pdf`

**FINGERPRINTING EMBEDDINGS:**
Are vectors normalized?
```
import numpy as np

emb = np.load("embeddings2.npy")

print(np.linalg.norm(emb[0]))
```
Dimension
```
import numpy as np

emb = np.load("embeddings2.npy")

print(emb.shape)
```
Inspect embedding Script
```
#!/usr/bin/env python3

import numpy as np

# Load embedding
emb = np.load("embeddings2.npy")

print("=" * 60)
print("Embedding inspection")
print("=" * 60)

print(f"Shape        : {emb.shape}")
print(f"Data type    : {emb.dtype}")

print("\nFirst 20 values:\n")
print(emb[0][:20])

print("\nStatistics")
print("-" * 60)

print(f"Minimum      : {emb.min():.6f}")
print(f"Maximum      : {emb.max():.6f}")
print(f"Mean         : {emb.mean():.6f}")
print(f"Std deviation: {emb.std():.6f}")

print("\nNaN values   :", np.isnan(emb).any())
print("Inf values   :", np.isinf(emb).any())

print("\nLast 20 values:\n")
print(emb[0][-20:])
```
Check Normalization : 
```
#!/usr/bin/env python3

import numpy as np

emb = np.load("embeddings2.npy")

print("=" * 60)
print("Vector norm")
print("=" * 60)

for i, vec in enumerate(emb):
    norm = np.linalg.norm(vec)

    print(f"Vector {i}")
    print(f"Norm : {norm:.6f}")

    if abs(norm - 1.0) < 0.01:
        print("Likely normalized")
    else:
        print("Not normalized")

    print()
```
Additional useful inspection:
```
#!/usr/bin/env python3

import numpy as np

emb = np.load("embeddings2.npy")

print("="*60)
print("General information")
print("="*60)

print(f"Shape          : {emb.shape}")
print(f"Dtype          : {emb.dtype}")
print(f"Itemsize       : {emb.itemsize} bytes")
print(f"Dimensions     : {emb.ndim}")
print(f"Total elements : {emb.size}")
print(f"Memory usage   : {emb.nbytes} bytes")

print("\nStatistics")
print("="*60)

print(f"Mean           : {emb.mean()}")
print(f"Median         : {np.median(emb)}")
print(f"Variance       : {emb.var()}")
print(f"Std            : {emb.std()}")

print("\nDistribution")
print("="*60)

print(f"Min            : {emb.min()}")
print(f"25%            : {np.percentile(emb,25)}")
print(f"50%            : {np.percentile(emb,50)}")
print(f"75%            : {np.percentile(emb,75)}")
print(f"Max            : {emb.max()}")
```
Automated script for embeddings.
```#!/usr/bin/env python3
"""Evidence-based forensic reconnaissance for offline NumPy embedding files.

This utility deliberately does not attempt embedding inversion or text recovery.
It describes structural and statistical properties and ranks compatible model
families; its findings are hypotheses, not identifications.
"""
from __future__ import annotations

import argparse
import hashlib
import html
import json
import platform
import sys
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Sequence

import numpy as np

try:
    from scipy import stats
except ImportError:  # Small, deterministic fallbacks keep the core tool usable.
    stats = None

try:
    from tabulate import tabulate
except ImportError:
    tabulate = None

try:
    from rich.console import Console
except ImportError:
    Console = None


def json_default(value: Any) -> Any:
    """Convert NumPy and path objects to JSON-safe equivalents."""
    if isinstance(value, (np.integer, np.floating)):
        return value.item()
    if isinstance(value, np.ndarray):
        return value.tolist()
    if isinstance(value, Path):
        return str(value)
    raise TypeError(f"Cannot serialize {type(value).__name__}")


def finite(values: np.ndarray) -> np.ndarray:
    """Return only finite values from an array."""
    return values[np.isfinite(values)]


@dataclass
class Finding:
    """A confidence-calibrated inference suitable for a forensic report."""
    label: str
    confidence: float
    evidence: list[str]
    reasoning: str


@dataclass
class AnalysisResult:
    """All report sections collected by the independent analysis modules."""
    file: dict[str, Any]
    structure: dict[str, Any]
    statistics: dict[str, Any]
    normalization: dict[str, Any]
    distribution: dict[str, Any]
    similarity: dict[str, Any]
    candidates: list[Finding]
    heuristics: list[Finding]
    recommendations: list[str]
    warnings: list[str] = field(default_factory=list)
    plots: list[str] = field(default_factory=list)


class EmbeddingLoader:
    """Safely load an offline ``.npy`` file and collect file provenance."""

    def __init__(self, path: Path) -> None:
        self.path = path.expanduser().resolve()

    def load(self) -> np.ndarray:
        if not self.path.is_file():
            raise FileNotFoundError(f"Input file does not exist: {self.path}")
        if self.path.suffix.lower() != ".npy":
            raise ValueError("Only offline .npy files are supported")
        array = np.load(self.path, allow_pickle=False)
        if not isinstance(array, np.ndarray):
            raise ValueError("The file did not contain a NumPy ndarray")
        return array

    def file_information(self) -> dict[str, Any]:
        hashes = {"sha256": hashlib.sha256(), "md5": hashlib.md5()}
        with self.path.open("rb") as handle:
            while chunk := handle.read(1024 * 1024):
                for digest in hashes.values():
                    digest.update(chunk)
        stat = self.path.stat()
        created = datetime.fromtimestamp(stat.st_ctime, tz=timezone.utc).isoformat()
        return {
            "filename": self.path.name, "absolute_path": str(self.path),
            "sha256": hashes["sha256"].hexdigest(), "md5": hashes["md5"].hexdigest(),
            "file_size_bytes": stat.st_size, "creation_time_utc": created,
            "numpy_version": np.__version__, "python_version": sys.version.split()[0],
            "platform": platform.platform(),
        }


class StatisticsAnalyzer:
    """Calculate robust scalar statistics without modifying source data."""

    def analyze(self, array: np.ndarray) -> dict[str, Any]:
        values = array.astype(np.float64, copy=False).ravel()
        usable = finite(values)
        total = values.size
        output: dict[str, Any] = {
            "value_count": int(total), "nan_count": int(np.isnan(values).sum()),
            "inf_count": int(np.isinf(values).sum()), "zero_count": int((values == 0).sum()),
            "positive_count": int((values > 0).sum()), "negative_count": int((values < 0).sum()),
        }
        if not usable.size:
            return output | {"error": "No finite values available for numerical statistics."}
        median = float(np.median(usable))
        counts = np.unique(usable, return_counts=True)[1]
        probabilities = counts / counts.sum()
        output.update({
            "minimum": float(usable.min()), "maximum": float(usable.max()),
            "mean": float(usable.mean()), "median": median,
            "variance": float(usable.var()), "std": float(usable.std()),
            "mad": float(np.median(np.abs(usable - median))),
            "percentiles": {str(p): float(np.percentile(usable, p)) for p in (1, 5, 25, 50, 75, 95, 99)},
            "duplicate_values": int(usable.size - np.unique(usable).size),
            "entropy_estimate_bits": float(-(probabilities * np.log2(probabilities)).sum()),
            "histogram": self._histogram(usable),
            "skewness": self._skew(usable), "kurtosis_excess": self._kurtosis(usable),
        })
        return output

    @staticmethod
    def _histogram(values: np.ndarray) -> dict[str, list[float] | list[int]]:
        counts, edges = np.histogram(values, bins="auto")
        return {"counts": counts.astype(int).tolist(), "bin_edges": edges.tolist()}

    @staticmethod
    def _skew(values: np.ndarray) -> float:
        if stats:
            return float(stats.skew(values, bias=False))
        std = values.std()
        return float(np.mean(((values - values.mean()) / std) ** 3)) if std else 0.0

    @staticmethod
    def _kurtosis(values: np.ndarray) -> float:
        if stats:
            return float(stats.kurtosis(values, bias=False))
        std = values.std()
        return float(np.mean(((values - values.mean()) / std) ** 4) - 3) if std else 0.0


class NormalizationAnalyzer:
    """Assess L1, L2, and infinity norms per vector."""

    def analyze(self, vectors: np.ndarray) -> dict[str, Any]:
        if vectors.ndim != 2 or not np.isfinite(vectors).all():
            return {"status": "unavailable", "reasoning": "Requires a finite 2-D vector matrix."}
        l1 = np.linalg.norm(vectors, ord=1, axis=1)
        l2 = np.linalg.norm(vectors, axis=1)
        linf = np.linalg.norm(vectors, ord=np.inf, axis=1)
        near_unit = np.isclose(l2, 1.0, rtol=0.01, atol=0.01)
        fraction = float(near_unit.mean())
        if fraction >= .98:
            status, reason = "approximately unit normalized", "At least 98% of L2 norms fall within 1% of 1.0."
        elif fraction >= .10:
            status, reason = "mixed normalization", "Some vectors are near unit length while others are not."
        else:
            status, reason = "not unit normalized", "Fewer than 10% of vectors are within 1% of unit length."
        return {"status": status, "reasoning": reason, "unit_fraction": fraction,
                "l1": self._summary(l1), "l2": self._summary(l2), "linf": self._summary(linf),
                "average_norm": float(l2.mean()), "norm_variance": float(l2.var())}

    @staticmethod
    def _summary(values: np.ndarray) -> dict[str, float]:
        return {"min": float(values.min()), "max": float(values.max()), "mean": float(values.mean()),
                "median": float(np.median(values)), "std": float(values.std())}


class DistributionAnalyzer:
    """Add embedding-focused distribution observations."""

    def analyze(self, statistics: dict[str, Any]) -> dict[str, Any]:
        if "error" in statistics:
            return {"status": "unavailable"}
        observations: list[str] = []
        if abs(statistics["mean"]) < max(statistics["std"] * .05, 1e-9):
            observations.append("Values are approximately centered around zero.")
        if statistics["duplicate_values"]:
            observations.append("Repeated scalar values exist; this is common in quantized or sparse data.")
        if abs(statistics["skewness"]) > 1:
            observations.append("The value distribution is materially skewed.")
        return {"observations": observations, "skewness": statistics["skewness"],
                "kurtosis_excess": statistics["kurtosis_excess"], "entropy_estimate_bits": statistics["entropy_estimate_bits"]}


class SimilarityAnalyzer:
    """Analyze vector relationships, sampling safely for large files."""

    def __init__(self, maximum_vectors: int = 2000) -> None:
        self.maximum_vectors = maximum_vectors

    def analyze(self, vectors: np.ndarray) -> dict[str, Any]:
        if vectors.ndim != 2 or vectors.shape[0] < 2:
            return {"status": "skipped", "reasoning": "Similarity analysis requires multiple vectors."}
        if not np.isfinite(vectors).all():
            return {"status": "skipped", "reasoning": "Similarity analysis requires finite values."}
        sampled = vectors[:self.maximum_vectors]
        norms = np.linalg.norm(sampled, axis=1)
        safe = np.where(norms == 0, 1, norms)
        cosine = (sampled / safe[:, None]) @ (sampled / safe[:, None]).T
        distances = np.sqrt(np.maximum(0, (sampled ** 2).sum(1)[:, None] + (sampled ** 2).sum(1)[None, :] - 2 * sampled @ sampled.T))
        np.fill_diagonal(cosine, np.nan)
        duplicate_vectors = int(sampled.shape[0] - np.unique(sampled, axis=0).shape[0])
        nearest = np.nanargmax(cosine, axis=1)
        nearest_scores = np.nanmax(cosine, axis=1)
        outliers = np.where(nearest_scores < np.nanpercentile(nearest_scores, 5))[0].tolist()
        result: dict[str, Any] = {
            "status": "completed", "analyzed_vectors": int(sampled.shape[0]), "sampled": vectors.shape[0] > sampled.shape[0],
            "average_cosine_similarity": float(np.nanmean(cosine)), "duplicate_vectors": duplicate_vectors,
            "nearest_neighbors": [{"vector": int(i), "neighbor": int(nearest[i]), "cosine": float(nearest_scores[i])}
                                  for i in range(min(20, sampled.shape[0]))],
            "outlier_indices": [int(i) for i in outliers],
            "cluster_hint": "possible tight groups" if float(np.nanpercentile(cosine, 95)) > .8 else "no strong tight-group signal",
        }
        # Matrices are intentionally capped for JSON/report practicality.
        if sampled.shape[0] <= 200:
            result["cosine_similarity_matrix"] = cosine
            result["euclidean_distance_matrix"] = distances
        return result


@dataclass(frozen=True)
class ModelProfile:
    name: str; dimension: int | tuple[int, ...]; normalized: bool | None
    pooling: str; tokenizer: str; notes: str; family: str


class ModelFingerprintEngine:
    """Rank known profiles from independently observable, non-identifying traits."""

    def __init__(self) -> None:
        self.profiles = self._knowledge_base()

    @staticmethod
    def _knowledge_base() -> list[ModelProfile]:
        p = ModelProfile
        return [
            p("all-MiniLM-L6-v2", 384, True, "mean", "WordPiece", "Sentence Transformers", "Sentence Transformers"),
            p("all-MiniLM-L12-v2", 384, True, "mean", "WordPiece", "Sentence Transformers", "Sentence Transformers"),
            p("all-mpnet-base-v2", 768, True, "mean", "WordPiece", "Sentence Transformers", "Sentence Transformers"),
            p("e5-small", 384, True, "mean", "WordPiece", "query/passage prefixes", "E5"),
            p("e5-base", 768, True, "mean", "WordPiece", "query/passage prefixes", "E5"),
            p("e5-large", 1024, True, "mean", "WordPiece", "query/passage prefixes", "E5"),
            p("bge-small-en-v1.5", 384, True, "CLS", "WordPiece", "BAAI BGE", "BGE"),
            p("bge-base-en-v1.5", 768, True, "CLS", "WordPiece", "BAAI BGE", "BGE"),
            p("bge-large-en-v1.5", 1024, True, "CLS", "WordPiece", "BAAI BGE", "BGE"),
            p("gte-small", 384, True, "mean", "WordPiece", "Alibaba GTE", "GTE"),
            p("gte-base", 768, True, "mean", "WordPiece", "Alibaba GTE", "GTE"),
            p("gte-large", 1024, True, "mean", "WordPiece", "Alibaba GTE", "GTE"),
            p("Instructor models", 768, None, "masked mean", "WordPiece", "Instruction-conditioned", "Instructor"),
            p("Jina embeddings v2", (512, 768, 1024), None, "mean", "WordPiece", "Version dependent", "Jina"),
            p("Nomic embed text v1.5", 768, True, "mean", "BPE", "Matryoshka-capable", "Nomic"),
            p("text-embedding-ada-002", 1536, None, "service-defined", "service-defined", "OpenAI legacy", "OpenAI"),
            p("text-embedding-3-small", (512, 1536), None, "service-defined", "service-defined", "Dimensions may be shortened", "OpenAI"),
            p("text-embedding-3-large", (256, 1024, 3072), None, "service-defined", "service-defined", "Dimensions may be shortened", "OpenAI"),
            p("Cohere embed English v3", 1024, None, "service-defined", "service-defined", "Provider output", "Cohere"),
            p("Voyage embeddings", (512, 1024, 2048), None, "service-defined", "service-defined", "Model/version dependent", "Voyage"),
        ]

    def rank(self, structure: dict[str, Any], normalization: dict[str, Any]) -> list[Finding]:
        dimension = structure.get("vector_dimension")
        normalized = normalization.get("status") == "approximately unit normalized"
        candidates: list[Finding] = []
        for profile in self.profiles:
            dimensions = (profile.dimension,) if isinstance(profile.dimension, int) else profile.dimension
            evidence: list[str] = []
            score = 0.0
            if dimension in dimensions:
                score += .65; evidence.append(f"dimension {dimension} matches known profile dimension")
            else:
                evidence.append(f"dimension {dimension} does not match this profile")
            if profile.normalized is None:
                score += .10; evidence.append("normalization is not a decisive published profile trait")
            elif profile.normalized == normalized:
                score += .25; evidence.append("observed unit-normalization behavior is compatible")
            else:
                evidence.append("observed normalization behavior differs from the typical profile")
            candidates.append(Finding(profile.name, min(score, .95), evidence,
                f"{profile.family}: {profile.notes}. This is compatibility evidence only; many models share these traits."))
        return sorted(candidates, key=lambda candidate: candidate.confidence, reverse=True)

    def family_heuristics(self, candidates: Sequence[Finding]) -> list[Finding]:
        families: dict[str, list[Finding]] = {}
        for candidate in candidates:
            profile = next(p for p in self.profiles if p.name == candidate.label)
            families.setdefault(profile.family, []).append(candidate)
        results = []
        for family, matches in families.items():
            confidence = max(match.confidence for match in matches)
            results.append(Finding(f"likely {family}", confidence,
                [f"Best compatible profile: {max(matches, key=lambda x: x.confidence).label}"],
                "Family-level heuristic based mainly on dimension and normalization; it is not proof of origin."))
        return sorted(results, key=lambda item: item.confidence, reverse=True)


class VisualizationEngine:
    """Write optional diagnostic PNGs without making plots mandatory."""

    def create(self, vectors: np.ndarray, similarity: dict[str, Any], directory: Path) -> list[str]:
        try:
            import matplotlib
            matplotlib.use("Agg")
            import matplotlib.pyplot as plt
        except ImportError as error:
            raise RuntimeError("--plots requires matplotlib") from error
        directory.mkdir(parents=True, exist_ok=True)
        values = finite(vectors.astype(float, copy=False).ravel())
        paths: list[str] = []
        def save(name: str) -> None:
            path = directory / name; plt.tight_layout(); plt.savefig(path, dpi=150); plt.close(); paths.append(str(path))
        plt.hist(values, bins="auto"); plt.title("Embedding value histogram"); plt.xlabel("Value"); plt.ylabel("Count"); save("histogram.png")
        plt.boxplot(values, vert=False); plt.title("Embedding value boxplot"); save("boxplot.png")
        if vectors.ndim == 2 and vectors.shape[0] >= 2:
            sample = vectors[:min(2000, len(vectors))].astype(float)
            centered = sample - sample.mean(axis=0)
            _, _, vh = np.linalg.svd(centered, full_matrices=False)
            projected = centered @ vh[:2].T
            plt.scatter(projected[:, 0], projected[:, 1], s=8, alpha=.65); plt.title("PCA projection"); plt.xlabel("PC1"); plt.ylabel("PC2"); save("pca.png")
        matrix = similarity.get("cosine_similarity_matrix")
        if matrix is not None:
            plt.imshow(matrix, cmap="coolwarm", vmin=-1, vmax=1); plt.colorbar(label="cosine similarity"); plt.title("Cosine similarity heatmap"); save("cosine_heatmap.png")
        return paths


class ReportGenerator:
    """Render the result as readable console, JSON, HTML, or Markdown output."""

    def console(self, result: AnalysisResult, candidate_limit: int = 10) -> str:
        lines = ["=" * 60, "Embedding Fingerprint Report", "=" * 60]
        for title, section in (("General Information", result.file), ("Structure", result.structure),
                               ("Statistics", result.statistics), ("Normalization", result.normalization),
                               ("Distribution", result.distribution), ("Similarity", result.similarity)):
            lines.extend(["", title, "-" * len(title), self._mapping(section)])
        lines.extend(["", "Model Candidates", "-" * 16])
        lines.extend(self._candidate_table(result.candidates[:candidate_limit]))
        lines.extend(["", "Evidence / Family Heuristics", "-" * 28])
        lines.extend(self._findings(result.heuristics[:8]))
        lines.extend(["", "Recommendations", "-" * 15] + [f"- {item}" for item in result.recommendations])
        if result.warnings:
            lines.extend(["", "Warnings", "-" * 8] + [f"- {item}" for item in result.warnings])
        return "\n".join(lines)

    @staticmethod
    def _mapping(section: dict[str, Any]) -> str:
        return "\n".join(f"{key}: {value}" for key, value in section.items() if not isinstance(value, (dict, np.ndarray)))

    @staticmethod
    def _findings(items: Sequence[Finding]) -> list[str]:
        return [f"{i + 1}. {item.label} — confidence {item.confidence:.0%}\n   Evidence: {'; '.join(item.evidence)}\n   {item.reasoning}" for i, item in enumerate(items)]

    @staticmethod
    def _candidate_table(items: Sequence[Finding]) -> list[str]:
        """Use tabulate when installed, with a plain-text fallback."""
        rows = [[index + 1, item.label, f"{item.confidence:.0%}", "; ".join(item.evidence)]
                for index, item in enumerate(items)]
        if tabulate:
            return [tabulate(rows, headers=("Rank", "Model", "Confidence", "Evidence"), tablefmt="simple")]
        return [f"{row[0]}. {row[1]} — {row[2]}: {row[3]}" for row in rows]

    def json(self, result: AnalysisResult) -> str:
        return json.dumps(asdict(result), indent=2, default=json_default)

    @staticmethod
    def display(text: str) -> None:
        """Render with Rich when available, preserving plain-text portability."""
        if Console:
            Console().print(text, markup=False, highlight=False)
        else:
            print(text)

    def html(self, result: AnalysisResult) -> str:
        report = html.escape(self.console(result))
        return f"<!doctype html><html><head><meta charset='utf-8'><title>Embedding Fingerprint Report</title><style>body{{font:15px system-ui;margin:2rem;background:#fafafa}}pre{{white-space:pre-wrap;background:white;padding:1.5rem;border:1px solid #ddd}}</style></head><body><pre>{report}</pre></body></html>"

    def markdown(self, result: AnalysisResult) -> str:
        return "# Embedding Fingerprint Report\n\n```text\n" + self.console(result) + "\n```\n"


class CLI:
    """Coordinate analysis modules and command-line output."""

    def parser(self) -> argparse.ArgumentParser:
        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument("embedding_file", type=Path, help="Offline NumPy .npy embedding file")
        parser.add_argument("--json", dest="json_path", type=Path, help="Write structured JSON report")
        parser.add_argument("--html", dest="html_path", type=Path, help="Write HTML report")
        parser.add_argument("--markdown", type=Path, help="Write Markdown report")
        parser.add_argument("--plots", action="store_true", help="Write diagnostic PNGs beside the input file")
        parser.add_argument("--verbose", action="store_true", help="Include expanded candidates in console output")
        return parser

    def run(self, arguments: Sequence[str] | None = None) -> int:
        args = self.parser().parse_args(arguments)
        try:
            loader = EmbeddingLoader(args.embedding_file); array = loader.load()
            structure, vectors, warnings = self._structure(array)
            statistics = StatisticsAnalyzer().analyze(array)
            normalization = NormalizationAnalyzer().analyze(vectors)
            distribution = DistributionAnalyzer().analyze(statistics)
            similarity = SimilarityAnalyzer().analyze(vectors)
            engine = ModelFingerprintEngine(); candidates = engine.rank(structure, normalization)
            heuristics = engine.family_heuristics(candidates)
            recommendations = self._recommend(structure, normalization, candidates, warnings)
            result = AnalysisResult(loader.file_information(), structure, statistics, normalization, distribution,
                                    similarity, candidates, heuristics, recommendations, warnings)
            if args.plots:
                result.plots = VisualizationEngine().create(vectors, similarity, loader.path.parent / f"{loader.path.stem}_plots")
            renderer = ReportGenerator()
            renderer.display(renderer.console(result, candidate_limit=10 if args.verbose else 3))
            self._write(args.json_path, renderer.json(result)); self._write(args.html_path, renderer.html(result)); self._write(args.markdown, renderer.markdown(result))
            return 0
        except (OSError, ValueError, RuntimeError) as error:
            print(f"Error: {error}", file=sys.stderr); return 2

    @staticmethod
    def _structure(array: np.ndarray) -> tuple[dict[str, Any], np.ndarray, list[str]]:
        warnings: list[str] = []
        if array.ndim == 1:
            vectors, kind = array.reshape(1, -1), "single embedding"
        elif array.ndim == 2:
            vectors, kind = array, "multiple embeddings / matrix"
        else:
            vectors, kind = array.reshape(array.shape[0], -1), "unexpected dimensions (flattened trailing axes for analysis)"
            warnings.append("Input is not 1-D or 2-D; vector interpretation is heuristic.")
        if not np.issubdtype(array.dtype, np.number):
            warnings.append("Array dtype is non-numeric; numerical analyses may fail.")
        byteorder = {"=": "native", "<": "little-endian", ">": "big-endian", "|": "not applicable"}.get(array.dtype.byteorder, array.dtype.byteorder)
        return ({"shape": list(array.shape), "dimensions": array.ndim, "dtype": str(array.dtype), "endianness": byteorder,
                 "itemsize_bytes": array.itemsize, "memory_usage_bytes": array.nbytes, "number_of_vectors": int(vectors.shape[0]),
                 "vector_dimension": int(vectors.shape[1]), "classification": kind}, vectors, warnings)

    @staticmethod
    def _recommend(structure: dict[str, Any], normalization: dict[str, Any], candidates: list[Finding], warnings: list[str]) -> list[str]:
        dimension = structure["vector_dimension"]
        recommendations = ["Treat model rankings as compatibility hypotheses; compare with known generation metadata for identification."]
        if dimension != 1536:
            recommendations.append("Dimension rules out the default 1536-dimensional text-embedding-ada-002 output.")
        if normalization.get("status") == "approximately unit normalized":
            recommendations.append("Embedding appears unit normalized; record whether your pipeline normalized output after model inference.")
        if candidates and candidates[0].confidence >= .75:
            recommendations.append(f"Investigate compatible {candidates[0].label} documentation and surrounding pipeline metadata next.")
        recommendations.extend(warnings)
        return recommendations

    @staticmethod
    def _write(path: Path | None, content: str) -> None:
        if path:
            path.parent.mkdir(parents=True, exist_ok=True); path.write_text(content, encoding="utf-8")


if __name__ == "__main__":
    raise SystemExit(CLI().run())
```

emb_fin script
```#!/usr/bin/env python3
"""
Improved Template Bank + Enhanced Slot Filler Pipeline
======================================================

Embedding inversion via template bank scoring and margin-aware slot filling.
This is the improved version of emb_fin.py with four enhancements:

  1. Template Diversity Clustering — removes near-duplicate templates via
     greedy agglomerative clustering on pairwise cosine similarity.
  2. Two-Stage Narrowing — coarse pass on top-3 templates narrows the
     wordlist before the full tournament, dramatically reducing computation.
  3. Gap-Based Confidence — uses separation_ratio (best/second-best weighted
     score) for more robust confidence classification.
  4. Relative Threshold for Template Selection — replaces fixed top_k with
     a similarity-floor approach that adapts to the embedding landscape.

  Stage 1: Score template bank against target embedding -> threshold selection
  Stage 2: Diversity clustering -> diverse seed set
  Stage 3: Enhanced slot filling (two-stage narrowing, margin-aware,
           weighted consensus, gap-based confidence, progressive fill-and-lock)

Requirements (pip):
    pip install torch numpy transformers

Usage:
    python emb_fin_improved.py embeddings.npy --chunk 0 \\
        --templates templates.json --wordlist passwords.txt \\
        --slots PASSWORD --default-URL https://login.megacorpone.ai

    python emb_fin_improved.py embeddings.npy --all \\
        --templates templates.json --wordlist passwords.txt
"""

import sys
import json
import re
import gzip
import argparse
import numpy as np
import torch
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional, Tuple


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
    - Relative-threshold template scoring (Improvement 4)
    - Diversity clustering (Improvement 1)
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
        Score all templates against target and return candidates using
        relative threshold selection (Improvement 4).

        Instead of a fixed top_k, uses a similarity floor relative to the
        top-1 score:
          threshold = top1_similarity * similarity_floor_pct
        All templates above that threshold are included, capped at max_seeds
        and floored at min_seeds.

        When top_k == max_seeds == min_seeds (i.e. --top-k was used as a
        fixed override), this degrades gracefully to the original behavior.
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
        threshold = top1_sim * similarity_floor_pct

        # Count how many pass the threshold
        qualifying = [p for p in pairs if p[1] >= threshold]
        n_qualifying = len(qualifying)

        # Apply min/max bounds
        n_selected = max(min_seeds, min(n_qualifying, max_seeds))
        # Also don't exceed available templates
        n_selected = min(n_selected, len(pairs))

        top = pairs[:n_selected]

        if verbose:
            print(f"    Threshold {threshold:.4f}: {n_qualifying} templates qualify "
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
        Improvement 1: Template Diversity Clustering.

        Given a list of (template, similarity) pairs, remove near-duplicates
        using greedy agglomerative clustering based on pairwise cosine
        similarity of template embeddings.

        Algorithm:
          1. Compute embeddings for all top templates.
          2. Compute pairwise cosine similarity matrix.
          3. Greedily iterate through templates (in order of descending
             target similarity). Add a template to the "kept" set only if
             its maximum cosine similarity to any already-kept template is
             below diversity_threshold.
          4. Enforce min_diverse: if fewer than min_diverse are kept, relax
             by adding the next-best templates that were skipped.

        Returns the filtered list of (template, similarity) tuples.
        """
        if len(top_templates) <= 1:
            return top_templates

        # Compute embeddings for all top templates
        template_texts = [t for t, _ in top_templates]
        template_embs = self.get_embeddings_batch(template_texts)

        # Normalize for cosine similarity
        norms = template_embs.norm(dim=1, keepdim=True).clamp(min=1e-9)
        normed = template_embs / norms

        # Pairwise cosine similarity matrix
        pairwise_sim = torch.mm(normed, normed.t())

        # Greedy selection (templates already sorted by target similarity desc)
        kept_indices = []
        skipped_indices = []

        for i in range(len(top_templates)):
            if not kept_indices:
                # Always keep the best template
                kept_indices.append(i)
                continue

            # Max similarity to any already-kept template
            max_sim_to_kept = max(
                pairwise_sim[i, j].item() for j in kept_indices
            )

            if max_sim_to_kept < diversity_threshold:
                kept_indices.append(i)
            else:
                skipped_indices.append(i)

        # Enforce minimum diversity count
        if len(kept_indices) < min_diverse:
            needed = min_diverse - len(kept_indices)
            # Add back skipped templates in their original order (best first)
            for idx in skipped_indices[:needed]:
                kept_indices.append(idx)
            kept_indices.sort()

        result = [top_templates[i] for i in kept_indices]
        return result

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
# SECTION 4: SLOT RESULT + ENHANCED SLOT FILLER
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
    separation_ratio: float = 0.0


class EnhancedSlotFiller:
    """
    Enhanced slot filler with improvements over the base version:

    1. Margin-aware scoring  -- computes a neutral baseline per template
       and uses (raw_sim - baseline) margins for winner selection and
       z-score computation.

    2. Weighted consensus -- each template's vote is weighted by its
       base similarity to the target (better templates count more).

    3. Progressive fill-and-lock -- two-pass slot filling where Pass 1
       fills all slots independently, high-confidence results are locked,
       and Pass 2 re-fills weak slots with locked context.

    4. Two-Stage Narrowing (Improvement 2) -- coarse pass on top-3
       templates narrows the wordlist before the full tournament.

    5. Gap-Based Confidence (Improvement 3) -- uses separation_ratio
       for more robust confidence classification.
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

    def _run_template_tournament(
        self,
        templates_subset: List[Tuple[str, float]],
        slot_name: str,
        wordlist: List[str],
        target_emb: torch.Tensor,
        locked_values: Optional[Dict[str, str]],
        label: str = "",
    ) -> Tuple[List[tuple], Dict[str, list], Dict[str, list]]:
        """
        Run per-template tournament on a set of templates with a given wordlist.

        Returns:
            template_winners: list of (template, winner_value, winner_sim,
                              raw_margin, winner_margin, base_similarity)
            all_value_scores: dict mapping value -> list of raw sims
            all_value_margin_scores: dict mapping value -> list of margin sims
        """
        placeholder = "{" + slot_name + "}"

        valid = [(t, s) for t, s in templates_subset if placeholder in t]
        if not valid:
            return [], {v: [] for v in wordlist}, {v: [] for v in wordlist}

        template_winners = []
        all_value_scores = {v: [] for v in wordlist}
        all_value_margin_scores = {v: [] for v in wordlist}

        for idx, (template, base_similarity) in enumerate(valid):
            if label:
                print(f"    {label} Template {idx + 1}/{len(valid)} "
                      f"({len(wordlist):,} candidates)...",
                      end="\r", flush=True)
            else:
                print(f"    Template {idx + 1}/{len(valid)} "
                      f"({len(wordlist):,} candidates)...",
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

            # Compute baseline: template with ALL slots neutral-filled
            baseline_text = prefilled.replace(
                placeholder,
                self.neutral_defaults.get(slot_name, "example")
            )
            baseline_sim = self.engine.compute_similarity(baseline_text, target_emb)

            # Score candidates (raw similarities)
            texts = [prefilled.replace(placeholder, v) for v in wordlist]
            raw_sims = self.engine.score_against_target(texts, target_emb)

            # Margin scores: improvement over neutral baseline
            margin_sims = [s - baseline_sim for s in raw_sims]

            # Winner selection uses margin_sims (largest margin wins)
            sorted_by_margin = sorted(
                zip(wordlist, raw_sims, margin_sims),
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

            for value, sim, msim in zip(wordlist, raw_sims, margin_sims):
                all_value_scores[value].append(sim)
                all_value_margin_scores[value].append(msim)

        print()
        return template_winners, all_value_scores, all_value_margin_scores

    def fill_slot(
        self,
        top_k_templates: List[Tuple[str, float]],
        slot_name: str,
        target_emb: torch.Tensor,
        locked_values: Optional[Dict[str, str]] = None,
    ) -> SlotResult:
        """
        Fill a single slot using top-K templates with:
        - Two-stage narrowing (Improvement 2)
        - Margin-aware scoring
        - Weighted consensus
        - Gap-based confidence (Improvement 3)
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

        # ============================================================
        # Improvement 2: Two-Stage Narrowing
        # ============================================================
        # Stage 1 (coarse): Run full wordlist against top-3 templates
        # to narrow down candidates.
        # Stage 2 (full): Run survivors through ALL templates.
        # ============================================================

        use_two_stage = len(wordlist) > 200 and len(valid) > 3

        if use_two_stage:
            # --- Stage 1: Coarse pass with top-3 templates ---
            coarse_templates = valid[:3]
            print(f"    [Stage 1/2] Coarse pass: {len(wordlist):,} candidates "
                  f"x {len(coarse_templates)} templates")

            coarse_winners, coarse_scores, coarse_margins = self._run_template_tournament(
                coarse_templates, slot_name, wordlist, target_emb,
                locked_values, label="[Stage 1]",
            )

            # Collect survivors: values that appeared in top-10 by margin
            # for ANY coarse template
            survivors_set = set()

            for value in wordlist:
                if coarse_margins[value]:
                    # Check if this value was in top-10 by margin for any template
                    for tmpl_idx in range(len(coarse_templates)):
                        # Get this value's margin for this template
                        if tmpl_idx < len(coarse_margins[value]):
                            pass  # margins are stored per-template in order

                    # Simpler approach: compute avg margin, take top candidates
                    pass

            # Compute per-value average margin across coarse templates
            value_avg_margins = []
            for v in wordlist:
                if coarse_margins[v]:
                    avg_m = float(np.mean(coarse_margins[v]))
                else:
                    avg_m = float('-inf')
                value_avg_margins.append((v, avg_m))

            value_avg_margins.sort(key=lambda x: x[1], reverse=True)

            # Also collect per-template top-10 by margin
            # We need to reconstruct per-template rankings
            for tmpl_idx in range(len(coarse_templates)):
                tmpl_values_margins = []
                for v in wordlist:
                    if tmpl_idx < len(coarse_margins[v]):
                        tmpl_values_margins.append((v, coarse_margins[v][tmpl_idx]))
                tmpl_values_margins.sort(key=lambda x: x[1], reverse=True)
                for v, _ in tmpl_values_margins[:10]:
                    survivors_set.add(v)

            # Always include at least top-200 unique candidates by avg margin
            for v, _ in value_avg_margins[:200]:
                survivors_set.add(v)

            survivors = [v for v in wordlist if v in survivors_set]
            print(f"    [Stage 1/2] Narrowed to {len(survivors):,} survivors "
                  f"from {len(wordlist):,} candidates")

            # --- Stage 2: Full pass with ALL templates ---
            print(f"    [Stage 2/2] Full pass: {len(survivors):,} candidates "
                  f"x {len(valid)} templates")

            template_winners, all_value_scores, all_value_margin_scores = \
                self._run_template_tournament(
                    valid, slot_name, survivors, target_emb,
                    locked_values, label="[Stage 2]",
                )

            # Use survivors as the effective wordlist for statistics
            effective_wordlist = survivors

        else:
            # --- Single-stage (original behavior for small wordlists) ---
            template_winners, all_value_scores, all_value_margin_scores = \
                self._run_template_tournament(
                    valid, slot_name, wordlist, target_emb, locked_values,
                )
            effective_wordlist = wordlist

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

        if not value_wins:
            return SlotResult(
                value=f"[NO_WINNERS_{slot_name}]",
                similarity=0.0, margin=0.0, template_consensus=0.0,
                confidence="NO_TEMPLATE", competing_values=[],
                separation_ratio=0.0,
            )

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
            [(v, float(np.mean(all_value_scores[v])))
             for v in effective_wordlist
             if v != best_value and all_value_scores.get(v)],
            key=lambda x: x[1], reverse=True
        )[:5]

        # --- Z-score: raw similarities ---
        avg_sims_per_value = []
        for v in effective_wordlist:
            if all_value_scores.get(v):
                avg_sims_per_value.append(float(np.mean(all_value_scores[v])))
            else:
                avg_sims_per_value.append(0.0)
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
        avg_margins_per_value = []
        for v in effective_wordlist:
            if all_value_margin_scores.get(v):
                avg_margins_per_value.append(float(np.mean(all_value_margin_scores[v])))
            else:
                avg_margins_per_value.append(0.0)
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

        # ============================================================
        # Improvement 3: Gap-Based Confidence with separation_ratio
        # ============================================================
        effective_z = max(z_score, margin_z_score)
        effective_gap = max(z_gap, margin_z_gap)
        consensus = weighted_consensus  # use weighted for thresholds

        # Compute separation_ratio: best weighted score / second-best weighted score
        sorted_by_weight = sorted(
            value_wins.items(),
            key=lambda x: x[1]["weight"],
            reverse=True,
        )
        best_weight = sorted_by_weight[0][1]["weight"]
        if len(sorted_by_weight) > 1:
            second_weight = sorted_by_weight[1][1]["weight"]
            if second_weight > 1e-9:
                separation_ratio = best_weight / second_weight
            else:
                separation_ratio = float('inf')
        else:
            separation_ratio = float('inf')

        # Gap-based confidence tiers
        if (separation_ratio >= 3.0 and raw_consensus >= 0.6):
            confidence = "HIGH"
        elif (effective_z > 4.0 and effective_gap > 1.5):
            confidence = "HIGH"
        elif (separation_ratio >= 1.8 and raw_consensus >= 0.4):
            confidence = "MEDIUM"
        elif (effective_z > 2.5 and consensus >= 0.7):
            confidence = "MEDIUM"
        elif (separation_ratio >= 1.3 or
              (effective_z > 2.0 and raw_consensus >= 0.3)):
            confidence = "LOW"
        else:
            confidence = "LIKELY_FALSE_POSITIVE"

        return SlotResult(
            value=best_value,
            similarity=avg_sim,
            margin=avg_margin,
            template_consensus=weighted_consensus,
            confidence=confidence,
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
            print(f"\n  [Slot: {slot}] Pass 1 — testing across "
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
                    print(f"\n  [Slot: {slot}] Pass 2 — re-filling with "
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
# SECTION 5: PIPELINE (Orchestrator)
# ============================================================================

class SlotPipeline:
    """
    Orchestrates the attack pipeline:

      Stage 1: Template bank scoring -> relative threshold selection
      Stage 2: Diversity clustering -> diverse seed set
      Stage 3: Enhanced slot filling (two-stage narrowing, margin-aware,
               weighted, gap-based confidence, progressive)
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

        # ==============================================================
        # Stage 1: Template bank scoring -> relative threshold selection
        # ==============================================================
        print(f"\n  Scoring template bank...")

        templates, source = TemplateLoader.load(
            bank_path=self.config.bank_path,
            templates_json=self.config.templates_json,
            max_templates=self.config.max_templates,
        )
        print(f"    Templates loaded: {len(templates):,} from {source}")

        top_k = self.engine.find_top_k(
            templates, target_emb,
            top_k=self.config.top_k,
            verbose=self.config.verbose,
            similarity_floor_pct=self.config.similarity_floor_pct,
            max_seeds=self.config.max_seeds,
            min_seeds=self.config.min_seeds,
        )

        result["template_source"] = source
        result["templates_scored"] = len(templates)
        result["top_k_before_diversity"] = len(top_k)

        # ==============================================================
        # Stage 1.5: Diversity clustering (Improvement 1)
        # ==============================================================
        pool_size = len(top_k)
        top_k = self.engine.select_diverse_templates(
            top_k, target_emb,
            diversity_threshold=self.config.diversity_threshold,
        )
        print(f"    Selected {len(top_k)} diverse templates from top-{pool_size}")

        result["top_k"] = [
            {"template": t, "similarity": s} for t, s in top_k[:5]
        ]

        if self.config.verbose:
            print(f"\n    Top-{len(top_k)} templates:")
            for i, (t, s) in enumerate(top_k[:5]):
                print(f"      {i+1}. [{s:.4f}] {t[:65]}...")
            if len(top_k) > 5:
                print(f"      ... ({len(top_k) - 5} more)")

        # ==============================================================
        # Stage 2: Enhanced slot filling
        # ==============================================================
        print(f"\n  Slot filling...")

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

        # ==============================================================
        # SUMMARY
        # ==============================================================
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
                sr = info.get("separation_ratio", 0)
                label = _user_confidence(conf, rc, n_templates, sr)
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
                          f"margin={margin:.4f} sep_ratio={sr:.1f}x]")
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
# SECTION 6: CONFIGURATION
# ============================================================================

@dataclass
class PipelineConfig:
    """Configuration for the slot filling pipeline."""

    embedding_model: str = "sentence-transformers/all-MiniLM-L6-v2"
    device: str = "auto"
    batch_size: int = 256

    # Template sources
    bank_path: Optional[str] = None
    templates_json: Optional[str] = None
    max_templates: int = 100000

    # Top-K
    top_k: int = 20

    # Improvement 4: Relative threshold for template selection
    similarity_floor_pct: float = 0.85
    max_seeds: int = 50
    min_seeds: int = 5

    # Improvement 1: Diversity clustering threshold
    diversity_threshold: float = 0.85

    # Slot filling
    wordlist_path: Optional[str] = None
    target_slots: Optional[List[str]] = None
    neutral_defaults: Optional[Dict[str, str]] = None

    verbose: bool = False


# ============================================================================
# SECTION 7: OUTPUT FORMATTER
# ============================================================================

def _user_confidence(
    conf: str,
    rcons: float = 0,
    n_templates: int = 0,
    separation_ratio: float = 0.0,
) -> str:
    """
    Map internal tier to user-friendly strength label with agreement info
    and separation ratio (Improvement 3).
    """
    agrees = round(rcons * n_templates) if n_templates else 0
    sep_str = ""
    if separation_ratio and separation_ratio != float('inf') and separation_ratio > 0:
        sep_str = f", {separation_ratio:.1f}x ahead of runner-up"
    elif separation_ratio == float('inf'):
        sep_str = ", no runner-up"

    if conf == "HIGH":
        if n_templates:
            return f"Strong — {agrees}/{n_templates} templates agree{sep_str}"
        return "Strong"
    elif conf == "MEDIUM":
        if n_templates:
            return f"Moderate — {agrees}/{n_templates} templates agree{sep_str}, worth verifying"
        return "Moderate — worth verifying"
    elif conf == "LOW":
        if rcons >= 0.7 and n_templates:
            return f"Likely — {agrees}/{n_templates} templates agree{sep_str}"
        elif n_templates:
            return f"Weak — {agrees}/{n_templates} templates agree{sep_str}"
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
                "separation_ratio": info.get("separation_ratio", 0),
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
            sr = c.get('separation_ratio', 0)
            marker = _result_marker(c['confidence'])
            label = _user_confidence(c['confidence'], rc, nt, sr)
            output.append(f"    {marker} {c['slot']} = {c['value']}")
            output.append(f"        {label}")
            output.append(f"        Chunk {c['chunk']} "
                          f"| Best template: {c['similarity']*100:.1f}% match"
                          f" | Sep ratio: {sr:.1f}x")
            if verbose:
                output.append(
                    f"        [tier={c['confidence']} "
                    f"z={c['z_score']:.2f} gap={c['z_gap']:.2f} "
                    f"mz={c['margin_z_score']:.2f} "
                    f"mgap={c['margin_z_gap']:.2f} "
                    f"margin={c['margin']:.4f} "
                    f"pctl={c['percentile']:.1f}% "
                    f"sep_ratio={sr:.1f}x]")

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
# SECTION 8: CLI
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Improved Template Bank + Enhanced Slot Filler Pipeline',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Single chunk
  python emb_fin_improved.py embeddings.npy --chunk 0 \\
      --templates templates.json --wordlist passwords.txt \\
      --slots PASSWORD --default-URL https://login.megacorpone.ai

  # Multiple chunks
  python emb_fin_improved.py embeddings.npy --chunks 0,1,2 \\
      --templates templates.json --wordlist passwords.txt

  # All chunks
  python emb_fin_improved.py embeddings.npy --all \\
      --templates templates.json --wordlist passwords.txt

  # Fill PASSWORD slot with custom URL context
  python emb_fin_improved.py embeddings.npy --chunk 0 \\
      --templates templates.json --wordlist passwords.txt \\
      --slots PASSWORD \\
      --default-URL https://login.mycompany.com --default-USERNAME admin

  # Use relative threshold instead of fixed top-k
  python emb_fin_improved.py embeddings.npy --chunk 0 \\
      --templates templates.json --wordlist passwords.txt \\
      --similarity-floor 0.80 --max-seeds 40 --min-seeds 10

  # Adjust diversity threshold
  python emb_fin_improved.py embeddings.npy --chunk 0 \\
      --templates templates.json --wordlist passwords.txt \\
      --diversity-threshold 0.90
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

    # Top-K (kept as alias for fixed mode)
    parser.add_argument('--top-k', type=int, default=20,
                        help='Number of top seed templates for consensus (default: 20). '
                             'Sets both max-seeds and min-seeds for fixed mode.')

    # Improvement 4: Relative threshold args
    parser.add_argument('--similarity-floor', type=float, default=0.85,
                        help='Similarity floor as fraction of top-1 (default: 0.85)')
    parser.add_argument('--max-seeds', type=int, default=None,
                        help='Max templates to keep after threshold (default: 50)')
    parser.add_argument('--min-seeds', type=int, default=None,
                        help='Min templates to keep (default: 5)')

    # Improvement 1: Diversity clustering
    parser.add_argument('--diversity-threshold', type=float, default=0.85,
                        help='Max pairwise similarity for diversity clustering (default: 0.85)')

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

    # --- Handle --top-k as alias for fixed mode ---
    # If --top-k is explicitly provided and --max-seeds/--min-seeds are not,
    # use top_k as both max and min (fixed mode behavior).
    if args.max_seeds is None and args.min_seeds is None:
        # Check if --top-k was explicitly provided (not default)
        # We detect this by checking if it differs from default or
        # if max_seeds/min_seeds were not set
        max_seeds = args.top_k if args.top_k != 20 else 50
        min_seeds = args.top_k if args.top_k != 20 else 5
        # If top_k was explicitly set to 20 but user wanted fixed mode,
        # they would need to also set max/min. For backward compat,
        # if top_k != 20 we treat it as fixed mode.
        if args.top_k != 20:
            max_seeds = args.top_k
            min_seeds = args.top_k
        else:
            max_seeds = 50
            min_seeds = 5
    else:
        max_seeds = args.max_seeds if args.max_seeds is not None else 50
        min_seeds = args.min_seeds if args.min_seeds is not None else 5

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

    # Build config
    config = PipelineConfig(
        embedding_model=args.model,
        device=args.device,
        batch_size=args.batch_size,
        bank_path=args.bank,
        templates_json=args.templates,
        max_templates=args.max_templates,
        top_k=args.top_k,
        similarity_floor_pct=args.similarity_floor,
        max_seeds=max_seeds,
        min_seeds=min_seeds,
        diversity_threshold=args.diversity_threshold,
        wordlist_path=args.wordlist,
        target_slots=([s.strip().upper() for s in args.slots.split(',')]
                      if args.slots else None),
        neutral_defaults=slot_defaults if slot_defaults else None,
        verbose=args.verbose,
    )

    # Run pipeline
    pipeline = SlotPipeline(config)
    results = pipeline.attack_chunks(embeddings, chunk_indices)

    # Display
    print(format_results(results, verbose=config.verbose))

    # Save
    if args.output:
        output_data = {
            "pipeline": "template+slot (improved)",
            "timestamp": datetime.now().isoformat(),
            "embeddings_file": args.embeddings_file,
            "config": {
                "embedding_model": config.embedding_model,
                "top_k": config.top_k,
                "similarity_floor_pct": config.similarity_floor_pct,
                "max_seeds": config.max_seeds,
                "min_seeds": config.min_seeds,
                "diversity_threshold": config.diversity_threshold,
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
GENERATE TEMPLATE SCRIPT

```#!/usr/bin/env python3
"""
Standalone Template Generator with Auto-Domain Detection
==========================================================

Generates hundreds of thousands of unique templates for embedding inversion
attacks. Includes automatic domain detection from target embeddings.

This is a standalone script — no other project files required.

Requirements (pip):
    pip install numpy
    pip install torch transformers    (only needed for --auto-detect from embeddings)

Usage:
    # Auto-detect domain from embeddings, generate 100k templates
    python generate_templates.py embeddings2.npy -o templates.json

    # Auto-detect from a specific chunk
    python generate_templates.py embeddings2.npy --chunk 3 -o templates.json

    # Majority vote across first 5 chunks
    python generate_templates.py embeddings2.npy --chunks 0,1,2,3,4 -o templates.json

    # Custom count
    python generate_templates.py embeddings2.npy --count 500000 -o templates.json

    # Skip detection, specify domain manually
    python generate_templates.py --domain infrastructure_credentials -o templates.json

    # Generate for specific chunk position (first/middle/last)
    python generate_templates.py --domain it_password --chunk-position first -o templates.json

    # List available domains
    python generate_templates.py --list-domains

Then use the output with the attack tools:
    python emb_seeds_fin.py embeddings2.npy --chunk 0 \\
        --templates templates.json --fill-slots --wordlist passwords.txt
    python emb_unified_fin.py embeddings2.npy --chunk 0 \\
        --templates templates.json --wordlist passwords.txt
"""

import re
import sys
import json
import random
import hashlib
import argparse
import numpy as np
from itertools import product, permutations, combinations
from typing import List, Dict, Set, Generator, Optional, Tuple
from dataclasses import dataclass, field
from collections import defaultdict, Counter
from pathlib import Path


# ============================================================================
# COMPREHENSIVE VARIATION BANKS
# ============================================================================

# Password/credential terminology across languages and styles
PASSWORD_TERMS = {
    "standard": [
        "password", "passcode", "pass code", "credential", "access code",
        "security code", "auth code", "authentication code", "PIN",
        "secret", "passphrase", "pass phrase", "access key"
    ],
    "technical": [
        "passwd", "pwd", "cred", "auth token", "secret key", "API key",
        "bearer token", "access token", "refresh token", "session key"
    ],
    "formal": [
        "authentication credential", "security credential",
        "access credential", "login credential", "user credential"
    ],
    "casual": [
        "pw", "pass", "login", "key", "code"
    ],
    "temporary": [
        "temporary password", "temp password", "one-time password",
        "OTP", "initial password", "default password", "reset password",
        "new password", "generated password", "assigned password"
    ]
}

# URL/endpoint terminology
URL_TERMS = {
    "standard": [
        "URL", "link", "website", "web address", "address",
        "site", "web site", "webpage", "web page"
    ],
    "technical": [
        "endpoint", "API endpoint", "service URL", "base URL",
        "host", "server", "destination", "target URL", "URI"
    ],
    "portal": [
        "portal", "login portal", "access portal", "web portal",
        "user portal", "employee portal", "admin portal", "SSO portal"
    ],
    "casual": [
        "page", "login page", "site", "the link"
    ]
}

# Action/instruction verbs
ACTION_VERBS = {
    "navigation": [
        "navigate to", "go to", "visit", "access", "open",
        "proceed to", "head to", "click on", "follow"
    ],
    "formal": [
        "please navigate to", "kindly visit", "please access",
        "you are requested to visit", "please proceed to"
    ],
    "casual": [
        "go", "click", "open up", "check out", "hit"
    ],
    "technical": [
        "connect to", "access endpoint", "authenticate at",
        "login to", "sign in at", "authenticate via"
    ]
}

# Reset/help action phrases
RESET_ACTIONS = [
    "Need help signing in", "Forgot password", "Reset password",
    "Can't access your account", "Sign in help", "Account recovery",
    "Unlock account", "Password assistance", "Login help",
    "Trouble signing in", "Account access", "Security reset",
    "Password reset", "Forgot your password", "Reset your password",
    "Having trouble signing in", "Account locked", "Need password help",
    "Lost password", "Recover account", "Regain access"
]

# Immediacy/urgency terms
IMMEDIACY_TERMS = [
    "immediately", "right away", "promptly", "at once",
    "as soon as possible", "ASAP", "without delay", "urgently",
    "now", "straight away", "right now", "", "upon first login",
    "on first access", "after logging in",
    "on your first login", "on your next login",
    "before your next session", "at your first opportunity",
]

# Formality prefixes
FORMALITY_PREFIXES = [
    "", "Please ", "Kindly ", "We request that you ",
    "You are required to ", "You must ", "You should ",
    "We ask that you ", "It is required that you ",
    "For security purposes, ", "For your security, ",
    "Important: ", "Action required: ", "Notice: "
]

# Sentence connectors
CONNECTORS = [
    "and", "then", "after which", "following which",
    "and then", "next", "subsequently", "afterward",
    ". Then", ". After that,", ". Next,"
]

# Closing phrases
CLOSING_PHRASES = [
    ".", "!", " immediately.", " right away.",
    " as soon as possible.", " upon first login.",
    " on your next login.", " within 24 hours.",
    " before it expires.", " to complete setup.",
    " which must be changed immediately.",
    " which must be updated on first login.",
    " and must be changed immediately.",
    " and must be updated on first login.",
    " which expires in 24 hours.",
]

# Time constraints
TIME_CONSTRAINTS = [
    "", "within 24 hours", "within 48 hours", "within 7 days",
    "before expiration", "on first login", "immediately",
    "by end of day", "at your earliest convenience"
]

# Database/service type terminology
DBTYPE_TERMS = [
    "Production database", "Database", "Production DB", "MySQL",
    "PostgreSQL", "Postgres", "MongoDB", "Redis", "MariaDB", "SQL Server",
    "Oracle", "MSSQL", "SQLite", "Cassandra", "DynamoDB", "CouchDB",
    "Staging database", "Dev database", "Test database",
    "Primary database", "Replica database", "Master database",
]

# Service/system names
SERVICE_TERMS = [
    "Production database server", "Database server", "DB server",
    "Production server", "Staging server", "Application server",
    "Web server", "API server", "Backend server", "Auth server",
    "LDAP server", "SMTP server", "FTP server", "SSH gateway",
    "VPN gateway", "Kubernetes cluster", "Docker registry",
    "Jenkins", "GitLab", "Grafana", "Prometheus", "Elasticsearch",
    "RabbitMQ", "Kafka", "Nginx", "Apache", "Tomcat",
    "Admin panel", "Control panel", "Management console",
    "AWS console", "Azure portal", "GCP console",
]

# Username terms for infrastructure contexts
USERNAME_TERMS = [
    "admin", "root", "administrator", "sa", "postgres", "mysql",
    "dbadmin", "sysadmin", "devops", "deploy", "service", "app",
    "backup", "monitor", "readonly", "readwrite", "superuser",
    "operator", "maintainer", "support", "guest", "test",
]

# Hostname / IP terms
HOSTNAME_TERMS = [
    "db-prod-01", "db-prod-02", "db-staging-01", "app-prod-01",
    "web-prod-01", "api-prod-01", "srv-01", "node-01", "master-01",
    "10.0.0.1", "10.0.1.100", "192.168.1.10", "172.16.0.50",
    "db.internal.corp", "prod-db.company.local", "api.internal.net",
]

# Connection context phrases for infrastructure credentials
INFRA_CONTEXT_PHRASES = [
    "server admin username is", "admin username is", "username is",
    "login username is", "default username is", "root user is",
    "admin user is", "service account is", "system user is",
    "db user is", "database user is", "connection user is",
]

# Credential joining phrases
CREDENTIAL_JOINERS = [
    "with password", "password", "and password is", "pass",
    "and the password is", "pwd", "password is", "with pass",
    "with credential", "using password", "authenticated by",
    "with secret", "and password", "/ password",
]

# Cloud - AWS
AWS_SERVICES = [
    "S3", "EC2", "Lambda", "RDS", "DynamoDB", "IAM", "EKS", "ECS",
    "CloudFront", "SQS", "SNS", "SES", "Redshift", "ElastiCache",
    "Secrets Manager", "Parameter Store", "CloudWatch", "Route 53",
]

AWS_REGIONS = [
    "us-east-1", "us-west-2", "eu-west-1", "eu-central-1",
    "ap-southeast-1", "ap-northeast-1", "us-east-2", "ca-central-1",
]

# Cloud - Azure
AZURE_SERVICES = [
    "Azure AD", "Azure SQL", "Azure Blob Storage", "Azure Functions",
    "AKS", "Azure DevOps", "Key Vault", "Cosmos DB", "Azure App Service",
    "Azure Service Bus", "Azure Event Hub", "Azure Storage",
]

AZURE_RESOURCE_TYPES = [
    "subscription", "resource group", "storage account", "SQL database",
    "key vault", "app registration", "service principal", "managed identity",
]

# Network / VPN
VPN_TYPES = [
    "OpenVPN", "WireGuard", "IPSec", "Cisco AnyConnect", "FortiClient",
    "GlobalProtect", "Pulse Secure", "F5 BIG-IP", "Palo Alto",
]

WIFI_SECURITY = ["WPA2-Enterprise", "WPA3", "WPA2-PSK", "802.1X"]

NETWORK_DEVICES = [
    "firewall", "router", "switch", "access point", "load balancer",
    "VPN concentrator", "proxy", "WAF", "IDS/IPS",
]

# CI/CD DevOps
CICD_PLATFORMS = [
    "GitHub Actions", "Jenkins", "GitLab CI", "CircleCI", "Travis CI",
    "Azure Pipelines", "Terraform Cloud", "ArgoCD", "Ansible Tower",
    "Bamboo", "TeamCity", "Drone CI",
]

REGISTRY_TYPES = [
    "Docker Hub", "ECR", "GCR", "ACR", "GitHub Container Registry",
    "Harbor", "Nexus", "Artifactory", "Quay.io",
]

# Email / SMTP
SMTP_SERVERS = [
    "smtp.gmail.com", "smtp.office365.com", "smtp.sendgrid.net",
    "email-smtp.us-east-1.amazonaws.com", "smtp.mailgun.org",
    "smtp-relay.sendinblue.com", "smtp.postmarkapp.com",
    "smtp.company.com", "mail.internal.corp",
]

EMAIL_PROTOCOLS = ["SMTP", "IMAP", "POP3", "Exchange", "MAPI"]

# Financial / Banking
BANK_NAMES = [
    "Chase", "Bank of America", "Wells Fargo", "Citibank", "Goldman Sachs",
    "JP Morgan", "Morgan Stanley", "HSBC", "Barclays", "Deutsche Bank",
    "First National", "Silicon Valley Bank", "Capital One",
]

TRANSACTION_TYPES = [
    "wire transfer", "ACH transfer", "SWIFT transfer", "domestic wire",
    "international wire", "direct deposit", "payment", "disbursement",
]

# Legal
LEGAL_TYPES = [
    "NDA", "Non-Disclosure Agreement", "Settlement Agreement",
    "Master Services Agreement", "SLA", "SOW", "License Agreement",
    "Employment Agreement", "Non-Compete", "Merger Agreement",
    "Asset Purchase Agreement", "Stock Purchase Agreement",
]

LEGAL_PARTIES = [
    "the Company", "the Vendor", "the Contractor", "the Employee",
    "the Acquiring Party", "the Target", "the Licensee", "the Licensor",
]

# Medical / HIPAA
MEDICAL_FACILITIES = [
    "General Hospital", "Medical Center", "Regional Health System",
    "Community Clinic", "Urgent Care", "Specialty Clinic",
    "Children's Hospital", "Veterans Medical Center",
]

DIAGNOSIS_CODES = [
    "ICD-10: {CODE}", "CPT: {CODE}", "diagnosis code {CODE}",
    "DRG: {CODE}", "procedure code {CODE}",
]

MEDICAL_DEPARTMENTS = [
    "Cardiology", "Oncology", "Orthopedics", "Neurology", "Radiology",
    "Emergency", "Internal Medicine", "Surgery", "Pediatrics", "ICU",
]

# Customer PII
PII_DOCUMENT_TYPES = [
    "customer record", "account profile", "user record",
    "member profile", "subscriber record", "client file",
]

# Internal Strategy
MEETING_TYPES = [
    "Board meeting", "Executive committee", "Strategy session",
    "Quarterly business review", "Leadership offsite", "Budget meeting",
    "M&A committee", "Risk committee", "Compensation committee",
]

STRATEGY_ACTIONS = [
    "approved", "discussed", "proposed", "tabled", "voted on",
    "greenlit", "postponed", "finalized", "rejected", "escalated",
]

# Certificate / TLS
CERT_TYPES = [
    "SSL", "TLS", "wildcard SSL", "EV SSL", "code signing",
    "client certificate", "intermediate CA", "root CA", "self-signed",
]

CERT_FORMATS = ["PEM", "DER", "PKCS12", "P7B", "PFX", "JKS"]

# Encryption / Secrets
ENCRYPTION_TYPES = [
    "AES-256", "RSA-4096", "GPG", "PGP", "KMS", "HSM",
    "Vault", "SOPS", "age", "LUKS", "BitLocker",
]

VAULT_PATHS = [
    "secret/data/production", "secret/data/staging", "kv/production",
    "secret/infra/database", "secret/app/api-keys", "transit/keys/main",
]

# OAuth / SSO
OAUTH_PROVIDERS = [
    "Okta", "Auth0", "Azure AD", "Google Workspace", "OneLogin",
    "PingIdentity", "Keycloak", "AWS Cognito", "ForgeRock", "Duo",
]

OAUTH_GRANT_TYPES = [
    "authorization_code", "client_credentials", "implicit",
    "password", "refresh_token", "device_code",
]

# Vendor / Partner
VENDOR_NAMES = [
    "Acme Corp", "TechVendor Inc", "CloudPartner LLC", "DataCorp",
    "SecureNet", "InfoSys", "GlobalTech", "NextGen Solutions",
    "PlatformOne", "ServicePro",
]

# SaaS Platforms
SAAS_PLATFORMS = [
    "Salesforce", "Jira", "Confluence", "Slack", "Microsoft Teams",
    "ServiceNow", "Workday", "Datadog", "Splunk", "PagerDuty",
    "Zendesk", "HubSpot", "Snowflake", "Tableau", "Okta",
    "GitHub Enterprise", "Bitbucket", "New Relic",
]


# ============================================================================
# TEMPLATE PATTERN STRUCTURES
# ============================================================================

# Structural patterns for password reset templates
PASSWORD_RESET_PATTERNS = [
    # Standard patterns
    "{PREFIX}{VERB} {URL}. {PW_CONTEXT} {PASSWORD}{CLOSING}",
    "{PREFIX}{VERB} {URL} and {ACTION}. {PW_CONTEXT} {PASSWORD}{CLOSING}",
    "{PW_CONTEXT} {PASSWORD}. {PREFIX}{VERB} {URL}{CLOSING}",
    "{PREFIX}use {PASSWORD} to {VERB} {URL}{CLOSING}",
    "{ACTION} at {URL}. {PW_CONTEXT} {PASSWORD}{CLOSING}",

    # Short/compact patterns
    "{PW_TERM}: {PASSWORD}. {URL_TERM}: {URL}",
    "{URL_TERM}: {URL} | {PW_TERM}: {PASSWORD}",
    "Login: {URL}, {PW_TERM}: {PASSWORD}",
    "{URL} - {PW_TERM} {PASSWORD}",
    "Access {URL} with {PASSWORD}",

    # Technical patterns
    "AUTH_URL={URL} PASSWD={PASSWORD}",
    "Endpoint: {URL}, Token: {PASSWORD}",
    "Service credentials - URL: {URL}, Key: {PASSWORD}",

    # Multi-sentence patterns
    "{PREFIX}{VERB} {URL}. Click on {ACTION}. {PW_CONTEXT} {PASSWORD}{CLOSING}",
    "{PW_CONTEXT} {PASSWORD}. This must be changed {IMMEDIACY}. {VERB} {URL}.",
    "Your account has been reset. {PW_CONTEXT} {PASSWORD}. {PREFIX}{VERB} {URL}{CLOSING}",

    # Question-answer style
    "How to reset? {VERB} {URL}, use {PASSWORD}.",
    "Lost access? {PREFIX}{VERB} {URL}. {PW_TERM}: {PASSWORD}.",

    # Instructional style
    "Step 1: {VERB} {URL}. Step 2: Enter {PASSWORD}. Step 3: Change {IMMEDIACY}.",
    "To reset your password: {VERB} {URL} and use {PASSWORD}.",

    # "which must be changed" constructions
    "{PW_CONTEXT} {PASSWORD} which must be changed {IMMEDIACY}. {VERB} {URL}.",
    "{PW_CONTEXT} {PASSWORD} which must be updated on first login. {VERB} {URL}.",
    "Your account has been reset. {PW_CONTEXT} {PASSWORD} which expires in 24 hours.",

    # "after resetting" phrasing
    "The default password after resetting is {PASSWORD}. {PREFIX}{VERB} {URL}{CLOSING}",
    "After reset, your password is {PASSWORD}. {VERB} {URL} to change it {IMMEDIACY}.",

    # Longer multi-clause patterns
    "{PREFIX}{VERB} {URL} and click on {ACTION}. {PW_CONTEXT} {PASSWORD} and must be updated on first login.",
    "Your account password has been reset to {PASSWORD}. Please {VERB} {URL} and change it {IMMEDIACY}. This is time-sensitive.",

    # Passive/formal voice
    "A temporary password {PASSWORD} has been assigned to your account. {VERB} {URL} to update it.",
    "Your password has been reset to {PASSWORD}. Access the portal at {URL} to set a new one.",

    # Conversational/direct
    "Hi, your new password is {PASSWORD}. Go to {URL} to change it.",
    "FYI your password was reset to {PASSWORD}. Login at {URL} and update it.",
]

# Structural patterns for infrastructure credential templates
INFRASTRUCTURE_CREDENTIAL_PATTERNS = [
    # Simple credential notes
    "{SERVICE} {INFRA_CONTEXT} {USERNAME} {CRED_JOIN} {PASSWORD}",
    "{SERVICE} {INFRA_CONTEXT} {USERNAME} {CRED_JOIN} {PASSWORD}{CLOSING}",
    "{DBTYPE} server {INFRA_CONTEXT} {USERNAME} {CRED_JOIN} {PASSWORD}",
    "{DBTYPE} {INFRA_CONTEXT} {USERNAME} {CRED_JOIN} {PASSWORD}",

    # Hostname-based patterns
    "Server {HOSTNAME}: user {USERNAME}, password {PASSWORD}",
    "Server {HOSTNAME} - {INFRA_CONTEXT} {USERNAME} {CRED_JOIN} {PASSWORD}",
    "{HOSTNAME}: username {USERNAME}, password {PASSWORD}",
    "Host {HOSTNAME} credentials: {USERNAME} / {PASSWORD}",

    # Connection string patterns
    "Connection string: host={HOSTNAME} user={USERNAME} password={PASSWORD}",
    "Connection: {DBTYPE}://{USERNAME}:{PASSWORD}@{HOSTNAME}",
    "DSN: {DBTYPE}://{USERNAME}:{PASSWORD}@{HOSTNAME}/{DBNAME}",
    "{DBTYPE} connection: host={HOSTNAME} port={PORT} user={USERNAME} password={PASSWORD}",

    # Key-value credential patterns
    "{SERVICE} credentials - username: {USERNAME}, password: {PASSWORD}",
    "{SERVICE} credentials: username={USERNAME} password={PASSWORD}",
    "Credentials for {SERVICE}: user {USERNAME}, pass {PASSWORD}",
    "{SERVICE} login: {USERNAME} / {PASSWORD}",
    "Login for {SERVICE} is {USERNAME} with password {PASSWORD}",

    # Short/compact patterns
    "{PW_TERM}: {PASSWORD}. User: {USERNAME}. Service: {SERVICE}",
    "user: {USERNAME}, {PW_TERM}: {PASSWORD}",
    "username: {USERNAME}\npassword: {PASSWORD}",
    "{USERNAME}:{PASSWORD}",
    "{USERNAME} / {PASSWORD}",

    # Descriptive/documentation patterns
    "The {DBTYPE} admin password is {PASSWORD}",
    "The {SERVICE} admin account uses password {PASSWORD}",
    "Default credentials for {SERVICE} are {USERNAME}/{PASSWORD}",
    "Root password for {SERVICE}: {PASSWORD}",
    "{SERVICE} default admin credentials: user={USERNAME}, password={PASSWORD}",
    "Production credentials: {USERNAME} / {PASSWORD} on {HOSTNAME}",

    # Multi-sentence patterns
    "The {SERVICE} is hosted at {HOSTNAME}. Admin credentials: {USERNAME} / {PASSWORD}.",
    "{SERVICE} has been deployed. {INFRA_CONTEXT} {USERNAME} {CRED_JOIN} {PASSWORD}.",
    "Access {SERVICE} at {HOSTNAME}. Username: {USERNAME}. Password: {PASSWORD}.",
    "New {SERVICE} setup complete. Login with {USERNAME} and password {PASSWORD}.",

    # Config/env file style
    "DB_HOST={HOSTNAME}\nDB_USER={USERNAME}\nDB_PASS={PASSWORD}",
    "DATABASE_URL={DBTYPE}://{USERNAME}:{PASSWORD}@{HOSTNAME}",
    "{DBTYPE}_PASSWORD={PASSWORD}",
    "ADMIN_PASSWORD={PASSWORD}",

    # With IP addresses
    "Server at {HOSTNAME}, admin credentials {USERNAME}:{PASSWORD}",
    "{DBTYPE} on {HOSTNAME} - login: {USERNAME}, password: {PASSWORD}",
    "Connect to {HOSTNAME} as {USERNAME} with password {PASSWORD}",

    # Formal/ticket style
    "{PREFIX}the {SERVICE} admin password has been set to {PASSWORD}",
    "{PREFIX}credentials for {SERVICE}: username {USERNAME}, password {PASSWORD}",
    "Ticket #{NUMBER}: {SERVICE} password set to {PASSWORD} for user {USERNAME}",

    # Notification style
    "The {SERVICE} password has been updated to {PASSWORD} for user {USERNAME}.",
    # Urgency
    "{SERVICE} credentials need to be rotated. Current: {USERNAME} / {PASSWORD}.",
    # Conversational
    "FYI the {SERVICE} admin password is {PASSWORD}, user is {USERNAME}.",
    # Passive
    "A new password {PASSWORD} has been assigned for {SERVICE} user {USERNAME}.",
    # Multi-sentence
    "The {SERVICE} at {HOSTNAME} has been provisioned. Login with {USERNAME} and password {PASSWORD}. Change on first access.",
]

# Password context phrases
PW_CONTEXT_PHRASES = [
    "The default password is",
    "Your temporary password is",
    "The initial password is",
    "Your new password is",
    "The reset password is",
    "Use password",
    "Password:",
    "Your password has been set to",
    "The system has assigned",
    "Temporary credential:",
    "Initial access code:",
    "One-time password:",
    "Generated password:",
    "The default password after resetting is",
    "Your temporary password has been set to",
    "The system has reset your password to",
    "Your account password is now",
    "The assigned temporary password is",
    "After reset, your password is",
    "Your temporary access password is",
    "The new temporary password is",
]

CLOUD_AWS_PATTERNS = [
    "AWS {AWS_SERVICE} access key: {ACCESS_KEY}, secret: {SECRET_KEY}",
    "AWS account {ACCOUNT_ID}: access key {ACCESS_KEY}, secret key {SECRET_KEY}",
    "{PREFIX}the AWS {AWS_SERVICE} credentials are access key {ACCESS_KEY} and secret {SECRET_KEY}",
    "IAM user {USERNAME} in account {ACCOUNT_ID}: {ACCESS_KEY} / {SECRET_KEY}",
    "AWS_ACCESS_KEY_ID={ACCESS_KEY}\nAWS_SECRET_ACCESS_KEY={SECRET_KEY}",
    "AWS credentials for {AWS_SERVICE} in {AWS_REGION}: key {ACCESS_KEY}, secret {SECRET_KEY}",
    "Production AWS account ({ACCOUNT_ID}) - {USERNAME}: {ACCESS_KEY} / {SECRET_KEY}",
    "{AWS_SERVICE} ({AWS_REGION}): access key {ACCESS_KEY}{CLOSING}",
    "ARN: arn:aws:iam::{ACCOUNT_ID}:user/{USERNAME}, key: {ACCESS_KEY}",
    "{PREFIX}use access key {ACCESS_KEY} for {AWS_SERVICE} in {AWS_REGION}",
    "AWS console login: account {ACCOUNT_ID}, user {USERNAME}, password {PASSWORD}",
    "[{AWS_REGION}] {AWS_SERVICE} credentials: {ACCESS_KEY} / {SECRET_KEY}",
    "Terraform AWS provider: access_key = \"{ACCESS_KEY}\", secret_key = \"{SECRET_KEY}\", region = \"{AWS_REGION}\"",
    "aws configure --profile prod: key={ACCESS_KEY} secret={SECRET_KEY} region={AWS_REGION}",

    # Notification
    "New AWS credentials have been generated. Access key: {ACCESS_KEY}, secret: {SECRET_KEY}.",
    # Multi-sentence
    "The {AWS_SERVICE} service in {AWS_REGION} is ready. Access key: {ACCESS_KEY}. Secret key: {SECRET_KEY}. Rotate within 90 days.",
    # Conversational
    "Here are the AWS creds for {AWS_SERVICE}: {ACCESS_KEY} / {SECRET_KEY}.",
    # Passive
    "IAM credentials have been issued for account {ACCOUNT_ID}: key {ACCESS_KEY}, secret {SECRET_KEY}.",
    # Formal
    "Please find below the AWS credentials for {AWS_SERVICE}: access key {ACCESS_KEY} and secret key {SECRET_KEY}.",
]

CLOUD_AZURE_PATTERNS = [
    "Azure {AZURE_SERVICE} tenant {TENANT_ID}, client {CLIENT_ID}, secret {CLIENT_SECRET}",
    "AZURE_TENANT_ID={TENANT_ID}\nAZURE_CLIENT_ID={CLIENT_ID}\nAZURE_CLIENT_SECRET={CLIENT_SECRET}",
    "Azure AD app registration: client ID {CLIENT_ID}, secret {CLIENT_SECRET}",
    "{PREFIX}the {AZURE_SERVICE} service principal: tenant {TENANT_ID}, client {CLIENT_ID}, secret {CLIENT_SECRET}",
    "Azure {AZURE_RESOURCE} connection string: {PASSWORD}",
    "SAS token for {AZURE_SERVICE}: {API_KEY}",
    "Azure {AZURE_RESOURCE} admin password: {PASSWORD}",
    "az login --service-principal -u {CLIENT_ID} -p {CLIENT_SECRET} --tenant {TENANT_ID}",
    "Azure Key Vault ({URL}): secret {API_KEY}",
    "Subscription {ACCOUNT_ID}: {AZURE_SERVICE} credentials - client {CLIENT_ID}, secret {CLIENT_SECRET}",
    "Azure SQL connection: Server={HOSTNAME};Database={DBNAME};User={USERNAME};Password={PASSWORD}",
    "{AZURE_SERVICE} managed identity: client ID {CLIENT_ID}{CLOSING}",

    # Notification
    "Azure service principal credentials have been created. Client ID: {CLIENT_ID}, secret: {CLIENT_SECRET}.",
    # Multi-sentence
    "The {AZURE_SERVICE} is configured under tenant {TENANT_ID}. Client ID: {CLIENT_ID}. Client secret: {CLIENT_SECRET}.",
    # Conversational
    "Here are the Azure creds: tenant {TENANT_ID}, client {CLIENT_ID}, secret {CLIENT_SECRET}.",
    # Passive
    "A new client secret {CLIENT_SECRET} has been generated for app {CLIENT_ID}.",
    # Urgency
    "Azure client secret for {CLIENT_ID} expires soon. Current secret: {CLIENT_SECRET}. Rotate immediately.",
]

NETWORK_VPN_PATTERNS = [
    "{VPN_TYPE} gateway: {URL}, username {USERNAME}, password {PASSWORD}",
    "VPN credentials for {VPN_TYPE}: server {URL}, user {USERNAME}, pass {PASSWORD}",
    "{PREFIX}connect to {VPN_TYPE} at {URL} with password {PASSWORD}",
    "WiFi network \"{HOSTNAME}\": security {WIFI_SEC}, password {PASSWORD}",
    "Guest WiFi password: {PASSWORD}. Network: {HOSTNAME}",
    "Corporate WiFi ({HOSTNAME}): {WIFI_SEC}, passphrase {PASSWORD}",
    "{NETWORK_DEVICE} admin console: {URL}, credentials {USERNAME}/{PASSWORD}",
    "Firewall {HOSTNAME} management: user {USERNAME}, password {PASSWORD}",
    "RADIUS shared secret for {HOSTNAME}: {PASSWORD}",
    "{VPN_TYPE} config: remote {URL}, auth {USERNAME}/{PASSWORD}",
    "Network {NETWORK_DEVICE} at {HOSTNAME}: admin password {PASSWORD}{CLOSING}",
    "IPSec pre-shared key: {PASSWORD}. Gateway: {URL}",
    "Site-to-site VPN tunnel: endpoint {URL}, PSK {PASSWORD}",
    "SNMP community string for {HOSTNAME}: {PASSWORD}",

    # Notification
    "VPN access has been configured. Server: {URL}, username: {USERNAME}, password: {PASSWORD}.",
    # Multi-sentence
    "Connect to {VPN_TYPE} at {URL}. Your username is {USERNAME} and password is {PASSWORD}. Change on first login.",
    # Conversational
    "Here are your VPN credentials: server {URL}, user {USERNAME}, pass {PASSWORD}.",
    # Passive
    "A {VPN_TYPE} account has been created for you. Server: {URL}, password: {PASSWORD}.",
    # Urgency
    "{VPN_TYPE} password for {USERNAME} expires soon. Current: {PASSWORD}. Update at {URL}.",
]

CICD_DEVOPS_PATTERNS = [
    "{CICD_PLATFORM} token: {API_KEY}",
    "GitHub personal access token: {API_KEY}",
    "{CICD_PLATFORM} credentials: user {USERNAME}, token {API_KEY}",
    "Docker registry ({REGISTRY}) login: {USERNAME} / {PASSWORD}",
    "{PREFIX}the {CICD_PLATFORM} deploy key is {API_KEY}",
    "DOCKER_USERNAME={USERNAME}\nDOCKER_PASSWORD={PASSWORD}\nDOCKER_REGISTRY={REGISTRY}",
    "{REGISTRY} push credentials: {USERNAME}:{PASSWORD}",
    "Terraform Cloud API token: {API_KEY}",
    "{CICD_PLATFORM} webhook secret: {API_KEY}{CLOSING}",
    "CI/CD pipeline secret ({CICD_PLATFORM}): {API_KEY}",
    "Ansible vault password: {PASSWORD}",
    "Kubernetes service account token: {API_KEY}",
    "Helm chart repo ({URL}): user {USERNAME}, password {PASSWORD}",
    "ArgoCD admin password: {PASSWORD}. Server: {URL}",
    "NPM_TOKEN={API_KEY}",
    "PYPI_TOKEN={API_KEY}",
    "{CICD_PLATFORM} SSH deploy key for {URL}: {SSH_KEY}",

    # Notification
    "A new {CICD_PLATFORM} token has been generated: {API_KEY}.",
    # Multi-sentence
    "The {CICD_PLATFORM} pipeline is configured. Deploy token: {API_KEY}. Registry: {REGISTRY}, user: {USERNAME}, password: {PASSWORD}.",
    # Conversational
    "Here's the {CICD_PLATFORM} deploy key: {API_KEY}.",
    # Passive
    "A deploy token {API_KEY} has been created for the {CICD_PLATFORM} pipeline.",
    # Urgency
    "{CICD_PLATFORM} token {API_KEY} needs rotation. Current credentials: {USERNAME} / {PASSWORD}.",
]

EMAIL_SMTP_PATTERNS = [
    "SMTP server: {SMTP_SVR}, port {PORT}, user {EMAIL}, password {PASSWORD}",
    "Email credentials: {SMTP_SVR}:{PORT}, login {EMAIL}/{PASSWORD}",
    "SMTP_HOST={SMTP_SVR}\nSMTP_PORT={PORT}\nSMTP_USER={EMAIL}\nSMTP_PASS={PASSWORD}",
    "{PREFIX}the outgoing mail server is {SMTP_SVR} with password {PASSWORD}",
    "Mail relay: {SMTP_SVR}, auth {EMAIL} / {PASSWORD}",
    "{EMAIL_PROTO} server {SMTP_SVR}: username {EMAIL}, password {PASSWORD}",
    "Office 365 SMTP: smtp.office365.com:587, user {EMAIL}, pass {PASSWORD}",
    "SendGrid API key for transactional email: {API_KEY}",
    "Mailgun API key: {API_KEY}, domain: {DOMAIN}",
    "Email service ({SMTP_SVR}): app password {PASSWORD}{CLOSING}",
    "IMAP login: server {SMTP_SVR}, user {EMAIL}, password {PASSWORD}",
    "Exchange server: {URL}, mailbox {EMAIL}, password {PASSWORD}",

    # Notification
    "SMTP credentials have been configured. Server: {SMTP_SVR}, user: {EMAIL}, password: {PASSWORD}.",
    # Multi-sentence
    "The mail server is {SMTP_SVR} on port {PORT}. Login with {EMAIL} and password {PASSWORD}.",
    # Conversational
    "SMTP details: server {SMTP_SVR}, port {PORT}, user {EMAIL}, pass {PASSWORD}.",
    # Passive
    "An SMTP account has been provisioned. Server: {SMTP_SVR}, credentials: {EMAIL} / {PASSWORD}.",
    # Formal
    "Please configure your email client with server {SMTP_SVR}, port {PORT}, username {EMAIL}, and password {PASSWORD}.",
]

FINANCIAL_BANKING_PATTERNS = [
    "{TRANSACTION} of {AMOUNT} to account {ACCOUNT} at {BANK}",
    "Wire transfer: {AMOUNT} to {BANK}, account {ACCOUNT}, routing {ROUTING}",
    "ACH details: routing {ROUTING}, account {ACCOUNT}, amount {AMOUNT}",
    "Payment to {NAME}: {AMOUNT} via {TRANSACTION} to {BANK} account {ACCOUNT}",
    "Bank: {BANK}, Account: {ACCOUNT}, Routing: {ROUTING}",
    "{PREFIX}{TRANSACTION} of {AMOUNT} to {NAME} at {BANK}{CLOSING}",
    "Invoice #{NUMBER}: {AMOUNT} payable to account {ACCOUNT} at {BANK}",
    "Direct deposit: {BANK} routing {ROUTING} account {ACCOUNT}",
    "SWIFT code: {ROUTING}. Beneficiary account: {ACCOUNT}. Amount: {AMOUNT}",
    "Payroll: {NAME} - {BANK} account {ACCOUNT}, {AMOUNT} per period",
    "Treasury {TRANSACTION}: {AMOUNT} from account {ACCOUNT} to {NAME}",
    "Credit facility: {AMOUNT} at {RATE}% from {BANK}. Account: {ACCOUNT}",
    "Company bank details: {BANK}, routing {ROUTING}, account {ACCOUNT}",

    # Multi-sentence
    "Wire transfer authorized. Amount: {AMOUNT}. Destination: {BANK}, account {ACCOUNT}, routing {ROUTING}.",
    # Notification
    "A payment of {AMOUNT} has been initiated to {BANK} account {ACCOUNT}.",
    # Passive
    "Funds of {AMOUNT} have been wired to routing {ROUTING}, account {ACCOUNT} at {BANK}.",
    # Formal
    "Please process a transfer of {AMOUNT} to {BANK}. Routing: {ROUTING}. Account: {ACCOUNT}.",
    # Conversational
    "FYI wired {AMOUNT} to {BANK}, acct {ACCOUNT}, routing {ROUTING}.",
]

LEGAL_CONFIDENTIAL_PATTERNS = [
    "{LEGAL_TYPE} between {COMPANY} and {LEGAL_PARTY}: {AMOUNT}",
    "Settlement: {AMOUNT} to {LEGAL_PARTY}. Case #{NUMBER}. Confidential.",
    "{LEGAL_TYPE} signed {DATE}: {COMPANY} agrees to pay {AMOUNT}",
    "Acquisition of {COMPANY} for {AMOUNT}. Closing date: {DATE}",
    "M&A: {COMPANY} valued at {AMOUNT}. {LEGAL_PARTY} advising.",
    "{PREFIX}{LEGAL_TYPE} with {COMPANY}: total value {AMOUNT}{CLOSING}",
    "Confidential: {COMPANY} settlement for {AMOUNT} on {DATE}",
    "Board approved: acquire {COMPANY} at {AMOUNT} per share",
    "Termination agreement: {NAME} receives {AMOUNT}. Effective {DATE}.",
    "Non-compete: {NAME}, {COMPANY}, {DATE} through {DATE}. Penalty: {AMOUNT}",
    "{LEGAL_TYPE}: {COMPANY}. Effective {DATE}. Governing law: Delaware.",
    "Pending litigation: {COMPANY} vs {LEGAL_PARTY}. Reserve: {AMOUNT}",
    "Due diligence: {COMPANY} EBITDA {AMOUNT}. LOI signed {DATE}.",

    # Notification
    "Settlement approved: {AMOUNT} to {LEGAL_PARTY}. {LEGAL_TYPE} signed {DATE}.",
    # Multi-sentence
    "The {LEGAL_TYPE} with {COMPANY} has been finalized. Settlement amount: {AMOUNT}. Effective: {DATE}. This is strictly confidential.",
    # Passive
    "A {LEGAL_TYPE} has been executed between the parties. {COMPANY} to receive {AMOUNT}.",
    # Conversational
    "FYI the {COMPANY} deal closed at {AMOUNT}. {LEGAL_TYPE} signed {DATE}.",
    # Urgency
    "Confidential: {LEGAL_TYPE} for {COMPANY} at {AMOUNT} requires signature by {DATE}.",
]

MEDICAL_HIPAA_PATTERNS = [
    "Patient {NAME}, MRN {MRN}: {DIAGNOSIS_CODE}. Attending: Dr. {NAME}",
    "Medical record: {NAME}, DOB {DATE}, MRN {MRN}",
    "{FACILITY} - patient {NAME}: {DIAGNOSIS_CODE}, admitted {DATE}",
    "Prescription for {NAME} (MRN {MRN}): {MEDICATION} {DOSAGE}. Dr. {NAME}",
    "Lab results for {NAME} ({MRN}): {CODE}. {DEPARTMENT} department.",
    "Discharge summary: {NAME}, MRN {MRN}. Admitted {DATE}. {DIAGNOSIS_CODE}",
    "HIPAA: patient {NAME}, SSN ending {SSN_LAST4}, MRN {MRN}",
    "Insurance: {NAME}, member ID {MRN}, group #{NUMBER}",
    "{DEPARTMENT}: {NAME}, {DIAGNOSIS_CODE}. Follow-up {DATE}",
    "Surgical report: {NAME}, MRN {MRN}. Procedure: {CODE}. Date: {DATE}",
    "Mental health record: {NAME}. Provider: {FACILITY}. Session {DATE}",
    "Radiology: {NAME}, MRN {MRN}. Findings: {CODE}. Ordered by Dr. {NAME}",

    # Notification
    "Lab results are available for patient {NAME}, MRN {MRN}. {DIAGNOSIS_CODE}.",
    # Multi-sentence
    "Patient {NAME} (MRN: {MRN}) was admitted on {DATE}. Diagnosis: {DIAGNOSIS_CODE}. Attending physician notified.",
    # Passive
    "Results for {NAME} (MRN {MRN}) have been posted. {DIAGNOSIS_CODE}.",
    # Formal
    "This is to notify that patient {NAME}, MRN {MRN}, has been diagnosed with {DIAGNOSIS_CODE} on {DATE}.",
    # Conversational
    "FYI patient {NAME} MRN {MRN} labs came back: {DIAGNOSIS_CODE}.",
]

CUSTOMER_PII_PATTERNS = [
    "Customer: {NAME}, SSN: {SSN}, DOB: {DATE}",
    "{PII_DOC}: {NAME}, card ending {CARD_LAST4}, exp {DATE}",
    "Account holder: {NAME}. Address: {ADDRESS}. Phone: {PHONE}. Email: {EMAIL}",
    "Member profile: {NAME}, ID {EMPLOYEE_ID}, email {EMAIL}, phone {PHONE}",
    "Credit card: {NAME}, ending {CARD_LAST4}, billing {ADDRESS}",
    "Customer {NAME}: SSN {SSN}, DL #{NUMBER}",
    "KYC: {NAME}, DOB {DATE}, SSN {SSN}, address {ADDRESS}",
    "Loyalty account: {NAME}, email {EMAIL}. Points: {AMOUNT}. Phone: {PHONE}",
    "Subscriber: {NAME}, phone {PHONE}, address {ADDRESS}, since {DATE}",
    "Dispute: {NAME}, card ending {CARD_LAST4}, amount {AMOUNT}, date {DATE}",
    "Identity verification: {NAME}, SSN ending {SSN_LAST4}, DOB {DATE}",
    "Data export: {NAME}, {EMAIL}, {PHONE}, {ADDRESS}, account since {DATE}",

    # Notification
    "New customer registered: {NAME}, SSN: {SSN}, DOB: {DATE}.",
    # Multi-sentence
    "Customer {NAME} has been verified. SSN: {SSN}. Date of birth: {DATE}. Address: {ADDRESS}.",
    # Passive
    "Account for {NAME} has been created. SSN ending {SSN_LAST4} verified.",
    # Formal
    "KYC verification complete for {NAME}. SSN: {SSN}, DOB: {DATE}, address: {ADDRESS}.",
    # Conversational
    "New account: {NAME}, DOB {DATE}, SSN {SSN}. Address: {ADDRESS}.",
]

INTERNAL_STRATEGY_PATTERNS = [
    "{MEETING}: {STRATEGY_ACTION} acquisition of {COMPANY} for {AMOUNT}",
    "Confidential: {COMPANY} Q{QUARTER} revenue {AMOUNT}. Not yet public.",
    "{MEETING} minutes: {NAME} {STRATEGY_ACTION} {AMOUNT} budget for {DEPARTMENT}",
    "Pre-announcement: {COMPANY} to lay off {NUMBER} employees effective {DATE}",
    "M&A pipeline: {COMPANY} target, valuation {AMOUNT}, LOI by {DATE}",
    "Strategic initiative: invest {AMOUNT} in {DEPARTMENT}. Sponsor: {NAME}",
    "{PREFIX}board {STRATEGY_ACTION} {AMOUNT} share buyback program{CLOSING}",
    "Earnings preview: Q{QUARTER} EPS {AMOUNT}. Embargo until {DATE}.",
    "Restructuring: {DEPARTMENT} headcount reduced by {NUMBER}. Savings: {AMOUNT}",
    "{MEETING}: CEO {NAME} proposed merger with {COMPANY}. Valued at {AMOUNT}.",
    "Insider information: {COMPANY} patent settlement {AMOUNT}. Announce {DATE}.",
    "Compensation committee: CEO {NAME} total comp {AMOUNT} for FY{YEAR}",

    # Notification
    "Board has approved acquisition of {COMPANY} for {AMOUNT}. Closing: {DATE}.",
    # Multi-sentence
    "{MEETING} update: {STRATEGY_ACTION} {COMPANY} acquisition at {AMOUNT}. Target close date: {DATE}. Strictly confidential.",
    # Passive
    "The acquisition of {COMPANY} has been {STRATEGY_ACTION} at a valuation of {AMOUNT}.",
    # Formal
    "This is to confirm that the {MEETING} has {STRATEGY_ACTION} the {COMPANY} transaction for {AMOUNT}.",
    # Conversational
    "FYI board {STRATEGY_ACTION} the {COMPANY} deal at {AMOUNT}. Closing {DATE}.",
]

CERTIFICATE_TLS_PATTERNS = [
    "{CERT_TYPE} certificate for {DOMAIN}: private key passphrase {PASSWORD}",
    "SSL cert ({DOMAIN}): key file /etc/ssl/{DOMAIN}.key, passphrase {PASSWORD}",
    "{CERT_TYPE} ({CERT_FORMAT}): {DOMAIN}, expires {DATE}, passphrase {PASSWORD}",
    "Wildcard cert *.{DOMAIN}: PKCS12 password {PASSWORD}",
    "Certificate Authority: {URL}. Signing key passphrase: {PASSWORD}",
    "{PREFIX}the {CERT_TYPE} private key password for {DOMAIN} is {PASSWORD}",
    "JKS keystore: /opt/certs/{DOMAIN}.jks, password {PASSWORD}",
    "Let's Encrypt cert for {DOMAIN}: account key {API_KEY}",
    "Code signing certificate: {DOMAIN}, key password {PASSWORD}, expires {DATE}",
    "Client certificate for {USERNAME}@{DOMAIN}: passphrase {PASSWORD}",
    "PFX export password for {DOMAIN}: {PASSWORD}",
    "Root CA key passphrase: {PASSWORD}. Cert path: /etc/pki/ca/{DOMAIN}.crt",

    # Notification
    "SSL certificate for {DOMAIN} has been renewed. Key passphrase: {PASSWORD}.",
    # Multi-sentence
    "The {CERT_TYPE} certificate for {DOMAIN} expires on {DATE}. Keystore password: {PASSWORD}. Please renew before expiration.",
    # Passive
    "A new {CERT_TYPE} certificate has been issued for {DOMAIN}. Passphrase: {PASSWORD}.",
    # Formal
    "Please find the {CERT_TYPE} certificate details: domain {DOMAIN}, format {CERT_FORMAT}, passphrase {PASSWORD}.",
    # Urgency
    "Certificate for {DOMAIN} expires {DATE}. Current key passphrase: {PASSWORD}. Renew immediately.",
]

ENCRYPTION_KEYS_PATTERNS = [
    "HashiCorp Vault token: {API_KEY}. URL: {URL}",
    "Vault ({URL}): root token {API_KEY}, unseal key {PASSWORD}",
    "KMS key ID: {API_KEY}. Region: {AWS_REGION}",
    "{ENCRYPTION_TYPE} master key: {PASSWORD}",
    "VAULT_TOKEN={API_KEY}\nVAULT_ADDR={URL}",
    "GPG passphrase for {EMAIL}: {PASSWORD}",
    "{PREFIX}the {ENCRYPTION_TYPE} encryption key is {PASSWORD}",
    "Secrets path: {VAULT_PATH}. Token: {API_KEY}",
    "SOPS key: {API_KEY}. Config: .sops.yaml",
    "Age recipient key: {API_KEY}",
    "LUKS passphrase for /dev/sda2: {PASSWORD}",
    "Sealed secrets key: {API_KEY}. Namespace: {HOSTNAME}",
    "Backup encryption passphrase: {PASSWORD}. Algorithm: {ENCRYPTION_TYPE}",

    # Notification
    "New Vault token has been generated: {API_KEY}. Endpoint: {URL}.",
    # Multi-sentence
    "The secrets vault at {URL} is ready. Root token: {API_KEY}. Unseal key: {PASSWORD}. Store securely.",
    # Passive
    "A {ENCRYPTION_TYPE} key has been provisioned. Key ID: {API_KEY}.",
    # Formal
    "Please configure the vault at {URL} using token {API_KEY} and unseal key {PASSWORD}.",
    # Conversational
    "Vault is up at {URL}. Token: {API_KEY}, unseal: {PASSWORD}.",
]

OAUTH_SSO_PATTERNS = [
    "{OAUTH_PROVIDER} client ID: {CLIENT_ID}, secret: {CLIENT_SECRET}",
    "OAuth2 ({OAUTH_PROVIDER}): client_id={CLIENT_ID}, client_secret={CLIENT_SECRET}",
    "SSO config ({OAUTH_PROVIDER}): tenant {TENANT_ID}, client {CLIENT_ID}, secret {CLIENT_SECRET}",
    "SAML IdP ({OAUTH_PROVIDER}): metadata URL {URL}, signing cert password {PASSWORD}",
    "OIDC discovery: {URL}/.well-known/openid-configuration. Client secret: {CLIENT_SECRET}",
    "{PREFIX}{OAUTH_PROVIDER} app credentials: client {CLIENT_ID}, secret {CLIENT_SECRET}",
    "Redirect URI: {URL}/callback. Client secret: {CLIENT_SECRET}",
    "{OAUTH_PROVIDER} API: client_credentials grant, secret {CLIENT_SECRET}",
    "JWT signing key ({OAUTH_PROVIDER}): {API_KEY}",
    "SSO admin ({OAUTH_PROVIDER}): {URL}, API token {API_KEY}",
    "SCIM provisioning token ({OAUTH_PROVIDER}): {API_KEY}",
    "MFA bypass code ({OAUTH_PROVIDER}): {PASSWORD}",

    # Notification
    "OAuth app registered with {OAUTH_PROVIDER}. Client ID: {CLIENT_ID}, secret: {CLIENT_SECRET}.",
    # Multi-sentence
    "SSO has been configured with {OAUTH_PROVIDER}. Client ID: {CLIENT_ID}. Client secret: {CLIENT_SECRET}. Discovery URL: {URL}.",
    # Passive
    "A new client secret {CLIENT_SECRET} has been generated for {OAUTH_PROVIDER} app {CLIENT_ID}.",
    # Formal
    "Please update the {OAUTH_PROVIDER} configuration with client ID {CLIENT_ID} and secret {CLIENT_SECRET}.",
    # Urgency
    "{OAUTH_PROVIDER} client secret for {CLIENT_ID} expires soon. Current: {CLIENT_SECRET}. Rotate immediately.",
]

DATABASE_CONNECTION_PATTERNS = [
    "jdbc:{DBTYPE}://{HOSTNAME}:{PORT}/{DBNAME}?user={USERNAME}&password={PASSWORD}",
    "{DBTYPE}://{USERNAME}:{PASSWORD}@{HOSTNAME}:{PORT}/{DBNAME}",
    "DSN: {DBTYPE}://{USERNAME}:{PASSWORD}@{HOSTNAME}/{DBNAME}",
    "Database: {DBTYPE} on {HOSTNAME}:{PORT}. DB: {DBNAME}. User: {USERNAME}. Pass: {PASSWORD}",
    "DATABASE_URL={DBTYPE}://{USERNAME}:{PASSWORD}@{HOSTNAME}:{PORT}/{DBNAME}",
    "Connection: host={HOSTNAME} port={PORT} dbname={DBNAME} user={USERNAME} password={PASSWORD}",
    "{DBTYPE} connection string: Server={HOSTNAME},{PORT};Database={DBNAME};User Id={USERNAME};Password={PASSWORD}",
    "Data Source={HOSTNAME};Initial Catalog={DBNAME};User ID={USERNAME};Password={PASSWORD}",
    "ODBC: Driver={DBTYPE};Server={HOSTNAME};Port={PORT};Database={DBNAME};Uid={USERNAME};Pwd={PASSWORD}",
    "{PREFIX}{DBTYPE} production database: {HOSTNAME}:{PORT}/{DBNAME}, user {USERNAME}, password {PASSWORD}",
    "Read replica: {HOSTNAME}:{PORT}, db {DBNAME}, credentials {USERNAME}/{PASSWORD}",
    "Connection pooler: pgbouncer://{USERNAME}:{PASSWORD}@{HOSTNAME}:{PORT}/{DBNAME}",

    # Notification
    "Database credentials have been updated. Host: {HOSTNAME}, user: {USERNAME}, password: {PASSWORD}.",
    # Multi-sentence
    "The {DBTYPE} database is available at {HOSTNAME}:{PORT}. Database name: {DBNAME}. Login with {USERNAME} and password {PASSWORD}.",
    # Passive
    "A {DBTYPE} account has been created. Host: {HOSTNAME}, database: {DBNAME}, user: {USERNAME}, password: {PASSWORD}.",
    # Conversational
    "DB creds: {DBTYPE} on {HOSTNAME}:{PORT}/{DBNAME}, user {USERNAME}, pass {PASSWORD}.",
    # Formal
    "Please connect to {DBTYPE} at {HOSTNAME}:{PORT} using database {DBNAME}, username {USERNAME}, and password {PASSWORD}.",
]

VENDOR_PARTNER_PATTERNS = [
    "{VENDOR} API key: {API_KEY}. Endpoint: {URL}",
    "Vendor ({VENDOR}) credentials: user {USERNAME}, key {API_KEY}",
    "Partner portal ({VENDOR}): {URL}, login {USERNAME}/{PASSWORD}",
    "{VENDOR} integration: API URL {URL}, token {API_KEY}",
    "{PREFIX}{VENDOR} access credentials: API key {API_KEY}{CLOSING}",
    "Third-party service ({VENDOR}): endpoint {URL}, secret {PASSWORD}",
    "{VENDOR} webhook URL: {URL}, signing secret {API_KEY}",
    "Vendor SFTP ({VENDOR}): host {HOSTNAME}, user {USERNAME}, password {PASSWORD}",
    "Partner API ({VENDOR}): client ID {CLIENT_ID}, secret {CLIENT_SECRET}",
    "{VENDOR} sandbox: {URL}, test key {API_KEY}",
    "{VENDOR} production key: {API_KEY}. Rate limit: 1000/min.",
    "SLA with {VENDOR}: support portal {URL}, admin password {PASSWORD}",

    # Notification
    "{VENDOR} integration is live. API key: {API_KEY}. Endpoint: {URL}.",
    # Multi-sentence
    "The {VENDOR} API has been configured. Endpoint: {URL}. API key: {API_KEY}. Contact vendor for support.",
    # Passive
    "Access to {VENDOR} has been provisioned. Portal: {URL}, credentials: {USERNAME} / {PASSWORD}.",
    # Formal
    "Please configure the {VENDOR} integration with endpoint {URL} and API key {API_KEY}.",
    # Conversational
    "Here's the {VENDOR} API key: {API_KEY}. Endpoint: {URL}.",
]

SAAS_CREDENTIALS_PATTERNS = [
    "{SAAS_PLATFORM} login: {USERNAME} / {PASSWORD}",
    "{SAAS_PLATFORM} admin account: {EMAIL}, password {PASSWORD}",
    "{SAAS_PLATFORM} API token: {API_KEY}",
    "{SAAS_PLATFORM} ({URL}): user {USERNAME}, password {PASSWORD}",
    "{PREFIX}the {SAAS_PLATFORM} service account password is {PASSWORD}",
    "{SAAS_PLATFORM} integration token: {API_KEY}. Workspace: {HOSTNAME}",
    "SAAS_TOKEN={API_KEY}\nSAAS_URL={URL}",
    "{SAAS_PLATFORM} OAuth app: client ID {CLIENT_ID}, secret {CLIENT_SECRET}",
    "{SAAS_PLATFORM} SSO admin: {URL}, API key {API_KEY}",
    "{SAAS_PLATFORM} bot token: {API_KEY}",
    "Service account for {SAAS_PLATFORM}: {EMAIL} / {PASSWORD}",
    "{SAAS_PLATFORM} webhook secret: {API_KEY}. Endpoint: {URL}",

    # Notification
    "Your {SAAS_PLATFORM} account has been created. Login: {USERNAME}, password: {PASSWORD}.",
    # Multi-sentence
    "{SAAS_PLATFORM} is ready. Log in at the portal with username {USERNAME} and password {PASSWORD}. Change on first login.",
    # Passive
    "A {SAAS_PLATFORM} account has been provisioned. Credentials: {EMAIL} / {PASSWORD}.",
    # Formal
    "Please sign in to {SAAS_PLATFORM} using username {USERNAME} and password {PASSWORD}.",
    # Urgency
    "{SAAS_PLATFORM} password for {USERNAME} expires soon. Current: {PASSWORD}. Update immediately.",
]


# ============================================================================
# DOMAIN CONFIGURATIONS
# ============================================================================

DOMAIN_CONFIGS = {
    "it_password": {
        "name": "IT/Password Reset",
        "slot_types": ["PASSWORD", "URL", "API_KEY", "USERNAME", "EMAIL"],
        "primary_slot": "PASSWORD",
        "patterns": PASSWORD_RESET_PATTERNS,
        "base_templates": [
            "Please navigate to {URL} and click on Need help signing in. The default password after resetting is {PASSWORD} which must be changed immediately.",
            "Visit {URL} to reset your password. Your temporary credential is {PASSWORD} and must be updated on first login.",
            "Access the login portal at {URL} and select forgot password. The system will assign {PASSWORD} as your temporary access code.",
            "For password recovery, go to {URL} and follow the reset process. Default credentials are {PASSWORD}.",
            "The SSO portal at {URL} requires password reset. Use {PASSWORD} for initial access then change immediately.",
            "Your account password has been reset. New temporary password: {PASSWORD}. Change at {URL}.",
            "Password reset complete for your account. Temporary access: {PASSWORD}. Login at {URL} to update.",
        ]
    },
    "hr_employee": {
        "name": "HR/Employee Records",
        "slot_types": ["NAME", "SALARY", "SSN", "EMPLOYEE_ID", "DATE", "EMAIL"],
        "primary_slot": "NAME",
        "patterns": [
            "Employee {NAME} salary adjusted to {SALARY} effective {DATE}.",
            "{NAME} ({EMPLOYEE_ID}) - Salary: {SALARY}",
            "Personnel record: {NAME}, ID {EMPLOYEE_ID}, compensation {SALARY}.",
            "New hire {NAME} starting {DATE} at {SALARY} annually.",
            "{NAME_PREFIX}{NAME} {SALARY_ACTION} to {SALARY} {DATE_CTX} {DATE}.",

            # Multi-sentence
            "{NAME} has been hired starting {DATE}. Annual compensation: {SALARY}. Please update payroll.",
            # Notification
            "Salary adjustment notification: {NAME} adjusted to {SALARY} effective {DATE}.",
            # Passive
            "{NAME}'s compensation has been updated to {SALARY} as of {DATE}.",
            # Formal
            "This is to confirm that {NAME} (ID: {EMPLOYEE_ID}) salary is now {SALARY}.",
            # Conversational
            "FYI {NAME} is starting at {SALARY} on {DATE}.",
            # With context
            "HR update: {NAME}, employee ID {EMPLOYEE_ID}, annual salary {SALARY}, start date {DATE}.",
        ],
        "base_templates": [
            "Employee {NAME} salary adjusted to {SALARY} annually effective {DATE}.",
            "Compensation package for {NAME} includes base salary {SALARY}.",
            "New hire {NAME} starting {DATE} with salary {SALARY}.",
            "{NAME} has been onboarded. Employee ID: {EMPLOYEE_ID}. Annual salary: {SALARY}. Start date: {DATE}. Please update payroll records.",
            "HR notification: {NAME} (ID: {EMPLOYEE_ID}) compensation updated to {SALARY} effective {DATE}.",
            "This is to confirm that {NAME} will join the team on {DATE} with an annual salary of {SALARY}.",
            "FYI {NAME} salary is now {SALARY} as of {DATE}. Employee ID: {EMPLOYEE_ID}.",
        ]
    },
    "api_developer": {
        "name": "API/Developer",
        "slot_types": ["API_KEY", "URL", "TOKEN", "SECRET"],
        "primary_slot": "API_KEY",
        "patterns": [
            "API endpoint: {URL}, Key: {API_KEY}.",
            "Bearer token for {URL}: {API_KEY}.",
            "curl -H 'Authorization: Bearer {API_KEY}' {URL}",
            "Service URL: {URL} with auth {API_KEY}.",

            # Multi-sentence
            "The API is available at {URL}. Use key {API_KEY} for authentication.",
            # Notification
            "Your API key has been generated: {API_KEY}. Endpoint: {URL}.",
            # Passive
            "An API key {API_KEY} has been provisioned for endpoint {URL}.",
            # Conversational
            "Here's your API key: {API_KEY}. The endpoint is {URL}.",
            # Urgency
            "API key {API_KEY} for {URL} expires in 30 days. Rotate immediately.",
        ],
        "base_templates": [
            "API endpoint: {URL}, Key: {API_KEY}.",
            "Authentication token: {API_KEY}. Endpoint: {URL}.",
            "Production endpoint {URL} requires key {API_KEY}.",
            "Your API key has been generated: {API_KEY}. Use it to authenticate at {URL}. Rotate within 90 days.",
            "The API at {URL} is ready. Your key is {API_KEY}. Include it in the Authorization header.",
            "Here is your API key: {API_KEY}. The endpoint is {URL}. Please store it securely.",
        ]
    },
    "infrastructure_credentials": {
        "name": "Infrastructure/Server Credentials",
        "slot_types": ["PASSWORD", "USERNAME", "HOSTNAME", "DBNAME", "PORT"],
        "primary_slot": "PASSWORD",
        "patterns": INFRASTRUCTURE_CREDENTIAL_PATTERNS,
        "base_templates": [
            "Production database server admin username is {USERNAME} with password {PASSWORD}",
            "Database server admin username is {USERNAME} with password {PASSWORD}",
            "Server admin username is {USERNAME} with password {PASSWORD}",
            "Production database server admin username is admin with password {PASSWORD}",
            "The admin username is {USERNAME} and the password is {PASSWORD}",
            "{USERNAME}:{PASSWORD}",
            "Default credentials: {USERNAME} / {PASSWORD}",
            "Login: {USERNAME}, password: {PASSWORD}",
            "Server credentials - user: {USERNAME}, pass: {PASSWORD}",
            "Admin password: {PASSWORD}",
            "Root password for the database server is {PASSWORD}",
        ]
    },
    "cloud_aws": {
        "name": "Cloud/AWS Credentials",
        "slot_types": ["ACCESS_KEY", "SECRET_KEY", "ACCOUNT_ID", "PASSWORD", "USERNAME"],
        "primary_slot": "ACCESS_KEY",
        "patterns": CLOUD_AWS_PATTERNS,
        "base_templates": [
            "AWS account {ACCOUNT_ID}: access key {ACCESS_KEY}, secret key {SECRET_KEY}",
            "IAM user credentials: access key {ACCESS_KEY}, secret {SECRET_KEY}",
            "AWS_ACCESS_KEY_ID={ACCESS_KEY}\nAWS_SECRET_ACCESS_KEY={SECRET_KEY}",
            "AWS console login: account {ACCOUNT_ID}, user {USERNAME}, password {PASSWORD}",
            "Production AWS credentials: {ACCESS_KEY} / {SECRET_KEY}",
        ]
    },
    "cloud_azure": {
        "name": "Cloud/Azure Credentials",
        "slot_types": ["CLIENT_ID", "CLIENT_SECRET", "TENANT_ID", "PASSWORD", "ACCOUNT_ID"],
        "primary_slot": "CLIENT_SECRET",
        "patterns": CLOUD_AZURE_PATTERNS,
        "base_templates": [
            "Azure AD: tenant {TENANT_ID}, client {CLIENT_ID}, secret {CLIENT_SECRET}",
            "AZURE_TENANT_ID={TENANT_ID}\nAZURE_CLIENT_ID={CLIENT_ID}\nAZURE_CLIENT_SECRET={CLIENT_SECRET}",
            "Azure service principal: client {CLIENT_ID}, secret {CLIENT_SECRET}",
            "Azure SQL connection: Server={HOSTNAME};User={USERNAME};Password={PASSWORD}",
        ]
    },
    "network_vpn": {
        "name": "Network/VPN Credentials",
        "slot_types": ["PASSWORD", "USERNAME", "URL", "HOSTNAME"],
        "primary_slot": "PASSWORD",
        "patterns": NETWORK_VPN_PATTERNS,
        "base_templates": [
            "VPN gateway: {URL}, username {USERNAME}, password {PASSWORD}",
            "Corporate WiFi password: {PASSWORD}",
            "Firewall admin console: {URL}, credentials {USERNAME}/{PASSWORD}",
            "IPSec pre-shared key: {PASSWORD}",
            "Guest WiFi password: {PASSWORD}. Network: {HOSTNAME}",
        ]
    },
    "ci_cd_devops": {
        "name": "CI/CD DevOps Secrets",
        "slot_types": ["API_KEY", "PASSWORD", "USERNAME", "URL", "SSH_KEY"],
        "primary_slot": "API_KEY",
        "patterns": CICD_DEVOPS_PATTERNS,
        "base_templates": [
            "GitHub personal access token: {API_KEY}",
            "Docker registry login: {USERNAME} / {PASSWORD}",
            "Jenkins admin password: {PASSWORD}",
            "Terraform Cloud API token: {API_KEY}",
            "Ansible vault password: {PASSWORD}",
            "NPM_TOKEN={API_KEY}",
        ]
    },
    "email_smtp": {
        "name": "Email/SMTP Credentials",
        "slot_types": ["PASSWORD", "EMAIL", "URL", "API_KEY"],
        "primary_slot": "PASSWORD",
        "patterns": EMAIL_SMTP_PATTERNS,
        "base_templates": [
            "SMTP server: smtp.company.com, port 587, user {EMAIL}, password {PASSWORD}",
            "SendGrid API key: {API_KEY}",
            "Office 365 SMTP: user {EMAIL}, password {PASSWORD}",
            "SMTP_HOST=smtp.company.com\nSMTP_USER={EMAIL}\nSMTP_PASS={PASSWORD}",
        ]
    },
    "financial_banking": {
        "name": "Financial/Banking Details",
        "slot_types": ["ACCOUNT", "AMOUNT", "ROUTING", "NAME"],
        "primary_slot": "ACCOUNT",
        "patterns": FINANCIAL_BANKING_PATTERNS,
        "base_templates": [
            "Wire transfer: {AMOUNT} to account {ACCOUNT}, routing {ROUTING}",
            "Bank account: {ACCOUNT}, routing: {ROUTING}",
            "Payment to {NAME}: {AMOUNT} to account {ACCOUNT}",
            "Direct deposit: routing {ROUTING}, account {ACCOUNT}",
            "SWIFT transfer: {AMOUNT} to account {ACCOUNT}",
        ]
    },
    "legal_confidential": {
        "name": "Legal/Confidential",
        "slot_types": ["AMOUNT", "COMPANY", "NAME", "DATE"],
        "primary_slot": "AMOUNT",
        "patterns": LEGAL_CONFIDENTIAL_PATTERNS,
        "base_templates": [
            "Settlement: {AMOUNT} to {COMPANY}. Confidential.",
            "Acquisition of {COMPANY} for {AMOUNT}. Closing: {DATE}",
            "NDA between {COMPANY} and {NAME}. Signed {DATE}.",
            "Board approved acquisition: {COMPANY} at {AMOUNT}",
            "The settlement agreement with {COMPANY} has been finalized at {AMOUNT}. Effective {DATE}. This is strictly confidential.",
            "Confidential: {COMPANY} deal closed at {AMOUNT}. NDA signed {DATE}. Do not distribute.",
            "This is to confirm the merger with {COMPANY} for {AMOUNT}. Closing date: {DATE}. Board approval received.",
        ]
    },
    "medical_hipaa": {
        "name": "Medical/HIPAA Records",
        "slot_types": ["NAME", "MRN", "DATE", "CODE", "SSN_LAST4"],
        "primary_slot": "NAME",
        "patterns": MEDICAL_HIPAA_PATTERNS,
        "base_templates": [
            "Patient {NAME}, MRN {MRN}: diagnosis {CODE}",
            "Medical record: {NAME}, DOB {DATE}, MRN {MRN}",
            "Prescription for {NAME} (MRN {MRN}): medication, Dr. {NAME}",
            "HIPAA: patient {NAME}, SSN ending {SSN_LAST4}, MRN {MRN}",
            "Patient {NAME} (MRN: {MRN}) was admitted on {DATE}. Diagnosis: {CODE}. Attending physician has been notified.",
            "Lab results for patient {NAME}, MRN {MRN}, are now available. Diagnosis code: {CODE}.",
            "This is to notify that patient {NAME}, MRN {MRN}, has been diagnosed with {CODE} on {DATE}.",
        ]
    },
    "customer_pii": {
        "name": "Customer PII",
        "slot_types": ["NAME", "SSN", "EMAIL", "PHONE", "ADDRESS", "DATE"],
        "primary_slot": "NAME",
        "patterns": CUSTOMER_PII_PATTERNS,
        "base_templates": [
            "Customer: {NAME}, SSN: {SSN}, DOB: {DATE}",
            "Account holder: {NAME}. Email: {EMAIL}. Phone: {PHONE}.",
            "Member profile: {NAME}, email {EMAIL}, phone {PHONE}",
            "KYC: {NAME}, DOB {DATE}, SSN {SSN}, address {ADDRESS}",
            "Customer {NAME} has been verified. SSN: {SSN}. Date of birth: {DATE}. Address: {ADDRESS}. Account is now active.",
            "New customer registration: {NAME}, SSN: {SSN}, DOB: {DATE}. Identity verification complete.",
            "KYC verification complete for {NAME}. SSN: {SSN}, DOB: {DATE}, address: {ADDRESS}. Please review.",
        ]
    },
    "internal_strategy": {
        "name": "Internal Strategy/M&A",
        "slot_types": ["COMPANY", "AMOUNT", "NAME", "DATE"],
        "primary_slot": "COMPANY",
        "patterns": INTERNAL_STRATEGY_PATTERNS,
        "base_templates": [
            "Board approved acquisition of {COMPANY} for {AMOUNT}",
            "Q{QUARTER} revenue: {AMOUNT}. Not yet public.",
            "M&A target: {COMPANY}, valuation {AMOUNT}",
            "Restructuring: savings {AMOUNT}. Effective {DATE}.",
        ]
    },
    "certificate_tls": {
        "name": "Certificate/TLS Key Material",
        "slot_types": ["PASSWORD", "DOMAIN", "API_KEY", "DATE"],
        "primary_slot": "PASSWORD",
        "patterns": CERTIFICATE_TLS_PATTERNS,
        "base_templates": [
            "SSL certificate for {DOMAIN}: private key passphrase {PASSWORD}",
            "Wildcard cert *.{DOMAIN}: PKCS12 password {PASSWORD}",
            "JKS keystore password: {PASSWORD}",
            "Root CA key passphrase: {PASSWORD}",
            "Code signing cert passphrase: {PASSWORD}",
        ]
    },
    "encryption_keys": {
        "name": "Encryption Keys/Vault Secrets",
        "slot_types": ["API_KEY", "PASSWORD", "URL"],
        "primary_slot": "API_KEY",
        "patterns": ENCRYPTION_KEYS_PATTERNS,
        "base_templates": [
            "HashiCorp Vault token: {API_KEY}",
            "Vault root token: {API_KEY}, unseal key: {PASSWORD}",
            "GPG passphrase: {PASSWORD}",
            "VAULT_TOKEN={API_KEY}\nVAULT_ADDR={URL}",
            "KMS master key: {PASSWORD}",
        ]
    },
    "oauth_sso": {
        "name": "OAuth/SSO Secrets",
        "slot_types": ["CLIENT_ID", "CLIENT_SECRET", "URL", "API_KEY", "TENANT_ID"],
        "primary_slot": "CLIENT_SECRET",
        "patterns": OAUTH_SSO_PATTERNS,
        "base_templates": [
            "OAuth client ID: {CLIENT_ID}, secret: {CLIENT_SECRET}",
            "SSO config: client {CLIENT_ID}, secret {CLIENT_SECRET}",
            "OIDC client secret: {CLIENT_SECRET}. Discovery URL: {URL}",
            "SAML signing cert password: {PASSWORD}",
            "JWT signing key: {API_KEY}",
        ]
    },
    "database_connection": {
        "name": "Database Connection Strings",
        "slot_types": ["PASSWORD", "USERNAME", "HOSTNAME", "PORT", "DBNAME"],
        "primary_slot": "PASSWORD",
        "patterns": DATABASE_CONNECTION_PATTERNS,
        "base_templates": [
            "DATABASE_URL=postgresql://{USERNAME}:{PASSWORD}@{HOSTNAME}:{PORT}/{DBNAME}",
            "jdbc:mysql://{HOSTNAME}:{PORT}/{DBNAME}?user={USERNAME}&password={PASSWORD}",
            "Connection: host={HOSTNAME} dbname={DBNAME} user={USERNAME} password={PASSWORD}",
            "MongoDB: mongodb://{USERNAME}:{PASSWORD}@{HOSTNAME}:{PORT}/{DBNAME}",
            "The database is available at {HOSTNAME}:{PORT}. Database name: {DBNAME}. Login with {USERNAME} and password {PASSWORD}.",
            "Database credentials have been updated. Host: {HOSTNAME}, user: {USERNAME}, password: {PASSWORD}. Database: {DBNAME}.",
            "Please connect to the database at {HOSTNAME}:{PORT} using username {USERNAME} and password {PASSWORD}.",
        ]
    },
    "vendor_partner": {
        "name": "Vendor/Partner Access",
        "slot_types": ["API_KEY", "PASSWORD", "URL", "USERNAME", "CLIENT_ID", "CLIENT_SECRET"],
        "primary_slot": "API_KEY",
        "patterns": VENDOR_PARTNER_PATTERNS,
        "base_templates": [
            "Vendor API key: {API_KEY}. Endpoint: {URL}",
            "Partner portal: {URL}, login {USERNAME}/{PASSWORD}",
            "Third-party integration: API key {API_KEY}",
            "Vendor SFTP: user {USERNAME}, password {PASSWORD}",
            "The vendor API has been configured. Endpoint: {URL}. API key: {API_KEY}. Contact vendor for support.",
            "Vendor integration is live. API key: {API_KEY}. Endpoint: {URL}. Please verify connectivity.",
            "Access to the partner portal at {URL} has been provisioned. Username: {USERNAME}, password: {PASSWORD}.",
        ]
    },
    "saas_credentials": {
        "name": "SaaS Platform Credentials",
        "slot_types": ["PASSWORD", "API_KEY", "USERNAME", "URL", "EMAIL"],
        "primary_slot": "PASSWORD",
        "patterns": SAAS_CREDENTIALS_PATTERNS,
        "base_templates": [
            "Salesforce admin: {EMAIL} / {PASSWORD}",
            "Jira API token: {API_KEY}",
            "Slack bot token: {API_KEY}",
            "Datadog API key: {API_KEY}",
            "ServiceNow admin: {USERNAME} / {PASSWORD}",
        ]
    },
}


# ============================================================================
# ADVANCED TEMPLATE GENERATOR
# ============================================================================

@dataclass
class GeneratorConfig:
    """Configuration for template generation."""
    target_count: int = 100000
    max_count: int = 2000000
    include_case_variations: bool = True
    include_punctuation_variations: bool = True
    include_structural_variations: bool = True
    dedup_enabled: bool = True
    random_seed: Optional[int] = None


class AdvancedTemplateGenerator:
    """
    Generates massive numbers of unique templates through multiple strategies.
    """

    def __init__(self, domain: str, config: Optional[GeneratorConfig] = None):
        if domain not in DOMAIN_CONFIGS:
            raise ValueError(f"Unknown domain: {domain}")

        self.domain = domain
        self.domain_config = DOMAIN_CONFIGS[domain]
        self.config = config or GeneratorConfig()

        if self.config.random_seed is not None:
            random.seed(self.config.random_seed)

        self._seen_hashes: Set[str] = set()
        self._templates: List[str] = []

    def _hash(self, text: str) -> str:
        """Create hash for deduplication."""
        normalized = re.sub(r'\s+', ' ', text.lower().strip())
        return hashlib.md5(normalized.encode()).hexdigest()[:16]

    def _add_template(self, template: str) -> bool:
        """Add template if unique and well-formed. Returns True if added."""
        if not template or len(template) < 10:
            return False

        # Reject stacked formality prefixes (e.g. "Please please navigate")
        if self._has_stacked_formality(template):
            return False

        if self.config.dedup_enabled:
            h = self._hash(template)
            if h in self._seen_hashes:
                return False
            self._seen_hashes.add(h)

        self._templates.append(template)
        return True

    # Formality phrases that should never be stacked (lowercased for matching)
    _FORMALITY_PHRASES = (
        "please ", "kindly ", "we request that you ",
        "you are required to ", "you are requested to ",
        "you must ", "you should ",
        "we ask that you ", "it is required that you ",
        "for security purposes, ", "for your security, ",
        "important: ", "action required: ", "notice: ",
    )

    def _clean_template(self, template: str) -> str:
        """Clean up template formatting."""
        # Remove extra whitespace
        template = re.sub(r'\s+', ' ', template).strip()
        # Fix punctuation spacing
        template = re.sub(r'\s+([.,!?])', r'\1', template)
        template = re.sub(r'([.,!?])\s*([.,!?])', r'\1', template)
        # Fix double spaces after punctuation
        template = re.sub(r'([.,!?])\s{2,}', r'\1 ', template)
        return template

    # Verb-expecting prefixes: these only make sense before a verb/action
    _VERB_EXPECTING_PREFIXES = (
        "please ", "kindly ", "we request that you ",
        "you are required to ", "you are requested to ",
        "you must ", "you should ",
        "we ask that you ", "it is required that you ",
    )
    # Words that indicate a noun phrase (not a verb) follows
    _NON_VERB_STARTERS = (
        "the ", "a ", "an ", "your ", "our ", "their ", "its ",
        "this ", "that ", "these ", "those ",
    )
    # Regex: next word starts with uppercase = likely a proper noun, not a verb
    _PROPER_NOUN_RE = re.compile(r'^[A-Z][a-zA-Z]')

    def _has_stacked_formality(self, text: str) -> bool:
        """Detect garbled formality: doubled prefixes or verb-expecting prefix
        followed by an article/noun instead of a verb, anywhere in template."""
        tl = text.lower()
        # Check at start and after sentence boundaries (". ", "! ", "? ")
        positions = [0]
        for m in re.finditer(r'[.!?]\s+', tl):
            positions.append(m.end())
        for pos in positions:
            segment = tl[pos:]
            for prefix in self._FORMALITY_PHRASES:
                if segment.startswith(prefix):
                    rest = segment[len(prefix):]
                    # Reject stacked formality
                    if any(rest.startswith(p) for p in self._FORMALITY_PHRASES):
                        return True
            # Reject verb-expecting prefix + article/determiner or proper noun
            for prefix in self._VERB_EXPECTING_PREFIXES:
                if segment.startswith(prefix):
                    rest = segment[len(prefix):]
                    if any(rest.startswith(w) for w in self._NON_VERB_STARTERS):
                        return True
                    # Check against the ORIGINAL text (not lowered) for proper nouns
                    orig_rest = text[pos + len(prefix):]
                    if self._PROPER_NOUN_RE.match(orig_rest):
                        return True
        return False

    # -------------------------------------------------------------------------
    # Strategy 1: Base template expansion
    # -------------------------------------------------------------------------
    def _generate_from_base(self) -> int:
        """Generate from base templates with variations."""
        count = 0
        base_templates = self.domain_config.get("base_templates", [])

        for template in base_templates:
            if self._add_template(template):
                count += 1

        return count

    # -------------------------------------------------------------------------
    # Strategy 2: Pattern-based combinatorial expansion
    # -------------------------------------------------------------------------
    def _generate_from_patterns(self, max_per_pattern: int = 10000) -> int:
        """Generate templates from structural patterns."""
        count = 0
        patterns = self.domain_config.get("patterns", PASSWORD_RESET_PATTERNS)

        for pattern in patterns:
            generated = 0

            # Identify placeholders
            placeholders = re.findall(r'\{([A-Z_]+)\}', pattern)

            # Build variation lists for each placeholder type
            variations = self._get_placeholder_variations(placeholders)

            if not variations:
                if self._add_template(pattern):
                    count += 1
                continue

            # Generate combinations
            keys = list(variations.keys())
            value_lists = [variations[k] for k in keys]

            for combo in product(*value_lists):
                if generated >= max_per_pattern:
                    break

                result = pattern
                for key, value in zip(keys, combo):
                    # Replace placeholder with value
                    result = result.replace("{" + key + "}", value, 1)

                result = self._clean_template(result)
                if self._add_template(result):
                    count += 1
                    generated += 1

        return count

    def _get_placeholder_variations(self, placeholders: List[str]) -> Dict[str, List[str]]:
        """Get variations for each placeholder type."""
        variations = {}

        for ph in placeholders:
            if ph in ["PASSWORD", "URL", "API_KEY", "NAME", "SALARY", "DATE",
                      "SSN", "EMPLOYEE_ID", "EMAIL", "TOKEN", "SECRET",
                      "ACCESS_KEY", "SECRET_KEY", "SSH_KEY",
                      "ACCOUNT_ID", "ACCOUNT", "AMOUNT", "ROUTING",
                      "CLIENT_ID", "CLIENT_SECRET", "TENANT_ID",
                      "MRN", "CODE", "COMPANY", "DEPARTMENT",
                      "DOMAIN", "ARN", "PHONE", "ADDRESS",
                      "SSN_LAST4", "CARD_LAST4", "RATE", "YEAR", "QUARTER",
                      "DOSAGE", "MEDICATION"]:
                # These are slot placeholders - keep as is
                variations[ph] = ["{" + ph + "}"]

            elif ph == "PREFIX":
                variations[ph] = FORMALITY_PREFIXES[:15]

            elif ph == "VERB":
                all_verbs = []
                for verb_list in ACTION_VERBS.values():
                    all_verbs.extend(verb_list[:5])
                variations[ph] = list(set(all_verbs))[:20]

            elif ph in ["URL_TERM"]:
                all_terms = []
                for term_list in URL_TERMS.values():
                    all_terms.extend(term_list[:4])
                variations[ph] = list(set(all_terms))[:15]

            elif ph in ["PW_TERM"]:
                all_terms = []
                for term_list in PASSWORD_TERMS.values():
                    all_terms.extend(term_list[:4])
                variations[ph] = list(set(all_terms))[:15]

            elif ph == "ACTION":
                variations[ph] = RESET_ACTIONS[:15]

            elif ph == "IMMEDIACY":
                variations[ph] = IMMEDIACY_TERMS[:10]

            elif ph == "CLOSING":
                variations[ph] = CLOSING_PHRASES[:10]

            elif ph == "PW_CONTEXT":
                variations[ph] = PW_CONTEXT_PHRASES[:12]

            elif ph == "CONNECTOR":
                variations[ph] = CONNECTORS[:8]

            elif ph == "TIME":
                variations[ph] = TIME_CONSTRAINTS[:8]

            # HR-specific
            elif ph == "NAME_PREFIX":
                variations[ph] = ["Employee ", "Staff member ", "Team member ", ""]

            elif ph == "SALARY_ACTION":
                variations[ph] = ["salary adjusted", "compensation set", "pay increased",
                                  "earnings changed", "base salary set"]

            elif ph == "DATE_CTX":
                variations[ph] = ["effective", "starting", "as of", "beginning", "from"]

            # Infrastructure credential-specific
            elif ph == "SERVICE":
                variations[ph] = SERVICE_TERMS[:20]

            elif ph == "DBTYPE":
                variations[ph] = DBTYPE_TERMS[:15]

            elif ph == "USERNAME":
                variations[ph] = USERNAME_TERMS[:15]

            elif ph == "HOSTNAME":
                variations[ph] = HOSTNAME_TERMS[:12]

            elif ph == "INFRA_CONTEXT":
                variations[ph] = INFRA_CONTEXT_PHRASES[:10]

            elif ph == "CRED_JOIN":
                variations[ph] = CREDENTIAL_JOINERS[:10]

            elif ph == "DBNAME":
                variations[ph] = ["production", "staging", "main", "app", "mydb",
                                  "webapp", "core", "primary"]

            elif ph == "PORT":
                variations[ph] = ["5432", "3306", "27017", "6379", "1433",
                                  "3307", "5433", "8080", "443"]

            elif ph == "NUMBER":
                variations[ph] = ["12345", "67890", "11111", "99999", "54321"]

            # Cloud AWS
            elif ph == "AWS_SERVICE":
                variations[ph] = AWS_SERVICES[:12]
            elif ph == "AWS_REGION":
                variations[ph] = AWS_REGIONS

            # Cloud Azure
            elif ph == "AZURE_SERVICE":
                variations[ph] = AZURE_SERVICES[:10]
            elif ph == "AZURE_RESOURCE":
                variations[ph] = AZURE_RESOURCE_TYPES[:8]

            # Network/VPN
            elif ph == "VPN_TYPE":
                variations[ph] = VPN_TYPES[:8]
            elif ph == "WIFI_SEC":
                variations[ph] = WIFI_SECURITY
            elif ph == "NETWORK_DEVICE":
                variations[ph] = NETWORK_DEVICES[:8]

            # CI/CD
            elif ph == "CICD_PLATFORM":
                variations[ph] = CICD_PLATFORMS[:10]
            elif ph == "REGISTRY":
                variations[ph] = REGISTRY_TYPES[:8]

            # Email/SMTP
            elif ph == "SMTP_SVR":
                variations[ph] = SMTP_SERVERS[:8]
            elif ph == "EMAIL_PROTO":
                variations[ph] = EMAIL_PROTOCOLS

            # Financial
            elif ph == "BANK":
                variations[ph] = BANK_NAMES[:10]
            elif ph == "TRANSACTION":
                variations[ph] = TRANSACTION_TYPES[:6]

            # Legal
            elif ph == "LEGAL_TYPE":
                variations[ph] = LEGAL_TYPES[:10]
            elif ph == "LEGAL_PARTY":
                variations[ph] = LEGAL_PARTIES[:6]

            # Medical
            elif ph == "FACILITY":
                variations[ph] = MEDICAL_FACILITIES[:6]
            elif ph == "DIAGNOSIS_CODE":
                variations[ph] = DIAGNOSIS_CODES
            elif ph == "MEDICATION":
                variations[ph] = ["{MEDICATION}"]
            elif ph == "DOSAGE":
                variations[ph] = ["{DOSAGE}"]

            # Customer PII
            elif ph == "PII_DOC":
                variations[ph] = PII_DOCUMENT_TYPES[:6]

            # Internal Strategy
            elif ph == "MEETING":
                variations[ph] = MEETING_TYPES[:8]
            elif ph == "STRATEGY_ACTION":
                variations[ph] = STRATEGY_ACTIONS[:8]

            # Certificate/TLS
            elif ph == "CERT_TYPE":
                variations[ph] = CERT_TYPES[:8]
            elif ph == "CERT_FORMAT":
                variations[ph] = CERT_FORMATS

            # Encryption
            elif ph == "ENCRYPTION_TYPE":
                variations[ph] = ENCRYPTION_TYPES[:8]
            elif ph == "VAULT_PATH":
                variations[ph] = VAULT_PATHS

            # OAuth/SSO
            elif ph == "OAUTH_PROVIDER":
                variations[ph] = OAUTH_PROVIDERS[:8]

            # Vendor/Partner
            elif ph == "VENDOR":
                variations[ph] = VENDOR_NAMES[:8]

            # SaaS
            elif ph == "SAAS_PLATFORM":
                variations[ph] = SAAS_PLATFORMS[:12]

        return variations

    # -------------------------------------------------------------------------
    # Strategy 3: Linguistic variations
    # -------------------------------------------------------------------------
    def _generate_linguistic_variations(self, max_variations: int = 50000) -> int:
        """Generate variations through linguistic transformations."""
        count = 0
        existing = self._templates.copy()

        for template in existing:
            if count >= max_variations:
                break

            # Protect slot placeholders from synonym replacement:
            # Temporarily replace {SLOT} tokens with opaque markers,
            # do synonym substitution, then restore them.
            slot_map = {}
            protected = template
            for i, m in enumerate(re.finditer(r'\{[A-Z_]+\}', template)):
                marker = f"\x00SLOT{i}\x00"
                slot_map[marker] = m.group()
                protected = protected.replace(m.group(), marker, 1)

            # Synonym replacement for common terms
            # Words that should not be replaced when used as adjectives
            # (e.g. "reset password" — "reset" is an adjective here)
            _adj_nouns = r'(?:\s+(?:password|passcode|credential|code|key|token|access))'
            for original, replacements in self._get_synonym_map().items():
                for replacement in replacements[:5]:
                    # For words like "reset"/"default" that can be adj or verb,
                    # avoid replacing when directly before a noun
                    if original in ("reset", "default"):
                        pattern = r'\b' + re.escape(original) + r'\b(?!' + _adj_nouns + r')'
                    else:
                        pattern = r'\b' + re.escape(original) + r'\b'
                    variant = re.sub(
                        pattern,
                        replacement,
                        protected,
                        flags=re.IGNORECASE
                    )
                    if variant != protected:
                        # Restore slot placeholders
                        restored = variant
                        for marker, slot in slot_map.items():
                            restored = restored.replace(marker, slot)
                        restored = self._clean_template(restored)
                        if self._add_template(restored):
                            count += 1

            # Active/passive voice transformation (simplified)
            if "is set to" in template.lower():
                variant = template.replace("is set to", "has been set to")
                if self._add_template(variant):
                    count += 1

            if "must be" in template.lower():
                variant = template.replace("must be", "should be")
                if self._add_template(variant):
                    count += 1
                variant = template.replace("must be", "needs to be")
                if self._add_template(variant):
                    count += 1

        return count

    def _get_synonym_map(self) -> Dict[str, List[str]]:
        """Get synonym mapping for common terms."""
        base = {
            "password": ["passcode", "credential", "access code"],
            "navigate": ["go", "proceed", "head"],
            "visit": ["access", "open", "go to"],
            "click": ["select", "choose", "press"],
            "immediately": ["right away", "promptly", "at once"],
            "temporary": ["temp", "initial", "one-time"],
            "default": ["initial", "assigned", "generated"],
            "reset": ["change", "update", "modify"],
            "portal": ["site", "page", "website"],
            "login": ["sign in", "log in", "authenticate"],
        }

        if self.domain == "infrastructure_credentials":
            base.update({
                "server": ["host", "machine", "instance", "node"],
                "database": ["DB", "datastore", "data store"],
                "admin": ["administrator", "root", "superuser"],
                "credentials": ["login details", "access details", "auth details"],
                "username": ["user", "login", "account"],
                "production": ["prod", "live", "primary"],
                "connect": ["access", "log in", "authenticate"],
            })

        if self.domain in ("cloud_aws", "cloud_azure"):
            base.update({
                "credentials": ["creds", "access details", "auth details"],
                "secret": ["secret key", "private key", "auth secret"],
                "account": ["subscription", "project", "tenant"],
            })

        if self.domain in ("network_vpn",):
            base.update({
                "gateway": ["server", "endpoint", "concentrator"],
                "connect": ["log in", "authenticate", "access"],
                "password": ["passphrase", "PSK", "pre-shared key", "credential"],
            })

        if self.domain in ("ci_cd_devops",):
            base.update({
                "token": ["key", "secret", "credential", "PAT"],
                "deploy": ["release", "publish", "push"],
                "pipeline": ["workflow", "job", "build"],
            })

        if self.domain in ("financial_banking",):
            base.update({
                "transfer": ["payment", "wire", "remittance", "disbursement"],
                "account": ["acct", "deposit account", "bank account"],
            })

        if self.domain in ("medical_hipaa",):
            base.update({
                "patient": ["client", "member", "individual"],
                "diagnosis": ["condition", "finding", "assessment"],
                "prescription": ["medication", "Rx", "order"],
            })

        if self.domain in ("saas_credentials", "vendor_partner"):
            base.update({
                "token": ["API key", "secret", "auth token"],
                "login": ["sign in", "authenticate", "access"],
                "admin": ["administrator", "super admin", "owner"],
            })

        return base

    # -------------------------------------------------------------------------
    # Strategy 4: Structural transformations
    # -------------------------------------------------------------------------
    def _generate_structural_variations(self, max_variations: int = 30000) -> int:
        """Generate variations through structural transformations."""
        count = 0
        existing = self._templates.copy()

        for template in existing:
            if count >= max_variations:
                break

            # Sentence reordering
            sentences = re.split(r'(?<=[.!?])\s+', template)
            if len(sentences) >= 2:
                # Swap sentences
                for i in range(len(sentences) - 1):
                    reordered = sentences.copy()
                    reordered[i], reordered[i + 1] = reordered[i + 1], reordered[i]
                    variant = ' '.join(reordered)
                    variant = self._clean_template(variant)
                    if self._add_template(variant):
                        count += 1

            # Add/remove politeness prefixes
            # Known formality prefixes that should not be stacked
            _formality_starts = (
                "please ", "kindly ", "we request that you ",
                "you are required to ", "you must ", "you should ",
                "we ask that you ", "it is required that you ",
                "for security purposes, ", "for your security, ",
                "important: ", "action required: ", "notice: ",
            )
            for prefix in ["Please ", "Kindly ", ""]:
                if template.startswith("Please "):
                    body = template[7:]
                elif template.startswith("Kindly "):
                    body = template[7:]
                else:
                    if prefix:
                        # Don't try to lowercase — it corrupts proper nouns
                        # (Docker→docker, Slack→slack, etc.).  The stacked-
                        # formality filter already rejects "Please The..." etc.
                        body = template
                    else:
                        continue

                # Skip if adding a prefix on top of another formality phrase
                if prefix and body.lower().startswith(_formality_starts):
                    continue

                variant = prefix + body
                variant = self._clean_template(variant)
                if variant != template and self._add_template(variant):
                    count += 1

            # Punctuation variations
            if template.endswith('.'):
                if self._add_template(template[:-1] + '!'):
                    count += 1
            elif template.endswith('!'):
                if self._add_template(template[:-1] + '.'):
                    count += 1

        return count

    # -------------------------------------------------------------------------
    # Strategy 5: Contextual wrapping (email framing, urgency, clause insertion)
    # -------------------------------------------------------------------------
    # Domains where credential-change language makes sense
    _CREDENTIAL_DOMAINS = {
        "it_password", "infrastructure_credentials", "cloud_aws",
        "cloud_azure", "network_vpn", "ci_cd_devops", "email_smtp",
        "oauth_sso", "database_connection", "saas_credentials",
        "vendor_partner", "api_developer", "certificate_tls",
        "encryption_keys",
    }

    def _generate_contextual_wrapping(self, max_variations: int = 25000) -> int:
        """Generate variations by wrapping existing templates with contextual framing."""
        count = 0
        existing = self._templates.copy()

        # Skip env-var / connection-string style templates
        skip_prefixes = (
            "DB_HOST=", "DB_USER=", "DB_PASS=", "DATABASE_URL=",
            "AWS_ACCESS_KEY", "AZURE_TENANT", "AZURE_CLIENT",
            "SMTP_HOST=", "SMTP_PORT=", "SMTP_USER=", "SMTP_PASS=",
            "VAULT_TOKEN=", "VAULT_ADDR=", "DOCKER_USERNAME=",
            "DOCKER_PASSWORD=", "NPM_TOKEN=", "PYPI_TOKEN=",
            "SAAS_TOKEN=", "SAAS_URL=",
        )
        skip_patterns = (
            "jdbc:", "://{", "DSN:", "ODBC:", "Data Source=",
            "{USERNAME}:{PASSWORD}", "={", "Connection string:",
            "aws configure", "az login", "curl -H",
        )

        email_framings = [
            "Dear employee, ", "Hi team, ",
            "This is an automated notification. ", "FYI - ",
            "As discussed, ", "Per your request, ",
        ]
        urgency_suffixes = [
            " This must be completed within 24 hours.",
            " This is time-sensitive.",
            " Please action immediately.",
        ]
        # Only add "account lockout" suffix for credential domains
        if self.domain in self._CREDENTIAL_DOMAINS:
            urgency_suffixes.append(
                " Failure to comply may result in account lockout."
            )

        clause_insertions = [
            " which must be changed immediately",
            " which expires in 24 hours",
            " and must be updated on first login",
        ]
        # Clause insertions only make sense for credential/key domains
        use_clause_insertions = self.domain in self._CREDENTIAL_DOMAINS

        # Determine available transforms: always 0 (email) and 1 (urgency)
        available_transforms = [0, 1]
        if use_clause_insertions:
            available_transforms.append(2)

        random.shuffle(existing)

        for template in existing:
            if count >= max_variations:
                break

            # Skip env-var style templates
            if any(template.startswith(p) for p in skip_prefixes):
                continue
            if any(p in template for p in skip_patterns):
                continue

            transform = random.choice(available_transforms)

            if transform == 0:
                # Email framing
                prefix = random.choice(email_framings)
                # Don't try to lowercase — it corrupts proper nouns
                # (Docker→docker, Slack→slack, Settlement→settlement, etc.)
                variant = prefix + template
            elif transform == 1:
                # Urgency suffix
                suffix = random.choice(urgency_suffixes)
                if template.endswith('.'):
                    variant = template[:-1] + suffix
                elif template.endswith('!'):
                    variant = template[:-1] + suffix
                else:
                    variant = template + suffix
            else:
                # Clause insertion after first sentence
                sentences = re.split(r'(?<=[.!?])\s+', template, maxsplit=1)
                if len(sentences) >= 2:
                    clause = random.choice(clause_insertions)
                    first = sentences[0]
                    if first.endswith('.'):
                        first = first[:-1] + clause + '.'
                    elif first.endswith('!'):
                        first = first[:-1] + clause + '!'
                    else:
                        first = first + clause
                    variant = first + ' ' + sentences[1]
                else:
                    # Single sentence - append clause before final punctuation
                    clause = random.choice(clause_insertions)
                    if template.endswith('.'):
                        variant = template[:-1] + clause + '.'
                    elif template.endswith('!'):
                        variant = template[:-1] + clause + '!'
                    else:
                        variant = template + clause
            variant = self._clean_template(variant)
            if self._add_template(variant):
                count += 1

        return count

    # -------------------------------------------------------------------------
    # Strategy 6: Case variations
    # -------------------------------------------------------------------------
    def _generate_case_variations(self, max_variations: int = 20000) -> int:
        """Generate case variations."""
        if not self.config.include_case_variations:
            return 0

        count = 0
        existing = self._templates.copy()

        for template in existing:
            if count >= max_variations:
                break

            # Lowercase (preserve placeholders)
            def lowercase_preserve_placeholders(text):
                parts = re.split(r'(\{[A-Z_]+\})', text)
                return ''.join(
                    p if p.startswith('{') else p.lower()
                    for p in parts
                )

            variant = lowercase_preserve_placeholders(template)
            if self._add_template(variant):
                count += 1

            # Title case for sentences
            sentences = re.split(r'(?<=[.!?])\s+', template)
            titled = ' '.join(s.capitalize() if not s.startswith('{') else s for s in sentences)
            if self._add_template(titled):
                count += 1

        return count

    # -------------------------------------------------------------------------
    # Strategy 7: Randomized combination synthesis
    # -------------------------------------------------------------------------
    def _generate_random_combinations(self, target_remaining: int) -> int:
        """Generate random combinations by sampling patterns with random placeholder values."""
        count = 0
        patterns = self.domain_config.get("patterns", [])
        if not patterns:
            return 0

        attempts = 0
        max_attempts = target_remaining * 5

        while count < target_remaining and attempts < max_attempts:
            attempts += 1

            pattern = random.choice(patterns)
            placeholders = re.findall(r'\{([A-Z_]+)\}', pattern)
            variations = self._get_placeholder_variations(placeholders)

            if not variations:
                continue

            result = pattern
            for ph in placeholders:
                if ph in variations:
                    result = result.replace("{" + ph + "}", random.choice(variations[ph]), 1)

            result = self._clean_template(result)
            if len(result) >= 10 and self._add_template(result):
                count += 1

        return count

    # -------------------------------------------------------------------------
    # Main generation method
    # -------------------------------------------------------------------------
    def generate(self, count: Optional[int] = None) -> List[str]:
        """
        Generate templates using all strategies.

        Args:
            count: Target number of templates (default from config)

        Returns:
            List of unique template strings
        """
        target = count or self.config.target_count
        target = min(target, self.config.max_count)

        self._templates = []
        self._seen_hashes = set()

        print(f"\n[+] Generating templates for: {self.domain_config['name']}")
        print(f"    Target: {target:,}")

        # Strategy 1: Base templates
        n = self._generate_from_base()
        print(f"    Base templates: {n:,} (total: {len(self._templates):,})")

        # Strategy 2: Pattern-based
        if len(self._templates) < target:
            n = self._generate_from_patterns(max_per_pattern=max(1000, target // 20))
            print(f"    Pattern-based: {n:,} (total: {len(self._templates):,})")

        # Strategy 3: Linguistic variations
        if len(self._templates) < target:
            n = self._generate_linguistic_variations(max_variations=target // 3)
            print(f"    Linguistic variations: {n:,} (total: {len(self._templates):,})")

        # Strategy 4: Structural variations
        if len(self._templates) < target:
            n = self._generate_structural_variations(max_variations=target // 4)
            print(f"    Structural variations: {n:,} (total: {len(self._templates):,})")

        # Strategy 5: Contextual wrapping (email framing, urgency, clause insertion)
        if len(self._templates) < target:
            n = self._generate_contextual_wrapping(max_variations=target // 4)
            print(f"    Contextual wrapping: {n:,} (total: {len(self._templates):,})")

        # Strategy 6: Case variations
        if len(self._templates) < target:
            n = self._generate_case_variations(max_variations=target // 5)
            print(f"    Case variations: {n:,} (total: {len(self._templates):,})")

        # Strategy 7: Random synthesis to fill remaining
        if len(self._templates) < target:
            remaining = target - len(self._templates)
            n = self._generate_random_combinations(remaining)
            print(f"    Random synthesis: {n:,} (total: {len(self._templates):,})")

        print(f"\n    Final count: {len(self._templates):,}")

        # Shuffle so any prefix slice is representative of all strategies
        result = self._templates[:target]
        random.shuffle(result)
        return result

    def generate_for_chunk_position(
        self,
        position: str,
        count: int = 10000
    ) -> List[str]:
        """
        Generate templates optimized for specific chunk position.

        Args:
            position: "first", "middle", or "last"
            count: Number of templates to generate

        Returns:
            Templates weighted for the specified position
        """
        all_templates = self.generate(count * 2)

        # Filter/weight based on position
        weighted = []

        for template in all_templates:
            score = 1.0
            template_lower = template.lower()

            if position == "first":
                # First chunks often have greetings, intros
                if any(t in template_lower for t in ["please", "dear", "hello", "welcome"]):
                    score *= 1.3
                if any(t in template_lower for t in ["thank", "regards", "sincerely"]):
                    score *= 0.7

            elif position == "last":
                # Last chunks often have closings
                if any(t in template_lower for t in ["thank", "regards", "contact", "support"]):
                    score *= 1.3
                if any(t in template_lower for t in ["dear", "hello", "welcome"]):
                    score *= 0.7

            elif position == "middle":
                # Middle chunks are more neutral
                if any(t in template_lower for t in ["following", "below", "details"]):
                    score *= 1.2

            weighted.append((template, score))

        # Sort by score and return top
        weighted.sort(key=lambda x: x[1], reverse=True)
        return [t for t, _ in weighted[:count]]


# ============================================================================
# DOMAIN DETECTION (requires torch + transformers)
# ============================================================================

# Domain detection signatures -- representative phrases for each domain,
# used to classify target embeddings via cosine similarity.
DOMAIN_SIGNATURES = {
    "it_password": [
        "password reset portal login",
        "temporary password first login",
        "navigate to URL and click forgot password",
        "SSO portal access code credential",
        "reset your password at the login page",
        "default password after resetting must be changed immediately",
    ],
    "infrastructure_credentials": [
        "production database server admin username password",
        "server admin root credentials connection string",
        "database host port username password",
        "VPN gateway kubernetes cluster SSH key",
        "DB_HOST DB_USER DB_PASS connection",
        "default credentials for the server root password",
    ],
    "hr_employee": [
        "employee salary compensation annually effective",
        "SSN employee ID benefits enrollment",
        "personal info address phone emergency contact",
        "new hire starting salary date",
        "medical claim diagnosis HIPAA patient",
        "compensation package base salary bonus",
    ],
    "api_developer": [
        "API endpoint key bearer token authorization",
        "service URL API key authentication token",
        "production API auth secret key",
        "curl authorization bearer access token",
        "endpoint requires token refresh secret",
        "service account credentials API key",
    ],
    "cloud_aws": [
        "AWS access key secret key IAM credentials",
        "AWS account ID access key secret key region",
        "AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY environment",
        "S3 EC2 Lambda RDS IAM credentials production",
        "ARN IAM user access key secret us-east-1",
        "aws configure profile access key secret region",
    ],
    "cloud_azure": [
        "Azure tenant ID client ID client secret service principal",
        "AZURE_TENANT_ID AZURE_CLIENT_ID AZURE_CLIENT_SECRET",
        "Azure AD app registration client secret",
        "Azure Key Vault SAS token connection string",
        "Azure SQL Server password connection string",
        "az login service principal tenant client secret",
    ],
    "network_vpn": [
        "VPN gateway username password OpenVPN WireGuard",
        "WiFi network WPA2 password passphrase SSID",
        "firewall admin console management credentials",
        "IPSec pre-shared key tunnel gateway VPN",
        "RADIUS shared secret network access control",
        "SNMP community string router switch firewall",
    ],
    "ci_cd_devops": [
        "GitHub personal access token Jenkins pipeline",
        "Docker registry login username password push",
        "CI CD pipeline secret token deploy key",
        "Terraform Cloud API token Ansible vault password",
        "NPM_TOKEN PYPI_TOKEN package registry auth",
        "GitLab CI runner token deploy key webhook secret",
    ],
    "email_smtp": [
        "SMTP server port username password outgoing mail",
        "SMTP_HOST SMTP_PORT SMTP_USER SMTP_PASS",
        "SendGrid Mailgun API key email service",
        "Office 365 SMTP email password app password",
        "IMAP POP3 Exchange mailbox credentials login",
        "email relay server authentication password",
    ],
    "financial_banking": [
        "wire transfer ACH routing number account number bank",
        "bank account routing number direct deposit payment",
        "SWIFT code beneficiary account amount transfer",
        "invoice payment amount payable account bank",
        "payroll direct deposit routing account salary",
        "treasury disbursement wire transfer amount account",
    ],
    "legal_confidential": [
        "NDA settlement agreement confidential amount signed",
        "acquisition merger valuation closing date agreement",
        "non-disclosure settlement confidential legal agreement",
        "board approved acquire company valuation amount",
        "termination agreement severance amount effective date",
        "pending litigation reserve settlement confidential",
    ],
    "medical_hipaa": [
        "patient name MRN medical record number diagnosis",
        "HIPAA patient SSN medical record prescription",
        "ICD-10 CPT diagnosis code patient admission",
        "discharge summary patient MRN admitted diagnosis",
        "prescription medication dosage patient doctor",
        "lab results radiology patient record department",
    ],
    "customer_pii": [
        "customer SSN social security number date of birth",
        "account holder name address phone email credit card",
        "KYC identity verification SSN DOB address",
        "member profile email phone address subscriber",
        "credit card number expiration billing address name",
        "customer data export name email phone address PII",
    ],
    "internal_strategy": [
        "board meeting approved acquisition valuation confidential",
        "quarterly revenue earnings not yet public embargo",
        "M&A pipeline target company valuation LOI",
        "restructuring headcount layoff savings effective date",
        "insider information patent settlement announce date",
        "executive compensation CEO total comp board approved",
    ],
    "certificate_tls": [
        "SSL TLS certificate private key passphrase domain",
        "wildcard certificate PKCS12 PEM key password",
        "JKS keystore password certificate signing key",
        "root CA intermediate certificate private key passphrase",
        "code signing certificate key password expiration",
        "Let's Encrypt certificate account key PFX export",
    ],
    "encryption_keys": [
        "HashiCorp Vault token root unseal key secret",
        "KMS master key encryption AES-256 RSA GPG",
        "VAULT_TOKEN VAULT_ADDR secret data production",
        "GPG PGP passphrase encryption key signing",
        "SOPS age sealed secrets encryption key",
        "LUKS BitLocker disk encryption passphrase volume",
    ],
    "oauth_sso": [
        "OAuth client ID client secret OIDC SSO",
        "Okta Auth0 Azure AD SSO SAML configuration",
        "OIDC discovery well-known client secret redirect",
        "JWT signing key SAML IdP metadata certificate",
        "SCIM provisioning token SSO admin API",
        "OAuth2 authorization code client credentials grant secret",
    ],
    "database_connection": [
        "jdbc connection string host port database user password",
        "DATABASE_URL postgresql mysql mongodb connection string",
        "DSN data source host port dbname user password",
        "connection string server database user ID password",
        "ODBC driver server port database uid pwd connection",
        "read replica connection pooler pgbouncer credentials",
    ],
    "vendor_partner": [
        "vendor API key endpoint third party integration",
        "partner portal login credentials username password",
        "vendor SFTP host username password file transfer",
        "third party service webhook signing secret",
        "partner API client ID secret OAuth integration",
        "vendor sandbox production key rate limit endpoint",
    ],
    "saas_credentials": [
        "Salesforce Jira Slack admin login password API",
        "SaaS platform API token workspace integration",
        "ServiceNow Workday Datadog admin credentials",
        "Slack bot token Jira API key Confluence",
        "GitHub Enterprise Bitbucket service account password",
        "SaaS OAuth app client ID secret webhook token",
    ],
}

# Human-readable descriptions
DOMAIN_DESCRIPTIONS = {
    "it_password":                "IT/Password Reset — login portals, password reset emails, SSO",
    "infrastructure_credentials": "Infrastructure — server/DB admin creds, connection strings, hostnames",
    "hr_employee":                "HR/Employee Records — salaries, SSN, benefits, personnel files",
    "api_developer":              "API/Developer — API keys, bearer tokens, service endpoints",
    "cloud_aws":                  "Cloud/AWS — access keys, secret keys, IAM, S3, EC2, Lambda",
    "cloud_azure":                "Cloud/Azure — tenant/client IDs, service principals, Key Vault",
    "network_vpn":                "Network/VPN — VPN gateways, WiFi passwords, firewall admin, SNMP",
    "ci_cd_devops":               "CI/CD DevOps — GitHub tokens, Docker registry, Jenkins, deploy keys",
    "email_smtp":                 "Email/SMTP — mail server credentials, SendGrid/Mailgun API keys",
    "financial_banking":          "Financial/Banking — wire transfers, routing/account numbers, SWIFT",
    "legal_confidential":         "Legal/Confidential — NDAs, settlements, M&A, acquisition terms",
    "medical_hipaa":              "Medical/HIPAA — patient records, MRN, diagnoses, prescriptions",
    "customer_pii":               "Customer PII — SSN, credit cards, addresses, KYC data",
    "internal_strategy":          "Internal Strategy — board minutes, M&A pipeline, earnings, layoffs",
    "certificate_tls":            "Certificate/TLS — SSL private key passphrases, JKS, PKCS12",
    "encryption_keys":            "Encryption/Vault — Vault tokens, KMS keys, GPG passphrases, SOPS",
    "oauth_sso":                  "OAuth/SSO — client secrets, OIDC, SAML, JWT signing keys",
    "database_connection":        "Database Connections — JDBC/DSN strings, DATABASE_URL, ODBC",
    "vendor_partner":             "Vendor/Partner — third-party API keys, partner portal creds, SFTP",
    "saas_credentials":           "SaaS Credentials — Salesforce, Jira, Slack, Datadog, ServiceNow",
}


def detect_domain(embeddings: np.ndarray, chunk_idx: int = 0,
                  verbose: bool = True) -> tuple:
    """
    Detect the most likely domain for the given embedding chunk.

    Requires: pip install torch transformers

    Returns (best_domain, scores_dict).
    """
    import torch
    from transformers import AutoModel, AutoTokenizer

    model_name = "sentence-transformers/all-MiniLM-L6-v2"

    if torch.cuda.is_available():
        device = "cuda"
    elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
        device = "mps"
    else:
        device = "cpu"

    if verbose:
        print(f"[Detect] Loading {model_name} on {device}")

    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModel.from_pretrained(model_name).to(device)
    model.eval()

    def embed(text):
        inputs = tokenizer(text, return_tensors="pt",
                           padding=True, truncation=True, max_length=512).to(device)
        with torch.no_grad():
            outputs = model(**inputs)
            tok = outputs.last_hidden_state
            mask = inputs['attention_mask'].unsqueeze(-1).expand(tok.size()).float()
            return (torch.sum(tok * mask, 1) / torch.clamp(mask.sum(1), min=1e-9)).squeeze()

    # Target embedding
    target_emb = torch.tensor(embeddings[chunk_idx], dtype=torch.float32).to(device)

    # Score each domain
    scores = {}
    for domain, phrases in DOMAIN_SIGNATURES.items():
        # Embed each phrase, average the similarities
        sims = []
        for phrase in phrases:
            sig_emb = embed(phrase)
            sim = torch.nn.functional.cosine_similarity(
                target_emb.unsqueeze(0), sig_emb.unsqueeze(0)
            ).item()
            sims.append(sim)
        scores[domain] = sum(sims) / len(sims)

    best = max(scores, key=scores.get)

    if verbose:
        print(f"[Detect] Chunk {chunk_idx} domain scores:")
        for domain, score in sorted(scores.items(), key=lambda x: x[1], reverse=True):
            marker = " <--" if domain == best else ""
            desc = DOMAIN_DESCRIPTIONS.get(domain, "")
            print(f"    {score:.4f}  {domain:30s} {desc}{marker}")

    return best, scores


def detect_domain_majority(embeddings: np.ndarray, chunk_indices: list,
                           verbose: bool = True) -> tuple:
    """Detect domain using majority vote across multiple chunks."""
    votes = []
    all_scores = {}

    for idx in chunk_indices:
        if idx >= len(embeddings):
            continue
        domain, scores = detect_domain(embeddings, idx, verbose=False)
        votes.append(domain)
        for d, s in scores.items():
            if d not in all_scores:
                all_scores[d] = []
            all_scores[d].append(s)

    # Average scores across chunks
    avg_scores = {d: sum(s) / len(s) for d, s in all_scores.items()}
    majority = Counter(votes).most_common(1)[0][0]

    if verbose:
        print(f"[Detect] Majority vote across {len(votes)} chunk(s):")
        for domain, score in sorted(avg_scores.items(), key=lambda x: x[1], reverse=True):
            count = votes.count(domain)
            marker = " <--" if domain == majority else ""
            print(f"    {score:.4f}  {domain:30s} ({count}/{len(votes)} votes){marker}")

    return majority, avg_scores


# ============================================================================
# CLI
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Standalone template generator with auto-domain detection',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Available domains (20):
  it_password                 IT/Password Reset (URLs, passwords, login portals)
  infrastructure_credentials  Infrastructure (server/DB admin creds, hostnames)
  hr_employee                 HR/Employee Records (salaries, SSN, benefits)
  api_developer               API/Developer (API keys, bearer tokens, endpoints)
  cloud_aws                   Cloud/AWS (access keys, IAM, S3, EC2)
  cloud_azure                 Cloud/Azure (tenant/client IDs, service principals)
  network_vpn                 Network/VPN (VPN gateways, WiFi, firewall, SNMP)
  ci_cd_devops                CI/CD DevOps (GitHub tokens, Docker, Jenkins)
  email_smtp                  Email/SMTP (mail server creds, SendGrid, Mailgun)
  financial_banking           Financial/Banking (wire transfers, routing numbers)
  legal_confidential          Legal/Confidential (NDAs, settlements, M&A)
  medical_hipaa               Medical/HIPAA (patient records, MRN, diagnoses)
  customer_pii                Customer PII (SSN, credit cards, KYC)
  internal_strategy           Internal Strategy (board minutes, M&A, earnings)
  certificate_tls             Certificate/TLS (SSL key passphrases, JKS, PKCS12)
  encryption_keys             Encryption/Vault (Vault tokens, KMS, GPG)
  oauth_sso                   OAuth/SSO (client secrets, OIDC, SAML, JWT)
  database_connection         Database Connections (JDBC, DSN, DATABASE_URL)
  vendor_partner              Vendor/Partner (third-party API keys, SFTP)
  saas_credentials            SaaS Credentials (Salesforce, Jira, Slack, etc.)

Examples:
  # Auto-detect domain and generate templates
  python generate_templates.py embeddings2.npy -o templates.json

  # Auto-detect from specific chunk
  python generate_templates.py embeddings2.npy --chunk 3 -o templates.json

  # Majority vote across first 5 chunks
  python generate_templates.py embeddings2.npy --chunks 0,1,2,3,4 -o templates.json

  # Skip detection, specify domain
  python generate_templates.py --domain infrastructure_credentials -o templates.json

  # Generate for specific chunk position
  python generate_templates.py --domain it_password --chunk-position first -o templates.json

  # Custom count
  python generate_templates.py embeddings2.npy --count 500000 -o templates.json

  # List domains and exit
  python generate_templates.py --list-domains
        """
    )

    parser.add_argument('embeddings_file', nargs='?', default=None,
                        help='Path to embeddings.npy (required for auto-detection)')

    # Domain selection
    parser.add_argument('--domain', type=str, default=None,
                        help='Override auto-detection with this domain')
    parser.add_argument('--list-domains', action='store_true',
                        help='List available domains and exit')

    # Chunk selection for detection
    parser.add_argument('--chunk', type=int, default=None,
                        help='Detect domain from this chunk (default: 0)')
    parser.add_argument('--chunks', type=str, default=None,
                        help='Majority vote across these chunks (comma-separated)')

    # Generation
    parser.add_argument('--count', type=int, default=100000,
                        help='Number of templates to generate (default: 100000)')
    parser.add_argument('--seed', type=int, default=None,
                        help='Random seed for reproducibility')
    parser.add_argument('--chunk-position', type=str, default=None,
                        choices=['first', 'middle', 'last'],
                        help='Generate templates for specific chunk position')

    # Output
    parser.add_argument('--output', '-o', type=str, default=None,
                        help='Output JSON file')
    parser.add_argument('--sample', type=int, default=20,
                        help='Number of sample templates to display (default: 20)')
    parser.add_argument('--quiet', '-q', action='store_true')

    args = parser.parse_args()

    # --list-domains
    if args.list_domains:
        print("\nAvailable domains (20):\n")
        for domain, desc in DOMAIN_DESCRIPTIONS.items():
            print(f"  {domain:30s} {desc}")
        print()
        sys.exit(0)

    # Determine domain
    domain = args.domain

    if domain is None:
        # Auto-detect from embeddings
        if args.embeddings_file is None:
            parser.error("embeddings_file is required for auto-detection "
                         "(or use --domain to specify manually)")

        print(f"\n[+] Loading: {args.embeddings_file}")
        embeddings = np.load(args.embeddings_file)
        if len(embeddings.shape) == 1:
            embeddings = embeddings.reshape(1, -1)
        print(f"    Shape: {embeddings.shape}")

        if args.chunks:
            chunk_indices = [int(c.strip()) for c in args.chunks.split(',')]
            domain, scores = detect_domain_majority(
                embeddings, chunk_indices, verbose=not args.quiet
            )
        else:
            chunk_idx = args.chunk if args.chunk is not None else 0
            domain, scores = detect_domain(
                embeddings, chunk_idx, verbose=not args.quiet
            )

        print(f"\n[+] Detected domain: {domain}")
        print(f"    ({DOMAIN_DESCRIPTIONS.get(domain, '')})")

    else:
        if domain not in DOMAIN_CONFIGS:
            print(f"[!] ERROR: Unknown domain '{domain}'")
            print(f"    Available: {', '.join(sorted(DOMAIN_CONFIGS.keys()))}")
            sys.exit(1)
        print(f"\n[+] Using domain: {domain}")
        print(f"    ({DOMAIN_DESCRIPTIONS.get(domain, '')})")

    # Generate templates
    print(f"\n[+] Generating {args.count:,} templates...")

    config = GeneratorConfig(
        target_count=args.count,
        random_seed=args.seed,
    )

    generator = AdvancedTemplateGenerator(domain, config)

    if args.chunk_position:
        templates = generator.generate_for_chunk_position(args.chunk_position, args.count)
    else:
        templates = generator.generate(args.count)

    print(f"\n[+] Generated {len(templates):,} unique templates")

    # Show samples
    print(f"\nSample templates ({min(args.sample, len(templates))}):")
    for t in random.sample(templates, min(args.sample, len(templates))):
        print(f"  {t[:120]}{'...' if len(t) > 120 else ''}")

    # Save
    if args.output:
        output_data = {
            "domain": domain,
            "count": len(templates),
            "chunk_position": args.chunk_position,
            "templates": templates,
        }
        with open(args.output, 'w') as f:
            json.dump(output_data, f, indent=2)
        print(f"\n[+] Saved to: {args.output}")
    else:
        print("\n[!] No --output specified, templates not saved")
        print("    Use -o templates.json to save")


if __name__ == "__main__":
    main()
```