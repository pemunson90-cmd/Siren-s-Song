**Identity (user-ratified 22 Oct):** Siren's Song is first a military photographic reconnaissance game (Iron Lung influence); rescue, industrial and fleet work support it. Read docs/PHOTO_RECON.md. Implementation and evidence status live in docs/PHOTO_RECON.md; current work lives in docs/RESUME.md.

**Development integration:** `claude/integration`. `gauntlet/production` is the frozen promotion baseline; `main` is the protected accepted baseline. Pat authorizes promotion to either. Operational status: docs/RESUME.md. Codex assignments and claims: docs/codex/BOARD.md on `codex/handoffs`.

> **READ FIRST — CURRENT USER ORDER:** docs/USER_DIRECTIVES.md. Implement the approved full-release expansion; preserve accepted Pass0/V7 systems. User playtest timing never gates work.

# Siren’s Song — Gauntlet operating instructions

Continually assess the whole playable game, identify its most consequential weakness, improve it, evaluate actual player experience, and repeat. Build toward AAA-caliber Android content and execution. The user alone ends the Gauntlet. Milestones, passing checks and internally assessed readiness lead to the next highest-value work.

## Current execution contract

**Current user boundary (23 October Eastern):** finish PR96, save later ARCH2 preparations, reconcile stale documentation and prepare the Windows desktop handover, then STOP. Do not start metrics, the feature contract or the next handoff in this cloud session. Read docs/DESKTOP_HANDOFF.md and docs/RESUME.md. Resume only when Pat asks; this overrides automatic continuation below without declaring the project finished.
Read docs/USER_DIRECTIVES.md first. It records the latest order correction and governs earlier workflow prose. The unchanged audit and frozen-source response remain on archive/claude-audit-2026-10-19 under docs/audit/.

Current user directive: **implement the approved full-release program** in docs/CURRENT_GAME_SPEC.md. Earlier Pass0 rough-only and small-iteration limits are historical. Build reusable operation systems, depth-aware stealth/sonar/enemies/fleet, a complete campaign and replay package, expeditions and naval career, with production presentation and Android quality. Use Sol6.1 Medium, one implementation worker and one independent integration reviewer; broader critics run sequentially at substantial milestones. Preserve existing work/profiles and use coherent feature batches. No new governance tooling or approval gates. docs/CONTINUATION.md and docs/WORKBENCH.md stay under40 lines each.

The user decides when to playtest; user play never gates development. Agents keep closing on the specification and external quality bar throughout execution. Preserve user agency over playtesting and keep developing autonomously. A task, worker, plan, review or milestone completion starts the next authorized action within the assigned scope. Codex follows its existing handoff protocol on codex/handoffs: complete its claim, then take the next eligible OPEN handoff; preserve HOLD/CLAIMED work and stop when no authorized handoff remains. Actual platform/usage exhaustion requires published recovery refs and PAUSED, RESUME REQUIRED with the exact next command. State execution honestly when a session ends.

## Development and integration
1. Rank player-facing weaknesses across tactics, stakes, operations, controls, story, world, art, sound and technical quality. Examine actual source, playable v7 and relevant successful games.
2. Develop coherent gains on dedicated feature branches/worktrees with explicit ownership. Reuse inactive worktrees and one shared toolchain. Preserve other workers’ edits and all unique evidence.
3. Use one designated integration reviewer for actual source changes, gameplay consequences, current-save integrity and relevant targeted checks. Fix consequential regressions before integration.
4. Complete coherent assigned batches on their dedicated branches, with independent review and final-head guidance/game-smoke CI before PR integration into `claude/integration`. Reconcile the fetched integration tip into the proposed head and recheck when it moves. Claude orchestrates; Codex may merge only under its current handoff/delegation permission. Preserve the frozen `gauntlet/production` and protected `main` baselines; promotion requires Pat. Preserve all published work and recovery refs.
5. Validate primarily in Godot, locally or through GitHub. Batch broad regression at meaningful integrated passes. Current Pat rules prohibit Android APK builds and defer physical-phone testing until feature complete and bug free; native-specific risks do not grant an exception. Reuse the canonical Git-tracked debug signer.
6. Evaluate actual gains and costs, then immediately continue. Every hour of simulation, layout and encounter work should outweigh an hour of documentation.

