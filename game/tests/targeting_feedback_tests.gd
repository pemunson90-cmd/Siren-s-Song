extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 4:await process_frame
func run():
 root.size=Vector2i(1280,720)
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="targeting-feedback";root.add_child(game);await settle()
 game.set_process(false);game._start_mission(0);await settle()
 game._order("decoy");var charges=game.sim.tools.decoy
 game._order("decoy",{"point":Vector2(1500,900)});await settle()
 check(game.decoy_armed and game.sim.tools.decoy==charges,"invalid decoy remains armed without spending")
 check(game.sim.message in game.mission_hud.intent.text,"armed intent exposes the actual rejected deployment reason")
 game._primary_action();game._order("knock");var shots=game.sim.tools.knock
 game._target_knockdown(Vector2(20,20));await settle()
 check(game.knock_armed and game.sim.tools.knock==shots,"invalid torpedo tap preserves charge and aim mode")
 check(game.sim.message in game.mission_hud.intent.text,"armed intent exposes the actual rejected shot reason")
 var enemy=game.sim.sirens[0];enemy.pos=game.sim.units[0].pos+Vector2(100,0);enemy.mode="DISRUPTED";enemy.stun=6.;enemy.lock=0.;enemy.target=-1
 game.sim._observe();game._refresh();await settle()
 game._target_knockdown(game.ocean.global_position+game.ocean.screen_position(enemy.pos));await settle()
 check("disrupt" in game.mission_hud.intent.text.to_lower() and game.sim.tools.knock==shots,"observed disrupted target explains rejection without spending")
 game._primary_action();await settle()
 check(not game.knock_armed and not game.decoy_armed and "disrupted" not in game.mission_hud.intent.text.to_lower(),"cancel clears the old targeting result")
 game.fitted_equipment={"quietus":"","drone_a":"drone_sampler","drone_b":""};game._start_mission(10)
 game.sim.units[1].pos=game.sim.mission.objectives[0].pos+Vector2(0,100);game.sim.command("select",{"unit":1});game._refresh()
 game._order("decoy");game._order("decoy",{"point":Vector2(1900,1900)});await settle()
 check(game.sim.message in game.mission_hud.intent.text,"rejected deployment takes precedence over field-sampler readiness")
 game.queue_free();await settle()
 print("TARGETING FEEDBACK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
