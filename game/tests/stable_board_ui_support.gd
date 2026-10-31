extends "res://tests/status_text_ui_tests.gd"
# Source-known layout fixtures, real engine touch and native screenshots.
var baseline=false
# This suite asserts live geometry and injects real touch itself. Per-scroll
# diagnostic target dumps duplicate that work and schedule extra post-draw waits.
# Keep the actual scene, input, renderer and all settling frames unchanged.
class BoardMain extends "res://tests/density_main.gd":
 func _report_targets()->void:pass
func make_game(id:int,shape:Vector2i):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate()
 game.set_script(BoardMain);game.capture_scenario="stable-board-ui"
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false)
 var settings=Store.DEFAULTS.duplicate(true);settings.text_scale=1.5
 Settings.apply(settings,game);await settle()
 game._start_mission(id);game._layout();await settle()
 return game
var settle_frames=0
var settle_usec=0
func settle():
 var started=Time.get_ticks_usec()
 var previous=0
 var stable=0
 for n in 6:
  await process_frame
  settle_frames+=1
  # Wait for actual rendered, unchanged layout rather than six unconditional
  # frames at every scroll step. Keep the original six-frame upper bound.
  if DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw
  var geometry=[]
  for control in root.find_children("*","Control",true,false):
   geometry.append([control.get_instance_id(),control.get_global_rect(),control.is_visible_in_tree()])
   if control is ScrollContainer:geometry.append([control.scroll_horizontal,control.scroll_vertical])
  var current=hash(geometry)
  stable=stable+1 if current==previous else 0
  previous=current
  if stable>=2:break
 settle_usec+=Time.get_ticks_usec()-started
