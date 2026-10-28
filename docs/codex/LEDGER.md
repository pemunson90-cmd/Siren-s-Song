# Execution ledger (lightweight; append one line per event)

Started 28 Oct 2026 by Claude under Pat's efficiency baseline. Earlier entries are reconstructed from the board, PRs and session notes.

## Claude sessions
| Session | Window (ET) | Ended by | Restart cost note |
|---|---|---|---|
| S1 | 26 Oct 16:53 to ~18:35 | usage limit (reset 21:20) | Full CLAUDE.md + governance read; necessary first orientation |
| S2 | 27 Oct 19:16 to ~00:30 | usage limit (reset ~00:30) | Heavy: 4-agent inventory, 45-agent gap scout (~6.2M subagent tokens), 9 lane workflows |
| S3 | 28 Oct 05:01 to ~06:25 | Pat hold-off, 5 h cooldown (reset 10:00) | Lane workflows ran to the limit; 5 died at CI stage |
| S4 | 28 Oct 10:04 to | | Baseline: no Claude subagents; reconcile first |

## Usage observations (readily available only)
- 26 Oct ~18:35 ET: five-hour limit hit with two sonnet lanes + Codex running.
- 28 Oct ~00:30 ET and ~06:30 ET: limits hit with 7 to 9 Claude lane workflows in parallel. Lesson: Claude-side parallel lanes exhausted the five-hour budget in about 4 hours; Codex carries execution better.
- Weekly usage: not observed in session.

## Delegated work and outcomes (handoff, executor, PR, result)
- 050 Hunt, Codex, PR147, merged. 051 Calder, Codex, PR152, merged. 052 optionals, Codex, PR153, merged. 053 regions + Night mode, Codex, PR154, merged.
- 054 economy, Claude lane then Codex, PR151, merged. 055 modules + 8 tools, Claude lane then Codex, PR150, merged (one Pat ruling on relay).
- 058 menu focus/fps, Codex root, PR163. 059 pars, Claude lane, PR158. 060 audio, Claude lanes, PR159+177. 061/062 voices/archive/research/credits, Claude lane, PR160.
- 064 fit surface, Claude lane then Codex root repair, PR178. 066 fleet sites, Codex root, PR169. 074 optional geometry, Codex, PR162.
- 076 Arc 6 capstone, Claude lane died, Codex root resumed, PR165. 077 carry, same, PR166. 078 ledger, same, PR167+170. 079 Ironman, same, PR168.
- 081 chart accessibility, Codex root, PR171. 083 dossier, Codex, PR164. 084 CI shards, Codex root built, Claude fixed and merged, PR172. 065 partial, Codex root, PR183. Silt photo fix, Codex root, PR180.
- C6 doc sweep (haiku), PR156. C7 economy calibration (sonnet, finished by Codex root), PR157. Owner questions doc, PR161.
- Promotions: P1 PR148 (Claude, 26 Oct). P2 PR179 to production 225c3c45 (Codex root, independently reviewed, 28 Oct).
- In flight at S4 start: 056 PR175 (HOLD for Back-navigation bug), 063 perf, 065 completion, 072 PR174, 075 PR176, 082 PR173 (Codex root review cycles).

## Failed, retried or duplicated work
- Claude lanes C1/C2 (26 Oct) and 076 to 079 (27 Oct) died at usage limits; Codex resumed from pushed WIP, no work lost.
- PR165 cancelled by the 90-minute single-job CI cap; fixed structurally by 084 sharding.
- PR172 first run failed: upload-artifact rejected '..' path; one-commit fix.
- Two roots active at once on 28 Oct (codex-root during Claude cooldown); resolved by explicit banner splits, no duplicate implementation found.
- Cost outlier: the 27 Oct gap scout (45 agents) found 24 real gaps but cost far more than a 4-agent pass would have.

## Suspected redundant context loading
- Each Claude lane agent re-read CONVENTIONS/TESTING/handoffs; acceptable but avoidable under the baseline.
- Large CLAUDE.md files are injected every session; out of project control.
