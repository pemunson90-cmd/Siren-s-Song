# Agent instructions — Siren's Song

> **LIVING GAME SPEC / PERPETUAL QUALITY RATC HET (2026-10-19 USER DIRECTIVE).** Read `docs/CURRENT_GAME_SPEC.md` and `docs/V7_TO_GODOT_PARITY.md` alongside source authority before assigning design or implementing gameplay. The historical original functional spec is superseded as a **current** requirement source; preserve it as provenance. Playable v7 demonstrated targetable knockdown and other omitted mechanics; audit and reconcile them instead of treating old written development-status labels as definitive. At every substantial development pass, assess how to make the entire game more cohesive, deep, polished, intuitive, atmospheric and AAA-caliber in *content and execution*; do not self-declare finished at any milestone. Publishability refers to craftsmanship, not app-store submission/business/legal tasks. Record the next consequential player-facing gain, not merely additional fine-grained checks. Retain continuous branches, one reviewer, appropriate milestone validation and honest platform-limited continuation.


## Current execution contract — user directive, 2026-10-19

This section governs current Gauntlet execution over older per-cycle gates in this file and historical docs. Maintain the game's ratified identity, accepted work, and safety-critical regressions.

**Continuous development:** Each independently mergeable design or implementation lives on its own feature branch/worktree. Allow nonconflicting work to advance concurrently. One assigned integrator coordinates changes into `gauntlet/production`. Each proposed merge receives **one designated reviewer** inspecting the diff, potential conflicts, and focused tests; resolve findings and reconcile against the latest production tip. Additional reviewers require a specific consequential risk. Preserve a playable production branch.

**Proportionate testing:** Fast targeted tests and Godot previews during iterations; affected regression checks before merges; full suite and Android APK at meaningful integrated milestones or for a concrete Android-specific problem. Do not require an APK, exhaustive recordings, independent experiential criticism, or a detailed evidence archive for every small step. Keep existing tests/artifacts available; always correct known breaking regressions. Make game progress the primary outcome.

**Mandatory instruction refresh at every task boundary:** Before assigning the next task, spawning a worker, deciding a merge, or resuming a checkpoint, the orchestrator/integrator must (1) fetch the latest remote `gauntlet/production` without disturbing active work, (2) read `AGENTS.md`, `docs/CONTINUATION.md`, and `docs/WORKBENCH.md` from the fetched tip, (3) apply newer user-directed policy and reconcile any conflicting older local instructions, and (4) pass the current policy and its SHA in the next worker/reviewer brief. Do not assume a running Codex session automatically reloads AGENTS.md. If fetch is unavailable, document the failure, protect existing changes, and retry at the next boundary; do not falsely attest a refresh.

**Self-directed handoffs:** Completing a feature, review, build, checkpoint, or task triggers the next highest-value authorized development activity without asking the user to coordinate routine work. Preserve the running context, current branch/commit, open work and concrete next action. Pause only on an actual execution/resource boundary, dangerous unresolved conflict, or material decision outside the user's existing authorization; a repository instruction cannot itself guarantee execution after a platform session ends. Do not claim background execution across unavailable sessions.

**Instruction upkeep:** Keep this concise contract as the canonical operating policy. WORKBENCH/CONTINUATION contain current state rather than duplicate full governance. Historical mandatory native/review-per-increment wording is superseded. Update the short active handoff when implementing a new policy, and explicitly acknowledge the fetched governance SHA once per session, not after every tiny action.

**Concrete boundary mechanism:** Run `python3 scripts/toolchain/gauntlet-boundary.py --boundary <complete|dispatch|review|merge|resume>`; for dispatch use `--dispatch work/task.json` and invoke the emitted collaboration payload after reading changed cached instructions. Reviewed installer `scripts/toolchain/install-gauntlet-hooks.py` adds non-destructive shared Git hooks for commit/checkout/merge/push. Collaboration callbacks and session-resume hooks are unavailable here, so their explicit preflight remains mandatory. See [docs/GAUNTLET_ORCHESTRATION.md](docs/GAUNTLET_ORCHESTRATION.md); a fresh receipt proves retrieval, not semantic adoption or future/background execution.

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

## Exact publication scope

Before publishing, name the intended committed SHA, agreed reference and sole pusher. A docs-only / `[skip ci]` publication must **abort** if `git diff <reference> <tip> -- game scripts/toolchain .github/workflows` is nonempty; printing the diff is not a guard. Check the committed tip, not merely the working tree, and never stage another owner's active files. An experimental source checkpoint does not promote its APK/runtime. Preserve accepted source/artifacts and label source versus playable-build status explicitly.
## Original implementation reference and addenda — user ratified 2026-10-19

