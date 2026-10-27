# Handoff 052: OPTIONAL OPERATIONS, Sorley's trawler + 3 more (ids 37 to 40)

Status: DONE
Claimed at: 2026-10-27 02:10:55 UTC
Claimed by: codex
Finished at: 2026-10-27 03:33:35 UTC

Precondition: 051 is DONE. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Bring optional operations from 8 to 12 (spec target). Optionals are side jobs: shorter, one sharp idea each, never required for the campaign.
- 37 **Sorley's trawler** (bible section 2 item 8), placed in arc 4 Glass Reach, requires 15. A fishing boat sunk on a wellhead; one survivor, a boy, in an air pocket; no threat at all, the Sirens hit it anyway. Quiet, tense, small. Recover artifact `trawler_screw` (append RECIPES row). Skipper Iain Sorley gives honest pilotage notes.
- 38 deep-thread optional in arc 2 (requires 7), 39 shelf-thread optional in arc 2 (requires 8), 40 Confluence optional (requires 11, either route). Reuse the existing region geometry of their arc where possible; each needs one distinct decision (a photo vs survivor tradeoff, a depth-band crossing, a Hunt-pressure gamble, and so on). AI-DESIGNED: you pick the idea; keep it consistent with the bible.
- Optional ops appear in Operations and the route map with a clear OPTIONAL label, using route-map data only (ops_home is Claude's).
- Placeholder text only, no em dashes.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-optional-ops

## Files you may edit
New operation files for 37 to 40; campaign/operation_catalog.gd (append); the RECIPES row; route-map data rows if optional marking needs them; shared append-only files; one MODULES.md row and one RESUME bullet.

## Files you must not touch
Claude-owned files (ORCHESTRATION section 3), existing ops content, endings, protected mechanics.

## What done looks like
Four new optional ops launch, finish and pay out; campaign completion never requires them. CI green.

## Checks
Import and core only (optional ops cannot softlock the campaign). Add a journey only if you change a shared system.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
Four OPTIONAL photo side jobs37..40 merged in https://github.com/pemunson90-cmd/Siren-s-Song/pull/153; no core job depends on them.
Landed77f26ced6024da49c3c5c1fae81123ddae325bcc; retained laneed45b49eb20227fd17f6cb1df692380aedb45c2e; tree verified, exact-head gates green40437527882.
Windows import/core845/0 including new-operation save roundtrips; no optional journeys added under current rules.
Physical trawler_screw uses existing cargo; hull:fast follows054/055. Boy image confirms survival, not rescue. Phone play deferred.
Necessary data seams: simulation/glass_reach_work.gd cargo ID, hunt_pressure/hunt_table.gd arc caps and route fixtures41nodes. Protected mechanics unchanged; ownership released, next053.