extends SceneTree
# PRICED SHOTS: film, reach rings, shutter estimate, the three prices of light,
# timing windows, briefing line, hints and optional save fields. Everything the
# feature adds lives in photo_pricing/; these tests sit beside it.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Table=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const Briefing=preload("res://src/simulation/photo_pricing/photo_pricing_briefing.gd")
const Hints=preload("res://src/presentation/photo_pricing/photo_pricing_hints.gd")
const Text=preload("res://src/campaign/onboarding_text.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
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
func lines_text(r:Dictionary)->String:
	var parts=[]
	for l in r.lines:parts.append(str(l.text))
	return " | ".join(parts)
func _initialize():
	var spire=Vector2(1300,300);var facing=2.74
	# 1 / Film: an exposure spends one; the others are untouched.
	var s=fresh(0);put(s,0,at(spire,facing,110),facing+PI)
	check(Pricing.film_left(s,0)==8 and Pricing.film_left(s,1)==4 and Pricing.film_left(s,2)==4,"film starts at 8 for Quietus and 4 per drone")
	check(not s.mission.has("photo_pricing"),"an untouched mission carries no pricing field")
	check(s.camera_context().text.contains("FILM 8/8"),"the camera text shows the film count")
	s.command("camera");run(s,6)
	check(s.mission.objectives[0].captured and Pricing.film_left(s,0)==7 and Pricing.film_left(s,1)==4,"a usable exposure spends one film")
	# 2 / An unusable exposure still costs film.
	var far=fresh(0);put(far,0,at(spire,facing+PI,230),facing)
	far.command("frame",{"mode":"tight","focus":"drill"});far.command("camera");run(far,6)
	check(Photo.peek(far).shots.size()==1 and not Photo.peek(far).shots[0].usable and Pricing.film_left(far,0)==7,"an unusable exposure spends one film")
	# 3 / An interrupted exposure costs film, and the retake costs another.
	var cut=fresh(0);put(cut,0,at(spire,facing,110),facing+PI)
	cut.command("camera");run(cut,1.0);cut.units[0].pos=at(spire,facing,400);run(cut,1.0)
	check(not cut.mission.objectives[0].captured and Pricing.film_left(cut,0)==7,"an interrupted exposure spends one film")
	put(cut,0,at(spire,facing,110),facing+PI)
	cut.command("camera");run(cut,6)
	check(cut.mission.objectives[0].captured and Pricing.film_left(cut,0)==6,"the retake spends another")
	# 4 / No film, no exposure.
	var dry=fresh(0);put(dry,0,at(spire,facing,110),facing+PI)
	dry.mission["photo_pricing"]={"film":[0,4,4]}
	var ctx=dry.camera_context()
	check(not ctx.ready and ctx.text==Table.TEXT.film_out,"an empty craft cannot start an exposure")
	check(not dry.command("camera") and dry.captures[0].is_empty(),"the camera order is refused with no film")
	# 5 / Saves: the field is optional and validated; old saves load with full film.
	var snap=cut.snapshot()
	check(Sim.valid_snapshot(snap),"a snapshot with spent film is valid")
	var copy=Sim.new();check(copy.restore(snap) and Pricing.film_left(copy,0)==6,"spent film survives a restore")
	var old=fresh(0).snapshot()
	check(not old.mission.has("photo_pricing") and Sim.valid_snapshot(old),"a save without the field is valid")
	var oldcopy=Sim.new();oldcopy.restore(old)
	check(Pricing.film_left(oldcopy,0)==8,"an old save restores with full film")
	for bad in [{"film":[1,2]},{"film":[1,2,"x"]},{"film":[-1,0,0]},{"film":"none"},"x"]:
		var broken=cut.snapshot();broken.mission["photo_pricing"]=bad
		check(not Sim.valid_snapshot(broken),"a malformed pricing field is rejected: "+str(bad))
	var stripped=cut.snapshot();stripped.mission.erase("photo_pricing")
	check(Sim.valid_snapshot(stripped),"removing the field leaves a valid save")
	# 6 / Reach rings: pure reads from the real frame, and a hidden aspect says so.
	var r0=fresh(0);put(r0,0,at(spire,facing+PI,150),facing)
	var spire_obj=r0.mission.objectives[0]
	var before=r0.mission.duplicate(true)
	var pos0=r0.units[0].pos
	var read=Pricing.readout(r0,0,spire_obj)
	check(read.hidden or read.key!="","the readout names a key feature")
	check(read.key=="SCORED PLATING" and not read.hidden and read.plain>60.0 and read.plain<=200.0,"the lee plating resolves inside a close ring: %s %s"%[read.key,str(read.plain)])
	check(r0.units[0].pos==pos0 and r0.mission==before,"a readout changes neither the craft nor the mission")
	var front=fresh(0);put(front,0,at(spire,facing,150),facing+PI)
	var rf=Pricing.readout(front,0,front.mission.objectives[0])
	check(rf.key=="BROKEN DRILL STRING" or rf.key=="SCORED PLATING","the front view keys on an unfilmed detail")
	var hid=fresh(0);put(hid,0,at(spire,facing,150),facing+PI)
	hid.mission.objectives[0].subject.features=hid.mission.objectives[0].subject.features.filter(func(f):return f.id!="drill")
	var rh=Pricing.readout(hid,0,hid.mission.objectives[0])
	check(rh.hidden and lines_text(rh).contains("hidden from here"),"a detail on the far side reads as hidden")
	# 7 / Flash widens the ring on a dark feature; the probe leaves no trace.
	var fl=fresh(1);var west=fl.mission.objectives[0]
	fl.mission.launch_equipment=Equipment.canonical({"quietus":"photo_flash","drone_a":"","drone_b":""})
	put(fl,0,at(west.pos,west.subject.facing,150),west.subject.facing+PI)
	var plain=Pricing.reach_of(fl,0,west,"clock",false)
	var lit=Pricing.reach_of(fl,0,west,"clock",true)
	check(lit>plain and lit>0.0,"flash resolves the dark clock from farther (%d vs %d)"%[plain,lit])
	check(not fl.mission.has("photo") and Photo.settings(fl,0).flash==false,"a flash probe leaves no photo state behind")
	# 8 / The shutter estimate: fixed rings, tele cannot hide them, known Sirens only.
	check(Table.SHUTTER_RING==520.0 and Table.FLASH_RING==760.0,"the told rings are 520 and 760")
	var ring=fresh(0);put(ring,0,at(spire,facing,150),facing+PI)
	ring.mission.objectives[0].subject.features=ring.mission.objectives[0].subject.features.filter(func(f):return f.id!="scoring")
	check(lines_text(Pricing.readout(ring,0,ring.mission.objectives[0])).contains("no known Siren"),"no known Siren means no arrival estimate")
	ring.elapsed+=1.0
	ring.contacts[0]={"pos":ring.units[0].pos+Vector2(240,0),"time":ring.elapsed,"type":"patroller","band":1}
	var heard=lines_text(Pricing.readout(ring,0,ring.mission.objectives[0]))
	check(heard.contains("heard to 520m") and heard.contains("~5s"),"a patroller 240m away arrives in about 5s: "+heard)
	ring.elapsed+=1.0;ring.contacts[0].pos=ring.units[0].pos+Vector2(900,0);ring.contacts[0].time=ring.elapsed
	check(lines_text(Pricing.readout(ring,0,ring.mission.objectives[0])).contains("no known Siren"),"a Siren beyond the ring does not hear it")
	var tele=fresh(0);put(tele,0,at(spire,facing,300),facing+PI)
	tele.mission.launch_equipment=Equipment.canonical({"quietus":"quietus_tele_lens","drone_a":"","drone_b":""})
	check(Photo.optics(tele,0).range==360.0,"tele reaches 360m")
	check(Photo.noise_radius(tele,0)==Table.SHUTTER_RING,"tele leaves the shutter ring at 520m")
	var lamp=fresh(0);put(lamp,0,at(spire,facing,150),facing+PI)
	lamp.mission.launch_equipment=Equipment.canonical({"quietus":"photo_flash","drone_a":"","drone_b":""})
	lamp.command("frame",{"flash":true});lamp.command("camera")
	check(Photo.noise_radius(lamp,0)==Table.FLASH_RING,"a flash exposure is heard to 760m")
	# 9 / Three prices of light: the dark west relay in op 1.
	var dark=fresh(1);var relay=dark.mission.objectives[0]
	dark.mission.launch_equipment=Equipment.canonical({"quietus":"photo_flash","drone_a":"","drone_b":""})
	put(dark,0,at(relay.pos,relay.subject.facing,170),relay.subject.facing+PI)
	var rd=Pricing.readout(dark,0,relay)
	check(rd.light and lines_text(rd).contains("FLASH") and lines_text(rd).contains("WAIT") and lines_text(rd).contains("CLOSE"),"a dark feature shows flash, wait and close prices: "+lines_text(rd))
	check(lines_text(rd).contains("WAIT needs the low-light back"),"wait is unavailable without the back")
	var lowlight=fresh(1);lowlight.mission.launch_equipment=Equipment.canonical({"quietus":"low_light_back","drone_a":"","drone_b":""})
	put(lowlight,0,at(relay.pos,relay.subject.facing,170),relay.subject.facing+PI)
	var rl=Pricing.readout(lowlight,0,lowlight.mission.objectives[0])
	check(lines_text(rl).contains("WAIT 8s still") and lines_text(rl).contains("FLASH not fitted"),"the low-light back offers an 8s wait: "+lines_text(rl))
	var drone_dark=fresh(1)
	drone_dark.units[1].alive=true
	put(drone_dark,1,at(relay.pos,relay.subject.facing,60),relay.subject.facing+PI)
	var dframe=Photo.frame(drone_dark,1,drone_dark.mission.objectives[0])
	check(dframe.rows[1].why.begins_with("TOO DARK"),"a drone lamp cannot light the west relay clock")
	# 10 / Timing window countdown on the hatch seam.
	var hatch=fresh(3);var bay=hatch.mission.objectives.filter(func(o):return o.get("optical","")=="frame_cycle")[0]
	put(hatch,0,at(bay.pos,bay.subject.facing,120),bay.subject.facing+PI)
	hatch.elapsed=10.0
	var fr=Photo.frame(hatch,0,bay)
	var win=Pricing.windows(hatch,bay,fr)
	check(win.size()==1 and not win[0].open and win[0].text.contains("OPENS IN 20s"),"at 10s of a 30s cycle the hatch opens in 20s: "+str(win))
	hatch.elapsed=32.0
	win=Pricing.windows(hatch,bay,Photo.frame(hatch,0,bay))
	check(win[0].open and win[0].text.contains("5s left"),"inside the 7s window it counts down: "+str(win))
	# 11 / Briefing line.
	var plain_fit=Equipment.default_loadout()
	var b0=Briefing.line(0,plain_fit)
	check(b0.contains("PHOTO PROBLEMS") and b0.contains("standard lens"),"op 0 briefing names the photo problem and the optics")
	var tele_fit=Equipment.canonical({"quietus":"quietus_tele_lens","drone_a":"","drone_b":""})
	check(Briefing.line(3,tele_fit).contains("tele lens") and Briefing.line(2,tele_fit).is_empty(),"the line follows the fitting and skips unphotographed ops")
	check(b0.split("\n").size()<=2,"the briefing line is at most two lines")
	# 12 / Hints: once-only ids, kept valid without the module.
	check(Hints.applies("priced_reach",0) and Hints.applies("priced_light",1) and Hints.applies("priced_window",3) and Hints.applies("priced_film",4),"four hints over ops 0 to 4")
	check(Text.HINTS.has("priced_reach") and Text.applies("priced_film",4) and not Text.applies("priced_film",0),"the hint text table carries them")
	check(Text.valid_seen(["move","priced_film"]) and Text.valid_seen(["priced_gone"]) and not Text.valid_seen(["bogus"]),"saved hint ids stay valid if the module is removed")
	var h0=fresh(0);put(h0,0,at(spire,facing,150),facing+PI)
	check(Hints.wanted(h0,0,func(id):return false)=="priced_reach","arming the camera in op 0 asks for the reach hint")
	check(Hints.wanted(h0,0,func(id):return id=="priced_reach")=="","a seen hint is not repeated")
	var h4=fresh(4);h4.mission["photo_pricing"]={"film":[6,4,4]}
	check(Hints.wanted(h4,4,func(id):return false)=="priced_film","the second exposure raises the film hint")
	# 13 / Data pass: bare Quietus can still finish every core photo job in ops 0 to 5.
	for id in [0,1,3,4,5]:
		var op=fresh(id)
		for i in op.mission.objectives.size():
			var o=op.mission.objectives[i]
			if not Photo.applies(o) or o.get("optional",false):continue
			put(op,0,at(o.pos,float(o.subject.facing),90),float(o.subject.facing)+PI)
			var f=Photo.frame(op,0,o)
			var ok=true
			for rr in f.rows:
				if rr.id in o.subject.required and not rr.ready and not str(rr.why).begins_with("WAITING"):ok=false
			check(ok,"op %d objective %d required feature resolves for bare Quietus at 90m"%[id,i])
	# 14 / Probes restore everything on a fresh mission.
	var clean=fresh(0);put(clean,0,at(spire,facing+PI,150),facing)
	Pricing.reach_of(clean,0,clean.mission.objectives[0],"scoring",true)
	check(not clean.mission.has("photo") and clean.units[0].pos==at(spire,facing+PI,150),"probing does not create photo state or move the craft")
	print("PHOTO PRICING CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