Read [the original prototype handoff](reference/original-prototype/MANIFEST.md) and [v7 implementation](reference/original-prototype/sirens_song_prototype_v7.html) as working gameplay reference before relevant production changes. Compare actual behavior and preserve intentional gains; record omissions/departures against current source authority rather than silently replacing proven mechanics. Historical embedded governance does not override current explicit decisions.

The user explicitly ratified [Addendum A](docs/reviews/2026-10-19-external-audit-addendum-A.md) as the priority fix and [Addendum B](docs/reviews/2026-10-19-external-audit-addendum-B.md) as critic direction. After the prototype import/comparison audit and committed/remote integrity checks, implement A test-first: authored terrain-safe patrol loops, distinct tethered sentinel/fast-response hunter, Listening Well hunter and intentional Foundry sentinels, preserved fair sensing, historical pre-fix balance numbers and rerun strategies/naive policies/critic probes. Do not weaken detection or speed merely to recover old hull results. Complete this priority before resuming the parked density UI cycle.

All future critic briefs inherit [docs/CRITIC_BRIEF.md](docs/CRITIC_BRIEF.md): one dimension against shipped-game footage, actual 10–20 second game clips including idle-world observation, blind only where feasible and honestly labeled, retained losses and no imitation. Start with Door Kickers, Barotrauma and Mark of the Ninja; verify current store availability before recommending play. [Ratification/checkpoint note](docs/source-import/original-prototype-handoff/RATIFICATION.md) distinguishes originals, current directions, evidence gaps and preserved work. Existing model-selection and persistent Gauntlet policy remain binding.


## Gauntlet execution loop — user correction, 19 October 2026

The user explicitly corrected a root orchestration failure: stopping after a bounded milestone despite an identified next action. The fully polished, feature-complete, playable Android game is the long-term target; only the user determines satisfaction and when to stop spending compute. Passing tests, an accepted build/review, a completed plan or absence of critical defects never sets that bar or ends execution.

| Event/state | Meaning | Required next action |
| --- | --- | --- |
| Task completion | One bounded assignment has its required evidence. | Integrate/review it as appropriate and execute the next available task in the same available session. |
| Worker completion | One worker has released its assigned scope. | Reuse, release or replace that worker and continue orchestration. Worker completion never implies program completion. |
| Milestone/checkpoint | Verified baseline, evidence and decisions are preserved. | Identify the highest-value next improvement, update WORKBENCH/CONTINUATION, and immediately begin implementing or investigating it. Repeat without routine approval. |
| Available execution session | Tools/context/resources still permit useful authorized work. | Continue development, evaluation, criticism, planning and improvement. Continue through task-plan completion and supported context compaction. |
| Actual session exhaustion | A concrete platform/context/usage/execution/resource boundary prevents further useful execution. | Preserve a durable runnable checkpoint, exact observed boundary, source/branch/worker/evidence status and exact next commands. Mark paused/awaiting continuation; do not claim background execution. |
| User-authorized program termination | The user explicitly says to stop because satisfied or changing direction. | Follow that instruction and preserve the requested final/handoff state. No worker or quality estimate substitutes for this decision. |

At every checkpoint: (1) preserve the verified baseline/evidence/decisions; (2) select the highest-value next improvement; (3) update the workbench and continuation; (4) immediately execute or investigate it; (5) repeat. If review finds no consequential defect, choose a meaningful creative/experiential improvement rather than ending the loop. Preserve source hierarchy, Sol-first model policy, evidence ratchet and active independent workers.

A boundary must be actual, not inferred from finished work, a long turn, a clean handoff, an arbitrary cycle count or anticipated context pressure. Use available compaction/continuation within the session. Record the concrete blocking observation honestly; never relabel a voluntary stop as an enforced session boundary. When a task ends and another authorized task is available, the next action is execution, not a final report to the user.


## User-directed workflow correction — 2026-10-19 (highest priority for Gauntlet execution)

**Develop continuously; validate proportionately; build Android at meaningful milestones.** This explicit user direction supersedes earlier instructions anywhere in the repository that require a full regression suite, fresh independent criticism, motion/screenshot archives, detailed forensic evidence, or native APK certification for each small design or gameplay step. Keep the existing tests, tools, archived evidence, and verified APKs available. Do not discard previous work.

