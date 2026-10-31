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
func tap_at(p:Vector2):
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new();event.index=0;event.position=p;event.pressed=pressed;root.push_input(event,true);await process_frame
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.position=p;mouse.global_position=p;mouse.pressed=pressed;root.push_input(mouse,true);await process_frame
 await frames()
func tap(button):await tap_at(button.get_global_rect().get_center())
func progress():return {"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,16,17,18,19,22],"facts":{"deep":"received carrier","confluence_route":"concealed","resolution":"concealed_recovery","choir_22":"physical freight arrived"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(captures)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await frames()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://iron-ui-"+str(dimensions.x)+".save"
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(g.store.path+suffix)
  root.add_child(g);await frames();g.set_process(false);if g.get_node_or_null("Frontend")!=null:g.get_node("Frontend")._dismiss()
  g.completed=[0,1,2,3,4,5];g.unlocked=5;g.expedition=progress();g._show_campaign();await frames()
  var buttons=g.panel_box.find_children("*","Button",true,false).filter(func(c):return c.get_meta("action","")=="expedition23")
  check(buttons.size()==1,"ordinary campaign archive offers industrial next job")
  if buttons.size()==1:g.scroll.ensure_control_visible(buttons[0]);await frames();await tap(buttons[0]);check(g.screen=="briefing","actual archive touch opens Iron briefing")
  g._start_mission(23);g._enter_water();g.sim.sirens=[];g.sim.units[0].pos=g.sim.mission.iron_choir.sites[0].pos+Vector2(0,35);g.sim.units[0].vel=Vector2.ZERO;g._focus_craft();g.sim._observe();g.mission_hud.open("craft");g._refresh();await frames()
  check(g.mission_hud.extra.has("choir_work"),"ordinary craft exposes industrial work")
  if g.mission_hud.extra.has("choir_work"):
   await tap(g.mission_hud.extra.choir_work);check(g.mission_hud.page=="choir","actual craft input opens industrial actions")
   var button=g.mission_hud.extra.choir_lock_a;check(not button.disabled and button.size.y>=g.ui_touch_height,"local lock action retains full touch size/readiness")
   await tap(button);check(not g.sim.mission.iron_choir.jobs[0].is_empty(),"actual input starts physical lock work without route")
   check(preload("res://src/presentation/module_recovery_view.gd").work(g.sim,0).unit==0,"actual industrial work has visible craft progress instead of generic hold")
   if not captures.is_empty() and DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join("iron-lock-"+str(dimensions.x)+".png"))
  g._start_mission(24);g._enter_water();g.sim.sirens=[];g.sim.units[0].pos=g.sim.mission.iron_choir.load.pos+Vector2(0,40);g._focus_craft();g.sim._observe();g._refresh();await frames()
  var subject=g.ocean.pick_context(g.ocean.screen_position(g.sim.mission.iron_choir.load.pos),g.ui_touch_height)
  check(subject.get("subkind","")=="choir","observed real ballast has interactive body")
  if subject.get("subkind","")=="choir":
   await tap_at(g.ocean.screen_position(g.sim.mission.iron_choir.load.pos)+g.ocean.global_position);await frames()
   # The ballast and its actual nearby carrier are independent touch owners.
   if g.mission_hud.page=="choose":
    var owner=g.mission_hud.target_choices.find_custom(func(c):return c.get("kind","")=="objective" and c.get("subkind","")=="choir" and c.get("target_id","")=="load")
    check(owner>=0,"owner chooser retains the actual ballast load")
    if owner>=0:await tap(g.mission_hud.target_buttons[owner])
   check(g.mission_hud.extra.choir_work.visible,"body input exposes its industrial work menu")
   await tap(g.mission_hud.extra.choir_work);await tap(g.mission_hud.extra.choir_attach)
   check(g.sim.mission.iron_choir.load.carrier==0,"actual ballast attach input binds physical Quietus tow")
  g._start_mission(22);g._enter_water();g.sim.units[0].pos=Vector2(950,1400);g.sim.units[0].vel=Vector2.ZERO;g.sim.units[1].alive=false;g.sim.units[2].alive=false;g._focus_craft();g.sim.paused=false
  for n in 12:g.sim.advance(g.sim.STEP)
  g.sim.paused=true;g.sim._observe();g._refresh();await frames()
  check(g.sim.contacts.values().any(func(c):return c.type=="interceptor" and c.mode=="BURST WINDUP"),"actual acquired interceptor windup has earned visible readout")
  if not captures.is_empty() and DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join("iron-interceptor-"+str(dimensions.x)+".png"))
  g._start_mission(23);g._enter_water();g.sim.units[0].pos=Vector2(1500,950);g.sim.units[0].band=2;g.sim.units[1].alive=false;g.sim.units[2].alive=false;g._focus_craft();g.sim.paused=false
  for n in 168:g.sim.advance(g.sim.STEP)
  g.sim.paused=true;g.sim._observe();g._refresh();await frames()
  check(not g.sim.Industry.patches(g.sim).is_empty() and g.sim.contacts.values().any(func(c):return c.type=="warden"),"actual acquired finite warden pressure has visible equivalent")
  if not captures.is_empty() and DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join("iron-warden-"+str(dimensions.x)+".png"))
  g.queue_free();await frames()
 print("IRON CHOIR UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
