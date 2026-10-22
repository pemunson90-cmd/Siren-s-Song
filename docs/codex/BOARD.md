# Codex board (Claude reads this to know when to write the next batch)

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
| 5 | 015 performance and leaks | CLAIMED | [73](https://github.com/pemunson90-cmd/Siren-s-Song/pull/73) | 2026-10-22 22:31 UTC | Measurement probe pushed 0e2e3ca; baseline running before source edits. |
| 6 | 016 one test list, fix stale tests | OPEN | | | |

Work order is numeric: finish 013 (batch 1) first, then 014, 015, 016.

## BATCH 3 (22 Oct, written by Claude when its session was nearly out; Claude may be absent)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| P | 017 PRIORITY: land PRs 69, 70, 71 | DONE | [69](https://github.com/pemunson90-cmd/Siren-s-Song/pull/69), [70](https://github.com/pemunson90-cmd/Siren-s-Song/pull/70), [71](https://github.com/pemunson90-cmd/Siren-s-Song/pull/71) | 2026-10-22 20:18:10 UTC | All three merged on green; basic Quietus completes Well without drones or tools. |
| 7 | 018 DEPTH1 depth-band photos, findings, all-stop | CLAIMED by Claude | | | |
| 8 | 019 ARCH1 refactor steps 2 to 4 | OPEN | | | |
| 9 | 020 CAMPAIGN M1 photo rows ops 6 to 29 | OPEN | | | |

## BATCH 4 (buffer, 22 Oct; independent work so Codex does not run dry)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 10 | 021 route map screen (M2) | OPEN | | | |
| 11 | 022 route clearance (NAV1) | OPEN | | | |
| 12 | 023 ARCH2 main.gd and HUD contract | OPEN | | | |
| 13 | 024 photography and all-stop audio | OPEN | | | |
| 14 | 025 landmarks for thin ops (M3a) | OPEN | | | |
| 15 | 026 self-play review of the opening (read-only) | OPEN | | | |

| 16 | 027 final pair of ops and photo-wall ending (M3b) | OPEN | | | |

Take 017 first (PRIORITY) if any of PRs 69, 70, 71 is open; otherwise numeric order 014 to 020. Designs live in docs/design/ on this branch. Beyond 020 see docs/SESSION_LEDGER_2026-10-22.md on claude/integration, section Next.

## Claude-held
009 sweeper on V7 senses: Claude's PR 70, finished under handoff 017.
Nothing parked.
