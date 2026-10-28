# Handoff 057: C4 NAVAL CAREER

Status: DONE
Claimed at: 2026-10-28 (UTC; exact claim time not retained here)
Claimed by: codex-root; worker34488; branch claude/c4-career; New career, mode entry and persistence.
Finished at: 2026-10-28 (date supplied; exact time not recorded)

Precondition: 056 is DONE. Read ORCHESTRATION_2026-10-26.md first. Claude's session hit its usage limit on 26 Oct; this lane transfers to Codex, and while you hold this claim you own the files listed here.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Persistent regional naval career mode: contracts drawn from existing operations with rewards in the economy's resources; three or four factions from docs/STORY_BIBLE_DRAFT.md (Brannock command, Hollins Field crews, Varne range, local mariners) whose standing changes with contract outcomes and opens or closes contracts; fleet development through the economy and research. Separate sidecar state; enable its mode-select entry. Placeholder text only.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/c4-career

## Files you may edit
New campaign/career/* and presentation/career/*, the mode-select entry, persistence file sets; shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design, story beyond 1 to 2 line placeholders. Files owned by any other CLAIMED handoff.

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Suite ranks: local 380-389, CI 480-489.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
[PAT: 28 Oct 2026 closeout facts] PR190 head `6e92643363aa6f2e02c42f914933e20fd1ff3c62`; independent reviews17A/19C/22; merged `2bfbfc1c688dd0eff48e9f888caf78861f6592c5`.
All seven own-head checks green: [CI job](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/40727569975/job/122954850748).
CLEAN sequential merge under review22 carry conditions; byte identity verified.
12 contracts / 4 factions; isolated career state; rewards, research and fittings.
Career `_notification` and quality methods coexist.
