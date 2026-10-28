extends SceneTree
const Console=preload("res://src/debug/debug_console.gd")
const State=preload("res://src/debug/dev_state.gd")
const Simulation=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test";root.add_child(game);game.set_process(false)
 var dev=game.debug_console
 check(dev!=null,"debug host installs console")
 check(not Console.available(false) and Console.install(game,false)==null,"release flag prevents every console node")
 check(not State.marked(game),"ordinary profile starts unmarked")
 dev.open();check(dev.panel.visible and game.sim.paused,"console opens and pauses")
 # Closing a read-only console preserves eligibility.
 dev.panel.hide();check(State.eligible(game),"opening alone preserves clean profile")
 for thread in ["deep","shelf"]:
  for channel in ["concealed","overt"]:
   for votes in ["none","concealed","overt"]:
    game.active_started=false;game.screen="menu";dev.execute("preset %s %s %s found"%[thread,channel,votes])
    var h=State.setup(game).history
    check(h.selected_thread==thread and h.confluence_route==channel,"preset history "+thread+channel+votes)
    game.active_started=false;dev.execute("jump 34")
    check(game.sim.mission.id==34 and game.sim.mission.get("launch_context",{}).get("facts",{}).get("confluence_route")==channel,"ordinary authored launch consumes history")
 for id in Console.Catalog.registered_ids():
  game.active_started=false;dev.execute("jump "+str(id));check(game.sim.mission.id==id,"jump authored op "+str(id))
 game.active_started=false;game.screen="menu";dev.execute("complete 17");check(17 in State.setup(game).completed,"DEV completion setup")
 dev.execute("fact glass_choice service");check(State.setup(game).history.glass_choice=="service","fact set")
 dev.execute("clear glass_choice");check(not State.setup(game).history.has("glass_choice"),"fact clear")
 dev.execute("grant scrap 4");dev.execute("unlock")
 check(State.setup(game).items.size()==State.Equipment.ITEMS.size(),"all modules unlocked")
 check(State.marked(game) and not State.eligible(game),"mutation permanently excludes records and standing")
 game.active_started=false;dev.execute("jump 0");var archive=game._archive()
 check(game.store.valid(archive),"DEV active archive validates")
 game.store.path="user://101-dev-test.save";check(game.store.save(archive),"DEV profile writes")
 State.restore(game,{},true);game.sim.mission.erase("dev");game._load_archive();check(State.marked(game) and not State.eligible(game),"taint survives disk reload")
 for value in ["yes",1,{},[]]:
  var bad=archive.duplicate(true);bad.dev=value;check(not game.store.valid(bad),"malformed DEV field rejected")
 var bad=archive.duplicate(true);bad.dev_setup=[];check(not game.store.valid(bad),"malformed setup rejected before dereference")
 game.active_started=true;game.screen="menu"
 var setup_before=State.setup(game).duplicate(true)
 check(dev.execute("fact glass_choice sever").begins_with("Between dives") and State.setup(game)==setup_before,"Operations screen cannot bypass active-dive setup guard")
 dev.execute("end");check(not game.active_started,"explicit DEV end returns to setup")
 # Role dispatch mirrors actual sight and emission paths, including silent network relays.
 game.active_started=false;dev.execute("jump 0")
 var guard=game.sim.sirens[0].duplicate(true);var quietus=game.sim.units[0]
 quietus.vel=Vector2(90,0);quietus.silent=false;guard.band=quietus.band
 for role in ["buoy","relay","interceptor","warden","patroller"]:
  guard.type=role;var ranges=dev.Overlay.ranges(game.sim,guard)
  if role in ["buoy","relay"]:check(ranges.silent==0 and ranges.cruise==0,"network role has no sight: "+role)
  if role=="buoy":check(is_equal_approx(ranges.hearing,minf(650.,game.sim.motion_radius(0)*1.6)),"buoy hearing uses network emission cap")
  if role=="relay":check(ranges.hearing==0.,"relay never samples craft sounds")
  if role in ["interceptor","warden"]:check(ranges.silent==180. and ranges.cruise==290.,"industrial role uses unscaled sight: "+role)
  if role=="patroller":check(is_equal_approx(ranges.cruise,290.*dev.Overlay.Hunt.sight(game.sim.mission,guard,dev.Overlay.Recon.readiness(guard))),"ordinary role uses Hunt sight")
 quietus.vel=Vector2.ZERO;guard.type="buoy"
 check(dev.Overlay.ranges(game.sim,guard).hearing==0.,"stationary Quietus emits no buoy motion candidate")
 # Overlays only read the same simulation. Draw while paused between identical advances.
 game.active_started=false;dev.execute("jump 0");game.sim.paused=false
 var mirror=Simulation.new();check(mirror.restore(game.sim.snapshot()),"mirror restores");mirror.paused=false
 for layer in dev.Overlay.LAYERS:dev.layers[layer]=true
 for i in 600:
  game.sim.advance(.1);mirror.advance(.1)
  if i%60==0:
   var before=hash(game.sim.snapshot());dev.overlay.queue_redraw();await process_frame
   check(hash(game.sim.snapshot())==before,"overlay draw is read-only at "+str(i))
 check(hash(game.sim.snapshot())==hash(mirror.snapshot()),"60 second overlay observation leaves simulation hash identical")
 check(JSON.parse_string(dev.json_log()) is Dictionary,"run export is valid JSON")
 game.active_started=false;dev.execute("jump 0");dev.reset_metrics()
 var hidden=game.sim.sirens[0];hidden.lock=1.;hidden.target=0;game.sim.contacts.clear();dev.sample()
 check(dev.metrics.received_lock_episodes==0,"unseen raw lock does not count as a received episode")
 game.sim.contacts[0]={"time":game.sim.elapsed-.5,"lock":1.};dev.sample()
 check(dev.metrics.received_lock_episodes==0,"expired received lock does not count")
 game.sim.contacts[0].time=game.sim.elapsed;dev.sample();dev.sample()
 check(dev.metrics.received_lock_episodes==1,"fresh received-contact lock counts one transition")
 game.sim.contacts[0].lock=0.;dev.sample();game.sim.contacts[0].lock=1.;dev.sample()
 check(dev.metrics.received_lock_episodes==2,"received lock break and reacquisition starts a new episode")
 game.sim.contacts[0].time=game.sim.elapsed-.5;dev.sample();game.sim.contacts[0].time=game.sim.elapsed;dev.sample()
 check(dev.metrics.received_lock_episodes==3,"receipt expiry and fresh reacquisition starts a new episode")
 game.active_started=false;dev.execute("jump 0");dev.execute("invulnerable");game.sim.paused=false
 var s=game.sim.sirens[0];s.pos=game.sim.units[0].pos+Vector2(30,0);s.lock=3.99;s.target=0;game.sim.sensor_clock=0
 var before_hull=game.sim.hull;dev.advance(.1)
 check(game.sim.hull==before_hull and game.sim.outcome.is_empty() and game.sim.units[0].alive,"invulnerable restores survival after actual beam")
 check(float(s.lock)>=4.,"invulnerable retains actual lock clock")
 check(game.sim.contacts.has(0) and float(game.sim.contacts[0].lock)>0 and dev.metrics.received_lock_episodes>0,"invulnerable lock episode measured through actual sensor receipt")
 dev.execute("invulnerable");game.sim.paused=true;var t=game.sim.elapsed;dev.execute("step")
 check(game.sim.paused and is_equal_approx(game.sim.elapsed,t+game.sim.STEP),"paused step advances one fixed tick")
 game.active_started=false;dev.execute("jump 0");dev.execute("time 4");game.sim.paused=false;t=game.sim.elapsed;dev.advance(.1)
 check(is_equal_approx(game.sim.elapsed,t+.4),"4x processes scaled time without frame cap loss")
 for viewport in [Vector2i(1080,2520),Vector2i(2520,1080)]:
  root.size=viewport
  for n in 6:await process_frame
  game._layout();dev.open();await process_frame
  check(dev.panel.size.x<=game.get_viewport_rect().size.x and dev.panel.size.y<=game.get_viewport_rect().size.y,"console fits viewport "+str(viewport))
  for b in dev.panel.find_children("*","Button",true,false):check(b.custom_minimum_size.y>=48,"touch row >=48dp")
 dev.panel.hide()
 # Actual input reaches the shared console close control on both physical shapes.
 for viewport in [Vector2i(1080,2520),Vector2i(2520,1080)]:
  root.size=viewport
  for n in 6:await process_frame
  game._layout();dev.open()
  for n in 8:await process_frame
  var close=dev.panel.find_children("*","Button",true,false)[0]
  await tap(close.get_global_rect().get_center())
  check(not dev.panel.visible,"real injected touch closes console "+str(viewport))
  for n in 4:await process_frame
  var badge=dev.badge.get_global_rect()
  check(badge.size.x>=game.ui_touch_height and badge.size.y>=game.ui_touch_height,"DEV badge shares both touch dimensions "+str(viewport))
  for occupied in game.mission_hud.occupied_rects():check(not badge.intersects(occupied),"DEV badge avoids occupied HUD plate "+str(viewport))
  check(not badge.intersects(game.pause_button.get_global_rect()),"DEV badge preserves Pause hit rectangle "+str(viewport))
  for control in game.find_children("*","Button",true,false):
   if control!=dev.badge and control.is_visible_in_tree() and not dev.is_ancestor_of(control):check(not badge.intersects(control.get_global_rect()),"DEV badge avoids visible action "+control.text)
  await tap(badge.get_center())
  check(dev.panel.visible,"injected DEV badge touch opens console "+str(viewport))
  dev.panel.hide()
 # All three real mode entry points reject settlement before their state machines.
 for mode in ["frontend/challenge_session","runs/expedition_session","career/career_session"]:
  var session=load("res://scenes/main.tscn").instantiate();session.set_script(load("res://src/presentation/"+mode+".gd"));session.campaign_host=game
  if "challenge" in mode:session.challenge_id="shelf_passive"
  if "expedition" in mode:session.run_state=preload("res://src/campaign/runs/run_state.gd").new_run(101)
  if "career" in mode:session.career_state=preload("res://src/campaign/career/career_state.gd").new_career()
  root.add_child(session);session.set_process(false)
  var before={}
  if "expedition" in mode:before=session.run_state.duplicate(true)
  if "career" in mode:before=session.career_state.duplicate(true)
  var records=game.challenge_records.duplicate(true)
  session.sim.outcome="won";session._debrief()
  check(session.screen=="dev_debrief","DEV intercepted actual mode: "+mode)
  if "challenge" in mode:check(game.challenge_records==records,"challenge bests excluded")
  if "expedition" in mode:check(session.run_state==before,"expedition records excluded")
  if "career" in mode:check(session.career_state==before,"career settlement/standing excluded")
  var old=session.debug_console;session.debug_console=null;session._debrief()
  check(session.screen=="dev_debrief","release-safe settlement guard: "+mode)
  session.debug_console=old;session.queue_free();await process_frame
 dev.debrief();check(game.screen=="dev_debrief","DEV debrief owns terminal flow")
 check(game.completed.is_empty(),"DEV result never credits campaign or Ironman progression")
 game.queue_free();await process_frame
 await replacement_case("manual");await replacement_case("fork")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://101-dev-test.save"+suffix)
 print("DEBUG CONSOLE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)

func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true);await process_frame
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 for n in 6:await process_frame