func capture_case(shape:Vector2i):
 var game=await make_game(12,shape)
 var sim=game.sim;var hud=game.mission_hud;var ocean=game.ocean
 sim.paused=true
 # Isolated received-contact fixture: no enemy stepping or sensing changes.
 sim.contacts.clear()
 for id in 3:
  sim.contacts[id]={"pos":sim.units[0].pos+Vector2(80+id*20,0),"time":sim.elapsed,"mode":"LOCKING" if id==0 else "PATROL","lock":1.5 if id==0 else 0.,"target":0,"band":sim.units[0].band,"source":"optical","angle":0.}
 game._refresh();await settle()
 var camera=[ocean.screen_position(sim.units[0].pos),ocean.world_scale]
 await picture("%d-water"%shape.x)
 hud.open("craft",{"kind":"craft","unit":0,"pos":sim.units[0].pos});await settle()
 await picture("%d-craft"%shape.x)
 print("STABLE GEOMETRY ",shape," size=",hud.size," h=",hud.touch_height," dock=",hud.order_dock.get_rect()," scroll=",hud.order_dock_scroll.get_rect()," actions=",hud.command_controls().map(func(b):return [b.get_meta("action"),b.get_rect()]))
 if not baseline:
  check(ocean.screen_position(sim.units[0].pos).distance_to(camera[0])<.1 and is_equal_approx(ocean.world_scale,camera[1]),"panel opening preserves chart transform "+str(shape))
  var protected=hud.threat_rects()
  for rect in protected:
   check(not hud.order_dock.get_rect().intersects(rect),"dock clears threat/lock stack "+str(shape))
   if hud.has_meta("hunt_meter_button"):
    var meter=hud.get_meta("hunt_meter_button")
    check(not meter.visible or not meter.get_rect().intersects(rect),"Hunt clears threat/lock stack "+str(shape))
  for b in hud.command_controls():
   await reveal(game,b)
   check(hud.order_dock_scroll.get_global_rect().encloses(b.get_global_rect()),"150% action reachable: "+str(b.get_meta("action")))
  for page in ["tools","field_tools","route","acoustics"]:
   hud.open(page);await settle()
   for b in hud.command_controls():
    await reveal(game,b)
    check(hud.order_dock_scroll.get_global_rect().encloses(b.get_global_rect()),"150% "+page+" action reachable: "+str(b.get_meta("action")))
   if page=="tools":await picture("%d-defence"%shape.x)
  hud.open("inspect");await settle()
  for rect in hud.threat_rects():check(not hud.sheet.get_rect().intersects(rect),"status sheet clears threat stack")
  await picture("%d-status"%shape.x)
  for id in [1,2]:
   sim.command("select",{"unit":id})
   for page in ["craft","tools"]:
    hud.open(page,{"kind":"craft","unit":id,"pos":sim.units[id].pos});await settle()
    for b in hud.command_controls():
     await reveal(game,b)
     check(hud.order_dock_scroll.get_global_rect().encloses(b.get_global_rect()),"150%% craft %d %s action reachable: %s"%[id,page,b.get_meta("action")])
   await picture("%d-drone%d-defence"%[shape.x,id])
  sim.command("select",{"unit":0})
 hud.dismiss();await settle()
 if not baseline:
  hud.guard.pending={"unit":0,"point":sim.units[0].pos+Vector2(100,0)}
  game._refresh();await settle()
  for rect in hud.threat_rects():check(not hud.guard.panel.get_rect().intersects(rect),"route confirmation clears threat stack")
  check(Rect2(Vector2.ZERO,hud.size).encloses(hud.guard.panel.get_rect()),"route confirmation stays in viewport")
  await picture("%d-confirm"%shape.x)
  hud.guard.reset();game._refresh();await settle()
 var site=sim.observable_sites()[0]
 sim.units[0].pos=site.pos;sim.units[1].pos=site.pos
 game._refresh();await settle()
 print("STABLE TARGETS ",shape," site=",site," point=",ocean.screen_position(site.pos)," hits=",ocean.contexts_at(ocean.screen_position(site.pos),game.ui_touch_height) if not baseline else [])
 var before=sim.snapshot()
 await tap(ocean.global_position+ocean.screen_position(site.pos))
 await picture("%d-overlap"%shape.x)
 if not baseline:
  check(hud.page=="choose" and hud.target_choices.size()>=3,"own craft, peer and job have explicit choices "+str(shape))
  check(sim.snapshot()==before,"overlap touch issues no order")
  var job=hud.target_choices.filter(func(c):return c.kind=="objective")
  check(not job.is_empty(),"overlap retains work object")
  if not job.is_empty():
   var i=hud.target_choices.find(job[0]);var b=hud.target_buttons[i]
   await reveal(game,b);await tap(b.get_global_rect().get_center())
   check(hud.page=="object","touch selects object from overlap")
  hud.dismiss();await settle()
  # Relocated visible job labels use their drawn rectangle, never a route tap.
  var labels=ocean.label_targets.filter(func(t):return t.context.kind=="objective")
  check(not labels.is_empty(),"visible job label registered")
  if not labels.is_empty():
   before=sim.snapshot();await tap(ocean.global_position+labels[0].rect.get_center())
   check(game.advanced_orders and sim.snapshot()==before,"job label opens context without routing")
  hud.dismiss();await settle()
  ocean.zoom_at(4.,Vector2.ZERO);game._refresh();await settle()
  if ocean.goal_marker.visible:
   before=sim.snapshot();await tap(ocean.global_position+ocean.goal_marker.info.rect.get_center())
   check(game.advanced_orders and sim.snapshot()==before,"GOAL badge opens its subject without routing")
 game.queue_free();await settle()
func swipe_region(area:Rect2):
 var start=area.get_center()+Vector2(0,area.size.y*.3);var finish=area.get_center()-Vector2(0,area.size.y*.3)
 var e=InputEventScreenTouch.new();e.index=0;e.position=start;e.pressed=true;root.push_input(e,true);await process_frame
 for n in 8:
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=start.lerp(finish,(n+1)/8.);drag.relative=(finish-start)/8.;root.push_input(drag,true);await process_frame
 e=InputEventScreenTouch.new();e.index=0;e.position=finish;e.pressed=false;root.push_input(e,true);await settle()
