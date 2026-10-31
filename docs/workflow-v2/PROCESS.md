# Target process (workflow v2)

Drafted 2026-10-30 by Claude (Fable 5.1). Not live. Switches on only after Pat approves (see QUESTIONS_FOR_PAT.md and MIGRATION.md). Every rule here is judged by one test: does it make the game Pat wants more likely, sooner, for less. Anything that only proves a workflow happened is out.

## 0. The loop in one paragraph

One ratified **intent card** says what the player does and what must stay hard. A short **queue** of items, each a player-facing gain plus an acceptance test, is built by whichever provider is available, in isolated worktrees that cannot touch the same files. Each PR carries evidence sized to its change class, gets one reviewer and one intent check, then a script merges it serially onto a green integration branch. Every night a scripted whole-game run reports metrics against the intent card. Every milestone, blind critics play a tagged build against the intent card and named reference games, a milestone assessor ranks the next plan, and the workflow itself gets a short review. Pat reads one digest a day and answers one yes/no question at a time.

## 1. Roles and models

| Role | Who | Model and effort | Notes |
|---|---|---|---|
| Owner | Pat | | Rules and approves in chat. Never operates tools. |
| Orchestrator | one Claude session | Opus 5.5, medium | Intent checks, ranking, queue order, digest, questions. Never builds inside its own context. |
| Milestone assessor | one fresh Claude session per milestone | Opus 5.5, high; Fable 5.1 only for an architecture-level decision or a demonstrated impasse | Reads critic verdicts, metrics and reference pairs; writes the ranked plan and the workflow review. Replaces the Astra role. |
| Builder | fresh headless session per item, launched by the runner | Codex gpt-6.1-sol medium when available; otherwise Claude Sonnet 5.5 for text, UI and presentation items, Opus 5.5 medium for simulation, persistence and campaign-structure items | At most 2 builder sessions alive at once across both providers. No fan-outs. One item, one worktree, one branch. |
| Reviewer | one fresh session per PR | The other provider when both are up: Codex gpt-6.1-sol high reviews Claude-built PRs; Sonnet 5.5 (text/UI) or Opus 5.5 (sim) reviews Codex-built PRs | Fixed checklist, verdict of at most 10 lines. Reviews the frozen head only. |
| Blind critic | fresh session per region per milestone | Sonnet 5.5 (reads screenshots); Codex gpt-6.1-sol when Claude is out | Hard cap: 400 commands or 150k context per region, then a fresh session from the progress file. |
| Mechanical helper | Haiku 5.5 | | Evidence folding, log triage, digest draft, suite-selection sanity. Read-only. |

Why Claude builds: the ban on Claude subagents came from unbounded fan-outs (S2's 45 agents, S3's 9 parallel lanes), not from Claude building per se. A single bounded builder session per item is the same shape as a Codex fresh session and costs a small fraction of one (Codex fresh sessions ran 35 to 55M tokens each on 29 Oct). Both providers must be able to fill every role so that an outage pauses nothing but critics at worst. This needs Pat's yes (question 1).

Why Codex stays: it is the cheaper builder per item when its usage is available and its reviewer catches different mistakes than a Claude reviewer. Cross-provider review is the default when both are up.

## 2. Unit of work: the item

An item is one player-facing gain that one builder can finish in one session, touching files in one ownership area, with an acceptance test named before work starts. Template: ITEM_TEMPLATE.md (40 lines max).

- **Goal**: two lines, what the player gets.
- **Acceptance test**: a suite, harness run or screenshot check that fails before and passes after. Named, not described. Measured output, not prose.
- **Change class**: text, ui, sim or protected. The class decides the evidence (section 5) and the reviewer model.
- **Areas and files**: the ownership areas and globs the item may touch. The runner refuses to start two items whose areas intersect. `main.gd`, `mission_hud.gd`, `ocean_view.gd` and `simulation.gd` are serial zones: one live item at a time.
- **Protected rules touched**: none, or the ruling line verbatim with its date.
- **Size cap**: about 400 changed lines. Larger work is split before it is queued.

Lanes are replaced by area locks. The two-lane fencing by hand (126 versus package 2 inside `mission_hud.gd`) failed because a concern is not enforceable; a file glob is.

## 3. Branches and integration

