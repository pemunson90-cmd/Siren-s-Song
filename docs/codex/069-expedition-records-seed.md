# Handoff 069: EXPEDITION RUN SUMMARY, RECORDS AND SEED ENTRY

Status: DONE
Claimed at: 
Claimed by: 
Finished at: 2026-10-28T22:42:43Z

Precondition: 056 is DONE. Scout note: 056 DONE. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Add three things on top of the 056 run. First, a run-end screen for both loss and full clear. It shows seed, operations cleared, modifiers, resources spent and gained, and best-photo grade per operation. Second, a records list: best cleared depth and the last 10 runs with their seeds, in a bounded, validated sidecar field (follow the challenge_records bounds-and-corrupt-reject pattern). Third, a seed field on the expedition start screen. It offers a random seed, a typed or paste seed, and 'replay this seed' from a past run. The seed text must be capped and sanitized. Same seed plus same modifiers must always produce the same sequence (test it).

Spec basis: CURRENT_GAME_SPEC.md: "seeded roguelite expeditions of 3-6 operations"; "Complete title/menu, Continue/mode selection, profiles, fitting/research/archive".
Evidence it is missing: Challenges have a records module (campaign/challenges/challenge_records.gd, validated in save_store.gd) and a results flow. 056 specifies a seeded run and a sidecar archive but no run-end summary, no history or best records, and no way to type or copy a seed. Without these a seed cannot be shared or replayed on purpose.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-run-records

## Files you may edit
New campaign/runs/run_records.gd; presentation/runs/run_summary_view.gd and seed_entry.gd; sidecar validator in persistence/profiles/* file sets. Tests: new run_records_tests (round trip, bounds, corrupt reject, seed determinism).

## Files you must not touch
 Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
Run summaries, bounded records and seed replay integrated; records/run ownership released to root070.
Accepted through PR207 head951f8e00, merge152111a1; independent source44/doc-base46, exact treea0db916ed060db16b3da2a920e19647f8b44016b.
All seven current required checks SUCCESS, run40775745180; integrated-batch gate, not standalone task gates. Source-known; no physical-phone claim.
