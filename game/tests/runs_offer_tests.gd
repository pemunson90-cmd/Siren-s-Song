extends SceneTree
# Sidecar determinism, additive legacy support, corrupt-field rejection and budgets.
const State=preload("res://src/campaign/runs/run_state.gd")
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const Archive=preload("res://src/campaign/runs/run_archive.gd")
const Run=preload("res://src/campaign/runs/expedition_run.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func result(state,outcome="won"):
	return {"op":State.current_operation(state),"outcome":outcome,"time":0.,"hull":100.,"tools":state.stock.duplicate(),"story":{}}
func win(state):return State.settle(State.launch(state),result(state))
func _initialize():
	var archive=Archive.new();archive.path="user://offer-test.runs"
	for seed in [0,1,42,12345,2147483647]:
		var old=win(State.new_run(seed))
		check(State.valid(old) and not old.has("offers"),"legacy recovery remains valid %d"%seed)
		var state=Offers.prepare(old)
		check(State.valid(state) and Offers.pending(state) and Offers.prepare(old)==state,"three deterministic optional offers %d"%seed)
		check(State.launch(state)==state,"cannot bypass pending choice")
		check(archive.save({"version":1,"run":state}) and archive.load_game().run==state,"pending offers survive checked disk reload")
		for id in state.offers.pending:
			var picked=Offers.choose(state,id)
			check(State.valid(picked) and not Offers.pending(picked) and picked.offers.picks.size()==1,"choice replay validates "+id)
			check(Offers.choose(picked,id)==picked,"pick grants exactly once")
			check(archive.save({"version":1,"run":picked}) and archive.load_game().run==picked,"picked sidecar reload grants nothing again")
			var sim=Run.new();check(sim.configure(picked),"picked state configures run")
			sim.start(-1)
			check(sim.mission.id==State.current_operation(picked) and sim.tools.emp==picked.stock.emp and sim.mission.field_tools.counts.hull_patch==picked.stock.hull_patch,"authored operation and promised starting counts applied")
			if id.begins_with("route:"):
				check(picked.stock.decoy==maxi(0,state.stock.decoy-1) and picked.stock.emp==mini(9,state.stock.emp+2),"route rider and reward exact")
			elif id=="refit":check(picked.stock.hull_patch==mini(9,state.stock.hull_patch+2),"refit is existing finite repair kits")
			else:check(picked.stock[id.get_slice(":",1)]==mini(9,state.stock[id.get_slice(":",1)]+2),"seeded boon finite charges exact")
			var completed=picked
			while completed.status=="active":
				completed=win(completed)
				check(State.valid(completed),"later outcome replays offers")
				if Offers.pending(completed):completed=Offers.choose(completed,completed.offers.pending[completed.cursor%3])
			check(completed.status=="won" and State.valid(completed) and not Offers.pending(completed),"complete mixed-choice run terminal and valid")
		var lost=State.settle(State.launch(state),result(state,"lost"))
		check(lost.status=="lost" and State.valid(lost) and not Offers.pending(lost),"existing Modes END RUN works at pending offers")
		for field in ["pending","picks","start","version"]:
			var bad=state.duplicate(true)
			bad.offers[field]={"fake":"charge"} if field in ["pending","picks"] else -1
			check(not State.valid(bad) and not archive.valid({"version":1,"run":bad}),"corrupt offer field rejected "+field)
		var corrupt=state.duplicate(true);corrupt.offers.pending[0]="route:999"
		check(not State.valid(corrupt),"unknown route rejected before use")
		corrupt=Offers.choose(state,state.offers.pending[0]);corrupt.stock.emp=9 if corrupt.stock.emp!=9 else 8
		check(not State.valid(corrupt),"unearned supply rejected")
		corrupt=state.duplicate(true);corrupt.offers.picks["1"]="boon:emp"
		check(not State.valid(corrupt),"undrawn pick rejected")
	# Migration may begin after several legacy stages, without rewriting history.
	var late=win(win(State.new_run(0)))
	if late.status=="active":check(State.valid(Offers.prepare(late)),"later legacy run adopts offers safely")
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(archive.path+suffix)
	print("RUNS OFFER CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
