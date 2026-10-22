extends SceneTree
# PHOTO RULES: loop clock, post return clock, window check, known lane and the
# optional deep seam. Everything the feature adds lives in src/photo_rules/;
# these tests sit beside it.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Findings=preload("res://src/simulation/photo_findings.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Table=preload("res://src/photo_rules/rule_table.gd")
const LoopClock=preload("res://src/photo_rules/loop_clock.gd")
const PostClock=preload("res://src/photo_rules/post_clock.gd")
const WindowCheck=preload("res://src/photo_rules/window_check.gd")
const KnownLane=preload("res://src/photo_rules/known_lane.gd")
const RuleData=preload("res://src/photo_rules/rule_data.gd")
const BandPhoto=preload("res://src/photo_depth/band_photo.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func run(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
func fresh(id:int):
	var s=Sim.new();s.start(id,"endurance");s.units[1].alive=false;s.units[2].alive=false
	return s
func contact(s,i:int,pos:Vector2,mode:String="PATROL",age:float=0.0):
	s.contacts[i]={"pos":pos,"time":s.elapsed-age,"mode":mode,"lock":0.0,"angle":0.0,"target":-1,"type":str(s.sirens[i].get("type","patroller")),"band":int(s.sirens[i].band),"transition":{},"source":"optical","confidence":1.0}
func store(s,list:Array):
	Photo.state(s);Findings.file(s,list)
func file_loop(s,i:int,q:float=0.6,text:String=""):
	var pts:Array=s.sirens[i].patrol_points.map(func(p):return Findings.pt(p))
	pts.append(pts[0])
	store(s,[Findings.make("loop_%d"%i,"loop",text if not text.is_empty() else "S%d PATROL LOOP · %d turns"%[i+1,pts.size()-1],q,s.mission.id,1,{"pts":pts})])
func _initialize():
	# 1 / Loop clock: locked until the gait frame files a loop at quality 0.45.
	var s=fresh(0);s.sirens.remove_at(1)
	s.elapsed=100.0
	check(LoopClock.entries(s).is_empty(),"no loop clock before the loop is studied")
	file_loop(s,0,0.3)
	check(LoopClock.entries(s).is_empty(),"a weak gait frame (0.3) unlocks nothing")
	s.mission.photo.findings.clear();file_loop(s,0,0.7,"S1 OBSERVED PATH · loop not yet clear")
	check(LoopClock.entries(s).is_empty(),"an observed path is not a studied loop")
	s.mission.photo.findings.clear();file_loop(s,0,0.6)
	var pts:Array=s.sirens[0].patrol_points
	var length:float=0.0
	for k in pts.size():length+=pts[k].distance_to(pts[(k+1)%pts.size()])
	var e=LoopClock.entries(s)
	check(e.size()==1 and e[0].state=="stale" and is_equal_approx(float(e[0].period),length/Table.PATROL_SPEED),"with no sighting the loop shows only its length and STALE (%s)"%LoopClock.text(e[0]))
	contact(s,0,pts[0]);e=LoopClock.entries(s)
	var first:float=pts[0].distance_to(pts[1])/25.0
	check(e[0].state=="live" and absf(float(e[0].turn)-first)<0.05,"a fresh sighting at a corner puts the next turn %.1f s away (got %.2f)"%[first,float(e[0].turn)])
	s.elapsed+=3.0;e=LoopClock.entries(s)
	check(absf(float(e[0].turn)-(first-3.0))<0.05 and e[0].at.distance_to(pts[0])>60.0,"the tick dead reckons along the loop as time passes (%.2f)"%float(e[0].turn))
	s.elapsed+=9.0;e=LoopClock.entries(s)
	check(e[0].state=="aging" and LoopClock.text(e[0]).contains("AGING"),"older than 10 s reads AGING")
	s.elapsed+=9.0;e=LoopClock.entries(s)
	check(e[0].state=="stale" and LoopClock.text(e[0]).contains("STALE"),"older than 20 s reads STALE and drops the tick")
	s.elapsed=100.0;contact(s,0,pts[0]);s.sirens[0].pos=Vector2(900,900)
	check(LoopClock.entries(s)[0].at.distance_to(pts[0])<1.0,"the clock never reads the live Siren position")
	contact(s,0,pts[0],"INVESTIGATE")
	check(LoopClock.entries(s)[0].state=="stale","a Siren last seen off its routine is not clocked")
	contact(s,0,pts[0]);s.noises.append({"band":1,"pos":pts[0]+Vector2(100,0),"radius":520.0,"time":2.0,"label":"CAMERA"})
	check(LoopClock.entries(s)[0].state=="stale","a noise the Siren would have heard retires the clock")
	s.noises.clear();contact(s,0,pts[0]+Vector2(400,400))
	check(LoopClock.entries(s)[0].state=="stale","a sighting far from the loop is not placed on it")
	var sentinel=fresh(3);file_loop(sentinel,0,0.8)
	check(LoopClock.entries(sentinel).is_empty(),"a sentinel holds a post and has no loop clock")
	# 2 / Post return clock.
	var p=fresh(3);p.elapsed=50.0
	var home:Vector2=p.sirens[0].home
	store(p,[Findings.make("post_0","post","S1 SENTINEL · holds its post",0.6,3,1,{"pos":Findings.pt(home),"r":190.0})])
	check(PostClock.entries(p).is_empty(),"no post clock without a sighting")
	contact(p,0,home+Vector2(400,0),"INVESTIGATE")
	var pe=PostClock.entries(p)
	check(pe.size()==1 and ceili(float(pe[0].back))==9 and PostClock.text(pe[0]).contains("BACK ~9s"),"an alerted sentinel 400 m out is about 9 s from its post (%s)"%(PostClock.text(pe[0]) if pe.size()>0 else "none"))
	contact(p,0,home+Vector2(400,0),"PATROL")
	check(ceili(float(PostClock.entries(p)[0].back))==16,"a sentinel at patrol pace is 16 s away")
	contact(p,0,home+Vector2(100,0))
	check(PostClock.entries(p).is_empty(),"inside its tether it is on post: nothing to show")
	contact(p,0,home+Vector2(400,0),"INVESTIGATE",21.0)
	check(PostClock.entries(p).is_empty(),"out of view for 20 s the clock is gone")
	contact(p,0,home+Vector2(400,0),"INVESTIGATE",12.0)
	check(PostClock.text(PostClock.entries(p)[0]).contains("AGING"),"an old sighting reads AGING")
	# 3 / Window check.
	var w=WindowCheck.evaluate(18.0,30.0,7.0,0.0,9.0)
	check(w.state=="wait" and w.text.contains("OPENS IN 12s") and w.text.contains("you arrive in 9s") and w.text.contains("WAIT 3s"),"opens in 12, arrive in 9: WAIT 3 (%s)"%w.text)
	w=WindowCheck.evaluate(18.0,30.0,7.0,0.0,14.0)
	check(w.state=="go" and w.text.contains("GO"),"arriving 2 s into the window is GO (%s)"%w.text)
	w=WindowCheck.evaluate(18.0,30.0,7.0,0.0,18.5)
	check(w.state=="late" and w.text.contains("TOO LATE"),"arriving as it closes is TOO LATE (%s)"%w.text)
	w=WindowCheck.evaluate(8.0,30.0,7.0,0.0,1.0)
	check(w.state=="late" and w.text.contains("OPENS IN 22s"),"a long wait after a missed window is TOO LATE (%s)"%w.text)
	w=WindowCheck.evaluate(2.0,30.0,7.0,0.0,1.0)
	check(w.state=="go" and w.text.contains("OPEN 5s"),"an open window with time left is GO (%s)"%w.text)
	var c3=fresh(3);var hatch=c3.mission.objectives[2]
	store(c3,[Findings.make("frame_cycle:hatch","cycle","BAY HATCHES · open together 7s of every 30s",0.6,3,1,{"pos":Findings.pt(hatch.pos),"period":30.0,"open":7.0,"phase":0.0})])
	c3.elapsed=18.0;c3.units[0].pos=hatch.pos+Vector2(-300,0);c3.units[0].route=[{"pos":hatch.pos+Vector2(-100,0),"stop":true}]
	var we=WindowCheck.entries(c3)
	check(we.size()==1 and we[0].state=="wait" and we[0].arrive>0.0,"the check uses the selected craft's own route")
	c3.units[0].route=[];c3.units[0].pos=hatch.pos+Vector2(-120,0);c3.units[0].angle=0.0
	check(WindowCheck.camera_line(c3,hatch.pos).contains("you arrive in"),"the camera line carries the window check for the framed subject")
	c3.units[0].alive=false
	check(WindowCheck.entries(c3).is_empty(),"a lost craft plans nothing")
	# 4 / Known lane.
	var l=fresh(0);l.sirens=[]
	var lane:Array=[Vector2(1240,360),Vector2(1180,520),Vector2(900,540),Vector2(760,720)]
	var cell_of=func(v:Vector2):return Vector2i((v/40.0).floor())
	var before:int=l.known.size()
	check(KnownLane.chart_of(l)==null and not l.known.has(cell_of.call(Vector2(1030,530))),"the lane water is uncharted at the start (opening operation: fog, no earned chart)")
	check(KnownLane.apply(l)==0,"with no route finding the lane adds nothing")
	store(l,[Findings.make("spire_wreck:drill","route","LEE CHANNEL",0.6,0,1,{"pts":lane.map(func(v):return Findings.pt(v))})])
	var added=KnownLane.apply(l)
	check(added>0 and l.known.size()==before+added,"a route finding charts a strip of the lane (%d cells)"%added)
	check(l.known.has(cell_of.call(Vector2(1030,530))),"a point on the photographed lane is charted")
	check(KnownLane.apply(l)==0,"certifying twice adds nothing")
	var rocky=0
	for cell in l.known:
		if l.blocked(Vector2(cell)*40.0+Vector2(20,20),0.0):rocky+=1
	check(rocky==0,"no rock is ever charted as water")
	var saved=Sim.new();saved.start(0,"endurance")
	check(saved.restore(l.snapshot()) and saved.known.has(cell_of.call(Vector2(1030,530))),"a saved game restores the lane")
	# Where terrain is earned (Confluence) the lane is certified on the chart.
	var ern=Sim.new();ern.start(11,"endurance")
	var ec=KnownLane.chart_of(ern)
	if ec!=null:
		var lane2:Array=[ern.units[0].pos+Vector2(60,0),ern.units[0].pos+Vector2(260,0)]
		store(ern,[Findings.make("x:route","route","TEST LANE",0.6,11,1,{"pts":lane2.map(func(v):return Findings.pt(v))})])
		var n0=ec.clear_cells.size();var got=KnownLane.apply(ern)
		check(ec.clear_cells.size()==n0+got and ern.mission.terrain_chart.clear_cells.size()==ec.clear_cells.size(),"on an earned chart the lane is certified on the chart and saved with it")
	else:check(true,"(operation 11 has no earned chart in this build)")
	# The real frame: a close, tight photograph of the drill string files the route and the lane.
	var r=fresh(0);r.sirens=[]
	var spire=Vector2(1300,300);var facing=2.74
	r.units[0].pos=spire+Vector2.from_angle(facing)*90;r.units[0].angle=facing+PI;r.units[0].vel=Vector2.ZERO
	r.command("frame",{"mode":"tight","focus":"drill"});r.command("camera");run(r,8)
	var drill=r.mission.get("photo",{}).get("findings",[]).any(func(f):return f.kind=="route")
	check(drill,"a close tight frame of the drill string files the lee channel route")
	check(r.known.has(cell_of.call(Vector2(900,540))),"and the lee channel is charted on the real chart")
	# 5 / The optional deep seam on operation 1.
	var d=fresh(1);d.sirens=[]
	var seam=d.mission.photo_hidden[0]
	check(seam.key=="deep_seam" and seam.subject.bands==[2] and seam.subject.band==2 and not seam.found,"operation 1 authors a hidden seam only DEEP can frame")
	check(d.mission.brief.contains("below the west shelf"),"the brief gives a one-line hint")
	check(d.mission.objectives.size()==3 and d.mission.objectives.all(func(o):return not o.get("unknown",false) or o.has("lead")),"the charted objectives are unchanged")
	check("deep_seam" in Catalog.record_keys(false),"its record key is registered")
	d.units[0].pos=RuleData.POS+Vector2(-150,0);d.units[0].angle=0.0;d.units[0].vel=Vector2.ZERO;d.units[0].band=1
	Photo.discover(d)
	check(seam.found and d.mission.objectives.size()==4 and d.mission.objectives[3].optional,"the forward camera sights it as an optional unknown")
	var o=d.mission.objectives[3]
	d._use_band(1)
	var ctx=d.camera_context()
	check(not ctx.ready and ctx.text.contains("seen only from DEEP"),"from MIDDLE the camera says it is seen only from DEEP (%s)"%ctx.text)
	check(not d.command("camera"),"and refuses the exposure")
	d.units[0].band=2;d._use_band(2)
	d.units[0].pos=RuleData.POS+Vector2(0,80);d.units[0].angle=-PI/2
	ctx=d.camera_context()
	check(ctx.ready and ctx.text.contains("DEEP:"),"from DEEP it is ready, with the band price")
	var ox:float=d.oxygen
	d.command("camera");run(d,7)
	check(o.captured and d.oxygen<ox-0.075*3.0,"the seam is photographed from DEEP at the deep exposure cost")
	check(d.mission.photo.findings.any(func(f):return str(f.id).begins_with("deep_seam")),"it files its finding")
	check(Photo.peek(d).shots[0].band==2,"and the shot records DEEP")
	# 6 / A bare Quietus can finish operation 1 without the seam: it is optional.
	var bare=fresh(1);bare.sirens=[]
	for obj in bare.mission.objectives:obj.captured=true
	check(bare.all_records(),"the seam does not gate completion")
	print("PHOTO RULES CHECKS ",checks," FAILURES ",failures)
	quit()
