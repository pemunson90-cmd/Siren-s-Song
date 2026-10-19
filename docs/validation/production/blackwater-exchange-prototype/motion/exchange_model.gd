extends RefCounted
# Isolated authored relay hypothesis. No enemy state or rendering dependency.
const PERIOD=10.0
const WINDOW=4.0
const SAMPLE=2.0
const REPLAY=3.0
var variant="cycle"
var records=[false,false]
var replay_until=[-1.0,-1.0]
var site=-1
var unit=-1
var progress=0.0
func signal_open(id:int,time:float) -> bool:
	return variant=="direct" or fposmod(time-id*5.0,PERIOD)<WINDOW
func prediction(id:int,time:float) -> Dictionary:
	if not records[1-id]:return {"prediction":false}
	if variant=="direct":return {"prediction":true,"until_open":0.0,"continuous":true}
	var phase=fposmod(time-id*5.0,PERIOD)
	return {"prediction":true,"until_open":0.0 if phase<WINDOW else PERIOD-phase,"open_for":WINDOW-phase if phase<WINDOW else WINDOW}
func solicit(id:int,time:float,reachable:bool):
	if reachable and not records[id]:replay_until[id]=time+REPLAY
func eligible(id:int,time:float,sense:Dictionary) -> bool:
	return sense.alive and sense.clear and (sense.local or (sense.standoff and replay_until[id]>time))
func arm(id:int,station:int,time:float,sense:Dictionary) -> bool:
	if records[id] or not eligible(id,time,sense):return false
	site=id;unit=station;progress=0.0;return true
func cancel():site=-1;unit=-1;progress=0.0
func step(dt:float,time:float,sense:Dictionary) -> int:
	if site<0:return -1
	if not eligible(site,time,sense):cancel();return -1
	var available=(sense.local and signal_open(site,time)) or replay_until[site]>time
	if not sense.settled or not available:progress=0.0;return -1
	progress+=dt
	if progress+0.0000001<SAMPLE:return -1
	var done=site;records[done]=true;cancel();return done
func snapshot() -> Dictionary:
	return {"variant":variant,"records":records.duplicate(),"replay_until":replay_until.duplicate(),"site":site,"unit":unit,"progress":progress}
func restore(data:Dictionary) -> bool:
	if not data.has_all(["variant","records","replay_until","site","unit","progress"]):return false
	if data.records.size()!=2 or data.replay_until.size()!=2 or data.variant not in ["cycle","direct"]:return false
	variant=data.variant;records=data.records.duplicate();replay_until=data.replay_until.duplicate();site=int(data.site);unit=int(data.unit);progress=float(data.progress);return true
