extends SceneTree
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/campaign/early_reward/early_reward.gd"
 var Reward=load(path) if ResourceLoader.exists(path) else null
 check(Reward!=null,"early module reward exists")
 if Reward==null:finish();return
 var Table=load("res://src/campaign/early_reward/reward_table.gd")
 check(Table.GRANT.operation==1 and Table.GRANT.module=="quietus_tele_lens","approved first reward uses the existing photographic lens after op1")
 for op in [0,1,2,3,4,5]:
  for outcome in ["won","lost",""]:
   var state=Reward.grant({},op,outcome)
   check(not state.is_empty() if op==1 and outcome=="won" else state.is_empty(),"grant filter %d/%s"%[op,outcome])
 var state=Reward.grant({},1,"won")
 check(Reward.grant(state,1,"won")==state,"replay grants only once")
 check(Reward.earned(state,[]).count(Table.GRANT.module)==1,"one entitlement is available")
 check(Reward.earned(state,[Table.GRANT.module]).count(Table.GRANT.module)==1,"existing ownership is never duplicated")
 var choice=Catalog.choose(Catalog.default_loadout(),"quietus",Table.GRANT.module,Reward.earned(state,[]))
 check(choice.ok and Catalog.valid_fitting(choice.fitted),"free lens fits the unchanged standard hull")
 check(Catalog.budget(choice.fitted,0).power==1 and Catalog.budget(choice.fitted,0).endurance==1.,"reward requires no extra oxygen or opening stock")
 Table.enabled=false
 check(Reward.grant({},1,"won").is_empty(),"off switch stops new grants")
 check(Table.GRANT.module in Reward.earned(state,[]),"off switch preserves saved ownership")
 Table.enabled=true
 check(Reward.valid({"completed":[0,1],"early_reward":state}),"optional earned state validates")
 check(Reward.valid({"completed":[]}),"older archive without reward stays valid")
 for invalid in [true,[],{"granted":true},{"granted":true,"module":"unknown"},{"granted":1,"module":Table.GRANT.module}]:
  check(not Reward.valid({"completed":[0,1],"early_reward":invalid}),"malformed optional state rejected")
 check(not Reward.valid({"completed":[0],"early_reward":state}),"reward cannot claim an unfinished op")
 var bare=Sim.new();bare.start(2)
 var original=bare.snapshot();Reward.grant({},1,"won")
 check(bare.snapshot()==original,"grant cannot modify an active bare dive")
 finish()
func finish():
 print("EARLY REWARD CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
