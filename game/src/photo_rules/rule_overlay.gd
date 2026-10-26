extends RefCounted
# PHOTO RULES drawing: loop clocks, post return clocks and window checks on the
# chart. Draws only what the clock functions read; nothing here changes the
# simulation, and nothing is drawn for a Siren the player has not studied.
const Table = preload("res://src/photo_rules/rule_table.gd")
const LoopClock = preload("res://src/photo_rules/loop_clock.gd")
const PostClock = preload("res://src/photo_rules/post_clock.gd")
const WindowCheck = preload("res://src/photo_rules/window_check.gd")
const LOOP := Color(0.95, 0.6, 0.35)
const POST := Color(0.95, 0.4, 0.35)
const STALE := Color(0.62, 0.68, 0.68)
const GO := Color(0.5, 0.95, 0.6)
const WAIT := Color(0.95, 0.8, 0.4)
const LATE := Color(0.95, 0.5, 0.4)

# Called inside the chart's world transform. `ci` is the ocean view.
static func draw_chart(ci, sim) -> void:
	if not Table.ENABLED or sim.mission.get("photo", {}).get("findings", []).is_empty():
		return
	var scale: float = ci.world_scale
	for e in LoopClock.entries(sim):
		var live: bool = str(e.state) != "stale"
		var color: Color = LOOP if live else STALE
		var anchor: Vector2 = e.at
		if not live:
			anchor = Vector2.ZERO
			for p in e.pts:
				anchor += p
			anchor /= e.pts.size()
		else:
			ci.draw_arc(anchor, 9.0 / scale, 0, TAU, 20, Color(color, 0.95), 2.0 / scale)
			ci.draw_circle(anchor, 3.0 / scale, color)
		ci._label(anchor + Vector2(12, 18), LoopClock.text(e), color, 14)
	for e in PostClock.entries(sim):
		ci._label(e.post + Vector2(14, 26), PostClock.text(e), POST, 14)
	for e in WindowCheck.entries(sim):
		var color: Color = GO if str(e.state) == "go" else (WAIT if str(e.state) == "wait" else LATE)
		ci._label(e.pos + Vector2(-60, 56), str(e.text), color, 14)
