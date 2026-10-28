# Handoff 060: EQUIPMENT AND EVENT AUDIO

Status: CLAIMED
Claimed at: 2026-10-28 00:21:22 UTC
Claimed by: claude
Finished at:

Precondition: 053 is DONE. Take after 059 or whenever no CLAIMED handoff owns audio/*. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Spec audio list: distinct propulsion, sonar, enemy, hull, equipment, impact/loss/extraction cues, prioritized consequential sounds, each with a visual/caption equivalent. Today camera/photo cues exist but most equipment and the 4 new field tools (sonobuoy, silt_screen, hull_patch, relay_buoy) and new modules have no own cue, and hull stress (creak) triggering is unclear. Add a cue table: one short cue per field tool use, module activation where it is a player action, hull stress by collision severity, survivor pickup, artifact secure, research complete. Reuse the existing generated-audio approach and Soundscape paths; respect cue rate limits; add captions through the existing accessibility caption path. Off switch restores today.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-event-audio

## Files you may edit
audio/* (cue table, generated cues), presentation/accessibility/* caption rows, minimal hook calls at existing event points; shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files of any other CLAIMED handoff. Claude lanes in flight: claude/c6-doc-sweep (docs/ only) and claude/c7-economy-calibration (campaign/economy_table.gd numbers + new tools/tests only).

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Ranks: Codex local 300-349 / CI 400-449 (next free).

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
Codex CI repair returned to root: [PR159](https://github.com/pemunson90-cmd/Siren-s-Song/pull/159) OPEN / NOT MERGED; head20743b68 includes integration88188bd0.
Fixed repeated event PCM synthesis in f6a542de: 36 setups6094.9ms to171.1ms; players/state remain local.
Verified isolated import/core846/0, event-cue45/0, native Operations2060/0 (167.65s original;159.59s fixed).
[CI40621139086](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/40621139086): guidance PASS; ops_home_ui_tests repeats480s timeout, no reported assertion failure. No further rerun.
Remaining: root investigates hosted renderer/suite performance and field-tool hooks afterPR150; claimed status retained. Only owned audio/test fix; imports preserved. [Report](https://github.com/pemunson90-cmd/Siren-s-Song/pull/159#issuecomment-6460051280).

## Claude claim (27 Oct)
Claude builds this in parallel with Codex on branch `claude/c9-event-audio` (worktree Siren-s-Song-claude-*). Codex: skip it; Claude owns its listed files until DONE.
