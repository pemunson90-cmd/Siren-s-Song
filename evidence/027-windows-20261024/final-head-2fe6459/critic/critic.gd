extends "res://tests/challenges_ui_tests.gd"
var game
var base="C:/Users/Archi/Documents/Codex/2026-10-23/continue-as-codex-on-the-siren/work/027-blind-review/"
var serial=0
func button(node,id):
 for b in node.find_children("*","Button",true,false):
  if b.get_meta("ui_action",b.get_meta("action",""))==id and b.is_visible_in_tree():return b
 return null
func run():
 root.size=Vector2i(2520,1080);root.content_scale_size=Vector2i(2520,1080)
 game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 game.store.path="user://review.save";root.add_child(game);await settle();game.set_process(false)
 game.completed=[0,1,2,3,4,5];game.unlocked=5;game.active_started=false;game.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed"},"completed":[6,7,9,11,12,14,15,16,17,18,19,22,23,24,25],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"};game._show_campaign();await settle()
 dump()
 while true:
  await process_frame
  if not FileAccess.file_exists(base+"command.json"):continue
  var cmd=JSON.parse_string(FileAccess.get_file_as_string(base+"command.json"));DirAccess.remove_absolute(base+"command.json")
  print("REVIEW_COMMAND ",JSON.stringify(cmd))
  match cmd.get("cmd",""):
   "press":await press(game,cmd.id)
   "tap":await tap(Vector2(cmd.x,cmd.y))
   "site":
    var sites=game.ocean.observable_sites()
    if cmd.index<sites.size():await tap(game.ocean.screen_position(sites[cmd.index].pos)+game.ocean.global_position)
   "craft":await tap(game.ocean.screen_position(game.sim.units[game.sim.selected].pos)+game.ocean.global_position)
   "step":
    for n in int(float(cmd.seconds)*20):
     game._process(.05)
     if n%20==0:await process_frame
    await settle()
   "shape":root.size=Vector2i(cmd.x,cmd.y);await settle()
   "back":await android_back()
   "shot":
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(base+cmd.name+".png")
   "reload":game._load_archive();game._show_campaign();await settle()
   "pinch":
    var center=Vector2(root.size)*.5
    for i in 2:
     var e=InputEventScreenTouch.new();e.index=i;e.position=center+Vector2((-1 if i==0 else 1)*500,0);e.pressed=true;root.push_input(e,true)
    await process_frame
    for n in 20:
     for i in 2:
      var e=InputEventScreenDrag.new();e.index=i;e.position=center+Vector2((-1 if i==0 else 1)*(500-float(n+1)*18),0);e.relative=Vector2((-1 if i==0 else 1)*-18,0);root.push_input(e,true)
     await process_frame
    for i in 2:
     var e=InputEventScreenTouch.new();e.index=i;e.position=center+Vector2((-1 if i==0 else 1)*140,0);e.pressed=false;root.push_input(e,true)
    await settle()
   "quit":quit();return
  dump()
func dump():
 serial+=1
 var result={"serial":serial,"screen":game.screen,"mission":game.mission_index,"paused":game.sim.paused,"outcome":game.sim.outcome,"message":game.sim.message,"buttons":[],"labels":[],"sites":[],"craft":[]}
 for b in game.find_children("*","Button",true,false):
  if b.is_visible_in_tree():result.buttons.append({"id":b.get_meta("ui_action",b.get_meta("action","")),"text":b.text,"disabled":b.disabled,"rect":str(b.get_global_rect())})
 for l in game.find_children("*","Label",true,false):
  if l.is_visible_in_tree() and not l.text.is_empty():result.labels.append(l.text)
 for s in game.ocean.observable_sites():result.sites.append({"name":s.get("name",""),"pos":str(s.pos),"screen":str(game.ocean.screen_position(s.pos)+game.ocean.global_position)})
 for u in game.sim.units:result.craft.append({"pos":str(u.pos),"alive":u.alive})
 var content=JSON.stringify(result,"  ")
 FileAccess.open(base+"state.json",FileAccess.WRITE).store_string(content)
 FileAccess.open(base+"state-%03d.json"%serial,FileAccess.WRITE).store_string(content)
 print("REVIEW_STATE ",serial," ",game.screen," ",game.sim.message)




