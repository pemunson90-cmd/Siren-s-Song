extends SceneTree
# THREAT READ (WP-08) without a display: the shutter reach equals the camera
# panel's figure by band, the lock countdown equals the simulation's remaining
# lock time, a drone loss names its cause and bearing without revealing an
# unearned role, the optional pause aid pauses once per loss, and with the
# module switched off the readouts, message and pause are as before.
const Sim=preload("res://src/simulation/simulation.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
const Store=preload("res://src/persistence/settings_store.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Aids=preload("res://src/presentation/accessibility/tactical_aids.gd")
const TR=preload("res://src/presentation/threat_read/threat_read.gd")
const TT=preload("res://src/presentation/threat_read/threat_read_table.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const PT=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const Warning=preload("res://src/presentation/lock_warning.gd")
const Identity=preload("res://src/simulation/contact_identity.gd")
class Host extends RefCounted:
	var sim
	var screen="mission"
	var debug_console=null
class View extends RefCounted:
	var instrument_top=64.0
	var size=Vector2(1280,720)
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")

func photo_fixture(band:int):
	var s=Sim.new();s.start(0);s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
	var spire=Vector2(1300,300);var facing=2.74
	var q=s.units[0];q.pos=spire+Vector2.from_angle(facing+PI)*150;q.angle=facing;q.vel=Vector2.ZERO;q.band=band;q.transition={}
	s._use_band(band)
	return s
# The combat_rules_tests beam fixture: one Siren east of drone A, Quietus far away.
func beam_fixture():
	var s=Sim.new();s.start(2);s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
	s.units[0].pos=Vector2(400,2000);PlayerDive.launch_drones(s);s.units[1].pos=Vector2(900,840);s.units[2].alive=false
	s.sirens=[s.sirens[0]];var e=s.sirens[0]
	e.pos=Vector2(1060,840);e.home=e.pos;e.goal=e.pos;e.route=[];e.stun=0.;e.lock=0.;e.target=-1
	# A calm Siren ignores a drone in its sight (Pat, 2026-11-12). The drone-loss cases are a Siren already searching.
	e.mode="SEARCH"
	s.contacts={};s.known={};s.paused=false
	return s
func host_for(s):
	var h=Host.new();h.sim=s;return h

func run():
	# This suite tests the craft-loss pause aid alone; trial rules 4 and 5 (trial_rules.gd) are covered by trial_rules_tests.
	preload("res://src/trial_rules.gd").override("PAUSE_ON_EVERY_LOCK",false);preload("res://src/trial_rules.gd").override("PAUSE_WHEN_BLOCKED",false)
	Settings.apply(Store.sanitize({}))
	shutter_checks()
	lock_checks()
	loss_checks()
	pause_checks()
	settings_checks()
	chip_checks()
	threat_line_checks()
	disabled_checks()
	TR.reset();Settings.apply(Store.sanitize({}))
	print("THREAT READ CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)

func shutter_checks():
	var radii=[]
	for band in [1,0,2]:
		var s=photo_fixture(band)
		var reach=TR.shutter_reach(s)
		var view=s.Photo.preview(s,0)
		check(not reach.is_empty() and not view.is_empty(),"band %d: framing a photograph gives a shutter reach"%band)
		if reach.is_empty() or view.is_empty():continue
		var panel=Pricing.readout(s,0,view.o)
		var line=str(panel.lines.back().text)
		check(is_equal_approx(float(reach.radius),float(panel.heard)),"band %d: chart radius equals the panel's shutter figure"%band)
		check(line.begins_with(PT.TEXT.heard%roundi(reach.radius)),"band %d: the panel line prints the same metres (%s)"%[band,line])
		check(reach.label==TT.TEXT.shutter%roundi(panel.heard) and reach.craft==s.units[0].pos,"band %d: label and centre come from the same readout"%band)
		radii.append(roundi(reach.radius))
	check(radii==[520,676,416],"shutter reach follows the depth band, not a fixed 520 m: %s"%str(radii))
	# Known contacts inside the panel's reach are named; others are not.
	var s=photo_fixture(1);var q=s.units[0].pos
	s.contacts={0:{"pos":q+Vector2(300,0),"time":s.elapsed,"mode":"PATROL","lock":0.,"target":-1,"type":"patroller","band":1},
		1:{"pos":q+Vector2(900,0),"time":s.elapsed,"mode":"PATROL","lock":0.,"target":-1,"type":"patroller","band":1},
		2:{"pos":q+Vector2(200,0),"time":s.elapsed-25.,"mode":"PATROL","lock":0.,"target":-1,"type":"patroller","band":1}}
	var reach=TR.shutter_reach(s)
	check(reach.get("inside",[])==[0],"only fresh known contacts inside the shutter reach are named")
	# No photograph framed: no ring.
	s.units[0].pos=Vector2(200,800)
	check(TR.shutter_reach(s).is_empty(),"no shutter reach is drawn without a framed photograph")

func lock_checks():
	var s=beam_fixture()
	for n in 90:s.advance(Sim.STEP)
	var rows=TR.lock_rows(s)
	var e=s.sirens[0]
	check(s.units[1].alive and e.lock>0.5 and e.lock<4.0,"drone A is under a building lock (lock %.2f)"%e.lock)
	var row={}
	for r in rows:
		if r.craft==1:row=r
	check(not row.is_empty(),"a received lock on a drone gets a countdown beside that drone")
	if not row.is_empty():
		var c=s.contacts[row.source]
		# The received contact carries the lock the simulation published at its last sensor pass (0.15 s).
		check(is_equal_approx(float(row.remaining),4.0-float(c.lock)) and absf(float(row.remaining)-(4.0-e.lock))<=0.15+Sim.STEP,"drone countdown equals the simulation's published remaining lock time")
		check(row.text==TT.TEXT.lock_one%[row.source+1,4.0-float(c.lock)],"drone countdown text: %s"%row.text)
	# Quietus: same number as the existing lock card.
	s=beam_fixture();s.units[1].alive=false;s.units[0].pos=Vector2(900,840)
	for n in 90:s.advance(Sim.STEP)
	var frames=Warning.frames(s);rows=TR.lock_rows(s)
	check(frames.size()==1 and rows.size()==1 and rows[0].craft==0,"a Quietus lock gets one chip and one lock card")
	if frames.size()==1 and rows.size()==1:
		check(is_equal_approx(float(rows[0].remaining),float(frames[0].remaining)),"Quietus chip time equals the lock card's seconds")
		check(rows[0].text==TT.TEXT.lock_one%[int(frames[0].id)+1,frames[0].remaining],"Quietus chip text matches the card format: %s"%rows[0].text)
	# Stale or stunned contacts give no chip.
	for id in s.contacts:s.contacts[id].time=s.elapsed-1.0
	check(TR.lock_rows(s).is_empty(),"a stale received lock gives no countdown")

func loss_checks():
	var s=beam_fixture();TR.reset()
	check(TR.observe(s).is_empty(),"the first observation primes and reports nothing")
	var found=[]
	for n in 60*7:
		s.advance(Sim.STEP)
		found.append_array(TR.observe(s))
		if not s.units[1].alive and not found.is_empty():break
	check(not s.units[1].alive and s.outcome.is_empty(),"the real beam destroys drone A")
	check(found.size()==1 and found[0].unit==1,"one loss row for drone A")
	if found.size()!=1:return
	var row=found[0]
	check(row.siren==0 and absf(float(row.bearing)-90.0)<3.0,"the bearing points from the wreck to the Siren that fired (%.1f)"%row.bearing)
	check(row.text.begins_with("DRONE A LOST · SIREN BEAM FROM 090°"),"the loss line names cause and bearing: %s"%row.text)
	# Independent rule: no held contact -> UNSEEN SIREN; held and identified -> role word; held -> coarse class.
	var true_type=str(s.sirens[0].get("type","patroller"))
	var expected=" · UNSEEN SIREN" if not s.contacts.has(0) else " · S1 "+TT.ROLE_WORDS[true_type if Identity.known(s,0) else Identity.coarse(true_type)]
	check(row.text.ends_with(expected),"the loss line names only the earned identity (%s, expected %s)"%[row.text,expected])
	check(str(s.message).begins_with(row.text+" · ") and str(s.message).ends_with("submarine camera remains available"),"the status message leads with the cause and keeps its advice: %s"%s.message)
	check(TR.loss_rows(s).size()==1,"the loss stays on the chart")
	var card:String=TR.loss_card(s)
	check(card.begins_with("DRONE A LOST
SIREN BEAM FROM 090° · TO THE EAST"),"the loss card names the craft, the cause and the direction in words: "+card)
	check(card.count("
")==1,"with no cost rule known the card has no cost line")
	var view=DrawView.new();view.size=Vector2(1280,720);TR.draw_screen(view,s)
	check(TR.last_draw.card.size.x==minf(1280-32,view.feedback_font_size*3.0*preload("res://src/presentation/ui_style.gd").LOCK_CARD_WIDTH) and TR.last_draw.card.position.y==view.feedback_font_size*3.0+24,"the loss card sits where the lock card sits, at its width")
	var then=s.elapsed
	for n in roundi((TT.LOSS_CARD_SECONDS+0.5)*60):s.advance(Sim.STEP)
	check(TR.loss_card(s)=="" and TR.loss_rows(s).size()==1,"the card gives way after its seconds while the wreck mark stays")
	var at=then
	for n in roundi((TT.LOSS_SECONDS+1.0)*60):s.advance(Sim.STEP)
	TR.observe(s)
	check(TR.loss_rows(s).is_empty() and s.elapsed>at+TT.LOSS_SECONDS,"the loss mark expires after its table time")
	# Identity boundary on the source label.
	s.sirens[0].type="sentinel";s.sonar.erase("identified");s.contacts={}
	check(TR.source_label(s,0)==" · UNSEEN SIREN","no contact and no identification: UNSEEN SIREN with no number")
	s.contacts={0:{"pos":s.sirens[0].pos,"time":s.elapsed,"mode":"PATROL","lock":0.,"target":-1,"type":"sentinel","display_type":"PATROLLER","band":1,"source":"active"}}
	check(TR.source_label(s,0)==" · S1 PATROLLER","an unidentified contact shows only the chart's coarse class")
	Identity.identify(s,0)
	check(TR.source_label(s,0)==" · S1 GUARD","an identified contact shows the readout's role word")
	s.contacts={}
	check(TR.source_label(s,0)==" · UNSEEN SIREN","an identification without a held contact names nothing")
	s.sonar.erase("identified");Identity.seed(s,{"siren_sentinel":{"q":1.0,"op":0}})
	check(Identity.known(s,0) and TR.source_label(s,0)==" · UNSEEN SIREN","a role seeded from earlier intel with no held contact stays UNSEEN SIREN")
	# Battery loss: cause without a bearing.
	s=beam_fixture();s.sirens=[];s.units[2].alive=true;TR.reset();TR.observe(s)
	s.units[2].alive=false;s.units[2].battery=0.0;s.events.append({"type":"loss","pos":s.units[2].pos});s.message="DRONE B battery exhausted. Quietus camera remains available."
	var battery=TR.observe(s)
	check(battery.size()==1 and battery[0].text=="DRONE B LOST · BATTERY EXHAUSTED" and battery[0].bearing<0,"a battery loss names its cause and draws no bearing")
	check(s.message=="DRONE B LOST · BATTERY EXHAUSTED · Quietus camera remains available.","battery message keeps its advice")
	# A first notice pausing in the same step as a loss keeps the loss line first.
	Settings.apply(Store.sanitize({"auto_pause_notice":true}))
	s=beam_fixture();s.sirens=[];s.units[2].alive=true;var aid=Aids.new();aid.bind(host_for(s));TR.reset();aid.observe()
	s.units[2].alive=false;s.units[2].battery=0.0;s.events.append({"type":"loss","pos":s.units[2].pos})
	s.message="DRONE B battery exhausted. Quietus camera remains available.";aid.pending_notice=true;aid.observe()
	check(s.paused and s.message=="AUTO PAUSE: DRONE B LOST · BATTERY EXHAUSTED · Quietus camera remains available. · FIRST NOTICE","a same-step notice keeps the loss cause: %s"%s.message)
	s.paused=false;aid.pending_notice=true;aid.observe()
	check(s.paused and s.message=="AUTO PAUSE: FIRST NOTICE","without a loss the notice aid prints its original text")
	Settings.apply(Store.sanitize({}))
	# A craft removed without a simulation loss event (a launch rule) is not reported.
	s=beam_fixture();s.sirens=[];s.units[2].alive=true;TR.reset();TR.observe(s);s.events.clear();s.units[2].alive=false
	check(TR.observe(s).is_empty(),"a craft removed without a loss event is not reported")
	# A restored dive with a drone already lost never replays it.
	TR.reset();var restored=beam_fixture();restored.units[1].alive=false
	check(TR.observe(restored).is_empty() and TR.observe(restored).is_empty(),"a craft already lost at the first observation is not reported")
	# A rewound clock primes again.
	restored.units[1].alive=true;TR.observe(restored);restored.elapsed-=5.0;restored.units[1].alive=false;restored.events.append({"type":"loss","pos":restored.units[1].pos})
	check(TR.observe(restored).is_empty(),"a rewound clock primes instead of reporting")

func pause_run(on:bool)->Dictionary:
	Settings.apply(Store.sanitize({"auto_pause_loss":on}))
	var s=beam_fixture();var host=host_for(s);var aid=Aids.new();aid.bind(host);TR.reset()
	var pauses=0;var message="";var lost_message=""
	for n in 60*9:
		var was=s.units[1].alive
		aid.advance(Sim.STEP)
		if was and not s.units[1].alive:lost_message=str(s.message)
		if s.paused:
			pauses+=1;message=str(s.message);s.paused=false
		if not s.outcome.is_empty():break
	return {"pauses":pauses,"message":message,"alive":s.units[1].alive,"final":lost_message}
func pause_checks():
	var on=pause_run(true)
	check(not on.alive and on.pauses==1,"with the aid on, the loss pauses once (%d)"%on.pauses)
	check(on.message.begins_with("AUTO PAUSE: DRONE A LOST · SIREN BEAM FROM"),"the pause names the loss: %s"%on.message)
	var off=pause_run(false)
	check(not off.alive and off.pauses==0,"with the aid off, a loss never pauses")
	check(off.final.begins_with("DRONE A LOST · SIREN BEAM FROM"),"the status line names the cause with the aid off: %s"%off.final)
	Settings.apply(Store.sanitize({}))

func settings_checks():
	check(Store.DEFAULTS.get(TT.SETTING,true)==false,"the craft loss pause is off by default")
	check(Store.sanitize({TT.SETTING:true})[TT.SETTING]==true,"the toggle is saved like its neighbours")
	check(Store.sanitize({TT.SETTING:"yes"})[TT.SETTING]==false and Store.sanitize({TT.SETTING:1})[TT.SETTING]==false,"a non-boolean value loads as off")
	check(Store.sanitize({"auto_pause_notice":true,"auto_pause_lock":true}).get(TT.SETTING)==false,"neighbouring aids do not switch it on")

func chip_checks():
	var view=View.new()
	var banner=Rect2(440,90,400,60)
	var anchor=Vector2(640,130)
	var box=TR.chip(view,anchor,"S1 LOCK · 2.0s",18,[banner])
	check(box.size!=Vector2.ZERO and not box.intersects(banner),"a chip never covers the lock card")
	check(Rect2(Vector2(TT.EDGE,view.instrument_top+TT.EDGE),view.size-Vector2(TT.EDGE*2,view.instrument_top+TT.EDGE*2)).encloses(box),"a chip stays inside the chart below the instruments")
	check(TR.chip(view,Vector2(-50,300),"S1 LOCK · 2.0s",18,[]).size==Vector2.ZERO,"a craft off the chart gets no chip")
	check(TR.chip(view,anchor,"S1 LOCK · 2.0s",18,[Rect2(Vector2.ZERO,view.size)]).size==Vector2.ZERO,"a chip with no free room is not drawn")

class DrawView extends RefCounted:
	var presenting_mission=true
	var ui_blocked_rects=[]
	var world_label_rects=[]
	var optical_feed=null
	var feedback_font_size=18
	var instrument_top=64.0
	var size=Vector2(1280,720)
	var offset=Vector2.ZERO
	func screen_position(p:Vector2)->Vector2:return p*0.5+offset
	func contact_readout_rects()->Array:return []
	func own_craft_rects()->Array:return []
	func ship_instrument_rects()->Array:return []
	func draw_line(_a,_b,_c,_w=1.0,_aa=false)->void:pass
	func draw_rect(_r,_c,_f=true,_w=1.0)->void:pass
	func draw_arc(_a,_b,_c,_d,_e,_f,_g=1.0,_h=false)->void:pass
	func draw_string(_f,_p,_t,_al=0,_w=-1,_fs=16,_c=Color.WHITE)->void:pass
	func draw_style_box(_s,_r)->void:pass
	func draw_multiline_string(_f,_p,_t,_al=0,_w=-1,_fs=16,_ml=-1,_c=Color.WHITE)->void:pass

func moves_checks(s):
	# The lock card names the moves the locked craft can make now, from live state.
	var drone=preload("res://src/equipment/tool_racks.gd").UNITS[1]
	s.units[1].silent=false
	if s.mission.has("tool_racks"):
		s.mission.tool_racks[drone]={"decoy":3,"emp":2}
	else:
		s.tools.decoy=3;s.tools.emp=2
	var line=TR.counter_moves(s,1,s.units[1].pos+Vector2(100,0))
	check(line=="Or: GO LOW PROFILE · DECOY ×3 · EMP ×2","a drone that is open, with decoys and EMP in reach, lists all three: "+line)
	s.units[0].silent=false
	check(TR.counter_moves(s,0,s.units[0].pos+Vector2(100,0)).begins_with("Or: GO SILENT"),"Quietus reads GO SILENT while it runs loud")
	check(TR.counter_moves(s,1,s.units[1].pos+Vector2(2000,0)).find("EMP")<0,"an EMP is not offered when the locking Siren is outside its pulse")
	s.units[1].silent=true
	if s.mission.has("tool_racks"):s.mission.tool_racks[drone]={"decoy":0,"emp":0}
	else:s.tools.decoy=0;s.tools.emp=0
	check(TR.counter_moves(s,1,s.units[1].pos+Vector2(100,0))=="","a silent craft with nothing to throw gets no line")
	if s.mission.has("tool_racks"):s.mission.tool_racks[drone]={"decoy":1}
	else:s.tools.decoy=1
	check(TR.counter_moves(s,1,s.units[1].pos+Vector2(100,0))=="Or: DECOY ×1","only the moves that exist are listed")
	s.units[1].silent=false

func threat_line_checks():
	# Compass: one convention, eight points.
	var C=preload("res://src/presentation/compass.gd")
	check(C.point(0.)=="NORTH" and C.point(90.)=="EAST" and C.point(180.)=="SOUTH" and C.point(270.)=="WEST" and C.point(45.)=="NORTH-EAST" and C.point(359.)=="NORTH","compass points follow clockwise-from-north bearings")
	check(C.word(Vector2(1,-1))=="NORTH-EAST" and C.bearing(Vector2(0,100))==180 and C.bearing(Vector2(-100,0))==270,"chart up is north, +x is east, +y is south")
	# A lock on drone A with the Siren east of it: a line while the lock is active, none otherwise.
	var s=beam_fixture()
	for n in 90:s.advance(Sim.STEP)
	var view=DrawView.new()
	TR.draw_screen(view,s)
	check(TR.last_draw.lines==1,"one threat line is drawn while a received lock is active")
	var rows=TR.lock_rows(s)
	var row={}
	for r in rows:
		if r.craft==1:row=r
	check(TR.last_draw.chips.is_empty(),"a lock draws no chip at the craft: the line's countdown and the card state it once")
	check(not row.is_empty() and row.sentence.begins_with("GUARD TO THE EAST") and "locks DRONE A in " in row.sentence and row.sentence.ends_with(" s"),"the card names the Siren's type and the direction that matches the bearing: %s"%str(row.get("sentence")))
	check(not row.is_empty() and row.advice.begins_with(TT.TEXT.lock_exit_drone) and TT.TEXT.lock_exit_drone=="Move it behind rock, or let it go.","a lock on a drone gets the drone's advice")
	check(not row.is_empty() and row.siren_pos==s.contacts[row.source].pos and roundi(row.bearing)==90,"the line and the words use the contact's known position")
	var card=Warning.new();card.update_state(s,true)
	check(card.visible and "GUARD TO THE EAST" in card.card_text and "locks DRONE A in " in card.card_text and TT.TEXT.lock_exit_drone in card.card_text,"the lock card carries the type, direction, craft and way out for a drone")
	card.free()
	moves_checks(s)
	# The Siren is off the chart: the line is cut at the chart edge, not dropped.
	view.size=Vector2(500,720);TR.draw_screen(view,s)
	check(TR.last_draw.lines==1,"a Siren beyond the chart edge still gets a clipped line")
	# No lock, no line.
	for id in s.contacts:s.contacts[id].time=s.elapsed-1.0
	view.size=Vector2(1280,720);TR.draw_screen(view,s)
	check(TR.last_draw.lines==0,"no threat line without a live received lock")
	var idle=Warning.new();idle.update_state(s,true);check(not idle.visible and idle.card_text=="","no card without a lock");idle.free()
	# Loss lines appear only when the simulation recorded the data.
	var Summary=preload("res://src/presentation/loss_summary.gd")
	var lost=FakeLoss.new()
	lost.contacts={0:{"pos":Vector2(0,123),"time":5.0,"target":0,"mode":"BEAM"}}
	check(Summary.line(lost)=="A Siren's beam from the south struck Quietus, about 120 m away.","a recorded contact gives direction and rounded range: "+Summary.line(lost))
	lost.contacts={}
	var bare=Summary.line(lost)
	check(bare=="A Siren beam hit Quietus before it could break contact." and not ("to the" in bare),"no recorded contact: the cause only, no invented direction")

class FakeLoss extends RefCounted:
	var outcome="lost"
	var message="VAPORIZED · Siren beam struck Quietus."
	var contacts:Dictionary={}
	var units:Array=[{"pos":Vector2.ZERO}]
	var elapsed=5.0
	var oxygen=80.0
	var hull=100.0

func disabled_checks():
	TT.enabled=false
	check(TR.shutter_reach(photo_fixture(1)).is_empty(),"disabled: no shutter reach")
	var s=beam_fixture()
	for n in 90:s.advance(Sim.STEP)
	check(TR.lock_rows(s).is_empty(),"disabled: no lock chips")
	check(not TR.pause_wanted(),"disabled: the pause aid is never wanted")
	Settings.apply(Store.sanitize({"auto_pause_loss":true}))
	var host=host_for(s);var aid=Aids.new();aid.bind(host);TR.reset()
	var paused=false
	for n in 60*7:
		aid.advance(Sim.STEP)
		if s.paused:paused=true;s.paused=false
		if not s.units[1].alive:break
	check(not s.units[1].alive and not paused,"disabled: a loss never pauses even with the setting on")
	check(str(s.message)=="DRONE A lost · submarine camera remains available","disabled: the simulation's loss message is unchanged")
	check(TR.loss_rows(s).is_empty(),"disabled: no loss mark")
	TT.enabled=true;Settings.apply(Store.sanitize({}))
