# Handoff 023: ARCH2, split main.gd and give HUD/ocean view one contract

Status: CLAIMED
Claimed at: 2026-10-24 00:08:00 UTC
Claimed by: codex
Finished at:

Precondition: handoffs 019 and 016 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Read docs/design/ARCH_AUDIT_1.md steps 5 and 6 on branch codex/handoffs. Step 5: extract main.gd into presentation/flow/campaign_flow.gd, photo_review.gd and ui_metrics.gd with no behavior change. Step 6: give the existing *_view.gd files one shared three-function contract and have mission_hud.gd and ocean_view.gd loop over them instead of naming each feature, one feature per PR. Prove each PR behavior-preserving (identical core check counts plus the named UI suites). Each as its own small PR. Write the final conventions into docs/CONVENTIONS.md if 019 did not.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-arch2-*

## Files you must not touch
Rules and numbers (move verbatim), story text.

## What done looks like
main.gd and the two draw files shrink with identical behavior; CI green on each PR.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion

### Canonical current local recovery refs, 24 October 2026 Eastern

Codex owns023, CLAIMED and partial. This supersedes all older stop/progress notes.
Pat explicitly resumed local work. Published integration is97e48d33cb47375f9fb5bc90ad44f0cb5b941622:
Windows PR99 merged24 October12:42 AM Eastern after exact1606418 guidance and
game-smoke SUCCESS, run40061261634, independent review and fresh base/head/
mergeability verification. Normal non-force push ran required hooks; fetched
parents/tree match and GitHub confirms closed/merged true. PR96/98 remain merged.
Photo PR100 merged24 October1:20 AM Eastern at97e48d3 after exactc6440ab
guidance/game-smoke SUCCESS, run40063076798, exact predecessor review and
fresh livefab2617/head/mergeability checks. Required hooks ran; fetched parents/
tree match and GitHub confirms actual closed/merged true. Metrics101 is next.

All later final candidates are pushed and independently APPROVED at the exact
head/planned base below. Complete game trees match their native-tested original
preparations. All reported native imports, core818/runtime665 and affected UI/
density suites pass with zero failures and clean logs; no full local matrix.
The earlier Recipient/Recovery interface issues were fixed before preparation
publication and all affected checks rerun. Hosted results must be read live.

Recovery branch claude/lane-arch2-merge-sequence at8c13f5be841ab71ad41b5a4dd1ea3c030b370e8c
contains the prepared ordinary merge commits. It is NOT published integration.
This lets each immutable PR head contain its exact predecessor while checks run
concurrently. No further integration publication until own exact-head guidance
and game-smoke are SUCCESS, attributable independent approval exists, fresh live
tip EQUALS the named predecessor, PR is mergeable, and merge parents/tree match
the approved head. Publish in the listed order using a normal push through active
hooks/protections. Stop on rejection or unexpected tip advance; never force or
bypass. After each push verify remote parents/tree and actual PR merged state.
Root owns all merge mutations; designated reviewer /root/review_photo is read-only.

