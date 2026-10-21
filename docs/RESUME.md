# RESUME (living handoff; updated at each merge; if usage ends this is the state)

Status: RUNNING (flip to PAUSED, RESUME REQUIRED if usage ends). Branch: `claude/integration`. Lane table: docs/LANES.md.
Orchestrator brief: Pat's kickoff (21 Oct): root merges lane PRs into claude/integration after green CI; Pat approves promotion to gauntlet/production; no APKs; more game than docs; story is provisionally approved (docs/STORY_BIBLE_DRAFT.md).

In flight (branches pushed by workers; each returns a PR-ready branch): claude/lane-c1-glass, lane-p1-fittings, lane-s3-rewrite, lane-x4-seam, lane-x2-probes, lane-x3-audio, lane-a1-art, lane-f1-frontend.
Done, unmerged: claude/lane-s1-inventory (story inventory, reference only, do not merge to keep Git lean).

Merge procedure per lane: git fetch; open PR lane -> claude/integration; wait for gauntlet-pr-checks (guidance + game-smoke) green; merge; run core suite locally
(export PATH=$HOME/.cache/sirens-song-toolchain/bin:$PATH; scripts/toolchain/install-godot.sh if missing; scripts/toolchain/headless.sh --editor --import --quit; scripts/toolchain/headless.sh --script res://tests/run_tests.gd ends CHECKS N FAILURES 0).
Merge order: x4 before T; s3 text before glass/iron text pass; c1 before c2.

Next lanes to dispatch: C2 Iron Choir de-template, S3b glass/iron strings + renames, T pressure (needs X2 table), P2 economy/manufacturing, then challenges, roguelite (rename "expedition" first), naval career, settings polish, art/audio passes.
First command on resume: git fetch origin && git log --oneline origin/claude/integration -5 && read docs/LANES.md.
