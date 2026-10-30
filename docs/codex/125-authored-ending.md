# Handoff 125: AUTHORED ENDING AND VARIED LATE-CAMPAIGN EVIDENCE (091 F7/F8/F14)

Status: QUEUED (claude-lane, Pat 30 Oct)

Precondition: none of the files below claimed by another BOARD row (123 cold audit is read-only); check `git worktree list`.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval, Claude's `CLAUDE INTENT: PASS` comment and green required checks on the exact head, merge commit.
Source: `docs/design/COLD_REVIEW_4.md` (on codex/handoffs) findings F7, F8, F14. Ruling (Pat, 2026-10-30, chat, after Claude asked "Should Codex add an authored campaign ending plus more varied late-campaign evidence (F7/F8/F14), with story lines as 1-2 line AI-designed placeholders you can replace? I recommend yes."): "Yes".

## Task
1. **F7 authored ending:** END OF LINE today closes on an explicitly unfinished placeholder ledger and credits. Replace with an authored closure for each existing ending: what the player's branch choices, recovered evidence and real omissions (for example the unrescued boy) led to, shown as a short consequence ledger. Each line is a 1-2 line AI-DESIGNED placeholder Pat can replace, no em dashes. Remove player-visible "placeholder"/"unfinished" wording from the ledger, credits, manuals and fittings named in F7 (keep creator-facing markers in code comments or docs only).
2. **F8 result wording:** make result and pre-action text say exactly what the action does: Divergence route-to-each versus shelf-only carrier, and Standing Down cutting versus loud prose with no separate CUT. Prose only; do not change which actions exist or what they do.
3. **F14 late-campaign evidence:** late ops (Calder, Gallery, Beneath) repeat machinery work, photo, material and withdrawal. Make late evidence deepen interpretation: each late op's evidence should add a new fact or a new way to read earlier evidence (for example a later photo or sample recontextualising a Gallery or bore finding, shown in the record and the ending ledger). Reuse existing systems (photography, samples, listening, tow, escort); keep existing physical variety.

## Protected (do not change)
Ending conditions (which ending a player reaches and why), Siren senses, lock timing, beam lethality, collision/hull/damage, photography exposure and grading, art direction, campaign branch structure. Story text stays 1-2 line placeholders.

## Bar
- Full SILENT bare voyages of ops 2, 30 and each late op touched (STANDARD and ACCESSIBLE): identical physics before/after (time, Hunt, locks, hull, oxygen, ending reached).
- A table: every ending, its old ledger/credits text versus its new consequence lines; every late op, its evidence before versus after and what new fact it adds.
- Native screenshots of each ending's END OF LINE ledger on both shapes at 100% and 150%, no clipping.
- No player-visible "placeholder" or "unfinished" string left (grep result in the PR).

## Files you may edit
Ending ledger/credits, mission/debrief/record text and late-op evidence data and their tests, docs, shared registration lines.

## Checks
Import + Core, campaign/ending, records, photography/evidence, debrief and presentation suites.

## Return
PR into claude/integration with the tables above; independent review; wait for CLAUDE INTENT: PASS; merge on green; close the BOARD row and add one LEDGER line.
