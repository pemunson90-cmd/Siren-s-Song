# Repository map

Live execution/next work: [RESUME](RESUME.md). Rules: AGENTS and USER_DIRECTIVES. This map describes repository roles and the dated branch inventory; it does not duplicate assignments.

## Where things live
| Path/ref | Responsibility |
|---|---|
| `game/` | Godot project, shipped assets, simulation, presentation, persistence and tests |
| `game/tests/suites.txt` | Registered local/CI test inventory and ordering |
| `scripts/toolchain/`, `.github/workflows/` | Pinned tools, focused checks, CI and canonical debug-signing support |
| `docs/CURRENT_GAME_SPEC.md`, `docs/PHOTO_RECON.md` | Intended behavior; camera implementation/evidence/gaps |
| `docs/RESUME.md` | Sole reconciled operational snapshot |
| `codex/handoffs:docs/codex/` | Task protocol, queue and completion; use fetched ref, not a stale copy |
| `design/`, `references/`, `reference/` | Ratified design, selection/provenance locators and original implementation references |
| `archive/*` and checkpoint refs | Preserved criticism, evidence and historical source; not current instructions |

## Branch roles
`claude/integration` is development integration; `gauntlet/production` is frozen promotion baseline; `main` is accepted baseline. Pat authorizes promotion. `codex/handoffs` owns the queue. Feature branches return to integration through reviewed PRs; review the current board before assigning work.

Inventory snapshot:165 remote branches, fetched with full commit ancestry at integration7089470 and queueab293a7. Of these105 tips are ancestors of integration and60 are not. See [all branch names, exact tips and classifications](https://github.com/pemunson90-cmd/Siren-s-Song/blob/archive/docs-pre-sweep-20261027/docs/repository/branches-2026-10-22.tsv). The reference-package archive ref created by this organization pass is additional to that snapshot. No branch was deleted, renamed or force-reset.

| Lifecycle | Snapshot count | Treatment |
|---|---:|---|
| accepted-baseline | 1 | Preserve accepted baseline |
| archive | 21 | Historical evidence/source; preserve |
| development | 1 | Current development source |
| frozen-baseline | 1 | Preserve promotion boundary |
| historical-unmerged | 35 | Preserve unique history; inspect before any retirement |
| merged-retained | 96 | Tip ancestry is integrated; retain historical locator |
| parked | 6 | Preserve for later comparison; no current owner |
| pending-PR | 3 | Reconcile/review open proposal |
| queue | 1 | Task history and future queue |

An ancestor relationship proves commit reachability, not that every historical behavior remains enabled. A non-ancestor tip can contain rebased/squashed equivalents, outdated experiments or unique evidence; it is not automatically unfinished feature work. No historical-unmerged branch is promoted by this inventory. The parked sweeper experiment is reachable historically but remains a different, unratified future direction.

## Current reconciliation and desktop transfer
PR77, PR79 and PR80 are merged; the inventory above remains the dated22Oct snapshot, not a live pending list. Use [RESUME](RESUME.md) and live GitHub refs/checks for published state. [DESKTOP_HANDOFF](DESKTOP_HANDOFF.md) records the Windows transition, preserved preparation and evidence-transfer instructions. The queue remains on codex/handoffs; preserve its partial claim.

## Reference package
Raw non-runtime concept images, source ZIP and review PDF are preserved at `archive/reference-package-20261022` (snapshot of7089470) with original paths and hashes. The active tree keeps source Markdown, the selection ledger, archive links and MANIFEST.json; shipped Godot assets stay in game/. See [visual package](../references/package/START_HERE.md). This changes checkout contents, not historical Git storage; no history rewrite is performed.