| Work | Branch | Pushed head | Planned predecessor | Merge commit | State |
|---|---|---|---|---|---|
| [PR99](https://github.com/pemunson90-cmd/Siren-s-Song/pull/99) | claude/windows-hook-compat | 1606418c0e8aa2a8b08246845716882565167ebe | ca2bda005c2f12b87294511e4c02c3accb58dec3 | fab2617575d5156d74b87aede4aa9ba21367504b | MERGED, exact checks/review passed |
| [PR100](https://github.com/pemunson90-cmd/Siren-s-Song/pull/100) | claude/lane-arch2-photo-review | c6440abc8a192d950155ef36ddcc162b63354cbe | fab2617575d5156d74b87aede4aa9ba21367504b | 97e48d33cb47375f9fb5bc90ad44f0cb5b941622 | MERGED, exact checks/review passed, run40063076798 |
| [PR101](https://github.com/pemunson90-cmd/Siren-s-Song/pull/101) | claude/lane-arch2-ui-metrics | aafa21e97a1057a2dd375d45017d545ebae14796 | 97e48d33cb47375f9fb5bc90ad44f0cb5b941622 | 4eb6d91ad3f52612002d41161280f032e1247bde | Exact planned-base APPROVE; own hosted gates pending |
| [PR102](https://github.com/pemunson90-cmd/Siren-s-Song/pull/102) | claude/lane-arch2-wake-view | 0f2b3882b1edbe4dee0c3448a6babbaeb63b283a | 4eb6d91ad3f52612002d41161280f032e1247bde | 286ee11cf78dad368ade5126fc8d3a55f7991bb0 | Exact planned-base APPROVE; own hosted gates pending |
| [PR104](https://github.com/pemunson90-cmd/Siren-s-Song/pull/104) | claude/lane-arch2-rendezvous-view | 99a1df8ca05a202f556f5504108767f624fa6a6c | 286ee11cf78dad368ade5126fc8d3a55f7991bb0 | 79fffb8a5711b9a050076768bcd6e9901f489768 | Exact planned-base APPROVE; own hosted gates pending |
| [PR108](https://github.com/pemunson90-cmd/Siren-s-Song/pull/108) | claude/lane-arch2-shelf-view | e69609debcde96edfaa193ae895aafdaf94ffc96 | 79fffb8a5711b9a050076768bcd6e9901f489768 | da4ce0e554260681748189ede5b5a7c2f6897fb7 | Exact planned-base APPROVE; own hosted gates pending |
| [PR109](https://github.com/pemunson90-cmd/Siren-s-Song/pull/109) | claude/lane-arch2-warning-chain-view | c8ccf309263ff01127533ce1df9b9a533eaa4d9c | da4ce0e554260681748189ede5b5a7c2f6897fb7 | 2f5babef84e5d2ed4e0443acd2f4e3dcb9853c44 | Exact planned-base APPROVE; own hosted gates pending |
| [PR110](https://github.com/pemunson90-cmd/Siren-s-Song/pull/110) | claude/lane-arch2-delivery-view | a41f16f1dade17540a262e02c7b0445b6bc5994e | 2f5babef84e5d2ed4e0443acd2f4e3dcb9853c44 | e93422d50d66e9b16a5f439e10677aa48a67bad3 | Exact planned-base APPROVE; own hosted gates pending |
| [PR111](https://github.com/pemunson90-cmd/Siren-s-Song/pull/111) | claude/lane-arch2-recipient-view | 667ec8235f009b41f105bf6ced7801bcb0321642 | e93422d50d66e9b16a5f439e10677aa48a67bad3 | 0694fc39eab56f81d16beafd74a86ec2f97983fa | Exact planned-base APPROVE; own hosted gates pending |
| [PR113](https://github.com/pemunson90-cmd/Siren-s-Song/pull/113) | claude/lane-arch2-concealed-view | 158c1fcdc985327e18baefb16f7084bdc697301f | 0694fc39eab56f81d16beafd74a86ec2f97983fa | fd7be71d030be2ff1bf3724fe068bdc8f13519e2 | Exact planned-base APPROVE; own hosted gates pending |
| [PR115](https://github.com/pemunson90-cmd/Siren-s-Song/pull/115) | claude/lane-arch2-witness-view | 331f061c781c03ee60608c7bd37c73afbd051215 | fd7be71d030be2ff1bf3724fe068bdc8f13519e2 | 2bba0bd801dd6879089611c6a050c6cb82dc27e7 | Exact planned-base APPROVE; own hosted gates pending |
| [PR117](https://github.com/pemunson90-cmd/Siren-s-Song/pull/117) | claude/lane-arch2-courier-view | ca133c52dd14fb83bf8d6965df7d9407a69c9ef3 | 2bba0bd801dd6879089611c6a050c6cb82dc27e7 | 73c50e73313dfc056333af1a6360f475fc9e0fff | Exact planned-base APPROVE; own hosted gates pending |
| [PR118](https://github.com/pemunson90-cmd/Siren-s-Song/pull/118) | claude/lane-arch2-expedition-view | afb9485c98d82125d1b413cc4e0a84e7823377e2 | 73c50e73313dfc056333af1a6360f475fc9e0fff | f03d9eb411d9579472514be3bfa71ffb43d39639 | Exact planned-base APPROVE; own hosted gates pending |
| [PR119](https://github.com/pemunson90-cmd/Siren-s-Song/pull/119) | claude/lane-arch2-recovery-view | 8ea8180f21d5b337677ce55ac5d2f0e2ada51dba | f03d9eb411d9579472514be3bfa71ffb43d39639 | a6e342caca41a7fe6702fbac4678e3b4d8ff9177 | Exact planned-base APPROVE; own hosted gates pending |
| [PR120](https://github.com/pemunson90-cmd/Siren-s-Song/pull/120) | claude/lane-arch2-industrial-view | 96f15a59e60d0988ffd55140a337d2face4bcbe0 | a6e342caca41a7fe6702fbac4678e3b4d8ff9177 | 8c13f5be841ab71ad41b5a4dd1ea3c030b370e8c | Exact planned-base APPROVE; own hosted gates pending |

This finishes source preparation of the existing mission feature-view seams,
not publication or023 completion. Host composition, setup/input/picking and
framework terrain/course primitives are intentional scope exclusions, reviewed
and documented in CONVENTIONS. No025 claim until every023 step lands. Only then
update023 and BOARD together in one done023 commit. Claude: please do not duplicate
this active claim; coordinate unrelated integration updates with this sequence.

### Current local Windows resume, 23 October 2026 Eastern

Pat explicitly resumed this existing claim and the later eligible numeric queue.
Prior cloud stop notes below remain historical. PR96/98 are already merged;
fetched integration30f555a260d4edf5f0300935e7381475ba620fcc. Do not repeat them.

Photo step: [PR100](https://github.com/pemunson90-cmd/Siren-s-Song/pull/100),
branch claude/lane-arch2-photo-review, last pushed
57b6ce627c60a9d0c3ce98f7cd213c1c0de4d3fe. Preserved52ba7d5 source reconciled
with actual integration and current local resume notes. Native Windows Godot
4.6.3 import clean; core818/runtime665/dispatch13/recap8/captureUI9/cold-reviewUI218
all zero failures and clean exits. Independent reviewer /root/review_photo
confirmed all nine bodies/signatures, host callbacks and deferred layout;
requested historical-doc clarification was fixed. Exact final-head review and
hosted guidance/game-smoke remain required. No full local scenario list or phone
acceptance. Generated UID/import changes are not committed; personal saves use
isolated APPDATA/LOCALAPPDATA.

Separate user-authorized unblock: [PR99](https://github.com/pemunson90-cmd/Siren-s-Song/pull/99),
branch claude/windows-hook-compat, last pushed
fcefbe2b3d38a56220d2300c51c3bd4bc4b77762. Linux-only fcntl blocked the required
hooks. Added native Windows locking/timeout cleanup and quoted installer Python;
22 real-Git regression tests and10 guidance tests pass. Independent source PASS,
prior timeout P2 reproduced/fixed; reviewed hooks installed and exercised during
commits/pushes. No bypass. Hosted exact-head guidance green/game-smoke running.
Initial push privacy rejection fixed using the existing GitHub no-reply address.

Metrics preparation: [draft PR101](https://github.com/pemunson90-cmd/Siren-s-Song/pull/101),
claude/lane-arch2-ui-metrics last pushed041902edca946e6fd3093ed9dfbe3d1af4376d96,
based on photo57b6ce6. Four synchronous helpers move behind original forwarders;
main864 to817, exact body/full-main restoration proof, import clean and preliminary
independent source PASS. Core/affected tests running. Node-owned awaits remain in
Main. Keep draft until99/100 land and fresh integration/review/own checks pass.

023 stays CLAIMED and partial. Merge reviewed green PRs with current integration
contained, then continue ui_metrics and one presentation feature per PR. Only
after every023 step lands mark DONE with BOARD in the same done023 commit.

Later local preparation checkpoint: metrics PR101 last pushed
983f057da75c60240a9e3634dffcfed2aeb16693, independent exact prepared-head APPROVE,
import/core818/runtime665/dispatch13/recap8/metrics77/planner38/density883/menu7/
scroll15 all zero failures, clean exits/logs, exact source/body restoration.
First display-contract feature is claude/lane-arch2-wake-view last pushed
5935f1cfd496a2adb9a499e57e62862c7f7b1742, based on metrics983f057. Wake uses
ordered HUD/WORLD registration at exactly its original refresh/draw positions.
Preliminary independent source PASS; import/Wake31/touchUI37/density883/menu7/
scroll15 pass. Core/runtime still running, no PR/final gate yet. These remain
preparations until parent PRs land and each own current-head/base gate passes.

### Latest local recovery checkpoint

Latest local recovery checkpoint, 23 October 2026 Eastern:
- Integration advanced docs-only through Claude PR103 to
  f43a67255a75942f301403e96059238aec1b877b. PR99 reconciled/pushed
  29c405cb5efab9590394adc2049c9925813ec7c8, exact independent source APPROVE,
  native import/core818/0 clean. Its earlier hosted fcef head is superseded;
  require fresh exact29c405c checks. No merge has been performed by this session.
- Photo PR100 remains57b6ce6; reconcile after99, preserve latest Claude RESUME
  and current prepared work. Metrics PR101 prepared983f057 remains approved/tested.
- Wake draftPR102 last pushed d229936afd36bb445496387473cee4cea8e7f323,
  exact prepared source/docs APPROVE; import/core818/runtime665/Wake31/UI37/
  density883/menu7/scroll15 all0 and clean. Parent/final gates pending.
- Rendezvous draftPR104 last pushed15057f3f527d6643321749bb0ec6ac1b9d078cfb,
  exact prepared source/docs APPROVE; import/core818/runtime665/transport61/UI57/
  density883/menu7/scroll15 all0 and clean. Parent/final gates pending.
- Shelf is being prepared on claude/lane-arch2-shelf-view from15057f3; import and
  preliminary source review pass, tests running. Separate ordered ground adapter
  preserves the original ground/world layers. Not yet pushed or given a PR.

### Earlier cloud progress
Claimed after021/PR95 merged b03dd691a4775bbc07abfa1e87f4938ead653342 and DONE021 plus BOARD published b169abc. Preconditions016 and019 are DONE. Read ARCH_AUDIT_1 steps5/6, current standing rules and PLAN_SNAPSHOT. Next branch claude/lane-arch2-campaign-flow from freshly fetched integration, establish named check baselines, then mechanical extraction with one main file per PR and one presentation feature per later PR. No code pushed yet; record branch and last pushed SHA after first coherent WIP. Preserve all rules, numbers, text, saves and original forwarded entry points.

First coherent step: [PR96](https://github.com/pemunson90-cmd/Siren-s-Song/pull/96), branch claude/lane-arch2-campaign-flow last pushed3afb12f966efc2646c9b148ddf7de5aafe68c5c5, tree8e1270dfb99c2d6861f4d506e81bdba95171bdaf, contains actual integrationb03dd69. Nineteen campaign/menu functions move to flow/campaign_flow.gd with original main signatures/one-line forwarders retained, main1106->950. Every moved body plus complete main restoration verified mechanically, numbers/text/callbacks/deferred ordering unchanged. Baseline/after core818/runtime665(includes campaign_ui_scenarios)/dispatch13/archive8/Canvas route-map70 all0 and clean, identical core outcome lines. Extra early-reward Canvas40 and FIX2 menu24 all0. No test edits, new save fields, rules or Simulation changes. Initial import name collision/host qualification corrected before publication; current import clean. Independent exact-head review requested from /root/review_integration, PR draft, own CI pending. Handoff remains CLAIMED through all separate ARCH2 PRs. While PR96 runs, prepare photo_review on its own branch based on published3afb12f; before its PR/merge reconcile actual integration and run its own exact-head CI.

Pat stop order23Oct2026 Eastern (24OctUTC): finish PR96 only, save remaining steps, refresh stale documentation and prepare Windows desktop handover for Pat/future Codex/Claude Code, then STOP. Do not start metrics, feature-contract implementation or025 in this cloud session. PR96 exact3afb12f independently APPROVED by /root/review_integration with no findings, full original-main reconstruction and personal Canvas reward40/0, verdict relayed in PR body; ready. Exact CI40043994511 guidance success/game-smoke running.

Preserved second-step preparation: branch claude/lane-arch2-photo-review last pushed52ba7d502b3e449180a4883eb570a2c80a9b94f5, tree002047d39ee8eb8212683d2eb9fbd7f8a95914f9, parent3afb12f. Nine photo/archive functions, main950->864, original main entry points retained. Mechanical body/full-main restoration proof accounts for host qualification and one explicit String annotation preserving original inference. Clean import2, core818/runtime665/dispatch13/recap8/captureUI9/archive-parent2/Canvas cold-review218 all0; exact core outcome lines match. No test edits or save/rule/story changes. No PR yet and not merged; future desktop continuation must first reconcile actual integration, update prepared RESUME, obtain independent review and own exact-head hosted checks. Metrics and the feature registry have NOT been implemented.

Documentation handover is being prepared separately on claude/desktop-handoff-20261023 based on published3afb12f, to return as a docs-only PR after PR96 lands. This preserves PR96's tested head. All code is pushed; local raw logs/parity proofs/screenshots/pressure evidence require a separate transfer, not just Git clone. Final exact refs and next desktop commands will be recorded before stopping.023 stays CLAIMED, partially complete; do not falsely mark DONE or take025.

Windows handover WIP published1122ca4f41befa751e2676e08be0fa86b00ed0eb on claude/desktop-handoff-20261023, only26 Markdown files over reviewed3afb12f, independent documentation review requested. New docs/DESKTOP_HANDOFF.md has separate notes for Pat/future Codex/Claude Code, WSL2/Linux-x86_64 setup, exact saved refs, claim/remaining steps, test limits, saves/signing and archive retrieval. Corrected old auto-continuation/no-APK exceptions, stale camera/campaign/role facts, outdated PR/lane states and unsafe environment startup commands. Guidance/relative links/diff checks pass. No implementation after Pat stop choice. Will update pending PR96 facts from live merge, open docs-only PR, obtain own exact-head checks/review and finish the handover, then STOP.

Portable cloud evidence is published on archive/cloud-desktop-20261023 at5407a241c9993b2c2e03fdfd83d03e334bc23368. ZIP551 files/2648261bytes, SHA256de357d0afa4431c4ef16efe066688c9d6019476a8962aec356de0bb72fc7604e. Manifest and per-file integrity verified;11 local recovery refs bundled and git-bundle verified. Selected screenshots/logs/pressure/parity evidence recover through Git; personal saves, credentials, caches and APKs excluded. Read its README for retrieval. Current96 exact40043994511 guidance success, import/core stage passed, navigation/touch stage running.

Documentation review checkpoint: latest pushed docs head2cbd1f2de90158ce91899968859c9c5339f6cf65 on claude/desktop-handoff-20261023. Independent reviewer approved preparation1122ca4 with two minor wording findings; both are fixed in2cbd1f2. Final diff is25 Markdown files over3afb12f, with game/toolchain/workflows byte-identical. The dated signing provenance is preserved unchanged; current no-APK policy is canonical in USER_DIRECTIVES/environment/desktop notes. Reviewer independently verified published ZIP size/hash, all551 payload hashes/lengths and11 recovery refs. Relative54 links/guidance/short pointers/no-added-em-dash/prior-directives-suffix checks pass. Current integration stillb03dd69; PR96 game-smoke remains running on approved3afb. No further implementation. After green96 and actual merge, correct final status/merge refs in the two handover documents, get final exact-head/base docs review and own docs PR checks, publish, checkpoint023/BOARD and STOP.

## Final cloud checkpoint, 23 October 2026 Eastern

This final checkpoint supersedes the in-flight statuses above. Cloud work is STOPPED at Pat's requested boundary, not because of usage exhaustion and not because the project or023 is complete. Status remains CLAIMED and partial; Finished at stays empty. No025 was claimed and no metrics/shared feature contract was implemented.

PR96 merged at dcf81b542bc5a4d27774deb271c9c98a0235e8e7 after exact head3afb12f966efc2646c9b148ddf7de5aafe68c5c5 passed guidance and game-smoke40043994511 and attributable independent approval from /root/review_integration. Fetched whole-tree equality and both expected merge parents verified. Its campaign-flow step is finished; do not repeat it.

[PR98 Windows handover](https://github.com/pemunson90-cmd/Siren-s-Song/pull/98) merged at30f555a260d4edf5f0300935e7381475ba620fcc. Final branch claude/desktop-handoff-20261023 last pushed632f59215cd32c248fc6a88b5edc37414ceb859f, treee090bba487060dabdb775f3aace4ecfc09288775, based on actual integrationdcf81b5. Exact hosted run40047638546 passed guidance/game-smoke (docs-only classification, no Godot run). Independent reviewer /root/review_integration APPROVED that exact head/base with no remaining findings, relayed in the PR body. Twenty-five Markdown files refreshed,54 relative links checked,10 guidance regression tests passed; game/toolchain/workflows unchanged. Final fetched integration tree equals the reviewed head, with expected parentsdcf81b5 and632f592. Complete-boundary structural guidance passed. New living guidance is adopted; its explicit stop overrides automatic continuation. Physical Windows/phone operation and enjoyment remain unverified.

Claude's separate [PR97 PC notes](https://github.com/pemunson90-cmd/Siren-s-Song/pull/97), head2f154f2facd34e7105c71b403dc8d32427a94208, is incorporated with original ancestry and unique future-local notes preserved, while its old PR96-in-flight snapshot is corrected. GitHub now reports97 merged. No separate old RESUME should be merged over current guidance.

Published recovery refs, last pushed:
- claude/lane-arch2-campaign-flow:3afb12f966efc2646c9b148ddf7de5aafe68c5c5, merged96.
- claude/lane-arch2-photo-review:52ba7d502b3e449180a4883eb570a2c80a9b94f5, preserved preparation only, no PR/final independent review/own hosted gate. Its stale prepared RESUME must be reconciled before a future PR.
- claude/desktop-handoff-20261023:632f59215cd32c248fc6a88b5edc37414ceb859f, merged98.
- archive/cloud-desktop-20261023:5407a241c9993b2c2e03fdfd83d03e334bc23368, independently verified551-file evidence ZIP and11 recovery refs. ZIP2648261bytes, SHA256de357d0afa4431c4ef16efe066688c9d6019476a8962aec356de0bb72fc7604e. It is a dated historical snapshot, not a live CI-status report.
- Current integration:30f555a260d4edf5f0300935e7381475ba620fcc.

Desktop orientation, only when Pat asks: `git fetch origin claude/integration codex/handoffs`, then read docs/USER_DIRECTIVES.md, docs/RESUME.md and docs/DESKTOP_HANDOFF.md from origin/claude/integration, plus this Completion and BOARD from origin/codex/handoffs; check live PRs/refs. Inspect the existing Windows setup without overwriting it. WSL2 Ubuntu x86_64 runs the current Linux automation; native Windows Godot is optional for desktop play. The handover has separate notes for Pat, future Codex and Claude Code, including archive retrieval, prerequisites, saves/signing and unavailable cloud-tool fallbacks. Do not assume cloud absolute paths, credentials, agents or check-ins carry over.

After Pat explicitly resumes implementation, continue the existing photo branch, reconcile newest integration/current guidance, obtain its own independent review and exact-head CI before merge, then metrics and shared presentation contract one feature per PR. Only after full023 DONE continue the eligible numeric queue. Preserve all branches and personal saves/signing; no APKs or promotion to main/production. This checkpoint and BOARD are the last authorized cloud edits.
