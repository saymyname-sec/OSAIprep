Draft design: Perun autonomous agent configuration

No files have been changed. This design incorporates your decisions:

    Full validation only at the final milestone.
    Remove per-edit frontend test hooks.
    Retain Windows-oriented hook commands.
    Make verification hooks read-only.
    Reduce duplicated auto-loaded steering.
    Correct all six existing skills.
    Prepare custom subagent profiles.
    Split large specs into overnight-sized milestones.
    Make MCP integrations optional and non-blocking.

1. Target instruction architecture

Each type of file should have one clear responsibility.
Component	Responsibility	Must not contain
AGENTS.md	Binding repository rules, autonomy contract, recovery policy, verification policy	Large tutorials and copy-pasted architecture details
Auto steering	Short critical rules Kiro and subagents must always receive	Full project documentation
Skills	Focused, on-demand implementation procedures	Global policy or stale generic templates
Specs	Requirements, design, executable tasks, acceptance criteria	Repository-wide coding rules duplicated from AGENTS.md
Hooks	Deterministic automation and final quality gates	Open-ended agent loops on every edit
Custom subagents	Specialized delegated responsibilities	Overall task ownership or spec progress management
Task prompt	Outcome, scope, acceptance criteria, constraints	Every coding convention already supplied by steering
Instruction precedence

The intended hierarchy should be stated explicitly:

    Security and safety requirements
    Accepted task requirements and spec
    AGENTS.md
    Auto steering
    Relevant skill
    Existing source patterns
    Historical documents and old plans

Historical plans under Ideas/ and docs/superpowers/plans/ should never override source, accepted specs, or current architecture.
2. AGENTS.md redesign
2.1 What remains

Retain these stable, binding sections:

    Project purpose
    Normalize-once architecture
    Security rules
    Rust and frontend invariants
    Component boundaries
    Concise directory map
    Environment-specific verification matrix
    MCP usage policy

2.2 What should be moved out

Move detailed tutorials into skills or referenced documentation:

    Adding a backend endpoint
    Adding frontend views
    Catalog authoring details
    Pipeline TOML examples
    Sigma rule examples
    Full ingest-debugging procedure
    Long lists of runtime configuration fields

AGENTS.md should tell agents what is binding and where to find procedures, not teach every procedure itself.
2.3 Add an Autonomous Execution Contract

Proposed content:

## Autonomous Execution Contract

For an implementation task, own the requested outcome end-to-end. Planning, progress
updates, and checkpoint summaries are execution steps and are not stopping points.

Continue until:

1. Every required acceptance criterion is satisfied and verified; or
2. A genuine hard blocker remains after the recovery procedure has been exhausted.

Do not stop merely because:

- One command failed
- A live dependency is unavailable
- The original implementation approach did not work
- A pre-existing unrelated failure was discovered
- One optional task cannot be completed
- The task has taken longer than expected

When a safe decision can be inferred from the accepted spec, existing source, tests,
public behavior, or repository conventions, make that decision and continue.

2.4 Add a mandatory anti-stall protocol

### Progress and Stall Detection

Divide work into coherent units expected to take 20–45 minutes.

Measurable progress means at least one of:

- An acceptance criterion became satisfied
- A required implementation unit was completed
- A failing reproduction was reduced or understood
- A relevant test changed from failing to passing
- A blocker was conclusively classified with evidence

Repeated tool calls, repeated builds, rereading the same files, and rerunning an
unchanged failing command are not measurable progress.

Rules:

- Never rerun an unchanged failing command without new evidence or a change.
- After two failures with the same error signature, stop retrying and diagnose.
- After three failed attempts based on one hypothesis, discard that hypothesis.
- After 20 minutes without measurable progress, change strategy.
- After 45 minutes on one unresolved work unit, execute the recovery procedure.
- After 60 minutes and two materially different strategies, quarantine the blocker
  and continue all independent work.

These are operational targets. Kiro may not have an exact wall-clock alarm in every interface, so attempt counts are equally important.
2.5 Add the recovery procedure

### Mandatory Recovery Procedure

When a work unit stalls:

1. Preserve the current valid state and inspect the diff.
2. Record the exact command, error, affected files, and last passing check.
3. Classify the blocker:
   - implementation
   - test
   - dependency
   - environment
   - permission
   - requirements
   - integration
   - performance
