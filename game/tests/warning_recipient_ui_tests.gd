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
func mouse(point:Vector2,down:bool,emulated:bool=true):
 var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION if emulated else 0;e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
func drag(point:Vector2,delta:Vector2):
 var e=InputEventScreenDrag.new();e.position=point+delta;e.relative=delta;e.index=0;root.push_input(e,true);await process_frame
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
func open_craft(g):
 if g.advanced_orders:g.mission_hud.dismiss();await settle()
 await tap(g.ocean.global_position+g.ocean.screen_position(g.sim.units[g.sim.selected].pos))
func rejected(g,button,kind:String,label:String):
 var before=g.sim.snapshot();var point=button.get_global_rect().get_center()
 await touch(point,true);await mouse(point,true)
 if kind=="cancel":await touch(point,false,true);await mouse(point,false)
 elif kind=="pinch":
  await touch(point+Vector2(100,0),true,false,1);await touch(point,false);await mouse(point,false);await touch(point+Vector2(100,0),false,false,1)
 else:
  var delta=Vector2(20,0) if kind=="short drag" else Vector2(220,170)
  await drag(point,delta);await touch(point+delta,false);await mouse(point+delta,false)
 await settle()
 check(g.sim.snapshot()==before,"local "+label+" rejects "+kind+" plus emulated release without orders")
func intent(s)->Dictionary:
 var u=s.units[s.selected]
 return {"selected":s.selected,"queue":s.queue_mode,"paused":s.paused,"silent":u.silent,"route":u.route.duplicate(true),"program":u.get("route_plan",[]).duplicate(true)}
func target_fits(g,button,label:String):
 var scale=Vector2(root.size)/root.get_visible_rect().size
 check(g.get_global_rect().encloses(button.get_global_rect()) and button.size.x*scale.x>=125.99 and button.size.y*scale.y>=125.99,label+" retains a full48dp safe-area target")
func pending_gate_actions(g,label:String):
 var s=g.sim;var h=g.mission_hud;var pending=s.snapshot()
 # The newly added ordinary-camera fallback must share the same tap owner as
 # contextual entry and physical release; native GUI release is insufficient.
 for gesture in ["cancel","short drag","drag off","pinch"]:
  check(s.restore(pending),"restore pending acknowledgement for "+gesture+" "+label)
  await open_craft(g);await tap(g.order_buttons.camera.get_global_rect().get_center())
  await rejected(g,g.order_buttons.camera,gesture,"pending camera/listen "+label)
  if gesture=="cancel":check(g.advanced_orders and h.page=="object","canceled camera/listen keeps gate context open "+label)
 for protocol in ["touch","mouse"]:
  check(s.restore(pending),"restore pending acknowledgement for deliberate "+protocol+" "+label)
  await open_craft(g);await tap(g.order_buttons.camera.get_global_rect().get_center())
  var at=g.order_buttons.camera.get_global_rect().get_center()
  if protocol=="touch":await tap(at)
  else:await mouse(at,true,false);await mouse(at,false,false);await settle()
  var clock=s.capture_feedback()
  check(clock.unit==0 and clock.elapsed==0 and s.paused and not s.warning_recipient_status().informed and not s.warning_recipient_status().gate.opened,"deliberate "+protocol+" starts actual paused LISTEN without opening gate "+label)
  advance(s,4.2)
  check(s.warning_recipient_status().informed and not s.warning_recipient_status().gate.opened,"gate context "+protocol+" LISTEN receives real acknowledgement without releasing gate "+label)
