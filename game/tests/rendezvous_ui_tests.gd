extends SceneTree
# Explicit local geometry fixtures. These exercise real touch controls and the
# public tender projection; they are not earned campaign journeys.
var checks=0
var failures=0
var folder=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 6:await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func advance(sim,seconds:float):
 sim.paused=false
 for n in roundi(seconds*60):sim.advance(1./60.)
 sim.paused=true
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func action(game,id:String):
 for b in game.menu.find_children("*","Button",true,false):
  if b.get_meta("action","")==id:return b
 return null
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 check(ResourceLoader.exists("res://src/presentation/rendezvous_view.gd"),"Deep7 has a sensed tender and discovered berth-control projection")
 if failures:finish();return
 var View=load("res://src/presentation/rendezvous_view.gd")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="deep-rendezvous-ui-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false)
  game.completed=[0,1,2,3,4,5];game.unlocked=5;game.fitted_equipment.drone_a="drone_deep_cells";game._start_mission(7);await settle()
  var sim=game.sim;sim.sirens=[];var label="cover" if dimensions.x==2520 else "inner"
  check(game.sound.cues.has("berth_release"),"soundscape registers the berth release event as a real player machinery cue")
  var samples=game.sound.samples("berth_release");var peak=0.;var energy=0.
  for value in samples:peak=maxf(peak,absf(value));energy+=value*value
  check(peak<.95 and energy>.01 and samples!=game.sound.samples("alert"),"berth release has a distinct nonzero machinery signal with clipping headroom")
  var before=sim.snapshot();var unknown=View.projection(sim)
  check(unknown.hull.is_empty() and unknown.control.is_empty() and unknown.course.is_empty() and sim.snapshot()==before,"unlocated tender presentation contains no hidden position or announced course and cannot acquire knowledge")
  # A local scout earns the control independently; Survey earns the remote hull.
  sim.units[2].pos=Vector2(650,1120);sim.command("select",{"unit":2});advance(sim,.8);game.ocean.focus_craft();game._refresh();await settle()
  var control=sim.rendezvous_context().control
  check(control.known and not View.projection(sim).control.is_empty() and View.projection(sim).hull.is_empty(),"local control discovery does not draw an unsensed hull")
  var goals=sim.route_goals().duplicate(true);before=sim.snapshot()
  var marker=View.markers(game.ocean,sim,game.ui_touch_height).filter(func(m):return m.subject.subkind=="berth_control")[0]
  check(not game.ocean.ship_instrument_rects().any(func(rect):return rect.intersects(marker.rect)),"discovered control badge stays clear of own craft instruments")
  await tap(game.ocean.global_position+marker.rect.get_center())
  var h=game.mission_hud
  check(game.advanced_orders and h.subject.get("subkind","")=="berth_control" and sim.snapshot()==before,"touching acquired control opens its own context without route or model mutation")
  check(h.extra.has("rendezvous_release") and h.extra.rendezvous_release.visible and not h.extra.rendezvous_release.disabled and not game.order_buttons.camera.visible,"local settled scout gets release instead of a misleading camera action")
  check("950m" in h.extra.rendezvous_release.text and "6s" in h.extra.rendezvous_release.text,"release action discloses finite audible reach and duration before activation")
  sim.units[2].vel=Vector2(13,0);game._refresh();await settle()
  check(h.extra.rendezvous_release.disabled,"release control follows actual settling eligibility while its context stays open")
  sim.units[2].vel=Vector2.ZERO;game._refresh();await settle()
  await capture(label+"-control-release")
  await tap(h.extra.rendezvous_release.get_global_rect().get_center())
  check(sim.rendezvous_context().released and sim.route_goals()==goals and sim.noises.filter(func(n):return n.label=="BERTH RELEASE").size()==1 and not game.advanced_orders,"separate touch starts exactly one real audible voyage while preserving route and pause")
  game.sound.update(sim,0,true)
  check(game.sound.cues.has("berth_release") and game.sound.voices.any(func(voice):return voice.stream==game.sound.cues.get("berth_release")),"real release event reaches a positional audio voice through the ordinary soundscape")
  h.open("object",{"kind":"objective","subkind":"berth_control","name":"BERTH CONTROL","pos":control.pos});await settle()
  check(h.extra.rendezvous_release.disabled,"used control cannot issue repeated departures")
  h.open("inspect");await settle()
  check("permanent" in h.instrument_info.text.to_lower() and "announced" in h.instrument_info.text.to_lower(),"control status explains authored course and permanent refuge without promising live tracking")
  h.dismiss();sim.command("recon");game._refresh();await settle()
  var report=View.projection(sim)
  check(not report.hull.is_empty() and report.hull.live and report.course==sim.rendezvous_context().course,"finite Survey draws permitted measured hull and announced route")
  game.ocean.chart_camera.mode="free";game.ocean.chart_camera.center=Vector2(530,670);game._layout();await settle();await capture(label+"-sensed-tender")
  sim.recon_time=0
  for unit in sim.units:unit.pos=Vector2(1800,2180);unit.vel=Vector2.ZERO
  advance(sim,.8);var stale=View.projection(sim);advance(sim,4);report=View.projection(sim)
  check(not stale.hull.live and report.hull.pos==stale.hull.pos and report.hull.age>stale.hull.age and "LAST" in report.hull.label and "STALE" in report.hull.label,"unsensed transit keeps an explicitly stale stationary last fix")
  before=sim.snapshot();game._refresh();await settle();check(sim.snapshot()==before,"refreshing stale hull cannot reveal or advance private vessel state")
  await capture(label+"-stale-fix")
  marker=View.markers(game.ocean,sim,game.ui_touch_height).filter(func(m):return m.subject.subkind=="rendezvous_hull")[0]
  await tap(game.ocean.global_position+marker.rect.get_center())
  check("LAST FIX" in h.extra.route_here.text and game.order_buttons.camera.disabled,"stale vessel context offers an explicit last-fix approach and cannot remotely decode")
  await tap(h.extra.route_here.get_global_rect().get_center())
  check(not sim.route_goals().is_empty() and sim.route_goals().back().pos==stale.hull.pos,"actual last-fix route action uses measured position rather than hidden moving source")
  sim.command("hold")
  # Quietus meets the permanent refuge; the equipped drone remains outside.
  advance(sim,30);sim.units[0].pos=Vector2(420,210);sim.units[0].vel=Vector2.ZERO;sim.command("select",{"unit":0});advance(sim,.8)
  game.ocean.focus_craft();game._refresh();await settle()
  report=View.projection(sim)
  check(report.hull.live and report.hull.phase=="refuge","local arrival reacquires the real permanent refuge hull")
  check(game.ocean.pick_context(game.ocean.screen_position(sim.units[0].pos),game.ui_touch_height).get("kind","")=="craft","nearby tender body does not steal Quietus's own craft tap; its separate hull badge remains available")
  var hull_markers=View.markers(game.ocean,sim,game.ui_touch_height).filter(func(m):return m.subject.subkind=="rendezvous_hull")
  check(not hull_markers.is_empty(),"sensed refuge hull has a visible accessible badge beside Quietus")
  if hull_markers.is_empty():
   game.queue_free();await settle();continue
  marker=hull_markers[0]
  await tap(game.ocean.global_position+marker.rect.get_center())
  check(h.subject.get("subkind","")=="rendezvous_hull" and game.order_buttons.camera.visible and not game.order_buttons.camera.disabled and "DECODE" in game.order_buttons.camera.text,"sensed refuge hull exposes the ordinary local Quietus decode")
  await tap(game.order_buttons.camera.get_global_rect().get_center());advance(sim,2);game._refresh();await settle()
  check(sim.capture_feedback().unit==0 and sim.capture_feedback().elapsed>=1.9,"touch decode starts the existing real four-second receiver work")
  var lines=View.receiver_lines(sim,0)
  check(lines.any(func(line):return "LOCAL HULL" in line) and lines.any(func(line):return "m" in line) and not lines.any(func(line):return "No hull image" in line),"receiver feed reports permitted actual local hull reception rather than an unrelated analytical no-range claim")
  await capture(label+"-refuge-receiver")
  advance(sim,2.2);game._process(0);await settle()
  check(sim.mission.objectives[0].captured and game.screen=="departure" and sim.paused and action(game,"keep_recovering")!=null,"refuge decode coexists with outstanding module-return decision without premature debrief")
  await capture(label+"-refuge-module-decision")
  if action(game,"keep_recovering")==null:game.queue_free();await settle();continue
  await tap(action(game,"keep_recovering").get_global_rect().get_center())
  check(game.screen=="mission" and sim.paused and sim.outcome.is_empty(),"keep recovering returns from refuge departure to paused normal craft control")
  # A separate bare Quietus fixture proves the original silent berth action.
  game.fitted_equipment.drone_a="";game._start_mission(7);sim=game.sim;sim.sirens=[];sim.units[0].pos=Vector2(380,760);sim.units[0].vel=Vector2.ZERO;advance(sim,.8)
  game.ocean.focus_craft();game._refresh();await settle();h.open("craft");await settle()
  check("DECODE" in game.order_buttons.camera.text and not game.order_buttons.camera.disabled,"Quietus-only quiet berth remains directly available through craft commands")
  await tap(game.order_buttons.camera.get_global_rect().get_center());advance(sim,4.2)
  check(sim.mission.objectives[0].captured and not sim.rendezvous_context().released,"quiet berth touch decode never requires releasing the hull or optional hardware")
  game.queue_free();await settle()
 finish()
func finish():
 print("RENDEZVOUS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
