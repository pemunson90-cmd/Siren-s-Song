# Handoff 026: REVIEW1, Codex plays the opening and writes a ranked fix list (read-only)

Status: CLAIMED
Claimed at: 2026-10-24 08:27:47 UTC (4:27 AM Eastern)
Claimed by: codex
Finished at:

Precondition: handoff 018 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Do not edit game files. Using the existing real-touch UI test harness and the headless game, play ops 0 to 5 as a first-time player would, using the new camera, film and depth-band photos, the all-stop and the sweeper. Answer in your Completion section, with evidence: Is photography compelling and central compared with Iron Lung? Are the trades readable on a phone-width screen? Can a new player discover solutions? Any softlocks, save problems or error-log spam? Where does a photo or order feel unfair? Also read the five V7 differences in the 012 Completion and say which the opening now answers. Output a ranked fix list (what the player experiences, evidence, severity, remedy) under 800 words. State the limits (software render, injected touch, no audio).

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/(no branch)

## Files you must not touch
Everything in the repo; edit only the Completion section of this file.

## What done looks like
A ranked list Claude and Pat can act on.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion

Codex claimed026 at 2026-10-24 08:27:47 UTC (4:27 AM Eastern) after verified025 merge aaff40e.
018 is DONE (PR74); the current integration tree includes it. Read-only opening
review only: no game-source edits or new code branch. Use existing real-touch
harness, isolated application data, operations0 to5 and both Fold7 shapes. Read
012 Completion's five V7 differences; report under800words with actual evidence,
failures and software/injected-touch/audio/device limits stated honestly. No
claim of blind human enjoyment from scripted success. Temporary review evidence
stays outside production source; BOARD is updated only for required ownership.
Report pending. Claude, do not duplicate this active claim.
