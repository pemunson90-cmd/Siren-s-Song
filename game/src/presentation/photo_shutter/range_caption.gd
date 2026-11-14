extends RefCounted
# WP-10 [AI-DESIGNED] RANGE CAPTION: the ring's camera caption names the camera reach
# the simulation's refusals use (Photo.reach), labelled, beside the distance to the
# public position of the site. An unresolved lead shows only the search area, never
# the distance to its hidden true position.
# Seam: mission_hud.gd camera_caption(), third line.
# REVERT: set `enabled` to false; the caption returns to "READY · 304m" exactly.
const Photo=preload("res://src/simulation/photo_capture.gd")
static var enabled:=true
const TEXT:={"ready":"READY · ","not_ready":"NOT READY · ","site":"%dm · REACH %dm","lead":"SEARCH AREA · REACH %dm","old":"%dm","far":"m away / "}

# WP-69: why the camera is not ready, in the simulation's own words (the first missing condition its context
# reports). Empty when ready, or when the only reason is distance, which the caption's own figures already show.
static func why(context:Dictionary)->String:
	if not enabled or context.get("ready",false):return ""
	var reason:String=str(context.get("text","")).strip_edges()
	if reason.contains(TEXT.far):
		# "<site> · 170m away / 240m range · view blocked by cover": only a trailing extra clause is a reason.
		var parts:PackedStringArray=reason.split(" · ")
		return parts[parts.size()-1] if parts.size()>2 else ""
	return reason

static func line(sim,o:Dictionary,ready:bool)->String:
	var head:String=TEXT.ready if ready else TEXT.not_ready
	var u=sim.units[sim.selected]
	if not enabled:return head+TEXT.old%roundi(u.pos.distance_to(o.pos))
	var reach:int=roundi(Photo.reach(sim,sim.selected))
	if Photo.applies(o) and Photo.stage(o)=="lead":return head+TEXT.lead%reach
	return head+TEXT.site%[roundi(u.pos.distance_to(Photo.masked(o).pos)),reach]
