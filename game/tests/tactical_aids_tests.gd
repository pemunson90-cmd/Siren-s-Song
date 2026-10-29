extends SceneTree
const Store=preload("res://src/persistence/settings_store.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Aids=preload("res://src/presentation/accessibility/tactical_aids.gd")
const Sim=preload("res://src/simulation/simulation.gd")
class Host extends RefCounted:
 var sim=Sim.new()
 var screen="mission"
 var debug_console=null
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 8:await process_frame
func tap(point):
 for down in [true,false]:
  var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
  var m=InputEventMouseButton.new();m.device=InputEvent.DEVICE_ID_EMULATION;m.position=point;m.button_index=MOUSE_BUTTON_LEFT;m.pressed=down;root.push_input(m,true);await process_frame
 await settle()
func restored_aids():
 var host=Host.new();host.sim.start(0);var sim=host.sim;var aid=Aids.new();aid.bind(host)
 sim.elapsed=10.;sim.mission.structures=[];sim.mission.depth_geometry={}
 sim.sirens[0].target=1
 sim.contacts={0:{"pos":sim.units[1].pos+Vector2(60,0),"time":10.,"mode":"LOCKING","lock":.1,"target":1,"band":sim.units[1].band}}
 Settings.apply(Store.sanitize({"auto_pause_notice":true,"auto_pause_lock":true}))
 sim.paused=false;sim.siren_notice.emit(0,Vector2.ZERO);aid.observe()
 var history=preload("res://src/persistence/profiles/profile_codec.gd").decode(var_to_bytes(aid.saved_history()));var snapshot=sim.snapshot()
 check(history==aid.saved_history(),"archive binary codec preserves aid IDs and warning times")
 var restored=Host.new();var next=Aids.new();next.bind(restored)
 check(restored.sim.restore(snapshot),"active snapshot with warning restores")
 next.restore_history(history);restored.sim.paused=false
 restored.sim.siren_notice.emit(0,Vector2.ZERO);next.observe()
 check(not restored.sim.paused,"restored ongoing notice and received lock do not replay")
 restored.sim.siren_notice.emit(1,Vector2.ZERO);next.observe()
 check(restored.sim.paused,"distinct notice after restore still pauses")
 restored.sim.paused=false;restored.sim.contacts[0].target=0
 restored.sim.contacts[0].pos=restored.sim.units[0].pos+Vector2(60,0);restored.sim.contacts[0].band=restored.sim.units[0].band
 next.observe();check(restored.sim.paused,"distinct craft lock after restore still pauses")
 restored.sim.paused=false;restored.sim.contacts.clear();next.observe()
 restored.sim.elapsed+=Aids.LOCK_CLEAR_SECONDS+.01
 restored.sim.contacts=snapshot.contacts.duplicate(true);restored.sim.contacts[0].time=restored.sim.elapsed
 next.observe();check(restored.sim.paused,"restored warning rearms after sustained clear")
 # Presentation history also remembers an acoustic notice without a live target.
 sim.contacts.clear();sim.sirens[0].target=-1
 var hearing_snapshot=sim.snapshot();history=aid.saved_history()
 check(restored.sim.restore(hearing_snapshot),"acoustic-notice snapshot restores")
 next.restore_history(history);restored.sim.paused=false;restored.sim.siren_notice.emit(0,Vector2.ZERO);next.observe()
 check(not restored.sim.paused,"persisted acoustic notice does not replay after restore")
 for invalid in [null,[],{"noticed":"bad","locks":"bad"},{"noticed":[-1,"0"],"locks":[[0,1,INF],[0,1,NAN],[0,1,11.],[0,1,-1.]]}]:
  check(restored.sim.restore(snapshot),"legacy or malformed optional history keeps active save valid")
  next.restore_history(invalid);restored.sim.paused=false;restored.sim.siren_notice.emit(0,Vector2.ZERO);next.observe()
  check(not restored.sim.paused,"legacy or malformed history primes ongoing visual warning")
 # Saving during a brief clear gap preserves the same episode across restore.
 sim.contacts.clear();sim.elapsed+=.5;history=aid.saved_history();snapshot=sim.snapshot()
 check(restored.sim.restore(snapshot),"brief-clear snapshot restores")
 next.restore_history(history);restored.sim.paused=false;restored.sim.contacts={0:{"pos":restored.sim.units[1].pos+Vector2(60,0),"time":restored.sim.elapsed,"mode":"LOCKING","lock":.1,"target":1,"band":restored.sim.units[1].band}}
 next.observe();check(not restored.sim.paused,"brief-clear restore retains coalesced lock episode")
 Settings.apply(Store.sanitize({"auto_pause_notice":true}))
 restored.sim.paused=false;restored.sim.contacts[0].target=0;next.observe()
 check(not restored.sim.paused,"restored lock stays independent of notice toggle")
 restored.sim.siren_notice.emit(3,Vector2.ZERO);next.observe()
 check(restored.sim.paused,"notice-only option still pauses for a fresh notice")
 restored.sim.paused=false
 Settings.apply(Store.sanitize({"auto_pause_lock":true}));restored.sim.siren_notice.emit(2,Vector2.ZERO);next.observe()
 check(not restored.sim.paused,"restored notice stays independent of lock toggle")
 restored.sim.contacts[0].target=2;restored.sim.contacts[0].pos=restored.sim.units[2].pos+Vector2(60,0);restored.sim.contacts[0].band=restored.sim.units[2].band
 next.observe();check(restored.sim.paused,"lock-only option still pauses for a fresh lock")
 sim.start(0);aid.observe();snapshot=sim.snapshot();history=aid.saved_history()
 check(restored.sim.restore(snapshot),"snapshot before first warning restores")
 next.restore_history(history);restored.sim.paused=false
 Settings.apply(Store.sanitize({"auto_pause_notice":true}));restored.sim.siren_notice.emit(0,Vector2.ZERO);next.observe()
 check(restored.sim.paused,"first new notice after a quiet restore still pauses")
func run():
 var previous=Settings.current.duplicate(true)
 for key in ["auto_pause_notice","auto_pause_lock","mirrored_hud"]:
  check(not Store.sanitize({})[key],"legacy default off: "+key)
  for bad in [1,"true",null,[],{}]:check(not Store.sanitize({key:bad})[key],"invalid boolean rejected: "+key)
 var options=Store.sanitize({"auto_pause_notice":true,"auto_pause_lock":true,"mirrored_hud":true})
 var store=Store.new();store.path="user://tactical-aids-settings-test.json"
 check(store.save_settings(options) and store.load_settings()==options,"all three choices persist separately from campaign")
 DirAccess.remove_absolute(store.path)
 var host=Host.new();host.sim.start(0);var sim=host.sim;var aid=Aids.new();aid.bind(host)
 Settings.apply(Store.DEFAULTS);sim.paused=false;sim.siren_notice.emit(0,Vector2.ZERO);aid.observe()
 check(not sim.paused,"default notice leaves time running")
 Settings.apply(options);sim.siren_notice.emit(0,Vector2.ZERO);aid.observe()
 check(not sim.paused,"enabling an aid does not replay an old notice")
 sim.siren_notice.emit(1,Vector2.ZERO);aid.observe();check(sim.paused,"a new Siren notice pauses")
 sim.paused=false;sim.siren_notice.emit(1,Vector2.ZERO);aid.observe();check(not sim.paused,"resume under same first notice stays running")
 sim.start(1);sim.paused=false;sim.selected=0
 sim.siren_notice.emit(1,Vector2.ZERO);aid.observe();check(sim.paused,"new operation rearms first notice")
 # A received drone lock must pause even while Quietus is selected.
 sim.paused=false;sim.elapsed=10.;sim.mission.structures=[];sim.mission.depth_geometry={}
 sim.contacts={2:{"pos":sim.units[1].pos+Vector2(60,0),"time":10.,"mode":"LOCKING","lock":.1,"target":1,"band":sim.units[1].band}}
 aid.observe();check(sim.paused,"fresh unselected drone lock pauses")
 var lock=sim.contacts[2].lock;var elapsed=sim.elapsed;aid.advance(.25)
 check(sim.elapsed==elapsed and sim.contacts[2].lock==lock,"paused aid freezes simulation and warning clock")
 sim.paused=false;aid.observe();check(not sim.paused,"resume with same lock does not trap player")
 sim.contacts.clear();aid.observe();sim.contacts={2:{"pos":sim.units[1].pos+Vector2(60,0),"time":10.,"mode":"LOCKING","lock":.1,"target":1,"band":sim.units[1].band}}
 aid.observe();check(not sim.paused,"brief warning gap coalesces instead of demanding another resume")
 sim.elapsed+=1.;sim.contacts[2].time=sim.elapsed;aid.observe()
 check(not sim.paused,"continued warning refreshes the same episode")
 sim.contacts.clear();aid.observe();sim.elapsed+=Aids.LOCK_CLEAR_SECONDS+.01
 sim.contacts={2:{"pos":sim.units[1].pos+Vector2(60,0),"time":sim.elapsed,"mode":"LOCKING","lock":.1,"target":1,"band":sim.units[1].band}}
 aid.observe();check(sim.paused,"sustained clear interval rearms the warning")
 sim.paused=false;sim.contacts[2].target=0;sim.contacts[2].pos=sim.units[0].pos+Vector2(60,0);sim.contacts[2].band=sim.units[0].band;aid.observe()
 check(sim.paused,"different craft target pauses immediately despite same Siren")
 sim.paused=false;sim.contacts[4]=sim.contacts[2].duplicate();aid.observe()
 check(sim.paused,"different Siren pauses immediately despite same craft")
 sim.paused=false;sim.contacts.clear();aid.observe()
 sim.contacts={3:{"pos":Vector2.ZERO,"time":9.,"mode":"LOCKING","lock":1.,"target":0}}
 aid.observe();check(not sim.paused,"stale warning never pauses")
 sim.contacts[3].time=sim.elapsed;sim.contacts[3].recipient_target=true;aid.observe();check(not sim.paused,"recipient warning never aliases craft")
 host.screen="menu";sim.siren_notice.emit(4,Vector2.ZERO);aid.observe();check(not sim.paused,"menu never auto pauses")
 # Real simulation acquisition on an unselected, stationary SILENT drone.
 host.screen="mission";sim.start(0);sim.mission.structures=[];sim.mission.depth_geometry={}
 sim.band_shapes={0:[],1:[],2:[]};sim.band_bounds={}
 sim.units[0].pos=Vector2(100,100);sim.units[1].pos=Vector2(400,300);sim.units[1].silent=true
 sim.units[2].alive=false;sim.selected=0
 sim.sirens=[sim.sirens[0]];sim.sirens[0].pos=Vector2(460,300);sim.sirens[0].route=[];sim.sirens[0].band=sim.units[1].band
 sim.paused=false;aid.advance(.25)
 check(sim.paused and sim.elapsed<=sim.STEP+.00001,"real any-craft notice stops after first fixed step of long frame")
 check(sim.sirens[0].target==1 and sim.sirens[0].lock<.02,"real drone lock keeps its ordinary initial accumulation")
 restored_aids()
 # Geometry and injected touch on both Fold shapes at normal and large text.
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="radial-hud"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g.sim.paused=true
  for scale in [1.,1.5]:
   Settings.apply(Store.sanitize({"text_scale":scale}),g);g._layout();await settle()
   var h=g.mission_hud;h.open("tools");await settle()
   var normal={}
   for b in h.ring_buttons:normal[b.get_meta("action")]=b.position+b.size/2-h.center
   var pause_x=g.pause_button.position.x;var fleet_x=g.advanced_button.position.x
   Settings.apply(Store.sanitize({"text_scale":scale,"mirrored_hud":true}),g);g._layout();await settle()
   check(is_equal_approx(g.pause_button.position.x,fleet_x) and is_equal_approx(g.advanced_button.position.x,pause_x),"top clusters swap "+str(dimensions)+" scale "+str(scale))
   for b in h.ring_buttons:
    var delta=b.position+b.size/2-h.center;var old=normal[b.get_meta("action")]
    check(delta.distance_to(Vector2(-old.x,old.y))<1.,"radial action mirrors "+str(b.get_meta("action")))
    var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
    check(b.size.x*dp>=48. and b.size.y*dp>=48.,"physical 48 dp target preserved")
    check(Rect2(Vector2.ZERO,h.size).encloses(b.get_rect()),"mirrored target inside safe HUD")
   for i in h.ring_buttons.size():
    var point=h.center+preload("res://src/presentation/status_text/status_view.gd").radial_point(h,-PI/2+TAU*i/h.ring_buttons.size(),h.ring_radius)
    check(h.sector_at(h.global_position+point)==h.ring_buttons[i],"visible mirrored wedge matches hit action")
   h.dismiss();await settle();await tap(g.pause_button.get_global_rect().get_center())
   check(not g.sim.paused,"mirrored pause touch resumes")
   await tap(g.pause_button.get_global_rect().get_center());check(g.sim.paused,"mirrored pause touch pauses")
   await tap(g.advanced_button.get_global_rect().get_center());check(g.advanced_orders and h.page=="fleet","mirrored fleet touch opens fleet")
   h.dismiss();await settle()
  g.queue_free();await settle()
 Settings.apply(previous)
 print("TACTICAL AIDS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
