# Addendum B to the external adversarial audit: external reference bar for critics

## Provenance

| Field | Value |
| --- | --- |
| Date | 2026-10-19 |
| Author | Claude Opus 5.5 (Anthropic), external auditor |
| Parent documents | `docs/reviews/2026-10-19-external-adversarial-audit.md` (F7, intervention 7) and Addendum A |
| Status | **Proposal.** Becomes governing only when the owner hands it to the Gauntlet as direction. If ratified, persist it into `docs/AGENT_BRIEF.md` and the critic briefs per the AGENTS.md rule on persisting agreed decisions. |

### Owner-stated facts vs auditor proposals

- **Owner's words (2026-10-19, paraphrased from chat):** Siren's Song is basically a top-down point-and-click tactical game. It is inspired by Frozen Synapse, Door Kickers, and submarine games the owner saw as a child but never played, possibly including one called something like "Silent Hunter."
- **Everything else below** (the reference roles, Barotrauma, Mark of the Ninja, Into the Breach, the method) is the auditor's proposal.

## Problem this addresses

The Gauntlet is modeled on Matt Shumer's "Gauntlet Loop." The original loop gave its critics a concrete external bar: each piece was compared against footage of a shipped game in a blind side-by-side. Siren's Song critics compare against concept art and the design bible. Those are internal references, and concept art does not move, so no critic was ever forced to compare enemy behavior over time. A blind clip next to a shipped game would have exposed the frozen Sirens (audit F1, Addendum A) immediately.

The original loop's published critic scores still climbed only from about 3.6 to just over 5 out of 10, and the real game won every logged round. The external bar keeps critics honest; it does not create quality by itself.

## Proposed reference set: one job per game

Each reference judges one dimension. A critic asked "is this as clear as X at Y" gives a verdict; a critic asked "does this look like X" does not.

| Reference | Judges | Why this one |
| --- | --- | --- |
| **Door Kickers** | Route planning, waypoints, conditional orders, touch planning UI | Owner-named inspiration and the closest mechanical match: top-down, real-time with pause, drawn routes and go-codes. At its Android launch it was tablet-only, which shows its developers judged phone screens too cramped for that planning UI. That maps directly onto the Fold7: inner screen is tablet territory, the cover screen is the hard case. |
| **Frozen Synapse** | Plan legibility, intent lines, enemy-position uncertainty, HUD economy | Owner-named inspiration. Minimal visual language with highly readable plans; a test of whether the Siren's Song HUD earns its density. Shipped on Android, with a later Prime version. |
| **Silent Hunter** series (pending owner confirmation of the title) | Submarine atmosphere, plotting on a navigation chart, the feel of commanding a vulnerable boat | Owner's possible childhood reference. Primarily a 3D submarine simulator, but its map and plotting view is the relevant reference for chart memory and planned routes. Use for atmosphere and chart work, not for UI density. |
| **Barotrauma** | Sonar as the primary view of the world, creature behavior, submarine dread | 2D submarine game built around sonar and hostile creatures that move with intent. The comparison that would have caught the patrol stall. |
| **Mark of the Ninja** | Making noise and detection visible and learnable | Side-on rather than top-down, but the reference standard for showing sound as visible rings. "Moving makes noise" is a core Siren's Song tension, and its noise is currently mostly invisible. |
| **Into the Breach** | Telegraphing enemy intent on a small screen | Every threat shows its next action. Bar for the lock and beam countdown and the "superior but legible" Siren goal. On mobile via Netflix. |

**Starting set:** Door Kickers, Barotrauma, Mark of the Ninja. These cover the largest current gaps: touch planning, enemy life, readable noise. Add Frozen Synapse, Silent Hunter and Into the Breach once those close.

## Method for critics

1. **Clips, not stills.** Capture 10 to 20 second Siren's Song clips of the dimension under review, including at least one clip with no player input (watch the world). Pair each with reference footage of the same dimension.
2. **Blind where possible.** Strip titles and HUD branding from both clips. The critic states which clip better achieves the dimension and why, before learning which is which.
3. **One dimension per comparison.** Route planning against Door Kickers; enemy movement and sonar against Barotrauma; noise feedback against Mark of the Ninja.
4. **Record losses.** Log each comparison result, including outright losses, in `docs/BASELINE_AND_EXPERIMENTS.md`. Losing to a shipped game is expected and is the useful signal.
5. **No imitation.** References judge clarity, behavior and feel. Siren's Song keeps its own identity, art and mechanics; nothing is copied.
6. **Footage over play.** Mobile availability above is from launch-era articles and decade-old ports may be delisted. Confirm current store status before asking anyone to play one; recorded footage works regardless.

## Sources

- [Android Police: Door Kickers on Android, tablets only](https://www.androidpolice.com/2015/09/03/door-kickers-brings-innovative-controls-to-the-squad-based-tactical-strategy-game-but-only-on-tablets/)
- [Android Police: Frozen Synapse launches on the Play Store](https://www.androidpolice.com/2013/06/19/new-game-frozen-synapse-launches-in-the-play-store-for-6-99-reminds-everyone-how-awesome-the-humble-bundle-is/)
- [Pocket Gamer: Frozen Synapse Prime on Android](https://www.pocketgamer.com/articles/064373/r/)
- [Engadget: Into the Breach as a Netflix mobile exclusive](https://www.engadget.com/netflix-into-the-breach-ios-android-mobile-exclusive-204020515.html)
- [Decrypt: the Gauntlet Loop](https://decrypt.co/374560/dumbest-ai-prompt-claude-beat-careful-game-design)
