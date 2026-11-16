extends SceneTree
# WP-97: every number a player reads agrees with the others, and the result shows what was won.
# 1. Oxygen is one unit, time left: the pause plate, the craft readout and the result agree; no percentage over 100.
# 2. The Career board card shows the salvage a recovery pays beside the contract reward, from the rules the result uses.
# 3. A recovered dive's result draws the best filed frame (the gallery's Plate).
# 4. A drone left outside recovery says what it costs.
# 5. A tap past the edge of the operation says why it did nothing.
# Run at the cover screen (2520x1080) and the inner screen (2184x1968).
const Chip=preload("res://src/presentation/oxygen_reading.gd")
const Flow=preload("res://src/presentation/flow/campaign_flow.gd")
const Review=preload("res://src/presentation/flow/photo_review.gd")
const Board=preload("res://src/presentation/career/career_board.gd")
const State=preload("res://src/campaign/career/career_state.gd")
const Table=preload("res://src/campaign/career/career_table.gd")
const Economy=preload("res://src/campaign/economy.gd")
const View=preload("res://src/presentation/module_recovery_view.gd")
const DiveInput=preload("res://src/presentation/dive_input.gd")
const Recovery=preload("res://src/simulation/module_recovery.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
# A stand-in for the career host: the board reads only the career state and the economy.
class Host:
	var career_state:Dictionary
	var economy:Dictionary
func salvage_checks()->void:
	for id in Table.CONTRACTS:
		var c=Table.CONTRACTS[id]
		var host=Host.new();host.career_state=State.new_career();host.economy=host.career_state.economy
		for first in [true,false]:
			var state=State.new_career()
			if not first:state.progress.completed.append(c.op)
			var launched=state.duplicate(true);launched.active=id;launched.in_flight=true;launched.serial=1
			var before=launched.economy.stock.duplicate()
			var settled=State.settle(launched,{"outcome":"won","hull":100.,"alive":[true,true]})
			host.career_state=state;host.economy=state.economy
			var shown=Board.salvage(host,c)
			var ok=true
			for key in Economy.RES:
				var paid=settled.economy.stock[key]-before[key]-c.reward.get(key,0)
				if paid!=shown[key]:ok=false;printerr("  ",id," ",key," paid ",paid," shown ",shown[key])
			check(ok,"%s (%s): the salvage the card shows is what the recovery pays"%[id,"first" if first else "replay"])
		check(Economy.fmt(Board.salvage(host,c)).length()>0 and "FREE" not in Economy.fmt(Board.salvage(host,c)),"%s: the card names a salvage amount"%id)
func consequence_checks()->void:
	var s=Sim.new();s.start(0,"endurance",{PlayerDive.Rules.KEY:false,"drones_aboard":false});s.sirens=[]
	var context=Recovery.departure(s,{"pos":s.mission.extraction})
	Recovery.record(s,context);s.outcome="won"
	var text=View.consequence(s)
	check(text.contains("OUTSIDE RECOVERY") and text.contains(View.ABSENT),"a drone left outside recovery states its cost: "+text)
	check(View.ABSENT_IRON!=View.ABSENT and View.ABSENT_IRON.contains("gone for good"),"the Ironman consequence says the drone is gone for good")
func unit_checks(g,stamp:String)->void:
	var s=g.sim
	s.oxygen=120.
	check(Chip.percent(s)==100 and Chip.text(s).begins_with("100% ~"),"an endurance tank shows full, never over 100 "+stamp+": "+Chip.text(s))
	var craft=g.mission_hud.fleet.status(0)
	check(craft.contains("O₂ "+Chip.text(s)) and not craft.contains("120"),"the craft readout gives oxygen as percent and time left "+stamp+": "+craft)
	var result=Flow.stats_line(s)
	check(result.contains("Life support "+Chip.text(s)) and not result.contains("120"),"the result gives life support in the same words "+stamp+": "+result)
	s.oxygen=45.
	check(g.mission_hud.fleet.status(0).contains(Chip.text(s)) and Flow.stats_line(s).contains(Chip.text(s)) and Chip.text(s).begins_with("45% ~"),"craft readout and result agree "+stamp)
func take_spire_photo(g)->void:
	var s=g.sim;s.sirens=[]
	var spire=Vector2(1300,300);var facing=2.74
	s.units[0].pos=spire+Vector2.from_angle(facing)*110;s.units[0].angle=facing+PI
	s.paused=false
	for n in 12:s.advance(1./60)
	s.command("camera")
	for n in 300:s.advance(1./60)
	s.paused=true
func photo_checks(g,stamp:String)->void:
	take_spire_photo(g)
	var s=g.sim
	check(not s.mission.get("photo",{}).get("shots",[]).is_empty(),"the dive filed a frame "+stamp)
	g._clear_menu();s.outcome="lost"
	Review.show_best_frame(g)
	check(g.panel_box.get_node_or_null(Review.BEST_FRAME_NODE)==null,"a lost dive draws no best frame "+stamp)
	s.outcome="won"
	Review.show_best_frame(g);await settle()
	var plate=g.panel_box.get_node_or_null(Review.BEST_FRAME_NODE)
	check(plate!=null,"a recovered dive's result draws the best frame "+stamp)
	if plate!=null:
		check(plate.custom_minimum_size.x<=g.size.x*0.7+0.5 and plate.custom_minimum_size.y<=g.size.y*0.22+0.5,"the frame is drawn small "+stamp+": "+str(plate.custom_minimum_size))
		check(plate.title.contains("BEST FRAME") and plate.vm.has("cols"),"the frame is a gallery Plate with the filed shot "+stamp)
		var best=Review.best_shot(s.mission)
		for shot in s.mission.photo.shots:check(float(shot.q)<=float(best.q),"it is the sharpest filed frame "+stamp)
	g._clear_menu()
	# The campaign debrief itself reaches the same call.
	g.economy=Economy.new_state("standard");g.recovered_evidence={};g.photo_records={}
	g._debrief();await settle()
	check(g.panel_box.get_node_or_null(Review.BEST_FRAME_NODE)!=null or not s.mission.get("recovered",true),"the debrief path draws the frame "+stamp)
func tap_checks(g,stamp:String)->void:
	g._start_mission(0);await settle()
	g.sim.message="Tap water to route"
	DiveInput.outside_tap(g)
	check(g.sim.message==DiveInput.OUTSIDE_TAP and g.sim.message.contains("Outside the operation area"),"a tap past the operation edge says why "+stamp)
	# A real tap on the chart past the world edge, when the view shows that much water.
	g.ocean.zoom_at(0.5,g.ocean.size/2);await settle()
	var outside=Vector2(-60,-60)
	var screen=g.ocean.global_position+g.ocean.screen_position(outside)
	if g.ocean.get_global_rect().grow(-4).has_point(screen) and not g.mission_hud.blocks(screen):
		g.sim.message="Tap water to route"
		var mouse=InputEventMouseButton.new();mouse.position=screen;mouse.global_position=screen;mouse.button_index=MOUSE_BUTTON_LEFT
		for down in [true,false]:
			mouse.pressed=down;DiveInput.map_event(g,mouse);await process_frame
		await settle()
		check(g.sim.message==DiveInput.OUTSIDE_TAP,"a real tap beyond the edge sets the line and it stays "+stamp+": "+g.sim.message)
	else:
		check(true,"the view does not show water past the edge at this size "+stamp)
func run():
	salvage_checks()
	consequence_checks()
	for size in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		root.size=size;await settle()
		var stamp="at %dx%d"%[size.x,size.y]
		var g=load("res://scenes/main.tscn").instantiate();g.capture_scenario="wp97-result-numbers";root.add_child(g);await settle();g.set_process(false)
		g._start_mission(0);await settle()
		unit_checks(g,stamp)
		await photo_checks(g,stamp)
		await tap_checks(g,stamp)
		g.queue_free();await settle()
	print("RESULT NUMBERS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
