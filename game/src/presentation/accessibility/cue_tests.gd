extends SceneTree
# Source-known own-craft and public-contact fixtures, not an encounter journey.
const Sim=preload("res://src/simulation/simulation.gd")
const Observer=preload("res://src/presentation/accessibility/cue_observer.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Store=preload("res://src/persistence/settings_store.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func contrast(a:Color,b:Color)->float:
 var x=a.srgb_to_linear().get_luminance();var y=b.srgb_to_linear().get_luminance()
 return (maxf(x,y)+.05)/(minf(x,y)+.05)
func _initialize():call_deferred("run")
func fresh():
 var s=Sim.new();s.start(0);s.paused=false;return s
func event(s,receiver=0):return {"type":"sweep_received","receiver":receiver,"time":s.elapsed,"direction":Vector2.UP}
func run():
 Settings.apply({"audio_captions":true,"haptics":false,"master":0.})
 check(not Store.sanitize({}).safe_palette and not Store.sanitize({}).audio_captions,"old settings default to standard palette and captions off")
 check(not Store.sanitize({"safe_palette":"yes","audio_captions":1}).safe_palette and not Store.sanitize({"audio_captions":1}).audio_captions,"invalid optional fields recover independently")
 var s=fresh();var observer=Observer.new();observer.observe(s,true)
 s.elapsed=10.;s.events=[event(s,1)];observer.observe(s,true)
 check(observer.text().is_empty(),"other receiver never captions")
 s.events=[{"type":"factory","receiver":1,"time":10.,"direction":Vector2.UP}];observer.observe(s,true)
 check(observer.text().is_empty(),"other receiver industrial warning stays private")
 s.events=[{"type":"factory","receiver":0,"time":10.,"direction":Vector2.UP}];observer.observe(s,true)
 check(observer.emitted==["factory"],"earned industrial cue uses the same received gate")
 observer.rows=[]
 s.events=[event(s)];var before=s.snapshot();observer.observe(s,true)
 check("HEARD" in observer.text() and observer.emitted==["sweep_received"],"selected receiver caption works with master muted")
 check(s.snapshot()==before and s.events.size()==1,"observer leaves simulation and events untouched")
 observer.observe(s,true);check(observer.emitted.is_empty(),"independent received state deduplicates repeated refresh")
 s.events=[{"type":"camera"}];s.paused=true;observer.observe(s,true)
 check(observer.emitted.is_empty() and observer.pulse_requests==0,"pause cannot emit captions or haptic repeats")
 s.events=[];s.paused=false;s.elapsed=11.;observer.observe(s,false)
 check(observer.text().is_empty() and observer.history.is_empty(),"menu clears caption and history state")
 s=fresh();s.events=[event(s)];observer.observe(s,true)
 check(observer.text().is_empty() and observer.history.is_empty(),"new mission seeds without historical event replay")
 s.elapsed=10.;s.events=[event(s)];observer.observe(s,true);s.elapsed=0.;observer.observe(s,true)
 check(observer.text().is_empty() and observer.history.is_empty(),"rewound clock clears old session captions and history")
 s=fresh();s.mission.photo_pricing={"film":[3,4,4]};observer.observe(s,true)
 s.mission.photo_pricing.film[0]=2;observer.observe(s,true)
 check(observer.emitted.has("film_low"),"low film transition reuses published threshold")
 observer.observe(s,true);check(observer.emitted.is_empty(),"film low does not repeat")
 s.paused=true;s.mission.photo_pricing.film[0]=0;observer.observe(s,true);s.paused=false;observer.observe(s,true)
 check(observer.emitted.is_empty(),"paused own-state transitions seed without replay")
 Settings.apply({"audio_captions":true,"haptics":true})
 s.elapsed=30.;s.events=[event(s)];observer.observe(s,true)
 check(observer.pulse_requests==1,"optional warning pulse uses existing platform seam")
 s.events=[];observer.observe(s,true)
 check(observer.pulse_requests==1,"unchanged warning cannot repeatedly request haptics")
 for n in 12:
  s.elapsed+=1.;s.events=[{"type":"camera"}];observer.observe(s,true)
 check(observer.history.size()==preload("res://src/presentation/accessibility/cue_table.gd").HISTORY_ROWS and "mission clock" in observer.history_text(),"audio history is bounded and explicitly historical")
 s.selected=1;s.events=[];observer.observe(s,true)
 check(observer.history.is_empty(),"changing receivers clears previous receiver history")
 s.selected=0;observer.observe(s,true)
 Settings.apply({"audio_captions":false,"haptics":false})
 s.elapsed=20.;s.events=[event(s)];observer.observe(s,true)
 check(observer.text().is_empty() and observer.history.is_empty(),"captions off clears optional text and audio history")
 check(Palette.film_tag(0,8).ends_with("EMPTY") and Palette.film_tag(2,8).ends_with("LOW"),"film LOW and EMPTY remain explicit with captions off")
 check(Palette.color("warning",Color.RED)==Color.RED,"standard default hue is untouched")
 Settings.apply({"safe_palette":true})
 check(Palette.color("warning",Color.RED)==Color("e69f00"),"optional palette uses table color")
 for role in ["warning","reach","flash","ink"]:
  check(contrast(Palette.color(role,Color.WHITE),Color("07131b"))>=4.5,"safe palette label contrast on caption/chart backing "+role)
 check(contrast(Palette.color("heard",Color.WHITE),Color("07131b"))>=3.,"safe shutter stroke contrast on dark backing")
 var patterns=preload("res://src/presentation/accessibility/cue_table.gd").PATTERNS
 check(patterns.flash!=patterns.warning and patterns.warning!=patterns.heard and patterns.heard!=patterns.flash,"semantic rings differ without hue")
 var sound=preload("res://src/audio/soundscape.gd").new();root.add_child(sound);await process_frame
 Settings.apply({"audio_captions":true,"haptics":false})
 s=fresh();sound.update(s,0.);sound.muted=true;s.elapsed=10.;s.events=[event(s)];sound.update(s,0.)
 check("HEARD" in sound.accessibility.text() and s.events.is_empty(),"real muted Soundscape observes captions before clearing events")
 sound.muted=false;s.elapsed=20.;s.events=[event(s)];sound.update(s,0.)
 check(sound.accessibility.emitted.has("sweep_received") and sound.received_cues.heard.has("0/sweep_received"),"caption observer does not consume original audio dedup")
 sound.queue_free();await process_frame;await create_timer(.1).timeout
 await chart_checks()
 Settings.apply({})
 print("A11Y CUES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)

class DrawCommands extends RefCounted:
 var commands:Array=[]
 var world_offset=Vector2.ZERO
 var world_scale=1.
 var size=Vector2(800,600)
 func draw_rect(rect,color):commands.append(["rect",rect,color])
 func draw_line(a,b,color,width):commands.append(["line",a,b,color,width])
 func draw_arc(at,r,a,b,n,color,width):commands.append(["arc",at,r,a,b,n,color,width])
 func draw_dashed_line(a,b,color,width,dash):commands.append(["dash",a,b,color,width,dash])
func chart_checks():
 var region=preload("res://src/presentation/art/region_renderer.gd")
 var style=preload("res://src/presentation/art/region_table.gd").STYLES.glass
 var a=DrawCommands.new();var b=DrawCommands.new()
 Settings.apply({})
 var parts=[{"from":Vector2.ZERO,"to":Vector2(180,0),"confirmed":true},{"from":Vector2(180,0),"to":Vector2(360,0),"confirmed":false}]
 Palette.course(a,parts,1.,true)
 preload("res://src/presentation/earned_chart_view.gd").draw_course(b,parts,1.,true)
 check(a.commands==b.commands,"chart_default_course_commands_exact_legacy")
 a.commands=[];Palette.marker(a,Vector2.ZERO,20.,"threat")
 check(a.commands.is_empty() and Palette.motion_phase(17.)==17. and Palette.stroke(2.)==2.,"chart_disabled_helpers_emit_no_extra_commands")
 Settings.apply({"reduced_motion":true})
 a.commands=[];b.commands=[]
 region.atmosphere(a,style,Vector2(1600,960),1.)
 region.atmosphere(b,style,Vector2(1600,960),53.)
 check(not a.commands.is_empty() and a.commands==b.commands,"chart_reduced_motion_atmosphere_commands_identical_across_phase")
 var meter=preload("res://src/presentation/hunt_meter.gd")
 var view={"index":4,"active":true}
 check(meter.tone(view,1.)==meter.tone(view,53.) and Palette.pulse(.3,.75)==.75,"chart_reduced_motion_warning_and_hunt_pulses_steady")
 Settings.apply({"safe_palette":true})
 var shapes=[]
 for role in ["threat","evidence","route","warning"]:
  a.commands=[];Palette.marker(a,Vector2.ZERO,20.,role)
  var shape=a.commands.map(func(cmd):return cmd.slice(0,6))
  check(not shapes.has(shape),"chart_safe_"+role+"_distinct_draw_pattern")
  shapes.append(shape)
  check(contrast(Palette.color(role,Color.WHITE),Color("07131b"))>=3.,"chart_safe_"+role+"_stroke_contrast")
 check(not Palette.legend().is_empty(),"chart_safe_legend_in_existing_help")
 Settings.apply({"high_contrast":true})
 check(Palette.stroke(2.)>2. and Palette.chart_color("route",Color(.2,.3,.4,.2)).a>=.85,"chart_high_contrast_thicker_brighter_strokes")
 a.commands=[];region.atmosphere(a,style,Vector2(1600,960),1.)
 Settings.apply({});b.commands=[];region.atmosphere(b,style,Vector2(1600,960),1.)
 check(a.commands[0][2].a<b.commands[0][2].a,"chart_high_contrast_mutes_regional_light")
 var ocean=preload("res://src/presentation/ocean_view.gd").new();ocean.sim=fresh()
 ocean.sim.contacts[0]={"pos":ocean.sim.units[0].pos+Vector2(80,0),"angle":PI,"time":0.,"mode":"LOCKING","lock":2.,"target":0,"type":"patroller","band":ocean.sim.units[0].band}
 var warnings=preload("res://src/presentation/lock_warning.gd")
 var eligible=warnings.frames(ocean.sim);var entries=ocean.contact_entries();var before=ocean.sim.snapshot()
 ocean.camera_flash=1.;ocean._process(0.)
 check(ocean.camera_flash==1.,"chart_default_flash_state_unchanged")
 Settings.apply({"reduced_motion":true,"safe_palette":true,"high_contrast":true})
 ocean._process(0.)
 check(ocean.camera_flash<=.08,"chart_reduced_motion_caps_camera_flash")
 check(not eligible.is_empty() and eligible==warnings.frames(ocean.sim) and entries==ocean.contact_entries() and before==ocean.sim.snapshot(),"chart_settings_preserve_warning_eligibility_and_all_contact_information")
 ocean.free()
 if "--chart-render" in OS.get_cmdline_user_args():await chart_render_checks()
func chart_image(script,options:Dictionary,phase_value:float,operation:int=0):
 Settings.apply(options)
 var viewport=SubViewport.new();viewport.size=Vector2i(800,600);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 root.add_child(viewport)
 var ocean=script.new();ocean.sim=fresh();ocean.sim.start(operation);ocean.size=Vector2(800,600)
 # Source-known contact and course: presentation must not alter the fixture.
 ocean.sim.units[0].route=[{"pos":ocean.sim.units[0].pos+Vector2(250,0),"stop":true}]
 var own=ocean.sim.units[0].pos
 ocean.sim.contacts[0]={"pos":own+Vector2(180,0),"angle":PI,"time":ocean.sim.elapsed,"mode":"LOCKING","lock":4.,"target":0,"type":"patroller","band":ocean.sim.units[0].band}
 var before=ocean.sim.snapshot()
 viewport.add_child(ocean);ocean.set_process(false);ocean.phase=phase_value
 ocean.optical_feed.hide();ocean.queue_redraw()
 for n in 3:await process_frame
 await RenderingServer.frame_post_draw
 var img=viewport.get_texture().get_image()
 check(ocean.sim.snapshot()==before,"chart_render_preserves_simulation")
 viewport.queue_free();await process_frame
 return img
func chart_render_checks():
 if DisplayServer.get_name()=="headless":check(false,"chart_render_requires_Compatibility_display");return
 var script=preload("res://src/presentation/ocean_view.gd")
 var off=await chart_image(script,{},1.)
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--chart-baseline="):
   var baseline=await chart_image(load(arg.trim_prefix("--chart-baseline=")),{},1.)
   check(off.get_data()==baseline.get_data(),"chart_default_render_byte_identical_pre081_source")
   var earned_off=await chart_image(script,{},1.,10)
   var earned_baseline=await chart_image(load(arg.trim_prefix("--chart-baseline=")),{},1.,10)
   check(earned_off.get_data()==earned_baseline.get_data(),"chart_earned_default_render_byte_identical_pre081_source")
 var still_a=await chart_image(script,{"reduced_motion":true},1.)
 var still_b=await chart_image(script,{"reduced_motion":true},53.)
 check(still_a.get_data()==still_b.get_data(),"chart_reduced_motion_render_identical_across_phase")
 var contrast_img=await chart_image(script,{"high_contrast":true},1.)
 check(off.get_data()!=contrast_img.get_data(),"chart_high_contrast_changes_actual_render")
 await chart_image(script,{"safe_palette":true},1.)
 var restored=await chart_image(script,{},1.)
 check(off.get_data()==restored.get_data(),"chart_settings_reversible_render_exact")