4. Reduce the failure to the smallest reproducible command or test.
5. Search existing source, tests, repository history, and documentation.
6. Delegate the isolated failure to a fresh investigator subagent when available.
7. Choose a materially different strategy:
   - use an existing abstraction
   - replace the implementation approach
   - isolate or mock an unavailable dependency
   - revert only the unverified work unit
   - run a focused check instead of a full suite
   - defer an explicitly optional unit
8. Verify the alternative with the smallest relevant check.
9. After two distinct strategies fail, mark the unit blocked with evidence and
   continue independent tasks.

Never hide a blocker by disabling tests, suppressing warnings, weakening security,
removing acceptance criteria, or silently changing public behavior.

2.6 Define when questions are permitted

### User Interaction Policy

Ask the user only when:

- The next operation is destructive or irreversible
- Required credentials or permissions are unavailable
- Two interpretations materially change public API, storage, security, or scope
- A mandatory external system is unavailable and cannot be replaced by a mock
- No independent work can continue without the answer

Do not ask for approval for routine implementation decisions, safe refactors within
scope, test corrections, or choosing between equivalent internal approaches.

This prevents milestones from automatically ending with “ask the user if questions arise.”
2.7 Add layered verification

### Verification Ladder

During implementation, use the cheapest relevant check:

1. Edit loop:
   - syntax or compile check
   - one relevant test or test module
   - lint only changed files when supported

2. Work-unit completion:
   - changed crate or frontend feature tests
   - changed crate Clippy or changed-file ESLint

3. Milestone completion:
   - all affected subsystem checks

4. Final milestone:
   - complete quality gate for every affected subsystem, exactly once

Do not run the complete sensor and backend suites after every spec task.
Do not run the complete frontend suite after every edited file.

2.8 Completion contract

Before claiming completion, the agent must report:

    Acceptance criteria and their status
    Files changed
    Tests/checks run and outcomes
    Any pre-existing failures
    Any unverified live behavior and why
    Remaining blockers
    PR or branch location where relevant

A successful command alone does not prove that the requested behavior works.
3. Steering redesign
3.1 Keep only two compact auto-loaded files
.kiro/steering/core-invariants.md

Contains only rules that every agent and subagent always needs:

    Normalize once
    Sensor faithful-capture boundary
    Security requirements
    No destructive ClickHouse migrations
    SQL safety
    No production unwrap/expect
    Current state-management and UI conventions
    Smallest safe patch
    History is not authoritative

Target: approximately 80–120 concise lines.
.kiro/steering/autonomous-execution.md

New file containing the compressed version of:

    End-to-end ownership
    20/45/60-minute policy
    Retry limits
    Recovery procedure
    Verification ladder
    User interaction policy
    Completion contract
    Subagent delegation constraints

This should be auto-loaded because subagents also receive steering.
3.2 Reduce or remove automatic loading for large files
project-context.md

Change from a large always-loaded architecture document into one of:

    A concise orientation file; or
    Context activated only for architecture/ingest work; or
    A referenced document loaded by relevant skills.

Remove details that are likely to drift, such as exhaustive tables and current implementation status.
workflow-guide.md

Replace with a short verification matrix or stop auto-loading it. Its detailed procedures belong in skills.

Suggested compact matrix:
Change	During implementation	Final milestone
perun-server	Relevant test + crate check	fmt check, server Clippy, server tests
perun-pipeline	Relevant pipeline tests	pipeline Clippy/tests; sensor if shared API changed
perun-common	Relevant common tests	common + downstream server/sensor
Sensor	Relevant module tests	sensor Clippy/tests
Frontend	Changed-file ESLint + focused Vitest	build + complete Vitest
Catalog	Catalog test	server catalog/full affected checks
Sigma rules	Compile/load tests + vectors	affected Sigma/server tests
3.3 Avoid duplication

Steering should not say that AGENTS.md is authoritative and then repeat hundreds of lines from it. Use concise references:

For detailed procedures, activate the relevant workspace skill. Do not infer current
behavior from historical plans; verify source and accepted specs.

4. Hook redesign

Windows command wrappers will remain as requested.
4.1 Rust quality gate
Current problem

postTaskExecution invokes all Rust checks after every leaf spec task.
Proposed design

