extends RefCounted
# The words of an Expedition's set-up and stock, in one place so every screen states the same numbers:
# the seed screen, the briefing, the next-dive offer, the result and the run record.
# Presentation only: every number is read from the run state, the run table or the tool table.
const Names=preload("res://src/names.gd")
const State=preload("res://src/campaign/runs/run_state.gd")
const Table=preload("res://src/campaign/runs/run_table.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const KIT_LINE="Starting kit: %s loadout, %s."
const KIT_STANDARD="the standard kit"
const KIT_MORE="with more %s than the standard kit"
const HUNT_LINE="Hunt ceiling for this run: stage %d (%s). Each operation also caps how high the Hunt can start, so operation %d starts at stage %d (%s). The meter in the dive shows the current stage and rises as the Sirens notice you."
const STOCK_LINE="Stock: %s."
const STOCK_NONE="nothing"
const CHANGED_LINE="Since the dive: %s."
const CHANGED_REASON=" (recovery supplies and any rider bonus)"
const SPARE_LINE="In the depot, not in the racks for this dive: %s."
const SPENT_LINE="Spent: %s."
const EARNED_LINE="Earned: %s."
const KEPT_LINE="Kept: %s."
const NOTHING="nothing"
const LEDGER_TITLE="THIS DIVE"
# What a loadout adds to the standard kit, from the tool table: "with more EMP, Decoy than the standard kit".
static func kit_line(loadout:String)->String:
	var more:Array=[]
	for key in Table.TOOLS:
		if Tools.loadout_count(key,loadout)>Tools.loadout_count(key,Names.LOADOUT_ENDURANCE):more.append(Tools.spec(key).name)
	return KIT_LINE%[Tools.loadout_label(loadout),KIT_MORE%", ".join(more) if not more.is_empty() else KIT_STANDARD]
# The ceiling and where this operation starts, the same sentence on the seed screen and the briefing.
static func hunt_line(state:Dictionary)->String:
	var stage:int=State.starting_hunt(state,State.current_operation(state))
	return HUNT_LINE%[state.hunt_stage,Names.HUNT_STAGES[state.hunt_stage],int(state.cursor)+1,stage,Names.HUNT_STAGES[stage]]
# "3 EMP, 2 Survey" for the tools a count table holds, in the run table's order; zero rows are left out.
static func count_text(counts:Dictionary,signed:bool=false)->String:
	var parts:Array=[]
	for key in Table.TOOLS:
		var n:int=int(counts.get(key,0))
		if n>0:parts.append("%s%d %s"%["+" if signed else "",n,Tools.spec(key).name])
	return ", ".join(parts) if not parts.is_empty() else NOTHING
# What the next dive can draw on: every tool held (the racks may take fewer), then what the last recovery added.
static func stock_lines(state:Dictionary)->Array:
	var out=[STOCK_LINE%count_text(state.stock)]
	if not state.results.is_empty():
		var last:Dictionary=state.results.back().tools
		var added:Dictionary={}
		for key in Table.TOOLS:added[key]=maxi(0,int(state.stock[key])-int(last[key]))
		var text=count_text(added,true)
		if text!=NOTHING:out.append(CHANGED_LINE%(text+CHANGED_REASON))
	return out
# Tools held that the racks will not take on this dive, so the briefing and the stock never disagree without a word.
static func spare_line(stock:Dictionary,racks:Dictionary)->String:
	var spare:Dictionary={}
	for key in Table.TOOLS:spare[key]=maxi(0,int(stock.get(key,0))-Racks.total(racks,key))
	var text=count_text(spare)
	return SPARE_LINE%text if text!=NOTHING else ""
# The short block under a dive's result: what it spent, what it earned and what is kept. Each argument is a table of counts or a ready phrase.
static func difference(more:Dictionary,less:Dictionary)->Dictionary:
	var out:Dictionary={}
	for key in Table.TOOLS:out[key]=maxi(0,int(more.get(key,0))-int(less.get(key,0)))
	return out
# An Expedition dive: it started with `before`, ended with `after_dive` (the result's tools) and the run now holds `kept`.
static func dive_ledger(before:Dictionary,after_dive:Dictionary,kept:Dictionary)->Array:
	return ledger(count_text(difference(before,after_dive)),count_text(difference(kept,after_dive),true),count_text(kept))
static func ledger(spent:String,earned:String,kept:String)->Array:
	return [LEDGER_TITLE,SPENT_LINE%spent,EARNED_LINE%earned,KEPT_LINE%kept]
