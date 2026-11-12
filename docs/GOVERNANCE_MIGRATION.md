# Governance migration table

Written 2026-11-12 by the overhaul run `overhaul-20261111` (AI-written). It accounts for every rule in the governing files as they stood on `claude/integration` at `cabd5bd5`, and for the agent decisions recorded on `codex/handoffs` at `99e52d2d`.

How to read it. **Source** gives the old file and line on that base; files marked (scrap) are now under `_scrap-20261111/` at the same path. **Disposition** is one of:

- **KEPT** (where): the rule is carried, in the place named.
- **MERGED** (into what): the rule is carried as part of a broader rule.
- **DROPPED** (why): the rule is not carried. Each has its reason.
- **PAT**: the rule would change how agents behave and its standing is uncertain. It is listed in the run's decisions file (`.fable/DECISIONS.md`) and the old behavior stays until Pat rules.

Pat's verbatim rulings are never dropped. Where a later ruling overrides an earlier one, both stay in [USER_DIRECTIVES.md](USER_DIRECTIVES.md) and the row says which governs.

## 1. `AGENTS.md` (old text in `_scrap-20261111/AGENTS.md`)

| # | Rule | Source | Disposition |
| --- | --- | --- | --- |
| 1 | Feature continuity directive (owner): nothing working is removed without Pat's explicit authorization; check the real baseline before coding | AGENTS.md:1-5 | KEPT verbatim at the top of AGENTS.md |
| 2 | Identity: military photographic reconnaissance first | AGENTS.md:7 | KEPT, AGENTS.md section 1 (labelled summary; verbatim in USER_DIRECTIVES 22 Oct) |
| 3 | Integration is `claude/integration`; `gauntlet/production` frozen; `main` protected; Pat authorizes promotion | AGENTS.md:9 | KEPT, AGENTS.md section 5, with the 31 Oct ruling that `main` is the only promotion target |
| 4 | Operational status lives in RESUME; Codex claims on the handoffs board | AGENTS.md:7,9 | MERGED into "status lives in docs/STATUS.md" (AGENTS.md section 6). The board was frozen on 31 Oct (handoffs decision D14). |
| 5 | Read USER_DIRECTIVES first; implement the approved full-release expansion; preserve Pass0 and v7 systems; playtest timing never gates work | AGENTS.md:11 | KEPT: authority order (section 3), v7 reference (section 3), playtest never gates (section 9) |
| 6 | Gauntlet loop: assess the whole game, fix the most consequential weakness, repeat; the user alone ends it | AGENTS.md:15 | KEPT, AGENTS.md sections 7 and 9, with Pat's milestone-loop line from `main` quoted verbatim |
| 7 | "Current execution": Pat continued locally on 25 Oct; Codex continues its queue | AGENTS.md:19 | DROPPED: a dated session arrangement. Codex was not active after 1 Nov (STATE.md). |
| 8 | Historical 23 Oct cloud stop: finish PR96, hand over, stop | AGENTS.md:21 | DROPPED: superseded by the 25 and 27 Oct resumptions; the order is kept in USER_DIRECTIVES as history |
| 9 | Standing plan: implement the full-release program in the specification; reusable operation systems; complete campaign, expeditions, career | AGENTS.md:24 | KEPT, AGENTS.md section 2 (project) and the specification |
| 10 | Use Sol6.1 Medium, one implementation worker, one independent reviewer; broader critics sequentially at milestones | AGENTS.md:24 | Model part DROPPED (see section 9 below, model routing). "One independent reviewer per change" KEPT, AGENTS.md section 7. |
| 11 | No new governance tooling or approval gates | AGENTS.md:24 | MERGED into "work on the game, not on proving that a workflow happened" (section 7) |
| 12 | CONTINUATION and WORKBENCH stay under 40 lines | AGENTS.md:24 | MERGED: STATUS.md stays short; the guidance checker fails above 80 lines |
| 13 | A task, worker, plan, review or milestone completion starts the next authorized action | AGENTS.md:26 | KEPT, AGENTS.md section 9 (Gauntlet runs) |
| 14 | Codex follows its handoff protocol on `codex/handoffs` | AGENTS.md:26 | DROPPED: the protocol was replaced on 31 Oct and Codex is not part of current work. Retiring the branch is decision D-04. |
| 15 | On exhaustion publish recovery refs and write PAUSED, RESUME REQUIRED with the exact next command; state execution honestly | AGENTS.md:26 | KEPT, AGENTS.md section 9 |
| 16 | Rank player-facing weaknesses against source, v7 and successful games | AGENTS.md:29 | KEPT, section 7 |
| 17 | Dedicated branches and worktrees with explicit ownership; preserve other workers' edits and evidence | AGENTS.md:30 | KEPT, section 7 and WORKFLOW.md |
| 18 | One designated integration reviewer; fix consequential regressions before integration | AGENTS.md:31 | KEPT, section 7 and WORKFLOW.md "Review and merge" |
| 19 | Independent review and final-head CI before a PR into `claude/integration`; reconcile the fetched tip when it moves | AGENTS.md:32 | KEPT, WORKFLOW.md "Review and merge" |
| 20 | Claude orchestrates; Codex may merge only under delegation | AGENTS.md:32 | DROPPED: session arrangement. Who integrates is set per run. |
| 21 | Validate primarily in Godot; batch broad regression at milestones | AGENTS.md:33 | KEPT, WORKFLOW.md "Tests and CI", under Pat's 31 Oct minimum-tests ruling |
| 22 | "Current Pat rules prohibit Android APK builds" | AGENTS.md:33 | DROPPED: overridden by Pat's ruling of 1 Nov 2026 ("If it would be easier to test on, you can build the apk..."). The current rule is in AGENTS.md section 7 and WORKFLOW.md. |
| 23 | Reuse the canonical Git-tracked debug signer | AGENTS.md:33 | KEPT, AGENTS.md section 7 and WORKFLOW.md |
| 24 | Simulation, layout and encounter work should outweigh documentation | AGENTS.md:34 | KEPT, section 7 |
| 25 | The SHA in RESUME is the last reconciled baseline, not a promise to equal HEAD | AGENTS.md:37 | MERGED: STATUS.md records a base and is updated only when something substantive changes (WORKFLOW.md "Status") |
| 26 | Record an attributable reviewer verdict in the PR before merge; label a relayed review as relayed; CI is not criticism | AGENTS.md:39 | KEPT, WORKFLOW.md "Review and merge" and AGENTS.md section 7 |
| 27 | Reconcile RESUME at each merge; do not make meaningless document edits; do not add CI gates or orchestration layers | AGENTS.md:41 | MERGED into AGENTS.md section 8 and WORKFLOW.md step 5 |
| 28 | Critics start fresh, play full operations by real touch on cover and inner views, with distinct strategies | AGENTS.md:44 | KEPT, AGENTS.md section 7 and `scripts/critic/CRITIC_BRIEF.md` |
| 29 | Blind side-by-side comparison with reference footage (Door Kickers, Mark of the Ninja, Barotrauma, Duskers) | AGENTS.md:46 | MERGED: the critic brief names reference games per dimension and says comparisons are from memory, because no footage is available to the kit. Pat's 30 Oct reference list is in USER_DIRECTIVES. |
| 30 | Authority order | AGENTS.md:49 | KEPT, AGENTS.md section 3 |
| 31 | v7 outranks older prose about its mechanics; preserve its source | AGENTS.md:49 | KEPT, section 3 |
| 32 | Six original missions are the tutorial foundation of a longer branching campaign | AGENTS.md:49 | KEPT, section 2 |
| 33 | Preserve Godot 4.6.3, GDScript, Compatibility and the module boundaries | AGENTS.md:51 | KEPT, section 2 |
| 34 | Physical movement, unlimited pause, fair information, finite tools, independent craft; publishing administration out of scope | AGENTS.md:51 | KEPT, section 2 |
| 35 | At boundaries fetch guidance with `gauntlet-boundary.py`, read changed files, reconcile, start the next task | AGENTS.md:54 | KEPT, section 8 and WORKFLOW.md "Tools" |
| 36 | Default `gpt-6.1-sol` with fresh context; record requested routing separately | AGENTS.md:56 | DROPPED from the governing file: model routing (section 9 below) |
| 37 | Minimal useful parallelism with clear ownership | AGENTS.md:56 | MERGED into section 7 |
| 38 | Keep source, assets, tests, tools and concise instructions on production; store raw evidence externally; preserve refs, evidence, saves and signing material | AGENTS.md:58 | KEPT, section 7 "Keep the tree lean" and section 5 |
| 39 | Communicate concrete actions, results and player gains | AGENTS.md:58 | KEPT, section 8 item 3 |
| 40 | Guidance ownership: USER_DIRECTIVES records decisions, AGENTS owns rules, the specification owns behavior, PHOTO_RECON the camera, RESUME the snapshot | AGENTS.md:61 | KEPT, section 6 table, with STATUS.md in place of RESUME |
| 41 | A structural guidance pass cannot establish semantic accuracy | AGENTS.md:61 | KEPT, section 8 item 1 |
| 42 | Installed hooks adopt a changed helper only by explicit reinstallation | AGENTS.md:61 | KEPT, WORKFLOW.md "Tools" |