Rename conceptually to Final Rust Quality Gate and make it manually/finally invoked rather than automatic after each spec task.

    Trigger: userTriggered
    Invocation: once at final milestone, and only if Rust changed
    Formatting: check-only
    Backend: use workspace-wide invocations instead of separate command per crate
    Sensor: remain separate because it is not a workspace member

Proposed command:

cmd /c "cargo fmt --manifest-path src/sensor/perun-sensor/Cargo.toml --all -- --check ^
&& cargo fmt --manifest-path src/backend/Cargo.toml --all -- --check ^
&& cargo clippy --manifest-path src/sensor/perun-sensor/Cargo.toml --all-targets -- -D warnings ^
&& cargo clippy --manifest-path src/backend/Cargo.toml --workspace --all-targets -- -D warnings ^
&& cargo test --manifest-path src/sensor/perun-sensor/Cargo.toml ^
&& cargo test --manifest-path src/backend/Cargo.toml --workspace"

The exact multiline escaping would need validation when implemented. The existing one-line cmd /c style can be retained if safer.
During implementation

No hook. The agent directly runs targeted commands such as:

cargo test --manifest-path src/backend/Cargo.toml -p perun-server test_name
cargo check --manifest-path src/backend/Cargo.toml -p perun-server
cargo clippy --manifest-path src/backend/Cargo.toml -p perun-server --all-targets -- -D warnings

Run Clippy after a coherent work unit—not after every edit.
4.2 Frontend quality gate
Current problem

fileEdited → askAgent can run Vitest after every TS/TSX edit and recursively generate more work.
Proposed design

Remove or disable the per-edit hook.

Create a Final Frontend Quality Gate:

    Trigger: userTriggered
    Invoke once at final milestone if frontend files changed
    Run:
        Production build
        Full Vitest suite
        ESLint according to the agreed baseline policy

Because the repository currently has a lint backlog, final lint should either:

    Target all changed files; or
    Use a known baseline/diff mechanism.

Do not make an unrelated existing lint backlog a final blocker.

During implementation:

npx eslint src/path/ChangedFile.tsx
npx vitest run src/path/ChangedFile.test.tsx

4.3 Catalog lint hook

Keep it as an automatic focused hook because:

    It has a narrow file match.
    It runs a relevant catalog-specific test.
    Failure provides immediate actionable information.
    It does not launch an open-ended agent loop.

Possible refinement: make the timeout smaller if the catalog test normally completes quickly.
4.4 Manual server verification hook

Keep verify-perun-server as a focused manual gate. Change formatting to check-only if it is not already check-only—it currently is.

Use it for server-only milestones when running the entire Rust gate is unnecessary.
4.5 Hook principles

Add these design rules:

    Hooks must be deterministic.
    Hooks must have bounded timeouts.
    Hooks should not mutate source files.
    Hooks must not rerun an agent recursively after each edit.
    Hooks must not depend on live ClickHouse, Redis, or frontend servers unless explicitly manual.
    A hook failure should report the failed command and stop; it should not repeatedly retry.

5. Skill-by-skill redesign
5.1 add-backend-endpoint
Problems

    Assumes every endpoint needs four new files.
    Shows manual SQL construction as the default.
    Does not emphasize authentication, role gates, request bounds, or auditing.
    Uses illustrative code that may not match current feature patterns.
    Treats schema creation too casually.

New skill design
Phase 1: inspect

    Find the closest existing endpoint with similar:
        Authentication
        Storage
        Request shape
        Pagination
        Data-view scoping
    Determine whether this belongs in an existing module.
    Identify required role and whether the route is data-plane or control-plane.
    Determine whether the endpoint is read-only or state-changing.
    Reuse existing models and storage helpers where possible.

Phase 2: design

Require:

    Typed request/response models
    Input validation and explicit limits
    Correct role middleware
    Audit entry for sensitive administration or response actions
    Parameterized queries where supported
    escape_sql only where repository conventions require literal construction
    Strict allowlists for dynamic identifiers/order fields
    No untrusted raw SQL fragments
    Consistent error envelope
    Data-view constraint where telemetry is returned

Phase 3: implementation

Do not force a new directory. Follow the closest current module structure.

