Produce a senior-operator attack plan for the current engagement state using the Autonomy Contract. Read the engagement state, form ranked hypotheses, and output the single recommended next move with both a manual and an autonomous path. This is the OPERATING MODE reasoning made on-demand — call it whenever you feel the work drifting into blind step-by-step execution.

$ARGUMENTS = optional focus (a host IP, "AD", "AI targets", "what next"). If empty, plan the whole engagement from current state.

## Step 1: Load state (never guess — read the files)
```bash
cat ~/osai/current/state/progress.md 2>/dev/null
cat ~/osai/current/state/network_map.md 2>/dev/null
jq '.' ~/osai/current/loot/findings.json 2>/dev/null
jq '[.[] | {user,pass,hash,host}]' ~/osai/current/state/creds.json 2>/dev/null
cat ~/osai/current/recon/recon_summary.md 2>/dev/null
```
Pull only what's relevant to $ARGUMENTS — don't dump every file into context.

## Step 2: Score against the engagement math
- AI machines = 15 each and the pass mark. Traditional = 10. DC flag = 5.
- Weigh every candidate move by (likelihood × points × speed).
- Untouched AI host with no prereqs beats grinding a half-done AD chain. Say so.

## Step 3: Research the unknowns (if any hypothesis needs it)
If a candidate path involves a surface/framework/version you're not certain about, spawn an
Explore research agent (see Research Protocol) against the local repos BEFORE recommending it.
Fold the finding into the RESEARCH line. Don't recommend a path you can't yet execute.

## Step 4: Output — the Autonomy Contract
```
STATE:        where the engagement is (points banked, chains open, what's untouched)
FINDINGS:     what current state means, triaged — not a file dump
HYPOTHESES:   2–4 ranked next moves. Each: technique · likelihood · pts · one-line why
RESEARCH:     what I looked up (if anything) + the key finding
RECOMMENDED:  the one move I'd make, and why it beats the others
  → Manual:     exact commands Kapi can run himself
  → Autonomous: the skill/agent sequence I'll run if you say "go"
NEXT:         what this unlocks — the next link in the chain
```

## Step 5: Proceed
Recon/research → proceed autonomously and report. Exploitation → recommend and proceed on the
obvious high-EV move unless Kapi redirects. Genuine fork → ask. Bias toward action.
