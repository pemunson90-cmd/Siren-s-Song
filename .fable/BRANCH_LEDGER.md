# Branch ledger

Status: GENERATED (rerun the script to refresh; do not edit by hand)

Produced by `scripts/repo/branch_ledger.py` on 2026-11-12 from the local remote-tracking refs of `origin`. Baseline `main` at f5b66a19, base `claude/integration` at cabd5bd5. Activity window: 10 days. Nothing was changed.

| Class | Count | Meaning |
| --- | --- | --- |
| SHARED | 5 | other work is based on it or promoted through it; keep |
| ACTIVE | 4 | run branch, open PR or recent commit; keep |
| UNMERGED-UNIQUE | 24 | unmerged and still needed as a branch; keep |
| UNMERGED-STALE | 62 | unmerged, old; archivable once a tag holds the tip |
| MERGED | 279 | tip is in the baseline or the base; archivable |
| Total | 374 | |

## SHARED (5)

| Branch | Tip | Last commit | Author | Ahead/behind main | Ahead/behind claude/integration | Merged into | PR | Reason |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `claude/integration` | cabd5bd5 | 2026-11-01 | pemunson90-cmd | 1320/1 | 0/0 | claude/integration | #148 MERGED | shared line |
| `claude/workflow-v2` | 9624f1fb | 2026-10-30 | pemunson90-cmd | 1012/3 | 713/1023 | no | none | shared line |
| `codex/handoffs` | 99e52d2d | 2026-11-01 | pemunson90-cmd | 1159/3 | 860/1023 | no | none | shared line |
| `gauntlet/production` | 26e09906 | 2026-10-30 | pemunson90-cmd | 1165/1 | 4/159 | no | #5 MERGED | shared line |
| `main` | f5b66a19 | 2026-11-01 | pemunson90-cmd | 0/0 | 1/1320 | main | none | shared line |

## ACTIVE (4)

| Branch | Tip | Last commit | Author | Ahead/behind main | Ahead/behind claude/integration | Merged into | PR | Reason |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `archive/archaeology-siren-20261106` | fa13bd27 | 2026-11-06 | Claude | 2/0 | 3/1320 | no | none | commit within 10 days |
| `claude/archaeology-lookup` | 68133f46 | 2026-11-06 | Claude | 2/0 | 3/1320 | no | #261 OPEN | open PR #261 |
| `docs/project-ledger-20261024` | 7dc09ad9 | 2026-10-24 | pemunson90-cmd | 1/1 | 1/1320 | no | #139 OPEN | open PR #139 |
| `fable/overhaul-20261111` | f1b42b36 | 2026-11-12 | pemunson90-cmd | 1404/1 | 84/0 | no | #262 OPEN | run branch |

## UNMERGED-UNIQUE (24)

| Branch | Tip | Last commit | Author | Ahead/behind main | Ahead/behind claude/integration | Merged into | PR | Reason |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `archive/claude-audit-2026-10-19` | 251fc485 | 2026-10-20 | Codex | 79/3 | 3/1246 | no | none | preservation branch |
| `archive/claude-current-audit-2026-10-19` | 3adf4be7 | 2026-10-19 | Codex | 77/3 | 1/1246 | no | none | preservation branch |
| `archive/cloud-desktop-20261023` | 5407a241 | 2026-10-24 | Codex | 1/415 | 1/1734 | no | none | preservation branch |
| `archive/codex-025-landmarks-windows-20261024` | 33dfe867 | 2026-10-24 | pemunson90-cmd | 649/1 | 2/673 | no | none | preservation branch |
| `archive/codex-026-opening-windows-20261024` | 3ddcd73d | 2026-10-24 | pemunson90-cmd | 688/1 | 5/637 | no | none | preservation branch |
| `archive/codex-027-ending-windows-20261024` | 15411eaa | 2026-10-24 | pemunson90-cmd | 664/1 | 2/658 | no | none | preservation branch |
| `archive/codex-029-onboard-windows-20261024` | a74bd80e | 2026-10-24 | pemunson90-cmd | 670/1 | 4/654 | no | none | preservation branch |
| `archive/codex-030-profiles-windows-20261024` | daa851a2 | 2026-10-24 | pemunson90-cmd | 674/1 | 2/648 | no | none | preservation branch |
| `archive/codex-031-a11y-windows-20261024` | f2d0512e | 2026-10-24 | pemunson90-cmd | 679/1 | 2/643 | no | none | preservation branch |
| `archive/codex-032-art-windows-20261024` | 2e3b56c4 | 2026-10-24 | pemunson90-cmd | 687/1 | 4/637 | no | none | preservation branch |
| `archive/codex-033-docs-windows-20261025` | 27d20bdc | 2026-10-25 | pemunson90-cmd | 774/1 | 3/549 | no | none | preservation branch |
| `archive/codex-038-ops-home-windows-20261024` | 537967ff | 2026-10-24 | pemunson90-cmd | 724/1 | 5/601 | no | none | preservation branch |
| `archive/codex-040-photo-journeys-windows-20261025` | 250d1222 | 2026-10-25 | pemunson90-cmd | 770/1 | 4/554 | no | none | preservation branch |
| `archive/codex-042-finale-windows-20261025` | 42b4238e | 2026-10-25 | pemunson90-cmd | 570/3 | 271/1023 | no | none | preservation branch |
| `archive/codex-043-save2-windows-20261025` | 5c241628 | 2026-10-25 | pemunson90-cmd | 578/3 | 279/1023 | no | none | preservation branch |
| `archive/codex-044-menu-reach-windows-20261024` | 0c86d9bd | 2026-10-25 | pemunson90-cmd | 755/1 | 6/571 | no | none | preservation branch |
| `archive/codex-048-hud-windows-20261025` | 492f484b | 2026-10-25 | pemunson90-cmd | 596/3 | 297/1023 | no | none | preservation branch |
| `archive/codex-050-hunt-windows-20261025` | 887a41e9 | 2026-10-26 | pemunson90-cmd | 600/3 | 301/1023 | no | none | preservation branch |
| `archive/gauntlet-cold-frames-2026-10-20` | f31bc8af | 2026-10-20 | Codex | 1/415 | 1/1734 | no | none | preservation branch |
| `archive/gauntlet-cold-frames-execution-2026-10-20` | 2b6fdd7a | 2026-10-20 | Patrick M | 3/415 | 3/1734 | no | none | preservation branch |
| `archive/gauntlet-evidence-2026-10-19-planner-71f10cf` | 71f10cff | 2026-10-19 | Codex | 3/121 | 3/1440 | no | none | preservation branch |
| `archive/gauntlet-governance-acceptance-2026-10-19` | 3c3937f4 | 2026-10-19 | pemunson90-cmd | 28/223 | 28/1542 | no | none | preservation branch |
| `archive/gauntlet-program-audit-2026-10-19` | 715043c5 | 2026-10-19 | Codex | 8/3 | 1/1315 | no | none | preservation branch |
| `archive/workflow-v1-2026-10-31` | 543fd415 | 2026-10-30 | pemunson90-cmd | 1011/3 | 712/1023 | no | none | preservation branch |

## UNMERGED-STALE (62)

