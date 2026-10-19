# Siren's Song — worker and reviewer brief

Every worker reads the latest `AGENTS.md`, `docs/CURRENT_GAME_SPEC.md`, `docs/SOURCE_AUTHORITY.md`, `docs/V7_TO_GODOT_PARITY.md` and `docs/CONTINUATION.md` from the current production tip before acting. The user has authorized autonomous, continuous game improvement. Each individual assignment contributes to the orchestrator's ongoing **whole-game evaluation → largest opportunity → improvement → reassessment** loop.

**Implementer assignment:** name the dedicated branch/worktree, owned files, baseline source SHA, precise player-facing result, existing applicable v7/production references, interfaces and narrowly relevant tests. Research/reuse where suitable, deliver functioning coherent game changes, and tell the integrator what actually improved, broke or remains uncertain. Preserve other workers' changes. Store extensive captures and reports in a recoverable archive outside active production Git.

**Integration reviewer:** one reviewer examines the actual diff against latest production, interactions with other branches, relevant mechanics and user intent, save/source fidelity, and focused regressions. Provide approval or reproducible corrections. No automatic second critic, external reference footage comparison, APK, exhaustive screenshots or evidence dossier for an ordinary merge. Distinct high risks justify focused additional review.

**Whole-game experience critic:** a separately commissioned, periodic quality assessment, not the default merge reviewer. Inspect the playable experience across tactics, depth, mission differentiation, storytelling, audiovisual quality and intuitive mobile controls. Compare with the strongest prior experience and useful shipped-game examples; identify the most important next improvement. Use `docs/CRITIC_BRIEF.md` when appropriate.

Substantial work defaults to `gpt-6.1-sol` with fresh context when selectable. Smaller fit-for-purpose workers are allowed; premium escalation requires exceptional reasoning. Root alone integrates/pushes production. Finishing a bounded worker task releases that scope; the orchestrator proceeds to the next highest-value game improvement.
