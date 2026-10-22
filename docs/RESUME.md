# RESUME: the one entry point (rewritten 22 Oct 2026, 7:20 PM EDT / 23:20 UTC)

Older status blocks from 21 Oct are in git history and in docs/SESSION_LEDGER_2026-10-21.md. This file is current. If it disagrees with a PR or branch you can see, trust GitHub and update this file.

## 0. Who you are and what to do first
**New Claude session (root orchestrator):** say "Read docs/RESUME.md, then continue the Gauntlet." Then: (1) `git fetch origin`; read sections 1 to 3 below; (2) open PRs: `mcp__github__list_pull_requests` (load via ToolSearch); (3) check docs/codex/BOARD.md on branch codex/handoffs for Codex progress; (4) do the "next actions" in section 4 in order. Do not re-read the whole governance set; Pat is not a professional developer: plain language, Eastern times, no em dashes, no jargon.
**Codex:** open branch codex/handoffs, read docs/codex/README.md (Step 0 orientation, push-WIP rule, batch rule), take the lowest OPEN handoff whose precondition is met (PRIORITY ones first). Mark DONE and update docs/codex/BOARD.md in the same commit.
**Pat:** nothing required. To restart Codex paste the prompt in docs/codex/README.md (also in section 7). To restart Claude say the line above.

