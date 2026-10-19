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

**Default model: Sol 6.1** for implementation, tests, review, visual criticism, integration, and all delegated/subagent tasks where model selection is available.

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
