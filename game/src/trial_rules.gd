extends RefCounted
# The six trial rules Pat approved on 2026-11-13 with the words "Yes for testing" (docs/USER_DIRECTIVES.md,
# "2026-11-13: six trial rules from the blind critic rounds"). They are TRIALS: each one is put to Pat again
# after he has played, and each is listed in docs/V7_TO_GODOT_PARITY.md as a difference from the prototype.
# This is the only table. Every site reads a rule through the functions below; no rule is hard-wired where
# it acts. To switch a rule back, change its one constant here. With the rule switched back the game behaves
# exactly as it did before the rules were added.
#
# 1. Dive time stands still while the command wheel, one of its pages, the status sheet, the PAST PINGS sheet,
#    the contact card or the FLEET panel is open. Switch back: WHEEL_HOLDS_TIME=false.
const WHEEL_HOLDS_TIME=true
# 2. The first dive of the Campaign (operation 01, not an Expedition or Career run of it) gives a longer warning
#    before a Siren's lock fires. Every other operation keeps STANDARD_LOCK_SECONDS. Switch back: set
#    FIRST_DIVE_LOCK_SECONDS to the same figure as STANDARD_LOCK_SECONDS (4.0).
const STANDARD_LOCK_SECONDS=4.0
const FIRST_DIVE_LOCK_SECONDS=6.0
# 3. The game pauses when a craft that was moving reaches the end of its route. Intermediate stop points do not
#    count: the craft carries on by itself after them. Switch back: PAUSE_AT_ROUTE_END=false.
const PAUSE_AT_ROUTE_END=true
# 4. The game pauses whenever a new lock by a Siren starts on any of the player's craft, whatever the
#    accessibility setting says. Switch back: PAUSE_ON_EVERY_LOCK=false (the accessibility settings still work).
const PAUSE_ON_EVERY_LOCK=true
# 5. The game pauses once when a craft holds because rock blocks its leg. Switch back: PAUSE_WHEN_BLOCKED=false.
const PAUSE_WHEN_BLOCKED=true
# 6. An Expedition operation's optional rider starts switched on (true) or off (false). The player can still
#    switch it on. Naval Career has its own variable and is not affected. Switch back: EXPEDITION_RIDER_DEFAULT_ON=true.
const EXPEDITION_RIDER_DEFAULT_ON=false

const DEFAULTS={
	"WHEEL_HOLDS_TIME": WHEEL_HOLDS_TIME,
	"FIRST_DIVE_LOCK_SECONDS": FIRST_DIVE_LOCK_SECONDS,
	"PAUSE_AT_ROUTE_END": PAUSE_AT_ROUTE_END,
	"PAUSE_ON_EVERY_LOCK": PAUSE_ON_EVERY_LOCK,
	"PAUSE_WHEN_BLOCKED": PAUSE_WHEN_BLOCKED,
	"EXPEDITION_RIDER_DEFAULT_ON": EXPEDITION_RIDER_DEFAULT_ON,
}
# Test seam. Only test suites call override() and reset(); the game never does.
static var _overrides:Dictionary={}
static func override(rule:String,value)->void:
	assert(DEFAULTS.has(rule),"unknown trial rule "+rule)
	_overrides[rule]=value
static func reset()->void:
	_overrides.clear()
static func _read(rule:String):
	return _overrides.get(rule,DEFAULTS[rule])

static func wheel_holds_time()->bool:return bool(_read("WHEEL_HOLDS_TIME"))
static func first_dive_lock_seconds()->float:return float(_read("FIRST_DIVE_LOCK_SECONDS"))
static func pause_at_route_end()->bool:return bool(_read("PAUSE_AT_ROUTE_END"))
static func pause_on_every_lock()->bool:return bool(_read("PAUSE_ON_EVERY_LOCK"))
static func pause_when_blocked()->bool:return bool(_read("PAUSE_WHEN_BLOCKED"))
static func expedition_rider_default_on()->bool:return bool(_read("EXPEDITION_RIDER_DEFAULT_ON"))
