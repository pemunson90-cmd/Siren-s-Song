# Earned campaign evidence and recovery handoff

Published 2026-11-18 from the completed November 17 review. This is a portable evidence summary, not a new playthrough, independent reproduction or publication of the raw save/profile. [Current status](STATUS.md) distinguishes the candidate from prepared local fixes.

## Source and run settings

- Candidate: `df0171c18dcc0147b3fc0b02995ebea78bc85ca5`, Fable overhaul branch.
- Continuation: direct child `21ef2c725b341c8087d227bac46e08c995ca6340`, after ten earned recoveries. Its three-file diff changes public-control access and adapter tests, not gameplay rules. This commit remains local-only; its hash is an identifier, not a promise that GitHub can resolve it.
- One new isolated Standard campaign, Ironman off, default endurance; stock hull/drones and no fittings initially. Later fittings, research, repairs and replacements were acquired through ordinary play. Public speeds were within 1/2/4; no developer progress commands.
- Continuation kit `codex-public-adapter-standard-20261117`, slot `ordinary`, session `ordinary-adapter-continuation`, cover view. Play used the public scripted adapter, headless initially, then a visible 2520x1080 game window and game-rendered frame exports. No successful native/CUA input or screenshot, Android touch or audio assessment is claimed.
- Copied-save metadata checks recorded profile `dev=false` and active mission `dev=false`. The campaign was not replayed from the beginning to produce the continuation. The retry of unfinished operation 13 was expressly authorized and retained all ten previous recoveries.

## Verified outcome and observed progression

**27 earned recoveries; END OF LINE / FINAL ACCOUNT / STANDING DOWN reached and reopened after normal quit/relaunch.** This is one ending, not every ending or all 42 operations.

Observed progression included the opening campaign, Shelf Return, Confluence and Concealed Record, Glass Reach operations, physical cargo and witnesses, Hammerwake's actual sled arrival, Pressure Stair, an optional Counterweight Grave equipment detour, Choir Cut, late surveys, Calder Shut-In, The Human Gallery and Beneath the Well. Choices and retained consequences appeared in the final account.

Choir Cut required three genuine losses, earned traction-core research costing two alloy, Drone A yoke fitting, and learning to clear both carrier and trailing ballast through the slit. BYPASS completed on attempt four. Final operation 35 (catalog ID 34) followed two real losses and succeeded on attempt three at 572.15 seconds, displayed 09:32, hull 100%, about two seconds of air remaining. Reserve air and different craft assignments materially affected the successful attempt. These observations establish consequential mechanics, not that difficulty must be reduced.

Drone A and its yoke were at the recovery mouth. **Drone B was still outside at extraction.** No claim that both returned. Postreload public balances were 99 scrap, 39 cells, 8 alloy; Quietus and A showed condition 100%, A's yoke and Quietus' Reserve air remained fitted.

The final account reported the recovered Kestrel landing, six Port Ardent watch survivors, Hollins sled arrival, severed Varne reporting spur, bypassed Choir line and quiet Confluence. It did not report a Sorley-boy landing. It displayed late photo comparisons and a B grade across 21 intel records (67% average, 97% sharpest). Archive CONTINUE -> RECOVERED (27) -> VIEW END OF LINE reopened the same ending. Both owned game processes exited normally afterward.

## Discovered-chart coverage, not an old-rules run

The candidate descends from overhaul code `955ac8a1`. Its active parity defaults include discovered charts after tutorial catalog IDs 0-2, a limited 480-by-480 launch window, fixed objectives presented as search areas, survey visibility lasting 30 seconds unless craft sensors map it, and drones starting aboard Quietus. All parity switches were enabled in the inspected source. Recorded play encountered unknown terrain, searched and sensed objectives, used sonar/survey, and deployed/recovered craft under these rules.

The November 12 FINAL_REPORT warning that operations 3-41 had never been completed on discovered maps is a dated checkpoint. November 16 Fable reports later record all 42 individually won using developer starts, with clean continuity then only through 01 -> 07 -> 09. Our November 17 route adds 27 earned recoveries and ending persistence without developer starts. These are complementary evidence classes. Neither establishes a clean playthrough of every operation, every alternate route, comprehensive survey-expiry behavior, or fresh-player chart comprehension.

