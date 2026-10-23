extends SceneTree
# Source-known UI fixtures. All interactions use ScreenTouch plus Android-style
# mouse emulation; synthetic placement isolates presentation from travel skill.
var checks=0
var failures=0
var game
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func touch(point:Vector2,down:bool):
 var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
 var m=InputEventMouseButton.new();m.device=InputEvent.DEVICE_ID_EMULATION;m.position=point;m.button_index=MOUSE_BUTTON_LEFT;m.pressed=down;root.push_input(m,true);await process_frame
func tap(button):
 var point=button.get_global_rect().get_center()
 await touch(point,true);await touch(point,false);await settle()
func property(object,key:String):
 for field in object.get_property_list():
  if field.name==key:return object.get(key)
 return null
func start(op:int=0):
 game._start_mission(op);game.set_process(false);game.hints_seen=preload("res://src/campaign/onboarding_text.gd").HINTS.keys();game.mission_hud.hints.dismiss();game._refresh();await settle()
func lock_drone(op:int,busy:bool=false):
 await start(op)
 var s=game.sim;s.mission.rocks=[];s.mission.structures=[]
 for band in s.mission.get("depth_geometry",{}):s.mission.depth_geometry[band].rocks=[];s.mission.depth_geometry[band].structures=[]
 s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 s.units[0].pos=Vector2(100,900);s.units[1].pos=Vector2(600,500);s.units[1].band=1
 var e=s.sirens[0];e.pos=Vector2(720,500);e.home=e.pos;e.goal=e.pos;e.route=[];e.patrol_points=[];e.angle=PI;e.stun=0.0;e.band=1;e.transition={};s.sirens=[e]
 game.hints_seen=["move","pause","drone","noise"];game.mission_hud.hints.dismiss()
 if busy:game.mission_hud.open("tools")
 s.paused=false;s.advance(.5);game._refresh();await settle()
 check(s.contacts.has(0) and s.contacts[0].target==1 and s.contacts[0].lock>0,"real own-drone lock fixture op%d"%op)
 check(s.paused and game.mission_hud.hints.panel.visible,"first drone warning pauses op%d"%op)
 if game.mission_hud.hints.panel.visible:
  check(game.get_global_rect().encloses(game.mission_hud.hints.panel.get_global_rect()),"warning card and acknowledgement fit the safe viewport")
  await tap(game.mission_hud.hints.dismiss_button)
  check(not game.mission_hud.hints.panel.visible,"touch GOT IT dismisses the visible warning card")
 s.paused=false;game._refresh();await settle()
 check(not s.paused,"warning is not repeated after acknowledgement op%d"%op)