func overlap_gate(g,label:String):
 var s=g.sim;var h=g.mission_hud;var initial=s.snapshot()
 g.ocean.focus_craft();g._refresh();await settle()
 var gates=preload("res://src/presentation/warning_recipient_view.gd").markers(g.ocean,s,g.ui_touch_height).filter(func(m):return m.subject.subkind=="warning_gate")
 check(not gates.is_empty(),"known gate keeps its independent object target "+label)
 if gates.is_empty():return
 await tap(g.ocean.global_position+gates[0].rect.get_center());await tap(h.extra.route_here.get_global_rect().get_center())
 advance(s,12)
 print("LOCAL_GATE_ROUTE ",label," distance=",s.units[0].pos.distance_to(PANEL)," speed=",s.units[0].vel.length())
 check(s.units[0].pos.distance_to(PANEL)<9 and s.units[0].vel.length()<2,"actual gate PLOT ROUTE arrives at overlapping local work position "+label)
 check(s.command("route",{"point":PANEL+Vector2(-40,25)}) and s.command("queue") and s.command("silent"),"stage a real retained route, queue and propulsion choice "+label)
 g.ocean.focus_craft();g._refresh();await settle();var retained=intent(s);var before=s.snapshot()
 await open_craft(g)
 check(g.advanced_orders and h.page=="craft" and s.selected==0 and s.snapshot()==before,"overlapped gate still selects own craft without changing intent "+label)
 var primary=g.order_buttons.camera
 check(primary.text=="GATE\nCONTROLS" and not primary.disabled,"overlapped craft exposes reachable local gate controls "+label)
 target_fits(g,primary,"local gate entry "+label);await capture(label+"-overlapped-local-work")
 for gesture in ["cancel","short drag","drag off","pinch"]:
  await open_craft(g);await rejected(g,primary,gesture,"gate entry "+label)
  check(not g.advanced_orders or h.page=="craft","rejected gate entry never opens or spends local work "+label)
 await open_craft(g);before=s.snapshot();await tap(primary.get_global_rect().get_center())
 check(h.page=="object" and h.subject.get("subkind","")=="warning_gate" and s.snapshot()==before,"deliberate primary opens gate context without spending release/noise "+label)
 check(primary.is_visible_in_tree() and primary.text!="GATE\nCONTROLS","ordinary camera/transmit remains reachable inside gate context "+label)
 target_fits(g,h.extra.warning_gate,"local manual release "+label);await capture(label+"-local-gate-controls")
 # Native mouse follows the same contextual entry, without changing model state.
 await open_craft(g);before=s.snapshot();var at=primary.get_global_rect().get_center()
 await mouse(at,true,false);await mouse(at,false,false);await settle()
 check(h.subject.get("subkind","")=="warning_gate" and h.page=="object" and s.snapshot()==before,"ordinary mouse opens local context exactly once "+label)
 s.units[0].vel=Vector2(2,0);g._refresh();await settle();before=s.snapshot()
 check(h.extra.warning_gate.disabled and "Settle below 2m/s" in h.instrument_info.text,"local gate explains its actual unsettled prerequisite "+label)
 await tap(h.extra.warning_gate.get_global_rect().get_center())
 check(s.snapshot()==before,"disabled local release cannot operate gate "+label)
 await tap(h.extra.inspect.get_global_rect().get_center())
 check(h.sheet.is_visible_in_tree() and h.instrument_info.is_visible_in_tree() and "Settle below 2m/s" in h.instrument_info.text,"real gate STATUS displays unmet release prerequisite "+label)
 await capture(label+"-local-gate-prerequisite");await tap(h.close_button.get_global_rect().get_center())
 s.units[0].vel=Vector2.ZERO;g._refresh();await settle()
 for gesture in ["cancel","short drag","drag off","pinch"]:
  if not g.advanced_orders or h.subject.get("subkind","")!="warning_gate":await open_craft(g);await tap(primary.get_global_rect().get_center())
  await rejected(g,h.extra.warning_gate,gesture,"manual release "+label)
 if not g.advanced_orders or h.subject.get("subkind","")!="warning_gate":await open_craft(g);await tap(primary.get_global_rect().get_center())
 var pre_release=s.snapshot();await tap(h.extra.warning_gate.get_global_rect().get_center())
 check(not s.blocked(s.warning_recipient_status().gate.rect.get_center(),12) and s.noises.filter(func(n):return n.label=="WARNING SERVICE GATE").size()==1,"only deliberate release opens actual gate and emits one real noise "+label)
 check(intent(s)==retained,"local entry and release preserve route/profile/queue and tactical pause "+label)
 g._refresh();await settle();await open_craft(g)
 check(primary.text=="RECIPIENT\nCONTROLS" and not primary.disabled,"opened gate restores earned recipient craft primary "+label)
 await rejected(g,primary,"cancel","earned recipient entry "+label)
 check(g.advanced_orders and h.page=="craft","canceled recipient entry preserves craft context "+label)
 await tap(primary.get_global_rect().get_center())
 check(h.subject.get("subkind","")=="warning_recipient","earned recipient primary remains available after gate work "+label)
 check(s.restore(pre_release),"restore closed gate only for the independent badge/native-mouse fixture "+label)
 if g.advanced_orders:h.dismiss();await settle()
 s.command("select",{"unit":1});g.ocean.focus_craft();g._refresh();await settle();await open_craft(g)
 check(primary.text!="GATE\nCONTROLS" and not h.extra.warning_gate.is_visible_in_tree(),"remote selected drone does not inherit Quietus local gate work "+label)
 await tap(primary.get_global_rect().get_center())
 check(h.subject.get("subkind","")=="warning_recipient" and primary.is_visible_in_tree() and primary.text!="GATE\nCONTROLS","remote selected drone keeps earned recipient and ordinary camera access "+label)
 s.command("select",{"unit":0});g.ocean.focus_craft();g._refresh();await settle()
 if g.advanced_orders:h.dismiss();await settle()
 check(s.restore(initial),"restore waiting recipient for independent badge/native-mouse release "+label)
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
  var unknown=s.snapshot();s.units[0].pos=PANEL;s.units[0].vel=Vector2.ZERO;g.ocean.focus_craft();g._refresh();await settle();before=s.snapshot();await open_craft(g)
  check(g.order_buttons.camera.text!="GATE\nCONTROLS" and s.snapshot()==before and not s.warning_recipient_status().gate.known,"unobserved local gate is not invented by craft context "+label)
  check(s.restore(unknown),"restore initial unknown fixture "+label)
  if g.advanced_orders:h.dismiss();await settle()
  s.units[0].pos=Vector2(1840,1080);s.units[0].vel=Vector2.ZERO;s.command("camera");advance(s,6.2)
  s.units[0].pos=PANEL;s.units[0].vel=Vector2.ZERO;advance(s,.8);g.ocean.focus_craft();g._refresh();await settle();await open_craft(g)
  await tap(g.order_buttons.camera.get_global_rect().get_center())
  check(h.subject.get("subkind","")=="warning_gate" and not g.order_buttons.camera.disabled and g.order_buttons.camera.text in ["CAMERA","CAMERA\nLISTEN","LISTEN"],"nearby closed gate context retains actual pending camera/listen "+label)
  await pending_gate_actions(g,label)
  s.units[0].pos=BERTH+Vector2(-100,0);s.units[0].vel=Vector2.ZERO
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
  await overlap_gate(g,label)
  s.units[0].pos=PANEL;s.units[0].vel=Vector2.ZERO;g.ocean.focus_craft();g._refresh();await settle()
  var gates=preload("res://src/presentation/warning_recipient_view.gd").markers(g.ocean,s,g.ui_touch_height).filter(func(m):return m.subject.subkind=="warning_gate")
  check(not gates.is_empty(),"local gate has unobstructed full-size object badge "+label)
  if not gates.is_empty():await tap(g.ocean.global_position+gates[0].rect.get_center())
  check(h.extra.warning_gate.is_visible_in_tree() and not h.extra.warning_gate.disabled,"bare Q reaches actual local manual gate control "+label)
  var release_at=h.extra.warning_gate.get_global_rect().get_center();await mouse(release_at,true,false);await mouse(release_at,false,false);await settle()
  check(not s.blocked(s.warning_recipient_status().gate.rect.get_center(),12),"touch actually opens physical service water "+label)
  g._refresh();await settle();await capture(label+"-manual-gate-open")
  g._refresh();await settle();await tap(g.ocean.global_position+g.ocean.screen_position(BERTH))
  var scale=Vector2(dimensions)/root.get_visible_rect().size
  check(g.get_global_rect().encloses(h.extra.warning_sheltered.get_global_rect()) and h.extra.warning_sheltered.size.y*scale.y>=125.99,"course choice retains full48dp safe-area touch size "+label)
  await tap(h.extra.warning_sheltered.get_global_rect().get_center());advance(s,2);g._refresh();await settle()
  check(s.warning_recipient_status().course=="sheltered" and s.warning_recipient_status().recipient.pos.distance_to(BERTH)>1,"deliberate sheltered touch starts real continuous transit "+label)
  await capture(label+"-recipient-transit")
  # Keep this staged touch fixture's original arrival wait, then receive the
  # mandatory account through the same craft primary a player uses.
  s.units[0].pos=HOME;s.units[0].vel=Vector2.ZERO;advance(s,60)
  if g.advanced_orders:h.dismiss();await settle()
  g.ocean.focus_craft();g._refresh();await settle();await open_craft(g)
  check(s.camera_context().ready,"pickup LISTEN is locally ready after actual recipient transit "+label)
  # At the arrived launch, the craft primary first opens recipient controls.
  # Its ordinary LISTEN remains available inside that measured object context.
  await tap(g.order_buttons.camera.get_global_rect().get_center())
  check(h.subject.get("subkind","")=="warning_recipient","pickup craft primary opens the received recipient controls "+label)
  await tap(g.order_buttons.camera.get_global_rect().get_center())
  check(not s.captures[0].is_empty(),"deliberate contextual LISTEN starts real pickup work "+label)
  advance(s,4.2)
  check(s.mission.objectives.any(func(o):return o.get("site_id","")=="warning_uplink" and o.captured),"touch receives the mandatory pickup service account "+label)
  g._process(0);await settle()
  check(s.outcome=="won" and g.screen=="ending" and g.menu.find_child("WarningArrival",true,false)!=null,"actual arrival receipt and recovered Q reach persistent distinct ending "+label)
  await capture(label+"-warning-arrival")
  g.queue_free();await settle()
 print("WARNING RECIPIENT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
