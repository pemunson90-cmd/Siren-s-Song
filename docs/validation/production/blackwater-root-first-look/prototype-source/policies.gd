extends SceneTree
const Base=preload("res://src/simulation/simulation.gd")
const Candidate=preload("res://proto/simulation.gd")
var results=[]
func _initialize():call_deferred("run")
func protect(s,unit:int,log:Dictionary):
	if not log.protect or s.elapsed-log.last_emp<1:return
	for c in s.contacts.values():
		if s.elapsed-c.time<0.3 and c.lock>1 and c.target==unit and s.tools.emp>0:
			s.command("emp");log.last_emp=s.elapsed;return
func step(s,unit:int,log:Dictionary):
	s.advance(0.1);protect(s,unit,log)
	for c in s.contacts.values():
		if s.elapsed-c.time<0.3:log.max_observed_lock=maxf(log.max_observed_lock,c.lock)
func travel(s,unit:int,point:Vector2,log:Dictionary) -> bool:
	s.command("select",{"unit":unit})
	if not s.command("route",{"point":point}):return false
	s.paused=false
	for n in 1500:
		step(s,unit,log)
		if not s.units[unit].alive or not s.outcome.is_empty():return s.outcome=="won"
		if s.units[unit].route.is_empty() and s.units[unit].vel.length()<2:return s.units[unit].pos.distance_to(point)<25
	return false
func play(variant:String,policy:String) -> Dictionary:
	var s=Base.new() if variant=="baseline" else Candidate.new()
	if variant!="baseline":s.set_variant(variant)
	s.start(2,"endurance")
	var unit=0 if "solo" in policy else 1
	var active="active" in policy
	var log={"protect":not "impatient" in policy,"last_emp":-100.0,"max_observed_lock":0.0}
	if unit==0:s.units[1].alive=false;s.units[2].alive=false
	var acquisitions=[];var inputs=[]
	for id in ([1,0] if "reverse" in policy else [0,1]):
		var distance=(230.0 if unit==1 else 210.0) if active else (140.0 if unit==0 else 190.0)
		var point=s.mission.objectives[id].pos+Vector2(0,distance if id==0 else -distance)
		var routed=travel(s,unit,point,log)
		inputs.append({"site":id,"routed":routed,"arrival":s.elapsed,"own_pos":str(s.units[unit].pos),"camera_context":s.camera_context()})
		if not routed or not s.units[unit].alive:break
		var use_ping=active
		if policy=="adaptive_drone" and variant!="baseline":
			var info=s.exchange_context(id);use_ping=info.get("prediction",false) and not info.get("open",false) and info.get("until_open",0)>2
		if use_ping:inputs.append({"ping":s.command("ping"),"time":s.elapsed})
		var accepted=s.command("camera");var start=s.elapsed
		if not accepted:break
		for n in 125:
			step(s,unit,log)
			if s.mission.objectives[id].captured or not s.units[unit].alive or not s.outcome.is_empty():break
		acquisitions.append({"site":id,"accepted":accepted,"start":start,"duration":snappedf(s.elapsed-start,0.01),"captured":s.mission.objectives[id].captured,"alive":s.units[unit].alive})
		if not s.mission.objectives[id].captured:break
	var records_time=s.elapsed if s.all_records() else -1.0
	# Experimental acquisition is applied after the base world tick. Let the
	# unchanged extraction rule observe it on the next ordinary tick.
	if s.all_records() and s.outcome.is_empty():step(s,unit,log)
	if unit==0 and s.all_records() and s.outcome.is_empty():travel(s,0,s.mission.extraction,log)
	return {"variant":variant,"policy":policy,"time":snappedf(s.elapsed,0.1),"time_to_records":snappedf(records_time,0.1),"time_to_win":snappedf(s.elapsed,0.1) if s.outcome=="won" else -1.0,"records":s.mission.objectives.map(func(o):return o.captured),"outcome":s.outcome,"hull":snappedf(s.hull,0.1),"drones":s.units.slice(1).map(func(u):return u.alive),"tools":s.tools,"accepted_pings":s.events.filter(func(e):return e.type=="ping").size(),"max_observed_lock":snappedf(log.max_observed_lock,0.01),"acquisitions":acquisitions,"inputs":inputs,"message":s.message}
func run():
	for variant in ["baseline","cycle","direct"]:
		for policy in ["quiet_drone","active_drone","impatient_drone","reverse_quiet_drone","quiet_solo","active_solo","adaptive_drone"]:
			var result=play(variant,policy);results.append(result);print("POLICY ",JSON.stringify(result))
	var out="res://../policies.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--results="):out=arg.trim_prefix("--results=")
	var file=FileAccess.open(out,FileAccess.WRITE);file.store_string(JSON.stringify(results,"  "));file.close()
	print("EXCHANGE POLICIES ",results.size());quit()
