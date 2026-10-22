# Photographic reconnaissance (core pillar, user-ratified 22 Oct 2026)

**Ratified premise:** Quietus is a vulnerable military recon submarine investigating the Sirens; photography is one of the most meaningful things the player does (Iron Lung influence). Rescue, industrial and fleet work support it and must not displace it. Full statement: top of docs/USER_DIRECTIVES.md. Everything under "PHOTO1 proposal" is a proposal; the premise is not.

## Audit of the game as of 22 Oct (verified in code, not played)
**V7:** four fixed photo targets, instant CAPTURE within 72 of the nearest craft. Quality = prox-based, drone 0.55+0.45p, sub 0.25+0.45p. Costs 14 suspicion and +8 Hunt. Final A/B/C. The picture is a flash and a ring. No framing, heading or stored image.
**Godot now:** capture is a timed hold (MIDDLE band, within 240 m, clear line of sight, under 12 m/s, interruption resets; per-craft state). Quality is the V7 formula at 240 m and only graded for kind "" or "photo". The capture panel shows one of 7 authored PNGs chosen by objective, independent of where the craft is. Archive keeps best grade per record. A drone sampler takes 8 s audible field samples.
**Already useful:** per-craft physical exposure, drone vs sub constants, contacts and depth-band sight checks, Hunt floor and guard alert floors from secured records, evidence persistence, a research and facts path that can consume observations (campaign/glass_research.gd).

## Deficiencies, ranked
1. Quality is cosmetic: it reaches only the grade display. Nothing uses it for research, planning, unlocks or later ops.
2. The image does not depend on the photo: no heading, field of view, framing, light or conditions; distance only.
3. No discovery: targets are authored, charted and named in the brief; the art is identical at any grade.
4. Photography fades after op 5: ops 6 to 21 are essentially photo-free, ops 22 to 29 have none. Only op 0 is purely photographic; 1, 3, 5 mixed; 4 probably.
5. No camera equipment line (lens, flash, film, stabilizer); drone vs sub differs only by a constant.
6. Thin archive: one best shot per record, no comparison or annotation.

## Drift from the identity
Spec and parity ledger accepted "temporary" illustrations and a display-only grade ("every grade preserves completion"). Blackwater and Glass Reach reused the camera button for hydrophone "listening" reception, which also removed the drone/sub photo difference. Iron Choir work is entirely industrial and rescue. Rescue and machinery displaced reconnaissance exactly as the directive warns.

## PHOTO1 proposal (one sole builder, one branch, internal checkpoints, one PR)
Seams: new `simulation/photo_capture.gd` (heading, field of view, distance, band, light and thermal conditions, resulting frame with a visibility mask; replaces the hard 240 m radius); `Recon.secured` writes a structured observation (facts actually visible plus quality) instead of three scalars; grade becomes a function of the frame; equipment catalog gains camera gear (lens, flash, film or exposure limits) gated by upgrades; observed facts feed campaign consequences and research (route reveals, enemy roles, recipes); new archive viewer (multi-shot per target, compare, annotate); the camera panel renders from frame data instead of static PNGs; split the "listen" and "photo" labels in `campaign/encounters/work_sites.gd`; save validation updated.
Playable proof: rework representative ops across the campaign so photography matters in each band: a locate-and-photograph unknown in Glass Reach, intelligence from an earlier photo that changes an Iron Choir approach, a Siren factory or behavior study, and keep the tutorial ops 0 to 5 honest. Fair information throughout; no omniscient rewards. Not every op needs a photo task.
Checks: focused tests during construction, one full CI at the PR, then the cold review plays it and judges against Iron Lung.
