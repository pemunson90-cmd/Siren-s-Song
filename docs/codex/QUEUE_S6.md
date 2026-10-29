# Claude-lane queue (Claude S6, 29 Oct 2026 11:30 ET)

Run by one long-lived Codex **queue runner** session that Claude launched before a context clear. The runner works this queue so Codex never idles while Claude is cleared. It obeys every rule in HANDOFF.md and FRESH_SESSION_PROMPT.md. Rulings: PAT_RULINGS_2026-10-29.md.

## Already running when the runner starts (do not touch; wait for them)
- **103b** role senses, PR216 (draft until its contrast bar is met), fresh session pid 52948.
- **110** advanced economy and easier preset, PR217, fresh session pid 2880.
A row is free only when BOARD shows it DONE or BLOCKED. Merged is not enough: wait for the closeout.

## Queue, in order
Two chains run side by side, at most one item per chain at a time.

**Chain S (Siren senses, strictly one at a time, each after the previous row is DONE):**
1. 103b (already running) -> 2. **105** thermal layer one band -> 3. **104** Siren reports -> 4. **106** sonar rough type.

**Chain C (everything else, one at a time):**
1. 110 (already running) -> 2. **112** Sorley pilotage charts -> 2b. **114** foundation cleanup (Claude S7, 29 Oct; see 114-foundation-cleanup.md; behaviour-preserving bar, an identical voyage table IS the pass except op 41) -> 3. **109** seeds shuffle Siren starts and timing -> 4. **108** arc 5 second fork -> 5. **111** auto-pause and mirrored HUD (root released HUD ownership 29 Oct) -> 6. **113** presentation pass.

If an item blocks, write BLOCKED with numbers on its row, skip to the next item in the same chain, and list the block in the runner's banner line.

## Intent bar (Claude's check, the runner applies it before any merge)
- Read the PR's before/after table, not the summary.
- A Siren-behaviour item (103, 104, 105, 109, 108) must show the ruled behaviour changes play: at least two ops where the best plan or the outcome differs because of the change. A table identical before and after everywhere is NOT done (that is why 103 was held).
- Bare (Quietus SILENT throughout) stays finishable on ACCESSIBLE and STANDARD. No op that met the Sirens in 094 to 097 may stop meeting them. Equipped stays clearly better.
- Protected rules beyond the named change stay untouched: sight 180/290 m, 4 s lock warning, beam, collision, damage, hull, V7 sweeper shape, photography, endings.
- If a PR fails this bar, hold it as draft with a comment naming the missing evidence, then relaunch the item once with that bar. Only after a second failure, mark it BLOCKED.

## Do not
Launch Claude subagents; touch root rows (091 audit, EXP-PHOTO-INTENT) or root worktrees; ask Pat anything (Claude asks Pat); build an APK; force-push, amend pushed commits or delete branches.
