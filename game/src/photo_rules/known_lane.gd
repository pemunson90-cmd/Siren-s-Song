extends RefCounted
# PHOTO RULES / KNOWN LANE. Unlock: a `route` finding (the lee channel on the
# Corran Bank, the load lane at the Cold Foundry). The player photographed that
# water, so a strip LANE_STRIP wide along it counts as charted clear: courses
# planned along the lane are no longer held to the unknown-terrain speed cap.
#
# It adds nothing the camera did not show: only cells of open water with the usual
# hull clearance count, a rock in the strip stays a rock, and only band 1 is touched.
# Where the operation earns its terrain (a terrain chart exists) the cells are
# certified on that chart (terrain_chart.certify), so planned courses are not held
# to the unknown-terrain speed cap. On the authored opening operations the cells
# join sim.known, which lifts the fog on the chart and in the route planner.
# Idempotent; both stores are part of the saved game already, so removing the
# module leaves old saves valid. Called from Photo.finish after a usable frame
# files its findings.
const Table = preload("res://src/photo_rules/rule_table.gd")

static func chart_of(sim):
	return sim.depth_charts.get(1) if not sim.depth_charts.is_empty() else sim.terrain_chart
# Certifies the lane cells of every route finding; returns how many cells it added.
static func apply(sim) -> int:
	if not Table.ENABLED:
		return 0
	var chart = chart_of(sim)
	var tile: float = 40.0
	var added := 0
	for f in sim.mission.get("photo", {}).get("findings", []):
		if f.kind != "route" or not f.get("pts") is Array or f.pts.size() < 2:
			continue
		for k in f.pts.size() - 1:
			var a := Vector2(float(f.pts[k][0]), float(f.pts[k][1]))
			var b := Vector2(float(f.pts[k + 1][0]), float(f.pts[k + 1][1]))
			var steps: int = maxi(1, ceili(a.distance_to(b) / Table.LANE_STEP))
			for n in steps + 1:
				var p: Vector2 = a.lerp(b, float(n) / steps)
				var base := Vector2i((p / tile).floor())
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var cell := base + Vector2i(dx, dy)
						var rect := Rect2(Vector2(cell) * tile, Vector2.ONE * tile)
						if p.clamp(rect.position, rect.end).distance_to(p) <= Table.LANE_STRIP * 0.5 and _certify(sim, chart, cell):
							added += 1
	if added > 0 and chart != null:
		sim.known = chart.clear_cells.duplicate()
		sim.mission["terrain_chart"] = chart.snapshot()
	return added
static func _certify(sim, chart, cell: Vector2i) -> bool:
	if chart != null:
		return chart.certify(cell)
	var size: Vector2 = sim.world_size()
	if cell.x < 0 or cell.y < 0 or cell.x >= int(size.x / 40.0) or cell.y >= int(size.y / 40.0) or sim.known.has(cell):
		return false
	var center := Vector2(cell) * 40.0 + Vector2(20, 20)
	if not sim.Depth.clear(sim, center, center, 1, 20.0):
		return false
	sim.known[cell] = true
	return true
