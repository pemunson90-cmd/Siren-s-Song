extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
var results=[]
func execute(label,structures,start,target,angle,velocity,station=0,queued=[]):
 var s=Sim.new();s.start(0);s.sirens=[];s.mission.rocks=[];s.mission.structures=structures;s._build_navigation();s.selected=station;s.paused=false
 var u=s.units[station];u.pos=start;u.vel=velocity;u.angle=angle
 var accepted=s.command("route",{"point":target})
 if not queued.is_empty():
  s.command("queue")
  if "stop" in label:s.command("waypoint_mode")
  for point in queued:accepted=s.command("route",{"point":point}) and accepted
 var final=queued.back() if not queued.is_empty() else target
 var before=s.snapshot();s.paused=true;s.advance(999);var pause_equal=before.mission==s.mission and before.units==s.units and s.elapsed==before.elapsed;s.paused=false
 var positions=[];var penetrate=false;var emergency=false
 for n in 1200:
  if "replace" in label and n==2:
   accepted=s.command("queue") and accepted
   accepted=s.command("emergency",{"point":Vector2(1100,300)}) and accepted
   final=Vector2(1100,300);emergency=not s.queue_mode and u.hold==""
  s.advance(0.1)
  if s.blocked(u.pos,12):penetrate=true
  if n%10==0:positions.append(u.pos)
  if u.route.is_empty() and u.vel.length()<2:break
 var stalled=false
 if positions.size()>6 and not u.route.is_empty():stalled=u.pos.distance_to(positions[-6])<1
 results.append({"case":label,"accepted":accepted,"time":s.elapsed,"pos":u.pos,"target":final,"reached":u.pos.distance_to(final)<20 and u.vel.length()<2,"route_count":u.route.size(),"speed":u.vel.length(),"penetration":penetrate,"pause_equal":pause_equal,"stalled":stalled,"emergency_cleared_intent":emergency,"message":s.message})
func _initialize():
 for station in [0,1]:
  for north in [true,false]:
   for residual in [0,8]:
    var p=Vector2(730,760 if north else 200);var target=Vector2(730,200 if north else 760)
    execute("corridor_%d_%s_%d"%[station,north,residual],[Rect2(300,300,400,500),Rect2(760,300,400,500)],p,target,0.0,Vector2(residual,0),station)
  execute("world_top_%d"%station,[],Vector2(30,30),Vector2(500,30),-PI/2,Vector2.ZERO,station)
  execute("world_bottom_%d"%station,[],Vector2(1570,930),Vector2(1100,930),PI/2,Vector2.ZERO,station)
  for mode in ["pass","stop"]:
   execute("long_%s_%d"%[mode,station],[Rect2(300,300,400,500),Rect2(760,300,400,500)],Vector2(730,760),Vector2(730,200),0.0,Vector2.ZERO,station,[Vector2(1250,200),Vector2(1250,850),Vector2(300,850)])
 execute("replace_turn",[Rect2(300,300,400,500),Rect2(760,300,400,500)],Vector2(730,260),Vector2(730,200),PI/2,Vector2(0,8),0)
 # Real integrated threat update under equivalent own stationary inputs/noise.
 var s=Sim.new();s.start(3);s.command("decoy",{"point":Vector2(980,260)});s.paused=false;var trace=[]
 for n in 1800:
  s.advance(1.0/60)
  if n%10==0:trace.append(s.snapshot())
 var ai_digest=JSON.stringify(trace).sha256_text()
 # Actual accepted legacy archives must validate/restore without new fields.
 var legacy=[]
 for name in ["accepted-blackwater.archive","accepted-finale.archive"]:
  var store=Store.new();store.path="res://tests/fixtures/"+name;var data=store.load_game();var restored=Sim.new();legacy.append({"fixture":name,"loaded":not data.is_empty(),"restored":not data.is_empty() and restored.restore(data.active),"mission_same":not data.is_empty() and restored.mission==data.active.mission})
 var file=""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="):file=arg.trim_prefix("--out=")
 var f=FileAccess.open(file,FileAccess.WRITE);f.store_string(JSON.stringify({"geometry_cases":results,"integrated_stationary_threat_digest":ai_digest,"legacy":legacy},"  "));f.close()
 print("HUNTER_NAV cases=",results.size()," ai_digest=",ai_digest," legacy=",legacy);quit()
