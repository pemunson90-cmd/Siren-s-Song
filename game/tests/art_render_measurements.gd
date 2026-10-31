extends SceneTree
# Staged public-contact fixture, not acquisition/blind play or physical Fold7 proof.
const Sim=preload("res://src/simulation/simulation.gd")
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
class View extends "res://src/presentation/ocean_view.gd":
 var cpu_usec=0
 var fixture_scene=0
 var full_context={"landmarks":[{"kind":"factory","rect":Rect2(100,100,480,360)}],"surface_segments":[PackedVector2Array([Vector2(100,100),Vector2(580,100)]),PackedVector2Array([Vector2(580,100),Vector2(580,460)]),PackedVector2Array([Vector2(580,460),Vector2(100,460)]),PackedVector2Array([Vector2(100,460),Vector2(100,100)])]}
 var partial_context={"landmarks":[{"kind":"factory","rect":Rect2(100,790,480,170)}],"surface_segments":[PackedVector2Array([Vector2(100,790),Vector2(580,790)])]}
 func _draw():
  var started=Time.get_ticks_usec()
  super._draw()
  draw_set_transform(world_offset,0,Vector2.ONE*world_scale)
  if fixture_scene==1:
   Confluence.draw_landmarks(self,full_context,world_scale)
   Confluence.draw_landmarks(self,partial_context,world_scale)
   _installation(Vector2(1400,780),false)
  draw_set_transform(Vector2.ZERO)
  draw_string(ThemeDB.fallback_font,Vector2(20,size.y-24),"STAGED PUBLIC CONTACTS / FIXED CAMERA / 420 DPI TARGET",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("92b5b5"))
  cpu_usec=Time.get_ticks_usec()-started
var checks=0
var failures=0
var folder=""
var sample_frames=12
var blocks=1
var baseline=false
var profile_chart=false
var reference_source=""
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
func stable_camera_checks(view,s,dimensions):
 var original=view.chart_camera.snapshot()
 for mode in ["follow","overview"]:
  if mode=="follow":view.focus_craft()
  else:view.fit_chart()
  # Reuse the unchanged native visibility/pixel/optics assertions in each
  # deliberate framing mode, at the same photographic vantage as scene 2.
  await lamp_checks(view,s)
  root.get_texture().get_image().save_png(folder.path_join("%dx%d-scene2-%s.png"%[dimensions.x,dimensions.y,mode]))
  var transform=[view.world_offset,view.world_scale]
  var intent=view.chart_camera.snapshot()
  for suppressed in [true,false]:
   view.optical_suppressed=suppressed;view._process(0.)
   await draw_frame(view)
   check(view.world_offset==transform[0] and view.world_scale==transform[1] and view.chart_camera.snapshot()==intent,"optical visibility preserves "+mode+" chart transform")
  for compact in [true,false]:
   view.optical_feed.compact=compact;view._process(0.)
   await draw_frame(view)
   check(view.world_offset==transform[0] and view.world_scale==transform[1],"optical fold preserves "+mode+" chart transform")
 var chart=view.stable_chart_rect()
 var anchor=chart.get_center()
 var point=view.map_position(anchor)
 view.zoom_at(1.5,anchor)
 check(view.chart_camera.mode=="free" and view.screen_position(point).distance_to(anchor)<.01,"FREE zoom keeps deliberate chart anchor")
 var free=view.chart_camera.snapshot()
 view.optical_suppressed=true;view._process(0.)
 check(view.chart_camera.snapshot()==free and view.screen_position(point).distance_to(anchor)<.01,"hidden optics preserve FREE anchor")
 view.optical_suppressed=false;view.chart_camera.restore(original);view._process(0.)
 await draw_frame(view)
