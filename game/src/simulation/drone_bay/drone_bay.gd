extends RefCounted
# WP-13: drones are launched from Quietus. They do not start on the map.
#
# [PAT, 2026-11-12] "drones are torpedo launched from the quietus. There should
# be no issues of throwing starting in any place cuz they do not start on the
# map." and "That was a core gameplay design even all the way back in the
# prototype". The v7 prototype created a drone at the submarine's position when
# the player launched it (prototype lines 231 to 234). The Godot game had
# placed both drones in the water at the start of every dive.
#
# [AI-DESIGNED] How it is built. A drone that is aboard uses the state the game
# already has for a craft that is not in the water (alive=false: nothing sees
# it, strikes it, hears it or draws it, and its battery does not drain), plus
# the key "aboard". Its position follows Quietus. The first route order given
# to it launches it beside Quietus, in Quietus's depth band, at rest. A drone
# that is still aboard at the end of a dive is home: it counts as recovered and
# never as lost.
#
# Pat's rulings for this first version (2026-11-12): launching adds no noise
# beyond the drone's own movement; two drones, no spares; recovery is unchanged
# (bring a launched drone to the recovery point).
#
# Seam: Simulation.start() stows the drones unless the launch dictionary says
# "drones_aboard":false (wanted() below; aboard is the default since code audit
# fix A5, 2026-11-12). Simulation.command() launches; Simulation._tick()
# carries. A test that needs drones in the water launches them with
# tests/fixtures/player_dive.gd; only a test of the older start passes false.
# Revert: set ENABLED=false (every dive starts with the drones in the water).
const ENABLED=true
const KEY="aboard"
const FLAG="drones_aboard"
# Metres from Quietus to the launch point. Inside the hull clearance on purpose:
# overlapping hulls separate without a strike (Simulation._hull_contacts).
const CLEARANCE=14.0
# Orders that put an aboard drone in the water.
const LAUNCH_ORDERS=["route","emergency"]
# Orders an aboard drone accepts without launching (they set how it will travel).
const PASS_ORDERS=["select","queue","waypoint_mode","silent","drone_drive"]

static func aboard(u:Dictionary)->bool:
 return bool(u.get(KEY,false))
# Destroyed or absent, as opposed to waiting in its tube.
static func lost(u:Dictionary)->bool:
 return not bool(u.get("alive",true)) and not aboard(u)
# In the water and working, or still aboard: not lost.
static func home(u:Dictionary)->bool:
 return not lost(u)
static func wanted(launch:Dictionary)->bool:
 return ENABLED and bool(launch.get(FLAG,true))
# Dive start: both drones go aboard.
static func stow(sim)->void:
 for id in [1,2]:
  var u=sim.units[id]
  u.alive=false;u[KEY]=true;u.vel=Vector2.ZERO;u.route=[]
 carry(sim)
# A craft that is not coming on this dive (challenge policy, an Ironman loss) is not aboard either.
static func leave_behind(u:Dictionary)->void:
 u.alive=false;u.erase(KEY)
# Aboard drones ride with Quietus.
static func carry(sim)->void:
 var q=sim.units[0]
 for id in [1,2]:
  var u=sim.units[id]
  if not aboard(u):continue
  u.pos=q.pos;u.vel=Vector2.ZERO;u.angle=q.angle
  if q.get("transition",{}).is_empty():u.band=q.get("band",1)
static func any_aboard(sim)->bool:
 return sim.units.size()==3 and (aboard(sim.units[1]) or aboard(sim.units[2]))
# Returns "" when the order may proceed (after a launch if it needed one), or
# the reason it may not. Called by Simulation.command() for an aboard drone.
static func before_order(sim,id:int,order:String)->String:
 var u=sim.units[id]
 if order in PASS_ORDERS:return ""
 if order not in LAUNCH_ORDERS:return "%s is aboard Quietus · tap water to deploy it"%u.name
 return launch(sim,id)
# Puts the drone in the water beside Quietus. Returns "" on success, else the reason.
static func launch(sim,id:int)->String:
 var u=sim.units[id];var q=sim.units[0]
 if not aboard(u):return ""
 if not q.alive or not sim.outcome.is_empty():return "%s cannot deploy"%u.name
 if not q.get("transition",{}).is_empty():return "%s cannot deploy while Quietus changes depth"%u.name
 var forward=Vector2.from_angle(float(q.angle))
 var at:Vector2=q.pos
 for turn in [0.,PI/4,-PI/4,PI/2,-PI/2,PI*.75,-PI*.75,PI]:
  var p:Vector2=q.pos+forward.rotated(turn)*CLEARANCE
  if not sim.blocked(p,12.) and sim.line_clear(q.pos,p):at=p;break
 u.erase(KEY);u.alive=true
 u.pos=at;u.vel=Vector2.ZERO;u.angle=q.angle;u.band=q.get("band",1);u.transition={};u.route=[];u.hold=""
 sim.events.append({"type":"drone_launch","unit":id,"pos":at})
 return ""
# Label for fleet buttons and manifests.
static func label(u:Dictionary)->String:
 return "ABOARD" if aboard(u) else ""
# Saved dives: the key is a bool, only on a drone that is not in the water.
static func valid(units:Array)->bool:
 for id in units.size():
  var u=units[id]
  if not u is Dictionary or not u.has(KEY):continue
  if not u[KEY] is bool:return false
  if u[KEY] and (id==0 or bool(u.get("alive",true))):return false
 return true
