extends RefCounted
# WP-48: the wording of the dive's state controls, in one table. The pause plate names the state first and
# the action second; the silent segment and its centre caption say what the switch does and costs; the
# sonar segments name the ping, not the old transmit jargon; two status lines say why the dive is held and
# when a craft has finished its route. Presentation only: no rule, order id or saved value is touched.
# Every figure shown is read from the constant the simulation uses (see speeds() and sights()):
#   Siren sight   photo_pricing_table.gd SIREN_SIGHT / SIREN_SIGHT_SILENT
#   Quietus speed rule_table.gd CRAFT_SPEED (silent / cruise) through craft_upgrades.gd, the same call
#                 the simulation makes for the fitted hull and drive (cruise_speed, frame_speed).
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const RuleTable=preload("res://src/photo_rules/rule_table.gd")
const CraftUpgrades=preload("res://src/equipment/craft_upgrades.gd")
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
const TEXT={
	"paused": "PAUSED",
	# Time stands still only while a menu or the route prompt is open (trial rule 1); closing it lets time run.
	"held": "HELD",
	"running": "RUNNING",
	"tap_resume": "TAP TO RESUME",
	"tap_pause": "TAP TO PAUSE",
	"route_prompt": "ANSWER ROUTE PROMPT",
	"close_to_resume": "CLOSE TO RESUME",
	"join": " · ",
	# A toggle segment names the action a tap performs (first line) and the state it is in now (small second line).
	"silent_off": "GO SILENT",
	"silent_on": "GO LOUD",
	"silent_state_off": "running loud",
	"silent_state_on": "silent is on",
	"silent_off_line": "%s\nslower (%d m/s) · seen from %d m",
	"silent_on_line": "%s\nfull speed (%d m/s) · seen from %d m",
	"profile_low": "GO LOW PROFILE",
	"profile_open": "GO OPEN",
	"profile_state_low": "low profile is on",
	"profile_state_open": "open profile",
	"profile_low_line": "%s\nSirens see this drone from %d m, not %d m\nIts speed is unchanged",
	"profile_open_line": "%s\nSirens see this drone from %d m, not %d m\nIts speed is unchanged",
	"confirm": "Tap again to confirm",
	# The target chooser's centre question: only craft to pick from, or craft and objects mixed.
	"choose_craft": "WHICH CRAFT?",
	"choose_any": "CRAFT OR OBJECT?",
	"depth_menu": "DEPTH AND\nSONAR",
	"all_stop": "ALL STOP",
	"audio_log_empty": "No sounds logged yet",
	"rock_route": "This route crosses charted rock. Tap the marker again to send it anyway, or tap open water.",
	"rock_route_replace": "REPLACE ROUTE would cross charted rock; ADD TO ROUTE would not. Tap open water to move the marker.",
	"rock_route_add": "ADD TO ROUTE would cross charted rock; REPLACE ROUTE would not. Tap open water to move the marker.",
	# WP-69: a tap on open water that orders nothing says what a water tap needs (or that the dive is over).
	"tap_idle": "Select a craft first: tap Quietus or a drone, or use FLEET",
	"tap_over": "The dive is over: no craft can be ordered",
	"send_anyway": "SEND ANYWAY",
	"ping": "PING SONAR\nuses %s reserve",
	"ping_free": "PING SONAR\nuses no reserve",
	"ping_caption": "Sirens hear every ping",
	"ping_arc": "PING ARC\n%s",	# two lines: one long line ran past the wheel's rim
	"ping_power": "PING POWER\n%s",
	"arc_all": "ALL",	# "ALL ROUND" wrapped to a third line and ran past the wheel's rim
	"arc_forward": "AHEAD",
	"history": "PAST PINGS",
	"history_heading": "PAST PINGS · %s",
	"paused_notice": "PAUSED: a Siren has noticed you",
	"paused_lock": "PAUSED: a Siren is locking on",
	"paused_route": "PAUSED: choose what to do with the route",
	"held_menu": "HELD: time runs again when you close this menu",
	"held_route": "HELD: time runs again once you answer the route prompt",
	"paused_route_end": "PAUSED: %s finished its route",
	"paused_blocked": "PAUSED: rock blocks %s's route",
	"route_end": "%s has stopped: its route is finished.",
	# A craft with a route that is not getting anywhere (presentation/no_progress.gd). The first line of each pair is the
	# pause reason on the status line; the second is the status message set when the dive pauses.
	"paused_stuck": "PAUSED: %s is not getting anywhere on its route",
	"stuck": "%s · no progress · replot",
	"paused_stuck_current": "PAUSED: the current holds %s back",
	"stuck_current": "%s · no progress · the current is stronger than its drive · replot or wait",
	"paused_stuck_band": "PAUSED: %s cannot pass here at this depth · %s is open",
	"stuck_band": "%s · no progress · %s is open here · replot or change depth",
	"paused_blocked_band": "PAUSED: rock blocks %s's route at this depth · %s is open",
	"blocked_band": "%s · rock blocks this leg at this depth · %s is open · replot or change depth",
	"paused_stuck_rock": "PAUSED: rock blocks %s's route",
	"stuck_rock": "%s · no progress · rock blocks this leg · replot",
	# The status line once a message has gone stale (presentation/strip_message.gd).
	"under_way": "%s · under way to point %d · %dm",
	"at_rest": "%s · at rest · no route set",
	# The move buttons on the lock card: what each move does about this lock (presentation/lock_move_timing.gd).
	"move_now": "works at once",
	"move_after": "works in %.1fs",
	"move_close": "Siren inside %dm",
	"move_decoy": "cannot break a lock",
}
# The status line for the route dialog's switch ("New points: the craft stops at each one." / "... keeps
# moving through them.") is set where the simulation answers the waypoint_mode order, orders/route_orders.gd.
# tactical_aids.gd words its own automatic pause "AUTO PAUSE: <reason>" in the status message.
const AUTO_PAUSE_PREFIX="AUTO PAUSE: "
const AUTO_PAUSE_REASONS={"FIRST NOTICE": "paused_notice", "LOCK WARNING": "paused_lock"}
# The reason keys of presentation/auto_pause.gd, and the line each one shows. A %s takes the craft's name.
const AUTO_PAUSE_KEYS={"notice": "paused_notice", "lock": "paused_lock", "route_end": "paused_route_end", "blocked": "paused_blocked", "blocked_band": "paused_blocked_band", "stuck": "paused_stuck", "stuck_current": "paused_stuck_current", "stuck_band": "paused_stuck_band", "stuck_rock": "paused_stuck_rock"}
# A route message ends with one of these (route_orders.gd): a craft that has since stopped no longer "set route".
const ROUTE_MESSAGE_ENDINGS=["set route", "replaced route", "queued route"]
# Seconds of dive time a status message counts as new. Older, a craft that is under way says what it is doing now.
const MESSAGE_FRESH_SECONDS=4.0
# Seconds of dive time the "route finished" line stays on the status line.
const ROUTE_END_SECONDS=8.0
# A craft counts as moving above this speed (m/s) when its route runs out.
const MOVING_SPEED=2.0

