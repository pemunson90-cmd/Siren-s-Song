# STATE (updated 2026-10-31T23:22:40-04:00, by runner2.py)

## Base
integration: e51b85d0   main: a2300840   production: 26e09906
v1 frozen: branch archive/workflow-v1-2026-10-31 (543fd415); queue folder zip artifacts/workflow-v1-archive/ (MANIFEST.txt)
nightly: not yet running (item 128)   controls mix: not yet measured (item 130)

## In flight
| item | title | class | provider | phase | branch | PR | head | status |
| PKG2 | Stable board and clear threat (PR 239, r | ui | external | B | root/stable-board-pkg2 | 239 | 527e4478 | parked |
| 130 | R5 control-mix telemetry (dev state only | sim | claude:opus | A | item/130-control-mix | 247 | bc424bca | active |
| 133 | Recovery manifest before the dive ends | ui | claude:sonnet | A | item/133-recovery-manifest | - | - | active |
| 137 | Menu panels scroll and take keys | ui | claude:sonnet | C | item/137-menu-scroll-keys | 246 | a0729129 | merging |
| 138 | No internal ids on player screens | text | claude:sonnet | C | item/138-player-names | 245 | e96806c5 | merging |
| 139 | Bare Quietus meets the Sirens on ops 2,  | sim | claude:opus | A | item/139-bare-contact | - | - | active |
| 140 | Every dive end shows time, hull and oxyg | ui | claude:sonnet | A | item/140-dive-end-stats | - | - | active |

## Queued (order = priority; see queue.json)
131 crash-possible, 134 route-flow, 141 own-craft-legs

## Done (branches kept)
126 claude/truthful-commands PR 238, 127 item/127-release-controls PR 241, 136 item/136-shard-all-failures PR 242, 128 item/128-ci-v2 PR 240, 129 item/129-protected-golden PR 243, 135 item/135-prep-results PR 244

## Blockers
- none

## Waiting on Pat
- Q3 intent card and spec line 73; Q4 daily digest; Q5 model cap (docs/workflow-v2/QUESTIONS_FOR_PAT.md on claude/workflow-v2)

## Next
- Resume 127 builder from its pushed branch (worktree Siren-s-Song-item-127); then draft PR, review, intent.
- 136: verify the WIP fix under WSL (empty selection exits non-zero; printf escapes), re-review changed lines, merge on green.
