extends SceneTree
# WP-10 shutter through the real Main, by touch, on the Fold cover and inner shapes.
# The fixture subject is op 0's spire carrying the op 15 strain vane crack row
# (detail 0.68, the "use a TIGHT frame" case a blind critic lost two frames to).
const Photo=preload("res://src/simulation/photo_capture.gd")
const PhotoOps=preload("res://src/campaign/photo_ops.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
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
func feed_point(feed,local:Rect2,fallback:Vector2)->Vector2:
	return feed.global_position+(local.get_center() if local.has_area() else fallback)
func fine_subject(spire:Dictionary)->Dictionary:
	var row=PhotoOps.CAMPAIGN_PHOTOS.filter(func(r):return r.key=="vane_crack")[0]
	var config=PhotoOps.CAMPAIGN_DEFAULTS.duplicate(true);config.merge(row,true)
	var feature=PhotoOps.F(row.key,row.feature,0.0,PI,config.detail,0.0,{"intel":row.key,"dwell":config.dwell})
	return PhotoOps.S(spire.subject.facing,config.size,config.glow,[row.key],[feature])
func shutter_rect(feed):
	var r=feed.get("shutter_rect")
	return r if r is Rect2 else Rect2()
func view(game):
	game._refresh();game.ocean._process(0.0);game.ocean.optical_feed.queue_redraw();await settle()
func run():
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
	var u=s.units[0];u.pos=spire.pos+Vector2.from_angle(spire.subject.facing)*100.0;u.angle=u.pos.angle_to_point(spire.pos);u.vel=Vector2.ZERO
	Photo.set_frame(s,0,{"mode":"wide"})
	await view(game)
	var feed=game.ocean.optical_feed
	check(feed.visible,"viewfinder opens for the subject "+stamp)
	check(game.order_buttons.camera.text=="PHOTO","the ring keeps its PHOTO action "+stamp)
	var context=s.camera_context()
	check(context.get("ready",false),"the simulation would accept this WIDE exposure (the old film-wasting case) "+stamp)
	var r:Rect2=shutter_rect(feed)
	check(r.has_area(),"the camera panel draws a shutter control "+stamp)
	var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
	check(r.size.x*dp>=48.0 and r.size.y*dp>=48.0,"shutter keeps a 48 dp target "+stamp)
	check(Rect2(Vector2.ZERO,feed.size).encloses(r),"shutter lies inside the camera panel "+stamp)
	check(not r.intersects(feed.picture_rect) and not r.intersects(feed.toggle_rect) and not feed._buttons.any(func(b):return b.rect.intersects(r)),"shutter covers neither the viewfinder picture nor another control "+stamp)
	# A WIDE frame of a fine-detail subject is refused before it starts.
	var film:int=Pricing.film_left(s,0);var noises:int=s.noises.size()
	await tap(feed_point(feed,r,Vector2(feed.size.x-260,30)))
	check(s.captures[0].is_empty() and Pricing.film_left(s,0)==film and s.noises.size()==noises,"refused shutter starts no exposure, spends no film and makes no shutter noise "+stamp)
	check("TIGHT" in s.message and "no film spent" in s.message and "HAIRLINE CRACK" in s.message,"refusal names the detail, the fix and that no film was spent "+stamp)
	check(not game.mission_hud.task_result.get("ok",true) and "no film spent" in str(game.mission_hud.task_result.get("text","")),"refusal is reported as the last order result "+stamp)
	# The viewfinder toggle switches to TIGHT; the shutter then runs the ring's order.
	var toggle=feed._buttons.filter(func(b):return b.args.has("mode"))
	check(toggle.size()==1,"frame toggle is on the panel "+stamp)
	if not toggle.is_empty():await tap(feed.global_position+toggle[0].rect.get_center())
	check(Photo.settings(s,0).mode=="tight","a real tap on WIDE selects TIGHT "+stamp)
	await view(game);r=shutter_rect(feed)
	check(r.has_area() and feed.get("shutter_refusal")=="","TIGHT clears the refusal "+stamp)
	var target:int=int(s.camera_context().get("target",-1))
	await tap(feed_point(feed,r,Vector2(feed.size.x-260,30)))
	check(not s.captures[0].is_empty() and int(s.captures[0].get("target",-1))==target,"shutter starts the exposure of the framed subject "+stamp)
	check(Pricing.film_left(s,0)==film-1,"an exposure that starts spends exactly one frame of film "+stamp)
	check(s.noises.size()==noises+1 and str(s.noises.back().get("label",""))=="CAMERA","shutter noise is the ring order's CAMERA noise "+stamp)
	check(game.mission_hud.task_result.get("ok",false) and "Camera exposure" in str(game.mission_hud.task_result.get("text","")),"accepted shutter reports the same result as the ring order "+stamp)
	await view(game)
	check(not shutter_rect(feed).has_area(),"no shutter is offered while the exposure runs "+stamp)
	# Mirrored HUD: the shutter moves to the left end of the header.
	s.captures[0]={};s.mission.photo.acc.erase(0)
	var mirrored=Settings.current.get("mirrored_hud",false)
	Settings.current["mirrored_hud"]=true
	await view(game);r=shutter_rect(feed)
	check(r.has_area() and r.end.x<feed.toggle_rect.position.x and r.position.x<feed.size.x*0.5,"mirrored HUD places the shutter at the left of the header "+stamp)
	check(not r.intersects(feed.picture_rect) and not feed._buttons.any(func(b):return b.rect.intersects(r)),"mirrored shutter covers no picture or control "+stamp)
	Settings.current["mirrored_hud"]=mirrored
	game.queue_free();await settle()