## 2. `CLAUDE.md`, `README.md`, `docs/START_HERE.md`

| # | Rule | Source | Disposition |
| --- | --- | --- | --- |
| 43 | CLAUDE.md repeated the feature continuity directive | CLAUDE.md:1-5 | MERGED: CLAUDE.md is now `@AGENTS.md`, which carries it verbatim |
| 44 | Stop banner: "Observe Pat's cloud stop and Windows desktop handover" | README.md:1,5; START_HERE.md:1 (scrap); and the same banner on AGENT_BRIEF, GAUNTLET_ORCHESTRATION, architecture/GAUNTLET, CRITIC_BRIEF | DROPPED: lifted by Pat on 25 and 27 Oct (USER_DIRECTIVES). The checker now rejects it. |
| 45 | Start with AGENTS, the specification, source authority, parity ledger, design bible, concept ledger | README.md:11 | KEPT, README.md document table |
| 46 | The user alone can terminate the program; completed tasks trigger policy refresh and the next work | README.md:13; START_HERE.md:11,20 (scrap) | KEPT, AGENTS.md section 9 |
| 47 | Every proposed integration is reviewed on its own branch and reconciled against the integration tip | README.md:13 | KEPT, WORKFLOW.md |
| 48 | "Android builds/phone testing remain deferred" | START_HERE.md:11 (scrap) | DROPPED: overridden by the 1 Nov ruling for builds. Phone testing is Pat's own timing (AGENTS.md section 9). |
| 49 | Historical prototype material is provenance; v7 does not impose its one-level workflow | START_HERE.md:13 (scrap) | KEPT, AGENTS.md section 3 and SOURCE_AUTHORITY.md |
| 50 | Lean repository; consult AGENTS before creating reporting documents | START_HERE.md:15 (scrap) | KEPT, AGENTS.md section 7 |
| 51 | Closeout: fetch integration, run the boundary check, compare guidance, repair stale instructions | START_HERE.md:20 (scrap) | KEPT, AGENTS.md section 8 |
| 52 | Feature branches never land directly on `main` | START_HERE.md:20 (scrap) | KEPT, WORKFLOW.md branch model |

