# Handoff 068: EXPEDITION BETWEEN-OPERATION CHOICES (ROUTE FORK, REPAIR OR BOON)

Status: OPEN
Claimed at: 
Claimed by: 
Finished at:

Precondition: 056 is DONE. Scout note: 056 DONE (owns campaign/runs/* and presentation/runs/*). Also needs 054 DONE (it is). Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
After 056 lands, add a between-operation node to the expedition run. After each win, the player sees 2 or 3 offers drawn from the seed. Offers: the next operation (shown with its title and its rider or reward), a repair or refit stop, or a one-use boon such as extra film, an extra finite tool charge or spare scrap. Choices must not change sensing, pause, combat or hull rules. They only change which existing operation comes next and what the player starts it with. Store the offers and the pick in the run sidecar so a restart cannot reroll them. Build a touch-first 48dp view with Android Back handling, and a plain-language run-state line. Reuse OperationCatalog.make and economy.gd costs. Placeholder text only.

Spec basis: CURRENT_GAME_SPEC.md 'Approved full-release expansion': "seeded roguelite expeditions of 3-6 operations"; "Missions connect approach, sensing, fleet allocation, objective priorities and withdrawal through multiple viable strategies".
Evidence it is missing: Handoff 056 (origin/codex/handoffs docs/codex/056-c3-modes-expeditions.md) has the seed choose the whole sequence and run modifiers up front, then 'the run ends on loss'. It has no player decision between operations. A 3-6 op run is therefore a fixed shuffled playlist. The existing economy (054, economy.gd: repair, manufacture, refine, spares) has no hook for between-op choices inside a run.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-run-offers

## Files you may edit
New campaign/runs/run_offers.gd and campaign/runs/offer_table.gd (seed to offers, with an enabled switch); new presentation/runs/offer_view.gd; one hook line in the 056 run flow. Tests: new runs_offer_tests (determinism per seed, no reroll after reload, corrupt-offer reject).

## Files you must not touch
 Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
