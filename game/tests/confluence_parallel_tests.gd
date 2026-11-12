extends SceneTree
const Plan=preload("res://tests/confluence_command_plan.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const HandLegs=preload("res://tests/hand_legs.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
func _initialize():
 # Scripted two-craft route through authored water, not a discovery test: known-charts developer switch (the player rules leave this water uncharted).
 var charts_before=PlayerDive.known_water(true)
 var s=play_parallel()
 PlayerDive.known_water(charts_before)
 var failed=0
 if s.outcome!="won" or not s.mission.physical_gates[0].opened:failed+=1
 var packet=s.mission.objectives.filter(func(site):return site.get("site_id","")=="confluence_packet")
 if packet.is_empty() or not packet[0].captured:failed+=1
 if s.units[0].pos.distance_to(Vector2(1080,1840))<2000 or s.units[1].pos.distance_to(Vector2(1080,1840))>240:failed+=1
 if s.units[1].battery>=95 or not s.units[1].alive:failed+=1
 print("CONFLUENCE_PARALLEL_TECHNICAL outcome=",s.outcome," t=",s.elapsed," hull=",s.hull," units=",s.units.map(func(u):return {"alive":u.alive,"pos":u.pos,"battery":u.battery})," tools=",s.tools)
 print("CONFLUENCE PARALLEL CHECKS 4 FAILURES ",failed)
 quit(1 if failed else 0)
# Copy of confluence_command_plan.gd play_parallel() with the fitted drone launched first: the plan skips a craft that is not alive, so an aboard drone would never start.
func play_parallel():
 var s=Sim.new();s.start(11,"disruption",{"context":{"thread":"deep","completed":[9]},"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}});PlayerDive.launch_drones(s)
 var itineraries={0:[Vector2(2780,3900),Vector2(2720,3130),Vector2(2860,2540),Vector2(2960,2460)],1:[Vector2(2840,4650),Vector2(2530,4660),Vector2(1840,4720),Vector2(1160,4640),Vector2(1000,4160),Vector2(1120,3510),Vector2(1120,2910),Vector2(1090,2360),Vector2(1080,2020)]}
 var goals={};var working={};var returned=false
 s.paused=false
 for n in 6000:
  Plan.tick(s)
  for unit in [0,1]:
   if not s.units[unit].alive:continue
   if goals.has(unit) and s.units[unit].pos.distance_to(goals[unit])<22 and s.units[unit].vel.length()<2:goals.erase(unit)
   if not goals.has(unit) and not itineraries[unit].is_empty():
    var point=itineraries[unit].pop_front();goals[unit]=point
    s.command("select",{"unit":unit});HandLegs.route(s,point)
   elif goals.has(unit) and s.units[unit].has("chart_stop"):
    s.command("select",{"unit":unit});HandLegs.route(s,goals[unit])
   if not goals.has(unit) and itineraries[unit].is_empty() and not working.has(unit):
    var site_id="confluence_repeater" if unit==0 else "confluence_packet"
    var sites=s.mission.objectives.filter(func(site):return site.get("site_id","")==site_id)
    if not sites.is_empty():
     if not sites[0].captured:
      s.command("select",{"unit":unit})
      if s.command("camera"):working[unit]=true
  if working.get(0,false) and s.mission.physical_gates[0].opened and not returned:
   returned=true;itineraries[0]=[Vector2(2860,2540),Vector2(2720,3130),Vector2(2780,3900),s.mission.corridors[1].pos]
  if s.all_records() and returned and not goals.has(0) and itineraries[0].is_empty():
   s.command("select",{"unit":0});HandLegs.route(s,s.mission.corridors[1].pos)
   if s.departure_context().get("confirmation_required",false):s.command("depart",{"confirm":true})
  if not s.outcome.is_empty():break
 return s
