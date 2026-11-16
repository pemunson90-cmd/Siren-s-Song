extends RefCounted
# WP-128 (critic rounds 9 and 10: players could not tell what to do next; getting home was the worst case). Read-only.
# One imperative sentence from state the dive already has, plus the chart point it names, so the strip's NEXT line and the
# GOAL / SEARCH chip always agree. It changes no rule: the recovery condition it states is simulation.gd _try_extract /
# departure_context (Quietus alive, within RECOVERY_REACH of an available recovery mouth, slower than EXTRACT_SPEED, in
# MIDDLE, not changing depth, with required cargo carriers inside the same reach). Words live in hud_words.gd.
const Words=preload("res://src/presentation/hud_words.gd")
const ModuleRecovery=preload("res://src/simulation/module_recovery.gd")
const Glass=preload("res://src/simulation/glass_reach_work.gd")
const RECOVERY_REACH=65.0 # simulation.gd: Quietus recovers within this many metres of the recovery mouth
const EXTRACT_SPEED=12.0 # simulation.gd _try_extract
const MIDDLE=1
# {"text": the NEXT line ("" when there is nothing to say), "site": the chart subject it names ({} when none; has "pos")}.
static func step(sim)->Dictionary:
	var none:Dictionary={"text":"","site":{}}
	if sim==null or not sim.outcome.is_empty() or not sim.units[0].alive:return none
	if sim.all_records():return _home(sim)
	var sites:Array=sim.observable_sites()
	var q:Dictionary=sim.units[0]
	var pick:int=-1;var best:=INF
	for i in mini(sites.size(),sim.mission.objectives.size()):
		var o:Dictionary=sim.mission.objectives[i]
		if o.captured or o.get("optional",false):continue
		var d:float=q.pos.distance_to(sites[i].pos)
		if d<best:best=d;pick=i
	if pick<0:return {"text":Words.TEXT.next_open_job,"site":_corridor(sim)}
	# A record behind an unfinished prerequisite: the prerequisite is the next step.
	for guard in 8:
		var open:int=-1
		for p in sim.mission.objectives[pick].get("requires",[]):
			if int(p)>=0 and int(p)<sites.size() and not sim.mission.objectives[int(p)].captured:open=int(p);break
		if open<0:break
		pick=open
	return {"text":_objective(sim,sites[pick]),"site":sites[pick]}
static func _objective(sim,site:Dictionary)->String:
	var name:String=sim.Photo.label(site).to_upper()
	if site.get("stage","")=="lead":
		return Words.TEXT.next_search_unknown if site.get("unknown",false) else Words.TEXT.next_search%name
	if sim.Operations.own_origin(site):return Words.TEXT.next_transmit%[name,roundi(EXTRACT_SPEED)]
	var listen:bool=site.get("kind","")=="receiver"
	var near:String="";var near_d:=INF;var reach:=0.0
	for id in sim.units.size():
		var u:Dictionary=sim.units[id]
		if not u.alive or sim.DroneBay.aboard(u):continue
		var r:float=sim.Photo.reach(sim,id)
		reach=maxf(reach,r)
		var d:float=u.pos.distance_to(site.pos)
		if d<r and d<near_d:near=str(u.name).to_upper();near_d=d
	if not near.is_empty():return (Words.TEXT.next_listen_reach if listen else Words.TEXT.next_photo_reach)%[name,near]
	return (Words.TEXT.next_listen_far if listen else Words.TEXT.next_photo_far)%[name,roundi(reach)]
# The available recovery mouth nearest Quietus ({} when none is open).
static func _corridor(sim)->Dictionary:
	var best:Dictionary={};var best_d:=INF
	for c in sim.extraction_corridors():
		var d:float=sim.units[0].pos.distance_to(c.pos)
		if d<best_d:best=c;best_d=d
	return best
static func _home(sim)->Dictionary:
	var c:Dictionary=_corridor(sim)
	if c.is_empty():return {"text":"","site":{}}
	var q:Dictionary=sim.units[0]
	var middle:String=sim.Depth.NAMES[MIDDLE]
	var ring:String=str(c.get("name","")).to_upper() if sim.mission.has("expedition_revision") else Words.TEXT.next_ring_name
	var line:String=""
	if q.pos.distance_to(c.pos)>=RECOVERY_REACH:line=Words.TEXT.next_ring%[ring,roundi(RECOVERY_REACH)]
	elif not c.get("available",true):line=sim.corridor_blocked_reason(c) # WP-172: at a mouth that is not open, say why
	elif not q.transition.is_empty():line=Words.TEXT.next_settle%middle
	elif q.band!=MIDDLE:line=(Words.TEXT.next_rise if q.band>MIDDLE else Words.TEXT.next_sink)%middle
	elif q.vel.length()>=EXTRACT_SPEED:line=Words.TEXT.next_slow%roundi(EXTRACT_SPEED)
	elif not Glass.can_extract(sim,c) or not sim.Choir.can_extract(sim,c):line=Words.TEXT.next_material%[ring,roundi(RECOVERY_REACH)]
	elif sim.mission.has("module_recovery"):
		for module in ModuleRecovery.departure(sim,c).left:
			if module.state=="salvage":line=Words.TEXT.next_salvage%[str(module.name).to_upper(),ring]
			elif module.unit>0:line=Words.TEXT.next_carrier%[str(sim.units[module.unit].name).to_upper(),ring,roundi(RECOVERY_REACH),str(module.name).to_lower()]
			if not line.is_empty():break
	return {"text":line,"site":c}
# Whether the standing hint stays in place of the NEXT line (a situational warning rather than advice).
static func keeps(standing:String)->bool:
	return Words.TEXT.next_keep.any(func(prefix):return standing.begins_with(prefix))
