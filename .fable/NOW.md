# NOW: what the root session is doing

Status: LIVE NOTE (rewritten before every step; if a session died, this is the step it died in)
Updated: 2026-11-13 14:43

**To resume after a context clear or a new session:** open this folder as the project and run `/siren-s-start-fable`. Read `.fable/PHASE9.md` first: it is the whole handoff. The `next_action` field in the state file always starts by sending the session to `.fable/HANDOFF.md` and to this file.

## Doing right now

RUNNING. WP-51, WP-52, WP-53 merged at b352f808 and pushed (rows 81 to 83 still to write). A full local sweep of every registered suite is running in the background on the root worktree: results in the session scratchpad file sweep_result.txt. WP-54 (six trial rules) is with one Sonnet implementer. Do not edit game source in the root worktree until the sweep ends.

## In flight

| Package | Branch | What | Owns |
|---|---|---|---|
| WP-54 | `wp-54` | The six trial rules Pat approved "for testing": open wheel or panel holds time; 6 s lock on the first Campaign dive; pause at a route's end, on every new lock, when blocked by rock; Expedition rider starts off. One table `game/src/trial_rules.gd`, one auto-pause path | `trial_rules.gd`, `presentation/auto_pause.gd`, lock length in `simulation.gd`, time hold in `main.gd`, `tactical_aids.gd`, rider default, parity doc |

If the session died: the branches are local in the helpers' worktrees (`git worktree list`, `git branch --list "wp-4*"`). A branch with commits can be reviewed and merged as it stands; one without is redispatched from PHASE9.md "Queue".

## Next, in order

1. Review, merge, test and look at WP-40, WP-41, WP-42 as each reports.
2. C8 (route dialog, `order_guard.gd`) with the small dive-screen items from PHASE9.md "Seen in the kit and not yet fixed".
3. C9 and B17, then a fresh blind critic round, then the everyday set and the pull request 262 body.
