# MENU REACH stock-layout regression, 25 October 2026 Eastern

Exact5a run40159952600 failed game-smoke121069232039 at step8:
LOADOUT38/2, selected stock and three comparison rows outside the scrolled
viewport on2520x1080. Guidance121069231929 succeeded. No merge occurred.

proof-5a-ci-failure.zip has6members:5 raw logs plus manifest.
Payload14044164bytes; ZIP783512bytes.
SHA256:a2eb5aa6a093d353b8bf3afa387ff65285df1971294bf95988f347d355c36130.
Every member was reopened and size/hash verified. It includes the full final
13137263byte hosted failure, local unchanged Loadout38/2 reproduction, and
the repair's unchanged Loadout38/0 headless/native and new menu309/0 logs.
Earlier partial hosted snapshots were not treated as final proof.

Three new separate navigation rows below Settings increased the menu tail,
so scrolling to bottom displaced the selected stock/comparison labels. The
repair reuses the original Settings button in one compact bottom row with
Title, Challenges and Credits. Existing IDs/callbacks and scroll propagation
remain. Table gap and48dp minimum widths are explicit; no simulation or save
change. The original Loadout test is byte-identical to base69fc9e46, with all
assertions retained. Its meaningful38/2 RED precedes38/0 repaired.

The repaired candidate c991a00ee055da7824d015503d8a14357ff00598 adds actual
150% navigation visibility/touch assertions to the new Menu Reach test. It
passed309/0 headless. Fresh independent/current proof is in README-c991.
At150%, some compact labels wrap midword; all letters and touch targets stay
visible. That P3 readability limit is retained honestly, not claimed fixed.
