extends RefCounted
# 102 provisional tuning.
# Custody is read from existing physical state; this creates no carry ability.
const ONE_SECONDS=8.0
const MANY_SECONDS=12.0
const SETTLE_SECONDS=6.0
static func duration_for_count(count:int)->float:
 return MANY_SECONDS if count>=2 else ONE_SECONDS if count==1 else 0.0
static func count(mission:Dictionary,unit:int)->int:
 var result=0
 var pod=mission.get("witness_evacuation",{})
 # resolution_missions.gd witness_packet evidence says "sailors alive inside".
 # Class 2 means multiple occupants, not an exact headcount. Sorley is one boy.
 if pod.get("state","")=="carried" and pod.get("carrier",-1)==unit:result+=2 if mission.get("id")==12 else 1
 var load=mission.get("iron_choir",{}).get("load",{})
 # Plural occupied loads use the >=2 class, not a claim about exact headcount.
 # Existing towing prohibits depth changes and remains unchanged.
 if load.get("state","")=="towed" and load.get("carrier",-1)==unit and mission.get("id") in [25,28]:result+=2
 return result
static func line(mission:Dictionary,unit:int,body:Dictionary,compact:bool=false)->String:
 if count(mission,unit)<=0:return ""
 var load=mission.get("iron_choir",{}).get("load",{})
 if load.get("state","")=="towed" and load.get("carrier",-1)==unit and mission.get("id") in [25,28]:return "TOW / DEPTH FIXED" if compact else "Occupied tow: release before changing depth"
 var transition=body.get("transition",{})
 if transition.get("carried_ascent",false):return ("SURVIVOR ASCENT %.1fs" if compact else "Survivor ascent %.1fs / exposed in BOTH bands")%transition.remaining
 var settle=body.get("ascent_settle",0.0)
 if settle>0:return ("SETTLE %.1fs" if compact else "Survivors / settle %.1fs before next ascent")%settle
 return ("ASCENT %.0fs / SETTLE %.0fs" if compact else "Survivors / ascent %.0fs / settle %.0fs")%[duration_for_count(count(mission,unit)),SETTLE_SECONDS]
static func briefing(mission:Dictionary)->String:
 if mission.get("id") in [12,41]:return "Carried survivors need a slow ascent and six seconds at the new band before rising again; plan the return depth."
 if mission.get("id") in [25,28]:return "Occupied tows stay at their current depth; release before any depth change."
 return ""
