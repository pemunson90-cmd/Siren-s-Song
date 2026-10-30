extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Soundscape=preload("res://src/audio/soundscape.gd")
const Art=preload("res://src/presentation/art/art_table.gd")
const Quality=preload("res://src/presentation/quality/quality_table.gd")
const Roles=preload("res://src/audio/siren_role_cues.gd")
const Wave=preload("res://src/audio/photo_audio/photo_wave.gd")
const PassiveFixture=preload("res://tests/depth_sonar_scenarios.gd")
const Sonar=preload("res://src/simulation/advanced_sonar.gd")
const Industry=preload("res://src/simulation/industrial_threats.gd")
class SoundProbe extends "res://src/audio/soundscape.gd":
	var observed:Array=[]
	func _play_observed(cue:String,_position:Vector2,recording:String)->void:observed.append([cue,recording])
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var signatures={}
	for frame in ["quietus","quiet","fast","drone_a","drone_b","scout","heavy","endurance"]:
		var shape=Art.SHAPES[frame]
		var digest=var_to_bytes(shape).hex_encode().sha256_text()
		check(not signatures.has(digest),"distinct frame silhouette "+frame)
		signatures[digest]=true
		var bounds:Vector2=Art.BOUNDS[frame]
		var fits=true
		for point in shape:fits=fits and absf(point.x)<=bounds.x and absf(point.y)<=bounds.y
		check(fits,"frame fits phone-scale local bounds "+frame)
	var roles={}
	var audio_signatures={}
	for role in Roles.SIGNATURES:
		var cue=Roles.signature(role)
		check(not cue.is_empty() and Roles.CUES.has(cue),"every Siren role maps to an owned cue "+role)
		roles[cue]=true
		var pcm=Wave.render(Roles.CUES[cue]).data
		check(not pcm.is_empty(),"role cue has prepared audio "+role)
		var audio_digest=pcm.hex_encode().sha256_text()
		check(not audio_signatures.has(audio_digest),"role cue has distinct acoustic signature "+role)
		audio_signatures[audio_digest]=true
	check(roles.size()==Roles.SIGNATURES.size(),"each Siren role has a unique audio signature")
	var sim=Sim.new();sim.start(0,"endurance");sim.paused=false
	if sim.sirens.is_empty():sim.sirens=[{"type":"hunter","pos":Vector2(400,400)}]
	else:sim.sirens[0]["type"]="hunter"
	var sound=SoundProbe.new();root.add_child(sound)
	var event={"type":"carrier_received","enemy":0,"receiver":0,"direction":Vector2.RIGHT,"pos":Vector2.ZERO,"time":sim.elapsed}
	sim.events=[event.duplicate()];sound.update(sim,0.,true)
	check(sound.observed.size()==1 and sound.observed[0][1]=="carrier_received","unknown sonar keeps generic received tone")
	sound.observed.clear();sim.elapsed+=6.;sim.sonar["identified"]={0:"hunter"}
	event.time=sim.elapsed;sim.events=[event.duplicate()];sound.update(sim,0.,true)
	check(sound.observed.size()==1 and sound.observed[0][0]=="carrier_received" and sound.observed[0][1]==Roles.signature("hunter"),"identified sonar plays role sound on received-message cue")
	sound.observed.clear();sim.elapsed+=6.;event.time=sim.elapsed;event.receiver=1;sim.events=[event.duplicate()];sound.update(sim,0.,true)
	check(sound.observed.is_empty(),"unselected receiver cannot trigger role sound")
	sim.selected=0;sim.paused=true;sim.elapsed+=6.;event.time=sim.elapsed;event.receiver=0;sim.events=[event.duplicate()];sound.update(sim,0.,true)
	check(sound.observed.is_empty(),"paused sonar cannot trigger role sound")
	sim.paused=false;sim.elapsed+=6.;event.time=sim.elapsed-1.;sim.events=[event.duplicate()];sound.update(sim,0.,true)
	check(sound.observed.is_empty(),"stale sonar cannot trigger role sound")
	sound.free();sim=null
	var passive_sound=SoundProbe.new();root.add_child(passive_sound)
	var role_clock=10.
	var historical=PassiveFixture.fixture();historical.elapsed=role_clock;historical.sirens[0].type="hunter";historical.sonar["identified"]={0:"hunter"};Sonar.advance(historical,0.)
	passive_sound.update(historical,0.,true)
	check(passive_sound.observed.is_empty(),"mission replacement baselines preexisting sonar history");historical=null;role_clock+=6.
	for role in Roles.PASSIVE_ROLES:
		var source=PassiveFixture.fixture();source.elapsed=role_clock;role_clock+=6.
		source.paused=true;source.sirens[0].type=role;source.sonar["identified"]={0:role}
		if role=="warden":Industry.initialize(source);source.sirens[0].industry.phase="windup"
		passive_sound.observed.clear();passive_sound.update(source,0.,true)
		check(passive_sound.observed.is_empty(),"observer baselines existing history without replay for "+role)
		source.paused=false;source.sonar.clock=0.;Sonar.advance(source,0.)
		var actual_bearing=source.sonar.history.any(func(row):return row.kind=="bearing" and row.enemy==0)
		check(actual_bearing,"real sonar source creates passive bearing for "+role)
		passive_sound.update(source,0.,true)
		check(passive_sound.observed.size()==1 and passive_sound.observed[0][1]==Roles.signature(role),"fresh passive bearing reaches role sound for "+role)
		role_clock+=2.;source=null
	var unknown=PassiveFixture.fixture();unknown.elapsed=role_clock;role_clock+=6.;unknown.paused=true;passive_sound.observed.clear()
	unknown.sirens[0].type="hunter";passive_sound.update(unknown,0.,true);unknown.paused=false;unknown.sonar.clock=0.;Sonar.advance(unknown,0.)
	passive_sound.update(unknown,0.,true);check(passive_sound.observed.is_empty(),"unknown-role bearing is consumed without special sound")
	unknown.sonar["identified"]={0:"hunter"};passive_sound.update(unknown,0.,true)
	check(passive_sound.observed.is_empty(),"later identification cannot replay an already heard bearing");unknown=null
	var unselected=PassiveFixture.fixture();unselected.elapsed=role_clock;role_clock+=6.;unselected.paused=true;unselected.sonar["identified"]={0:"patroller"};passive_sound.observed.clear()
	passive_sound.update(unselected,0.,true);unselected.selected=1;unselected.paused=false;unselected.sonar.clock=0.;Sonar.advance(unselected,0.)
	passive_sound.update(unselected,0.,true);check(passive_sound.observed.is_empty(),"bearing received by another craft is consumed silently")
	unselected.selected=0;passive_sound.update(unselected,0.,true);check(passive_sound.observed.is_empty(),"selection change cannot replay an unselected bearing");unselected=null
	var frozen=PassiveFixture.fixture();frozen.elapsed=role_clock;role_clock+=6.;frozen.paused=true;frozen.sonar["identified"]={0:"sentinel"};passive_sound.observed.clear()
	passive_sound.update(frozen,0.,true);frozen.sonar.clock=0.;Sonar.advance(frozen,0.);passive_sound.update(frozen,0.,true)
	check(passive_sound.observed.is_empty(),"paused bearing is consumed without audio");frozen.paused=false;passive_sound.update(frozen,0.,true)
	check(passive_sound.observed.is_empty(),"resume cannot replay a paused bearing");frozen=null
	var stale=PassiveFixture.fixture();stale.elapsed=role_clock;role_clock+=6.;stale.paused=true;stale.sonar["identified"]={0:"hunter"};passive_sound.observed.clear()
	passive_sound.update(stale,0.,true);stale.paused=false;stale.sonar.clock=0.;Sonar.advance(stale,0.);stale.elapsed+=1.;passive_sound.update(stale,0.,true)
	check(passive_sound.observed.is_empty(),"stale bearing fails normal received-cue freshness gate");stale=null
	var far=PassiveFixture.fixture();far.elapsed=role_clock;role_clock+=6.;far.paused=true;far.sonar["identified"]={0:"sentinel"};far.sirens[0].pos=Vector2(1500,900);passive_sound.observed.clear()
	passive_sound.update(far,0.,true);far.paused=false;far.sonar.clock=0.;Sonar.advance(far,0.);passive_sound.update(far,0.,true)
	check(far.sonar.history.is_empty() and passive_sound.observed.is_empty(),"out-of-range Siren produces no special sound");far=null
	var blocked=PassiveFixture.fixture();blocked.elapsed=role_clock;role_clock+=6.;blocked.paused=true;blocked.sonar["identified"]={0:"hunter"};passive_sound.observed.clear()
	var extent:Vector2=blocked.world_size();var wall=PackedVector2Array([Vector2(400,0),Vector2(500,0),Vector2(500,extent.y),Vector2(400,extent.y)])
	blocked.acoustic_paths.configure([wall],blocked.world_size());passive_sound.update(blocked,0.,true);blocked.paused=false;blocked.sonar.clock=0.;Sonar.advance(blocked,0.);passive_sound.update(blocked,0.,true)
	check(blocked.sonar.history.is_empty() and passive_sound.observed.is_empty(),"fully blocked acoustic path produces no special sound");blocked=null
	var rewind=PassiveFixture.fixture();rewind.elapsed=role_clock;role_clock+=6.;rewind.paused=true;rewind.sonar["identified"]={0:"hunter"};passive_sound.observed.clear()
	passive_sound.update(rewind,0.,true);rewind.paused=false;rewind.sonar.clock=0.;Sonar.advance(rewind,0.);passive_sound.update(rewind,0.,true)
	check(passive_sound.observed.size()==1,"pre-rewind fresh bearing emits once");passive_sound.observed.clear();rewind.elapsed-=1.;passive_sound.update(rewind,0.,true)
	check(passive_sound.observed.is_empty(),"elapsed rewind baselines existing history without replay");rewind=null
	passive_sound.free()
	var low=Quality.decorative_enabled("ambient_sea_life",Quality.LOW_EFFECTS)
	var standard=Quality.decorative_enabled("ambient_sea_life",Quality.STANDARD)
	check(standard and not low,"battery-saving LOW EFFECTS removes ambient wildlife")
	var feed=FileAccess.get_file_as_string("res://src/presentation/camera_feed.gd")
	var chart=FileAccess.get_file_as_string("res://src/presentation/ocean_view.gd")
	check("_draw_ambient_sea_life(picture)" in feed and "not live" in feed,"wildlife is limited to non-exposure viewfinder atmosphere")
	check("_draw_ambient_sea_life" not in chart and "_draw_sea_life" not in chart,"wildlife never renders on tactical chart")
	var project=FileAccess.get_file_as_string("res://project.godot")
	check('config/icon="res://assets/title/icon.svg"' in project and 'boot_splash/image="res://assets/title/splash.png"' in project,"project uses replaceable Quietus placeholder key art")
	for path in ["res://assets/title/icon.svg","res://assets/title/splash.svg","res://assets/title/splash.png"]:check(ResourceLoader.exists(path),"placeholder art asset imports: "+path)
	var frontend=FileAccess.get_file_as_string("res://src/presentation/frontend/frontend.gd")
	check("key_art.texture=TITLE_ART" in frontend and "QUIETUS · PHOTOGRAPHIC RECONNAISSANCE" in frontend,"title screen shows Quietus silhouette with reconnaissance caption")
	print("PRESENTATION PASS CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
