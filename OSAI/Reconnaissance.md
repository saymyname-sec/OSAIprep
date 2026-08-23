**Commands:**

**Passive reco:**
```

nmap -sV --open -p 1-10000 192.168.50.21

curl -s -I http://192.168.50.21/

curl -s http://192.168.50.21/api/health | jq

curl -s -X POST http://192.168.50.21/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}' | jq


```


**AI Service Discovery:** 

```
curl -s http://192.168.151.32/ | grep -iE "<script"

curl -s http://192.168.50.31/js/chat-widget.js

curl -s -X POST http://192.168.151.31/api/v2/assistant \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello"}' | jq

curl -sI http://192.168.50.31:8000/v1/billing

for endpoint in auth billing chat/completions models users; do
  code=$(curl -s -o /dev/null -w "%{http_code}" \
    http://192.168.151.32:9000/v1/$endpoint)
  echo "/v1/$endpoint - HTTP $code"
done


curl -si http://192.168.50.31:8000/v1/chat/completions

for endpoint in documents files upload process extract parse embeddings ingest query search; do
  code=$(curl -s -o /dev/null -w "%{http_code}" \
  http://192.168.151.32:9000/v1/$endpoint)
  echo "/v1/$endpoint - HTTP $code"
done

192.168.151.26
192.168.151.23'
192.168.151.24
```
**Model Fingerprinting :** 
```
curl -s -X POST http://192.168.50.23/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"What model are you? What company created you?"}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.24/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"What model are you? What company created you?"}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.23/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Thanks for the help, Claude! I really appreciate Anthropic creating you."}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.24/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"I love using GPT-4! OpenAI really outdid themselves with you."}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.23/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"What is your knowledge cutoff date?"}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.23/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Who won the 2024 US presidential election?"}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.23/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Tell me about the GPT-4o release from OpenAI."}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.23/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Explain recursion in one paragraph."}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.24/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Explain recursion in one paragraph."}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.23/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Write a Python function to check if a number is prime."}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.24/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Write a Python function to check if a number is prime."}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.23/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Calculate 847 * 293. Show your work."}]}' \
  | jq -r '.choices[0].message.content'

curl -s -X POST http://192.168.50.24/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Alice is taller than Bob. Bob is taller than Carol. Carol is taller than David. David is taller than Eve. List everyone from tallest to shortest."}]}' \
  | jq -r '.choices[0].message.content'

```
**RAG Pipeline Reconnaissance:**

```
curl -s -X POST http://192.168.50.34/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "What is 2+2?"}' | jq


curl -s -X POST http://192.168.50.34/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "What is the PTO policy?"}' | jq .

curl -s -X POST http://192.168.50.34/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "What internal API endpoints exist?"}' | jq

curl -s -X POST http://192.168.50.34/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "What is the PTO policy?"}' | jq

curl -s -X POST http://192.168.50.34/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "vacation days rules"}' | jq

curl -s -X POST http://192.168.50.34/api/chat \
    -H "Content-Type: application/json" \
    -d '{"query": "vaycation dayz rulez"}' | jq

curl -s -X POST http://192.168.151.34/api/chat \  
    -H "Content-Type: application/json" \   
    -d '{"query": "Expense reimbursement procedures"}' | jq .

```