## Preserved evidence identifiers

Raw evidence remains preserved locally; it is not embedded or remotely accessible through this report. These identifiers permit matching it if later transferred deliberately:

- Final ten-file profile backup: `adapter-profile-earned-ending-20261117T170022713Z`.
- `slot1.save` SHA-256: `C9DA4DFBE216495B0066D5B44218E5EB7237709FBA057C0AC9FB73324346832F`. Recorded unchanged across both normal quits and ending reopen.
- Final journal SHA-256: `3AC531995988CCAA4279A6E89BFC00A2C89FEC083CA73B943614A66FD9DFED97`.
- Reopened Standing Down frame SHA-256: `CC6D15DD3B29EF27680F85F567AA2E7DF04FA834CE13BB93737413737A43C465`.
- Frames: `035-ENDING-earned.png`, `035-ENDING-outcome-detail.png`, `035-ENDING-reopened-after-reload.png`, `035-ENDING-reopened-final-account.png`, `035-ENDING-reopened-standing-down.png`.
- Recorded command audit: 584 baseline plus 1,838 derivative completed public requests; zero parse errors or debug/truth/jump/grant-style entries. Refused routes/controls remain in the record.

Detailed local originals: `earned-campaign-review.md`, `CURRENT-HANDOFF.md`, `EXECUTIVE-REVIEW.md`, `project-overview.md`, and `authority-evidence.md` in review directory `01a1e7ef-8e32-7f02-9548-dab755c6b21a`. This report removes dependence on a Windows path for understanding the result, but does not claim those raw artifacts were uploaded.

## Prepared fixes: local-only, not integrated

| Commit | Scope | Evidence boundary |
| --- | --- | --- |
| `d0b9fef0` | Six readiness/guidance discrepancies | Focused fixtures/core checks; not in original run |
| `c0d001d1` | Supplies aboard/lost and postdock repair | 109 focused checks plus copied-ending-profile normal payment/reload |
| `07e4576b` | Warning overlap and truthful route wording | Focused rendered frame review |
| `021b905e` | Survey/chart Field Manual paragraph | Source/static review, no measured usability gain |
| `21ef2c72` | Existing public campaign controls | 82 checks and actual continuation use |
| `a2a1b2c1` | Headless viewport sizing | Isolated geometry/menu smoke; not in campaign kit |
| `4e42c9b3` | Recall acceptance and named-craft guard | 89 focused checks; not in campaign kit |
| `0102ce67` | Photo payoff debrief descriptions | 13 focused checks; rewards/thresholds unchanged |

The strongest confirmed defect: debrief offered B repair at 60%, while Supplies said LOST and suppressed repair. The c0 fix on a separate copied ending profile charged one scrap and one cell, restored B to 100%, retained all 27 recoveries/ending, and survived reload. Original save hash above remained unchanged; repaired-copy hash was `E8AF58538809CA582878E36D1140289DFD5926C5C3C678DFCCDC95065371B313`. This does not retroactively install that fix in the earned run.

Photography already has quality-gated research, later chart information and environmental effects. The debrief correction describes existing Silt Scour/Exhaust Stack effects; it does not add reward payouts. Optional-shot grade cash rewards were not found in inspected settlement. Reward retuning remains an owner decision.

## Precise next steps and limits

1. Resolve the documented integration-target authority conflict before shared reconciliation; no merge or promotion is authorized by these reports.
2. Reconcile selected existing fixes, prioritizing Supplies and readiness, with their own evidence. Do not recreate them or treat all eight as an already-tested integrated build.
3. Obtain bounded fresh-player chart and physical-device controls/performance/audio evidence. Preserve limited sensing and original saves; do not infer automatic navigation or easier rules from one observer's losses.
4. Keep raw evidence, local fix refs and immutable campaign kits preserved. Any remote raw-artifact transfer or implementation publication is separate work.

No claim of commercial readiness, all-endings coverage or Gauntlet completion. No new game run, test, application edit or integration accompanied this publication.
