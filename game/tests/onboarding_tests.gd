extends SceneTree
# New-player onboarding and control safety: stray taps, undo, once-only prompts, readable text, plain wording.
var failures:=0
var checks:=0
var game
func check(value: bool,label: String) -> void:
	checks+=1
	if not value: failures+=1; printerr("FAIL: ",label)
func _initialize() -> void: call_deferred("run")
func click(p: Vector2) -> void:
	var down=InputEventMouseButton.new(); down.position=p; down.global_position=p; down.button_index=MOUSE_BUTTON_LEFT; down.button_mask=MOUSE_BUTTON_MASK_LEFT; down.pressed=true
	var motion=InputEventMouseMotion.new(); motion.position=p; motion.global_position=p; root.push_input(motion,true)
	root.push_input(down,true); await process_frame
	var up=InputEventMouseButton.new(); up.position=p; up.global_position=p; up.button_index=MOUSE_BUTTON_LEFT; up.pressed=false
	root.push_input(up,true); await process_frame
func settle() -> void:
	for n in 4: await process_frame
func water_point(world: Vector2) -> Vector2:
	return game.ocean.global_position+game.ocean.world_offset+world*game.ocean.world_scale
func buttons(node: Node, id: String) -> Button:
	for c in node.find_children("*","Button",true,false):
		if c.get_meta("action","")==id: return c
	return null
