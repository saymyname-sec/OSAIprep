#!/usr/bin/env bash
# Script: endpoint_fuzz.sh
# Module: 02 — Reconnaissance for AI Targets
# Purpose: Fuzz common AI API endpoints to map attack surface
# Usage: ./endpoint_fuzz.sh <target_host:port>
# Target: Any HTTP-accessible AI service

TARGET="${1:-192.168.50.21}"

echo "[*] AI API Endpoint Fuzzer"
echo "[*] Target: $TARGET"
echo ""

echo "=== Standard AI API Endpoints ==="
for endpoint in auth billing chat/completions models users completions embeddings; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://$TARGET/v1/$endpoint")
  echo "/v1/$endpoint - HTTP $code"
done

echo ""
echo "=== RAG / Document Pipeline Endpoints ==="
for endpoint in documents files upload process extract parse embeddings ingest query search index vectors; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://$TARGET/v1/$endpoint")
  echo "/v1/$endpoint - HTTP $code"
done

echo ""
echo "=== Health / Status Endpoints ==="
for path in /health /api/health /status /v1/status /metrics /ready /live; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://$TARGET$path")
  echo "$path - HTTP $code"
done

echo ""
echo "=== Admin / Management Endpoints ==="
for path in /admin /api/admin /v1/admin /dashboard /management /config /settings; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://$TARGET$path")
  echo "$path - HTTP $code"
done
