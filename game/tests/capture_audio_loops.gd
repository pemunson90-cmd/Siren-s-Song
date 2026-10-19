extends SceneTree
# Long production-mixer audition: crosses 8-second ambience and 2-second engine loops.
var game
var clock:=0.0
var next_boundary:=2.0
func _initialize() -> void: call_deferred("run")
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="audio-loop-regression"; root.add_child(game)
	game._start_mission(0); game.sim.command("route",{"point":Vector2(800,800)}); game.sim.paused=false
	for name in ["ambience","engine"]:
		var wav=game.sound.get(name).stream
		print("AUDIO LOOP ",name," frames=",wav.data.size()/2," begin=",wav.loop_begin," end=",wav.loop_end)
func _process(dt: float) -> bool:
	if game==null: return false
	clock+=dt
	if clock>=next_boundary:
		print("AUDIO LOOP AUDITION clock=",snappedf(clock,0.01)," ambience_position=",snappedf(game.sound.ambience.get_playback_position(),0.01)," engine_position=",snappedf(game.sound.engine.get_playback_position(),0.01))
		next_boundary+=2.0
	return false
