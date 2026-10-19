extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
func _initialize():
 for mission_id in 6:
  var q=Simulation.new(); q.start(mission_id,"endurance"); q.paused=false
  var stats=[]
  for si in q.sirens.size():
   stats.append({"travel":0.0,"moving_seconds":0.0,"stationary_start":0.0,"longest_stationary":0.0,"longest_start":0.0,"longest_end":0.0,"blocked_goal_seconds":0.0,"empty_route_seconds":0.0,"goal_changes":0,"max_step":0.0,"start":str(q.sirens[si].pos),"last_goal":q.sirens[si].goal})
  for tick in 36000:
   var before=[]
   for s in q.sirens: before.append(s.pos)
   var old_time=q.elapsed
   q.advance(Simulation.STEP)
   assert(q.elapsed>old_time,"unexpected halted simulation")
   for si in q.sirens.size():
    var s=q.sirens[si]; var st=stats[si]; var d=s.pos.distance_to(before[si]); var dt=q.elapsed-old_time
    st.travel+=d; st.max_step=maxf(st.max_step,d)
    if d>0.000001:
     st.moving_seconds+=dt; st.stationary_start=q.elapsed
    else:
     var still=q.elapsed-st.stationary_start
     if still>st.longest_stationary: st.longest_stationary=still; st.longest_start=st.stationary_start; st.longest_end=q.elapsed
    if q.blocked(s.goal,24): st.blocked_goal_seconds+=dt
    if s.route.is_empty(): st.empty_route_seconds+=dt
    if s.goal!=st.last_goal: st.goal_changes+=1; st.last_goal=s.goal
   if tick%3600==3599:
    for si in q.sirens.size():
     var s=q.sirens[si]
     print("SNAP ",JSON.stringify({"mission":mission_id,"siren":si,"time":q.elapsed,"position":str(s.pos),"goal":str(s.goal),"mode":s.mode,"route_size":s.route.size(),"blocked_goal24":q.blocked(s.goal,24),"path_size":q.path(s.pos,s.goal).size(),"distance_to_goal":s.pos.distance_to(s.goal),"suspicion":s.suspicion,"lock":s.lock,"target":s.target}))
  for si in q.sirens.size():
   var st=stats[si]; var s=q.sirens[si]
   st.erase("last_goal"); st.mission=mission_id;st.siren=si;st.elapsed=q.elapsed;st.finish=str(s.pos);st.goal=str(s.goal);st.goal_blocked=q.blocked(s.goal,24);st.final_path_size=q.path(s.pos,s.goal).size();st.distance_to_goal=s.pos.distance_to(s.goal);st.outcome=q.outcome
   print("RESULT ",JSON.stringify(st))
 print("PATROL AUDIT COMPLETE")
 quit()
