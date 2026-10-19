extends SceneTree
const Equipment=preload("res://src/presentation/equipment_context.gd")
var checks=0
var failures=0
var requests=[]
var folder=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 8:await process_frame
func tap(point:Vector2):
 var previous=Input.is_emulating_touch_from_mouse();Input.set_emulate_touch_from_mouse(true)
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.global_position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle();Input.set_emulate_touch_from_mouse(previous)
func picture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=");DirAccess.make_dir_recursive_absolute(folder)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="public-fitting-and-local-receiver-geometry"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._briefing(0);await settle()
  # Public equipment/context fixture exercises the actual view and touch path;
  # this is not a claimed earned recovery or campaign/Main progression proof.
  var context={"slots":{"quietus":"quietus_correlator","drone_a":"drone_sampler","drone_b":""},"available":["quietus_correlator","drone_sampler"],"catalog":[{"id":"quietus_correlator","name":"CADENCE CORRELATOR","compatible_slots":["quietus"],"benefit":"Compare received pulses with a recovered reference.","cost":"6 seconds settled listening. No identity or range fix."},{"id":"drone_sampler","name":"FIELD SAMPLER","compatible_slots":["drone_a","drone_b"],"benefit":"Operate compatible field receivers with one drone.","cost":"8 seconds exposed versus Quietus4. One sampler, A or B."}]}
  var before=g.sim.snapshot();requests.clear()
  var buttons=Equipment.fitting(g,context,func(slot,id):requests.append([slot,id]));g._layout();await settle()
  check(buttons.size()==3 and buttons[2].disabled,"one recovered sampler has explicit unique owner rather than cloned fitting")
  g.scroll.ensure_control_visible(buttons[0]);await settle()
  check(buttons[0].size.y>=g.ui_touch_height,"fitting control keeps actual density-sized minimum touch height")
  await tap(buttons[0].get_global_rect().get_center())
  print("FIT_REQUESTS ",requests," state_unchanged=",g.sim.snapshot()==before," button=",buttons[0].get_global_rect()," scroll=",g.scroll.get_global_rect())
  check(requests==[["quietus",""]] and g.sim.snapshot()==before,"ordinary fit-row touch requests BARE once without touching active dive or granting equipment")
  var name="cover" if dimensions.x==2520 else "inner"
  await picture(name+"-fitting-fixture")
  g._start_mission(7);await settle()
  # Local acquisition geometry fixture: real passive reception earns site first.
  g.sim.units[0].pos=Vector2(540,800);g.sim.units[0].vel=Vector2.ZERO;g.sim.paused=false;g.sim.advance(.1);g.sim.paused=true
  g.ocean.focus_craft();g._refresh();await settle()
  check(g.sim.observable_sites().any(func(site):return site.site_id=="rendezvous"),"real close passive reception exposes the known Deep receiver")
  check(g.sim.command("camera"),"actual CAMERA/LISTEN starts permitted Deep receiver acquisition")
  g._refresh();await settle();before=g.sim.snapshot()
  check(g.ocean.optical_feed.visible,"known local receiver uses actual acquisition feed")
  check(preload("res://src/presentation/receiver_scene.gd").applies(g.sim.mission.id,g.sim.mission.objectives[g.sim.capture_target]),"Deep capture chooses analytical receiver rather than false Foundry")
  await picture(name+"-deep-receiver-fixture")
  check(g.sim.snapshot()==before,"analytical receiver rendering does not mutate or reveal new observations while paused")
  g.queue_free();await settle()
 print("CAMPAIGN INSTRUMENT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
