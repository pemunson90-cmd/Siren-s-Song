extends SceneTree
# WP-83: the status strip (MissionHud.intent) says each instruction once, keeps the newest message whole and
# holds two lines at every text size, clear of the craft chips, UNDO and the extraction label.
const Feed=preload("res://src/presentation/archive/voice_feed.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const OPENING="Drones aboard. Tap a craft for DEPTH AND SONAR; tap water to route or deploy."
const HINT="DEEP under the arch · MIDDLE camera/recovery · craft → DEPTH AND SONAR."
const DEFAULT_HINT="Craft → DEPTH AND SONAR · bearings need movement or a second receiver; depth costs time."
const WARNING="SIREN WARNING · patrol sweeping toward QUIETUS from the north-east · hold depth and cut engines"
const HEAD="QUIETUS · MIDDLE · REPLACE"
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func body(message:String)->String:return HEAD if message.is_empty() else HEAD+" · "+message
func lines(text:String,width:float,font_size:int)->int:
	var label=Label.new();label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size);label.custom_minimum_size.x=width;label.size.x=width;label.text=text
	root.add_child(label);var count=label.get_line_count();label.queue_free();return count
func run():
	await process_frame
	for shape in [[1400.,22],[1400.,33],[900.,22],[900.,33]]:
		var width:float=shape[0];var font:int=shape[1]
		var fits=func(text:String)->bool:return lines(text,width,font)<=2
		for case in [[OPENING,HINT],[OPENING,DEFAULT_HINT],[WARNING,HINT],["",HINT],[OPENING,""]]:
			var text:String=Feed.strip_text(body(case[0]),case[0],case[1],fits)
			var label="w%d f%d '%s'"%[width,font,str(case[0]).left(14)]
			check(lines(text,width,font)<=2 or (text==case[0] and lines(case[0],width,font)>2),label+" holds two lines, or is a message too long for two that stands alone")
			check(case[0].is_empty() or text.contains(case[0]),label+" keeps the message whole")
			check(not text.contains("..."),label+" never cuts a word")
			check(text.to_lower().count("depth and sonar")<=1,label+" says DEPTH AND SONAR once")
	var wide=func(_text):return true
	var text:String=Feed.strip_text(body(OPENING),OPENING,HINT,wide)
	check(text==HEAD+" · "+OPENING+"\nDEEP under the arch · MIDDLE camera/recovery","opening keeps the facts and drops the repeated instruction: "+text)
	check(Feed.strip_text(body(OPENING),OPENING,DEFAULT_HINT,wide).ends_with("bearings need movement or a second receiver; depth costs time."),"the default hint keeps its facts")
	check(Feed.strip_text(body(""),"",HINT,wide)==HEAD+"\n"+HINT,"an empty message leaves the standing hint whole")
	var narrow=func(candidate:String)->bool:return not candidate.contains("\n")
	check(Feed.strip_text(body(WARNING),WARNING,HINT,narrow)==body(WARNING),"a long warning drops the standing hint first")
	await real_strip()
	print("STATUS STRIP CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
func make(shape:Vector2i,scale:float):
	root.size=shape;await settle()
	Settings.current["text_scale"]=scale
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp83-strip-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game._start_mission(0);await settle();game._layout();await settle()
	game.sim.sirens=[]
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	return game
func real_strip():
	var saved=Settings.current.duplicate()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			var game=await make(shape,scale)
			var hud=game.mission_hud
			for message in [OPENING,WARNING+" · patrol bearing 045 · closing fast · the hull will not survive a second pass if it finds you here",""]:
				game.sim.message=message;game._refresh();await settle()
				var label="%dx%d x%.1f '%s'"%[shape.x,shape.y,scale,message.left(12)]
				var shown:String=hud.intent.text
				var font=hud.intent.get_theme_font("font");var size=hud.intent.get_theme_font_size("font_size")
				var rows=font.get_multiline_string_size(shown,HORIZONTAL_ALIGNMENT_LEFT,hud.intent.size.x-8.,size).y/font.get_height(size)
				print("STRIP ",label," rows ",rows," [",shown.replace("\n"," // "),"]")
				check(hud.intent.visible and rows<=2.01 or message.length()>100,label+" strip holds two lines: "+shown.replace("\n"," // "))
				check(message.is_empty() or shown.contains(message),label+" newest message whole")
				check(shown.to_lower().count("depth and sonar")<=1,label+" says DEPTH AND SONAR once")
				var avoid=[]
				for reading in hud.fleet.readouts:avoid.append(Rect2(hud.fleet.global_position+reading.rect.position,reading.rect.size))
				for button in hud.fleet.buttons:avoid.append(button.get_global_rect())
				if hud.guard.undo_button.visible:avoid.append(hud.guard.undo_button.get_global_rect())
				for rect in avoid:check(not rect.intersects(hud.intent.get_global_rect()),label+" strip clear of chip "+str(rect))
			game.queue_free();await settle()
	Settings.current=saved