## 3. `docs/RESUME.md`, `docs/CONTINUATION.md`, `docs/WORKBENCH.md` (scrap)

| # | Rule | Source | Disposition |
| --- | --- | --- | --- |
| 53 | Read USER_DIRECTIVES first; the specification owns behavior; PHOTO_RECON owns the camera | RESUME.md:3 | KEPT, AGENTS.md sections 3 and 6 |
| 54 | Live queue and next action are in `docs/state/` on `codex/handoffs`; rulings in `RULINGS.md` there | RESUME.md:8; CONTINUATION.md:7-8; WORKBENCH.md:5 | DROPPED as a pointer: status is now docs/STATUS.md and the rulings are copied into USER_DIRECTIVES. Whether the branch is retired is D-04. |
| 55 | Critic evidence stays outside the repository | RESUME.md:9; CONTINUATION.md:9 | KEPT, AGENTS.md section 7 |
| 56 | Keep evidence levels distinct; CI does not establish enjoyment, audio, ergonomics or Android performance | RESUME.md:10; WORKBENCH.md:10-12 | KEPT, AGENTS.md section 7 |
| 57 | Independent review precedes every new commit and merge; root verifies unchanged approved bytes | RESUME.md:14 | MERGED: one independent reviewer per change on the frozen head before merge (WORKFLOW.md). "Before every commit" was replaced by handoffs decision D17 (one reviewer per PR). |
| 58 | Focused local checks; do not loosen assertions or timeouts | RESUME.md:14 | KEPT, WORKFLOW.md "Tests and CI" |
| 59 | APK builds allowed when they help testing, development key only (Pat 1 Nov) | RESUME.md:15 | KEPT, AGENTS.md section 7, WORKFLOW.md; verbatim ruling in USER_DIRECTIVES |
| 60 | No phone acceptance claims without device evidence; preserve profiles, saves, edits, refs, signer; no force push or branch deletion | RESUME.md:15 | KEPT, AGENTS.md sections 5 and 7 |
| 61 | Run the boundary helper at boundaries; a structural pass is not proof | RESUME.md:16 | KEPT, AGENTS.md section 8 |
| 62 | Only Pat's stop or exhaustion interrupts work; checkpoint as PAUSED, RESUME REQUIRED | RESUME.md:17 | KEPT, AGENTS.md section 9, plus a charter's stop point |
| 63 | At closeout report the player gain, evidence and largest remaining weakness | WORKBENCH.md:10 | KEPT, AGENTS.md section 8 item 3 |
| 64 | Read USER_DIRECTIVES and the task brief before implementation; preserve other workers' scope | CONTINUATION.md:11 | KEPT, AGENTS.md section 7 |

