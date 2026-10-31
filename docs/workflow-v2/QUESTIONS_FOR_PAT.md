# Questions for Pat (2026-10-30)

Five yes/no lines, most important first. Recommendation first in each. Everything not asked here is decided in DECISIONS.md and can be reverted by saying "revert Dnn".

1. **Let Claude build game items directly when Codex is out or slower, one bounded session per item, two sessions alive at most, no fan-outs?** I recommend yes. Codex is out for about 4 days and today's rule stops all building; the rule came from unbounded fan-outs, which stay banned.

2. **Make `main` the only promotion target, tagged per milestone, and freeze `gauntlet/production` (kept, never deleted, no longer a target)?** I recommend yes. `main` has not moved since 19 Oct while production took four promotions; two baselines mean neither is the game.

3. **Amend the spec line that says "safe pathfinding" to your 30 Oct ruling (straight legs, crashing possible, light edge assist) and ratify the 10-line intent card in RULINGS.md?** I recommend yes. The spec still endorses the autopilot you rejected, and critics judge against the spec.

4. **Replace ad-hoc updates with one 12-line digest a day plus a push notification only when a decision blocks work?** I recommend yes.

5. **Cap the orchestrator at Opus 5.5 and use Fable 5.1 only for a milestone assessment that involves an architecture-level call or an impasse?** I recommend yes. It mirrors your Astra rule and keeps the expensive model off the daily loop.
