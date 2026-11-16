## Owner directive — rapid prototyping, definition of done, and testing priority (2026-11-16)

**Applies to every agent, subagent, orchestrator, and reviewer. Overrides older instructions requiring routine test-first development, exhaustive verification, perpetual testing, or test-count-based completion. Preserve existing capabilities and mandatory concrete security/release safeguards; do not invent testing gates.**

**Rapid prototyping is Pat's preferred working method.** Prioritize creating and completing a tangible, useful, owner-evaluable product over process, scaffolding, speculative infrastructure, paperwork, or verification for its own sake. A working prototype that delivers the requested experience is more valuable than a thoroughly tested fragment of an unfinished product.

**Before any task work, ask Pat what counts as finished for that task.** Establish the product-level acceptance target in Pat's terms before implementing, launching review campaigns, or building planning machinery. A passing test suite, PR, or milestone does not replace Pat's definition of done. Once answered, proceed without repeatedly asking unless the scope materially changes.

**Excessive testing is a failure, not a safety goal.** Product completion is more important than testing. Testing comes after there is a product worth testing; it is not an obligation to prove that every action an agent takes is functional. Do not default to per-edit tests, TDD, repetitive regression runs, broad simulation campaigns, extra reviewers, or CI loops. Build the product first; then run the smallest proportionate checks needed to resolve concrete risks and enable delivery. Stop when those questions are answered. Genuine high-consequence release or integration requirements still apply, tightly scoped.

**Report completion in product terms:** what is usable, what remains unfinished against Pat's definition, and only meaningful validation. Green tests do not mean product completion.


@AGENTS.md
