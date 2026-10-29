# Handoff 120: AUDIT 091 FIX 3, FEWER REPEAT STOPS, FASTER RECORDS AND LOADOUTS

Status: QUEUED (claude-lane, Pat 29 Oct)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit, COLD_REVIEW_4, known-items reconciliation) and EXP-PHOTO-INTENT: do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval, Claude's `CLAUDE INTENT: PASS` comment and green required checks on the exact head, merge commit.
Source: the frozen independent 091 critic verdict (read-only, do not edit): `C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\critic-091-13a64ed0\audit\INDEPENDENT_VERDICT.md` and the PNG evidence beside it. Read the named findings in full and open the cited screenshots. Authority: Pat's standing order to fix what the 091 audit finds (HANDOFF section 4 item 3). Layout numbers are AI-DESIGNED.

Protected (never change): beam lethality, the 4 s interruptible lock warning, collision/hull/damage rules, Siren and role senses (silent 180 m, cruise 290 m), the PR70 sweeper, photography design (exposure, grading), ending conditions, art direction. Keep large text and high contrast; removing an accessibility option is never a fix.

## Findings
F4 (repeated chart stops turn exploration into repeated confirmation), F9 (reviewing recent evidence and returning to the branch takes too much navigation), F10 (loadout comparison and retry economics buried in long scrolls), F11 (large hull losses hard to explain afterwards).

## Task
- F4: when new chart sections of the same obstacle appear, emphasise the newly charted edge and offer one direct continue-or-replan choice keeping the retained destination; never automatic travel through unknown water; collision and terrain unchanged.
- F9: direct access to the most recent records and back to the current branch (no traversing 44 unrelated records).
- F10: a compact loadout comparison and retry cost summary on the launch screen.
- F11: an after-the-moment damage explanation (what hit, when, how much) in the debrief.

## Bar
- Native screenshots on both Fold shapes (cover and inner) at 100% and 150% text, before and after, for every screen the findings cite; each finding's 'Expected' line visibly met.
- Full SILENT bare voyages of ops 2, 30 and one late op on STANDARD and ACCESSIBLE: every physical field identical before/after (this is presentation and input work, not a rules change).
- A before/after table per finding: what the player sees or taps, before and after.
- F4: count of repeated stops on the verdict's Beneath the Well Deep route before and after with the same orders.

## Files you may edit
chart/route presentation, records/gallery navigation, launch and debrief panels, their tests, docs, shared registration lines. Not simulation, route physics or economy numbers.

## Checks
Import + Core, affected chart/records/launch suites, one new suite for the repeat-stop replan choice.

## Return
PR into claude/integration with the before/after tables; independent review; wait for CLAUDE INTENT: PASS; merge on green; close the BOARD row and add one LEDGER line.
