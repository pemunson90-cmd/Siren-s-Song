# A11Y1 cue inventory and seams

Scope: presentation of existing player information. No acquisition, reach, timing,
pause, physics, campaign schema or narrative changes. Standard hues are retained.
Craft/Siren silhouette art remains handoff032. Native fixtures are source-known
technical checks, not blind play or physical-device perception claims.

## Complete playable sound inventory

This inventory covers `Soundscape.RECORDINGS`, the actual `cues` registration,
direct lock/first-notice players, and every `PhotoAudio.Table.CUES` entry.
An existing second channel is not counted as an audio-only gap.

| Sound | Existing equivalent | A11Y1 parallel channel |
| --- | --- | --- |
| alert (lock player) | LockWarning source S#, dashed tether, arc, seconds and interruption hint | Optional LOCK WARNING caption and one episode pulse; original warning always remains |
| alert (first notice player) | FirstSirenCue arrow, NOTICE / receiver / bearing; first-notice hint | Existing text/shape remains, no duplicate new acquisition signal |
| carrier_received | Receiver-owned instruments / received contact state | HEARD: carrier signal, same ReceivedCues gates on independent observer |
| return_received | Receiver-owned sonar return / bearing history | HEARD: return signal, same gate |
| sweep_received | MissionHUD HEARD classification / bearing / age | HEARD: sweeper warning and optional one pulse, same gate |
| factory (received industrial windup) | Public cached PRESSURE CHARGE / BURST WINDUP when observed | HEARD: machinery pulse, receiver/time/vector gate; no roster lookup |
| factory (industrial departure) | Earned deep-motor received bearing/readout | Generic machinery caption only for existing industrial=true publication |
| factory (scripted base response) | Existing mandatory heavy-pulse / recovery-route mission message | Existing message retained; no new source/position caption |
| beam | Fresh contact FIRING, visible beam, own loss/debrief cause | Existing visual/text remains; no caption generated from hidden source/recipient events |
| heartbeat, tension | Public OP PRESSURE stage / received contact warnings and pressure vignette | Existing text remains; continuous sound is not repeatedly captioned as a new threat |
| camera, photo shutter | Viewfinder, active PHOTO task / exposure and film count | Shutter released caption on existing camera event |
| photo hold | Real exposure progress / viewfinder quality and PHOTO task | Existing progress remains; no synthetic countdown |
| photo develop | Record secured / stored plate / grade | Plate developed caption on own plate-count transition |
| photo film_low, film_empty | Numeric film count with warning hue | Mandatory FILM n/c LOW or EMPTY; optional transition caption; EMPTY optional pulse |
| photo engine_down | ALL STOP / own craft propulsion state | ALL STOP: engines off caption |
| photo pressure_shallow, pressure_deep | Own depth band, transition arrow / remaining time | Pressure: ascending/descending plus own craft name |
| ping | Own pulse / physical echo instruments and accepted order message | Acoustic pulse caption, no inferred target |
| emp | Tool count, disruption pulse and 12-second message | DISRUPT released caption |
| knock | Own projectile, tool count, impact feedback | Torpedo launched caption |
| snare | S# snared / recovery time and observed stun text | Snare impact caption |
| decoy | Own decoy ring / lifetime, tool count, accepted order message | Decoy released caption |
| recon | Own survey timer/tool count and survey uplink message | Survey released caption |
| record | Mandatory record-secured message / plate archive | Record secured caption while active; outcome/debrief text remains authoritative |
| salvage | Own recovery/cargo status and accepted winch message | Salvage secured caption |
| berth_release | Own accepted berth-release state / operation message | Berth released caption |
| plant_switch (plant_control event) | Own accepted machinery control / state text | Machinery switched caption |
| loss | Own LOST craft / battery-loss message; terminal loss/debrief cause | Craft lost caption during live play; terminal text remains mandatory |
| extraction | Recovery outcome/debrief | Existing terminal text remains; no event replay after outcome |
| ambience, creak | Decorative ocean/structure beds, no gameplay warning information | Excluded; never label a decorative creak as danger |
| engine | Own speed / propulsion and ALL STOP indicators | Continuous bed excluded; stop transition is captioned above |

## Color meanings

PhotoPricingOverlay was the genuine hue-meaning gap: flash reach, observed Siren
radius and own shutter radius all used short dotted rings. They now use table
patterns (short dash, long dash, sparse dot) and FLASH REACH / OBSERVED SIREN /
OWN SHUTTER labels. Plain reach stays solid with its subject/meters label.
Radii come directly from the existing `Pricing.chart_rings` readout unchanged.
The readout's pre-existing cached-contact radius computation is outside this
presentation change; this renderer introduces no roster/source queries.