Schema changes require explicit treatment of:

    Backward compatibility
    Existing data
    Table engine
    Ordering key
    Migration behavior
    Rollback
    Deployment sequencing

Verification

During implementation:

cargo test --manifest-path src/backend/Cargo.toml -p perun-server relevant_test
cargo check --manifest-path src/backend/Cargo.toml -p perun-server

At milestone completion:

cargo clippy --manifest-path src/backend/Cargo.toml -p perun-server --all-targets -- -D warnings
cargo test --manifest-path src/backend/Cargo.toml -p perun-server

The final global Rust gate runs only at the final milestone.
5.2 add-frontend-view
Problems

    Uses raw fetch.
    Uses .then() despite project preference for async/await.
    References the wrong Data View import/API.
    Does not preserve cookie/CSRF handling.
    Generic template can create inconsistent loading/error behavior.
    Does not sufficiently cover accessibility or request cancellation.

New skill design

Use current canonical abstractions:

import apiClient, { authFetch, authFetchJson } from '../utils/apiClient';
import { useDataView, withDataViewParam } from '../context/DataViewContext';

Rules:

    Add typed methods to apiClient for reusable control-plane API operations.
    Use authFetch for already-built paths with data-view query parameters.
    Never use unauthenticated raw fetch for /api/v1 operations.
    Use async/await.
    Model loading, success, empty, and error states explicitly.
    Avoid storing tokens in browser storage.
    Encode dynamic URL path segments.
    Preserve global 401 handling.
    Use semantic controls, labels, keyboard behavior, and visible focus states.
    Use existing Zustand stores only when state is genuinely cross-view or persistent.
    Use local state for view-local state.
    Use useDataView().toParam() and withDataViewParam for scoped telemetry calls.
    Inspect App.tsx and Sidebar.tsx before assuming wiring conventions.
    Do not introduce React.FC as a mandatory style.
    Do not copy a large generic component template without comparing nearby views.

Verification:

npx eslint <changed-files>
npx vitest run <relevant-test-files>

Final frontend milestone:

npm run build
npm test

5.3 add-ocsf-catalog-entry
Problems

    Commands may fail if executed from the repository root.
    Live ClickHouse verification is treated as generally available.
    Some examples risk becoming stale as OCSF or catalog conventions evolve.

New skill design

Procedure:

    Inspect CATALOG_AUTHORING.md.
    Inspect the exact raw source event shape.
    Confirm the unique (product, channel, event_id) triple.
    Consult the pinned local OCSF v1.8 schema first.
    Choose class/category/activity from the schema—not memory.
    Map only observed source fields.
    Verify time_field exists in the raw event.
    Preserve unmapped fields.
    Avoid sensor-side or handler-side duplicate mapping.
    Add a focused normalization test when behavior changes.

Canonical command from repository root:

cargo test --manifest-path src/backend/Cargo.toml -p perun-server catalog

Live ingest and ClickHouse verification should be an optional integration tier:

    Use MCP if available.
    Perform one availability check.
    If unavailable, record that live verification was skipped and continue with deterministic tests.

5.4 add-pipeline-definition
Architectural conflict

The current perun-pipeline schema explicitly contains:

    classification
    field_map
    severity_rules

That conflicts with the newer broad statement that all normalization occurs exactly once through the server catalog.

The skill is not merely stale—the code and architecture documentation currently disagree.
Proposed short-term design

Rename or reposition the skill as:

    Add a legacy/agentless declarative pipeline definition using the existing compatibility engine.

The skill must say:

    This path is a current compatibility exception.
    It must not be used for endpoint sensor telemetry.
    Sensor telemetry uses RawCaptureEnvelope and server catalog normalization.
    Do not claim that every new source should use pipeline field_map.
    Before adding a pipeline, determine whether it should instead emit raw source identity and use the catalog.
    Do not duplicate a source already handled through normalize-once.
    Always preserve unknown fields with the supported fallback.
    Treat filtering as collection filtering, not detection logic.
    Severity rules in the compatibility pipeline should not become a second detection system.

Long-term architecture decision

A future code/spec task should decide between:

Option A — migrate pipeline engine to normalize-once

Pipeline definitions parse raw records and produce a raw envelope:

source → parser → RawCaptureEnvelope → CatalogNormalizer

Classification and mapping move to catalog entries.

Option B — explicitly document two normalization paths

