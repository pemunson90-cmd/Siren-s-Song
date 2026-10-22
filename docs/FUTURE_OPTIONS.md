# Future options (not current spec, does not block development)

## Siren active sonar (Pat, 21 Oct: keep as a possible later mode)
V7 Sirens have no sonar. They notice Quietus by proximity plus line of sight, by hearing throttle noise, and by hearing Quietus pings. The current "active-sonar sweeper" was a later addition and was rebuilt on V7 senses (handoff 009). The original design is preserved here as an option. Pat's note: it drastically changes gameplay and is more difficult and threatening, so it may return as a hard mode, a late-game enemy, or a challenge modifier.

Preserved code: git branch `claude/future-siren-active-sonar-sweeper` (do not delete) (file `game/src/simulation/sonar_sweeper.gd` exists only on that branch; integration now has the V7-senses sweeper in `sweeper_senses.gd`).

How it works at that tag:
- Charges 2.5 s, then emits an ACTIVE SWEEP for 1.5 s (12 s cooldown). The emission is itself noise (radius 900) that other units can hear.
- For each live craft with a direct water path within 600, it queues a delayed echo (round trip at sound speed).
- A delivered echo makes the sweeper remember the position and depth band, set a 7 s attention window, share a stale report with one nearby peer, and arm a return strike (1.5 s windup).
- The strike hits anything within 55 of the stored spot, in the same band, with a clear path: 22 hull to Quietus, 28 battery to other craft. Stun or pin clears charge, echoes and strike.
- Known rule gap: each delivered echo replaces the armed strike and resets its countdown, so a second craft's echo changes the outcome (audit finding 5, stationary Quietus 78 hull alone, 100 with a second craft). A rule is needed if this returns: first strike stands, or newest echo wins on purpose.
- Counterplay: break line of sight or water path, move after the sweep, stun or pin, change depth band.
