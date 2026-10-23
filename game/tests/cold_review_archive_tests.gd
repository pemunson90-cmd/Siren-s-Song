extends SceneTree
# Each phone profile boots the actual frontend in a separate empty OS data dir.
# Scroll uses native ScreenTouch and Android-style mouse emulation, not scroll assignment.
var checks=0
var failures=0
var game
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 8:await process_frame
func mouse(point,down):
 var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION;e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true)
func touch(point,down):
 var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);mouse(point,down);await process_frame
func drag(a,b):
 var motion=InputEventMouseMotion.new();motion.device=InputEvent.DEVICE_ID_EMULATION;motion.position=a;root.push_input(motion,true)
 await touch(a,true)
 var previous=a
 for n in 16:
  var point=a.lerp(b,(n+1)/16.)
  var e=InputEventScreenDrag.new();e.index=0;e.position=point;e.relative=point-previous;root.push_input(e,true)
  motion=InputEventMouseMotion.new();motion.device=InputEvent.DEVICE_ID_EMULATION;motion.position=point;motion.relative=point-previous;motion.button_mask=MOUSE_BUTTON_MASK_LEFT;root.push_input(motion,true)
  previous=point;await process_frame
 await touch(b,false);await create_timer(.5).timeout
func run():
 var args=OS.get_cmdline_user_args()
 if args.is_empty():
  for profile in ["cover","inner"]:
   var fresh=OS.get_cache_dir().path_join("sirens-cold-review-%d-%s-%d"%[OS.get_process_id(),profile,Time.get_ticks_usec()])
   DirAccess.make_dir_recursive_absolute(fresh)
   var output=[]
   var result=OS.execute("env",["XDG_DATA_HOME="+fresh,OS.get_executable_path(),"--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/cold_review_archive_tests.gd","--",profile],output,true)
   for line in output:print(line)
   var joined="\n".join(output)
   var summary=RegEx.new();summary.compile("ARCHIVE PROFILE CHECKS ([1-9][0-9]*) FAILURES 0")
   check(result==0 and summary.search(joined)!=null and not "SCRIPT ERROR:" in joined and not "ERROR:" in joined and not "instances leaked" in joined and not "resources still in use" in joined,"fresh "+profile+" launch and touch archive checks")
  print("COLD REVIEW ARCHIVE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0);return
 Input.set_emulate_touch_from_mouse(true)
 var cover=args[0]=="cover"
 root.size=Vector2i(2520,1080) if cover else Vector2i(2184,1968);await settle()
 check(not FileAccess.file_exists("user://quietus.save") and not FileAccess.file_exists("user://quietus.save.bak"),"OS data directory contains no campaign archive")
 game=load("res://scenes/main.tscn").instantiate();game.set_script(preload("res://tests/fit_label_main.gd"));game.fixture_dpi=420.
 if cover:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false)
 check(game.capture_scenario.is_empty(),"ordinary first launch runs the real archive loader")
 check(game.archive_warning.is_empty() and game.store.warning.is_empty() and not game.archive_status.visible,"clean first launch has no backup-recovery notice")
 # Close the boot overlay through its normal campaign action.
 for front in game.get_children():
  if front.get_script()!=null and front.get_script().resource_path=="res://src/presentation/frontend/frontend.gd":front.queue_free()
 await settle()
 game._start_mission(0);game.set_process(false)
 var s=game.sim;s.sirens=[];var spire=s.mission.objectives[0]
 s.units[0].pos=spire.pos+Vector2.from_angle(2.74)*110;s.units[0].angle=2.74+PI;s.command("camera");s.paused=false
 for n in 300:s.advance(1./60)
 s.paused=true;game._retain_evidence();game._evidence_gallery(0);await settle()
 var intel
 for b in game.panel_box.find_children("*","Button",true,false):
  if b.get_meta("action","")=="intel":intel=b
 check(intel!=null and game.screen=="evidence","real recovered-frame archive exposes Intel and Research")
 if intel!=null:
  var initial=game.scroll.scroll_vertical
  var started_below=not game.scroll.get_global_rect().encloses(intel.get_global_rect())
  for n in 12:
   var body=game.scroll.get_global_rect();var rect=intel.get_global_rect()
   if body.encloses(rect):break
   var origin=Vector2(body.end.x-8,body.end.y-24)
   await drag(origin,origin+Vector2(0,clampf(body.get_center().y-rect.get_center().y,-body.size.y*.65,body.size.y*.65)))
  print("ARCHIVE TOUCH profile=",args[0]," started_below=",started_below," offset=",game.scroll.scroll_vertical)
  check(game.scroll.get_global_rect().encloses(intel.get_global_rect()),"touch scroll fully exposes Intel and Research")
  check(not started_below or game.scroll.scroll_vertical>initial,"below-fold button reached by an actual drag")
  var point=intel.get_global_rect().get_center();await touch(point,true);await touch(point,false);await settle()
  check(game.screen=="intel","touch opens Intel and Research after scrolling")
 # Reproduce the notice only after deliberately making a dirty primary and valid backup.
 game._start_mission(0);game.active_started=false
 var data=game._archive()
 check(game.store.save(data) and game.store.save(data),"fixture writes valid primary and rotated backup")
 var corrupt=FileAccess.open(game.store.path,FileAccess.WRITE);corrupt.store_string("deliberately unreadable test primary");corrupt.close()
 game._load_archive();await settle()
 check(game.archive_warning=="Primary archive was unreadable. Recovered previous backup.","dirty-folder fixture reproduces the reported notice")
 game.queue_free();await settle();await create_timer(.1).timeout
 print("ARCHIVE PROFILE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