func run():
 if DisplayServer.get_name()=="headless":printerr("Native renderer required");quit(1);return
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
  if arg=="--baseline":baseline=true
  if arg=="--profile-chart":profile_chart=true
  if arg.begins_with("--reference-source="):reference_source=arg.trim_prefix("--reference-source=")
  if arg.begins_with("--frames="):sample_frames=int(arg.trim_prefix("--frames="))
  if arg.begins_with("--blocks="):blocks=int(arg.trim_prefix("--blocks="))
 if ResourceLoader.exists("res://src/presentation/art/art_table.gd"):table=load("res://src/presentation/art/art_table.gd")
 if folder.is_empty():folder=OS.get_user_data_dir().path_join("art-render")
 DirAccess.make_dir_recursive_absolute(folder)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var render_timing=RenderingServer.has_method("viewport_set_measure_render_time") and RenderingServer.has_method("viewport_get_measured_render_time_gpu") and RenderingServer.has_method("viewport_get_measured_render_time_cpu")
 if render_timing:RenderingServer.call("viewport_set_measure_render_time",root.get_viewport_rid(),true)
 print("ART HOST ",JSON.stringify({"adapter":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version(),"display":DisplayServer.get_name(),"target_dpi":420,"vsync":DisplayServer.window_get_vsync_mode(),"baseline":baseline}))
 if profile_chart:
  await run_chart_profile(render_timing)
  return
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
   if scene in [1,2]:
    s.units[0].pos=s.mission.objectives[0].pos-Vector2(130,0)
    if scene==1:
     # Explicit source-known public chart fixture, not a survey/travel claim.
     # Use the real chart authority and its ordinary earned draw branch.
     s.mission["earned_terrain"]=true;s.mission["world_size"]=Vector2(1600,960);s.mission["region_revision"]=1
     s.mission["launch_seed"]=Rect2(s.units[0].pos-Vector2(80,80),Vector2(160,160))
     s._configure_terrain();s._configure_depth_charts()
    view._process(0.);view.optical_feed.time=0.;view.optical_feed._vm_age=1.
    if table!=null and scene==2:
     await lamp_checks(view,s)
     await stable_camera_checks(view,s,dimensions)
   var state=digest(s)
   check(Sim.valid_snapshot(s.snapshot()),"staged complete snapshot is structurally valid")
   var command_reference=Sim.new();check(command_reference.restore(s.snapshot()),"command reference restores complete fixture")
   var accepted_reference=command_reference.command("select",{"unit":1})
   var command_hash=digest(command_reference);command_reference=null
   var capture_pixels={}
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
     # Sample retained counters before image readback, hashing or result storage.
     var objects_delta=Performance.get_monitor(Performance.OBJECT_COUNT)-objects_before
     var memory_delta=Performance.get_monitor(Performance.MEMORY_STATIC)-memory_before
     var name="%dx%d-scene%d-%s"%[dimensions.x,dimensions.y,scene,"new" if enabled else "old"]
     if block==0:
      var image=root.get_texture().get_image()
      if capture_pixels.has(name):check(capture_pixels[name]==image.get_data(),"old-look revert and repeated new capture are pixel exact "+name)
      else:capture_pixels[name]=image.get_data()
      image.save_png(folder.path_join(name+".png"))
      var hidden=s.sirens.duplicate(true)
      for enemy in s.sirens:enemy.pos+=Vector2(170,120);enemy.mode="ENGAGE"
      await draw_frame(view)
      check(root.get_texture().get_image().get_data()==image.get_data(),"hidden roster cannot alter public art pixels "+name)
      s.sirens=hidden
      await draw_frame(view)
      if scene==1:
       var private_shapes=s.terrain_chart._shapes
       s.terrain_chart._shapes=[]
       await draw_frame(view)
       check(root.get_texture().get_image().get_data()==image.get_data(),"earned art uses public chart, not hidden chart geometry "+name)
       s.terrain_chart._shapes=private_shapes
       await draw_frame(view)
     var row={"name":name,"block":block,"enabled":enabled,"snapshot":state,"snapshot_after":digest(s),"cpu_usec":times,"frame_usec":cadence,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"objects_delta":Performance.get_monitor(Performance.OBJECT_COUNT)-objects_before,"static_bytes_delta":Performance.get_monitor(Performance.MEMORY_STATIC)-memory_before,"gpu_timing":"unavailable","window_size":DisplayServer.window_get_size(),"effective_viewport":root.get_visible_rect().size,"view_size":view.size,"camera":view.chart_camera.snapshot(),"world_scale":view.world_scale,"world_offset":view.world_offset,"phase":view.phase,"lamp_on":view.optical_feed.art_lamp_current(s) if not baseline else false}
     records.append(row)
     row["objects_delta"]=objects_delta;row["static_bytes_delta"]=memory_delta
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

