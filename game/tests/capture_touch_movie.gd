extends SceneTree
# Synthetic Godot pointer/touch events, never an OS-touch or human-play claim.
var game
var clock:=0.0
var phase:=0
var finger_origin:=Vector2.ZERO
var finger_last:=Vector2.ZERO
func _initialize() -> void: call_deferred("run")
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="touch-movie"; root.add_child(game)
	game._start_mission(3); game.sim=preload("res://tests/foundry_command_plan.gd").play(true,"cradle",true); game.ocean.sim=game.sim; game.sim.paused=true; game._refresh()
func click(button) -> void:
	for pressed in [true,false]:
		var event=InputEventMouseButton.new(); event.position=button.get_global_rect().get_center(); event.button_index=MOUSE_BUTTON_LEFT; event.pressed=pressed; root.push_input(event,true)
func finger(pressed: bool) -> void:
	var event=InputEventScreenTouch.new(); event.index=0; event.position=finger_last; event.pressed=pressed; root.push_input(event,true)
func _process(dt: float) -> bool:
	if game==null: return false
	clock+=dt
	if phase==0 and clock>0.5: click(game.zoom_buttons[1]); phase=1
	if phase==1 and clock>1.1: click(game.zoom_buttons[1]); phase=2
	if phase==2 and clock>1.8:
		finger_origin=game.ocean.get_global_rect().get_center(); finger_last=finger_origin; finger(true); phase=3
	if phase==3:
		var next=finger_origin+Vector2(-260,-190)*clampf((clock-1.8)/0.9,0,1)
		var event=InputEventScreenDrag.new(); event.index=0; event.position=next; event.relative=next-finger_last; root.push_input(event,true); finger_last=next
		if clock>2.7: finger(false); phase=4
	if phase==4 and clock>3.8: click(game.zoom_buttons[2]); phase=5
	if phase==5 and clock>4.8: click(game.advanced_button); phase=6
	if phase==6 and clock>5.8: click(game.advanced_button); phase=7
	return false
