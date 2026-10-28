extends SceneTree
# Economy calibration by simulated full campaign (AI-DESIGNED targets, Pat ratifies or retunes).
# economy_campaign_sim.gd walks the real operation graph and drives the real Economy functions
# for every preset (Accessible, Standard, Survival, Survival+Ironman), three player profiles
# (careful, average, struggling) and all four fork routes (deep/shelf x concealed/overt).
# Targets, all AI-DESIGNED:
#  1. Never soft-locks: every preset and profile reaches the final operation, and a bare standard
#     launch is always possible.
#  2. Standard, careful and average: every researchable artifact is researched within 2 operations
#     of recovery, one hull unlock is held by the end of arc 5, launches are never cut back for cost,
#     and alloy never sits above 10 for more than 2 operations in a row.
#  3. Survival and Survival+Ironman, struggling: tight, forced choices (some wants go unmet or
#     launches are cut back) yet the campaign still finishes. Survival average is also tighter
#     than Standard average.
#  4. Accessible: never blocked by cost for any profile.
# Arcs: 1 ops 0-5 opening, 2 ops 6-13 and 38-40 divergence, 3 ops 14-21 and 37 glass, 4 ops 22-29
# iron choir, 5 ops 30-36 final survey and Calder trench. Resource lines print scrap/cells/alloy.
const Sim=preload("res://tests/economy_campaign_sim.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Table=preload("res://src/campaign/economy_table.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tag(r:Dictionary)->String:
 return "%s%s/%s/%s%s"%[r.preset,"+iron" if r.ironman else "",r.profile,"deep" if r.deep else "shelf","+conc" if r.concealed else "+overt"]
func _initialize():
 check(Sim.artifact_of(20)=="prism_core" and Sim.artifact_of(35)=="deep_keel_plate" and Sim.artifact_of(6)=="","artifacts come from the real operation catalog")
 check(Sim.order(true,true).size()==Sim.order(false,false).size() and Sim.order(true,true).has(34),"every route plays the same number of operations and ends at the final op")
 for preset in Table.ORDER:
  var zero=Economy.new_state(preset,true);zero.stock={"scrap":0,"cells":0,"alloy":0}
  check(Economy.charge_launch(zero,Catalog.default_loadout()),"%s: a bare standard launch is always possible"%preset)
 var runs={}
 for deep in [true,false]:
  for concealed in [true,false]:
   for config in [["accessible",false],["standard",false],["survival",false],["survival",true]]:
    for profile in Sim.PROFILES:
     var r=Sim.run(config[0],config[1],profile,deep,concealed)
     runs[tag(r)]=r
     if deep and concealed:print(Sim.line(r))
     check(r.reached_final and r.graph_ok and r.valid and r.unreachable==0 and r.wins==Sim.order(deep,concealed).size(),"never soft-locks: "+tag(r))
 for key in runs:
  var r=runs[key]
  if r.preset=="accessible":
   check(r.reduced==0 and r.bare==0 and r.blocked==0,"accessible is never blocked by cost: "+key)
  if r.preset=="standard" and not r.ironman and r.profile in ["careful","average"]:
   check(r.lags.size()==8 and r.lags.max()<=2 and "quietus_wellhead_seal" in r.researched and "drone_choir_tuner" in r.researched,"standard researches each artifact within 2 ops: "+key+" "+str(r.lags))
   check(r.hull_arc>0 and r.hull_arc<=5,"standard holds a hull unlock by the end of arc 5: "+key)
   check(r.reduced==0 and r.bare==0,"standard launches are never cut back for cost: "+key)
   check(r.alloy_streak<=2 and r.max_alloy<=12,"standard alloy is spent, not hoarded: "+key+" max "+str(r.max_alloy))
  if r.preset=="survival" and r.profile=="struggling":
   check(r.reduced+r.blocked>0,"survival struggling faces forced choices: "+key)
 for deep in [true,false]:
  for concealed in [true,false]:
   var std=runs[tag(Sim.run("standard",false,"average",deep,concealed))]
   var surv=runs[tag(Sim.run("survival",false,"average",deep,concealed))]
   check(surv.reduced+surv.blocked>std.reduced+std.blocked,"survival average is tighter than standard average")
 print("ECONOMY CAMPAIGN CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
