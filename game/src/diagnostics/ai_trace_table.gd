extends RefCounted
# AI trace settings (roadmap Phase G). Off by default: attach() returns an empty
# recorder while enabled is false, and sample() on it costs one is_empty() call.
# Revert by deleting diagnostics/ai_trace*.gd, AI_TRACE.md, ai_trace_tests.gd and its suites.txt row.
static var enabled=false
# Ring buffer caps. Oldest rows drop first; the dropped counters keep the loss visible.
const EVENT_CAP=256
const TICK_CAP=1024
const DEFAULT_ROLE="patroller"
const LOCKISH=["LOCKING","BEAM"]
const STUNNED=["PINNED","DISRUPTED"]
const PARKED=["RETURN","DORMANT"]
# A heard goal is an acoustic arrival point, not the exact source: match the nearest noise within this many world units.
const NOISE_MATCH=64.0