- `claude/integration` stays the one development line. Feature branches `item/NNN-slug` target it.
- `main` is the accepted baseline and the only promotion target. Promotion is a PR from integration to main at a milestone, tagged `milestone-YYYYMMDD`. Pat says yes in chat; the orchestrator merges. Critics play the tagged build.
- `gauntlet/production` is kept, never deleted, and stops being a target. Its last promotion is the record of where v1 ended. This needs Pat's yes (question 2).
- Merges are merge commits. No rebase, amend or force push on any shared branch, ever.
- **Serial merge**: only the runner merges, one PR at a time, in queue order. Before merging it merges integration into the PR branch and waits for the full matrix on that exact head. Builders never merge. If GitHub's merge queue is enabled on integration (the repo is public, so it is available), the runner enables auto-merge and GitHub does the same thing; the rule is identical either way.
- Branch retirement: the runner records each merged item's branch in STATE.md and leaves it. Stale worktrees are pruned when their directory is gone (`git worktree prune`, which deletes nothing on the remote). No branch deletion.

## 4. Testing

Three tiers, each with a purpose.

| Tier | When | What | Budget |
|---|---|---|---|
| Local, before every push | builder | import, core, the affected suites chosen by `select-suites.py` from the diff, plus the canary set (the ruling tests in RULING_TESTS.md) | about 10 to 15 minutes |
| PR check, on ready-for-review pushes only | CI | the same selection, on the PR head; draft PRs do not run game jobs | about 15 minutes |
| Full matrix | CI | all 354 suites, duration-balanced 4 shards | only on the merge candidate (merge queue or runner phase C) and nightly on integration |

Rules:
- Never skip, loosen or delete a test to get green. A test that asserts behaviour Pat changed is updated with his ruling line in the commit message.
- The full matrix runs once per merge, never per push. That alone removes most red rounds: a push cannot break a test it does not touch and still merge, because the merge candidate runs everything.
- Shards are balanced by recorded suite durations, not by count (`suite-times.json` written by CI, read by `test.sh --shard`).
- The ruling tests encode Pat's design decisions so they cannot regress silently: release play exposes no one-press travel; finishability is measured with a hand-piloting policy; protected constants are pinned; crashing remains possible. Details in RULING_TESTS.md.
- Nightly on integration: full matrix plus the hand-pilot whole-game run that writes `metrics.json` (section 6). A red nightly creates a fix-forward item at the head of the queue.

## 5. Evidence, by change class, with a hard cap

| Class | Required proof | Cap |
|---|---|---|
| text | diff of the strings; one screenshot per changed screen at the shape it appears on | PR body 20 lines, 2 PNGs |
| ui | before and after screenshots of each changed screen, both shapes, 100% and 150%; native layout test counts | 40 lines, 8 PNGs |
| sim | hand-pilot finishability table for the affected ops only (time, Hunt peak, locks, hull, oxygen, legs placed, collisions, drones recovered) on STANDARD and ACCESSIBLE; one line stating the voyage hash of unaffected ops is unchanged | 40 lines, one table of at most 14 rows |
| protected | Pat's ruling line verbatim; the golden-constant diff; two full-op causal contrasts showing the ruled change decides play | 60 lines |

Raw logs, PNG sets and voyage JSON live in the artifact cache under `artifacts/items/NNN/` with a SHA-256 manifest, linked from the PR. Nothing larger than the cap goes in a PR body, a commit or `docs/`. Reviewer verdicts are 10 lines; the intent check is 5 lines plus `INTENT: PASS` or `INTENT: HOLD <reason>`.

## 6. Game evaluation

Three layers, so a design-level problem surfaces in days.

**Nightly metrics (scripted, free of model cost).** The hand-pilot policy plays every core op and one run of each side mode on integration and writes one table: finishable by hand (yes/no per op and preset), time, hull, Hunt peak, locks, legs placed, collisions, stuck-holds, drones recovered, and the **control mix**: the share of movement distance ordered through one-press travel versus planned legs. Any op where the control mix exceeds 50% one-press is flagged. In release play that number must be zero because the orders do not exist. A render run under Xvfb records frame time per op as a desktop proxy. The soundscape event log records dropped voices and overlapping cues. The orchestrator reads the delta, not the table.

**Milestone blind critics (model cost, bounded).** On each tagged build, four regions in parallel (opening, middle, late through END OF LINE, side modes), fresh sessions, the fixed kit with its watchdog (CRITIC_HARNESS.md). Each critic receives the intent card and answers three questions per op in a fixed form: what did I decide, what did I watch, what did I not understand. A coverage contract is checked before the verdict is accepted: the ending reached by at least one critic, every side mode entered, both shapes, 150% text once. Stalls are classified HARNESS unless `godot.log` shows a script error.

**Reference comparison (blind, matched).** For each piece in the plan (commands, chart and touch, HUD and threat, fleet and extraction, route flow, prep and results, look and sound, mission variety) one matched task is captured from our build and from the named reference game using public footage, labels removed. A fresh critic picks the stronger one and says why in three lines. The ratchet keeps only changes that win their pair. Recognised games are disclosed, not hidden.

