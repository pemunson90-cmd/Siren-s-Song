# Release reconciliation plan: branches, cleanup, and production

Status: PROPOSAL, 24 Oct 2026 Eastern. AI-DESIGNED by Claude root orchestrator; Pat ratifies each phase. Nothing here runs until the entry condition of its phase is met. Phases 1 and 2 change no existing branch (Phase 2 lands through a normal PR). Phase 3 only creates a new tag, and Phase 4 onward are Pat-gated. Claude creates the release-candidate tag only after Pat says go; Pat creates or authorizes the production and main tags.

## Snapshot (measured 24 Oct, claude/integration at f43a672)

| Fact | Value |
|---|---|
| Remote branches | 197 (111 gauntlet/, 61 claude/, 11 archive/, plus audit, maintenance, checkpoint, docs, codex, main) |
| Integration vs gauntlet/production | integration is 296 commits ahead, production has 0 commits integration lacks |
| Integration vs main | integration is 577 commits ahead; main has 2 commits integration lacks (a230084 docs, 6d27f72 merge of PR5) |
| Branches already merged into integration (git ancestry) | 128 (74 gauntlet/, 46 claude/, 3 archive/, 2 audit/, 1 checkpoint, 1 ccr) |
| Branches not merged by ancestry | 69, but several are likely squashed or re-landed through integration branches and need a content check |
| Open PRs | 99, 100, 101, 102 (Codex ARCH2 and Windows hooks) |

Rules that stay in force the whole time: no branch or file deletion by Claude or Codex (Pat deletes), no force-push, no promotion without Pat, parked WIP branches preserved (claude/lane-n1-calder, claude/lane-p2-economy, claude/lane-c2-wip-b, claude/future-siren-active-sonar-sweeper), archive/ branches preserved.

## Phase 1: classify every branch (read-only, Claude, any time)

Produce docs/repository/BRANCH_LEDGER_YYYYMMDD.md with one row per remote branch: tip SHA and date, ahead/behind integration, state, and a recommended disposition.
States: MERGED (ancestor of integration); CONTENT-LANDED (not an ancestor, but its diff is already present on integration, checked by patch-id or tree comparison of its owned files); OPEN-PR; ACTIVE-LANE (a claim on the board); PARKED (see rules above); ARCHIVE; STALE-UNIQUE (has commits with content nowhere on integration). Every STALE-UNIQUE branch gets a one-line note on what is unique and whether it matters.
Done when: ledger committed through a docs PR and the counts add up to 197.

## Phase 2: reconcile main (Claude proposes, Pat merges decisions)

main has 2 commits integration lacks. Inspect them; if content only, merge main into integration through a normal PR (merge commit, so history is preserved) so integration contains everything main has. Do not move main itself in this phase.
Done when: git rev-list integration..main is empty.

## Phase 3: release candidate and acceptance (no promotion yet)

Cut a release-candidate tag on integration (a lightweight tag, no branch move) once the entry conditions hold:
1. Codex queue through the finale and save work (023, 038 to 045 as ratified) is DONE or deliberately deferred by Pat.
2. Full hosted matrix green on the exact RC head and the core suite at the documented count with 0 failures.
3. A fresh cold review (like COLD_REVIEW_3) against the RC with no blockers open.
4. Pat's decisions closed: ending at op 30, SIREN TELL, art direction 032, 049 cue extension.
5. Phone testing is Pat's call and happens only when the game is feature complete and bug free; no APKs before then.
Claude writes the RC acceptance report at docs/repository/RC_ACCEPTANCE_YYYYMMDD.md listing evidence and known gaps (no human or physical-device play counts as a gap until Pat says otherwise).

## Phase 4: promotion to gauntlet/production (Pat authorizes)

Because production has nothing integration lacks, promotion is a fast-forward to the RC tag. Steps: Pat says go; Claude opens a promotion PR integration to gauntlet/production if branch rules require a PR, otherwise a fast-forward push by Pat; both hosted checks green on the exact head; production tag created. Rollback is moving the branch pointer back to the previous tag (ca4735e is today's production), so record that SHA in the promotion note.

## Phase 5: main (Pat authorizes separately)

main is the protected accepted baseline. After Phase 2, and only when production has soaked, promote main to the same RC by fast-forward or merge, with Pat's explicit go. Rollback the same way, recording the previous main SHA (a230084 today).

## Phase 6: branch cleanup (Pat executes)

Claude never deletes. From the Phase 1 ledger Claude prepares a deletion manifest, safest first:
1. MERGED and CONTENT-LANDED branches with no open PR and no claim (about 128 plus whatever content check adds).
2. Superseded checkpoints and audit branches, after Pat confirms the evidence archive (archive/cloud-desktop-20261023 and archive/ branches) is kept.
Never on the manifest: archive/, parked WIP, codex/handoffs, claude/integration, gauntlet/production, main, any branch with an open PR or a board claim, any STALE-UNIQUE branch without a Pat decision.
The manifest is a plain list with a copyable command block Pat can run in batches (for example git push origin --delete for each name), so every deletion is Pat's action and is reversible while the SHA is recorded in the ledger (a deleted branch can be recreated from its tip SHA).
Done when: remote branch count matches the manifest minus deletions and the ledger is updated.

## Phase 7: repo tidy (docs and structure, Claude, additive)

Refresh docs/REPOSITORY_MAP.md and docs/repository/ for the final layout; retire stale pointers in CONTINUATION and WORKBENCH by marking them historical (strike-through in place, nothing removed); update README and RESUME; record the release tag, previous production and main SHAs, and the Windows and Android build notes in docs/repository/RELEASE_NOTES.md.

## Open questions for Pat (answer when convenient; none block Phase 1 or 2)
1. Should main and gauntlet/production end up at the same commit, or keep production slightly behind as a soak stage?
2. Is a version tag name preferred (for example v0.9-rc1)?
3. After cleanup, keep archive/ branches indefinitely or move them into tags?

## Order of work now
Phase 1 first (ledger), Phase 2 inspection next, both read-only or docs-only. Codex continues the handoff queue in parallel; the plan changes no files Codex owns.
