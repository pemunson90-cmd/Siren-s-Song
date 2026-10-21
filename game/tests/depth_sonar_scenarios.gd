extends RefCounted
const Sim=preload("res://src/simulation/simulation.gd")
const Depth=preload("res://src/simulation/depth_bands.gd")
const Sonar=preload("res://src/simulation/advanced_sonar.gd")
static func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(1./60)
 s.paused=true
static func fixture():
 var s=Sim.new();s.start(0);s.mission.rocks=[];s.mission.structures=[];s.mission.erase("depth_geometry");s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 s.contacts={};s.sirens=s.sirens.slice(0,1)
 var e=s.sirens[0];e.type="sentinel";e.pos=Vector2(600,700);e.home=e.pos;e.goal=e.pos;e.route=[];e.patrol_points=[]
 s.units[0].pos=Vector2(250,700);s.units[0].angle=0
 for i in [1,2]:s.units[i].alive=false
 return s
static func run(t):
 preload("res://tests/depth_repair_scenarios.gd").run(t)
 for id in Sim.Missions.Catalog.registered_ids():
  var original=Sim.new();original.start(id);var copy=Sim.new()
  t.check(copy.restore(original.snapshot()),"all registered operations roundtrip physical depth and sonar "+str(id))
 var s=fixture();tick(s,.7)
 t.check(not s.sonar.history.is_empty() and s.contacts.is_empty(),"passive machinery yields a bearing without an unearned positional contact")
 var row=s.sonar.history.back()
 t.check(row.direction.distance_to(Vector2.RIGHT)<.001 and row.band==-1 and row.classification=="MACHINERY" and row.confidence<.5,"passive evidence carries real direction, uncertain classification and unresolved depth")
 var quiet_count=s.sonar.history.size();s.units[0].vel=Vector2(96,0);s.sonar.clock=0;Sonar.advance(s,0.)
 t.check(s.sonar.history.size()==quiet_count,"actual own motion masks the distant passive arrival")
 s=fixture();s.units[1].alive=true;s.units[1].pos=Vector2(300,400);tick(s,.7)
 t.check(s.sonar.fixes.has(0) and s.contacts.get(0,{}).get("source")=="triangulation","independent drone rays produce a separately labelled positional fix")
 t.check(s.contacts[0].pos.distance_to(Vector2(600,700))<1 and s.contacts[0].get("band")==-1,"triangulation constrains the intersection without claiming hidden band or role")
 s=fixture();tick(s,.7);s.units[0].pos=Vector2(250,500);tick(s,.7)
 t.check(s.sonar.fixes.has(0),"movement supplies an independent triangulation baseline")
 s=fixture();s.command("sonar_mode",{"sector":"forward","power":"low"});s.units[0].angle=PI
 t.check(s.command("ping") and not s.sonar.pending.any(func(p):return p.kind=="echo"),"selected forward sector excludes a rear reflector")
 s=fixture();var reserve=s.oxygen;s.command("ping");var emitted=s.sirens[0].pos
 t.check(s.oxygen<reserve and s.contacts.is_empty() and s.sonar.pending.size()==1,"pulse spends reserve and has no instantaneous positional return")
 var copy=Sim.new();t.check(copy.restore(s.snapshot()),"emission-time pending return saves before arrival")
 s.sirens[0].pos=Vector2(1100,500);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
 tick(s,2.4)
 t.check(s.contacts.has(0) and s.contacts[0].pos==emitted and s.contacts[0].time==0 and s.contacts[0].source=="active","delayed echo remains its old emission-time position and timestamp")
 tick(copy,2.4)
 t.check(copy.contacts.get(0,{}).get("source")=="active","restored pending return is physically delivered without a new pulse")
 s=fixture();s.sirens[0].pos=Vector2(850,700);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
 s.command("ping");t.check(s.sonar.pending.is_empty(),"default low power cannot resolve a600m reflector")
 s.ping_time=0;s.command("sonar_mode",{"sector":"all","power":"high"});s.command("ping")
 t.check(s.sonar.pending.size()==1,"high power buys a real longer-range return")
 s=fixture();s.mission.rocks=[Rect2(400,0,80,960)];s._build_navigation();s._configure_terrain();s._configure_depth_charts();s.command("ping")
 t.check(s.sonar.pending.is_empty(),"opaque full-height geometry blocks active reflection")
 s=fixture();s.sirens[0].pos=Vector2(390,700);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
 tick(s,.4);t.check(s.sirens[0].lock>.3,"middle guard starts with legitimately seen player")
 t.check(s.command("depth",{"band":2}),"depth transition starts while exposed")
 tick(s,.5);t.check(s.sirens[0].get("known_band")==2,"visible transition legitimately reveals intended depth")
 s.units[0].pos=Vector2(250,900);s.sirens[0].stun=0;s.sirens[0].route=[]
 var observed_band=s.sirens[0].known_band;s.units[0].band=0;s.units[0].transition={}
 tick(s,.3);t.check(s.sirens[0].known_band==observed_band,"lost sight never reads a hidden new player band")
 s=fixture();s.units[0].band=2;s._use_band(2);s.sirens[0].pos=Vector2(350,700);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
 tick(s,1);t.check(s.sirens[0].lock==0 and s.hull==100,"different-band guard cannot fire a planar beam through thermal separation")
 s.sirens[0].known_band=2;s.sirens[0].attention_time=10.;s.sirens[0].last_known=s.units[0].pos
 s.paused=false
 for n in roundi(4.2*60):
  s.advance(1./60);s.outcome="";s.hull=100.0 # beam now vaporizes; this test only tracks the guard following depth, so keep the dive running
 s.paused=true
 t.check(s.sirens[0].band==2 and s.sirens[0].lock>0,"guard can deliberately follow acquired depth and resume its ordinary attack")
 s=Sim.new();s.start(0)
 t.check(not Depth.clear(s,Vector2(560,480),Vector2(560,480),1,12) and Depth.clear(s,Vector2(560,480),Vector2(560,480),2,24),"authored deep passage passes beneath physically solid middle shelf")
 t.check(not Depth.clear(s,Vector2(550,650),Vector2(550,650),0,12) and Depth.clear(s,Vector2(550,650),Vector2(550,650),1,24),"shallow sill creates its own real clearance tradeoff")
 var plan=[{"pos":Vector2(360,650),"stop":true,"mode":"silent"}]
 s.command("route",{"point":plan[0].pos});var goals=s.route_goals();s.command("depth",{"band":2});var partial=s.snapshot();var restored=Sim.new()
 t.check(restored.restore(partial),"pause during ordered descent roundtrips all chart and transition state")
 tick(restored,4.1);t.check(restored.route_goals().size()==goals.size() and restored.route_goals()[0].pos==goals[0].pos,"new band recompiles public course while preserving operator destination")
 var invalid=partial.duplicate(true);invalid.units[0].transition.remaining=5.
 t.check(not Sim.valid_snapshot(invalid),"invalid transition duration rejects")
 invalid=partial.duplicate(true);invalid.sonar.pending=[{"kind":"echo","due":INF}]
 t.check(not Sim.valid_snapshot(invalid),"nonphysical pending echo rejects")
 invalid=partial.duplicate(true);invalid.mission.depth_charts[2].clear_cells[Vector2i(999,999)]=true
 t.check(not Sim.valid_snapshot(invalid),"out-of-world measured depth chart rejects")
 # A fitted drone's actual wreck stays at its own depth, and can be winched there.
 s=Sim.new();s.start(0,"endurance",{"fitted":{"quietus":"","drone_a":"drone_survey_array","drone_b":""}})
 # Resolve catalog's actual passive-array identifier rather than invent a module.
 var item=s.mission.module_recovery.modules.keys()[0] if not s.mission.module_recovery.modules.is_empty() else ""
 if not item.is_empty():
  s.units[1].band=2;s.units[1].pos=Vector2(300,800);s.units[1].alive=false;tick(s,.1)
  t.check(s.salvage_sites().any(func(site):return site.item==item and site.band==2),"known lost module retains its actual deep wreck band")
  s.units[0].pos=Vector2(300,800);s.units[0].vel=Vector2.ZERO
  t.check(not s.command("salvage",{"item":item}),"middle craft cannot winch co-located deep cargo")
  s.units[0].band=2;s._use_band(2)
  t.check(s.command("salvage",{"item":item}),"craft in wreck band can recover its physical cargo")
  tick(s,4.1);t.check(s.module_recovery_status().cargo[0].has(item) and Sim.valid_snapshot(s.snapshot()),"deep module winch completes and saves current custody")

 s=fixture();s.units[0].hold="CONTACT";s.command("depth",{"band":2})
 t.check(s.units[0].hold=="CONTACT","depth order preserves an independent conditional hold")
 s=Sim.new();s.start(10);s.units[0].pos=s.Chain.layout(s.mission).inlet;s.units[0].vel=Vector2.ZERO;s.Consequences.observe(s,true)
 if s.command("chain_power",{"mode":"connect"}):
  t.check(s.command("depth",{"band":2}) and Sim.valid_snapshot(s.snapshot()) and s.mission.warning_chain.power!="umbilical","paused descent immediately releases physical shore power and saves coherently")
 else:t.check(false,"local shore-power depth fixture can actually connect")

 s=Sim.new();s.start(0);s.mission.depth_geometry[1]={"rocks":[]};s._build_navigation()
 t.check(not s.blocked(Vector2(560,480),12),"explicit middle-band override drives physical navigation too")
 s=fixture();s.units[0].pos=Vector2(250,500);s.sirens[0].pos=Vector2(650,500);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
 s.mission.rocks=[Rect2(450,480,20,40)];s._build_navigation();s._configure_terrain();s._configure_depth_charts();s.command("sonar_mode",{"sector":"all","power":"high"});s.command("ping")
 var indirect=s.sonar.pending.filter(func(packet):return packet.kind=="echo" and not packet.direct)
 t.check(not indirect.is_empty() and absf(indirect[0].get("direction",Vector2.RIGHT).y)>.01,"diffracted echo records actual corner arrival bearing instead of hidden true bearing")
 s=fixture();s.units[1].alive=true;s.units[1].pos=Vector2(350,450)
 var indistinct=s.sirens[0].duplicate(true);indistinct.pos=Vector2(800,400);indistinct.home=indistinct.pos;indistinct.goal=indistinct.pos;s.sirens.append(indistinct)
 tick(s,.7)
 t.check(s.sonar.history.any(func(row):return row.enemy==1) and s.sonar.fixes.is_empty(),"actually received indistinguishable motor tones retain ambiguity instead of false triangulation")
 invalid=partial.duplicate(true);invalid.units[0].erase("band")
 t.check(not Sim.valid_snapshot(invalid),"older snapshots with no physical band reject without migration")
 s=fixture();s.units[0].pos=s.mission.extraction;s.units[0].band=2
 for objective in s.mission.objectives:objective.captured=true
 tick(s,.1);t.check(s.outcome.is_empty(),"a deep craft cannot extract through a middle recovery mouth")
 s.units[0].band=1;tick(s,.1)
 t.check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"settled middle recovery remains finishable and restorable")
 var heard=preload("res://src/audio/received_cues.gd").new()
 var event={"type":"sweep_received","receiver":0,"direction":Vector2.LEFT,"time":1.}
 t.check(heard.take(event,1,1.,true).is_empty() and not heard.take(event,0,1.,true).is_empty() and heard.take(event,0,1.1,true).is_empty(),"sweeper audio belongs only to its actual receiver and does not replay history")
 s=fixture();s.units[1].alive=true;s.units[1].pos=s.units[0].pos;s.units[1].band=2;s.command("select",{"unit":1});s.command("emp")
 t.check(s.noises.back().get("band")==2,"co-located craft in different bands retain the actual emitter's acoustic depth")
 s=fixture();s.sirens[0].pos=Vector2(350,700);s._observe();s.command("knock",{"target":0})
 var shot=s.snapshot();shot.projectiles[0].band=3
 t.check(not Sim.valid_snapshot(shot),"an impossible torpedo band cannot enter a current save")
 s=fixture();s.units[0].band=2;s._use_band(2);s.sirens[0].pos=Vector2(350,700);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos;s.command("ping")
 tick(s,.8)
 t.check(s.sonar.history.any(func(row):return row.kind=="echo" and row.band==1) and s.contacts[0].source=="optical" and s.contacts[0].time>0,"cross-layer echo returns to emission band without replacing newer optical knowledge")
