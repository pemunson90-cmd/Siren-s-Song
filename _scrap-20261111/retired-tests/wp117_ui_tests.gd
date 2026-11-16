extends SceneTree
# WP-117 (blind critic B, round 9, cover screen 1680x720 at up to 150% text):
# 1. the scroll cue shows only when more than a line really runs on below, never on the title or Game Modes, sits in the
#    margin under the body (never over a line of text) and is gone at the end of the text;
# 2. every leg the dive chart draws red (HandPilot.warnings) is a red leg with its mark on the ROUTE PROGRAM screen, on every operation;
# 3. mid-dive SUPPLIES reads a lost drone as lost, not "CONDITION 100%";
# 4. the rock card's sentence matches its buttons, and the status strip does not repeat it;
# 5. the title's drifting craft never passes behind a menu button.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
const Preview=preload("res://src/presentation/route_program_preview.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Economy=preload("res://src/presentation/economy_panel.gd")
const SHAPES=[Vector2i(1680,720),Vector2i(1280,1153)]
const SCALES=[1.0,1.3,1.5]
var checks=0
var failures=0
var overflowed=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 7:await process_frame
func make(shape:Vector2i,scale:float,dive:bool=false):
	root.size=shape;await settle()
	Settings.current["text_scale"]=scale
	var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"))
	g.store.path="user://wp117-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	root.add_child(g);await settle();g.set_process(false)
	if dive:
		g._start_mission(0);await settle();g._layout();await settle()
		g.sim.sirens=[]
		if g.mission_hud.hints.panel.visible:g.mission_hud.hints.dismiss()
	return g
func gone(g):
	var path:String=g.store.path
	g.queue_free();await settle()
	for suffix in ["",".bak",".tmp",".settings"]:DirAccess.remove_absolute(path+suffix)
# 1 and 5: front-end screens and the briefing.
func menu_case(shape:Vector2i,scale:float):
	var tag="%s %d%%"%[str(shape),roundi(scale*100.)]
	var g=await make(shape,scale)
	var front=g.get_node_or_null("Frontend")
	check(front!=null,"%s: the front end is up"%tag)
	var cue=g.get_node_or_null("ScrollCue")
	check(cue!=null,"%s: the cue exists"%tag)
	if front!=null and cue!=null:
		for screen in ["title","modes","settings"]:
			match screen:
				"title":front._title_screen()
				"modes":front._mode_select()
				"settings":front._settings_screen()
			await settle()
			check(not cue.more_below() and not cue.visible,"%s: %s shows no MORE BELOW cue (nothing is below)"%[tag,screen])
			await craft_case(front,"%s %s"%[tag,screen])
		front._title_screen();await settle()
	# A long briefing shows the cue until the end of the text, in the margin below the body.
	g.unlocked=5;g._briefing(3);await settle();g._briefing(3);await settle()
	if cue!=null:
		check(cue.hidden_below()>=0.0,"%s: the briefing reports how far text runs on"%tag)
		if cue.more_below():
			overflowed+=1
			check(cue.visible,"%s: the long briefing shows the cue (%.0f px below, line %d)"%[tag,cue.hidden_below(),cue.font_px()])
			check(not g.scroll.get_global_rect().grow(-1.0).intersects(cue.get_global_rect()),"%s: the cue covers no line of the body: cue %s body %s"%[tag,str(cue.get_global_rect()),str(g.scroll.get_global_rect())])
			g.scroll.scroll_vertical=int(g.scroll.get_v_scroll_bar().max_value);await settle()
			check(not cue.visible and not cue.more_below(),"%s: the cue is gone at the end of the text"%tag)
		else:
			check(not cue.visible,"%s: a briefing that fits shows no cue"%tag)
	await gone(g)
# 5: sample the craft's whole loop; wherever it would sit over a visible menu control it is invisible.
func craft_case(front,tag):
	var bd=front.title_backdrop
	var rects=[]
	for b in front.column.find_children("*","Button",true,false):
		if b.is_visible_in_tree():rects.append(b.get_global_rect())
	for s in front.column.find_children("*","HSlider",true,false):
		if s.is_visible_in_tree():rects.append(s.get_global_rect())
	check(not rects.is_empty(),"%s: the menu has controls to keep clear"%tag)
	var span:float=(bd.size.x+400.*bd.unit)/(bd.DRIFT_SPEED*bd.unit)
	var bad=0;var seen=0
	var t=0.0
	while t<span:
		var at:Vector2=bd.craft_position(t)+bd.global_position
		var box:=Rect2(at-Vector2(120,30)*bd.unit,Vector2(240,60)*bd.unit)
		for r in rects:
			if box.intersects(r) and bd.craft_alpha(bd.craft_position(t))>0.01:bad+=1
		if bd.craft_alpha(bd.craft_position(t))>0.5:seen+=1
		t+=2.0
	check(bad==0,"%s: the craft is never drawn behind a menu control (%d samples)"%[tag,bad])
	check(seen>0,"%s: the craft still shows in open water (%d samples)"%[tag,seen])
# 2: the route program draws every red leg of the dive chart, on every operation.
func route_case():
	var ids=Catalog.registered_ids();var legs_checked=0;var with_rock=0
	for id in ids:
		var s=Sim.new();s.start(id);s.paused=true
		var corridors=s.extraction_corridors()
		if corridors.is_empty() or not HandPilot.release(s):continue
		var rec:Vector2=corridors[0].pos
		var found:Variant=null
		for x in range(120,int(s.world_size().x)-100,140):
			for y in range(120,int(s.world_size().y)-100,140):
				var p:=Vector2(x,y)
				if p.distance_to(rec)>300.0 and not HandPilot.rock_at(s,p) and HandPilot.rock_point(s,p,rec)!=null:found=p;break
			if found!=null:break
		if found==null:continue
		s.units[0].pos=found
		if not s.command("route",{"point":rec}):continue
		var pv=Preview.new();pv.sim=s
		var warned=HandPilot.warnings(s,0).filter(func(w):return w.reason==HandPilot.ROCK_REASON)
		var legs=pv.rock_legs()
		with_rock+=1;legs_checked+=legs.size()
		check(not warned.is_empty() and legs.size()==warned.size(),"operation %d: the programme draws %d red leg(s), the dive chart %d"%[id+1,legs.size(),warned.size()])
		for n in mini(legs.size(),warned.size()):
			check(legs[n][0]==warned[n].from and legs[n][1]==warned[n].to and pv.rock_marks()[n]==warned[n].at,"operation %d: red leg %d runs where the dive chart's does, marked at the rock"%[id+1,n+1])
		pv.free()
	check(with_rock>=3,"several operations have a Quietus-to-RECOVERY leg across rock to test (%d)"%with_rock)
	# Operation 01, whose rock is authored: a leg across it is red, a clear leg is not.
	var s=Sim.new();s.start(0);s.paused=true
	var rec:Vector2=s.extraction_corridors()[0].pos
	var pv=Preview.new();pv.sim=s
	s.units[0].pos=Vector2(1180,860)
	check(s.command("route",{"point":rec}),"operation 01: a route to RECOVERY is accepted")
	var crossing=HandPilot.rock_point(s,s.units[0].pos,rec)!=null
	check(pv.rock_legs().size()==(1 if crossing else 0),"operation 01: the leg is red exactly when the dive chart's is (crossing %s)"%str(crossing))
	var open_start:Vector2=rec+Vector2(300,0)
	s.command("order_undo",{"goals":[],"hold":""});s.units[0].pos=open_start;s.command("route",{"point":rec})
	check(HandPilot.rock_point(s,open_start,rec)==null and pv.rock_legs().is_empty(),"operation 01: an open leg draws no red")
	pv.free()
# 3: mid-dive SUPPLIES.
func supplies_case():
	var g=await make(Vector2i(1680,720),1.5,true)
	g.sim.units[1].alive=false
	Economy.show(g);await settle()
	var text=" | ".join(g.panel_box.find_children("*","Label",true,false).map(func(l):return l.text))
	check(text.contains("DRONE A · LOST THIS DIVE"),"mid-dive SUPPLIES reads drone A as lost: "+text.substr(0,400))
	check(not text.contains("DRONE A · CONDITION"),"mid-dive SUPPLIES no longer gives a lost drone a condition")
	check(text.contains("DRONE B") ,"the surviving drone is still listed")
	await gone(g)
# 4: the card and the strip.
func card_case():
	var g=await make(Vector2i(1680,720),1.5,true)
	var s=g.sim;var guard=g.mission_hud.guard
	s.paused=true;s.selected=0;g._refresh()
	var found:Variant=null
	var from:Vector2=s.units[0].pos
	for distance in [160.0,240.0,320.0,420.0,540.0,700.0,900.0]:
		for i in 32:
			var p:Vector2=from+Vector2.from_angle(TAU*i/32.0)*distance
			if Rect2(Vector2.ONE*24,s.world_size()-Vector2.ONE*48).has_point(p) and not HandPilot.rock_at(s,p) and HandPilot.crosses_rock(s,from,p):found=p;break
		if found!=null:break
	check(found!=null,"the opening chart has a water point behind rock")
	if found!=null:
		guard.tap_water(found);await settle()
		check(guard.panel.visible,"the rock bar is up")
		# WP-127: the card is a slim bar; its one sentence names the rock and its buttons are SEND ANYWAY and CANCEL.
		check(guard.go_button.text==Words.TEXT.send_anyway and guard.cancel_button.text=="CANCEL" and guard.prompt.text==Words.TEXT.rock_bar,"the bar says SEND ANYWAY and CANCEL: %s / %s"%[guard.go_button.text,guard.prompt.text])
		check(s.message!=guard.prompt.text and s.message==Words.TEXT.rock_strip,"the status strip does not repeat the bar's sentence: "+s.message)
	await gone(g)
func run():
	route_case()
	for shape in SHAPES:
		for scale in SCALES:await menu_case(shape,scale)
	check(overflowed>0,"at least one long briefing scrolled, so the cue was exercised (%d)"%overflowed)
	await supplies_case()
	await card_case()
	print("WP117 UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
