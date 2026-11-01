# Item 146: Entry docs point at the live state

Goal (player): Indirect: a fresh session or critic brief reads the current base, queue and rulings instead of 25 to 30 Oct status, so no work is redone or misdirected.
Why now: RESUME.md, CONTINUATION.md and WORKBENCH.md on claude/integration still name codex/BOARD.md as the queue, a 30 Oct reconciled base (2ef78adf) and root123 as the active audit. D14 moved all status to docs/state/ on codex/handoffs; the 1 Nov overview reconciliation found them stale.
Class: text
Areas: none
Files: docs/RESUME.md, docs/CONTINUATION.md, docs/WORKBENCH.md
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
`git grep -nE 'codex/BOARD.md|2ef78adf|Root123 is|on25October' -- docs/RESUME.md docs/CONTINUATION.md docs/WORKBENCH.md` prints nothing (prints 5+ lines today), and the guidance CI job stays green. Each file says: development integration is claude/integration; main is the protected accepted baseline; gauntlet/production is frozen; the live queue, ownership and next action are docs/state/STATE.md and queue.json on codex/handoffs; Pat's rulings are docs/state/RULINGS.md; critic evidence stays outside the repo. Keep pointers to USER_DIRECTIVES, CURRENT_GAME_SPEC, PHOTO_RECON, MODULES, DESKTOP_HANDOFF and the evidence-level distinctions (implementation, scripted, cold play, device). No status tables, SHAs or dates of work state.

## Do not
Edit any other file, AGENTS.md, USER_DIRECTIVES, the spec or reports/. Delete history; it stays in Git.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
text: the grep before and after.

## Builder notes
Branch item/146-docs-pointers from origin/claude/integration. Preferred provider: claude:sonnet. No Godot run needed: the change is docs only; RED BEFORE is the grep output on origin/claude/integration. If the hand-in gate demands a suites.txt line, say so in PHASE B instead of adding a test.
Checks before push: the minimum (RULINGS.md speed rule).
