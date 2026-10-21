extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func make():
 var s=Sim.new();s.start(1)
 # Isolate camera rules in the actual divided Split region.
 for enemy in s.sirens:enemy.stun=100.0
 for pair in [[1,0],[2,1]]:
  s.units[pair[0]].pos=s.mission.objectives[pair[1]].pos+Vector2(0,100)
 return s
func tick(s,seconds:float):
 for n in roundi(seconds*60):s.advance(1.0/60)
func begin(s)->bool:
 s.command("select",{"unit":2})
 var b=s.command("camera")
 s.command("select",{"unit":1})
 return s.command("camera") and b
func _initialize():
 var s=make()
 check(begin(s),"opposite Split relays accept DRONE A while DRONE B exposes")
 check(s.noises.filter(func(n):return n.label=="CAMERA").size()==2,"each commanded exposure emits at its own craft")
 s.paused=false;tick(s,4.1)
 check(s.mission.objectives[0].captured and s.mission.objectives[1].captured,"both separated craft finish within one exposure interval")
 check(not s.mission.objectives[2].captured,"parallel relay records still require Quietus uplink")
 for mission_id in [1,2]:
  s=Sim.new();s.start(mission_id)
  for enemy in s.sirens:enemy.stun=100.0
  for id in [1,2]:s.units[id].pos=s.mission.objectives[0].pos+Vector2(0,100)
  s.command("select",{"unit":1});check(s.command("camera"),"first craft owns record in mission%d"%mission_id)
  var emissions=s.noises.duplicate(true);var events=s.events.duplicate(true)
  s.command("select",{"unit":2})
  check(not s.command("camera") and s.noises==emissions and s.events==events,"same record rejects second craft without another emission or award in mission%d"%mission_id)
  s.paused=false;tick(s,4.1)
  check(s.mission.reconnaissance.secured==[0] and s.mission.reconnaissance.floor==8.0,"single record raises evidence pressure once in mission%d"%mission_id)
  if mission_id==1:check(s.mission.objectives[0].photo_craft=="DRONE A","exclusive first owner supplies photograph grade")
 for interruption in ["death","move","cover"]:
  s=make();begin(s);s.paused=false;tick(s,1)
  if interruption=="death":s.units[1].alive=false
  elif interruption=="move":check(s.command("route",{"point":s.units[1].pos+Vector2(0,100)}),"accepted movement order replaces only DRONE A exposure")
  else:
   s.mission.rocks.append(Rect2(s.mission.objectives[0].pos+Vector2(-35,40),Vector2(70,20)));s._build_navigation()
  tick(s,3.1)
  check(not s.mission.objectives[0].captured and s.mission.objectives[1].captured,"%s interrupts A while B completes independently"%interruption)
 s=make();begin(s);s.paused=false;tick(s,1);s.paused=true
 var before=s.snapshot();s.advance(50)
 check(s.snapshot()==before,"tactical pause freezes both exposure clocks")
 var duplicated=before.duplicate(true);duplicated.captures[2].target=duplicated.captures[1].target
 check(not Sim.valid_snapshot(duplicated),"current save cannot assign the same record to two craft")
 var store=Store.new();store.path="user://test-independent-capture.save"
 var archive={"version":2,"unlocked":1,"completed":[0],"upgrade":"endurance","settings":{},"active":before}
 check(store.save(archive),"current archive writes simultaneous partial exposures")
 var loaded=store.load_game();var restored=Sim.new()
 check(not loaded.is_empty() and restored.restore(loaded.active) and restored.paused,"current archive restores both exposures paused")
 if not loaded.is_empty():
  restored.paused=false;tick(restored,3.1)
  check(restored.mission.objectives[0].captured and restored.mission.objectives[1].captured,"restored craft each finish remaining exposure time")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(store.path+suffix)
 s=make();s.units[1].alive=false;s.units[2].alive=false
 s.units[0].pos=s.mission.objectives[0].pos+Vector2(0,100)
 check(s.command("camera"),"Quietus retains camera fallback after both drone losses")
 s.paused=false;tick(s,4.1)
 check(s.mission.objectives[0].captured,"Quietus fallback completes unchanged finite exposure")
 print("INDEPENDENT CAPTURE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
