extends SceneTree
# WP-98: the briefing's right column is the boat, oxygen stock reads as a tank size, and the craft readout keeps its
# lines whole.
# 1. On a wide screen what Quietus carries (loadout lines, optics, launch cost) sits in the column of LOADOUT, apart from
#    the mission's goal; one column keeps today's order.
# 2. "O2 tank N% of standard" in the briefing, the compare list and the challenge page; never a bare "O2 120%".
# 3. The Quietus readout is "HULL .. O2 ..", then one line "BAND · task"; the chip draws exactly those lines.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Oxygen=preload("res://src/presentation/oxygen_reading.gd")
const Flow=preload("res://src/presentation/flow/campaign_flow.gd")
const PHONE_SIZE=Vector2i(600,1400)
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func action(g,id:String):
	for control in g.menu.find_children("*","Button",true,false):
		if control.get_meta("action","")==id:return control
	return null
func label_with(g,prefix:String):
	for label in g.menu.find_children("*","Label",true,false):
		if label.text.begins_with(prefix):return label
	return null
func briefing_checks(g,stamp:String,wide:bool)->void:
	g.completed=[0];g.unlocked=1
	# A phone is narrower than the headless window allows; the briefing reads the host's own size.
	if not wide:g.size=Vector2(PHONE_SIZE)
	g._briefing(1);await settle()
	var arc=g.get_node_or_null("ArcCard")
	if arc!=null:
		var buttons=arc.find_children("*","Button",true,false)
		if not buttons.is_empty():buttons[0].pressed.emit();await settle()
	var loadout=action(g,"edit_racks");var manual=action(g,"manual");var stock=label_with(g,"Loadout:")
	check(loadout!=null and manual!=null and stock!=null,"the briefing has LOADOUT, the field manual and the stock line "+stamp)
	if loadout==null or manual==null or stock==null:return
	check(g.get_meta("hub_wide",false)==wide,"the briefing is "+("two columns" if wide else "one column")+" "+stamp)
	if wide:
		check(stock.get_parent()==loadout.get_parent() and stock.get_index()<loadout.get_index(),"the loadout stock sits above LOADOUT in the boat's column "+stamp)
		check(manual.get_parent()!=loadout.get_parent(),"the mission column (field manual) is the other column "+stamp)
		for label in g.menu.find_children("*","Label",true,false):
			if label.text.begins_with("OPTICS") or label.text.begins_with("Launch") or label.text.begins_with("Quietus starts at hull"):
				check(label.get_parent()==loadout.get_parent(),"what Quietus carries sits in the boat's column: "+label.text.left(24)+" "+stamp)
	else:
		check(stock.get_parent()==manual.get_parent() and manual.get_index()<stock.get_index() and stock.get_index()<loadout.get_index(),"one column keeps today's order (manual, stock, LOADOUT) "+stamp)
	check(stock.text.contains("O₂ tank ") and stock.text.contains("% of standard") and not stock.text.contains("O₂ 1"),"the stock line reads as a tank size "+stamp+": "+stock.text.replace("\n"," | "))
func wording_checks(g,stamp:String)->void:
	check(Oxygen.tank(120)=="O₂ tank 120% of standard","the tank wording is defined once")
	g._show_campaign();await settle()
	var compare=label_with(g,"COMPARE STOCK")
	check(compare!=null and compare.text.contains("O₂ tank 120% of standard") and compare.text.contains("O₂ tank 100% of standard") and not compare.text.contains("O₂ 1"),"the compare list reads as tank sizes "+stamp)
	var source:String=FileAccess.get_file_as_string("res://src/presentation/frontend/challenges_frontend.gd")
	check(source.contains("oxygen_reading.gd\").tank(") and not source.contains("O₂ %d%%"),"the challenge page uses the same wording "+stamp)
func readout_checks(g,stamp:String)->void:
	g._start_mission(0);await settle()
	var s=g.sim;s.paused=true;g._refresh();await settle()
	var status:String=g.mission_hud.fleet.status(0)
	var lines:PackedStringArray=status.split("\n")
	var band:String=s.Depth.NAMES[s.units[0].band]
	check(lines.size()>=2 and lines[0].begins_with("HULL") and lines[0].contains("O₂ ") and not lines[0].contains(band),"line one is the whole reserve group "+stamp+": "+status.replace("\n"," | "))
	check(lines.size()>=2 and lines[1].begins_with(band+" · "),"line two starts with the depth band and carries the task "+stamp+": "+status.replace("\n"," | "))
	var chip=g.mission_hud.fleet.telemetry[0]
	if chip.visible:
		check(chip.get_line_count()==lines.size(),"the chip draws one row per line, nothing wrapped alone "+stamp+": %d rows for %d lines"%[chip.get_line_count(),lines.size()])
	else:
		check(true,"the chip is hidden at this size "+stamp)
func run():
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(1080,2400)]:
		for scale in [1.,1.5]:
			root.size=shape;await settle()
			Settings.current["text_scale"]=scale
			var stamp="at %dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
			var g=load("res://scenes/main.tscn").instantiate();g.capture_scenario="wp98-boat-column";root.add_child(g);await settle();g.set_process(false)
			g.size=Vector2(g.get_viewport_rect().size);g._layout();await settle()
			await briefing_checks(g,stamp,shape.x>shape.y)
			await wording_checks(g,stamp)
			await readout_checks(g,stamp)
			g.queue_free();await settle()
	Settings.current["text_scale"]=1.
	print("BRIEFING BOAT COLUMN UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