If the agentless pipeline remains allowed to create OCSF directly, AGENTS.md must stop claiming catalog-only normalization for every source and precisely document the exception.

Option A is architecturally cleaner and aligns with your stated principle, but it is a product/code change—not just a skill edit.
5.5 add-sigma-rule
Problems

    Claims broad “standard modifier” support without proving current engine support.
    Treats live server reload and alert APIs as generally available.
    Hard-coded examples may not match current engine semantics.
    Does not require both positive and negative vectors strongly enough.

New skill design

Procedure:

    Inspect current Sigma compiler/matcher support.
    Inspect rules/mappings/ and catalog resolution for every field.
    Confirm the logsource maps to telemetry Perun actually emits.
    Use only supported condition syntax and modifiers.
    Give every rule a stable unique UUID.
    Add:
        At least one matching synthetic vector
        At least one non-matching synthetic vector
        A false-positive rationale
    Use RFC documentation IP ranges and harmless command strings.
    Validate rule loading and matching without requiring a live service.
    Use live ingest/API verification only when services are available.
    Do not modify field mappings merely to force one bad rule to compile without considering all affected rules.

Verification:

cargo test --manifest-path src/backend/Cargo.toml -p perun-server sigma

For overhaul work, use the relevant perun-sigma test target once that crate is active.

The skill should derive its supported-operator table from current code or a committed compatibility report rather than maintaining an unverified list.
5.6 debug-ingest-pipeline
Problems

    Mixes MCP, direct CLI, live logs, and source changes without a strict order.
    Recommends Redis KEYS rather than scan-based discovery.
    Can cause repeated attempts against unavailable localhost services.
    Includes mutation/replay operations near routine diagnostics.
    Does not impose stop conditions before adding code or logging.

New skill design

Use a deterministic stage-by-stage evidence ladder:

    Environment availability
        Check Redis and ClickHouse once.
        If unavailable, classify as environment and switch to static/unit-test investigation.
    Ingress
        Confirm request accepted and normalized.
    Queue
        Read main queue, processing lists, and DLQ with read-only MCP tools.
    Worker
        Inspect bounded logs or focused worker tests.
    Storage
        Check whether the event reached telemetry.
    Detection
        Check whether the correct engine admitted and evaluated the event.
    Presentation
        Check API/data-view scoping and frontend rendering only after storage is proven.

Rules:

    Prefer MCP read tools.
    Use scan operations, not Redis KEYS.
    Never drain/replay the DLQ without explicit approval.
    Never mutate production-like data during diagnosis.
    Do not add logging until the failed stage is identified.
    Do not repeatedly retry unavailable localhost services.
    Correlate evidence using sensor ID, trace ID, event time, and ingest time.
    Produce a final diagnosis table: stage, evidence, conclusion, next action.

6. Custom subagent drafts

Create these later under .kiro/agents/. Models can remain unpinned so they inherit Kiro’s selected/default behavior.
6.1 blocker-investigator.md

---
name: blocker-investigator
description: Diagnoses stalled builds, tests, integration failures, and implementation blockers without modifying source files.
tools: ["read", "shell", "web"]
includeMcpJson: true
---

You are Perun's read-only blocker investigator.

Your job is to determine why a specific work unit is blocked and return evidence plus
materially different recovery options.

Rules:

- Do not modify files.
- Do not run destructive commands.
- Do not rerun the same failing command without changing diagnostic scope.
- Start from the exact error and smallest reproduction supplied by the parent agent.
- Inspect source, tests, relevant configuration, and repository documentation.
- Use MCP only when the failure concerns live Redis or ClickHouse state.
- Distinguish code failures from environment, dependency, permissions, and requirement failures.
- Time-box broad investigation; prefer focused symbol and error searches.

Return:

1. Root cause or ranked hypotheses
2. Evidence for each conclusion
3. Smallest reproduction
4. Two materially different recovery approaches
5. Recommended approach and risks
6. Whether independent work can continue

6.2 rust-implementer.md

---
name: rust-implementer
description: Implements a bounded Rust work unit in one Perun crate with focused tests and verification.
tools: ["read", "write", "shell"]
includeMcpJson: false
---

You implement one explicitly bounded Rust work unit.

The parent agent must provide the acceptance criteria, relevant spec excerpt, allowed files,
and verification command because subagents do not own Spec progress.

