extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.READ);var snapshot=f.get_var();f.close();var s=Sim.new();assert(s.restore(snapshot));s.command("route",{"point":s.mission.extraction});s.paused=false
 var origin=s.units[0].pos;var first_motion=-1.0;var turn_at_motion=0.0;var minimum_y=origin.y;var maximum_y=origin.y
 for n in 240:
  s.advance(1.0/60);var u=s.units[0];minimum_y=minf(minimum_y,u.pos.y);maximum_y=maxf(maximum_y,u.pos.y)
  if first_motion<0 and u.vel.length()>0.1:first_motion=(n+1)/60.0;turn_at_motion=u.angle
 print("INITIAL_RESPONSE first_motion_s=",first_motion," heading_at_motion=",turn_at_motion," y_range=",minimum_y,",",maximum_y," final_route_size=",s.units[0].route.size()," message=",s.message)
 quit()
