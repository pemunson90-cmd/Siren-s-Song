# Handoff 067: TEACHING AND BRIEFINGS FOR THE MID AND LATE CAMPAIGN

Status: CLAIMED
Claimed at: 2026-10-28 (exact time not supplied)
Claimed by: codex-root; worker21300; new teaching work, four authorized files only; shared root reserved-suite-ranks.json allocations067: local310/311, CI411/412.
Finished at:

Precondition: 055 is DONE. Scout note: Handoff 055 DONE (so the final tool names exist). No claimed handoff owns these files. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Write 1 to 2 line placeholder rows for operations 30..40 in the same GOAL / DANGER / NEW THIS DIVE shape so they use the compact briefing layout, and add four just-in-time first-use hints shown once per campaign when the player first does the thing: first depth change, first sonar EMIT, first RESEARCH or SUPPLIES visit after an artifact is recovered, and first use of any new field tool. Add the four new tool descriptions to tool_help.gd TEXT. Keep all text placeholder-level, plain, and drawn only from rules already in the FIELD MANUAL or the module descriptions. Extend valid_seen limits for the new ids.

Spec basis: 'Concise briefs and own-state/received-evidence context teach decisions in play' and 'Complete title/menu, Continue/mode selection ... truthful recovery'; new systems (depth bands, advanced sonar, 8 field tools, economy, research) must be learnable.
Evidence it is missing: campaign/onboarding2/briefing_rows.gd ROWS covers operations 3..29 and onboarding_text.gd GOALS covers 0..5; operations 30..40 (the last Iron Choir pair, all of Calder Trench 32..36, optional 35..40) fall back to the full-length brief text at 20 pt (campaign_flow.gd briefing() else-branch; calder_trench_operations.gd:45 shows two-sentence briefs). onboarding_text.gd MAX_OPERATION=4 and HINTS only cover move, pause, drone, sweep, warning, noise and priced_* hints, so nothing teaches the first depth-band change (the 4 s exposed transition exists only in the FIELD MANUAL text), sonar EMIT/sector/power, the hunt meter, the economy panel or research. tool_help.gd TEXT has no entries for the new sonobuoy, silt_screen, hull_patch or relay_buoy (PR150 does not touch it).

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-late-teaching

## Files you may edit
game/src/campaign/onboarding2/briefing_rows.gd, campaign/onboarding_text.gd, presentation/onboarding_hints.gd, presentation/tool_help/tool_help.gd.

## Files you must not touch
No new rules, story text beyond placeholders, or changes to the hint pause behaviour of warning and sweep hints. Do not edit the opening-arc rows already tuned. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import and core. Data test: every operation id 0..40 has either a compact row or a GOAL line; every hint id round-trips through valid_seen and is rejected when unknown; one briefing journey on op 32 at 150% text on both viewports fits without horizontal scroll. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
