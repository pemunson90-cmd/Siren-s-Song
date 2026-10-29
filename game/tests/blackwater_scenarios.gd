extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
static func make():
	var s=Simulation.new();s.start(2)
	# Rule fixture only. Actual ordinary threat/loss encounters are separate evidence.
	for enemy in s.sirens:enemy.stun=100.0
	return s
static func place(s,site:int,distance:float=130,station:int=0):
	s.units[station].pos=s.mission.objectives[site].pos+Vector2(0,distance if site==0 else -distance);s.units[station].vel=Vector2.ZERO
static func tick(s,seconds:float):
	for n in int(round(seconds*60)):s.advance(1.0/60)
static func run(t):
	var s=make();var objective=s.mission.objectives[0]
	t.check(s.mission.get("blackwater_revision",0)==1 and objective.get("kind","")=="exchange" and objective.get("duration",4)==2.0,"fresh Blackwater uses two-second direct relay samples without cyclic waiting")
	t.check(objective.get("optical","")=="blackwater_request" and s.mission.objectives[1].get("optical","")=="blackwater_reply","request and reply have distinct retained receiver records")
	place(s,0);s.command("camera");t.check(not s.noises.any(func(n):return n.label=="CAMERA"),"quiet receiver emits no camera pulse at command acceptance");s.paused=false;tick(s,2.05)
	t.check(objective.captured and not s.noises.any(func(n):return n.label=="CAMERA"),"quiet local reception earns request without an optical emission")
	t.check("REPLY" in s.message and "SONAR" in s.message,"first earned request explains a usable next-site audible replay alternative")
	t.check("240" in objective.get("evidence","") and "SONAR" in objective.get("evidence",""),"retained request preserves the learned replay protocol")
	s=make();place(s,1);s.command("camera");s.paused=false;tick(s,2.05)
	t.check(s.mission.objectives[1].captured and "REQUEST" in s.message,"reverse reply-first order remains valid and teaches matching request action")
	t.check("log" in s.mission.objectives[1].get("evidence","").to_lower(),"reply preserves the driller log discovery")
	s=make();place(s,0,210)
	t.check(not s.command("camera"),"Quietus210m standoff cannot silently use its156m passive receiver")
	t.check(s.command("ping") and s.command("camera"),"accepted existing SONAR permits local clear standoff replay sampling")
	t.check(s.ping_time==3.5 and s.noises.any(func(n):return n.label=="ACTIVE SONAR" and n.radius==750),"replay retains selected default low-power sonar cooldown and750m emission")
	s.paused=false;tick(s,2.05);t.check(s.mission.objectives[0].captured,"audible standoff earns the same request in two settled seconds")
	s=make();place(s,0,230,1);s.command("select",{"unit":1})
	t.check(not s.command("camera"),"drone230m is outside actual214.5m passive reach")
	s.command("ping");t.check(s.command("camera"),"drone can use clear230m replay standoff")
	s.paused=false;tick(s,2.05);t.check(s.mission.objectives[0].captured,"drone and Quietus share the locally earned replay path")
	s=make();place(s,0,210);s.command("ping");s.paused=false;tick(s,1.8);var until=s.mission.objectives[0].get("replay_until",0)
	t.check(not s.command("ping") and s.mission.objectives[0].get("replay_until",0)==until,"cooling-down sonar cannot extend an earned replay")
	s.command("camera");tick(s,1.3)
	t.check(not s.mission.objectives[0].captured and s.capture_unit<0,"replay expiry interrupts an incomplete standoff sample")
	s=make();place(s,0);s.mission.rocks.append(Rect2(735,250,60,20));s._build_navigation();s.command("ping")
	t.check(not s.blackwater_context(0,0).ready and s.camera_context().target!=0 and s.mission.objectives[0].get("replay_until",0)==0,"cover blocks both quiet reception and sonar replay confirmation")
	var before=s.snapshot();s.camera_context();t.check(before==s.snapshot(),"receiver readiness is a read-only own-range and terrain query")
	s=make();place(s,0);s.units[0].vel=Vector2(80,0);s.command("camera");s.paused=false;tick(s,0.25)
	t.check(s.capture_time==0,"moving craft must settle before reception accumulates")
	s=make();place(s,0);s.command("camera");s.command("select",{"unit":1});s.paused=false;tick(s,1.0)
	t.check(s.capture_feedback(0).unit==0 and s.capture_feedback(1).unit<0 and not s.camera_context().ready,"station handoff keeps remote reception while readiness follows selected craft")
	s.paused=true;before=s.snapshot();s.advance(100);t.check(before==s.snapshot(),"tactical pause freezes partial reception and all relay clocks")
	var restored=Simulation.new();t.check(restored.restore(s.snapshot()) and restored.paused,"partial receiver sample restores paused through the existing snapshot")
	restored.paused=false;tick(restored,1.05);t.check(restored.mission.objectives[0].captured,"restored partial sample finishes its remaining reception")
	s=make();place(s,0);s.units[1].alive=false;s.units[2].alive=false;s.command("camera");s.paused=false;tick(s,2.05)
	t.check(s.mission.objectives[0].captured,"slower Quietus remains valid after both drones are lost")
	s=make();place(s,0,130,1);s.command("select",{"unit":1});s.command("camera");s.units[1].alive=false;s.paused=false;tick(s,0.05)
	t.check(s.selected==0 and "SAMPLE" in s.message,"lost Blackwater station names the actual Quietus SAMPLE fallback")
	s=make();place(s,0,210);s.command("ping");s.paused=false;tick(s,0.4);s.paused=true
	var data={"version":1,"unlocked":2,"completed":[0,1],"upgrade":"endurance","settings":{},"active":s.snapshot(),"evidence":{"blackwater_request":{"name":"REQUEST RELAY","caption":"Replay protocol","optical":"blackwater_request"}}}
	var store=Store.new();store.path="user://test-blackwater.save"
	t.check(store.save(data) and store.load_game()==data,"actual archive retains new request evidence and remaining replay lifetime")
	var persisted=store.load_game()
	for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(store.path+suffix)
	var clock_restore=Simulation.new();var restored_clock=clock_restore.restore(persisted.get("active",{}))
	if restored_clock:clock_restore.paused=false;tick(clock_restore,2.65)
	t.check(restored_clock and not clock_restore.blackwater_context(0,0).ready and clock_restore.camera_context().target!=0,"restored replay expires against active simulation time without a wall-clock extension")
	var malformed=s.snapshot();malformed.mission.objectives[0]["replay_until"]="forever"
	t.check(not Simulation.valid_snapshot(malformed),"malformed optional replay state is rejected before restore")
	malformed=s.snapshot();malformed.mission.objectives[0]["replay_until"]=NAN
	t.check(not Simulation.valid_snapshot(malformed),"nonfinite optional replay clock cannot enter a restored mission")
	# Actual ordinary finale plan leaves target2 inactive; production reuses this sim.
	var replay=preload("res://tests/finale_command_plan.gd").play(false,"warning",true)
	replay.start(2)
	t.check(Simulation.valid_snapshot(replay.snapshot()),"replaying Blackwater after ordinary finale completion yields a valid fresh snapshot")
	var replay_data={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"active":replay.snapshot()}
	t.check(store.save(replay_data),"existing autosave accepts fresh Blackwater after finale target2")
	for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(store.path+suffix)
	var legacy_store=Store.new();legacy_store.path="res://tests/fixtures/accepted-blackwater.archive"
	var old=legacy_store.load_game()
	t.check(old.is_empty() and not legacy_store.warning.is_empty(),"Pass0 cleanly rejects the incompatible Blackwater archive")
