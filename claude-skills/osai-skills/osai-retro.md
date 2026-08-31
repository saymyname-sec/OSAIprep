Post-lab retrospective — analyze the engagement, identify bottlenecks, and propose concrete skill/CLAUDE.md improvements. $ARGUMENTS = --lab <name> (optional, defaults to most recent lab)

## Step 1: Identify lab dir
```bash
if [ -n "<LAB from $ARGUMENTS>" ]; then
  LAB_DIR=~/osai/labs/<LAB>
else
  LAB_DIR=~/osai/labs/$(ls -t ~/osai/labs/ | head -1)
fi
LAB=$(basename $LAB_DIR)
echo "=== RETRO: $LAB ==="
```

## Step 2: Load state (token-efficient)
```bash
# Scope
cat $LAB_DIR/state/scope.md

# Findings summary only — not full entries
jq '[.[] | {id, title, severity, host, mitre, screenshot}]' $LAB_DIR/loot/findings.json 2>/dev/null

# Cred count
jq 'length' $LAB_DIR/loot/creds.json 2>/dev/null

# Recon files produced
ls -lh $LAB_DIR/recon/ 2>/dev/null

# Progress notes (manual notes Kapi wrote during lab)
cat $LAB_DIR/state/progress.md 2>/dev/null
```

## Step 3: Analyze — answer each question
Work through the evidence silently, then report findings:

1. **Entry point** — What service/vuln gave initial access? How long did it take to find?
2. **Enumeration gaps** — Any finding logged late that earlier recon should have surfaced?
3. **Skill gaps** — Any manual command run with no matching skill? List exact commands.
4. **Skill misfires** — Any skill output that was wrong, ignored, or needed correction?
5. **Missing MITRE map** — Any technique used not in osai-notes auto-map?
6. **Slow phases** — Which phase (recon/access/privesc/lateral/report) was slowest? Why?
7. **Cred handling** — Were all creds logged live via /osai-cred-vault or found in files later?
8. **AI surface** — Any LLM/RAG/MCP endpoint found that /osai-ai-hunter didn't flag?
9. **Pivot friction** — Any pivot issue (routing, proxychains, Ligolo) that cost time?

## Step 4: Write proposals
For each identified gap, produce a structured proposal block:

```
[PROPOSAL-N]
FILE: osai-<skill>.md  (or CLAUDE.md)
TYPE: add-step | fix-step | add-trigger | add-mitre-map | new-skill
SECTION: Step N  (or trigger keyword)
PRIORITY: HIGH | MEDIUM | LOW
BEFORE: <current text, or "N/A — new addition">
AFTER: <exact replacement or addition>
REASON: <what broke and how this fixes it>
```

## Step 5: Save retro report
```bash
TS=$(date +%Y%m%d_%H%M%S)
RETRO_FILE=$LAB_DIR/loot/retro_${TS}.md
# Write to lab loot dir
tee $RETRO_FILE >> ~/osai/retro_log.md
echo "[+] Retro saved: $RETRO_FILE"
echo "[+] Appended to: ~/osai/retro_log.md"
```

## Step 6: Print summary dashboard
```
╔══════════════════════════════════════════════╗
║          LAB RETRO: <LAB>                   ║
╠══════════════════════════════════════════════╣
║ Findings:  N  (C:X  H:X  M:X  L:X)         ║
║ Creds:     N recovered                      ║
║ Proposals: N improvements identified        ║
╠══════════════════════════════════════════════╣
║ HIGH PRIORITY:                              ║
║  · <proposal-1 one-liner>                   ║
║  · <proposal-2 one-liner>                   ║
╠══════════════════════════════════════════════╣
║ NEXT: review ~/osai/retro_log.md            ║
║       apply accepted proposals to repo      ║
║       git commit -m "retro: <lab>" && push  ║
╚══════════════════════════════════════════════╝
```

## Applying accepted proposals
After Kapi reviews and accepts proposals, edit the relevant skill .md files in
~/osai/labs/<lab>/  (or directly in the repo clone), then:
```bash
cd ~/Git/OSAI
git add claude-skills/
git commit -m "retro(<LAB>): <summary of changes>"
git push
# Then redeploy skills to Claude Code:
cp claude-skills/osai-skills/*.md ~/.claude/commands/
```
