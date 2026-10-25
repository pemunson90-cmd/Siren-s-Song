# 042 Windows candidate evidence

PR142: https://github.com/pemunson90-cmd/Siren-s-Song/pull/142
Final candidate:94ae4a2be26e0d44440ad74536869485ab76a141. Base:01bc90b0ad3fc28a73aa8121eb30f28f19eadfca.

These are candidate records, not merge approval. Independent fresh exact-head validation and hosted game-smoke run40166837512 are pending as of25October2026 at1:51AM Eastern. Guidance is green. Source implementation was committed atd7b0a8a8; e0bff838 and94ae4a2b add tests only.

Use local-proof-94ae4a2b.zip and its matching JSON manifest for the current local proof:37 members,6,275,953bytes,SHA2565c35bbb1f17fccec4b9470cd6ef4a5f617e72ecd5f7bd327567e83f76146ef70. It contains19 raw logs and18 PNGs, including both earlier and fully developed final images. Parent independently reopened both verified bundles and checked ZIP CRC, every member size/CRC32/SHA256, member counts, and ZIP size/hash.

Historical e0 proof is local-proof-e0bff838-1.zip with local-proof-e0bff838-manifest-1.json:27 members,3,172,960bytes,SHA256d3862c8abf845ca83997ea22c20eb5e129ec0d0197c5657f98b86aed9e881b1e. README-1.txt and README-94ae4a2b.txt preserve the preparation records.

The first archive attempt, local-proof-e0bff838.zip, is an incomplete/unverified preparation artifact with no matching manifest. It is retained as failed evidence and must not be used as verified proof. No file was deleted or overwritten.

Test history: baseline finale UI114/39 RED; initial implementation UI156/6 was a case-insensitive assertion fixture false positive, corrected to165/0; explicit reload/targets231/0 headless240/0 native; final Android Back246/0 headless255/0 native. Core836/0; unit28/0; existing endings92/0 and wall42/0; save12/0; profiles68/0+cold3/0 and native profile UI168/0; Ops1472/0; menu309/0. The failed headless profile UI log has162/0 assertions but renderer-null/script errors, so it is a failed run. Its unchanged renderer-only capture helper passes natively. Never count the failed attempt as green.

Limits: source-known recovery and saved-state fixtures, not blind campaign journeys or phone/human testing. Existing027 Plate is reused and has no tap/enlarge interaction. Fallback text wraps inside the existing scroll. Two provisional recorded-fact lines remain AI-DESIGNED placeholder, Pat to rewrite. Earlier first-native screenshots show developing plates; captures-android-back-native wait1.8seconds. No gameplay rules or old ending resolver changed.

Process record: docs-only progress commit1da5ff79 pushed after a checker path error and shell continuation. Corrective docsd9567356 records the mistake; active code registry was rerun258/0errors/0warnings and subsequent docs/archive commands stop on failure. That failed invocation is not retroactively reported as passing.

Independent review,25October2026 at1:53AM Eastern: APPROVE with no P1/P2 on exact94ae4a2be26e0d44440ad74536869485ab76a141, comment6394110769 https://github.com/pemunson90-cmd/Siren-s-Song/pull/142#issuecomment-6394110769. This is an attributable Codex non-author subagent review, not a separate-account GitHub approval or a Claude review. Parent read back the published comment and independently checked all11 final94 logs, reviewer checkout HEAD and unchanged tracked source/tests/scripts.

Independent raw proof: independent-review-94ae4a2b.zip with matching manifest,40 members,6,210,925bytes,SHA2562983d54d2ddc6ef5fd6c8095c825ed47d57491d7505a74e0f8c41269b61cfb1d. Reopened ZIP and verified every member hash and length. It includes22 raw logs and18 screenshots: final94-* are fresh final-head runs; finale0-* are earlier e0 candidate runs retained historically. Final head results: import clean/core836/0/unit28/0/UI246/0/native255/0/photo92/0/native wall42/0/save12/0/profiles68/0+cold3/0/native profiles168/0/Back17/0. Native nine final images were independently viewed by the reviewer. Hosted game-smoke is still pending; earlier pending-review wording above is historical.


## Hosted CI cancellation update

Updated 2026-10-25. PR142 head `94ae4a2be26e0d44440ad74536869485ab76a141`, base `01bc90b0ad3fc28a73aa8121eb30f28f19eadfca`, hosted run `40166837512`. `game-smoke` job/check `121089563322` was cancelled at step 8, “Validate navigation, recovery and touch runtime regressions”; `guidance` check `121089563689` succeeded. The final hosted log ends with `##[error]The operation was canceled.` The PR comment recording the workflow timeout request is [comment 6394577710](https://github.com/pemunson90-cmd/Siren-s-Song/pull/142#issuecomment-6394577710).

The job ran from 05:48:25 UTC to 06:48:42 UTC, about 60 minutes. Workflow job configuration sets a 60-minute timeout. The matching duration and limit support timeout as the cancellation cause; this is an inference from timing/configuration. No same-configuration rerun is represented here.

The preserved snapshots contain 257 completed suite summaries, all with zero failures, and final `OPS HOME UI CHECKS 1472 FAILURES 0`. Four final matrix suites were unfinished when the job was cancelled. This hosted run is cancelled, not green. Registry validation was 258/0 errors and 0 warnings.

Bundle: `hosted-cancelled-40166837512.zip` (6513156 bytes, SHA256 `63894563215b130ad600183350f681bfd9da79fa406fda18e5bdbf1b43bbd511`), manifest `hosted-cancelled-40166837512-manifest.json` (9 log snapshots, including identical partial copies and the final cancellation log). The ZIP was reopened and every member size, CRC32, and SHA256 was verified.
