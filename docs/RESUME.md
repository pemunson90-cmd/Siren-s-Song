# RESUME (living handoff; updated at each merge; if usage ends this is the state)

Status: RUNNING (resumed 21 Oct after usage ended; earlier lane workers had died, WIP snapshotted and pushed, fresh workers dispatched). Branch: `claude/integration`. Lane table: docs/LANES.md.
Orchestrator brief: Pat's kickoff (21 Oct): root merges lane PRs into claude/integration after green CI; Pat approves promotion to gauntlet/production; no APKs; more game than docs; story is provisionally approved (docs/STORY_BIBLE_DRAFT.md).

Standing orders from Pat (21 Oct, later): story minutiae and old-save compatibility are irrelevant until the game is finished; the five S3 placeholders and ending wording are accepted; do not hold work for story or polish. Priority is finishing the whole functional game, then critically evaluating it and finding the next improvement. Indefinite loop, nothing is ever good enough. Never wait on Pat; only a true blocker needing his input stops work. Notes: C1 ops 14-21 share one core objective (depth gap, follow up after C2). Reviews: C1 approved (PR 55), S3 HOLD then fixes (PR 56), P1 review pending (PR 57). C2 stacked on lane-c1-glass.

Pat's rulings (21 Oct, supersede earlier notes above): (1) Nova Mobiles is dropped (handoff was sent to the wrong chat). (2) Story: add any detail that does not contradict the provisional plot; do not reject or obsess. Hard rule: the Sirens were here first, have established a base (the factory), and are becoming dangerous; Quietus is a recon mission. Never aliens fleeing humans. (3) No per-feature independent reviewers. Merge on green CI. Review happens only at the checkpoint where the whole game is provisionally finished: a fresh critic with no build info plays/reviews the complete game as if first seeing it, judges it as a publishable AAA game, harshly and impartially, no sycophancy, lists every area that needs improvement, every time. Nothing is ever done until Pat says so. (4) Talk to Pat in plain language, no jargon.

Merged into integration (tip 31bded5, core suite 758/0): X4 seam #52, X2 probes #53, X3 audio #54 (each CI green, relayed independent approval).
Resumed (WIP pushed to branches, workers re-dispatched, no PRs yet): lane-c1-glass, lane-p1-fittings, lane-s3-rewrite. Codex owns lane-t-pressure (brief issued). lane-a1-art and lane-f1-frontend have no work yet and are parked.
X3 carries CC-BY attribution: frontend lane must surface Soundscape.ATTRIBUTION in credits. X2 baseline (ops 14-29, 4 policies) is in PR #53; T reruns it on its own head.
Done, unmerged: claude/lane-s1-inventory (story inventory, reference only, do not merge to keep Git lean).

Merge procedure per lane: git fetch; open PR lane -> claude/integration; wait for gauntlet-pr-checks (guidance + game-smoke) green; merge; run core suite locally
(export PATH=$HOME/.cache/sirens-song-toolchain/bin:$PATH; scripts/toolchain/install-godot.sh if missing; scripts/toolchain/headless.sh --editor --import --quit; scripts/toolchain/headless.sh --script res://tests/run_tests.gd ends CHECKS N FAILURES 0).
Merge order: x4 before T; s3 text before glass/iron text pass; c1 before c2.

Next lanes to dispatch: C2 Iron Choir de-template, S3b glass/iron strings + renames, T pressure (X4 and X2 now landed, unblocked), P2 economy/manufacturing, then challenges, roguelite (rename "expedition" first), naval career, settings polish, art/audio passes.
First command on resume: git fetch origin && git log --oneline origin/claude/integration -5 && read docs/LANES.md.
