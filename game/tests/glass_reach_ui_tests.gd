extends SceneTree
var checks=0
var failures=0
var captures=""
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frames():
 for n in 4:await process_frame
func tap(button):
 await tap_at(button.get_global_rect().get_center())
func tap_at(p:Vector2):
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new();event.index=0;event.position=p;event.pressed=pressed;root.push_input(event,true);await process_frame
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.position=p;mouse.global_position=p;mouse.pressed=pressed;root.push_input(mouse,true);await process_frame
 await frames()
func progress(overt=false):return {"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,13 if overt else 12],"facts":{"deep":"received carrier","confluence_route":"overt" if overt else "concealed","resolution":"overt_warning" if overt else "concealed_recovery"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(captures)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await frames()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://glass-ui-"+str(dimensions.x)+".save"
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(g.store.path+suffix)
  g.capture_scenario="runtime-test"
  root.add_child(g);await frames();g.set_process(false)
  g.completed=[0,1,2,3,4,5];g.unlocked=5;g.expedition=progress(dimensions.x==2184);g._show_ending();await frames()
  check(g.screen=="menu" and g.panel_box.get_children().any(func(c):return c is Label and c.text=="Course so far: %s (provisional)."%g.Endings.resolve(g.expedition).title),"pre-op34 ending redirects to Operations with provisional course line")
  var buttons=g.panel_box.find_children("*","Button",true,false).filter(func(c):return c.get_meta("action","")=="expedition14" and not c.disabled and c.is_visible_in_tree())
  check(buttons.size()==1,"provisional Operations offers available Glass Reach operation")
  if buttons.size()==1:
   g.scroll.ensure_control_visible(buttons[0]);await frames();await tap(buttons[0]);check(g.screen=="briefing" and g.get_meta("onboard2_fit_index",-1)==14,"actual Operations touch opens Glass Reach briefing")
  g.expedition.completed.append_array([14,15,16,17]);g._start_mission(18);g._enter_water();g.sim.sirens=[];g.sim.units[0].pos=g.sim.mission.glass_reach.work_pos+Vector2(0,35);g.sim.units[0].vel=Vector2.ZERO;g._focus_craft();g.mission_hud.open("craft");g._refresh();await frames()
  check(g.mission_hud.extra.has("glass_work"),"new craft-local work control exists")
  if g.mission_hud.extra.has("glass_work"):
   await tap(g.mission_hud.extra.glass_work)
   check(g.mission_hud.page=="glass" and g.mission_hud.extra.glass_service.visible,"actual craft work touch opens local machinery actions")
   var action=g.mission_hud.extra.glass_service
   check(not action.disabled and action.get_global_rect().size.y>=g.ui_touch_height,"service action is ready with retained touch size")
   await tap(action)
   check(not g.sim.mission.glass_reach.job.is_empty() and g.sim.mission.glass_reach.job.action=="service","actual local action touch starts physical service work without issuing a route")
   if not captures.is_empty() and DisplayServer.get_name()!="headless":
    await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join("glass-service-"+str(dimensions.x)+".png"))
  g._start_mission(20);g._enter_water();g.sim.sirens=[]
  var position=g.sim.mission.glass_reach.work_pos
  g.sim.units[1].pos=position+Vector2(0,35);g.sim.units[0].pos=position+Vector2(0,80);g._order("select",{"unit":1});g._focus_craft();g._refresh();await frames()
  var markers=g.ocean.salvage_markers()
  check(markers.size()==1,"charted Reach material has one real interactive recovery marker")
  if markers.size()==1:
   await tap_at(markers[0].rect.get_center()+g.ocean.global_position)
   check(g.mission_hud.page=="salvage" and not g.mission_hud.extra.salvage.disabled,"material marker touch offers worker-local recovery")
   await tap(g.mission_hud.extra.salvage)
   check(not g.sim.mission.glass_reach.job.is_empty() and g.sim.mission.glass_reach.job.unit==1,"actual material recovery touch starts drone's physical winch")
   g.sim.paused=false
   for n in 252:g.sim.advance(g.sim.STEP)
   g.sim.paused=true;g._refresh();g.mission_hud.open("craft");await frames()
   check(g.sim.mission.glass_reach.artifact.carrier==1 and not preload("res://src/presentation/module_recovery_view.gd").cargo(g.sim,1).is_empty(),"live carrier exposes its new physical material in fleet feedback")
   await tap(g.mission_hud.extra.glass_work);await tap(g.mission_hud.extra.glass_transfer)
   check(g.sim.mission.glass_reach.artifact.carrier==0,"actual local transfer touch puts physical material on Quietus")
  g._start_mission(15);check(g.mission_hud.subject.get("kind","")!="salvage","new region launch clears previous material/object command subject");g._enter_water();g.sim.units[0].pos=Vector2(1150,1900);g.sim.units[0].angle=0;g.sim.units[1].pos=Vector2(1350,2050);g.sim.units[1].band=2;g.sim.contacts={};g.sim._observe();g._focus_craft();g._refresh();g.mission_hud.open("acoustics");await frames()
  await tap(g.mission_hud.extra.sonar_emit)
  g.sim.paused=false
  for n in 45:g.sim.advance(g.sim.STEP)
  g.sim.paused=true;g.sim._observe();g._refresh();g.mission_hud.open("acoustics");await frames()
  check(g.sim.network_feedback().any(func(row):return row.type=="buoy" and row.mode=="BUOY CHARGING"),"actual SONAR input produces earned visible listener charge")
  if not captures.is_empty() and DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join("glass-network-"+str(dimensions.x)+".png"))
  g.sim.mission.launch_equipment.quietus="quietus_prism";g.sim.sonar.sector="forward";g._refresh();await frames()
  check("0.8 RESERVE" in g.mission_hud.extra.sonar_emit.text,"new prism fitting presents its actual directional reserve cost")
  g.queue_free();await frames()
 print("GLASS REACH UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
