extends RefCounted
# Isolated challenger budgets, in seconds for a 100-point supply at full work.
# Longer operations retain room for Quietus-only acquisition and withdrawal.
const OXYGEN_SECONDS=[180.0,300.0,180.0,180.0,240.0,300.0,300.0,300.0,300.0,300.0,300.0,840.0,420.0,360.0]
const DRONE_SECONDS=[180.0,240.0,150.0,180.0,180.0,240.0,240.0,240.0,240.0,240.0,240.0,600.0,300.0,300.0]
static func for_mission(id:int)->Dictionary:
 if id<0 or id>=OXYGEN_SECONDS.size():return {"oxygen_seconds":300.0,"drone_seconds":240.0}
 return {"oxygen_seconds":OXYGEN_SECONDS[id],"drone_seconds":DRONE_SECONDS[id]}
