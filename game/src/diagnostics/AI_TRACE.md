# AI trace (roadmap Phase G)

Read-only observer of Siren state for tests and debugging. It never writes to the
simulation, saves or detection, and does nothing unless attached.

```gdscript
const Trace=preload("res://src/diagnostics/ai_trace.gd")
const TraceTable=preload("res://src/diagnostics/ai_trace_table.gd")
TraceTable.enabled=true                  # default false: attach() then returns {} and sample() is a no-op
var rec=Trace.attach(sim)                # optional: attach(sim, true) for a per-tick row ring, attach(sim, false, {"event_cap":64})
Trace.step(rec, sim, 0.1)                # sim.advance(dt) then sample; in a game loop call Trace.sample(rec, sim) after each advance
var out=Trace.export(rec)                # {"events","ticks","metrics"}; same script gives an identical dictionary
Trace.detach(rec, sim)                   # disconnects siren_notice
```

Event row: `{t, id, role, from, to, cause, suspicion, alert_floor, lock, target, pos, band}`. The first row per Siren has `cause` "init" (state at attach). `cause` is derived from existing fields, best effort: `sight` (LOCKING), `timer` (BEAM, patrol or return changes), `sound:<LABEL>` or `sound` (INVESTIGATE from a heard emission), `decoy`, `report` (guard has `report_interest`), `stun` and `stun_end`, `lost_target`.

Metrics (seconds since attach, -1 if it never happened), per Siren: `time_to_first_notice` (first `siren_notice`), `time_to_lock_start`, `time_to_detection` (first sample with a target), `time_to_beam`, `transitions`; plus totals `transitions`, `noticed`, `first_notice`, `first_lock`, `samples`, `dropped`, `dropped_ticks`.

Rings are capped by `EVENT_CAP` and `TICK_CAP` in `ai_trace_table.gd`; oldest rows drop first and the dropped counters keep the loss visible. Times are stamped at the end of the tick that caused the change.

Revert: delete `diagnostics/ai_trace*.gd`, this file, `tests/ai_trace_tests.gd` and its last row in `tests/suites.txt`. No other file refers to them. Tests: `AI TRACE` suite.
