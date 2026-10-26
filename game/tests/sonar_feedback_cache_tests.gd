extends SceneTree
# PERF fix 2 equivalence: AdvancedSonar.feedback() now caches its filtered rows per sim tick.
# The old straightforward implementation (row.duplicate per call) is the oracle below.
# Timing is printed, never asserted.
const Sim=preload("res://src/simulation/simulation.gd")
const Sonar=preload("res://src/simulation/advanced_sonar.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
static func oracle(sim,station:int)->Dictionary:
	var rows=[]
	for row in sim.sonar.history:
		if row.station==station and sim.elapsed-row.time<=20:rows.append(row.duplicate())
	return {"rows":rows,"own_noise":sim.motion_radius(station),"sector":sim.sonar.sector,"power":sim.sonar.power,"listening":maxf(0.,sim.sonar.listening_until[station]-sim.elapsed)}
func same(sim,label:String)->int:
	var bad=0
	for station in 3:
		for repeat in 2:
			if var_to_str(Sonar.feedback(sim,station))!=var_to_str(oracle(sim,station)):bad+=1;printerr("MISMATCH ",label," station ",station)
	return bad
func fixture(op:int):
	var s=Sim.new();s.start(op);s.paused=false
	return s
func _initialize():call_deferred("run")
func run():
	var rng=RandomNumberGenerator.new();rng.seed=77
	var total_bad=0;var ticks=0;var rows_seen=0
	for op in [0,6,16,19]:
		var s=fixture(op)
		s.sonar.power="high"
		for n in 1500:
			if n%120==0:
				s.units[0].vel=Vector2(rng.randf_range(-100,100),rng.randf_range(-100,100))
				if n%240==0:s.sonar.power="high" if s.sonar.power=="low" else "low"
				if n%360==0:s.sonar.sector="forward" if s.sonar.sector=="all" else "all"
				s.selected=rng.randi_range(0,2)
			s.advance(1./60);ticks+=1
			total_bad+=same(s,"op %d tick %d"%[op,n])
			rows_seen+=s.sonar.history.size()
		# Direct surgery of the history between calls at the same sim time.
		var before=Sonar.feedback(s,0)
		if not s.sonar.history.is_empty():
			var extra=s.sonar.history.back().duplicate();extra.station=0;extra.time=s.elapsed
			s.sonar.history.append(extra)
			total_bad+=same(s,"op %d appended directly"%op)
			s.sonar.history.pop_front();total_bad+=same(s,"op %d popped directly"%op)
			s.sonar.history=s.sonar.history.duplicate(true);total_bad+=same(s,"op %d history array replaced"%op)
			s.sonar.history.clear();total_bad+=same(s,"op %d history cleared"%op)
		var copy=Sim.new()
		check(copy.restore(s.snapshot()),"op %d snapshot restores"%op)
		var sa=copy.snapshot().sonar.keys();var sb=Sonar.initial().keys();sa.sort();sb.sort()
		check(sa==sb,"op %d snapshot shape unchanged by cache (no new save field)"%op)
		total_bad+=same(copy,"op %d restored copy"%op)
		total_bad+=same(s,"op %d original after restored copy"%op)
		s.elapsed+=0.001;total_bad+=same(s,"op %d elapsed bump"%op)
	check(total_bad==0,"feedback byte-identical to old implementation on %d ticks x 3 stations x 2 calls (%d total history rows seen)"%[ticks,rows_seen])
	check(rows_seen>0,"history was actually exercised")
	# Callers may mutate the returned container without poisoning the cache.
	var s2=fixture(19);for n in 300:s2.advance(1./60)
	var a=Sonar.feedback(s2,0);a.rows.clear();a["power"]="x"
	check(var_to_str(Sonar.feedback(s2,0))==var_to_str(oracle(s2,0)),"mutating a returned dictionary does not alter later results")
	# Timing: three reads per frame over a full 72 row history.
	var s3=fixture(19);s3.sonar.history.clear()
	for i in 72:s3.sonar.history.append({"station":0,"enemy":0,"origin":Vector2.ZERO,"direction":Vector2.RIGHT,"time":s3.elapsed-i*0.1,"band":-1,"confidence":0.5,"tone":100.0,"classification":"MACHINERY","direct":true,"kind":"bearing"})
	var at=Time.get_ticks_usec()
	for f in 600:
		s3.elapsed+=1./60
		for k in 4:oracle(s3,0)
	var t_old=Time.get_ticks_usec()-at
	at=Time.get_ticks_usec()
	for f in 600:
		s3.elapsed+=1./60
		for k in 4:Sonar.feedback(s3,0)
	var t_new=Time.get_ticks_usec()-at
	print("TIMING feedback 4 reads/frame, 72 rows: old=%.1f us/frame new=%.1f us/frame (%.2fx)"%[t_old/600.0,t_new/600.0,float(t_old)/maxf(1.0,t_new)])
	print("SONAR FEEDBACK CACHE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
