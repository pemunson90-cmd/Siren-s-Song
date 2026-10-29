extends "res://tests/photo_row_journey_support.gd"
# Earned charts stop at newly seen terrain. Replan the same intended waypoint
# through the now observed chart, as the bare regional controller does.
func go(point:Vector2,seconds:float=GO_SECONDS)->bool:
 select()
 if not check(s.command("route",{"point":point}),"fleet route accepts waypoint "+str(point)):return false
 for n in ceili(seconds/Sim.STEP):
  if not s.outcome.is_empty() or not s.units[uid].alive:break
  tick(Sim.STEP)
  if s.units[uid].has("chart_stop") and n%30==0:s.command("route",{"point":point})
  if s.units[uid].route.is_empty() and s.units[uid].vel.length()<2.0:break
 var reached=s.units[uid].alive and s.outcome!="lost" and s.units[uid].pos.distance_to(point)<25.0
 print("GLASS DRONE LEG ",op," ",point," reached=",reached," actual=",s.units[uid].pos," time=",s.elapsed," hull=",s.hull)
 return check(reached,"fleet physically reaches "+str(point))
func record_optional()->bool:
 var index=target()
 if not check(index>=0,"optional subject was physically discovered"):return false
 # A real defensive order cancels that craft's exposure and spends the film.
 # Reacquire with ordinary commands after the received-lock response settles.
 for attempt in 4:
  if s.mission.objectives[index].get("captured",false):break
  select()
  var context=s.camera_context()
  if not check(context.get("ready",false) and context.get("target",-1)==index,"retry still targets the exact optional photo"):return false
  if not command("camera"):return false
  tick(float(s.mission.objectives[index].get("duration",4.0))+.5)
 return check(s.mission.objectives[index].get("captured",false) and Photo.shots_for(s.mission,key).any(func(shot):return shot.get("usable",false)),"optional exposure eventually files real usable film")
