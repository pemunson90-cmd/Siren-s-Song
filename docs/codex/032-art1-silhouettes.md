# Handoff 032: ART1, Siren, Quietus and structure silhouettes (procedural, Pat judges)

Status: CLAIMED
Claimed at: 2026-10-24 18:33:15 UTC
Claimed by: codex
Finished at:

Precondition: handoff 017 DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub runs it. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, INPUT PRIORITY: Android touch-first, 48 dp, Android Back as Escape, keyboard fallback only). Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP to your lane branch at least every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
The spec art direction is layered abyssal basalt, cyan/amber industrial structures, charcoal Quietus, angular ray/serpentine red-lit Sirens, legible sensor and evidence distinction. Improve the in-game drawing of Quietus, the two drones, the Siren roles (patroller, sentinel, hunter, sweeper), and the factory structures using procedural drawing in one self-contained module (game/src/presentation/art/ with a data table of shapes, palettes and glow). Priorities: instantly readable silhouettes at small size on a phone, role distinguishable by shape not just color (accessibility), red-lit angular Sirens that feel dangerous, a clear lamp cone for the camera. Keep draw cost low (no per-frame allocations); check with the performance test from handoff 015. Provide before/after screenshots at the two Fold7 shapes in Completion for Pat to judge; he decides. Keep the old drawing reachable behind a table switch so it can be reverted.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-art1

## Files you must not touch
Gameplay rules, hit shapes and collision geometry (draw only), story.

## What done looks like
Before/after screenshots, no performance regression, old look restorable by one switch.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, branch and last pushed SHA, test results, unverified items, files outside ownership needed, recommended next.)


Claimed 24 October 2026, 2:33 PM Eastern, before implementation.
031 is verified DONE at actual integration ad841f69394eb4ade818794056e5ccac56f0bc0b
(PR127 merged after both exact ec23 checks and independent approval).
032 precondition017 is DONE. Code branch claude/lane-art1 will start from freshly
fetched actual integration. One implementation worker and independent reviewer.
Preserve existing art direction and all rules; no new story or SIREN TELL.
Provide source-matched old/new native pictures at both Fold7 shapes, real drawing
cost evidence alongside the simulation-only015 probe, and a single old-look switch.
Pat decides the actual artwork after the concrete candidate is ready. Do not merge
new artwork before that judgment. Next assigned task after032 is033 only.


Recovery checkpoint, 24 October, 2:37 PM Eastern:
Public claim ce56635 precedes implementation. Lane claude/lane-art1, actual base
ad841f69394eb4ade818794056e5ccac56f0bc0b. Last pushed04c9fc59759523be21c94ef3557c9431cf02f0a4
is root-only RESUME reconciliation of published031 and active032. Game tree unchanged.
Sole worker /root/art032_builder requested gpt-6.1-sol Medium, short fresh context;
root owns integration/RESUME/PR/board and a separate independent reviewer.
Worker is establishing the untouched old renderer baseline before art edits.
Actual feature source WIP is due3:03PM Eastern, then every30minutes.
No candidate artwork, final032 verification, PR or Pat art acceptance claimed yet.


First source WIP, 24 October, 2:57 PM Eastern:
Branch claude/lane-art1, last pushed241d44ea1906bff1d1b23650d68c12f2aa4cd83f.
Public claimce56635 preceded implementation and source WIP was within30minutes.
Draft PR130 https://github.com/pemunson90-cmd/Siren-s-Song/pull/130 is attached.
Root docs04c9fc5 plus nine exact owned source/test files; normal hooks passed,
no UID/import churn or runtime rule/save/story edits. Baseactualad841 remains current.
Clean serial frozen WIP import/core835/ART33/Confluence15/named015SIM2 all zero
failures and clean exits/log scans. Native bounded preview88/0 covers corrected
logical viewport, both420dpi shapes,150%camera text, whole visible craft/cone,
retained material, hidden-roster pixels, factory knowledge/bounds and valid full
snapshot/subsequent-command invariance. These are preliminary technical fixtures,
not final frozen proof, human perception, Android or blind-play acceptance.

Known development failures retained separately: missing stale default script,
packed-array const parser failure, short contract/core overlap (not final proof),
clipped initial window/logical viewport, rejected hollow UV outlines, and wrong
fixture depletion setup corrected without weakening its assertion. Work-only
runner now has serial mutex, immediate PID/argument metadata and bounded wait;
all Godot invocations use unique isolated APPDATA/LOCALAPPDATA, no parallel root runs.

Sole builder /root/art032_builder now refines table-only lamp visibility and
immutable buffer caches before final paired native measurements. Independent
/root/art032_reviewer requested gpt-6.1-sol Medium is inspecting frozen WIP source,
no final approval claimed yet. No32 art published and Pat has not judged it.
Do not merge before final evidence/review/exact-head hosted gates, fresh current
integration containment, and Pat's concrete before/after artwork judgment.