- **Daily iterations (art, sound, copy, UI, local gameplay):** implement in Godot on focused branches/copies, use fast relevant unit/scene tests and desktop play/captures as needed to judge the actual result. Git commits are checkpoints, not releases. A passing complete Android build is not an entry or exit condition for each iteration.
- **Feature or chapter integration:** run relevant focused tests and affected regressions; test ordinary gameplay in desktop builds. Run a broader suite when interactions, persistence, or core invariants materially change. Fix observed failures. Avoid rerunning unchanged suites and collecting redundant evidence. Existing automated tests may run in CI when cheap; do not block iteration on exhaustive capture/audit rituals.
- **Milestone / device-specific / user playtest:** build one coherent Android APK after several meaningful changes or when Android input, layout, lifecycle, save, audio-device, or performance behavior specifically requires native verification. Run the appropriate full suite and inspect the relevant native evidence once for that milestone; retain prior verified APK as fallback. Build sooner for an actual Android-specific blocker, not merely because a small feature landed.
- **Independent critics:** use for substantial playable chapters, meaningful experiential choices, high-risk regressions, and release milestones, not automatically after every feature or tiny change. One scoped critic is enough unless a distinct regression risk justifies another. Record concrete failures and implement fixes; a reviewer report is not a dependency for ordinary iteration.
- **Documentation:** keep WORKBENCH and CONTINUATION short and current: what is playable, what changed, what failed, and next highest-value gameplay improvement. Git history is the normal version ledger. Add detailed validation records only for genuinely significant risks, irreversible decisions, native milestones, or defects whose reproductions matter. Do not require comprehensive evidence archives before committing functional progress.
- **Scheduling and priorities:** favor completed coherent gameplay, mission differentiation, polished visual/audio feedback, and player experience over repeated certification of tiny deltas. Integrate reviewed Blackwater and then loadout clarity using the lightest appropriate checks; batch subsequent Android validation to a meaningful playable milestone unless a specific native risk appears. Keep ongoing Gauntlet autonomy and source/design constraints unchanged.
- **Safety invariant:** never merge known broken core gameplay, save compatibility, or build-breaking changes; run targeted guards before commit. A milestone full validation and a final release-quality acceptance gate remain mandatory. Explicitly distinguish desktop proof, automated native proof, and physical Fold7 user testing.

When historical continuation notes say "next single action" is native certification of an otherwise desktop-reviewed small change, interpret that as milestone-pending unless a concrete Android-specific defect demands immediate validation. This policy governs all future workers and review instructions; inherited older stage gates do not override it.

### Branch-per-design and single-reviewer integration (2026-10-19 clarification)

User-directed operating model: **one dedicated Git feature branch per independently mergeable design/implementation change, continuous parallel progress where work is independent, and one assigned integration reviewer for each proposed merge**.

1. Branch from the latest integrated `gauntlet/production` tip, e.g. `gauntlet/feature/blackwater-evidence`; define the owned files and expected player-facing change. Commit useful increments on that branch. Do not share a mutable feature branch between unrelated workers.
2. Work continues on other nonconflicting feature branches. Do not serialize independent design development behind one branch's full suite, evidence packaging, independent reviews or Android APK build.
3. Before merge, **one designated integration reviewer** examines the actual diff, verifies it still fits the game and current baseline, checks interactions/conflicts/asset provenance and save compatibility where relevant, and runs or requests *targeted* tests. The reviewer reports concrete fix requests or approves. A second reviewer is exceptional and justified by a distinct high-risk concern, not routine ceremony.
4. Reconcile approved branches against the current production tip, resolve conflicts deliberately, and recheck the changed surfaces. Merge through a reviewable PR/merge (or equivalent explicit integration commit). Prefer one clearly assigned integrator to avoid concurrent pushes to the shared branch. Never silently overwrite other branches or uncommitted work.
5. Keep `gauntlet/production` in a playable, known-working state. A branch needing larger experimentation stays separate. When one branch lands, subsequent branches reconcile against that newer source rather than replacing it with a stale snapshot.
6. Periodically build and validate an Android APK for a **coherent batch of merged features** or an observed Android-specific problem, with full milestone/release gates as defined above. Feature-branch approval does not require producing an APK.
7. Preserve prior reviewer findings and failure reproductions; don't force each new design through repeated external criticism or identical audit records. Track simple statuses: developing → review → reconcile → merged; blocked means a concrete unresolved defect or conflict.

If inherited ownership notes say only root can push, treat that as the shared-branch integrator role; implementers may push their own dedicated feature branches if authorized and technically supported. Active isolated work can be promoted into feature branches without restarting it.