Rules:

- Modify only the assigned files and necessary directly related tests.
- Do not edit shared manifests, lockfiles, migrations, or public APIs unless explicitly assigned.
- Preserve normalize-once and security invariants.
- Do not use production unwrap/expect.
- Run only focused checks during implementation.
- Do not run the complete repository quality gate.
- Stop after the assigned work unit is implemented and focused verification passes.
- Report all changed files and exact commands.

If blocked, return evidence and alternatives; do not broaden scope.

6.3 frontend-implementer.md

---
name: frontend-implementer
description: Implements a bounded Perun React and TypeScript work unit using the existing API client, Zustand, Data View context, and cyber theme.
tools: ["read", "write", "shell"]
includeMcpJson: false
---

You implement one explicitly bounded frontend work unit.

Rules:

- Use apiClient/authFetch for API access.
- Preserve credentials, CSRF, and global 401 handling.
- Use useDataView and withDataViewParam for scoped telemetry.
- Use functional components, strict types, existing Zustand stores, and existing theme tokens.
- Do not add another state, styling, or component framework.
- Modify only assigned files and directly related tests.
- Run changed-file ESLint and focused Vitest tests.
- Do not run the complete frontend quality gate; the parent agent owns final integration.
- Report changed files, checks, and accessibility considerations.

Do not start a development server.

6.4 integration-verifier.md

---
name: integration-verifier
description: Independently verifies completed Perun changes against acceptance criteria without changing implementation files.
tools: ["read", "shell"]
includeMcpJson: true
---

You are an independent verifier. Do not modify implementation files.

Given acceptance criteria and a completed diff:

1. Map each criterion to code and a verification method.
2. Inspect the diff for incomplete wiring, security regressions, and architectural violations.
3. Run the smallest sufficient checks first.
4. Run affected final quality gates only when requested by the parent.
5. Separate failures introduced by the change from pre-existing failures.
6. Do not claim behavior was verified if required live infrastructure was unavailable.

Return a table:

- Acceptance criterion
- Evidence
- Command or inspection
- Pass/fail/unverified
- Risk or follow-up

6.5 Delegation policy

Add to AGENTS.md:

    Main agent always owns requirements, task list, spec updates, integration, and final result.
    Subagents receive explicit acceptance criteria and file boundaries.
    Parallel write agents must have disjoint file sets.
    Tasks are not independent if they share:
        A source file
        Public types
        Cargo/package manifests
        Lockfiles
        Schema/migrations
        Generated artifacts
    Investigator and verifier agents should normally be read-only.
    Do not delegate the same blocker to multiple agents with identical instructions.
    Main agent must independently integrate and verify subagent results.
    Hooks do not run in subagents, so hook success cannot be assumed.

7. Spec redesign
7.1 Overnight execution size

One unattended session should target one shippable milestone containing approximately:

    3–8 leaf implementation tasks
    Each expected to take 20–45 minutes
    One final integration task
    One final quality gate
    Clear rollback or fallback behavior

Do not assign the entire Sigma overhaul as one overnight execution.
7.2 Split Sigma overhaul by milestone

Suggested sessions:

    Harness and baseline
    M0 structural correctness
    M1 field resolution
    M2 core compiler/evaluator
    M2 server adapter
    M3 shadow and authority transfer
    M4 normalization variants
    M5 correlation
    M6 packs and capability negotiation

Each can remain within the same overall design, but its task file should have an independently executable milestone boundary.
7.3 Every leaf task should declare

- Outcome
- Allowed/expected files
- Dependencies
- Acceptance criteria
- Focused verification
- Whether it is required or optional
- Whether it may execute in parallel
- Shared-file conflicts

7.4 Verification placement

Remove “full server and engine suite after every task.”

Instead:

    Leaf task: focused test/check
    Milestone checkpoint: affected crate suite
    Final milestone: full affected subsystem gate once

7.5 Remove unnecessary approval stops

Replace:

Ensure all tests pass, ask the user if questions arise.

With:

Verify milestone acceptance criteria and continue automatically. Ask the user only if
the AGENTS.md hard-blocker criteria are met.

8. MCP design
8.1 Availability policy

At task start, do not repeatedly probe every MCP server. Use a server when the task requires it.

