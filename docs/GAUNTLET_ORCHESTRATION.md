# Gauntlet boundary refresh

This opt-in helper fetches `origin/gauntlet/production` and reads the **full bytes** of remote `AGENTS.md`, `docs/CONTINUATION.md`, `docs/WORKBENCH.md`, `docs/architecture/GAUNTLET.md`, `docs/CURRENT_GAME_SPEC.md` and `docs/V7_TO_GODOT_PARITY.md` at a task boundary. All six files are required; a missing living spec or parity ledger fails the refresh without emitting a dispatch. It never checks out, merges, resets, stages or changes an active branch. Root is the assigned integration reviewer and installer; no production publication is implied.

Run before task completion/handoff, dispatch, review, merge decision or checkpoint resume:

```sh
python3 scripts/toolchain/gauntlet-boundary.py --boundary complete
python3 scripts/toolchain/gauntlet-boundary.py --boundary review
python3 scripts/toolchain/gauntlet-boundary.py --boundary merge
python3 scripts/toolchain/gauntlet-boundary.py --boundary resume
```

The helper reports the fetched SHA, changed instruction hashes and cached paths on stderr. Full files live under the shared Git common directory at `gauntlet-boundary/policies/<SHA>/`; `gauntlet-boundary/receipt.json` is atomically replaced. `fresh` means fetch/full-file retrieval succeeded, **not that an agent semantically read, reconciled or adopted them**. The orchestrator must open all six cached files, apply current user policy over historical gates, and use that SHA in its next brief. A running model does not automatically reload AGENTS. Before design or gameplay implementation, read both cached living documents alongside source authority even when the active feature branch predates them; historical specifications remain provenance.

On fetch/missing-file/cache failure, exit1 records `stale`, `policy_sha: null`, concrete error and the previous successful receipt. No new dispatch payload is emitted. Protect active work, report the failure and retry the same command at the next boundary; do not attest a successful refresh from the old cache. Git subprocesses default to30s (configurable1–60s); fetch has a shared advisory lock with3s bounded wait (configurable0–10s). A timed-out process group is killed. Independent external Git commands do not honor this helper lock.

## Dispatch preflight

Write the actual tool arguments as JSON, then generate the prefixed payload:

```json
{"target":"/root/existing_worker","message":"Exact owned files, task, evidence and exclusions."}
```

```sh
python3 scripts/toolchain/gauntlet-boundary.py --boundary dispatch --dispatch work/task.json >work/dispatch.json
```

`work/dispatch.json` contains `tool: collaboration.followup_task` and its `arguments`. For a new worker use `task_name` instead of `target`, optionally model/reasoning/fork arguments; default routing is explicit `gpt-6.1-sol`, `fork_turns: none`. The message prefix carries the current policy SHA, leading AGENTS directives plus its exact canonical current-contract section (full AGENTS if that section is absent), all six cached paths, and living-spec/source-authority/model/ownership reminders. The orchestrator must inspect this JSON and invoke the named collaboration tool with those arguments. When the runtime cannot pass a generated string directly between tool namespaces, it may send a pointer to the saved payload in the shared workspace: the worker must read and apply the complete `arguments.message` before executing the task. Both forms use the fetched revision and exact generated brief; neither is an automatic collaboration callback. This script cannot call collaboration tools or automatically choose the next gameplay task.

**Runtime limit:** there is no supported callback for collaboration completion/dispatch, and collaboration cannot be called inside `functions.exec`. Those boundaries require the explicit command above. Git hooks cover only actual Git events, never all orchestration events; do not claim universal enforcement.

## Reviewed, explicit hook installation

After root reviews this feature:

```sh
python3 scripts/toolchain/install-gauntlet-hooks.py
```

The installer refuses configured `core.hooksPath` and any unmanaged/symlink target hook before changing anything. It never overwrites those settings/hooks. Managed hooks can be updated idempotently. A hash-versioned helper copy is stored under the Git common directory; each hook invokes that absolute copy, so old feature branches need not contain the new source. The installer prints its path; the same versioned copy can also serve explicit CLI boundaries from such branches. Reinstall explicitly to adopt a reviewed helper version; branch checkout alone does not update installed hook code.