## 4. `docs/AGENT_BRIEF.md` (scrap)

| # | Rule | Source | Disposition |
| --- | --- | --- | --- |
| 65 | Gameplay features use PRs with passing game-smoke CI | AGENT_BRIEF.md:5 | KEPT, WORKFLOW.md |
| 66 | New operations should give photography a real role with fair information | AGENT_BRIEF.md:9 | KEPT as identity, AGENTS.md section 1; detail in PHOTO_RECON.md |
| 67 | Root supplies a bounded brief with the governing revision; workers read the brief and what it names | AGENT_BRIEF.md:11 | KEPT, AGENTS.md section 7 |
| 68 | Implementer assignment: branch, owned files, base SHA, player-facing result, references, tests; report what improved, broke or is uncertain | AGENT_BRIEF.md:13 | KEPT, AGENTS.md section 7 (brief contents) |
| 69 | Integration reviewer: examine the diff against integration, interactions, mechanics, intent, save fidelity, focused regressions; no automatic second critic, APK or evidence dossier for an ordinary merge | AGENT_BRIEF.md:15 | KEPT, WORKFLOW.md "Review and merge" |
| 70 | Whole-game critic is periodic, not the merge reviewer | AGENT_BRIEF.md:17 | KEPT, AGENTS.md section 7 |
| 71 | Closeout: every worker reports stale handoff text; root runs the boundary check and reconciles; repairs routine obsolete documents without the user | AGENT_BRIEF.md:19 | KEPT, AGENTS.md section 8 |
| 72 | `gpt-6.1-sol`, Medium effort defaults | AGENT_BRIEF.md:21 | DROPPED: model routing (section 9 below) |

## 5. `docs/GAUNTLET_ORCHESTRATION.md` (scrap)

