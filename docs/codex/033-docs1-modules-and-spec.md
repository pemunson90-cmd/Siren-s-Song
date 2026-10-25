# Handoff 033: DOCS1, module index with revert notes, and spec refresh

Status: DONE
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at: 2026-10-25 22:23:18 UTC
Claimed by: codex
Finished at: 2026-10-25 23:49:44 UTC

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

### Published candidate,6:46PM Eastern

PR145 https://github.com/pemunson90-cmd/Siren-s-Song/pull/145 on claude/lane-docs1, exacte0c6e8f6e80059e93601e21998d62c85e3a72f70, basebbc1bed0. First WIP pushed6:41:50PM Eastern, within30minutes of claim. MODULES54lines/44groups, CONTINUATION14, WORKBENCH15. Original17516byte RESUME preserved verbatim in docs/RESUME_2026-10-24_HISTORY.md in the same directory so relative links keep their base. Current entry is short/factual; five012 differences reconciled as accepted/open, profiles/finale/photo-route capabilities corrected,048/050 explicitly unbuilt, sight-only approval recorded with hearing/speed/lock unchanged.

Root and independent nonauthor /root/save043_architect each actually ran Windows import/core836/0 and guidancechecker/10regressiontests. Independent PASS6404465570 on exacte0, source-backed semantic checks of62source refs,78registered test refs and28local links all pass. Root read actual reviewer stdout/stderr/results. Eight changed GDScript files have identical executable lines; only stale header comments changed. Shared lock/audio helpers, optional validators, profile four-file contract and SAVE2 pinned sidecars/recovery are explicitly retained. Source/UID/import churn not staged.

Extra cleanup beyond the original named docs follows Pat25October explicit stale-doc instruction and the plainly wrong RESUME source-document boundary: AGENTS/USER_DIRECTIVES/SOURCE_AUTHORITY banners, PHOTO_RECON current limits, profiles README and narrow module-header comments. No code behavior/schema/test registration or story changes. No invented flags: older coupled modules are labeled coordinated reverts, not promised one-line opt-outs. Existing diagnostic default-off flag remains default-off.

Setup limits retained in external033 evidence: the initial small inventory had search misses (not game defects), corrected by root actual-source checks. A Windows default-encoding wording helper failed and was rerun with explicit UTF-8; game import/core separately passed. Legacy AItrace CRLF body bytes are retained, while new comments avoid CR-at-EOL whitespace errors. No gameplay test failure is claimed for those setup corrections.

Current integration is contained; explicit merge already up to date. Hosted40241428577 guidance121313857302 passed, game-smoke121313857512 still running.033 remains CLAIMED pending final hosted gate, evidence publication and verified merge;048 follows.

### DONE,7:49:44PM Eastern,25October2026

PR145 mergede0ee34d356d61c42e9809305647415c103e3cf84 verified remotely and GitHub merged=true. Parentsbbc1bed0+e0c6e8f6 and tested tree952f6f01991773e2f102e76a9c74e10aa020ed28 match; source branch retained. Exacte0c6e8f6 has independent nonauthor PASS6404465570 and both green hosted jobs40241428577. Full hosted278summaries/17633reportedchecks/0failures/0actual script-engine-leak errors. Root and reviewer each ran import/core836/0 plus10guidance regression tests, registry275/0 and documented semantic checks.

Final evidence archive27d20bdc9842837fcfb7f95397840d8420640fbf on archive/codex-033-docs-windows-20261025 contains19member local ZIP23521bytes/SHA2568b87705c91b3e2880a23ac35b8c37b12f8627979e63dab0575ddbeea221539ec, full hosted ZIP2319479bytes/SHA256a8e48f9f61a907758da4d2e8f01a4460f6ff00b5068accff4616b1d0011de299, manifests and merge verification. Raw hosted aggregate19839981bytes/SHA2569dafaa3f8796753964e3aca54d438bf9c25e51cbcfc8f83d34ff0839ed3bcc48. Both earlier partial logs are exact prefixes of the archived final log, verified byte-for-byte. The echoed grep command containing error patterns is explicitly retained/excluded as shell text; no actual errors discarded. Actual committed ZIP blobs/member hashes/CRCs verified.

Reconciled historical cloud/art pauses, stale profile/final-pair/photo-route statements, five012 feel differences, current authorization and safe module reverts. Prior17516byte RESUME is preserved verbatim in a labeled same-directory historical snapshot; original failures/limits/links remain. Header corrections preserve shared helpers/validators, SAVE2 sidecars/recovery and tests. No executable source, schema, rule, test registration, story, artwork, UID/import churn or protected branch change. No extra meaningless RESUME commit to chase the merge SHA; this is the authorized source-document boundary and live board remains claim authority.

Limits: no claim every disable/revert combination was exercised, every historical external artifact revalidated, full campaign/subjective/phone/human acceptance or APK/full local matrix. Older coupled modules honestly require coordinated reverts; no off flag invented. Current supplied scope complete. Pat-reassigned048 HUD is next, followed by sight-only050 with hearing/speed/lock unchanged.
