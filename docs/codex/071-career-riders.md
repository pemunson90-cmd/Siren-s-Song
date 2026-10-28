# Handoff 071: Career and expedition riders: optional contract conditions with bonus pay

Status: CLAIMED
Claimed at: 2026-10-28 (exact time not supplied)
Claimed by: codex-root; branch claude/lane-career-riders-complete, worker49768; preserved career slice ported to current offers integration; full expedition hook in progress, NOT DONE.
Finished at:

Precondition: 057 is DONE. Scout note: 057 DONE (contract board); 055 DONE (it changes FINITE_TOOLS in challenge_rules.gd, which this gap reads). Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Add a rider table. A rider is an optional, announced, per-contract condition drawn from the existing ChallengeRules set (for example no charges, middle water only, every craft home), with an extra payout in scrap, cells or alloy, or a faction-standing bonus. The contract board and the briefing show the rider in one plain line. The simulation subclass for career and expedition dives enforces rider failure using the same Rules.before and Rules.status calls that ChallengeRun uses, but it never blocks completing the base contract. A failed rider simply forfeits the bonus. No new enemy rules or senses. Riders must be drawn per contract by seed, with an enabled switch.

Spec basis: CURRENT_GAME_SPEC.md: "persistent regional naval career with contracts, fleet development, research and faction consequences"; "difficulties should progress chiefly through learnable tactical complexity and consequences".
Evidence it is missing: 057 draws contracts 'from existing operations with rewards'. The player already knows every operation by then (41 ids registered in operation_catalog.gd, 12 challenge rows replaying them). The repo already has a tested rule library (campaign/challenges/challenge_rules.gd and challenge_catalog.gd RULES: no_sonar, no_tools, quiet_propulsion, hull_intact, no_losses, middle_only, one_tool, time_limit) that only the 12 fixed challenges use. Neither 056 nor 057 reuses it for career contracts or expedition run modifiers.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-career-riders

## Files you may edit
New campaign/career/riders.gd and rider_table.gd; a small mode-dive subclass in presentation/career/ that reuses challenge_run's policy hook; read-only use of campaign/challenges/challenge_rules.gd. Tests: new rider_tests (each rider pass and fail, bonus applied once, base reward unaffected).

## Files you must not touch
 Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
