extends SceneTree
# Standalone compatibility probe: never preloads the removed ending or its view.
const Store=preload("res://src/persistence/save_store.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 check(not ResourceLoader.exists("res://src/campaign/endings_photo.gd") and not ResourceLoader.exists("res://src/presentation/endings_photo_view.gd"),"ending modules physically absent")
 var legacy={"version":1,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance"}
 roundtrip(legacy,"legacy")
 var p={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed"},"completed":[6,7,9,11,12,14,15,16,17,18,19,22,23,24,25],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
 for id in [30,31]:
  var s=Sim.new();s.start(id)
  var data={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"settings":{},"upgrade":"endurance","expedition":p.duplicate(true),"active":s.snapshot()}
  check(Sim.valid_snapshot(s.snapshot()),"active snapshot without ending module "+str(id))
  roundtrip(data,"active"+str(id))
  p.completed.append(id)
 check(Campaign.valid(p),"completed final campaign valid without ending module")
 var data={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"settings":{},"upgrade":"endurance","expedition":p}
 roundtrip(data,"completed")
 print("ENDING REMOVAL SAVE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func roundtrip(data,label):
 var store=Store.new();store.path="user://027-removal-"+label+".save"
 check(store.valid(data),"archive validates "+label)
 check(store.save(data),"checksummed disk save "+label)
 check(store.load_game()==data,"checksummed disk load "+label)
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
