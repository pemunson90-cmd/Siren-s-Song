extends RefCounted
# Sweeper role on V7 senses. A sweeper owns no sonar: it sees by proximity plus line of sight,
# hears throttle noise, pings and loud tools through the shared Siren loop, and attacks only
# through the normal lock then beam route. What differs from a patroller is a wider ear, a
# longer investigation and a slower walk. Quiet play, cover and decoys all beat it.
# Seam: simulation.gd asks this file for four numbers or answers (ear, attention, speed,
# stands_to_lock / walks_lane) and records note_heard. All tuning lives in PROFILES.
const WARNING:="SWEEPER INVESTIGATING"
const DEFAULT:={"ear":1.0,"attention":12.0,"patrol_speed":null,"investigate_speed":null,"stands":false,"lane_needs_points":false}
# Per-role tunables. A role absent here behaves exactly as before this file existed.
const PROFILES:={
	"patroller":{"stands":true},
	"sweeper":{"ear":1.3,"attention":20.0,"patrol_speed":22.0,"investigate_speed":34.0,"stands":true,"lane_needs_points":true},
}
static func profile(enemy)->Dictionary:
 var p:Dictionary=DEFAULT.duplicate()
 p.merge(PROFILES.get(enemy.get("type","patroller"),{}),true)
 return p
static func is_sweeper(enemy)->bool:
 return enemy.get("type","")=="sweeper"
# Hearing radius multiplier applied to every noise a Siren can hear.
static func ear(enemy)->float:
 return float(profile(enemy).ear)
# Seconds a Siren keeps searching after it last heard or saw Quietus.
static func attention(enemy)->float:
 return float(profile(enemy).attention)
# Walking speed override, or the caller's base speed when the role has none.
static func speed(enemy,base:float)->float:
 var p:=profile(enemy)
 var wanted=p.investigate_speed if enemy.suspicion>0.1 else p.patrol_speed
 return base if wanted==null else float(wanted)
# Stand, face and lock on sight instead of chasing.
static func stands_to_lock(enemy)->bool:
 return bool(profile(enemy).stands)
# Walk a patrol lane while idle. A sweeper walks only a lane its operation authored; otherwise
# it holds its post like other station roles, then returns to it after a search.
static func walks_lane(enemy)->bool:
 var type=enemy.get("type","patroller")
 if type=="patroller":return true
 return type=="sweeper" and not (profile(enemy).lane_needs_points and enemy.get("patrol_points",[]).is_empty())
# Remember the last heard spot. It is a stale report: it moves only when something new is heard.
static func note_heard(enemy,pos:Vector2,time:float)->void:
 if is_sweeper(enemy):enemy["listen"]={"pos":pos,"time":time}
# Optional save field: absent on every other role and on old saves. The retired sonar state
# (key "sweep") is the old shape and is rejected.
static func valid(enemy,time)->bool:
 if enemy.has("sweep"):return false
 if not enemy.has("listen"):return true
 var state=enemy.listen
 if not is_sweeper(enemy) or not state is Dictionary or not state.has_all(["pos","time"]) or state.size()!=2:return false
 if not state.pos is Vector2 or not state.pos.is_finite():return false
 var stamp=state.time
 return (stamp is float or stamp is int) and is_finite(float(stamp)) and stamp>=0 and stamp<=time+.001
