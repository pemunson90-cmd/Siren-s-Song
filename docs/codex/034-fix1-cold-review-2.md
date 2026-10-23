# Handoff 034 (PRIORITY after 016): FIX1, concrete problems found by cold review 2

Status: CLAIMED
Claimed at: 2026-10-23 00:58:12 UTC
Claimed by: codex
Finished at:

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
In progress, awaiting final-head CI and required follow-on checks. Branch: `claude/fix1-cold-review-2`. Last pushed SHA: `9a7180ac1f6dc88925224b52d7092edbc66545d8`. PR78: https://github.com/pemunson90-cmd/Siren-s-Song/pull/78. Candidate pushed2026-10-23 02:25 UTC; no uncommitted source work.

1. Opening eastward self-collision reproduced in all0–5 (hull86.5012016296387). opening_fleet/launch_layout.gd puts DroneB on the opposite flank (0,+100), first six new launches only; stored saves and later operations retain existing positions. Hits name own friendly hulls; other hulls remain anonymous. Forced hit still has identical damage, thresholds, cooldown and velocity response. The initially tried northeastern spawn exposed B to the first decoy investigation and was rejected by core; the final flank passes that regression too.
2. Fresh receiver-earned contacts pause once for any own craft in opening0–3, including an open command ring/aiming UI. First heard-investigation cue pauses independently. GOT IT only dismisses, with saved existing flags preventing repeats. Transient hint state clears on mission start. Warning-card text gets its real width before measuring; full card and acknowledgement fit both phone safe areas.
3. Read-only goal_bearing module draws an offscreen arrow and distance using the existing public masked chart sites, then recovery mouths. No new discovery, hidden enemy inspection or state writes.
4. Confirmation minimum widths fit whole words. Paused action and teaching text consistently say RESUME.
5. Main screen-state seam and Ocean presentation flag clear viewfinder, world beam overlays and lock warning on loss/briefing/menu transitions.
6. Read-only tool_help module explains DECOY, DISRUPT, SURVEY, EMIT, SECTOR, POWER, HISTORY on touch hold. Short taps retain their actions, slight finger jitter is tolerated, pan/pinch/cancel dismiss safely, spent tools remain explainable. Android Back returns to the source wheel; keyboard is fallback. Node-owned cancellable timer fixes a strict shutdown leak exposed by radial testing. Wheel BACK is below measured center captions.
7. Quietus primary ring retains eight choices and now exposes ALL STOP with its existing oxygen price; GUARD remains under ROUTE. Mechanics unchanged.
8. Short briefing/manual/finding lines replace lee-plating and passive-bearing jargon; photography rules unchanged.
9. No archive scroll fix needed: actual touch drag reaches the initially-below-fold Intel button on both shapes (offset956cover/336inner), and touch opens it. Actual first launch in separate fresh OS data directories has no recovery notice. Deliberately corrupting a primary with a valid rotated backup reproduces the exact reported notice.

Validation: import clean; core817/0; opening35/0; warning15/0; drone38/0; radial58/0 with no errors/leaks; rendered cold-review touch173/0 across both Fold7 shapes plus desktop with clean error/leak scan; both isolated archive profiles9/0 and parent2/0. No physical Android or headphone claim. No APK/main/production changes. Prior WIP CI red at core; all later CI-list suites are now running locally per this handoff, pending completion. Job budget60m accommodates the189-suite baseline plus new coverage; per-suite480s and strict checks unchanged.

Independent reviewer found stale transient hints and warning suppression with an open ring, both repaired; implementation review completed atb8d270e with no blockers. No merge or DONE claim until guidance and game-smoke green on the exact candidate and mergeable against fresh integration. PR77 is a separate active Claude photo/cargo repair lane and has not been mutated or merged here.

Post-red local follow-on found the old accelerated depth-policy UI journey counted travel while the new opening tutorial pause was active. Updated only its fixture driver to touch GOT IT, verify acknowledgement keeps pause, and touch RESUME; all original route/photo/completion assertions retained. Now126/0: quiet and active policies win on both shapes (quiet82.33s hull100, active69.72s hull62.65). Pushed test-only1df2e8b. Independent reviewer approved implementation atb8d270e and independently ran touch173/0 clean;1df2e8b changes only this journey test. First23 later suites passed; fixed depth policy passed; remaining canonical CI list is running from the next suite. Exact new-head CI pending.

Fresh-directory validation exposed a second stale fixture assumption: inner opening1 could leave an acknowledged-in-prior-runs warning card covering the next command. Test-only203282a makes the shared craft-selection driver and opening travel loop touch-acknowledge before further orders. Fresh operation1 now64/0, both shapes win full hull; full fresh opening and depth-policy reruns are in progress. Regular opening1–5 journeys406/0, all10 full-hull/no-finite-tool wins. Remaining post-red local list continues; no tests removed or assertions weakened. New exact-head CI pending203282a. Source implementation remains the reviewedb8d270e.

Final fresh-save reruns completed at203282a: depth-policy132/0 (all4 cautious/active journeys), opening-policy410/0 (all10 operations1–5 cover/inner journeys), both strict runner exit0 with no errors/leaks. Every opening journey wins with100 hull, all3craft alive and no finite tools spent. Fresh op1 correction is verified. At02:11 UTC the required post-red local checks have97 successful suite summaries; remaining list and exact-head game-smoke are still running. No uncommitted source changes.

Latest pushed9a7180a fixes a real layout regression exposed by unchanged density assertions (883/12 red). Moving BACK down had overlapped five/seven-choice ring commands. New radial_layout/center_layout.gd chooses free BACK placement from actual command rectangles and fits captions above it. A red visibility probe also caught a coordinate mistake before push; corrected and verified with rendered screenshot. Final density883/0, radial58/0, expanded real-rendered touch218/0 (caption visibility, BACK spacing on craft/route/fleet/tools and five-line photo captions), strict clean logs. Import clean and fresh core817/0. No rules/save changes. All191 required post-red local CI suites passed by02:29 UTC, with strict runner exit0 and clean error/leak scans. Final runs include planner render5/0, Well render14/0, touch218/0 and isolated archive2/0 plus9/0 per phone. Previous203282a CI red; new exact9a7180a CI pending. No uncommitted source work.
