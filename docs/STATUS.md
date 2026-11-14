# Status

The one live status file. Keep it short. Update it in the change that alters the base, the active work, the top weaknesses, the blockers or the next action. History is in git and in [CHANGELOG.md](../CHANGELOG.md).

Updated: 2026-11-14

## Current integrated base

- `claude/integration` at `cabd5bd5` (2026-11-01). It holds items 126 to 148 and the stable-board package; a debug package of `6182568d` was built for Pat on 2026-11-01 (workflow run 41379272814).
- `main` at `f5b66a19`. `gauntlet/production` frozen at `26e09906`.

## Active work

- Chartered overhaul run `overhaul-20261111` on branch `fable/overhaul-20261111`, in phase 9: UI and UX repair by Claude's judgement (resumed on Opus 13 to 14 November). Merged and pushed: work packages WP-31 to WP-92 (report rows 57 to 122), five blind critic rounds, and six trial rules Pat approved "for testing" (`game/src/trial_rules.gd`). Plan, rankings, what is unseen and the queue: `.fable/PHASE9.md`. Pull request 262 is a draft (report `.fable/FINAL_REPORT.md`).
- Parked: item 134, route flow (superseded by the release controls of item 127; reopen only if a critic finds route stops again).

## Top weaknesses

From `.fable/UX_AUDIT.md` (interface and looks), `.fable/CODE_AUDIT.md` (code) and `.fable/COLD_REVIEW_6.md` (whole game). What is still open, most costly first:

1. Long waits on the way home: route legs are about 450 m and Quietus is slow when silent; all three fifth-round critics spent much of a return leg waiting. A 2x speed button while no Siren hunts is proposed to Pat (his travel rules). The fixes of the fifth round (rows 112 to 122) need the sixth blind critic round.
2. Photo payoff still favors distance and tools over photo quality (waits for Pat's playtest and the pay retune he approved).
3. Late-operation variety and the branching route graph.
4. Three play questions raised by Pat's own rules (tender door with quiet drones, the scout-ahead opening, operations 17 and 30 on discovered charts).
5. Code: `main.gd` still holds the state its helper modules reach into; drone state is read straight from `alive` in about 30 places.
6. Sound has never been assessed; phone feel can only be judged by Pat.

Fixed this week and no longer on the list: the hub as a wall of look-alike buttons, a tap on a Siren setting a route onto it, colliding chart labels, jargon on the route and wheel screens, mixed back labels, engineering notes in the credits, no visible drone deploy or recall, the dialog covering the craft, unconfirmed run endings, the lost screen hiding photographs, look-alike buttons, pause and life support not reading as controls, stale status lines.

## Blockers

- GitHub Actions: the monthly allowance is spent (12 November 2026). No workflow run, package build included, until Pat asks for one. Testing is local.
- The nightly workflow cannot run until `nightly-integration.yml` is on `main` (next promotion, Pat's call).
- Physical phone acceptance is Pat's.

## Waiting on Pat

Nothing blocks the work. For his play, when he gets to it: the items under "Open for Pat" in `.fable/PHASE9.md`, N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9, and the older open questions in [QUESTIONS_FOR_PAT.md](QUESTIONS_FOR_PAT.md) (items 3 and 8).

## Next action

Resume the run with `/siren-s-start-opus` (or `/siren-s-start-fable` on the Fable model) and continue `.fable/PHASE9.md`: run the eighth full sweep of every registered suite on the merged head (WP-88 to WP-92 merged after the seventh) and fix what it finds; then the sixth blind critic round.

Testing rule (Pat, 2026-11-12): the bare minimum, locally. Per change, the suites that test what changed; the everyday set (39 suites, `scripts\toolchain\win\test-suite.ps1 -All -Profile local`) before a merge of size. No GitHub Actions run without Pat asking for it; every push carries `[skip ci]`.
