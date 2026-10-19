extends SceneTree
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func run():
 var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://campaign-dispatch-fixture.save";root.add_child(game);game.set_process(false)
 var tutorial=[0,1,2,3,4,5];game.completed=tutorial.duplicate();game.unlocked=5
 game.expedition=preload("res://src/campaign/campaign_consequences.gd").upgrade({"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"fixture carrier"},"completed":[6,7]})
 game.expedition.entitlements=["quietus_correlator"];game.expedition.references={"return_cadence":[.8,1.6,.8]}
 game._start_mission(9)
 # Self-contained terminal dispatch fixture, NOT an earned journey. Remove
 # threats/position an actor only to obtain a valid production terminal state;
 # receive/capture/extract still run through the actual simulation commands.
 game.sim.sirens=[];game.sim.units[0].pos=Vector2(480,700);game.sim.units[0].vel=Vector2.ZERO
 game.sim.paused=false;game.sim.advance(.1)
 check(game.sim.command("camera"),"terminal fixture uses actual receiver acquisition")
 for n in 45:game.sim.advance(.1)
 game.sim.units[0].pos=game.sim.mission.extraction;game.sim.units[0].vel=Vector2.ZERO;game.sim.advance(.1)
 check(game.sim.outcome=="won" and preload("res://src/simulation/simulation.gd").valid_snapshot(game.sim.snapshot()),"self-contained onward terminal fixture satisfies real save schema")
 game._process(0.)
 check(game.screen=="debrief" and game.completed==tutorial and game.unlocked==5,"normal Main frame dispatch preserves tutorial completion IDs")
 check(9 in game.expedition.completed and game.expedition.selected_thread=="deep" and game.expedition.history.any(func(item):return item.mission==9),"normal frame dispatch commits successful onward recovery and history through expedition adapter")
 check(game.store.valid(game._archive()) and not game.store.load_game().is_empty(),"actual dispatched campaign archive survives checksummed save/load")
 game.queue_free();await process_frame
 print("CAMPAIGN MAIN DISPATCH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
