# Handoff 034 (PRIORITY after 016): FIX1, concrete problems found by cold review 2

Status: DONE
Claimed at: 2026-10-23 00:58:12 UTC
Claimed by: codex
Finished at: 2026-10-23 02:52:10 UTC

Precondition: none. Take this right after 016 (or before it if 016 is blocked).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back), modular, optional validated save fields. Push WIP every 30 minutes. No em dashes. Do not change combat, beam, collision, damage, hull or Siren sight/hearing rules.

## Task (plain language)
Read docs/design/COLD_REVIEW_2.md on branch codex/handoffs (a partial first-time-player review of op 1, four dives, injected touch, software render, so verify each item yourself before fixing; report any that do not reproduce). Fix these, each as a small change in its owning module, in one PR:
1. Opening self-collision: the first straight route east in op 1 rams the player's own Drone B (hull strikes of 13% and 11%, and the text never says what was hit). Move the drones' start positions off the opening lane (data change) or have the route planner treat friendly craft as obstacles, and name what was hit in the message. Check ops 0 to 5 openings the same way. Do not change collision damage numbers.
2. The first-Siren-warning tutorial pause in ops 1 to 3 appeared to key on Quietus being locked; a warning card about a sweeper hearing noise showed with GOT IT while time kept advancing, and a drone died within seconds. Make the once-only pause fire on the first warning that concerns ANY craft (including drones) and on the first heard-investigation card, UI flow only.
3. The goal is not visible at the start: the objective ring is hidden until FLEET, VIEW, FIT. Show a bearing arrow or edge marker toward the active goal on the default view, with distance, in the existing safe-area style.
4. Confirm buttons wrap badly ("REPLA CE ROUTE", "CANCE L") at default text size on the narrow shape; fix sizing or wording so no word breaks mid-word. The pause control reads RUN in one place and RESUME in another for the same state; unify the wording.
5. After a loss, the old viewfinder and "BEAM 0.1s" warning remain visible behind the briefing; clear transient mission HUD when the loss or briefing screen opens.
6. The radial tool wheel: names (DECOY, DISRUPT, SURVEY, EMIT, SECTOR, POWER, HISTORY) have no explanation, and the wheel's center text overlaps its BACK label. Add a one-line description on press-and-hold or on selection (touch), and fix the overlap.
7. ALL STOP is two taps deep; add it to the primary Quietus ring page (data change in the ring layout) while keeping its oxygen cost visible.
8. Briefing and manual jargon ("lee plating", "passive bearings"): rewrite those lines in plain words (placeholder length).
9. Archive: confirm whether the "Intel and Research" button below the fold can be reached by touch scroll on both Fold7 shapes; fix scroll or move the button up if not. Also confirm the "Primary archive was unreadable. Recovered previous backup." notice on a clean first launch is test pollution from a dirty save folder and not a real bug (use a fresh user dir).
NOT in this handoff (design decisions for Claude and Pat): the photograph not changing visibly with small viewpoint changes, weak frames still securing records (33% secured), and discovery versus confirmation; do not change those.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/fix1-cold-review-2

## What done looks like
Each item fixed or reported as not reproducing, real-touch tests at both Fold7 shapes for items 2 to 7, CI green.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
DONE. Branch: `claude/fix1-cold-review-2`. Last pushed SHA: `9a7180ac1f6dc88925224b52d7092edbc66545d8`. [PR78](https://github.com/pemunson90-cmd/Siren-s-Song/pull/78) merged into claude/integration as `70894702610ba8499b696af072444c8c942e2476`. Exact-head guidance and game-smoke passed in [run39889490544](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39889490544). Fresh integration6229d09 was an ancestor before merge; landed merge tree equals the tested9a7180a tree.

1. Opening self-collision reproduced in all0–5. opening_fleet/launch_layout.gd places DroneB on the opposite flank for these new launches only; stored saves and later operations retain their positions. First eastward routes keep100 hull. Forced old alignment still causes exactly86.5012016296387 final hull and names DRONE B. Collision formulas, thresholds, cooldown and velocity response unchanged; first-decoy survival also verified.
2. Fresh earned warnings pause once for any living own craft in opening0–3, including an open wheel/aiming UI. First heard-investigation cue pauses independently. GOT IT dismisses without resuming; existing saved flags prevent repeats. Mission start clears transient hint state. Warning cards and acknowledgement fit both phone safe areas.
3. Public-chart goal_bearing module adds an offscreen arrow and distance using existing masked chart sites, then recovery mouths. No new discovery, private enemy inspection or simulation writes.
4. Confirmations preserve whole words; pause action and teaching text consistently say RESUME.
5. Screen-state presentation seam clears viewfinder, world beam overlays and lock warnings on loss/briefing/menu transitions.
6. Read-only tool_help module explains DECOY, DISRUPT, SURVEY, EMIT, SECTOR, POWER and HISTORY on hold, including spent tools. Short taps retain actions; jitter is tolerated and pan/pinch/cancel safely stop the hold. Android Back returns to the source wheel; keyboard is fallback. HUD-owned Timer avoids pending-coroutine leaks. radial_layout/center_layout.gd places BACK clear of actual command rectangles and fits visible captions above it, including five-line photo captions. Screenshot inspected.
7. Quietus primary ring retains eight choices and exposes ALL STOP with its existing oxygen cost; GUARD remains under ROUTE. Mechanics unchanged.
8. Short briefing/manual/finding wording replaces lee-plating and passive-bearing jargon. Photography design unchanged.
9. No archive scroll change needed: actual touch drag reaches initially-below-fold Intel on both shapes (956px cover/336px inner) and opens it. Actual first launches in separate fresh OS data directories have no recovery notice. A deliberately corrupt primary with valid backup reproduces the exact reported notice.

Validation: clean import; fresh core817/0; opening35/0; warning15/0; drone38/0; radial58/0; unchanged density883/0; rendered touch218/0 across both Fold7 shapes and desktop. Fresh depth-policy132/0 and opening-policy410/0: all10 opening1–5 journeys win with full hull, all3craft alive and no finite tools spent. Existing accelerated journey fixtures now touch GOT IT and RESUME rather than count paused travel; every original route/photo/completion assertion remains. Both isolated archive profiles9/0 and parent2/0. Strict error/leak scans clean.

After prior red game-smoke, all191 later CI suites passed locally through strict canonical runners. Includes challenge model178/UI86/journey9, planner render5/0 and Well render14/0. No tests skipped, removed or loosened. Local prior density883/12 exposed BACK overlapping odd-count rings; fixed through actual geometry and permanent visible-caption/target checks. Job budget60m accommodates existing189-suite baseline plus new coverage; per-suite480s and strict checks unchanged.

A relayed independent review at implementationb8d270e found no remaining blockers and independently ran touch173/0; later geometry9a7180a is covered by expanded218/0, density883/0 and final exact-head CI. No physical Android or headphone claim. No APK/main/production changes, no branches deleted. PR77 remains a separate Claude photo/cargo lane and was not mutated or merged.

Pat requested pause before new tasks immediately after this merge. Closeout completed;019 not claimed or started. Resume only on a new user instruction, then fetch current board and take the lowest eligible OPEN handoff.
