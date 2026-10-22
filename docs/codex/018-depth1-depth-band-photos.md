# Handoff 018: DEPTH1, depth-band photos, findings displays, all-stop

Status: CLAIMED
Claimed at: 2026-10-22 21:10 UTC
Claimed by: claude (builder on branch claude/depth1; Codex skip 018, 020 and 019 wait on it)
Finished at:

Precondition: handoff 017 must be DONE (Priced Shots and the sweeper are in).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally, because CI stops at its first failure. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Every feature is a self-contained module with one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules beyond what these handoffs say Pat approved. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Build the milestone Pat approved. Read docs/design/DESIGN_DEPTH_FINDINGS.md on branch codex/handoffs (the approved design, with the numbers) and docs/design/DESIGN_TRADES_FITTINGS.md (Priced Shots, already built under photo_pricing). Pat's decisions: deep photo oxygen cost 0.075 per second yes; the craft's own shutter noise ring varies by band (shallow louder, deep quieter) yes; Sirens may NOT be studied from a band other than their own; author two patrol loops on ops 1 and 2; the SIREN TELL idea is deferred (do not build); shifts 1 to 4 in section 2 of the design are approved (loop clock, known lane, post return clock, window check).
Three self-contained modules, each with one narrow seam and a data table:
1. photo_depth (game/src/photo_depth/): the band table and can_shoot / mods / noise_scale / deep_cost per the design. Replace the six "middle only" checks with one can_shoot call. Optional validated save field "band" on each shot (default 1). Compose with photo_pricing: its rings and "if heard" estimates must read the band's shutter radius, not hard-coded 520/760.
2. photo_rules (game/src/photo_rules/): loop clock, post return clock, known lane, window check, all display or planning aids from last contact and published cycles, never live tracking; computed when drawn, not saved. Author two patrol loops on ops 1 and 2. Add ONE optional photo subject reachable only from a non-middle band so the pressure sleeve earns its place (core jobs stay finishable with bare Quietus).
3. all_stop (game/src/simulation/all_stop/): Pat approved a true ALL-STOP for Quietus: engines off, coasts to rest, zero throttle noise, at a cost of oxygen and time (choose numbers so it is a real beat, not free; put them in the module table). Own module; touches noise rules, approved. Camera hold and all-stop should compose naturally.
Setting each table to neutral values (all ones, all-stop disabled) must make the game play as today; say how in each module header.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/depth1

## Files you must not touch
Combat, beam, collision, damage, hull rules; Siren sight/lock rules; the sweeper (sweeper_senses.gd); story text.

## What done looks like
Ops 0 and 3 playable in each band with the trades readable on the chart and viewfinder; all tests pass; focused tests beside each module registered in the workflow.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)
