# Module 11 — Gaps & Missing Coverage

## Missing Coverage

### Active Directory Attack Depth
**Status:** Partially documented
**Notes:** Notes cover GenericWrite → group add and adsisearcher for enum, but do not detail Kerberoasting, ASREPRoasting, or BloodHound-based path analysis if the initial path is blocked.
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### Antivirus / EDR Evasion Detail
**Status:** Partially documented
**Notes:** XOR obfuscation of shellcode and `EnumDesktopWindows` callback loader are covered, but specific Defender signature bypass techniques (AMSI patching, ETW patching, sleep obfuscation) are not detailed.
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### Sliver C2 Configuration
**Status:** Not documented
**Notes:** `xor_encrypt.py` generates a shellcode header for a Sliver beacon, but the Sliver server setup, listener config, and stageless vs. staged payload generation are not covered.
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### LM Studio / Qwen Model Specifics
**Status:** Partially documented
**Notes:** Port 1234 and model name (Qwen) noted, but the API endpoint format, token limits, and any model-specific injection quirks are not detailed.
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### RDS Gateway Authentication Flow
**Status:** Partially documented
**Notes:** xfreerdp command documented, but the full RDS Gateway authentication flow, certificate validation, and NLA bypass (if applicable) are not covered.
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### MSSQL Linked Server Exploitation
**Status:** Not documented
**Notes:** If `dev-db01` has linked servers to INTERNAL SQL instances, this is an alternative lateral movement path not covered in the notes.
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### Vault / Secret Manager Post-Exploitation
**Status:** Not documented
**Notes:** `vault_admin` credentials are recovered via KeePass dump, but the Vault API interaction (listing secrets, reading paths, token renewal) is not detailed.
**Action needed:** Add notes? [ ] Yes  [ ] Skip

---

### Cleanup / OPSEC Exit
**Status:** Not documented
**Notes:** No coverage of cleaning up artifacts: removing chisel.exe, pandas.py, .dmp files, clearing Windows Event Log entries, or restoring xp_cmdshell to disabled.
**Action needed:** Add notes? [ ] Yes  [ ] Skip
