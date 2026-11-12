# Repository map

Current status and next work: [STATUS](STATUS.md). Rules: [AGENTS](../AGENTS.md) and [USER_DIRECTIVES](USER_DIRECTIVES.md). This map says where things live and what each branch is for.

## Where things live

| Path or ref | Responsibility |
|---|---|
| `game/` | Godot project: shipped assets, simulation, campaign, presentation, persistence, audio and tests |
| `game/tests/suites.txt` | The single registry of test suites, with local and CI order |
| `scripts/toolchain/`, `.github/workflows/` | Pinned tools, focused checks, CI and development signing |
| `scripts/toolchain/win/` | Native Windows counterparts of the toolchain scripts |
| `scripts/critic/` | Blind critic play kit |
| `scripts/repo/` | Repository tools: branch ledger, branch archive plan, documentation link check, run-state helpers |
| `docs/CURRENT_GAME_SPEC.md`, `docs/PHOTO_RECON.md` | Intended behavior; camera implementation, evidence and gaps |
| `docs/STATUS.md` | The one live status file |
| `docs/USER_DIRECTIVES.md` | Pat's rulings, verbatim and dated |
| `docs/guides/` | How to add an operation, a region, a Siren role and a fitting |
| `design/`, `references/`, `reference/` | Ratified design, visual selections and provenance, the original prototype (immutable) |
| `_scrap-YYYYMMDD/` | Retired files, each with a row in that folder's `SCRAP_MANIFEST.md`. Nothing is deleted. |
| `.fable/` | Charter, state, survey, plan and reports of the chartered overhaul run |
| `archive/*` branches | Preserved criticism, evidence and historical source; not current instructions. The first independent audit and the frozen-source response are on `archive/claude-audit-2026-10-19` under `docs/audit/`. Cold reviews 1 to 5 and the design audits are under `docs/design/` on `codex/handoffs`. |

## Branch roles

`claude/integration` is development integration. `main` is the protected accepted baseline and the only promotion target; Pat authorizes promotion. `gauntlet/production` is a frozen earlier promotion baseline. `codex/handoffs` held the queue, rulings and state until 1 November 2026; its rulings are now in USER_DIRECTIVES and its status in STATUS. Feature branches return to integration through reviewed pull requests. Details: [WORKFLOW](WORKFLOW.md).

## Branch inventory

`python scripts/repo/branch_ledger.py` lists every remote branch with its last commit, author, ahead and behind counts and a class (SHARED, ACTIVE, MERGED, UNMERGED-STALE, UNMERGED-UNIQUE). The ledger generated on 2026-11-11 is `.fable/BRANCH_LEDGER.md` (374 branches). An earlier snapshot of 22 October 2026 (165 branches) is preserved at [branches-2026-10-22.tsv](https://github.com/pemunson90-cmd/Siren-s-Song/blob/archive/docs-pre-sweep-20261027/docs/repository/branches-2026-10-22.tsv).

An ancestor relationship proves that commits are reachable, not that every historical behavior is still enabled. A branch that is not an ancestor can hold rebased equivalents, outdated experiments or unique evidence; it is not automatically unfinished work. No branch has been deleted, renamed or force-reset. Branches are archived by tag only when Pat approves (`scripts/repo/archive_branches.py`).

## Reference package

Raw non-runtime concept images, the source ZIP and the review PDF are preserved at `archive/reference-package-20261022` (snapshot of 7089470) with original paths and hashes. The active tree keeps the source Markdown, the selection ledger, archive links and `MANIFEST.json`; shipped Godot assets stay in `game/`. See the [visual package](../references/package/START_HERE.md).