static func sights()->Dictionary:
	return {"silent": Pricing.SIREN_SIGHT_SILENT, "open": Pricing.SIREN_SIGHT}
# Quietus silent and cruise speed for the fitted hull and drive, as the simulation computes them.
static func speeds(sim)->Dictionary:
	var fitted:Dictionary=sim.mission.get("launch_equipment",{})
	return {"silent": CraftUpgrades.frame_speed(fitted,0,RuleTable.CRAFT_SPEED.silent), "cruise": CraftUpgrades.cruise_speed(fitted)}

# The pause plate: state first, then what a tap does, then the oxygen reading when it fits.
# paused: the player or an automatic pause stopped the dive (it stays stopped until resumed). held: an open menu
# or the route prompt holds time, which runs again when it closes; the plate says so, not PAUSED.
static func plate_state(paused:bool,held:bool=false)->String:
	return TEXT.paused if paused else TEXT.held if held else TEXT.running
static func plate_action(sim,dialog_open:bool,menu_open:bool=false)->String:
	if dialog_open and not sim.paused:return TEXT.route_prompt
	if menu_open and not sim.paused:return TEXT.close_to_resume
	return TEXT.tap_resume if sim.paused else TEXT.tap_pause

# The segments whose tap costs something that cannot be read before it lands: the first tap arms the segment and
# shows its cost in the wheel's centre, the second tap on the same segment performs it. Keys are the segments'
# "action" meta. Segments that only open a page, or are harmless, stay one tap.
const TWO_TAP=["silent","all_stop"]
static func needs_confirm(key:String,sim)->bool:
	if key=="all_stop":
		var u:Dictionary=sim.units[0]
		return not AllStop.stopped(u) and not AllStop.restarting(u)
	return key in TWO_TAP

# A toggle segment: the name says what the tap does, a small second line says how things stand now.
static func silent_label(sim)->String:
	if sim.selected>0:
		return TEXT.profile_low if not sim.units[sim.selected].silent else TEXT.profile_open
	return TEXT.silent_on if sim.units[0].silent else TEXT.silent_off
