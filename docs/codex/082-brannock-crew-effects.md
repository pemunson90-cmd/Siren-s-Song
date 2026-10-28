# Handoff 082: Rescued people and recovered knowledge as visible Brannock crew effects

Status: OPEN
Claimed at: 
Claimed by: 
Finished at:

Precondition: 061 is DONE. Scout note: 061 merged (voices table to reuse for attribution). Rebase onto claude/c7-economy-calibration if it has merged, since it edits economy_table.gd numbers. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Add a small 'BRANNOCK CREW' table: each recovered group (Kestrel sailors, Port Ardent watch, Tessaly divers where applicable, Hollins last shift, Varne staff) maps to exactly one practical, visible effect on later launches, chosen from: (a) a pre-placed chart mark at a named place in a specific later op, reusing the apply_effects mark kinds; (b) a one-time supply credit through the existing economy hook; (c) a short briefing line in that person's voice.
Show the crew list on the briefing and in the SUPPLIES panel.
Effects are grants only and never required, so a campaign that rescued nobody still has a free bare-Quietus route.
Placeholder text only.

Spec basis: Spec: 'Recovered knowledge, people, infrastructure and disclosure affect later play'; 'actual cross-dive capability/consequence must change later play, not merely a label.' Bible section 4 recurring characters (Okafor, Rill, Ash, Vey, Kade, Sorley).
Evidence it is missing: People outcomes (witness_arrival, warning_arrival, choir_people=landed, shelf_warning) change only ending text (endings.gd) and one brief sentence in Iron Choir (iron_choir_operations.gd:52, 'Recovered workers staff the service berth'). Nothing the player rescued gives any later practical effect. photo_intel.gd already shows the working pattern: RETURNED_FILM has 14 entries that add chart marks to later ops via apply_effects, but only film triggers it, never rescued people.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-crew-effects

## Files you may edit
new campaign/crew/crew_table.gd and crew.gd; one hook in campaign/photo_intel.gd apply_effects (or the same call site in operation_catalog make); one line each in campaign/economy.gd after_recover and presentation/economy_panel.gd; briefing line in presentation/flow/campaign_flow.gd

## Files you must not touch
Making any effect required for completion; changing economy prices or presets; editing endings; inventing new characters beyond the bible's six; em dashes. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. One small suite: empty crew gives today's launch exactly; each crew entry produces its single effect once; save with and without the crew field validates. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
