extends RefCounted
# Source-known technical completion routes. Commands use only public-chart
# navigation and fresh observed locks; this is not evidence of blind player quality.
const Sim=preload("res://src/simulation/simulation.gd")
static func tick(s,seconds:float=.1)->void:
 for n in ceili(seconds*10):
  s.advance(.1)
  for contact in s.contacts.values():
   if s.elapsed-contact.time>.3 or contact.lock<1.2:continue
   var unit=int(contact.target)
   if unit<0 or not s.units[unit].alive:continue
   s.command("select",{"unit":unit})
   if s.tools.emp>0:s.command("emp")
   elif s.tools.decoy>0:s.command("decoy",{"point":s.units[unit].pos+Vector2(0,-100)})
   break
static func travel(s,unit:int,point:Vector2)->bool:
 s.command("select",{"unit":unit})
 if not s.command("route",{"point":point}):print("REJECT ",point," ",s.message);return false
 s.paused=false
 for n in 1800:
  tick(s)
  if not s.outcome.is_empty():return s.outcome=="won"
  if not s.units[unit].alive:return false
  if s.units[unit].pos.distance_to(point)<22 and s.units[unit].vel.length()<2:return true
  if s.units[unit].has("chart_stop"):
   s.command("select",{"unit":unit});s.command("route",{"point":point})
 print("STUCK unit=",unit," goal=",point," at=",s.units[unit].pos," message=",s.message)
 return false
static func circuit(s,unit:int,points:Array)->bool:
 for point in points:
  if not travel(s,unit,point):return false
 return true
static func acquire(s,unit:int,site_id:String)->bool:
 s.command("select",{"unit":unit})
 var site=s.mission.objectives.filter(func(o):return o.get("site_id","")==site_id)
 if site.is_empty():print("UNLOCATED ",site_id);return false
 if not s.command("camera"):print("CAPTURE REJECT ",s.capture_context());return false
 for n in 150:
  tick(s)
  if site[0].captured:return true
  if not s.outcome.is_empty() or not s.units[unit].alive:return false
 return false
static func play(thread:String="shelf",route:String="concealed",service:bool=false,stage:String="complete"):
 var s=Sim.new();s.start(11,"endurance",{"context":{"thread":thread,"completed":[9 if thread=="deep" else 10]}})
 s.units[1].alive=false;s.units[2].alive=false
 if thread=="deep" and route=="concealed" and not service:
  if not circuit(s,0,[Vector2(2840,4650),Vector2(2530,4660),Vector2(1840,4720),Vector2(1160,4640),Vector2(1000,4160),Vector2(1120,3510),Vector2(1120,2910),Vector2(1090,2360),Vector2(1080,2020)]):return s
 elif thread=="shelf":
  if not circuit(s,0,[Vector2(1000,4160),Vector2(1120,3510),Vector2(1120,2910),Vector2(1090,2360),Vector2(1080,2020)]):return s
 elif service:
  if not circuit(s,0,[Vector2(2780,3900),Vector2(2720,3130),Vector2(2860,2540),Vector2(2960,2460)]):return s
  if not acquire(s,0,"confluence_repeater"):return s
  if not circuit(s,0,[Vector2(2640,2520),Vector2(2570,2300),Vector2(1090,2300),Vector2(1080,2020)]):return s
 else:
  if not circuit(s,0,[Vector2(2780,3900),Vector2(2720,3130),Vector2(2620,2590),Vector2(2600,1850),Vector2(2740,1190),Vector2(2600,1000),Vector2(1740,850),Vector2(1110,1090),Vector2(1100,1720),Vector2(1080,2020)]):return s
 if not acquire(s,0,"confluence_packet"):return s
 if stage=="factory":s.paused=true;return s
 if route=="concealed":
  if not circuit(s,0,[Vector2(1090,2360),Vector2(1120,2910),Vector2(1120,3510),Vector2(1000,4160)]):return s
 elif service:
  if not circuit(s,0,[Vector2(1090,2300),Vector2(2570,2300),Vector2(2630,2550),Vector2(2720,3130),Vector2(2780,3900)]):return s
 else:
  if not circuit(s,0,[Vector2(1090,2360),Vector2(1120,2910),Vector2(1120,3510),Vector2(1000,4160),Vector2(1160,4640),Vector2(1840,4720),Vector2(2530,4660),Vector2(2840,4650)]):return s
 for exit in s.mission.corridors:
  if exit.route==route:travel(s,0,exit.pos)
 return s
