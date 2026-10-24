# RESUME: operational entry

**Current execution boundary, 24 October 2026 Eastern:** work now runs locally on
Pat's Windows PC. Pat stopped the cloud session on 23 October and said continue on
24 October. The earlier cloud stop is lifted and is history only. Read
[DESKTOP_HANDOFF](DESKTOP_HANDOFF.md) for the move, and the live board on
`codex/handoffs` for claims.

## Live source checkpoint

Development integration is `claude/integration`, last reconciled baseline `97e48d33cb47375f9fb5bc90ad44f0cb5b941622`.
This ARCH2 candidate includes the Windows hook repair PR99 through a planned
predecessor merge. At preparation, published integration isca2bda0 and99 remains
open. Publish its reviewed, successful exact head first. Live refs and the board
determine published state; preparing a merge commit does not publish it.
Recent documentation/history merges include103/105/106/107/112/114; those design
proposals do not authorize implementation in handoff023.
Earlier baseline was30f555a (merge of PR98). Recent merges, in order: PR95 route map (b03dd69), PR96 campaign
flow (dcf81b5, 23 Oct 8:56 PM Eastern, reviewed head 3afb12f, hosted run
40043994511 green), PR97 Claude's PC handover (632f592) and PR98 the cloud
closeout documentation (30f555a, both merged about 9:01 PM Eastern). Live Git refs
and PRs win over this snapshot. `gauntlet/production` and `main` stay frozen under
Pat's promotion authority. No branches are deleted. All code PRs target integration.

## Current claim and open PRs

Ownership is authoritative on `codex/handoffs` in `docs/codex/BOARD.md` and
`023-arch2-main-and-hud.md`. Handoff 023 stays CLAIMED and partial; do not
re-claim it or mark it DONE after one PR.

| Work | State |
|---|---|
| 023 campaign flow | PR96 merged |
| Windows hooks PR99 | Included prerequisite; publish in order only after its own gates |
| Photo review PR100 | Included prerequisite; publish in order only after its own gates |
| Metrics PR101 | Current candidate, exact-head review and hosted checks pending |
| Feature contract | Separate preparations102/104/108/109/110/111/113/115/117/118/119/120, live refs and board decide published state |
| Portable cloud evidence | archive/cloud-desktop-20261023 at5407a241,551 files with manifest/hash |

Every merge needs latest integration, independent review, both hosted checks on
the exact head, and a merge commit. 025 waits until 023 is DONE.

Local photo verification: clean Windows import; core818/runtime665/campaign
dispatch13/archive recap8/photo captureUI9/cold reviewUI218 all0 on the prepared
source. All nine moved bodies, retained host entry points and callback/deferred
order are independently reviewed. Preserve this evidence separately from each
final exact-head/base review and hosted result. The shared contract preparations
remain drafts until parents land and each own final gate passes.

Native hook verification:22 real-Git boundary tests and10 guidance tests pass.
Hooks use the actual Windows Python executable, exclusive locking and bounded
process cleanup; no hooks are bypassed. Godot checks redirect APPDATA and
LOCALAPPDATA to isolated work folders, preserving personal saves.

## Current ARCH2 candidate

This candidate is metrics PR101, reconciled against planned predecessor merge
97e48d33cb47375f9fb5bc90ad44f0cb5b941622. The predecessor is prepared, not yet published.
Four synchronous helpers move into flow/ui_metrics.gd; Main entry points, state
and Node-owned capture/report awaits stay. Main864 to817. The game tree must
match prepared983f057 exactly, preserving the native import/core818/runtime665/
dispatch13/recap8/metrics77/planner38/density883/menu7/scroll15 zero-failure logs.
Exact final-head/planned-base independent review and both hosted gates remain.
Only publish its ordinary merge when live integration equals that predecessor,
its PR is mergeable, and merge parents/tree equal the approved tested result.
If integration advances unexpectedly, stop this sequence and reconcile again.
Handoff023 remains CLAIMED and partial; no025 claim until all023 steps land.

## Cold review 3 and the new batches

Cold review 3 is done. Report: `docs/design/COLD_REVIEW_3.md` on `codex/handoffs`.
It ran on 30f555a: core 818/0 and 33 targeted suites passed, with no regressions
from FIX2, the first-Siren cue, early reward, photo rows, route map or ARCH2.
Headless, injected touch only; no pixels, sound or phone. Key findings:

