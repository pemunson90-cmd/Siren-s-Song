# Execution ledger (lightweight; append one line per event)

Started 28 Oct 2026 by Claude under Pat's efficiency baseline. Earlier entries are reconstructed from the board, PRs and session notes.

## Claude sessions
| Session | Window (ET) | Ended by | Restart cost note |
|---|---|---|---|
| S1 | 26 Oct 16:53 to ~18:35 | usage limit (reset 21:20) | Full CLAUDE.md + governance read; necessary first orientation |
| S2 | 27 Oct 19:16 to ~00:30 | usage limit (reset ~00:30) | Heavy: 4-agent inventory, 45-agent gap scout (~6.2M subagent tokens), 9 lane workflows |
| S3 | 28 Oct 05:01 to ~06:25 | Pat hold-off, 5 h cooldown (reset 10:00) | Lane workflows ran to the limit; 5 died at CI stage |
| S4 | 28 Oct 10:04 to ~10:20 | Pat /clear (context hygiene) | Baseline: no Claude subagents; reconcile first |
| S5 | 28 Oct 11:13 to | | Cold restart at medium effort; reconcile from HANDOFF/BOARD/LEDGER + gh only, no re-issue |

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
- 28 Oct 2026: 063 DONE, Codex root; PR184 heade161619c, independent reviews7B+9C+12E, full seven checks green40697606109, mergedd1469e3c; CLEAN automerge/byte identity checked under review12 carry conditions. Desktop CPU gain about 0.2 ms; no FPS or Android performance claim. Prior local core848/0, fidelity102/0.
- 28 Oct 2026: 065 DONE, Codex root; PR183 headef2606d1, independent reviews5B+8C, full seven checks green40694551612, merged433d4df9; CLEAN automerge/byte identity checked under review12 carry conditions. Both alien-module interactions and optional sites integrated; owned source paths released.
- 28 Oct 2026: 075 DONE, Codex root; PR176 head6eff9038, independent reviews6B+8B+12B, full seven checks green40694543912, mergeddb4395aa; CLEAN automerge/byte identity checked under review12 carry conditions. Profile transfer integrated; owned source paths released, subject to056 repair ownership.
- 28 Oct 2026: 082 DONE, Codex root; PR173 heade4241b35, independent reviews8A+12A, full seven checks green40694533215, merged701f4822; CLEAN automerge/byte identity checked under review12 carry conditions. Brannock crew effects integrated; owned source paths released.
- 28 Oct 2026 11:20 ET: Claude S5 reconcile. 087 merged (PR187 e09c2db8). 056/072/085/086 on CI under Codex root. 073 newly eligible. 083 row closed. Pat: let Codex runs finish, fresh sessions for new work.
- 28 Oct 2026 11:30 ET: Pat ruled ending family decided after op 34 with arcs 4 to 6 able to change it; Claude wrote handoff 088 (after 085).
- 28 Oct 2026 11:40 ET: Claude S5 wrote 089 (V7 earned-chart restore), 090 (Promotion 3), 091 (cold audit) and the post-audit roadmap; no Codex runs touched.
- 28 Oct 2026 11:50 ET: Pat ruled hidden Sorley rescue (logs or photo unlock, reward, ending change); Claude wrote handoff 092, added to content-complete list.
- 28 Oct 2026: 056 DONE, Codex root; PR175 head `45991efb`; independent review13A+16; all seven own-head checks green, run40710486650; merged `a4dd77e7`. CLEAN automatic new base and byte identity checked before sequential merges under review16 carry conditions. Campaign, Challenges and seeded runs separated.
- 28 Oct 2026: 085 DONE, Codex root; PR185 head `236aef01`; independent review13B+16; all seven own-head checks green, run40710625875; merged `913f58fa`. CLEAN automatic new base and byte identity checked before sequential merges under review16 carry conditions. Four meaningful late-choice deltas integrated.
- 28 Oct 2026: 086 DONE, Codex root; PR186 head `45c58750`; independent review13C+16; all seven own-head checks green, run40710636101; merged `a0a7550b`. CLEAN automatic new base and byte identity checked before sequential merges under review16 carry conditions. Existing rescue records and briefing crew integrated; no new rescue mechanics.
- 28 Oct 2026: 087 DONE, Codex root; PR187 head `209800ce`; independent review14B; docs-only checks passed (runtime skipped), run40710642054; merged `e09c2db8`. Pat's efficiency baseline recorded; docs only.
- 28 Oct 2026: 072 DONE, Codex root; PR174 head f99fa5a9, independent reviews10/15/16, own seven checks green40713900155, merged db60fe5a after clean unchanged integration; settings ownership released to073.
- 28 Oct 2026 12:26 ET: Pat ruled the bare-launch floor applies to ACCESSIBLE/STANDARD only and the fleet must matter; Claude wrote 093 (measurement) and rewrote the bare rule in 089/091/092.
- 28 Oct 2026 12:27 ET: Pat refined finishability: bare finish = skilled-player feat, must not feel like a walking simulator; 093 and HANDOFF updated.
- 28 Oct 2026: 093 DONE, codex-fresh-093; read-only source 2bfbfc1c, 82 bounded policy attempts over IDs0-40; report docs/design/FLEET_MATTERS_2026-10-28.md: 29 WAYPOINT, 0 THIN, 4 EARNED, 8 UNMEASURED, equipped recovery/pay/ending gaps explicit; isolated artifacts ~/.cache/sirens-song-toolchain/artifacts/093; directives PR194 open, green docs checks, independent review; no game commits or merge.
- 28 Oct 2026 13:52 ET: 093 DONE by a fresh headless Codex session launched by Claude (13:30 to 13:50 ET, ~20 min): 29 WAYPOINT/4 EARNED/8 UNMEASURED. Claude wrote region fix handoffs 094 to 097.
- 28 Oct 2026 14:10 ET: Possible duplicate: root created 093 worktrees at 12:39 while Claude's fresh 093 session ran 13:30 to 13:50. 097 nearly duplicated (claim race); caught before launch. Lesson: claim on BOARD before worktree; Claude checks `git worktree list` before launching.
- 28 Oct 2026 14:16 ET: Pat ruled tools cost cargo; Claude wrote handoff 098.
- 28 Oct 2026 14:27 ET: PR198 (094) held as draft by Claude: success measure was too loose (Claude's wording), oxygen-only pressure passed it. Bar tightened for 094 to 097. Cost: one revision cycle.
- 28 Oct 2026 14:36 ET: PR199 (098) held by Claude intent check (template winch/scout-chassis regressions); Claude stopped both first-pass fresh sessions before auto-merge and relaunched revision sessions (094b, 098b).
- 28 Oct 2026 [CODEX verified closeout]: 057 DONE; PR190 head `6e92643363aa6f2e02c42f914933e20fd1ff3c62`; independent reviews17A/19C/22; merged `2bfbfc1c688dd0eff48e9f888caf78861f6592c5`. All seven own-head checks green: [CI job](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/40727569975/job/122954850748); CLEAN sequential merge and byte identity verified under review22 carry. 12 contracts/4 factions, isolated career/rewards/research/fittings; Career `_notification` and quality methods coexist.
- 28 Oct 2026 [CODEX verified closeout]: 073 DONE; PR189 head `4c28838b7b924d236ab0cd74a9924719baf4aa4c`; independent reviews19A+22; merged `1f98bcee4b20e86fedf76bd8e0fbbf371c3aa6ec`. All seven own-head checks green: [CI job](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/40727567440/job/122954842942); CLEAN sequential merge and byte identity verified under review22 carry. Desktop Compatibility paused10.84Hz cover/8.97Hz inner; UI44/quality43/core842; accelerated60s simulation identical; no phone battery/thermal/GPU claim.
- 28 Oct 2026: 068 DONE, Codex root; PR192 headff3a9e4c, independent reviews21/22, own seven checks green40730766122, merged04486ef9 after clean unchanged integration; run flow released to071.
- 28 Oct 2026 [Source: PR195; external Codex review31]: 067 DONE; head `b6e5b66f`, independent reviews24/31, seven exact-head checks green40749723462, merged `449bcf5c`. Compact briefs30-40, first-use hints and four tool descriptions integrated. Teaching/help paths released, subject to current094/096/097 fleet-fix claims.
- 28 Oct 2026 [Source: PR200; external Codex review31]: 071 DONE; head `d008d7ba`, independent reviews29/30/31, seven exact-head checks green40749967537, merged `3cfb34ba`. Seeded optional riders and once-only bonuses integrated; base completion/pay preserved. Career/run paths released, subject to Claude-owned069 and other current claims.
- 28 Oct 2026, 094b: BLOCKED and stopped per bounded-task order; independent Sol6.1-high quiet replay disproved all six pressure rows (51 checks/0 failures, Hunt0/locks0). PR198 draft/head324286e9 retained; rejected tree de09a430 and recovery artifacts saved; no code commit or merge. Review: https://github.com/pemunson90-cmd/Siren-s-Song/pull/198#issuecomment-6478846123 .
- 28 Oct 2026 15:45 ET: Pat kept the 088 vote rule as is for now (provisionally accepted).
- 28 Oct 2026 15:48 ET: 094b blocked by independent review (cruise toggle manufactured contact); good catch by the reviewer. 094c relaunched; silent-running measurement added to 095 to 097. Finding for Pat: SILENT costs only 4 to 14 s per op versus cruise.
- 28 Oct 2026, 094c: BLOCKED and stopped after six bounded placement/work-site timing probes; exact SILENT matrix175 checks/40 failures, only22/26 qualify (2/8), bare5/8 wins and equipped4/8. PR198 remains draft/head324286e9; no game revision commit/merge. Sources, permanent quiet witness, all18 final rows and recovery ZIPs preserved in artifacts/094c. Further work needs verified work/escape gaps with cargo and fitted-craft recovery; protected-rule changes are not established as necessary.
- 28 Oct 2026 16:41 ET: 094 third attempt BLOCKED (2/8 SILENT pressure). Three Codex cycles spent on 094; parked pending Pat's SILENT-cost ruling.
- 28 Oct 2026 16:44 ET: Pat ruled SILENT may be made clearly slower; Claude wrote 099 and launched a fresh session.
- 28 Oct 2026 16:57 ET: Claude's 098 revision rule over-corrected (templates carry 0 tools); follow-up 100 tool lockers queued. Cost: one extra small handoff.
- 2026-10-28 20:58 UTC [KEEL:096v]: PR202 merged a658c2ca; all 7 bare STANDARD SILENT finish, 6/7 pressure, Hunt 100/37.1/17.2/27/33.2/44.8/20.9 and locks67/4/0/4/0/4/2 (ops30..36); permanent29/0, carry261/0, core842/0, independent Sol6.1-high approval and exact-head CI green. Bounded session complete.
- 2026-10-28 21:23 UTC [KEEL:099]: BLOCKED, stopped without gameplay commit/PR/merge; candidate6m/s tree db1c475f on claude/silent-speed at a658c2ca. Full37 pre0961b56be6f baseline and6/8 probes; same-source6 has19 tight/14 oxygen losses. Import/core842/0, Glass70/0, representative14/0; mixed8/10/11/12 unproven, recipient58/1 and Calder pressure3/7 remain blockers. Patch/metrics/independent review: artifacts/099; other claims preserved.
