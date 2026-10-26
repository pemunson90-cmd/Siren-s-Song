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
 Settings.apply({})
 print("A11Y CUES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
