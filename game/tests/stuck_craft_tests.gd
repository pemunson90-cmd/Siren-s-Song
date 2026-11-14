extends SceneTree
# WP-85 (critic 14 Nov): a craft that is not getting anywhere says so; the lock card says whether a move lands in
# time; the strip's message does not go stale. Logic only: the screens are in stuck_craft_ui_tests.gd.
const TrialRules=preload("res://src/trial_rules.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Aids=preload("res://src/presentation/accessibility/tactical_aids.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Store=preload("res://src/persistence/settings_store.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
const NoProgress=preload("res://src/presentation/no_progress.gd")
const StripMessage=preload("res://src/presentation/strip_message.gd")
const MoveTiming=preload("res://src/presentation/lock_move_timing.gd")
const ThreatRead=preload("res://src/presentation/threat_read/threat_read.gd")
class Host extends RefCounted:
	var sim=Sim.new()
	var screen="mission"
	var debug_console=null
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
	var saved=Settings.current.duplicate()
	Settings.apply(Store.sanitize({}))
	TrialRules.reset()
	current_case()
	band_case()
	nothing_case()
	strip_case()
	move_case()
	TrialRules.reset()
	Settings.current=saved
	print("STUCK CRAFT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
# Operation 02 in open water with the drones away, the aids bound, time running.
func fixture():
	var host=Host.new();host.sim.start(1);PlayerDive.launch_drones(host.sim)
	host.sim.sirens=[]
	var aid=Aids.new();aid.bind(host)
	host.sim.paused=false
	return [host,aid]
# One 0.1 s step of dive time, then the aids look, as the game does between frames.
func step(pair,seconds:float)->void:
	for n in roundi(seconds*10.0):
		pair[0].sim.advance(0.1);pair[1].observe()
		if pair[0].sim.paused:return
func order(sim,point:Vector2,queue:bool=false)->bool:
	var was=sim.paused;sim.paused=true
	var ok:bool=sim.command("select",{"unit":0})
	sim.queue_mode=queue
	ok=ok and sim.command("route",{"point":point})
	sim.queue_mode=false;sim.paused=was;return ok
# 1. A route in open water, a current as strong as the drive pushing back: no rock, no edge hold, no motion.
func current_case():
	var pair=fixture();var host=pair[0];var aid=pair[1];var sim=host.sim;var q=sim.units[0]
	q.silent=false
	var drive:float=sim._craft_speed(q,78.0)
	sim.mission["currents"]=[{"center":q.pos,"radius":100000.0,"velocity":Vector2(-drive*1.1,0.0)}]
	check(order(sim,q.pos+Vector2(400,0)),"the route east is accepted")
	step(pair,30.0)
	check(not q.has("edge_hold"),"the pinned craft never sets a rock hold (so the old rule 5 could not see it)")
	check(sim.paused,"rule 5 on: a craft with a route and no progress pauses the dive within 30 s (ran "+str(snappedf(sim.elapsed,0.1))+" s)")
	check(sim.elapsed<15.0,"the pause comes within a few seconds of the stall: "+str(snappedf(sim.elapsed,0.1)))
	check(aid.auto_pause.line(sim)=="PAUSED: the current holds QUIETUS back","the reason line names the current: "+aid.auto_pause.line(sim))
	check(sim.message=="QUIETUS · no progress · the current is stronger than its drive · replot or wait","the strip message says why: "+sim.message)
	sim.paused=false;aid.auto_pause.clear();step(pair,10.0)
	check(not sim.paused,"resuming does not pause again for the same stall")
	# The player gives a new order that works (the current is gone): the craft moves, the hold ends, a later stall pauses again.
	sim.mission["currents"]=[]
	order(sim,q.pos+Vector2(300,0));step(pair,3.0)
	check(not sim.paused and q.vel.length()>5.0,"with the current gone the craft moves and nothing pauses")
	sim.mission["currents"]=[{"center":q.pos,"radius":100000.0,"velocity":Vector2(-drive*1.1,0.0)}]
	step(pair,30.0)
	check(sim.paused,"a second stall, after the craft moved, pauses again")
	# Rule 5 off: nothing pauses.
	TrialRules.override("PAUSE_WHEN_BLOCKED",false)
	var off=fixture();var o=off[0].sim;var oq=o.units[0];oq.silent=false
	o.mission["currents"]=[{"center":oq.pos,"radius":100000.0,"velocity":Vector2(-drive*1.1,0.0)}]
	order(o,oq.pos+Vector2(400,0));step(off,30.0)
	check(not o.paused,"rule 5 off: the pinned craft does not pause the dive (the behaviour before WP-85)")
	TrialRules.reset()
# 2. A leg that runs into rock at the craft's depth while another depth is open: the pause names that depth.
func band_case():
	var candidates:Array=find_band_legs(fixture()[0].sim)
	check(not candidates.is_empty(),"operation 02 has legs shut at MIDDLE and open at another depth (the test needs one)")
	var tried:=0
	for found in candidates:
		tried+=1
		var pair=fixture();var sim=pair[0].sim;var q=sim.units[0];var aid=pair[1]
		q.pos=found.from
		if not order(sim,found.point):continue
		step(pair,40.0)
		if not q.has("edge_hold"):continue
		check(sim.paused,"the craft grinds to a rock hold on the shut leg and the dive pauses")
		check(aid.auto_pause.line(sim)=="PAUSED: rock blocks QUIETUS's route at this depth · %s is open"%sim.Depth.NAMES[found.band],"the pause line names the open depth: "+aid.auto_pause.line(sim))
		check(sim.message=="QUIETUS · rock blocks this leg at this depth · %s is open · replot or change depth"%sim.Depth.NAMES[found.band],"the strip message says it in plain words: "+sim.message)
		check(q.band==1,"reading the other depths did not change the craft's depth")
		return
	check(false,"one of %d candidate legs held the craft against rock"%tried)
# Start and end points 240 m apart, both in open water at every depth, whose straight leg is shut at MIDDLE and clear
# at DEEP or SHALLOW. Sixteen of them, spread over the chart.
func find_band_legs(sim)->Array:
	var size:Vector2=sim.world_size();var found:=[]
	for x in range(100,int(size.x)-100,40):
		for y in range(100,int(size.y)-100,40):
			var from:=Vector2(x,y)
			for d in 16:
				var to:Vector2=from+Vector2.from_angle(TAU*d/16.0)*240.0
				if to.x<60 or to.y<60 or to.x>size.x-60 or to.y>size.y-60:continue
				if not _open_at(sim,1,from) or not _open_at(sim,1,to) or not _leg_shut(sim,1,from,to):continue
				for band in [0,2]:
					if _open_at(sim,band,from) and _open_at(sim,band,to) and _leg_clear(sim,band,from,to):
						found.append({"from":from,"point":to,"band":band});break
	sim._use_band(1)
	var picked:=[]
	for i in range(0,found.size(),maxi(1,found.size()/16)):picked.append(found[i])
	return picked
func _open_at(sim,band:int,point:Vector2)->bool:
	sim._use_band(band);return not sim.blocked(point,16)
# At this depth a long stretch of the leg lies in rock (a ridge, not a corner the craft could slide round).
func _leg_shut(sim,band:int,a:Vector2,b:Vector2)->bool:
	sim._use_band(band)
	var inside:=0
	for n in 41:
		if sim.blocked(a.lerp(b,n/40.0),6):inside+=1
	return inside>=14
func _leg_clear(sim,band:int,a:Vector2,b:Vector2)->bool:
	sim._use_band(band)
	for n in 41:
		if sim.blocked(a.lerp(b,n/40.0),16):return false
	return true
# 3. Nothing that is meant to stand still counts as stuck: held in the current that stalls it, or stopped with a route.
func pinned()->Array:
	var pair=fixture();var sim=pair[0].sim;var q=sim.units[0]
	q.silent=false
	var drive:float=sim._craft_speed(q,78.0)
	sim.mission["currents"]=[{"center":q.pos,"radius":100000.0,"velocity":Vector2(-drive*1.1,0.0)}]
	order(sim,q.pos+Vector2(400,0))
	return pair
func nothing_case():
	var pair=fixture();var sim=pair[0].sim
	step(pair,12.0)
	check(not sim.paused,"a craft with no route never pauses")
	pair=pinned();sim=pair[0].sim;sim.units[0].hold="HOLD"
	step(pair,12.0)
	check(not sim.paused,"a craft the player holds (HOLD) does not count as stuck")
	pair=fixture();sim=pair[0].sim;order(sim,sim.units[0].pos+Vector2(400,0));sim.command("all_stop")
	step(pair,12.0)
	check(not sim.paused,"a craft at ALL STOP does not count as stuck: "+sim.message)
# 4. The strip's message.
func strip_case():
	var pair=fixture();var sim=pair[0].sim;var q=sim.units[0]
	var strip=StripMessage.new()
	q.silent=false
	order(sim,q.pos+Vector2(400,0));order(sim,q.pos+Vector2(900,0),true)
	check(sim.message.ends_with("queued route"),"the second point is queued: "+sim.message)
	var first:String=strip.current(sim)
	check(first==sim.message,"a new message is shown whole: "+first)
	var seen:=[]
	for n in 100:
		sim.advance(0.1);var text:String=strip.current(sim)
		if sim.elapsed<Words.MESSAGE_FRESH_SECONDS-0.2:check(text==sim.message,"the newest message stays whole while it is new at "+str(snappedf(sim.elapsed,0.1))+": "+text)
		elif sim.elapsed>Words.MESSAGE_FRESH_SECONDS+0.2 and (seen.is_empty() or seen.back()!=text):seen.append(text)
		if q.route.is_empty():break
	check(seen.size()>=2 and seen.all(func(t):return t.begins_with("QUIETUS · under way to point ")),"once under way the strip says what the craft is doing: "+str(seen))
	check(seen.any(func(t):return t.begins_with("QUIETUS · under way to point 2 · ")),"it counts the points: "+str(seen))
	check(not seen.any(func(t):return "set route" in t or "queued route" in t),"the old route message is gone: "+str(seen))
	# A newer message is shown whole at once, whatever the craft is doing.
	sim.message="Decoy launched · 15s transmission"
	check(strip.current(sim)==sim.message,"a newer message replaces the status at once")
	# At rest with a route message that no longer says anything true.
	var rest=fixture();var s2=rest[0].sim;var q2=s2.units[0];var strip2=StripMessage.new()
	order(s2,q2.pos+Vector2(60,0));strip2.current(s2)
	for n in 120:
		s2.advance(0.1);strip2.current(s2)
	check(q2.route.is_empty() and q2.vel.length()<2.0,"the short route finished")
	check(strip2.current(s2)=="QUIETUS · at rest · no route set","the finished route no longer reads set route: "+strip2.current(s2))
	s2.message="Hull strike against terrain · 12m/s · hull -4%"
	strip2.current(s2)
	for n in 60:
		s2.advance(0.1)
	check(strip2.current(s2)==s2.message,"a message that is not about a route stays until a newer one comes")
# 5. The lock card's moves.
func move_case():
	var pair=fixture();var sim=pair[0].sim
	sim.elapsed=10.;sim.mission.structures=[];sim.mission.depth_geometry={}
	sim.sirens=[]
	var near:Vector2=sim.units[1].pos+Vector2(60,0)
	sim.contacts={0:{"pos":near,"time":10.,"mode":"LOCKING","lock":.1,"target":1,"band":sim.units[1].band}}
	var rows=ThreatRead.lock_rows(sim)
	check(rows.size()==1 and not rows[0].moves.is_empty(),"a lock on a drone offers moves")
	if rows.is_empty():return
	var row=rows[0]
	for move in row.moves:
		var read=MoveTiming.read(sim,row,move)
		check(read.line!="" and read.has("in_time"),"every move has a timing line: "+str(move.order)+" "+read.line)
		match str(move.order):
			"decoy":check(not read.in_time and read.line==Words.TEXT.move_decoy,"a decoy cannot end a lock that has started: "+read.line)
			"silent":check(not read.in_time and read.line==Words.TEXT.move_close%roundi(180.0*sim.HuntPressure.scale(sim.mission)),"a Siren 60 m away still sees a silent craft: "+read.line)
			"emp":check(read.in_time and read.line==Words.TEXT.move_now,"the EMP works at once: "+read.line)
	check(row.moves.any(func(m):return m.order=="decoy"),"the decoy is on the card with its mark")
	sim.contacts[0].pos=sim.units[1].pos+Vector2(260,0)
	row=ThreatRead.lock_rows(sim)[0]
	for move in row.moves:
		if str(move.order)=="silent":
			var read=MoveTiming.read(sim,row,move)
			check(read.in_time and read.line==Words.TEXT.move_now,"a Siren beyond silent sight loses the craft at once: "+read.line)
	# The silent and EMP moves take effect on the step they are ordered (weapon_orders.gd, the silent order).
	check(float(MoveTiming.DELAY.silent)==0.0 and float(MoveTiming.DELAY.emp)==0.0,"the silent and EMP moves take effect at once")
