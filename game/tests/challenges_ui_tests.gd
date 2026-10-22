extends SceneTree
# Source-known staged result flow through real title and mode-menu touch.
# Full operation completion is exercised separately in challenges_journey_tests.
const Front=preload("res://src/presentation/frontend/frontend.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func tap(point):
 for down in [true,false]:
  var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func escape_key():
 for down in [true,false]:
  var event=InputEventKey.new();event.keycode=KEY_ESCAPE;event.pressed=down;root.push_input(event,true);await process_frame
 await settle()
func android_back(count=1):
 for n in count:root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
 await settle()
func button(node,id):
 for b in node.find_children("*","Button",true,false):
  if b.get_meta("ui_action","")==id and b.is_visible_in_tree():return b
 return null
func press(node,id):
 var b=button(node,id)
 check(b!=null,"visible action "+id)
 if b==null:return false
 var parent=b.get_parent()
 while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
 if parent!=null:parent.ensure_control_visible(b);await settle()
 await tap(b.get_global_rect().get_center());return true
func campaign(data):
 var copy=data.duplicate(true);copy.erase("challenges");return copy
func difference(a,b,path=""):
 var out=[]
 if a is Dictionary and b is Dictionary:
  var keys=a.keys()
  for key in b:
   if key not in keys:keys.append(key)
  for key in keys:
   if not a.has(key) or not b.has(key):out.append(path+"/"+str(key))
   else:out.append_array(difference(a[key],b[key],path+"/"+str(key)))
 elif a!=b:out.append(path)
 return out
func shape_case(shape):
 root.size=shape;await settle()
 var path="user://challenges-ui-%d.save"%shape.x
 var settings_path="user://challenges-ui-%d-settings.json"%shape.x
 for file in [path,path+".challenges",settings_path]:
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(file+suffix)
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="runtime-test";game.store.path=path
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle()
 game.completed=[0];game.unlocked=1;game.upgrade="survey";game._start_mission(1)
 game.sim.oxygen=57.;game.sim.hull=93.;game.sim.tools.emp=1;game.sim.command("select",{"unit":2})
 game._show_campaign();game.capture_scenario="";game._save_archive();await settle()
 var legacy=game.store.load_game();legacy.version=1
 check(game.store.save(legacy),"the fixture retains a readable older profile version")
 var before=game.store.load_game();var dive=game.sim.snapshot()
 var campaign_bytes=FileAccess.get_file_as_bytes(path)
 var backup_bytes=FileAccess.get_file_as_bytes(path+".bak")
 check(not before.is_empty(),"the campaign fixture is a valid ordinary profile")
 var front=Front.new();front.settings_store.path=settings_path;game.add_child(front);front.setup(game);await settle()
 var entry=button(front,"frontend_challenges")
 check(entry!=null and entry.text=="CHALLENGES","the title offers Challenges beside campaign play "+str(shape))
 if entry!=null:
  check(entry.get_global_rect().size.y>=game.ui_touch_height,"the challenge entry retains a full-density touch target")
  if await press(front,"frontend_challenges"):
   check(front.screen=="challenges","real touch opens the challenge list")
   var rows=front.find_children("*","Button",true,false).filter(func(b):return b.get_meta("challenge_id","")!="")
   check(rows.size()==12,"the menu lists all twelve challenge unlocks")
   check(rows.filter(func(b):return not b.disabled).size()==1,"only the recovered operation is unlocked")
   if await press(front,"challenge_shelf_passive"):
    if await press(front,"challenge_start"):
     var session=game.get_node_or_null("ChallengeSession")
     check(session!=null,"starting creates a separate playable session")
     if session!=null:
      session.set_process(false)
      check(not game.can_process() and session.can_process(),"the challenge runs while the campaign session is frozen")
      check(session.sim.mission.id==0 and game.sim.mission.id==1,"the challenge cannot replace the active campaign dive")
      check(session.sim.oxygen==120. and session.sim.tools.emp==2 and session.sim.selected==0,"the challenge uses its fixed fleet rather than campaign reserves")
      check(not session.sim.command("ping"),"the actual challenge session enforces its rule")
      session.sim.paused=false;session.sim.advance(.1);session.sim.paused=true;session._refresh()
      check(game.sim.snapshot()==dive and game.store.load_game()==before,"playing the challenge leaves the active dive and disk archive unchanged")
      game.notification(Node.NOTIFICATION_APPLICATION_PAUSED);session.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
      check(FileAccess.get_file_as_bytes(path)==campaign_bytes and FileAccess.get_file_as_bytes(path+".bak")==backup_bytes,"Android suspend leaves the frozen campaign files byte-identical")
      # Staged win exercises the result boundary, not operation finishability.
      session.sim.outcome="won";session._process(0.0);await settle()
      var saved=game.store.load_game()
      check(FileAccess.get_file_as_bytes(path)==campaign_bytes and FileAccess.get_file_as_bytes(path+".bak")==backup_bytes,"completion leaves campaign primary and backup byte-identical")
      var history=load("res://src/campaign/challenges/challenge_archive.gd").new()
      history.path=path+".challenges"
      history=history.load_game().get("challenges",{})
      check(history.has("shelf_passive"),"finishing writes a separate challenge result")
      if campaign(saved)!=campaign(before) or game.sim.snapshot()!=dive:printerr("ISOLATION DIFF archive=",difference(campaign(before),campaign(saved))," dive=",difference(dive,game.sim.snapshot()))
      check(campaign(saved)==campaign(before) and game.sim.snapshot()==dive,"completion preserves all campaign fields and live simulation")
      if history.has("shelf_passive"):
       check(not history.shelf_passive.best.loss and history.shelf_passive.attempts==1,"the successful best is saved once")
       session._debrief();await settle()
       check(game.challenge_records.shelf_passive.attempts==1,"repeated debrief cannot duplicate an attempt")
       if await press(session,"challenge_return"):
        check(game.get_node_or_null("ChallengeSession")==null and game.can_process(),"return restores the original campaign host")
        check(front.visible and front.screen=="challenges","return restores the challenge menu")
        game._save_archive()
        check(game.challenge_records==history,"ordinary campaign saves retain challenge bests")
        before=game.store.load_game()
        campaign_bytes=FileAccess.get_file_as_bytes(path);backup_bytes=FileAccess.get_file_as_bytes(path+".bak")
        var loaded=load("res://scenes/main.tscn").instantiate();loaded.capture_scenario="runtime-test";loaded.store.path=path;root.add_child(loaded);await settle()
        loaded.capture_scenario="";loaded._load_archive()
        load("res://src/campaign/challenges/challenge_archive.gd").restore(loaded)
        check(loaded.get("challenge_records")==history,"profile reload restores the separate challenge results")
        loaded.queue_free();await settle()
        for navigation in ["android","keyboard"]:
         if await press(front,"challenge_shelf_passive"):
          if await press(front,"challenge_start"):
           session=game.get_node_or_null("ChallengeSession")
           if session!=null:
            session.set_process(false);await android_back()
            check(session.screen=="challenge_menu","Android Back opens the attempt menu through the normal lifecycle notification")
            if await press(session,"challenge_abandon"):
             if navigation=="android":await android_back(2)
             else:await escape_key()
             check(game.get_node_or_null("ChallengeSession")==null and front.screen=="challenges","Escape or Android Back leaves a finished attempt instead of reopening a recorded loss")
             var after=game.store.load_game()
             check(FileAccess.get_file_as_bytes(path)==campaign_bytes and FileAccess.get_file_as_bytes(path+".bak")==backup_bytes,"abandonment leaves campaign primary and backup byte-identical")
             check(game.challenge_records.shelf_passive.attempts==2+["android","keyboard"].find(navigation) and game.challenge_records.shelf_passive.last.loss,"ending an unfinished attempt records its loss")
             check(game.challenge_records.shelf_passive.best==history.shelf_passive.best and campaign(after)==campaign(before),"an abandoned attempt preserves the best and the campaign")
 game.queue_free();await settle()
 for file in [path,path+".challenges",settings_path]:
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(file+suffix)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("CHALLENGES UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
