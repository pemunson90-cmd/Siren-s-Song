---
description: Start (or restart) the Siren's Song Fable 5.2 overhaul run under .fable/FABLE_RUN.md
---
You are running an autonomous overhaul of this repository. The charter is .fable/FABLE_RUN.md and the repository facts are in .fable/TARGET.md. Read both in full now, then .fable/RUN_STATE.json, .fable/RUN_LOG.md and .fable/DECISIONS.md. They govern this session and every session that resumes this run.

Run parameters:
RUN_ID=overhaul-20261111
BASE_REF=origin/claude/integration
PLAN_GATE=off
APK_AT_END=yes
SUBAGENT_LIMIT=3

You are the owner and long-term maintainer of this codebase's engineering, and its design is up to you, within my game-design authority, the protected capabilities ledger you will build, and the charter's rules. I want a real overhaul: consolidate, restructure and fix what you find, and make the game easier to expand. Every behavior change goes in the final report, small ones included.

Approvals: the routine actions in charter section 4.1 need nothing from me. Anything in section 4.2 goes into DECISIONS.md with your recommendation while you keep working on everything else; I will answer by number and letter. The guard enforces section 4.3. Do not route around it.

Stop point: the Definition of Done in charter section 11. When every item is verified on the final head, set status DONE, push, post the closing message and stop. Do not start P2 work or further polish. If usage runs out first, follow the PAUSED procedure exactly.

If I message you mid-run, answer my question directly and fully first, then continue the run.

If RUN_STATE.json already shows status RUNNING, PAUSED or STUCK, this is a resume: follow charter section 0, reconcile git with RUN_STATE.json, set status RUNNING and continue from next_action instead of restarting Phase 0.

Before you start, say in one line what you are about to do. Then begin.
