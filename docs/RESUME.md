# RESUME (living handoff; updated at each merge; if usage ends this is the state)

Status: RUNNING (flip to PAUSED, RESUME REQUIRED if usage ends). Branch: `claude/integration`. Lane table: docs/LANES.md.
Orchestrator brief: Pat's kickoff (21 Oct): root merges lane PRs into claude/integration after green CI; Pat approves promotion to gauntlet/production; no APKs; more game than docs; story is provisionally approved (docs/STORY_BIBLE_DRAFT.md).

Merged into integration (tip 31bded5, core suite 758/0): X4 seam #52, X2 probes #53, X3 audio #54 (each CI green, relayed independent approval).
In flight (not yet pushed as PRs): claude/lane-c1-glass, lane-p1-fittings, lane-s3-rewrite, lane-a1-art, lane-f1-frontend.
X3 carries CC-BY attribution: frontend lane must surface Soundscape.ATTRIBUTION in credits. X2 baseline (ops 14-29, 4 policies) is in PR #53; T reruns it on its own head.
Done, unmerged: claude/lane-s1-inventory (story inventory, reference only, do not merge to keep Git lean).

Merge procedure per lane: git fetch; open PR lane -> claude/integration; wait for gauntlet-pr-checks (guidance + game-smoke) green; merge; run core suite locally
(export PATH=$HOME/.cache/sirens-song-toolchain/bin:$PATH; scripts/toolchain/install-godot.sh if missing; scripts/toolchain/headless.sh --editor --import --quit; scripts/toolchain/headless.sh --script res://tests/run_tests.gd ends CHECKS N FAILURES 0).
Merge order: x4 before T; s3 text before glass/iron text pass; c1 before c2.

Next lanes to dispatch: C2 Iron Choir de-template, S3b glass/iron strings + renames, T pressure (X4 and X2 now landed, unblocked), P2 economy/manufacturing, then challenges, roguelite (rename "expedition" first), naval career, settings polish, art/audio passes.
First command on resume: git fetch origin && git log --oneline origin/claude/integration -5 && read docs/LANES.md.