Current frozen candidate checkpoint, 24 October, about3:05 PM Eastern:
Branch claude/lane-art1, last pushed7619ff17069bf52534239702c54462bac8793561.
Full tree fb28192aa5112d465c7236446429e683e469bdb5;
game tree ead6c0b35a7b331d88e2475d60f76594808eaf13. Tracked source clean.
Baseactualad841f6 remains current at3:09PM fetch. Draft PR130 now records exacthead.
Own40123591760 guidance120960243877 SUCCESS, game-smoke120960244052 running.
Older WIP run40123168433 is not the current publication gate.

Relayed /root/art032_reviewer SOURCE PASS exact7619 vsad841, no source blocker.
Finaldelta resolves steady-state mutable tint/lamp buffer risk:128 immutable tint
arrays (cosmetic1/127 bound), configuration-dependent local cone, transform placement.
Source supports bounded new steady-state draw behavior, not zero engine allocations.
Factory/freshness/other-role/pin/snare/warning/old-look/save boundaries remain.
Reviewer ran no tests; final approval pending immutable receipt/measurements/pixels.

Latest native preview108/0 includes filled existing biological material, lamp180m
artistic fade within actual range, actual420dpi/coverinset and150%camera, onscreen
craft/cone and actual lamp-on/off pixels. Earned charts use a camera-direction
instrument instead of a filled visible corridor, preserving unknown terrain.
Actual retainedtexture cases, four roles, drones, installation, whole/partial
factory, old-look pixel return, hidden-roster/private-chart geometry invariance,
valid snapshots and subsequent commands covered by source-known technical fixtures.
An initial earnedfixture lacked region_revision; preserved red, fixed only fixture,
production validator unchanged. Final numeric command hashes will be a separate
bounded headless receipt linked to every native initial-state hash, not falsely
claimed as emitted inside the original native rows.

Frozen serial finalsession84074: isolated import; core/art/Confluence/photo-depth/
photo-pricing/015SIM; native Well/camera/031accessibility; full art performance.
No source changes while running. Five old/new/new/old blocks,90warmup/300samples,
three states at both shapes. Real engine GPU/CPU timers are last-frame milliseconds
converted to microseconds; draw-submission CPU/cadence/drawcalls/counters separate.
Official4.6 docs verified, API has no disjoint flag, GPU power-state/host noise limit
claims; no Android FPS or universal zero-allocation claim. Raw final packet pending.
Source-known pixels are for Pat to judge after technical gates, no art acceptance yet.


Measured performance finding, 24 October, about3:25 PM Eastern:
All frozen7619 final correctness/state/privacy checks pass: core835/art33/
Confluence15/depth49/pricing64/015SIM2; nativeWell14/camera56/a11y98/ART204,
separate linked command140, all exits0 and clean raw logs. Root and independent
reviewer verified82 evidence files and9 actual frozen Git blobs; reviewer also
recomputed all24 metric medians, all120 snapshot/memory rows and viewed12 images.
No additional technical pixel blocker, but strict no-regression criterion UNMET.
Draw CPU increases80.75..109.75us; viewport CPU43.75..59.25us. All five innerfactory
and innercamera paired blocks increase. GPU medians flat/improved0..31us does not
negate CPU cost. Frame cadence increases113.5..195us, mostly within repeat drift.
No final integration approval or Pat artwork acceptance. Keep draft/no merge.

Immutable quantified baseline e411b8087ab81c8579d8aee1736e6eb70a3cff41,
evidence/032-windows-20261024/head-7619ff1, on archive/codex-032-art-windows-20261024.
292 files128955923bytes before portable index:82 proof/tool files,197development,
9frozen source copies and original manifests/qualification. Original receipt SHA
9a5097ed3cdb5ee8e78f9fe3cabfc6e2d536e1d8132483744ae8ebb1b9d9631d. Scope says
performance baseline, not blanket no-regression or accepted art. Raw failures and
superseded initial cropped/hollow material pictures remain development only.

One bounded work-only native profile identifies repeated shape/circle API work.
Root approved smallest Art-only cached ArrayMesh fill/aperture change, retaining
all AAoutlines/lines/cues/geometry/UV/oldlook and existing knowledge boundaries,
without newnodes/visibilitysubsystem. Exact continuous tint replaces128shade bins.
Worker verifies official API, short paired proof first, full measurement only after
actual source change and promising result. Latest public source remains7619 until
next WIP; code changes require push by3:34PM at latest. Root/reviewer no Godot runs.
Current own7619 checks remain40123591760; optimized head needs its own exact gates.
