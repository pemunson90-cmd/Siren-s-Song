# DIRECTIVE: PASS 0 · BUILD THE WHOLE GAME ROUGH, THEN IMPROVE IT

**From the user, 2026-10-19.** Read this after SIRENS_SONG_AUDIT_AND_PAUSE_2026-10-19.md. Where the two conflict, this file wins.

## The problem

You keep improving pieces of a game that does not exist yet. The loop is meant to evaluate the whole game and fix its biggest weakness. With no whole game to look at, the biggest weakness always looks local: a label, a caveat, a save edge case. So you polish edges and the game never gets finished.

## The order changes

Pass 0 runs before the audit's Passes 1 to 3.

**Pass 0: a rough, complete, playable game, start to finish.**
1. Write a one-page campaign plan: the branch graph, the endings, the upgrade list and the enemy roster. Write it once, then build it. Do not polish the plan.
2. Build every node of that plan at rough quality:
   - Every branch reachable and playable through to its own ending.
   - Every ending with a real end screen and its own outcome. No generic debrief.
   - Quietus and drone upgrades that change what the craft can do across missions. Keys that unlock one authored objective do not count.
   - Every enemy role (patroller, sentinel, hunter, plus anything new in the plan) appears beyond the tutorial.
   - Placeholder art, text and audio are fine everywhere.
3. Reuse missions 0 to 13 where they fit the plan. Replace or cut any that do not.
4. Pass 0 is complete when critic agents can play every branch to every ending through real input. Then run the whole-game evaluation and continue with Passes 1 to 3, reordered by what that evaluation finds.

Pass 0 being complete does not end the Gauntlet. Only the user ends the Gauntlet.

## Rules that change now

- **Drop legacy save compatibility** until the user ends the Gauntlet. No new `*_revision` flags to preserve old saves. An old save that no longer fits is rejected cleanly and the player starts fresh. It must never crash.
- **Rough merges are allowed.** Placeholder content, unbalanced numbers and ugly layout can merge. The only merge blockers are crashes, softlocks, a branch that cannot be completed, and corruption of current saves.
- **No polish work during Pass 0:**
  - label or caveat wording;
  - layout nudges;
  - save-shape validation;
  - evidence packets;
  - governance tooling;
  - more than one doc refresh per completed plan node.
- **One reviewer pass per merge, aimed at crashes and blockers.** Quality judgment happens in the whole-game evaluation, not at each merge.

## How the user judges this

The user does not play until he ends the Gauntlet. When he checks WORKBENCH, he wants to see the campaign plan with each node marked unbuilt, rough or improved. Nothing else.
