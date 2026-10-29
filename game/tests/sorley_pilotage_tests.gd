extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const S=preload("res://src/campaign/sorley_rescue.gd")
const Endings=preload("res://src/campaign/endings.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var plain={"facts":{}}
 for tier in ["rescued","rescued_quiet"]:
  var rescued={"facts":{"sorley_boy":tier}}
  var e={"stock":{"scrap":7,"cells":3,"alloy":1},"report":""}
  S.credit(e,plain,rescued)
  check(e.stock=={"scrap":7,"cells":3,"alloy":1},"charts replace supplies "+tier)
  check(e.report.contains("PILOTAGE CHARTS") and e.report.contains("Needle Strait") and e.report.contains("Furnace Drift"),"settlement names chart reward "+tier)
  var report=e.report;S.credit(e,rescued,rescued)
  check(e.report==report,"replay does not duplicate reward report")
  for id in [15,16]:
   var before=Sim.new();before.start(id)
   var after=Sim.new();after.start(id,"endurance",{"context":rescued})
   var a=Vector2(1000,3200) if id==15 else Vector2(300,2400)
   var b=Vector2(1000,800) if id==15 else Vector2(300,700)
   check(before.terrain_chart.clear_distance(a,b)<a.distance_to(b) and after.terrain_chart.clear_distance(a,b)==a.distance_to(b),"reward certifies useful continuous passage "+str(id)+tier)
   check(after.sirens==before.sirens and after.contacts==before.contacts and after.sonar==before.sonar,"reward reveals no contacts or changes threats "+str(id))
   check(after.mission.rocks==before.mission.rocks and after.mission.structures==before.mission.structures,"physical terrain preserved")
   check(after.mission.brief.contains("SORLEY / PILOTAGE") and after.mission.brief.contains("MIDDLE"),"brief identifies charted band")
   check(after.depth_charts[0].snapshot()==before.depth_charts[0].snapshot() and after.depth_charts[2].snapshot()==before.depth_charts[2].snapshot(),"charts do not certify other bands")
   var snapshot=after.snapshot();var restored=Sim.new()
   check(Sim.valid_snapshot(snapshot) and restored.restore(snapshot) and restored.snapshot()==snapshot,"earned charts persist through ordinary snapshot")
   var old=before.snapshot();var legacy=Sim.new()
   check(legacy.restore(old) and legacy.snapshot()==old,"active pre-reward save keeps its chart until next launch")
   print("PILOTAGE op=",id," tier=",tier," before_cells=",before.public_chart().clear_cells.size()," after_cells=",after.public_chart().clear_cells.size()," before_clear=",before.terrain_chart.clear_distance(a,b)," after_clear=",after.terrain_chart.clear_distance(a,b))
 var ending={"completed":[6,7,9,11,12],"route":"deep","facts":{"confluence_route":"concealed"}}
 var before_ending=Endings.resolve(ending).id
 ending.facts.sorley_boy="rescued"
 check(Endings.resolve(ending).id==before_ending,"rescue remains separate from ending votes")
 print("SORLEY PILOTAGE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
