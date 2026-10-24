# RESUME: operational entry

**Execution (24 Oct 2026, 8:26 PM Eastern):** the cloud Claude session that orchestrated 23 Oct has been stopped by Pat. Pat's PC is set up again, so the next Claude session runs locally on the PC, not in the cloud. No scheduled check-ins remain from that session. Codex continues on its own protocol (docs/codex/README.md on codex/handoffs).

**Merged on claude/integration (tip b03dd69 at handoff time):** PR77, PR79 (guidance and D1 to D5), PR81, PR83, PR88, PR90, PR91, PR92 (all of 019 ARCH1), PR86 (035 FIX2), PR87 (024 audio), PR89 (D3 photo grade), PR93 (D1 first-Siren cue), PR94 (D2 early Tele lens), PR85 (020 campaign photo rows), PR95 (021 route map). Check live refs for anything newer.

**In flight:** handoff 023 ARCH2 (main.gd and HUD contract) is CLAIMED by Codex in [PR96](https://github.com/pemunson90-cmd/Siren-s-Song/pull/96), first step published, review and exact-head CI pending. Do not touch that branch. Then 025, 026, 027, 029 to 033 in numeric order on docs/codex/BOARD.md (codex/handoffs), which owns claims and statuses.

**Next for Claude (local session on the PC):** (1) fetch claude/integration and codex/handoffs and read the live board and open PRs; (2) when two of 023, 025, 026 are DONE, write the next handoff batch and keep about 5 hours of OPEN work ahead of Codex; (3) re-run a cold review of the whole campaign now that 035, 036, 037, 020 and 021 have landed, and send the ranked fixes to Pat in chat; (4) review Codex PRs for independent approval; (5) no APKs and no promotion to gauntlet/production or main without Pat.

**Decisions waiting on Pat:** none open. Still gated by Pat: SIREN TELL idea, art direction (handoff 032), combat/beam/collision/damage/hull/Siren senses changes, story and ending text, promotion to production or main.

**Stale-doc note:** the GitHub MCP tools and scheduled check-ins used in the cloud session do not exist in a local session unless Pat configures them; use git and the GitHub CLI or web if they are missing.

## CHECKPOINT (kept short; live state is the board and open PRs)
Codex merge hold is LIFTED. Hooks: Pat reinstalls between Codex tasks (python3 scripts/toolchain/install-gauntlet-hooks.py). Pat's rule: phone testing only after the game is feature complete and bug free; no APKs.

Resume command: start Claude Code on claude/integration and say: "Read docs/RESUME.md, then continue the Gauntlet as root orchestrator." Pat is not a developer: plain language, Eastern times, no em dashes, no jargon.

## Authority and first action
Read current USER_DIRECTIVES, then AGENTS for stable execution rules. Intended behavior lives in CURRENT_GAME_SPEC; camera implementation and gaps live in PHOTO_RECON. This file owns the reconciled operational snapshot. Session ledgers retain dated history. CONTINUATION and WORKBENCH are pointers.

Fetch `origin/claude/integration` and `origin/codex/handoffs`, inspect live PR/check state, then reconcile this snapshot. Live refs establish published source; a newer SHA alone does not invalidate a recorded baseline. Check changed substantive instructions and ownership before continuing.

| Branch | Role | Publication |
|---|---|---|
| `claude/integration` | Active development integration | Reviewed feature PRs with required exact-head checks |
| `codex/handoffs` | Codex protocol, queue, claims and completion | Existing claim/completion procedure |
| `gauntlet/production` | Frozen promotion baseline | Pat-authorized coherent promotion |
| `main` | Protected accepted baseline | Pat-authorized tested promotion |

Claude orchestrates; Codex continues its current handoff protocol and may merge only under its handoff/delegation permission. Preserve running claims and other workers' files. Branch retirement remains outside this pass.

## Historical reconciled snapshot: 22 October 2026 evening
Integration baseline: `70894702610ba8499b696af072444c8c942e2476` (PR78). Queue observed at `ab293a7a998f541e61ef226129c552702928c311`. These are reconciliation anchors, not promises to equal the next merge commit.

- Integrated: Iron Choir (PR63), PHOTO1/PHOTO2 (65/67), ONBOARD1 (66), lock warning (68), Priced Shots (69), V7-senses sweeper (70), controls (71), challenges (72), performance (73), DEPTH1/ALL STOP (74), route clearance (75), centralized test registry (76), opening safety/touch FIX1 (78). Completion evidence remains in those PRs and handoffs.
- Codex handoff034 FIX1 is DONE: [PR78](https://github.com/pemunson90-cmd/Siren-s-Song/pull/78) merged at7089470. Exact head9a7180a passed guidance/game-smoke run39889490544. Its Completion records targeted touch/render checks and all191 follow-on suites. Codex then claimed 019 (PR81 in progress).
- Isolated audit repairs: draft [PR77](https://github.com/pemunson90-cmd/Siren-s-Song/pull/77), branch `audit/recon-cargo-fixes-20261022`. Camera-information/identity/lifecycle and physical cargo fixes are proposed; they are not integrated merely because local checks pass.
- Cold Review2 on codex/handoffs is partial: operation1, four dives, software rendering/injected touch, no sound or physical phone. Merged FIX1 addresses its concrete opening findings; the wider campaign review remains owed.
- Architecture019/023, later reconnaissance020, route map021, landmarks025 and final pair/photo-wall027 remain on the existing board, alongside the other authorized lanes. Read live eligibility and claims there instead of copying the queue here.

## Next actions
1. 020,036,037 and all019 steps are merged/DONE. Finish claimed021 route map on claude/lane-route-map with independent review and exact-head guidance/game-smoke.
2. After021 DONE and BOARD are committed together, take eligible023, then025 to027 and029 to033 in numeric order, skipping unmet preconditions.
3. Preserve published source, existing saves and recorded evidence. No APKs or frozen-branch promotion.


## Verification and evidence
Run import, core and affected suites; the full registered matrix runs in GitHub game-smoke. Inventory and local/CI ordering come from `game/tests/suites.txt`, not a copied count here. Reconcile current integration into a proposed code head and obtain exact-head guidance/game-smoke plus attributable independent review before merge. Preserve tests and explain corrected stale fixtures.

No physical-phone or human-play evidence was established in this reconciliation. Synthetic touch/render results, scripted completion, balance, headphone experience and enjoyment remain distinct. Known camera and campaign limitations live in PHOTO_RECON and the existing review/handoff sources. Human play timing never gates authorized development.

GitHub branch protection for active integration is a separate pending administration action: require PRs and existing guidance/game-smoke checks while preserving the authorized merge workflow. No ruleset or promotion permission is changed by this documentation PR.

## Working rules kept from the earlier RESUME (restored 23 Oct)
**Hard rules:** Android touch is primary (48 dp targets, Android Back = Escape, keyboard fallback only). Features are self-contained modules with one narrow seam, numbers in data tables, optional validated save fields, a revert note in the module header. Do not change combat (beam kills Quietus outright after a 4 s lock warning), collision, damage, hull or Siren sight/hearing without Pat. V7 Sirens have no sonar. Story text stays 1 to 2 line placeholders. No APKs. Only Pat promotes to gauntlet/production or main. Delete no branches. Plain language, Eastern times, no em dashes, no jargon for Pat.
**Standing delegation:** build to spec on the plan; ask Pat only for changes to the rules above, story/characters/endings, new design pillars, irreversible things, or an unclear plan.
**Testing:** `export PATH=$HOME/.cache/sirens-song-toolchain/bin:$PATH; scripts/toolchain/install-godot.sh; scripts/toolchain/headless.sh --editor --import --quit`; core suite `scripts/toolchain/headless.sh --script res://tests/run_tests.gd` must end `CHECKS N FAILURES 0`. Never run the full scenario list locally; GitHub game-smoke is the gate. A Godot "resources still in use at exit" line fails CI. Do not commit generated .uid files integration does not track. Merge into claude/integration with a merge commit only when guidance and game-smoke are green on the exact head AND the head contains the current integration tip.
**Decision gates for Pat:** combat, beam, collision, damage, hull or Siren senses beyond approved items; new story text, characters or ending content; the SIREN TELL idea; promotion to production or main; art direction (handoff 032); any new design pillar.
**Claude next builds (one branch and PR each):** (a) the full cold review's top finding; (b) SIREN TELL after the sweeper settles (needs Pat); (c) sweeper lane walking via authored patrol points; (d) a band-guarded subject for the pressure sleeve if DEPTH1's seam proves thin.
**Known caveats:** no human or physical-device play yet; all checks are headless, software-rendered or injected touch. Band, film and all-stop numbers are first-pass. Codex runs only when Pat pastes its prompt (docs/codex/README.md on codex/handoffs). Claude builder agents die when a session ends; their branches survive. Parked WIP branches (do not delete): claude/lane-n1-calder, claude/lane-p2-economy, claude/lane-c2-wip-b, claude/future-siren-active-sonar-sweeper.
