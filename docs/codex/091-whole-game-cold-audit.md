# Handoff 091: WHOLE-GAME COLD AUDIT (read-only)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 090 is DONE (audit the promoted production snapshot). Read-only: no game edits, no commits to claude/integration.
Codex may merge: no merge; commit the report to codex/handoffs only.

## Task (plain language)
Pat's ruling 27 Oct: finish planned content first, then an independent whole-game audit prioritizing **photographic reconnaissance, strategic depth and actual player experience**; other quality, technical and Android findings still belong in it.

Run a **fresh-context Sol6.1-high critic** that gets only `docs/CRITIC_BRIEF.md`, `docs/CURRENT_GAME_SPEC.md`, the protected-items list from HANDOFF.md section 2 and the running production build. It gets no handoffs, PR history, journeys or winning routes. It plays through injected touch on cover and inner viewports, using cautious, aggressive, drone-heavy and Quietus-only styles. It covers:
- the campaign through at least one full branch to an ending
- one expedition
- one career stretch
- three challenges
- Ironman
- settings and accessibility
- save, export and import
It records what it actually saw, and for every op it judges whether planning, drones and tools changed the outcome or whether the op played like a waypoint simulator (Pat 28 Oct). Give it 093's report only after it has written its own verdicts. Use bounded parallel critics only if each gets the same cold brief and a distinct slice (for example arcs 1 to 3, arcs 4 to 6, modes and menus); merge and dedupe their findings.

Output `docs/design/COLD_REVIEW_4.md` on codex/handoffs. It holds one ranked deficiency list. Each finding has:
- rank and severity
- player-facing symptom
- evidence (op, steps, screenshot path kept outside the repo)
- suspected area
- whether it touches a protected item (if so it is a question for Pat, not a fix)

Put inherited issues and regressions in separate groups. End with the single most valuable next improvement. Do not propose balance numbers as final. Claude turns this list into fix handoffs.

## Checks
None beyond running the build. Report only.

## Return
Report committed to codex/handoffs; BOARD row DONE; one LEDGER line; banner note telling Claude the report is ready.
