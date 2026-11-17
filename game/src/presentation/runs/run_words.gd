extends RefCounted
# The words of an Expedition's set-up and stock, in one place so every screen states the same numbers:
# the seed screen, the briefing, the next-dive offer, the result and the run record.
# Presentation only: every number is read from the run state, the run table or the tool table.
const Names=preload("res://src/names.gd")
const State=preload("res://src/campaign/runs/run_state.gd")
const Table=preload("res://src/campaign/runs/run_table.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const ResultText=preload("res://src/presentation/mode_result_text.gd")
const KIT_LINE="Starting kit: %s loadout, %s."
const KIT_STANDARD="the standard kit"
const KIT_MORE="with more %s than the standard kit"
# The kit is the loadout at full stock; the run's scarcity then takes a fixed number from every tool, and the scarcity line gives the result.
const KIT_SCARCITY=" This run is %s: it starts with %d fewer of each tool than the full kit."
const HUNT_LINE="Hunt ceiling for this run: stage %d (%s). Each operation also caps how high the Hunt can start, so operation %d starts at stage %d (%s). The meter in the dive shows the current stage and rises as the Sirens notice you."
const STOCK_LINE="Stock: %s."
const STOCK_NONE="nothing"
const CHANGED_LINE="Since the dive: %s."
const CHANGED_REASON=" (recovery supplies and any rider bonus)"
const SPARE_LINE="In the depot, not in the racks for this dive: %s."
const SPENT_LINE="Spent: %s."
const EARNED_LINE="Earned: %s."
const KEPT_LINE="Kept: %s."
const RECOVERED_RECORD="archive recovered (%s)"
const NOTHING="nothing"
const LEDGER_TITLE="THIS DIVE"
# WP-109: a Naval Career dive launches with a full kit every time (Career.launch), so what it used is not a cost carried forward.
const USED_REFILL_LINE="Used: %s. Field tools refill at the next launch."
# What a loadout adds to the standard kit, from the tool table: "with more EMP, Decoy than the standard kit".
static func kit_line(loadout:String,scarcity:int=0)->String:
	var more:Array=[]
	for key in Table.TOOLS:
		if Tools.loadout_count(key,loadout)>Tools.loadout_count(key,Names.LOADOUT_ENDURANCE):more.append(Tools.spec(key).name)
	var line:String=KIT_LINE%[Tools.loadout_label(loadout),KIT_MORE%", ".join(more) if not more.is_empty() else KIT_STANDARD]
	return line+KIT_SCARCITY%[Table.SCARCITY[scarcity],scarcity] if scarcity>0 else line
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
static func dive_ledger(before:Dictionary,after_dive:Dictionary,kept:Dictionary,recovered:String="",photo:float=-1.,lost:Array=[])->Array:
	return ledger(count_text(difference(before,after_dive)),earned_text(count_text(difference(kept,after_dive),true),recovered,photo),count_text(kept),lost) # WP-119: lost craft sit under what was spent
# What a dive earned: the archive it recovered and its photograph grade (when it recovered one), then the supplies it added.
static func earned_text(supplies:String,recovered:String="",photo:float=-1.)->String:
	var parts:Array=[]
	if not recovered.is_empty():parts.append(RECOVERED_RECORD%recovered)
	if not recovered.is_empty() and photo>=0.:parts.append(ResultText.photo_word(photo))
	if supplies!=NOTHING:parts.append(supplies)
	return ", ".join(parts) if not parts.is_empty() else NOTHING
static func ledger(spent:String,earned:String,kept:String,lost:Array=[])->Array:
	return [LEDGER_TITLE,SPENT_LINE%spent]+lost+[EARNED_LINE%earned,KEPT_LINE%kept]

static func career_ledger(used:String,earned:String,kept:String,lost:Array=[])->Array:
	return [LEDGER_TITLE,USED_REFILL_LINE%used]+lost+[EARNED_LINE%earned,KEPT_LINE%kept]
# WP-119: the craft a dive lost and why, one line each, from ThreatRead.dive_losses (the cause the dive already knew).
const LOST_LINE="Lost: %s%s."
const LOST_BEAM=", to a Siren beam from %03d°%s"
const LOST_LABEL=" (%s)"
const LOST_BATTERY=", its battery ran flat"
# WP-119: the run ended because the player chose END DIVE · LOSE RUN, not because the dive was lost.
const ABANDONED_LINE="You ended the dive with END DIVE · LOSE RUN, so the run is lost."
static func lost_cause(row:Dictionary)->String:
	if float(row.bearing)>=0.:return LOST_BEAM%[roundi(float(row.bearing))%360,LOST_LABEL%row.label if not str(row.label).is_empty() else ""]
	return LOST_BATTERY if bool(row.battery) else ""
static func lost_lines(losses:Array)->Array:
	var out:Array=[]
	for row in losses:out.append(LOST_LINE%[str(row.name).capitalize(),lost_cause(row)])
	return out
# WP-119: the Campaign result's block. Every amount is what the economy applied (Economy.settle's income, the launch's actual charge, the balance now).
const CAMPAIGN_TITLE="THIS DIVE · EARNED AND SPENT"
const CAMPAIGN_SPENT="Spent: %s on the launch."
const CAMPAIGN_SPENT_FREE="Spent: nothing (the launch was free)."
const CAMPAIGN_BALANCE="Balance now: %s."
const DRONE_RECORDED=" Its battery is recorded at %d%%; repair in SUPPLIES costs %s."
const DRONE_RECORDED_FREE=" Its battery is recorded at %d%%."
const DRONE_RESTORED=" The difficulty restores it for the next dive."
const DRONE_GONE=" It is gone for good; a replacement in SUPPLIES costs %s."