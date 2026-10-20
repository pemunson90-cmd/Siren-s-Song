extends SceneTree
# Source-known own-position fixtures exercise the real model and ordinary touch.
# This is not an earned campaign journey or a blind player preference test.
const BERTH=Vector2(1840,760)
const HOME=Vector2(2260,2700)
const Store=preload("res://src/persistence/save_store.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
var checks=0
var failures=0
var capture_dir=""
const Harbour=preload("res://src/presentation/concealed_harbour_view.gd")
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for frame in 6:await process_frame
func touch(point:Vector2,down:bool,id:int=0,canceled:bool=false):
 var e=InputEventScreenTouch.new();e.index=id;e.position=point;e.pressed=down;e.canceled=canceled;root.push_input(e,true);await process_frame
func mouse(point:Vector2,down:bool):
 var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION;e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
func tap(point:Vector2):
 for down in [true,false]:await touch(point,down);await mouse(point,down)
 await settle()
func drag(point:Vector2,delta:Vector2,id:int=0):
 var e=InputEventScreenDrag.new();e.index=id;e.position=point+delta;e.relative=delta;root.push_input(e,true);await process_frame
func advance(sim,seconds:float):
 sim.paused=false
 for frame in ceili(seconds*60):sim.advance(1./60.)
 sim.paused=true
func progress()->Dictionary:
 return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch","confluence_route":"concealed"},"completed":[6,7,9,11],"notes":{},"references":{},"entitlements":["quietus_vector_drive","drone_deep_cells","quietus_baffles"],"history":[],"selected_thread":"deep"}
func game_for(dimensions:Vector2i,thread:String="deep"):
 root.size=dimensions;await settle()
 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="witness-evacuation-ui"
 if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(g);await settle();g.set_process(false)
 g.completed=[0,1,2,3,4,5];g.unlocked=5;g.expedition=progress();g.expedition.selected_thread=thread;g.expedition.route=thread;g.expedition.routes=[thread];g.expedition.facts={thread:"Recovered branch","confluence_route":"concealed"};g.expedition.completed=[6,7,9,11] if thread=="deep" else [6,8,10,11];g.upgrade="endurance"
 g._start_mission(12);g.sim.sirens=[]
 # These source-known positions isolate local custody, not voyage finishability.
 g.sim.units[0].pos=HOME+Vector2(-200,-20);g.sim.units[0].vel=Vector2.ZERO
 g.sim.units[2].pos=HOME+Vector2(-260,0);g.sim.units[2].vel=Vector2.ZERO
 g._refresh();await settle();return g
func measure(g,unit:int=1):
 g.sim.units[unit].pos=BERTH+Vector2(0,40);g.sim.units[unit].vel=Vector2.ZERO
 g.sim.command("select",{"unit":unit});advance(g.sim,.02);g.ocean.focus_craft();g._refresh();await settle()
func open_pod(g)->bool:
 if g.advanced_orders:g.mission_hud.dismiss();await settle()
 var markers=g.ocean.salvage_markers().filter(func(m):return m.site.get("witness",false))
 if markers.is_empty():check(false,"known occupied pod has a reachable physical target");return false
 await tap(g.ocean.global_position+markers[0].rect.get_center())
 check(g.mission_hud.page=="salvage","touching occupied pod opens its object context")
 return g.mission_hud.page=="salvage"
func select_craft(g,unit:int,open:bool=false):
 if g.advanced_orders:g.mission_hud.dismiss();await settle()
 await tap(g.mission_hud.fleet.buttons[unit].get_global_rect().get_center())
 if open and not g.advanced_orders:await tap(g.mission_hud.fleet.buttons[unit].get_global_rect().get_center())
 if not open and g.advanced_orders:g.mission_hud.dismiss();await settle()
func rejected(g,button,kind:String):
 var before=g.sim.snapshot();var point=button.get_global_rect().get_center()
 await touch(point,true);await mouse(point,true)
 if kind=="short drag":
  await drag(point,Vector2(20,0));await touch(point+Vector2(20,0),false);await mouse(point+Vector2(20,0),false)
 elif kind=="cancel":await touch(point,false,0,true);await mouse(point,false)
 else:
  await touch(point+Vector2(100,0),true,1);await touch(point,false);await mouse(point,false);await touch(point+Vector2(100,0),false,1)
 await settle()
 check(g.sim.snapshot()==before,"rejected "+kind+" plus emulated release issues no witness or water order")
func target_fits(g,button,label:String):
 var scale=Vector2(root.size)/root.get_visible_rect().size
 check(g.get_global_rect().encloses(button.get_global_rect()) and button.size.x*scale.x>=125.99 and button.size.y*scale.y>=125.99,label+" retains a full48dp safe-area target")
func reading(g,unit:int)->Dictionary:
 for row in g.mission_hud.fleet.readouts:
  if row.unit==unit:return row
 return {}
func capture(name:String):
 if capture_dir.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func run_case(dimensions:Vector2i,thread:String):
 var label=("cover" if dimensions.x==2520 else "inner")+"-"+thread
 var g=await game_for(dimensions,thread);var s=g.sim
 check(Harbour.subjects(s).is_empty(),"before rescue no witness-private work targets "+label)
 s.units[0].pos=BERTH+Vector2(0,40);s.units[0].vel=Vector2.ZERO;s.command("select",{"unit":0});advance(s,.02)
 check(s.command("salvage",{"item":"witness_capsule"}),"real model winch starts UI fixture "+label);advance(s,4.1)
 s.units[0].pos=Vector2(1840,1010) if thread=="deep" else Vector2(1940,1040);s.units[0].vel=Vector2.ZERO
 g.ocean.focus_craft();g._refresh();await settle()
 await select_craft(g,0,true)
 var work=g.mission_hud.extra.concealed_work
 check(work.is_visible_in_tree(),"living witness contributes reachable account control "+label)
 await tap(work.get_global_rect().get_center())
 check(g.mission_hud.subject.get("subkind","")=="concealed" and "NAVIGATOR" in g.mission_hud.instrument_info.text if thread=="deep" else "HARBOUR KEEPER" in g.mission_hud.instrument_info.text,"account is attached to actual local problem "+label)
 await capture(label+"-witness-account")
 await tap(g.mission_hud.close_button.get_global_rect().get_center())
 var attach=g.mission_hud.extra.concealed_attach
 check(attach.is_visible_in_tree() and not attach.disabled,"ordinary ring exposes ready local tow "+label);target_fits(g,attach,"ATTACH TOW "+label)
 for kind in ["short drag","cancel","two fingers"]:
  await rejected(g,attach,kind)
  if g.advanced_orders:g.mission_hud.dismiss();await settle()
  g.mission_hud.open("object",Harbour.subjects(s)[0]);g._refresh();await settle();attach=g.mission_hud.extra.concealed_attach
 await capture(label+"-local-tow-orders")
 await tap(attach.get_global_rect().get_center())
 check(s.mission.concealed_harbour.phase=="towing","one ordinary tap couples exactly one actual tow "+label)
 var before=s.snapshot();g._refresh();await settle();check(s.snapshot()==before,"paused drawing and account do not advance tow or earn reply "+label)
 if thread=="deep":
  s.units[0].pos=Vector2(1840,850);s.units[0].vel=Vector2.ZERO;advance(s,2.2)
  check(not s.concealed_status().connected and s.concealed_status().receipt,"actual hauled socket earns external station receipt "+label)
  g.mission_hud.open("object",Harbour.subjects(s)[0]);g._refresh();await settle()
  var release=g.mission_hud.extra.concealed_release;check(not release.disabled,"hauled deep tow can be cast off without arbitrary cradle requirement "+label)
  for kind in ["short drag","cancel","two fingers"]:
   await rejected(g,release,kind)
   g.mission_hud.open("object",Harbour.subjects(s)[0]);g._refresh();await settle();release=g.mission_hud.extra.concealed_release
  await tap(release.get_global_rect().get_center())
  check(s.mission.concealed_harbour.phase=="ready","ordinary release preserves actual disconnected float "+label)
  s.units[0].pos=Vector2(2180,800);s.units[0].vel=Vector2.ZERO;advance(s,.02)
 else:
  var choice=Harbour.subjects(s).filter(func(v):return v.seat=="baffle")[0]
  s.units[0].pos=Vector2(1970,1010);s.units[0].vel=Vector2.ZERO;advance(s,.02)
  g.ocean.focus_craft();g._refresh();await settle();g.mission_hud.open("object",choice);g._refresh();await settle()
  check("longer lower" in g.mission_hud.instrument_info.text,"baffle costs and surviving entry are explained before commitment "+label)
  var seat=g.mission_hud.extra.concealed_seat;check(not seat.disabled,"actual local unfolded baffle is ready "+label);target_fits(g,seat,"SEAT HERE "+label)
  for kind in ["short drag","cancel","two fingers"]:
   await rejected(g,seat,kind)
   g.mission_hud.open("object",choice);g._refresh();await settle();seat=g.mission_hud.extra.concealed_seat
  await tap(seat.get_global_rect().get_center());check(s.mission.concealed_harbour.placement=="baffle","ordinary seat tap changes actual refuge geometry "+label)
  s.units[0].pos=Vector2(2300,970);s.units[0].vel=Vector2.ZERO;advance(s,2.2)
  check(s.concealed_status().receipt and s.concealed_status().station_seen.get("open",false),"local inhabited refuge response is actually earned "+label)
 if g.advanced_orders:g.mission_hud.dismiss();await settle()
 g.ocean.focus_craft();g._refresh();await settle();await capture(label+"-local-consequence")
 g.queue_free();await settle()
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(capture_dir)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  for thread in ["deep","shelf"]:await run_case(dimensions,thread)
 print("CONCEALED HARBOUR UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
