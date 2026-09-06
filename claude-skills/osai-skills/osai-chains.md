Print the common OSAI attack chains as a quick reference, and recognize which chain the current situation fits so you complete it instead of stopping at a single win. A chain turns one foothold into points — always ask "what does this unlock?" Filter by category in $ARGUMENTS.

$ARGUMENTS = optional category: ai, ad, cloud, web, linux, windows. If empty, list all chain names and ask which, OR — if the user described a current position — identify the matching chain and show what completes it.

## How to use
Two modes:
1. **Reference:** print the requested category's chains.
2. **Recognize:** if given a current position ("I have SSRF on the AI host", "low-priv domain user"),
   name the chain it belongs to and output the remaining links + the skill for each.

## Category: ai
```
RAG file-read → proof
  ai-hunter → owasp(LLM01/06) → rag-attack (poison doc w/ file-read instruction)
  → trigger retrieval → model returns proof file → notes --flag

RAG → SSRF → cloud
  rag-attack (SSRF payload) → model fetches internal URL → cloud-loot (IMDS→IAM→secrets)

Vector DB → secrets
  ai-hunter (finds Qdrant/Weaviate) → embed (dump + invert embeddings) → cred-vault → spray

MCP tool abuse → RCE
  ai-hunter → mcp-attack (path traversal read → write file → post-reload hook) → shell → win/linux-enum

A2A mesh → injection → proof
  ai-hunter → a2a (enum agent cards → inject via peer/tool → scanner bypass) → proof
```

## Category: ad
```
Low-priv user → DA
  win-enum → ad-attack (BloodHound) → [Kerberoast/ASREP → crack → cred-vault]
  → spray → [ACL edge: GenericWrite/WriteDACL] → DCSync → PTH DA → DC flag

Foothold → Kerberoast → lateral
  win-enum → ad-attack (GetUserSPNs) → hashcat → cred-vault → spray → new host → win-enum

ADCS → domain admin
  win-enum → ad-attack (certipy find -vulnerable) → ESC1/8 → auth → NT hash → PTH → DCSync

Delegation → impersonate
  ad-attack (unconstrained/constrained/RBCD) → getST impersonate Administrator → psexec
```

## Category: cloud
```
SSRF → full cloud compromise
  web OR rag-attack (SSRF) → cloud-loot (IMDSv1/v2 → role creds) → enumerate IAM
  → chain roles (Lambda→DataScientist→MLOps→SageMaker) → secrets (S3/SSM/ECR) → cred-vault

Leaked key → pivot
  loot a key from a config/model → cloud-loot (have-creds) → enumerate → escalate → K8s pivot
```

## Category: web
```
Web foothold → shell → loot
  web (map) → [SQLi→xp_cmdshell | LFI→log poison | SSTI | upload webshell | cmdi] → shell
  → win-enum/linux-attack → cred-vault → pivot

Upload bypass → RCE
  web → upload (extension/magic/polyglot bypass) → webshell → revshell → enum
```

## Category: linux
```
Foothold → root
  linux-attack (SUID/sudo/cap/cron/NFS/Docker) → root → loot creds → cred-vault → pivot

Writable-path hijack → priv exec
  hijack (python-module/PATH/LD_PRELOAD/cron) → priv process runs your code → root
```

## Category: windows
```
Shell → SYSTEM → loot
  win-enum (whoami /priv FIRST) → winpeas → [SeImpersonate→Potato | service | AlwaysInstallElevated]
  → SYSTEM → dump SAM/LSASS → cred-vault → spray/pivot

Local admin → domain
  win-enum → dump creds → cred-vault → spray → domain user → ad chain (see: ad)
```

## The universal rule
Every win asks ONE question: **what does this unlock?**
- Credential → check vault, then spray (cred-vault → spray)
- SSRF → cloud metadata (cloud-loot)
- RCE/shell → enumerate for privesc, then loot, then pivot
- Proof file reachable → grab it NOW (notes --flag), don't wait
- New subnet → pivot → re-run recon
Never stop at the foothold. State the next link and take it.

## Output (recognize mode)
```
POSITION:   <where you are>
CHAIN:      <named chain this fits>
DONE:       <links already completed>
REMAINING:  <next links, each with the skill to run>
NEXT:       <the immediate action>
```
