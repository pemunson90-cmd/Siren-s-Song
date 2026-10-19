extends RefCounted
# Throwaway hypothesis only. Models engine emissions; never creates visual contacts.
const Sound=preload("res://src/simulation/acoustic_paths.gd")
const SENSITIVITY=2.0
var acoustics=Sound.new()
func configure(s):
 var shapes=s.rock_shapes.duplicate()
 for r in s.mission.get("structures",[]):shapes.append(PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]))
 acoustics.configure(shapes,s.BOUNDS)
func sample(s,index:int)->Dictionary:
 var u=s.units[index]
 if s.paused:return {"state":"PAUSED","bearings":[]}
 if not u.alive:return {"state":"LOST","bearings":[]}
 if u.vel.length()>=1 or not u.route.is_empty():return {"state":"MOVING · array unavailable","bearings":[]}
 var known=[];var unknown=[]
 for i in s.units.size():
  if i==index or not s.units[i].alive:continue
  var other=s.units[i]
  for arrival in acoustics.arrivals(u.pos,other.pos,Sound.motion_radius(other.vel.length())*SENSITIVITY):known.append(arrival)
 for n in s.noises:
  for arrival in acoustics.arrivals(u.pos,n.pos,n.radius*SENSITIVITY):
   if n.label=="FACTORY RESPONSE":unknown.append(arrival)
   else:known.append(arrival)
 for e in s.sirens:
  # Equal speed/signature law, no role, goal, intention, targeting or ID output.
  for arrival in acoustics.arrivals(u.pos,e.pos,Sound.motion_radius(e.vel.length())*SENSITIVITY):unknown.append(arrival)
 var bearings=[];var masked=false
 for arrival in unknown:
  var direction=u.pos.direction_to(arrival.points[1]);var blocked=false
  for own in known:
   if direction.dot(u.pos.direction_to(own.points[1]))>cos(deg_to_rad(20)) and own.strength>=arrival.strength:blocked=true
  if blocked:masked=true;continue
  var angle=roundf(rad_to_deg(direction.angle())/20)*20
  var observation={"bearing_degrees":angle,"spread_degrees":40 if not arrival.direct else 20,"time":s.elapsed}
  if not bearings.any(func(b):return b.bearing_degrees==angle):bearings.append(observation)
 return {"state":"UNCLASSIFIED ARRIVAL" if not bearings.is_empty() else "NO CLEAR ARRIVAL · threat unknown","bearings":bearings,"known_emissions_present":not known.is_empty()}
