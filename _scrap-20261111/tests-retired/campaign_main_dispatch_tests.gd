extends SceneTree
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func run():
 for id in [9,10]:
  var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="campaign-dispatch-fixture";game.store.path="user://campaign-dispatch%d-fixture.save"%id;root.add_child(game);game.capture_scenario="";game.set_process(false)
  var tutorial=[0,1,2,3,4,5];game.completed=tutorial.duplicate();game.unlocked=5
  var branch="deep" if id==9 else "shelf"
  game.expedition=preload("res://src/campaign/campaign_consequences.gd").upgrade({"version":1,"route":branch,"routes":[branch],"facts":{branch:"fixture carrier"},"completed":[6,id-2]})
  if id==9:
   game.expedition.entitlements=["quietus_correlator"];game.expedition.references={"return_cadence":[.8,1.6,.8]}
  else:
   game.expedition.entitlements=["drone_sampler"];game.fitted_equipment={"quietus":"","drone_a":"drone_sampler","drone_b":""}
  game._start_mission(id)
  # Self-contained terminal dispatch fixture, NOT an earned journey. Remove
  # threats/position an actor only to obtain a valid production terminal state;
  # receive/capture/extract still run through the actual simulation commands.
  game.sim.sirens=[];game.sim.paused=false
  if id==9:
   game.sim.units[0].pos=Vector2(480,700);game.sim.units[0].vel=Vector2.ZERO;game.sim.advance(.1)
   check(game.sim.command("camera"),"terminal9 fixture uses actual receiver acquisition")
   for n in 45:game.sim.advance(.1)
  else:
   # Warning Chain replaced camera holds with explicit local plant controls.
   game.sim.units[0].pos=Vector2(480,1000);game.sim.units[0].vel=Vector2.ZERO
   check(game.sim.command("chain_power",{"mode":"backup"}),"terminal10 fixture powers the actual plant")
   game.sim.units[0].pos=Vector2(1520,1000)
   check(game.sim.command("chain_route",{"output":"service"}),"terminal10 fixture selects the actual service output")
   check(game.sim.command("chain_send") and game.sim.all_records(),"terminal10 fixture earns the actual local warning receipt")
  game.sim.units[0].pos=Vector2(180,1000) if id==10 else game.sim.mission.extraction;game.sim.units[0].vel=Vector2.ZERO;game.sim.advance(.1)
  if game.sim.departure_context().get("confirmation_required",false):
   check(game.sim.command("depart",{"confirm":true}),"terminal fixture explicitly confirms leaving remote carriers")
  check(game.sim.outcome=="won" and preload("res://src/simulation/simulation.gd").valid_snapshot(game.sim.snapshot()),"self-contained onward%d terminal fixture satisfies real save schema"%id)
  game._process(0.)
  check(game.screen=="debrief" and game.completed==tutorial and game.unlocked==5,"normal Main%d frame dispatch preserves tutorial completion IDs"%id)
  check(id in game.expedition.completed and game.expedition.selected_thread==branch and game.expedition.history.any(func(item):return item.mission==id),"normal frame dispatch commits successful onward%d recovery and history through expedition adapter"%id)
  check(game.store.valid(game._archive()) and not game.store.load_game().is_empty(),"actual dispatched%d campaign archive survives checksummed save/load"%id)
  game.queue_free();await process_frame

 print("CAMPAIGN MAIN DISPATCH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
