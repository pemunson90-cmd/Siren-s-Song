# Handoff 033: DOCS1, module index with revert notes, and spec refresh

Status: CLAIMED
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at: 2026-10-25 22:23:18 UTC
Claimed by: codex
Finished at:

Precondition: handoff 018 DONE (PR 74 merged).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub runs it. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, INPUT PRIORITY: Android touch-first, 48 dp, Android Back as Escape, keyboard fallback only). Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP to your lane branch at least every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Pat requires everything documentable and revertible. Write docs/MODULES.md (under 120 lines): one entry per self-contained module (photo_pricing, photo_depth, photo_rules, all_stop, sweeper_senses, lock_warning, challenges, onboarding hints, plus any new ones merged since), each with: purpose in one line, folder, seam lines (file and hook names), data table file, save fields, tests, and the exact revert steps. Verify each entry against the code and the module header comment; correct the headers if they disagree. Then refresh docs/CURRENT_GAME_SPEC.md and docs/V7_TO_GODOT_PARITY.md so they describe what is built now (photo pillar, film, depth-band photos, all-stop, V7-senses sweeper, challenge mode, touch-first priority), keeping the file structure and not rewriting history; add the five differences from handoff 012 to the parity ledger as accepted/open items. Keep docs/CONTINUATION.md and docs/WORKBENCH.md under 40 lines each and current. No game code changes.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-docs1

## Files you must not touch
All game source (documentation only, except fixing a stale module header comment).

## What done looks like
MODULES.md complete and verified, spec and parity ledger current, guidance check green.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, branch and last pushed SHA, test results, unverified items, files outside ownership needed, recommended next.)

### Implementation plan,25October2026 Eastern

Basebbc1bed0 after040/PR144; own branchclaude/lane-docs1, worktree033-docs1. Root writes docs; one small read-only worker inventories module headers/actual hooks/flags/save validators/tests. No gameplay/source behavior changes, new infrastructure or tests that mirror prose. Module index stays below120lines, pointers below40lines. Each entry distinguishes an actual disable flag, neutral table settings or a coordinated Git revert when no runtime flag exists; preserve saves and catalog identities. Verify against actual source, not previous claims.

Refresh existing spec/parity structure with built features and five ranked012 differences, clearly separating accepted adaptations, open evaluation and approved-but-unbuilt sight-only Hunt. Preserve earlier evidence and qualifications. Update the plainly wrong RESUME at this authorized source-document boundary; preserve its long dated record in a clearly historical snapshot and make the operational entry short and factual. Pat25October explicitly asked stale-doc cleanup while continuing; label obsolete cloud-stop/art/deferred033 statements historical rather than letting them govern current work. The narrow extra guidance/banner/photo-capability corrections are documentation only and follow that latest cleanup instruction; no ownership or feature is silently marked complete.

Record Pat25October reversible choices and queued048/050 takeovers without opening another implementation claim. Hearing/speed/lock stay unchanged; pending numbers are tunable/off-switchable, no irreversible promotion or story decisions. Run guidance checker/tests, local import/core and only relevant semantic/doc checks, registry before every push, independent exact-head review and both hosted jobs before merge. Full local scenario matrix remains prohibited. Publish coherent WIP/PR within30minutes; evidence stays off integration. At closeout mark033+BOARD in one commit, then claim048.
