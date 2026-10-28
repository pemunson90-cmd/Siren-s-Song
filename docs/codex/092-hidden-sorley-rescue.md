# Handoff 092: HIDDEN RESCUE OF SORLEY'S BOY (experiment)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 088 is DONE (it owns ending resolution) and 086 is DONE (rescue facts). Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Pat's ruling (verbatim, 28 Oct 2026 ~11:50 ET)
Claude asked whether Sorley's boy (photographed alive in optional op 37, never evacuated) should get a rescue follow-up or stay unresolved. Pat: "Experiment with a hidden rescue mission that requires either found logs off the beaten path, or certain photos. So its an option side quest with at least one game reward and ending changes."
This answers QUESTIONS_FOR_PAT item 4. Everything below beyond that sentence is AI-DESIGNED for Pat to ratify.

## Task (plain language)
Add one hidden optional operation, "OPTIONAL / Last Boat Out" (placeholder title; use the next free optional id), that rescues the boy from the trawler's air pocket.

1. **Hidden until earned.** It does not appear on the route map or Operations list until **either** key is held:
   - **Photo key:** the op 37 bonus frame "BOY AT THE AIR-POCKET WINDOW" was secured (existing record key `glass_record_37_bonus`).
   - **Log key:** the player found **2 of 3 Sorley logs** placed **off the main routes** of existing ops in his waters (arcs 2 to 4). Each log is a small optional local find (a recorder buoy or wreck locker) reached by a short side detour, picked up by settled local work the same way existing field logs or cargo are. A log is never on a required route and never gates finishability. Each log is a 1 to 2 line placeholder in Sorley's voice hinting where the boy is.
   On unlock, one Operations line (for example "SORLEY'S SIGNAL: a new course is open") and one Sorley voice line.
2. **The mission.** Reuse the op 37 region and layout (`optional_operations.gd` `_trawler`) with a new objective: reach the air pocket, couple a pod or winch (reuse the 012/witness pod carry and landing mechanics, not new rules), and bring the boy home. Existing Siren roles only. Bare Quietus with no finite tools must be able to finish it.
3. **At least one game reward** (pick the strongest that fits existing systems; more than one is fine):
   - preferred: **Sorley's pilotage**. He shares honest charts of his waters, which pre-charts shoal outlines in that region's later ops. If 089 is DONE this uses the earned-chart seed; otherwise it can be a fixed charted outline.
   - and/or a rescued-crew effect through the 082 Brannock crew system
   - and/or a modest economy reward through existing rewards
4. **Ending changes.** A rescued boy adds a placeholder line to the ending story and an entry to the campaign ledger (078). Not rescuing him (the mission was unlocked but not done, or never found) gives a different short ledger line. Whether the rescue may also count toward 088's late-campaign ending rule is Codex's call, stated in the PR for Pat to ratify. It must not change the thread axis.
5. **Persistence.** At most one new fact key in the existing campaign facts (for example `sorley_boy`: rescued / left). Old saves without it load as "not rescued, not unlocked" unless the existing photo key already unlocks it.
6. **Docs on integration.** Add Pat's ruling verbatim to `docs/USER_DIRECTIVES.md`. Mark QUESTIONS_FOR_PAT item 4 as ruled. Keep story lines as 1 to 2 line placeholders within `docs/STORY_BIBLE_DRAFT.md`. No em dashes.

Behind a mission-table flag so it can be switched off cleanly (it is an experiment).

## Files you may edit
optional_operations.gd (new entry, reusing the trawler layout), the route map and Operations unlock seam, voices_table.gd (Sorley lines), the 2 or 3 host ops' data for log placement only, the archive/log list, reward wiring in the chosen existing system, ending story and ledger text hooks (after 088), tests, docs as listed, shared registration lines.

## Files you must not touch
Siren senses or behavior, lock, beam, collision, damage, hull rules, photography design, the thread axis, required routes of host ops. Files owned by any other CLAIMED handoff.

## Checks
Import + core. One new suite:
- hidden with neither key
- unlocked by the photo key alone
- unlocked by 2 logs alone, not by 1
- the logs are not on any required route
- bare Quietus finishes the mission
- the reward is applied once
- ending and ledger lines for the rescued and not-rescued cases
- an old save loads
- the flag switched off hides everything
Rerun the op 37, ledger and ending suites.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; add one line to LEDGER.md.

## Completion
(five lines max; name the reward chosen and whether the rescue feeds 088's rule)