func repair_threat_case(shape:Vector2i,mirrored:bool):
 var game=await make_game(12,shape);var hud=game.mission_hud;var sim=game.sim
 var prefs=Settings.current.duplicate(true);prefs.mirrored_hud=mirrored;Settings.apply(prefs,game);game._layout();sim.paused=true
 var maximum=0
 for id in preload("res://src/campaign/operation_catalog.gd").registered_ids():maximum=maxi(maximum,preload("res://src/campaign/operation_catalog.gd").make(id).sirens.size())
 print("REPAIR AUTHORED MAX ",maximum)
 for count in ([] if "--restore-only" in OS.get_cmdline_user_args() else [3,maximum,32]):
  sim.contacts.clear()
  for id in count:
   sim.contacts[id]={"pos":sim.units[0].pos+Vector2(60+id,0),"time":sim.elapsed,"mode":"LOCKING" if id==0 else "PATROL","lock":1.5 if id==0 else 0.,"target":0,"band":sim.units[0].band,"source":"triangulation","confidence":.95,"angle":0.,"report_remaining":2.5 if id>0 and count>3 else 0.}
  game._refresh();await settle()
  hud.open("craft",{"kind":"craft","unit":0,"pos":sim.units[0].pos});await settle()
  var tag="%d-%s-%d"%[shape.x,"mirror" if mirrored else "normal",count]
  print("REPAIR GEOMETRY ",tag," pause=",game.pause_button.get_rect()," lock=",game.lock_warning.banner," threats=",hud.threat_rects()," dock=",hud.order_dock.get_rect()," scroll=",hud.order_dock_scroll.size)
  for rect in hud.threat_rects():
   check(not rect.intersects(game.pause_button.get_rect()),tag+" threats clear actual Pause")
   check(not rect.intersects(Rect2(hud.close_button.global_position-hud.global_position,hud.close_button.size)),tag+" threats clear Back")
   check(not rect.intersects(hud.order_dock.get_rect()),tag+" threats clear action dock")
   check(Rect2(Vector2.ZERO,hud.size).encloses(rect),tag+" threats in safe bounds")
  check(not game.pause_button.get_rect().intersects(game.lock_warning.banner),tag+" lock clears Pause")
  check(game.pause_button.visible and hud.close_button.visible,tag+" Pause/Back visible")
  await picture(tag+"-threats")
  var received=hud.get("contact_scroll")
  if received!=null and received.visible:
   check(hud.contact_list.get_child_count()>=game.ocean.contact_entries().size()+1,tag+" every received row retained")
   var before=sim.snapshot();await swipe_region(received.get_global_rect())
   check(received.scroll_vertical>0 and sim.snapshot()==before,tag+" received list scroll owns touch without orders")
  # Each stack proves every craft-page action; the extreme stack also exercises every menu.
  for craft in 3:
   sim.command("select",{"unit":craft})
   for page in (["craft","tools","field_tools","route","acoustics"] if count==32 else ["craft"]):
    hud.open(page,{"kind":"craft","unit":craft,"pos":sim.units[craft].pos});await settle()
    for button in hud.command_controls():
     check(hud.order_dock_scroll.size.y>=button.size.y,tag+" full action has enough scroll space "+str(button.get_meta("action")))
     if hud.order_dock_scroll.size.y>=button.size.y and not baseline:await reveal(game,button)
     if not baseline:check(hud.order_dock_scroll.get_global_rect().encloses(button.get_global_rect()),tag+" whole action reachable "+str(button.get_meta("action")))
  sim.command("select",{"unit":0})
  hud.open("craft",{"kind":"craft","unit":0,"pos":sim.units[0].pos});await settle()
  await tap(hud.close_button.get_global_rect().get_center());check(not game.advanced_orders,tag+" actual Back touch returns to water")
  var paused=sim.paused;await tap(game.pause_button.get_global_rect().get_center());check(sim.paused!=paused,tag+" actual Pause touch toggles pause")
  await tap(game.pause_button.get_global_rect().get_center());check(sim.paused==paused,tag+" actual Resume touch restores pause state")
  hud.dismiss();game._refresh();await settle()
 game._start_mission(0);sim=game.sim;sim.paused=true;game._refresh();await settle()
 for mode in ["free","follow","overview"]:
  var ocean=game.ocean
  if mode=="free":ocean.zoom_at(2.,ocean.size/2);ocean.pan_chart(Vector2(40,20))
  elif mode=="follow":ocean.focus_craft()
  else:ocean.fit_chart()
  game._refresh();await settle()
  var state=ocean.chart_camera.snapshot();var transform=[ocean.world_offset,ocean.world_scale];var saved=sim.snapshot()
  for page in ["craft","inspect","tools"]:
   hud.open(page,{"kind":"craft","unit":0,"pos":sim.units[0].pos});await settle();hud.dismiss();game._refresh();await settle()
   check(ocean.chart_camera.snapshot()==state and ocean.world_offset.distance_to(transform[0])<.1 and is_equal_approx(ocean.world_scale,transform[1]),mode+" panel roundtrip preserves transform")
  var restored=Sim.new();check(restored.restore(saved),mode+" current dive snapshot restores")
  check(restored.snapshot()==saved,mode+" restore preserves current dive fields")
  game.store.pin_path("user://stable-board-restore-%d.json"%shape.x,false)
  check(game.store.save(game._archive()),mode+" current dive writes isolated archive")
  sim.oxygen-=1.;ocean.pan_chart(Vector2(30,10));game._load_archive();game._layout();await settle()
  check(sim.snapshot()==saved and ocean.chart_camera.snapshot()==state,mode+" archive reload restores current dive and camera")
  check(ocean.world_offset.distance_to(transform[0])<.1 and is_equal_approx(ocean.world_scale,transform[1]),mode+" archive reload preserves physical transform")
 game.queue_free();await settle()
