# MENU REACH hosted lifecycle regression, 24 October 2026 Eastern

Exactbf hosted40158611057 failed game-smoke121065245153 at step8:
DEPTH SONAR UI42/2, both received evidence history waterfall checks.
Guidance121065245292 succeeded. No merge occurred.

proof-bf-ci-failure.zip contains7members:6 raw logs/data plus manifest.
Payload3127333bytes; ZIP170493bytes.
SHA256:1f9d06254be1c0fd3088b9f46648e0cad0597d6681d8ca14926d1a9a7450609b.
All members were reopened and size/hash verified. Full hosted log2502625bytes
is preserved. The GitHub connector returned no data; an existing authenticated
read-only local helper retrieved it without printing/saving credentials or
forwarding authorization to the signed log host.

Unchanged Depth Sonar UI passes42/0 by itself onbf, headless and native.
The file named depth-sonar-bf-red.log is that isolated PASS, not a failed test.
Running unchanged onboarding_tests (CIrank3) then unchanged depth_sonar_ui_tests
(CIrank24) against the SAME scoped userdata root reproduces30/0 then42/2.
After onboarding chooses150% and then100% just before quit, the persisted
settings file still says150%. A snapshot of that scoped settings JSON is kept.
The shared frontend lost its pending debounce on scene-tree exit; the later
sonar UI inherited the wrong size. No sonar, camera or game rule needed repair.

Candidate5a715b6528495df4f7700ff578804526fae5ebae adds a frontend-only dirty
guard and flush on dismissal, tree exit and application suspend/focus loss.
No setting/save keys added. New real-touch lifecycle tests for Operations host
exit, Title host exit and app suspend reproduce23/3 RED before the fix and23/0
after. The unchanged ordered pair now gives30/0 then42/0 with persisted100%.
Those newer candidate logs are preserved in the later5a packet, not this ZIP.

Earlier lifecycle fixture attempts are retained separately:21/7 looked for
embedded controls under Frontend instead of Main, and23/4 lacked an explicit
viewport so the130% target was offscreen. Root corrected the fixture before
changing production; the meaningful23/3 failures above cover only lifecycle
persistence. Existing sonar/onboarding tests and all their assertions remain
unchanged. Fresh5a review and exact-head hosted checks are still required.
