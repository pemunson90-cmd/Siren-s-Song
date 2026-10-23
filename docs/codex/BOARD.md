# Codex board (Claude reads this to know when to write the next batch)

**MERGES CLEAR (Pat,23Oct latest): PR88 merged009f2b8; 035/PR86 merged d9a0bf7; 024/PR87 merged a63aeeb; PR90 sensors merged9ae3212 and PR91 route merged70b1f18; final019 photo mergeddb6b162; next036/PR93,037/PR94 and the eligible numeric queue. Reconcile newest integration into each proposed head and recheck if it moved. Use exact-head guidance/game-smoke and independent review before each merge.**

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

Work order is numeric: finish 013 (batch 1) first, then 014, 015, 016.

## BATCH 3 (22 Oct, written by Claude when its session was nearly out; Claude may be absent)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| P | 017 PRIORITY: land PRs 69, 70, 71 | DONE | [69](https://github.com/pemunson90-cmd/Siren-s-Song/pull/69), [70](https://github.com/pemunson90-cmd/Siren-s-Song/pull/70), [71](https://github.com/pemunson90-cmd/Siren-s-Song/pull/71) | 2026-10-22 20:18:10 UTC | All three merged on green; basic Quietus completes Well without drones or tools. |
| 7 | 018 DEPTH1 depth-band photos, findings, all-stop | DONE | [74](https://github.com/pemunson90-cmd/Siren-s-Song/pull/74) | 2026-10-22 23:30 UTC | Merged by Claude: photo_depth, photo_rules, all_stop; each has an off switch. Preconditions of 016, 019, 020, 023 to 027, 033 on 018 are now met. |
| 8 | 019 ARCH1 refactor steps 2 to 4 | DONE | [81](https://github.com/pemunson90-cmd/Siren-s-Song/pull/81), [83](https://github.com/pemunson90-cmd/Siren-s-Song/pull/83), [88](https://github.com/pemunson90-cmd/Siren-s-Song/pull/88), [90](https://github.com/pemunson90-cmd/Siren-s-Song/pull/90), [91](https://github.com/pemunson90-cmd/Siren-s-Song/pull/91), [92](https://github.com/pemunson90-cmd/Siren-s-Song/pull/92) | 2026-10-23 20:04:03 UTC | All six steps merged, final92 atdb6b162 after exacta421140 bothgreen40010611700 and independent approval. Core count parity perstep, targeted checks and17line conventions;036 next. |
| 9 | 020 CAMPAIGN M1 photo rows ops 6 to 29 | CLAIMED | [85 draft](https://github.com/pemunson90-cmd/Siren-s-Song/pull/85) | | Preparedd82df6d includes actual019/proposed036/037; M1 data/tests unchanged, independent preparation review approved. Combined runtime/new paired pressure running; draft85 stays behind93/94 and final actual-parent review/CI. |

## BATCH 4 (buffer, 22 Oct; independent work so Codex does not run dry)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 10 | 021 route map screen (M2) | OPEN | | | |
| 11 | 022 route clearance (NAV1) | DONE | [75](https://github.com/pemunson90-cmd/Siren-s-Song/pull/75) | 2026-10-23 00:05:58 UTC | Merged07eb890; exact-head guidance/game-smoke green, clearance and touch/Back verified. |
| 12 | 023 ARCH2 main.gd and HUD contract | OPEN | | | |
| 13 | 024 photography and all-stop audio | DONE | [87](https://github.com/pemunson90-cmd/Siren-s-Song/pull/87) | 2026-10-23 17:59:25 UTC | Mergeda63aeeb after exact9b2f665 guidance/game-smoke39993951569 green and final independent approval; core818/0,audio47/0; subjective sound unjudged. |
| 14 | 025 landmarks for thin ops (M3a) | OPEN | | | |
| 15 | 026 self-play review of the opening (read-only) | OPEN | | | |

| 16 | 027 final pair of ops and photo-wall ending (M3b) | OPEN | | | |

## BATCH 5 (22 Oct evening, written at about 77% of Claude's session usage)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| F | 028 FALLBACK: land PR 74 | DONE (not needed; Claude merged PR 74) | | | |
| 17 | 029 ONBOARD2 short briefings ops 4 to 29 | OPEN | | | |
| 18 | 030 SAVE1 profiles, copy/clear, export/import | OPEN | | | |
| 19 | 031 A11Y1 audio-only/color-only cue equivalents | OPEN | | | |
| 20 | 032 ART1 silhouettes (Pat judges) | OPEN | | | |
| 21 | 033 DOCS1 MODULES.md and spec refresh | OPEN | | | |

Dependency note: 016, 019, 020, 023 to 027 wait on PR 74 (handoff 018). 021 waits on 020. Work available without PR 74: 022, 029, 030, 031, 032. Pick the lowest OPEN handoff whose precondition is met.

## PRIORITY after 016 (22 Oct night)
| P | 034 FIX1 concrete fixes from cold review 2 | DONE | [78](https://github.com/pemunson90-cmd/Siren-s-Song/pull/78) | 2026-10-23 02:52:10 UTC | Merged7089470; exact9a7180a CI39889490544 green, core817/0, touch218/0, all191 follow-on suites green. Paused before019 per Pat. |

Take 017 first (PRIORITY) if any of PRs 69, 70, 71 is open; otherwise numeric order 014 to 020. Designs live in docs/design/ on this branch. Beyond 020 see docs/SESSION_LEDGER_2026-10-22.md on claude/integration, section Next.

## PRIORITY after 019 step 1 (23 Oct)
| P | 035 FIX2 full cold review fixes (save error first) | DONE | [86](https://github.com/pemunson90-cmd/Siren-s-Song/pull/86) | 2026-10-23 17:17:50 UTC | Mergedd9a0bf7 after exactfd2224a guidance/game-smoke39989872271 green and final independent approval; core818/0 and affected Canvas checks; all11 items fixed or reported. |

## BATCH 6 (23 Oct, Pat's decisions D1 and D2)
| 36 | 036 first-Siren cue, ops 1 to 3 | CLAIMED | [93](https://github.com/pemunson90-cmd/Siren-s-Song/pull/93) | | Final57806a3 contains actualdb6b162; core818/0, functional37/0, rendered50/0 and affected checks pass. Independent final review approved. PR ready; exact CI40016621553 guidance green/game-smoke running. |
| 37 | 037 early module reward | CLAIMED | [94 draft](https://github.com/pemunson90-cmd/Siren-s-Song/pull/94) | | Publisheda475cb6 includes actual92 and proposed03657806a3; core818/0,both functional/Canvas and save checks pass. Composition review approved; actual93 merge then final reconciliation/review/CI required. |

## Claude-held
009 sweeper on V7 senses: Claude's PR 70, finished under handoff 017.
Nothing parked.
