# STATE (updated 2026-10-31T18:17:01-04:00, by runner2.py)

## Base
integration: 348533af   main: a2300840   production: 26e09906
v1 frozen: branch archive/workflow-v1-2026-10-31 (543fd415); queue folder zip artifacts/workflow-v1-archive/ (MANIFEST.txt)
nightly: not yet running (item 128)   controls mix: not yet measured (item 130)

## In flight
| item | title | class | provider | phase | branch | PR | head | status |
| 127 | Release controls, pilot by hand | sim | claude:opus | A | item/127-release-controls | 241 | 364c124d | active |
| PKG2 | Stable board and clear threat (PR 239, r | ui | external | B | root/stable-board-pkg2 | 239 | 527e4478 | parked |
| 129 | R3 protected rules golden test | protected | claude:opus | review | item/129-protected-golden | 243 | eb2685aa | active |
| 135 | Prep screens put the decision first | ui | claude:sonnet | A | item/135-prep-results | - | - | active |
| 137 | Menu panels scroll and take keys | ui | claude:sonnet | A | item/137-menu-scroll-keys | - | - | active |

## Queued (order = priority; see queue.json)
130 control-mix, 131 crash-possible, 133 recovery-manifest, 134 route-flow, 138 player-names

## Done (branches kept)
126 claude/truthful-commands PR 238, 136 item/136-shard-all-failures PR 242, 128 item/128-ci-v2 PR 240

## Blockers
- none

## Waiting on Pat
- Q3 intent card and spec line 73; Q4 daily digest; Q5 model cap (docs/workflow-v2/QUESTIONS_FOR_PAT.md on claude/workflow-v2)

## Next
- Resume 127 builder from its pushed branch (worktree Siren-s-Song-item-127); then draft PR, review, intent.
- 136: verify the WIP fix under WSL (empty selection exits non-zero; printf escapes), re-review changed lines, merge on green.