func run():
 for profile in [{"size":Vector2i(2520,1080),"dpi":420.,"inset":136},{"size":Vector2i(2184,1968),"dpi":420.,"inset":0},{"size":Vector2i(1280,576),"dpi":95.,"inset":0}]:
  root.size=profile.size;await settle()
  game=load("res://scenes/main.tscn").instantiate();game.set_script(preload("res://tests/fit_label_main.gd"));game.fixture_dpi=profile.dpi;game.capture_scenario="cold-review-ui-fixture"
  if profile.inset:game.fixture_safe_area=Rect2(profile.inset,0,profile.size.x-profile.inset,profile.size.y)
  root.add_child(game);await settle();game.set_process(false)
  await lock_drone(0);await lock_drone(1);await lock_drone(0,true)
  await start();var h=game.mission_hud;var s=game.sim
  game.hints_seen=["move","pause","drone","noise","warning"];h.hints.dismiss();s.contacts={};s.paused=false
  s.sonar.history.append({"station":0,"enemy":0,"origin":s.units[0].pos,"direction":Vector2.UP,"time":s.elapsed,"band":-1,"confidence":.6,"tone":300.,"classification":preload("res://src/simulation/sweeper_senses.gd").WARNING,"direct":true,"kind":"bearing"})
  game._refresh();await settle()
  check(h.hints.current=="sweep" and s.paused,"first heard investigation pauses independently of the earlier lock hint")
  if h.hints.panel.visible:await tap(h.hints.dismiss_button)
  check(s.paused,"GOT IT dismisses a warning without silently resuming")
  game._pause();game._refresh();await settle();check(not s.paused,"acknowledged heard cue does not pause a second time")
  await start();s=game.sim;s.sirens=[];game._refresh();await settle()
  var before=s.snapshot();var marker=property(game.ocean,"goal_marker")
  check(marker!=null and marker.visible,"default FOLLOW view exposes the active offscreen goal")
  if marker!=null:
   check(marker.info.target==s.observable_sites()[0].pos,"goal uses the public masked chart position")
   check(marker.info.get("distance",0)>0 and not str(marker.info.get("text","")).is_empty(),"goal marker includes direction context and distance")
   check(game.get_global_rect().encloses(Rect2(game.ocean.global_position+marker.info.rect.position,marker.info.rect.size)),"goal marker stays inside the safe area")
  check(s.snapshot()==before,"goal indicator reads without changing mission knowledge")
  # Busy-craft replacement uses the actual confirmation flow.
  game.ocean.fit_chart();game._view_changed();await settle()
  for point in [Vector2(600,800),Vector2(900,600)]:
   var p=game.ocean.global_position+game.ocean.screen_position(point);await touch(p,true);await touch(p,false);await settle()
  check(not h.guard.pending.is_empty(),"second water touch opens a replacement confirmation")
  for b in [h.guard.go_button,h.guard.add_button,h.guard.points_button,h.guard.cancel_button]:
   var font=b.get_theme_font("font");var fs=b.get_theme_font_size("font_size");var padding=b.get_theme_stylebox("normal").get_minimum_size().x
   for word in b.text.replace("\n"," ").split(" ",false):check(font.get_string_size(word,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x+padding<=b.size.x+.1,"confirmation word stays whole: "+word)
  game.sim.paused=true;game._refresh();await settle();check("RESUME" in game.pause_button.text and not "RUN" in game.pause_button.text,"pause action consistently says RESUME")
  await start();h=game.mission_hud;s=game.sim;h.open("tools");await settle()
  var rects=property(h,"caption_rects")
  check(rects!=null and not rects.is_empty(),"wheel exposes measured center text bounds")
  if rects!=null:check(rects.all(func(r):return not Rect2(h.global_position+r.position,r.size).intersects(h.close_button.get_global_rect())),"wheel center text does not overlap BACK")
  before=s.snapshot();var point=game.order_buttons.decoy.get_global_rect().get_center();await touch(point,true)
  var jitter=InputEventScreenDrag.new();jitter.index=0;jitter.position=point+Vector2(2,1);jitter.relative=Vector2(2,1);root.push_input(jitter,true)
  await create_timer(.65).timeout;await touch(point+Vector2(2,1),false);await settle()
  check(h.sheet.visible and "DECOY" in h.instrument_info.text and "noise" in h.instrument_info.text.to_lower(),"touch hold explains DECOY before spending it")
  check(s.snapshot()==before,"tool explanation spends nothing and issues no order")
  if not OS.get_environment("SIRENS_EVIDENCE_DIR").is_empty():
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(OS.get_environment("SIRENS_EVIDENCE_DIR").path_join("034-help-%dx%d.png"%[profile.size.x,profile.size.y]))
  root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST);await settle()
  check(game.screen=="mission" and h.page=="tools","Android Back returns from tool help to its wheel")
  if profile.dpi==420.:
   for key in ["emp","recon","sonar_emit","sonar_sector","sonar_power","sonar_history"]:
    var menu="tools" if key in ["emp","recon"] else "acoustics"
    h.open(menu);await settle()
    var b=game.order_buttons[key] if game.order_buttons.has(key) else h.extra[key]
    before=s.snapshot();point=b.get_global_rect().get_center();await touch(point,true);await create_timer(.65).timeout;await touch(point,false);await settle()
    check(h.page=="order_help" and h.sheet.visible and not h.instrument_info.text.is_empty(),"touch hold explains "+key)
    check(s.snapshot()==before,"help for "+key+" issues no order")
    root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST);await settle()
    check(game.screen=="mission" and h.page==menu,"Android Back restores "+menu)
   # An empty tool still explains its purpose; it cannot fire on release.
   s.tools.emp=0;h.open("tools");await settle();before=s.snapshot();point=game.order_buttons.emp.get_global_rect().get_center()
   await touch(point,true);await create_timer(.65).timeout;await touch(point,false);await settle()
   check(h.page=="order_help" and s.snapshot()==before,"spent tool remains explainable without activation")
  await start();h=game.mission_hud;s=game.sim;h.open("craft");await settle()
  check(h.extra.all_stop in h.ring_buttons and h.extra.all_stop.is_visible_in_tree(),"ALL STOP is a primary Quietus choice")
  if h.extra.all_stop in h.ring_buttons:
   check("O2" in h.extra.all_stop.text,"primary ALL STOP discloses oxygen cost")
   var oxygen=s.oxygen;await tap(h.extra.all_stop);check(s.oxygen<oxygen,"primary ALL STOP touch executes its existing paid action")
  # Start a genuine local photo preview, then leave a terminal dive for briefing.
  await start();s=game.sim;var objective=s.mission.objectives[0]
  s.units[0].pos=objective.pos+Vector2(-140,0);s.units[0].angle=0.;s.units[0].vel=Vector2.ZERO;objective.unknown=false
  game._focus_craft();await settle();h.open("craft");await settle();await tap(game.order_buttons.camera)
  check(game.ocean.optical_feed.is_visible_in_tree(),"photo fixture exposes the real viewfinder")
  s.outcome="lost";s.hull=0;game._debrief();game._briefing(0);await settle()
  check(not game.ocean.optical_feed.is_visible_in_tree() and not game.lock_warning.is_visible_in_tree(),"loss and briefing clear transient viewfinder and warning HUD")
  game.queue_free();await settle();await create_timer(.1).timeout
 print("COLD REVIEW UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
