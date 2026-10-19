extends SceneTree
const Base=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",label)
func make(mode="cycle"):
	var path="res://proto/simulation.gd"
	var s=load(path).new() if FileAccess.file_exists(path) else Base.new()
	if s.has_method("set_variant"):s.set_variant(mode)
	s.start(2)
	# Acquisition-rule fixture only; ordinary threat policies are separate evidence.
	for enemy in s.sirens:enemy.stun=100.0
	return s
func place(s,site:int,distance:float=130):
	s.units[0].pos=s.mission.objectives[site].pos+Vector2(0,distance if site==0 else -distance);s.units[0].vel=Vector2.ZERO
func tick(s,seconds:float):
	for n in int(round(seconds*60)):s.advance(1.0/60)
func intel(s,site:int) -> Dictionary:
	return s.exchange_context(site) if s.has_method("exchange_context") else {}
func _initialize():
	var s=make();place(s,0);s.paused=false
	check(s.command("camera"),"close craft can arm a request sample during the locally open carrier")
	check(not s.noises.any(func(n):return n.label=="CAMERA"),"quiet hydrophone sample adds no optical camera pulse")
	tick(s,2.05)
	check(s.mission.objectives[0].captured,"two settled seconds earn a distinct request sample")
	check(intel(s,1).get("prediction",false),"request sample earns a predicted reply rhythm that changes the next-site plan")
	s=make();place(s,0,210)
	check(not s.command("camera"),"Quietus standoff outside actual156m passive reach requires local reacquisition")
	check(s.command("ping") and s.command("camera"),"existing accepted sonar solicits a locally reachable standoff replay")
	s.paused=false;tick(s,2.05)
	check(s.mission.objectives[0].captured,"two settled replay seconds acquire from audible240m standoff")
	s=make();place(s,0);s.elapsed=4.1;s.command("camera");s.paused=false;tick(s,4.1)
	check(not s.mission.objectives[0].captured,"closed carrier cannot quietly earn information by generic optical exposure")
	tick(s,4.0);check(s.mission.objectives[0].captured,"quiet acquisition after a closed gap completes within10active seconds")
	s=make("direct");place(s,0);s.elapsed=4.1;s.command("camera");s.paused=false;tick(s,2.05)
	check(s.mission.objectives[0].captured,"simpler direct comparator has no mandatory cycle wait")
	var direct_info=intel(s,1)
	check(direct_info.get("prediction",false) and direct_info.get("until_open",-1)==0 and direct_info.get("continuous",false),"direct comparator truthfully predicts a continuously available carrier")
	s=make();place(s,1);s.elapsed=5.0;s.command("camera");s.paused=false;tick(s,2.05)
	check(s.mission.objectives[1].captured and intel(s,0).get("prediction",false),"reverse-order reply sampling remains valid and calibrates the request")
	s=make();place(s,0);s.command("camera");s.paused=false;tick(s,1.0);s.paused=true
	var before=s.snapshot();s.advance(20)
	check(s.snapshot()==before,"pause freezes partial reception, carrier clock, resources and observations")
	var restored=make();restored.restore(bytes_to_var(var_to_bytes(before)));restored.paused=false;tick(restored,1.05)
	check(restored.mission.objectives[0].captured,"partial quiet reception survives serialization and paused restore")
	s=make();place(s,0,210);s.command("ping");s.paused=false;tick(s,1.0)
	check(not s.command("ping"),"solicitation cannot bypass the existing sonar cooldown")
	s=make();place(s,0);s.units[1].alive=false;s.units[2].alive=false;s.command("camera");s.paused=false;tick(s,2.05)
	check(s.mission.objectives[0].captured,"slower Quietus remains a sample fallback after both drones are lost")
	var legacy=Base.new();legacy.start(2);var old=legacy.snapshot();s=make();s.restore(old)
	check(s.mission==old.mission,"legacy two-photo mission data is not silently converted into an exchange")

	var Model=load("res://proto/exchange_model.gd")
	var m=Model.new();var sense={"alive":true,"clear":true,"local":false,"standoff":true,"settled":true}
	m.solicit(0,0,true);check(m.arm(0,0,0,sense),"reachable replay permits standoff sample")
	check(not m.eligible(0,3.0,sense),"three-second replay expires without silently extending itself")
	sense.clear=false;check(not m.arm(0,0,0,sense),"cover blocks relay reception even during a replay")
	sense.clear=true;sense.alive=false;check(not m.arm(0,0,0,sense),"lost craft cannot receive a relay sample")
	var worst=0.0;var complete_all=true
	for phase in 100:
		m=Model.new();sense={"alive":true,"clear":true,"local":true,"standoff":true,"settled":true}
		var time=phase*0.1;m.arm(0,0,time,sense);var done=-1;var duration=0.0
		for n in 601:
			duration+=1.0/60;done=m.step(1.0/60,time+duration,sense)
			if done>=0:break
		complete_all=complete_all and done==0;worst=maxf(worst,duration)
	check(complete_all and worst<=10.01,"every tenth-second arrival phase completes within ten active settled seconds")
	print("WORST QUIET WAIT ",worst," sec over100 arrival phases; no travel/threat guarantee")
	print("EXCHANGE RULE CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
