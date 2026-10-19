extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;print("FAIL ",label)
	else:print("PASS ",label)
func fixture():
	var s=Sim.new();s.start(4,"disruption")
	# Explicit isolated rule fixture. Ordinary unmodified threat traces are separate.
	for enemy in s.sirens:enemy.stun=1000.0
	return s
func tick(s,seconds):
	s.paused=false
	for n in int(round(seconds*60)):
		if not s.outcome.is_empty():break
		s.advance(1.0/60)
func reference(s):
	s.mission.objectives[0].captured=true
	s.units[0].pos=Vector2(1190,450);s.units[0].vel=Vector2(65,0);s.units[0].silent=false
	s.units[1].pos=Vector2(140,700);s.units[2].pos=Vector2(280,800)
	tick(s,1.0/60)
func run():
	var s=fixture()
	check(s.mission.get("well_revision",0)==1 and s.mission.objectives.size()==3,"fresh Well preserves three required records and advertises optional signature revision")
	check("optional" in s.mission.brief.to_lower() and "cruise" in s.mission.brief.to_lower(),"brief explains optional moving pass rather than mandatory stationary decode")
	check("unverified" in s.mission.record.to_lower() and not "lone pilot" in s.mission.record.to_lower(),"unobserved fresh debrief does not claim engine or pilot recognition")
	check(s.mission.objectives[0].get("optical","")=="well_pattern","first actually captured record has a retained pattern/invitation")
	var guard=fixture();guard.units[0].pos=Vector2(1190,450);guard.units[0].vel=Vector2(65,0);tick(guard,1.0/60)
	check(guard.mission.well_reference.is_empty(),"moving past aperture before first record does not silently verify a comparison")
	guard=fixture();guard.mission.objectives[0].captured=true;guard.units[0].vel=Vector2(65,0);tick(guard,1.0/60)
	check(guard.mission.well_reference.is_empty(),"moving Quietus outside local aperture reach does not acquire a reference")
	guard=fixture();guard.mission.objectives[0].captured=true;guard.units[0].pos=Vector2(1190,310);guard.units[0].vel=Vector2(65,0);tick(guard,1.0/60)
	check(guard.mission.well_reference.is_empty(),"actual northern basalt occludes an in-range moving reference")
	reference(s)
	check(not s.mission.get("well_reference",{}).is_empty(),"real moving Quietus clear and within aperture range earns own reference")
	check(s.mission.get("well_observation",{}).is_empty(),"own reference alone does not grant a remote received-match claim")
	var snapshot=s.snapshot();s.paused=true;s.advance(5)
	check(s.snapshot()==snapshot.merged({"paused":true},true),"pause freezes pending reference and world state")
	var restored=Sim.new();check(restored.restore(s.snapshot()),"existing snapshot restores pending comparison paused")
	restored.units[2].pos=Vector2(780,850);tick(restored,1.0/60)
	check(not restored.mission.get("well_observation",{}).is_empty(),"live drone locally receives southern return using ordinary passive range and clear line")
	check("matches" in restored.mission.record.to_lower() and not "pilot" in restored.mission.record.to_lower(),"observed result states matching pattern without hidden biological-pilot inference")
	check(restored.has_method("well_signature_evidence"),"earned comparison supplies inspectable retained evidence")
	if restored.has_method("well_signature_evidence"):
		var entry=restored.well_signature_evidence();check(not entry.is_empty() and "DRONE B" in entry.caption and "reference" in entry.caption.to_lower(),"retained comparison names actual reference and receiving station")
	var fresh=fixture();fresh.mission.objectives[0].captured=true;fresh.units[1].pos=Vector2(1190,450);fresh.units[1].vel=Vector2(80,0);tick(fresh,1.0/60)
	check(fresh.mission.get("well_reference",{}).is_empty(),"drone motion cannot impersonate Quietus engine reference")
	fresh=fixture();fresh.mission.objectives[0].captured=true;fresh.units[0].pos=Vector2(1190,450);fresh.command("ping");tick(fresh,1.0/60)
	check(fresh.mission.get("well_reference",{}).is_empty(),"stationary sonar cannot impersonate moving engine reference")
	fresh=fixture();fresh.mission.objectives[0].captured=true;fresh.units[0].pos=Vector2(1190,450);fresh.units[0].vel=Vector2(50,0);tick(fresh,1.0/60)
	check(fresh.mission.get("well_reference",{}).is_empty(),"reference uses existing strict motion-noise threshold")
	fresh=fixture();reference(fresh);fresh.units[2].pos=Vector2(780,850);fresh.units[2].alive=false;tick(fresh,1.0/60)
	check(fresh.mission.get("well_observation",{}).is_empty(),"dead observer cannot receive signature evidence")
	fresh=fixture();reference(fresh);fresh.units[0].pos=Vector2(780,850);fresh.units[0].vel=Vector2.ZERO;fresh.units[1].alive=false;fresh.units[2].alive=false;tick(fresh,1.0/60)
	check(not fresh.mission.get("well_observation",{}).is_empty(),"solo Quietus can receive after its moving pass with both drones lost")
	var legacy=fixture().snapshot();legacy.mission.erase("well_revision");legacy.mission.erase("well_reference");legacy.mission.erase("well_observation");legacy.mission.record="Legacy engine-note record";var old=Sim.new();old.restore(legacy)
	check(old.mission.record=="Legacy engine-note record" and not old.mission.has("well_revision"),"legacy active Well is not silently revised on restore")
	fresh.start(4);check(fresh.mission.get("well_reference",{}).is_empty() and fresh.mission.get("well_observation",{}).is_empty(),"retry starts a new comparison without prior-dive proof")
	var malformed=restored.snapshot();malformed.mission["well_reference"]={"time":"forever"}
	check(not Sim.valid_snapshot(malformed),"malformed reference state is rejected by existing snapshot boundary")
	print("WELL SIGNATURE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
