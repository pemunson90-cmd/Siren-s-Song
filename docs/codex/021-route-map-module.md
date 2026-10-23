# Handoff 021: CAMPAIGN M2, the route map screen

Status: CLAIMED
Claimed at: 2026-10-23 23:03:00 UTC
Claimed by: codex
Finished at:

Precondition: handoff 020 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Read docs/design/DESIGN_CAMPAIGN_DEPTH.md section 3 on branch codex/handoffs. Build the campaign route map as a self-contained module (game/src/presentation/route_map/ and game/src/campaign/route_map/): the 30 operations as branching nodes with states recovered, available, locked, and known-from-photos. An operation's name appears only after its prerequisite is recovered or a photo finding mentions it (fair information). Phone-friendly touch targets (48 dp minimum), pan and zoom if needed, a back button. One narrow seam: a button added in main._show_campaign(). No new save fields (derive everything from existing campaign state and photo intel). Placeholder styling is fine; readable first.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-route-map

## Files you must not touch
Endings, story text, combat and detection rules, operation tables (read only).

## What done looks like
Route map opens from the campaign screen, shows correct states on a fresh save and on a mid-campaign fixture, tests beside the module registered in the workflow.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
Claimed after020/PR85 merged ddc336132181191ed5db387899af8be4fc35b317 and was marked DONE with BOARD. Base is that actual integration. Next create/resume claude/lane-route-map from fetched integration, inspect existing campaign availability/photo-intel/menu seams, then implement only the approved derived route-map module and focused touch/Back checks. No code pushed yet; branch/base/source checkpoint will be recorded after first coherent WIP.
