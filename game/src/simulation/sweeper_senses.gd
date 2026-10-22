extends RefCounted
# Sweeper role on V7 senses. A sweeper owns no sonar: it sees by proximity plus line of sight,
# hears throttle noise, pings and loud tools through the shared Siren loop, and attacks only
# through the normal lock then beam route. What differs from a patroller is a wider ear, a
# longer investigation and a slower walk. Quiet play, cover and decoys all beat it.
const EAR:=1.3
const ATTENTION:=20.0
const BASE_ATTENTION:=12.0
const PATROL_SPEED:=22.0
const INVESTIGATE_SPEED:=34.0
const WARNING:="SWEEPER INVESTIGATING"
static func is_sweeper(enemy)->bool:
 return enemy.get("type","")=="sweeper"
# Roles that stand, face and lock when they see Quietus instead of chasing.
static func stands_to_lock(enemy)->bool:
 return enemy.get("type","patroller") in ["patroller","sweeper"]
# Roles that walk their patrol lane while idle. A sweeper walks only a lane its operation authored;
# otherwise it holds its post like other station roles, then returns to it after a search.
static func walks_lane(enemy)->bool:
 var type=enemy.get("type","patroller")
 return type=="patroller" or (type=="sweeper" and not enemy.get("patrol_points",[]).is_empty())
static func ear(enemy)->float:
 return EAR if is_sweeper(enemy) else 1.0
static func attention(enemy)->float:
 return ATTENTION if is_sweeper(enemy) else BASE_ATTENTION
static func speed(enemy,base:float)->float:
 if not is_sweeper(enemy):return base
 return INVESTIGATE_SPEED if enemy.suspicion>0.1 else PATROL_SPEED
# Remember the last heard spot. It is a stale report: it moves only when something new is heard.
static func note_heard(enemy,pos:Vector2,time:float)->void:
 if is_sweeper(enemy):enemy["listen"]={"pos":pos,"time":time}
static func valid(enemy,time)->bool:
 # The retired sonar state is the old save shape and is rejected.
 if enemy.has("sweep"):return false
 if not enemy.has("listen"):return true
 var state=enemy.listen
 if not is_sweeper(enemy) or not state is Dictionary or not state.has_all(["pos","time"]) or state.size()!=2:return false
 if not state.pos is Vector2 or not state.pos.is_finite():return false
 var stamp=state.time
 return (stamp is float or stamp is int) and is_finite(float(stamp)) and stamp>=0 and stamp<=time+.001
