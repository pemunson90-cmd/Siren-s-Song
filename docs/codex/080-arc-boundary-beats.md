# Handoff 080: ARC BOUNDARY BEATS AND ARC-GROUPED OPERATIONS LIST

Status: OPEN
Claimed at: 
Claimed by: 
Finished at:

Precondition: 056 and 061 are DONE. Scout note: 056 DONE (it renames the EXPEDITIONS strings in the same files) and 061 merged or not claiming (shares the debrief seam). Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Create an arc table: arc number, name, region key, first and last core op, and a 1 to 2 line placeholder intro and outro (Okafor on Brannock voices the intros, using the bible's six-arc table).
Show a one-screen arc card the first time an arc's first op is opened and after an arc's last core op is recovered. Each card has a 2 to 4 line 'what you carry in' recap built from facts already saved (thread, confluence_route, glass_choice, choir_*).
Group the Operations list and the route map legend under arc headings with recovered/total counts. Tracking 'card seen' needs one optional boolean per arc, following the finale_table.gd SEEN_FIELD pattern (absent means unseen, old saves valid).
Placeholder text only; Pat rewrites it later.

Spec basis: Spec: 'Deliver 28 core campaign operations and 12 optional operations across six arcs and six distinct regions' and 'Integrate recurring command/local characters, received messages, logs, evidence and visible consequences.'
Evidence it is missing: The codebase has no arc concept. region_table.gd maps op id to an art style only. expedition_operations.gd:7 lists every post-tutorial op under one flat heading 'BEYOND THE WARNING / EXPEDITIONS'. The only arc-level story beats are 'THE SONG CONTINUES' after op 5 (campaign_flow.gd:216) and the Confluence departure scene (confluence_resolution.gd). Moving from op 19 to Iron Choir (22), or from op 25 to the final pair and Calder, shows the generic 'EXPEDITION RECOVERED' debrief with no region entry or exit and no recap of what the player carries in. Handoff 061 covers per-op received lines and the field log, not arc transitions.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-arc-beats

## Files you may edit
new campaign/arcs/arc_table.gd and arc_recap.gd, new presentation/arcs/arc_card.gd; small hooks in presentation/expedition_operations.gd (headings), presentation/flow/campaign_flow.gd (debrief and briefing entry), presentation/ops_home/ops_home.gd (group headings); shared append-only save key list

## Files you must not touch
New story beyond 1 to 2 line placeholders; changing endings; touching 056/061 files while they are claimed; em dashes in added text. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. One new UI suite at both required viewports: card shown once, not re-shown on replay, Back handled, 48 dp targets, old save without the new field loads and shows cards as unseen. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
