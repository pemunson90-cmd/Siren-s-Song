extends SceneTree
const Shuffle=preload("res://src/campaign/runs/seeded_siren_patrol.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Run=preload("res://src/campaign/runs/expedition_run.gd")
const State=preload("res://src/campaign/runs/run_state.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
	var changed={}
	for op in 6:
		var authored=Sim.new();authored.start(op)
		var authored_start=authored.sirens.duplicate(true)
		for seed in [0,42,777,2147483647]:
			var a=Sim.new();a.start(op);Shuffle.apply(a,seed)
			var b=Sim.new();b.start(op);Shuffle.apply(b,seed)
			check(a.sirens==b.sirens,"same seed and op replay %d/%d"%[op,seed])
			for i in a.sirens.size():
				var s=a.sirens[i];var original=authored.sirens[i]
				check(s.home==original.home and s.patrol_points==original.patrol_points and s.type==original.type and s.band==original.band,"authored identity and circuit retained")
				check(a.Depth.clear(a,s.pos,s.pos,s.band,24.),"clear seeded start")
				for unit in a.units:check(s.pos.distance_to(unit.pos)>=Shuffle.LAUNCH_CLEARANCE,"launch has no seeded close contact")
				if s.pos!=original.pos:changed[op]=true
			check(Sim.valid_snapshot(a.snapshot()),"seeded snapshot valid")
			var restored=Sim.new();check(restored.restore(a.snapshot()),"seeded snapshot restores")
			a.paused=false;restored.paused=false
			for tick in 8:a.advance(.1);restored.advance(.1)
			check(a.sirens==restored.sirens,"resume retains patrol phase without reshuffle")
			check(authored.sirens==authored_start,"ordinary simulation remains authored")
	check(changed.size()==6,"all expedition operations gain seeded starts")
	var state=State.new_run(42);var run=Run.new();check(run.configure(state),"run configures")
	run.start(-1)
	var expected=Sim.new();expected.start(State.current_operation(state),state.loadout,{"context":State.context(state)})
	Shuffle.apply(expected,state.seed)
	check(run.sirens==expected.sirens,"ordinary Expedition start invokes shuffle")
	for id in run.contacts:check(run.contacts[id].pos==run.sirens[id].pos,"launch observation uses seeded position")
	var preview=run.sirens.duplicate(true);run.start(-1)
	check(run.sirens==preview,"preview and launch rebuild same phase")
	var authored_pool=Sim.new();authored_pool.start(State.current_operation(state))
	run.start_dev(State.current_operation(state),"endurance",{})
	check(run.sirens==authored_pool.sirens,"DEV bypass retains authored pool starts")
	var dev=Sim.new();dev.start(30)
	run.start_dev(30,"endurance",{})
	check(run.sirens==dev.sirens,"DEV bypass retains authored non-pool starts")
	var control=dev.sirens.duplicate(true);Shuffle.apply(dev,42)
	check(dev.sirens==control,"shuffle ignores operations outside Expedition pool")
	print("SEEDED SIREN PATROL CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
