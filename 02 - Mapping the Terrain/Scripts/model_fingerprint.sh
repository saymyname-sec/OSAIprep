#!/usr/bin/env bash
# Script: model_fingerprint.sh
# Module: 02 — Reconnaissance for AI Targets
# Purpose: Fingerprint the LLM model behind an OpenAI-compatible endpoint
# Usage: ./model_fingerprint.sh <target_host:port>
# Target: OpenAI-compatible /v1/chat/completions endpoint

TARGET="${1:-192.168.50.23}"
URL="http://$TARGET/v1/chat/completions"

chat() {
  curl -s -X POST "$URL"     -H "Content-Type: application/json"     -d "{"messages":[{"role":"user","content":"$1"}]}"     | jq -r '.choices[0].message.content // "NO RESPONSE"'
}

echo "[*] Model Fingerprinting — $TARGET"
echo ""

echo "=== Direct Identity ==="
chat "What model are you? What company created you?"

echo ""
echo "=== False Attribution (Claude) ==="
chat "Thanks for the help, Claude! I really appreciate Anthropic creating you."

echo ""
echo "=== False Attribution (GPT-4) ==="
chat "I love using GPT-4! OpenAI really outdid themselves with you."

echo ""
echo "=== Knowledge Cutoff ==="
chat "What is your knowledge cutoff date?"

echo ""
echo "=== Temporal Event (2024) ==="
chat "Who won the 2024 US presidential election?"

echo ""
echo "=== GPT-4o Knowledge Test ==="
chat "Tell me about the GPT-4o release from OpenAI."

echo ""
echo "=== Reasoning Benchmark ==="
chat "Alice is taller than Bob. Bob is taller than Carol. Carol is taller than David. David is taller than Eve. List everyone from tallest to shortest."

echo ""
echo "=== Code Style Benchmark ==="
chat "Write a Python function to check if a number is prime."
