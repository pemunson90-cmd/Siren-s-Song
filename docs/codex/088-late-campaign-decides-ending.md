# Handoff 088: THE ENDING IS DECIDED AFTER OP 34, AND ARCS 4 TO 6 CAN CHANGE IT

Status: DONE
Claimed at: 2026-10-28 (UTC; exact claim time not retained here)
Claimed by: codex-root; worker500; branch claude/codex-088-late-ending; Ending flow and docs ruling only.
Finished at: 2026-10-28T18:56:16Z

Precondition: 085 is DONE (PR185; it owns the op 30 to 34 carry rows and facts this reads). Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Pat's ruling (verbatim, 28 Oct 2026 ~11:22 ET)
Claude asked: "Should what you do in arcs 4 to 6 be able to change which ending you get? Today the ending is locked at ops 12/13 ... I'd queue a follow-up that moves the decision to op 34." Pat answered: "Sure that's fine". This answers QUESTIONS_FOR_PAT items 1 and 5. Story ending conditions are protected; this ruling authorizes only what is written below.

## Task (plain language)
Today `game/src/campaign/endings.gd` `resolve()` picks one of four families from two axes as soon as op 12 or 13 is won: the thread (deep or shelf: whose people you brought out) and the Confluence route (concealed or overt: whether the Sirens learned Quietus). Change it so that in the campaign:

1. The family is final only once op 34 (the staged capstone) is resolved. Before that, the ops 12/13 result is a **provisional** family: the ending screen and "VIEW CAMPAIGN ENDING" are not offered as final before op 34; at most one short placeholder line on Operations says the course so far (for example "Course so far: OPEN WATER"). Keep fork/hard-save ending buttons truthful (043 rule): they show the provisional family as provisional.
2. The **thread axis stays fixed**. Who you brought out in arcs 1 to 3 is history.
3. The **channel axis (concealed vs overt) is re-decided at op 34** from conduct in arcs 4 to 6. Default is the Confluence choice. It flips only when the late record clearly points the other way. Use facts already saved by 077, 078, 082, 085 and 086 (for example warning_chain, choir_*, glass_choice, the op 34 result, rescue facts). Pick a small, deterministic rule (2 to 4 facts, a simple count or majority, documented in a comment and in the PR). Put the rule in a pure function so it is testable.
4. When the family changed from the provisional one, the ending story gets one short placeholder line naming the cause (1 to 2 lines, within `docs/STORY_BIBLE_DRAFT.md`, no em dashes). Existing family titles and stories stay unchanged otherwise. The existing per-family variants (witness_arrival, concealed_consequence, warning_arrival) keep working for whichever family results.
5. **Expedition mode is unchanged.** If an expedition run never reaches op 34, keep today's 12/13 resolution for it (expedition_campaign.gd, expedition_operations.gd).
6. Old saves: no new save field. A save already past op 34 resolves by the new rule on load; a save between 13 and 34 shows the provisional family. Empty late history must give exactly today's family.
7. Docs on integration: add Pat's ruling verbatim at the top of `docs/USER_DIRECTIVES.md`; mark QUESTIONS_FOR_PAT items 1 and 5 as ruled with the date.

The exact flip rule is AI-DESIGNED: state it plainly in the PR body and in the Completion lines so Claude can show it to Pat for ratification.

## Files you may edit
game/src/campaign/endings.gd, endings_photo.gd, the ending gating in presentation/flow/campaign_flow.gd and save_states/save2_controller.gd, one Operations status line, tests for the above, docs/USER_DIRECTIVES.md, docs/QUESTIONS_FOR_PAT.md, docs/STORY_BIBLE_DRAFT.md (placeholder lines only), shared registration lines.

## Files you must not touch
The thread axis; ops 12/13 mission content; expedition resolution; carry table rows (085 owns them until DONE); save fields; Siren behavior or senses; lock, beam, collision, damage, hull rules; photography design; art direction. Files owned by any other CLAIMED handoff.

## Checks
Import + core. One new suite: the flip rule as a table (each fact on and off, empty history equals today's family for all four seeds); ending not offered as final before op 34; provisional line shown between 13 and 34; old save past 34 loads and resolves; fork buttons truthful; expedition path unchanged. Rerun existing ending, ledger and save2 suites. Suite ranks: next free in your rank block.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; add one line to LEDGER.md.

## Completion
[CODEX verified] PR193 merged `2ba1edf9a176d430274fe84f96e1e1931655d4c6` from head `ae1c15062aca540f800e4d3114a0d481347ad808`; own seven checks green40743351396.
[CODEX verified] Independent26 source +28A approved exact tree `03060d5b14f01927807318bd1dc71056e7200040` (head1519dbb5 + mergeD560); root record: external `independent-review28.result.txt`.
[CODEX verified] Late family stays provisional until op34; thread fixed; strict majority with two matching late votes can flip channel; ties/sparse votes retain Confluence fallback.
[CODEX verified] Pat provisionally accepted the vote rule at15:45 ET; verbatim quote recorded in `docs/USER_DIRECTIVES.md` via PR205.
[CODEX verified] Ending paths released, subject to current claims.