# Opt-in native profile of the real OceanView source. Timers are injected in memory
# only; the production script and draw commands stay byte-for-byte on disk.
# -- --profile-chart --frames=120 --blocks=4 --folder=ABSOLUTE_PATH
# Blocks use OFF/ON/ON/OFF. Fixed phase and manually timed _process(0)
# isolate presentation from simulation. Native desktop timers are not phone FPS.
# render_phase_wall_usec spans frame_pre_draw..frame_post_draw (CPU/submission/
# driver waiting inclusive), not an isolated GPU or render-wait measurement.
var render_started=0
var render_wall_usec=0
func profile_render_start():render_started=Time.get_ticks_usec()
func profile_render_end():render_wall_usec=Time.get_ticks_usec()-render_started
func profiled_ocean_script():
 var source=FileAccess.get_file_as_string("res://src/presentation/ocean_view.gd").replace("\r", "")
 source+="\nvar profile_costs={}\nvar profile_at=0\nvar profile_visibility_usec=0\nvar profile_visibility_calls=0\nfunc profile_visible(p):\n\tvar at=Time.get_ticks_usec()\n\tvar result=sim.visible(p)\n\tprofile_visibility_usec+=Time.get_ticks_usec()-at\n\tprofile_visibility_calls+=1\n\treturn result\nfunc profile_mark(key):\n\tvar now=Time.get_ticks_usec()\n\tif not key.is_empty():profile_costs[key]=now-profile_at\n\tprofile_at=now\n"
 source=source.replace("func _draw() -> void:\n", "func _draw() -> void:\n\tprofile_visibility_usec=0;profile_visibility_calls=0\n\tprofile_costs={}\n\tprofile_mark(\"\")\n")
 source=source.replace("if sim.visible(p) else 0.20", "if profile_visible(p) else 0.20")
 var markers=[
  ["\tRegionArt.atmosphere(self,regional_style,region,phase)","setup_chart"],
  ["\t# Cartographic graticule", "region_atmosphere"],
  ["\t# Briefed environment only", "graticule_contours"],
  ["\t# Bedrock and columnar basalt", "departure_lamp"],
  ["\tFeatureViews.draw_ground(self)", "terrain"],
  ["\t# Intelligence marks are briefed", "ground_sites_structures"],
  ["\tFeatureViews.draw(self)", "objectives_fog"],
  ["\t_draw_observed_paths()", "features_sonar_extraction"],
  ["\tfor i in sim.units.size():", "findings_rules_pricing"],
  ["\tPalette.received_bearings(self,sim)", "fleet_routes_activity"],
  ["\tvar acoustic=sim.acoustic_feedback()", "bearings_contacts"],
  ["\t_draw_pressure_overlay()", "acoustics_particles"],
  ["\t# Short screen-sized tags", "pressure_current_screen"],
  ["\n# A Siren study keeps", "readouts"]]
 for marker in markers:
  check(source.count(marker[0])==1,"unique source timer anchor "+marker[1])
  source=source.replace(marker[0],"\tprofile_mark(\"%s\")\n"%marker[1]+marker[0])
 var script=GDScript.new();script.source_code=source
 check(script.reload()==OK,"instrumented actual OceanView compiles")
 return script
