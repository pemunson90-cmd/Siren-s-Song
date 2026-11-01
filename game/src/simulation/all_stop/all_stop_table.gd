extends RefCounted
# ALL STOP: every number and line of placeholder text the module uses.
#
# A true all-stop for Quietus: engines off, the hull coasts to rest, and there is no
# throttle noise at all while the engines are off. It is a deliberate beat, not a
# free button: shutting the engines down and starting them again each cost
# oxygen, the hull coasts a distance before it rests, a current carries it, and
# bringing the engines back takes RESTART_SECONDS at limited thrust.
# It touches one noise rule, Pat approved: the motion noise of an engines-off hull
# is zero. It does not change sight, hearing, combat, beams, collision or damage.
#
# NEUTRAL VALUES (the game as it played before this module): ENABLED=false. Then
# the ALL STOP order is refused and no button is offered; every other number here
# is unused.
const ENABLED := true

# Metres per second squared the hull slows while the engines are off. Ordinary
# braking is 42, so this is a long glide: from silent running (42 m/s) it is 3 s
# and about 63 m, from cruise (78 m/s) it is 5.6 s and about 217 m.
const COAST_DECEL := 14.0
# Oxygen (percent of the full tank) drawn when the engines are shut down and again
# when the restart is ordered. The tank is about 180 s on the opening operations at
# about 0.55 percent a second, so the pair is a few seconds of air.
const ENTRY_OXYGEN := 1.0
const RESTART_OXYGEN := 0.5
# Seconds the engines take to come back, during which thrust is held to RESTART_SPEED.
const RESTART_SECONDS := 6.0
const RESTART_SPEED := 20.0
# Multipliers on the hull's motion noise: engines off is silent; the restart is as
# loud as the speed it makes.
const OFF_NOISE := 0.0
const RESTART_NOISE := 1.0
# Orders that plot a new course. Issuing one with the engines off orders the restart.
const COURSE_ORDERS := ["route", "emergency", "order_undo", "route_edit", "route_insert", "route_delete", "route_undo"]

const TEXT := {
	"engage": "ALL STOP · engines off · coasting to rest · no throttle noise · %.1f%% oxygen · %ds restart",
	"restart": "Engines restarting · %ds to full thrust · %.1f%% oxygen",
	"refused_oxygen": "Not enough air to shut the engines down",
	"refused_craft": "Only Quietus can all stop",
	"refused_depth": "Settle at depth before shutting the engines down",
	"button": "ALL STOP",
	"button_cost": "ALL STOP\n%.1f%% O2 · %ds restart",
	"button_restart": "ENGINES\nRESTART",
	"button_spinup": "ENGINES\n%ds",
}
