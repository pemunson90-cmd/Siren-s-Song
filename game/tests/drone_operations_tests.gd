extends SceneTree
# 127 (Pat 2026-10-30): scripted journeys here fly the dev/test pathfinder route; hand_pilot_journeys covers release play.
const Sim=preload('res://src/simulation/simulation.gd')
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr('FAIL: ',label)
func fresh():
 var s=Sim.new();s.start(0);s.mission["dev"]=true;return s
func advance(s,seconds:float):
 s.paused=false
 for i in roundi(seconds*60):s.advance(1./60)
func _initialize():
 # Acquisition fixtures use real sensors: no fabricated contact or forced safety.
 var s=fresh();s.units[0].pos=Vector2(300,800);s.units[1].pos=Vector2(320,250);s.units[2].pos=Vector2(140,800);s._observe()
 check(s.contacts.get(0,{}).get('seen_by',[])==[1],'fresh passive contact records only the receiving drone')
 s.command('select',{'unit':2});s.command('route',{'point':Vector2(350,800)});s.command('contact_hold');advance(s,.5)
 check(s.units[2].hold=='SCOUT' and s.units[2].vel.length()>5,'remote fleet contact does not stop an armed scout on another branch')
 s=fresh();s.command('select',{'unit':1});s.command('route',{'point':Vector2(400,700)});s.command('contact_hold');var planned=s.units[1].route.duplicate(true)
 s.sirens[0].pos=Vector2(400,700);s._observe();advance(s,.1)
 check(s.units[1].hold=='SCOUT_STOP' and s.units[1].route==planned,'own passive observation latches scout stop without erasing its plan')
 s.contacts.clear();s.sirens[0].pos=Vector2(1400,100);advance(s,.5)
 check(s.units[1].hold=='SCOUT_STOP' and s.units[1].vel.length()<.1,'fading or absent contacts never restart a stopped scout')
 s.paused=true;var saved=s.snapshot();s.advance(20)
 check(s.snapshot()==saved,'pause freezes scout stop and observation times')
 var restored=Sim.new();check(restored.restore(bytes_to_var(var_to_bytes(s.snapshot()))),'scout state restores through real binary snapshot')
 check(restored.units[1].hold=='SCOUT_STOP' and restored.units[1].route==planned,'restore preserves stopped scout and remaining route')
 restored.command('contact_hold');advance(restored,.3)
 check(restored.units[1].hold=='' and restored.units[1].vel.length()>0,'explicit scout release resumes its retained route')
 s=fresh();s.units[1].hold='CONTACT';s.contacts[0]={'pos':Vector2(1400,100),'time':0.,'mode':'PATROL','lock':0.,'angle':0.,'target':-1}
 s.command('select',{'unit':1});s.command('route',{'point':Vector2(350,700)});s.units[1].hold='CONTACT';advance(s,.1)
 check(s.units[1].vel.length()<.1,'old aggregate drone CONTACT holds keep their fleet-wide behavior')
 check(Sim.valid_snapshot(s.snapshot()),'legacy contacts without observer metadata remain valid')
 s=fresh();s.command('route',{'point':Vector2(350,800)});s.command('contact_hold');s.contacts[0]={'pos':Vector2(1400,100),'time':0.};advance(s,.1)
 check(s.units[0].vel.length()<.1 and s.units[0].hold=='CONTACT','Quietus retains fleet guard semantics')
 var bad=fresh().snapshot();bad.contacts={0:{'seen_by':[3]}}
 check(not Sim.valid_snapshot(bad),'archive rejects out-of-range observer identity')
 bad=fresh().snapshot();bad.contacts={0:{'seen_by':[1,1]}}
 check(not Sim.valid_snapshot(bad),'archive rejects duplicated observer identity')
 bad=fresh().snapshot();bad.units[0].hold='SCOUT'
 check(not Sim.valid_snapshot(bad),'drone-only scout state cannot restore onto Quietus')
 s=fresh();s.sirens[0].pos=Vector2(700,850);s.command('recon');s._observe()
 check(not s.contacts.get(0,{}).get('seen_by',[]).has(1),'global survey observation does not claim a drone passive receiver')
 s=fresh();s.command('select',{'unit':1});s.command('contact_hold');s.command('emergency',{'point':Vector2(350,700)})
 check(s.units[1].hold=='' and not s.units[1].route.is_empty(),'emergency replacement clears scout condition and installs normal route')
 s=fresh();s.start(3);s.units[1].pos=Vector2(980,850);s.sirens[0].pos=Vector2(1220,850)
 s.command('select',{'unit':1});s.command('contact_hold');s.command('recon');s._observe();advance(s,.1)
 check(s.units[1].hold=='SCOUT' and s.contacts.has(0) and not 1 in s.contacts[0].seen_by,'thermal front weakens local reception; survey-only contact cannot trip scout')
 s.sirens[0].pos=Vector2(1100,850);s._observe();advance(s,.1)
 check(s.units[1].hold=='SCOUT_STOP','locally acquired close contact across front genuinely trips scout')
 s=fresh();s.units[1].pos=Vector2(320,250);s._observe();s.elapsed=.31;s.command('select',{'unit':1});s.command('contact_hold');advance(s,1./60)
 check(s.units[1].hold=='SCOUT','aged cached receiver attribution cannot trigger before fresh acquisition')
 advance(s,.1);check(s.units[1].hold=='SCOUT_STOP','subsequent real sensor refresh can trigger scout normally')
 s=fresh();s.sirens[0].pos=Vector2(700,850);s.units[0].pos=Vector2(600,850);s.command('emp')
 s.units[0].pos=Vector2(160,800);s.command('select',{'unit':1});s.command('contact_hold');s.command('sonar_mode',{'sector':'all','power':'high'});s.command('ping')
 check(not s.sonar.pending.is_empty() and s.units[1].hold=='SCOUT','active pulse schedules real echo travel before a scout can receive it')
 advance(s,4.0)
 check(s.contacts.has(0) and s.units[1].hold=='SCOUT','sonar-only contact does not trip local passive scout')
 var store=preload('res://src/persistence/save_store.gd').new();store.path='user://drone-operations-test.save'
 s=fresh();s.units[1].hold='SCOUT_STOP';var archive={'version':1,'unlocked':0,'completed':[],'settings':{},'upgrade':'endurance','active':s.snapshot()}
 check(store.save(archive) and store.load_game().active.units[1].hold=='SCOUT_STOP','actual validated archive round trip preserves scout state')
 for profile in [true,false]:
  s=fresh();s.command('select',{'unit':1});s.units[1].silent=profile;s.command('route',{'point':Vector2(400,700)});advance(s,2.0)
  check(s.units[1].vel.length()>80,'both drone visual profiles retain fixed-thrust motion')
 s=fresh();s.units[1].pos=Vector2(320,250);s.units[1].vel=Vector2(96,0);s.command('select',{'unit':1});s.command('route',{'point':Vector2(400,250)});s.command('contact_hold');s._observe();var before_stop=s.units[1].pos;advance(s,1./60)
 check(s.units[1].hold=='SCOUT_STOP' and s.units[1].vel.length()>90 and s.units[1].pos!=before_stop,'scout condition brakes real momentum rather than instantly stopping')
 advance(s,2.5);check(s.units[1].vel.length()<.1,'scout braking settles through the existing deceleration')
 var visual_targets=[]
 for profile in [true,false]:
  s=fresh();s.units[1].pos=Vector2(420,130);s.units[1].silent=profile;advance(s,1./60);visual_targets.append(s.sirens[0].target)
 check(visual_targets==[-1,1],'low/open drone profile preserves the actual180/290 visual acquisition distinction')
 s=fresh();s.start(4);s.mission["dev"]=true
 for id in [1,2]:
  s.command('select',{'unit':id});s.command('route',{'point':[Vector2(760,200),Vector2(1370,450)][id-1]});s.command('contact_hold')
 s.paused=false
 for n in 200:
  s.advance(.1)
  if not s.units[2].alive:break
 var lost_observer=s.contacts.values().any(func(c):return 2 in c.get('seen_by',[]) and s.elapsed-c.time<.3)
 var after_loss=Sim.new()
 check(not s.units[2].alive and s.units[2].hold=='SCOUT_STOP' and lost_observer and after_loss.restore(bytes_to_var(var_to_bytes(s.snapshot()))),'legitimate drone loss preserves stopped hold and fresh historical observer attribution through restore')
 print('DRONE OPERATIONS CHECKS ',checks,' FAILURES ',failures);quit(1 if failures else 0)
