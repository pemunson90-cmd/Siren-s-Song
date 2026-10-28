# Handoff 085: EARLIER CHOICES CHANGE ARC 6 (Calder and final pair)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 076 is DONE (PR165) and 077 is DONE (PR166); none beyond that. Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Task (plain language)
077 added a carry table (campaign/carry/*) so saved facts change ops 14 to 29; it deliberately skipped Calder and the final pair because 076 was rebuilding them. 076 is merged. Extend the same carry table with 3 to 5 deltas across ops 30 to 36 (a gate, a start or recovery mouth, one guard added or removed, a pre-placed cargo or landmark), keyed on facts already saved (thread, confluence_route, glass_choice, choir_*, warning_chain and similar). Empty history must return exactly today's mission. Every core op (30 to 34) keeps a bare-Quietus, no-finite-tool route; the op 34 staged capstone keeps its three stages. One short placeholder brief line names the cause. No save-format change.

## Files you may edit
campaign/carry/carry_table.gd (rows), campaign/carry/carry.gd only if a new delta kind is needed, the Calder/final layout data the deltas touch, carry tests, shared registration lines

## Files you must not touch
Ending resolution or ending text; new Siren behavior; removing a bare route; save fields. Lock, beam, collision, damage, hull rules, Siren senses, photography design, endings.gd resolution. Files owned by any other CLAIMED handoff.

## Checks
Import + core; extend carry tests (with/without each fact, empty-history equality); rerun the Calder and final-pair bare journeys for changed ops.

## Return
PR into claude/integration; review, merge on green; close per ORCHESTRATION section 7; add one line to LEDGER.md.

## Completion
(five lines max)
