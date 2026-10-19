# Focused composition finding · tests only

Exact combined source `e209b89` (route5ee9555 + acoustic75537f7), isolated read-only simulation/campaign/test copies; root mutable torpedo/contact-clearance work untouched. Full source SHAs in `source-versions.json`. No new gameplay tuning, route search, captures, APK or complete suite.

| Source / ordinary scripted loadout | Direct return | Same late-decoy return |
| --- | --- | --- |
| Pre-acousticdced / routes-only5ee ·3EMP | win62.5%hull | win100%hull,1decoy spent |
| Acoustic755 / composede209 ·3EMP | win100%hull | win100%hull,1decoy spent |
| Explicit legacy hearing on755/e209 ·3EMP | win62.5%hull | win100%hull,1decoy spent |
| Fresh composede209 · ordinary2EMP Endurance | win61.6%hull | win100%hull,1decoy spent |

Every listed run39.2s, all3records and both drones recovered; EMPremaining0 means charges SPENT, not free completion. Both source-isolation and explicit legacy replay identify hearing as the cause, not route programming. Old reactive script fires EMP at7.1,11.4,11.5s (lasttwo at the unchanged observed east position); fresh fires6.6,11.1 then25.9s on direct return or32.2s on decoy return. Changed acoustic inference shifts encounters and leaves the third defense for return. The script is deliberately preserved, including its costly near-duplicate old action; no harness optimization or golden-hull restoration.

Disposition: no encounter/enemy correction is supported by this finding. Three-EMP direct play is a viable finite-resource alternative; a decoy retains a demonstrated consequential role with ordinary two-EMP equipment. This does not prove every Split route/loadout balanced or every decoy useful.

Patch ONLY `game/tests/core_scenarios.gd` and `game/tests/split_channel_scenarios.gd`: fresh direct hearing asserts bounded80m-bin inference/no hidden exact goal/no visual lock, plus explicit old exact-origin compatibility; Split keeps fresh ordinary archive/drone recovery and one-decoy cost, preserves the legacy >10hull guard explicitly, and asserts the demonstrated fresh two-EMP >10hull alternative. Added helper parameters select actual existing loadout/legacy hearing without changing defaults or production code. Other fresh fixtures remain fresh.

Focused actual RED26checks/2failures reproduced both root findings; focused GREEN31/0 on exact frozen composition plus this test patch. Same designated acoustic reviewer android_artifact_review; no second review. Original feature evidence/losses and drone-research scratch preserved. Requested Sol6.1/high, actual backend/usage unknown. No new human/native/experiential quality claim from these targeted assertions.
