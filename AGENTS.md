# Agent instructions — Siren's Song

Read `docs/START_HERE.md` and `docs/SOURCE_AUTHORITY.md` before substantial work. Consult the design bible and provenance sources when available.

## Identity and design

Siren's Song is an original Android-first 2D tactical stealth game. A single human pilot commands the USS Quietus and remote drones against technologically superior alien Sirens. Core tensions: perceiving exposes you; moving makes noise. Drones extend perception and attention is limited. The agreed working control direction is continuous real-time simulation with unlimited tactical pause, assisted navigation, queued waypoints and conditional orders.

The production game targets multiple missions, satisfying progression, compelling audio, and a distinctive visual identity. Treat old one-level and no-procedural-generation prototype constraints as historical scope decisions.

## Autonomy

Agents may propose and implement original mission design, progression, visuals, systems, tools, and technical architecture within the game's identity. Escalate changes that materially rewrite the premise, core player role, or established identity. Document significant creative decisions and provenance.

## Execution and quality

- Research and reuse maintained, suitably licensed implementations before building custom equivalents.
- Favor inspectable builds and measured results over unsupported claims.
- Preserve a working baseline; use focused branches/PRs for substantial changes.
- Capture screenshots and repeatable gameplay scenarios for visual and experiential review.
- Test Android behavior, performance, input, save/resume, and failure cases.
- Keep independent reviews evidence-driven; critics should inspect artifacts before builder explanations.
- Record unresolved design questions without silently ratifying proposals.
- Do not configure a new Codex environment or lock the game engine without reviewing existing environment capabilities and documenting the choice.

## Coordination

Codex is the provisional primary implementer; Claude Code can contribute art direction and independent reviews; Astra is optional for difficult tasks. These are flexible roles, not exclusive ownership. Avoid concurrent edits to the same files; integrate through reviewable changes.


## Model selection and usage policy (Gauntlet)

**Default model: Sol 6.1** for implementation, tests, review, visual criticism, integration, and substantial delegated/subagent tasks where model selection is available. Smaller/weaker agents are permitted for appropriately scoped smaller actions when fit and reliability justify them; do not choose a cheaper agent that creates rework.

**Astra:** use for the initial source-corpus/architecture kickoff and rare, specifically justified escalations where Sol has reached a demonstrated impasse or the decision has unusually broad consequences. Do not create Astra subagents by default. Starting a task with Astra does not authorize inheriting Astra for delegated tasks.

Before spawning a subagent, establish its actual model selection. If the platform silently inherits Astra and cannot explicitly route to Sol, do not fan out Astra subagents. Instead perform the work sequentially, use Sol in a separate task/session, or stop and report the limitation. Never claim a requested model was used without verification.

Each subagent instruction must inherit this policy, the project source hierarchy, the assigned scope, the required evidence, and a bounded deliverable. Delegate only independent work that justifies its coordination and usage costs. Limit concurrency to the smallest useful number; avoid spawning agents solely to increase parallelism.

Prefer deterministic tests, static checks, local scripts, and targeted screenshot comparisons before additional model calls. Reserve fresh-context criticism for substantial, inspectable results. Critics must inspect the running game or captured evidence rather than relying on builder summaries.

Record in the project progress workbench: model actually used (when observable), task, reason for escalation, result, and remaining quality gap. When model routing or usage visibility is unavailable, mark it unknown rather than assuming.

Keep the policy in AGENTS.md and include it in each new session's working context. Do not relax it through nested delegation. If budget or session limits interrupt work, preserve checkpoints and a clear continuation instruction.

## Production implementation and continuation

Read `docs/architecture/GAUNTLET.md`, `docs/WORKBENCH.md`, and `docs/CONTINUATION.md` after the source authority. The current user has authorized production, engine/toolchain selection and autonomous iteration; historical import-only scope is superseded. Follow the Sol-first policy above, including in fresh-context/nested instructions. User autonomy and model policy override skill defaults that would request repeated routine design approval, impose fixed critique counts, or select a premium reviewer automatically.

Production engine: Godot 4.6.3 stable, GDScript, Compatibility renderer. Project lives in `game/`; official Android templates must match. See ADR 0001 and `docs/CODEX_ENVIRONMENT.md`. Use existing environment capabilities before replacing configuration. Main device target: Galaxy Z Fold7; test cover and unfolded landscape sizes, safe areas and lifecycle. GitHub emulator evidence supplements real device review.

Keep deterministic simulation separated from presentation, commands explicit, and observations bounded by sensors. Cover blocks perception in both directions; paused simulation does not consume resources. Switching drone→sub must clear stale append/tool state; emergency route replacement is reliable. Maintain imported sources byte-for-byte.

