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
const TEXT={
	"paused": "PAUSED",
	"running": "RUNNING",
	"tap_resume": "TAP TO RESUME",
	"tap_pause": "TAP TO PAUSE",
	"route_prompt": "ANSWER ROUTE PROMPT",
	"join": " · ",
	"silent_off": "GO SILENT",
	"silent_on": "SILENT IS ON",
	"silent_off_line": "%s\nslower (%d m/s) · seen from %d m",
	"silent_on_line": "%s\ntap for full speed (%d m/s) · seen from %d m",
	"profile_low": "LOW\nPROFILE",
	"profile_open": "OPEN\nPROFILE",
	"profile_low_line": "LOW PROFILE\nSirens see this drone from %d m, not %d m\nIts speed is unchanged",
	"profile_open_line": "OPEN PROFILE\nSirens see this drone from %d m\nTap: from %d m instead. Speed is unchanged",
	"ping": "PING SONAR\nuses %s reserve",
	"ping_free": "PING SONAR\nuses no reserve",
	"ping_caption": "Sirens hear every ping",
	"ping_arc": "PING ARC\n%s",	# two lines: one long line ran past the wheel's rim
	"ping_power": "PING POWER\n%s",
	"arc_all": "ALL ROUND",
	"arc_forward": "AHEAD",
	"history": "PAST PINGS",
	"history_heading": "PAST PINGS · %s",
	"paused_notice": "PAUSED: a Siren has noticed you",
	"paused_lock": "PAUSED: a Siren is locking on",
	"paused_route": "PAUSED: choose what to do with the route",
	"route_end": "%s has stopped: its route is finished.",
}
# The status line for the route dialog's switch ("New points: the craft stops at each one." / "... keeps
# moving through them.") is set where the simulation answers the waypoint_mode order, orders/route_orders.gd.
# tactical_aids.gd words its own automatic pause "AUTO PAUSE: <reason>" in the status message.
const AUTO_PAUSE_PREFIX="AUTO PAUSE: "
const AUTO_PAUSE_REASONS={"FIRST NOTICE": "paused_notice", "LOCK WARNING": "paused_lock"}
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
static func plate_state(held:bool)->String:
	return TEXT.paused if held else TEXT.running
static func plate_action(sim,dialog_open:bool)->String:
	if dialog_open and not sim.paused:return TEXT.route_prompt
	return TEXT.tap_resume if sim.paused else TEXT.tap_pause

# Quietus: the segment names the state; its caption says what the next tap does and what it costs.
static func silent_label(sim)->String:
	if sim.selected>0:
		return TEXT.profile_low if sim.units[sim.selected].silent else TEXT.profile_open
	return TEXT.silent_on if sim.units[0].silent else TEXT.silent_off
static func silent_caption(sim)->Array:
	var sight:=sights()
	if sim.selected>0:
		if sim.units[sim.selected].silent:return (TEXT.profile_low_line%[roundi(sight.silent),roundi(sight.open)]).split("\n")
		return (TEXT.profile_open_line%[roundi(sight.open),roundi(sight.silent)]).split("\n")
	var speed:=speeds(sim)
	if sim.units[0].silent:return (TEXT.silent_on_line%[TEXT.silent_on,roundi(speed.cruise),roundi(sight.open)]).split("\n")
	return (TEXT.silent_off_line%[TEXT.silent_off,roundi(speed.silent),roundi(sight.silent)]).split("\n")

# Sonar page segments.
static func ping_label(cost:float)->String:
	return TEXT.ping%String.num(snappedf(cost,0.01)) if cost>0.0 else TEXT.ping_free
static func arc_label(sector:String)->String:
	return TEXT.ping_arc%(TEXT.arc_all if sector=="all" else TEXT.arc_forward)
static func power_label(power:String)->String:
	return TEXT.ping_power%power.to_upper()

# Why the dive is held, when something other than the player held it. Empty when the player paused,
# or when the held state already shows a card that states its reason.
static func pause_reason(host)->String:
	var sim=host.sim
	if host._order_dialog_open():return TEXT.paused_route
	if not sim.paused:return ""
	for key in AUTO_PAUSE_REASONS:
		if sim.message==AUTO_PAUSE_PREFIX+key:return TEXT[AUTO_PAUSE_REASONS[key]]
	return ""
