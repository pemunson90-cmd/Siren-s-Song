# Agent instructions — Siren's Song

Read `docs/START_HERE.md` and `docs/SOURCE_AUTHORITY.md` before substantial work. Consult the design bible and provenance sources when available.

## Identity and design

Siren's Song is an original Android-first 2D tactical stealth game. A single human pilot commands the USS Quietus and remote drones against technologically superior alien Sirens. Core tensions: perceiving exposes you; moving makes noise. Drones extend perception and attention is limited. The agreed working control direction is continuous real-time simulation with unlimited tactical pause, assisted navigation, queued waypoints and conditional orders.

The production game targets multiple missions, satisfying progression, compelling audio, and a distinctive visual identity. Treat old one-level and no-procedural-generation prototype constraints as historical scope decisions.

## Autonomy

Agents may propose and implement original mission design, progression, visuals, systems, tools, and technical architecture within the game's identity. Escalate changes that materially rewrite the premise, core player role, or established identity. Document significant creative decisions and provenance.

## Execution and quality

- Research and reuse maintained, suitably licensed implementations before building custom equivalents.
- Favor inspectable builds and measured results over unsupported claims.
- Preserve a working baseline; use focused branches/PRs for substantial changes.
- Capture screenshots and repeatable gameplay scenarios for visual and experiential review.
- Test Android behavior, performance, input, save/resume, and failure cases.
- Keep independent reviews evidence-driven; critics should inspect artifacts before builder explanations.
- Record unresolved design questions without silently ratifying proposals.
- Do not configure a new Codex environment or lock the game engine without reviewing existing environment capabilities and documenting the choice.

## Coordination

Codex is the provisional primary implementer; Claude Code can contribute art direction and independent reviews; Astra is optional for difficult tasks. These are flexible roles, not exclusive ownership. Avoid concurrent edits to the same files; integrate through reviewable changes.
