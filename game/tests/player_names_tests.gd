extends SceneTree
# Player-facing run text must not show internal ids (snake_case) or codenames.
const State=preload("res://src/campaign/runs/run_state.gd")
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const Records=preload("res://src/campaign/runs/run_records.gd")
const Table=preload("res://src/campaign/runs/run_table.gd")
const Summary=preload("res://src/presentation/runs/run_summary_view.gd")
const Riders=preload("res://src/campaign/career/riders.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func leaks(text:String)->bool:
	var re=RegEx.new();re.compile("\b[a-z]+(_[a-z0-9]+)+\b")
	return re.search(text)!=null
func clean(text:String,label:String)->void:
	check(not leaks(text),"no internal id in "+label+": "+text)
	check(not text.contains("—"),"no em dash in "+label)
func completed(seed_value:int)->Dictionary:
	var state=State.new_run(seed_value)
	while state.status=="active":
		if Offers.pending(state):state=Offers.choose(state,state.offers.pending[0])
		var r={"op":State.current_operation(state),"outcome":"won","time":12.,"hull":90.,"tools":state.stock.duplicate(),"story":{},"photo":.91}
		state=Offers.prepare(State.settle(State.launch(state),r))
	return state
func _initialize():call_deferred("run")
func run():
	for op in Table.POOL:
		var m=Catalog.make(op,{})
		clean(str(m.title),"title op %d"%op)
		clean(str(m.brief),"brief op %d"%op)
	for key in Table.TOOLS:clean(Summary.Tools.spec(key).name,"tool "+key)
	for id in Riders.Table.ROWS.keys():
		var a={"id":id}
		clean(Riders.description(a,Riders.bonus_text(a)),"rider "+id)
	for s in 12:
		var row=Records.summary(completed(s+1))
		check(not row.is_empty(),"summary %d"%s)
		var st=State.new_run(s+1)
		while st.status=="active":
			if Offers.pending(st):
				for id in st.offers.pending:
					var d=Offers.describe(st,id);clean(d.title,"offer title");clean(d.detail,"offer detail")
				st=Offers.choose(st,st.offers.pending[0])
			st=Offers.prepare(State.settle(State.launch(st),{"op":State.current_operation(st),"outcome":"won","time":12.,"hull":90.,"tools":st.stock.duplicate(),"story":{},"photo":.91}))
		for line in Summary.lines(row):clean(line,"summary line seed %d"%s)
	print("PLAYER NAMES CHECKS %d FAILURES %d"%[checks,failures])
	quit(1 if failures>0 else 0)