On first failure:

    Retry once only if the failure looks transient.
    Classify availability.
    Continue with source/tests/mocks if live verification is not mandatory.
    Report live verification as unverified.

8.2 Redis and ClickHouse

    Keep read operations auto-approved.
    Treat generic query tools carefully; only run read queries automatically.
    Require explicit approval for writes, replay, queue mutation, or DDL.
    Replace direct credentials in tracked configuration with environment variables where the MCP format permits.
    Pin MCP package versions rather than @latest.
    Prefer scan operations over Redis KEYS.

8.3 Playwright

Playwright should be optional:

    Use it only when a server is already available.
    Do not block backend or deterministic frontend work because localhost:5173 is unavailable.
    Do not start a long-running server from a blocking hook.
    Report browser verification separately from build/test verification.

9. Autonomous task prompt template

For overnight Autonomous mode tasks, use a prompt structured like this:

## Outcome

Implement [specific milestone/outcome].

## Problem

[Why this is needed and what currently fails.]

## Scope

In:
- ...

Out:
- ...

## Acceptance criteria

1. ...
2. ...
3. ...

## Constraints

- Follow AGENTS.md and .kiro/steering.
- Use the accepted spec at ...
- Preserve ...
- Do not change ...

## Autonomy

Own the outcome end-to-end. Resolve routine implementation decisions from source, tests,
and repository conventions. Do not stop after planning or the first failed approach.

If a work unit stalls, follow the repository recovery procedure. After 45–60 minutes,
change strategy or quarantine the blocker and continue independent work.

Ask only for destructive operations, unavailable required credentials, or ambiguity that
materially affects API, stored data, security, or scope.

## Verification

During implementation, run focused checks only. At the final milestone, run the complete
quality gate for affected subsystems exactly once.

## Deliverable

Open a PR containing implementation, relevant tests, and a description mapping each
acceptance criterion to verification evidence.

10. Proposed implementation phases

Once you approve the design, I recommend applying it in this order.
Phase 1 — Stop the current waste

    Add autonomy/recovery policy to AGENTS.md.
    Add compact autonomous steering.
    Convert Rust gate from postTaskExecution to final/manual.
    Make Rust formatting check-only.
    Remove the per-edit frontend askAgent hook.
    Add final frontend gate.

This phase provides the largest immediate improvement.
Phase 2 — Reduce context and conflicts

    Trim auto steering.
    Move procedures from steering into skills.
    Add verification matrix.
    Remove repeated architecture and commands.

Phase 3 — Repair skills

Update all six existing skills, with special attention to:

    API client/CSRF behavior
    SQL safety
    Correct working directories
    Optional live infrastructure
    Pipeline normalize-once conflict
    Current Sigma capabilities

Phase 4 — Add subagents

Create and validate:

    blocker-investigator
    rust-implementer
    frontend-implementer
    integration-verifier

Phase 5 — Restructure active specs

Split the Sigma overhaul into milestone-sized executions and remove full-suite checks from leaf tasks.
Phase 6 — Harden MCP

Pin versions, externalize credentials, document availability fallback, and restrict automatic queries to read-only behavior.
11. Acceptance criteria for the configuration overhaul

The configuration change should not be considered complete until:

    No full Rust suite runs automatically after every spec task.
    No complete frontend suite runs automatically after each TS/TSX edit.
    Hook-driven formatting does not modify source files.
    Final Rust and frontend gates can be invoked once per affected final milestone.
    Auto steering contains no large duplicate of AGENTS.md.
    The anti-stall procedure defines retry, 20-minute, 45-minute, and 60-minute behavior.
    All six skills use current paths, APIs, and architecture.
    The frontend skill uses apiClient/authFetch and the correct useDataView.
    Backend skill does not present unsafe SQL interpolation as its default template.
    Pipeline skill explicitly handles the normalize-once conflict.
    Custom subagents have bounded responsibility and least-privilege tools.
    Specs define file ownership and do not parallelize overlapping edits.
    MCP unavailability does not stop deterministic implementation.
    No mandatory quality or security check is removed—only moved to the correct verification level.

The only architectural decision still requiring explicit approval is the pipeline conflict: migrate agentless pipelines to RawCaptureEnvelope → CatalogNormalizer, or formally document them as a normalize-once exception.