**Audio and phone feel, honestly.** No model here perceives sound or holds the phone. Audio gets a structural audit (voice saturation, cue collisions, missing cues in dense events) from the event log, and Pat gets one yes/no at a milestone playtest ("did the lock warning read by ear"). Frame rate on Android needs an APK, which Pat decides; the desktop frame-time proxy is labelled a proxy. Pat's playtest never gates development.

**Milestone assessor.** One fresh high-effort session reads the three layers and the intent card, ranks the next plan by player cost, and writes a one-page workflow review: where time, tokens or CI rounds were wasted, one or two fixes. That satisfies Pat's "mini gauntlet on our own workflow" ruling.

## 7. State and memory: one source of truth

All live state lives in `docs/state/` on the `codex/handoffs` branch (renamed in spirit, not in Git, to avoid churn). Five small files, each with one owner:

| File | Owner | Content | Size cap |
|---|---|---|---|
| `STATE.md` | runner writes, orchestrator edits the "next" line | integrated base, items in flight with phase and head, blockers, next action, PAUSED block when applicable | 60 lines |
| `RULINGS.md` | orchestrator, append-only | Pat's words, verbatim, dated, one per line, plus the intent card | grows slowly |
| `DECISIONS.md` | orchestrator, newest first | agent decisions: what, why, revert | 120 lines rolling, older ones archived |
| `queue.json` | runner | items, areas, phase, provider, head, attempts | machine-read |
| `items/NNN.md` | orchestrator writes, builder reads | the item (ITEM_TEMPLATE.md) | 40 lines each |

Startup reads STATE.md, the last 20 lines of RULINGS.md, the first 20 lines of DECISIONS.md and `runner status`. Under 8 KB. HANDOFF, BOARD, LEDGER, QUEUE_S6, PLAN_DRAFT, CONTINUATION, WORKBENCH and RESUME status prose are retired: frozen in `archive/workflow-v1-2026-10-31` (a branch, kept) and a dated zip with SHA in the artifact cache. The runner's banner becomes a local `status.txt`, not a commit. The phone tracker is generated from `queue.json` by a script, never hand-edited.

The repo's lean-git rule holds: critic reports, metrics history, screenshots and logs stay in the artifact cache under dated folders with manifests; only compact verdicts (one file per milestone, under 25 KB) are committed, to `docs/design/`.

## 8. Pat's interface

- **One digest per day**, phone-sized (12 lines max): what merged, what the nightly metrics changed, the one weakness being worked, any blocker, and at most one yes/no question with the recommendation first. Pushed as a notification only when a question blocks work.
- **Decisions he can revert**: each entry in DECISIONS.md has a `Revert:` line that names one command or one PR to revert. Pat says "revert D14" and the orchestrator does it and reports in one line.
- **Milestone card**: one screenshot of the game played as designed, the six nightly metrics that moved, the three top weaknesses, the one question.
- Protected rules, art direction, story canon and real forks are the only things he is asked. Everything else is decided, logged, reported.

## 9. Failure handling

| Failure | Response |
|---|---|
| Provider outage | Items carry no provider. The runner probes both providers each tick (a one-line exec) and launches on the one that answers. If neither answers, it parks the queue, writes PAUSED to STATE.md with the resume command, and the orchestrator does read-only work (ranking, critic synthesis, item writing). |
| Red CI on the merge candidate | The runner writes the failing assertions to the item's notes and relaunches phase A once. A second red marks the item BLOCKED with the failing lines and the queue moves on. No orchestrator edits to runner state. |
| Red nightly on integration | A fix-forward item goes to the head of the queue. A revert PR is allowed; a force push is not. |
| Stalled builder | Notes file silent for 45 minutes: the runner kills the session, relaunches once from pushed WIP, then BLOCKED. |
| Critic harness fault | The kit's sender has a 60 s watchdog and a driver heartbeat. A missing result is logged HARNESS and the critic continues; it never writes "game hang" without a `godot.log` excerpt. |
| Usage limit, Claude | The runner keeps building with Codex; PRs wait for the intent check with `INTENT` pending. STATE.md gets a PAUSED block with the resume command. |
| Usage limit, Codex | Claude builds. Critics wait for a tagged milestone or run on Sonnet. |
| Rule conflict found | The file with the newer date wins; the orchestrator fixes the older line the same day and logs a decision. One runner, one prompt template, so the full-suite contradiction of 30 Oct cannot recur. |
