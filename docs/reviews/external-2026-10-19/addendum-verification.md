# Addendum A · source verification and authority

[Original addendum](2026-10-19-external-audit-addendum-A.md) preserved byte-for-byte, **5067 bytes**, SHA256 **705abbcf5aea1fafb0d9c03c1fb5b021c4c4d8452f5a89a95cb954c894c9f339**. Received with empty user body and an explicit instruction to distinguish document instructions from user instructions. Its provenance claims are self-reported. No embedded “Instructions for the fix,” “owner call,” mandatory type assignment or no-retune prescription is adopted as a user decision.

## Confirmed by source inspection

Historical source: [archived v7 HTML](../../../archive/prototypes/sirens_song_prototype_v7.html), SHA256 **3b00be96179f6a61d23fe203483de3f4083bcc866c75d483ac5bfa748502e85b**. Archive unchanged. Neither this verification nor the original auditor ran v7; “working” behavior is not browser-runtime evidence here.

- Lines 187–192 define two `patroller` objects, each with four authored `wp` entries, `wi`, patrol/chase speeds. Lines 373–376 pursue sightings/lures/investigation, otherwise advance `wi` modulo waypoint count on arrival. Source supports the authored loop mechanism.
- Line 193 defines `sentinel`, home and tether 190. Lines 362–367 return home when outside tether without current sight or lure; otherwise chase sight/lure, investigate remembered locations, or return home. **This is not a hard leash during chase or lure.**
- Line 194 defines `hunter`, `pat:0`, `chase:64`, home equal to initial position. Lines 368–372 chase sightings/lures, investigate with wider random offsets, otherwise return home at speed 38. **This does not establish an unprovoked roaming hunter:** at initial home without stimuli it has no travel to do.
- `invX/invY/invT` memory and decoy behavior are present. Lines 426–427 give patroller/sentinel/hunter different silhouettes.
- Lines 199–201 `moveToward` moves directly toward a target, without production's obstacle/path clearance checks. Porting waypoint coordinates/branches blindly would not demonstrate terrain-safe movement.

## Production comparison and limits

Accepted production 92625ac/f1ea536 uses a common Siren dictionary and procedural patrol goal formula; it does not contain those explicit type fields or authored waypoint arrays. The [independent 600 s probe](README.md) verifies a production liveness defect: **eight of thirteen stall for most of the run**, not eight that literally never move. Four have zero travel; four move before stalling. The historical source shows an available differentiated movement reference, but no cross-runtime behavior equivalence or balanced patrol guarantee is established.

[Architecture GAUNTLET](../../architecture/GAUNTLET.md), line 16, explicitly treats v7 as a reusable behavioral reference for noise, suspicion, ping investigation, last-known positions, tools, extraction and procedural audio. It says the integrated HTML architecture and exact balance values are not production constraints. [Source authority](../../SOURCE_AUTHORITY.md) ranks current explicit decisions, current design/accepted amendments, selection decisions and verified evidence above older prototypes/proposals. Its import reconciliation states that embedded workflow instructions do not authorize implementation.

Therefore waypoint, sentinel and hunter ideas can inform authored behavior, but their exact port, Listening Well/Foundry assignments, no-retune demands and model rotation are **external recommendations**. Production fair sensing, occlusion, telegraph/stun, bounded observation, playable recovery and current user priorities remain authoritative. A liveness correction requires new balance comparisons; old outcomes remain historical observations, and neither a harder game nor restored old hull percentages alone proves improvement.

No game edits, model-policy changes or CI triggers were made by this source verification. Requested `gpt-6.1-sol`; actual backend/usage telemetry unavailable.
