extends RefCounted
# Input is already received data, not a mission/source query. A match compares
# cadence only: a repeater can copy it and a bent arrival remains a bent arrival.
const REQUIRED=6.0
const QUALIFICATION="Cadence only; identity, range and passage safety remain unknown."
const STATE_KEYS=["version","dwell","last_time","anchor","status","arrivals","qualification","patterns","reference"]
const SAMPLE_KEYS=["receiver","origin","direction","time","uncertainty","cadence"]
static func _number(value)->bool:
 return (value is float or value is int) and is_finite(value)
static func valid_cadence(value)->bool:
 if not value is Array or value.size()<2 or value.size()>8:return false
 for interval in value:
  if not _number(interval) or interval<=0 or interval>10:return false
 return true
static func _sample(value,time:float)->bool:
 if not value is Dictionary or not value.has_all(SAMPLE_KEYS):return false
 if not value.receiver is int or value.receiver!=0:return false
 if not value.origin is Vector2 or not value.origin.is_finite() or not value.direction is Vector2 or not value.direction.is_finite():return false
 if absf(value.direction.length()-1.0)>0.001:return false
 if not _number(value.time) or value.time<0 or value.time>time or time-value.time>1.0:return false
 if not _number(value.uncertainty) or value.uncertainty<0 or value.uncertainty>PI:return false
 return valid_cadence(value.cadence)
static func _match(cadence:Array,reference:Array)->bool:
 if cadence.size()!=reference.size():return false
 for index in cadence.size():
  if absf(cadence[index]-reference[index])>0.08:return false
 return true
static func _patterns_match(patterns:Array,current:Array)->bool:
 if patterns.size()!=current.size():return false
 var used=[]
 for pattern in patterns:
  var matched=-1
  for index in current.size():
   if index not in used and _match(pattern.cadence,current[index].cadence) and pattern.direction.dot(current[index].direction)>=cos(0.12):
    matched=index;break
  if matched<0:return false
  used.append(matched)
 return true
static func _empty(position:Vector2,time:float)->Dictionary:
 return {"version":1,"dwell":0.0,"last_time":time,"anchor":position,"status":"unresolved","arrivals":[],"qualification":QUALIFICATION,"patterns":[],"reference":[]}
static func advance(previous:Dictionary,samples:Array,reference:Array,position:Vector2,speed:float,elapsed:float,dt:float,enabled:bool=true)->Dictionary:
 if not position.is_finite() or not is_finite(elapsed) or elapsed<0:return {}
 var result=_empty(position,elapsed)
 if not is_finite(speed) or speed<0 or not is_finite(dt) or dt<=0 or dt>0.25 or not enabled or speed>=12 or not valid_cadence(reference):return result
 if not previous.is_empty() and not valid_state(previous,elapsed):return result
 # Repeated paused calls cannot acquire a fresh result or integrate time.
 if not previous.is_empty() and elapsed==previous.last_time:return previous.duplicate(true)
 var current=[]
 for sample in samples:
  if _sample(sample,elapsed) and sample.origin.distance_to(position)<=8:
   var reading={}
   for key in SAMPLE_KEYS:reading[key]=sample[key].duplicate() if sample[key] is Array else sample[key]
   reading["classification"]="match" if _match(reading.cadence,reference) else "other"
   current.append(reading)
 if current.is_empty() or current.size()>8:return result
 result.patterns=current.map(func(reading):return {"cadence":reading.cadence.duplicate(),"direction":reading.direction})
 result.reference=reference.duplicate()
 if not previous.is_empty() and position.distance_to(previous.anchor)<=8 and elapsed-previous.last_time<=1.0 and previous.reference==reference and _patterns_match(previous.patterns,current):
  result.anchor=previous.anchor
  result.patterns=previous.patterns.duplicate(true)
  result.dwell=previous.dwell
  dt=minf(dt,elapsed-previous.last_time)
 result.dwell=minf(REQUIRED,result.dwell+dt)
 result.status="listening"
 if result.dwell+0.000001<REQUIRED:return result
 result.dwell=REQUIRED
 result.arrivals=current
 var matches=current.filter(func(reading):return reading.classification=="match")
 result.status="match" if matches.size()==1 else ("other" if matches.is_empty() else "unresolved")
 return result
static func valid_state(value,time:float)->bool:
 if not value is Dictionary:return false
 if value.is_empty():return true
 if not is_finite(time) or time<0 or not value.has_all(STATE_KEYS):return false
 if value.size()!=STATE_KEYS.size() or not value.version is int or value.version!=1 or not _number(value.dwell) or value.dwell<0 or value.dwell>REQUIRED:return false
 if not _number(value.last_time) or value.last_time<0 or value.last_time>time:return false
 if not value.anchor is Vector2 or not value.anchor.is_finite() or value.status not in ["unresolved","listening","match","other"] or value.qualification!=QUALIFICATION:return false
 if not value.arrivals is Array or value.arrivals.size()>8:return false
 if value.dwell<REQUIRED and not value.arrivals.is_empty():return false
 if value.status in ["match","other"] and (value.dwell<REQUIRED or value.arrivals.is_empty()):return false
 if not value.patterns is Array or value.patterns.size()>8 or not value.reference is Array:return false
 if value.dwell>0 and (value.patterns.is_empty() or not valid_cadence(value.reference)):return false
 if value.dwell==0 and (not value.patterns.is_empty() or not value.reference.is_empty()):return false
 for pattern in value.patterns:
  if not pattern is Dictionary or pattern.size()!=2 or not pattern.has_all(["cadence","direction"]) or not valid_cadence(pattern.cadence) or not pattern.direction is Vector2 or not pattern.direction.is_finite() or absf(pattern.direction.length()-1.0)>0.001:return false
 var matches=0
 for reading in value.arrivals:
  if not reading is Dictionary or reading.size()!=SAMPLE_KEYS.size()+1 or not _sample(reading,value.last_time) or reading.get("classification","") not in ["match","other"]:return false
  if reading.classification!=("match" if _match(reading.cadence,value.reference) else "other"):return false
  if reading.classification=="match":matches+=1
 if not value.arrivals.is_empty() and not _patterns_match(value.patterns,value.arrivals):return false
 return (value.status!="match" or matches==1) and (value.status!="other" or matches==0)
