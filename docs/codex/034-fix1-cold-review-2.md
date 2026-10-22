# Handoff 034 (PRIORITY after 016): FIX1, concrete problems found by cold review 2

Status: OPEN
Claimed at:
Claimed by:
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
(Codex fills this in: per item fixed or not reproduced, PR link, branch and last pushed SHA, test results.)
