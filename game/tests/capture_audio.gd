extends SceneTree
# Controlled audition of production mixer while the actual game runs.
var game
var clock:=0.0
var next_cue:=0
const CUES=["ping","recon","camera","emp","decoy","alert","beam","record","creak","extraction"]
func _initialize() -> void: call_deferred("run")
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="audio-audition"; root.add_child(game)
	game._start_mission(0); game.sim.command("route",{"point":Vector2(800,800)}); game.sim.command("silent"); game.sim.paused=false
	print("AUDIO AUDITION running ambience + cruise propulsion + spaced cues; pause at7s")
func _process(dt: float) -> bool:
	if game==null: return false
	clock+=dt
	if next_cue<CUES.size() and clock>=0.4+next_cue*0.55:
		game.sound.play(CUES[next_cue],Vector2(-300 if next_cue%2==0 else 300,0)); print("AUDIO CUE ",CUES[next_cue]," time=",snappedf(clock,0.01)); next_cue+=1
	if clock>=7: game.sim.paused=true
	return false
