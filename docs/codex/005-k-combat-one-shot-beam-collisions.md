# Handoff 005: one-shot beam and collision damage

Status: CLAIMED
Claimed at: 2026-10-21 22:57:52 UTC
Claimed by: codex
Finished at:

Precondition: run `git log -1 --format=%cr origin/claude/lane-k-combat`. If the newest commit is under 90 minutes old, a Claude worker may still be active on this branch: do not claim, skip to the next OPEN handoff, and if none remain tell Pat.
Codex may merge: yes, same rule, after you open the pull request into claude/integration.

## Task (plain language)
Pat decided (Option A plus collisions). (1) When a Siren's beam fires at Quietus it destroys Quietus outright, like V7's vaporize. Keep the existing 4 second lock build (LOCKING then BEAM) as the fair warning, and keep every way to break it (losing line of sight, EMP, knockdown, cover, braking or turning). Replace the beam hull drain (hull=maxf(0,hull-dt*18) near game/src/simulation/simulation.gd line 1160) with an immediate loss when the beam fires on unit 0, outcome text VAPORIZED. Drones still die to a beam at once. (2) Collisions hurt: Quietus takes hull damage when it hits terrain or hulls, scaled by impact speed. Slow bumps cost little, hard fast impacts cost real damage, a single normal-cruise hit never destroys Quietus. Add a short hit cooldown so grinding is not a per-frame drain. Keep V7's slowdown (speed cut to 25 percent). Show collision damage in the existing hull readout. Other damage sources stay (interceptor burst 20, pressure patch 8 per second, sonar sweeper 22). Pat's target: a punishing stealth game that rewards careful planning, route execution and timing of tools and equipment, neither impossibly hard nor painfully easy. Autopilot strength gets tuned later by Pat, so put the numbers in clearly named constants at the top of the file with a comment. A Claude worker started this and a WIP snapshot is on the branch.

Do not change detection or suspicion rules, drone rules or any story text. Update old tests that assumed the slow beam drain or no collision damage, narrowly, and say which and why. Authored bare-Quietus journeys for operations 0 to 29 must still finish; if one does not, report it instead of editing the route. Add a focused new test (beam kills on fire; a broken lock does not; fast collision damages, slow bump barely does; cooldown works) and register it in .github/workflows/gauntlet-pr-checks.yml.

## Added 21 Oct by Claude (Codex audit findings 1 and 5, Pat said continue the loop)
(a) Strike targeting rule. Today each delivered sonar return replaces the armed strike and resets its countdown, so a second craft's echo changes the outcome (stationary Quietus: 78 hull alone, 100 hull with a second craft). Make it explicit: an armed strike keeps its target and countdown; later returns do not replace or reset it until it fires, expires or is broken. Put the rule in a comment and a focused test. This is a targeting tiebreak, not a change to who gets detected; say so in the PR and flag it to Pat as reversible.
(b) After the combat work lands on your branch, update the pressure probe (docs/codex/run_ci_scenarios.sh lists it; test files from lane X2). All four policies reject their first route in operation 14 at time zero because the controller assumes old map dimensions. Read dimensions from the operation data, rerun ops 14 to 29 for all four policies, and put the resulting difficulty curve table in your completion note. Probe files only; no tuning of game numbers, report them to Pat instead.

## Base and branch
Work on the existing branch `claude/lane-k-combat`. First `git fetch origin` and merge `origin/claude/integration` into it, resolving conflicts and keeping both sides. Do not rewrite history or force push.

## Files you may edit
The beam, lock, hull and collision parts of game/src/simulation/simulation.gd, the hull readout, new tests.

## Files you must not touch
Detection rules, drone rules, story text, campaign tables.

## What done looks like
Beam fires means Quietus is destroyed; collisions hurt as described; bare-Quietus journeys finish; all scenarios ok.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean (every line ok). Machine may be slow: if a scenario times out, rerun it alone before concluding.

## Return
Push the branch, then open a pull request into claude/integration. Wait for GitHub's checks.
Pat decides design: do not alter anything beyond what is written here.

## Completion
(Codex fills this in.)