Use `scripts/toolchain/headless.sh --script res://tests/run_tests.gd`, `scripts/toolchain/build.sh android`, and `scripts/toolchain/capture.sh` once supplied; inspect exact script help/contracts. Run the actual game for visual evidence. Headless tests and desktop captures do not establish Android runtime behavior. Record device/emulator differences.

Every meaningful milestone updates workbench status, raw evidence paths, independent criticism, model assignments, known blockers and next command. Commit focused runnable progress. Never overwrite another worker's files; assign ownership and interfaces first. The production lead owns game code except tooling-owned export presets; tooling owns its scripts and CI. Preserve the latest checkpoint through context loss.


## Persistent Gauntlet mandate — user ratified 2026-10-18

**The Gauntlet is an open-ended, user-terminated improvement program.** A working prototype, complete six-mission campaign, passing tests, signed/installable APK, polished vertical slice, or app-store-caliber release candidate is a **baseline milestone, never the automatic stopping condition**. The long-term quality ambition is a cohesive, genuinely publishable Android game of the caliber a player could encounter on an app store; after reaching that bar, keep evaluating and improving until the user explicitly says to stop or changes direction. Do not interpret a task list, quality checklist, reviewer approval, or absence of severe defects as authorization to terminate the program.

After each meaningful milestone: (1) build/run and gather inspectable gameplay, visual, audio, interaction and Android evidence; (2) solicit independent evidence-first criticism when warranted; (3) identify the largest remaining experiential, design, content, technical or accessibility opportunity, including improvements beyond bug fixes; (4) prioritize against the established Siren's Song identity and source hierarchy; (5) implement and validate the next bounded improvement; (6) record results, evidence, known limitations and the next action, then repeat. Revisit the quality bar as the game improves. Avoid aimless feature accumulation, endless cosmetic churn and regressions: prioritize player experience, coherence, performance, and meaningful progress. Existing campaign and implementation tasks are the first production phase, not the entire Gauntlet.

**Session/usage/resource limits:** Stop executing when limits require it, preserve a runnable checkpoint, branch/commit status, exact evidence, remaining gaps and a specific next command in WORKBENCH and CONTINUATION. Label the state 'paused / awaiting continuation' rather than 'complete'. Resume the loop when execution becomes available; do not claim background execution across unavailable sessions or automatically bypass platform limits.

**User involvement:** As playable builds mature, invite targeted hands-on testing and incorporate the user's observations, preferences, and new direction. Human feedback becomes increasingly valuable; do not require it for every routine iteration or replace autonomous progress with approval loops. The user alone determines satisfaction and authorizes ending the Gauntlet. Distinguish internal quality estimates from user acceptance. Respect material premise/identity escalation rules and the existing model-budget policy.


## Evidence ratchet and current user direction — ratified 2026-10-19

Preserve the strongest verified baseline and its artifacts before substantial challengers. Record intended player gain, actual comparisons, accepted tradeoffs and retained rejected/deferred experiments in `docs/BASELINE_AND_EXPERIMENTS.md`. Deterministic checks precede critics. Periodically commission fresh whole-game criticism across pacing, variety, tactical depth, progression/upgrades, narrative, atmosphere, audiovisual quality, accessibility and comprehension. Use a separate evidence-based regression hunter after substantial changes; it may find no meaningful regression. Reproduce/compare findings, distinguish inherited weaknesses, and prioritize confirmed consequential regressions. Do not replace experiential improvement with more invariant counts or force reviewers to invent faults.

Maintain the lightweight phone-readable repository dashboard at `docs/PHONE_DASHBOARD.md`: current stage/cycle, actual images/video, APK, criticism, accepted gains, rejected/deferred experiments, weaknesses/opportunities, blockers and next action. Reuse existing workbench/evidence; no hosting dependency or process infrastructure is required. User hands-on direction remains authoritative; retain useful work and avoid routine approval/opinion gates.

Zoom in/out and a usable, friendly touch UI are key production features. The prototype UI and screen dimensions are not constraints; logical coordinates are implementation details. Validate zoom/pan, responsive controls, gesture conflicts, accidental orders, route clarity and tactical pause on cover/unfolded evidence, then physical Fold7 when available.

Persist future agreed workflow and creative decisions in Git instructions with rationale and source hierarchy. Update governing docs and continuation at the next safe checkpoint so future sessions inherit them. Every new worker/critic brief must include `docs/AGENT_BRIEF.md` policy, exact scope and evidence; requested model routing must be explicit and actual telemetry honestly unknown where unavailable. The ratified fit-to-task lighter-agent permission refines earlier blanket Sol-only wording; Sol remains the substantial-work default, premium remains justified escalation only.
