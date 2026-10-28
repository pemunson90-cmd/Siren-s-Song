# Handoff 093: DOES THE FLEET MATTER? (measurement, read-only)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none (read-only; runs on current claude/integration). Read HANDOFF.md first.
Codex may merge: no game changes. Commit the report to codex/handoffs only.

## Pat's ruling (verbatim, 28 Oct 2026 ~12:25 ET)
"I'm worried that the goal is to make sure everything is finishable with just the sub, that makes sense for the easy and normal difficulties for now, but if there's no progression skill and planning and usage of the tools and drones etc, then we don't really have a game we kind of just have a waypoint simulator"

Pat follow-up (verbatim, 28 Oct 2026 ~12:30 ET): "I mean I guess a skilled player should be able to do it, but I still you know walk the game to feel like a game and not just a walking simulator in a submarine"

Operating effect (Claude's reading of both; Pat may correct it):
- **Bare finish is a skill feat, not the easy path.** A skilled player should be able to finish required ops with a bare launch (no finite tools), but it should be demanding: tighter timing, more exposure, close calls, worse results. On ACCESSIBLE and STANDARD it is also the anti-soft-lock floor. On SURVIVAL it may be very hard, but should stay possible for an expert.
- **Design target, every preset:** planning, drones, tools and progression must change the outcome. The bare minimum finish should be clearly worse than a planned, equipped finish (fewer people out, worse photos, lower pay, more Hunt, harsher ledger or ending lines, missed side objectives).
- The spec already says "viable baseline fleet solution" (Quietus plus bare drones). Handoffs that say "bare Quietus alone" were stricter than the spec, and that wording is superseded.

## Task (plain language)
Measure, per operation, whether the fleet and tools matter today. For each core op (0 to 34) and each optional op:
1. Run the existing source-known journey **bare** (Quietus only, no finite tools, drones idle), and **equipped** (drones used plus the tools and modules a player plausibly has by then). Use existing journeys and controllers. Where no equipped journey exists, write the shortest scripted one that uses the obvious drone or tool play. Do not tune anything.
2. Record for each run: success, time, hull, Hunt peak, lock warnings received, oxygen and endurance margin, people or cargo recovered, photo grades or records, reward and pay, ledger or ending facts set, side objectives done.
3. Classify each op:
   - **WAYPOINT**: bare equals or beats equipped on every axis, or the bare run is low-risk (no lock warnings, low Hunt, wide oxygen margin): a walk, not a feat
   - **THIN**: equipped is better on only one minor axis
   - **EARNED**: equipped is clearly better on a major axis
   Note why in one line (for example "drones never needed: all objectives on Quietus's route").
4. List which tools, modules and drone abilities are never decisive anywhere.

Output `docs/design/FLEET_MATTERS_2026-10-28.md` on codex/handoffs. It holds the table, the counts per class, the unused-tools list and the 5 worst WAYPOINT ops ranked by how central they are. No proposals for Siren senses, lock, beam or damage (protected). Claude turns the result into fix handoffs.

Also add Pat's ruling verbatim to `docs/USER_DIRECTIVES.md` on integration, through a docs-only PR under normal review, with the operating effect lines above marked as Claude's reading.

## Checks
None beyond the runs. Keep raw logs outside the repo.

## Return
Report committed; BOARD row DONE; one LEDGER line; banner note for Claude.

## Completion
(five lines max: class counts and the top 3 WAYPOINT ops)
