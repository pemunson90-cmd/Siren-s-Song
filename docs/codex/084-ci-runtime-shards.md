# Handoff084: preserve the full CI gate while running its suite matrix in parallel
Status: CLAIMED
Claimed by: codex-root-parallel
Precondition: real failure observed: PR165 run40647110543 cancelled at90minute job cap, despite no emitted assertion failure. No gameplay source ownership overlap.
Codex may merge: no; root collects current-head checks and integrates.

Split the existing full registered CI suite list into a small number of parallel jobs (prefer4 balanced deterministic partitions), retaining every existing assertion, suite, timeout and rendered execution requirement. Keep a single required game-smoke aggregate check that fails if any partition or core fails; docs-only behavior remains valid. Default local full/focused invocation must remain unchanged. Prove partition union equals the complete registry and intersections are empty; never loosen tests or merely raise timeouts. Avoid multiple full core runs.

Files: .github/workflows/gauntlet-pr-checks.yml, scripts/toolchain/test.sh and existing CI scenario wrapper if required; one narrow assignment-validation check. No gameplay/save/art/source changes.
Branch: claude/lane-ci-shards from current integration.
Minimal validation: shell/Python registry/partition selection checks and the complete hosted gate on current head; do not rerun unrelated local game suites. Preserve existing suites and focused invocations.
No APK, force push, Astra, or production/main changes. Push WIP/open PR; root collects CI, no model polling. Keep closeout short and truthful.
