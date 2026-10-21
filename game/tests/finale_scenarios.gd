extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
static func run(t) -> void:
	var s=Simulation.new(); s.start(5,"disruption")
	var receiver=s.mission.objectives[2]
	t.check(receiver.get("kind","")=="receiver" and receiver.get("required_unit",-1)==0,"final warning needs Quietus hydrophones at a sheltered receiver")
	t.check(receiver.get("requires",[])==[0,1] and receiver.get("duration",0)==6.0,"warning interpretation requires both distinct observations and an uninterrupted listening interval")
	t.check(s.mission.objectives[0].get("optical","")=="transmitter" and s.mission.objectives[1].get("optical","")=="departure","finale observations have distinct retained visual evidence")
	t.check(s.has_method("camera_context"),"selected station has honest camera range/readiness/prerequisite guidance")
	if receiver.get("kind","")!="receiver" or not s.has_method("camera_context"): return
	for siren in s.sirens: siren.stun=30.0
	# Acquisition semantics are isolated here; ordinary navigation/loss recovery has separate traces.
	s.units[0].pos=receiver.pos+Vector2(0,150)
	t.check(not s.command("camera") and "observations" in s.message,"decode explains its missing optical observations")
	s.mission.objectives[0].captured=true
	t.check(not s.command("camera"),"one observation cannot be mistaken for the final warning")
	s.mission.objectives[1].captured=true
	s.units[1].pos=s.units[0].pos; s.command("select",{"unit":1})
	t.check(not s.command("camera") and "hydrophones" in s.message,"small drone cannot replace the explained shipborne receiver")
	s.command("select",{"unit":0})
	var before=s.snapshot(); var context=s.camera_context()
	t.check(context.ready and "LEE RECEIVER" in context.text and before==s.snapshot(),"camera context names an eligible target without changing perception or simulation")
	t.check(s.command("camera") and not s.noises.any(func(n): return n.label=="CAMERA"),"passive hydrophone decode does not emit an optical camera pulse")
	s.advance(2.0); t.check(s.capture_time==0.0,"unlimited tactical pause freezes passive acquisition")
	s.paused=false
	for n in 30: s.advance(0.1)
	var restored=Simulation.new(); t.check(restored.restore(s.snapshot()) and restored.paused,"half-heard packet and evidence restore safely paused")
	restored.paused=false
	for n in 35: restored.advance(0.1)
	t.check(restored.mission.objectives[2].captured and restored.outcome.is_empty(),"resolved warning is earned but still needs Quietus returned to the buoy")
	t.check("fracture" in restored.mission.objectives[2].evidence and restored.mission.objectives[2].get("optical","")=="warning","final interpretation retains inspectable geological warning evidence")
	var data={"version":2,"unlocked":5,"completed":[0],"upgrade":"disruption","settings":{},"active":restored.snapshot(),"evidence":{"warning":{"name":"WARNING PACKET","caption":restored.mission.objectives[2].evidence,"optical":"warning"}}}
	var store=SaveStore.new(); store.path="user://test-finale.save"
	t.check(store.save(data) and store.load_game()==data,"new warning evidence and partially returned mission survive actual archive roundtrip")
	for suffix in ["",".tmp",".bak"]: DirAccess.remove_absolute(store.path+suffix)
	var early=Simulation.new(); early.start(0); early.command("select",{"unit":1}); early.units[1].pos=Vector2(1300,510)
	t.check(early.camera_context().ready and "READY" in early.camera_context().text,"a legitimate first-mission camera vantage explains readiness to the player")

	var legacy_store=SaveStore.new(); legacy_store.path="res://tests/fixtures/accepted-finale.archive"
	var legacy_data=legacy_store.load_game()
	t.check(legacy_data.is_empty() and not legacy_store.warning.is_empty(),"Pass0 cleanly rejects the incompatible promoted-APK save")