- F1: Godot's default quit_on_go_back is still on, so Android Back may close the app.
- F2: op 30 has no finale and no photo wall ending.
- F3: the ending screen goes stale after later ops, and replay means erasing.
- F4: debrief "record" text for ops 15 to 30 just repeats the briefing.

Later findings (long Operations list, menus only at boot, briefing walls) feed the
batches below.

Batch 7 (handoffs 038 to 040): Ops home, consequence lines for ops 15 to 30,
photo row journeys under live Sirens. Batch 8 (041 to 045), AI-DESIGNED and Pat to
adjust: 041 Back fix, 042 finale (provisional), 043 save slots and replay from
fork, 044 menu reach, 045 three early rewards before op 7. 029 now includes the
F7 briefing addendum. Statuses live on the board, all OPEN at this snapshot.

Held for Pat: any change to Siren senses (sight, hearing) or lock timing (Pat: not
yet), ending at op30 details and early-reward count changes. Board049 was
released separately by Pat on24 October; it is outside the current023 claim.

## Completed context

019 ARCH1 is DONE through PR81/83/88/90/91/92.035/FIX2 PR86,024 audio PR87,
036 cue PR93,037 reward PR94,020 M1 photo rows PR85 and021 route map PR95 are
merged and DONE. PR77/79/89 are also integrated; PR80 reconciled handoff pointers.
The board retains the full earlier history and exact completion facts. Do not
restart those claims from an old lane table, source checkpoint or session ledger.

Thirty operation IDs exist. M1 adds fourteen optional subjects and sixteen
returned-film marks; PR95 adds a derived route map. These do not implement027's
final pair/photo-wall or establish full cold campaign/physical-phone acceptance.
Camera capability and limits: [PHOTO_RECON](PHOTO_RECON.md). Intended expansion
remains [CURRENT_GAME_SPEC](CURRENT_GAME_SPEC.md), not a completed feature claim.

## Next steps for the PC sessions

Publish023 prepared heads in their recorded order, one reviewed PR and ordinary
merge commit per step. Each head contains its planned predecessor so exact-head
checks can run concurrently. Publish only after that predecessor is the freshly
fetched live integration tip, own independent approval and both own hosted checks
are successful. Normal hooks and branch protections apply; stop on a rejection
or unexpected integration advance. Verify actual remote parents/tree and PR
merged disposition after each publication. Board owns claims and recovery refs.
Then025 and the eligible numeric queue. Use the current local tool inventory;
do not assume cloud agents or credentials carried over.

## Verification and preservation

Use Godot 4.6.3/GDScript/Compatibility. Windows toolchain: the official Windows
Godot 4.6.3 is at C:\Users\Archi\.cache\sirens-song-toolchain\win (sha512 verified).
install-godot.sh is Linux only; run the Godot console exe directly. Do not commit
.uid or .import churn. Role notes: DESKTOP_HANDOFF and CODEX_ENVIRONMENT.
Import, core and affected suites locally; GitHub owns the full
registered matrix. Core must end CHECKS N FAILURES 0 with positive N; any Godot
script error, resource-in-use line or leak fails. Preserve 48 dp touch and Android
Back=Escape. Never skip, loosen or delete a test for green.

No APKs, phone-test request, frozen-branch promotion or branch deletion. Preserve
combat/beam/collision/damage/hull/Siren sight/hearing without Pat; V7 Sirens have no
sonar. Narrative, endings/characters, new pillars, SIREN TELL and art032 decisions
remain Pat's. Story stays short placeholders; no em dashes. Keep existing saves
and the canonical tracked debug signing identity. Commit/push WIP at least every
30 minutes and record branch plus pushed SHA in the claimed Completion.

Pat chooses playtest timing. Synthetic touch/render and controller outcomes are
technical evidence, distinct from human enjoyment, headphones and physical Fold7
comfort. No cloud credentials, running agents, absolute paths or caches should be
assumed on desktop. The evidence archive excludes personal saves/credentials;
preserve any personal progress separately before discarding cloud storage.

AGENTS owns stable execution rules, USER_DIRECTIVES user decisions, this file the
reconciled snapshot, and the codex/handoffs board claims/completion. CONTINUATION
and WORKBENCH stay short pointers. Dated ledgers/audits/design snapshots remain
historical provenance. Only Pat ends the project; work continues locally.