| # | Rule | Source | Disposition |
| --- | --- | --- | --- |
| 73 | The boundary helper fetches integration and reads eight governing files in full; it never changes a branch | GAUNTLET_ORCHESTRATION.md:7 | KEPT, WORKFLOW.md "Tools". The file list is now AGENTS, USER_DIRECTIVES, STATUS, WORKFLOW, architecture/GAUNTLET, the specification and the parity ledger; the helper still reads the old list from a commit that predates the consolidation. |
| 74 | Run it before completion, dispatch, review, merge and resume | GAUNTLET_ORCHESTRATION.md:9-16 | KEPT, AGENTS.md section 8 |
| 75 | `fresh` means fetched, not read | GAUNTLET_ORCHESTRATION.md:18 | KEPT, WORKFLOW.md "Tools" |
| 76 | On failure record `stale`, emit no dispatch, retry at the next boundary; timeouts and lock rules | GAUNTLET_ORCHESTRATION.md:20 | KEPT in the tool and its test (`test-gauntlet-boundary.py`); not restated in prose |
| 77 | Dispatch preflight payload for Codex collaboration tools, default routing `gpt-6.1-sol`, medium | GAUNTLET_ORCHESTRATION.md:24-36 | KEPT in the tool (its `--dispatch` option and default are unchanged, because removing a working tool is Pat's call). DROPPED from prose: no current agent uses it. |
| 78 | Hook installer refuses unmanaged hooks and `core.hooksPath`; what each hook does | GAUNTLET_ORCHESTRATION.md:38-50 | KEPT, WORKFLOW.md "Tools" (summary); behavior is in the installer and its tests |
| 79 | Android marker route on `gauntlet/production`; "current Pat rules prohibit APK builds"; do not trigger the workflow | GAUNTLET_ORCHESTRATION.md:52-63 | Prohibition DROPPED (1 Nov ruling). The marker route still exists in `android-validation.yml` and targets a frozen branch; the any-branch debug job (item 147) is the route in use (WORKFLOW.md "Android packages"). |
| 80 | A coherent playable milestone alone is not an APK trigger | GAUNTLET_ORCHESTRATION.md:52 | KEPT, WORKFLOW.md: "Do not build a package for every change" |
| 81 | Signing always reuses the tracked debug key | GAUNTLET_ORCHESTRATION.md:52 | KEPT, AGENTS.md section 7 |
| 82 | At every completion run the boundary check; the linter runs in CI; a failure is a repair assignment | GAUNTLET_ORCHESTRATION.md:70 | KEPT, AGENTS.md section 8, WORKFLOW.md |
| 83 | Structural checks do not establish semantic consistency; the user does not maintain handoffs | GAUNTLET_ORCHESTRATION.md:72 | KEPT, AGENTS.md section 8 |
| 84 | Promotion policy; configure GitHub rulesets to require the checks | GAUNTLET_ORCHESTRATION.md:76 | Promotion KEPT (WORKFLOW.md). Rulesets are repository settings: Pat's, not restated as an agent rule. |

## 6. `docs/architecture/GAUNTLET.md`, `docs/SOURCE_AUTHORITY.md`, `docs/CURRENT_GAME_SPEC.md`, `docs/V7_TO_GODOT_PARITY.md` (kept, edited)

| # | Rule | Source | Disposition |
| --- | --- | --- | --- |
| 85 | Stop banner at the top of architecture/GAUNTLET | architecture/GAUNTLET.md:1 | DROPPED, replaced by one pointer line to AGENTS, USER_DIRECTIVES and STATUS |
| 86 | "Operational status belongs to RESUME" | architecture/GAUNTLET.md:5,63 | KEPT with STATUS.md named instead |
| 87 | "Current Pat rules prohibit APK builds and defer phone testing" | architecture/GAUNTLET.md:61 | DROPPED: replaced by a sentence that states the 1 Nov ruling |
| 88 | All technical constraints, system boundaries, gameplay design decisions, art and sound targets, verification approach | architecture/GAUNTLET.md:7-61 | KEPT unchanged |
| 89 | Two banners ("Current authority 25 October", "Historical 23 October cloud-boundary banner") | SOURCE_AUTHORITY.md:1-3; CURRENT_GAME_SPEC.md:1-3; V7_TO_GODOT_PARITY.md:1-3 | DROPPED, replaced by one pointer line each. Nothing else in the specification or the parity ledger changed, except the next row. |
| 90 | "Historical cloud-era wording ... using Sol6.1 Medium" | CURRENT_GAME_SPEC.md:5 | DROPPED: model routing and a lifted stop |
| 91 | "maintained in RESUME.md" | CURRENT_GAME_SPEC.md:114 | KEPT with STATUS.md named instead (link fix) |
| 91b | "Current Pat rules prohibit APK builds and defer physical-phone testing" in the specification's development section | CURRENT_GAME_SPEC.md:114 | The sentence is kept as written (the specification is not rewritten by this run) and a dated note after it states that Pat's 1 Nov ruling supersedes it. The pointer "operational status: docs/RESUME.md" on line 91 now names STATUS.md (link fix). |
| 92 | Authority hierarchy, v7 ratification, reconciliation note, visual guidance, scope, import checklist | SOURCE_AUTHORITY.md:5-54 | KEPT unchanged, except that "RESUME is the sole reconciled operational snapshot. The codex/handoffs board ... own worker claims" now names STATUS.md, and the promotion sentence names `main` as the only promotion target (31 Oct ruling) |
| 93 | Specification line 73 "safe pathfinding" against Pat's 30 Oct movement ruling | CURRENT_GAME_SPEC.md:73 | PAT: decision D-06 (open question Q3). The line is unchanged. |
| 94 | Parity ledger line "later par suggestions remain proposals" although route pars were ratified on 27 Oct | V7_TO_GODOT_PARITY.md:59 | Not edited (the ledger is kept as it is). The ratification is in `docs/design/CHALLENGE_PARS_PROPOSAL.md`; that file governs. |

## 7. `docs/CODEX_ENVIRONMENT.md`, `docs/DESKTOP_HANDOFF.md`, `docs/CRITIC_BRIEF.md`, `docs/PAUSE_CHECKPOINT_2026-10-21.md` (scrap) and `docs/TESTING.md`, `docs/PLAYTEST_ANDROID.md` (kept, edited)

| # | Rule | Source | Disposition |
| --- | --- | --- | --- |
| 95 | "Use WSL2 Ubuntu on Windows" | CODEX_ENVIRONMENT.md:10-13; TESTING.md:40; DESKTOP_HANDOFF.md:14-15 | DROPPED: the native Windows scripts in `scripts/toolchain/win/` exist and are what the run used. TESTING.md now says so. |
| 96 | Toolchain requirements, commands, overrides, cache locations | CODEX_ENVIRONMENT.md:15-45 | KEPT, TESTING.md "Environment" |
| 97 | Never run the complete local scenario list; every log needs its strict summary and no errors or leaks | CODEX_ENVIRONMENT.md:30-33; TESTING.md:26-37 | KEPT, TESTING.md and WORKFLOW.md |
| 98 | "No APK builds, Android workflow dispatch or exports" | CODEX_ENVIRONMENT.md:34,54-59; TESTING.md:38; PLAYTEST_ANDROID.md:5-10; DESKTOP_HANDOFF.md:89; docs/decisions/README.md:5 | DROPPED: 1 Nov ruling. Each sentence was replaced by the current rule. |
| 99 | Preserve the development keystore; certificate SHA256; never generate a replacement | CODEX_ENVIRONMENT.md:49-52; DESKTOP_HANDOFF.md:179-180 | KEPT, TESTING.md "Environment", AGENTS.md section 7, `scripts/toolchain/signing/README.md` |
| 100 | Do not change `.github/native-milestone.txt`, push production or main | CODEX_ENVIRONMENT.md:56-57 | KEPT as the branch rules (AGENTS.md section 5); the marker file has no current use |
| 101 | Recreate checkouts from published refs; do not copy caches or credentials | CODEX_ENVIRONMENT.md:63 | KEPT in substance by AGENTS.md section 7 "Keep the tree lean"; the cloud-to-desktop move it served is finished |
| 102 | Godot user-data paths; back up before replacing; do not overwrite progress with fixtures | DESKTOP_HANDOFF.md:173-177 | KEPT, TESTING.md "Environment" |
| 103 | Evidence archive on `archive/cloud-desktop-20261023` | DESKTOP_HANDOFF.md:39,163-168 | KEPT as a pointer, TESTING.md "Environment" |
| 104 | Handoff 023 resume steps, PR96 instructions, "then stop" | DESKTOP_HANDOFF.md:3-6,26-28,65-85 | DROPPED: done (handoff 023 completed) and the stop was lifted |
| 105 | "Every merge contains latest integration; never promote, delete branches; no em dashes" | DESKTOP_HANDOFF.md:87-92 | KEPT: WORKFLOW.md (merge rules, branch rules). "No em dashes" applies to story placeholders by the draft intent card and to documents agents write. |
| 106 | Critics get the running game without builder history; distinct strategies; record routes, time, losses, confusion | CRITIC_BRIEF.md:5-7 | KEPT, `scripts/critic/CRITIC_BRIEF.md` |
| 107 | Compare against reference footage with labels withheld | CRITIC_BRIEF.md:9 | MERGED (row 29) |
| 108 | At milestones keep a cumulative inventory of every material deficiency with evidence, consequence, severity, remedy | CRITIC_BRIEF.md:11 | KEPT, `scripts/critic/CRITIC_BRIEF.md` report format; merged findings are committed as a cold review |
| 109 | Decided, watched and lost questions and the control-mix number in every critic brief (handoffs decision D11) | handoffs DECISIONS.md D11 | KEPT in part: the brief asks decided versus watched and carries the intent card as an unratified lens. The control-mix number needs the developer state, which a blind critic must not enable. |
| 110 | Pause checkpoint rules of 21 Oct: no automatic resume, no direct production pushes, no cleanup pass | PAUSE_CHECKPOINT_2026-10-21.md:18,98,100 | DROPPED: the pause ended (23 and 27 Oct). The story ruling it quotes is in USER_DIRECTIVES. |
| 111 | "Do not fabricate the missing Warning Chain receipt" | PAUSE_CHECKPOINT_2026-10-21.md:91 | KEPT in substance: AGENTS.md section 7 (evidence levels; do not claim what was not observed) |

## 8. Entries in `docs/USER_DIRECTIVES.md` that a later ruling overrides

Nothing in that file was edited apart from one link and a reading note at the top. These rows say which entry governs.

| # | Earlier entry | Source | What governs now |
| --- | --- | --- | --- |
| 112 | No APKs; phone testing only when feature complete (D5, 23 Oct) and repeated in later entries | USER_DIRECTIVES.md:176 and others | Pat, 1 Nov 2026: a debug package may be built when it helps testing, development key only. Pat still decides when he plays. |
| 113 | Milestone promotion PRs go to `gauntlet/production` (26 Oct) | USER_DIRECTIVES.md:149 | Pat, 31 Oct 2026: `main` is the only promotion target; `gauntlet/production` is frozen and kept |
| 114 | Per-feature independent review dropped (26 Oct) | USER_DIRECTIVES.md:147 | Pat, 28 Oct 2026: a separate independent reviewer checks changes before commits and merges ("supersedes earlier entries dropping per-feature review") |
| 115 | Claude launches no subagents; implementation goes to Codex (28 Oct, later) | USER_DIRECTIVES.md:132 | Pat, 31 Oct 2026: Claude may build items directly, one bounded session per item, two alive at most (raised to three on 31 Oct per handoffs decision D32), no fan-outs. A chartered run sets its own limits in its charter. |
| 116 | "Tests only when absolutely necessary" (26 Oct) and the 26 Oct minimum-tests list | USER_DIRECTIVES.md:145-148 | Pat, 31 Oct 2026 minimum-tests ruling; applied as WORKFLOW.md "Tests and CI" |
| 117 | Pauses and stops of 21, 22 and 23 Oct | USER_DIRECTIVES.md:163-189,213-220 | Lifted by Pat on 23, 25 and 27 Oct (same file) |
| 118 | "Sol6.1 Medium with one implementation worker" and Codex model lines | USER_DIRECTIVES.md:132,138,241 | Model routing: section 9 below |
| 119 | "Drop legacy-save compatibility and reject incompatible saves cleanly" | USER_DIRECTIVES.md:254 | Still in force and restated by Pat on 2026-11-11 (save files are minor priority) |

## 9. Model routing lines

The old files named `gpt-6.1-sol`, "Sol6.1 Medium", "Sol6.1 high reviewer" and "never Astra" as defaults for workers and reviewers (AGENTS.md:24,56; AGENT_BRIEF.md:21; GAUNTLET_ORCHESTRATION.md:34; CURRENT_GAME_SPEC.md:5; USER_DIRECTIVES.md:132,138,241; `gauntlet-boundary.py` dispatch default). They were arrangements for sessions in which Codex did the building. Disposition: **DROPPED from the governing file**, which now says that model choice is set per session by Pat or by a run's charter (AGENTS.md section 10). Pat's words about models stay in USER_DIRECTIVES. The dispatch tool's default is unchanged. The open question about a model cap for the orchestrator (Q5 on `claude/workflow-v2`) is listed in decision D-06 and is not answered here.

## 10. Perpetual Gauntlet lines

"The user alone ends the Gauntlet" appears in AGENTS.md:15, README.md:13, START_HERE.md:20, CURRENT_GAME_SPEC.md:12, USER_DIRECTIVES.md:241,247 and V7_TO_GODOT_PARITY.md:61. Disposition: **KEPT** as the policy for Gauntlet runs (AGENTS.md section 9), with one addition: a run that has its own charter stops where its charter says. Whether future work runs as a perpetual Gauntlet or as chartered runs is **PAT**: decision D-05.

## 11. Agent decisions on `codex/handoffs` (`docs/state/DECISIONS.md`, D1 to D37)

These were agent calls that Pat could revert. The ones that are standing rules:

| # | Decision | Disposition |
| --- | --- | --- |
| 120 | D36 minimum local checks (import, core, touched suites, canaries, check-suites; full matrix once in CI; no reruns on the same head) | KEPT, WORKFLOW.md "Tests and CI" (it applies Pat's 31 Oct ruling) |
| 121 | D22 draft PRs run no game CI; D21 shards balanced by duration; D25 suite selection falls back to the full matrix when a serial zone is reached | KEPT: they are how `gauntlet-pr-checks.yml` works today |
| 122 | D20 reverts D10 ("full suite before every push") | KEPT (D10 stays reverted) |
| 123 | D17 one reviewer per PR on the frozen head; cross-provider by default | KEPT as one independent reviewer per change. "Cross-provider" DROPPED: it depended on Codex being available. |
| 124 | D15 only the runner merges, serially; builders never merge | MERGED: the integrator merges (WORKFLOW.md); the queue runner itself is not part of current work |
| 125 | D14 one state folder on `codex/handoffs` replaces the v1 board and the status prose | DROPPED as the home: status is docs/STATUS.md beside the game. D-04 asks Pat whether the branch is retired. |
| 126 | D16 critic sessions capped; stalls classified as harness unless the log shows an error; coverage contract before a verdict counts | KEPT in substance: the critic brief has a command budget and the cold review states coverage before its ranking |
| 127 | D12 evidence caps by change class; D13 area locks; D18 daily digest (pending Q4); D19 phase C script; D23 to D35, D37 queue and item decisions; D1 to D9 package decisions | DROPPED as rules: they governed the queue runner and items that are finished. D18 and the open workflow questions are in decision D-06. D9 (movement) is carried by Pat's 30 Oct ruling. |
| 128 | D3 reference games per piece | KEPT, `scripts/critic/CRITIC_BRIEF.md` |

## 12. Rules of uncertain origin

| # | Rule | Source | Disposition |
| --- | --- | --- | --- |
| 129 | The draft intent card (ten lines on what the player does and what must stay hard) | handoffs RULINGS.md section 1 | PAT: unratified until Pat answers Q3 (decision D-06). Copied verbatim into USER_DIRECTIVES with its UNRATIFIED label and used only as a lens in the critic brief. |
| 130 | "Human test readiness" gate before phone testing | docs/design/HUMAN_TEST_READINESS.md | PAT: decision D-02. The file is unchanged. |
| 131 | Authored sweeper patrol points called "against the PR70 invariant" on the old board while the game ships them | handoffs BOARD.md:134 | PAT: decision D-03. The game is unchanged. |
| 132 | Removal rule of 5 Nov 2026 (nothing is deleted; move to scrap) | Pat's working copy of AGENTS.md, not committed on a shared branch | KEPT verbatim in AGENTS.md section 1 and USER_DIRECTIVES, with its source stated. It matches the run charter's own rule. |
| 133 | Milestone loop line ("Milestone = a complete playable game...") | `AGENTS.md` on `main`, commit a2300840; absent from `claude/integration` | KEPT verbatim in AGENTS.md section 1 |