func run() -> void:
	root.size=Vector2i(1280,720); await process_frame; await process_frame
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="runtime-test"; root.add_child(game)
	await settle()
	var Text=preload("res://src/campaign/onboarding_text.gd")
	var Store=preload("res://src/persistence/save_store.gd")
	# Saved first-run flags: optional, validated.
	check(Text.valid_seen([]) and Text.valid_seen(["move","sweep"]) and not Text.valid_seen(["bogus"]) and not Text.valid_seen("move"),"first-run flags validate")
	var base={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance"}
	var store=Store.new()
	check(store.valid(base),"an archive without hint flags still loads")
	var flagged=base.duplicate(); flagged["hints_seen"]=["move"]
	check(store.valid(flagged),"an archive with hint flags loads")
	flagged["hints_seen"]=["nonsense"]
	check(not store.valid(flagged),"an archive with unknown hint flags is rejected cleanly")
	# No dive text wall, no manual wording on a fresh campaign.
	game._briefing(0); await settle()
	var shown=""
	for c in game.panel_box.get_children():
		if c is Label: shown+=c.text+"\n"
	check(shown.length()<420 and "GOAL" in shown and "DANGER" in shown and "exposed" not in shown,"opening briefing is a goal and one danger")
	check(buttons(game.panel_box,"manual")!=null,"rules live behind a field manual button")
	game._reference(0); await settle()
	shown=""
	for c in game.panel_box.get_children():
		if c is Label: shown+=c.text+"\n"
	check("stationary seconds" in shown and "FIELD MANUAL" in shown,"field manual keeps the full rules")
	game._show_campaign(); await settle()
	var resume=false; var erase=false
	for c in game.panel_box.get_children():
		if c is Button and c.text.begins_with("RESUME"): resume=true
		if c is Button and c.get_meta("action","")=="new_campaign": erase=true
	check(not erase,"a fresh campaign offers no erase or replace wording")
	# Dive: stray tap safety.
	game._start_mission(0); await settle()
	var guard=game.mission_hud.guard
	game.sim.paused=true
	var first=Vector2(320,800)
	await click(water_point(first)); await settle()
	check(not game.sim.units[0].route.is_empty(),"first plan on an idle craft is placed at once")
	check(guard.undo_button.visible and guard.pending.is_empty(),"an undo chip follows the order")
	var planned=game.sim.units[0].route.back().pos
	await click(water_point(Vector2(780,640))); await settle()
	check(not guard.pending.is_empty() and game.sim.units[0].route.back().pos==planned,"a tap over an existing route only sets a pending marker")
	check(guard.panel.visible and guard.go_button.visible and guard.add_button.visible and guard.points_button.visible,"replace, add and pass/stop choices are on screen")
	await click(guard.cancel_button.get_global_rect().get_center()); await settle()
	check(guard.pending.is_empty() and game.sim.units[0].route.back().pos==planned,"cancel leaves the route untouched")
	await click(water_point(Vector2(780,640))); await settle()
	await click(guard.go_button.get_global_rect().get_center()); await settle()
	check(guard.pending.is_empty() and game.sim.units[0].route.back().pos.distance_to(Vector2(780,640))<30,"REPLACE ROUTE applies the new route")
	await click(guard.undo_button.get_global_rect().get_center()); await settle()
	check(game.sim.units[0].route.back().pos==planned,"undo restores the previous route")
	await click(water_point(Vector2(780,640))); await settle()
	var before=game.sim.route_goals().size()
	await click(guard.add_button.get_global_rect().get_center()); await settle()
	check(game.sim.route_goals().size()==before+1 and not game.sim.queue_mode,"ADD TO ROUTE extends without leaving queue mode on")
	await click(guard.undo_button.get_global_rect().get_center()); await settle()
	check(game.sim.route_goals().size()==before,"undo removes the added stop")
	# Undo of a first plan clears it.
	game._start_mission(0); await settle()
	game.sim.paused=true
	await click(water_point(first)); await settle()
	await click(guard.undo_button.get_global_rect().get_center()); await settle()
	check(game.sim.units[0].route.is_empty(),"undo of a first order leaves the craft with no route")
	# Prompts: once each, never pausing play.
	game.hints_seen=[]; game._start_mission(0); await settle()
	var hints=game.mission_hud.hints
	check(hints.panel.visible and hints.current=="move" and game.sim.paused,"the first prompt teaches one verb while paused")
	check("move" in game.hints_seen,"a shown prompt is remembered")
	game.sim.command("route",{"point":Vector2(400,700)}); game._refresh(); await settle()
	check(not hints.panel.visible,"taking the step retires its prompt")
	game.sim.paused=false; game.sim.elapsed=1.0; game._refresh(); await settle()
	check(hints.current=="pause" and not game.sim.paused,"the pause prompt appears without pausing the game")
	hints.dismiss(); game.sim.paused=true; game._refresh(); await settle()
	check(not hints.panel.visible,"prompts can be dismissed")
	var count=game.hints_seen.size(); game._start_mission(0); await settle()
	check(not hints.panel.visible and game.hints_seen.size()==count,"a prompt does not show twice")
	# Contextual action reads before the tap.
	var caption=game.mission_hud.camera_caption()
	check(caption.size()>=2 and caption.size()<=3 and (caption.size()==2 and "NO SITE" in caption[1] or "NOT READY" in caption[2]),"the action button says it is not ready before the tap")
	game.sim.units[0].pos=game.sim.mission.objectives[0].pos+Vector2(60,0); game.sim.units[0].vel=Vector2.ZERO
	game.sim.units[0].angle=PI
	game.sim.Photo.discover(game.sim)
	game._refresh(); caption=game.mission_hud.camera_caption()
	check(caption.size()==3 and game.sim.Photo.label(game.sim.mission.objectives[0]).to_upper().substr(0,18) in caption[1] and caption[2].begins_with("READY"),"the action button uses its target's known label and says it is ready")
	# Text size reaches the dive HUD without shrinking touch targets.
	var normal_font=game.mission_hud.host.pause_button.get_theme_font_size("font_size")
	var h=game.ui_touch_height
	game._set_text_scale(1.5); await settle(); await settle()
	check(game.mission_hud.host.pause_button.get_theme_font_size("font_size")>normal_font,"large text enlarges the dive buttons")
	check(game.pause_button.size.y>=h-0.5 and game.pause_button.size.x>=h*1.55-0.5,"larger text never shrinks touch targets")
	game._set_text_scale(1.0); await settle()
	check(game.screen!="" ,"settings menu still builds")
	# Text wrapping: long status messages stay whole.
	game.sim.message="Local record nearby within240m with a very long explanation that must wrap rather than be cut off by an ellipsis at the end of the line"
	game.sim.paused=true; game._refresh(); await settle()
	var intent=game.mission_hud.intent
	check(intent.get_combined_minimum_size().y<=intent.size.y+1 and intent.size.y>=intent.get_line_height()*2 and intent.get_global_rect().end.y<=game.size.y,"status text wraps inside the screen")
	print("ONBOARDING CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
