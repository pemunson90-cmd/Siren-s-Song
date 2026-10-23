# RESUME: operational entry

**Execution:** development RESUMED by Pat (23 Oct 2026). Codex034/FIX1 and019 save/cancel steps PR81/PR83 are merged. Pat cleared merges after PR79 and ordered: finish019, then035 (PRIORITY),036,037. Live claims/completion remain on docs/codex/BOARD.md in codex/handoffs.

**019 source checkpoint:** last reconciled integration0df6796 includes PR77 and PR79. This lane extracts only weapons behind the shared order table, preserving behavior. Next: sensors, route/drive, then photo, each as its own reviewed, green PR after its parent merges. Prepared035/020/024 source stays separate. Reconcile the newest integration before each merge; no main/production promotion or APK.

## CHECKPOINT 23 Oct (updated after PR79 and PR80 merged)
Integration holds PR77 (photo and cargo repairs), PR79 (this guidance and Pat's decisions D1 to D5), PR81 and PR83 (ARCH1 steps). PR80 is merged on codex/handoffs. PR82 and PR84 were folded into PR79 and closed. Codex merge hold is LIFTED (Pat tells Codex). Hooks: Pat reinstalls between Codex tasks (python3 scripts/toolchain/install-gauntlet-hooks.py).
Codex queue (docs/codex/BOARD.md): 019 remaining ARCH1 steps, PRIORITY 035 FIX2 (full cold review fixes, save error first; report docs/design/COLD_REVIEW_2_FULL.md), 036 first-Siren cue (D1), 037 early module reward (D2), then 020, 021, 023 to 027, 029 to 033. Pat's rule: phone testing only after the game is feature complete and bug free; no APKs.
D3 photo grade at "Record secured" is in PR (branch claude/grade-on-secure, switch GradeOnSecure.enabled). Next: review Codex PRs, re-run a cold review after 035 lands, and keep 5 hours of OPEN work ahead of Codex (write batch 7 when two of 035, 036, 037 are DONE).
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

## Reconciled snapshot: 22 October 2026 evening
Integration baseline: `70894702610ba8499b696af072444c8c942e2476` (PR78). Queue observed at `ab293a7a998f541e61ef226129c552702928c311`. These are reconciliation anchors, not promises to equal the next merge commit.

- Integrated: Iron Choir (PR63), PHOTO1/PHOTO2 (65/67), ONBOARD1 (66), lock warning (68), Priced Shots (69), V7-senses sweeper (70), controls (71), challenges (72), performance (73), DEPTH1/ALL STOP (74), route clearance (75), centralized test registry (76), opening safety/touch FIX1 (78). Completion evidence remains in those PRs and handoffs.
- Codex handoff034 FIX1 is DONE: [PR78](https://github.com/pemunson90-cmd/Siren-s-Song/pull/78) merged at7089470. Exact head9a7180a passed guidance/game-smoke run39889490544. Its Completion records targeted touch/render checks and all191 follow-on suites. Codex then claimed 019 (PR81 in progress).
- Isolated audit repairs: draft [PR77](https://github.com/pemunson90-cmd/Siren-s-Song/pull/77), branch `audit/recon-cargo-fixes-20261022`. Camera-information/identity/lifecycle and physical cargo fixes are proposed; they are not integrated merely because local checks pass.
- Cold Review2 on codex/handoffs is partial: operation1, four dives, software rendering/injected touch, no sound or physical phone. Merged FIX1 addresses its concrete opening findings; the wider campaign review remains owed.
- Architecture019/023, later reconnaissance020, route map021, landmarks025 and final pair/photo-wall027 remain on the existing board, alongside the other authorized lanes. Read live eligibility and claims there instead of copying the queue here.

## Next actions
1. Complete the authorized repository organization and reconcile the guidance drafts against the completed PR78 and current codex/handoffs. Branch classification and source locations: [REPOSITORY_MAP](REPOSITORY_MAP.md).
2. Preserve queued work and unique branch tips. Pending audit game repairs PR77 stay separate from this organization pass; do not count them as integrated. Review/reconcile them before later architecture work.
3. Development is resumed. 019 is underway in PR81; root reads the board for the next eligible assignment and writes a new batch when two of three handoffs in a batch show DONE. Second cold review (full campaign) is running; its ranked fixes go to Pat in chat. Existing hook copies adopt a reviewed helper only through explicit local reinstallation after integration.


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
