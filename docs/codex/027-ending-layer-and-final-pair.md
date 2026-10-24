# Handoff 027: CAMPAIGN M3b, final pair of operations and the photo-wall ending

Status: CLAIMED
Claimed at: 2026-10-24 09:15:18 UTC (5:15 AM Eastern)
Claimed by: codex
Finished at:

Precondition: handoffs 020 and 025 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, and the 22 Oct "Campaign and ending answers" entry). Self-contained modules, one narrow seam, numbers in data tables, optional validated save fields, revert note in each module header. No em dashes. All new text is 1 to 2 line placeholders. Do not change combat, beam, collision, damage, hull or Siren sight/hearing rules.

## Task (plain language)
Pat decided: the true ending moves to after op 25 with a final pair of operations after Iron Choir's core; ops 12 and 13 stay the fork; the ending is an annotated wall of the player's best film first.
1. Read docs/design/DESIGN_CAMPAIGN_DEPTH.md section 4 on branch codex/handoffs. Add two final operations (ids after the current last) as rows in the operation catalog with their own small encounter files, reusing existing systems (photography problems at Siren structures, the depth bands, the new film and trade systems); briefings 1 to 2 lines. They unlock after op 25's recovery and are finishable with bare Quietus. Core jobs finishable bare; bonus photos optional.
2. Add a new module campaign/endings_photo.gd that, after the final pair, selects an ending variant from the existing four endings' conditions plus the player's photo intel keys and the Glass/Iron choice facts, and presents an annotated wall of the player's best archive frames (use the existing archive viewer's frame renderer; captions are the finding names, no new story). Keep the existing ending flow at ops 12 and 13 working as the fork; do not remove any existing ending. If the final pair is not completed, the existing behavior must be unchanged.
3. Old saves load; new save fields are optional and validated; removing the module leaves saves valid.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/ending-m3b

## Files you must not touch
Story text beyond placeholders, combat and detection rules, existing operations' tables (read only).

## What done looks like
Both new ops playable from a fixture, the photo wall shows on a fixture save with several archive frames, existing endings still reachable, tests beside the modules registered in the workflow, CI green.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion

Codex claimed027 at 2026-10-24 09:15:18 UTC (5:15 AM Eastern) from actual integration aaff40e.
Preconditions020 and025 are DONE;026 is DONE in f1d4550 with verified report.
No existing local/remote claude/ending-m3b branch or open duplicate PR found.
The claim is posted before implementation so Claude does not duplicate it.

Read assigned design section4 and the ratified Campaign and ending answers.
The older design question is superseded by Pat's answer: two final operations
with ids after the current last, unlocked after25, then a best-film wall using
existing frame rendering/finding names. Preserve existing four endings and
12/13fork. No new story, characters, combat/sensing rules or art direction;
only mechanical briefing placeholders and existing captions. Film never gates
routes. Existing operations' tables remain read-only. Optional validated state,
old-save compatibility and a clear revert path are required. Plan, fixtures and
independent review follow on claude/ending-m3b; own final-head GitHub gates before
any merge. No code work pushed yet.

WIP 24 Oct, 5:40 AM Eastern: branch claude/ending-m3b pushed at
1b5bc55f22b404bd062072433492b477ff80b7b0; draft PR122:
https://github.com/pemunson90-cmd/Siren-s-Song/pull/122
Core833/0, ending76/0, wall layout/touch38/0 and route map52/0.
Physical-route, rendered inspection, save/revert proof and independent
final-head review remain. Still CLAIMED, not DONE; no merge yet.

24 Oct, 6:02 AM Eastern: current head730d45bafc624fecf8d73590df87f1cb40557902,
baseaaff40e, game tree984e155e2c67e601ad4e3bfc11c9cf8205934f9d.
Import clean; core833, model92, ordinary-command bare journeys10, native GPU
wall42, old endings48, catalog199, route52/UI70 and module-removal/save16,
all zero failures. Both journeys win with actual threats and optional photos
unshot. Wall uses existing shapes and recorded finding captions. Missing-usable
legacy shots now keep the ordinary archive renderer's default semantics.
Removal proof physically removes selector/presenter and loads the save-only
dependency graph; it does not claim full boot with dangling presentation hooks.
Catalog/factory identities stay for active/completed saves. No new save fields.
Raw evidence: archive commitc2022370f0de0185beb9949117f660f982232b01,
evidence/027-windows-20261024 with hashes, logs, source and cover/inner PNGs.
Independent reviewer /root/review_photo APPROVE exact730d45b againstaaff40e,
source/docs/visuals/evidence, no remaining findings; reviewer ran no tests.
Own run40083978483: guidance green, game-smoke running. Fresh runtime critic
is trying actual touch routes. Still CLAIMED; no merge. Await own exact gates,
refresh current integration and mergeability, then merge/verify before done027.

24 Oct, 6:23 AM Eastern: superseding post-critic head is
2fe6459bc7a59f94e46c4ff5d012461e4c6c81ab, game tree
2524e1ee90ad27597f70eed81e3dbbb2f1f69299, base stillaaff40e.
Fresh critic /root/final_pair_critic027 recovered30, lost31 once, then earned
31 and its wall by retry through actual touch. Fork, archive, Android Back
and reopening work. No persistence claim. Process exited0. Developing27%,
low-grade side-on plates limit the subjective photo-similarity observation.
The genuine misleading-label P2 reproduced on both shapes (RED42/2), then
fixed with a guarded research summary: latest import clean, core833/0,
headless UI42/0, GPU UI44/0 and corrected footer captures44/0. Supplemental
photo-capture UI9/0 and photo-study saves45/0. No mission/selector/save changes.
Earlier model/journey/removal proof retains unchanged dependencies.
Independent /root/review_photo APPROVE exact2fe6459 againstaaff40e, no blockers;
source/docs/logs/GPU inspected, no tests run by reviewer. Final raw evidence
and critic report: archive15411eaad95253fcb23651d4d9dce58925d98562,
evidence/027-windows-20261024/final-head-2fe6459, with hashes.
Own current run40085216588: guidance green, game-smoke running at6:17 AM Eastern.
Old730d45b checks and prepared merge7732ffc are superseded. Current prepared
mergea5246131f5fde6caca332d4c986df10a0ad1b69c is local only, not published.
Do not merge until own exact-head gates pass and fresh integration/mergeability
are checked. Still CLAIMED.029 has only been read ahead, not claimed or edited.
