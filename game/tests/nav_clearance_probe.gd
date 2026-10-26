extends SceneTree
# Source-known diagnostic: independently measures planned line/terrain distances.
# No gameplay outcome or balance conclusions; --sweep expands the sampled endpoints.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
const Measure=preload("res://tests/nav_clearance_measure.gd")
func _initialize():
 var sweep="--sweep" in OS.get_cmdline_user_args()
 var corners="--corners" in OS.get_cmdline_user_args()
 for operation in [0,1,3,4,5]:
  var s=Sim.new();s.start(operation);var origin=s.units[0].pos
  var endpoints=[s.mission.extraction]
  for target in s.mission.objectives:
   endpoints.append(target.pos+Vector2(0,210));endpoints.append(target.pos+Vector2(-210,0))
  if sweep:
   for y in range(80,int(s.world_size().y),80):
    for x in range(80,int(s.world_size().x),80):endpoints.append(Vector2(x,y))
  var origins=[origin]
  if corners:
   endpoints=[s.mission.extraction]
   for polygon in s.Depth.shapes(s,1):
    for vertex in polygon:
     for index in 8:
      var point=vertex+Vector2.from_angle(index*TAU/8)*32.
      if not s.blocked(point,24):origins.append(point)
  var accepted=0;var clipped=0;var tight=0;var minimum=INF
  for start in origins:
   for endpoint in endpoints:
    var route=s.player_path(start,endpoint)
    if route.is_empty():continue
    accepted+=1;checks+=1
    var clearance=Measure.route_clearance(s,start,route);minimum=minf(minimum,clearance)
    if clearance<12.-.001:
     clipped+=1;failures+=1
     if clipped<=3:printerr("CLIPPED ",operation," from=",start," to=",endpoint," clearance=",clearance," route=",route)
    elif clearance<24.-.001:
     tight+=1
     if tight<=2:print("TIGHT ",operation," from=",start," to=",endpoint," clearance=",clearance," route=",route)
  print("NAV PROBE op=",operation," accepted=",accepted," clipped=",clipped," below_planner_margin=",tight," minimum=",minimum)
 print("NAV CLEARANCE PROBE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
