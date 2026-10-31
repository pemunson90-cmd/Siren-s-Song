# STATE (updated 2026-10-31T00:03:59-04:00, by orchestrator; workflow v2 migration in progress)

## Base
integration: 05d09718   main: a2300840 (2026-10-19)   production: 26e09906 (Promotion 4, frozen pending question 2)
v1 frozen: branch archive/workflow-v1-2026-10-31 (543fd415); queue folder zip artifacts/workflow-v1-archive/ (MANIFEST.txt)
nightly: not yet running (item 128)   controls mix: not yet measured (item 130)

## In flight
| item | title | class | provider | phase | branch | PR | head |
| 126 | Truthful commands | text | claude (Codex out) | B: pushing reviewed repair 3 | claude/truthful-commands | 238 | 3cde47e4 |
| PKG2 | Stable board | ui | codex root (out) | B | root/stable-board-pkg2 | 239 | f432d0a2 |

## Queued (order = priority; see queue.json)
127 release controls, 128 CI v2, 129 protected golden, 130 control mix, 131 crash possible, 133 recovery manifest, 134 route flow, 135 prep and results

## Blockers
- Codex usage out until about 2026-11-03. Claude may now build (Pat, 2026-10-31, question 1).
- auto.py (v1 runner) still alive; it ignores BLOCKED rows 126/127 and launches nothing. Stop it when runner2.py goes live (step 3).

## Waiting on Pat
- Q2 main as sole promotion target; Q3 intent card and spec line 73; Q4 daily digest; Q5 model cap (docs/workflow-v2/QUESTIONS_FOR_PAT.md on claude/workflow-v2)

## Next
- Push 126 repair 3, intent-check PR 238 on green, merge. Then build 127 with a Claude builder.
