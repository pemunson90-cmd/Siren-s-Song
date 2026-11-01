# RESUME: operational entry

Read [USER_DIRECTIVES.md](USER_DIRECTIVES.md) first. Current user rulings override historical plans. [CURRENT_GAME_SPEC.md](CURRENT_GAME_SPEC.md) owns intended behavior; [PHOTO_RECON.md](PHOTO_RECON.md) owns photographic capabilities and gaps. Military photographic reconnaissance remains the primary pillar.

## Where the live state is

Branches: development integration is `claude/integration`; `main` is the protected accepted baseline; `gauntlet/production` is frozen. Feature PRs target integration; Pat authorizes promotion. Fetch `claude/integration` for the live tip.
The live queue, ownership and next action are `docs/state/STATE.md` and `docs/state/queue.json` on `codex/handoffs`. Pat's rulings, newest last, are `docs/state/RULINGS.md` on the same branch. Fetch those refs at execution boundaries and preserve other workers' claims.
Critic evidence (blind audit briefs, raw reports, captures, profiles) stays outside the repo in the external toolchain artifact cache. Audit findings and reconciliations live on `codex/handoffs` under `docs/design/`.
Keep evidence levels distinct: implementation, scripted verification, cold play and physical-device observation. Passing CI does not establish human enjoyment, audio perception, phone ergonomics or Android performance.

## Execution and verification

Use Godot4.6.3 / GDScript / Compatibility. Independent separate review precedes every new commit and merge; root verifies unchanged approved bytes or exact head/parents. Merge only reviewed current heads with their required hosted checks passed. Use focused local checks; batch broad regression at meaningful milestones. Do not loosen assertions or timeouts.
No Android APK builds or physical-phone acceptance claims. Preserve existing profiles, saves, other workers' edits, recovery refs and the Git-tracked development signer under scripts/toolchain/signing/. No force push or branch deletion.
Run scripts/toolchain/gauntlet-boundary.py at required boundaries and apply changed guidance semantically; a structural pass is not proof of current ownership or game quality. Follow docs/GAUNTLET_ORCHESTRATION.md and docs/DESKTOP_HANDOFF.md for execution/recovery.
Only Pat's stop or actual execution/usage exhaustion interrupts authorized work. On exhaustion checkpoint exact SHA, branches, owners, evidence and first resumption command as PAUSED — RESUME REQUIRED; do not claim invisible execution after a session ends.

Module seams and safe reverts: [MODULES.md](MODULES.md). Prior feature tables, repair attempts and dated notes remain recoverable in Git history, USER_DIRECTIVES and the handoffs ledger. CONTINUATION and WORKBENCH remain short links, not duplicate queues.
