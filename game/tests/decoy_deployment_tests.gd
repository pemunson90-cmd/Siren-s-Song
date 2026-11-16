extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Tuning=preload("res://src/simulation/tuning.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var s=Sim.new();s.start(0);s.units[0].pos=Vector2(400,500)
 check(not s.command("decoy") and s.tools.decoy==3 and s.noises.is_empty(),"default east landing in basalt rejects without spending")
 for point in [Vector2(560,500),Vector2(400,800),Vector2(-1,500),Vector2(NAN,500),"water"]:
  s=Sim.new();s.start(0);s.units[0].pos=Vector2(400,500)
  var before=s.snapshot();check(not s.command("decoy",{"point":point}) and s.snapshot()==before,"invalid target %s cannot spend or mutate active state"%str(point))
 s=Sim.new();s.start(0);s.units[0].pos=Vector2(400,500)
 check(s.command("decoy",{"point":Vector2(300,500)}) and s.tools.decoy==2,"pilot deliberately deploys at a reachable water point")
 check(s.noises.size()==1 and s.noises[0].pos==Vector2(300,500) and s.noises[0].radius==1100 and s.noises[0].time==15,"valid deployment retains finite15s1100m lure")
 var cover=Sim.new();cover.start(3);cover.units[0].pos=Vector2(880,710)
 check(not cover.command("decoy",{"point":Vector2(1040,710)}) and cover.tools.decoy==3,"nearby water behind solid basalt is not a teleport deployment")
 var edge=Sim.new();edge.start(0);edge.units[0].pos=Vector2(1470,900)
 check(not edge.command("decoy") and edge.tools.decoy==3,"default outside world rejects without spending")
 var ordinary=Sim.new();ordinary.start(0)
 check(ordinary.command("decoy") and ordinary.noises[0].pos==Vector2(300,800),"existing default API retains valid east160 deployment")
 var legacy=ordinary.snapshot();legacy.noises[0].pos=Vector2(560,500);legacy.noises[0].time=12.0
 var restored=Sim.new();check(restored.restore(legacy) and restored.snapshot()==legacy,"existing active legacy noise is preserved even at newly forbidden landing")
 restored.advance(2);check(restored.snapshot()==legacy,"pause preserves existing transmission lifetime")
 var drone=Sim.new();drone.start(0);PlayerDive.launch_drones(drone);drone.command("select",{"unit":1})
 check(drone.command("decoy",{"point":Vector2(240,700)}) and drone.tools.decoy==2,"selected drone can deliberately place its finite common buoy")
 # WP-137 (Pat, 15 Nov 2026): a decoy within a locking Siren's hearing breaks the lock; out of hearing it does not.
 var lock=Sim.new();lock.start(0);lock.units[0].pos=Vector2(400,500);lock.paused=false
 var siren=lock.sirens[0];siren.lock=2.0;siren.target=0;siren.mode="LOCKING";siren.stun=0.0
 var before_lock:Dictionary=lock.snapshot()
 var point:Vector2=lock.decoy_lock_point(0,0)
 check(point!=Vector2.INF and lock.decoy_point_ok(0,point) and 0 in lock.decoy_lock_breakers(point,1,0),"a drop point in reach exists for a locking Siren that hears it")
 check(lock.decoy_lock_point(0,0)==point and lock.snapshot()==before_lock,"the offered point is deterministic and the query changes nothing")
 check(lock.command("decoy",{"point":point}) and lock.tools.decoy==2,"the decoy is placed as the chart places it")
 check(siren.lock==0.0 and siren.target==-1 and siren.goal==point and siren.mode=="INVESTIGATE","the decoy ends the countdown and the Siren turns to it")
 check(lock.message.contains("S1 LOCK BROKEN") and lock.message.contains("drawn to the decoy"),"the event text says the lock broke: "+lock.message)
 for n in 40:lock.advance(0.1)
 check(lock.outcome.is_empty() and lock.units[0].alive and float(siren.lock)<=0.0,"drawn off for the decoy's sounding: no beam, no new lock")
 var again=Sim.new();again.start(0);again.paused=false;again.units[0].pos=Vector2(400,500);again.sirens[0].lock=2.0;again.sirens[0].target=0;again.sirens[0].mode="LOCKING"
 again.command("decoy",{"point":point});for n in 40:again.advance(0.1)
 check(again.sirens[0].pos==siren.pos and again.sirens[0].lock==siren.lock,"same start, same result")
 var far=Sim.new();far.start(0);far.units[0].pos=Vector2(400,500)
 far.sirens[0].pos=Vector2(400+Tuning.DECOY_NOISE*3,500);far.sirens[0].lock=2.0;far.sirens[0].target=0;far.sirens[0].mode="LOCKING"
 check(far.decoy_lock_point(0,0)==Vector2.INF and far.decoy_lock_breakers(Vector2(300,500),1,0).is_empty(),"a Siren out of hearing is not offered the decoy")
 check(far.command("decoy",{"point":Vector2(300,500)}) and far.sirens[0].lock==2.0 and far.sirens[0].target==0 and not far.message.contains("LOCK BROKEN"),"out of hearing: the lock stands and nothing is said")
 var landed=Sim.new();landed.start(0);landed.units[0].pos=Vector2(400,500);landed.sirens[0].lock=landed.lock_seconds();landed.sirens[0].target=0
 check(landed.decoy_lock_breakers(Vector2(300,500),1,0).is_empty(),"a beam already fired is not a countdown")
 # The lock card's offer (ThreatRead rows) names the decoy with its reason when a charge and a drop point exist.
 var card=Sim.new();card.start(0);card.units[0].pos=Vector2(600,210);card.elapsed=10.
 var cs=card.sirens[0];cs.lock=2.0;cs.target=0;cs.mode="LOCKING"
 card.contacts={0:{"pos":cs.pos,"time":10.,"mode":"LOCKING","lock":2.0,"target":0,"band":card.units[0].band,"type":"patroller","source":"optical","angle":0.0}}
 var rows=preload("res://src/presentation/threat_read/threat_read.gd").lock_rows(card)
 check(rows.size()==1 and rows[0].moves.any(func(m):return m.order=="decoy"),"the lock card offers DECOY with a charge and a drop point in reach: "+str(rows))
 if rows.size()==1:
  var read=preload("res://src/presentation/lock_move_timing.gd").read(card,rows[0],rows[0].moves.filter(func(m):return m.order=="decoy")[0])
  check(read.in_time and read.line=="draws it off the lock","its reason line reads: "+read.line)
 # WP-148: a decoy that breaks the lock closes the card at once (paused clock included) and offers nothing more.
 var broke=Sim.new();broke.start(0);broke.units[0].pos=Vector2(600,210);broke.elapsed=10.
 var bs=broke.sirens[0];bs.lock=2.0;bs.target=0;bs.mode="LOCKING"
 broke.contacts={0:{"pos":bs.pos,"time":10.,"mode":"LOCKING","lock":2.0,"target":0,"band":broke.units[0].band,"type":"patroller","source":"optical","angle":0.0}}
 var drop:Vector2=broke.decoy_lock_point(0,0)
 check(drop!=Vector2.INF and not preload("res://src/presentation/threat_read/threat_read.gd").lock_rows(broke).is_empty(),"the lock card is up before the drop")
 check(broke.command("decoy",{"point":drop}) and preload("res://src/presentation/threat_read/threat_read.gd").lock_rows(broke).is_empty(),"after LOCK BROKEN the lock card has no row, so no DECOY is offered for it")
 card.tools.decoy=0
 if card.mission.has("tool_racks"):
  for k in card.mission.tool_racks:card.mission.tool_racks[k]["decoy"]=0
 var none=preload("res://src/presentation/threat_read/threat_read.gd").lock_rows(card)
 check(none.size()==1 and not none[0].moves.any(func(m):return m.order=="decoy"),"no charge, no DECOY on the card")
 print("DECOY DEPLOYMENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
