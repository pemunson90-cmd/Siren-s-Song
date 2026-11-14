extends SceneTree
# WP-10 shutter through the real Main, by touch, on the Fold cover and inner shapes.
# The fixture subject is op 0's spire carrying the op 15 strain vane crack row
# (detail 0.68, the "use a TIGHT frame" case a blind critic lost two frames to).
# A WIDE frame of it is warned once at no cost; pressing again exposes as before.
const Photo=preload("res://src/simulation/photo_capture.gd")
const PhotoOps=preload("res://src/campaign/photo_ops.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const ForecastRule=preload("res://src/photo_grade/frame_forecast.gd")
const SHUTTER_PATH="res://src/presentation/photo_shutter/shutter.gd"
const TABLE_PATH="res://src/presentation/photo_shutter/shutter_table.gd"
var Shutter
var ShutterTable
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 7:await process_frame
func touch(point,pressed,index=0):
	var e=InputEventScreenTouch.new();e.position=point;e.index=index;e.pressed=pressed;root.push_input(e,true);await process_frame
func tap(point):
	await touch(point,true);await touch(point,false);await settle()
func fine_subject(spire:Dictionary)->Dictionary:
	var row=PhotoOps.CAMPAIGN_PHOTOS.filter(func(r):return r.key=="vane_crack")[0]
	var config=PhotoOps.CAMPAIGN_DEFAULTS.duplicate(true);config.merge(row,true)
	var feature=PhotoOps.F(row.key,row.feature,0.0,PI,config.detail,0.0,{"intel":row.key,"dwell":config.dwell})
	return PhotoOps.S(spire.subject.facing,config.size,config.glow,[row.key],[feature])
func shutter_rect(feed)->Rect2:
	var r=feed.get("shutter_rect")
	return r if r is Rect2 else Rect2()
func view(game):
	game._refresh();game.ocean._process(0.0);game.ocean.optical_feed.queue_redraw();await settle()
func press_shutter(game):
	var feed=game.ocean.optical_feed;await view(game)
	var r:=shutter_rect(feed)
	await tap(feed.global_position+(r.get_center() if r.has_area() else Vector2(feed.size.x-260,30)))
func press_ring(game):
	game.order_buttons.camera.emit_signal("pressed");await settle()
func idle(s):
	return s.captures[0].is_empty()
func reset_capture(s):
	s.captures[0]={};s.mission.photo.acc.erase(0);s.units[0].hold=""
func run():
	Shutter=load(SHUTTER_PATH) if ResourceLoader.exists(SHUTTER_PATH) else null
	ShutterTable=load(TABLE_PATH) if ResourceLoader.exists(TABLE_PATH) else null
	check(Shutter!=null and ShutterTable!=null,"the shutter module exists")
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
	print("PHOTO SHUTTER UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func shape_case(shape:Vector2i):
	var stamp="%dx%d"%[shape.x,shape.y]
	root.size=shape;await settle()
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp10-shutter-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false);game._start_mission(0);await settle()
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	var s=game.sim;s.sirens=[]
	var spire:Dictionary=s.mission.objectives[0]
	spire.erase("unknown");spire["subject"]=fine_subject(spire)
	var u=s.units[0];var near:Vector2=spire.pos+Vector2.from_angle(spire.subject.facing)*100.0
	u.pos=near;u.angle=u.pos.angle_to_point(spire.pos);u.vel=Vector2.ZERO
	Photo.set_frame(s,0,{"mode":"wide"})
	await view(game)
	var feed=game.ocean.optical_feed
	check(feed.visible,"viewfinder opens for the subject "+stamp)
	check(game.order_buttons.camera.text=="PHOTO","the ring keeps its PHOTO action "+stamp)
	check(s.camera_context().get("ready",false),"the simulation would accept this WIDE exposure (setup) "+stamp)
	var r:=shutter_rect(feed)
	check(r.has_area(),"the camera panel draws a shutter control "+stamp)
	var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
	check(r.size.x*dp>=48.0 and r.size.y*dp>=48.0,"shutter keeps a 48 dp target "+stamp)
	check(Rect2(Vector2.ZERO,feed.size).encloses(r),"shutter lies inside the camera panel "+stamp)
	check(not r.intersects(feed.picture_rect) and not r.intersects(feed.toggle_rect) and not feed._buttons.any(func(b):return b.rect.intersects(r)),"shutter covers neither the viewfinder picture nor another control "+stamp)
	check(feed.get("shutter_refusal")!="","the panel knows this frame will be warned "+stamp)
	# Forecast beside SHUTTER: the frame it would file now and the shutter's reach, before the tap.
	var heard:int=roundi(float(Pricing.readout(s,0,spire).heard))
	check("HEARD TO %dm"%heard in str(feed.get("forecast_text")) and ("FRAME ~" in str(feed.get("forecast_text")) or "NO USABLE FRAME" in str(feed.get("forecast_text"))),"the panel states the forecast frame and how far the shutter is heard "+stamp)
	var guess=ForecastRule.forecast(feed._frame,spire)
	check(not guess.usable and "NO USABLE FRAME" in str(feed.get("forecast_text")),"a WIDE frame of a fine-detail subject forecasts no usable frame "+stamp)
	# The panel holds still: fold and open, with the threat stack changing, never move SHUTTER, WIDE or the panel.
	var held_position:Vector2=feed.position
	s.message="x";game.ocean.threat_bottom=game.ocean.instrument_top+60.;await view(game)
	var raised:Vector2=feed.position;game.ocean.threat_bottom=0.
	feed.compact=true;await view(game);var folded_position:Vector2=feed.position
	feed.compact=false;await view(game)
	check(feed.position.y>=held_position.y and raised.y>=held_position.y and folded_position==raised and feed.position==raised,"fold and open never move the camera panel up or sideways "+stamp)
	game.ocean.threat_bottom=0.;await view(game)
	# A first-notice toast stays clear of the camera panel.
	var cue=game.find_child("FirstSirenCue",true,false)
	if cue!=null:
		cue.refresh();check(cue.chip_rect.end.x<=feed.global_position.x+0.5 and cue.note_rect.end.x<=feed.global_position.x+0.5,"the Siren-noticed toast sits left of the camera panel "+stamp)
	# First shutter press: warned, nothing spent.
	if Shutter!=null:Shutter.warned={}
	var film:int=Pricing.film_left(s,0);var noises:int=s.noises.size()
	await press_shutter(game)
	check(idle(s) and Pricing.film_left(s,0)==film and s.noises.size()==noises,"first press starts no exposure, spends no film and makes no shutter noise "+stamp)
	check("TIGHT" in s.message and "press again" in s.message and "no film spent" in s.message and "HAIRLINE CRACK" in s.message,"the warning names the detail, both choices and that no film was spent "+stamp)
	check(not game.mission_hud.task_result.get("ok",true) and "no film spent" in str(game.mission_hud.task_result.get("text","")),"the warning is reported as the last order result "+stamp)
	# An expired warning warns again.
	if Shutter!=null:Shutter.warned["at"]=float(Shutter.warned.get("at",0.0))-ShutterTable.REPEAT_SECONDS-1.0
	await press_shutter(game)
	check(idle(s) and Pricing.film_left(s,0)==film,"a press after the window warns again instead of exposing "+stamp)
	# Second press within the window: the base exposure, exactly once.
	await press_shutter(game)
	check(not idle(s) and Pricing.film_left(s,0)==film-1,"a second press exposes anyway and spends exactly one frame "+stamp)
	check(s.noises.size()==noises+1 and str(s.noises.back().get("label",""))=="CAMERA","the forced exposure makes the ring order's CAMERA noise once "+stamp)
	check(game.mission_hud.task_result.get("ok",false) and "Camera exposure" in str(game.mission_hud.task_result.get("text","")),"the forced exposure reports the ring order's result "+stamp)
	await view(game)
	check(not shutter_rect(feed).has_area(),"no shutter is offered while the exposure runs "+stamp)
	reset_capture(s);film=Pricing.film_left(s,0);noises=s.noises.size()
	# The ring's PHOTO follows the same rule.
	if Shutter!=null:Shutter.warned={}
	await press_ring(game)
	check(idle(s) and Pricing.film_left(s,0)==film and "press again" in s.message,"the ring's first PHOTO is warned at no cost "+stamp)
	await press_ring(game)
	check(not idle(s) and Pricing.film_left(s,0)==film-1 and s.noises.size()==noises+1,"the ring's second PHOTO exposes as before "+stamp)
	reset_capture(s);film=Pricing.film_left(s,0);noises=s.noises.size()
	# TIGHT: no warning; one shutter press exposes.
	var toggle=feed._buttons.filter(func(b):return b.args.has("mode"))
	check(toggle.size()==1,"frame toggle is on the panel "+stamp)
	if not toggle.is_empty():await tap(feed.global_position+toggle[0].rect.get_center())
	check(Photo.settings(s,0).mode=="tight","a real tap on WIDE selects TIGHT "+stamp)
	await view(game)
	check(shutter_rect(feed).has_area() and feed.get("shutter_refusal")=="","TIGHT clears the warning "+stamp)
	var target:int=int(s.camera_context().get("target",-1))
	await press_shutter(game)
	check(not idle(s) and int(s.captures[0].get("target",-1))==target and Pricing.film_left(s,0)==film-1,"one shutter press exposes the framed subject "+stamp)
	reset_capture(s)
	# Mirrored HUD: the shutter moves to the left end of the header.
	var mirrored=Settings.current.get("mirrored_hud",false)
	Settings.current["mirrored_hud"]=true
	await view(game);r=shutter_rect(feed)
	check(r.has_area() and r.end.x<feed.toggle_rect.position.x and r.position.x<feed.size.x*0.5,"mirrored HUD places the shutter at the left of the header "+stamp)
	check(not r.intersects(feed.picture_rect) and not feed._buttons.any(func(b):return b.rect.intersects(r)),"mirrored shutter covers no picture or control "+stamp)
	Settings.current["mirrored_hud"]=mirrored
	# Folded panel: no shutter.
	feed.compact=true;await view(game)
	check(not shutter_rect(feed).has_area(),"a folded panel draws no shutter "+stamp)
	feed.compact=false
	# Not a ready photograph: the viewfinder may preview, but no shutter is drawn.
	u.pos=spire.pos+Vector2.from_angle(spire.subject.facing)*300.0;u.angle=u.pos.angle_to_point(spire.pos)
	await view(game)
	check(not s.camera_context().get("ready",true),"out of reach the camera is not ready (setup) "+stamp)
	check(not shutter_rect(feed).has_area(),"no shutter when the primary action is not a ready photograph "+stamp)
	u.pos=near;u.angle=u.pos.angle_to_point(spire.pos)
	# Switch off: no shutter, and the ring's PHOTO exposes at once as on the base.
	Photo.set_frame(s,0,{"mode":"wide"});film=Pricing.film_left(s,0)
	if ShutterTable!=null:ShutterTable.enabled=false
	await view(game)
	check(not shutter_rect(feed).has_area(),"switch off: the panel draws no shutter "+stamp)
	await press_ring(game)
	check(not idle(s) and Pricing.film_left(s,0)==film-1,"switch off: the ring's first PHOTO exposes at once, as before "+stamp)
	if ShutterTable!=null:ShutterTable.enabled=true
	reset_capture(s)
	game.queue_free();await settle()
