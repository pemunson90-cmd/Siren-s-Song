# Handoff 051: CALDER TRENCH, arc 6 (3 core + 2 optional operations, 3 artifacts)

Status: CLAIMED
Claimed at: 2026-10-26 23:48:53 UTC
Claimed by: codex
Finished at:

Precondition: 050 is DONE (merged). Read ORCHESTRATION_2026-10-26.md first; it overrides older review/evidence rules.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Build the sixth and last campaign region, Calder Trench (docs/STORY_BIBLE_DRAFT.md section 2 item 7 and section 3 row 6, on claude/integration). A classified deep test well drilled toward a Siren site. Survivors: the drilling team and their guard detail. The well is still flowing and must be shut in by hand, which is loud. This arc is the "full noise budget of everything learned": it should ask the player to combine depth bands, sonar, Hunt, photography, cargo and the finite tools under the heaviest pressure in the game.

- Ids 32, 33, 34 core; 35, 36 optional. Op 32 requires 31 completed; 33 requires 32; 34 requires 33. 35 and 36 require 32.
- Reuse existing shared systems and enemy roles (all 8 exist). Distinct authored geography in a new region file, deep-band heavy. No new enemy role and no new sense rules.
- Photography stays the primary act in every op (at least one consequential photo objective each). Survivor rescue and the shut-in work support it.
- Physically recoverable artifacts, ids per ORCHESTRATION section 4: `trench_seal_core` (core op), `choir_reed` (core op), `deep_keel_plate` (op 35 or 36). Append one RECIPES row each in campaign/glass_research.gd.
- Move the END OF LINE finale trigger from first recovery of id 31 to first recovery of id 34 (presentation/finale only). Endings logic unchanged.
- Text: 1 to 2 line placeholder briefings/debriefs, consistent with the bible (Okafor on Brannock as command voice). No em dashes.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-calder-trench

## Files you may edit
New campaign/calder_trench_operations.gd and any new Calder region/terrain files; campaign/operation_catalog.gd (append entries); presentation/finale/* (trigger only); RECIPES rows in campaign/glass_research.gd; region drawing hooks in presentation/ocean_view.gd if the new region needs them; shared append-only files per ORCHESTRATION section 3; one MODULES.md row and one RESUME bullet.

## Files you must not touch
Everything Claude owns (ORCHESTRATION section 3), campaign/endings.gd, enemy senses, lock/beam/collision/damage/hull rules, existing ops 0 to 31 content.

## What done looks like
Ops 32 to 36 launch from Operations, are finishable, recover their artifacts physically, and the finale appears after first recovery of 34. CI green.

## Checks
Import, core, and one bare-Quietus finishability journey per core op (32, 33, 34). Rank block Codex local 300+, CI 400+. Nothing else.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
