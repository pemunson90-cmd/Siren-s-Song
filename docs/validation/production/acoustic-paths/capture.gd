extends SceneTree
var game
var folder=""
func settle(n=8):
 for i in n:await process_frame
func run():
 var args=OS.get_cmdline_user_args();folder=args[0];var mode=args[1] if args.size()>1 else "challenger";var idle=mode=="idle";var branch=mode.begins_with("branch-");DirAccess.make_dir_recursive_absolute(folder)
 root.size=Vector2i(1280,720);game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="acoustic-path-ordinary-replay";root.add_child(game);await settle()
 game._start_mission(4);game.set_process(false);game.sim.paused=false
 if branch:
  game._start_mission(0);game.set_process(false);game.sim.mission.title="AUTHORED ACOUSTIC ISLAND";game.sim.mission.rocks=[Rect2(450,400,100,200)];game.sim._build_navigation()
  game.sim.units[0].pos=Vector2(300,500);game.sim.units[1].pos=Vector2(900,300)
  var e=game.sim.sirens[0];e.pos=Vector2(700,500);e.home=e.pos;e.goal=e.pos;e.type="hunter";e.route=[];e.vel=Vector2.ZERO
  game.sim._observe();game.sim.command("ping");game.sim.command("route",{"point":Vector2(300,800)});game.sim.paused=false
 var actions=[]
 if not idle and not branch:
  for command in [["silent",{}],["route",{"point":Vector2(800,780)}],["select",{"unit":1}],["route",{"point":Vector2(760,200)}],["select",{"unit":2}],["route",{"point":Vector2(1370,450)}],["select",{"unit":0}]]:
   game.sim.command(command[0],command[1]);actions.append(command)
 FileAccess.open(folder.path_join("commands.json"),FileAccess.WRITE).store_string(JSON.stringify({"source":"authored island + initialpositions and hunter role; ordinary SONAR and silent withdrawal; knowledge only through actual sensors" if branch else "ordinary mission4start; commands through productionAPI; no enemy,knowledge,resource or outcome fixture edits","actions":actions,"fps":15,"duration":12 if branch else 16,"idle":idle,"branch_fixture":branch},"\t"))
 for n in (180 if branch else 240):
  for tick in 4:game.sim.advance(1.0/60)
  if not game.sim.outcome.is_empty() and game.screen=="mission":game._debrief()
  game._refresh();await process_frame;await RenderingServer.frame_post_draw
  var img=root.get_texture().get_image();img.save_png(folder.path_join("%04d.png"%n))
  if n==119:FileAccess.open(folder.path_join("mid-state.json"),FileAccess.WRITE).store_string(JSON.stringify({"time":game.sim.elapsed,"hull":game.sim.hull,"units":game.sim.units,"contacts":game.sim.contacts,"threats":game.sim.sirens,"feedback":game.sim.acoustic_feedback()},"\t"))
  if n==119 and not idle and not branch:
   # Actual same-physics checkpoint, density-only fixture scene replacement.
   var state=game.sim.snapshot();var status=game.sim.message;game.queue_free();await settle()
   for profile in [{"name":"cover","size":Vector2i(2520,1080)},{"name":"inner","size":Vector2i(2184,1968)}]:
    root.size=profile.size;await settle()
    var phone=load("res://scenes/main.tscn").instantiate();phone.set_script(load("res://tests/density_main.gd"));phone.capture_scenario="acoustic-path-density-checkpoint";phone.fixture_safe_area=Rect2(136,0,2384,1080) if profile.name=="cover" else Rect2(0,0,2184,1968);root.add_child(phone);await settle()
    phone.set_process(false);phone._start_mission(4);phone.sim.restore(state);phone.sim.message=status;phone.screen="mission";phone.menu.visible=false;phone.hud.visible=true;phone._layout();phone._refresh();await settle();await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(folder.path_join(profile.name+"-420dpi.png"));FileAccess.open(folder.path_join(profile.name+"-420dpi.json"),FileAccess.WRITE).store_string(JSON.stringify(phone._ui_metrics(),"\t"));phone.queue_free();await settle()
   root.size=Vector2i(1280,720);await settle();game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="acoustic-path-resume-capture";root.add_child(game);await settle();game.set_process(false);game._start_mission(4);game.sim.restore(state);game.sim.message=status;game.sim.paused=false;game.screen="mission";game.menu.visible=false;game.hud.visible=true;game._layout()
 print("CAPTURE_END ",JSON.stringify({"time":game.sim.elapsed,"hull":game.sim.hull,"outcome":game.sim.outcome,"alive":game.sim.units.map(func(u):return u.alive),"feedback":game.sim.acoustic_feedback()}));game.queue_free();await settle();quit()
func _initialize():call_deferred("run")
