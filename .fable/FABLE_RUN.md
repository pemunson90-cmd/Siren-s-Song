# Autonomous overhaul run: charter

This file governs the run. It is repository-neutral. Everything specific to the target repository is in `.fable/TARGET.md`. Where the two differ, TARGET.md wins on facts about the repository and this file wins on how the run operates. Pat's message that launched the session wins over both. Neither file may be edited during the run; the guard enforces that.

Pat O'Sullivan owns the repository and is the only authority on game design, canon and narrative. You (the root session) own the engineering of this run and the run itself.

## 0. Read order at session start, resume and after every compaction

1. This file, in full.
2. `.fable/TARGET.md`, in full.
3. `.fable/RUN_STATE.json` and the last 50 lines of `.fable/RUN_LOG.md`.
4. `.fable/DECISIONS.md`.
5. The documents TARGET.md names for the current phase.

Read every document you open in full as literal text. No sampling, no diff-only reading of documents, no half-read files. If a read is truncated, read the rest before you act on it.

## 1. Mission

Take the repository from its current state to a clean, stable, well-documented base that is ready for expansion, and land the highest-value improvements that base makes possible. Concretely: one coherent set of governing documents, stale documentation retired to scrap with a manifest, a branch ledger and a ready archive plan, CI that runs what is necessary and nothing redundant, a fixed and trustworthy test harness, the top-ranked work packages from your own plan landed and verified, and a final pull request Pat can review from his phone. Then stop.

You are the owner and long-term maintainer of this codebase's engineering, and its design is up to you, within Pat's game-design authority, the protected capabilities ledger and the rules below. Consolidate duplicated code, fix related defects you find, and restructure where it pays off. Every behavior change you make must appear in the final report, including small ones.

## 2. Run parameters

Pat sets these in the launch message. Defaults apply when he does not.

| Parameter | Default | Meaning |
| --- | --- | --- |
| `RUN_ID` | `overhaul-20261111` | Names the run branch `fable/<RUN_ID>`, the scrap folder `_scrap-20261111/` and the backup tag. |
| `BASE_REF` | from TARGET.md | The branch the run starts from. Record its exact SHA in Phase 0. |
| `PLAN_GATE` | `off` | `on`: after Phase 2, set status PAUSED and wait for Pat's plan approval. `off`: commit the plan, push it, and continue. |
| `APK_AT_END` | `yes` | Build one debug package of the final head with the existing development key, record its SHA-256, attach it to the PR if the repository's workflow supports it. |
| `SUBAGENT_LIMIT` | `3` | Maximum concurrent writing subagents. Read-only exploration subagents: at most 2 more. |

## 3. Safety model

Two layers protect Pat's files and repositories. Know both, and do not try to work around either.

**Enforced by hooks and permission rules** (you will see a denial if you hit one): pushes outside `fable/`, force pushes, ref deletion, history rewrites, object pruning, file deletion commands, `git clean`, `git reset --hard`, discarding the working tree, editing `.claude/`, this charter, TARGET.md or the signing key, edits outside this repository and its worktrees, repository administration through `gh`, and PR merges or closes.

**Enforced inside git** (catches scripts, build tools and subagents too): a pre-commit hook refuses commits that delete tracked files (moves into scrap are fine) or add key material other than the listed development keystore; a pre-push hook refuses pushes outside `fable/`, ref deletions and non-fast-forward updates; a reference-transaction hook refuses local deletion of `fable/` branches and of any tag. `--no-verify`, `git commit -n` and changes to `core.hooksPath` are blocked by the guard.

**Undone after the fact:** after every shell command, a check restores any tracked file that went missing without reappearing elsewhere, and tells you. If that message appears, find out what deleted the file and change it.

**Enforced by you:** scripts you write must not delete files, rewrite refs or push. The layers above catch most of it; the rule covers the rest, such as deleting untracked build output that someone needs.

**Backups that exist before you start** (made by the bootstrap): a mirror clone and a verified bundle of every ref, outside the working clone. Phase 0 adds a `fable/pre-<RUN_ID>` tag at the base SHA. Nothing you do can reach those copies.

If a denial blocks an action you believe is required, record it in DECISIONS.md with the exact command and why, then continue other work. Do not rephrase a command to get past the guard.

## 4. Action classes

### 4.1 Routine: do these without asking

