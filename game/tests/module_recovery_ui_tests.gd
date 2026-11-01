extends SceneTree
const Fleet=preload("res://src/presentation/fleet_instruments.gd")
const Equipment=preload("res://src/presentation/equipment_context.gd")
class RecoverySim:
 extends "res://src/simulation/simulation.gd"
 var recovery={"modules":[{"item":"drone_sampler","name":"FIELD SAMPLER","state":"salvage","unit":-1,"pos":Vector2(200,200)}],"cargo":[[],[],[]],"jobs":[{},{},{}],"result":{}}
 var local_ready=true
 var departure={"available":false,"pending":false,"confirmation_required":false,"corridor":{"name":"HOME BASIN","route":"home","pos":Vector2(140,800)},"recovered":[],"left":[],"recovered_drones":[],"text":""}
 var requests=[]
 func module_recovery_status()->Dictionary:return recovery.duplicate(true)
 func salvage_sites()->Array:return recovery.modules.filter(func(m):return m.state=="salvage").map(func(m):return {"item":m.item,"name":m.name,"pos":m.pos})
 func salvage_context(item:String,unit_id:int=-1)->Dictionary:return {"item":item,"unit":selected if unit_id<0 else unit_id,"ready":local_ready,"reason":"READY" if local_ready else "Move within60m with clear line of sight.","active":false,"claimed_by":-1,"elapsed":0.,"duration":4.,"distance":40.,"range":60.,"noise_radius":520.}
 func departure_context()->Dictionary:return departure.duplicate(true)
 func command(order:String,args:Dictionary={})->bool:
  if order in ["salvage","depart"]:
   requests.append({"order":order,"args":args.duplicate(true)})
   if order=="depart" and not args.get("confirm",false):departure.pending=false
   return true
  return super.command(order,args)
