# 043 SAVE2 evidence, in progress

25 October 2026, 2:28 PM Eastern. Draft PR143; last published source a449f1bc. This is a recovery checkpoint, not a DONE report or final-head approval.

The attached ZIP preserves successful and failed local runs. Its manifest lists every member's exact size and SHA256. All ZIP members and CRCs were independently reread before this checkpoint. User-data directories and live campaign files are excluded.

Current verified results: storage194/0, forks46/0, core836/0, registry261/0. Existing focused save, profile, photo-ending, Operations and menu regressions pass. Native results: profile UI168/0, photo-ending UI42/0, menu reach309/0, Settings lifecycle23/0 and Operations1502/0. The existing FIX2 save UI4/0 deliberately prints a persistent-write-failure message to test visible retry handling.

Interim review found a profile replacement could bypass a pending SAVE2 rollback, and a later launch could orphan a failed fork checkpoint. The original failing tests remain in the ZIP; the published fixes add recovery before public profile snapshots and preserve launch identity until an already-committed checkpoint can be published. Cold recovery, failed rollback, all-unreadable fork slots, explicit deletion, replay recovery counts and cross-profile isolation are covered.

UI work is still changing. Normal-text first-ending replay passed, but expanded 150 percent touch checks remain unresolved. The initial double-activation diagnosis was premature. Isolated headless and native probes prove direct viewport touch injection does not activate standard buttons; physical input parsing requires engine mouse emulation and the window's final coordinate transform. The inherited combined viewport touch/mouse helper activates a plain button once. Raw probe sources and logs preserve this distinction. No final touch/layout result is claimed here.

Other retained failures include malformed Variant decoding, oversized unreadable deletion, test fault-injection mistakes, a temporary incompatible return signature that was corrected before publication, and relative user-data import paths. Current runs use full absolute isolated paths. No full local scenario matrix, APK or phone test was run. Final exact-head independent review and hosted guidance/game-smoke remain required before merge.