func run_chart_profile(render_timing):
 RenderingServer.frame_pre_draw.connect(profile_render_start)
 RenderingServer.frame_post_draw.connect(profile_render_end)
 var script=profiled_ocean_script()
 var records=[]
 table.enabled=true
 var original=load("res://src/presentation/ocean_view.gd")
 var contour_test=original.new()
 for extent in [Vector2(1600,960),Vector2(4000,2500),Vector2(800,480),Vector2(1600,960)]:
  contour_test._contour_extent=Vector2(-1,-1)
  var rebuilt=contour_test._depth_contours(extent)
  contour_test._contour_extent=Vector2(-1,-1)
  var cached=contour_test._depth_contours(extent)
  check(cached==rebuilt,"cache rebuilds identical geometry after extent change "+str(extent))
  check(is_same(cached,contour_test._depth_contours(extent)),"same extent reuses contour array")
 contour_test.free()
 var fidelity_script=original
 if not reference_source.is_empty():
  fidelity_script=GDScript.new()
  fidelity_script.source_code=FileAccess.get_file_as_string(reference_source).replace("\r", "")
  check(fidelity_script.reload()==OK,"pre-patch source reference compiles")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await process_frame;await process_frame
  for operation in [11,28,32]:
   var s=Sim.new();s.start(operation,"endurance");s.paused=true;s.elapsed=10.
   # Source-known staged received evidence, not acquisition or encounter balance.
   # Ordinary chart.observe creates only measured surfaces and certified water.
   if s.terrain_chart!=null:
    for unit in s.units:s.terrain_chart.observe([{"pos":unit.pos,"radius":720.}],{})
   s.mission["reconnaissance"]=s.Recon.state(s.mission).duplicate(true)
   s.mission.reconnaissance.hunt=85.
   s.HuntPressure.initialize(s.mission)
   s.mission.hunt_pressure.stage=s.HuntPressure.stage(s.mission)
   s.contacts={}
   for id in s.sirens.size():
    var enemy=s.sirens[id]
    s.contacts[id]={"pos":enemy.pos,"angle":enemy.angle,"type":enemy.type,"time":s.elapsed,"mode":"LOCKING","lock":2.,"target":0,"band":enemy.band,"source":"optical","confidence":1.,"seen_by":[0]}
   for n in 72:
    var id=n%s.sirens.size();var enemy=s.sirens[id];var station=n%3
    s.sonar.history.append({"station":station,"enemy":id,"origin":s.units[station].pos,"direction":s.units[station].pos.direction_to(enemy.pos),"time":s.elapsed-float(n%12)*.1,"band":enemy.band,"confidence":.8,"classification":"PROPULSION","direct":true,"kind":"bearing","tone":enemy.acoustic_tone})
   check(Sim.valid_snapshot(s.snapshot()),"dense public fixture valid op "+str(operation))
   var state=digest(s);var reference=Sim.new();check(reference.restore(s.snapshot()),"reference restores dense fixture")
   var accepted_reference=reference.command("select",{"unit":1});var command_hash=digest(reference);reference=null
   var view=Control.new();view.set_script(script);view.sim=s;view.size=root.get_visible_rect().size;root.add_child(view)
   view.set_process(false);view.optical_feed.set_process(false);view._process(0.);view.phase=.5
   for n in 30:await draw_frame(view)
   var before=root.get_texture().get_image();before.save_png(folder.path_join("op%d-%dx%d.png"%[operation,dimensions.x,dimensions.y]))
   for block in blocks:
    for n in 10:await draw_frame(view)
    check(root.get_texture().get_image().get_data()==before.get_data(),"repeated draw preserves default pixels op "+str(operation))
    var draw=[];var process=[];var wall=[];var cadence=[];var renderer_cpu=[];var gpu=[];var sections={};var calls=[];var visibility=[];var visibility_calls=[]
    for n in sample_frames:
     var at=Time.get_ticks_usec();view._process(0.);process.append(Time.get_ticks_usec()-at)
     at=Time.get_ticks_usec();await draw_frame(view);cadence.append(Time.get_ticks_usec()-at)
     var total=0
     for key in view.profile_costs:
      if not sections.has(key):sections[key]=[]
      sections[key].append(view.profile_costs[key]);total+=view.profile_costs[key]
     draw.append(total);wall.append(render_wall_usec)
     visibility.append(view.profile_visibility_usec);visibility_calls.append(view.profile_visibility_calls)
     calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
     renderer_cpu.append(float(RenderingServer.call("viewport_get_measured_render_time_cpu",root.get_viewport_rid()))*1000. if render_timing else 0.)
     gpu.append(float(RenderingServer.call("viewport_get_measured_render_time_gpu",root.get_viewport_rid()))*1000. if render_timing else 0.)
    records.append({"operation":operation,"dimensions":dimensions,"block":block,"draw_cpu_usec":draw,"process_cpu_usec":process,"render_phase_wall_usec":wall,"await_frame_wall_usec":cadence,"viewport_render_cpu_usec":renderer_cpu,"viewport_gpu_usec":gpu,"draw_calls":calls,"sections_usec":sections,"fog_visibility_line_usec":visibility,"fog_visibility_calls":visibility_calls,"snapshot":state,"snapshot_after":digest(s),"contacts":s.contacts.size(),"sonar_history":s.sonar.history.size(),"public_clear_cells":s.public_chart().get("clear_cells",[]).size(),"public_surfaces":s.public_chart().get("surface_segments",[]).size(),"region":view.regional_style,"effective_viewport":root.get_visible_rect().size,"view_size":view.size,"window_size":DisplayServer.window_get_size()})
    check(digest(s)==state,"profile preserves snapshot op "+str(operation))
    print("CHART PROFILE op ",operation," size ",dimensions," block ",block)
   # Compare a fresh uninstrumented production view at the same fixed pose.
   # Exact native pixels must match with all default presentation enabled.
   view.visible=false
   var plain=fidelity_script.new();plain.sim=s;plain.size=root.get_visible_rect().size;root.add_child(plain)
   plain.set_process(false);plain.optical_feed.set_process(false);plain._process(0.);plain.phase=.5
   await draw_frame(plain);await draw_frame(plain)
   root.get_texture().get_image().save_png(folder.path_join("op%d-%dx%d-plain.png"%[operation,dimensions.x,dimensions.y]))
   check(root.get_texture().get_image().get_data()==before.get_data(),"instrumentation preserves default art pixels op "+str(operation))
   check(digest(s)==state,"plain draw preserves snapshot op "+str(operation))
   check(s.command("select",{"unit":1})==accepted_reference and digest(s)==command_hash,"draw preserves subsequent command op "+str(operation))
   view.queue_free();plain.queue_free();await process_frame;s=null
 var file=FileAccess.open(folder.path_join("chart-profile.json"),FileAccess.WRITE);file.store_string(JSON.stringify(records));file.close()
 print("ART RENDER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
