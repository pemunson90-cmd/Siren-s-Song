# Handoff 059: CHALLENGE PARS AND PER-ROUTE BESTS

Status: DONE
Claimed at: 2026-10-28 00:21:22 UTC
Claimed by: claude
Finished at: 2026-10-28 01:27:16 UTC

Precondition: 056 is DONE or not CLAIMED (avoids frontend overlap). Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Implement Pat's 27 Oct rulings 2 and 3 (BOARD, PAT DESIGN RULINGS):
- Challenge `lung_solo` par: 110 s when the run takes the dismantle route, 300 s for reconnect, selected from the route the mission actually took. Keep existing hull/tools par requirements.
- Records keep the best time per route plus an overall challenge completion record; a fast dismantle never erases the reconnect achievement. Simple presentation in the existing challenges screen.
Use docs/design/CHALLENGE_PARS_PROPOSAL.md on integration for context.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-challenge-route-pars

## Files you may edit
campaign/challenges/*, presentation/frontend/challenges_frontend.gd and challenge_session.gd, the challenge records save validator, shared append-only files.

## Files you must not touch
Protected mechanics; other CLAIMED handoffs' files.

## Checks
Import, core, and one records round trip + corrupt reject if the saved records shape changes. Ranks local 395-399, CI 495-499.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

## Claude claim (27 Oct)
Claude builds this in parallel with Codex on branch `claude/c8-challenge-pars` (worktree Siren-s-Song-claude-*). Codex: skip it; Claude owns its listed files until DONE.

Verified closeout: PR158 merged as 0f4d2a9b. Head23279a85 passed guidance and game-smoke run40609262069. Separate route bests and approved110/300-second pars delivered. Boundary script failed on native Windows: missing Linux fcntl; tooling repair is required, not a gameplay failure.
