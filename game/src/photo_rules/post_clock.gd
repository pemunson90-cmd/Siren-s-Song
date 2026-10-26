extends RefCounted
# PHOTO RULES / POST RETURN CLOCK. Unlock: a frame of a sentinel's sensor array,
# which files a `post` finding with its post and tether (photo_findings.gd).
# While the player holds a recent sighting of that sentinel OUTSIDE its tether,
# the post shows "BACK ~9s": the straight-line distance from where it was last
# seen to its post, at the patrol pace (25 m/s) or the alerted pace (48 m/s).
#
# This is the honest "sentinel gap": sentinels hold posts and do not patrol, so a
# marked wander is the one window the player can read. It uses the last contact
# only (sim.contacts, dropped by the simulation after 20 s), never the live Siren,
# and shows nothing once the contact is gone. Pure function, never saved.
const Table = preload("res://src/photo_rules/rule_table.gd")

static func entries(sim) -> Array:
	var result: Array = []
	if not Table.ENABLED:
		return result
	for f in sim.mission.get("photo", {}).get("findings", []):
		if f.kind != "post" or not f.has("pos") or not f.has("r") or not str(f.id).begins_with("post_"):
			continue
		var i: int = int(str(f.id).trim_prefix("post_"))
		if i < 0 or i >= sim.sirens.size():
			continue
		var c = sim.contacts.get(i)
		if not (c is Dictionary) or str(c.get("source", "")) != "optical":
			continue
		var age: float = sim.elapsed - float(c.time)
		var post := Vector2(float(f.pos[0]), float(f.pos[1]))
		var away: float = c.pos.distance_to(post)
		if age > Table.STALE_AFTER or away <= float(f.r):
			continue
		var speed: float = Table.ALERT_SPEED if str(c.get("mode", "")) in Table.POST_ALERT_MODES else Table.PATROL_SPEED
		# A sentinel already walking home has covered part of the distance since it was seen.
		var left: float = away
		if str(c.get("mode", "")) == "RETURN":
			left = maxf(0.0, away - speed * age)
		var seconds: float = left / speed
		result.append({"i": i, "post": post, "back": seconds, "age": age, "state": "live" if age <= Table.AGING_AFTER else "aging"})
	return result
static func text(e: Dictionary) -> String:
	var key: String = "post_back" if str(e.state) == "live" else "post_back_old"
	return Table.TEXT[key] % [int(e.i) + 1, ceili(float(e.back))]
