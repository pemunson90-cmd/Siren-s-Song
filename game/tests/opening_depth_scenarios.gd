extends RefCounted
const Sim=preload("res://src/simulation/simulation.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
static func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(1./60)
 s.paused=true
static func run(t):
 for id in range(1,6):
  var configured=Sim.new();configured.start(id)
  configured.message="stale order";configured.start(id)
  t.check(not configured.message.contains("stale"),"starting next opening clears prior craft order feedback: "+str(id))
  t.check(Catalog.valid_definition(Catalog.definition(id)) and Sim.valid_snapshot(configured.snapshot()),"authored opening initializes and saves: "+str(id))
  var restored=Sim.new();t.check(restored.restore(configured.snapshot()) and restored.snapshot()==configured.snapshot(),"authored opening restores exact bands: "+str(id))
 var s=Sim.new();s.start(1)
 t.check(Catalog.valid_definition(Catalog.definition(1)) and Sim.valid_snapshot(s.snapshot()),"configured opening factory yields valid current content")
 t.check(not s.Depth.clear(s,Vector2(1110,2150),Vector2(1110,1660),1,24) and s.Depth.clear(s,Vector2(1110,2150),Vector2(1110,1660),2,24),"Split southern shelf is a real deep underpass, not universal open water")
 t.check(not s.Depth.clear(s,Vector2(650,400),Vector2(1150,400),1,24) and s.Depth.clear(s,Vector2(650,400),Vector2(1150,400),0,24),"Split shallow saddle creates a distinct northern crossing")
 t.check(not s.Depth.clear(s,Vector2(1110,1450),Vector2(1110,1750),0,24) and s.Depth.clear(s,Vector2(1110,1450),Vector2(1110,1750),1,24),"Split shallow sill requires a deliberate ascent or middle approach at uplink")
 t.check(s.sirens[1].band==2 and s.sirens[0].band==1,"Split opposite patrols occupy different real waters")
 s.units[0].pos=Vector2(1110,2050);s.units[0].vel=Vector2.ZERO
 t.check(s.command("depth",{"band":2}),"Split actual local clearance permits deliberate dive")
 tick(s,4.1)
 t.check(s.units[0].band==2 and s.command("route",{"point":Vector2(1110,1660)}),"Split retains actionable operator route through underpass")
 var initial=s.units[0].pos;tick(s,4)
 t.check(s.units[0].pos.distance_to(initial)>60 and Sim.valid_snapshot(s.snapshot()),"Split craft physically traverses measured deep water and saves")
 var restored=Sim.new();t.check(restored.restore(s.snapshot()) and restored.snapshot()==s.snapshot(),"authored multi-band encounter roundtrips exactly")

 blackwater(t)
 foundry(t)
 well(t)
 reports(t)
 counterpolicies(t)
 private_listening(t)
static func blackwater(t):
 var s=Sim.new();s.start(2);s.units[0].pos=Vector2(560,200);s.units[0].band=2
 t.check(s.command("ping") and s.mission.objectives[0].replay_until==0,"deep pulse cannot trigger a middle relay's local handshake")
 t.check(not s.command("camera"),"deep shortcut does not bypass Blackwater middle sampling")
 tick(s,3.6);s.units[0].band=1;s.units[0].angle=PI
 s.command("sonar_mode",{"sector":"forward","power":"low"})
 t.check(s.command("ping") and s.mission.objectives[0].replay_until==0,"forward pulse facing away cannot solicit a relay reply")
 tick(s,3.6);s.units[0].angle=0.
 t.check(s.command("ping") and s.mission.objectives[0].replay_until>s.elapsed,"facing the real local relay earns its replay")
 t.check(s.Depth.clear(s,Vector2(300,540),Vector2(760,540),2,24) and not s.Depth.clear(s,Vector2(300,540),Vector2(760,540),1,24),"Blackwater deep basalt underpass changes real navigation")
 t.check(s.sirens.any(func(e):return e.band==2 and e.type=="sweeper") and s.sirens.any(func(e):return e.band==0),"Blackwater alternative waters have differentiated local threats")
static func foundry(t):
 var s=Sim.new();s.start(3)
 t.check(s.Depth.clear(s,Vector2(420,500),Vector2(960,500),2,24) and not s.Depth.clear(s,Vector2(420,500),Vector2(960,500),1,24),"Foundry deep spine passage is physical")
 t.check(not s.Depth.clear(s,Vector2(1300,500),Vector2(1300,500),2,12),"Foundry factory remains solid beneath the spine")
 s.units[0].pos=Vector2(1100,770);s.elapsed=20.
 for id in [1,2]:s.units[id].alive=false
 var middle=s.Departure.feedback(s);s.units[0].band=2;var deep=s.Departure.feedback(s)
 t.check(not middle.get("receivers",{}).has(0) and deep.get("receivers",{}).has(0),"same-position deep receiver actually hears industrial motor masked from middle")
 s.Departure.emit(s)
 t.check(s.noises.any(func(n):return n.label=="DEEP MOTOR" and n.band==2),"industrial emission has its own real source layer")
 t.check(s.mission.thermal_revision==1 and s.mission.thermal_fronts[0].transmission==.55,"Foundry retains its original physical cold front")
static func well(t):
 var s=Sim.new();s.start(4);s.mission.objectives[0].captured=true
 s.units[0].pos=Vector2(1200,380);s.units[0].band=2;s.units[0].silent=false
 s.command("route",{"point":Vector2(1330,380)});tick(s,2.)
 t.check(s.mission.well_reference.is_empty(),"actual deep cruise cannot forge the middle Well engine reference")
 s.units[0].band=1;s.units[0].pos=Vector2(1200,380);s.units[0].vel=Vector2.ZERO;s._use_band(1);s.command("route",{"point":Vector2(1500,380)});tick(s,2.)
 t.check(not s.mission.well_reference.is_empty(),"actual middle cruise earns a local moving engine reference")
 s.units[1].pos=Vector2(780,850);s.units[1].band=0;tick(s,.1)
 t.check(s.mission.well_observation.is_empty(),"shallow receiver cannot invent a middle Well return")
 s.units[1].band=1;tick(s,.1)
 t.check(s.mission.well_observation.get("unit",-1)==1,"independent middle drone receives real comparison locally")
 t.check(s.sirens.any(func(e):return e.type=="hunter" and e.band==1) and s.sirens.any(func(e):return e.type=="sweeper" and e.band==2),"Well hunter and sweeper create distinct information/counterplay")
static func reports(t):
 var s=Sim.new();s.start(5)
 s.units[0].pos=Vector2(1000,780)
 for id in [1,2]:s.units[id].alive=false
 s.sirens[0].pos=Vector2(1110,780);s.sirens[0].band=1
 s.sirens[1].pos=Vector2(1130,880);s.sirens[1].band=2
 for id in range(2,s.sirens.size()):s.sirens[id].stun=100.
 tick(s,preload("res://src/simulation/contact_reports.gd").charge(s.mission)+.1)
 t.check(s.sirens[1].get("known_band",-1)==1 and s.sirens[0].get("report",{}).get("sent",0)>0,"finale local report carries legitimately observed layer across actual water")
 var report_band=s.sirens[1].get("known_band",-1)
 s.units[0].pos=Vector2(700,780);s.command("depth",{"band":0});tick(s,4.1)
 t.check(s.units[0].band==0 and s.sirens[1].get("known_band",-1)==report_band,"after sight breaks, report cannot read hidden new player layer")
 t.check(Sim.valid_snapshot(s.snapshot()),"cross-layer report, hidden depth change and enemy pursuit save correctly")

 # Controlled visible actors: both occupied bands remain physical attack water.
 var moving=Sim.new();moving.start(0);moving.sirens=moving.sirens.slice(0,1)
 moving.units[0].pos=Vector2(760,650);moving.units[0].band=1
 moving.sirens[0].pos=Vector2(800,650);moving.sirens[0].band=1
 moving.sirens[0].transition={"to":2,"remaining":3.};moving.sirens[0].lock=4.5;moving.sirens[0].target=0
 tick(moving,.2)
 t.check(moving.outcome=="lost" and moving.hull==0 and moving.sirens[0].lock>4,"a visible shared-band target remains vulnerable while the enemy changes depth")

static func counterpolicies(t):
 # Matched source-known staged poses; ONLY pulse policy changes.
 var cases=[
  {"id":1,"enemy":1,"point":Vector2(1690,1340),"band":1},
  {"id":2,"enemy":0,"point":Vector2(760,340),"band":2},
  {"id":3,"enemy":1,"point":Vector2(1410,940),"band":1},
  # Keep this staged emitter near the Well hunter's relocated, navigable post.
  {"id":4,"enemy":1,"point":Vector2(1340,840),"band":2},
  {"id":5,"enemy":0,"point":Vector2(950,400),"band":2}
 ]
 for example in cases:
  var results=[]
  for active in [false,true]:
   var s=Sim.new();s.start(example.id);s.units[0].pos=example.point;s.units[0].band=example.band
   for id in [1,2]:s.units[id].alive=false
   if active:s.command("sonar_mode",{"sector":"all","power":"high"});s.command("ping")
   tick(s,1.);results.append(s)
  t.check(not results[0].sirens[example.enemy].has("known_band") and results[1].sirens[example.enemy].get("known_band",-1)==example.band,"matched staged active policy changes real acquired depth, operation "+str(example.id))
  t.check(results[0].oxygen-results[1].oxygen>=1.19,"same-position high active information has real reserve cost, operation "+str(example.id))
  t.check(Sim.valid_snapshot(results[0].snapshot()) and Sim.valid_snapshot(results[1].snapshot()),"both matched sensing policies save valid actual threat state, operation "+str(example.id))

 var exploit=Sim.new();exploit.start(0);exploit.sirens=exploit.sirens.slice(0,1)
 exploit.units[0].pos=Vector2(760,650);exploit.sirens[0].pos=Vector2(800,650)
 for id in [1,2]:exploit.units[id].alive=false
 for n in 3:
  exploit.command("depth",{"band":2 if exploit.units[0].band==1 else 1});tick(exploit,4.1)
 t.check(exploit.hull<70,"adversarial repeated depth toggling cannot make stationary craft invulnerable to acquired beam pursuit")

static func private_listening(t):
 for emitter in [0,1]:
  var results=[]
  for hidden in [false,true]:
   var s=Sim.new();s.start(0);var reflector=s.sirens[0].duplicate(true);s.sirens=[]
   s.units[0].pos=Vector2(300,800);s.units[0].band=2
   s.units[1].pos=s.units[0].pos;s.units[1].band=2;s.units[1].alive=emitter==1;s.units[2].alive=false
   if hidden:reflector.pos=Vector2(700,800);reflector.band=2;s.sirens=[reflector]
   s.command("select",{"unit":emitter});s.command("sonar_mode",{"sector":"all","power":"high"});s.command("ping");results.append(s)
  t.check(results[0].contacts.is_empty() and results[1].contacts.is_empty() and results[0].sonar.pending.size()!=results[1].sonar.pending.size(),"matched pre-arrival fixture really has different hidden internal packets")
  for receiver in [0,1]:
   t.check(results[0].Sonar.feedback(results[0],receiver)==results[1].Sonar.feedback(results[1],receiver),"pre-arrival player feedback is invariant to hidden roster, receiver "+str(receiver))
  for s in results:s.command("select",{"unit":0})
  t.check(preload("res://src/presentation/sonar_history.gd").detail(results[0])==preload("res://src/presentation/sonar_history.gd").detail(results[1]),"entire selected history/context text cannot leak hidden pending roster")
  t.check(results[0].Sonar.feedback(results[0],emitter).listening>4.79 and results[0].Sonar.feedback(results[0],1-emitter).listening==0,"listening window belongs only to its actual emitter")
  t.check(Sim.valid_snapshot(results[1].snapshot()) and Sim.new().restore(results[1].snapshot()),"internal delayed packets and own listening clock remain save-authoritative")