func replacement_case(kind:String):
 var path="user://101-dev-replace-"+kind+".save"
 var storage=preload("res://src/persistence/save_states/save2_store.gd").new(path)
 storage.delete_all(true)
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
 var host=load("res://scenes/main.tscn").instantiate();host.capture_scenario="runtime-test";host.store.path=path
 root.add_child(host);host.set_process(false);host.active_started=false
 var clean=host._archive();clean.erase("active")
 check(host.store.save(clean),"clean replacement fixture writes "+kind)
 var saved=storage.save_manual(0,clean,"Before DEV") if kind=="manual" else storage.save_fork("route",clean,"Before DEV")
 check(saved,"pre-DEV timeline captured "+kind)
 State.mark(host);check(host.store.save(host._archive()),"DEV profile persists before replacement "+kind)
 var token=storage.inspect(kind,0).token
 check(preload("res://src/persistence/save_states/save2_session.gd").restore(host,kind,0,token),"actual SAVE2 restore begins "+kind)
 for n in 12:await process_frame
 var fresh=null
 for child in root.get_children():
  if child.get_meta("save2_replaced",false):fresh=child;break
 check(fresh!=null,"SAVE2 installed replacement host "+kind)
 if fresh!=null:
  fresh.set_process(false)
  check(State.marked(fresh) and not State.eligible(fresh),"permanent DEV survives actual host replacement "+kind)
  check(fresh.store.load_game().get("dev",false),"replacement writes DEV atomically to disk "+kind)
  fresh._new_campaign()
  check(not State.marked(fresh),"intentional New Campaign clears DEV "+kind)
  fresh.queue_free();await process_frame
 storage.delete_all(true)
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
