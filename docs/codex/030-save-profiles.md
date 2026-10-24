# Handoff 030: SAVE1, profiles, copy/clear and export/import (self-contained)

Status: CLAIMED
Claimed at: 2026-10-24 15:11:57 UTC (11:11 AM Eastern)
Claimed by: codex
Finished at:

Precondition: handoff 017 DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub runs it. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, INPUT PRIORITY: Android touch-first, 48 dp, Android Back as Escape, keyboard fallback only). Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP to your lane branch at least every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
The spec says independent profiles, copy/clear and export/import become a milestone when progression breadth warrants; 30 operations plus challenges now do. Build a self-contained profile module (game/src/persistence/profiles/): up to three named profiles each with its own campaign save, backup and challenge archive; a profile picker on the title screen; COPY and CLEAR with a confirm and an undo window; EXPORT to a single validated file and IMPORT with full validation and a clear error (never overwrite an existing profile without confirm). Touch-first (48 dp targets, Android Back closes dialogs), and Android file access through the existing platform seam if one exists, otherwise export to the app's user directory and show the path. Migration: the current single save becomes profile 1 byte for byte; challenge archives follow their profile. One narrow seam into save_store.gd and the front end; optional validated fields; old saves load.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-save-profiles

## Files you must not touch
Save field meanings for existing features, game rules, story.

## What done looks like
A fixture with two profiles proves isolation (byte-identical campaign save after actions in the other profile), export then import round-trips, corrupt import is rejected cleanly, real-touch test at both Fold7 shapes.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
Codex claims030 at 11:11 AM Eastern, before implementation. Precondition017DONE.
Actual029merge dfaf5435a75364b82c57f5567fde7eb673e505a8 verified on live refs
and GitHub PR123 merged=true. No duplicate open PR or local/remote feature branch
was found. Branchclaude/lane-save-profiles now checks out that fresh integration
in reused work/landmarks-merge; only generated untracked UID files retained.
Scope is own persistence/profiles module, narrow SaveStore/frontend seams, real
four-file migration/isolation/copy/clear/undo/export/import and actual touch on
both shapes. Existing save meanings, rules, story and other profiles preserved.
No030code yet. Root integrates; one implementation worker and independent reviewer
per stable execution rules. WIP push within30min, import/core and affected suites,
exact-head hosted gates and independent review before delegated merge.
