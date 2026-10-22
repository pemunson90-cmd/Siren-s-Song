# Handoff 014: 12 curated challenges built on existing operations

Status: DONE
Note: BATCH 2 (released 22 Oct 17:45 UTC). Follow the standing engineering rule in PLAN_SNAPSHOT.md: self-contained module, one narrow seam, numbers in a data table, optional validated save fields, tests beside the feature.
Claimed at: 2026-10-22 20:18:44 UTC
Claimed by: codex
Finished at: 2026-10-22 22:26:25 UTC

Precondition: handoff 013 must be DONE or BLOCKED.
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning (22 Oct): PHOTO1 and ONBOARD1 are merged. Claude's PHOTO2 builder (branch claude/photo2-images) owns the camera, viewfinder, archive viewer, photo save paths, recon_consequences.gd, camera_feed.gd and evidence_catalog.gd. Claude's SWEEP1 builder (branch claude/lane-t2-sweeper) owns the sweeper code and its warning text, plus a first-warning tutorial pause in onboarding_hints.gd. Do not edit those files; write what you need in your Completion section instead.
Never change combat, beam, collision, detection, damage or hull rules, story, or photography design (those are Pat's). No em dashes in any text you add. Briefings and story text stay short placeholders.

## Task (plain language)
The approved release plan includes 12 curated challenges that reuse existing operations. Build the system and the 12 challenges. A challenge is an existing completed operation replayed with a fixed loadout and one rule twist, with par targets and a saved best result. Examples to choose from or improve: silent run (no active sonar), bare Quietus only, one-craft run, no-tool run, speed run against a par time, hull-intact run, drone-only run, minimum-footprint run, depth-band restriction. Pick 12 across ops 0 to 29 so they vary. Results (time, hull, tools used, loss) are saved as an additive field in the profile; old saves must still load; do not alter existing operations, endings, or campaign progression. Add a Challenges entry on the front-end menu (small edit in game/src/presentation/frontend/) listing unlocked challenges and best results. Leave a clear extension point so photography challenges can be added after PHOTO1 lands. Tests: each challenge starts with its loadout, enforces its rule, records a result, and a campaign save is not changed by playing a challenge.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-challenge-mode

## Files you may edit
new files under game/src/campaign/challenges/, game/src/presentation/frontend/ (menu entry), a small additive profile field and its validation, new tests.

## Files you must not touch
Existing operation tables, endings, combat and detection rules, the PHOTO1 files listed above.

## What done looks like
Twelve working challenges, saved bests, menu entry, tests pass, existing saves unaffected.

## Return
Open a PR into claude/integration, wait for guidance and game-smoke, merge when green, then write the Completion section and push to codex/handoffs.

## Completion
Branch: `claude/lane-challenge-mode`. Last pushed SHA: `5043a993b884e6eb2c0e66ecfca219a6af6aada8`.

PR: https://github.com/pemunson90-cmd/Siren-s-Song/pull/72. Merged into claude/integration as `ffde15e0f52528319bbac13704c9c7a15eb44f9a` after guidance and game-smoke both passed on that exact head (run 39861049380). Integration was current before merging.

Added twelve completed-operation challenges with fixed basic loadouts, one rule each, pars, best/last/attempt records, and a touch-first frontend entry. Mode code inherits existing Simulation behavior; ordinary operations and campaign progression remain unchanged. Future rule/catalog entries provide the photo-challenge extension seam.

At Pat's explicit correction, results live in a separate validated, checksummed challenge archive with its own `challenges` field. Attempts never write the campaign primary or backup. Tests compare both files byte-for-byte after completion, abandonment and Android suspend. Touch tests enter/abandon attempts and exercise Android Back notifications, repeated Back and Escape on both Fold layouts. Recorded attempts cannot reopen; Back navigation is deferred safely during notification traversal.

Import clean; core 817/0; runtime 665/0; challenge models 178/0; touch UI 86/0; live Shelf journey 9/0, won at 64 seconds with full hull and no tools. No Godot errors or resource-leak lines in these checks. The live journey is completion evidence, not a difficulty/enjoyment judgment. Physical Android devices and OS gesture recognition were unavailable.

No operation tables, combat/sensing/hull rules or photo save paths edited. Main has a small result-cache field and a lifecycle seam; SaveStore validates the optional field for compatibility. New suites (`challenges_tests`, `challenges_ui_tests`, `challenges_journey_tests`) were run locally; register them in 016, which owns the runners. Next: 015, then 016. Leave 018 to Claude.
