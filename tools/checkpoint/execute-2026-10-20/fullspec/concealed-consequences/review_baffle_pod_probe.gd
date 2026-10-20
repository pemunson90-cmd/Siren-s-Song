extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
func _initialize():call_deferred("run")
func advance(s,t):
 s.paused=false
 for n in ceili(t*60):s.advance(1./60.)
 s.paused=true
func run():
 var facts={"shelf":"Recovered branch","confluence_route":"concealed"}
 var s=Sim.new();s.start(12,"endurance",{"context":{"thread":"shelf","facts":facts,"completed":[6,8,10,11],"references":{}}});var guard=s.sirens[1].duplicate(true);s.sirens=[]
 s.units[1].pos=Vector2(1840,800);s.units[1].vel=Vector2.ZERO;s.command("select",{"unit":1});advance(s,.02)
 print("WINCH=",s.command("salvage",{"item":"witness_capsule"}));advance(s,4.1)
 s.command("select",{"unit":0});s.units[0].pos=Vector2(1940,1040);s.units[0].vel=Vector2.ZERO;s.units[0].silent=true
 print("ATTACH=",s.command("concealed_tow",{"action":"attach"}));s.units[0].pos=Vector2(1970,1010);s.units[0].vel=Vector2.ZERO;advance(s,.02)
 s.command("select",{"unit":1});print("REAL_DRONE_ROUTE=",s.command("route",{"point":Vector2(2140,970)}))
 for n in 1800:
  if s.units[1].pos.distance_to(Vector2(2140,970))<10 and s.units[1].vel.length()<2:break
  if s.units[1].has("chart_stop") and n%30==0:s.command("route",{"point":Vector2(2140,970)})
  advance(s,1./60.)
 print("DRONE_ARRIVED=",s.units[1].pos," speed=",s.units[1].vel.length()," witness=",s.mission.witness_evacuation.state," carrier=",s.mission.witness_evacuation.carrier)
 s.command("select",{"unit":0});print("BEFORE_LOSS baffle_ready=",s.concealed_status().actions.seats.filter(func(p):return p.id=="baffle")[0].ready)
 guard.pos=Vector2(2260,970);guard.home=guard.pos;guard.goal=guard.pos;guard.route=[];guard.patrol_points=[];s.sirens=[guard];advance(s,4.3)
 print("ACTUAL_BEAM_LOSS alive=",s.units[1].alive," guard_mode=",guard.mode," pod=",s.mission.witness_evacuation.state," pos=",s.mission.witness_evacuation.pos," valid=",Sim.valid_snapshot(s.snapshot()))
 print("SEAT_BAFFLE=",s.command("concealed_tow",{"action":"baffle"})," pod_blocked=",s.blocked(s.mission.witness_evacuation.pos)," phase=",s.mission.concealed_harbour.phase," can_attach=",s.concealed_status().actions.tow," can_release=",s.concealed_status().actions.release," all_records=",s.all_records()," valid=",Sim.valid_snapshot(s.snapshot()))
 var progress={"version":2,"route":"shelf","routes":["shelf"],"facts":facts,"completed":[6,8,10,11],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"shelf"}
 var archive={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress,"active":s.snapshot()};var store=Store.new();store.path="user://review-baffle-pod.save"
 var saved=store.save(archive);var loaded=store.load_game();var restored=Sim.new();var resumed=restored.restore(loaded.get("active",{}))
 print("BINARY_SAVE=",saved," equal=",loaded==archive," RESTORE=",resumed," error=",store.warning)
 for p in [Vector2(2020,970),Vector2(2260,970),Vector2(2140,820),Vector2(2140,1120)]:print("LEGAL_WATER ",p," blocked=",s.blocked(p)," line_to_pod=",s.line_clear(p,s.mission.witness_evacuation.pos))
 quit()
