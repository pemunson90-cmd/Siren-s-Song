**Current progress:**061/062 DONE in PR160. Root parallel worker owns058. Pat directs continuous work until usage or stop; if planned queue completes, use an isolated experimental branch for the next improvement within authorized mechanics.

**LIVE, 27 Oct 2026 22:11 Eastern:** Development is running. 059 is DONE (PR158). Sol6.1 medium owns055/PR150 and proceeds056 onward; parallel074/PR162 is building. 060/PR159 and061-062/PR160 plus C7/PR157 are awaiting checks. Entries describing pause or old claims below are historical; current handoff statuses govern.

**27 Oct ~20:25 ET (Claude):** Claude claimed 059, 060, 061 and 062 to build in parallel (branches claude/c8-challenge-pars, claude/c9-event-audio, claude/c10-archive-log). Codex queue: 055, then 056, 057, 058, 063. Claude will write BATCH 15 before Codex runs dry.

**RESUMED, 27 Oct 2026 ~19:17 ET:** Pat told Claude "Resume". This lifts the 27 Oct documentation-only pause (ruling 7). Rulings 1 to 6 stand as design direction. Work order for Codex: 055 (repair PR150's hosted fitting/touch regression, green CI, merge), 056, 057, 058, then 059 (challenge pars and per-route bests from rulings 2 and 3). Same rules as ORCHESTRATION_2026-10-26.md.

**PAUSE NOTE, 26 Oct 2026 ~18:30 ET (Claude): Claude hit its usage limit. The Claude stream is PAUSED and its lanes continue as Codex handoffs 054 to 058 (BATCH 12). Codex owns their files while claimed. The C6 doc sweep and the whole-game audit wait for Claude.**

**CURRENT, 26 October 2026 (Claude): read [ORCHESTRATION_2026-10-26.md](ORCHESTRATION_2026-10-26.md) first. Pat: finish the game, content first, minimal tests, no per-feature independent review, audit at the end. Codex stream = BATCH 11 below. Claude paused; stream C1-C5 transfers to Codex as054-058 after051-053, per current orchestration. 050 merged in PR147 on exact-head green. Older banners below are history.**

**HISTORICAL LOCAL WINDOWS CHECKPOINT, 24 October 2026 Eastern (superseded by Pat's25October continuation and queue below): through032 DONE. Pat selected NEW artwork, merged PR130 at f0fe890, verified remotely and GitHub merged=true. Exact093e own40132818916 both checks green and independent APPROVE. Pat said save rest for later:033 stays OPEN, do not claim or start until Pat resumes. No extra remote-session handoff, request cancelled.**

# Codex board (Claude reads this to know when to write the next batch)

**Historical pre-resume merge order (current live refs and claim rows govern): PR88 merged009f2b8; 035/PR86 merged d9a0bf7; 024/PR87 merged a63aeeb; PR90 sensors merged9ae3212 and PR91 route merged70b1f18; final019 photo mergeddb6b162; 036/PR93 mergedea78d3d; 037/PR94 merged ef27d72; 020/PR85 merged ddc3361; 021/PR95 merged b03dd69; PR96 campaign flow later merged dcf81b5 and documentation98 merged30f555a; that was the historical cloud checkpoint, superseded by completed023..032 and the current Pat deferral above. Reconcile newest integration into each proposed head and recheck if it moved. Use exact-head guidance/game-smoke and independent review before each merge.**

Codex: when you finish a handoff, update its row here in the same commit as `done NNN`. Claude will write batch 2 when two of three rows show DONE.

## BATCH 1 (22 Oct)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 1 | 011 lock warning readability | DONE | [68](https://github.com/pemunson90-cmd/Siren-s-Song/pull/68) | 2026-10-22 17:32:19 UTC | Clear observed-lock countdown, source link and accelerating audio; merged, CI green. |
| 2 | 012 V7 parity gap report | DONE | Report only; no PR | 2026-10-22 17:35:31 UTC | V7 comparison with immutable code anchors and five ranked differences; no game edits. |
| 3 | 013 controls friction | DONE | [71](https://github.com/pemunson90-cmd/Siren-s-Song/pull/71) | 2026-10-22 20:17:41 UTC | Clear rings and FIT/handle ownership on both screen shapes; merged, CI green. |

## BATCH 2 (22 Oct, released when 011 and 012 were DONE)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 4 | 014 challenge mode (12 curated challenges) | DONE | [72](https://github.com/pemunson90-cmd/Siren-s-Song/pull/72) | 2026-10-22 22:26:25 UTC | Twelve challenges; isolated archive; touch/Android Back tests; merged on green 5043a99. |
| 5 | 015 performance and leaks | DONE | [73](https://github.com/pemunson90-cmd/Siren-s-Song/pull/73) | 2026-10-22 23:01:31 UTC | Known-water observation cost reduced; ten identical state hashes; merged on green 9899a2c. |
| 6 | 016 one test list, fix stale tests | DONE | [76](https://github.com/pemunson90-cmd/Siren-s-Song/pull/76) | 2026-10-23 00:57:56 UTC | Merged6229d09; exact6564bb4 guidance/game-smoke green, all189 suites including software renderers. |

Historical batch order:013,014,015,016 are all DONE. Current statuses and Pat's latest deferral above govern.

## BATCH 3 (22 Oct, written by Claude when its session was nearly out; Claude may be absent)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| P | 017 PRIORITY: land PRs 69, 70, 71 | DONE | [69](https://github.com/pemunson90-cmd/Siren-s-Song/pull/69), [70](https://github.com/pemunson90-cmd/Siren-s-Song/pull/70), [71](https://github.com/pemunson90-cmd/Siren-s-Song/pull/71) | 2026-10-22 20:18:10 UTC | All three merged on green; basic Quietus completes Well without drones or tools. |
| 7 | 018 DEPTH1 depth-band photos, findings, all-stop | DONE | [74](https://github.com/pemunson90-cmd/Siren-s-Song/pull/74) | 2026-10-22 23:30 UTC | Merged by Claude: photo_depth, photo_rules, all_stop; each has an off switch. Preconditions of 016, 019, 020, 023 to 027, 033 on 018 are now met. |
| 8 | 019 ARCH1 refactor steps 2 to 4 | DONE | [81](https://github.com/pemunson90-cmd/Siren-s-Song/pull/81), [83](https://github.com/pemunson90-cmd/Siren-s-Song/pull/83), [88](https://github.com/pemunson90-cmd/Siren-s-Song/pull/88), [90](https://github.com/pemunson90-cmd/Siren-s-Song/pull/90), [91](https://github.com/pemunson90-cmd/Siren-s-Song/pull/91), [92](https://github.com/pemunson90-cmd/Siren-s-Song/pull/92) | 2026-10-23 20:04:03 UTC | All six steps merged, final92 atdb6b162 after exacta421140 bothgreen40010611700 and independent approval. Core count parity perstep, targeted checks and17line conventions;036 next. |
| 9 | 020 CAMPAIGN M1 photo rows ops 6 to 29 | DONE | [85](https://github.com/pemunson90-cmd/Siren-s-Song/pull/85) | 2026-10-23 23:02:29 UTC | Merged ddc3361 after exactfad2eba guidance/game-smoke40033091926 green and final independent approval. Core818/photo361/Iron57/journeys108 all0;76pressure pairs identical and verified.021 next. |

## BATCH 4 (buffer, 22 Oct; independent work so Codex does not run dry)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 10 | 021 route map screen (M2) | DONE | [95](https://github.com/pemunson90-cmd/Siren-s-Song/pull/95) | 2026-10-24 00:07:40 UTC | Merged b03dd69 after exact65260da guidance/game-smoke40039574968 green and independent approval including personal50/70 rerun. Core818/graph50/Canvas70 all0; no save fields or operation edits.023 next. |
| 11 | 022 route clearance (NAV1) | DONE | [75](https://github.com/pemunson90-cmd/Siren-s-Song/pull/75) | 2026-10-23 00:05:58 UTC | Merged07eb890; exact-head guidance/game-smoke green, clearance and touch/Back verified. |
| 12 | 023 ARCH2 main.gd and HUD contract | DONE | [96](https://github.com/pemunson90-cmd/Siren-s-Song/pull/96), [99 Windows](https://github.com/pemunson90-cmd/Siren-s-Song/pull/99), [100 photo](https://github.com/pemunson90-cmd/Siren-s-Song/pull/100), [101 metrics](https://github.com/pemunson90-cmd/Siren-s-Song/pull/101), [102 Wake](https://github.com/pemunson90-cmd/Siren-s-Song/pull/102), [104 Rendezvous](https://github.com/pemunson90-cmd/Siren-s-Song/pull/104) | 2026-10-24 05:44:22 UTC | Done023. Final integration8c13f5b; remaining steps100/101/102/104/108/109/110/111/113/115/117/118/119/120 and Windows99 merged with own exact checks and independent approval. Final closure APPROVE; Main950 to817, HUD657 to575, Ocean691 to685; rules/tests/assets unchanged.025 next if OPEN. |
| 13 | 024 photography and all-stop audio | DONE | [87](https://github.com/pemunson90-cmd/Siren-s-Song/pull/87) | 2026-10-23 17:59:25 UTC | Mergeda63aeeb after exact9b2f665 guidance/game-smoke39993951569 green and final independent approval; core818/0,audio47/0; subjective sound unjudged. |
| 14 | 025 landmarks for thin ops (M3a) | DONE | [121](https://github.com/pemunson90-cmd/Siren-s-Song/pull/121) | 2026-10-24 08:23:56 UTC | Done025. Actual merge aaff40e; exact757347b/current0e92729, independent APPROVE, own40075442240 bothgreen. Current831/665/883/468/92/56/49 all0; composed76pairs/1107commands equal. Evidence33dfe86.026 next. |
| 15 | 026 self-play review of the opening (read-only) | DONE | report only | 2026-10-24 09:10:26 UTC | Done026. Six UI attempts:ops0 and5won,op1unfinished,ops2/3/4beam losses; camera overlap confirmed on both shapes. Separate real coldrestart passed; no game edits. Import/core831/0; 694word Completion, verified local evidence ZIP. Corrects empty3997b1e publication;027 next. |

| 16 | 027 final pair of ops and photo-wall ending (M3b) | DONE | [122](https://github.com/pemunson90-cmd/Siren-s-Song/pull/122) | 2026-10-24 10:55:27 | Done027: actual mergea524613 verified. Exact2fe6459 guidance/game-smoke40085216588 green and independent approval. Core833/wall44/model92/save-removal16 all0; fresh touch critic earned pair after one loss, misleading-label P2 fixed.029 next. |

## BATCH 5 (22 Oct evening, written at about 77% of Claude's session usage)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| F | 028 FALLBACK: land PR 74 | DONE (not needed; Claude merged PR 74) | | | |
| 17 | 029 ONBOARD2 short briefings ops 4 to 29 | DONE | [123](https://github.com/pemunson90-cmd/Siren-s-Song/pull/123) | 2026-10-24 13:19:19 UTC | Done029. Actual mergedfaf543; exact053c1ae own40094401838 bothgreen, independent APPROVE. Core833/data57/nativeUI782/scroll52 all0; later151local ran150pass plus qualified Linux launcher failure, unchanged Windows children9/0each. Evidencea74bd80.030 next and claimed. |
| 18 | 030 SAVE1 profiles, copy/clear, export/import | DONE | [124](https://github.com/pemunson90-cmd/Siren-s-Song/pull/124) | 2026-10-24 16:38:27 UTC | Done030. Actual merged131ca0 verified; exact9f3 own40108698464 bothgreen, independent APPROVE. Core833/storage68+cold3/native150%UI168 and affectedall0.44file evidence daa851a, Windowsparent/child qualifications retained.031 next and claimed. |
| 19 | 031 A11Y1 audio-only/color-only cue equivalents | DONE | [127](https://github.com/pemunson90-cmd/Siren-s-Song/pull/127) | 2026-10-24 18:32:23 UTC | Done031. Actual ad841f6 verified remotely and GitHub merged=true. Exact ec23 own40117286964 both green; independent APPROVE; current139 contained. Core835, nativeUI98, Back17 and affected checks all zero failures. Evidence f2d0512.032 next. |
| 20 | 032 ART1 silhouettes (Pat judges) | DONE | [130](https://github.com/pemunson90-cmd/Siren-s-Song/pull/130) | 2026-10-24 22:01:15 UTC | Done032. Pat chose NEW. Actual f0fe890 verified remote/GitHub merged=true, exact093e/current2ce own40132818916 bothgreen and independent APPROVE. Core835/trace23/ART58/native48 all0; prior full proof retained. Evidence2e3b56c/C743 verified.033 deferred by Pat. |
| 21 | 033 DOCS1 MODULES.md and spec refresh | DONE | [145](https://github.com/pemunson90-cmd/Siren-s-Song/pull/145) | 2026-10-25 23:49:44 UTC | Mergee0ee34d3 verified; exacte0c6/currentbbc bothgreen40241428577 and independent PASS6404465570.44module groups, historical17516bytes retained, comment-only headers. Core836/guidance10/hosted17633 all0; evidence27d20bdc.048 next. |

Dependency note: 016, 019, 020, 023 to 027 wait on PR 74 (handoff 018). 021 waits on 020. Work available without PR 74: 022, 029, 030, 031, 032. Pick the lowest OPEN handoff whose precondition is met.

## PRIORITY after 016 (22 Oct night)
| P | 034 FIX1 concrete fixes from cold review 2 | DONE | [78](https://github.com/pemunson90-cmd/Siren-s-Song/pull/78) | 2026-10-23 02:52:10 UTC | Merged7089470; exact9a7180a CI39889490544 green, core817/0, touch218/0, all191 follow-on suites green. Paused before019 per Pat. |

Take 017 first (PRIORITY) if any of PRs 69, 70, 71 is open; otherwise numeric order 014 to 020. Designs live in docs/design/ on this branch. Beyond 020 see docs/SESSION_LEDGER_2026-10-22.md on claude/integration, section Next.

## PRIORITY after 019 step 1 (23 Oct)
| P | 035 FIX2 full cold review fixes (save error first) | DONE | [86](https://github.com/pemunson90-cmd/Siren-s-Song/pull/86) | 2026-10-23 17:17:50 UTC | Mergedd9a0bf7 after exactfd2224a guidance/game-smoke39989872271 green and final independent approval; core818/0 and affected Canvas checks; all11 items fixed or reported. |

## BATCH 6 (23 Oct, Pat's decisions D1 and D2)
| 36 | 036 first-Siren cue, ops 1 to 3 | DONE | [93](https://github.com/pemunson90-cmd/Siren-s-Song/pull/93) | 2026-10-23 21:38:53 UTC | Mergedea78d3d after exacta0f5cba guidance/game-smoke40023109430 green and independent approval/slow52 rerun; core818/0, normal/slow52/0.037 next. |
| 37 | 037 early module reward | DONE | [94](https://github.com/pemunson90-cmd/Siren-s-Song/pull/94) | 2026-10-23 22:20:37 UTC | Merged ef27d72 after exact76e78d3 guidance/game-smoke40028410939 green and final independent approval; core818/0,reward36/0,Canvas40/0. Existing020 next. |

## Claude-held
009 sweeper on V7 senses: Claude's PR 70, finished under handoff 017.
Historical24October status: Codex033 was deferred by Pat and no unfinished Codex implementation claim remained at that checkpoint. Superseded by the25October continuation and current claim rows.

## BATCH 7 (24 Oct, from docs/design/COLD_REVIEW_3.md; items needing Pat are NOT here)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| P | 038 OPS HOME: next op, route map and fittings at top; fold recovered; Erase to Settings only | DONE | [136](https://github.com/pemunson90-cmd/Siren-s-Song/pull/136) | 2026-10-25 03:09:39 UTC | Merged69fc9e46, exact331/current246 bothgreen40153330436 and independent APPROVE. Core835/home1382 all0; evidence537967ff. Optional Back deferred;044 next. |
| 38 | 039 CONSEQUENCE LINES for debriefs of ops15 to30 | DONE | [126](https://github.com/pemunson90-cmd/Siren-s-Song/pull/126) | 2026-10-24 19:24:11 UTC | Claude merged46a3be8; GitHub merged=true and current ancestry verified. Stale claim reconciled24October. |
| 39 | 040 PHOTO ROW JOURNEYS under live Sirens (14 rows) | DONE | [144](https://github.com/pemunson90-cmd/Siren-s-Song/pull/144) | 2026-10-25 22:22:02 UTC | Mergebbc1bed0 verified; exact44a/current0bf bothgreen40234636132 and independent PASS6403464883. Fourteen632/0, local1829/0, hosted17633/0; allhull100. No production edits; evidence250d1222.033 next. |
Also: 029 now includes the F7 addendum (GOAL / DANGER / NEW THIS DIVE for ops 7 to 30). Held for Pat: ending at op 30, replay without erase, settings/title reachable from Operations, quit_on_go_back, early-reward count, anything on Siren senses or lock timing.

## BATCH 8 (24 Oct, Pat's decisions on cold review 3; AI-DESIGNED, Pat to adjust)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| P | 041 BACK1: quit_on_go_back=false and press-Back-again-to-exit | DONE | [125](https://github.com/pemunson90-cmd/Siren-s-Song/pull/125) | 2026-10-24 17:34:15 UTC | Claude merged139f3e9; GitHub merged=true and current ancestry verified. Real phone unverified. |
| 40 | 042 FINALE1 (provisional): ~~END OF LINE screen and photo wall at first recovery of op 30~~ END OF LINE after last id31, reuse027 wall | DONE | [142](https://github.com/pemunson90-cmd/Siren-s-Song/pull/142) | 2026-10-25 16:59:47 UTC | Merge0e1b12ca verified; exact091/current01bc bothgreen40209279734 and independent APPROVE6399876902. Core836/UI246/native255 all0. Pat-authorized existing CI90min; cancelled60min run retained. Evidence42b4238e and Claude cutoff audit;043 next. |
| 41 | 043 SAVE2: 3 hard-save slots, automatic fork save states, replay from fork, truthful ending buttons | DONE | [143](https://github.com/pemunson90-cmd/Siren-s-Song/pull/143) | 2026-10-25 19:46:52 UTC | Merge0bf42344 verified; exact080/current0e1 bothgreen40223499332, independent APPROVE6401867249.3554 local/17001 hosted checks all0. Exact restore/no merge; states survive default erase. Evidence5c241628 retains rejected heads/limits;040 next. |
| 42 | 044 MENU REACH: shared full settings, Title, Challenges, Credits from Operations | DONE | [141](https://github.com/pemunson90-cmd/Siren-s-Song/pull/141) | 2026-10-25 05:11:59 UTC | Merged01bc90b0 verified; exactc991/current69fc bothgreen40161800552 and independent APPROVE with P3 word wrap. Core836/nav324/loadout38 all0; evidence0c86d9bd.042 UPDATE next. |
| 43 | 045 EARLY REWARDS 2: three grants before op 7 (Tele lens, baffles, low-light back) | DONE | PR137/140 | 2026-10-25 02:10 UTC | Pat: pick a number with mechanical value; 3 chosen. |
Still held for Pat: any change to Siren sight, hearing or lock timing (Pat: not yet).

## BATCH 9 (24 Oct, remaining cold review 3 polish items; AI-DESIGNED, Pat to adjust)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 44 | 046 DEATH CAUSE: one plain line on the loss debrief saying why the player was found (read-only) | DONE | PR135/140 | 2026-10-25 02:10 UTC | F9. Sim keeps no cause history; observer needed. |
| 45 | 047 CHALLENGE COMPLETIONS: one scripted completion per row, route-aware par proposal | DONE | PR138/140 | 2026-10-25 02:10 UTC | F11. Par changes are Pat decisions; proposal file only. |
| 46 | 048 HUD SAMENESS: operation-aware status text and explained ARRIVALS | DONE | [146](https://github.com/pemunson90-cmd/Siren-s-Song/pull/146) | 2026-10-26 01:38:35 UTC | Merge 0fb3873e verified; exact e1dbc026/current e0ee34d3, independent PASS 6405622605, both hosted gates green 40249328277. Core 836; independent 3,873 plus external 764; hosted 19,091 checks, all final failures zero. Public wording, explained signals, full-size viewport fit. Evidence 492f484b; 050 next. |
| 44 | 049 FIRST-SIREN CUE EXTENSION: op 1 and a one-time new Siren type note | DONE | PR134/140 | 2026-10-25 02:10 UTC | F8. Released by Pat 24 Oct. Presentation only: no change to Siren sight, hearing or lock timing. |

## BATCH 10 (24 Oct, Pat: restore the V7 Hunt; AI-DESIGNED, Pat to ratify numbers)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 47 | 050 HUNT RESTORE: global sight-only Hunt, visible meter, stage cue, flag | DONE | [147](https://github.com/pemunson90-cmd/Siren-s-Song/pull/147) | 2026-10-26 23:48:53 UTC | Merged ec19ecb4; exact a468bf8d guidance/game-smoke green40413750559. Density1084/0, transport80/0, View32/0; protected mechanics unchanged. |

## Verified stale-claim reconciliation, 24 October2026

Pat requested completion records be reconciled. GitHub merged=true and ancestry in current integration6e69116 were checked; no new implementation or tests are claimed.

| Handoff | Current status | Published resolution |
|---|---|---|
| 003 distinct Iron Choir objectives | DONE | PR63, cb1b7ac |
| 005 old blocked combat attempt | DONE, superseded by010 | PR64,338fae8; old failures retained as history |
| 006 existing story PR repair | DONE | PR56,49725ce; no new story |
| 009 V7-senses sweeper | DONE | PR70,567f0b2; already covered by017 |
| 039 consequence lines | DONE | PR126,46a3be8 |
| 041 Back exit | DONE | PR125,139f3e9 |

Progress report: [CODEX_REPORT_2026-10-24.md](CODEX_REPORT_2026-10-24.md).033 and all genuinely unfinished handoffs remain OPEN. Do not interpret this record cleanup as resuming development.

The same audit filled empty Completion sections in already-DONE002/PR62,004/PR61 and018/PR74 using verified merged references, and clarified001/PR59's already-satisfied merge recommendation. All50 status headers were checked:38DONE (including005superseded),12OPEN. No unfinished item was marked complete.

## SPLIT 24 Oct (Pat): Claude claims 045, 046, 047, 048, 049, 050. Codex takes 033, 038, 040, 042, 043, 044 when Pat says continue. Rank blocks: Claude local 228-239 / CI 251-259; Codex local 240+ / CI 260+.

## Pat continuation,25October2026 Eastern

Current authorized order:040 photo journeys,033 documentation,048 HUD,050 sight-only Hunt. Pat asked to follow guidance, reconcile stale owned documentation as work proceeds, keep working while questions are pending, and make choices revertible. Preserve off switches, data tables and narrow seams; uncertainty does not authorize changes to protected mechanics beyond the approved sight-only Hunt scope. At this continuation checkpoint only040 was claimed by Codex; current claim rows above govern. Historical pause/split statements above retain provenance and do not override this continuation.


## BATCH 11 (26 Oct, Pat: finish the game; rules in ORCHESTRATION_2026-10-26.md)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 48 | 051 CALDER TRENCH arc6: ops32-34 core,35-36 optional,3 artifacts,finale34 | DONE | [152](https://github.com/pemunson90-cmd/Siren-s-Song/pull/152) | 2026-10-27 02:10:38 UTC | Merged67bf23f6; exact4af007a7 guidance/game-smoke green40429459471. Bare journeys14/0; core841/0. |
| 49 | 052 OPTIONAL OPS37-40: Sorley trawler and three regional side jobs | DONE | [153](https://github.com/pemunson90-cmd/Siren-s-Song/pull/153) | 2026-10-27 03:33:35 UTC | Merged77f26ced; exacted45b49e gates green40437527882; import/core845/0. |
| 50 | 053 REGIONAL PRESENTATION: regional ambience/look and Night mode | DONE | [154](https://github.com/pemunson90-cmd/Siren-s-Song/pull/154) | 2026-10-27 05:19:42 UTC | Mergeda754e7d7; exact1d24364e gates green40448790846; core846/0/settings18/0/scroll17/0. |

Claude stream C (not Codex work, listed so you know what is coming and which files are taken): C1 economy, C2 equipment and tools, C3 modes and expeditions, C4 naval career, C5 settings gaps, C6 doc sweep.

## BATCH 12 (26 Oct, Claude stream transferred to Codex at Claude's usage limit)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 51 | 054 C1 ECONOMY | DONE | [151](https://github.com/pemunson90-cmd/Siren-s-Song/pull/151) | 2026-10-27 06:31:16 UTC | Merged0f2cc962; exact710f8909 gates green40455323703; core846/economy57/save13, zero failures. |
| 52 | 055 C2 EQUIPMENT AND TOOLS | CLAIMED (codex, active PR150) | [150 draft](https://github.com/pemunson90-cmd/Siren-s-Song/pull/150) | 2026-10-27 07:01:06 UTC | Head1f781bdb; local core846/tools87/radial58/touch36 all zero failures. Relay passive35% differs from requested command range (unlimited); awaiting Pat, CI pending. |
| 53 | 056 C3 MODES: mode select, campaign rename, seeded expeditions | OPEN | | | |
| 54 | 057 C4 NAVAL CAREER | OPEN | | | |
| 55 | 058 C5 SETTINGS GAPS | CLAIMED (codex-root-parallel) | | | |


## PAT DESIGN RULINGS — 27 Oct 2026 (documentation-only; development PAUSED)

These seven decisions are approved design direction, **not** evidence of implementation, balancing, CI success, a resumed claim, or permission to merge/promote. Preserve the current development pause. No task is claimed or restarted by this entry.

1. **055 Relay buoy:** retain the implemented **+35% passive-sensing bonus** instead of inventing drone command-range limits. It benefits **both drones when each is inside the buoy's effect radius**. Existing unlimited command range remains unchanged. Approval resolves the *design question*, not PR #150's failed hosted fitting/touch regression; repair and fresh green exact-head CI are still needed after work is resumed. Keep 055 BLOCKED/PAUSED, do not mark DONE.
2. **047 challenge route pars:** score `lung_solo` at **110 s for dismantle** and **300 s for reconnect**, selected from the actual mission route. Preserve hull/tools par requirements. Approved for future implementation, not yet in scoring code.
3. **047 personal bests:** keep **best per route** and an **overall challenge completion** record; do not let a fast dismantle time erase the reconnect achievement. Precise UI/scoring presentation can be designed after resumption.
4. **050 Hunt:** approve *current reversible sight-only tuning* as the **testing baseline**, not final balance. Retain current per-operation resets, caps, action values, HUD and audio behavior; hearing, movement, lock, beam and damage remain unchanged. Retune only from full-game evidence.
5. **054 economy:** prices, resource rewards, research/manufacturing costs and preset values remain **provisional**, to be calibrated with **simulated full-campaign runs**. No current numbers are ratified as final balance.
6. **Whole-game audit order:** **finish planned content first**, then prioritize **photographic reconnaissance, strategic depth and actual player experience** in the independent whole-game audit. Other quality, technical and Android findings still belong in that audit.
7. **PAUSE:** record these decisions only. **Do not resume implementation, run builds, claim 056–058, change gameplay code, merge PRs or promote branches** from this documentation update. Existing open/block statuses are retained.

## BATCH 13 (27 Oct, from Pat's rulings 2 and 3)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 56 | 059 CHALLENGE PARS AND PER-ROUTE BESTS (lung_solo 110 s dismantle / 300 s reconnect) | CLAIMED (claude, claude/c8-challenge-pars) | | | |

## BATCH 14 (27 Oct, queue depth; take after 059 in numeric order where preconditions allow)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 57 | 060 EQUIPMENT AND EVENT AUDIO | CLAIMED (claude, claude/c9-event-audio) | [159](https://github.com/pemunson90-cmd/Siren-s-Song/pull/159) | | Head20743b68; PCM cache fixed; guidance green, hosted Operations480s timeout persists (CI40621139086). CI lane returned to root; NOT merged. |
| 58 | 061 RECEIVED MESSAGES, FIELD LOGS, RECURRING VOICES | DONE | [160](https://github.com/pemunson90-cmd/Siren-s-Song/pull/160) | 2026-10-28 UTC | Merged88188bd0; current-head checks green. |
| 59 | 062 RESEARCH SCREEN, ARCHIVE AND CREDITS | DONE | [160](https://github.com/pemunson90-cmd/Siren-s-Song/pull/160) | 2026-10-28 UTC | Merged88188bd0; current-head checks green. |
| 60 | 063 PERFORMANCE PASS | OPEN | | | |

Claude lanes in parallel (not Codex work): C6 doc sweep (claude/c6-doc-sweep), C7 economy calibration by simulated campaign runs (claude/c7-economy-calibration): PR157 head3848ef2a, reconciled integration88188bd0. Repeated480s ops_home timeout repaired by shape-partitioned native CI (91ae12c2); full inherited coverage retained, no assertion/renderer/timeout or gameplay change. Isolated local native partitions2096/0 equal integration full2096/0; import/core846/sim109/registry/guidance pass. Exact-head CI40621628804: guidance green, game-smoke running; NOT merged. Completion and remaining merge steps: https://github.com/pemunson90-cmd/Siren-s-Song/pull/157#issuecomment-6459077025 .

## BATCH 15 (27 Oct, from Claude's verified gap scout; numeric order is priority, preconditions gate eligibility)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 61 | 064 Fittings and briefing fit surface at 24-module catalog scale | OPEN | | | |
| 62 | 065 Give the two new alien modules (Trench wellhead seal, Choir reed tuner) a world  | OPEN | | | |
| 63 | 066 Make hull, chassis and the new tools matter through optional fleet-specializatio | OPEN | | | |
| 64 | 067 Teaching and briefings for the mid and late campaign | OPEN | | | |
| 65 | 068 Expedition between-operation choices (route fork, repair or boon) | OPEN | | | |
| 66 | 069 Expedition run summary, records and seed entry | OPEN | | | |
| 67 | 070 Expedition and career dive resume after app kill | OPEN | | | |
| 68 | 071 Career and expedition riders: optional contract conditions with bonus pay | OPEN | | | |
| 69 | 072 Settings depth: separate mixer, haptic strength and coverage, gesture timing | OPEN | | | |
| 70 | 073 Performance and battery tier: Low-effects quality setting, auto frame-time gover | OPEN | | | |
| 71 | 074 New geometry for optional ops 38 and 39 | CLAIMED (codex-root-parallel) | [162](https://github.com/pemunson90-cmd/Siren-s-Song/pull/162) | | WIP 007405f5; local import/core846/0, bare journeys18/0; exact-head CI pending. |
| 72 | 075 Profile export and import that works on a real phone (system file dialog or shar | OPEN | | | |
| 73 | 076 Arc 6 distinct topologies and a staged capstone for op 34 | CLAIMED (claude, claude/c11-arc6-capstone) | | | |
| 74 | 077 Route and recovered-fact carry into arcs 4 to 6 | CLAIMED (claude, claude/c12-route-carry) | | | |
| 75 | 078 Campaign ledger: expand END OF LINE and the ending into a full account of people | CLAIMED (claude, claude/c13-ledger) | | | |
| 76 | 079 Ironman save integrity (no hard-save or fork undo bypass) | CLAIMED (claude, claude/c14-ironman) | | | |
| 77 | 080 Arc boundary beats and arc-grouped Operations list | OPEN | | | |
| 78 | 081 Reduced motion, high contrast and safe palette do not reach the tactical chart | OPEN | | | |
| 79 | 082 Rescued people and recovered knowledge as visible Brannock crew effects | OPEN | | | |
| 80 | 083 Add a Siren dossier: what each of the eight roles does and how to counter it, un | CLAIMED (codex, claude/lane-siren-dossier; WIP PR164) | [164 draft](https://github.com/pemunson90-cmd/Siren-s-Song/pull/164) | | Head2573f17d on base88188bd0; import/core846/0; Archive UI102/0. Awaiting 058 for Operations-home entry; hosted CI pending. |

Tooling repair pending: gauntlet-boundary.py imports fcntl unconditionally and cannot run on native Windows. Fix platform locking or supply supported Linux invocation; preserve guidance checks. Observed at059 closeout, 27Oct2026.

Boundary follow-up28Oct03:12UTC: Windows completion check PASSES from current integration88188bd0 using Siren-s-Song-codex-058. Earlier fcntl error came from the stale protected-main checkout; integration already has platform-specific locking. Use the current lane copy for boundaries; no new tooling repair is required.