- `post-commit` and `post-checkout` refresh automatically. Failure is visible/recorded but cannot undo the completed commit/checkout; preserve that work and retry.
- `pre-merge-commit` refreshes and blocks merge-commit creation on failure. A Git fast-forward or `--no-verify` can bypass this hook; run the explicit merge boundary before deciding any merge.
- `pre-push` refreshes and blocks on failure. Updates targeting `refs/heads/gauntlet/production` additionally require the freshly fetched origin production SHA to be an ancestor of the **proposed pushed tip**, not merely current HEAD; production deletion is refused. Feature pushes refresh without requiring a rebased feature. This compares the canonical origin production even when pushing another remote; no automatic merge, force or push occurs. Git hooks remain locally bypassable and cannot prevent a remote race after fetch; normal non-forced push still protects that race.

Android validation uses an explicit production milestone: `push` must target `gauntlet/production` **and** change the exact path `.github/native-milestone.txt`. Root alone creates/changes that marker in a separate deliberate batch commit after a coherent reviewed playable milestone or concrete native-specific fix is ready and any current native run has finished. For example, marker text can name the reviewed source SHA and the native validation reason; it is not updated on ordinary source/docs commits. This workflow correction does not create the marker. Feature pushes (even containing the marker) and tag pushes do not build; tags remain optional recovery/source labels. GitHub path filters have documented diff limits/timeouts, so keep production pushes small and inspect the actual event/source. Signing now requires the canonical Git-saved debug key on every ref; cache loss cannot generate a replacement. See [signing provenance](../scripts/toolchain/signing/README.md).

Production-only `workflow_dispatch` remains optional, with this explicit CLI form:

```sh
gh workflow run android-validation.yml --ref gauntlet/production
gh run view RUN_ID --json event,headBranch,headSha,url
```

Manual availability in this repository is **unverified**: default branch `main` lacks this workflow, while workflow `388967601` is registered active. GitHub's [manual-run guide](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow) requires default-branch presence; its [event reference](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_dispatch) also says a previously run workflow can be dispatched by API/CLI against another ref. Registration or parsed YAML alone proves neither actual dispatch nor a build; do not start a probe run. The marker route avoids depending on manual availability without modifying `main`.

Record the intended published production SHA (including the marker commit when used). Identify the actual run and verify event `push` for the marker route or `workflow_dispatch` for manual, branch `gauntlet/production`, and recorded `headSha` (API `head_sha`) equal that exact source before attributing evidence to it. The job guard rejects all feature/tag refs. Do not infer source from a tag or newest run alone, or issue both routes for one batch. This boundary helper never builds/reruns Android or dispatches CI.

Focused check: `python3 scripts/toolchain/test-gauntlet-boundary.py`. Tests use temporary local bare remotes, actual fetch/commit/checkout/push hooks, dirty work, full-byte caches, stale failure/retry, missing documents, dispatch, unmanaged installation refusal and bounded process/lock handling. No project hooks are installed by the tests. RED/GREEN logs remain ignored in the feature worktree's `work/` directory. No gameplay suite or APK is warranted for this opt-in development helper.


## Completion-time governance check and perpetual delegation

At **every worker/task/reviewer completion**, the root orchestrator runs `python3 scripts/toolchain/gauntlet-boundary.py --boundary complete` and reads the fetched current governing files. The completion boundary invokes the read-only `scripts/toolchain/check-gauntlet-guidance.py --ref <fetched-production-sha>` deterministic linter. CI also runs `check-gauntlet-guidance.py --root .` and its regression tests on PRs. A failure is an explicit new repair assignment on an isolated branch, followed by one reviewer/reconciliation; never overwrite another worker's edits or silently relabel historical originals.

**Structural checks do not establish semantic consistency.** Root must additionally review actual changes for contradictions with user decisions, `docs/CURRENT_GAME_SPEC.md`, ratified bible and concept selections, current ownership, CI/review facts and the next player-facing improvement. Root updates short current `CONTINUATION.md` and `WORKBENCH.md` automatically when the state changes; older handoffs remain identifiable historical provenance. If current state cannot be determined reliably, preserve uncertainty and assign a verification task. The user does not maintain routine handoffs.

The orchestrator stays live and delegates fresh useful work after workers release their scope, as long as actual model/platform execution and usage allow. The linter and hooks enforce document preconditions at boundaries; **they cannot generate collaboration calls or continue an expired agent session**. When a true session/usage limit is reached, checkpoint the exact next command, live branch/worker status, accepted source and pending changes, and label PAUSED — RESUME REQUIRED. Only the user can declare the overall Gauntlet finished.

**Promotion policy:** `gauntlet/production` is the current integrated development baseline. Promote coherent reviewed and tested snapshots to protected `main` via PR, applying required guidance and game checks; never push raw worker changes straight to `main`. Configure GitHub rulesets to require the `guidance` check and the applicable gameplay check after those checks first report successfully. See `.github/workflows/gauntlet-pr-checks.yml`.
