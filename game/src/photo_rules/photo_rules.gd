extends RefCounted
# PHOTO RULES: what studying a subject teaches the player, as display and planning
# aids. Four rules, each a pure function of the player's own findings and last
# contacts (loop_clock.gd, post_clock.gd, window_check.gd) or a certification of
# water the player photographed (known_lane.gd), plus one authored optional subject
# (rule_data.gd). Nothing here changes combat, beams, collision, damage, hull, or
# what a Siren sees or hears; nothing reads a Siren's live position; nothing is
# saved except the lane cells, which ride in the chart's own state.
#
# SEAMS (remove this folder and these lines to revert; rule_table.gd ENABLED=false
# plays exactly as before):
#   photo_capture.gd     finish():           PhotoRules.on_findings(sim)      after findings are filed
#   simulation.gd        camera_context():   PhotoRules.camera_hint(...)      one line on the camera text
#   terrain_chart.gd     certify(cell):      the one public door the lane uses
#   ocean_view.gd        _draw():            RuleOverlay.draw_chart(...)      after the findings are drawn
#   operation_catalog.gd make():             RuleData.apply(m,id)             the optional deep subject
#   photo_ops.gd         EVIDENCE_KEYS/LABELS: "deep_seam"                    record key for that subject
# Save: no new field. Clocks are computed when drawn.
const Table = preload("res://src/photo_rules/rule_table.gd")
const KnownLane = preload("res://src/photo_rules/known_lane.gd")
const WindowCheck = preload("res://src/photo_rules/window_check.gd")

static func on_findings(sim) -> void:
	KnownLane.apply(sim)
# Appends the route-aware window line when the framed subject carries a published cycle.
static func camera_hint(sim, ctx: Dictionary) -> Dictionary:
	if not Table.ENABLED or not ctx.get("ready", false):
		return ctx
	var t: int = int(ctx.get("target", -1))
	if t < 0 or t >= sim.mission.objectives.size():
		return ctx
	var line: String = WindowCheck.camera_line(sim, sim.mission.objectives[t].pos)
	if not line.is_empty():
		ctx["text"] = str(ctx.get("text", "")) + " · " + line
	return ctx
