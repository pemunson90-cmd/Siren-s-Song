extends RefCounted
# Threat placement builders. Each returns plain siren dictionaries in the shared
# patrol format, so every role keeps its existing simulation behaviour.
static func guard(type:String,pos:Vector2,band:int=1,points:Array=[],extra:Dictionary={})->Dictionary:
 var e={"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":0,"path_time":0.0,"type":type,"patrol_points":points.duplicate(),"patrol_index":0,"band":band}
 e.merge(extra,true);return e
static func add(m:Dictionary,list:Array)->void:
 for e in list:e.patrol=m.sirens.size();m.sirens.append(e)
# A listening line: passive buoys at the watched gaps, one relay behind them
# that can forward a stale report to whichever investigator it reaches.
static func listening_line(gaps:Array,relay:Vector2,band:int=1)->Array:
 var result=gaps.map(func(p):return guard("buoy",p,band))
 result.append(guard("relay",relay,band));return result
# A tethered post that returns to its water after an investigation.
static func post(pos:Vector2,band:int=1,tether:float=170.)->Dictionary:
 return guard("sentinel",pos,band,[pos,pos+Vector2(70,0),pos+Vector2(0,90)],{"tether":tether})
