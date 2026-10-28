extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func _initialize():
 var p={"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,16,17,18,19],"facts":{"deep":"received carrier","confluence_route":"concealed","resolution":"concealed_recovery"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
 for id in [14,15,16,20]:
  var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p)})
  var initial=s.public_chart();var seed=s.mission.launch_seed
  check(s.mission.earned_terrain and not initial.clear_cells.is_empty() and initial.return_cells.is_empty() and initial.surface_segments.is_empty(),"only launch water starts measured "+str(id))
  check(initial.clear_cells.all(func(cell):return seed.encloses(Rect2(Vector2(cell)*40,Vector2.ONE*40))),"every initial water cell lies within launch seed "+str(id))
  var objective=s.mission.objectives[0].pos;var before=s.snapshot()
  s.player_path(s.units[0].pos,objective)
  check(s.snapshot()==before and not s.terrain_chart.is_clear(objective),"planning cannot reveal distant record or terrain "+str(id))
  var tools=s.tools.duplicate();var origin=s.units[1].pos;var destination=origin+Vector2(0,120 if id==20 else -120)
  s.command("select",{"unit":1})
  check(s.command("route",{"point":destination}),"drone accepts frontier intent "+str(id))
  s.command("select",{"unit":0});tick(s,5)
  check(s.selected==0 and s.units[1].pos.distance_to(origin)>50 and s.units[1].alive and s.tools==tools,"independent drone autopilot earns local travel without tools "+str(id))
  check(s.public_chart().clear_cells.size()>initial.clear_cells.size(),"real passive observation expands chart "+str(id))
  var middle=s.terrain_chart.snapshot()
  check(s.command("depth",{"band":2}),"bare Quietus requests deep band "+str(id));tick(s,4.2)
  check(s.units[0].band==2 and s.units[0].transition.is_empty() and s.terrain_chart==s.depth_charts[2],"actual depth change selects separate earned chart "+str(id))
  check(s.depth_charts[1].snapshot()==middle,"deep observation preserves middle measurements "+str(id))
  var store=Store.new();store.path="user://glass-earned-"+str(id)+".save"
  var state=s.snapshot()
  var envelope={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":p,"active":state}
  check(store.save(envelope),"existing checked save serializes active earned operation "+str(id))
  var loaded=store.load_game();var restored=Sim.new()
  check(not loaded.is_empty() and restored.restore(loaded.active),"existing checked save reloads mid-operation "+str(id))
  check(restored.snapshot()==state and restored.public_chart()==s.public_chart(),"resume retains measurements in every depth band and drone course "+str(id))
 for id in [0,10,17,18,19,21]:
  var s=Sim.new();s.start(id)
  check(not s.mission.get("earned_terrain",false) and s.public_chart().is_empty(),"legacy authored chart preserved "+str(id))
 for item in [[14,{"thread":"shelf"}],[15,{"facts":{"warning_chain":"service_local_receipt"}}],[16,{"facts":{"confluence_route":"overt"}}]]:
  var plain=Sim.Missions.make(item[0]);var carried=Sim.Missions.make(item[0],item[1])
  check(carried.earned_terrain and carried.launch_seed==plain.launch_seed and carried.rocks==plain.rocks and carried.depth_geometry==plain.depth_geometry,"carry keeps earned policy and physical depth geometry "+str(item[0]))
  check(carried.corridors.size()==plain.corridors.size()+1 if item[0]==14 else carried.sirens.size()==plain.sirens.size()-1,"recovered route/fact still applies its authored delta "+str(item[0]))
 var legacy=Sim.new();legacy.start(14)
 # Reconstruct an in-progress pre-rollout mission, whose stored policy is absent.
 for key in ["earned_terrain","launch_seed","terrain_chart"]:legacy.mission.erase(key)
 legacy._configure_terrain();legacy._configure_depth_charts()
 var resumed=Sim.new()
 check(resumed.restore(bytes_to_var(var_to_bytes(legacy.snapshot()))) and resumed.public_chart().is_empty(),"earlier in-progress mission keeps precharted policy on resume")
 print("GLASS EARNED CHART CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
