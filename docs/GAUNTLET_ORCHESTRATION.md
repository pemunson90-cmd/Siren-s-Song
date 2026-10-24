> **CURRENT USER ORDER:** read docs/USER_DIRECTIVES.md first. Observe Pat's cloud stop and Windows desktop handover in docs/RESUME.md. The approved full-release program remains the standing plan when Pat resumes work. Preserve accepted Pass0/V7 systems. One implementation worker and one independent integration reviewer; human playtesting never gates authorized development.

> Current user contract: AGENTS.md, docs/USER_DIRECTIVES.md and the living release specification govern. The audit archive is historical provenance. Integrate coherent feature batches through PRs with independent review and game-smoke passing. Task completion advances the approved release work; user playtesting never gates development.

# Gauntlet boundary refresh

This opt-in helper fetches `origin/claude/integration` and reads the **full bytes** of remote `AGENTS.md`, `docs/USER_DIRECTIVES.md`, `docs/RESUME.md`, `docs/CONTINUATION.md`, `docs/WORKBENCH.md`, `docs/architecture/GAUNTLET.md`, `docs/CURRENT_GAME_SPEC.md` and `docs/V7_TO_GODOT_PARITY.md` at a task boundary. All eight files are required; missing user directives, living spec or parity ledger fails the refresh without emitting a dispatch. It never checks out, merges, resets, stages or changes an active branch. Root orchestrates the assigned independent integration reviewer. Existing hook installation is explicit; adopting this helper at a safe session boundary does not publish production.

Run before task completion/handoff, dispatch, review, merge decision or checkpoint resume:

```sh
python3 scripts/toolchain/gauntlet-boundary.py --boundary complete
python3 scripts/toolchain/gauntlet-boundary.py --boundary review
python3 scripts/toolchain/gauntlet-boundary.py --boundary merge
python3 scripts/toolchain/gauntlet-boundary.py --boundary resume
```

The helper reports the fetched SHA, changed instruction hashes and cached paths on stderr. Full files live under the shared Git common directory at `gauntlet-boundary/policies/<SHA>/`; `gauntlet-boundary/receipt.json` is atomically replaced. `fresh` means fetch/full-file retrieval succeeded, **not that an agent semantically read, reconciled or adopted them**. Root must open all eight cached files, apply current user policy over historical gates, and use that SHA in its next brief. Workers receive a bounded brief with USER_DIRECTIVES and directly relevant guidance/source; cached paths provide references without requiring a full-governance worker orientation. A running model does not automatically reload AGENTS. Before design or gameplay implementation, read both cached living documents alongside source authority even when the active feature branch predates them; historical specifications remain provenance.

On fetch/missing-file/cache failure, exit1 records `stale`, `policy_sha: null`, concrete error and the previous successful receipt. No new dispatch payload is emitted. Protect active work, report the failure and retry the same command at the next boundary; do not attest a successful refresh from the old cache. Git subprocesses default to30s (configurable1–60s); fetch has a shared advisory lock with3s bounded wait (configurable0–10s). A timed-out process group is killed. Independent external Git commands do not honor this helper lock.

## Dispatch preflight

Write the actual tool arguments as JSON, then generate the prefixed payload:

```json
{"target":"/root/existing_worker","message":"Exact owned files, task, evidence and exclusions."}
```

```sh
python3 scripts/toolchain/gauntlet-boundary.py --boundary dispatch --dispatch work/task.json >work/dispatch.json
```

`work/dispatch.json` contains `tool: collaboration.followup_task` and its `arguments`. For a new worker use `task_name` instead of `target`, optionally model/reasoning/fork arguments; default routing is explicit `gpt-6.1-sol`, `reasoning_effort: medium`, `fork_turns: none`. The message prefix carries the current policy SHA, leading AGENTS directives plus its exact canonical current-contract section (full AGENTS if that section is absent), all eight cached paths, and living-spec/source-authority/model/ownership reminders. The orchestrator must inspect this JSON and invoke the named collaboration tool with those arguments. When the runtime cannot pass a generated string directly between tool namespaces, it may send a pointer to the saved payload in the shared workspace: the worker must read and apply the complete `arguments.message` before executing the task. Both forms use the fetched revision and exact generated brief; neither is an automatic collaboration callback. This script cannot call collaboration tools or automatically choose the next gameplay task.

**Runtime limit:** there is no supported callback for collaboration completion/dispatch, and collaboration cannot be called inside `functions.exec`. Those boundaries require the explicit command above. Git hooks cover only actual Git events, never all orchestration events; do not claim universal enforcement.

## Reviewed, explicit hook installation

After root reviews this feature:

```sh
python3 scripts/toolchain/install-gauntlet-hooks.py
```

The installer refuses configured `core.hooksPath` and any unmanaged/symlink target hook before changing anything. It never overwrites those settings/hooks. Managed hooks can be updated idempotently. A hash-versioned helper copy is stored under the Git common directory; each hook invokes that absolute copy, so old feature branches need not contain the new source. The installer prints its path; the same versioned copy can also serve explicit CLI boundaries from such branches. Reinstall explicitly to adopt a reviewed helper version; branch checkout alone does not update installed hook code.

