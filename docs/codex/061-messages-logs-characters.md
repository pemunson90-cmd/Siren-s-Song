# Handoff 061: RECEIVED MESSAGES, FIELD LOGS AND RECURRING VOICES

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 056 is DONE or not CLAIMED (avoid ops_home overlap). Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Spec: integrate recurring command/local characters, received messages, logs, evidence and visible consequences. Story bible on integration (docs/STORY_BIBLE_DRAFT.md section 4) names Okafor (Brannock command), Rill, Ash, Vey, Kade, Sorley. Build a small data-driven layer: per operation 1 to 3 short received lines (briefing radio, a mid-dive received message triggered by an existing objective/event, a debrief line), attributed to the right recurring voice, plus a FIELD LOG in the archive that lists received messages and recovered evidence by operation. Reuse existing received_cues / archive_recap / consequence-line seams found with targeted git grep. Text stays 1 to 2 line placeholders consistent with the bible; no new plot. Messages are information the player legitimately received (fair information).

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-field-log

## Files you may edit
New campaign/voices/* (data table + module), presentation hooks for the field log inside the archive view, received-message display through existing HUD message paths (smallest seam), shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files of any other CLAIMED handoff. Claude lanes in flight: claude/c6-doc-sweep (docs/ only) and claude/c7-economy-calibration (campaign/economy_table.gd numbers + new tools/tests only).

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Ranks: Codex local 300-349 / CI 400-449 (next free).

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