| Branch | Tip | Last commit | Author | Ahead/behind main | Ahead/behind claude/integration | Merged into | PR | Reason |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `audit/gauntlet-exhaustive-2026-10-19` | f7b4f90f | 2026-10-19 | pemunson90-cmd | 27/223 | 27/1542 | no | none | no PR; older than 10 days |
| `audit/handoff-guidance-20261022` | 855955b9 | 2026-10-23 | Claude | 387/3 | 88/1023 | no | #80 MERGED | PR #80 merged; tip has later or rewritten commits |
| `claude/arch1-orders-photo` | 220fa18d | 2026-10-23 | Codex | 502/3 | 8/828 | no | none | no PR; older than 10 days |
| `claude/arch1-orders-route` | ce4b4810 | 2026-10-23 | Codex | 500/3 | 6/828 | no | none | no PR; older than 10 days |
| `claude/arch1-orders-sensors` | 62c58e10 | 2026-10-23 | Codex | 498/3 | 4/828 | no | none | no PR; older than 10 days |
| `claude/arch1-orders-weapons` | 0c94966e | 2026-10-23 | Codex | 496/3 | 2/828 | no | none | no PR; older than 10 days |
| `claude/expedition-records` | 2fec92db | 2026-10-28 | pemunson90-cmd | 1006/1 | 1/315 | no | #204 CLOSED | PR #204 closed unmerged |
| `claude/landmarks-merge` | 17b45e53 | 2026-10-24 | pemunson90-cmd | 652/1 | 1/669 | no | none | no PR; older than 10 days |
| `claude/lane-c2-wip-b` | ca4e8528 | 2026-10-21 | Claude | 319/3 | 1/1004 | no | none | no PR; older than 10 days |
| `claude/lane-n1-calder` | 0b6c6e07 | 2026-10-21 | Claude | 316/3 | 1/1007 | no | none | no PR; older than 10 days |
| `claude/lane-p2-economy` | 82bcf572 | 2026-10-21 | Claude | 316/3 | 1/1007 | no | none | no PR; older than 10 days |
| `claude/lane-s1-inventory` | 40137f8b | 2026-10-21 | Claude | 283/3 | 1/1040 | no | none | no PR; older than 10 days |
| `claude/lane-s2-bible` | de3a1351 | 2026-10-21 | Claude | 283/3 | 1/1040 | no | none | no PR; older than 10 days |
| `claude/siren-reports` | df721dac | 2026-10-29 | pemunson90-cmd | 1087/1 | 3/236 | no | #220 CLOSED | PR #220 closed unmerged |
| `claude/sorley-rescue` | e757345a | 2026-10-28 | pemunson90-cmd | 999/1 | 1/322 | no | #201 CLOSED | PR #201 closed unmerged |
| `claude/thermal-one-band` | ab94dd85 | 2026-10-29 | pemunson90-cmd | 1083/1 | 2/239 | no | #219 CLOSED | PR #219 closed unmerged |
| `codex/closeout-057073068-reviewed` | febf813e | 2026-10-28 | pemunson90-cmd | 738/3 | 439/1023 | no | #197 CLOSED | PR #197 closed unmerged |
| `codex/closeout-089-reviewed` | 4dab4308 | 2026-10-28 | pemunson90-cmd | 763/3 | 464/1023 | no | #206 MERGED | PR #206 merged; tip has later or rewritten commits |
| `docs/playable-milestone-main-sync-20261019` | 1cb839f6 | 2026-10-19 | pemunson90-cmd | 1/2 | 1/1321 | no | #14 MERGED | PR #14 merged; tip has later or rewritten commits |
| `experiment/photo-intent-preview` | 2be2cfb9 | 2026-10-29 | pemunson90-cmd | 1072/1 | 1/249 | no | none | no PR; older than 10 days |
| `gauntlet/checkpoint/execute-2026-10-20` | fa0bb17e | 2026-10-21 | Patrick M | 130/3 | 36/1228 | no | none | no PR; older than 10 days |
| `gauntlet/checkpoint/pre-claude-guidance` | 66c88d19 | 2026-10-19 | Codex | 81/3 | 5/1246 | no | none | no PR; older than 10 days |
| `gauntlet/checkpoint/recovery-route-review-2026-10-20` | 8a6144ce | 2026-10-20 | Codex | 217/3 | 2/1107 | no | none | no PR; older than 10 days |
| `gauntlet/checkpoint/resolution-proof-detached` | 257cff3c | 2026-10-19 | Codex | 33/3 | 5/1294 | no | none | no PR; older than 10 days |
| `gauntlet/checkpoint/touch-play-2026-10-20` | 20339513 | 2026-10-20 | Codex | 109/3 | 15/1228 | no | none | no PR; older than 10 days |
| `gauntlet/docs/pause-2026-10-21` | 313ecda3 | 2026-10-21 | Patrick M | 281/3 | 1/1042 | no | #51 MERGED | PR #51 merged; tip has later or rewritten commits |
| `gauntlet/feature/blackwater-data-delivery` | 83cdc725 | 2026-10-20 | Codex | 181/3 | 4/1145 | no | none | no PR; older than 10 days |
| `gauntlet/feature/blackwater-delivery-ui` | a81d77a1 | 2026-10-20 | Codex | 182/3 | 7/1147 | no | none | no PR; older than 10 days |
| `gauntlet/feature/blind-passage-content` | 7fe12f82 | 2026-10-19 | Codex | 77/3 | 1/1246 | no | none | no PR; older than 10 days |
| `gauntlet/feature/blind-passage-main` | 166081fc | 2026-10-19 | Codex | 100/3 | 24/1246 | no | none | no PR; older than 10 days |
| `gauntlet/feature/briefing-scroll-fit` | 06db9f24 | 2026-10-20 | Codex | 183/3 | 1/1140 | no | none | no PR; older than 10 days |
| `gauntlet/feature/campaign-upgrades` | 3a0f02a2 | 2026-10-20 | Codex | 84/3 | 3/1241 | no | none | no PR; older than 10 days |
| `gauntlet/feature/confluence-world-art` | 3018495d | 2026-10-20 | Codex | 138/3 | 4/1188 | no | none | no PR; older than 10 days |
| `gauntlet/feature/craft-anchored-fleet` | 0f145880 | 2026-10-20 | Codex | 206/3 | 3/1119 | no | none | no PR; older than 10 days |
| `gauntlet/feature/deep-rendezvous-tender` | 79b54dca | 2026-10-20 | Codex | 162/3 | 3/1163 | no | none | no PR; older than 10 days |
| `gauntlet/feature/deep-rendezvous-ui` | ab509bd0 | 2026-10-20 | Codex | 166/3 | 3/1159 | no | none | no PR; older than 10 days |
| `gauntlet/feature/drone-operational-investigation` | d625e561 | 2026-10-19 | Codex | 1/213 | 1/1532 | no | none | no PR; older than 10 days |
| `gauntlet/feature/drone-recovery-ui` | 62a548e6 | 2026-10-20 | Codex | 161/3 | 4/1165 | no | none | no PR; older than 10 days |
| `gauntlet/feature/drone-thrust-prototype` | c1b96fc5 | 2026-10-19 | Codex | 1/196 | 1/1515 | no | none | no PR; older than 10 days |
| `gauntlet/feature/earned-chart-world` | 55bc0b06 | 2026-10-19 | Codex | 106/3 | 30/1246 | no | none | no PR; older than 10 days |
| `gauntlet/feature/earned-course-continuity` | b29cb839 | 2026-10-20 | Codex | 146/3 | 1/1177 | no | none | no PR; older than 10 days |
| `gauntlet/feature/earned-terrain-chart` | 71d8fc23 | 2026-10-19 | Codex | 101/3 | 25/1246 | no | none | no PR; older than 10 days |
| `gauntlet/feature/live-fitting-identity` | aeeb5b0e | 2026-10-20 | Codex | 207/3 | 1/1116 | no | none | no PR; older than 10 days |
| `gauntlet/feature/observed-task-controls` | 8f7978b8 | 2026-10-19 | Codex | 81/3 | 8/1249 | no | none | no PR; older than 10 days |
| `gauntlet/feature/observed-task-execution` | 09e458ea | 2026-10-19 | Codex | 82/3 | 6/1246 | no | none | no PR; older than 10 days |
| `gauntlet/feature/physical-module-recovery` | ae33fc0d | 2026-10-20 | Codex | 160/3 | 3/1165 | no | none | no PR; older than 10 days |
| `gauntlet/feature/planner-chart-context` | 975d513c | 2026-10-20 | Codex | 197/3 | 2/1127 | no | none | no PR; older than 10 days |
| `gauntlet/feature/planner-chart-navigation` | 8e130431 | 2026-10-19 | Codex | 1/126 | 1/1445 | no | none | no PR; older than 10 days |
| `gauntlet/feature/recovery-route-intent` | 09b66ea0 | 2026-10-20 | Codex | 216/3 | 2/1108 | no | none | no PR; older than 10 days |
| `gauntlet/feature/route-first-telemetry` | b4f575de | 2026-10-20 | Codex | 177/3 | 2/1147 | no | none | no PR; older than 10 days |
| `gauntlet/feature/v7-currents` | 8767b85d | 2026-10-20 | Codex | 101/3 | 5/1226 | no | none | no PR; older than 10 days |
| `gauntlet/feature/warning-chain-plant` | 9ec99314 | 2026-10-20 | Codex | 194/3 | 3/1131 | no | none | no PR; older than 10 days |
| `gauntlet/feature/warning-chain-ui` | 2111a211 | 2026-10-20 | Codex | 200/3 | 5/1127 | no | none | no PR; older than 10 days |
| `gauntlet/feature/witness-evacuation` | 72a22bc8 | 2026-10-20 | Codex | 216/3 | 2/1108 | no | none | no PR; older than 10 days |
| `gauntlet/fix/save-tick-phase` | 640e3990 | 2026-10-19 | Codex | 82/3 | 6/1246 | no | none | no PR; older than 10 days |
| `gauntlet/review/blind-passage-main-play` | 4bc2746e | 2026-10-19 | Codex | 101/3 | 25/1246 | no | none | no PR; older than 10 days |
| `gauntlet/review/observed-task-and-save` | 49fb5941 | 2026-10-19 | Codex | 98/3 | 22/1246 | no | none | no PR; older than 10 days |
| `maintenance/gauntlet-audit-retirement-2026-10-19` | de6d671c | 2026-10-19 | pemunson90-cmd | 1/47 | 1/1366 | no | #4 CLOSED | PR #4 closed unmerged |
| `maintenance/gauntlet-default-branch-sync-20261019` | 84b72247 | 2026-10-19 | pemunson90-cmd | 4/405 | 4/1724 | no | #1 MERGED | PR #1 merged; tip has later or rewritten commits |
| `maintenance/gauntlet-staleness-continuity-20261019` | 74dc6669 | 2026-10-19 | pemunson90-cmd | 14/78 | 14/1397 | no | #2 MERGED | PR #2 merged; tip has later or rewritten commits |
| `maintenance/main-gauntlet-check-bootstrap-20261019` | 50dd9878 | 2026-10-19 | pemunson90-cmd | 3/404 | 3/1723 | no | #3 MERGED | PR #3 merged; tip has later or rewritten commits |
| `policy/preserve-working-features-20261101` | c6d7d362 | 2026-11-01 | pemunson90-cmd | 2/1 | 2/1320 | no | #260 MERGED | PR #260 merged; tip has later or rewritten commits |

