extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Findings=preload("res://src/simulation/photo_findings.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func shot(path:Array)->Dictionary:
	return {"siren":0,"type":"sentinel","op":3,"id":1,"path":path}
func _initialize():
	var s=Sim.new();s.start(3);Photo.state(s)
	var observed=shot([[700.,500.],[725.,500.],[750.,500.]])
	var a=Findings.from_siren(s,observed,["gait","array"],{"gait":0.8,"array":0.8})
	s.mission.photo.findings=[]
	s.sirens[0].patrol_points=[Vector2(30,30),Vector2(1500,30),Vector2(1500,900)]
	s.sirens[0].home=Vector2(1234,789);s.sirens[0].tether=800.
	var b=Findings.from_siren(s,observed,["gait","array"],{"gait":0.8,"array":0.8})
	check(a==b,"identical film produces identical findings despite unseen patrol, home and tether changes")
	check(a.any(func(f):return f.kind=="loop" and f.pts==observed.path and not f.text.contains("PATROL LOOP")),"partial observation marks only its observed path")
	var post=a.filter(func(f):return f.kind=="post")
	check(post.size()==1 and (not post[0].has("r") or post[0].r==0.),"array observation never invents an exact tether radius")
	s.mission.photo.findings=[]
	var closed=shot([[700.,500.],[800.,500.],[800.,600.],[700.,600.],[700.,500.]])
	var loop=Findings.from_siren(s,closed,["gait"],{"gait":0.8})
	check(loop.any(func(f):return f.kind=="loop" and f.text.contains("PATROL LOOP") and f.pts==closed.path),"a genuinely recorded closed circuit can earn a loop clock")
	s.mission.photo.findings=[]
	var stationary=shot([[700.,500.],[700.,500.],[700.,500.],[700.,500.]])
	var still=Findings.from_siren(s,stationary,["gait"],{"gait":0.8})
	check(not still.any(func(f):return f.text.contains("PATROL LOOP")),"stationary samples are never an observed circuit")
	s.mission.photo.findings=[]
	var repeated=shot([[700.,500.],[700.,500.],[800.,500.],[800.,600.],[700.,600.],[700.,500.]])
	check(Findings.from_siren(s,repeated,["gait"],{"gait":0.8}).any(func(f):return f.text.contains("PATROL LOOP")),"duplicate initial samples do not hide a genuinely observed circuit")
	# A gap cannot consult unmeasured world geometry behind the same observed routes.
	var paths=[Findings.make("loop_0","loop","S1 PATROL LOOP",0.8,3,1,{"pts":closed.path}),Findings.make("loop_1","loop","S2 PATROL LOOP",0.8,3,2,{"pts":[[1100.,500.],[1200.,500.],[1200.,600.],[1100.,600.],[1100.,500.]]})]
	s.mission.photo.findings=paths.duplicate(true);s.known={};s.depth_charts={}
	check(Findings._gap(s,0).is_empty(),"unmeasured gap water is not certified from hidden terrain")
	print("AUDIT FINDINGS PROVENANCE CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
