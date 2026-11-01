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
 var button=Button.new();button.size=Vector2(240,100);button.add_theme_font_size_override("font_size",20);button.text="LOCK A";button.disabled=true
 Copy.reason_button(button,"Finish LOCK B first");Copy.reason_button(button,"Finish LOCK B first")
 check(button.text=="LOCK A\nAFTER LOCK B" and button.tooltip_text=="Finish LOCK B first","grey reason remains visible and never accumulates")
 button.disabled=false;Copy.reason_button(button,"")
 check(button.text=="LOCK A","enabled action clears old refusal")
 # Native radial width/font: long label + long token must not become four
 # rendered lines. Full reason remains available when the token is omitted.
 button.disabled=true;button.size=Vector2(227.85,147);button.add_theme_font_size_override("font_size",38)
 button.text="RELEASE\nVANE";Copy.reason_button(button,"Needs MIDDLE")
 check(button.text=="RELEASE\nVANE" and button.tooltip_text=="Needs MIDDLE","native radial retains two-line action when token would grow it")
 button.text="ROUTE TO\nREACH WORK";Copy.reason_button(button,"Needs MIDDLE before plotting work approach")
 check(button.text=="ROUTE\nMIDDLE","native radial route and short band token each fit one line")
 button.text="TORPEDO\n0";Copy.reason_button(button,"Quietus only")
 check(button.text=="TORPEDO\n0","native radial retains tool count without adding a third rendered line")
 for op in [16,17,20]:
  sim.start(op)
  var caption=Copy.recovery_label(sim)
  var distance=roundi(sim.units[0].pos.distance_to(sim.mission.extraction))
  check(distance>=1000 and caption.ends_with("%dm"%distance),"distant actual recovery retains exact metres op%d"%op)
  for line in caption.split("\n"):
   check(button.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,38).x<=223.85,"actual recovery fits native radial line width op%d: %s"%[op,line])
 button.free()
 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://truthful-commands.save";g.capture_scenario="runtime-test"
 root.add_child(g);await frames();g.set_process(false)
 if g.get_node_or_null("Frontend")!=null:g.get_node("Frontend")._dismiss()
 g._start_mission(15);g._enter_water();g.sim.paused=true
 var racks=Racks.empty();racks.quietus={"knock":2,"emp":3};racks.drone_a={"emp":1};Racks.launch(g.sim,racks)
 for unit in 3:
  g.sim.command("select",{"unit":unit});g.mission_hud.open("tools");g._refresh();await frames()
  check(g.order_buttons.knock.text.replace("\n"," ").begins_with("TORPEDO %d"%(0 if unit>0 else 2)),"tool menu torpedo count belongs to craft %d"%unit)
  check(g.order_buttons.emp.text.replace("\n"," ").begins_with("DISRUPT %d"%[3,1,0][unit]),"tool menu disrupt count includes this craft's zero %d"%unit)
  if unit==2:check(g.order_buttons.emp.text.split("\n").size()<=2 and "Zero stock on DRONE B" in g.order_buttons.emp.tooltip_text,"zero stock refusal names owning craft")
  if unit>0:check(g.order_buttons.knock.text.split("\n").size()<=2 and "Quietus only" in g.order_buttons.knock.tooltip_text,"drone launcher refusal names actual owner")
 var brief=Copy.brief_stock(racks)
 check("QUIETUS: " in brief and "DRONE A: " in brief and "DRONE B: " in brief,"brief separates all three craft")
 check("TORPEDOES 0" in brief.get_slice("\n",1) and "DISRUPT 0" in brief.get_slice("\n",2),"brief shows each craft's zero stock")
 # Opening brief stays short; the existing fittings page carries every craft's stock.
 g.tool_racks=racks.duplicate(true);g._show_fittings();await frames()
 var fitting_copy=""
 for child in g.panel_box.get_children():
  if child is Label:fitting_copy+=child.text+"\n"
 check(brief in fitting_copy,"opening fittings entry shows all per-craft counts including zero")
 # The opening brief confirms actual Quietus stock without a text wall.
 var stock_before=g.sim.snapshot().duplicate(true)
 g._briefing(0);await frames()
 var opening_copy=""
 for child in g.panel_box.get_children():
  if child is Label:opening_copy+=child.text+"\n"
 check("QUIETUS\nO₂ 120% · DISRUPT 3 · SURVEY 0" in opening_copy,"opening brief confirms actual selected Quietus stock")
 check(g.sim.snapshot()==stock_before,"reading launch stock preserves the active dive")
 check(Work.action_verb({"site_id":"rendezvous","kind":"receiver"})=="DECODE","tender's receiver task keeps its authored decode verb")
 check(Work.action_verb({"kind":"receiver"})=="LISTEN","ordinary receiver keeps LISTEN distinct from exchange DECODE")
 check(Work.action_verb({"kind":"exchange"})=="DECODE","Blackwater exchange keeps the handoff's DECODE verb")
 # Object-sheet ROUTE HERE must use the same work approach seam as the
 # dedicated Reach/Choir pages. No direct-to-centre fallback on those sheets.
 # 127 (Pat 2026-10-30): ROUTE HERE is a dev/test shortcut; exercise it in dev state.
 g.set_meta("dev_profile",true)
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
 g.set_meta("dev_profile",false)
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
 check("Needs MIDDLE" in g.mission_hud.extra.glass_vane.tooltip_text and g.mission_hud.extra.glass_vane.text.begins_with("RELEASE"),"grey Reach action names physical MIDDLE band")
 g._start_mission(22);g._enter_water();g.sim.paused=true
 var station=g.sim.mission.iron_choir.sites.filter(func(site):return site.id!="release")[0]
 g.sim.recon_time=1.;g.sim.mission.survey_origin=station.pos;g.sim.units[0].band=0
 g.mission_hud.open("choir");g._refresh()
 check("Needs "+g.sim.Depth.NAMES[station.band] in g.mission_hud.extra["choir_"+station.id].tooltip_text,"grey Choir work names surveyed station band")
 g._start_mission(0);g._enter_water();g.sim.paused=true
 var origin:Vector2=g.sim.units[0].pos
 g.sim.mission.module_recovery.modules["drone_sampler"]={"state":"salvage","unit":-1,"pos":origin+Vector2(200,0)}
 g.sim.mission.depth_cargo["drone_sampler"]=1
 g.mission_hud.open("salvage",{"kind":"salvage","item":"drone_sampler","name":"FIELD SAMPLER","pos":origin+Vector2(200,0)});g._refresh()
 check(g.mission_hud.extra.salvage.text=="RECOVER\n200m" and "200m away" in g.mission_hud.extra.salvage.tooltip_text and "60m" in g.mission_hud.extra.salvage.tooltip_text,"grey module recovery shows current distance and reach without a context pos")
 # Rendezvous has a separate local-work busy guard, even with a ready decoder.
 g._start_mission(7);g._enter_water();g.sim.paused=true
 var receiver=g.sim.mission.objectives.filter(func(o):return o.get("site_id","")!="rendezvous")[0]
 g.sim.units[0].pos=receiver.pos+Vector2(-30,0);g.sim.units[0].vel=Vector2.ZERO;g.sim.units[0].angle=g.sim.units[0].pos.angle_to_point(receiver.pos)
 g.sim.mission.module_recovery.jobs[0]={"item":"drone_sampler","elapsed":0.}
 g.mission_hud.open("craft",{"kind":"craft","unit":0,"pos":g.sim.units[0].pos});g._refresh()
 check(g.sim.camera_context().get("ready",false),"rendezvous busy refusal fixture retains a READY camera context")
 check(g.order_buttons.camera.disabled and "Finish this craft's active work first" in g.order_buttons.camera.tooltip_text and not "READY" in g.order_buttons.camera.text,"grey decoder shows busy refusal rather than READY")
 g._start_mission(10);g._enter_water();g.sim.paused=true
 var inlet=g.sim.warning_chain_context().stations.filter(func(site):return site.id=="inlet")[0]
 g.sim.units[0].pos=inlet.pos+Vector2(400,0)
 g.mission_hud.open("plant",{"kind":"plant","station":"inlet","name":inlet.name,"pos":inlet.pos});g._refresh()
 check(g.mission_hud.extra.chain_connect.text.split("\n").size()<=2 and "400m away" in g.mission_hud.extra.chain_connect.tooltip_text and "60m" in g.mission_hud.extra.chain_connect.tooltip_text,"grey plant action names distance to public inlet")
 g._start_mission(0);g._enter_water();g.sim.paused=true
 g.sim.mission.erase("tool_racks");g.sim.mission.field_tools.counts["hull_patch"]=1;g.sim.tools.knock=2;g.sim.command("select",{"unit":1})
 g.mission_hud.open("field_tools");g._refresh()
 check(Racks.count(g.sim,"hull_patch")==1 and Copy.stock(g.sim,"hull_patch")==0,"legacy global patch reserve is not drone stock")
 check(g.mission_hud.extra.hull_patch.text.begins_with("HULL PATCH 0\n") and "Quietus only" in g.mission_hud.extra.hull_patch.tooltip_text,"legacy drone field menu shows zero Quietus-only patch stock")
 check(g.order_buttons.knock.text.replace("\n"," ").begins_with("TORPEDO 0"),"legacy drone menu shows zero Quietus-only torpedoes")
 for op in [2,15,16,17,20,22,30]:
  g._start_mission(op);g._enter_water();g.sim.paused=true
  check(not "AT SOUTH" in g.mission_hud.extra.glass_withdraw.text,"withdraw never invents south op%d"%op)
  var names=g.sim.extraction_corridors().filter(func(c):return c.pos.distance_to(g.sim.mission.extraction)<1.).map(func(c):return c.name)
  check(g.mission_hud.extra.glass_withdraw.text==Copy.recovery_label(g.sim),"withdraw names short actual mouth and distance op%d"%op)
  check(g.mission_hud.extra.glass_withdraw.text.split("\n").size()==2 and g.mission_hud.extra.glass_withdraw.text.begins_with("WITHDRAW\n"),"withdraw stays two lines op%d"%op)
  if not names.is_empty():check(names[0] in Copy.recovery_name(g.sim),"full recovery name remains available op%d"%op)
  g.mission_hud.open("signals",{"kind":"signals","receiver":0});g._refresh()
  check(preload("res://src/presentation/expedition_view.gd").detail(g.sim,0) in g.mission_hud.instrument_info.text,"ARRIVALS sheet retains complete received report after generic machinery status op%d"%op)
  for key in g.mission_hud.action_controls():
   var b=g.mission_hud.action_controls()[key]
   if b.disabled:
    check(not str(b.get_meta("truthful_reason","")).is_empty(),"visible grey action retains full reason "+str(key))
    check(b.text.split("\n").size()<=2,"grey action stays within two caption lines "+str(key))
    if b!=g.mission_hud.extra.glass_withdraw:check(b.text.get_slice("\n",1).length()<=14,"reason token is short "+str(key))
 # Both UI scales repeatedly refresh an empty drone menu without stale counts.
 for scale in [1.,1.5]:
  Settings.current["text_scale"]=scale;g._start_mission(15);g._enter_water();Racks.launch(g.sim,racks);g.sim.command("select",{"unit":2})
  g.mission_hud.open("tools");g._refresh();await frames();g._refresh()
  check((g.order_buttons.emp.text=="DISRUPT 0 / NONE ABOARD" if scale>=1.5 else g.order_buttons.emp.text.replace("\n"," ").begins_with("DISRUPT 0")) and "Zero stock on DRONE B" in g.order_buttons.emp.tooltip_text,"visible reason at text scale %.1f"%scale)
  # Real popup touch and dock-tap paths both explain grey actions and do not
  # emit their command signal. Periodic refresh must retain the feedback.
  var grey=g.order_buttons.emp;var fired=[0]
  grey.pressed.connect(func():fired[0]+=1)
  var state=g.sim.snapshot().duplicate(true)
  var point=grey.get_global_rect().get_center()
  if g.mission_hud.order_dock.visible:
   g.mission_hud._dock_tap(point,point)
  else:
   for down in [true,false]:
    var touch=InputEventScreenTouch.new();touch.index=71;touch.position=point;touch.pressed=down
    g.mission_hud.popup_input(touch)
  check(g.sim.message=="Zero stock on DRONE B" and g.sim.message in g.mission_hud.intent.text and g.mission_hud.intent.is_visible_in_tree(),"grey tap shows full refusal in existing status at %.1f"%scale)
  g._refresh()
  check(g.sim.message in g.mission_hud.intent.text,"grey refusal survives refresh at %.1f"%scale)
  check(fired[0]==0 and grey.disabled and g.sim.snapshot()==state,"grey feedback never emits an action or changes gameplay at %.1f"%scale)
  grey.pressed.disconnect(grey.pressed.get_connections().back().callable)
  var enabled=Button.new();var enabled_fired=[0]
  enabled.pressed.connect(func():enabled_fired[0]+=1)
  Copy.activate(g.mission_hud,enabled)
  check(enabled_fired[0]==1 and not g.mission_hud.has_meta("truthful_feedback") and not g.mission_hud.intent.visible,"enabled activation clears grey feedback without changing command handling")
  enabled.free()
 Settings.current["text_scale"]=1.
 g.queue_free();await frames()
 print("TRUTHFUL COMMANDS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
