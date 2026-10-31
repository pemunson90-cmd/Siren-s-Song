# Siren's Song: operating instructions (workflow v2, DRAFT)

Draft written 2026-10-30. Replaces the root `AGENTS.md` only after Pat approves (see docs/workflow-v2/MIGRATION.md step 10). Until then the live `AGENTS.md` governs.

## What we are making

An original Android-first 2D tactical submarine reconnaissance game. One pilot commands the Quietus and two drones under unlimited tactical pause. Sensing is limited, noise draws the Sirens, craft move under real physics. Godot 4.6.3, GDScript, Compatibility renderer, game in `game/`. The six authored missions are the tutorial arc. The goal is a long branching campaign with meaningful submarine and drone upgrades and several endings, at a quality that stands next to strong commercial games on a phone. It has to be a game: challenge and risk, decisions that change outcomes, piloting by hand.

## Who decides

- **Pat** rules and approves in chat, usually from a phone. One yes/no question at a time, recommendation first. He never operates tools. He is asked only about protected rules, art direction, story canon and real forks. Everything else is decided by the orchestrator, logged in `docs/state/DECISIONS.md` with a revert line, and reported in the daily digest.
- **Authority order**: Pat's dated words in `docs/state/RULINGS.md` > the intent card in the same file > `docs/CURRENT_GAME_SPEC.md` > demonstrated play and source > history > proposals.
- **Protected, Pat's call only**: beam lethality; the 4 s interruptible lock warning; collision, hull and damage; Siren and role senses (silent sight 180 m, cruise sight 290 m); the PR70 sweeper; photography exposure and grading; ending conditions; art direction. Story text stays 1 to 2 line placeholders with no em dashes.
- **Never**: build an APK unless Pat asks; force push; amend or rewrite shared history; delete a branch; skip, loosen or delete a test to get green; merge known broken game or save behaviour.
- **Release controls (Pat, 30 Oct 2026)**: one-press travel orders (route to work, route here, withdraw or home autopilot, object-tap auto-route) exist only behind the dev state and are stripped from release play. Release play is piloted by hand: planned waypoint legs, depth, in-reach jobs, recalling drones. Crashing stays possible with only a light edge-slide or hold assist. Finishability is measured with a hand-piloting policy, never with shortcuts.

## The loop

1. Nightly metrics and the latest critic verdicts say what the game is now.
2. The orchestrator keeps a short queue of items ranked by player cost (docs/state/queue.json, items in docs/state/items/).
3. The runner builds items on whichever provider is up, one bounded session per item, in isolated worktrees whose file areas cannot overlap.
4. Each PR carries evidence sized to its change class, gets one independent reviewer and one intent check, then the runner merges it serially onto a green integration branch.
5. At a milestone: tag, blind critics against the intent card and named reference games, a milestone assessor ranks the next plan and reviews the workflow itself. Promotion to `main` on Pat's yes.
6. Repeat. Only Pat ends it. A finished item, PR or milestone is never a stopping point.

## Roles

| Role | Default | Fallback |
|---|---|---|
| Orchestrator | one Claude session, Opus 5.5 medium | |
| Builder | Codex gpt-6.1-sol medium | Claude Sonnet 5.5 (text, UI) or Opus 5.5 (sim, persistence); two builder sessions alive at most, never fan-outs |
| Reviewer | the other provider, high effort | same provider, different model |
| Blind critic | Sonnet 5.5, 400 commands or 150k context per region | Codex gpt-6.1-sol |
| Milestone assessor | Opus 5.5 high | Fable 5.1 only for an architecture-level call or an impasse |
| Mechanical helper | Haiku 5.5, read-only | |

## Items

One player-facing gain per item, one builder session, one ownership area, an acceptance test named before work starts, about 400 changed lines at most. Template: `docs/state/ITEM_TEMPLATE.md`. Change class text, ui, sim or protected sets the evidence cap. `main.gd`, `mission_hud.gd`, `ocean_view.gd` and `simulation.gd` admit one live item at a time.

## Branches

`item/NNN-slug` into `claude/integration` by merge commit, merged only by the runner, one at a time, after the full matrix on the exact merge candidate. `main` is the accepted baseline, promoted by PR at milestones and tagged. `gauntlet/production` is kept and frozen. Live state lives on `codex/handoffs` under `docs/state/`.

## Testing

Before a push: import, core, the affected suites from `select-suites.py`, the canary set. On a ready-for-review PR: the same. Full matrix: merge candidate and nightly only. Ruling tests (release controls, hand-pilot finishability, protected golden, crash possible, control mix) are canaries and run every time. Draft PRs run no game jobs.

## Evidence caps

text 20 lines and 2 PNGs; ui 40 lines and 8 PNGs; sim 40 lines and one table of at most 14 rows; protected 60 lines with Pat's ruling verbatim. Raw material lives in the artifact cache with a SHA-256 manifest. Reviews are 10 lines. Intent checks are 5 lines ending `INTENT: PASS` or `INTENT: HOLD <reason>`.

## Keep Git lean

Game source, assets, tests, tooling, compact instructions. Critic reports, metrics, screenshots, logs and notes stay in the artifact cache under dated folders. One compact verdict per milestone (under 25 KB) goes to `docs/design/`. `docs/state/STATE.md` stays under 60 lines.

## Pause and resume

On a usage limit or outage, the runner writes a PAUSED block to STATE.md with the exact resume command, keeps the other provider working, and the orchestrator does read-only work. Never claim background execution after a session ends.
