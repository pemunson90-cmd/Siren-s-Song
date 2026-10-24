extends SceneTree
const OrderTable=preload("res://src/simulation/orders/order_table.gd")
const Tuning=preload("res://src/simulation/tuning.gd")
const Weapons=preload("res://src/simulation/orders/weapon_orders.gd")
const Sensors=preload("res://src/simulation/orders/sensor_orders.gd")
const Route=preload("res://src/simulation/orders/route_orders.gd")
const Photo=preload("res://src/simulation/orders/photo_orders.gd")
const Features=preload("res://src/simulation/orders/feature_orders.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var families=[Weapons,Sensors,Route,Photo,Features]
 var counts={}
 for order in OrderTable.TABLE:
  var row=OrderTable.TABLE[order]
  check(row is Array and row.size()==2 and row[0] in families and row[1] is bool,"row %s is [family, bool]"%order)
  counts[row[0]]=counts.get(row[0],0)+1
  # The family's own source must handle the order it is routed to.
  var src:String=row[0].source_code
  if not src.is_empty():check(src.contains("\"%s\""%order),"family source for %s names that order"%order)
 check(counts.size()==families.size(),"every order family has at least one table row")
 check(OrderTable.TABLE.size()>=40 and OrderTable.TABLE.has("depart"),"table keeps the depart door used by Simulation.command")
 # Finish-hook flag: hostile or movement-changing orders run it; dispatch-only feature orders do not.
 for order in ["emp","knock","decoy","ping","recon","route","hold","silent","camera"]:check(OrderTable.TABLE[order][1],"%s runs the shared finish hooks"%order)
 for order in ["all_stop","frame","depth","depart","salvage","chain_send"]:check(not OrderTable.TABLE[order][1],"%s skips the shared finish hooks"%order)
 check(OrderTable.TABLE.get("no_such_order",[]).is_empty(),"unknown orders have no handler row")
 # Families reject orders that belong to a different family, without touching the sim.
 var fake={"units":[{"alive":true}],"selected":0,"tools":{}}
 for fam in [Weapons,Sensors]:check(fam.command(fake,"definitely_not_an_order",{})==false,"%s rejects unknown orders"%fam.resource_path.get_file())
 check(Weapons.command(fake,"ping",{})==false and Sensors.command(fake,"emp",{})==false,"weapons and sensors do not accept each other's orders")
 # Weapons with an empty inventory spend nothing.
 var dry={"units":[{"alive":true}],"selected":0,"tools":{"emp":0,"knock":0,"decoy":0},"sirens":[],"message":""}
 check(Weapons.command(dry,"emp",{})==false and dry.tools.emp==0,"EMP with none left is refused and not driven negative")
 check(Sensors.command({"units":[{}],"selected":0,"tools":{"recon":0},"mission":{}},"recon",{})==false,"recon with none left is refused")
 # Tuning invariants.
 var vals={"EMP_RADIUS":Tuning.EMP_RADIUS,"EMP_STUN":Tuning.EMP_STUN,"WEAPON_NOISE":Tuning.WEAPON_NOISE,"WEAPON_NOISE_TIME":Tuning.WEAPON_NOISE_TIME,"DECOY_NOISE":Tuning.DECOY_NOISE,"DECOY_TIME":Tuning.DECOY_TIME,"PING_FEEDBACK_TIME":Tuning.PING_FEEDBACK_TIME,"RELAY_RANGE":Tuning.RELAY_RANGE,"RELAY_REPLAY_TIME":Tuning.RELAY_REPLAY_TIME,"RECON_TIME":Tuning.RECON_TIME,"RECON_NOISE":Tuning.RECON_NOISE,"RECON_NOISE_TIME":Tuning.RECON_NOISE_TIME,"DRONE_QUIET_SPEED":Tuning.DRONE_QUIET_SPEED,"DRONE_TRANSIT_SPEED":Tuning.DRONE_TRANSIT_SPEED,"REPEAT_PHOTO_ACTION":Tuning.REPEAT_PHOTO_ACTION,"PHOTO_FALLBACK_NOISE":Tuning.PHOTO_FALLBACK_NOISE,"PHOTO_NOISE_TIME":Tuning.PHOTO_NOISE_TIME}
 for k in vals:check(vals[k]>0,"tuning %s is positive"%k)
 check(Tuning.DRONE_QUIET_SPEED<Tuning.DRONE_TRANSIT_SPEED,"drone quiet speed is slower than transit")
 check(Tuning.EMP_STUN==12.0 and Tuning.DECOY_TIME==15.0 and Tuning.RECON_TIME==8.0 and Tuning.RELAY_REPLAY_TIME==3.0,"stun and timing values match the on-screen 12 s, 15 s, 8 s and 3 s messages")
 check(Tuning.DECOY_NOISE>Tuning.WEAPON_NOISE and Tuning.RECON_NOISE>Tuning.WEAPON_NOISE,"decoy and recon are louder than a weapon discharge")
 print("ORDER TABLE CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
