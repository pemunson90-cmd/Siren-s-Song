extends SceneTree
# PHOTO2 blocker: a Siren study is film, not a charted objective. Photographing a
# Siren in any operation with fixed-size objective checks leaves the save valid.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Recon=preload("res://src/simulation/recon_consequences.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func run(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
func _initialize():
	var store=Store.new();store.path="user://photo-study.save"
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
	# Operations with fixed objective counts: 2 Blackwater (2), 4 Well (3), 10 warning chain (3), plus open ones.
	for id in [0,1,2,3,4,5,10]:
		var s=Sim.new();s.start(id,"endurance");s.units[1].alive=false;s.units[2].alive=false
		var before=s.mission.objectives.size()
		var baseline=store.valid({"version":Store.VERSION,"unlocked":5,"completed":[],"settings":{},"upgrade":"endurance","active":s.snapshot()})
		if s.sirens.is_empty():check(false,"op %d has a Siren to study"%id);continue
		var guard=s.sirens[0];guard.stun=100.0;guard.angle=0.0
		var at=Vector2(guard.pos.x+110,guard.pos.y)
		s.units[0].pos=at;s.units[0].angle=PI;s.units[0].vel=Vector2.ZERO
		s.paused=false;run(s,0.4)
		var ctx=s.camera_context()
		if not (ctx.get("target",-1)==-2 and ctx.ready):
			# Another subject is nearer; the Siren is still studied through the study path.
			ctx={"target":-2,"siren":0,"ready":true}
		var index=Photo.siren_objective(s,0)
		check(index>=Photo.STUDY and s.mission.objectives.size()==before,"op %d: a Siren study is not appended to the objective list"%id)
		s.captures[0]={"target":index,"elapsed":0.0};s.units[0].hold="HOLD"
		Photo.begin(s,0,index)
		run(s,9.5)
		check(s.mission.photo.studies.size()==1 and s.mission.objectives.size()==before,"op %d: studies live in photo.studies, objectives unchanged"%id)
		var data={"version":Store.VERSION,"unlocked":5,"completed":[],"settings":{},"upgrade":"endurance","active":s.snapshot()}
		check(Sim.valid_snapshot(s.snapshot()),"op %d: snapshot with a Siren study is valid"%id)
		check(store.valid(data)==baseline,"op %d: a Siren study never turns a valid save invalid"%id)
		check(s.units[0].alive,"op %d: still running after the exposure"%id)
		var copy=Sim.new()
		check(copy.restore(s.snapshot()) and copy.mission.photo.studies.size()==1,"op %d: restore keeps the study"%id)
		copy.free() if copy is Node else null
	# A save mid-exposure on a Siren is valid too.
	var m=Sim.new();m.start(2,"endurance");m.units[1].alive=false;m.units[2].alive=false
	m.sirens[0].stun=100.0;m.units[0].pos=m.sirens[0].pos+Vector2(110,0);m.units[0].angle=PI
	var idx=Photo.siren_objective(m,0);m.captures[0]={"target":idx,"elapsed":2.0};m.units[0].hold="HOLD";Photo.begin(m,0,idx)
	check(Sim.valid_snapshot(m.snapshot()),"a snapshot mid Siren exposure is valid")
	var bad=m.snapshot();bad.captures[0].target=Photo.STUDY+5
	check(not Sim.valid_snapshot(bad),"a capture pointing at a missing study is rejected")
	# Dive grade states what it averages and never undercuts the best frame silently.
	var grade=Recon.grade([{"photo_quality":0.67},{"photo_quality":0.23}])
	check(is_equal_approx(grade.quality,0.45) and is_equal_approx(grade.best,0.67),"grade reports the mean and the sharpest record separately")
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
	print("PHOTO STUDY SAVE CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
