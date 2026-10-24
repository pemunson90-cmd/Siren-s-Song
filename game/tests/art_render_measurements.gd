extends SceneTree
# Staged public-contact fixture, not acquisition/blind play or physical Fold7 proof.
const Sim=preload("res://src/simulation/simulation.gd")
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
class View extends "res://src/presentation/ocean_view.gd":
 var cpu_usec=0
 var fixture_scene=0
 var full_context={"landmarks":[{"kind":"factory","rect":Rect2(1000,180,480,360)}],"surface_segments":[PackedVector2Array([Vector2(1000,180),Vector2(1480,180)]),PackedVector2Array([Vector2(1480,180),Vector2(1480,540)]),PackedVector2Array([Vector2(1480,540),Vector2(1000,540)]),PackedVector2Array([Vector2(1000,540),Vector2(1000,180)])]}
 var partial_context={"landmarks":[{"kind":"factory","rect":Rect2(1000,640,480,240)}],"surface_segments":[PackedVector2Array([Vector2(1000,640),Vector2(1480,640)])]}
 func _draw():
  var started=Time.get_ticks_usec()
  super._draw()
  draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
  if fixture_scene==1:
   Confluence.draw_landmarks(self,full_context,world_scale)
   Confluence.draw_landmarks(self,partial_context,world_scale)
  draw_set_transform(Vector2.ZERO)
  draw_string(ThemeDB.fallback_font,Vector2(20,size.y-24),"STAGED PUBLIC CONTACTS / FIXED CAMERA / 420 DPI TARGET",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("92b5b5"))
  cpu_usec=Time.get_ticks_usec()-started
var checks=0
var failures=0
var folder=""
var sample_frames=12
var blocks=1
var baseline=false
var table
func _initialize():call_deferred("run")
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func digest(s):return var_to_bytes(s.snapshot()).hex_encode().sha256_text()
func draw_frame(view):
 view.queue_redraw()
 await process_frame
 await RenderingServer.frame_post_draw
func lamp_checks(view,s):
 var saved=s.snapshot()
 table.enabled=true
 var feed=view.optical_feed
 feed._vm_age=1.;feed.queue_redraw();await draw_frame(view);await draw_frame(view)
 check(feed.art_lamp_current(s),"actual cached own camera lamp is active")
 var local_body=Rect2(view.screen_position(s.units[0].pos)-Vector2(74,32)*view.world_scale,Vector2(148,64)*view.world_scale)
 var local_cone=Rect2(view.screen_position(feed.art_lamp_pos),Vector2.ZERO)
 for side in 2:
  var tip=feed.art_lamp_pos+Vector2.from_angle(feed.art_lamp_aim+feed.art_lamp_fov*(float(side)-.5))*minf(feed.art_lamp_range,table.LAMP_FADE_LENGTH)
  local_cone=local_cone.expand(view.screen_position(tip))
 check(Rect2(Vector2.ZERO,view.size).encloses(local_body) and Rect2(Vector2.ZERO,view.size).encloses(local_cone) and not local_body.intersects(feed.get_rect()) and not local_cone.intersects(feed.get_rect()),"selected Quietus and complete local cone are on screen outside viewfinder")
 var with_lamp=root.get_texture().get_image().get_data()
 var own_strength=feed.art_lamp_strength;feed.art_lamp_strength=0.
 await draw_frame(view)
 check(root.get_texture().get_image().get_data()!=with_lamp,"actual steady lamp changes visible native pixels")
 feed.art_lamp_strength=own_strength;await draw_frame(view)
 var strength=feed.art_lamp_strength
 s.mission.launch_equipment=Equipment.canonical({"quietus":"photo_flash","drone_a":"","drone_b":""})
 check(Photo.set_frame(s,0,{"flash":true}),"real framing accepts fitted flash preview")
 feed._vm_age=1.;feed.queue_redraw();await draw_frame(view);await draw_frame(view)
 check(feed._frame.get("flash",false) and feed.art_lamp_strength==strength and view.camera_flash==0.,"armed idle preview never produces chart flash or stronger steady lamp")
 var accepted=s.command("camera")
 feed._vm_age=1.;feed.queue_redraw();await draw_frame(view);await draw_frame(view)
 check(accepted and feed.art_lamp_strength==strength and view.camera_flash==0.,"accepted exposure retains existing shutter illustration without inventing chart flash producer")
 s.captures[0]={}
 Photo.state(s).flash[0]=0
 feed._vm_age=1.;feed.queue_redraw();await draw_frame(view);await draw_frame(view)
 check(Photo.flash_left(s,0)==0 and not feed._frame.get("flash",false) and feed.art_lamp_strength==strength and view.camera_flash==0.,"depleted armed preview cannot amplify steady lamp or produce chart flash")
 for mode in ["wide","tight","tele"]:
  if mode=="tele":s.mission.launch_equipment=Equipment.canonical({"quietus":"quietus_tele_lens","drone_a":"","drone_b":""})
  Photo.set_frame(s,0,{"mode":"tight" if mode!="wide" else "wide","flash":false})
  feed._vm_age=1.;feed.queue_redraw();await draw_frame(view);await draw_frame(view)
  check(feed.art_lamp_aim==float(feed._frame.aim) and feed.art_lamp_fov==float(feed._frame.fov) and feed.art_lamp_range==float(feed._frame.range) and feed.art_lamp_strength==float(Photo.optics(s,0).lamp),"cached "+mode+" cone uses actual own optics and frame")
 check(s.restore(saved),"lamp test restores original full simulation")
 feed._vm_age=1.;view._process(0.);feed.queue_redraw();await draw_frame(view);await draw_frame(view)
