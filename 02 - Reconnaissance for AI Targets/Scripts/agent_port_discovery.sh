for port in 8000 8001 8002 8003 8004 8005 8006 8007 8008 8009 8010; do
  echo "=== Port $port ==="
  curl -s "http://192.168.50.25:$port/.well-known/agent.json" 2>/dev/null | \
    jq -r '.paths | keys[]' 2>/dev/null || echo "No OpenAPI found"
done

OR
# SHOWS A LOT
for port in {8000..8010}; do
  echo "=== Port $port ==="
  resp=$(curl -s -w '\n%{http_code}' "http://192.168.214.25:$port/.well-known/agent.json")
  code=$(echo "$resp" | tail -n1)
  body=$(echo "$resp" | sed '$d')
  echo "HTTP: $code"
  echo "$body" | jq . 2>/dev/null || echo "Not valid JSON"
done

OR
#SHOW ONLY NAME OF AI :
for port in {8000..8010}; do
  echo -n "Port $port: "
  curl -s "http://192.168.214.25:$port/.well-known/agent.json" \
    | jq -r '.name // empty'
done

OR
#Show only the skill Ids
for port in {8000..8010}; do
  echo "=== Port $port ==="
  curl -s "http://192.168.214.25:$port/.well-known/agent.json" \
    | jq -r '.skills[]?.id'
done

OR
#Shows Description Skills and ID's
HOST="192.168.214.25"
PATH_CARD="/.well-known/agent.json"

for port in {8000..8010}; do
  url="http://$HOST:$port$PATH_CARD"
  body=$(curl -s --max-time 3 "$url")

  if echo "$body" | jq -e . >/dev/null 2>&1; then
    name=$(echo "$body" | jq -r '.name // "N/A"')
    desc=$(echo "$body" | jq -r '.description // "N/A"')

    echo "=== Port $port ==="
    echo "Name: $name"
    echo "Description: $desc"
    echo "Skills:"

    echo "$body" | jq -r '.skills[]? | "- \(.name // .id // "unknown"): \(.description // "no description")"'

    echo
  fi
done

OR
#WITH CAPABILITIES AND ALL 

#!/usr/bin/env bash

HOST="192.168.214.25"
PATH_CARD="/.well-known/agent.json"

for port in {8000..8010}; do
  url="http://$HOST:$port$PATH_CARD"
  body=$(curl -s --max-time 3 "$url")

  if echo "$body" | jq -e . >/dev/null 2>&1; then
    name=$(echo "$body" | jq -r '.name // "N/A"')
    desc=$(echo "$body" | jq -r '.description // "N/A"')

    echo "=== Port $port ==="
    echo "Name: $name"
    echo "Description: $desc"

    echo "Skills:"
    echo "$body" | jq -r '
      if (.skills | type) == "array" then
        .skills[] |
        "- \(.name // .id // "unknown"): \(.description // "no description")"
      else
        "- None found"
      end
    '

    echo "Capabilities:"
    echo "$body" | jq -r '
      if (.capabilities | type) == "object" then
        .capabilities | to_entries[] |
        "- \(.key): \(.value)"
      elif (.capabilities | type) == "array" then
        .capabilities[] |
        if type == "object" then
          "- \(.name // .id // "unknown"): \(.description // "no description")"
        else
          "- \(.)"
        end
      elif (.capabilities | type) == "boolean" then
        "- Enabled: \(.)"
      else
        "- None found"
      end
    '

    echo "Supported Tasks:"
    echo "$body" | jq -r '
      if (.supportedTasks | type) == "array" then
        .supportedTasks[] |
        "- \(.name // .id // .)"
      else
        "- None found"
      end
    '

    echo
  fi
done