func choose_special(game,point:Vector2,subkind:String):
 var before=game.sim.snapshot();await tap(game.ocean.global_position+point)
 var hud=game.mission_hud
 check(hud.page=="choose",subkind+" craft overlap opens chooser")
 var matches=hud.target_choices.filter(func(c):return c.get("subkind","")==subkind)
 check(matches.size()==1 and hud.target_choices.any(func(c):return c.kind=="craft"),subkind+" owner identity and craft both present")
 check(game.sim.snapshot()==before,subkind+" touch causes no work/route")
 if matches.size()==1:
  var b=hud.target_buttons[hud.target_choices.find(matches[0])];await reveal(game,b);await tap(b.get_global_rect().get_center())
  check(hud.subject.get("subkind","")==subkind and hud.page=="object",subkind+" chooser dispatches correct object")
  check(game.sim.snapshot()==before,subkind+" choosing owner causes no work/route")
 hud.dismiss();game._refresh();await settle()
func repair_special_case(shape:Vector2i):
 var game=await make_game(7,shape);var sim=game.sim;var ocean=game.ocean
 game.tool_racks=preload("res://src/equipment/tool_racks.gd").empty();game.tool_racks.drone_b.recon=2;game._start_mission(7);sim=game.sim
 sim.units[2].pos=Vector2(650,1120);sim.command("select",{"unit":2});sim.paused=false;sim.advance(.8);sim.paused=true
 check(sim.command("recon"),"tender fixture spends own Survey");game._refresh();await settle()
 var known=game.mission_hud.Rendezvous.projection(sim)
 check(not known.control.is_empty() and not known.hull.is_empty(),"public tender/control fixtures known")
 for key in ["control","hull"]:
  var data=known[key]
  if data.is_empty():continue
  sim.units[0].pos=data.pos;sim.command("select",{"unit":0});ocean.focus_craft();game._refresh();await settle()
  await choose_special(game,ocean.screen_position(data.pos),"berth_control" if key=="control" else "rendezvous_hull")
  await picture("%d-%s-overlap"%[shape.x,key])
 # Actual witness custody earns the concealed work subjects.
 game.expedition={"version":2,"route":"shelf","routes":["shelf"],"facts":{"shelf":"Recovered branch","confluence_route":"concealed"},"completed":[6,8,10,11],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"shelf"}
 game._start_mission(12);sim=game.sim;sim.units[0].pos=Vector2(1840,800);sim.units[0].vel=Vector2.ZERO;sim.command("select",{"unit":0});sim.paused=false;sim.advance(.1)
 check(sim.command("salvage",{"item":"witness_capsule"}),"concealed fixture starts real winch")
 for n in 250:sim.advance(1./60.)
 sim.paused=true;game._refresh();await settle()
 var subjects=game.mission_hud.Concealed.subjects(sim);check(subjects.size()>1,"custody exposes concealed seats")
 if subjects.size()>1:
  var seat=subjects[1];sim.units[0].pos=seat.pos;ocean.focus_craft();game._refresh();await settle()
  var labels=ocean.label_targets.filter(func(t):return t.context.get("seat","")==seat.seat)
  print("REPAIR SEAT LABEL ",shape," seat=",seat," labels=",labels)
  check(not labels.is_empty(),"concealed seat has drawn target label")
  if not labels.is_empty():
   var before=sim.snapshot();await tap(ocean.global_position+labels[0].rect.get_center())
   if game.mission_hud.page=="choose":
    var choices=game.mission_hud.target_choices;var index=choices.find_custom(func(c):return c.get("seat","")==seat.seat)
    check(index>=0,"seat survives overlap identities")
    if index>=0:
     var b=game.mission_hud.target_buttons[index];await reveal(game,b);await tap(b.get_global_rect().get_center())
   check(game.mission_hud.subject.get("seat","")==seat.seat,"relocated seat label dispatches correct job identity")
   check(sim.snapshot()==before,"seat label causes no incidental route/work")
   await picture("%d-concealed-seat"%shape.x)
 game.queue_free();await settle()
