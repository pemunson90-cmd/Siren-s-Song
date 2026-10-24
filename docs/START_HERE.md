> **CURRENT USER ORDER:** read docs/USER_DIRECTIVES.md first. Observe Pat's cloud stop and Windows desktop handover in docs/RESUME.md. The approved full-release program remains the standing plan when Pat resumes work. Preserve accepted Pass0/V7 systems. One implementation worker and one independent integration reviewer; human playtesting never gates authorized development.

# Siren's Song — current project entry

**Gauntlet process:** [AGENTS.md](../AGENTS.md) — canonical orchestration and continuous-improvement instructions.
**Intended game:** [CURRENT_GAME_SPEC.md](CURRENT_GAME_SPEC.md) — living game specification.
**Source precedence and v7:** [SOURCE_AUTHORITY.md](SOURCE_AUTHORITY.md), [V7_TO_GODOT_PARITY.md](V7_TO_GODOT_PARITY.md).
**Active execution:** [RESUME.md](RESUME.md) owns the reconciled operational snapshot. Development integration is `claude/integration`; assignments and claims live on `codex/handoffs`. CONTINUATION and WORKBENCH point there.
**Engine and runtime:** [architecture/GAUNTLET.md](architecture/GAUNTLET.md), [GAUNTLET_ORCHESTRATION.md](GAUNTLET_ORCHESTRATION.md).

The Gauntlet continuously evaluates the whole game, identifies its most consequential weakness/opportunity, makes an improvement, assesses actual player gain, integrates with one reviewer, and repeats. Six missions, passing tests and APK builds are development checkpoints. The ultimate aspiration is AAA-caliber game content and execution, with the user controlling the game's creative identity.

Historical prototype wrappers, original specifications, past audits and validation records are preserved as archival provenance. The executable v7 implementation is a valuable source of already-proven mechanics; it does not impose its historical one-level workflow. Work on dedicated feature branches; root reconciles development integration without restarting completed work.

**Lean repository:** game/source/assets/test/build files and concise instructions stay active. Audit ledgers, external criticism, raw CI evidence, screenshots and video belong in recoverable archives outside active production Git. Consult `AGENTS.md` before creating any new reporting documents.


## Current operational closeout rule

At each closeout, fetch current integration, run `python3 scripts/toolchain/gauntlet-boundary.py --boundary complete`, compare guidance semantically and repair stale active instructions. During authorized development, delegate the next highest-value work. For the current cloud stop, finish PR96 and the requested documentation handover, preserve the partial claim and wait for Pat. [DESKTOP_HANDOFF.md](DESKTOP_HANDOFF.md) gives Windows setup and role-specific recovery notes. Status in archive/provenance documents is historical. `claude/integration` receives reviewed feature PRs; `gauntlet/production` stays frozen pending Pat-authorized promotion, and protected `main` remains the accepted baseline; individual feature branches never skip reconciliation or testing to land directly on main. Only the user determines that the Gauntlet is finished.
