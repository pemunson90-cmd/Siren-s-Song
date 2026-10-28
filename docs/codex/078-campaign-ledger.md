# Handoff 078: Campaign ledger: expand END OF LINE and the ending into a full account of people, knowledge, infrastructure and disclosure

Status: CLAIMED (root; Archive seam follow-up PR170 pending merge)
Claimed at: 2026-10-28 00:48:49 UTC
Claimed by: codex-root-resume
Finished at: pending Archive seam merge

Precondition: none. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Build a data-driven CAMPAIGN LEDGER with four fixed panels, each row derived only from facts and entitlements the campaign already records (progress.facts, completed, research.projects, photo_intel, economy flags):
1. PEOPLE: Kestrel sailors, Port Ardent watch, Tessaly divers, Hollins last shift, Varne staff and the Choir people, each marked recovered, lost or never found.
2. KNOWLEDGE: artifacts recovered X of 8, plus photo intel and research completed.
3. INFRASTRUCTURE: plant, gates, shutters and ballast states already stored as facts (choir_plant, glass_choice, concealed_consequence).
4. DISCLOSURE: concealed or overt (confluence_route) and the recipient or witness outcome.
Show the ledger on END OF LINE in place of the two lines (keep the two as the first rows) and from VIEW CAMPAIGN ENDING. Add one provisional placeholder line per row of 1 to 2 lines, marked AI-DESIGNED for Pat to rewrite.
Rows for facts that are absent must read 'not recorded', never guessed. Include a compact export of the ledger to the Archive entry that 062 builds if it has landed.

Spec basis: Recovered knowledge, people, infrastructure and disclosure affect later play and four principal ending families. ... Integrate recurring command/local characters, received messages, logs, evidence and visible consequences.
Evidence it is missing: presentation/finale/finale_table.gd LINES shows exactly two provisional facts (choir_choice, choir_plant) when the campaign ends at op 34 (LAST_ID=34). campaign/endings.gd resolve() reads only selected_thread, confluence_route, ops 12 and 13, witness_arrival, warning_arrival and concealed_consequence. campaign/archive_recap.gd summarizes only tutorial-era chapter evidence (blackwater, foundry, well, finale). Nothing at the campaign end lists the people rescued across arcs, the artifacts and research recovered, the infrastructure left running or closed, or the disclosure state. The 062 Archive and 061 Field log are per-region and per-operation lists, not an end-of-campaign account. Gap 4 adds effects on later launches, not the closing account.

Orchestrator note: Claude lane C13. Ledger text is a factual account of saved outcomes in 1 to 2 line placeholders; it does not change which ending family applies (owner question pending).

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/c13-ledger

## Files you may edit
New game/src/campaign/ledger/ledger_table.gd and ledger.gd; new game/src/presentation/ledger/ledger_view.gd; edits to presentation/finale/finale.gd and finale_table.gd (heading()/lines()), presentation/endings_photo_view.gd if it hosts the wall header; a registered test file under game/tests.

## Files you must not touch
Changing endings.resolve() or which ending family a player gets. New story, new names or plot (placeholders only, per spec governance). Reading any state the player has not legitimately earned. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Fixtures for each ending family and for a partially complete campaign (absent facts print 'not recorded'). Old saves with missing optional fields render with no error. Cover and inner viewport render check at 150 percent text. Never more than ORCHESTRATION section 5 requires. Suite ranks: local 560-569, CI 660-669.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

Recovery28Oct04:52UTC: root resumes prior Claude lane with existing uncommitted edits last written27Oct20:51-20:57ET. Preserve and snapshot owned source before updating integration. Bounded worker owns this existing branch; no duplicate lane is active. Current Pat ruling is continuous development within protected design limits.

Closeout: PR167 merged0320f632 after current-head5934a374 guidance/game-smoke green40641512193. Ledger covers saved people, knowledge, infrastructure and disclosure; absent facts remain not recorded. Ending-family resolution unchanged. Archive shortcut deferred to a later small handoff because its screen is already separate.

Completion correction: ending ledger is integrated, but the requested compact Archive presentation remains unfinished. Root retains078 until that seam lands; prior DONE entry described the merged main feature only and is superseded. Follow-up worker owns archive_view ledger summary, no new ending logic.

28 Oct follow-up: PR170 (a5795832) adds the shared four-panel ledger to Archive. Handoff remains CLAIMED until this seam is merged.