class PublicIndustry:
 extends RefCounted
 func choir_context():return {"sites":[{"id":"deep_job","done":false,"pos":Vector2(100,200),"band":2}],"load":{"name":"TEST LOAD","state":"held","pos":Vector2(100,200),"band":2},"artifact":{}}
# Shared implementation, not a *_tests.gd / *_scenarios.gd entrypoint.
# The registered suites override both concrete selectors.
func partition_shape()->Vector2i:
 push_error("stable board entry must select a physical shape")
 quit(1)
 return Vector2i.ZERO
func partition_mirrored()->bool:
 push_error("stable board entry must select handedness")
 quit(1)
 return false
func run():
 var started=Time.get_ticks_usec()
 # Keep every rendered/input frame; do not pay display-vsync pacing for tests.
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 for arg in OS.get_cmdline_user_args():
  if arg=="--baseline":baseline=true
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 if not capture_dir.is_empty():DirAccess.make_dir_recursive_absolute(capture_dir)
 # Each registered entry owns one physical shape/handedness pair. Concrete
 # selectors (rather than optional list filters) cannot produce an empty matrix.
 # Keep all contacts, crafts, pages, gestures and camera/restore modes together
 # inside their original scenario; only separate independently created games.
 var shape=partition_shape()
 var mirrored=partition_mirrored()
 if not mirrored and "--repair-only" not in OS.get_cmdline_user_args() and "--special-only" not in OS.get_cmdline_user_args() and "--restore-only" not in OS.get_cmdline_user_args():await capture_case(shape)
 if "--original-only" not in OS.get_cmdline_user_args():
  if "--special-only" not in OS.get_cmdline_user_args():await repair_threat_case(shape,mirrored)
  if not mirrored and "--restore-only" not in OS.get_cmdline_user_args():await repair_special_case(shape)
 var industry=preload("res://src/presentation/industrial_view.gd")
 var public_info=PublicIndustry.new();var public_target=industry.targets(public_info)[0]
 if not baseline:check(public_target.band==2 and industry.target_at(public_info,public_target.pos)==public_target,"DEEP public target metadata survives label context")
 if not baseline:
  check(industry.targets(public_info).size()==2 and industry.target_at(public_info,public_target.pos,"site:deep_job").target_id!=industry.target_at(public_info,public_target.pos,"load").target_id,"coincident industrial site and load labels retain distinct owners")
 Settings.apply(Store.DEFAULTS)
 print("STABLE BOARD TIMING elapsed_usec=",Time.get_ticks_usec()-started," settle_usec=",settle_usec," settle_frames=",settle_frames," drawn_frames=",Engine.get_frames_drawn())
 print("STABLE BOARD UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
