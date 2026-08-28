# Module 08 — Gaps & Missing Coverage

## Missing Coverage

### Sleeper Agent Detection
**Status:** Partially documented
**Notes say:** Sleeper agents conditionally backdoored — appear clean in eval
**Action needed:** Add notes on how sleeper agents are triggered vs. detected  [ ] Yes

---

### Quantization Supply Chain Gap
**Status:** Mentioned, not detailed
**Syllabus says:** Quantized model hash has no mathematical relationship to source model hash
**Action needed:** Document workflow for verifying quantized model integrity  [ ] Yes

---

### Anti-Sandbox Evasion in Payloads
**Status:** Mentioned briefly
**Notes say:** CPU count, disk size, debugger detection, temp dir contents as anti-sandbox checks
**Action needed:** Add code examples for anti-sandbox checks used in supply chain payloads  [ ] Yes

---

### Fickling Deep Analysis
**Status:** Tool mentioned, usage unclear
**Notes say:** fickling --check for advanced pickle analysis beyond picklescan
**Action needed:** Document fickling output format and what to look for  [ ] Yes

---

### torch.package Supply Chain Vector
**Status:** Listed as bypass technique, not expanded
**Notes say:** torch.package as another bypass avenue
**Action needed:** Explain how torch.package enables code execution vs. normal pickle  [ ] Yes

---

### EC2 IMDS Credential Retrieval
**Status:** Mentioned in context, no dedicated section
**Notes say:** EC2 IMDS v1/v2 for AWS credential retrieval from AI infrastructure
**Action needed:** Likely covered in Module 09 (AI Infrastructure) — cross-check  [ ] Review

---

### Model Behavioral Testing Methodology
**Status:** Not documented
**Gap:** No notes on how to design regression tests to detect poisoned behavior
**Action needed:** Add post-deployment behavioral testing strategy  [ ] Yes

---
