# Migration: from today's process to workflow v2

Written 2026-10-30 by Claude (Fable 5.1). Nothing here is destructive. No branch is deleted, no history rewritten, no live file edited until its step runs. Each step names its owner: **[Pat]** means only Pat can say yes; **[Agent]** means the orchestrator does it alone and logs a decision Pat can revert.

What is reused on purpose: `auto.py`'s phase machine (A build, B verify and PR, C merge, handoff through notes, `INTENT: PASS` gate), Claude's intent check, the reference ratchet Pat approved on 30 Oct, the Haiku evidence base (`artifacts/evidence-base/`) and the critic kit's v3 driver that root installed as package 0. The PLAN_DRAFT_1 packages become the first items in the new queue.

## Order of steps

| # | Step | Owner | Touches | Revert |
|---|---|---|---|---|
| 0 | Read the six-line summary. Answer question 1 (Claude may build, bounded). Nothing below runs before this answer. | **Pat** | chat | say no |
| 1 | Freeze v1: create branch `archive/workflow-v1-2026-10-31` from the `codex/handoffs` tip. Zip BOARD, LEDGER, HANDOFF, QUEUE_S6, the notes files and `runner-state.json` into the artifact cache with a SHA-256 manifest. | Agent | new branch, cache | none needed, additive |
| 2 | Seed `docs/state/` on `codex/handoffs` from the v2 templates: STATE.md (from HANDOFF's state section), RULINGS.md (Pat's lines from PAT_RULINGS and USER_DIRECTIVES, verbatim and dated, plus the intent card marked UNRATIFIED), DECISIONS.md (D1 to D10 carried over, D11 onward from this folder), `queue.json` and `items/` for 126, 127, package 2 (PR 239) and packages 3 to 7. Old files stay untouched until step 10. | Agent | `codex/handoffs` docs only | one revert commit |
| 3 | Install `runner2.py` beside `auto.py` in the queue folder (QUEUE_RUNNER.md). Run it in `status` and `dry-run` mode against `queue.json`. `auto.py` stays stopped (Codex is out; its last tick was 22:28 on 30 Oct). | Agent | cache folder | relaunch `auto.py` |
| 4 | Unblock 126: push the reviewed repair commit `3cde47e4` from worktree `Siren-s-Song-codex-126` to `claude/truthful-commands` (independent approval recorded in `artifacts/126/repair3-independent-review.txt`), let CI run on PR 238, intent-check, merge by the runner. Needs step 0 yes because HANDOFF currently makes Claude read-only. | Agent after step 0 | PR 238 | revert PR |
| 5 | CI change PR into `claude/integration` (CI_CHANGES.md): draft PRs skip game jobs, affected-suite selection on PR pushes, duration-balanced shards, full matrix on the merge candidate and nightly, `select-suites.py` and `suite-times.json`. One reviewer. Evidence: one green run of each job type. | Agent | `.github/workflows`, `scripts/toolchain` | revert PR |
| 6 | Enable GitHub merge queue on `claude/integration` with required checks `guidance` and `game-smoke` (repo ruleset; the repo is public so it is available). Until it is on, `runner2.py` phase C does the same thing serially. | Agent | repo settings | disable the ruleset |
| 7 | Queue the ruling tests as items (RULING_TESTS.md): R3 protected golden, R4 crash possible and R5 control-mix telemetry can start now; R1 release-controls gate and R2 hand-pilot harness start when 127 lands. | Agent | items | drop items |
| 8 | Build 127 release controls with a Claude builder (Opus 5.5 medium, sim class) if step 0 is yes; otherwise it waits for Codex around 3 Nov. Then package 2 (PR 239, root's branch) is reviewed and merged as an ordinary item. | Agent | PR | revert PR |
| 9 | Critic kit v4 (CRITIC_HARNESS.md): sender watchdog, driver heartbeat, self-test, HARNESS classification, coverage contract, intent card in the brief, control-mix telemetry read. Base: root's v3 driver. | Agent | cache kit, `docs/CRITIC_BRIEF.md` via PR | keep v3 |
| 10 | Retire v1 docs: HANDOFF, BOARD, LEDGER, QUEUE_S6, PLAN_DRAFT_1 become 3-line pointers to `docs/state/` and the archive branch. On integration, CONTINUATION, WORKBENCH and RESUME become pointers; AGENTS.md is replaced by the v2 draft (PR); the guidance linter's file list is updated; the `siren-start` command reads STATE.md. | Agent | docs | archive branch holds everything |
| 11 | Ratify the intent card and amend `CURRENT_GAME_SPEC.md:73` ("safe pathfinding") to the 30 Oct ruling. Question 3. | **Pat** | spec | say no; the card stays UNRATIFIED and the tests still encode his 30 Oct words |
| 12 | Branch simplification. Question 2. At the next milestone: promotion PR integration to `main`, tag `milestone-YYYYMMDD`, `gauntlet/production` frozen and kept. | **Pat** yes, Agent executes | `main`, tag | promote to production again |
| 13 | Hygiene: `git worktree prune` (removes registrations whose folders are gone; deletes nothing remote), move the 30 MB of Codex stderr logs into a dated zip. | Agent | local machine | none needed |
| 14 | First v2 milestone: with 127, package 2 and R1 to R5 landed and the nightly green, tag the build, run the nightly metrics, dispatch four blind critics on the hand-piloted game, run the reference pairs, then the milestone assessor writes the ranked plan and workflow review 1. Digest to Pat with the milestone card. | Agent | tag, cache, `docs/design/` verdict | none needed |

## What changes for each person

- **Pat**: one digest a day instead of ad-hoc updates; the same one-line questions; a `revert Dnn` command that works.
- **Orchestrator**: stops editing runner state by hand, stops writing BOARD rows and LEDGER lines, reads 8 KB at startup, spends its time on intent checks, ranking and items.
- **Codex**: same fresh-session shape, shorter prompts, no merging, no BOARD writes; a reviewer role for Claude-built PRs when it is up.
- **Claude builders**: new, bounded, one per item, launched by the runner like Codex sessions.

## What is deliberately not done

- No rename of `codex/handoffs` or `claude/integration` (churn without player value).
- No deletion of the 349 branches or the archive branches (Pat's rule).
- No APK (Pat's rule). Frame rate stays a desktop proxy until he asks.
- No rewrite of the test suites. Selection and sharding change; the tests do not.