## MERGED (279)

| Branch | Tip | Last commit | Author | Ahead/behind main | Ahead/behind claude/integration | Merged into | PR | Reason |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `archive/gauntlet-evidence-2026-10-19` | a855cc1d | 2026-10-19 | Codex | 0/121 | 0/1440 | main | none | tip is in main |
| `archive/gauntlet-evidence-2026-10-19-stage2` | 522c801d | 2026-10-19 | pemunson90-cmd | 0/109 | 0/1428 | main | none | tip is in main |
| `archive/reference-package-20261022` | 70894702 | 2026-10-22 | pemunson90-cmd | 474/3 | 0/848 | claude/integration | none | tip is in claude/integration |
| `audit/guidance-reconciliation-20261022` | f651b099 | 2026-10-23 | Claude | 496/3 | 0/826 | claude/integration | #79 MERGED | tip is in claude/integration |
| `audit/recon-cargo-fixes-20261022` | 73f670ef | 2026-10-23 | Claude | 485/3 | 0/837 | claude/integration | #77 MERGED | tip is in claude/integration |
| `ccr-de2814d6-7im23r` | 2f154f2f | 2026-10-24 | Claude | 567/3 | 0/755 | claude/integration | #97 MERGED | tip is in claude/integration |
| `checkpoint/patrol-recovery-8d8635a` | 8d8635aa | 2026-10-19 | pemunson90-cmd | 0/335 | 0/1654 | main | none | tip is in main |
| `claude/accessibility-autopause-mirror` | 9c02f483 | 2026-10-29 | pemunson90-cmd | 1109/1 | 0/211 | claude/integration | #226 MERGED | tip is in claude/integration |
| `claude/arc-beats` | bfad04e1 | 2026-10-28 | pemunson90-cmd | 999/1 | 0/321 | claude/integration | #203 MERGED | tip is in claude/integration |
| `claude/arc5-second-fork` | c86738d8 | 2026-10-29 | pemunson90-cmd | 1098/1 | 0/222 | claude/integration | #224 MERGED | tip is in claude/integration |
| `claude/arch1-cancel-helper` | faff74e4 | 2026-10-23 | Codex | 478/3 | 0/844 | claude/integration | #83 MERGED | tip is in claude/integration |
| `claude/arch1-photo-final` | a4211404 | 2026-10-23 | Codex | 538/3 | 0/784 | claude/integration | #92 MERGED | tip is in claude/integration |
| `claude/arch1-route-final` | c86f8c9d | 2026-10-23 | Codex | 533/3 | 0/789 | claude/integration | #91 MERGED | tip is in claude/integration |
| `claude/arch1-save-checks` | c7c5cfd9 | 2026-10-23 | Codex | 475/3 | 0/847 | claude/integration | #81 MERGED | tip is in claude/integration |
| `claude/arch1-sensors-final` | c2d2876f | 2026-10-23 | Codex | 529/3 | 0/793 | claude/integration | #90 MERGED | tip is in claude/integration |
| `claude/arch1-weapons-final` | 9c9eef07 | 2026-10-23 | Codex | 504/3 | 0/818 | claude/integration | #88 MERGED | tip is in claude/integration |
| `claude/audit-attribution-keystore` | 75c2e099 | 2026-10-23 | Claude | 476/3 | 0/846 | claude/integration | #82 MERGED | tip is in claude/integration |
| `claude/audit-navigation` | 6cab6d06 | 2026-10-30 | pemunson90-cmd | 1142/1 | 0/178 | claude/integration | #233 MERGED | tip is in claude/integration |
| `claude/audit-orders` | d9621fe2 | 2026-10-29 | pemunson90-cmd | 1125/1 | 0/195 | claude/integration | #230 MERGED | tip is in claude/integration |
| `claude/audit-photo-evidence` | 2fea22ce | 2026-10-30 | pemunson90-cmd | 1138/1 | 0/182 | claude/integration | #232 MERGED | tip is in claude/integration |
| `claude/audit-readability` | cea03030 | 2026-10-30 | pemunson90-cmd | 1160/1 | 0/160 | claude/integration | #229 MERGED | tip is in claude/integration |
| `claude/authored-ending` | ccc92a4c | 2026-10-30 | pemunson90-cmd | 1167/1 | 0/153 | claude/integration | #237 MERGED | tip is in claude/integration |
| `claude/batch-merge-20261024` | 839e59b0 | 2026-10-24 | pemunson90-cmd | 738/1 | 0/582 | claude/integration | #140 MERGED | tip is in claude/integration |
| `claude/branch-ledger-20261024` | 39ee5b58 | 2026-10-23 | pemunson90-cmd | 586/1 | 0/734 | claude/integration | #106 MERGED | tip is in claude/integration |
| `claude/c0-finish-directive` | e884819d | 2026-10-26 | pemunson90-cmd | 778/1 | 0/542 | claude/integration | #149 MERGED | tip is in claude/integration |
| `claude/c0-owner-questions-20261027` | 832dd104 | 2026-10-27 | pemunson90-cmd | 811/1 | 0/509 | claude/integration | #161 MERGED | tip is in claude/integration |
| `claude/c0-resume-20261027` | 50a22821 | 2026-10-27 | pemunson90-cmd | 807/1 | 0/513 | claude/integration | #155 MERGED | tip is in claude/integration |
| `claude/c1-economy` | 710f8909 | 2026-10-27 | pemunson90-cmd | 802/1 | 0/518 | claude/integration | #151 MERGED | tip is in claude/integration |
| `claude/c10-archive-log` | 47bf667e | 2026-10-27 | pemunson90-cmd | 815/1 | 0/505 | claude/integration | #160 MERGED | tip is in claude/integration |
| `claude/c11-arc6-capstone` | 306d886d | 2026-10-28 | pemunson90-cmd | 895/1 | 0/425 | claude/integration | #165 MERGED | tip is in claude/integration |
| `claude/c12-route-carry` | eea9d7e5 | 2026-10-28 | pemunson90-cmd | 839/1 | 0/481 | claude/integration | #166 MERGED | tip is in claude/integration |
| `claude/c13-ledger` | a5795832 | 2026-10-28 | pemunson90-cmd | 852/1 | 0/468 | claude/integration | #170 MERGED | tip is in claude/integration |
| `claude/c14-ironman` | 67c6da10 | 2026-10-28 | pemunson90-cmd | 857/1 | 0/463 | claude/integration | #168 MERGED | tip is in claude/integration |
| `claude/c15-settings-depth` | f99fa5a9 | 2026-10-28 | pemunson90-cmd | 940/1 | 0/380 | claude/integration | #174 MERGED | tip is in claude/integration |
| `claude/c16-crew-effects` | e4241b35 | 2026-10-28 | pemunson90-cmd | 926/1 | 0/394 | claude/integration | #173 MERGED | tip is in claude/integration |
| `claude/c17-tool-cues` | 28af3440 | 2026-10-28 | pemunson90-cmd | 880/1 | 0/440 | claude/integration | #177 MERGED | tip is in claude/integration |
| `claude/c18-fit-surface` | 8bfa330a | 2026-10-28 | pemunson90-cmd | 892/1 | 0/428 | claude/integration | #178 MERGED | tip is in claude/integration |
| `claude/c19-profile-transfer` | 6eff9038 | 2026-10-28 | pemunson90-cmd | 925/1 | 0/395 | claude/integration | #176 MERGED | tip is in claude/integration |
| `claude/c2-equipment` | cbff4e05 | 2026-10-28 | pemunson90-cmd | 868/1 | 0/452 | claude/integration | #150 MERGED | tip is in claude/integration |
| `claude/c3-modes` | 45991efb | 2026-10-28 | pemunson90-cmd | 944/1 | 0/376 | claude/integration | #175 MERGED | tip is in claude/integration |
| `claude/c4-career` | 6e926433 | 2026-10-28 | pemunson90-cmd | 957/1 | 0/363 | claude/integration | #190 MERGED | tip is in claude/integration |
| `claude/c5-settings` | a8a0a88a | 2026-10-28 | pemunson90-cmd | 832/1 | 0/488 | claude/integration | #163 MERGED | tip is in claude/integration |
| `claude/c6-doc-sweep` | 0b29bab9 | 2026-10-27 | pemunson90-cmd | 809/1 | 0/511 | claude/integration | #156 MERGED | tip is in claude/integration |
| `claude/c7-economy-calibration` | 3848ef2a | 2026-10-27 | pemunson90-cmd | 822/1 | 0/498 | claude/integration | #157 MERGED | tip is in claude/integration |
| `claude/c8-challenge-pars` | 23279a85 | 2026-10-27 | pemunson90-cmd | 811/1 | 0/509 | claude/integration | #158 MERGED | tip is in claude/integration |
| `claude/c9-event-audio` | b7b88adb | 2026-10-27 | pemunson90-cmd | 823/1 | 0/497 | claude/integration | #159 MERGED | tip is in claude/integration |
| `claude/campaign-m1` | fad2eba9 | 2026-10-23 | Codex | 562/3 | 0/760 | claude/integration | #85 MERGED | tip is in claude/integration |
| `claude/codex-085-arc6-carry` | 236aef01 | 2026-10-28 | pemunson90-cmd | 938/1 | 0/382 | claude/integration | #185 MERGED | tip is in claude/integration |
| `claude/codex-086-rescue-facts` | 45c58750 | 2026-10-28 | pemunson90-cmd | 938/1 | 0/382 | claude/integration | #186 MERGED | tip is in claude/integration |
| `claude/codex-087-directives` | 209800ce | 2026-10-28 | pemunson90-cmd | 938/1 | 0/382 | claude/integration | #187 MERGED | tip is in claude/integration |
| `claude/codex-088-late-ending` | ae1c1506 | 2026-10-28 | pemunson90-cmd | 970/1 | 0/350 | claude/integration | #193 MERGED | tip is in claude/integration |
| `claude/codex-089-earned-chart` | 1860c7d8 | 2026-10-28 | pemunson90-cmd | 976/1 | 0/344 | claude/integration | #191 MERGED | tip is in claude/integration |
| `claude/debug-console` | b71ea197 | 2026-10-28 | pemunson90-cmd | 1037/1 | 0/283 | claude/integration | #210 MERGED | tip is in claude/integration |
| `claude/depth1` | f2278c3b | 2026-10-22 | Claude | 439/3 | 0/883 | claude/integration | #74 MERGED | tip is in claude/integration |
| `claude/desktop-handoff-20261023` | 632f5921 | 2026-10-24 | Codex | 574/3 | 0/748 | claude/integration | #98 MERGED | tip is in claude/integration |
| `claude/directive-independent-review-20261028` | a218086a | 2026-10-28 | pemunson90-cmd | 907/1 | 0/413 | claude/integration | #181 MERGED | tip is in claude/integration |
| `claude/directives-23oct` | 5db48029 | 2026-10-23 | Claude | 477/3 | 0/845 | claude/integration | #84 MERGED | tip is in claude/integration |
| `claude/diver-ascent` | f24e0df0 | 2026-10-29 | pemunson90-cmd | 1070/1 | 0/250 | claude/integration | #214 MERGED | tip is in claude/integration |
| `claude/docs-accepted-ending-ruling` | 39838d5e | 2026-10-28 | pemunson90-cmd | 980/1 | 0/340 | claude/integration | #205 MERGED | tip is in claude/integration |
| `claude/docs-career-quality-status` | 7286aeaf | 2026-10-28 | pemunson90-cmd | 965/1 | 0/355 | claude/integration | #196 MERGED | tip is in claude/integration |
| `claude/docs-current-game-closeout-v2` | 914f6773 | 2026-10-28 | pemunson90-cmd | 956/1 | 0/364 | claude/integration | #188 MERGED | tip is in claude/integration |
| `claude/early-module-reward` | 76e78d31 | 2026-10-23 | Codex | 548/3 | 0/774 | claude/integration | #94 MERGED | tip is in claude/integration |
| `claude/economy-advanced` | ae3990c0 | 2026-10-29 | pemunson90-cmd | 1074/1 | 0/246 | claude/integration | #217 MERGED | tip is in claude/integration |
| `claude/ending-m3b` | 2fe6459b | 2026-10-24 | pemunson90-cmd | 662/1 | 0/658 | claude/integration | #122 MERGED | tip is in claude/integration |
| `claude/first-siren-cue` | a0f5cbae | 2026-10-23 | Codex | 543/3 | 0/779 | claude/integration | #93 MERGED | tip is in claude/integration |
| `claude/fix-silt-camera-parity` | c5bd45a5 | 2026-10-28 | pemunson90-cmd | 889/1 | 0/431 | claude/integration | #180 MERGED | tip is in claude/integration |
| `claude/fix1-cold-review-2` | 9a7180ac | 2026-10-23 | Patrick M | 473/3 | 0/849 | claude/integration | #78 MERGED | tip is in claude/integration |
| `claude/fix2-cold-review-full` | fd2224af | 2026-10-23 | Codex | 518/3 | 0/804 | claude/integration | #86 MERGED | tip is in claude/integration |
| `claude/fleet-fix-calder` | 76e98aba | 2026-10-28 | pemunson90-cmd | 989/1 | 0/331 | claude/integration | #202 MERGED | tip is in claude/integration |
| `claude/fleet-fix-glass` | 464e58ae | 2026-10-28 | pemunson90-cmd | 1053/1 | 0/267 | claude/integration | #209 MERGED | tip is in claude/integration |
| `claude/fleet-fix-iron-choir` | 180d5e9f | 2026-10-28 | pemunson90-cmd | 1045/1 | 0/275 | claude/integration | #198 MERGED | tip is in claude/integration |
| `claude/foundation-cleanup` | 00935696 | 2026-10-29 | pemunson90-cmd | 1095/1 | 0/225 | claude/integration | #223 MERGED | tip is in claude/integration |
| `claude/future-siren-active-sonar-sweeper` | d09378c4 | 2026-10-21 | Claude | 316/3 | 0/1006 | claude/integration | none | tip is in claude/integration |
| `claude/gauntlet-root-orchestrator-1paufv` | 70894702 | 2026-10-22 | pemunson90-cmd | 474/3 | 0/848 | claude/integration | none | tip is in claude/integration |
| `claude/grade-on-secure` | f7a7ea3b | 2026-10-23 | Claude | 499/3 | 0/823 | claude/integration | #89 MERGED | tip is in claude/integration |
| `claude/human-test-readiness` | 0abdc177 | 2026-10-24 | pemunson90-cmd | 711/1 | 0/609 | claude/integration | #131 MERGED | tip is in claude/integration |
| `claude/hunt-restore-design` | 8326fad0 | 2026-10-24 | pemunson90-cmd | 590/1 | 0/730 | claude/integration | #114 MERGED | tip is in claude/integration |
| `claude/integrate-tools-rescue` | 951f8e00 | 2026-10-28 | pemunson90-cmd | 1028/1 | 0/292 | claude/integration | #207 MERGED | tip is in claude/integration |
| `claude/ironman-losses` | dba83f79 | 2026-10-29 | pemunson90-cmd | 1072/1 | 0/248 | claude/integration | #215 MERGED | tip is in claude/integration |
| `claude/landmarks-current-merge` | aaff40ea | 2026-10-24 | pemunson90-cmd | 658/1 | 0/662 | claude/integration | none | tip is in claude/integration |
| `claude/lane-a11y1` | ec23bc68 | 2026-10-24 | pemunson90-cmd | 682/1 | 0/638 | claude/integration | #127 MERGED | tip is in claude/integration |
| `claude/lane-ai-trace` | 4bc52bbe | 2026-10-24 | pemunson90-cmd | 698/1 | 0/622 | claude/integration | #129 MERGED | tip is in claude/integration |
| `claude/lane-alien-interactions` | ef2606d1 | 2026-10-28 | pemunson90-cmd | 924/1 | 0/396 | claude/integration | #183 MERGED | tip is in claude/integration |
| `claude/lane-arch2-campaign-flow` | 3afb12f9 | 2026-10-24 | Codex | 567/3 | 0/755 | claude/integration | #96 MERGED | tip is in claude/integration |
| `claude/lane-arch2-concealed-view` | 158c1fcd | 2026-10-24 | pemunson90-cmd | 630/1 | 0/690 | claude/integration | #113 MERGED | tip is in claude/integration |
| `claude/lane-arch2-courier-view` | ca133c52 | 2026-10-24 | pemunson90-cmd | 637/1 | 0/683 | claude/integration | #117 MERGED | tip is in claude/integration |
| `claude/lane-arch2-delivery-view` | a41f16f1 | 2026-10-24 | pemunson90-cmd | 624/1 | 0/696 | claude/integration | #110 MERGED | tip is in claude/integration |
| `claude/lane-arch2-expedition-view` | afb9485c | 2026-10-24 | pemunson90-cmd | 640/1 | 0/680 | claude/integration | #118 MERGED | tip is in claude/integration |
| `claude/lane-arch2-industrial-view` | 96f15a59 | 2026-10-24 | pemunson90-cmd | 646/1 | 0/674 | claude/integration | #120 MERGED | tip is in claude/integration |
| `claude/lane-arch2-merge-sequence` | 8c13f5be | 2026-10-24 | pemunson90-cmd | 647/1 | 0/673 | claude/integration | none | tip is in claude/integration |
| `claude/lane-arch2-photo-review` | c6440abc | 2026-10-24 | pemunson90-cmd | 602/1 | 0/718 | claude/integration | #100 MERGED | tip is in claude/integration |
| `claude/lane-arch2-recipient-view` | 667ec823 | 2026-10-24 | pemunson90-cmd | 627/1 | 0/693 | claude/integration | #111 MERGED | tip is in claude/integration |
| `claude/lane-arch2-recovery-view` | 8ea8180f | 2026-10-24 | pemunson90-cmd | 643/1 | 0/677 | claude/integration | #119 MERGED | tip is in claude/integration |
| `claude/lane-arch2-rendezvous-view` | 99a1df8c | 2026-10-24 | pemunson90-cmd | 614/1 | 0/706 | claude/integration | #104 MERGED | tip is in claude/integration |
| `claude/lane-arch2-shelf-view` | e69609de | 2026-10-24 | pemunson90-cmd | 618/1 | 0/702 | claude/integration | #108 MERGED | tip is in claude/integration |
| `claude/lane-arch2-ui-metrics` | aafa21e9 | 2026-10-24 | pemunson90-cmd | 607/1 | 0/713 | claude/integration | #101 MERGED | tip is in claude/integration |
| `claude/lane-arch2-wake-view` | 0f2b3882 | 2026-10-24 | pemunson90-cmd | 611/1 | 0/709 | claude/integration | #102 MERGED | tip is in claude/integration |
| `claude/lane-arch2-warning-chain-view` | c8ccf309 | 2026-10-24 | pemunson90-cmd | 621/1 | 0/699 | claude/integration | #109 MERGED | tip is in claude/integration |
| `claude/lane-arch2-witness-view` | 331f061c | 2026-10-24 | pemunson90-cmd | 634/1 | 0/686 | claude/integration | #115 MERGED | tip is in claude/integration |
| `claude/lane-art1` | 093e8a15 | 2026-10-24 | pemunson90-cmd | 707/1 | 0/613 | claude/integration | #130 MERGED | tip is in claude/integration |
| `claude/lane-audio-photo` | 9b2f665e | 2026-10-23 | Codex | 525/3 | 0/797 | claude/integration | #87 MERGED | tip is in claude/integration |
| `claude/lane-back-exit` | 3d157f8c | 2026-10-24 | pemunson90-cmd | 676/1 | 0/644 | claude/integration | #125 MERGED | tip is in claude/integration |
| `claude/lane-c1-glass` | 7a5c4ee4 | 2026-10-21 | Claude | 285/3 | 0/1037 | claude/integration | #55 MERGED | tip is in claude/integration |
| `claude/lane-c2-iron` | 853331e4 | 2026-10-22 | Claude | 351/3 | 0/971 | claude/integration | #63 MERGED | tip is in claude/integration |
| `claude/lane-calder-trench` | 4af007a7 | 2026-10-26 | pemunson90-cmd | 791/1 | 0/529 | claude/integration | #152 MERGED | tip is in claude/integration |
| `claude/lane-career-riders-complete` | d008d7ba | 2026-10-28 | pemunson90-cmd | 970/1 | 0/350 | claude/integration | #200 MERGED | tip is in claude/integration |
| `claude/lane-challenge-completions` | fd8e43a3 | 2026-10-24 | pemunson90-cmd | 727/1 | 0/593 | claude/integration | #138 MERGED | tip is in claude/integration |
| `claude/lane-challenge-mode` | 5043a993 | 2026-10-22 | Patrick M | 428/3 | 0/894 | claude/integration | #72 MERGED | tip is in claude/integration |
| `claude/lane-chart-accessibility` | 64e313ba | 2026-10-28 | pemunson90-cmd | 892/1 | 0/428 | claude/integration | #171 MERGED | tip is in claude/integration |
| `claude/lane-ci-shards` | 94835a77 | 2026-10-28 | pemunson90-cmd | 881/1 | 0/439 | claude/integration | #172 MERGED | tip is in claude/integration |
| `claude/lane-consequence-lines` | 92358533 | 2026-10-24 | pemunson90-cmd | 690/1 | 0/630 | claude/integration | #126 MERGED | tip is in claude/integration |
| `claude/lane-controls-friction` | f71370ca | 2026-10-22 | Patrick M | 420/3 | 0/902 | claude/integration | #71 MERGED | tip is in claude/integration |
| `claude/lane-cue-ext` | eb2bd298 | 2026-10-24 | pemunson90-cmd | 727/1 | 0/593 | claude/integration | #134 MERGED | tip is in claude/integration |
| `claude/lane-death-cause` | b7ba025c | 2026-10-24 | pemunson90-cmd | 727/1 | 0/593 | claude/integration | #135 MERGED | tip is in claude/integration |
| `claude/lane-docs1` | e0c6e8f6 | 2026-10-25 | pemunson90-cmd | 772/1 | 0/548 | claude/integration | #145 MERGED | tip is in claude/integration |
| `claude/lane-early-rewards-2` | 6e53c484 | 2026-10-24 | pemunson90-cmd | 726/1 | 0/594 | claude/integration | #137 MERGED | tip is in claude/integration |
| `claude/lane-f1-frontend` | f22c9a19 | 2026-10-22 | Claude | 328/3 | 0/994 | claude/integration | #61 MERGED | tip is in claude/integration |
| `claude/lane-finale-provisional` | 091f529e | 2026-10-25 | pemunson90-cmd | 757/1 | 0/563 | claude/integration | #142 MERGED | tip is in claude/integration |
| `claude/lane-fleet-sites` | d5eb74b8 | 2026-10-28 | pemunson90-cmd | 914/1 | 0/406 | claude/integration | #169 MERGED | tip is in claude/integration |
| `claude/lane-free-zone-tests` | 3030654f | 2026-10-24 | pemunson90-cmd | 716/1 | 0/604 | claude/integration | #132 MERGED | tip is in claude/integration |
| `claude/lane-hud-sameness` | e1dbc026 | 2026-10-25 | pemunson90-cmd | 776/1 | 0/544 | claude/integration | #146 MERGED | tip is in claude/integration |
| `claude/lane-hunt-restore` | a468bf8d | 2026-10-26 | pemunson90-cmd | 788/1 | 0/532 | claude/integration | #147 MERGED | tip is in claude/integration |
| `claude/lane-k-combat` | f1ed21ac | 2026-10-22 | Codex | 355/3 | 0/967 | claude/integration | #64 MERGED | tip is in claude/integration |
| `claude/lane-landmarks` | 757347bc | 2026-10-24 | pemunson90-cmd | 657/1 | 0/663 | claude/integration | #121 MERGED | tip is in claude/integration |
| `claude/lane-late-teaching` | b6e5b66f | 2026-10-28 | pemunson90-cmd | 970/1 | 0/350 | claude/integration | #195 MERGED | tip is in claude/integration |
| `claude/lane-lock-warning-readability` | 2b6f3253 | 2026-10-22 | Patrick M | 396/3 | 0/926 | claude/integration | #68 MERGED | tip is in claude/integration |
| `claude/lane-menu-reach` | c991a00e | 2026-10-25 | pemunson90-cmd | 752/1 | 0/568 | claude/integration | #141 MERGED | tip is in claude/integration |
| `claude/lane-mode-resume` | fede2d11 | 2026-10-28 | pemunson90-cmd | 1059/1 | 0/261 | claude/integration | #211 MERGED | tip is in claude/integration |
| `claude/lane-nav-clearance` | ecfd4ef1 | 2026-10-22 | Patrick M | 454/3 | 0/868 | claude/integration | #75 MERGED | tip is in claude/integration |
| `claude/lane-onboard2` | 053c1ae5 | 2026-10-24 | pemunson90-cmd | 666/1 | 0/654 | claude/integration | #123 MERGED | tip is in claude/integration |
| `claude/lane-ops-home` | 331f5cf1 | 2026-10-24 | pemunson90-cmd | 746/1 | 0/574 | claude/integration | #136 MERGED | tip is in claude/integration |
| `claude/lane-optional-geometry` | 4435db13 | 2026-10-28 | pemunson90-cmd | 827/1 | 0/493 | claude/integration | #162 MERGED | tip is in claude/integration |
| `claude/lane-optional-ops` | ed45b49e | 2026-10-26 | pemunson90-cmd | 793/1 | 0/527 | claude/integration | #153 MERGED | tip is in claude/integration |
| `claude/lane-p1-fittings` | 84a83f1f | 2026-10-21 | Claude | 306/3 | 0/1016 | claude/integration | #57 MERGED | tip is in claude/integration |
| `claude/lane-perf-lowcollision` | b8293e38 | 2026-10-24 | pemunson90-cmd | 723/1 | 0/597 | claude/integration | #133 MERGED | tip is in claude/integration |
| `claude/lane-performance-2` | e161619c | 2026-10-28 | pemunson90-cmd | 924/1 | 0/396 | claude/integration | #184 MERGED | tip is in claude/integration |
| `claude/lane-performance-and-leaks` | 9899a2c0 | 2026-10-22 | Patrick M | 431/3 | 0/891 | claude/integration | #73 MERGED | tip is in claude/integration |
| `claude/lane-photo-row-journeys` | 44a168d6 | 2026-10-25 | pemunson90-cmd | 770/1 | 0/550 | claude/integration | #144 MERGED | tip is in claude/integration |
| `claude/lane-quality-tier` | 4c28838b | 2026-10-28 | pemunson90-cmd | 956/1 | 0/364 | claude/integration | #189 MERGED | tip is in claude/integration |
| `claude/lane-r1-rules` | 7aa88ff9 | 2026-10-21 | Claude | 316/3 | 0/1006 | claude/integration | #60 MERGED | tip is in claude/integration |
| `claude/lane-regional-presentation` | 1d24364e | 2026-10-27 | pemunson90-cmd | 796/1 | 0/524 | claude/integration | #154 MERGED | tip is in claude/integration |
| `claude/lane-route-map` | 65260dad | 2026-10-23 | Codex | 565/3 | 0/757 | claude/integration | #95 MERGED | tip is in claude/integration |
| `claude/lane-run-offers` | ff3a9e4c | 2026-10-28 | pemunson90-cmd | 956/1 | 0/364 | claude/integration | #192 MERGED | tip is in claude/integration |
| `claude/lane-s3-rewrite` | 812fc075 | 2026-10-21 | Claude | 321/3 | 0/1001 | claude/integration | #56 MERGED | tip is in claude/integration |
| `claude/lane-s3b-text` | e7a8995c | 2026-10-22 | Claude | 333/3 | 0/989 | claude/integration | #62 MERGED | tip is in claude/integration |
| `claude/lane-save-profiles` | 9f3a1e41 | 2026-10-24 | pemunson90-cmd | 672/1 | 0/648 | claude/integration | #124 MERGED | tip is in claude/integration |
| `claude/lane-save2` | 080add0a | 2026-10-25 | pemunson90-cmd | 765/1 | 0/555 | claude/integration | #143 MERGED | tip is in claude/integration |
| `claude/lane-siren-dossier` | 3fb0c299 | 2026-10-28 | pemunson90-cmd | 865/1 | 0/455 | claude/integration | #164 MERGED | tip is in claude/integration |
| `claude/lane-sweeper-patrols` | 3f1d8d15 | 2026-10-24 | pemunson90-cmd | 651/1 | 0/669 | claude/integration | #116 MERGED | tip is in claude/integration |
| `claude/lane-t-pressure` | 897f49f7 | 2026-10-21 | Codex | 295/3 | 0/1027 | claude/integration | #58 MERGED | tip is in claude/integration |
| `claude/lane-t2-sonar-bearing` | e1d906cc | 2026-10-21 | Codex | 300/3 | 0/1022 | claude/integration | #59 MERGED | tip is in claude/integration |
| `claude/lane-t2-sweeper` | 3d7da2da | 2026-10-22 | Patrick M | 417/3 | 0/905 | claude/integration | #70 MERGED | tip is in claude/integration |
| `claude/lane-test-registry` | 6564bb4e | 2026-10-23 | Patrick M | 464/3 | 0/858 | claude/integration | #76 MERGED | tip is in claude/integration |
| `claude/lane-win-tooling` | f1296416 | 2026-10-24 | pemunson90-cmd | 693/1 | 0/627 | claude/integration | #128 MERGED | tip is in claude/integration |
| `claude/lane-x2-probes` | 5252ef4b | 2026-10-21 | Patrick M | 284/3 | 0/1038 | claude/integration | #53 MERGED | tip is in claude/integration |
| `claude/lane-x3-audio` | 4ba9894a | 2026-10-21 | Patrick M | 285/3 | 0/1037 | claude/integration | #54 MERGED | tip is in claude/integration |
| `claude/lane-x4-seam` | d3c5028c | 2026-10-21 | Patrick M | 284/3 | 0/1038 | claude/integration | #52 MERGED | tip is in claude/integration |
| `claude/onboard1` | 74210941 | 2026-10-22 | Claude | 384/3 | 0/938 | claude/integration | #66 MERGED | tip is in claude/integration |
| `claude/photo1-recon` | b9bff6b4 | 2026-10-22 | Claude | 380/3 | 0/942 | claude/integration | #65 MERGED | tip is in claude/integration |
| `claude/photo2-images` | def58f72 | 2026-10-22 | Claude | 392/3 | 0/930 | claude/integration | #67 MERGED | tip is in claude/integration |
| `claude/presentation-pass` | c1bb63c6 | 2026-10-29 | pemunson90-cmd | 1102/1 | 0/218 | claude/integration | #225 MERGED | tip is in claude/integration |
| `claude/priced1` | f4a9f5db | 2026-10-22 | Patrick M | 407/3 | 0/915 | claude/integration | #69 MERGED | tip is in claude/integration |
| `claude/profiles-current-merge` | d131ca0b | 2026-10-24 | pemunson90-cmd | 673/1 | 0/647 | claude/integration | none | tip is in claude/integration |
| `claude/radio-ops` | 858f6019 | 2026-10-30 | pemunson90-cmd | 1132/1 | 0/188 | claude/integration | #231 MERGED | tip is in claude/integration |
| `claude/reconcile-early-content` | b6f07853 | 2026-10-29 | pemunson90-cmd | 1068/1 | 0/252 | claude/integration | #212 MERGED | tip is in claude/integration |
| `claude/reconcile-main-20261024` | 82bf4eef | 2026-10-23 | pemunson90-cmd | 578/1 | 0/742 | claude/integration | #107 MERGED | tip is in claude/integration |
| `claude/release-reconciliation-plan` | 36dd6d12 | 2026-10-23 | pemunson90-cmd | 582/1 | 0/738 | claude/integration | #105 MERGED | tip is in claude/integration |
| `claude/resume-refresh-20261024` | b5721b3d | 2026-10-23 | pemunson90-cmd | 576/3 | 0/746 | claude/integration | #103 MERGED | tip is in claude/integration |
| `claude/role-senses` | 7210e36f | 2026-10-29 | pemunson90-cmd | 1080/1 | 0/240 | claude/integration | #216 MERGED | tip is in claude/integration |
| `claude/s8-pr-audit-cleanup` | ffa497fd | 2026-10-30 | pemunson90-cmd | 1162/1 | 0/158 | claude/integration | #235 MERGED | tip is in claude/integration |
| `claude/seed-siren-shuffle` | c74dedbb | 2026-10-29 | pemunson90-cmd | 1085/1 | 0/235 | claude/integration | #221 MERGED | tip is in claude/integration |
| `claude/sonar-coarse-class` | 646e254a | 2026-10-29 | pemunson90-cmd | 1090/1 | 0/230 | claude/integration | #222 MERGED | tip is in claude/integration |
| `claude/sorley-pilotage-charts` | b8b5f25e | 2026-10-29 | pemunson90-cmd | 1083/1 | 0/237 | claude/integration | #218 MERGED | tip is in claude/integration |
| `claude/stealth-ai-roadmap` | 632e9954 | 2026-10-23 | pemunson90-cmd | 588/1 | 0/732 | claude/integration | #112 MERGED | tip is in claude/integration |
| `claude/thermal-ops` | 8e5b9c40 | 2026-10-29 | pemunson90-cmd | 1120/1 | 0/200 | claude/integration | #227 MERGED | tip is in claude/integration |
| `claude/tool-cargo-all-modes` | 0559ccd1 | 2026-10-29 | pemunson90-cmd | 1113/1 | 0/207 | claude/integration | #228 MERGED | tip is in claude/integration |
| `claude/tool-lockers` | bad644d3 | 2026-10-28 | pemunson90-cmd | 1032/1 | 0/288 | claude/integration | #208 MERGED | tip is in claude/integration |
| `claude/tools-cost-cargo` | 268f3e29 | 2026-10-28 | pemunson90-cmd | 1000/1 | 0/320 | claude/integration | #199 MERGED | tip is in claude/integration |
| `claude/truthful-commands` | 75f59cd6 | 2026-10-31 | pemunson90-cmd | 1175/1 | 0/145 | claude/integration | #238 MERGED | tip is in claude/integration |
| `claude/windows-hook-compat` | 1606418c | 2026-10-24 | pemunson90-cmd | 596/1 | 0/724 | claude/integration | #99 MERGED | tip is in claude/integration |
| `codex/093-directive` | e44f2f00 | 2026-10-28 | Codex | 963/1 | 0/357 | claude/integration | #194 MERGED | tip is in claude/integration |
| `docs/current-resume-pointer` | 63a4e04d | 2026-10-30 | pemunson90-cmd | 1164/1 | 0/156 | claude/integration | #236 MERGED | tip is in claude/integration |
| `gauntlet/docs/claude-replan` | 8310f56b | 2026-10-19 | Codex | 77/3 | 0/1245 | claude/integration | #6 MERGED | tip is in claude/integration |
| `gauntlet/docs/confluence-integrated` | a283a1a6 | 2026-10-20 | Codex | 144/3 | 0/1178 | claude/integration | #22 MERGED | tip is in claude/integration |
| `gauntlet/docs/current-game-handoff` | f0349548 | 2026-10-19 | Codex | 0/57 | 0/1376 | main | none | tip is in main |
| `gauntlet/docs/earned-course-integrated` | 98f4b355 | 2026-10-20 | Codex | 158/3 | 0/1164 | claude/integration | #26 MERGED | tip is in claude/integration |
| `gauntlet/docs/fleet-integrated` | 289ef105 | 2026-10-20 | Codex | 153/3 | 0/1169 | claude/integration | #24 MERGED | tip is in claude/integration |
| `gauntlet/docs/navigation-handoff` | 7f394bee | 2026-10-19 | Codex | 0/52 | 0/1371 | main | none | tip is in main |
| `gauntlet/docs/pass0-build-status` | 57280ef1 | 2026-10-20 | Codex | 90/3 | 0/1232 | claude/integration | #10 MERGED | tip is in claude/integration |
| `gauntlet/docs/pass0-built` | d74ed47e | 2026-10-20 | Codex | 120/3 | 0/1202 | claude/integration | #17 MERGED | tip is in claude/integration |
| `gauntlet/docs/pass0-plan` | 9d30dc83 | 2026-10-20 | Codex | 80/3 | 0/1242 | claude/integration | #7 MERGED | tip is in claude/integration |
| `gauntlet/docs/playable-milestone-critic-loop-20261019` | 5129b332 | 2026-10-19 | pemunson90-cmd | 98/3 | 0/1224 | claude/integration | #13 MERGED | tip is in claude/integration |
| `gauntlet/docs/recovery-next-operation` | fe43f90f | 2026-10-20 | Codex | 168/3 | 0/1154 | claude/integration | #28 MERGED | tip is in claude/integration |
| `gauntlet/docs/scrolling-playfield-priority` | 4a0ae5f0 | 2026-10-19 | Codex | 0/50 | 0/1369 | main | none | tip is in main |
| `gauntlet/docs/stakes-integrated` | 7aa77c52 | 2026-10-20 | Codex | 135/3 | 0/1187 | claude/integration | #20 MERGED | tip is in claude/integration |
| `gauntlet/docs/telemetry-blackwater-loop` | ccca7a5d | 2026-10-20 | Codex | 181/3 | 0/1141 | claude/integration | #32 MERGED | tip is in claude/integration |
| `gauntlet/docs/tender-next-operation` | c76ebfd8 | 2026-10-20 | Codex | 176/3 | 0/1146 | claude/integration | #30 MERGED | tip is in claude/integration |
| `gauntlet/docs/user-directive-order` | f887c35d | 2026-10-20 | Codex | 95/3 | 0/1227 | claude/integration | #12 MERGED | tip is in claude/integration |
| `gauntlet/feature/acoustic-paths` | 2b068150 | 2026-10-19 | Codex | 0/222 | 0/1541 | main | none | tip is in main |
| `gauntlet/feature/campaign-endings` | a824280b | 2026-10-20 | Codex | 88/3 | 0/1234 | claude/integration | #9 MERGED | tip is in claude/integration |
| `gauntlet/feature/campaign-evidence-recap` | 109a705b | 2026-10-19 | Codex | 0/248 | 0/1567 | main | none | tip is in main |
| `gauntlet/feature/concealed-consequences` | 818fe8c2 | 2026-10-20 | Patrick M | 253/3 | 0/1069 | claude/integration | #46 MERGED | tip is in claude/integration |
| `gauntlet/feature/confluence-operation` | 7caac2db | 2026-10-20 | Codex | 137/3 | 0/1185 | claude/integration | none | tip is in claude/integration |
| `gauntlet/feature/contact-instrument-clearance` | 8f32ca65 | 2026-10-19 | Codex | 0/205 | 0/1524 | main | none | tip is in main |
| `gauntlet/feature/drone-operations` | 4144d0ba | 2026-10-19 | Codex | 0/76 | 0/1395 | main | none | tip is in main |
| `gauntlet/feature/embodied-discovery` | 423b0237 | 2026-10-19 | Codex | 0/66 | 0/1385 | main | none | tip is in main |
| `gauntlet/feature/fit-label-layout` | dd09f5b4 | 2026-10-19 | Codex | 0/263 | 0/1582 | main | none | tip is in main |
| `gauntlet/feature/fleet-instruments` | e638fa76 | 2026-10-20 | Codex | 144/3 | 0/1178 | claude/integration | none | tip is in claude/integration |
| `gauntlet/feature/foundry-departure-cycle` | 5d021e1a | 2026-10-19 | Codex | 0/120 | 0/1439 | main | none | tip is in main |
| `gauntlet/feature/foundry-thermal-lee` | a5fe5e63 | 2026-10-19 | Codex | 0/162 | 0/1481 | main | none | tip is in main |
| `gauntlet/feature/independent-capture` | 5023c1cb | 2026-10-20 | Codex | 125/3 | 0/1197 | claude/integration | none | tip is in claude/integration |
| `gauntlet/feature/inhabited-shelf` | 5c699e42 | 2026-10-20 | Patrick M | 245/3 | 0/1077 | claude/integration | #44 MERGED | tip is in claude/integration |
| `gauntlet/feature/local-contact-reports` | 5dda4342 | 2026-10-19 | Codex | 0/65 | 0/1384 | main | none | tip is in main |
| `gauntlet/feature/open-warning-outcome` | cd2bc37d | 2026-10-20 | Patrick M | 237/3 | 0/1085 | claude/integration | #42 MERGED | tip is in claude/integration |
| `gauntlet/feature/operation-endurance` | 9dfd0a53 | 2026-10-20 | Codex | 126/3 | 0/1196 | claude/integration | none | tip is in claude/integration |
| `gauntlet/feature/order-row-layout` | 767309fd | 2026-10-19 | Codex | 0/252 | 0/1571 | main | none | tip is in main |
| `gauntlet/feature/pass0-encounters` | 01d11bc5 | 2026-10-20 | Codex | 82/3 | 0/1240 | claude/integration | #8 MERGED | tip is in claude/integration |
| `gauntlet/feature/programmed-waypoints` | 5ee95554 | 2026-10-19 | Codex | 0/224 | 0/1543 | main | none | tip is in main |
| `gauntlet/feature/relay-touch-access` | c0b12d5a | 2026-10-20 | Codex | 194/3 | 0/1128 | claude/integration | #34 MERGED | tip is in claude/integration |
| `gauntlet/feature/targeted-knockdown` | ad64e42c | 2026-10-19 | Codex | 0/227 | 0/1546 | main | none | tip is in main |
| `gauntlet/feature/torpedo-contact-aiming` | 029885c7 | 2026-10-19 | Codex | 0/162 | 0/1481 | main | none | tip is in main |
| `gauntlet/feature/v7-earned-region` | e30ccbbe | 2026-10-20 | Codex | 106/3 | 0/1216 | claude/integration | none | tip is in claude/integration |
| `gauntlet/feature/v7-recon-consequences` | b266bd8f | 2026-10-20 | Codex | 107/3 | 0/1215 | claude/integration | none | tip is in claude/integration |
| `gauntlet/feature/view-controls-menu` | 24f1b406 | 2026-10-20 | Codex | 93/3 | 0/1229 | claude/integration | #11 MERGED | tip is in claude/integration |
| `gauntlet/feature/well-acquisition-context` | fa0fa7ec | 2026-10-19 | Codex | 0/259 | 0/1578 | main | none | tip is in main |
| `gauntlet/feature/witness-rescue-ui` | e8c1241e | 2026-10-20 | Patrick M | 224/3 | 0/1098 | claude/integration | #39 MERGED | tip is in claude/integration |
| `gauntlet/fix/current-engine-audio` | 056f391c | 2026-10-20 | Patrick M | 230/3 | 0/1092 | claude/integration | #41 MERGED | tip is in claude/integration |
| `gauntlet/fix/field-record-language` | d35569d1 | 2026-10-19 | Codex | 0/57 | 0/1376 | main | none | tip is in main |
| `gauntlet/fix/local-work-access` | 566bacd2 | 2026-10-20 | Patrick M | 249/3 | 0/1073 | claude/integration | #45 MERGED | tip is in claude/integration |
| `gauntlet/fix/observable-beam-warning` | 2087d8dc | 2026-10-20 | Codex | 123/3 | 0/1199 | claude/integration | #18 MERGED | tip is in claude/integration |
| `gauntlet/fix/targeting-feedback` | be938170 | 2026-10-20 | Codex | 125/3 | 0/1197 | claude/integration | none | tip is in claude/integration |
| `gauntlet/fix/visible-save-failure` | cfa2ce70 | 2026-10-20 | Patrick M | 241/3 | 0/1081 | claude/integration | #43 MERGED | tip is in claude/integration |
| `gauntlet/integration/blackwater-data-delivery` | 5e437289 | 2026-10-20 | Codex | 190/3 | 0/1132 | claude/integration | #33 MERGED | tip is in claude/integration |
| `gauntlet/integration/confluence-operation` | f5c58fdd | 2026-10-20 | Codex | 142/3 | 0/1180 | claude/integration | #21 MERGED | tip is in claude/integration |
| `gauntlet/integration/connected-campaign` | 64d9621c | 2026-10-19 | Codex | 38/3 | 0/1284 | claude/integration | none | tip is in claude/integration |
| `gauntlet/integration/craft-anchored-batch` | 0eea954d | 2026-10-20 | Codex | 213/3 | 0/1109 | claude/integration | #36 MERGED | tip is in claude/integration |
| `gauntlet/integration/deep-rendezvous` | 133228f5 | 2026-10-20 | Codex | 174/3 | 0/1148 | claude/integration | #29 MERGED | tip is in claude/integration |
| `gauntlet/integration/earned-course-continuity` | da494f46 | 2026-10-20 | Codex | 156/3 | 0/1166 | claude/integration | #25 MERGED | tip is in claude/integration |
| `gauntlet/integration/fleet-instruments` | 83725a48 | 2026-10-20 | Codex | 151/3 | 0/1171 | claude/integration | #23 MERGED | tip is in claude/integration |
| `gauntlet/integration/physical-module-recovery` | c72dd3a7 | 2026-10-20 | Codex | 164/3 | 0/1158 | claude/integration | #27 MERGED | tip is in claude/integration |
| `gauntlet/integration/recovery-route-intent` | 97f2b260 | 2026-10-20 | Codex | 217/3 | 0/1105 | claude/integration | #37 MERGED | tip is in claude/integration |
| `gauntlet/integration/route-first-telemetry` | 1840732b | 2026-10-20 | Codex | 179/3 | 0/1143 | claude/integration | #31 MERGED | tip is in claude/integration |
| `gauntlet/integration/stakes` | 9957c7ed | 2026-10-20 | Codex | 133/3 | 0/1189 | claude/integration | #19 MERGED | tip is in claude/integration |
| `gauntlet/integration/v7-full-game` | af4441e4 | 2026-10-20 | Codex | 118/3 | 0/1204 | claude/integration | #16 MERGED | tip is in claude/integration |
| `gauntlet/integration/warning-chain-plant` | 0c619adf | 2026-10-20 | Codex | 205/3 | 0/1117 | claude/integration | #35 MERGED | tip is in claude/integration |
| `gauntlet/maintenance/handoff-evidence-20261020-0724` | 54c4a31c | 2026-10-20 | pemunson90-cmd | 226/3 | 0/1096 | claude/integration | #40 MERGED | tip is in claude/integration |
| `gauntlet/maintenance/redundant-assets-2026-10-20` | 02d6cd4f | 2026-10-20 | Patrick M | 219/3 | 0/1103 | claude/integration | #38 MERGED | tip is in claude/integration |
| `gauntlet/milestone-20261028` | c5bd45a5 | 2026-10-28 | pemunson90-cmd | 889/1 | 0/431 | claude/integration | #179 MERGED | tip is in claude/integration |
| `gauntlet/milestone-20261029` | 8b456b55 | 2026-10-29 | pemunson90-cmd | 1069/1 | 0/251 | claude/integration | #213 MERGED | tip is in claude/integration |
| `gauntlet/milestone-20261030` | cdd58f64 | 2026-10-30 | pemunson90-cmd | 1161/1 | 0/159 | claude/integration | #234 MERGED | tip is in claude/integration |
| `gauntlet/play/confluence-focused` | f5c58fdd | 2026-10-20 | Codex | 142/3 | 0/1180 | claude/integration | none | tip is in claude/integration |
| `gauntlet/play/stakes-whole-game` | b915b5c0 | 2026-10-19 | pemunson90-cmd | 134/3 | 0/1188 | claude/integration | none | tip is in claude/integration |
| `gauntlet/play/v7-whole-game` | af4441e4 | 2026-10-20 | Codex | 118/3 | 0/1204 | claude/integration | none | tip is in claude/integration |
| `gauntlet/release/depth-sonar` | ea645d31 | 2026-10-20 | Patrick M | 269/3 | 0/1053 | claude/integration | #48 MERGED | tip is in claude/integration |
| `gauntlet/release/glass-reach` | f4f4d000 | 2026-10-20 | Patrick M | 274/3 | 0/1048 | claude/integration | #49 MERGED | tip is in claude/integration |
| `gauntlet/release/iron-choir` | 707822eb | 2026-10-21 | Patrick M | 279/3 | 0/1043 | claude/integration | #50 MERGED | tip is in claude/integration |
| `gauntlet/release/operation-foundation` | a6b67014 | 2026-10-20 | Patrick M | 262/3 | 0/1060 | claude/integration | #47 MERGED | tip is in claude/integration |
| `gauntlet/test/pass0-route-contract` | f7f0264b | 2026-10-20 | Codex | 95/3 | 0/1227 | claude/integration | #15 MERGED | tip is in claude/integration |
| `item/127-release-controls` | eb919c8c | 2026-10-31 | pemunson90-cmd | 1203/1 | 0/117 | claude/integration | #241 MERGED | tip is in claude/integration |
| `item/128-ci-v2` | 9ff652ab | 2026-10-31 | pemunson90-cmd | 1179/1 | 0/141 | claude/integration | #240 MERGED | tip is in claude/integration |
| `item/129-protected-golden` | e2c7ba41 | 2026-10-31 | pemunson90-cmd | 1187/1 | 0/133 | claude/integration | #243 MERGED | tip is in claude/integration |
| `item/130-control-mix` | 82db3d60 | 2026-11-01 | pemunson90-cmd | 1223/1 | 0/97 | claude/integration | #247 MERGED | tip is in claude/integration |
| `item/131-crash-possible` | 591959e3 | 2026-11-01 | pemunson90-cmd | 1234/1 | 0/86 | claude/integration | #255 MERGED | tip is in claude/integration |
| `item/133-recovery-manifest` | 3adffb66 | 2026-11-01 | pemunson90-cmd | 1231/1 | 0/89 | claude/integration | #249 MERGED | tip is in claude/integration |
| `item/135-prep-results` | a402e770 | 2026-10-31 | pemunson90-cmd | 1191/1 | 0/129 | claude/integration | #244 MERGED | tip is in claude/integration |
| `item/136-shard-all-failures` | e748afa5 | 2026-10-31 | pemunson90-cmd | 1183/1 | 0/137 | claude/integration | #242 MERGED | tip is in claude/integration |
| `item/137-menu-scroll-keys` | a0729129 | 2026-10-31 | pemunson90-cmd | 1211/1 | 0/109 | claude/integration | #246 MERGED | tip is in claude/integration |
| `item/138-player-names` | e6ddad5b | 2026-10-31 | pemunson90-cmd | 1217/1 | 0/103 | claude/integration | #245 MERGED | tip is in claude/integration |
| `item/139-bare-contact` | 2bff50e5 | 2026-11-01 | pemunson90-cmd | 1269/1 | 0/51 | claude/integration | #252 MERGED | tip is in claude/integration |
| `item/140-dive-end-stats` | 2de2736f | 2026-11-01 | pemunson90-cmd | 1240/1 | 0/80 | claude/integration | #248 MERGED | tip is in claude/integration |
| `item/141-own-craft-legs` | ec6f0daa | 2026-11-01 | pemunson90-cmd | 1245/1 | 0/75 | claude/integration | #250 MERGED | tip is in claude/integration |
| `item/142-launch-guard` | 4b2cd830 | 2026-11-01 | pemunson90-cmd | 1284/1 | 0/36 | claude/integration | #251 MERGED | tip is in claude/integration |
| `item/143-dive-end-polish` | 0087f5ee | 2026-11-01 | pemunson90-cmd | 1291/1 | 0/29 | claude/integration | #256 MERGED | tip is in claude/integration |
| `item/144-all-stop-cost` | 3e4907b4 | 2026-11-01 | pemunson90-cmd | 1251/1 | 0/69 | claude/integration | #253 MERGED | tip is in claude/integration |
| `item/145-briefing-truth` | bf99e502 | 2026-11-01 | pemunson90-cmd | 1255/1 | 0/65 | claude/integration | #254 MERGED | tip is in claude/integration |
| `item/146-docs-pointers` | dae48357 | 2026-11-01 | pemunson90-cmd | 1273/1 | 0/47 | claude/integration | #257 MERGED | tip is in claude/integration |
| `item/147-integration-apk` | 63b03a75 | 2026-11-01 | pemunson90-cmd | 1297/1 | 0/23 | claude/integration | #258 MERGED | tip is in claude/integration |
| `item/148-android-smokes` | 8b7815bb | 2026-11-01 | pemunson90-cmd | 1299/1 | 0/21 | claude/integration | #259 MERGED | tip is in claude/integration |
| `root/stable-board-pkg2` | f9839757 | 2026-11-01 | pemunson90-cmd | 1317/1 | 0/3 | claude/integration | #239 MERGED | tip is in claude/integration |