## 1. The game and the rules that govern it
Siren's Song: Android-first 2D tactical submarine stealth and PHOTOGRAPHIC RECONNAISSANCE game (Godot 4.6.3, GDScript, game in game/). Vulnerable military recon sub USS Quietus plus two drones investigate the Sirens (superior aliens who were here first and built the factory). Photography is the core pillar (docs/PHOTO_RECON.md). Ops 0 to 29 exist; 0 to 5 are the tutorial arc.
Read in this order (each is short): docs/USER_DIRECTIVES.md top sections (Pat's orders, newest first: STANDING DELEGATION, STANDING ENGINEERING RULE, INPUT PRIORITY touch-first, depth-band and campaign/ending answers), then AGENTS.md, docs/CURRENT_GAME_SPEC.md, docs/PHOTO_RECON.md, docs/SESSION_LEDGER_2026-10-22.md.
Hard rules: Android touch is primary (48 dp targets, Android Back = Escape, keyboard fallback only). Features are self-contained modules with one narrow seam, numbers in data tables, optional validated save fields, a revert note in the module header (see docs/MODULES.md once handoff 033 lands). Do not change combat (beam kills Quietus outright after a 4 s lock warning), collision, damage, hull or Siren sight/hearing rules without Pat. V7 Sirens have no sonar. Story text stays 1 to 2 line placeholders. No APKs. Never push to gauntlet/production or main; only Pat promotes. Delete no branches.
Pat's standing delegation: build to spec on your understanding of the plan; ask only for changes to the rules above, story/characters/endings, new design pillars, irreversible things, or when the plan is unclear.

## 2. Testing and merging
Setup: `export PATH=$HOME/.cache/sirens-song-toolchain/bin:$PATH; scripts/toolchain/install-godot.sh; scripts/toolchain/headless.sh --editor --import --quit`. Core suite: `scripts/toolchain/headless.sh --script res://tests/run_tests.gd` must end `CHECKS N FAILURES 0` (817 at last count). Run import, core, and only tests for what you touched. Never run the full scenario list locally; GitHub game-smoke (about 25 minutes) is the gate. CI stops at its first red test, so after a failure also run the later CI-list tests locally. A Godot "resources still in use at exit" line fails CI. Do not commit generated .uid files integration does not track. Merge a PR into claude/integration with a merge commit only when guidance and game-smoke are green on the exact head AND the head contains the current integration tip (if integration moved, merge it in and recheck). Tags cannot be pushed from the sandbox. GitHub tools are mcp__github__* (no gh CLI).

## 3. State at 23:20 UTC 22 Oct
claude/integration tip: check `git log -1 origin/claude/integration`. Landed today: PRs 65 PHOTO1, 66 ONBOARD1, 67 PHOTO2, 68 lock warning, 69 Priced Shots, 70 sweeper on V7 senses, 71 controls friction, 72 challenge mode, 73 performance.
OPEN: PR 74 DEPTH1 (branch claude/depth1, handoff 018, Claude's): depth-band photos, findings displays, ALL STOP. game-smoke was re-running on head f2278c3 (merged with PR 73). Merge when green per section 2. Fallback: Codex handoff 028 lands it if the branch is idle 90+ minutes.
Waiting on PR 74: handoffs 016 (test list; Codex stops while any open PR edits the workflow file), 019, 020, 023 to 027. Available to Codex now: 022, 029, 030, 031, 032.
Parked WIP branches (safe, do not delete): claude/lane-n1-calder, claude/lane-p2-economy, claude/lane-c2-wip-b, claude/future-siren-active-sonar-sweeper (original active-sonar sweeper, a possible hard mode).
Design documents (committed on branch codex/handoffs under docs/design/): COLD_REVIEW_1, DESIGN_TRADES_FITTINGS (Priced Shots), DESIGN_DEPTH_FINDINGS, DESIGN_CAMPAIGN_DEPTH, ARCH_AUDIT_1.

## 4. Next actions, in order (about the next 5 hours)
1. Land PR 74 (watch checks; builder may be gone; use handoff 028 procedure). After it merges: mark 018 DONE on the board and tell Pat "Codex: 016 is clear".
2. SECOND COLD REVIEW (Claude): fresh critic agent with no build notes, real touch input, played from mission one, judged against Iron Lung and a publishable AAA stealth game; questions: is photography compelling and central, are the trades (film, light, band, all-stop) readable on a phone, can a new player discover solutions, any softlocks or save errors, plus the five V7 differences in docs/codex/012-v7-parity-gap-report.md Completion. Output a ranked fix list to Pat and the scratchpad; do not add content until it is read. Compare with Codex's own review (handoff 026) when done.
3. Next Claude builds, one at a time, each its own branch and PR with a designated builder agent (briefs follow the pattern of earlier ones: read docs/USER_DIRECTIVES.md top, the design doc, only needed source; modular; push WIP often): (a) from the cold review's top finding; (b) SIREN TELL after sweeper settles (needs Pat); (c) sweeper lane walking via authored patrol points; (d) a band-guarded subject for the pressure sleeve if DEPTH1's single seam proves thin.
4. Watch Codex: each time two of the three handoffs in a batch show DONE on docs/codex/BOARD.md, write the next three (see BOARD for numbering; designs in docs/design/). Keep at least 5 hours of OPEN work ahead of Codex.
5. Keep docs current at each merge: this file (RESUME), docs/SESSION_LEDGER_2026-10-22.md, docs/CONTINUATION.md and docs/WORKBENCH.md (each under 40 lines). Run `python3 scripts/toolchain/gauntlet-boundary.py --boundary complete` at task boundaries.

## 5. Decision gates for Pat (ask in plain language, one question at a time, with a recommendation)
Anything touching combat, beam, collision, damage, hull or Siren sight/hearing beyond approved items; new story text, characters or ending content; the SIREN TELL idea; promotion to gauntlet/production or main; art direction judgments (handoff 032 is his to judge); any new design pillar. Already answered (do not re-ask): see USER_DIRECTIVES.md entries for 22 Oct.

## 6. Known caveats
No human or physical-device play has happened; all checks are headless, software-rendered or injected touch. Band, film and all-stop numbers are first-pass. archive_recap_ui_tests may be stale (handoff 016 reviews it). The Well (op 4) was re-tuned by moving the dormant hunter's post. Codex runs only when Pat pastes its prompt; Claude builder agents die when a session ends but their branches survive.

## 7. Codex restart prompt (Pat pastes this)
```
Continue. Open the repo pemunson90-cmd/Siren-s-Song, branch codex/handoffs, and read docs/codex/README.md first. Do its Step 0 orientation and read the "Claude may be absent" and "Push work in progress" sections. Take the first OPEN handoff in numeric order whose precondition is met (a PRIORITY or FALLBACK handoff first). After each, mark it DONE in its file and update its row in docs/codex/BOARD.md in the same commit. Commit and push your lane branch at least every 30 minutes. Ignore anything marked HOLD or CLAIMED. Stop when none are OPEN and tell me plainly which are DONE.
```
