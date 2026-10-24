# Handoff 030: SAVE1, profiles, copy/clear and export/import (self-contained)

Status: DONE
Claimed at: 2026-10-24 15:11:57 UTC (11:11 AM Eastern)
Claimed by: codex
Finished at: 2026-10-24 16:38:27 UTC (12:38 PM Eastern)

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
Done030. PR124 https://github.com/pemunson90-cmd/Siren-s-Song/pull/124 merged
at12:38PM Eastern,24October2026. Actual merge
d131ca0b8b3538af6588f057ee8e7f1ab4f75273, parentsdfaf543 and9f3a1e4, verified
on live integration and GitHub merged=true. Branchclaude/lane-save-profiles,
last pushed9f3a1e41aaea1cc97c1acff26ea8cfee78201dfe. Published game tree
0a0b63763ab717d9d11196771851b6d49bdf1450. Prepared/source trees were identical;
normal non-force merge-commit push followed fresh containment/mergeability checks.

Own exact-head40108698464 guidance120915675760 and game-smoke120915675965 both
SUCCESS. Relayed independent /root/review_photo APPROVE exact9f3 againstdfaf543,
prior recovery/package findings resolved, no new findings. Reviewer source/docs/
log/hash/pixel review only, no Godot tests or independent process launches; not
formal GitHub approval. Root independently checked final logs and capture hashes.
Public claimbb060b6 preceded code; first WIP7acdf745 at11:26AM within30min.
Root-only RESUME2085192, hardeningfe18abe/2637fe4, final test-only9f3 preserved.

Own profiles module gives three named independent primary/backup/challenge/
challenge-backup slots. Legacy originals migrate byte for byte and remain.
Default Store paths resolve lazily and pin per instance; custom stores and
constructors/validators retain behavior. Retiring a host suspends queued writes
before mutation/selection and rebuilds a fresh session, avoiding stale state.
Staged four-file journal replacement preserves absence and rollback data;
failed recovery/index locks controls and storage mutation until recovery succeeds.
Named copy/clear/import confirmations and30second undo restore name plus bytes.
Export/import uses a bounded checksummed fully-consumed ordinary-Variant package
and existing save validators, shows app user-directory path, and rejects malformed
input before replacing progress. README documents switch and safe revert retaining
all files/current progress. No new campaign fields or existing field meanings.

Clean import; core833/0, storage68/0 including actual separate coldchild3/0,
native GPU150%touchUI168/0 on both420dpi Fold7 shapes. Affected equipment/study/
challenge/FIX2 suites10/45/178/86/12/4/9/63 all0. Worker recorded exit0 for each;
raw error/leak/failure scans clean. Real disk fixtures prove four-file migration,
other-slot byte identity, copy/clear undo, raw export/import roundtrip, malformed
packages, interrupted rollback, cold profile/challenge isolation, fresh hosts,
naming, Back and captured text/control bounds. Six native screenshots show
picker/named import confirmation/recovery error on both shapes at150%text.

Evidence archive daa851a2e9612225d3297f18c8538bbbcfe3560b,
evidence/030-windows-20261024/head-9f3a1e4,44files829124bytes before manifest.
Hashes verified. Both prior P2s reproduced red67/6 and fixed; original selected
tool-output excerpt with chunk e1db03 is preserved, not a full raw-log claim.
Original unchanged Windows cold-review parent fails2/2 on unavailable Linux env;
GUID-isolated unchanged native child branches9/0each, drag956/336, are separate
coverage, never a parent pass. Final hosted Linux parent passed independently.
An accidentally unisolated check-only setup crashed before loading a script;
transcript retained, no game/save test ran or personal save opened/modified.
Early parse/UI failures are qualified in receipt. Actual tests isolated appdata.
No full local scenario matrix, APK, physical Android keyboard/filesharing or
Fold7 hand-ergonomics acceptance claim. Source-known technical fixtures only.

Outside ownership: only narrow SaveStore/frontend seams, central suite wrappers/
registration and root operational RESUME. No Main, gameplay, rules or story edits.
Current031 precondition017DONE; no duplicate branch/open PR was found. Root
claims031 in the same board transaction before implementation. Claude retains
separate039/041 claims, preserved. Next after031 is032(Pat judges) then033.

[Cover picker](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/daa851a2e9612225d3297f18c8538bbbcfe3560b/evidence/030-windows-20261024/head-9f3a1e4/captures/profiles-picker-2520x1080-150.png),
[inner picker](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/daa851a2e9612225d3297f18c8538bbbcfe3560b/evidence/030-windows-20261024/head-9f3a1e4/captures/profiles-picker-2184x1968-150.png).
