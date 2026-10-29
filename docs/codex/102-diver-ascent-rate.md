# Handoff 102: CARRIED SURVIVORS LIMIT HOW FAST QUIETUS RISES (diver ascent rate)

Status: CLAIMED
Claimed at: 29 Oct 2026 08:13 ET
Claimed by: claude-lane (codex-fresh-102)

Precondition: none of the files below claimed by another handoff. The 091 cold audit runs in the root lane against production 13a64ed0; this work lands on claude/integration only and does not disturb it. Do not touch root worktrees or rows.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.

## Pat's ruling (verbatim, 29 Oct 2026 ~08:10 ET)
Claude asked (QUESTIONS_FOR_PAT 24 / 1, STORY_BIBLE_DRAFT decision 3): "Should carrying survivors slow how fast the sub can change depth? I recommend yes." Pat: "For now* Yes*".
The ruling is PROVISIONAL ("for now"). The exact numbers below are AI-DESIGNED for Pat to ratify. It serves Pat's 28 Oct rule that planning, tools and drones must change the outcome.

## Task (plain language)
Survivors brought aboard (saturation divers, witness pod occupants, rescued crew: find every way a craft carries people in the simulation, for example the witness pod and rescue code and sorley_rescue.gd) cannot be brought up quickly.

1. **Slow ascent while carrying.** In `game/src/simulation/depth_bands.gd`, a band change toward SHALLOW by a craft carrying survivors takes longer than the normal 4 s DURATION, scaled by how many it carries (suggested start: 8 s for one, 12 s for two or more), and that craft cannot start another upward change until it has held the new band for a short settle (suggested 6 s). Downward changes are unchanged. The existing rule that a craft in transition occupies BOTH bands stays exactly as it is; the longer transition simply means longer exposure in two bands. Do not change any Siren sense, sight range, lock or beam rule.
2. **Planning answers it.** If a drone can already carry survivors or tow a pod by existing rules, the same limit applies to that drone, so escorting or splitting the load is a real choice. Do not invent new carry abilities. Routes that let the player stay shallow, or use a drone to scout the ascent, should matter more; state in the PR which ops this touches.
3. **Player can see it.** The HUD depth control shows the slowed ascent and the settle countdown when carrying (one short line, 48 dp targets unaffected), and the briefing for affected ops names it in one placeholder line. No em dashes.
4. **No soft-lock.** Every required op stays finishable bare on ACCESSIBLE and STANDARD (Pat's floor). If any extraction requires a band change while carrying and the timer would make the op impossible, fix it with route or timing, never by exempting the rule silently; list every such op.
5. **Saves.** If a transition in progress or the settle timer must survive save/resume (070), persist it with migration; otherwise state why not.
6. **Docs on integration:** add Pat's ruling verbatim to `docs/USER_DIRECTIVES.md` (marked provisional, "for now"); mark QUESTIONS_FOR_PAT 24 and Earlier 1 ruled; update STORY_BIBLE_DRAFT decision 3 status in one line.

## Measure (before/after table in the PR, required)
For every op where survivors are carried (list them), one STANDARD bare SILENT run and one equipped run, before and after: completion, time, Hunt, received lock seconds, hull, oxygen. Bare must stay finishable. The table must show the rule changes something (time or exposure while carrying), and equipped or well-routed play must still be clearly better than bare. Use the 093 harness at C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\093 where it helps.

## Files you may edit
simulation/depth_bands.gd (ascent timing only), the carry/rescue seams needed to know who carries survivors, HUD depth control text, briefing lines for affected ops, mission route or timing data only where item 4 requires it, save field plus migration if needed, tests, docs as listed, shared registration lines.

## Files you must not touch
Siren senses (including silent sight 180 m and cruise sight 290 m), lock warning, beam, collision, damage, hull rules, the V7 sweeper (PR70) and its patrol shape, photography, ending conditions, SILENT speed (099 parked). Files owned by any other CLAIMED handoff.

## Checks
Import + core. One new suite: ascent slowed by carried count, descent unchanged, settle blocks an early second ascent, a non-carrying craft unchanged, both-bands occupancy unchanged during the longer transition, save/resume if persisted. Rerun the depth band, rescue, resume and affected journey suites.

## Return
PR into claude/integration with the before/after table; independent review; merge on green; close the BOARD row, one LEDGER line.
