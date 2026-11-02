extends SceneTree
var checks=0
var failures=0
var captures=""
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 7:await process_frame
func touch(point,pressed,index=0,canceled=false):
 var e=InputEventScreenTouch.new();e.position=point;e.index=index;e.pressed=pressed;e.canceled=canceled;root.push_input(e,true);await process_frame
func mouse(point,pressed):
 var e=InputEventMouseButton.new();e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.device=InputEvent.DEVICE_ID_EMULATION;e.pressed=pressed;root.push_input(e,true);await process_frame
func click(button):
 var p=button.get_global_rect().get_center()
 await touch(p,true);await mouse(p,true);await touch(p,false);await mouse(p,false);await settle()
func capture(name):
 if not captures.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(captures)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://depth-sonar-ui-%d.save"%dimensions.x
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(0);await settle()
  check(g.mission_hud.extra.has("depth_menu"),"craft has practical depth/sonar controls")
  if not g.mission_hud.extra.has("depth_menu"):g.queue_free();await settle();continue
  var h=g.mission_hud;h.open("craft",{"kind":"craft","unit":0,"pos":g.sim.units[0].pos});await settle();await click(h.extra.depth_menu)
  check(h.page=="acoustics" and h.extra.depth_down.visible,"real radial input opens acoustic choices")
  await capture(str(dimensions.x)+"-acoustic-controls")
  for key in ["depth_down","sonar_sector","sonar_power","sonar_emit"]:
   for kind in ["cancel","drag","pinch"]:
    h.open("acoustics");await settle();var before=g.sim.snapshot();var p=h.extra[key].get_global_rect().get_center()
    await touch(p,true);await mouse(p,true)
    if kind=="cancel":await touch(p,false,0,true);await mouse(p,false)
    elif kind=="pinch":
     await touch(p+Vector2(120,0),true,1);await touch(p,false);await mouse(p,false);await touch(p+Vector2(120,0),false,1)
    else:
     var e=InputEventScreenDrag.new();e.index=0;e.position=p+Vector2(24,0);e.relative=Vector2(24,0);root.push_input(e,true);await process_frame
     await touch(p+Vector2(24,0),false);await mouse(p+Vector2(24,0),false)
    await settle();check(g.sim.snapshot()==before,"canceled "+key+" "+kind+" preserves consequential state")
  h.open("acoustics");await settle();await click(h.extra.depth_down)
  check(g.sim.units[0].transition.get("to")==2,"deliberate depth touch starts exactly one physical transition")
  check(g.sim.paused and g.sim.elapsed==0,"depth planning keeps unlimited pause")
  g.sim.paused=false
  for n in 250:g.sim.advance(1./60)
  g.sim.paused=true;g._refresh();h.open("acoustics");await settle()
  check(g.sim.units[0].band==2 and "DEEP" in h.extra.depth_down.text+h.extra.depth_up.text+h.instrument_info.text,"executed band has readable feedback")
  await click(h.extra.sonar_sector);h.open("acoustics");await settle();await click(h.extra.sonar_power)
  check(g.sim.sonar.sector=="forward" and g.sim.sonar.power=="high","real touch selects sector and power")
  # Explicit received-display fixture; complete ordinary-policy input journeys
  # are separate. Only our craft pose is staged; contacts must be physically earned.
  g.sim.units[0].pos=Vector2(790,550);g.sim.units[0].angle=-1.33;g._refresh()
  h.open("acoustics");await settle();var reserve=g.sim.oxygen;await click(h.extra.sonar_emit)
  check(g.sim.oxygen<reserve and not g.sim.sonar.pending.is_empty(),"actual pulse spends energy and waits for echoes")
  g.sim.paused=false
  for n in 156:g.sim.advance(1./60)
  g.sim.paused=true;g._refresh()
  check(g.sim.sonar.history.any(func(row):return row.kind=="echo"),"history display receives an actual delayed reflection")
  h.open("acoustics");await settle()
  check(not h.hints.panel.visible or h.command_controls().all(func(b):return not b.get_global_rect().intersects(h.hints.panel.get_global_rect())),"received tutorial leaves every acoustic command visible and tappable")
  await click(h.extra.sonar_history)
  check(h.page=="inspect" and h.sonar_waterfall.visible and h.instrument_info.text.contains("BEARING"),"received evidence history owns a readable waterfall")
  check(not h.hints.panel.visible or not h.sheet.get_global_rect().intersects(h.hints.panel.get_global_rect()),"received history sheet stays clear of the tutorial card")
  await capture(str(dimensions.x)+"-sonar-history")
  # Source-known custody fixture tests the visible radial, not its hidden info sheet.
  g._start_mission(41);await settle();g.sim.sirens=[]
  g.sim.Depth.cargo_bands(g.sim)
  var carrier=g.sim.units[0];carrier.pos=g.sim.Witness.berth(g.sim.mission);carrier.band=1
  g.sim.Consequences.observe(g.sim)
  check(g.sim.Witness.known(g.sim),"local MIDDLE observation identifies the boy before the UI custody fixture")
  carrier.band=0;g.sim.Witness.collect_at(g.sim,0,carrier.pos)
  check(g.sim.mission.witness_evacuation.state=="carried" and g.sim.mission.witness_evacuation.carrier==0,"depth UI fixture really carries the identified boy")
  carrier.pos=g.sim.mission.extraction;carrier.band=2;g.sim._use_band(2);g._refresh()
  h.open("acoustics");await settle()
  check(not h.sheet.visible and not h.intent.visible and h.extra.depth_up.is_visible_in_tree(),"survivor guidance uses the actual visible depth radial")
  check(h.acoustics_carry_caption()=="ASCENT 8s / SETTLE 6s","depth radial previews carried ascent and settle duration")
  await click(h.extra.depth_up);h.open("acoustics");await settle()
  check(h.acoustics_carry_caption()=="SURVIVOR ASCENT 8.0s","visible radial reports the carried ascent countdown")
  check(h.caption_rects.size()==3 and h.caption_rects.all(func(r):return Rect2(Vector2.ZERO,h.size).encloses(r) and not r.intersects(h.close_button.get_rect())),"carried radial captions fit the safe area and clear BACK")
  check(h.caption_rects.all(func(r):return not h.command_controls().any(func(b):return r.intersects(b.get_rect()))),"carried captions clear every depth radial control")
  for control in h.command_controls():
   check(control.size.x>=h.touch_height and control.size.y>=h.touch_height,"survivor guidance preserves full depth touch targets")
  g.sim.Depth.advance(g.sim,8.);g._refresh();h.open("acoustics");await settle()
  check(h.acoustics_carry_caption()=="SETTLE 6.0s" and h.extra.depth_up.disabled,"visible settle countdown explains disabled ascent")
  await capture(str(dimensions.x)+"-survivor-settle")
  await click(h.extra.depth_up)
  check(carrier.transition.is_empty() and carrier.band==1,"real touch cannot bypass disabled settling ascent")
  g.sim.Depth.advance(g.sim,6.1);g._refresh();h.open("acoustics");await settle()
  check(not h.extra.depth_up.disabled,"depth ascent enables when the settle countdown ends")
  await click(h.extra.depth_up)
  check(carrier.transition.get("to",-1)==0 and carrier.transition.get("remaining",0.)==8.,"real touch starts the next slow ascent after settling")
  g.queue_free();await settle()
 print("DEPTH SONAR UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
