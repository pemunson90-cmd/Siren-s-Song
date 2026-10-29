extends SceneTree
# New sidecar validation, deterministic outcome/resource math and campaign isolation.
const State=preload("res://src/campaign/runs/run_state.gd")
const Table=preload("res://src/campaign/runs/run_table.gd")
const Archive=preload("res://src/campaign/runs/run_archive.gd")
const Run=preload("res://src/campaign/runs/expedition_run.gd")
const Store=preload("res://src/persistence/save_store.gd")
class Host extends RefCounted:
	var store
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func result(state:Dictionary,outcome:String="won")->Dictionary:
	return {"op":State.current_operation(state),"outcome":outcome,"time":50.,"hull":95.,"tools":state.stock.duplicate(),"story":{}}
func _initialize():
	var initial=State.new_run(42)
	check(State.valid(initial) and initial==State.new_run(42),"same seed generates identical valid run")
	var lengths={};var modifiers={}
	for seed in 32:
		var state=State.new_run(seed)
		lengths[state.operations.size()]=true;modifiers[state.loadout+str(state.scarcity)]=true
		var unique={}
		for op in state.operations:unique[op]=true
		check(State.valid(state) and unique.size()==state.operations.size(),"seeded sequence distinct and valid %d"%seed)
	check(lengths.size()==4 and modifiers.size()>3,"seeds vary length and supply/loadout")
	var launched=State.launch(initial)
	check(launched.in_flight and not initial.in_flight,"launch copies state and marks pending loss")
	var win=result(launched);win.tools.decoy=maxi(0,win.tools.decoy-1)
	var recovered=State.settle(launched,win)
	var supply:String=Table.TOOLS[posmod(initial.seed,Table.TOOLS.size())]
	check(recovered.cursor==1 and recovered.story.recovered==[initial.operations[0]] and State.valid(recovered),"successful recovery advances isolated story")
	check(recovered.stock[supply]==mini(9,win.tools[supply]+Table.RESUPPLY[initial.scarcity]),"bounded scarcity-dependent resupply")
	check(State.settle(State.launch(recovered),win)==State.launch(recovered),"stale result cannot settle next operation")
	check(State.settle(recovered,result(recovered))==recovered,"unlaunched operation cannot settle")
	var lost=State.settle(State.launch(recovered),result(recovered,"lost"))
	check(lost.status=="lost" and State.valid(lost) and State.launch(lost)==lost,"loss terminal and valid")
	check(State.settle(lost,result(recovered))==lost,"terminal loss cannot gain recovery")
	var completed=initial.duplicate(true)
	while completed.status=="active":completed=State.settle(State.launch(completed),result(completed))
	check(completed.status=="won" and completed.cursor==completed.operations.size() and State.valid(completed),"all operations resolve a complete run")
	var corrupt=initial.duplicate(true);corrupt.stock.emp=99
	check(not State.valid(corrupt),"corrupt stock rejected")
	corrupt=initial.duplicate(true);corrupt.operations[0]=99
	check(not State.valid(corrupt),"seed-inconsistent operation rejected")
	corrupt=initial.duplicate(true);corrupt.hunt_stage=4
	check(not State.valid(corrupt),"seed-inconsistent Hunt rejected")
	var archive=Archive.new();archive.path="user://expedition-model-test.runs"
	check(archive.save({"version":1,"run":recovered}) and archive.load_game().run==recovered,"checked sidecar round trip")
	check(not archive.valid({"version":1,"run":corrupt}),"archive rejects corrupt run")
	check(not archive.valid({"version":true,"run":initial}),"archive rejects boolean version")
	var unavailable=Host.new();unavailable.store=Store.new();unavailable.store.path=""
	check(Archive.restore(unavailable).is_empty() and not Archive.persist(unavailable,initial),"empty profile path blocks archive reads and writes")
	unavailable.store.path="user://expedition-model-retired-profile";unavailable.store.suspended=true
	check(Archive.restore(unavailable).is_empty() and not Archive.persist(unavailable,initial),"retired profile blocks archive reads and writes")
	check(not FileAccess.file_exists(unavailable.store.path+".runs"),"retired profile cannot gain sidecar")
	var host=Host.new();host.store=Store.new();host.store.path="user://expedition-model-test-profile"
	var campaign_file=FileAccess.open(host.store.path,FileAccess.WRITE);campaign_file.store_string("campaign untouched");campaign_file.close()
	check(Archive.persist(host,launched),"pending dive persisted before launch")
	host.remove_meta("runs_archive_path")
	check(Archive.restore(host).status=="lost","reopening an interrupted dive ends the run")
	check(FileAccess.get_file_as_string(host.store.path)=="campaign untouched","sidecar writes leave campaign bytes unchanged")
	var blocked=Host.new();blocked.store=Store.new();blocked.store.path="user://expedition-model-blocked-profile"
	check(Archive.persist(blocked,launched),"interrupted-write fixture starts from committed dive")
	blocked.remove_meta("runs_archive_path")
	DirAccess.make_dir_absolute(blocked.store.path+".runs.tmp")
	check(Archive.restore(blocked).status=="lost" and blocked.get_meta("runs_archive_dirty",false),"failed loss write retains terminal state in memory")
	check(Archive.restore(blocked).status=="lost","cached restore never revives interrupted dive after failed write")
	DirAccess.remove_absolute(blocked.store.path+".runs.tmp")
	check(Archive.restore(blocked).status=="lost" and not blocked.get_meta("runs_archive_dirty",true),"next restore retries and commits pending loss")
	var damaged=Host.new();damaged.store=Store.new();damaged.store.path="user://expedition-model-corrupt-profile"
	var bad_file=FileAccess.open(damaged.store.path+".runs",FileAccess.WRITE);bad_file.store_string("broken run bytes");bad_file.close()
	check(Archive.restore(damaged).is_empty() and not Archive.persist(damaged,initial),"unreadable sidecar blocks starting over")
	check(FileAccess.get_file_as_string(damaged.store.path+".runs")=="broken run bytes","unreadable original retained")
	var sim=Run.new();check(sim.configure(initial),"preview configures without committing dive")
	sim.start(99)
	check(sim.mission.id==State.current_operation(initial) and sim.mission.run_seed==initial.seed and not sim.mission.fleet_commit,"simulation uses seeded operation and detached launch")
	check(sim.tools.emp==initial.stock.emp and sim.oxygen>=100.,"scarcity changes optional tools and preserves oxygen")
	check(sim.HuntPressure.view(sim).scale<=sim.HuntPressure.view(sim).cap,"initial Hunt obeys sight-only authored cap")
	check(State.settle(launched,sim.result()).status=="lost","unfinished/abandoned attempt settles as loss")
	for path in [archive.path,host.store.path,host.store.path+".runs",damaged.store.path+".runs",blocked.store.path+".runs"]:
		for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(path+suffix)
	print("EXPEDITION RUNS CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
