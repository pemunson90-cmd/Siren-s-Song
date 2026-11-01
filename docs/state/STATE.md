# STATE (updated 2026-11-01T16:38:58-05:00, by runner2.py)

## Base
integration: 07a7e12b   main: a2300840   production: 26e09906
v1 frozen: branch archive/workflow-v1-2026-10-31 (543fd415); queue folder zip artifacts/workflow-v1-archive/ (MANIFEST.txt)
nightly: not yet running (item 128)   controls mix: not yet measured (item 130)

## In flight
| item | title | class | provider | phase | branch | PR | head | status |
| PKG2 | Stable board and clear threat (PR 239, C | ui | claude:opus | A | root/stable-board-pkg2 | 239 | 716c895a | active |
| 142 | Launching never replaces an active dive  | ui | claude:sonnet | C | item/142-launch-guard | 251 | 033301ea | merging |
| 134 | Route flow (package 4) | sim | external | - | item/134-route-flow | - | - | parked |
| 139 | Bare Quietus meets the Sirens on ops 2,  | sim | claude:opus | C | item/139-bare-contact | 252 | 2bff50e5 | merging |
| 143 | Honest END DIVE, stats on every recovery | ui | claude:sonnet | intent | item/143-dive-end-polish | 256 | d9909629 | waiting_intent |
| 146 | Entry docs point at the live state | text | claude:sonnet | C | item/146-docs-pointers | 257 | 114edb30 | merging |
| 147 | Debug APK from any branch, signature che | ui | claude:sonnet | A | item/147-integration-apk | - | - | active |

## Queued (order = priority; see queue.json)
148 android-smokes

## Done (branches kept)
126 claude/truthful-commands PR 238, 127 item/127-release-controls PR 241, 136 item/136-shard-all-failures PR 242, 128 item/128-ci-v2 PR 240, 129 item/129-protected-golden PR 243, 130 item/130-control-mix PR 247, 131 item/131-crash-possible PR 255, 133 item/133-recovery-manifest PR 249, 135 item/135-prep-results PR 244, 137 item/137-menu-scroll-keys PR 246, 138 item/138-player-names PR 245, 140 item/140-dive-end-stats PR 248, 141 item/141-own-craft-legs PR 250, 144 item/144-all-stop-cost PR 253, 145 item/145-briefing-truth PR 254

## Blockers
- provider codex down: exit 1: ERROR: unexpected status 401 Unauthorized: Missing bearer or basic authentication in header, (probed 2026-11-01T16:35:06-05:00)

## Waiting on Pat
- Q3 intent card and spec line 73; Q4 daily digest; Q5 model cap (docs/workflow-v2/QUESTIONS_FOR_PAT.md on claude/workflow-v2)

## Next (reconciled 1 Nov against reports/2026-11-01-sirens-song-full-project-overview.md and COLD_REVIEW_5)
- Finish in flight: 139 merging; 142 and 143 phase B (cards widened 1 Nov); intent on each green exact head.
- 146 docs-pointers (HOLD for the stale APK sentence).
- 147 integration-apk: debug APK from any branch with a signer check; then one APK of integration after PKG2, 142, 143 land, for Pat to test on the Fold.
- PKG2 stable board (CR5 ranks 1, 2, 5, 6: 150% reach, tap ownership, threat occlusion, chart re-fit). Highest player cost left. Pat 1 Nov: Claude takes it (claude:opus, merge integration into the branch).
- Before critic 6: confirm the critic driver fix (package 0: explicit parse errors, temp-then-rename writes) is in the critic kit; nightly (128) and control-mix number (130) produce a first reading.
- Critic 6, blind whole game on claude/integration after PKG2 lands: must reach END OF LINE and each ending family, Glass Reach 5-9, Iron Choir, one full Expedition, a Career stretch, Ironman. Watch list (not told to the critic): does contact on ops 2/16/17/20 (139) change a decision or cost anything (scripted course shows no cost); do photos read as their subjects and pay off later (F1/F15); does an unanswered launch still lose a dive.
- From critic 6, plan in this order: photo payoff (value favours distance and tools over quality, plan item 7); late-op variety and the branching route graph (forks mostly change approaches inside ops, not which ops you get; Star Fox scope in the spec); fitting allocation (CR5 rank 10, partly done by 135/138); look and sound read-only comparison (package 6; building waits on Pat art calls; audio never assessed).
- Not ours to start: physical Fold acceptance (Pat plays the APK); art/story changes (Pat rules).
