extends SceneTree
# Staged source-known touch fixtures, not a campaign preference/play report.
const BERTH=Vector2(1840,440)
const PANEL=Vector2(1840,380)
const HOME=Vector2(2420,240)
var checks=0
var failures=0
var capture_dir=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for frame in 6:await process_frame
func touch(point:Vector2,down:bool,canceled:bool=false,id:int=0):
 var e=InputEventScreenTouch.new();e.position=point;e.index=id;e.pressed=down;e.canceled=canceled;root.push_input(e,true);await process_frame
func mouse(point:Vector2,down:bool):
 var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION;e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
func tap(point:Vector2):
 for down in [true,false]:await touch(point,down);await mouse(point,down)
 await settle()
func advance(s,seconds:float):
 s.paused=false
 for frame in ceili(seconds*60):s.advance(1./60.)
 s.paused=true
func capture(name:String):
 if capture_dir.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(capture_dir)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="warning-recipient-ui"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false)
  g.completed=[0,1,2,3,4,5];g.unlocked=5;g.expedition={"version":2,"route":"shelf","routes":["shelf"],"facts":{"shelf":"Recovered branch","confluence_route":"overt"},"completed":[6,8,10,11],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"shelf"}
  g._start_mission(13);g.sim.sirens=[];var s=g.sim;var h=g.mission_hud;var label="cover" if dimensions.x==2520 else "inner"
  check(h.extra.has("warning_exposed") and h.extra.has("warning_sheltered") and h.extra.has("warning_gate"),"physical recipient has deliberate contextual route/release controls "+label)
  if not h.extra.has("warning_exposed"):g.queue_free();await settle();continue
  var before=s.snapshot();g.ocean.fit_chart();g._refresh();await settle()
  check(g.ocean.objective_context(g.ocean.screen_position(BERTH),g.ui_touch_height).get("subkind","")!="warning_recipient" and s.snapshot()==before,"unknown hull gains no target or sensing from drawing "+label)
  s.units[0].pos=Vector2(1840,1080);s.units[0].vel=Vector2.ZERO;s.command("camera");advance(s,6.2)
  s.units[0].pos=BERTH+Vector2(-100,0);s.units[0].vel=Vector2.ZERO;advance(s,.8);s.command("camera");advance(s,4.2)
  g.ocean.focus_craft();g._refresh();await settle()
  await tap(g.ocean.global_position+g.ocean.screen_position(BERTH))
  check(g.advanced_orders and h.subject.get("subkind","")=="warning_recipient" and not h.extra.warning_exposed.disabled and h.extra.warning_sheltered.disabled,"earned local recipient opens exposed choice while closed service route stays unavailable "+label)
  await capture(label+"-recipient-course-choice")
  var button=h.extra.warning_exposed;var at=button.get_global_rect().get_center();before=s.snapshot()
  await touch(at,true);await mouse(at,true);await touch(at,false,true);await mouse(at,false);await settle()
  check(s.snapshot()==before,"cancel plus emulated release cannot launch recipient or issue a water order "+label)
  var pre_departure=s.snapshot()
  await tap(h.extra.warning_exposed.get_global_rect().get_center())
  check(s.warning_recipient_status().course=="exposed","exposed choice commits through real touch too "+label)
  check(s.restore(pre_departure),"beam fixture restores a waiting actual hull "+label)
  advance(s,8)
  # An ordinary sighted guard independently acquires the non-player hull.
  var template=load("res://src/simulation/simulation.gd").new();template.start(13)
  var target=s.mission.warning_recipient.body
  var guard=template.sirens[2].duplicate(true);guard.pos=target.pos+Vector2(130,0);guard.home=guard.pos;guard.goal=guard.pos;guard.route=[];guard.patrol_points=[]
  s.sirens=[guard];s.units[0].pos=target.pos+Vector2(-90,0);s.units[0].vel=Vector2.ZERO
  advance(s,5);g.ocean.focus_craft();g._refresh();await settle()
  check(g.ocean.contact_entries().any(func(e):return e.urgent and "WARNING RECIPIENT" in e.text),"fresh beam names actual recipient rather than a fourth/aliased player craft "+label)
  await capture(label+"-recipient-threat")
  check(s.restore(pre_departure),"independent touch fixture restores predeparture model "+label)
  if g.advanced_orders:h.dismiss();await settle()
  s.units[0].pos=PANEL;s.units[0].vel=Vector2.ZERO;g.ocean.focus_craft();g._refresh();await settle()
  var gates=preload("res://src/presentation/warning_recipient_view.gd").markers(g.ocean,s,g.ui_touch_height).filter(func(m):return m.subject.subkind=="warning_gate")
  check(not gates.is_empty(),"local gate has unobstructed full-size object badge "+label)
  if not gates.is_empty():await tap(g.ocean.global_position+gates[0].rect.get_center())
  check(h.extra.warning_gate.is_visible_in_tree() and not h.extra.warning_gate.disabled,"bare Q reaches actual local manual gate control "+label)
  await tap(h.extra.warning_gate.get_global_rect().get_center())
  check(not s.blocked(s.warning_recipient_status().gate.rect.get_center(),12),"touch actually opens physical service water "+label)
  g._refresh();await settle();await capture(label+"-manual-gate-open")
  g._refresh();await settle();await tap(g.ocean.global_position+g.ocean.screen_position(BERTH))
  var scale=Vector2(dimensions)/root.get_visible_rect().size
  check(g.get_global_rect().encloses(h.extra.warning_sheltered.get_global_rect()) and h.extra.warning_sheltered.size.y*scale.y>=125.99,"course choice retains full48dp safe-area touch size "+label)
  await tap(h.extra.warning_sheltered.get_global_rect().get_center());advance(s,2);g._refresh();await settle()
  check(s.warning_recipient_status().course=="sheltered" and s.warning_recipient_status().recipient.pos.distance_to(BERTH)>1,"deliberate sheltered touch starts real continuous transit "+label)
  await capture(label+"-recipient-transit")
  s.units[0].pos=HOME;s.units[0].vel=Vector2.ZERO;advance(s,60);g._process(0);await settle()
  check(s.outcome=="won" and g.screen=="ending" and g.menu.find_child("WarningArrival",true,false)!=null,"actual arrival receipt and recovered Q reach persistent distinct ending "+label)
  await capture(label+"-warning-arrival")
  g.queue_free();await settle()
 print("WARNING RECIPIENT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
