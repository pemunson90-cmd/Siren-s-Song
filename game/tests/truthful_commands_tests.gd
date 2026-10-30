extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Copy=preload("res://src/presentation/truthful_commands.gd")
const Work=preload("res://src/presentation/work_task/work_task.gd")
const Chart=preload("res://src/simulation/terrain_chart.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frames():
 for i in 3:await process_frame
func run():
 root.size=Vector2i(2520,1080)
 var sim=Sim.new();sim.start(15)
 # The object lies in a returned rock cell. Only the small western patch has
 # been measured. The helper must choose that patch, never the hidden east.
 var chart=Chart.new()
 var rock=PackedVector2Array([Vector2(580,480),Vector2(620,480),Vector2(620,520),Vector2(580,520)])
 chart.configure({"world_size":Vector2(1600,960),"launch_seed":Rect2(360,360,160,240)},[rock])
 chart.return_cells[Vector2i(15,12)]=true
 sim.depth_charts[1]=chart;sim.terrain_chart=chart;sim.units[0].pos=Vector2(440,440);sim.units[0].band=1
 var target={"pos":Vector2(600,500),"band":1,"work_range":240.}
 var before=sim.snapshot().duplicate(true);var measured=chart.snapshot().duplicate(true)
 var message_before=sim.message
 var approach=Copy.approach(sim,target)
 check(sim.snapshot()==before,"successful lookup preserves complete simulation snapshot")
 check(approach.ready,"rock-sited object has a measured open-water approach")
 if approach.ready:
  check(chart.is_clear(approach.point) and not chart.point_blocked(approach.point),"approach is certified legal water")
  check(approach.point.distance_to(target.pos)<=240.,"approach stays within unchanged work range")
  check(approach.point!=target.pos,"route avoids object's rock centre")
  check(sim.command("route",{"point":approach.point}),"existing route command accepts the proposed approach")
 sim.units[0].route=[];sim.units[0].erase("route_plan");sim.units[0].erase("route_undo");sim.message=message_before
 check(chart.snapshot()==measured,"approach lookup does not certify or reveal geometry")
 var empty=Chart.new();empty.configure({"world_size":Vector2(1600,960),"launch_seed":Rect2()},[rock])
 sim.depth_charts[1]=empty;sim.terrain_chart=empty
 var frozen=sim.snapshot().duplicate(true)
 var absent=Copy.approach(sim,target)
 check(not absent.ready and "survey another side" in absent.reason,"unmeasured approach names needed survey and side")
 check(sim.snapshot()==frozen and empty.clear_cells.is_empty(),"unsuccessful lookup preserves complete simulation snapshot")
 sim.units[0].band=0
 check("MIDDLE" in Copy.approach(sim,target).reason,"wrong-band approach names required band")
 sim.units[0].band=1;sim.units[0].transition={"to":0,"remaining":2.}
 check("Finish changing depth" in Copy.approach(sim,target).reason,"transition cannot masquerade as a ready work approach")
 check("2.0s" in Copy.depth_reason(sim,-1),"disabled depth change names remaining time")
 sim.units[0].transition={};sim.units[0].band=0
 check(Copy.depth_reason(sim,-1)=="Already SHALLOW","outer depth limit has concrete reason")
 check(Copy.verb({"glass_effect":{}})=="WORK","machinery never says camera")
 check(Copy.verb({"kind":"receiver"})=="LISTEN","hydrophone names listening")
 check(Copy.verb({"kind":"exchange"})=="DECODE","packet work names decode")
 check("ACCEPTED" in Work.result_line({"owner":"DRONE A","ok":true,"text":"Tow released"}),"successful instant action does not claim work started")
 var button=Button.new();button.text="LOCK A";button.disabled=true
 Copy.reason_button(button,"Finish LOCK B first");Copy.reason_button(button,"Finish LOCK B first")
 check(button.text=="LOCK A\nFinish LOCK B first","grey reason remains visible and never accumulates")
 button.disabled=false;Copy.reason_button(button,"")
 check(button.text=="LOCK A","enabled action clears old refusal")
 button.free()
 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://truthful-commands.save";g.capture_scenario="runtime-test"
 root.add_child(g);await frames();g.set_process(false)
 if g.get_node_or_null("Frontend")!=null:g.get_node("Frontend")._dismiss()
 g._start_mission(15);g._enter_water();g.sim.paused=true
 var racks=Racks.empty();racks.quietus={"knock":2,"emp":3};racks.drone_a={"emp":1};Racks.launch(g.sim,racks)
 for unit in 3:
  g.sim.command("select",{"unit":unit});g.mission_hud.open("tools");g._refresh();await frames()
  check(g.order_buttons.knock.text.begins_with("TORPEDO\n%d"%(2 if unit==0 else 0)),"tool menu torpedo count belongs to craft %d"%unit)
  check(g.order_buttons.emp.text.begins_with("DISRUPT\n%d"%[3,1,0][unit]),"tool menu disrupt count includes this craft's zero %d"%unit)
  if unit==2:check("Zero stock on DRONE B" in g.order_buttons.emp.text,"zero stock refusal names owning craft")
  if unit>0:check("Quietus only" in g.order_buttons.knock.text,"drone launcher refusal names actual owner")
 var brief=Copy.brief_stock(racks)
 check("QUIETUS: " in brief and "DRONE A: " in brief and "DRONE B: " in brief,"brief separates all three craft")
 check("TORPEDOES 0" in brief.get_slice("\n",1) and "DISRUPT 0" in brief.get_slice("\n",2),"brief shows each craft's zero stock")
 # Object-sheet ROUTE HERE must use the same work approach seam as the
 # dedicated Reach/Choir pages. No direct-to-centre fallback on those sheets.
 for subkind in ["glass_work","choir"]:
  g._start_mission(15 if subkind=="glass_work" else 22);g._enter_water();g.sim.paused=true
  g.sim.units[0].pos=Vector2(440,440);g.sim.units[0].route=[]
  g.sim.depth_charts[1]=empty;g.sim.terrain_chart=empty
  g.mission_hud.subject={"kind":"objective","subkind":subkind,"name":"KNOWN WORK","pos":Vector2(600,500),"band":1}
  var projected=Copy.route_target(g.mission_hud,"route_here")
  check(not projected.is_empty() and projected.work_range==60.,"ROUTE HERE retains physical work range for "+subkind)
  g.mission_hud._extra("route_here")
  check(g.sim.units[0].route.is_empty() and "No measured approach" in g.sim.message,"ROUTE HERE refuses unmeasured centre for "+subkind)
  g.sim.depth_charts[1]=chart;g.sim.terrain_chart=chart
  g.mission_hud.subject.pos=Vector2(500,440)
  var local=Copy.approach(g.sim,Copy.route_target(g.mission_hud,"route_here"))
  check(local.ready and local.point.distance_to(g.mission_hud.subject.pos)<=60.,"ROUTE HERE finds measured local water for "+subkind)
 g._start_mission(15);g._enter_water();g.sim.paused=true
 g.sim.mission.objectives[0]={"name":"KNOWN MACHINE","pos":Vector2(600,500),"captured":false,"glass_effect":{},"duration":8.}
 for subkind in ["","actuator"]:
  g.mission_hud.subject={"kind":"objective","subkind":subkind,"index":0,"pos":Vector2(600,500)}
  var projected=Copy.route_target(g.mission_hud,"route_here")
  check(projected.pos==Vector2(600,500) and Copy.verb(projected)=="WORK","ROUTE HERE retains public indexed work site "+subkind)
 g.sim.mission.module_recovery.modules["drone_sampler"]={"state":"salvage","unit":-1,"pos":Vector2(600,500)}
 g.mission_hud.subject={"kind":"salvage","item":"drone_sampler","pos":Vector2(600,500)}
 var material=Copy.route_target(g.mission_hud,"route_here")
 check(material.work_range==g.sim.salvage_context(g.mission_hud.subject.item).get("range",60.) and material.band==g.sim.Depth.cargo_band(g.sim,g.mission_hud.subject.item),"ROUTE HERE uses public salvage range and recorded band")
 g.sim.mission.objectives[0]={"name":"SECRET","pos":Vector2(600,500),"captured":false,"unknown":true,"lead":{"off":Vector2(120,0),"r":150.}}
 g.mission_hud.subject={"kind":"objective","index":0,"pos":Vector2(720,500)}
 check(Copy.route_target(g.mission_hud,"route_here").is_empty(),"unlocated lead keeps its public search area instead of a true work position")
 g.mission_hud.subject={"kind":"objective","subkind":"corridor","pos":Vector2(720,500)}
 check(Copy.route_target(g.mission_hud,"route_here").is_empty(),"ordinary corridor keeps its existing route command")
 # Concrete refusal text, using real presenters rather than mere nonempty hints.
 g._start_mission(15);g._enter_water();g.sim.paused=true
 g.sim.mission.objectives[0]={"name":"KNOWN MACHINE","pos":g.sim.units[0].pos,"captured":false,"glass_effect":{},"duration":8.}
 g.sim.captures[0]={"target":0,"elapsed":0.};g._refresh()
 check(g.unit_buttons[0].text=="QUIETUS\nWORK","running machinery uses WORK in craft status")
 g.sim.captures[0]={};g.sim.units[0].band=0;g.mission_hud.open("glass");g._refresh()
 check("Needs MIDDLE" in g.mission_hud.extra.glass_vane.text,"grey Reach action names physical MIDDLE band")
 g._start_mission(22);g._enter_water();g.sim.paused=true
 var station=g.sim.mission.iron_choir.sites.filter(func(site):return site.id!="release")[0]
 g.sim.recon_time=1.;g.sim.mission.survey_origin=station.pos;g.sim.units[0].band=0
 g.mission_hud.open("choir");g._refresh()
 check("Needs "+g.sim.Depth.NAMES[station.band] in g.mission_hud.extra["choir_"+station.id].text,"grey Choir work names surveyed station band")
 g._start_mission(0);g._enter_water();g.sim.paused=true
 var origin:Vector2=g.sim.units[0].pos
 g.sim.mission.module_recovery.modules["drone_sampler"]={"state":"salvage","unit":-1,"pos":origin+Vector2(200,0)}
 g.sim.mission.depth_cargo["drone_sampler"]=1
 g.mission_hud.open("salvage",{"kind":"salvage","item":"drone_sampler","name":"FIELD SAMPLER","pos":origin+Vector2(200,0)});g._refresh()
 check("200m away" in g.mission_hud.extra.salvage.text and "60m" in g.mission_hud.extra.salvage.text,"grey module recovery shows current distance and reach without a context pos")
 # Rendezvous has a separate local-work busy guard, even with a ready decoder.
 g._start_mission(7);g._enter_water();g.sim.paused=true
 var receiver=g.sim.mission.objectives.filter(func(o):return o.get("site_id","")!="rendezvous")[0]
 g.sim.units[0].pos=receiver.pos+Vector2(-30,0);g.sim.units[0].vel=Vector2.ZERO;g.sim.units[0].angle=g.sim.units[0].pos.angle_to_point(receiver.pos)
 g.sim.mission.module_recovery.jobs[0]={"item":"drone_sampler","elapsed":0.}
 g.mission_hud.open("craft",{"kind":"craft","unit":0,"pos":g.sim.units[0].pos});g._refresh()
 check(g.sim.camera_context().get("ready",false),"rendezvous busy refusal fixture retains a READY camera context")
 check(g.order_buttons.camera.disabled and "Finish this craft's active work first" in g.order_buttons.camera.text and not "READY" in g.order_buttons.camera.text,"grey decoder shows busy refusal rather than READY")
 g._start_mission(10);g._enter_water();g.sim.paused=true
 var inlet=g.sim.warning_chain_context().stations.filter(func(site):return site.id=="inlet")[0]
 g.sim.units[0].pos=inlet.pos+Vector2(400,0)
 g.mission_hud.open("plant",{"kind":"plant","station":"inlet","name":inlet.name,"pos":inlet.pos});g._refresh()
 check("400m away" in g.mission_hud.extra.chain_connect.text and "60m" in g.mission_hud.extra.chain_connect.text,"grey plant action names distance to public inlet")
 g._start_mission(0);g._enter_water();g.sim.paused=true
 g.sim.mission.erase("tool_racks");g.sim.mission.field_tools.counts["hull_patch"]=1;g.sim.tools.knock=2;g.sim.command("select",{"unit":1})
 g.mission_hud.open("field_tools");g._refresh()
 check(Racks.count(g.sim,"hull_patch")==1 and Copy.stock(g.sim,"hull_patch")==0,"legacy global patch reserve is not drone stock")
 check(g.mission_hud.extra.hull_patch.text.begins_with("HULL PATCH 0\n") and "Quietus only" in g.mission_hud.extra.hull_patch.text,"legacy drone field menu shows zero Quietus-only patch stock")
 check(g.order_buttons.knock.text.begins_with("TORPEDO\n0"),"legacy drone menu shows zero Quietus-only torpedoes")
 for op in [2,15,16,17,20,22,30]:
  g._start_mission(op);g._enter_water();g.sim.paused=true
  check(not "AT SOUTH" in g.mission_hud.extra.glass_withdraw.text,"withdraw never invents south op%d"%op)
  var names=g.sim.extraction_corridors().filter(func(c):return c.pos.distance_to(g.sim.mission.extraction)<1.).map(func(c):return c.name)
  if not names.is_empty():check(names[0] in g.mission_hud.extra.glass_withdraw.text,"withdraw names actual mouth op%d"%op)
  g.mission_hud.open("signals",{"kind":"signals","receiver":0});g._refresh()
  check(preload("res://src/presentation/expedition_view.gd").detail(g.sim,0) in g.mission_hud.instrument_info.text,"ARRIVALS sheet retains complete received report after generic machinery status op%d"%op)
  for key in g.mission_hud.action_controls():
   var b=g.mission_hud.action_controls()[key]
   if b.disabled:check(not b.tooltip_text.is_empty(),"visible grey action has a reason "+str(key))
 # Both UI scales repeatedly refresh an empty drone menu without stale counts.
 for scale in [1.,1.5]:
  Settings.current["text_scale"]=scale;g._start_mission(15);g._enter_water();Racks.launch(g.sim,racks);g.sim.command("select",{"unit":2})
  g.mission_hud.open("tools");g._refresh();await frames();g._refresh()
  check("Zero stock on DRONE B" in g.order_buttons.emp.text,"visible reason at text scale %.1f"%scale)
 Settings.current["text_scale"]=1.
 g.queue_free();await frames()
 print("TRUTHFUL COMMANDS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
