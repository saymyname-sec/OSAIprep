# Archived skills — superseded by architecture v2

These were retired when enumeration + web scanning moved to the **HexStrike AI MCP**
(151 tools, better maintained than hand-rolled equivalents). They are kept, not deleted,
so the reasoning they encoded is recoverable.

| Archived skill | Replaced by |
|----------------|-------------|
| `osai-parallel-recon.md` | HexStrike MCP: `intelligent_smart_scan`, `nmap_advanced_scan`, `autorecon_comprehensive` |
| `osai-web.md` | HexStrike web stack: nuclei, ffuf, feroxbuster, katana, dalfox, sqlmap, arjun, `bugbounty_*` |

## Watch item — `osai-web` also carried CHAIN knowledge
`osai-web` did more than scan: it encoded exploitation *chains* — LFI → log poisoning → RCE,
SSTI → shell, upload-bypass → webshell. **HexStrike finds the bug; it does not chain it.**

If a lab stalls at *"nuclei/sqlmap found it — now what?"*, bring that reasoning back as a thin
**`osai-web-exploit`** skill: chain logic only, NO scanner invocation in it (HexStrike owns the
scanning). Do not restore `osai-web` wholesale — it would re-duplicate the scanners.

## AdaptixCustom/ — retired C2 helper scripts
Architecture v2 replaces Adaptix C2 with the **Metasploit MCP** (`msfmcpd`) entirely.
`adaptix_gen.py` and `adaptix_quick.sh` (previously under `Scripts/AdaptixCustom/`) are moved
here — kept for reference, not used by any skill. If you still want Adaptix as a personal C2,
restore them with `git mv` and re-add an `adaptix` server to `.mcp.json`; nothing in the
architecture-v2 toolkit references it.
