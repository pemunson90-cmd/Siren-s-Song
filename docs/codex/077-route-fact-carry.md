# Handoff 077: ROUTE AND RECOVERED-FACT CARRY INTO ARCS 4 TO 6

Status: CLAIMED
Claimed at: 2026-10-28 00:48:49 UTC
Claimed by: claude
Finished at:

Precondition: none. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Add a small data table of authored world deltas keyed on facts the campaign already records: selected_thread, confluence_route, warning_chain, shelf_warning, wake_crossing, glass_choice, choir_*.
Author 6 to 8 deltas across ops 14 to 36. A delta is one of: a gate or structure open or closed, a changed start or recovery mouth, one guard added or removed from the roster, or a pre-placed cargo or landmark. Example: a thread-dependent opening approach in Glass Fence, a plant-state-dependent listener count in Needle Strait.
Apply them through one hook in OperationCatalog.make (or each factory's build) that reads the history already passed in as launch_context. Empty history must return exactly today's mission, so legacy saves and frozen journeys are unchanged.
Every delta must leave the bare-Quietus, no-finite-tool solution intact. Add a short brief line naming the cause in 1 to 2 line placeholder text.
Do not touch endings.gd, sensing, lock or combat rules.

Spec basis: Spec 'Approved full-release expansion': 'Recovered knowledge, people, infrastructure and disclosure affect later play and four principal ending families.' Also 'actual cross-dive capability/consequence must change later play, not merely a label.'
Evidence it is missing: After op 13 the four route families (deep/shelf thread x concealed/overt) play the same ops 14 to 34. Ops 14 to 36 read only glass_choice (glass_reach_operations.gd:24, 41; one brief sentence from facts.resolution) and Iron's own choir_choice/choir_plant/choir_people (iron_layouts.gd:58-59, iron_choir_operations.gd:35-52). git grep shows selected_thread, confluence_route, warning_chain, shelf_warning, wake_crossing and witness_arrival are consumed only by endings.gd, the ops that set them, or brief text. Calder (calder_trench_operations.gd, calder_layouts.gd) and the final pair (final_pair_operations.gd, final_survey.gd, final_marks.gd) have zero history/facts references, so arc 6 cannot react to anything the player did.

Orchestrator note: Claude lane C12. SCOPE SPLIT: author deltas for ops 14 to 29 (Glass Reach, Iron Choir) only; do not edit campaign/encounters/calder_layouts.gd, calder ops or final pair (076 owns them). Calder/final deltas come in a later handoff once 076 lands.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/c12-route-carry

## Files you may edit
new campaign/carry/carry_table.gd and campaign/carry/carry.gd; one-line hooks in campaign/operation_catalog.gd make(); data edits via the existing layouts in campaign/encounters/calder_layouts.gd, iron_layouts.gd and campaign/glass_reach_operations.gd build()

## Files you must not touch
Changing ending resolution or ending text; Siren senses or lock timing; removing a bare-Quietus route; save-format changes (read facts that are already saved); em dashes in added text. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. One new small suite: for each delta, build with and without the fact and assert the difference; build with empty history and assert equality with the current output. Reuse the existing Iron and Calder journey launchers (iron_choir_journeys.gd, calder_trench_journey_tests.gd) for finishability on the changed ops. Never more than ORCHESTRATION section 5 requires. Suite ranks: local 550-559, CI 650-659.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