func run():
 if DisplayServer.get_name()=="headless":printerr("Native renderer required");quit(1);return
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
  if arg=="--baseline":baseline=true
  if arg.begins_with("--frames="):sample_frames=int(arg.trim_prefix("--frames="))
  if arg.begins_with("--blocks="):blocks=int(arg.trim_prefix("--blocks="))
 if ResourceLoader.exists("res://src/presentation/art/art_table.gd"):table=load("res://src/presentation/art/art_table.gd")
 if folder.is_empty():folder=OS.get_user_data_dir().path_join("art-render")
 DirAccess.make_dir_recursive_absolute(folder)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var render_timing=RenderingServer.has_method("viewport_set_measure_render_time") and RenderingServer.has_method("viewport_get_measured_render_time_gpu") and RenderingServer.has_method("viewport_get_measured_render_time_cpu")
 if render_timing:RenderingServer.call("viewport_set_measure_render_time",root.get_viewport_rid(),true)
 print("ART HOST ",JSON.stringify({"adapter":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version(),"display":DisplayServer.get_name(),"target_dpi":420,"vsync":DisplayServer.window_get_vsync_mode(),"baseline":baseline}))
 var records=[]
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await process_frame;await process_frame
  for scene in 3:
   var s=Sim.new();s.start(0,"endurance");s.paused=true;s.elapsed=10.
   s.units[0].pos=Vector2(360,450);s.units[0].angle=0.
   s.units[1].pos=Vector2(370,550);s.units[1].angle=0.
   s.units[2].pos=Vector2(370,650);s.units[2].angle=0.
   s.contacts={}
   for n in 5:
    s.contacts[n]={"pos":[Vector2(700,180),Vector2(860,130),Vector2(720,380),Vector2(850,520),Vector2(700,650)][n],"angle":0.,"type":["patroller","sentinel","sweeper","hunter","hunter"][n],"time":10. if n<4 else 6.,"mode":"PATROL","lock":0.,"target":-1,"band":1}
   var safe=Metrics.content_rect(root.get_visible_rect().size,Vector2(dimensions),Rect2(136,0,2384,1080) if dimensions.x==2520 else Rect2(Vector2.ZERO,Vector2(dimensions)))
   var view=View.new();view.sim=s;view.fixture_scene=scene;view.position=safe.position;view.size=safe.size;root.add_child(view)
   var touch=Metrics.touch_height(root.get_visible_rect().size,Vector2(dimensions),420.)
   var text_scale=1.5 if scene==2 else 1.
   view.feedback_font_size=maxi(14,roundi(touch*.26*text_scale));view.instrument_top=touch+24;view.instrument_height=touch
   view.optical_feed.touch_height=touch;view.optical_feed.receiver_font_size=maxi(17,roundi(touch*.29*text_scale))
   view.set_process(false);view.phase=0.;view.optical_feed.set_process(false)
   # Camera scene uses the actual cached photograph and its normal controls.
   if scene==2:
    s.units[0].pos=s.mission.objectives[0].pos-Vector2(130,0)
    view._process(0.);view.optical_feed.time=0.;view.optical_feed._vm_age=1.
    if table!=null:await lamp_checks(view,s)
   var state=digest(s)
   check(Sim.valid_snapshot(s.snapshot()),"staged complete snapshot is structurally valid")
   var command_reference=Sim.new();check(command_reference.restore(s.snapshot()),"command reference restores complete fixture")
   var accepted_reference=command_reference.command("select",{"unit":1})
   var command_hash=digest(command_reference);command_reference=null
   for block in blocks:
    var order=[false,true,true,false] if not baseline else [false]
    for enabled in order:
     if table!=null:table.enabled=enabled
     for n in 90:await draw_frame(view)
     var times=PackedFloat64Array();times.resize(sample_frames)
     var cadence=PackedFloat64Array();cadence.resize(sample_frames)
     var render_cpu=PackedFloat64Array();render_cpu.resize(sample_frames)
     var render_gpu=PackedFloat64Array();render_gpu.resize(sample_frames)
     var objects_before=Performance.get_monitor(Performance.OBJECT_COUNT)
     var memory_before=Performance.get_monitor(Performance.MEMORY_STATIC)
     var last=Time.get_ticks_usec()
     for n in sample_frames:
      await draw_frame(view)
      if render_timing:
       render_cpu[n]=float(RenderingServer.call("viewport_get_measured_render_time_cpu",root.get_viewport_rid()))*1000.
       render_gpu[n]=float(RenderingServer.call("viewport_get_measured_render_time_gpu",root.get_viewport_rid()))*1000.
      var now=Time.get_ticks_usec();times[n]=view.cpu_usec;cadence[n]=now-last;last=now
     var name="%dx%d-scene%d-%s"%[dimensions.x,dimensions.y,scene,"new" if enabled else "old"]
     if block==0:
      var image=root.get_texture().get_image()
      image.save_png(folder.path_join(name+".png"))
      var hidden=s.sirens.duplicate(true)
      for enemy in s.sirens:enemy.pos+=Vector2(170,120);enemy.mode="ENGAGE"
      await draw_frame(view)
      check(root.get_texture().get_image().get_data()==image.get_data(),"hidden roster cannot alter public art pixels "+name)
      s.sirens=hidden
      await draw_frame(view)
     var row={"name":name,"block":block,"enabled":enabled,"snapshot":state,"snapshot_after":digest(s),"cpu_usec":times,"frame_usec":cadence,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"objects_delta":Performance.get_monitor(Performance.OBJECT_COUNT)-objects_before,"static_bytes_delta":Performance.get_monitor(Performance.MEMORY_STATIC)-memory_before,"gpu_timing":"unavailable","window_size":DisplayServer.window_get_size(),"effective_viewport":root.get_visible_rect().size,"view_size":view.size,"camera":view.chart_camera.snapshot(),"world_scale":view.world_scale,"world_offset":view.world_offset,"phase":view.phase,"lamp_on":view.optical_feed.art_lamp_current(s) if not baseline else false}
     records.append(row)
     row["target_dpi"]=420;row["host_dpi"]=DisplayServer.screen_get_dpi();row["safe_content"]=safe;row["text_scale"]=text_scale;row["touch_height"]=touch
     row["lamp_pose"]={"pos":view.optical_feed.art_lamp_pos,"aim":view.optical_feed.art_lamp_aim,"fov":view.optical_feed.art_lamp_fov,"range":view.optical_feed.art_lamp_range,"strength":view.optical_feed.art_lamp_strength}
     row["viewport_render_cpu_usec"]=render_cpu;row["viewport_render_gpu_usec"]=render_gpu
     row["gpu_timing"]="reported viewport GPU samples" if render_timing and render_gpu.count(0.)<render_gpu.size() else "unavailable (zero or unsupported viewport GPU timer)"
     check(state==digest(s),"draw preserves complete snapshot "+name)
     print("ART BLOCK ",name," ",block," CPU ",times[0])
   var accepted=s.command("select",{"unit":1})
   check(accepted==accepted_reference and digest(s)==command_hash,"draw preserves subsequent ordinary command ")
   view.queue_free();await process_frame;s=null
 var file=FileAccess.open(folder.path_join("raw.json"),FileAccess.WRITE);file.store_string(JSON.stringify(records));file.close()
 print("ART RENDER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
