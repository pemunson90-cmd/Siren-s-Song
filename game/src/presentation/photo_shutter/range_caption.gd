extends RefCounted
# WP-10 [AI-DESIGNED] RANGE CAPTION: the ring's camera caption names the camera reach
# the simulation's refusals use (Photo.reach), labelled, beside the distance to the
# public position of the site. An unresolved lead shows only the search area, never
# the distance to its hidden true position.
# Seam: mission_hud.gd camera_caption(), third line.
# REVERT: set `enabled` to false; the caption returns to "READY · 304m" exactly.
const Photo=preload("res://src/simulation/photo_capture.gd")
static var enabled:=true
const TEXT:={"ready":"READY · ","not_ready":"NOT READY · ","site":"%dm\nREACH %dm","lead":"SEARCH AREA\nREACH %dm","old":"%dm","far":"m away / "}

# WP-69: why the camera is not ready, in the simulation's own words (the first missing condition its context
# reports). Empty when ready, or when the only reason is distance, which the caption's own figures already show.
# A site still charted as a lead is already said by line(): SEARCH AREA and the reach. The simulation's sentence
# would only repeat the site's name and the reach, so it adds nothing here.
static func why(context:Dictionary,site:Dictionary={})->String:
	if not enabled or context.get("ready",false):return ""
	if not site.is_empty() and Photo.applies(site) and Photo.stage(site)=="lead":return ""
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
	# Each fact on its own line (the caller splits at the newline): the state, what to do, the reach.
	if Photo.applies(o) and Photo.stage(o)=="lead":return head.trim_suffix(" · ")+"\n"+TEXT.lead%reach
	return head+TEXT.site%[roundi(u.pos.distance_to(Photo.masked(o).pos)),reach]
