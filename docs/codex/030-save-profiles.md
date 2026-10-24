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

11:36 AM Eastern WIP checkpoint: first source7acdf745 pushed11:26AM, root-only
RESUME2085192 then pushed. Current pushed headfe18abe03e3a73f743ab28d50d3d80563ca3d43b,
base actualdfaf543. No PR or merge yet. Module owns storage/rules/paths/picker/
session/codec/tests and README, narrow SaveStore/frontend seams; no Main edits.
Independent2085192 first pass requested fail-closed recovery handling and strict
package consumption. Both reproduced (storage67/6), then fixed with regressions;
latest pre-final counts storage68/0 and max150%nativeUI140/0. Final target-name
wording/name checks are committed; own exact-head import/core/storage/UI and
Windows cold-review equivalent reruns are ongoing, with re-review offe18abe.
Earlier core833/0 and affected suites passed, but final-head proof is pending.
Actual GPU captures cover picker, confirmation and recovery error on both420dpi
shapes at150%text. Root inspected picker/confirmation readability, no phone claim.
One initial unisolated check-only setup crashed before script loading; transcript
retained, no game/save tests ran or existing saves modified. Actual save tests
use isolated appdata; source-known fixtures and cold-process proof stay qualified.

11:52 AM Eastern, final candidate ready: PR124
https://github.com/pemunson90-cmd/Siren-s-Song/pull/124
Branchclaude/lane-save-profiles, last pushed9f3a1e41aaea1cc97c1acff26ea8cfee78201dfe,
production frozen2637fe4, rootRESUME2085192 included. Game tree
0a0b63763ab717d9d11196771851b6d49bdf1450. Tracked source clean.

Clean import, core833/0, real storage68/0 plus actual cold child3/0, native GPU
150%UI168/0 across both420dpi shapes. Affected suites10/45/178/86/12/4/9/63 all0.
Root and independent reviewer read all raw final suite logs/error scans and
verified all6capture hashes. Picker/import-confirm/error screens readable;
error state exposes Back only and replacement dialogs name the actual target.
No Main/gameplay/story changes; constructors/validators/custom paths preserved.
Four-file migration/isolation/absence/rollback, confirmation/30second undo,
bounded fully-consumed import codec and pinned/fresh sessions are documented
in own module README. No new campaign saved fields or field meanings.

Relayed /root/review_photo APPROVE exact9f3 againstdfaf543; both recovery/package
P2s resolved, no new findings. Reviewer source/log/hash/pixel review only, ran no
Godot tests or independent process launches. Not formal GitHub approval.
Own exact-head40108698464: guidance120915675760 SUCCESS, game-smoke120915675965
running. Prepared merged131ca0b8b3538af6588f057ee8e7f1ab4f75273 is unpublished,
source-identical; fresh live containment/mergeability and actual merged source
verification still required. Keep CLAIMED until verified publication.

Evidence daa851a2e9612225d3297f18c8538bbbcfe3560b,
evidence/030-windows-20261024/head-9f3a1e4,44files/829124bytes before manifest.
Original Windows env parent2fail remains distinct from unchanged native child
9/0each, with fresh GUID data folders and drag956/336. Hosted Linux parent gate
remains required. Original red67/6 selected tool-output excerpt is preserved with
chunk provenance, not presented as full raw log. Pre-script setup crash and early
parse/UI failures remain qualified. No APK/full local matrix or physical Android
keyboard/filesharing/hand-ergonomics acceptance. Source-known synthetic fixtures.

[Cover picker](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/daa851a2e9612225d3297f18c8538bbbcfe3560b/evidence/030-windows-20261024/head-9f3a1e4/captures/profiles-picker-2520x1080-150.png),
[inner picker](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/daa851a2e9612225d3297f18c8538bbbcfe3560b/evidence/030-windows-20261024/head-9f3a1e4/captures/profiles-picker-2184x1968-150.png).
