extends SceneTree
const Plan=preload("res://tests/confluence_command_plan.gd")
func _initialize():
 var s=Plan.play_parallel()
 var failed=0
 if s.outcome!="won" or not s.mission.physical_gates[0].opened:failed+=1
 var packet=s.mission.objectives.filter(func(site):return site.get("site_id","")=="confluence_packet")
 if packet.is_empty() or not packet[0].captured:failed+=1
 if s.units[0].pos.distance_to(Vector2(1080,1840))<2000 or s.units[1].pos.distance_to(Vector2(1080,1840))>240:failed+=1
 if s.units[1].battery>=95 or not s.units[1].alive:failed+=1
 print("CONFLUENCE_PARALLEL_TECHNICAL outcome=",s.outcome," t=",s.elapsed," hull=",s.hull," units=",s.units.map(func(u):return {"alive":u.alive,"pos":u.pos,"battery":u.battery})," tools=",s.tools)
 print("CONFLUENCE PARALLEL CHECKS 4 FAILURES ",failed)
 quit(1 if failed else 0)
