extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Gear=preload("res://src/equipment/equipment_catalog.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
	var s=Sim.new();s.start(0,"endurance");s.sirens=[]
	s.mission.launch_equipment=Gear.canonical({"quietus":"photo_flash"})
	var o=s.mission.objectives[0];var u=s.units[0]
	u.pos=o.pos+Vector2(110,0);u.angle=PI;u.vel=Vector2.ZERO
	Photo.set_frame(s,0,{"flash":true});Photo.state(s).flash[0]=1
	var ephemeral={"pos":o.pos,"subject":Photo.default_subject()}
	check(Photo.frame(s,0,ephemeral).flash,"uncatalogued viewfinder subject previews an available flash")
	var preview=Photo.frame(s,0,o)
	s.captures[0]={"target":0,"elapsed":0.0}
	Photo.begin(s,0,0)
	var exposure=Photo.frame(s,0,o)
	check(Photo.flash_left(s,0)==0 and exposure.flash,"last paid flash remains active during exposure")
	check(is_equal_approx(exposure.light,preview.light),"last-charge preview and exposure receive the same light")
	check(Photo.noise_radius(s,0)>=760.,"paid flash keeps its existing noise cost")
	var copy=Sim.new();copy.restore(s.snapshot())
	check(Photo.frame(copy,0,copy.mission.objectives[0]).flash,"committed last flash survives restore")
	check(s.command("route",{"point":u.pos+Vector2(40,0)}),"ordinary route command cancels the exposure")
	check(not Photo.frame(s,0,o).flash,"cancelled last-charge exposure cannot keep lighting the viewfinder")
	Photo.begin(s,0,0)
	check(not Photo.frame(s,0,o).flash,"next exposure cannot reuse the spent flash")
	var v=Sim.new();v.start(0);v.sirens=[];v.units[1].alive=false;v.units[2].alive=false
	var subject=v.mission.objectives[0]
	v.units[0].pos=Vector2(971.1075,419.7071)
	v.units[0].angle=v.units[0].pos.angle_to_point(subject.pos)
	check(not v.line_clear(v.units[0].pos,subject.pos),"fixture uses actual terrain occlusion")
	check(Photo.preview(v,0).is_empty(),"viewfinder cannot reveal a subject through cover")
	v.units[0].pos=subject.pos+Vector2.from_angle(2.74)*110.;v.units[0].angle=2.74
	check(Photo.stage(subject)=="lead" and Photo.preview(v,0).is_empty(),"lead outside the forward camera cannot expose its shape or features")
	v.units[0].angle=2.74+PI
	check(not Photo.preview(v,0).is_empty(),"live optical sight works before the next discovery tick without changing mission state")
	Photo.discover(v)
	check(Photo.stage(subject)=="sighted" and not Photo.preview(v,0).is_empty(),"legitimate forward-camera discovery enables the viewfinder")
	v.units[0].pos=Vector2(971.1075,419.7071)
	check(Photo.preview(v,0).is_empty(),"previous discovery does not permit later through-cover preview")
	var nine=Sim.new();nine.start(15)
	check(nine.sirens.size()==9,"Needle Strait supplies nine distinct subjects")
	var first=Photo.siren_objective(nine,0)
	for i in range(1,9):Photo.siren_objective(nine,i)
	check(Photo.obj(nine,first).siren==0,"ninth study preserves the first subject identity")
	check(Photo.peek(nine).studies.size()==9 and Photo.valid(nine.mission),"all authored subjects fit a valid bounded study collection")
	check(Photo.siren_objective(nine,0)==first,"returning to an earlier Siren reuses its stable study")
	for op in [6,7,8,9,10,22,23,24,25,26,27,28,29]:
		var late=Sim.new();late.start(op)
		late.units[0].pos=late.sirens[0].pos;late.units[0].band=late.sirens[0].band
		late._use_band(late.units[0].band);late._observe()
		check(Photo.siren_candidate(late,0)==0,"op%d fixture has a genuinely observed same-band subject"%op)
		var ctx=late.camera_context()
		check(ctx.get("target",-1)==-2 and ctx.ready and late.command("camera"),"op%d permits a Siren study when no ordinary camera job is ready"%op)
	var powered=Sim.new();powered.start(10)
	powered.units[0].pos=powered.sirens[0].pos;powered.units[0].band=powered.sirens[0].band
	powered._use_band(powered.units[0].band);powered._observe()
	powered.mission.warning_chain.power="umbilical";powered.mission.warning_chain.unit=0
	check(not powered.camera_context().ready and not powered.command("camera"),"optional Siren study cannot displace a connected plant supply")
	print("AUDIT PHOTO INTEGRITY CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
