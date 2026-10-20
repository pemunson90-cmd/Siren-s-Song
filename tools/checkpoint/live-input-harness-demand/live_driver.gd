extends SceneTree
# External evaluator adapter: only Window input events control production Main.
# No application callbacks, Sim commands, actor edits or clock stepping.
var game
var directory=OS.get_environment("SS_PLAY_SESSION")
var busy=false
var ready=false
var last_id=""
var pointers={}
var event_log:FileAccess
func _initialize():call_deferred("boot")
func boot():
 Engine.max_fps=60
 RenderingServer.render_loop_enabled=false
 event_log=FileAccess.open(directory.path_join("input-events.jsonl"),FileAccess.WRITE)
 var shape=OS.get_environment("SS_PLAY_SHAPE")
 root.size=Vector2i(2520,1080) if shape=="cover" else Vector2i(2184,1968)
 Input.set_emulate_touch_from_mouse(false)
 game=load("res://scenes/main.tscn").instantiate()
 # Existing display-only420dpi/recorded-inset fixture. Main processing stays live.
 var script=load("res://tests/density_main.gd")
 if script==null or not script.can_instantiate():
  write_json("ready.json",{"ready":false,"error":"Main startup failed; inspect godot.log"});quit(2);return
 game.set_script(script)
 if shape=="cover":game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game)
 for frame in 8:await process_frame
 if game.get_script()==null or game.sim==null:
  write_json("ready.json",{"ready":false,"error":"Main did not initialize; inspect godot.log"});quit(2);return
 ready=true
 var shot=await screenshot("initial.png")
 write_json("ready.json",{"ready":true,"screenshot":shot,"display":display_info(),"metrics":metrics()})
func _process(_delta:float)->bool:
 if not ready or busy:return false
 var path=directory.path_join("inbox.json")
 if not FileAccess.file_exists(path):return false
 var request=JSON.parse_string(FileAccess.get_file_as_string(path))
 if not request is Dictionary or str(request.get("id",""))==last_id:return false
 last_id=str(request.id);busy=true;call_deferred("handle",request)
 return false
func write_json(name:String,data):
 var path=directory.path_join(name);var file=FileAccess.open(path+".tmp",FileAccess.WRITE)
 file.store_string(JSON.stringify(data));file.close();DirAccess.rename_absolute(path+".tmp",path)
func display_info()->Dictionary:
 return {"physical_pixels":[root.size.x,root.size.y],"canvas":[root.get_visible_rect().size.x,root.get_visible_rect().size.y],"coordinates":"physical screenshot pixels","density":"recorded420dpi Godot desktop fixture"}
func metrics()->Dictionary:
 if game==null:return {}
 var sim=game.sim;var own=[]
 for id in sim.units.size():
  var u=sim.units[id];var goals=[]
  for goal in sim.route_goals(id):goals.append({"pos":[goal.pos.x,goal.pos.y],"stop":goal.stop,"mode":goal.mode})
  own.append({"unit":id,"name":u.name,"alive":u.alive,"battery":u.battery,"position":[u.pos.x,u.pos.y],"speed":u.vel.length(),"hold":u.hold,"goals":goals})
 return {"screen":game.screen,"mission":sim.mission.id,"elapsed":sim.elapsed,"paused":sim.paused,"outcome":sim.outcome,"hull":sim.hull,"oxygen":sim.oxygen,"tools":sim.tools.duplicate(),"selected":sim.selected,"own_craft":own}
func canvas(point:Array)->Vector2:
 return Vector2(float(point[0]),float(point[1]))*root.get_visible_rect().size/Vector2(root.size)
func trace(kind:String,id:int,point:Vector2,physical:Array):
 event_log.store_line(JSON.stringify({"wall_usec":Time.get_ticks_usec(),"frame":Engine.get_process_frames(),"kind":kind,"pointer":id,"physical":physical,"canvas":[point.x,point.y],"metrics":metrics()}));event_log.flush()
func touch(id:int,physical:Array,down:bool):
 var point=canvas(physical)
 var event=InputEventScreenTouch.new();event.index=id;event.position=point;event.pressed=down
 root.push_input(event,true)
 if id==0:
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.global_position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.button_mask=MOUSE_BUTTON_MASK_LEFT if down else 0;mouse.pressed=down;root.push_input(mouse,true)
 if down:pointers[id]=point
 else:pointers.erase(id)
 trace("touch_down" if down else "touch_up",id,point,physical)
func drag_point(id:int,physical:Array):
 var point=canvas(physical);var relative=point-pointers.get(id,point)
 var event=InputEventScreenDrag.new();event.index=id;event.position=point;event.relative=relative;root.push_input(event,true)
 if id==0:
  var mouse=InputEventMouseMotion.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.global_position=point;mouse.relative=relative;mouse.button_mask=MOUSE_BUTTON_MASK_LEFT;root.push_input(mouse,true)
 pointers[id]=point;trace("touch_drag",id,point,physical)
func interpolate(a:Array,b:Array,factor:float)->Array:return [lerpf(a[0],b[0],factor),lerpf(a[1],b[1],factor)]
func screenshot(name:String)->String:
 RenderingServer.force_draw(false)
 var path=directory.path_join(name.get_file());var image=root.get_texture().get_image();image.save_png(path);return path
func handle(request:Dictionary):
 root.grab_focus()
 var result={"id":request.id,"ok":true};var kind=str(request.get("action",""));var args=request.get("args",{})
 match kind:
  "tap":
   touch(0,args.point,true);await create_timer(.12).timeout;await process_frame;touch(0,args.point,false)
  "touch":touch(int(args.get("pointer",0)),args.point,bool(args.pressed))
  "move":drag_point(int(args.get("pointer",0)),args.point)
  "drag","pinch":
   Input.set_emulate_touch_from_mouse(kind=="drag")
   var starts=args.from;var ends=args.to
   if kind=="drag":starts=[starts];ends=[ends]
   for i in starts.size():touch(i,starts[i],true)
   var steps=maxi(2,int(args.get("steps",20)));var duration=clampf(float(args.get("seconds",.5)),.03,20.)
   for step in range(1,steps+1):
    await create_timer(duration/steps).timeout
    for i in starts.size():drag_point(i,interpolate(starts[i],ends[i],float(step)/steps))
   for i in starts.size():touch(i,ends[i],false)
   Input.set_emulate_touch_from_mouse(false)
  "key":
   var code=OS.find_keycode_from_string(str(args.key))
   for down in [true,false]:
    var event=InputEventKey.new();event.keycode=code;event.pressed=down;root.push_input(event,true);await process_frame
   event_log.store_line(JSON.stringify({"kind":"key","key":args.key,"wall_usec":Time.get_ticks_usec(),"metrics":metrics()}));event_log.flush()
  "wait":await create_timer(clampf(float(args.get("seconds",1)),.01,60.)).timeout
  "screenshot","status":pass
  "resize":
   var cover=args.shape=="cover";root.size=Vector2i(2520,1080) if cover else Vector2i(2184,1968)
   game.fixture_safe_area=Rect2(136,0,2384,1080) if cover else Rect2()
  "quit":pass
  _:result.ok=false;result["error"]="Unknown raw-input action"
 for frame in 4:await process_frame
 result["metrics"]=metrics();result["display"]=display_info()
 result["screenshot"]=await screenshot(str(request.id)+".png")
 write_json("reply.json",result)
 write_json("end-metrics.json",result.metrics)
 busy=false
 if kind=="quit":quit()
