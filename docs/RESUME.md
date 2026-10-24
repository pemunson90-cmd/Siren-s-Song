# RESUME: operational entry

**Current execution boundary, 24 October 2026 Eastern:** work now runs locally on
Pat's Windows PC. Pat stopped the cloud session on 23 October and said continue on
24 October. The earlier cloud stop is lifted and is history only. Read
[DESKTOP_HANDOFF](DESKTOP_HANDOFF.md) for the move, and the live board on
`codex/handoffs` for claims.

## Live source checkpoint

Development integration is `claude/integration`, tip `30f555a260d4edf5f0300935e7381475ba620fcc`
(merge of PR98). Recent merges, in order: PR95 route map (b03dd69), PR96 campaign
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
| 023 campaign flow, first main extraction | PR96 merged |
| 023 photo review, second main extraction | PR100, from preserved 52ba7d5; hosted checks pending |
| Windows hook repair | PR99, reviewed and installed locally; hosted checks pending |
| 023 metrics | In preparation on `claude/lane-arch2-ui-metrics`; do not duplicate |
| Portable cloud evidence | `archive/cloud-desktop-20261023` at 5407a241, 551 files with manifest and hash |

Every merge needs latest integration, independent review, both hosted checks on
the exact head, and a merge commit. 025 waits until 023 is DONE.

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
yet), the 049 first-Siren cue extension, ending at op 30 details, early-reward
count changes.

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

Finish 023 in order: land PR99 and PR100 on green, then metrics, then the shared
feature contract, one feature per PR. Then 025 and the numeric queue; the board
owns eligibility. Claude reviews Codex PRs independently and keeps about five
hours of eligible OPEN work queued. Cloud connectors and agents do not exist on
the PC; use Git and the GitHub web. Recheck the desktop setup before reinstalling.

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
