# Handoff 063: PERFORMANCE PASS (60 fps target, 30 fps fallback)

Status: CLAIMED
Claimed at: 2026-10-28 12:02:14 UTC
Claimed by: codex-root-queue
Finished at:

Precondition: 060 is DONE. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Spec: target 60 fps on modern Android with a usable 30 fps fallback; profile realistic and stress scenes. Add a headless frame-time probe (existing toolchain) over the heaviest scenes: Calder Trench core ops, Iron Choir industrial ops, Confluence, a dense sonar/Hunt late-stage scene, with all regional presentation on. Find and fix the top hot spots (draw calls, per-frame allocations, redundant terrain/LOS work) without changing simulation results (state hashes must match before/after). Report frame-time numbers before/after in the Completion.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-performance-2

## Files you may edit
Presentation draw code, simulation hot paths only where results are provably identical, a new probe script under scripts/toolchain or game/tests; shared append-only files. simulation.gd allowed for pure performance changes with identical state hashes.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files of any other CLAIMED handoff. Claude lanes in flight: claude/c6-doc-sweep (docs/ only) and claude/c7-economy-calibration (campaign/economy_table.gd numbers + new tools/tests only).

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Ranks: Codex local 300-349 / CI 400-449 (next free).

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

Root scheduling28Oct08:14UTC:081 owns chart/render files now while063 was unclaimed. Do not claim063 until081 releases those paths; keep060 precondition. This reverses only collision-avoidance order.

Rootassignment28Oct:060and081merged,sochartfilesreleased. BoundedLuna baselineworkermeasurescurrentheavyscenesandfindsonehotspotfirst; nosourcerewrite/commitbeforeseparatereview. Desktop/headlessmetricsmustnotbeclaimedAndroidGPUacceptance.
