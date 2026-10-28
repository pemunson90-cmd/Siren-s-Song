# Handoff 086: RECORD THE RESCUES THE LEDGER AND CREW CANNOT SEE YET

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 082 (crew, PR173) is DONE or its review is past the point of editing ledger/crew tables; otherwise none. Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Task (plain language)
The 078 ledger table names Tessaly divers, Hollins last shift and Varne staff, but no operation ever writes the facts it reads (tessaly_divers, hollins_last_shift, varne_staff), so those rescues never appear and the 082 crew layer cannot credit them. Find where each of those rescues already completes in play (Tessaly bell / Deep Rendezvous thread, Iron Choir Last Shift, Glass Reach Varne range ops; confirm with targeted git grep) and record one optional fact at that existing completion point, using the same fact-recording path other operations use. No new rescue mechanics, no balance change. Then add the matching crew rows (one small grant or briefing line each, same pattern as 082) and make the ledger lines appear. Absent facts on old saves mean nothing shows.

## Files you may edit
the existing fact-recording lines in the operations where those rescues complete (one line each), campaign/crew/crew_table.gd rows, campaign/ledger/ledger_table.gd only if a key name must match, tests, shared registration lines

## Files you must not touch
Rescue rules, operation geometry, economy_table.gd numbers. Lock, beam, collision, damage, hull rules, Siren senses, photography design, endings.gd resolution. Files owned by any other CLAIMED handoff.

## Checks
Import + core; one test per fact: completing the existing rescue writes it, the ledger shows it, the crew grant applies once; old save without the fact unchanged.

## Return
PR into claude/integration; review, merge on green; close per ORCHESTRATION section 7; add one line to LEDGER.md.

## Completion
(five lines max)