- `post-commit` and `post-checkout` refresh automatically. Failure is visible/recorded but cannot undo the completed commit/checkout; preserve that work and retry.
- `pre-merge-commit` refreshes and blocks merge-commit creation on failure. A Git fast-forward or `--no-verify` can bypass this hook; run the explicit merge boundary before deciding any merge.
- `pre-push` refreshes and blocks on failure. Updates targeting `refs/heads/claude/integration` or `refs/heads/gauntlet/production` additionally require the freshly fetched integration SHA to be an ancestor of the **proposed pushed tip**, not merely current HEAD; deletion of either is refused. Production updates also fetch the frozen production ref and require its tip as an ancestor, preserving production-only commits. Feature pushes refresh without requiring a rebased feature. This compares canonical origin integration even when pushing another remote; no automatic merge, force or push occurs. Git hooks remain locally bypassable and cannot prevent a remote race after fetch; normal non-forced push still protects that race.

Android validation has an explicit marker route: `push` must target `gauntlet/production` **and** change the exact path `.github/native-milestone.txt`. The marker route is deferred reference machinery: current Pat rules prohibit APK builds and freeze production/main. Do not change the marker or trigger the workflow without a later explicit Pat instruction changing those rules. A coherent playable milestone alone is NOT an APK trigger. Record the reviewed source and specific native reason; never bump it on ordinary source/docs changes or just to certify a completed cycle. Feature/tag pushes do not build. GitHub path-filter limits still require inspecting the actual event/source. Signing always reuses the canonical Git-saved debug key; cache loss cannot generate a replacement. See [signing provenance](../scripts/toolchain/signing/README.md).

Production-only `workflow_dispatch` remains optional, with this explicit CLI form:

```sh
gh workflow run android-validation.yml --ref gauntlet/production
gh run view RUN_ID --json event,headBranch,headSha,url
```

Protected `main` now contains both workflow definitions after PR5/merge6d27f72; the former missing-default-workflow rationale is obsolete. Manual dispatch has not been exercised for this later baseline and must not be probed merely to prove availability. Registration/YAML presence is not a completed native run. Both routes remain prohibited under the current no-APK order. Their presence is not permission to run either one; a later Pat instruction must change that rule first.

Record the intended published production SHA (including the marker commit when used). Identify the actual run and verify event `push` for the marker route or `workflow_dispatch` for manual, branch `gauntlet/production`, and recorded `headSha` (API `head_sha`) equal that exact source before attributing evidence to it. The job guard rejects all feature/tag refs. Do not infer source from a tag or newest run alone, or issue both routes for one batch. This boundary helper never builds/reruns Android or dispatches CI.

Focused check: `python3 scripts/toolchain/test-gauntlet-boundary.py`. Tests use temporary local bare remotes, actual fetch/commit/checkout/push hooks, dirty work, full-byte caches, stale failure/retry, missing documents, dispatch, unmanaged installation refusal and bounded process/lock handling. No project hooks are installed by the tests. RED/GREEN logs remain ignored in the feature worktree's `work/` directory. No gameplay suite or APK is warranted for this opt-in development helper.


## Completion-time governance check and perpetual delegation

At **every worker/task/reviewer completion**, the root orchestrator runs `python3 scripts/toolchain/gauntlet-boundary.py --boundary complete` and reads the fetched current governing files. The completion boundary invokes the read-only `scripts/toolchain/check-gauntlet-guidance.py --ref <fetched-integration-sha>` deterministic linter. CI also runs `check-gauntlet-guidance.py --root .` and its regression tests on PRs. A failure is an explicit new repair assignment on an isolated branch, followed by one reviewer/reconciliation; never overwrite another worker's edits or silently relabel historical originals.

**Structural checks do not establish semantic consistency.** Root must additionally review actual changes for contradictions with user decisions, `docs/CURRENT_GAME_SPEC.md`, ratified bible and concept selections, current ownership, CI/review facts and the next player-facing improvement. Root updates `RESUME.md` when substantive operational state changes; `CONTINUATION.md` and `WORKBENCH.md` remain short pointers; older handoffs remain identifiable historical provenance. If current state cannot be determined reliably, preserve uncertainty and assign a verification task. The user does not maintain routine handoffs.

During authorized development the orchestrator delegates useful work after workers release their scope. Pat's current cloud stop takes precedence: finish PR96 and the requested documentation/desktop handover, then stop and wait. Source and evidence recovery live in DESKTOP_HANDOFF.md; no new worker or implementation follows this closeout. The linter and hooks enforce document preconditions at boundaries; **they cannot generate collaboration calls or continue an expired agent session**. When a true session/usage limit is reached, checkpoint the exact next command, live branch/worker status, accepted source and pending changes, and label PAUSED: RESUME REQUIRED. Only the user can declare the overall Gauntlet finished.

**Promotion policy:** `claude/integration` is the development integration branch. `gauntlet/production` is frozen pending Pat-authorized coherent promotion; protected `main` remains the accepted baseline. Promote only under Pat's authorization via PR, applying required guidance and game checks; never push raw worker changes straight to `main`. Configure GitHub rulesets to require the `guidance` check and the applicable gameplay check after those checks first report successfully. See `.github/workflows/gauntlet-pr-checks.yml`.
