extends SceneTree
# WP-13: drones are launched from Quietus and do not start on the map
# (Pat, 2026-11-12; v7 prototype lines 231 to 234). A player dive starts with
# both drones aboard: not in the water, carried with Quietus, selectable, and
# launched by their first route order. A drone never launched is home at the
# end. A direct Simulation.start() without the flag keeps the drones deployed.
const Sim=preload("res://src/simulation/simulation.gd")
const Bay=preload("res://src/simulation/drone_bay/drone_bay.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func dive(operation:int=0)->Object:
 var s=Sim.new();s.start(operation,"endurance",{Bay.FLAG:true});return s
func open_water(s,from:Vector2,reach:float)->Vector2:
 for turn in 16:
  var p=from+Vector2(reach,0).rotated(TAU*turn/16.)
  if not s.blocked(p,24.) and s.line_clear(from,p):return p
 return from
func run():
 start_cases()
 carry_cases()
 launch_cases()
 home_cases()
 save_cases()
 await main_case()
 print("DRONE BAY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func start_cases():
 var legacy=Sim.new();legacy.start(0,"endurance")
 check(legacy.units[1].alive and legacy.units[2].alive and not Bay.any_aboard(legacy),"a start without the flag keeps both drones in the water")
 check(legacy.units[1].pos!=legacy.units[0].pos,"deployed drones keep their own positions")
 for operation in [0,1,15,22,41]:
  var s=dive(operation)
  if s.mission.is_empty():continue
  var tag="op%d"%operation
  for id in [1,2]:
   var u=s.units[id]
   check(Bay.aboard(u) and not u.alive and not Bay.lost(u) and Bay.home(u),"%s %s starts aboard, not in the water and not lost"%[tag,u.name])
   check(u.pos==s.units[0].pos and u.band==s.units[0].band,"%s %s is at Quietus"%[tag,u.name])
   check(float(u.battery)==100.,"%s %s starts with a full battery"%[tag,u.name])
  check("aboard" in s.message.to_lower(),"%s the opening message says the drones are aboard"%tag)
func carry_cases():
 var s=dive(0);s.sirens=[]
 var goal=open_water(s,s.units[0].pos,220.)
 check(goal!=s.units[0].pos,"setup: open water near the start")
 s.command("select",{"unit":0});s.command("route",{"point":goal})
 var from:Vector2=s.units[0].pos;s.paused=false
 for n in roundi(8.0/Sim.STEP):s.advance(Sim.STEP)
 check(s.units[0].pos.distance_to(from)>40.,"setup: Quietus moved %.0fm"%s.units[0].pos.distance_to(from))
 for id in [1,2]:
  check(Bay.aboard(s.units[id]) and s.units[id].pos==s.units[0].pos,"%s rides with Quietus"%s.units[id].name)
  check(float(s.units[id].battery)==100.,"%s spends no battery aboard"%s.units[id].name)
 check(s.hull==100.,"carrying the drones costs no hull (%.1f)"%s.hull)
 check(not s.events.any(func(e):return e.get("type","")=="loss"),"no drone is reported lost while aboard")
func launch_cases():
 var s=dive(0);s.sirens=[]
 check(s.command("select",{"unit":1}) and s.selected==1,"an aboard drone can be selected")
 check("aboard" in s.message.to_lower() and "launch" in s.message.to_lower(),"selecting it says how to launch: "+s.message)
 check(not s.command("hold") and Bay.aboard(s.units[1]) and s.selected==1,"an order that is not a route does not launch it and keeps it selected")
 check("aboard" in s.message.to_lower(),"the refusal says the drone is aboard: "+s.message)
 var goal=open_water(s,s.units[0].pos,260.)
 var hull=s.hull
 check(s.command("route",{"point":goal}),"a route order to an aboard drone is accepted")
 var u=s.units[1]
 check(u.alive and not Bay.aboard(u),"the route order launches the drone")
 check(u.pos.distance_to(s.units[0].pos)<=Bay.CLEARANCE+.01,"it enters the water beside Quietus (%.1fm)"%u.pos.distance_to(s.units[0].pos))
 check(u.band==s.units[0].band and u.transition.is_empty(),"it launches in Quietus's depth band")
 check(not u.route.is_empty(),"it holds the ordered route")
 check(s.events.any(func(e):return e.get("type","")=="drone_launch" and e.get("unit",-1)==1),"a launch event is recorded")
 check(Bay.aboard(s.units[2]),"the other drone stays aboard")
 var from:Vector2=u.pos;s.paused=false;var strikes=[]
 for n in roundi(6.0/Sim.STEP):
  s.advance(Sim.STEP)
  if s.message.begins_with("Hull strike") and s.message not in strikes:strikes.append(s.message)
 check(u.alive and u.pos.distance_to(from)>30.,"the launched drone swims its route (%.0fm)"%u.pos.distance_to(from))
 check(strikes.is_empty() and s.hull==hull,"launching strikes nothing and costs no hull %s"%str(strikes))
 check(float(u.battery)<100.,"a launched drone spends battery")
 check(Bay.aboard(s.units[2]) and s.units[2].pos==s.units[0].pos,"the drone still aboard stays with Quietus")
 # A drone cannot launch while Quietus is between depth bands.
 var t=dive(0);t.units[0]["transition"]={"to":2,"remaining":3.};t.command("select",{"unit":2})
 check(not t.command("route",{"point":open_water(t,t.units[0].pos,200.)}) and Bay.aboard(t.units[2]),"no launch while Quietus changes depth")
func home_cases():
 var s=dive(0)
 var corridor={"pos":s.units[0].pos,"available":true,"name":"TEST"}
 var result=s.ModuleRecovery.departure(s,corridor)
 check(1 in result.recovered_drones and 2 in result.recovered_drones,"drones still aboard are recovered with Quietus")
 var rows=preload("res://src/presentation/recovery_manifest.gd").entries(s)
 if not rows.is_empty():
  check(rows[1].get("aboard",false) and rows[1].in and not rows[1].lost,"the recovery manifest lists an aboard drone as in")
 # A drone destroyed after launch is lost, not aboard.
 s.sirens=[];s.command("select",{"unit":1});s.command("route",{"point":open_water(s,s.units[0].pos,200.)})
 s.units[1].alive=false
 check(Bay.lost(s.units[1]) and not Bay.home(s.units[1]),"a launched drone that is destroyed is lost")
 check(not s.command("select",{"unit":1}),"a lost drone cannot be selected")
func save_cases():
 var s=dive(0)
 var data=s.snapshot()
 check(Sim.valid_snapshot(data),"a dive with drones aboard saves as a valid snapshot")
 var r=Sim.new()
 check(r.restore(data) and Bay.aboard(r.units[1]) and Bay.aboard(r.units[2]),"restoring it keeps the drones aboard")
 var bad=data.duplicate(true);bad.units[1].alive=true
 check(not Sim.valid_snapshot(bad),"a snapshot with a drone both aboard and in the water is rejected")
 bad=data.duplicate(true);bad.units[0][Bay.KEY]=true
 check(not Sim.valid_snapshot(bad),"a snapshot with Quietus aboard itself is rejected")
func main_case():
 root.size=Vector2i(2520,1080);await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
 game.store.path="user://wp13-bay-%d.save"%Time.get_ticks_usec()
 root.add_child(game);await settle();game.set_process(false)
 game._start_mission(0);await settle();game._refresh();await settle()
 var s=game.sim
 check(Bay.aboard(s.units[1]) and Bay.aboard(s.units[2]),"a dive started by the game has both drones aboard")
 check(not game.unit_buttons[1].disabled and "ABOARD" in game.unit_buttons[1].text,"the fleet button for an aboard drone is enabled and reads ABOARD: "+game.unit_buttons[1].text.replace("\n"," / "))
 game._order("select",{"unit":1});await settle()
 check(s.selected==1,"the game selects an aboard drone")
 game._order("route",{"point":open_water(s,s.units[0].pos,240.)});await settle();game._refresh();await settle()
 check(s.units[1].alive and not Bay.aboard(s.units[1]),"a water route from the game launches it")
 check("ABOARD" not in game.unit_buttons[1].text and "ABOARD" in game.unit_buttons[2].text,"the fleet buttons follow the launch")
 game.queue_free();await settle()
