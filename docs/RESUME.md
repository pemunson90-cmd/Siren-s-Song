# RESUME: operational entry

**Current execution boundary, 24 October 2026 Eastern:** work now runs locally on
Pat's Windows PC. Pat stopped the cloud session on 23 October and said continue on
24 October. The earlier cloud stop is lifted and is history only. Read
[DESKTOP_HANDOFF](DESKTOP_HANDOFF.md) for the move, and the live board on
`codex/handoffs` for claims.

## Live source checkpoint

Active development integration: `claude/integration`.
Last reconciled source baseline:8c13f5be841ab71ad41b5a4dd1ea3c030b370e8c.
023 is DONE on the authoritative board in2df2e6b after all separate source PRs
and Windows99 passed own exact-head checks/review and actual merge verification.
Main817, HUD575, Ocean685. Do not repeat023 or its earlier preparations.

## Current claim and next work

Codex owns CLAIMED025, postedc0abb9c before implementation. Branch
claude/lane-landmarks starts from8c13f5b; no open duplicate landmark PR or prior
branch was found.020 is DONE atddc3361 and contained. Scope is the already
approved data-only landmark handoff, operations6 to29, existing visual language,
unchanged rules/story/endings and preserved fixtures/pressure. The plan is
[landmarks M3a](superpowers/plans/2026-10-24-landmarks-m3a.md).

Baseline Windows import/core818/0 pass.025 is an active visual prototype, not
complete: authored existing-feature treatments, photo-depth lamps and fresh load
lamps live behind one ground registration. Data468/0 and projection92/0 pass.
The first visual review rejected narrow surface borders as too weak. Localized
compositions are being inspected in native before/after captures; one capture
route lost Quietus and remains preserved. The renderer clipping edge case is repaired. A second review found that clipping
a motif to a thin rock could reveal its unseen back edge. The new thin-rock
regression is red against3c2af95 and green with whole-motif omission; final native
captures and independent acceptance are still required. The external epsilon-bounded pressure baseline is complete; the same
wrapper/comparison, five authored fixtures, final import/core/affected suites,
three accepted captures and exact-head independent review/CI are still required.
Do not merge this WIP or call025 DONE. Plan and recovery refs remain on this branch.
Board and025 Completion own claim/recovery state. Continue026/027/029..033 only
after this claim is complete and preconditions are met.

The native Windows hook fix is installed and merged;22 real-Git boundary and10
guidance tests passed. Use the official Windows Godot4.6.3 console build directly;
install-godot.sh is Linux only. Tests use isolated APPDATA/LOCALAPPDATA. Preserve
personal saves and exclude generated .uid/.import churn. Full local scenario
lists and APKs remain prohibited; GitHub game-smoke is the full gate.

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

Complete the existing025 claim, then eligible026,027,029 to033 in numeric order.
032 remains Pat's art judgment. Do not implement new story, new art direction or
SIREN TELL. Each handoff's exact-head checks, independent review, current-base
containment and merge permission govern publication; preserve frozen refs and
all branches. Claims and done updates live on codex/handoffs. Use actual local
tools; do not assume cloud agents, caches or credentials carried over.

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
