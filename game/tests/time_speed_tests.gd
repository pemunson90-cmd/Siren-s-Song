extends SceneTree
# WP-120 (Pat, 14 Nov: "question one should be 2X and 4x, especially for testing"): the dive's time speed control,
# the debug panel's buttons and the console commands behind them. Real main scene, real HUD layout.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const TimeSpeed=preload("res://src/time_speed.gd")
const TrialRules=preload("res://src/trial_rules.gd")
const Console=preload("res://src/debug/debug_console.gd")
const DevState=preload("res://src/debug/dev_state.gd")
const DiveClock=preload("res://src/dive_clock.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func make(shape:Vector2i,scale:float):
	root.size=shape;await settle()
	Settings.current["text_scale"]=scale
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp120-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game._start_mission(0);await settle();game._layout();await settle()
	game.sim.sirens=[];game.sim.contacts.clear()
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	return game
# A received contact with every field the chart draws (simulation.gd contacts[i]); age is seconds since it was seen.
func contact(sim,mode:String,age:float=0.0,recipient:bool=false)->Dictionary:
	var c={"pos":sim.units[0].pos+Vector2(200,0),"time":sim.elapsed-age,"mode":mode,"lock":1.0 if mode in ["LOCKING","BEAM"] else 0.0,"angle":0.0,"target":0 if mode in ["LOCKING","BEAM"] else -1,"type":"patroller","band":sim.units[0].band,"transition":{},"source":"optical","confidence":1.0}
	if recipient:c["recipient_target"]=true
	return c
func run():
	var saved=Settings.current.duplicate()
	rules_case()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			await layout_case(shape,scale)
	await cycle_case()
	await hunting_case()
	await scaling_case()
	await panel_case()
	await release_case()
	Settings.current=saved
	print("TIME SPEED CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func rules_case():
	check(TrialRules.time_speeds()==[1.0,2.0,4.0],"the speeds are 1x, 2x, 4x")
	check(TimeSpeed.next(1.0)==2.0 and TimeSpeed.next(2.0)==4.0 and TimeSpeed.next(4.0)==1.0,"cycle 1 -> 2 -> 4 -> 1")
	check(TimeSpeed.next(8.0)==1.0,"a developer's speed returns to 1x on a tap")
	check(Words.speed_text(2.0,false)=="SPEED\n2x" and Words.speed_text(1.0,true)=="1x · a Siren is hunting","the words come from hud_words")
func layout_case(shape:Vector2i,scale:float):
	var stamp="%dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
	var game=await make(shape,scale)
	var pause:Button=game.pause_button;var speed:Button=game.speed_button
	game._refresh();await settle()
	for hunted in [false,true]:
		game.sim.contacts.clear()
		if hunted:game.sim.contacts[0]=contact(game.sim,"SEARCH")
		game._refresh();await settle()
		var rect:=speed.get_global_rect()
		var room:float=speed.size.x-speed.get_theme_stylebox("normal").get_minimum_size().x
		for word in speed.text.replace("\n"," ").split(" ",false):
			check(speed.get_theme_font("font").get_string_size(word,HORIZONTAL_ALIGNMENT_LEFT,-1,speed.get_theme_font_size("font_size")).x<=room+.5,"the speed word '"+word+"' is not broken "+stamp)
		check(speed.is_visible_in_tree(),"the speed control shows "+stamp)
		check(rect.size.y>=game.ui_touch_height-.5 and rect.size.x>=game.ui_touch_height-.5,"the speed control is at least a touch target "+stamp+" "+str(rect.size))
		check(not rect.intersects(pause.get_global_rect()),"the speed control does not cover the pause plate "+stamp)
		check(rect.position.y==pause.get_global_rect().position.y and rect.size.y>=pause.get_global_rect().size.y-.5,"the speed control sits level with the plate "+stamp)
		check(rect.position.x>=-.5 and rect.end.x<=game.size.x+.5,"the speed control is on screen "+stamp)
		var size=speed.get_theme_font_size("font_size")
		var inner=speed.get_theme_font("font").get_multiline_string_size(speed.text,HORIZONTAL_ALIGNMENT_CENTER,speed.size.x-speed.get_theme_stylebox("normal").get_minimum_size().x,size)
		check(inner.y<=speed.size.y,"the speed words fit the control "+stamp+" hunted="+str(hunted)+" "+str(inner)+" in "+str(speed.size))
		var alarm:Control=game.mission_hud.alarm
		check(not alarm.visible or not alarm.get_global_rect().intersects(rect),"the alarm lane keeps clear of the speed control "+stamp)
	game.sim.contacts.clear();game.queue_free();await settle()
func cycle_case():
	var game=await make(Vector2i(2520,1080),1.0)
	check(game.time_speed==1.0 and not TimeSpeed.hunting(game.sim),"a dive starts at 1x with no hunting")
	var seen=[]
	for n in 4:
		game.speed_button.pressed.emit();await settle();seen.append(game.time_speed)
	check(seen==[2.0,4.0,1.0,2.0],"the control cycles 1x, 2x, 4x, 1x: "+str(seen))
	check(game.speed_button.text=="SPEED\n2x","the control shows the speed: "+game.speed_button.text)
	game.sim.paused=true;game.time_speed=4.0;game._refresh()
	DiveClock.advance(game,game.tactical_aids,.2)
	check(game.sim.elapsed==0.0 and game.sim.paused,"paused stays paused at 4x")
	game.queue_free();await settle()
func hunting_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var sim=game.sim
	for mode in ["PATROL","DORMANT","RETURN","PINNED"]:
		sim.contacts[0]=contact(sim,mode)
		check(not TimeSpeed.hunting(sim),"a Siren in mode "+mode+" is not hunting")
	for mode in ["INVESTIGATE","SEARCH","LOCKING","BEAM"]:
		sim.contacts[0]=contact(sim,mode)
		check(TimeSpeed.hunting(sim),"a Siren in mode "+mode+" is hunting")
	sim.contacts[0]=contact(sim,"LOCKING",5.0)
	check(not TimeSpeed.hunting(sim),"a contact not seen for 5 s is not hunting")
	sim.contacts[0]=contact(sim,"LOCKING",0.0,true)
	check(not TimeSpeed.hunting(sim),"a lock on a recipient is not hunting the player's craft")
	sim.contacts.clear()
	if preload("res://src/simulation/hunt_pressure/hunt_pressure.gd").active(sim.mission):
		var recon=sim.Recon.state(sim.mission).duplicate(true);recon["hunt"]=25.;sim.mission["reconnaissance"]=recon
		check(TimeSpeed.hunting(sim),"Hunt at its first stage is hunting")
		recon=recon.duplicate(true);recon["hunt"]=0.;sim.mission["reconnaissance"]=recon
		check(not TimeSpeed.hunting(sim),"Hunt at zero is not hunting")
	# A tap is refused while hunting.
	sim.contacts[0]=contact(sim,"LOCKING")
	game.time_speed=1.0;game.speed_button.pressed.emit();await settle()
	check(game.time_speed==1.0,"a tap is refused while a Siren is hunting")
	game._refresh();await settle()
	check(game.speed_button.text==Words.SPEED.hunting,"the control says why: "+game.speed_button.text)
	# Hunting starting drops 2x and 4x to 1x at once, and the speed does not climb back by itself.
	sim.contacts.clear();game.time_speed=4.0;game._refresh()
	sim.paused=false
	sim.contacts[0]=contact(sim,"LOCKING")
	DiveClock.advance(game,game.tactical_aids,.05)
	check(game.time_speed==1.0,"hunting drops 4x to 1x at once")
	sim.contacts.clear();DiveClock.advance(game,game.tactical_aids,.05);await settle()
	check(game.time_speed==1.0,"the speed does not come back up by itself")
	# A forced (developer) speed is not dropped.
	game.debug_console.execute("time 8");sim.contacts[0]=contact(sim,"LOCKING")
	check(not TimeSpeed.guard(game) and game.time_speed==8.0,"a developer's speed is not dropped by hunting")
	game.queue_free();await settle()
func scaling_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var sim=game.sim;sim.paused=false
	game.debug_console.time_scale=1.0
	var t0=sim.elapsed
	for n in 30:DiveClock.advance(game,game.tactical_aids,1.0/60.0)
	var base=sim.elapsed-t0
	for speed in [2.0,4.0]:
		game.time_speed=speed;t0=sim.elapsed
		for n in 30:DiveClock.advance(game,game.tactical_aids,1.0/60.0)
		check(absf((sim.elapsed-t0)-base*speed)<.05,"%dx runs %dx the dive time (%.3f vs %.3f)"%[speed,speed,sim.elapsed-t0,base*speed])
	game.time_speed=1.0
	# The same path serves a build with no console.
	var host_free=Node.new();host_free.set_script(load("res://tests/time_host.gd"));host_free.sim=sim;host_free.time_speed=4.0;t0=sim.elapsed
	for n in 30:TimeSpeed.advance(host_free,1.0/60.0)
	check(absf((sim.elapsed-t0)-base*4.0)<.05,"the release path scales the step the same way")
	host_free.free()
	game.queue_free();await settle()
func panel_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var dev=game.debug_console
	check(dev!=null and dev.panel!=null,"a debug build has the console and its panel")
	dev.open();await settle()
	var ids={}
	for b in dev.panel.body.find_children("*","Button",true,false):ids[str(b.get_meta("ui_action",""))]=b
	for id in ["dev_speed_1","dev_speed_2","dev_speed_4","dev_speed_8","dev_speed_16","dev_invulnerable","dev_oxygen","dev_oxygen_lock","dev_known","dev_win","dev_lose","dev_unlock","dev_granttools","dev_jump","dev_complete","dev_overlay_sight"]:
		check(ids.has(id),"the panel has the button "+id)
		if ids.has(id):check(ids[id].custom_minimum_size.y>=game.ui_touch_height-.5,"the button "+id+" is at least a touch height")
	var picker=dev.panel.body.find_children("*","OptionButton",true,false)[0]
	check(picker.item_count==42 and picker.get_item_text(0).begins_with("01  ") and picker.get_item_text(41).begins_with("42  "),"the jump list names all 42 operations by number")
	# Buttons run the console's commands.
	ids["dev_speed_16"].pressed.emit();await settle()
	check(game.time_speed==16.0 and game.time_forced,"SPEED 16x sets 16x")
	ids["dev_speed_1"].pressed.emit();await settle()
	check(game.time_speed==1.0 and not game.time_forced,"SPEED 1x sets 1x")
	check(dev.execute("time 17")!="Time scale 17.00x" and game.time_speed==1.0,"the console refuses above 16x")
	ids["dev_invulnerable"].pressed.emit();await settle()
	check(dev.invulnerable,"INVULNERABLE on");ids["dev_invulnerable"].pressed.emit();await settle()
	check(not dev.invulnerable,"INVULNERABLE off")
	ids["dev_oxygen_lock"].pressed.emit();await settle()
	check(dev.oxygen_locked,"OXYGEN LOCK on")
	game.sim.oxygen=50.;game.sim.paused=false
	for n in 20:dev.advance(.1)
	check(game.sim.oxygen>=50.,"OXYGEN LOCK stops the drain")
	ids["dev_oxygen_lock"].pressed.emit();await settle()
	check(not dev.oxygen_locked,"OXYGEN LOCK off")
	ids["dev_oxygen"].pressed.emit();await settle()
	check(game.sim.oxygen>=100.,"OXYGEN refills")
	check(DevState.marked(game),"a panel action marks the profile DEV")
	game.sim.paused=true
	dev.execute("granttools");check(dev.execute("granttools").begins_with("Granted"),"GRANT TOOLS runs")
	# WIN and LOSE end the dive.
	dev.execute("win");check(game.sim.outcome=="won","WIN DIVE NOW ends the dive won")
	game.active_started=false;dev.execute("jump 3");check(game.sim.mission.id==3 and game.sim.outcome.is_empty(),"JUMP launches operation 3")
	dev.execute("lose");check(game.sim.outcome=="lost","LOSE DIVE NOW ends the dive lost")
	check(dev.execute("win")=="No dive is running.","WIN with no dive running says so")
	game.queue_free();await settle()
func release_case():
	var game=await make(Vector2i(2520,1080),1.0)
	check(Console.install(game,false)==null and not Console.available(false),"a release build installs no console, so no debug panel")
	# The control a player uses is not debug only.
	check(game.speed_button!=null and game.speed_button.is_visible_in_tree(),"the speed control is in every build")
	game.queue_free();await settle()