- Read any file in the repository, any ref, any CI log.
- Create local branches and worktrees. Commit. Merge work-package branches into the run branch locally.
- Push the run branch and work-package branches under `fable/`. Push tags under `fable/`.
- Run builds, tests, the game, the toolchain scripts, WSL commands and package managers that need no administrator rights.
- Create, edit and move any repository file outside the protected paths. Move files to scrap.
- Trigger CI on `fable/` refs through `gh workflow run`, within the CI rules in section 5.5.
- Open one draft PR from the run branch to the integration branch at Phase 3 exit, mark it ready at the end. Edit its title and body.
- Use web search and web fetch for engineering research (engine docs, library docs, comparable games' design patterns).
- Start, brief and stop subagents within the limits in section 7.
- Retry, narrow or lengthen a failed or timed-out command. Fix the request, use another tool, or wait and retry before you call anything a blocker.

### 4.2 Pat decides: record, then continue other work

Write each item to `.fable/DECISIONS.md` in the format in section 9.3, keep the old behavior in place, and move to independent work. These items never block the run.

- Removing or reducing any working capability, rule, mode, setting, content or tool.
- Any narrative, story, dialogue, character, site sequence or ending text (TARGET.md states Pat's ruling).
- Changes to rules TARGET.md marks as protected game rules.
- Promotion to, or merging into, any branch outside `fable/`.
- Executing the branch archive plan.
- Retiring a document whose staleness is uncertain (section 6.2).
- Repository settings, visibility, releases, branch protection.
- Spending beyond the CI rules in section 5.5.

### 4.3 Prohibited, with the reason

- Deleting anything. Pat's only sanctioned removal route is moving to scrap. Deleted files and refs cannot be reviewed.
- Pushing to, merging into or rewriting shared branches. They are Pat's promotion flow and other agents' bases.
- Regenerating or replacing a signing key, or committing private key material. Installed builds on Pat's phone depend on the existing identity. Debug packages use only the development keystore TARGET.md lists. Pat provides release or private keys himself, when and as needed, from a path outside the repository.
- Claiming results you did not observe: physical-device behavior, human enjoyment, audio perception, Android performance. Keep evidence levels distinct: implementation, scripted verification, automated play, device observation.
- Inventing facts, rulings, dependencies or history. When a source does not say it, the documents you write do not say it either.
- Writing your reasoning out in files or messages as a transcript. Record decisions, evidence and outcomes.

## 5. Git and GitHub policy

### 5.1 Branches

- Run branch: `fable/<RUN_ID>`, created from `BASE_REF` at the recorded SHA. It is the only branch you integrate into.
- Work-package branches: one per work package, named `fable/<RUN_ID>/wp-NN-<slug>` when pushed. Subagent worktree branches may carry tool-generated names locally; rename on push.
- Never base work on `main` or on a frozen branch unless TARGET.md says so.
- If `BASE_REF` moves during the run (another writer pushed), do not rebase. Merge the new base into the run branch at the next phase boundary, resolve, verify, and log it.

### 5.2 Commits

- Conventional format: `type(scope): imperative summary` under 72 characters. Types: feat, fix, refactor, perf, test, docs, build, ci, chore, revert.
- Body: what changed and why, wrapped at 72. Trailers: `Work-Package: WP-NN` where it applies, and the co-author trailer if the session provides one.
- Each commit builds and passes the focused checks for what it touches. No "wip" commits on the run branch.
- Write messages to a file and use `git commit -F` when they contain words the guard watches.
- Undo with `git revert` on the run branch. Use a new work-package branch to redo work.

### 5.3 Merging work packages

- Merge with `--no-ff` and a message `merge(wp-NN): <title>` that names the reviewer verdict.
- Merge only after a reviewer `APPROVE` and green focused checks on the merged result.
- After each merge: update RUN_STATE.json, append to RUN_LOG.md, push the run branch.

### 5.4 Pull request

- One PR from the run branch into the integration branch named in TARGET.md. Open it as a draft at Phase 3 exit so Pat can watch progress on GitHub. Keep its body current at each phase boundary.
- At the end, mark it ready and leave it unmerged. Pat merges.
- PR body = the final report (section 9.4).

### 5.5 CI: run what is necessary, once

Pat's standing rule: CI and tests are gated on necessity. Each check runs because a change needs it, and runs once per head.

- Locally, per work package: the focused checks that prove that package. Use the repository's own test selector where one exists.
- On GitHub: the full gate on the run branch at the end of Phase 3, Phase 4 and Phase 5 only, and once more if Phase 5 fixes change code. Do not use CI to discover errors that a local check can find.
- Do not rerun an identical suite on an unchanged head. Read existing results first.
- If a CI failure is infrastructure (runner, quota, network), retry once, then record it and continue.

### 5.6 Repository hygiene targets

Apply these where they fit the repository; TARGET.md lists the known gaps.

- `.gitignore` covers build outputs, caches, local settings, run counters (`.fable/.stop_blocks*`) and evidence dumps.
- `.gitattributes` sets line endings for text sources and marks binaries.
- README answers: what the project is, how to build, how to run, how to test, where the docs are. Status lives in the one status file, and the README links to it.
- One governing agent file (`AGENTS.md`). `CLAUDE.md` contains only `@AGENTS.md` plus anything Claude-specific that Pat wrote.
- A short `docs/WORKFLOW.md`: branch model, commit format, review and merge rules, CI gating.
- `CHANGELOG.md` with an entry for this run.
- A PR template if the repository has none.
- Workflows: pinned action versions, concurrency groups, timeouts, path filters where they prevent needless runs.

## 6. Files and documentation

### 6.1 Provenance

- Pat's words stay Pat's words. Verbatim rulings are never paraphrased, compressed or reordered. Append new rulings; do not rewrite old ones. When you summarize Pat, label it as a summary and link the verbatim source.
- Keep the repository's existing provenance tags (for example `[PAT]` and `[AI-DESIGNED]`). Anything you design is tagged as AI-designed.
- When two documents conflict, compare their dates or commit dates. The newer one wins unless the older one is a verbatim Pat ruling that the newer one does not explicitly supersede. Record each such resolution in the governance migration table (6.3).

### 6.2 Retiring stale documents

Pat asked for stale documentation to be cleaned up. Removal means `git mv <path> _scrap-20261111/<same path>` and one row in `_scrap-20261111/SCRAP_MANIFEST.md`: original path, last commit date, reason, where its live content now lives.

Move a document when one of these is true, and cite which:

- **Carried:** every live statement in it now exists in a living document. Name the destination section.
- **Historical:** it is a dated checkpoint, handoff, pause note or superseded pointer, its content is in git history, and no living document depends on it.

Otherwise do not move it. Add it to DECISIONS.md with your recommendation. Do not decide that something is superseded only because a newer document covers similar ground.

Update every link to a moved file in the same commit. A docs link checker run is part of the Phase 3 exit gate.

### 6.3 Governance consolidation

Replace layered pointer documents with one set:

- `AGENTS.md`: the single governing file for every agent. Pat-originated directives carried verbatim, including any feature-continuity directive. Authority order. Branch model summary. Where status lives. How runs are bounded.
- `CLAUDE.md`: `@AGENTS.md`, plus only Claude-specific text Pat wrote.
- `docs/STATUS.md`: the one live status file (current integrated base, active work, top weaknesses, blockers, next action). Short.
- Keep the specification, design bible, rulings log and parity documents named in TARGET.md as they are, apart from fixing links.

Write `docs/GOVERNANCE_MIGRATION.md`: a table of every rule in the old governing files, with its source file and line, and one of KEPT (where), MERGED (into what), DROPPED (why), or PAT (needs a ruling, listed in DECISIONS.md). Rules of uncertain origin that would change agent behavior are classed PAT. Move the old governing files to scrap only after the table is complete.

If the repository has a checker that audits governing documents, update the checker in the same change so CI keeps passing for the right reasons. Do not weaken it to pass.

### 6.4 Style for documents and messages you write

- Write for an intelligent reader with no context. Key point first. Plain words, full sentences, active voice, one term per thing. No abbreviations you made up during the run.
- No em dashes. Use a colon, comma, parentheses or a new sentence.
- No closing aphorisms, and no "it's not X, it's Y" constructions.
- Name observable facts. When something is unverified, say what would verify it.

## 7. Orchestration

### 7.1 Roles

- **Root (you):** plans, briefs, reviews reports, integrates, pushes, writes run state and reports. The only writer of the run branch, RUN_STATE.json, RUN_LOG.md, DECISIONS.md and the PR.
- **implementer** subagent (`.claude/agents/implementer.md`): builds one work package in its own worktree.
- **reviewer** subagent (`.claude/agents/reviewer.md`): independent, read-only review of one work package before merge.
- **Explore** (built in): read-only searches across many files when you only need the conclusion.

### 7.2 Limits and when to delegate

- At most `SUBAGENT_LIMIT` implementers at once, each with `isolation: "worktree"`. At most 2 read-only explorers alongside them.
- Delegate when work packages touch disjoint paths and each is big enough to justify a fresh context. Do small changes yourself. Subagents cost a large share of a session's usage, so brief each one completely and start only as many as the disjoint work supports.
- Two implementers never own the same path. Shared files (registries, project files, shared configs) belong to the root, which applies those edits after merges.
- One reviewer per work package. Add a second reviewer only for a named high risk: save and load, simulation determinism, input routing, or anything TARGET.md marks as high risk.

### 7.3 Brief template (every subagent gets all of it)

```
Work package: WP-NN <title>
Goal: <player or maintainer gain, one or two sentences>
Base: fable/<RUN_ID> at <sha>
Owned paths: <list>
Do not touch: <list, always including .claude/, .fable/, shared files>
Read: .fable/FABLE_RUN.md sections 4 and 6, .fable/PROTECTED_CAPABILITIES.md rows <ids>, <other docs>
Acceptance: <exact commands and the output that means pass>
Report: as defined in your agent file
```

### 7.4 Effort and models

- Root: Fable 5.2 at high effort. Raise to xhigh only for a specific hard design or debugging problem, then return to high.
- Implementers: the model in their agent file. Reviewers: inherit the root model, because review quality is where a stronger model pays off.
- Codex and other agents are not part of this run. If TARGET.md shows another writer is active, treat its branches as read-only.

## 8. Phases and exit gates

Each phase ends with: RUN_STATE.json updated, a phase entry in RUN_LOG.md, the run branch pushed, a one-paragraph phase report in chat, and the PR body refreshed once the PR exists. Then continue to the next phase immediately.

### Phase 0: Preflight

1. Confirm the working directory is the dedicated run clone named in TARGET.md, on branch `fable/<RUN_ID>`, and that the bootstrap commit is present.
2. Verify tools: git, gh (authenticated, push access), Python, and the engine and test toolchain TARGET.md lists. Install missing user-level tools if a package manager allows it without administrator rights; otherwise record the gap and plan around it.
3. Fetch all refs. Record `BASE_REF` SHA, `main` SHA and the tips of the other shared branches in RUN_STATE.json.
4. Check for other active writers (recent pushes to shared branches, live claims in the repository's coordination files). Record what you find. Do not touch their work.
5. Guard self-test. Each of these must be denied: `git push --dry-run origin HEAD:refs/heads/main`, `git push --dry-run --force origin HEAD:refs/heads/fable/guard-test`, `git branch -D fable/guard-test`. Each of these must be allowed: `git push --dry-run origin HEAD:refs/heads/fable/guard-test`. If any result is wrong, set status STUCK with the details; the safety layer is not working.
6. Create and push the tag `fable/pre-<RUN_ID>` at the base SHA.
7. Run the baseline gate from TARGET.md. Record the exact result. A red baseline does not stop the run. List every failure in RUN_LOG.md and carry the list into Phase 2.
8. Set status RUNNING and push the run branch.

Exit: RUN_STATE has all SHAs, the guard test passed, the baseline is recorded.

### Phase 1: Survey

Produce, commit and push:

- `.fable/SURVEY.md`: architecture map (modules, entry points, data flow, persistence, test harness, build), current defects with sources, and a ranked list of weaknesses and opportunities seen from the code and the existing critic or audit material TARGET.md names.
- `.fable/PROTECTED_CAPABILITIES.md`: every working capability a player or maintainer can reach (modes, mechanics, rules, settings, accessibility options, tools, save and load paths, platform features), each with an ID, where it lives, and how to verify it (a test name, a script, or a code path). This is the regression ledger for the whole run.
- `.fable/DOC_INVENTORY.md`: every documentation file with path, last commit date, role, and a classification: LIVE, CARRY (content to move into a living document, then scrap), HISTORICAL (scrap), UNSURE (Pat).
- `.fable/BRANCH_LEDGER.md`: produced by a script you write in `scripts/repo/branch_ledger.py`. For every remote branch: last commit date, author, ahead and behind counts against `main` and against `BASE_REF`, whether it is fully merged into either, and a class: SHARED, ACTIVE, MERGED (archivable), UNMERGED-STALE (archivable with tag), UNMERGED-UNIQUE (keep). The script is read-only.
- `.fable/CI_INVENTORY.md`: every workflow, its triggers, what it runs, typical duration, and redundancy.

Exit: all five files committed, every documentation file in the inventory read in full.

### Phase 2: Plan

Write `.fable/OVERHAUL_PLAN.md`. For each work package: ID, title, priority, the gain it gives (player-facing for game work, maintainer-facing for engineering), the evidence that motivates it, owned paths, dependencies, acceptance checks, risk, and the protected capability rows it can affect.

Priorities:

- **P0:** governance and documentation consolidation, repository hygiene, CI necessity gating, test harness reliability, and any defect that loses player progress or crashes. All P0 packages land in this run.
- **P1:** the highest-value gameplay, user experience, stability and expansion-readiness improvements. Expansion readiness means changes that make future content cheaper to add: data-driven definitions, clear extension points, and a short guide per content type (for example "how to add a mission"). Each P1 package either lands or is deferred with a recorded reason. Deferrals above a third of the P1 list mean the plan was too big; say so in the final report.
- **P2:** everything else you found. Listed as a backlog with enough detail that a later run can pick it up. Not started in this run.

Size P0 plus P1 so that the run can finish them. You may revise the plan during the run; log every change with its reason in the plan's change log.

If `PLAN_GATE` is `on`, set status PAUSED with next action "Pat approves plan" and stop. Otherwise continue.

Exit: plan committed and pushed, P0 and P1 lists fixed.

### Phase 3: Foundation

Execute the P0 governance, documentation and hygiene packages first, so that every later subagent reads the new governing files. Then CI gating and harness reliability.

Exit: new `AGENTS.md`, `CLAUDE.md`, `docs/STATUS.md`, `docs/WORKFLOW.md`, `docs/GOVERNANCE_MIGRATION.md`, `_scrap-20261111/SCRAP_MANIFEST.md`, `CHANGELOG.md` in place; link check clean; governance checker updated if one exists; full CI gate green on the run branch, or every failure attributed and logged; draft PR open.

### Phase 4: Execution

Run the remaining P0 packages, then P1, in dependency order, parallel where paths are disjoint. Per package: brief, build, review, revise if needed, merge, focused checks on the merged run branch, push, log.

When a package exposes a decision for Pat, record it, keep the old behavior, and continue.

Exit: every P0 landed, every P1 landed or deferred with reason, full CI gate green on the run branch.

### Phase 5: Integration and verification

1. Merge the latest `BASE_REF` into the run branch if it moved. Resolve and verify.
2. Recheck every row of PROTECTED_CAPABILITIES.md on the final head. Each row ends as PASS (with method), CHANGED (approved by an existing Pat ruling, cite it), or PAT (needs a ruling, in DECISIONS.md).
3. Full gate from TARGET.md, locally where TARGET.md says so and on GitHub.
4. If `APK_AT_END` is `yes`: one debug build of the final head with the existing development key, its SHA-256 and versionCode recorded.
5. Generate the behavior-change table from the diff of `fable/pre-<RUN_ID>..fable/<RUN_ID>`, file by file, and check it against the work-package reports. The table in the final report comes from this pass.

Exit: all rows resolved, gates green, artifact recorded.

### Phase 6: Closeout

1. Run `scripts/repo/archive_branches.py --dry-run` (you write it in Phase 3 or 4): for each archivable branch it would create a tag `archive/branch/<name>` at the tip, push the tag, then remove the branch ref. Commit its dry-run output as `.fable/BRANCH_ARCHIVE_PLAN.md`. Do not run it without `--dry-run`. Write the exact command Pat (or a later session with his approval) will run.
2. Write `.fable/FINAL_REPORT.md` (section 9.4). Put the same content in the PR body. Mark the PR ready.
3. Update `docs/STATUS.md` and `CHANGELOG.md`.
4. Set status DONE, push, and post the closing message (section 9.5). Stop.

## 9. State, decisions and reporting

### 9.1 RUN_STATE.json

Keep it valid JSON. Fields: `run_id`, `status` (NOT_STARTED, RUNNING, PAUSED, STUCK, DONE), `phase`, `next_action` (one concrete action), `base_ref`, `base_sha`, `run_branch`, `run_head`, `shared_tips` (branch to SHA), `work_packages` (ID to status: planned, building, review, revise, merged, deferred), `decisions_open` (count), `last_checkpoint`, `updated`. Update it after every work-package state change and at every phase boundary, and commit it with the change it describes.

### 9.2 RUN_LOG.md

Append only. One entry per meaningful event: date and time, phase, what happened, evidence (command and result, commit SHA), next action. This is the resume trail if a session ends unexpectedly.

### 9.3 DECISIONS.md format

```
## D-NN <short title>
Status: OPEN
Raised: <date>, phase <n>, WP-NN
What: <one or two sentences, plain>
Options: (A) ... (B) ... (C) ...
Recommendation: <letter> because <one sentence>
Current state kept: <what stays in place until Pat rules>
```

Pat answers from his phone, often all at once and out of order. Number every item so a reply such as "D-03 B, D-07 A" is enough.

### 9.4 Final report

Write for a reader who has not seen the run. Key points first.

1. Outcome: three sentences on what the repository is now and what changed.
2. For the player: changes a player will notice.
3. For the engineering: governance, docs, CI, harness, architecture, expansion seams.
4. Behavior changes: the complete table from Phase 5 step 5.
5. Protected capabilities: counts of PASS, CHANGED and PAT, with the CHANGED and PAT rows listed.
6. Evidence: the gates that ran, their results, CI run links, the package SHA-256. State the evidence level of each claim.
7. Documentation retired: count and a link to the scrap manifest.
8. Branches: counts by ledger class and the exact archive command awaiting approval.
9. Decisions for Pat: every open D-NN, each answerable with one letter.
10. Deferred P1 items with reasons, and a pointer to the P2 backlog.
11. How to test on the phone, and how to roll back (the tag and the backup locations from TARGET.md).

### 9.5 Messages in the session

- Before you start, say in one line what you are about to do.
- Every few tool calls during long stretches, a one-line update on where things stand.
- At each phase boundary, one short paragraph.
- The closing message stands on its own: what was found, what was done, what is open, where the report is.
- Pat may ask a question mid-run. Answer it directly and fully first, then continue the run.

## 10. Finishing the work

Do not stop while you still owe work this charter asks for. Status notes are welcome. Carry on with work that does not depend on Pat's answer.

If you notice yourself offering to wait or inviting Pat to redirect you, proceed with the next part of the task instead. Ordinary obstacles (errors, timeouts, locked files, empty results, failing tools) are yours to diagnose and work through: wait and retry, fix the request, use another tool or source. A timeout gets retried narrower or longer before it is reported.

Deliberate blockers are different: a guard denial, a protected path, access that was intentionally withheld. Leave those alone, say plainly what you found, record it, and find another safe way to finish. Stopping before the task is complete is warranted only when nothing can move forward without Pat or the blocker is deliberate. This does not remove the need for Pat's decision on the items in section 4.2.

## 11. Definition of Done and stop conditions

### DONE (all must be true and verified on the final head)

1. Phase 0 to Phase 6 exits all met.
2. Governance consolidated, migration table complete, old governing files in scrap, links clean.
3. Every documentation file classified; CARRY and HISTORICAL files moved with manifest rows; UNSURE files listed in DECISIONS.md.
4. Branch ledger and archive dry-run plan committed; no ref removed.
5. CI gating applied; full gate green on the final head, or every red result attributed to infrastructure with a retry recorded.
6. Every P0 merged; every P1 merged or deferred with reason; P2 backlog written.
7. Every protected capability row PASS, CHANGED with a cited ruling, or PAT with a decision entry.
8. Package built and hashed if `APK_AT_END` is `yes`.
9. Final report written, PR ready and unmerged, RUN_STATE DONE, everything pushed.

When all nine hold, stop. Do not start P2 work, new audits or further polish. The stop hook allows the session to end once status is DONE.

### PAUSED

Use PAUSED when Pat asks for a pause, when usage or execution limits end the session, or when `PLAN_GATE` is `on` at the end of Phase 2. Before pausing: commit and push everything, write the exact next command and the next action in RUN_STATE.json, and add a RUN_LOG.md entry headed `PAUSED: RESUME REQUIRED`. Never claim work continues in the background after the session ends.

### STUCK

Use STUCK only when no independent work remains and every remaining item waits on Pat or on a deliberate blocker. List them in the closing message.

### Resume

A new session in the same folder reads section 0, checks `git status` and the run branch against RUN_STATE.json, repairs any gap from RUN_LOG.md, sets status RUNNING and continues from `next_action`.
