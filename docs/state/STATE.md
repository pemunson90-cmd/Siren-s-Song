# STATE (updated 2026-11-01T04:58:21-05:00, by runner2.py)

## Base
integration: 44e7588d   main: a2300840   production: 26e09906
v1 frozen: branch archive/workflow-v1-2026-10-31 (543fd415); queue folder zip artifacts/workflow-v1-archive/ (MANIFEST.txt)
nightly: not yet running (item 128)   controls mix: not yet measured (item 130)

## In flight
| item | title | class | provider | phase | branch | PR | head | status |
| PKG2 | Stable board and clear threat (PR 239, r | ui | external | B | root/stable-board-pkg2 | 239 | 527e4478 | parked |
| 142 | Launching never replaces an active dive  | ui | claude:sonnet | intent | item/142-launch-guard | 251 | 16045d63 | waiting_intent |
| 139 | Bare Quietus meets the Sirens on ops 2,  | sim | claude:opus | A | item/139-bare-contact | 252 | 8efd34eb | active |
| 145 | Briefing and onboarding text matches the | text | claude:sonnet | C | item/145-briefing-truth | 254 | bf99e502 | merging |

## Queued (order = priority; see queue.json)
134 route-flow

## Done (branches kept)
126 claude/truthful-commands PR 238, 127 item/127-release-controls PR 241, 136 item/136-shard-all-failures PR 242, 128 item/128-ci-v2 PR 240, 129 item/129-protected-golden PR 243, 130 item/130-control-mix PR 247, 131 item/131-crash-possible PR 255, 133 item/133-recovery-manifest PR 249, 135 item/135-prep-results PR 244, 137 item/137-menu-scroll-keys PR 246, 138 item/138-player-names PR 245, 140 item/140-dive-end-stats PR 248, 141 item/141-own-craft-legs PR 250, 144 item/144-all-stop-cost PR 253

## Blockers
- 143 dive-end-polish: phase B: widen item 143 card to include game/tests/density_scenarios.gd (required test fixture fix; reverting makes density_scenarios fail 3/1114)
- provider codex down: ERROR: You’ve hit your usage limit. Visit https://chatgpt.com/settings/usage to purchase more credit (probed 2026-11-01T03:25:08-05:00)

## Waiting on Pat
- Q3 intent card and spec line 73; Q4 daily digest; Q5 model cap (docs/workflow-v2/QUESTIONS_FOR_PAT.md on claude/workflow-v2)

## Next
- Resume 127 builder from its pushed branch (worktree Siren-s-Song-item-127); then draft PR, review, intent.
- 136: verify the WIP fix under WSL (empty selection exits non-zero; printf escapes), re-review changed lines, merge on green.
