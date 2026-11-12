extends RefCounted
# WP-10 [AI-DESIGNED] RANGE CAPTION: the ring's camera caption names the camera reach
# the simulation's refusals use (Photo.reach), labelled, beside the distance to the
# public position of the site. An unresolved lead shows only the search area, never
# the distance to its hidden true position.
# Seam: mission_hud.gd camera_caption(), third line.
# REVERT: set `enabled` to false; the caption returns to "READY · 304m" exactly.
const Photo=preload("res://src/simulation/photo_capture.gd")
static var enabled:=true
const TEXT:={"ready":"READY · ","not_ready":"NOT READY · ","site":"%dm · REACH %dm","lead":"SEARCH AREA · REACH %dm","old":"%dm"}

static func line(sim,o:Dictionary,ready:bool)->String:
	var head:String=TEXT.ready if ready else TEXT.not_ready
	var u=sim.units[sim.selected]
	if not enabled:return head+TEXT.old%roundi(u.pos.distance_to(o.pos))
	var reach:int=roundi(Photo.reach(sim,sim.selected))
	if Photo.applies(o) and Photo.stage(o)=="lead":return head+TEXT.lead%reach
	return head+TEXT.site%[roundi(u.pos.distance_to(Photo.masked(o).pos)),reach]
