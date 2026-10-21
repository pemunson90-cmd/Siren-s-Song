extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var store=Store.new()
 check(Campaign.available([0,1,2,3,4,5],{})==[6],"legacy tutorial completion opens entry without a migration flag")
 var sim=Sim.new();sim.start(6);sim.units[0].pos=sim.mission.signal_sources[0].pos+Vector2(0,150);sim.paused=false;sim.advance(0.1)
 var snap=sim.snapshot();var restored=Sim.new();check(restored.restore(snap),"ordinary precise signal record is a valid active save")
 restored.paused=false;sim.advance(0.2);restored.advance(0.2)
 check(restored.snapshot()==sim.snapshot(),"signal clocks and received observations replay deterministically")
 var data={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"disruption","settings":{},"active":sim.snapshot(),"evidence":{"divergence_deep":{"name":"DEEP CARRIER","caption":sim.mission.expedition_facts.deep,"optical":"divergence_deep"}}}
 check(store.valid(data),"retained field note after incomplete investigation is valid without branch entitlement")
 check(Campaign.available(data.completed,data.get("expedition",{}))==[6],"field note does not unlock a continuation or module")
 data.expedition={"version":1,"route":"shelf","routes":["shelf"],"facts":{},"completed":[6]}
 check(not store.valid(data),"missing recovered route fact cannot grant a continuation")
 var bad=snap.duplicate(true);bad.mission.signal_observations=[{"receiver":1,"origin":Vector2.ZERO,"direction":Vector2(NAN,1),"time":0,"uncertainty":0.1,"label":"x"}]
 check(not Sim.valid_snapshot(bad),"nonfinite received bearings are rejected before restore")
 bad=snap.duplicate(true);bad.mission.recovered=true;bad.mission.chosen_route="shelf"
 check(not Sim.valid_snapshot(bad),"recovered flag without corresponding source evidence is rejected")
 bad=snap.duplicate(true);bad.mission.expedition_facts["shelf"]="unsupported field note"
 check(not Sim.valid_snapshot(bad),"route facts must correspond to a located authored source")
 var premature=data.duplicate(true);premature.erase("expedition");var continuation=Sim.new();continuation.start(7);premature.active=continuation.snapshot()
 check(not store.valid(premature),"top-level archive cannot resume an unearned continuation without its recovered route")
 for id in [7,8]:
  var follow=Sim.new();follow.start(id);check(Sim.valid_snapshot(follow.snapshot()),"authored continuation starts in valid snapshot")
 print("DIVERGENCE SAVE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
