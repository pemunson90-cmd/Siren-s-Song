# Handoff 121: AUDIT 091 FIX 4, PHOTOS THAT SHOW WHAT YOU FOUND

Status: QUEUED (claude-lane, Pat 29 Oct)

Precondition: none of the files below claimed by another BOARD row (120 owns records/gallery navigation; touch only image content); check `git worktree list`. Root owns 091 and EXP-PHOTO-INTENT: do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval, Claude's `CLAUDE INTENT: PASS` comment and green required checks on the exact head, merge commit.
Ruling (Pat, 2026-10-29T18:48:40-0400, widget): "Can Codex draw new photo images that clearly show each subject (the people, the bore, the damage) in the game's current art style, without changing how exposure or photo grades work? This touches art direction, which is your call." = "Yes (Recommended)". Copy it verbatim into docs/USER_DIRECTIVES.md. Compositions are AI-DESIGNED placeholders Pat can replace.
Source: the frozen 091 verdict `C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\critic-091-13a64ed0\audit\INDEPENDENT_VERDICT.md`, finding F1 (and F15), with the cited PNGs (1320, 1321, 1313, 1435; strengths 784, 1090, 1281, 1390).

## Task
Author subject-specific photo record images: people, structures, machinery, damage and occlusion that the player can see and interpret, in the existing palette and style (match the detailed work illustrations in 1281/1390). Better technique (resolution, light, aspect) reveals more visible detail in the image itself, connected to a short precise interpretation line (1 to 2 lines, no em dashes). Start with Drillers and Guards at the Glass and Human Bore Through Siren Foundation, then every required-photo subject in the campaign.

Protected (never change): exposure duration, photo grading and quality math, what counts as captured, sensing, lethal pressure, ending conditions. This is image content and its interpretation text only.

## Bar
- Before/after native screenshots, both Fold shapes, of the full archived record for every required-photo subject; a table: subject, what the image showed before, what it shows after.
- Grade/quality numbers identical before/after for the same shots (prove no grading change).
- Two technique contrasts (for example WIDE vs settled TIGHT at Needle Strait) where the better shot visibly shows more.
- Full SILENT bare voyages of ops 2 and 30 identical before/after.

## Files you may edit
photo record image generation/composition and subject art, interpretation text, their tests, docs, shared registration lines. Not mission_hud.gd photo functions, grading, gallery navigation or simulation.

## Checks
Import + Core, photo/record suites, one new suite asserting every required subject has a distinct composition and unchanged grading.

## Return
PR into claude/integration with the before/after tables; independent review; wait for CLAUDE INTENT: PASS; merge on green; close the BOARD row and add one LEDGER line.
