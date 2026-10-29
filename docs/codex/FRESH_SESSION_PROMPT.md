# Fresh Codex session prompt (Claude lane template)

Claude fills the angle-bracket fields and saves the result as a scratch prompt file, then launches it per HANDOFF.md section 7. One handoff per session, one worktree per session.

```
You are a fresh Codex session for Siren's Song, launched by Claude (orchestrator) in the CLAUDE LANE for ONE bounded task: handoff <NNN> "<title>". Pat ruled (28 Oct ~20:00 ET, "Op 2") that Claude-lane sessions own their work end to end, including merging. Codex root owns only codex-root rows; do not touch its claims, branches or worktrees. Ignore modified *.import and *.uid files; never commit them.

Your workspace is the worktree on branch <branch>, based on origin/claude/integration. Read, in order (git fetch origin first):
1. git show origin/codex/handoffs:docs/codex/<NNN-file>.md   (your task, binding)
2. <extra reads, e.g. a PR's comments, a design report, a review that blocked an earlier attempt>
3. git show origin/codex/handoffs:docs/codex/HANDOFF.md   (rules, acceptance bars, Godot how-to, git identity)
Set MSYS_NO_PATHCONV=1 if a path starts with a dot.

Process:
- Orchestrate at Sol6.1 medium. Implementation subagents use the weakest capable model; never Astra.
- Before any commit, get an independent Sol6.1-high review of the frozen patch from a reviewer that did not write it. Findings go back for a bounded fix; re-review changed lines. Record the approval (reviewer, reviewed tree or SHA) in the PR body.
- Godot checks isolated: ARTIFACT_DIR=C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\<NNN> and UserDataRoot C:\Users\Archi\.cache\sirens-song-toolchain\isolated-<NNN>. Run <checks>. Never the full suite list locally.
- Git identity user.email 272409536+pemunson90-cmd@users.noreply.github.com. Push the branch, open the PR into claude/integration with a before/after table. Merge (merge commit) only after independent approval and green required checks on the exact head. If integration moves, merge it in, re-verify, and re-review conflict resolutions. Re-fetch before each push; if another lane changed the PR, stop and say so on the BOARD row.
- Use the next free suite ranks; insert registry lines next to related rows.
- When merged: in a scratch worktree of origin/codex/handoffs set the BOARD row "| <row> | <NNN>" to DONE with a one-line result, append one LEDGER.md line and a short banner line for Claude; push (on rejection fetch, rebase your one commit, push).
- Never change Siren senses, lock timing, beam, collision, damage or hull rules. No em dashes. No APK, force push, amend of pushed commits or branch deletion. If blocked, write BLOCKED with the reason and numbers on the BOARD row and stop.
<task-specific warnings, e.g. "measure bare in SILENT throughout">
Finish with a five-line summary on stdout.
```
