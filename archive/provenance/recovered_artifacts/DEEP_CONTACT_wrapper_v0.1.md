---

# DEEP CONTACT — Cowork Project Instructions (Wrapper)

*Wrapper v0.1 — appended 2026-06-03. Source: this design session only; no prior project
chats exist yet, so everything here is extracted from this conversation. Uncertainties are
flagged **[VERIFY]** rather than asserted.*

## Project Identity

A standalone game-dev project space for building and iterating **Deep Contact** (working
title — see boundaries), a one-shot, single-site, 2D top-down stealth game built as a
**test bed**. The player pilots a zero-kill experimental stealth sub to photograph an alien
deep-sea factory guarded by unkillable "Sirens." The project is exploratory: the goal is a
playable prototype that proves the loop, not a shipped commercial title.

## Source of Truth & Document Hierarchy

- **This file is the single canonical spec.** It is built up incrementally across sessions —
  **append, don't fork.** New decisions amend the relevant section; supersede with a version
  bump, never spawn parallel docs.
- §1–10 = functional design (what the game is). §11 = build leash (how Cowork builds it).
  This wrapper = project governance (how the space operates).
- Build outputs (code, the playable file) are products *of* this spec. If code and spec
  disagree, **the spec wins** unless Pat amends the spec.

## Domain Invariants (do not drift)

These are the project's canon. Any build, edit, or "improvement" that violates one is wrong
by definition, even if it seems like a better game:

1. **No enemy HP. No player kill-path.** Sirens are never defeatable. Tools disrupt; they
   never deal lethal damage. A build that adds a Siren health bar has failed the brief.
2. **Suspicion is the spine.** Threat escalation runs through the suspicion meter and its
   four states — not through scripted aggression or RNG.
3. **Perceiving costs.** Every way of seeing carries a suspicion or scarcity cost. Nothing
   reveals the world for free except passive sonar.
4. **Tools buy time and cost heat.** No tool is consequence-free.
5. **Fairness valve is mandatory.** Suspicion decays; instakill only on sustained max with a
   warning window. One mistake must never be an un-survivable instant restart.
6. **Function before form.** No art, sound, palette, or UI-chrome work until the systems are
   built and tuned. Form is always a later, separate pass.

## Build Governance (Cowork)

- Follow the §11 build order exactly. **Stop after each numbered step and hand back for
  review** — do not run the whole pipeline unattended.
- Honor the §11 DO-NOT list. No proc-gen, multi-level, meta-progression, or menus beyond
  start/restart in v1.
- All balance numbers are tunable defaults; changing them is expected. Changing the
  invariants above is not.
- **[VERIFY] Tech stack unconfirmed.** Spec says 2D top-down, point-and-click. The
  implementation target (single-file HTML5 canvas vs. a pixel/JS framework vs. an engine) is
  not yet pinned — confirm before scaffolding.

## Boundaries

- This is a **standalone project.** Not Nova Mobiles, not Lease World / Geiss, not
  Supernarrative canon. Keep mechanics, characters, and lore from those spaces out unless
  Pat explicitly imports them.
- Lore base is generic military + conspiracy-theory material (UFO USOs, the
  underwater-factory meme): original framing, influences only, not reproduction.
- **[VERIFY] Is Deep Contact part of the Supernarrative, or fully standalone?** Assumed
  standalone until confirmed.
- **[VERIFY] "Deep Contact" is a working title assigned during the design session, not a
  name Pat ratified.** Replace freely.

## Quick Reference

- Unkillable enemies, no kill-path — ever.
- Suspicion meter is the entire difficulty engine.
- Seeing = being seen.
- Function before form; build in §11 order, stop per step.
- This file is the source of truth; append, don't fork.
