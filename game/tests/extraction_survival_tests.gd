extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
var checks:=0
var failures:=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func fixture(cause:String):
 var s=Simulation.new();s.start(0)
 # Valid earned-record extraction state; the production tick decides survival.
 for objective in s.mission.objectives:objective.captured=true
 s.sirens[0].pos=Vector2(220,800);s.sirens[0].goal=s.units[0].pos;s.sirens[0].route=[];s.sirens[0].target=0;s.sirens[0].lock=4.0
 if cause in ["oxygen","both"]:s.oxygen=Simulation.STEP/36.0
 if cause in ["hull","both"]:s.hull=0.15
 check(Simulation.valid_snapshot(s.snapshot()) and s.line_clear(s.sirens[0].pos,s.units[0].pos),cause+" uses a restorable real charged-beam state")
 return s
func clone(seed):
 var s=Simulation.new();check(s.restore(seed.snapshot()),"actual snapshot restores before comparison");return s
func run():
 root.size=Vector2i(1280,720)
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="extraction-survival-test";root.add_child(game);game.set_process(false);game.ocean.hide()
 for n in 6:await process_frame
 var store=SaveStore.new();store.path="user://extraction-survival-test.save"
 for cause in ["hull","oxygen","both","surviving"]:
  var seed=fixture(cause);var won=cause=="surviving";var expected="won" if won else "lost"
  var single=clone(seed);single.paused=false;single.advance(Simulation.STEP)
  check(single.outcome==expected,cause+" resolves survival before extraction on the same tick")
  var reason="Archive recovered" if won else "Life support exhausted." if cause=="oxygen" else "Quietus lost."
  check(single.message.begins_with(reason),cause+" preserves the actual terminal reason")
  check(single.events.filter(func(event):return event.type=="extraction").size()==(1 if won else 0),cause+" emits extraction only for a surviving return")
  if won:check(single.hull<seed.hull and single.hull>0 and single.oxygen>0,"a surviving extraction still includes winning-tick beam damage")
  for batch in [0.1,0.25]:
   var batched=clone(seed);batched.paused=false;batched.advance(batch)
   check(batched.snapshot()==single.snapshot() and batched.events==single.events and batched.message==single.message,cause+" batched outcome matches STEP")
  var paused=clone(seed);var frozen=paused.snapshot();paused.advance(0.25);check(paused.snapshot()==frozen,cause+" pause defers both loss and extraction")
  var ended=single.snapshot();single.advance(0.25);check(single.snapshot()==ended,cause+" terminal state remains frozen")
  game.sim=single;game.ocean.sim=single;game.mission_index=0;game.unlocked=0;game.completed=[];game.recovered_evidence={};game._debrief()
  check(game.completed==([0] if won else []) and game.unlocked==(1 if won else 0),cause+" actual debrief grants completion/unlock credit only for survival")
  check(store.save(game._archive()),cause+" terminal campaign state saves through real binary archive")
  var saved=store.load_game();var restored=Simulation.new()
  check(saved.get("completed")==game.completed and saved.get("unlocked")==game.unlocked and restored.restore(saved.get("active",{})),cause+" archive restores terminal outcome and campaign credit")
  check(restored.outcome==expected and restored.hull==single.hull and restored.oxygen==single.oxygen,cause+" restored survival result/resources preserved")
  var saved_state=restored.snapshot();restored.advance(0.25);check(restored.snapshot()==saved_state,cause+" restored terminal state cannot resume ticking")
  print("EXTRACTION_SURVIVAL ",cause," outcome=",single.outcome," hull=",single.hull," oxygen=",single.oxygen," completed=",game.completed," unlocked=",game.unlocked)
  for n in 6:await process_frame
 game.queue_free()
 for n in 6:await process_frame
 await create_timer(0.25).timeout
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(store.path+suffix)
 print("EXTRACTION SURVIVAL CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