Viewfinder warning/open rows already contain explanatory price/window text.
Lock state already has arcs/seconds/tethers; contact roles, freshness, reporting,
stun, firing, depth and pressure already have words/numbers, not just hue.
Own oxygen/hull/battery/film reserves and tool availability have numeric/status
channels; task/order controls have text and disabled states. Terrain/current
arrows, course geometry, acoustic bearings and photographic quality meters retain
their existing geometry, labels and numeric channels. Decorative background,
lamps, particles and lighting carry no new warning semantics.

SAFE PALETTE selects the table's Okabe/Ito Color Universal Design colors for the
warning/range and chart consumers (blue, sky blue, orange, yellow), intended for
protanopia/deuteranopia support. Primary reference: Masataka Okabe and Kei Ito,
[Color Universal Design](https://jfly.uni-koeln.de/color/index.html), including
redundant coding guidance and palette. Labels and patterns are essential;
opacity, background, display calibration and individual vision affect perception.
No universal human/device readability claim is made. Other art is unchanged.

## Ownership, settings and revert

`presentation/accessibility` owns cue text/durations/pulse requests, palette,
independent ReceivedCues caches and passive caption placement. `Soundscape.update`
observes once before its original audio and event clearing, including muted audio.
It never consumes original audio dedup or mutates simulation/events. Mission
identity, rewound clock, receiver changes and inactive menus clear/seed observer
state; paused updates cannot emit or pulse. Haptics call FrontendSettings.vibrate,
honoring the existing toggle and Android-only physical seam.

Main only installs/refreshes the passive caption label and exposes optional rows
in its existing settings menu. Frontend exposes the same rows. SettingsStore adds
validated optional booleans `safe_palette` and `audio_captions`, false by default;
HAPTICS reuses the existing field. Main's `settings_path` defaults to the original
path and permits a scoped real-file UI fixture, independent of shared CI prefs.

Placement uses a bounded set of widths/occupied edges, avoids camera, live lock,
first notice, status, hints, guard, fleet readouts and active controls. If chart
space is exhausted, the existing FLEET target advertises AUDIO LOG. That existing
radial menu has an optional AUDIO LOG action which opens its existing scrollable
detail sheet with explicitly historical mission-clock timestamps. The observer
retains at most eight current-mission entries beyond transient overlay expiry.
Mission/receiver/menu resets and captions OFF clear history. Current status and
warning text and geometry stay untouched. MissionHUD adds only registration,
fleet-action selection and existing-sheet routing hooks for this fallback. Existing026
camera/status/badge overlap is not fixed by this work; native overlap checks
cover only the new floating caption, not a general HUD overlap claim.

Revert optional cues with AUDIO CAPTIONS / SAFE PALETTE OFF; HAPTICS remains its
existing independent setting. `CueTable.ENABLED=false` stops the observer and
optional palette. Revert this PR to remove mandatory ring patterns/labels and
film words as well. Campaigns remain readable because no campaign fields change.


## 081 chart settings (lane implementation; integration pending)

The existing REDUCED MOTION setting holds regional and legacy dust at phase zero,
steadies the beam target arc, pressure vignette and Hunt tone, and caps the own
camera_flash presentation timer at 0.08 s (the chart currently draws no flash wash).
HIGH CONTRAST thickens chart/contact/craft outlines and course strokes, brightens
course colors, and mutes decorative regional light/dust and photographic lamp wash.
SAFE PALETTE adds long-dash threat rings, dotted evidence/received marks and
short-dash warning rings with opaque dark stroke backing. The received-bearing
renderer uses the same published rows, latest-source/three-second gate and fan
geometry as SonarHistory, with dotted rays and an extra diamond for echoes. Course geometry retains
its solid confirmed / dashed unsurveyed distinction and gets role colors. Existing
contact words, photographic finding shapes, warning arcs, seconds and eligibility
remain authoritative. The existing Hunt help includes the optional chart legend.

Turn all three settings off to restore the standard draw path. There are no new
settings, campaign fields, sensing values or warning gates. `cue_tests.gd` covers
command equality, phase stability, distinct patterns, 3:1 stroke/backing contrast,
flash cap and unchanged warning/contact data. Its optional `--chart-render` checks
actual Compatibility output and reversible toggles; `--chart-baseline=<gd path>`
compares pre-change OceanView source as well. These fixtures establish technical
render behavior, not human perception or physical-phone readability.
