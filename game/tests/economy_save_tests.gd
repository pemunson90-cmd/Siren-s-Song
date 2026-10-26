extends SceneTree
const Economy=preload("res://src/campaign/economy.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var store=Store.new();store.path="user://economy_roundtrip.save"
 var e=Economy.new_state("survival");e.stock.alloy=3;e.unlocks=["hull:fast"];e.spares={"drone_deep_cells":1};e.cond.quietus=45
 e.last_fit=Catalog.canonical({"hull":"fast","drone_a":"drone_deep_cells"})
 var data={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","economy":e}
 check(store.valid(data),"archive with economy validates")
 check(store.save(data) and store.load_game().get("economy",{})==e,"economy round trips through the checksummed archive")
 check(not store.encoded(data).is_empty(),"economy is part of the exportable profile bytes")
 var plain=data.duplicate(true);plain.erase("economy")
 check(store.valid(plain),"an archive without the economy field still loads")
 for mutation in ["stock","preset","cond","spares","unlocks","report","last_fit","extra"]:
  var bad=data.duplicate(true)
  match mutation:
   "stock":bad.economy.stock.scrap=-1
   "preset":bad.economy.preset="bogus"
   "cond":bad.economy.cond.quietus=101
   "spares":bad.economy.spares={"not_an_item":1}
   "unlocks":bad.economy.unlocks=["hull:invisible"]
   "report":bad.economy.report=7
   "last_fit":bad.economy.last_fit={"hull":"submarine"}
   "extra":bad.economy["surprise"]=1
  check(not store.valid(bad),"corrupt economy field rejected: "+mutation)
 DirAccess.remove_absolute(store.path);DirAccess.remove_absolute(store.path+".bak")
 print("ECONOMY SAVE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
