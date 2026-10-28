# Handoff084: preserve the full CI gate while running its suite matrix in parallel
Status: DONE
Claimed by: codex-root-parallel
Precondition: real failure observed: PR165 run40647110543 cancelled at90minute job cap, despite no emitted assertion failure. No gameplay source ownership overlap.
Codex may merge: no; root collects current-head checks and integrates.

Split the existing full registered CI suite list into a small number of parallel jobs (prefer4 balanced deterministic partitions), retaining every existing assertion, suite, timeout and rendered execution requirement. Keep a single required game-smoke aggregate check that fails if any partition or core fails; docs-only behavior remains valid. Default local full/focused invocation must remain unchanged. Prove partition union equals the complete registry and intersections are empty; never loosen tests or merely raise timeouts. Avoid multiple full core runs.

Files: .github/workflows/gauntlet-pr-checks.yml, scripts/toolchain/test.sh and existing CI scenario wrapper if required; one narrow assignment-validation check. No gameplay/save/art/source changes.
Branch: claude/lane-ci-shards from current integration.
Minimal validation: shell/Python registry/partition selection checks and the complete hosted gate on current head; do not rerun unrelated local game suites. Preserve existing suites and focused invocations.
No APK, force push, Astra, or production/main changes. Push WIP/open PR; root collects CI, no model polling. Keep closeout short and truthful.

## Lane return — 28 October 2026

[KEEL: verified implementation/check results] WIP [PR172](https://github.com/pemunson90-cmd/Siren-s-Song/pull/172), head `2ee38d8a0d9f3ac83a9957cc55b6b86c95a1f526`, based on fetched integration `4dc4106f`. Four rank-strided runtime jobs cover 74/74/73/73 suites plus one separate core (295 registered total). Full union/counter and uniqueness check passes. Every existing assertion, renderer and per-suite/job timeout remains; default local/full-CI/focused core list selections match the prior wrapper. Core shares its verified editor artifact; opt-in installer `--editor-only` avoids Android template downloads while its default stays intact.

[KEEL: verified checks] Actionlint 1.7.12, Bash syntax, installer embedded Python syntax, guidance detector (10 tests), structural guidance, five rejected invalid shard selections and 29 actual aggregate-shell cases pass. Aggregate requires core/matrix success and all four shard completion outputs, including rejection of missing/cancelled/skipped gameplay results. Docs-only success with skipped runtime is preserved. No unrelated gameplay suites rerun; no gameplay/save/art edits. Installer change is the small extra seam needed to avoid unnecessary template downloads.

[KEEL: pending integration] [Hosted CI40658100764](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/40658100764) is running; no hosted success or merge claimed. Root collects complete guidance/game-smoke on the reconciled current head and merges. Lane implementation returned; no further claim taken. RESUME capability/next-action changes are unnecessary for this CI-only implementation, recorded in PR172.

## Claude root, 28 Oct 05:10 ET
Run 40658100764 failed in game-core before any shard ran: actions/upload-artifact rejects '..' in `${TOOLCHAIN_CACHE}/bin/godot` (TOOLCHAIN_CACHE = workspace/../sirens-song-toolchain). Claude pushed 317e4630 to claude/lane-ci-shards: resolve absolute paths (realpath -s) for upload and download; suites, assertions and cache paths unchanged. PR172 marked ready. Claude collects its hosted checks and merges on green; Codex root need not dispatch a repair.

## Completion (Claude, 2026-10-28 10:19 UTC)
Sharded gate: game-core + four runtime shards + aggregate game-smoke, about 36 minutes instead of the 90-minute single job.
PR172 merged as e52a8d6c on exact head 94835a77; run 40666390209 all seven checks green.
Fix on top of the lane: absolute artifact paths (317e4630); conflict with PR150's 150-minute stopgap resolved keeping shards.
Open PRs whose runs started on the old single job should merge fresh integration and push to rerun on the sharded gate.
