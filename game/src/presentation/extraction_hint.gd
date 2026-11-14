extends RefCounted
# WP-103: Quietus is inside a recovery area but cannot be recovered there (critic 14 Nov: it sat at the marker in DEEP and
# nothing said recovery needs MIDDLE). The rule is simulation.gd _try_extract / departure_context: Quietus alive, within
# REACH_METRES of an available recovery mouth, slower than EXTRACT_SPEED, in the MIDDLE band and not changing depth.
# This says which of the last two is missing. It changes no rule.
const Words=preload("res://src/presentation/hud_words.gd")
# The two figures simulation.gd uses (65 m reach, 12 m/s) and the band it names (Depth.NAMES[1]).
const REACH_METRES=65.0
const EXTRACT_SPEED=12.0
const MIDDLE=1
static func line(sim)->String:
	if not sim.outcome.is_empty() or not sim.units[0].alive:return ""
	var q:Dictionary=sim.units[0]
	var near:=false
	for corridor in sim.extraction_corridors():
		if corridor.get("available",false) and q.pos.distance_to(corridor.pos)<REACH_METRES:near=true;break
	if not near:return ""
	var name:String=str(q.name).to_upper()
	if q.band!=MIDDLE or not q.transition.is_empty():return Words.TEXT.extract_depth%[name,sim.Depth.NAMES[MIDDLE]]
	if q.vel.length()>=EXTRACT_SPEED:return Words.TEXT.extract_slow%[name,roundi(EXTRACT_SPEED)]
	return ""
