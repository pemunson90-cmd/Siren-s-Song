extends SceneTree
# WP-85 on screen, at the cover screen (2520x1080) and the inner screen (2184x1968), at normal and 150% text:
#   - the lock card's move buttons carry how long the move takes, fit inside their button and the card, and a move that
#     cannot work in time is drawn in the warning colour;
#   - the status strip says what a craft under way is doing once its route message is old, and fits the screen;
#   - a craft pinned on its route pauses the dive and the strip names the cause.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const TrialRules=preload("res://src/trial_rules.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
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
	game.store.path="user://wp85-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game._start_mission(0);await settle();game._layout();await settle()
	game.sim.sirens=[]
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	preload("res://tests/fixtures/player_dive.gd").launch_drones(game.sim)
	return game
func run():
	var saved=Settings.current.duplicate()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			var stamp="%dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
			await card_case(shape,scale,stamp)
			await strip_case(shape,scale,stamp)
			await stall_case(shape,scale,stamp)
	Settings.current=saved
	TrialRules.reset()
	print("STUCK CRAFT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func card_case(shape:Vector2i,scale:float,stamp:String):
	var game=await make(shape,scale)
	var sim=game.sim
	sim.units[0].silent=false
	sim.contacts={0:{"pos":sim.units[0].pos+Vector2(80,0),"time":sim.elapsed,"mode":"LOCKING","lock":2.0,"target":0,"type":"patroller","source":"optical","angle":0.0,"band":1}}
	sim.paused=true;game._refresh();await settle()
	var card=game.lock_warning
	var shown:Array=card.buttons.filter(func(b):return b.visible)
	check(shown.size()>=2,"the lock card shows its moves "+stamp+": "+str(shown.map(func(b):return b.text)))
	var rect:Rect2=Rect2(card.global_position+card.banner.position,card.banner.size)
	for b in shown:
		var lines:PackedStringArray=b.text.split("\n")
		var order:String=str(b.get_meta("order"))
		check(lines.size()==2,"%s has its name and how long it takes %s: %s"%[order,stamp,b.text.replace("\n"," / ")])
		var font=b.get_theme_font("font");var size=b.get_theme_font_size("font_size")
		var box=b.get_theme_stylebox("normal").get_minimum_size()
		var inner=font.get_multiline_string_size(b.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size)
		check(inner.x<=b.size.x-box.x+.5 and inner.y<=b.size.y-box.y+.5,"%s's two lines fit inside the button %s: %s in %s"%[order,stamp,str(inner),str(b.size-box)])
		check(rect.encloses(b.get_global_rect()),"%s sits inside the card %s"%[order,stamp])
		var warned:bool=b.get_theme_color("font_color")==Palette.color("warning",Color("ffb18b"))
		check(warned==not bool(b.get_meta("in_time")),"%s is drawn in the warning colour exactly when it cannot work in time %s"%[order,stamp])
		if order=="decoy":check(lines.size()==2 and lines[1]==Words.TEXT.move_decoy and not b.get_meta("in_time"),"the decoy says it cannot break a lock %s: %s"%[stamp,b.text.replace("\n"," / ")])
		if order=="silent":check(not b.get_meta("in_time") and lines[1].begins_with("Siren inside"),"silent says a Siren 80 m away still sees it %s: %s"%[stamp,b.text.replace("\n"," / ")])
	game.queue_free();await settle()
# A route order, then dive time: the strip shows the order while it is new and what the craft does after.
func strip_case(shape:Vector2i,scale:float,stamp:String):
	var game=await make(shape,scale)
	var sim=game.sim;var hud=game.mission_hud;var q=sim.units[0]
	q.silent=true
	sim.paused=true;sim.command("select",{"unit":0});sim.command("route",{"point":q.pos+Vector2(400,0)});game._refresh();await settle()
	check("set route" in hud.intent.text,"the new route message is shown whole "+stamp+": "+hud.intent.text)
	sim.paused=false
	for n in 70:game._process(0.1)
	game._refresh();await settle()
	check("under way to point 1" in hud.intent.text and "set route" not in hud.intent.text,"seven seconds on, the strip says what the craft does "+stamp+": "+hud.intent.text.replace("\n"," / "))
	var view:Rect2=Rect2(Vector2.ZERO,Vector2(shape))
	check(view.encloses(hud.intent.get_global_rect()),"the strip stays on the screen "+stamp+": "+str(hud.intent.get_global_rect()))
	var wide:float=hud.intent.get_theme_font("font").get_multiline_string_size(hud.intent.text,HORIZONTAL_ALIGNMENT_LEFT,hud.intent.size.x,hud.intent.get_theme_font_size("font_size")).y
	check(wide<=hud.intent.size.y+1.0,"all of its lines fit the strip "+stamp)
	sim.message="Decoy launched · 15s transmission";game._refresh();await settle()
	check("Decoy launched" in hud.intent.text,"a newer message replaces the status at once "+stamp)
	game.queue_free();await settle()
# A craft pinned against a current as strong as its drive: the dive pauses once and the strip names the cause.
func stall_case(shape:Vector2i,scale:float,stamp:String):
	TrialRules.reset()
	var game=await make(shape,scale)
	var sim=game.sim;var hud=game.mission_hud;var q=sim.units[0]
	q.silent=false
	var drive:float=sim._craft_speed(q,78.0)
	sim.mission["currents"]=[{"center":q.pos,"radius":100000.0,"velocity":Vector2(-drive*1.1,0.0)}]
	sim.paused=true;sim.command("select",{"unit":0});sim.command("route",{"point":q.pos+Vector2(400,0)})
	sim.paused=false
	var frames:=0
	while not sim.paused and frames<400:game._process(0.1);frames+=1
	game._refresh();await settle()
	check(sim.paused and frames<150,"the pinned craft pauses the dive within a few seconds "+stamp+" (frames "+str(frames)+")")
	check("PAUSED: the current holds QUIETUS back" in hud.intent.text and "no progress" in hud.intent.text,"the strip says why "+stamp+": "+hud.intent.text.replace("\n"," / "))
	check(Rect2(Vector2.ZERO,Vector2(shape)).encloses(hud.intent.get_global_rect()),"the strip with the reason stays on the screen "+stamp)
	game.queue_free();await settle()
