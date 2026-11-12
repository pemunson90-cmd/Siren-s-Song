# Scrap manifest: 2026-11-11 overhaul run

Files retired by the overhaul run `overhaul-20261111`. Nothing was deleted: each file was moved here with `git mv` at the same relative path, so `git log --follow` still shows its history. To restore one, move it back.

Reasons follow the run charter: **Carried** means every live statement now exists in a living document (named in the last column). **Historical** means a dated checkpoint or handoff whose content is in git history and which no living document depends on. The rule-by-rule account is in [docs/GOVERNANCE_MIGRATION.md](../docs/GOVERNANCE_MIGRATION.md).

| Original path | Last commit | Reason | Where its live content now lives |
| --- | --- | --- | --- |
| `docs/START_HERE.md` | 2026-10-24 | Carried | `README.md` (entry and document table), `AGENTS.md` sections 7 to 9 |
| `docs/RESUME.md` | 2026-11-01 | Carried | `docs/STATUS.md` (status), `docs/WORKFLOW.md` (review, tests, packages), `AGENTS.md` section 9 (pause rule) |
| `docs/CONTINUATION.md` | 2026-11-01 | Carried | `docs/STATUS.md`; its pointers are the table in `AGENTS.md` section 6 |
| `docs/WORKBENCH.md` | 2026-11-01 | Carried | `docs/STATUS.md`; closeout rule in `AGENTS.md` section 8 |
| `docs/AGENT_BRIEF.md` | 2026-10-24 | Carried | `AGENTS.md` section 7 (brief contents, reviewer, critic), `docs/WORKFLOW.md` "Review and merge" |
| `docs/GAUNTLET_ORCHESTRATION.md` | 2026-10-24 | Carried | `docs/WORKFLOW.md` "Tools" and "Android packages"; tool behavior is in `scripts/toolchain/gauntlet-boundary.py`, `install-gauntlet-hooks.py` and their tests |
| `docs/CODEX_ENVIRONMENT.md` | 2026-10-24 | Carried | `docs/TESTING.md` "Environment" |
| `docs/CRITIC_BRIEF.md` | 2026-10-24 | Carried | `scripts/critic/CRITIC_BRIEF.md` |
| `docs/DESKTOP_HANDOFF.md` | 2026-10-24 | Historical | The 23 Oct cloud-to-Windows handover is finished. Carried first: user-data paths, the evidence archive pointer and the key rule, into `docs/TESTING.md` "Environment". |
| `docs/design/HUMAN_TEST_READINESS.md` | 2026-10-24 | Pat's decision D-02 A (2026-11-12) | Nowhere: the gate was never ratified, and Pat's 1 November package ruling and this run's playtest overtook it |
| `docs/design/AUTHORED_ENDING_125.md` | 2026-10-30 | Pat's decision D-02 A (2026-11-12) | The ending copy lives in the game source (`game/src/campaign/endings.gd`) |
| `docs/PAUSE_CHECKPOINT_2026-10-21.md` | 2026-10-20 | Historical | The 21 Oct pause ended. The story ruling it quotes is in `docs/USER_DIRECTIVES.md`, which links here. |

Also in this folder, as copies and not moves: `AGENTS.md`, `CLAUDE.md` and `README.md` hold the text of those three files as it stood on `claude/integration` at `cabd5bd5`, before they were rewritten in place. The files themselves stay at the repository root.

Kept in place by Pat's decision D-02 A (2026-11-12): `docs/design/STEALTH_AI_ROADMAP.md` (still feeds the backlog) and `reports/2026-11-01-sirens-song-full-project-overview.md`.
