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

First coherent WIP: branch claude/lane-route-map last pushed0379e302f6118cd8d938cfaf351627393a344a4f, tree5d1578332a470debba02c75230537bc8d1bfc089, based on actual020 integrationddc3361. Pure graph/table and standalone view register through one main._show_campaign line; no operation-table, Simulation or save-code edits. Thirty operation states, catalog edges/route/fact gates, hidden names, returned-film rumors, six opening nodes grouped visually, flat-list fallback, pan/zoom and three Back paths. Functional missing-module RED1/1 then48/0; prerequisite-name RED49/1 then49/0. Missing-entry UI RED2/2; desktop input prototype58/2 failed only drag, established touchscreen emulation plus resize/valid-profile checks passed62/0 on both Fold7 shapes. Import/core818/0 and exits clean. Screenshots/workspace/ss-map-evidence inspected; no physical/enjoyment claim. Feature polish, affected menu checks, independent review and own exact-head CI remain; stays CLAIMED and draft.

Complete candidate: [PR95](https://github.com/pemunson90-cmd/Siren-s-Song/pull/95), branch claude/lane-route-map last pushed65260dada26df82b6584e43ab0067ade7ef6882a, treeaf554ba38d0a0f84cdfb2816307281a218dbb617. Actual integrationddc3361 remains contained; governing instructions unchanged. Added CURRENT next-available focus and existing text-size support, layout/palette tunables in table. Hidden names also guard briefing activation for inconsistent unlock counters. CURRENT/text scaling reproduced RED70/6 then Canvas70/0; hidden action RED50/1 then graph50/0. Current clean import/core818/0, graph50/0, real Canvas70/0 both Fold7 shapes, neighboring menu24/frontend63 all0, clean exits. Updated screenshots inspected. One main registration line is still the only seam; Simulation, persistence, operation data/endings untouched. Independent whole-batch review on exact65260 againstactualddc requested, including optional independent runtime; own exact-head CI pending. PR95 stays draft until review. No new save fields, story, APK or frozen-branch promotion.

Final independent /root/review_integration APPROVE exact65260dada26df82b6584e43ab0067ade7ef6882a againstactualddc3361, no Critical/Important/Minor. Verified exact tree/ancestry/diff and approved scope, campaign-derived gates, fair film knowledge and guarded briefings, Back/pan/zoom/resize/text-scale integrity. Inspected both screenshots and personally reran functional50/0 and actual Canvas/touch70/0 through CI runner, exit0, no errors/leaks. Readable at both shapes; physical Android/fullcampaign/enjoyment unjudged. Relayed verdict in PR95 body. PR95 is ready; exact hosted40039574968 guidance success/game-smoke running. Remains CLAIMED until exactgreen and normal merge with current integration contained; then DONE021+BOARDsamecommit and next eligible023.
