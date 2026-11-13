# Status

The one live status file. Keep it short. Update it in the change that alters the base, the active work, the top weaknesses, the blockers or the next action. History is in git and in [CHANGELOG.md](../CHANGELOG.md).

Updated: 2026-11-12

## Current integrated base

- `claude/integration` at `cabd5bd5` (2026-11-01). It holds items 126 to 148 and the stable-board package; a debug package of `6182568d` was built for Pat on 2026-11-01 (workflow run 41379272814).
- `main` at `f5b66a19`. `gauntlet/production` frozen at `26e09906`.

## Active work

- Chartered overhaul run `overhaul-20261111` on branch `fable/overhaul-20261111`, paused on 2026-11-12 after phase 8 (code base audit, approved fixes, independent review, test trim). Pull request 262 is a draft (report `.fable/FINAL_REPORT.md`). Next is phase 9, UI and UX repair: `.fable/PHASE9.md`. No writer is active.
- Parked: item 134, route flow (superseded by the release controls of item 127; reopen only if a critic finds route stops again).

## Top weaknesses

Ranked in `.fable/UX_AUDIT.md` (interface, 12 November), `.fable/CODE_AUDIT.md` (code) and `.fable/COLD_REVIEW_6.md` (whole game). In short:

1. Dive controls a new player cannot find or trust: no labelled drone launch or recall, a tap beside a menu sets a route, the route dialog covers the craft, discarding a dive is not confirmed.
2. The end of a dive does not show the photographs taken; photo payoff still favors distance and tools over photo quality.
3. Menus and side modes: five back patterns, briefings written as rules text in Career and Expedition, raw numbers on results and fittings screens, jargon on the route screens.
4. Late-operation variety and the branching route graph.
5. Code: `main.gd` still holds the state its helper modules reach into; drone state is read straight from `alive` in about 30 places.
6. Look and sound have never been compared against reference games; audio has never been assessed. Art direction is Pat's call.

## Blockers

- GitHub Actions: the monthly allowance is spent (12 November 2026). No workflow run, package build included, until Pat asks for one. Testing is local.
- The nightly workflow cannot run until `nightly-integration.yml` is on `main` (next promotion, Pat's call).
- Physical phone acceptance is Pat's.

## Waiting on Pat

- His yes or no on `.fable/UX_AUDIT.md` items B1 to B19.
- Three play questions from his rules (`docs/V7_TO_GODOT_PARITY.md`, "Tests that still fly on the older rules").
- N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9 and his playtest feedback. Older open questions are in [QUESTIONS_FOR_PAT.md](QUESTIONS_FOR_PAT.md) (items 3 and 8).

## Next action

Resume the run with `/siren-s-start-fable` and work through `.fable/PHASE9.md`: ask Pat for his Part B answers, fix the Part A defects, build what he approves, replay it through the critic kit.

Testing rule (Pat, 2026-11-12): the bare minimum, locally. Per change, the suites that test what changed; the everyday set (39 suites, `scripts\toolchain\win\test-suite.ps1 -All -Profile local`) before a merge of size. No GitHub Actions run without Pat asking for it; every push carries `[skip ci]`.
