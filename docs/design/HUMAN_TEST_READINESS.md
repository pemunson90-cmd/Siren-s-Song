# Human test readiness gate

Status: PROPOSAL, 24 Oct 2026 Eastern. AI-DESIGNED by the Claude orchestrator; Pat ratifies it.

## Pat's rule (24 Oct)
No phone or human testing until the whole program and gameplay experience is feature complete and as tuned as automated work can make it. Story and art finalization are not blockers (placeholders are acceptable). After Pat's test, Pat sets up the new expansion Gauntlet prompt. No APKs before the gate is met.

## What "ready" means: seven checks, each with evidence

| # | Check | Evidence that counts | Owner |
|---|---|---|---|
| 1 | Feature complete against the spec | Every handoff on docs/codex/BOARD.md is DONE or deliberately deferred by Pat; docs/CURRENT_GAME_SPEC.md has no open "must" item without a handoff | Claude audits, Pat accepts |
| 2 | Campaign playable end to end | Scripted journeys win ops 1 to 31 with the intended routes; ending flow and photo wall reachable; old saves load; hard saves and fork states work | Codex tests, Claude reviews |
| 3 | Fair detection | AI trace (Phase G) time-to-first-notice and time-to-lock on scripted routes inside a stated band per op; no op where an unaware, quiet player is locked with under the 4 s warning; Hunt (when restored) caps respected | Claude |
| 4 | Pressure curve | Per-op difficulty table reviewed: early ops gentle, later ops harder, no spike of more than one new idea per op | Claude proposes, Pat sets numbers |
| 5 | Phone performance | Redraw only when needed, catch-up tick cap, no per-frame allocation hot spots in the three big drawing files, texture size and APK size within a stated budget; headless frame-time probes recorded | Codex (after art work), Claude measures |
| 6 | Robustness | Core suite and the full hosted matrix green on the exact release-candidate head; no "resources still in use" lines; save corruption tests pass; Back/Escape consistent on every screen | Codex + CI |
| 7 | Tester kit | One page for Pat: how to install the build, what to try (a short route list), what to look and listen for, how to report; a build with the debug signing identity only; known gaps list | Claude |

## What is deliberately NOT required
- Final story text, final art, final audio mix (placeholders are fine; the known gaps list names them).
- Any change to combat, collision, damage, hull or Siren sight/hearing/lock timing beyond what Pat has already approved (Hunt restore numbers are ratified by Pat before they ship).

## How the gate is called
1. Claude writes docs/repository/RC_ACCEPTANCE_YYYYMMDD.md with one line of evidence per check and every known gap.
2. A fresh cold review (like COLD_REVIEW_3) runs against the release candidate; no blockers open.
3. Claude tells Pat in plain words: "ready" or "not ready, and here is the one thing".
4. Pat decides whether to build the test build. No APK is built before that.

## Early warning signs to report to Pat
- A queued handoff blocked for more than a day.
- A check in the table with no owner or no evidence path.
- Core suite count drops, or a test is removed.
