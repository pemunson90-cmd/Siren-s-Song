# Handoff 026: REVIEW1, Codex plays the opening and writes a ranked fix list (read-only)

Status: DONE
Claimed at: 2026-10-24 08:27:47 UTC (4:27 AM Eastern)
Claimed by: codex
Finished at: 2026-10-24 09:10:26 UTC (5:10 AM Eastern)

Precondition: handoff 018 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Do not edit game files. Using the existing real-touch UI test harness and the headless game, play ops 0 to 5 as a first-time player would, using the new camera, film and depth-band photos, the all-stop and the sweeper. Answer in your Completion section, with evidence: Is photography compelling and central compared with Iron Lung? Are the trades readable on a phone-width screen? Can a new player discover solutions? Any softlocks, save problems or error-log spam? Where does a photo or order feel unfair? Also read the five V7 differences in the 012 Completion and say which the opening now answers. Output a ranked fix list (what the player experiences, evidence, severity, remedy) under 800 words. State the limits (software render, injected touch, no audio).

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/(no branch)

## Files you must not touch
Everything in the repo; edit only the Completion section of this file.

## What done looks like
A ranked list Claude and Pat can act on.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion

Fresh critic reviewed aaff40ea7943278ade6ba3b7bcd5495c2dcac26e through injected touch on actual UI, Fold7 cover 2520×1080 and inner 2184×1968, DPI420 fixture, default text scale1.0. Hidden native Godot4.6.3 Compatibility used OpenGL3.3/NVIDIA RTX2080Ti, Dummy audio. This was GPU rendering, not software/headless pixels. No implementation edits.

1. **High: the photographic interface obscures its own decisions.** During paused exposure, camera captions, bottom mission status and craft badges overlap. Cover op4 obscures LIGHT, film and captions; inner op4 collides at the bottom. Evidence: op4-cover-exposure-no-tip.png/state269 and op4-inner-exposure.png/state267. Neither contains a first-use tip or developing inset. op0-record.png additionally has transient hint/developing overlap. Once the camera panel clears, op4-cover-settled-no-tip.png is clean. Remedy: reserve measured space for camera controls/captions, move craft badges and mission text outside it, and keep film, depth cost, shutter radius and quality separately readable throughout exposure and development.

2. **Medium: subject actions can contradict the subject just selected.** After photographing RETURN ARCHIVE, tapping its PHOTO action reports PATTERN ARRAY 619m away instead (states275–276). UNKNOWN HEAT SOURCE/TRANSMITTER offer ROUTE HERE, then reject their marked centers as rock/unsafe clearance (221,329). These are discoverability problems, not demonstrated softlocks. Remedy: name the action's actual target; offer an explicit retake path and reachable approach rather than a misleading center destination. Preserve uncertain-area information.

3. **Medium: recon has a real foundation, but low-information completion can dominate.** Op0's B70% frame resolved beacon/drill details and disclosed LEE CHANNEL. Op1 produced depth-sensitive drone records (DEEP SEAM8%, WEST47%, EAST61%); op4's actual WIDE→TIGHT touch produced a91% array frame. Those are meaningful photographic choices. Yet op5 completed with two very poor frames (12%,10%, average11%), a lost camera drone, and Quietus90% oxygen. Most tension in that successful attempt came from fleet survival and beam management. Remedy: make better observed details offer clear tactical/research advantages and an enticing, immediately inspectable return; retain bare completion rather than introducing a grade gate. Photography is central to the opening's tasks, but compellingness or superiority to Iron Lung is unproved: no direct reference play/footage comparison occurred.

4. **Medium: navigation feedback creates repeated administrative interruption.** Op1 drone stopped for new terrain at successive survey frontiers; replotting advanced it, but required repeated rediscovery of the same destination (states86–114). Op5's route also stopped at unsafe terrain just as the second frame finished, replacing secure feedback (379). Remedy: expose retained destination/replan as one clear touch action, distinguish surveying pauses from blocked endpoints, and retain photo results in a small persistent event history. Do not bypass physical terrain or sensor limits.

The five differences from012: (1) individual lethal locks are confirmed by actual op2/3/4 beam losses; no graze was observed. (2) local pressure displays changed DORMANT/STIRRING, but global-versus-local guard escalation remains untested. (3) vulnerable independent drones are confirmed; actual ALL STOP restores the engines-off contrast, including a separate moving coast test. (4) timed, viewpoint/depth-dependent photography is answered mechanically, with presentation still weak. (5) photos, hydrophone samples, linking and physical return coexist; op5's listening/packet return supported its recon purpose, but the wider campaign/logistics displacement question remains open.

Actual outcomes: op0 won02:19/hull100/O₂37; op1 abandoned unfinished after three records and a rejected drone uplink; ops2–4 lost to beams; op5 won01:28/hull100/O₂90, droneA lost. Coarse stepped intervals and batched failed commands limit death-fairness conclusions. No softlock was demonstrated. Main-play capture mode suppressed disk saves; its apparent reload was invalid evidence and withdrawn. A separate cold-restart save probe preserved position, reserves, route and engines-off state. Save-wiring inspection after main play exposed scripted scenario source; the later save/coast probe makes no fresh-player claim. Native logs contain harness FAIL lines and diagnostic traffic, no observed engine/script errors. No claims cover human enjoyment, audio, physical-phone ergonomics, full save integrity or direct Iron Lung comparison.

Parent validation: native headless import and core831/0 passed on this exact game tree; no full local suite list. Read-only report, no product-code branch or PR. No gameplay source was edited; generated import/UID churn was excluded. Startup/setup and post-play save probes are qualified in the evidence ledger.

Evidence on Pat’s PC: [verified ZIP](<C:/Users/Archi/Documents/Codex/2026-10-23/continue-as-codex-on-the-siren/outputs/026-opening-review-evidence.zip>), 510 members; SHA256 `3ce8969a51741d00e18b93a59171b4c5ab14357b1c9f015bbcc4481f831f5df5`. Raw states, commands, screenshots, save proof, validation logs and manifest are included. Raw source remains in `work/026-review/` outside the checkout.

Publication note: this complete UTF-8 report supersedes the empty file accidentally published in3997b1e. No game source or evidence was changed by that report-writing error.


Evidence preservation,24October2026: the original unedited510-member ZIP is now also published on archive/codex-026-opening-windows-20261024 at3ddcd73d8d00e3e4fe8a2392774377766452e1a8, path evidence/026-windows-20261024/026-opening-review-evidence.zip. Root verified its actual Git-blob bytes/hash against the original56056177-byte ZIP and SHA256 above. This adds remote preservation only, not a new play/test run.
