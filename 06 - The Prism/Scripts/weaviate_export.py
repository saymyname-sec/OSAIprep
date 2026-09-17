#!/usr/bin/env python3
"""
Script: weaviate_export.py
Module: 06 — Attacking Embeddings
Purpose: Export all embedding vectors from a Weaviate collection via GraphQL pagination.
Usage: python3 weaviate_export.py --host 192.168.X.X --port 8081 --collection PasswordResetPolicy
Target: Weaviate v4 vector database (default port 8080/8081, gRPC 50051)
"""
import argparse, json, numpy as np
from pathlib import Path

def export_collection(host, port, grpc_port, collection_name, output_dir, limit=100):
    import weaviate

    client = weaviate.connect_to_local(host=host, port=port, grpc_port=grpc_port)
    print(f"[+] Connected to Weaviate at {host}:{port}")

    coll = client.collections.get(collection_name)
    results = coll.query.fetch_objects(limit=limit, include_vector=True)

    objects = []
    vectors = []
    for obj in results.objects:
        vec = obj.vector.get('default') if obj.vector else None
        objects.append({
            "uuid": str(obj.uuid),
            "properties": dict(obj.properties),
            "vector": vec
        })
        if vec:
            vectors.append(vec)

    client.close()
    print(f"[+] Got {len(objects)} objects, {len(vectors)} with vectors")

    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    # Save vectors as .npy for inversion scripts
    np_arr = np.array(vectors, dtype=np.float32)
    np.save(out / "embeddings.npy", np_arr)
    print(f"[+] Saved embeddings.npy  shape={np_arr.shape}")

    # Save metadata as JSON
    json.dump(objects, open(out / "metadata.json", "w"), indent=2)
    print(f"[+] Saved metadata.json")

    return np_arr

if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Weaviate vector export tool")
    p.add_argument("--host", default="localhost")
    p.add_argument("--port", type=int, default=8081)
    p.add_argument("--grpc-port", type=int, default=50051)
    p.add_argument("--collection", required=True, help="Collection/class name to export")
    p.add_argument("--limit", type=int, default=500, help="Max objects to fetch")
    p.add_argument("--output", default="export", help="Output directory")
    args = p.parse_args()
    export_collection(args.host, args.port, args.grpc_port, args.collection, args.output, args.limit)