## Merge handoff and reviewer provenance (existing boundaries)
At the usual PR review/merge boundary, root fetches the live claude/integration tip and the exact proposed head. The SHA in `docs/RESUME.md` is the **last reconciled source baseline**, not a self-referential promise to equal the merge commit containing the document; the freshly fetched integration ref identifies live development. A different SHA alone is not a stale-document failure. Reconcile substantive state and next work rather than making follow-up commits merely to chase HEAD.

For each feature PR, root records a linkable, attributable independent reviewer verdict in the PR before merge: reviewer identity/role, reviewed head (and integration base), blocker findings or none, their disposition, and the relevant CI run. Use a submitted GitHub review where possible; otherwise copy the review into a PR comment or description with its original provenance and explicitly label it a **relayed review**, not a formal GitHub approval. Passing CI establishes test success, not independent criticism.

At each merge, root reconciles `docs/RESUME.md` against the integrated feature; `docs/CONTINUATION.md` and `docs/WORKBENCH.md` remain short pointers. Root includes the needed status/next-action corrections in the normal feature PR. If no game state, ownership or next action changed, record that decision in the PR instead of creating a meaningless document edit. After merging, fetch the new integration tip, confirm the landed source, and continue the next authorized task. Apply this during **existing** task/review/merge boundaries; do not reset active workers, gate user playtesting, introduce a new CI gate or build an additional orchestration layer.

## Critics stand in for players
Fresh critics start without builder history, explanations or winning routes. They inspect the actual running game and play full operations through real injected touch on actual cover and inner views. Give distinct cautious, aggressive, drone-heavy and Quietus-only strategies. Record their actual routes, time, losses, confusion and unused options. Button callbacks and scripted controllers remain useful technical tests with their narrower scope.

Use blind, anonymized side-by-side comparisons with real reference footage, one dimension each: Door Kickers for route/touch planning, Mark of the Ninja for detection readability, Barotrauma for acoustic tension, Duskers for drone tools/scarcity. Critics select the stronger experience without source labels; disclose recognizable identities and other comparison limits. The external bar keeps rising independently of internal output counts. Agent play supports development while human enjoyment, headphone audio and physical Fold7 ergonomics retain distinct limits.

## Authority and architecture
Current user decisions > living docs/CURRENT_GAME_SPEC.md and accepted amendments > ratified design bible/visual selections > demonstrated behavior > historical provenance > proposals. Apply docs/SOURCE_AUTHORITY.md and docs/V7_TO_GODOT_PARITY.md. Actual playable v7 outranks older prose about its implemented mechanics; preserve its source unchanged. The six original missions are the tutorial foundation for a longer branching campaign with craft growth, story and multiple endings.

Preserve Godot4.6.3/GDScript/Compatibility and established simulation/campaign/persistence/presentation/audio boundaries in docs/architecture/GAUNTLET.md. Maintain physical movement, unlimited tactical pause, fair information, finite tools and independent craft. Publishing administration is outside the game-development grant.

## Task closeout and instruction refresh
At task/dispatch/review/merge boundaries fetch current integration guidance with scripts/toolchain/gauntlet-boundary.py, read changed governing files, reconcile user decisions and stale handoffs, and execute the next highest-value task. Treat the structural checker as supporting machinery. Root owns orchestration, PR reconciliation and continuity after workers finish.

Substantial implementation/review defaults to gpt-6.1-sol with fresh context when selectable. Record requested routing separately from unavailable backend/effort telemetry. Use minimal useful parallelism with clear ownership.

Keep source/assets/tests/tools and concise live instructions on production. Store raw reports, screenshots, video and metrics in recoverable external archives. Preserve branch refs, unique/untracked evidence, saves and signing material during housekeeping. Communicate concrete actions, results and player gains affirmatively; explain limitations when they affect actual expectations.

## Guidance ownership
USER_DIRECTIVES records ratified decisions; AGENTS owns stable execution rules; CURRENT_GAME_SPEC owns intended behavior; PHOTO_RECON owns camera capabilities and gaps. RESUME alone owns the reconciled operational snapshot and links live PRs/refs. The codex/handoffs board alone owns Codex claims and completion. Session ledgers retain dated history. At closeout compare assertions with fetched source, PR state and evidence; a structural guidance pass cannot establish semantic accuracy. Existing installed hooks adopt a changed refresh helper only through explicit reinstallation at a safe session boundary.
