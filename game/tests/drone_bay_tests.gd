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
 deploy_cases()
 home_cases()
 save_cases()
 await main_case()
 await wheel_cases()
 print("DRONE BAY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func start_cases():
 var legacy=Sim.new();legacy.start(0,"endurance",{Bay.FLAG:false})
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
 check("aboard" in s.message.to_lower() and "deploy" in s.message.to_lower(),"selecting it says how to deploy (WP-35: was launch): "+s.message)
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
# WP-35: DEPLOY is the same launch a water tap reaches, with no route.
func deploy_cases():
 var s=dive(0);s.sirens=[];var tapped=dive(0);tapped.sirens=[]
 var goal=open_water(s,s.units[0].pos,240.)
 s.command("select",{"unit":0});check(s.command("deploy",{"unit":1}),"DEPLOY puts drone A in the water")
 tapped.command("select",{"unit":1});tapped.command("route",{"point":goal})
 var a:Dictionary=s.units[1].duplicate(true);var b:Dictionary=tapped.units[1].duplicate(true)
 for key in ["route","route_plan","route_undo","trail"]:a.erase(key);b.erase(key)
 var differing=[]
 for key in a:
  if a[key]!=b.get(key):differing.append("%s %s vs %s"%[key,a[key],b.get(key)])
 for key in b:
  if not a.has(key):differing.append("only after a route: %s %s"%[key,b[key]])
 check(a==b,"a deployed drone has the state a water-tap launch gives, apart from the route: "+str(differing))
 check(s.units[1].route.is_empty() and s.units[1].alive and not Bay.aboard(s.units[1]),"the deployed drone holds with no route")
 check(s.units[1].pos.distance_to(s.units[0].pos)<=Bay.CLEARANCE+.01 and s.units[1].band==s.units[0].band,"it appears beside Quietus in Quietus's band")
 check(Bay.aboard(s.units[2]) and s.selected==1,"drone B is still aboard and the deployed drone becomes the selected craft")
 check(s.events.filter(func(e):return e.get("type","")=="drone_launch").size()==tapped.events.filter(func(e):return e.get("type","")=="drone_launch").size(),"the same launch event is recorded")
 check("DRONE A" in s.message and "deployed" in s.message,"the message line says what happened: "+s.message)
 var before:Dictionary=s.snapshot().duplicate(true)
 check(not s.command("deploy",{"unit":1}) and not s.command("deploy",{"unit":0}) and not s.command("deploy",{"unit":7}) and not s.command("deploy",{}),"DEPLOY refuses a drone already out, Quietus and unknown units")
 check(s.snapshot().units==before.units,"a refused DEPLOY changes no unit")
 var r=dive(0);r.sirens=[];r.units[0].transition={"remaining":2.0,"to":2}
 var held:Array=r.snapshot().units.duplicate(true)
 check(not r.command("deploy",{"unit":2}) and "cannot deploy" in r.message,"a launch the bay refuses is refused with its reason: "+r.message)
 check(r.snapshot().units==held and Bay.aboard(r.units[2]),"and nothing changes")
 var lost=dive(0);lost.units[0].alive=false
 check(not lost.command("deploy",{"unit":1}) and Bay.aboard(lost.units[1]),"DEPLOY with Quietus lost is refused")
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
# WP-35: DEPLOY and RECALL on the wheel, driven through the real Main scene.
func press(button):
 button.pressed.emit();await settle()
func wheel_cases():
 root.size=Vector2i(2520,1080);await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
 game.store.path="user://wp35-deploy-%d.save"%Time.get_ticks_usec()
 root.add_child(game);await settle();game.set_process(false)
 game._start_mission(0);await settle();game._refresh();await settle()
 var s=game.sim;var h=game.mission_hud
 # Quietus: DEPLOY leads the main page while a drone is aboard, naming the next one.
 h.open("craft");await settle()
 var controls=h.command_controls()
 check(controls[3]==h.extra.deploy and h.extra.deploy.text=="DEPLOY\nDRONE A" and h.extra.deploy.is_visible_in_tree(),"Quietus's wheel offers DEPLOY DRONE A in PLAN ROUTE's place (WP-52): "+h.extra.deploy.text.replace("\n"," "))
 check(not (h.extra.recall in controls),"no RECALL ALL on the main page with both drones aboard")
 check(controls.size()==8 and not (game.order_buttons.program in controls),"the main page keeps eight segments, PLAN ROUTE stepping off it (%d)"%controls.size())
 await press(h.extra.deploy)
 check(s.units[1].alive and not Bay.aboard(s.units[1]) and Bay.aboard(s.units[2]) and s.units[1].route.is_empty(),"tapping DEPLOY puts drone A in the water with no route, drone B stays aboard")
 check(s.units[1].pos.distance_to(s.units[0].pos)<=Bay.CLEARANCE+.01 and not game.advanced_orders,"the drone is beside Quietus and the wheel closes")
 check("DRONE A" in s.message and "deployed" in s.message and s.selected==1,"the message line says what happened and the drone is selected: "+s.message)
 game._order("select",{"unit":0});h.open("craft");await settle();controls=h.command_controls()
 check(controls[3]==h.extra.deploy and h.extra.deploy.text=="DEPLOY\nDRONE B","DEPLOY now names DRONE B")
 check(not (h.extra.recall in controls) and controls.size()==8,"with DEPLOY on the main page RECALL ALL stays on the ROUTE page (%d segments)"%controls.size())
 h.dismiss();h.open("route");await settle()
 check(h.extra.recall in h.command_controls() and game.order_buttons.program in h.command_controls(),"RECALL ALL and PLAN ROUTE are on the ROUTE page")
 h.dismiss();h.open("craft");await settle()
 await press(h.extra.deploy)
 check(Bay.any_aboard(s)==false and s.units[2].alive,"DEPLOY DRONE B deploys the second drone")
 game._order("select",{"unit":0});h.open("craft");await settle();controls=h.command_controls()
 check(not (h.extra.deploy in controls) and not h.extra.deploy.is_visible_in_tree() and h.extra.recall in controls and h.extra.recall.text=="RECALL\nALL" and controls.size()==8 and not (game.order_buttons.program in controls),"with no drone aboard DEPLOY is absent and RECALL ALL takes its place on the main page")
 # A deployed drone has RECALL on its main page, and it does what the ROUTE page's does.
 game._order("select",{"unit":1});s.units[1].pos=s.units[0].pos+Vector2(180,0)
 if s.blocked(s.units[1].pos,12.):s.units[1].pos=s.units[0].pos+Vector2(-180,0)
 h.open("craft");await settle();controls=h.command_controls()
 check(h.extra.recall in controls and not (h.extra.deploy in controls) and h.extra.recall.text=="RECALL","a deployed drone's main page offers RECALL and no DEPLOY")
 check(h.extra.recall.is_visible_in_tree() and not h.extra.recall.disabled,"RECALL is live: "+h.extra.recall.tooltip_text)
 await press(h.extra.recall)
 var from_main:Array=s.route_goals().duplicate(true)
 check(not from_main.is_empty() and from_main.back().pos.distance_to(s.units[0].pos)<60.,"RECALL from the main page routes the drone back to Quietus")
 s.units[1].route=[];s.units[1].erase("route_plan");s.units[1].erase("route_undo");s.units[1].hold=""
 h.open("route");await settle()
 check(h.extra.recall in h.command_controls(),"RECALL stays on the ROUTE page")
 await press(h.extra.recall)
 check(s.route_goals()==from_main,"the ROUTE page's RECALL plots the same route")
 # An aboard drone's own wheel offers DEPLOY first.
 game._start_mission(0);await settle();game._refresh();await settle();s=game.sim;h=game.mission_hud
 game._order("select",{"unit":2});await settle();h.open("craft");await settle()
 controls=h.command_controls()
 check(s.selected==2 and controls[3]==h.extra.deploy and h.extra.deploy.text=="DEPLOY\nDRONE B" and not (h.extra.recall in controls),"an aboard drone's wheel offers its own DEPLOY in the same place")
 await press(h.extra.deploy)
 check(s.units[2].alive and not Bay.aboard(s.units[2]) and Bay.aboard(s.units[1]) and s.selected==2,"it deploys that drone, which stays selected")
 # A refused deploy changes nothing and says why.
 game._order("select",{"unit":0});s.units[0].transition={"remaining":2.0,"to":2};h.open("craft");await settle()
 var units_before:Array=s.snapshot().units.duplicate(true)
 await press(h.extra.deploy)
 check(Bay.aboard(s.units[1]) and s.snapshot().units==units_before and "cannot deploy" in s.message,"a refused DEPLOY changes no unit and shows the reason: "+s.message)
 game.queue_free();await settle()
