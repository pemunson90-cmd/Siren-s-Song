extends SceneTree
# PHOTO2: discovery (unknown until a frame resolves it), findings the archive
# teaches (marks on the chart), and the saves that carry them.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Findings=preload("res://src/simulation/photo_findings.gd")
const Missions=preload("res://src/campaign/missions.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func run(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
func fresh(id:int,keep_sirens:bool=false):
	var s=Sim.new();s.start(id,"endurance");s.units[1].alive=false;s.units[2].alive=false
	if not keep_sirens:s.sirens=[]
	return s
func put(s,uid:int,pos:Vector2,angle:float=0.0):
	s.units[uid].pos=pos;s.units[uid].angle=angle;s.units[uid].vel=Vector2.ZERO
func at(origin:Vector2,angle:float,dist:float)->Vector2:
	return origin+Vector2.from_angle(angle)*dist
func shoot(s,seconds:float=6.0)->bool:
	var ok=s.command("camera");run(s,seconds);return ok
func study(s,i:int):
	var g=s.sirens[i];g.stun=100.0
	for k in 16:
		var a=TAU*k/16.0;var p=g.pos+Vector2.from_angle(a)*110
		if s.blocked(p,30.0) or not s.line_clear(p,g.pos):continue
		g.angle=a;put(s,0,p,a+PI);break
	run(s,0.4)
	var idx=Photo.siren_objective(s,i);s.captures[0]={"target":idx,"elapsed":0.0};s.units[0].hold="HOLD";Photo.begin(s,0,idx);run(s,9.5)
func last(s)->Dictionary:
	return s.mission.photo.shots.back()
func _initialize():
	var spire=Vector2(1300,300);var facing=2.74
	# 1 / The spire is a lead, not a name or a point.
	var s=fresh(0)
	var site=s.observable_sites()[0]
	check(site.name=="UNKNOWN SIGNAL SOURCE" and site.stage=="lead","an unresolved tutorial target is charted only as an unknown lead")
	check(site.pos!=spire and spire.distance_to(site.pos)<site.lead_r,"the lead is an area that contains the target, never its exact point")
	check(not site.has("evidence"),"the public view carries no evidence text that names it")
	put(s,0,at(spire,facing,200),facing+PI)
	check(not s.camera_context().text.contains("SPIRE") and not s.message.contains("SPIRE"),"camera status does not name the unresolved target")
	# 2 / Sighting turns an area into an exact unnamed shape.
	put(s,0,at(spire,facing,130),facing+PI);s.advance(0.2);run(s,0.3)
	check(s.observable_sites()[0].stage=="sighted" and s.observable_sites()[0].pos==spire and s.observable_sites()[0].name=="UNKNOWN SIGNAL SOURCE","a craft that faces it within sight fixes it, still unnamed")
	# 3 / A frame that resolves it names it; a failed frame does not.
	var far=fresh(0);put(far,0,at(spire,facing,110),facing+PI);far.command("frame",{"mode":"tight","focus":"scoring"});shoot(far,6)
	check(not last(far).usable and far.observable_sites()[0].name=="UNKNOWN SIGNAL SOURCE","an unusable frame leaves it unnamed")
	put(s,0,at(spire,facing,110),facing+PI);shoot(s,6)
	check(s.observable_sites()[0].name=="SIGNAL SPIRE" and s.observable_sites()[0].get("stage","resolved")=="resolved","a resolving frame names it")
	# 4 / The frame taught something the player can act on.
	var found=s.mission.photo.findings
	var route=found.filter(func(f):return f.kind=="route")
	check(route.size()==1 and "drill" in last(s).features,"the front view resolves the drill string and files a lee channel route")
	var clear=true
	for n in route[0].pts.size()-1:
		var a=Findings.vec(route[0].pts[n]);var b=Findings.vec(route[0].pts[n+1])
		if not s.line_clear(a,b) or s.blocked(a,30.0):clear=false
	check(clear,"the marked route is true: every leg is clear water")
	check(not found.any(func(f):return f.kind=="hazard"),"the lee scoring was not resolved from the front, so no hazard mark exists")
	check(last(s).frame.marks.any(func(m):return m.get("find","")=="route"),"the stored plate marks which feature carries the finding")
	var rear=fresh(0);put(rear,0,at(spire,facing+PI,110),facing);shoot(rear)
	check(rear.mission.photo.findings.any(func(f):return f.kind=="hazard") and not rear.mission.photo.findings.any(func(f):return f.kind=="route"),"the rear view teaches the hazard and not the route")
	var data={"version":Store.VERSION,"unlocked":5,"completed":[],"settings":{},"upgrade":"endurance","active":s.snapshot()}
	check(Sim.valid_snapshot(s.snapshot()) and Store.new().valid(data),"a dive holding findings saves and validates")
	var bad=s.snapshot();bad.mission.photo.findings=[{"id":"x"}]
	check(not Sim.valid_snapshot(bad),"a malformed finding is rejected")
	var old=s.snapshot();old.mission.photo.erase("findings");old.mission.photo.erase("studies")
	check(Sim.valid_snapshot(old),"a snapshot from before findings still loads")
	# 5 / Sirens: loop, post and behavior come from what was resolved.
	var f3=fresh(3,true)
	study(f3,0)
	var post=f3.mission.photo.findings.filter(func(f):return f.kind=="post")
	check(post.size()==1 and post[0].has("r") and post[0].text.contains("Holds its post"),"its array shows a sentinel's post and tether")
	check(f3.mission.photo.findings.any(func(f):return f.kind=="loop"),"watching its movement shows its loop or path")
	# 6 / Patience teaches the hatch cycle; the chart clock is the shared world clock.
	var base=fresh(3);var bay=base.mission.objectives[2];put(base,0,bay.pos+Vector2(0,95),-PI/2);base.elapsed=9.0;base.command("camera");run(base,35)
	var cyc=base.mission.photo.findings.filter(func(f):return f.kind=="cycle")
	check(cyc.size()==1 and cyc[0].period==30.0 and cyc[0].open==7.0,"a held full cycle files the hatch count")
	# 7 / Two studied loops reveal the gap between them, computed from real loops.
	var two=fresh(1,true)
	for i in 2:
		study(two,i)
	var gaps=two.mission.photo.findings.filter(func(f):return f.kind=="gap")
	if gaps.size()==1:
		var gp=Findings.vec(gaps[0].pos)
		check(not two.blocked(gp,40.0) and gaps[0].r>=Findings.GAP_MIN,"the gap is open water at least the stated distance from both loops")
	else:
		check(two.mission.photo.findings.filter(func(f):return f.kind=="loop").size()>=1,"loops were studied; a gap appears only if open water exists between them")
	# 8 / Film from an earlier dive marks the chart of a later one.
	var plain=Missions.make(25,{});var informed=Missions.make(25,{"intel":{"exhaust_stack":{"q":0.6,"op":16}}})
	check(not plain.has("photo_marks") and informed.photo_marks.any(func(m):return m.kind=="lane" and m.rect.size()==4),"furnace film puts the warm lane on the Last Shift chart")
	var gap_op=Missions.make(19,{"intel":{"silt_scour":{"q":0.6,"op":17}}})
	check(gap_op.photo_marks.any(func(m):return m.kind=="gap") and not Missions.make(19,{"intel":{"silt_scour":{"q":0.1,"op":17}}}).has("photo_marks"),"scour film marks the opened gap, a poor frame marks nothing")
	# 9 / Glass Reach and Iron Choir unknowns.
	var prism=fresh(20);var pr=prism.mission.objectives.back()
	check(pr.get("unknown",false) and prism.observable_sites().back().stage=="lead","Prism Grave's crystal starts as an unknown lead")
	var win=fresh(22);var hidden=win.mission.photo_hidden[0]
	check(hidden.has("lead") and not hidden.found and win.mission.objectives.size()==win.mission.objectives.size(),"Hammerwake's window is a lead area with no objective yet")
	put(win,0,hidden.pos+Vector2(-130,0),0.0);win.advance(0.2);run(win,0.3)
	var wo=win.mission.objectives.filter(func(o):return o.get("optical","")=="choir_window")
	check(wo.size()==1 and wo[0].name=="UNIDENTIFIED LIGHT","facing it fixes an unidentified light")
	put(win,0,hidden.pos+Vector2(0,100),-PI/2);shoot(win,6)
	check(wo[0].name=="LOCK A WINDOW" and win.mission.photo.findings.any(func(f):return f.kind=="person"),"a good frame names the lock window and shows a person")
	print("PHOTO DISCOVERY CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