static func silent_state(sim)->String:
	if sim.selected>0:
		return TEXT.profile_state_low if sim.units[sim.selected].silent else TEXT.profile_state_open
	return TEXT.silent_state_on if sim.units[0].silent else TEXT.silent_state_off
# The small second line of a segment, by its action key. Empty for a segment that has none.
static func state_line(key:String,sim)->String:
	return silent_state(sim) if key=="silent" else ""
# The cost lines shown in the wheel's centre for a segment, by its action key: while a finger is on it, and once
# a two-tap segment is armed. Empty for a segment without a cost to show.
static func cost_lines(key:String,sim)->Array:
	if key=="silent":return silent_caption(sim)
	if key=="all_stop" and needs_confirm(key,sim):
		return [TEXT.all_stop,AllStop.label(sim).get_slice("\n",1)]
	return []
static func silent_caption(sim)->Array:
	var sight:=sights()
	if sim.selected>0:
		if sim.units[sim.selected].silent:return (TEXT.profile_open_line%[TEXT.profile_open,roundi(sight.open),roundi(sight.silent)]).split("\n")
		return (TEXT.profile_low_line%[TEXT.profile_low,roundi(sight.silent),roundi(sight.open)]).split("\n")
	var speed:=speeds(sim)
	if sim.units[0].silent:return (TEXT.silent_on_line%[TEXT.silent_on,roundi(speed.cruise),roundi(sight.open)]).split("\n")
	return (TEXT.silent_off_line%[TEXT.silent_off,roundi(speed.silent),roundi(sight.silent)]).split("\n")

# The question in the wheel's centre on the target chooser.
static func choose_prompt(choices:Array)->String:
	return TEXT.choose_craft if not choices.is_empty() and choices.all(func(c):return c.get("kind","")=="craft") else TEXT.choose_any

# Sonar page segments.
static func ping_label(cost:float)->String:
	return TEXT.ping%String.num(snappedf(cost,0.01)) if cost>0.0 else TEXT.ping_free
static func arc_label(sector:String)->String:
	return TEXT.ping_arc%(TEXT.arc_all if sector=="all" else TEXT.arc_forward)
static func power_label(power:String)->String:
	return TEXT.ping_power%power.to_upper()

# The status panel's row for a route point, in plain words: "Point 1: same speed, stops here". A drone names its
# drive, Quietus its speed; the key is the route program's mode ("inherit", "silent", "cruise").
const POINT_ROW="Point %d: %s, %s"
const POINT_MODES={"inherit": "same speed", "silent": "silent running", "cruise": "cruise speed"}
const POINT_MODES_DRONE={"inherit": "same drive", "silent": "quiet drive", "cruise": "transit drive"}
const POINT_STOPS={true: "stops here", false: "passes through"}
static func point_row(number:int,goal:Dictionary,drone:bool)->String:
	var modes:Dictionary=POINT_MODES_DRONE if drone else POINT_MODES
	return POINT_ROW%[number,modes.get(str(goal.get("mode","inherit")),"same speed"),POINT_STOPS[bool(goal.get("stop",true))]]

# extra is the second name some lines carry (the depth that is open).
static func auto_pause_text(key:String,craft:String,extra:String="")->String:
	var line:String=TEXT[AUTO_PAUSE_KEYS[key]]
	if line.count("%s")>=2:return line%[craft,extra]
	return line%craft if "%s" in line else line
# The status message a stall sets when it pauses the dive; "" for a rock hold, whose message the hold already set.
static func stall_message(key:String,craft:String,extra:String="")->String:
	if not TEXT.has(key):return ""
	var line:String=TEXT[key]
	return line%[craft,extra] if line.count("%s")>=2 else line%craft
static func is_route_message(message:String)->bool:
	return ROUTE_MESSAGE_ENDINGS.any(func(ending):return message.ends_with(ending))
# Why the dive is held, when something other than the player held it. Empty when the player paused,
# or when the held state already shows a card that states its reason.
static func pause_reason(host)->String:
	var sim=host.sim
	if host._order_dialog_open():return TEXT.paused_route if sim.paused else TEXT.held_route
	if not sim.paused:return TEXT.held_menu if host._time_held() else ""
	var automatic:String=host.tactical_aids.auto_pause.line(sim)
	if not automatic.is_empty():return automatic
	for key in AUTO_PAUSE_REASONS:
		if sim.message==AUTO_PAUSE_PREFIX+key:return TEXT[AUTO_PAUSE_REASONS[key]]
	return ""
