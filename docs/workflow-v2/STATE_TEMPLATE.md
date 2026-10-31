# STATE.md template (the one restart file)

Lives at `docs/state/STATE.md` on `codex/handoffs`. The runner writes the Base, In flight and Blockers sections on every state change (batched, at most one commit per 10 minutes). The orchestrator edits only the Next and Notes lines. Hard cap 60 lines. Anything older goes to the archive branch, not here. Startup reads this file, the last 20 lines of RULINGS.md, the first 20 lines of DECISIONS.md and `python -I runner2.py status`. Nothing else.

```
# STATE (updated <ISO timestamp from date>, by <runner|orchestrator>)

## Base
integration: <sha8> (<date>)      main: <sha8> (<tag>)      last milestone: <tag or none>
nightly: <GREEN|RED run-id> metrics: <path in cache>      controls mix (release policy): <n%> one-press

## In flight (one line per item; phase A build, B verify+PR, C merge)
| item | title | class | provider | phase | branch | PR | head | since |
| 127 | Release controls | sim | claude:opus | A | item/127-release-controls | | | <time> |

## Blockers (one line each, with the failing assertion or the missing decision)
- none

## Waiting on Pat
- Q3 intent card ratification (asked <date>)

## Next (orchestrator, one line)
- Intent-check PR 238 once CI is green on the pushed repair; then queue R3, R4, R5.

## PAUSED (only when execution stopped)
- reason: <usage limit | outage>   resume: `python -I C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/queue-s6/runner2.py resume`
```

## Rules for this file

- Facts come from `queue.json`, GitHub and the nightly artifact; the runner copies them in. No prose history. No session ledgers.
- A line is removed when it stops being true. Done items leave the table; their record is the merged PR.
- If STATE.md and `queue.json` disagree, `queue.json` wins and the runner rewrites STATE.md on its next tick.
- Timestamps come from `date`, never estimated.

## Filled example for tonight (2026-10-30 23:05 EDT)

```
# STATE (updated 2026-10-30T23:05:00-04:00, by orchestrator; v2 not yet live)

## Base
integration: 05d09718 (2026-10-30)   main: a2300840 (2026-10-19)   production: 26e09906 (Promotion 4)
nightly: not yet running   metrics: none   controls mix: not yet measured

## In flight
| item | title | class | provider | phase | branch | PR | head | since |
| 126 | Truthful commands | text | codex (out) | A repair 3 committed, unpushed 3cde47e4 | claude/truthful-commands | 238 | 4268032f | 22:27 |
| 127 | Release controls | sim | none (Codex out, Claude read-only) | queued | | | | 22:30 |
| PKG2 | Stable board | ui | codex root (out) | B | root/stable-board-pkg2 | 239 | f432d0a2 | 21:37 |

## Blockers
- 126: rule conflict, full suite before push (runner.py:64) vs never full locally (FRESH_SESSION_PROMPT, TESTING.md)
- Codex usage out until about 2026-11-03; Claude barred from building (HANDOFF)

## Waiting on Pat
- Q1 Claude may build, bounded (asked 2026-10-30)

## Next
- On Q1 yes: push 3cde47e4, intent-check 238, build 127 with a Claude builder.
```
