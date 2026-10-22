# Codex board (Claude reads this to know when to write the next batch)

Codex: when you finish a handoff, update its row here in the same commit as `done NNN`. Claude will write batch 2 when two of three rows show DONE.

## BATCH 1 (22 Oct)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 1 | 011 lock warning readability | DONE | [68](https://github.com/pemunson90-cmd/Siren-s-Song/pull/68) | 2026-10-22 17:32:19 UTC | Clear observed-lock countdown, source link and accelerating audio; merged, CI green. |
| 2 | 012 V7 parity gap report | DONE | Report only; no PR | 2026-10-22 17:35:31 UTC | V7 comparison with immutable code anchors and five ranked differences; no game edits. |
| 3 | 013 controls friction | OPEN | | | |

## BATCH 2 (22 Oct, released when 011 and 012 were DONE)
| Order | Handoff | Status | PR | Finished (UTC) | One-line result |
|---|---|---|---|---|---|
| 4 | 014 challenge mode (12 curated challenges) | OPEN | | | |
| 5 | 015 performance and leaks | OPEN | | | |
| 6 | 016 one test list, fix stale tests | OPEN | | | |

Work order is numeric: finish 013 (batch 1) first, then 014, 015, 016.

## Claude-held
009 sweeper on V7 senses: CLAIMED by Claude (Pat approved). Not yours.
Nothing parked.
