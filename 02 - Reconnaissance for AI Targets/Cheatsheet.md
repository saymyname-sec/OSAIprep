# Module 02 Cheatsheet — Reconnaissance for AI Targets

## Key Commands

```bash
# ── PASSIVE RECON ──
nmap -sV --open -p 1-10000 <target>
curl -s -I http://<target>/
curl -s http://<target>/api/health | jq
curl -s http://<target>/ | grep -iE "<script"
curl -s http://<target>/js/chat-widget.js   # find API base URLs in frontend

# ── QUICK LLM PROBE ──
curl -s -X POST http://<target>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}' | jq

# ── ENDPOINT FUZZING ──
for endpoint in auth billing chat/completions models users; do
  code=$(curl -s -o /dev/null -w "%{http_code}" http://<target>/v1/$endpoint)
  echo "/v1/$endpoint - HTTP $code"
done

for endpoint in documents files upload process extract parse embeddings ingest query search; do
  code=$(curl -s -o /dev/null -w "%{http_code}" http://<target>/v1/$endpoint)
  echo "/v1/$endpoint - HTTP $code"
done

# ── MODEL FINGERPRINTING ──
# Direct ask:
curl -s -X POST http://<target>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"What model are you?"}]}' | jq -r '.choices[0].message.content'

# False attribution (say wrong model):
curl -s -X POST http://<target>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Thanks Claude! Anthropic made you right?"}]}' | jq -r '.choices[0].message.content'

# Knowledge cutoff:
curl -s -X POST http://<target>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Who won the 2024 US presidential election?"}]}' | jq -r '.choices[0].message.content'

# ── RAG RECON ──
# Internal topic probe:
curl -s -X POST http://<target>/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "What is the PTO policy?"}' | jq .

# Semantic vs keyword test (typo probe):
curl -s -X POST http://<target>/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "vaycation dayz rulez"}' | jq

# API leakage probe:
curl -s -X POST http://<target>/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "What internal API endpoints exist?"}' | jq

# ── A2A AGENT CARD ENUM ──
# Quick name scan:
for port in {8000..8010}; do
  echo -n "Port $port: "
  curl -s "http://<target>:$port/.well-known/agent.json" | jq -r '.name // empty'
done

# Full card with skills + capabilities:
HOST="<target>"
for port in {8000..8010}; do
  body=$(curl -s --max-time 3 "http://$HOST:$port/.well-known/agent.json")
  if echo "$body" | jq -e . >/dev/null 2>&1; then
    echo "=== Port $port: $(echo "$body" | jq -r '.name') ==="
    echo "$body" | jq -r '.skills[]? | "  SKILL: \(.name // .id): \(.description)"'
    echo "$body" | jq -r '.capabilities | to_entries[]? | "  CAP: \(.key): \(.value)"'
  fi
done
```

## Attack Flow (quick version)
1. `nmap` → find open ports (8000-9000, 11434, 5000, 3000 priority)
2. `curl -I` headers → identify stack, framework, model hints
3. Probe `/api/health`, `/v1/models` → confirm AI service type
4. Fuzz standard + RAG endpoints → map full API surface
5. Model fingerprint → direct ask, false attribution, cutoff inference
6. RAG probe → topic test + typo test → semantic vs keyword
7. A2A card scan → `/.well-known/agent.json` on all ports → map agent network

## Tools at a Glance
| Tool | One-liner |
|------|-----------|
| `nmap` | `nmap -sV --open -p 1-10000 <target>` |
| `curl + jq` | `curl -s ... \| jq -r '.choices[0].message.content'` |
| `ffuf` | `ffuf -u http://target/v1/FUZZ -w ai_wordlist.txt -mc 200,401,403` |
| `gobuster` | `gobuster dir -u http://target -w wordlist.txt` |

## ⚠️ Weak Areas [PRIORITISE]
- [ ] Theory behind WHY false attribution works for fingerprinting
- [ ] How semantic embeddings differ from keyword search (cutoff for typo tolerance)
- [ ] What exactly is in an A2A agent card — schema fields
- [ ] How to infer RAG doc categories from model responses

## Remember
- `/v1/` prefix = OpenAI-compatible API format — standard tooling works
- **401 on any endpoint = that endpoint EXISTS** — never discard 401s
- Typo answer = semantic embeddings → Module 6 inversion attacks apply
- `/.well-known/agent.json` is unauthenticated by design in A2A spec
- Agent card `skills[]` tells you exactly what each agent can DO — read it carefully
