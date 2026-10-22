extends SceneTree
# PHOTO1: viewpoint, light, framing, craft, patience, discovery, intel and gear
# all change the frame, and only legitimately observable facts are recorded.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Intel=preload("res://src/campaign/photo_intel.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const Upgrades=preload("res://src/equipment/craft_upgrades.gd")
const View=preload("res://src/presentation/photo_view.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Missions=preload("res://src/campaign/missions.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func run(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
func fresh(id:int):
	var s=Sim.new();s.start(id,"endurance");s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
	return s
func put(s,uid:int,pos:Vector2,angle:float=0.0):
	s.units[uid].pos=pos;s.units[uid].angle=angle;s.units[uid].vel=Vector2.ZERO
func at(origin:Vector2,angle:float,dist:float)->Vector2:
	return origin+Vector2.from_angle(angle)*dist
func shoot(s,seconds:float=6.0)->bool:
	var ok=s.command("camera")
	run(s,seconds)
	return ok
func last(s)->Dictionary:
	return s.mission.photo.shots.back()
func _initialize():
	var spire=Vector2(1300,300);var facing=2.74
	# 1 / Viewpoint: the same subject shows different features from different sides.
	var s=fresh(0);put(s,0,at(spire,facing,110),facing+PI)
	check(shoot(s) and s.mission.objectives[0].captured,"front exposure completes the beacon record")
	check("drill" in last(s).features and "scoring" not in last(s).features,"front view resolves the drill string, not the lee plating")
	var rear=fresh(0);put(rear,0,at(spire,facing+PI,110),facing)
	shoot(rear)
	check("scoring" in last(rear).features and "drill" not in last(rear).features,"rear view resolves the scoring, not the drill string")
	# 2 / Distance: far exposure is still a record but loses fine detail.
	var far=fresh(0);put(far,0,at(spire,facing,232),facing+PI)
	shoot(far)
	check(last(far).features==["beacon"] and last(far).q<last(s).q-0.2,"distant frame keeps the glowing beacon only and grades lower")
	# 3 / Orientation: the craft turns onto the subject, costing exposure time.
	var turn=fresh(0);put(turn,0,at(spire,facing,110),facing)
	var pivot=Photo.frame(turn,0,turn.mission.objectives[0]).pivot
	check(pivot>0.5,"craft facing away from the subject must turn before it is framed")
	turn.command("camera");run(turn,2.5)
	check(not turn.mission.objectives[0].captured,"turning onto the subject delays a four second exposure")
	run(turn,3)
	check(turn.mission.objectives[0].captured and absf(angle_difference(turn.units[0].angle,turn.units[0].pos.angle_to_point(spire)))<2.3,"exposure completes after the turn, hull within the gimbal arc of the subject")
	# 4 / Framing: tight frames resolve one feature; wide frames cannot resolve fine detail.
	var tight=fresh(0);put(tight,0,at(spire,facing,100),facing+PI)
	tight.command("frame",{"mode":"tight","focus":"drill"});shoot(tight)
	check(last(tight).features==["drill"] and last(tight).mode=="tight","tight frame resolves exactly the focused feature")
	var wide=fresh(3);put(wide,0,wide.mission.objectives[0].pos+Vector2(0,60),-PI/2)
	var f_wide=Photo.frame(wide,0,wide.mission.objectives[0])
	check(f_wide.rows[1].why.contains("FINE") or f_wide.rows[1].ready==false or f_wide.mode=="wide","wide frame state reported")
	# 5 / Craft: Quietus has the better sensor, a drone can get closer and sees in the dark less well.
	var craft=fresh(0);craft.units[1].alive=true
	put(craft,0,at(spire,facing,140),facing+PI);put(craft,1,at(spire,facing,140),facing+PI)
	var sub_frame=Photo.frame(craft,0,craft.mission.objectives[0]);var drone_frame=Photo.frame(craft,1,craft.mission.objectives[0])
	check(sub_frame.sharp>drone_frame.sharp,"at the same range Quietus's lens and lamp beat a drone's")
	put(craft,1,at(spire,facing,45),facing+PI)
	check(Photo.frame(craft,1,craft.mission.objectives[0]).sharp>sub_frame.sharp,"a drone that closes in out-resolves Quietus at standoff")
	check(Photo.frame(craft,1,craft.mission.objectives[0]).dist<sub_frame.dist,"closing in is the drone's trade")
	# 6 / Gear: flash gives light at a charge and noise cost; thermal imager sees heat features.
	var gear=fresh(5);gear.units[1].alive=true
	gear.mission.launch_equipment=Equipment.canonical({"quietus":"","drone_a":"photo_flash","drone_b":"thermal_imager"})
	check(Equipment.valid_fitting(gear.mission.launch_equipment),"camera hardware fits the optics mounts")
	var wakes=gear.mission.objectives[1];put(gear,1,wakes.pos+Vector2(0,-150),PI/2);put(gear,2,wakes.pos+Vector2(0,-150),PI/2);put(gear,0,wakes.pos+Vector2(0,-150),PI/2)
	gear.units[2].alive=true
	check(not Photo.frame(gear,0,wakes).rows[1].ready and Photo.frame(gear,0,wakes).rows[1].why.contains("thermal"),"heat feature is not resolved without a thermal imager")
	check(Photo.frame(gear,2,wakes).rows[1].ready,"thermal imager resolves the warm fracture at standoff")
	var dark=Photo.frame(gear,1,wakes).light
	gear.command("select",{"unit":1});gear.command("frame",{"flash":true})
	check(Photo.frame(gear,1,wakes).light>dark+0.1,"flash adds light to the frame")
	gear.command("select",{"unit":0})
	check(not gear.command("frame",{"flash":true}),"a craft without a flash cannot arm one")
	gear.command("select",{"unit":1});gear.command("camera")
	check(Photo.flash_left(gear,1)==1 and gear.noises.any(func(n):return n.label=="CAMERA" and n.radius>=760),"flash spends a charge and widens the audible camera event")
	# 7 / Patience: a windowed feature needs a whole cycle held steady.
	var base=fresh(3);base.mission.photo_hidden=[]
	var bay=base.mission.objectives[2];put(base,0,bay.pos+Vector2(0,95),-PI/2)
	check(bay.optional and bay.duration>=30.0,"base cycle study is an optional long observation")
	base.elapsed=9.0
	base.command("camera");run(base,10)
	put(base,0,bay.pos+Vector2(60,95),-PI/2);base.command("route",{"point":bay.pos+Vector2(200,150)})
	check(Photo.state(base).shots.size()==0 and not bay.captured,"abandoning a long exposure yields no frame")
	Photo.state(base).acc={}
	var full=fresh(3);var bay2=full.mission.objectives[2];put(full,0,bay2.pos+Vector2(0,95),-PI/2)
	full.elapsed=9.0;full.command("camera");run(full,35)
	check(bay2.captured and "hatch" in last(full).features and last(full).intel.has("base_cycle"),"holding a full cycle resolves the hatch pattern and earns base-cycle intel")
	# 8 / Discovery: an unnamed phenomenon becomes an objective only when a craft's camera sights it.
	var silt=fresh(17);var target=Vector2(1750,1230)
	check(silt.mission.objectives.size()==1 and silt.mission.photo_hidden.size()==1,"the phenomenon is not an objective or chart mark before it is sighted")
	put(silt,0,target+Vector2(-150,0),PI);silt.advance(0.2)
	check(silt.mission.objectives.size()==1,"a craft facing away does not sight it")
	put(silt,0,target+Vector2(-420,0),0.0);silt.advance(0.2)
	check(silt.mission.objectives.size()==1,"too far to sight")
	put(silt,0,target+Vector2(-150,0),0.0);silt.advance(0.2);silt.paused=false;run(silt,0.3)
	check(silt.mission.objectives.size()==2 and silt.mission.objectives[1].get("unknown",false) and silt.mission.objectives[1].name.begins_with("UNIDENTIFIED"),"facing it within sight distance reveals an unidentified return")
	var bad=silt.mission.objectives[1]
	put(silt,0,target+Vector2(-235,0),0.0);shoot(silt,6)
	check(not bad.captured and not last(silt).usable,"a far frame leaves it unresolved and unusable")
	check(bad.name.begins_with("UNIDENTIFIED"),"an unusable frame does not name the phenomenon")
	put(silt,0,target+Vector2(-110,0),0.0);shoot(silt,6)
	check(bad.captured and bad.name=="SILT SCOUR LINES","a good frame identifies and names it")
	check("channel" not in last(silt).features,"the wrong side hides the cut channel")
	check(silt.camera_context().ready,"a captured subject with unseen features can be re-shot")
	put(silt,0,target+Vector2(110,0),PI);shoot(silt,6)
	check("channel" in last(silt).features and last(silt).intel.has("silt_scour") and silt.mission.photo.shots.size()==3,"re-shot from the front resolves the channel: three frames of one target")
	# 9 / Intel comes home and changes the next operation.
	var won=Sim.new();won.start(16);won.mission["recovered"]=true
	var with_intel=Intel.recover({},silt.mission)
	check(with_intel.has("silt_scour") and Intel.valid(with_intel),"returned film becomes validated intel")
	var plain=Missions.make(19,{});var informed=Missions.make(19,{"intel":with_intel})
	check(informed.rocks.size()==plain.rocks.size()-1 and informed.brief.contains("scour"),"silt scour photographs open the middle water in Last Boat Out")
	var weak=Missions.make(19,{"intel":{"silt_scour":{"q":0.1,"op":16}}})
	check(weak.rocks.size()==plain.rocks.size(),"a poor frame reveals nothing")
	var exhaust={"exhaust_stack":{"q":0.6,"op":15}}
	var choir=Missions.make(25,{"intel":exhaust});var bare=Missions.make(25,{})
	check(choir.get("photo_lane","")=="WARM EXHAUST LANE" and choir.thermal_fronts.size()==1 and not bare.has("photo_lane"),"furnace plume photographs give the Last Shift a warm exhaust lane")
	check(preload("res://src/simulation/thermal_front.gd").valid_mission(choir),"the revealed lane is a valid thermal front")
	# 10 / Research: the archive cuts camera hardware, and saves validate it.
	var intel={"foundry_lining":{"q":0.5,"op":3},"exhaust_stack":{"q":0.5,"op":15}}
	var earned=Upgrades.recovered([0,1,2,3,4,5],{},intel)
	check("photo_flash" in earned and "thermal_imager" in earned and "quietus_tele_lens" not in earned,"intel cuts exactly the hardware it supports")
	var save=Store.new()
	var data={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"settings":{},"upgrade":"endurance","intel":intel,"equipment":Equipment.canonical({"quietus":"","drone_a":"thermal_imager","drone_b":""})}
	check(save.valid(data),"save with intel and researched fitting validates")
	data.equipment=Equipment.canonical({"quietus":"quietus_tele_lens","drone_a":"","drone_b":""})
	check(not save.valid(data),"fitting hardware the archive has not cut is rejected")
	data.equipment=Equipment.default_loadout();data.intel={"ghost":{"q":0.5,"op":1}}
	check(not save.valid(data),"unknown intel key is rejected")
	data.intel=intel;data.evidence={"silt_scour":{"name":"SILT SCOUR LINES","caption":"x","optical":"silt_scour","shots":silt.mission.photo.shots.slice(0,2).duplicate(true)}}
	check(save.valid(data) and View.valid_shots(data.evidence.silt_scour.shots),"evidence with stored frames validates")
	data.evidence.silt_scour.shots[0].frame.cols=[1]
	check(not save.valid(data),"malformed stored frame is rejected")
	# 11 / Frames render from stored data, and mid-exposure state survives restore.
	var model=View.from_shot(silt.mission.photo.shots[0])
	check(model.cols.size()==36 and model.dist>0,"archive viewer builds its picture from the stored frame")
	var live=fresh(0);put(live,0,at(spire,facing,110),facing+PI);live.command("camera");run(live,1.5)
	var snap=live.snapshot()
	check(Sim.valid_snapshot(snap),"snapshot mid-exposure is valid")
	var copy=Sim.new();check(copy.restore(snap),"restore accepts mid-exposure photo state")
	copy.paused=false;run(copy,3)
	check(copy.mission.objectives[0].captured,"restored exposure finishes")
	# 12 / Sirens can be studied: movement is recorded as an observed path.
	var st=Sim.new();st.start(0);st.units[1].alive=false;st.units[2].alive=false
	var guard=st.sirens[0];guard.pos=Vector2(780,560);guard.stun=100.0;guard.angle=0.0
	put(st,0,Vector2(900,560),PI);run(st,0.4)
	var ctx=st.camera_context()
	check(ctx.ready and ctx.target==-2,"a visible Siren in clear water is a photographic subject")
	check(st.command("camera"),"camera order accepted on a Siren")
	run(st,9)
	var so=st.mission.objectives.back()
	check(so.has("siren") and so.captured and last(st).type=="patroller","studying a Siren files its own record")
	check("array" in last(st).features and last(st).path.size()>=4,"the front view resolves its array, a long watch records its movement")
	check(st.mission.photo.paths.size()==1,"the observed path is kept for the chart")
	var behind=Sim.new();behind.start(0);behind.units[1].alive=false;behind.units[2].alive=false
	behind.sirens[0].pos=Vector2(780,560);behind.sirens[0].stun=100.0;behind.sirens[0].angle=PI
	put(behind,0,Vector2(900,560),PI);run(behind,0.4);behind.command("camera");run(behind,9)
	check("array" not in last(behind).features,"from behind its array is not visible")
	print("PHOTO CAPTURE CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
