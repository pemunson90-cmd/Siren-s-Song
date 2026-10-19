# Siren's Song — current project entry

**Gauntlet process:** [AGENTS.md](../AGENTS.md) — canonical orchestration and continuous-improvement instructions.
**Intended game:** [CURRENT_GAME_SPEC.md](CURRENT_GAME_SPEC.md) — living game specification.
**Source precedence and v7:** [SOURCE_AUTHORITY.md](SOURCE_AUTHORITY.md), [V7_TO_GODOT_PARITY.md](V7_TO_GODOT_PARITY.md).
**Active execution:** [CONTINUATION.md](CONTINUATION.md) — integrated baseline, ownership, exact next task; [WORKBENCH.md](WORKBENCH.md) — player-facing status.
**Engine and runtime:** [architecture/GAUNTLET.md](architecture/GAUNTLET.md), [GAUNTLET_ORCHESTRATION.md](GAUNTLET_ORCHESTRATION.md).

The Gauntlet continuously evaluates the whole game, identifies its most consequential weakness/opportunity, makes an improvement, assesses actual player gain, integrates with one reviewer, and repeats. Six missions, passing tests and APK builds are development checkpoints. The ultimate aspiration is AAA-caliber game content and execution, with the user controlling the game's creative identity.

Historical prototype wrappers, original specifications, past audits and validation records are preserved as archival provenance. The executable v7 implementation is a valuable source of already-proven mechanics; it does not impose its historical one-level workflow. Work on dedicated feature branches; root reconciles production without restarting completed work.

**Lean repository:** game/source/assets/test/build files and concise instructions stay active. Audit ledgers, external criticism, raw CI evidence, screenshots and video belong in recoverable archives outside active production Git. Consult `AGENTS.md` before creating any new reporting documents.


## Current operational closeout rule

Every completed worker/review/merge task causes the orchestrator to fetch current production, run `python3 scripts/toolchain/gauntlet-boundary.py --boundary complete`, perform the semantic staleness comparison, repair obsolete active handoffs on a reviewed branch and delegate the next highest-value work. Status in archive/provenance documents is historical. `main` receives coherent tested promotions from the continuously reviewed `gauntlet/production` line; individual feature branches never skip reconciliation or testing to land directly on main. Only the user determines that the Gauntlet is finished.
