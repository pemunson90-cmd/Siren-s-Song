extends RefCounted
# Only a new, receiver-owned event may make sound. Historical observations are
# displayed by the instruments, never polled into repeat audio on load/pause.
var heard:Dictionary={}
var last_time=-1.
func observe_clock(time:float)->void:
 if time<last_time:heard.clear()
 last_time=time
func take(event:Dictionary,selected:int,time:float,running:bool)->Dictionary:
 observe_clock(time)
 if not running or event.get("type","") not in ["carrier_received","return_received","sweep_received"]:return {}
 if event.get("receiver",-1)!=selected or not event.get("direction",null) is Vector2:return {}
 var at=event.get("time",-100.)
 if not (at is float or at is int) or not is_finite(at) or at>time or time-at>.25:return {}
 var direction:Vector2=event.direction
 if not direction.is_finite() or direction.length()>1.001:return {}
 var cue=event.type;var key="%d/%s"%[selected,cue]
 if at-float(heard.get(key,-100.))<5.:return {}
 heard[key]=at
 return {"cue":cue,"relative":Vector2(direction.x*550.,0)}
