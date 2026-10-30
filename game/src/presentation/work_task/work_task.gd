extends RefCounted
# 119 (audit 091 F3/F5/F13) AI-DESIGNED presentation of the player's chosen work.
# Reads only public projections (observable sites, own craft, the selected
# craft's camera context, own capture clocks, observed industrial load).
# It never issues, reorders or retargets an order and changes no rule.
const Rules=preload("res://src/campaign/encounters/choir_rules.gd")
const NAMES=["QUIETUS","DRONE A","DRONE B"]
const LETTERS=["Q","A","B"]

# Plain public sites only; projected stations keep their own controls.
static func pinnable(subject:Dictionary)->bool:
	return subject.get("kind","")=="objective" and int(subject.get("index",-1))>=0 and subject.get("subkind","") in ["","actuator"]

static func pin(sim,subject:Dictionary)->Dictionary:
	if not pinnable(subject):return {}
	return {"index":int(subject.index),"owner":sim.selected}

static func site(sim,task:Dictionary)->Dictionary:
	if task.is_empty():return {}
	var sites=sim.observable_sites()
	var index=int(task.get("index",-1))
	return sites[index] if index>=0 and index<sites.size() else {}

static func bands_of(o:Dictionary)->Array:
	var bands=o.get("subject",{}).get("bands",[]) if o.get("subject") is Dictionary else []
	return bands if not bands.is_empty() else [int(o.get("band",1))]

static func label(sim,o:Dictionary)->String:
	return sim.Photo.label(o).to_upper() if not o.is_empty() else ""

static func live(sim,task:Dictionary)->bool:
	var o=site(sim,task)
	return not o.is_empty() and not o.get("captured",false)

# The selected craft's CAMERA would start a different optional job while the
# craft owns an unfinished chosen task: report why it is held, else "".
static func held_reason(sim,task:Dictionary)->String:
	if not live(sim,task) or sim.selected!=int(task.owner):return ""
	var context=sim.camera_context();var target=int(context.get("target",-1))
	if target<0 or target==int(task.index) or target>=sim.mission.objectives.size():return ""
	var other=sim.observable_sites()[target]
	if not other.get("optional",false):return ""
	return "CAMERA HELD · %s is the chosen task · open %s to work it instead"%[label(sim,site(sim,task)),label(sim,other)]

# CAMERA inside an object's own projection works only that object.
static func object_reason(sim,index:int)->String:
	var context=sim.camera_context();var target=int(context.get("target",-1))
	if target==index:return "" if context.get("ready",false) else str(context.get("text",""))
	var sites=sim.observable_sites()
	if index<0 or index>=sites.size():return "No site"
	var o=sites[index];var u=sim.units[sim.selected]
	if o.get("captured",false) and not o.get("repeatable",false):return "%s already complete"%label(sim,o)
	var bands=bands_of(o)
	if u.band not in bands:return "%s needs %s · %s is %s"%[label(sim,o),sim.Depth.NAMES[bands[0]],NAMES[sim.selected],sim.Depth.NAMES[u.band]]
	var reach=sim.Photo.reach(sim,sim.selected)
	var distance=u.pos.distance_to(o.pos)
	if distance>reach:return "%s · %dm / %dm reach"%[label(sim,o),roundi(distance),roundi(reach)]
	if target>=0 and target<sites.size():return "CAMERA aims at %s · turn or move toward %s"%[label(sim,sites[target]),label(sim,o)]
	return str(context.get("text","Not ready"))

static func state(sim,task:Dictionary)->String:
	var o=site(sim,task)
	if o.is_empty():return ""
	var owner=int(task.owner)
	var work=sim.capture_at_target(int(task.index))
	if work.unit>=0:return "WORKING %s %.1f / %ds"%[LETTERS[work.unit],work.elapsed,roundi(work.duration)]
	if o.get("captured",false):return "DONE"
	if not sim.units[owner].alive:return "OWNER LOST"
	if owner==sim.selected:
		var reason=object_reason(sim,int(task.index))
		return "READY" if reason.is_empty() else reason
	var u=sim.units[owner];var bands=bands_of(o)
	if u.band not in bands:return "NEEDS %s"%sim.Depth.NAMES[bands[0]]
	return "%dm / %dm reach"%[roundi(u.pos.distance_to(o.pos)),roundi(sim.Photo.reach(sim,owner))]

# One persistent status line: what, who, where it needs them, progress or refusal.
static func line(sim,task:Dictionary)->String:
	var o=site(sim,task)
	if o.is_empty():return ""
	var owner=int(task.owner);var u=sim.units[owner]
	return "TASK · %s · %s · %s · %dm · %s"%[label(sim,o),NAMES[owner],"/".join(bands_of(o).map(func(b):return sim.Depth.NAMES[b])),roundi(u.pos.distance_to(o.pos)),state(sim,task)]

static func result_line(result:Dictionary)->String:
	if result.is_empty():return ""
	return "LAST · %s · %s · %s"%[result.owner,"STARTED" if result.ok else "REFUSED",result.text]

# Short centre caption for an object's projection (two lines, <=22 chars).
static func captions(sim,subject:Dictionary)->Array:
	var lines=["BY "+NAMES[sim.selected]]
	if pinnable(subject):
		var reason=object_reason(sim,int(subject.index))
		var work=sim.capture_at_target(int(subject.index))
		lines.append(("WORKING %s"%LETTERS[work.unit]) if work.unit>=0 else "CAMERA READY" if reason.is_empty() else reason.substr(0,22))
	return lines

# Observed moving load: confirmed motion, escort hold, last fix or arrival.
static func load_status(sim)->String:
	if not sim.has_method("choir_context"):return ""
	var info=sim.choir_context()
	if info.is_empty() or info.load.is_empty():return ""
	var body=info.load;var name=str(body.name)
	if body.age>=1.:return "%s · LAST FIX %ds · %s · arrival not confirmed"%[name,int(body.age),str(body.state).to_upper()]
	if body.state=="arrived":return "%s · ARRIVED · CONFIRMED"%name
	if body.state!="transit":return "%s · %s"%[name,str(body.state).to_upper()]
	var mid=int(sim.mission.get("id",-1))
	if not Rules.ESCORT.has(mid):return "%s · TRANSIT · OBSERVED"%name
	var radius=float(Rules.ESCORT[mid]);var nearest=-1;var best=INF
	for id in sim.units.size():
		var unit=sim.units[id]
		if unit.alive and unit.pos.distance_to(body.pos)<best:best=unit.pos.distance_to(body.pos);nearest=id
	if nearest<0:return "%s · HELD · no living escort"%name
	if best<=radius:return "%s · MOVING · ESCORT %s %dm / %dm"%[name,LETTERS[nearest],roundi(best),roundi(radius)]
	return "%s · HELD · needs a craft within %dm · nearest %s %dm"%[name,roundi(radius),LETTERS[nearest],roundi(best)]

# Compact chart tag beside the load itself.
static func load_tag(sim)->String:
	var full=load_status(sim)
	if full.is_empty():return ""
	var name=str(sim.choir_context().load.name)
	return full.trim_prefix(name+" · ")