var checks=0
var failures=0
var folder=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func action(game,id:String):
 for b in game.menu.find_children("*","Button",true,false):
  if b.get_meta("action","")==id:return b
 return null
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 # Projection fixtures use the stable public own-module API. No simulated
 # recovery, campaign earning or touch journey is claimed by these checks.
 var sim=RecoverySim.new();sim.start(0);var fleet=Fleet.new();fleet.host={"sim":sim}
 sim.recovery.jobs[1]={"item":"drone_sampler","elapsed":1.,"duration":4.}
 var work=fleet.task(1)
 check("RECOVER" in work and "25%" in work and "FIELD SAMPLER" in work,"remote recovery job names the module and its own four-second progress")
 sim.recovery.jobs[1]={};sim.recovery.cargo[2]=["drone_sampler"];sim.recovery.modules[0].state="cargo";sim.recovery.modules[0].unit=2
 var cargo=fleet.task(2)
 check("CARGO" in cargo and "FIELD SAMPLER" in cargo and "INACTIVE" in cargo,"carried module remains identifiable and explicitly inactive")
 var context={"slots":{"quietus":"","drone_a":"","drone_b":""},"available":[],"catalog":[{"id":"drone_sampler","name":"FIELD SAMPLER","compatible_slots":["drone_a","drone_b"],"benefit":"Independent field sampling.","cost":"Eight audible seconds."}]}
 var rows=Equipment.rows(context)
 check(rows.size()==2 and rows.all(func(row):return row.get("unavailable",false)),"earned but physically lost drone module remains visible as unavailable at both compatible stations")
 fleet.free()
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="module-recovery-ui-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game.sim=RecoverySim.new();game._start_mission(0);await settle()
  var s=game.sim;s.units[0].pos=Vector2(300,800);s.units[1].alive=false;s.recovery.modules[0].pos=Vector2(340,800);game.ocean.focus_craft();game._refresh();await settle()
  var marker=game.ocean.salvage_markers()[0].rect.get_center()
  await tap(game.ocean.global_position+marker)
  check(game.advanced_orders and game.mission_hud.page=="salvage","touching known module marker opens recovery context instead of plotting water route")
  if game.mission_hud.extra.has("salvage"):
   var button=game.mission_hud.extra.salvage
   check(button.visible and not button.disabled and "4s" in button.text,"local recovery action communicates its four-second commitment")
   await tap(button.get_global_rect().get_center())
   check(s.requests.size()==1 and s.requests[0]=={"order":"salvage","args":{"item":"drone_sampler"}},"context touch sends exactly one selected-craft recovery command")
   game.mission_hud.open("salvage",{"kind":"salvage","item":"drone_sampler","name":"FIELD SAMPLER","pos":Vector2(340,800)})
   s.local_ready=false;game._refresh();await settle()
   check(game.mission_hud.extra.salvage.disabled,"range/line-of-sight eligibility disables recovery rather than silently starting work")
  else:check(false,"module context exposes its own recovery action")
  game.mission_hud.dismiss();s.requests.clear()
  s.departure.merge({"available":true,"pending":true,"confirmation_required":true,"left":[{"item":"drone_sampler","name":"FIELD SAMPLER","state":"salvage","unit":-1,"pos":Vector2(340,800),"reason":"Module remains in the water."}]},true)
  game._process(0);await settle()
  check(game.screen=="departure" and s.paused,"new pending module departure pauses and presents an explicit decision")
  if game.screen!="departure":game.queue_free();await settle();continue
  await capture(("cover" if dimensions.x==2520 else "inner")+"-departure-salvage")
  var keep=action(game,"keep_recovering");var leave=action(game,"abandon_modules")
  check(keep!=null and leave!=null and "ABANDON" in leave.text,"departure separates keep-recovering from explicit module abandonment")
  check(game.panel_box.find_children("*","Label",true,false).any(func(l):return "FIELD SAMPLER" in l.text),"loss confirmation names the actual missing module")
  var original=s.departure.left.duplicate(true)
  s.departure.left.append({"item":"drone_survey_array","name":"DRONE SURVEY ARRAY","state":"fitted","unit":2,"pos":s.units[2].pos,"reason":"Carrier outside this recovery mouth"})
  game._confirm_module_departure();await settle()
  var named=game.panel_box.find_children("*","Label",true,false).filter(func(l):return "FIELD SAMPLER" in l.text or "SURVEY ARRAY" in l.text)
  check(named.size()==2 and named.all(func(l):return game.scroll.get_global_rect().encloses(l.get_global_rect())),"both actual module identities and holder states are visible before abandonment without scrolling")
  await capture(("cover" if dimensions.x==2520 else "inner")+"-departure-two-modules")
  s.departure.left=original;game._confirm_module_departure();await settle();keep=action(game,"keep_recovering")
  await tap(keep.get_global_rect().get_center())
  check(game.screen=="mission" and s.paused and s.requests==[{"order":"depart","args":{"confirm":false}}],"keep-recovering acknowledges once and returns paused to normal craft commands")
  s.paused=false;game._process(0);await settle()
  check(game.screen=="mission" and not s.paused,"acknowledged departure does not repeatedly pause drones waiting for recovery")
  s.departure.pending=true;game._process(0);await settle()
  s.departure.left[0].item="drone_survey_array";s.departure.left[0].name="DRONE SURVEY ARRAY"
  await tap(action(game,"abandon_modules").get_global_rect().get_center())
  check(s.requests.size()==1 and game.screen=="departure","changed missing-module list is shown for a new decision before any abandonment command")
  await tap(action(game,"abandon_modules").get_global_rect().get_center())
  check(s.requests.size()==2 and s.requests[1]=={"order":"depart","args":{"confirm":true,"corridor":s.departure.corridor}},"explicit confirmed list sends one validated departure command bound to the viewed mouth")
  # Actual authored two-mouth geometry with isolated public departure state.
  game._start_mission(11);await settle();s.requests.clear()
  var mouth=s.extraction_corridors().filter(func(c):return c.route=="overt")[0]
  check(mouth.pos!=s.mission.extraction,"two-mouth fixture distinguishes selected overt exit from default extraction")
  s.departure.merge({"available":true,"pending":true,"confirmation_required":true,"corridor":mouth,"left":[{"item":"drone_sampler","name":"FIELD SAMPLER","state":"cargo","unit":2,"pos":s.units[2].pos,"reason":"Carrier outside this recovery mouth"}]},true)
  s.units[2].silent=true;s.units[2].drone_drive="quiet";s.queue_mode=true
  # 127 (Pat 2026-10-30): carrier-to-mouth return is a dev/test shortcut; release play hides it.
  game.set_meta("dev_profile",true);s.mission["dev"]=true
  game._confirm_module_departure();await settle()
  await capture(("cover" if dimensions.x==2520 else "inner")+"-departure-holder")
  var home=action(game,"return_module_2")
  check(home!=null,"departure offers an explicit return action for the living module holder")
  if home!=null:
   game.scroll.ensure_control_visible(home);await settle();await tap(home.get_global_rect().get_center())
   var goals=s.route_goals()
   check(s.selected==2 and not s.queue_mode and not goals.is_empty() and goals[0].pos==mouth.pos,"holder return replaces route toward the selected actual mouth rather than mission default")
   check(s.units[2].silent and s.units[2].drone_drive=="quiet" and game.screen=="mission" and s.paused,"explicit holder return preserves profile and drive and leaves unlimited planning paused")
  s.mission.fleet_commit=false;game._confirm_module_departure();await settle()
  check(game.panel_box.find_children("*","Label",true,false).any(func(l):return "COMPLETED REPLAY" in l.text and "stock unchanged" in l.text),"completed replay confirmation does not claim permanent future module loss")
  game.queue_free();await settle()
 print("MODULE RECOVERY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
