# Branch ledger, 24 October 2026

Phase 1 of docs/RELEASE_RECONCILIATION_PLAN.md (PR #105). Read-only inventory. AI-DESIGNED, Pat to ratify. Nothing was deleted, force-pushed or modified.

Snapshot: `git fetch origin --prune` on 2026-10-24; integration tip `f43a672`. Ahead/behind are commit counts of `origin/<branch>` relative to `origin/claude/integration` (ahead = commits only on the branch, behind = commits only on integration). Dates are tip commit dates.

## Method

- MERGED: tip is an ancestor of `origin/claude/integration` (`git merge-base --is-ancestor`).
- CONTENT-LANDED: not an ancestor, but `git cherry origin/claude/integration <branch>` shows only `-` lines (every commit has a patch-id equivalent on integration), or the branch has an empty diff against its merge-base. Squash merges with edited content are NOT detected, so some STALE-UNIQUE branches may in fact be landed. A reverse-apply test of the unique commits against integration found none that apply cleanly, because integration has since changed the same files.
- OPEN-PR: head of an open PR (`gh pr list --state open`): #99, #100, #101, #102, #104, #105.
- ACTIVE-LANE: named in the CLAIMED handoff 023 (docs/codex/023-arch2-main-and-hud.md and BOARD.md on origin/codex/handoffs). Board row 12 is the only CLAIMED row.
- PARKED, ARCHIVE, PROTECTED: by name or prefix as specified. Priority when several apply: PROTECTED, ARCHIVE, PARKED, OPEN-PR, ACTIVE-LANE, then MERGED, CONTENT-LANDED, STALE-UNIQUE. One state per branch.
- STALE-UNIQUE: at least one commit whose patch is not on integration. Notes come from commit subjects and file lists, not from a code review.
- Note: docs/RELEASE_RECONCILIATION_PLAN.md is not yet on integration (PR #105 open), so Phase 1 was built from the task description.

## Summary counts

| State | Count |
|---|---|
| MERGED | 120 |
| CONTENT-LANDED | 21 |
| OPEN-PR | 6 |
| ACTIVE-LANE | 2 |
| PARKED | 4 |
| ARCHIVE | 11 |
| PROTECTED | 4 |
| STALE-UNIQUE | 29 |
| **Total** | **197** |

## Main: 2 commits not on integration

`git log origin/claude/integration..origin/main` shows two commits:

- `6d27f72` Merge PR #5 (gauntlet/production into main). Its second parent `fbbdc64` is an ancestor of integration and its first parent `188b706` is the merge base of main and integration. The merge adds no content beyond history, so it is already on integration in substance.
- `a230084` "docs: make playable-milestone critic loop top-level on main". Adds two lines at the top of AGENTS.md (a "Milestone = a complete playable game..." critic-loop paragraph). Not on integration verbatim: integration rewrote AGENTS.md (identity banner, Current execution contract). Its intent (autonomous critic loop, user playtest never gates work, write PAUSED, RESUME REQUIRED when usage ends) is covered by the integration execution contract, so it is superseded rather than literally present.

Safe merge: `git merge-tree --write-tree` of integration with main reports exactly one conflict, AGENTS.md. A safe path is a PR from a throwaway branch off integration that runs `git merge origin/main`, resolves AGENTS.md by keeping the integration version (optionally re-adding the two lines if Pat wants that wording), and changes nothing else. That makes main an ancestor of integration, so a later promotion of integration to main is a fast-forward. Promotion is Pat's decision; nothing here pushes to main.

## Ledger

| Branch | Tip | Tip date | Ahead | Behind | State | Disposition |
|---|---|---|---|---|---|---|
| `audit/guidance-reconciliation-20261022` | f651b09 | 2026-10-23 | 0 | 81 | MERGED | Deletion candidate (ancestor of integration). |
| `audit/recon-cargo-fixes-20261022` | 73f670e | 2026-10-23 | 0 | 92 | MERGED | Deletion candidate (ancestor of integration). |
| `ccr-de2814d6-7im23r` | 2f154f2 | 2026-10-24 | 0 | 10 | MERGED | Deletion candidate (ancestor of integration). |
| `checkpoint/patrol-recovery-8d8635a` | 8d8635a | 2026-10-19 | 0 | 909 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/arch1-cancel-helper` | faff74e | 2026-10-23 | 0 | 99 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/arch1-photo-final` | a421140 | 2026-10-23 | 0 | 39 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/arch1-route-final` | c86f8c9 | 2026-10-23 | 0 | 44 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/arch1-save-checks` | c7c5cfd | 2026-10-23 | 0 | 102 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/arch1-sensors-final` | c2d2876 | 2026-10-23 | 0 | 48 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/arch1-weapons-final` | 9c9eef0 | 2026-10-23 | 0 | 73 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/audit-attribution-keystore` | 75c2e09 | 2026-10-23 | 0 | 101 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/campaign-m1` | fad2eba | 2026-10-23 | 0 | 15 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/depth1` | f2278c3 | 2026-10-22 | 0 | 138 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/directives-23oct` | 5db4802 | 2026-10-23 | 0 | 100 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/early-module-reward` | 76e78d3 | 2026-10-23 | 0 | 29 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/first-siren-cue` | a0f5cba | 2026-10-23 | 0 | 34 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/fix1-cold-review-2` | 9a7180a | 2026-10-23 | 0 | 104 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/fix2-cold-review-full` | fd2224a | 2026-10-23 | 0 | 59 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/gauntlet-root-orchestrator-1paufv` | 7089470 | 2026-10-22 | 0 | 103 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/grade-on-secure` | f7a7ea3 | 2026-10-23 | 0 | 78 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-audio-photo` | 9b2f665 | 2026-10-23 | 0 | 52 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-c1-glass` | 7a5c4ee | 2026-10-21 | 0 | 292 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-c2-iron` | 853331e | 2026-10-22 | 0 | 226 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-challenge-mode` | 5043a99 | 2026-10-22 | 0 | 149 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-controls-friction` | f71370c | 2026-10-22 | 0 | 157 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-f1-frontend` | f22c9a1 | 2026-10-22 | 0 | 249 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-k-combat` | f1ed21a | 2026-10-22 | 0 | 222 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-lock-warning-readability` | 2b6f325 | 2026-10-22 | 0 | 181 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-nav-clearance` | ecfd4ef | 2026-10-22 | 0 | 123 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-p1-fittings` | 84a83f1 | 2026-10-21 | 0 | 271 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-performance-and-leaks` | 9899a2c | 2026-10-22 | 0 | 146 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-r1-rules` | 7aa88ff | 2026-10-21 | 0 | 261 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-route-map` | 65260da | 2026-10-23 | 0 | 12 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-s3-rewrite` | 812fc07 | 2026-10-21 | 0 | 256 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-s3b-text` | e7a8995 | 2026-10-22 | 0 | 244 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-t-pressure` | 897f49f | 2026-10-21 | 0 | 282 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-t2-sonar-bearing` | e1d906c | 2026-10-21 | 0 | 277 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-t2-sweeper` | 3d7da2d | 2026-10-22 | 0 | 160 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-test-registry` | 6564bb4 | 2026-10-23 | 0 | 113 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-x2-probes` | 5252ef4 | 2026-10-21 | 0 | 293 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-x3-audio` | 4ba9894 | 2026-10-21 | 0 | 292 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/lane-x4-seam` | d3c5028 | 2026-10-21 | 0 | 293 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/onboard1` | 7421094 | 2026-10-22 | 0 | 193 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/photo1-recon` | b9bff6b | 2026-10-22 | 0 | 197 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/photo2-images` | def58f7 | 2026-10-22 | 0 | 185 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/priced1` | f4a9f5d | 2026-10-22 | 0 | 170 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/resume-refresh-20261024` | b5721b3 | 2026-10-23 | 0 | 1 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/claude-replan` | 8310f56 | 2026-10-19 | 0 | 500 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/confluence-integrated` | a283a1a | 2026-10-20 | 0 | 433 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/current-game-handoff` | f034954 | 2026-10-19 | 0 | 631 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/earned-course-integrated` | 98f4b35 | 2026-10-20 | 0 | 419 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/fleet-integrated` | 289ef10 | 2026-10-20 | 0 | 424 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/navigation-handoff` | 7f394be | 2026-10-19 | 0 | 626 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/pass0-build-status` | 57280ef | 2026-10-20 | 0 | 487 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/pass0-built` | d74ed47 | 2026-10-20 | 0 | 457 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/pass0-plan` | 9d30dc8 | 2026-10-20 | 0 | 497 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/playable-milestone-critic-loop-20261019` | 5129b33 | 2026-10-19 | 0 | 479 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/recovery-next-operation` | fe43f90 | 2026-10-20 | 0 | 409 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/scrolling-playfield-priority` | 4a0ae5f | 2026-10-19 | 0 | 624 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/stakes-integrated` | 7aa77c5 | 2026-10-20 | 0 | 442 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/telemetry-blackwater-loop` | ccca7a5 | 2026-10-20 | 0 | 396 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/tender-next-operation` | c76ebfd | 2026-10-20 | 0 | 401 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/docs/user-directive-order` | f887c35 | 2026-10-20 | 0 | 482 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/acoustic-paths` | 2b06815 | 2026-10-19 | 0 | 796 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/campaign-endings` | a824280 | 2026-10-20 | 0 | 489 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/campaign-evidence-recap` | 109a705 | 2026-10-19 | 0 | 822 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/concealed-consequences` | 818fe8c | 2026-10-20 | 0 | 324 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/confluence-operation` | 7caac2d | 2026-10-20 | 0 | 440 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/contact-instrument-clearance` | 8f32ca6 | 2026-10-19 | 0 | 779 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/drone-operations` | 4144d0b | 2026-10-19 | 0 | 650 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/embodied-discovery` | 423b023 | 2026-10-19 | 0 | 640 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/fit-label-layout` | dd09f5b | 2026-10-19 | 0 | 837 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/fleet-instruments` | e638fa7 | 2026-10-20 | 0 | 433 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/foundry-departure-cycle` | 5d021e1 | 2026-10-19 | 0 | 694 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/foundry-thermal-lee` | a5fe5e6 | 2026-10-19 | 0 | 736 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/independent-capture` | 5023c1c | 2026-10-20 | 0 | 452 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/inhabited-shelf` | 5c699e4 | 2026-10-20 | 0 | 332 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/local-contact-reports` | 5dda434 | 2026-10-19 | 0 | 639 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/open-warning-outcome` | cd2bc37 | 2026-10-20 | 0 | 340 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/operation-endurance` | 9dfd0a5 | 2026-10-20 | 0 | 451 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/order-row-layout` | 767309f | 2026-10-19 | 0 | 826 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/pass0-encounters` | 01d11bc | 2026-10-20 | 0 | 495 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/programmed-waypoints` | 5ee9555 | 2026-10-19 | 0 | 798 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/relay-touch-access` | c0b12d5 | 2026-10-20 | 0 | 383 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/targeted-knockdown` | ad64e42 | 2026-10-19 | 0 | 801 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/torpedo-contact-aiming` | 029885c | 2026-10-19 | 0 | 736 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/v7-earned-region` | e30ccbb | 2026-10-20 | 0 | 471 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/v7-recon-consequences` | b266bd8 | 2026-10-20 | 0 | 470 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/view-controls-menu` | 24f1b40 | 2026-10-20 | 0 | 484 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/well-acquisition-context` | fa0fa7e | 2026-10-19 | 0 | 833 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/feature/witness-rescue-ui` | e8c1241 | 2026-10-20 | 0 | 353 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/fix/current-engine-audio` | 056f391 | 2026-10-20 | 0 | 347 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/fix/field-record-language` | d35569d | 2026-10-19 | 0 | 631 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/fix/local-work-access` | 566bacd | 2026-10-20 | 0 | 328 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/fix/observable-beam-warning` | 2087d8d | 2026-10-20 | 0 | 454 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/fix/targeting-feedback` | be93817 | 2026-10-20 | 0 | 452 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/fix/visible-save-failure` | cfa2ce7 | 2026-10-20 | 0 | 336 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/blackwater-data-delivery` | 5e43728 | 2026-10-20 | 0 | 387 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/confluence-operation` | f5c58fd | 2026-10-20 | 0 | 435 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/connected-campaign` | 64d9621 | 2026-10-19 | 0 | 539 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/craft-anchored-batch` | 0eea954 | 2026-10-20 | 0 | 364 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/deep-rendezvous` | 133228f | 2026-10-20 | 0 | 403 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/earned-course-continuity` | da494f4 | 2026-10-20 | 0 | 421 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/fleet-instruments` | 83725a4 | 2026-10-20 | 0 | 426 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/physical-module-recovery` | c72dd3a | 2026-10-20 | 0 | 413 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/recovery-route-intent` | 97f2b26 | 2026-10-20 | 0 | 360 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/route-first-telemetry` | 1840732 | 2026-10-20 | 0 | 398 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/stakes` | 9957c7e | 2026-10-20 | 0 | 444 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/v7-full-game` | af4441e | 2026-10-20 | 0 | 459 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/integration/warning-chain-plant` | 0c619ad | 2026-10-20 | 0 | 372 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/maintenance/handoff-evidence-20261020-0724` | 54c4a31 | 2026-10-20 | 0 | 351 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/maintenance/redundant-assets-2026-10-20` | 02d6cd4 | 2026-10-20 | 0 | 358 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/play/confluence-focused` | f5c58fd | 2026-10-20 | 0 | 435 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/play/stakes-whole-game` | b915b5c | 2026-10-19 | 0 | 443 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/play/v7-whole-game` | af4441e | 2026-10-20 | 0 | 459 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/release/depth-sonar` | ea645d3 | 2026-10-20 | 0 | 308 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/release/glass-reach` | f4f4d00 | 2026-10-20 | 0 | 303 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/release/iron-choir` | 707822e | 2026-10-21 | 0 | 298 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/release/operation-foundation` | a6b6701 | 2026-10-20 | 0 | 315 | MERGED | Deletion candidate (ancestor of integration). |
| `gauntlet/test/pass0-route-contract` | f7f0264 | 2026-10-20 | 0 | 482 | MERGED | Deletion candidate (ancestor of integration). |
| `claude/arch1-orders-sensors` | 62c58e1 | 2026-10-23 | 4 | 83 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `claude/arch1-orders-weapons` | 0c94966 | 2026-10-23 | 2 | 83 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/checkpoint/resolution-proof-detached` | 257cff3 | 2026-10-19 | 5 | 549 | CONTENT-LANDED | Deletion candidate (content already on integration, method: emptydiff). |
| `gauntlet/docs/pause-2026-10-21` | 313ecda | 2026-10-21 | 1 | 297 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/blackwater-data-delivery` | 83cdc72 | 2026-10-20 | 4 | 400 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/blackwater-delivery-ui` | a81d77a | 2026-10-20 | 7 | 402 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/briefing-scroll-fit` | 06db9f2 | 2026-10-20 | 1 | 395 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/campaign-upgrades` | 3a0f02a | 2026-10-20 | 3 | 496 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/confluence-world-art` | 3018495 | 2026-10-20 | 4 | 443 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/craft-anchored-fleet` | 0f14588 | 2026-10-20 | 3 | 374 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/drone-recovery-ui` | 62a548e | 2026-10-20 | 4 | 420 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/earned-course-continuity` | b29cb83 | 2026-10-20 | 1 | 432 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/live-fitting-identity` | aeeb5b0 | 2026-10-20 | 1 | 371 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/physical-module-recovery` | ae33fc0 | 2026-10-20 | 3 | 420 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/planner-chart-context` | 975d513 | 2026-10-20 | 2 | 382 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/recovery-route-intent` | 09b66ea | 2026-10-20 | 2 | 363 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/route-first-telemetry` | b4f575d | 2026-10-20 | 2 | 402 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/v7-currents` | 8767b85 | 2026-10-20 | 5 | 481 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/warning-chain-plant` | 9ec9931 | 2026-10-20 | 3 | 386 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/warning-chain-ui` | 2111a21 | 2026-10-20 | 5 | 382 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `gauntlet/feature/witness-evacuation` | 72a22bc | 2026-10-20 | 2 | 363 | CONTENT-LANDED | Deletion candidate (content already on integration, method: cherry). |
| `claude/lane-arch2-photo-review` | 57b6ce6 | 2026-10-23 | 4 | 2 | OPEN-PR | Wait for PR #100, then reassess. ARCH2 photo_review extraction (PR100 open). Unique until PR100 lands. |
| `claude/lane-arch2-rendezvous-view` | 15057f3 | 2026-10-23 | 9 | 2 | OPEN-PR | Wait for PR #104, then reassess. ARCH2 display contract commits stacked on wake-view (PR104 open). Unique until it lands. |
| `claude/lane-arch2-ui-metrics` | 983f057 | 2026-10-23 | 6 | 2 | OPEN-PR | Wait for PR #101, then reassess. ARCH2 UI metrics extraction (PR101 open). Unique until it lands. |
| `claude/lane-arch2-wake-view` | d229936 | 2026-10-23 | 8 | 2 | OPEN-PR | Wait for PR #102, then reassess. ARCH2 Wake display contract (PR102 open). Unique until it lands. |
| `claude/release-reconciliation-plan` | a5e4b2c | 2026-10-23 | 1 | 0 | OPEN-PR | Wait for PR #105, then reassess. The reconciliation plan doc (PR105 open). |
| `claude/windows-hook-compat` | 29c405c | 2026-10-23 | 2 | 0 | OPEN-PR | Wait for PR #99, then reassess. Windows gauntlet hook support (PR99 open). |
| `claude/desktop-handoff-20261023` | 632f592 | 2026-10-24 | 0 | 3 | ACTIVE-LANE | Keep until 023 is DONE (merged PR98 but named in the open 023 claim); then deletion candidate. |
| `claude/lane-arch2-campaign-flow` | 3afb12f | 2026-10-24 | 0 | 10 | ACTIVE-LANE | Keep until 023 is DONE (merged PR96 but named in the open 023 claim); then deletion candidate. |
| `claude/future-siren-active-sonar-sweeper` | d09378c | 2026-10-21 | 0 | 261 | PARKED | Keep parked. Parked by Pat. |
| `claude/lane-c2-wip-b` | ca4e852 | 2026-10-21 | 1 | 259 | PARKED | Keep parked. Unreviewed WIP snapshot of Iron Choir encounter rules and industrial jobs. PARKED by Pat. |
| `claude/lane-n1-calder` | 0b6c6e0 | 2026-10-21 | 1 | 262 | PARKED | Keep parked. Unreviewed WIP snapshot of Calder Trench operations. PARKED by Pat. |
| `claude/lane-p2-economy` | 82bcf57 | 2026-10-21 | 1 | 262 | PARKED | Keep parked. Unreviewed WIP snapshot of economy and glass research. PARKED by Pat. |
| `archive/claude-audit-2026-10-19` | 251fc48 | 2026-10-20 | 3 | 501 | ARCHIVE | Keep. Archive branch. Audit findings and checkpoints JSON; only copy. |
| `archive/claude-current-audit-2026-10-19` | 3adf4be | 2026-10-19 | 1 | 501 | ARCHIVE | Keep. Archive branch. Audit brief and visuals; only copy. |
| `archive/cloud-desktop-20261023` | 5407a24 | 2026-10-24 | 1 | 989 | ARCHIVE | Keep. Archive branch. Cloud evidence archive for the desktop handover. |
| `archive/gauntlet-cold-frames-2026-10-20` | f31bc8a | 2026-10-20 | 1 | 989 | ARCHIVE | Keep. Archive branch. Frozen play frames; evidence only. |
| `archive/gauntlet-cold-frames-execution-2026-10-20` | 2b6fdd7 | 2026-10-20 | 3 | 989 | ARCHIVE | Keep. Archive branch. Reconstructable execution screenshots; evidence only. |
| `archive/gauntlet-evidence-2026-10-19` | a855cc1 | 2026-10-19 | 0 | 695 | ARCHIVE | Keep. Archive branch. Already an ancestor of integration; no action. |
| `archive/gauntlet-evidence-2026-10-19-planner-71f10cf` | 71f10cf | 2026-10-19 | 3 | 695 | ARCHIVE | Keep. Archive branch. Planner navigation evidence; feature code itself is superseded. |
| `archive/gauntlet-evidence-2026-10-19-stage2` | 522c801 | 2026-10-19 | 0 | 683 | ARCHIVE | Keep. Archive branch. Already an ancestor of integration; no action. |
| `archive/gauntlet-governance-acceptance-2026-10-19` | 3c3937f | 2026-10-19 | 28 | 797 | ARCHIVE | Keep. Archive branch. Audit batch evidence docs; no code. |
| `archive/gauntlet-program-audit-2026-10-19` | 715043c | 2026-10-19 | 1 | 570 | ARCHIVE | Keep. Archive branch. Program audit receipts; only copy. |
| `archive/reference-package-20261022` | 7089470 | 2026-10-22 | 0 | 103 | ARCHIVE | Keep. Archive branch. Already an ancestor of integration; no action. |
| `claude/integration` | f43a672 | 2026-10-23 | 0 | 0 | PROTECTED | Keep. Protected branch. |
| `codex/handoffs` | 90ed566 | 2026-10-23 | 187 | 278 | PROTECTED | Keep. Protected branch. Content diverges from integration by design. |
| `gauntlet/production` | ca4735e | 2026-10-20 | 0 | 296 | PROTECTED | Keep. Protected branch. |
| `main` | a230084 | 2026-10-19 | 2 | 577 | PROTECTED | Keep. Protected branch. |
| `audit/gauntlet-exhaustive-2026-10-19` | f7b4f90 | 2026-10-19 | 27 | 797 | STALE-UNIQUE | Pat decision. Exhaustive audit batches (docs only). Duplicates content of an archive branch. Matters only as evidence. |
| `audit/handoff-guidance-20261022` | 855955b | 2026-10-23 | 88 | 278 | STALE-UNIQUE | Pat decision. 86 patch-unique commits, mostly docs/codex handoff text later superseded on codex/handoffs. Low value; review before any removal. |
| `claude/arch1-orders-photo` | 220fa18 | 2026-10-23 | 8 | 83 | STALE-UNIQUE | Pat decision. Intermediate stacked ARCH1 steps (photo/feature orders); final steps merged as PR88/90/91/92 with different content. Superseded, does not matter. |
| `claude/arch1-orders-route` | ce4b481 | 2026-10-23 | 6 | 83 | STALE-UNIQUE | Pat decision. Intermediate stacked ARCH1 step (route orders); superseded by merged final steps. Does not matter. |
| `claude/lane-s1-inventory` | 40137f8 | 2026-10-21 | 1 | 295 | STALE-UNIQUE | Pat decision. docs/STORY_INVENTORY.md only. Story docs are placeholder-only now; matters little but the file exists nowhere else. |
| `claude/lane-s2-bible` | de3a135 | 2026-10-21 | 1 | 295 | STALE-UNIQUE | Pat decision. docs/STORY_BIBLE_DRAFT.md only (rescue-premise draft); also on codex/handoffs. Low value. |
| `docs/playable-milestone-main-sync-20261019` | 1cb839f | 2026-10-19 | 2 | 577 | STALE-UNIQUE | Pat decision. Same AGENTS.md 2-line edit as main a230084; guidance since rewritten on integration. Does not matter. |
| `gauntlet/checkpoint/execute-2026-10-20` | fa0bb17 | 2026-10-21 | 36 | 483 | STALE-UNIQUE | Pat decision. 602 files of checkpoint tools and handoff logs (Pass0 era); history/evidence only. |
| `gauntlet/checkpoint/pre-claude-guidance` | 66c88d1 | 2026-10-19 | 5 | 501 | STALE-UNIQUE | Pat decision. Old guidance docs checkpoint; superseded by integration guidance. |
| `gauntlet/checkpoint/recovery-route-review-2026-10-20` | 8a6144c | 2026-10-20 | 2 | 362 | STALE-UNIQUE | Pat decision. Recovery pointer fix plus work logs; the fix may or may not be on integration. Check mission_hud.gd tap validation before any removal. |
| `gauntlet/checkpoint/touch-play-2026-10-20` | 2033951 | 2026-10-20 | 15 | 483 | STALE-UNIQUE | Pat decision. Touch-play checkpoint tools and logs; evidence only. |
| `gauntlet/feature/blind-passage-content` | 7fe12f8 | 2026-10-19 | 1 | 501 | STALE-UNIQUE | Pat decision. Blind Passage content region; part of an abandoned chart-world line. Product decision needed. |
| `gauntlet/feature/blind-passage-main` | 166081f | 2026-10-19 | 24 | 501 | STALE-UNIQUE | Pat decision. Blind Passage wired into Main (24 commits); abandoned chart-world line. Product decision needed. |
| `gauntlet/feature/deep-rendezvous-tender` | 79b54dc | 2026-10-20 | 3 | 418 | STALE-UNIQUE | Pat decision. Deep Rendezvous tender sim; check against integration rendezvous_transport before removal. |
| `gauntlet/feature/deep-rendezvous-ui` | ab509bd | 2026-10-20 | 3 | 414 | STALE-UNIQUE | Pat decision. Deep Rendezvous UI and berth release; check against integration before removal. |
| `gauntlet/feature/drone-operational-investigation` | d625e56 | 2026-10-19 | 1 | 787 | STALE-UNIQUE | Pat decision. Rejected-probe evidence record (docs, jsonl); preserved as lessons. |
| `gauntlet/feature/drone-thrust-prototype` | c1b96fc | 2026-10-19 | 1 | 770 | STALE-UNIQUE | Pat decision. Rejected drone-thrust prototype evidence; preserved as lessons. |
| `gauntlet/feature/earned-chart-world` | 55bc0b0 | 2026-10-19 | 30 | 501 | STALE-UNIQUE | Pat decision. Earned-chart view (30 commits); abandoned chart-world line. Product decision needed. |
| `gauntlet/feature/earned-terrain-chart` | 71d8fc2 | 2026-10-19 | 25 | 501 | STALE-UNIQUE | Pat decision. Earned terrain chart (25 commits); abandoned chart-world line. Product decision needed. |
| `gauntlet/feature/observed-task-controls` | 8f7978b | 2026-10-19 | 8 | 504 | STALE-UNIQUE | Pat decision. Observed-task planner controls; route-program line not on integration. Product decision needed. |
| `gauntlet/feature/observed-task-execution` | 09e458e | 2026-10-19 | 6 | 501 | STALE-UNIQUE | Pat decision. Observed-task execution in sim; route-program line. Product decision needed. |
| `gauntlet/feature/planner-chart-navigation` | 8e13043 | 2026-10-19 | 1 | 700 | STALE-UNIQUE | Pat decision. Planner navigation with validation artifacts; route-program line (same commit as the archive planner branch). |
| `gauntlet/fix/save-tick-phase` | 640e399 | 2026-10-19 | 6 | 501 | STALE-UNIQUE | Pat decision. Save tick-phase fix stacked on observed-task work; confirm the fix is not needed on integration saves. |
| `gauntlet/review/blind-passage-main-play` | 4bc2746 | 2026-10-19 | 25 | 501 | STALE-UNIQUE | Pat decision. Review branch of blind-passage-main plus proof projection. Evidence only. |
| `gauntlet/review/observed-task-and-save` | 49fb594 | 2026-10-19 | 22 | 501 | STALE-UNIQUE | Pat decision. Review branch for observed-task and save work. Evidence only. |
| `maintenance/gauntlet-audit-retirement-2026-10-19` | de6d671 | 2026-10-19 | 1 | 621 | STALE-UNIQUE | Pat decision. One CONTINUATION.md edit; obsolete. |
| `maintenance/gauntlet-default-branch-sync-20261019` | 84b7224 | 2026-10-19 | 4 | 979 | STALE-UNIQUE | Pat decision. Default-branch guidance routing docs; superseded by integration guidance. |
| `maintenance/gauntlet-staleness-continuity-20261019` | 74dc666 | 2026-10-19 | 14 | 652 | STALE-UNIQUE | Pat decision. Guidance-checker CI hardening (14 commits); verify the checker on integration already fails closed on a missing living spec. |
| `maintenance/main-gauntlet-check-bootstrap-20261019` | 50dd987 | 2026-10-19 | 3 | 978 | STALE-UNIQUE | Pat decision. Bootstrap of guidance checks on main; superseded. |

## Deletion MANIFEST (PROPOSAL, Pat executes, nothing deleted)

141 branches that are MERGED or CONTENT-LANDED with no open PR, no 023 claim, and not PARKED, ARCHIVE or PROTECTED. Re-check that none has become the head of a new PR before running. Tips are listed so a deleted branch can be restored with `git push origin <sha>:refs/heads/<name>`.

```
git push origin --delete audit/guidance-reconciliation-20261022
git push origin --delete audit/recon-cargo-fixes-20261022
git push origin --delete ccr-de2814d6-7im23r
git push origin --delete checkpoint/patrol-recovery-8d8635a
git push origin --delete claude/arch1-cancel-helper
git push origin --delete claude/arch1-orders-sensors
git push origin --delete claude/arch1-orders-weapons
git push origin --delete claude/arch1-photo-final
git push origin --delete claude/arch1-route-final
git push origin --delete claude/arch1-save-checks
git push origin --delete claude/arch1-sensors-final
git push origin --delete claude/arch1-weapons-final
git push origin --delete claude/audit-attribution-keystore
git push origin --delete claude/campaign-m1
git push origin --delete claude/depth1
git push origin --delete claude/directives-23oct
git push origin --delete claude/early-module-reward
git push origin --delete claude/first-siren-cue
git push origin --delete claude/fix1-cold-review-2
git push origin --delete claude/fix2-cold-review-full
git push origin --delete claude/gauntlet-root-orchestrator-1paufv
git push origin --delete claude/grade-on-secure
git push origin --delete claude/lane-audio-photo
git push origin --delete claude/lane-c1-glass
git push origin --delete claude/lane-c2-iron
git push origin --delete claude/lane-challenge-mode
git push origin --delete claude/lane-controls-friction
git push origin --delete claude/lane-f1-frontend
git push origin --delete claude/lane-k-combat
git push origin --delete claude/lane-lock-warning-readability
git push origin --delete claude/lane-nav-clearance
git push origin --delete claude/lane-p1-fittings
git push origin --delete claude/lane-performance-and-leaks
git push origin --delete claude/lane-r1-rules
git push origin --delete claude/lane-route-map
git push origin --delete claude/lane-s3-rewrite
git push origin --delete claude/lane-s3b-text
git push origin --delete claude/lane-t-pressure
git push origin --delete claude/lane-t2-sonar-bearing
git push origin --delete claude/lane-t2-sweeper
git push origin --delete claude/lane-test-registry
git push origin --delete claude/lane-x2-probes
git push origin --delete claude/lane-x3-audio
git push origin --delete claude/lane-x4-seam
git push origin --delete claude/onboard1
git push origin --delete claude/photo1-recon
git push origin --delete claude/photo2-images
git push origin --delete claude/priced1
git push origin --delete claude/resume-refresh-20261024
git push origin --delete gauntlet/checkpoint/resolution-proof-detached
git push origin --delete gauntlet/docs/claude-replan
git push origin --delete gauntlet/docs/confluence-integrated
git push origin --delete gauntlet/docs/current-game-handoff
git push origin --delete gauntlet/docs/earned-course-integrated
git push origin --delete gauntlet/docs/fleet-integrated
git push origin --delete gauntlet/docs/navigation-handoff
git push origin --delete gauntlet/docs/pass0-build-status
git push origin --delete gauntlet/docs/pass0-built
git push origin --delete gauntlet/docs/pass0-plan
git push origin --delete gauntlet/docs/pause-2026-10-21
git push origin --delete gauntlet/docs/playable-milestone-critic-loop-20261019
git push origin --delete gauntlet/docs/recovery-next-operation
git push origin --delete gauntlet/docs/scrolling-playfield-priority
git push origin --delete gauntlet/docs/stakes-integrated
git push origin --delete gauntlet/docs/telemetry-blackwater-loop
git push origin --delete gauntlet/docs/tender-next-operation
git push origin --delete gauntlet/docs/user-directive-order
git push origin --delete gauntlet/feature/acoustic-paths
git push origin --delete gauntlet/feature/blackwater-data-delivery
git push origin --delete gauntlet/feature/blackwater-delivery-ui
git push origin --delete gauntlet/feature/briefing-scroll-fit
git push origin --delete gauntlet/feature/campaign-endings
git push origin --delete gauntlet/feature/campaign-evidence-recap
git push origin --delete gauntlet/feature/campaign-upgrades
git push origin --delete gauntlet/feature/concealed-consequences
git push origin --delete gauntlet/feature/confluence-operation
git push origin --delete gauntlet/feature/confluence-world-art
git push origin --delete gauntlet/feature/contact-instrument-clearance
git push origin --delete gauntlet/feature/craft-anchored-fleet
git push origin --delete gauntlet/feature/drone-operations
git push origin --delete gauntlet/feature/drone-recovery-ui
git push origin --delete gauntlet/feature/earned-course-continuity
git push origin --delete gauntlet/feature/embodied-discovery
git push origin --delete gauntlet/feature/fit-label-layout
git push origin --delete gauntlet/feature/fleet-instruments
git push origin --delete gauntlet/feature/foundry-departure-cycle
git push origin --delete gauntlet/feature/foundry-thermal-lee
git push origin --delete gauntlet/feature/independent-capture
git push origin --delete gauntlet/feature/inhabited-shelf
git push origin --delete gauntlet/feature/live-fitting-identity
git push origin --delete gauntlet/feature/local-contact-reports
git push origin --delete gauntlet/feature/open-warning-outcome
git push origin --delete gauntlet/feature/operation-endurance
git push origin --delete gauntlet/feature/order-row-layout
git push origin --delete gauntlet/feature/pass0-encounters
git push origin --delete gauntlet/feature/physical-module-recovery
git push origin --delete gauntlet/feature/planner-chart-context
git push origin --delete gauntlet/feature/programmed-waypoints
git push origin --delete gauntlet/feature/recovery-route-intent
git push origin --delete gauntlet/feature/relay-touch-access
git push origin --delete gauntlet/feature/route-first-telemetry
git push origin --delete gauntlet/feature/targeted-knockdown
git push origin --delete gauntlet/feature/torpedo-contact-aiming
git push origin --delete gauntlet/feature/v7-currents
git push origin --delete gauntlet/feature/v7-earned-region
git push origin --delete gauntlet/feature/v7-recon-consequences
git push origin --delete gauntlet/feature/view-controls-menu
git push origin --delete gauntlet/feature/warning-chain-plant
git push origin --delete gauntlet/feature/warning-chain-ui
git push origin --delete gauntlet/feature/well-acquisition-context
git push origin --delete gauntlet/feature/witness-evacuation
git push origin --delete gauntlet/feature/witness-rescue-ui
git push origin --delete gauntlet/fix/current-engine-audio
git push origin --delete gauntlet/fix/field-record-language
git push origin --delete gauntlet/fix/local-work-access
git push origin --delete gauntlet/fix/observable-beam-warning
git push origin --delete gauntlet/fix/targeting-feedback
git push origin --delete gauntlet/fix/visible-save-failure
git push origin --delete gauntlet/integration/blackwater-data-delivery
git push origin --delete gauntlet/integration/confluence-operation
git push origin --delete gauntlet/integration/connected-campaign
git push origin --delete gauntlet/integration/craft-anchored-batch
git push origin --delete gauntlet/integration/deep-rendezvous
git push origin --delete gauntlet/integration/earned-course-continuity
git push origin --delete gauntlet/integration/fleet-instruments
git push origin --delete gauntlet/integration/physical-module-recovery
git push origin --delete gauntlet/integration/recovery-route-intent
git push origin --delete gauntlet/integration/route-first-telemetry
git push origin --delete gauntlet/integration/stakes
git push origin --delete gauntlet/integration/v7-full-game
git push origin --delete gauntlet/integration/warning-chain-plant
git push origin --delete gauntlet/maintenance/handoff-evidence-20261020-0724
git push origin --delete gauntlet/maintenance/redundant-assets-2026-10-20
git push origin --delete gauntlet/play/confluence-focused
git push origin --delete gauntlet/play/stakes-whole-game
git push origin --delete gauntlet/play/v7-whole-game
git push origin --delete gauntlet/release/depth-sonar
git push origin --delete gauntlet/release/glass-reach
git push origin --delete gauntlet/release/iron-choir
git push origin --delete gauntlet/release/operation-foundation
git push origin --delete gauntlet/test/pass0-route-contract
```

Restore table (tip, name):

```
f651b09 audit/guidance-reconciliation-20261022
73f670e audit/recon-cargo-fixes-20261022
2f154f2 ccr-de2814d6-7im23r
8d8635a checkpoint/patrol-recovery-8d8635a
faff74e claude/arch1-cancel-helper
62c58e1 claude/arch1-orders-sensors
0c94966 claude/arch1-orders-weapons
a421140 claude/arch1-photo-final
c86f8c9 claude/arch1-route-final
c7c5cfd claude/arch1-save-checks
c2d2876 claude/arch1-sensors-final
9c9eef0 claude/arch1-weapons-final
75c2e09 claude/audit-attribution-keystore
fad2eba claude/campaign-m1
f2278c3 claude/depth1
5db4802 claude/directives-23oct
76e78d3 claude/early-module-reward
a0f5cba claude/first-siren-cue
9a7180a claude/fix1-cold-review-2
fd2224a claude/fix2-cold-review-full
7089470 claude/gauntlet-root-orchestrator-1paufv
f7a7ea3 claude/grade-on-secure
9b2f665 claude/lane-audio-photo
7a5c4ee claude/lane-c1-glass
853331e claude/lane-c2-iron
5043a99 claude/lane-challenge-mode
f71370c claude/lane-controls-friction
f22c9a1 claude/lane-f1-frontend
f1ed21a claude/lane-k-combat
2b6f325 claude/lane-lock-warning-readability
ecfd4ef claude/lane-nav-clearance
84a83f1 claude/lane-p1-fittings
9899a2c claude/lane-performance-and-leaks
7aa88ff claude/lane-r1-rules
65260da claude/lane-route-map
812fc07 claude/lane-s3-rewrite
e7a8995 claude/lane-s3b-text
897f49f claude/lane-t-pressure
e1d906c claude/lane-t2-sonar-bearing
3d7da2d claude/lane-t2-sweeper
6564bb4 claude/lane-test-registry
5252ef4 claude/lane-x2-probes
4ba9894 claude/lane-x3-audio
d3c5028 claude/lane-x4-seam
7421094 claude/onboard1
b9bff6b claude/photo1-recon
def58f7 claude/photo2-images
f4a9f5d claude/priced1
b5721b3 claude/resume-refresh-20261024
257cff3 gauntlet/checkpoint/resolution-proof-detached
8310f56 gauntlet/docs/claude-replan
a283a1a gauntlet/docs/confluence-integrated
f034954 gauntlet/docs/current-game-handoff
98f4b35 gauntlet/docs/earned-course-integrated
289ef10 gauntlet/docs/fleet-integrated
7f394be gauntlet/docs/navigation-handoff
57280ef gauntlet/docs/pass0-build-status
d74ed47 gauntlet/docs/pass0-built
9d30dc8 gauntlet/docs/pass0-plan
313ecda gauntlet/docs/pause-2026-10-21
5129b33 gauntlet/docs/playable-milestone-critic-loop-20261019
fe43f90 gauntlet/docs/recovery-next-operation
4a0ae5f gauntlet/docs/scrolling-playfield-priority
7aa77c5 gauntlet/docs/stakes-integrated
ccca7a5 gauntlet/docs/telemetry-blackwater-loop
c76ebfd gauntlet/docs/tender-next-operation
f887c35 gauntlet/docs/user-directive-order
2b06815 gauntlet/feature/acoustic-paths
83cdc72 gauntlet/feature/blackwater-data-delivery
a81d77a gauntlet/feature/blackwater-delivery-ui
06db9f2 gauntlet/feature/briefing-scroll-fit
a824280 gauntlet/feature/campaign-endings
109a705 gauntlet/feature/campaign-evidence-recap
3a0f02a gauntlet/feature/campaign-upgrades
818fe8c gauntlet/feature/concealed-consequences
7caac2d gauntlet/feature/confluence-operation
3018495 gauntlet/feature/confluence-world-art
8f32ca6 gauntlet/feature/contact-instrument-clearance
0f14588 gauntlet/feature/craft-anchored-fleet
4144d0b gauntlet/feature/drone-operations
62a548e gauntlet/feature/drone-recovery-ui
b29cb83 gauntlet/feature/earned-course-continuity
423b023 gauntlet/feature/embodied-discovery
dd09f5b gauntlet/feature/fit-label-layout
e638fa7 gauntlet/feature/fleet-instruments
5d021e1 gauntlet/feature/foundry-departure-cycle
a5fe5e6 gauntlet/feature/foundry-thermal-lee
5023c1c gauntlet/feature/independent-capture
5c699e4 gauntlet/feature/inhabited-shelf
aeeb5b0 gauntlet/feature/live-fitting-identity
5dda434 gauntlet/feature/local-contact-reports
cd2bc37 gauntlet/feature/open-warning-outcome
9dfd0a5 gauntlet/feature/operation-endurance
767309f gauntlet/feature/order-row-layout
01d11bc gauntlet/feature/pass0-encounters
ae33fc0 gauntlet/feature/physical-module-recovery
975d513 gauntlet/feature/planner-chart-context
5ee9555 gauntlet/feature/programmed-waypoints
09b66ea gauntlet/feature/recovery-route-intent
c0b12d5 gauntlet/feature/relay-touch-access
b4f575d gauntlet/feature/route-first-telemetry
ad64e42 gauntlet/feature/targeted-knockdown
029885c gauntlet/feature/torpedo-contact-aiming
8767b85 gauntlet/feature/v7-currents
e30ccbb gauntlet/feature/v7-earned-region
b266bd8 gauntlet/feature/v7-recon-consequences
24f1b40 gauntlet/feature/view-controls-menu
9ec9931 gauntlet/feature/warning-chain-plant
2111a21 gauntlet/feature/warning-chain-ui
fa0fa7e gauntlet/feature/well-acquisition-context
72a22bc gauntlet/feature/witness-evacuation
e8c1241 gauntlet/feature/witness-rescue-ui
056f391 gauntlet/fix/current-engine-audio
d35569d gauntlet/fix/field-record-language
566bacd gauntlet/fix/local-work-access
2087d8d gauntlet/fix/observable-beam-warning
be93817 gauntlet/fix/targeting-feedback
cfa2ce7 gauntlet/fix/visible-save-failure
5e43728 gauntlet/integration/blackwater-data-delivery
f5c58fd gauntlet/integration/confluence-operation
64d9621 gauntlet/integration/connected-campaign
0eea954 gauntlet/integration/craft-anchored-batch
133228f gauntlet/integration/deep-rendezvous
da494f4 gauntlet/integration/earned-course-continuity
83725a4 gauntlet/integration/fleet-instruments
c72dd3a gauntlet/integration/physical-module-recovery
97f2b26 gauntlet/integration/recovery-route-intent
1840732 gauntlet/integration/route-first-telemetry
9957c7e gauntlet/integration/stakes
af4441e gauntlet/integration/v7-full-game
0c619ad gauntlet/integration/warning-chain-plant
54c4a31 gauntlet/maintenance/handoff-evidence-20261020-0724
02d6cd4 gauntlet/maintenance/redundant-assets-2026-10-20
f5c58fd gauntlet/play/confluence-focused
b915b5c gauntlet/play/stakes-whole-game
af4441e gauntlet/play/v7-whole-game
ea645d3 gauntlet/release/depth-sonar
f4f4d00 gauntlet/release/glass-reach
707822e gauntlet/release/iron-choir
a6b6701 gauntlet/release/operation-foundation
f7f0264 gauntlet/test/pass0-route-contract
```

Built from ancestry and patch-id checks only. AI-DESIGNED.
