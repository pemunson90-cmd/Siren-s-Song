extends RefCounted
const Sim=preload("res://src/simulation/simulation.gd")
static func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
static func target_fixture(band:int):
 var s=Sim.new();s.start(4);s.contacts={}
 s.units[0].pos=Vector2(1280,820);s.units[0].band=band;s.units[0].angle=0
 for id in [1,2]:s.units[id].alive=false
 s.sirens=s.sirens.filter(func(enemy):return enemy.type=="sweeper");s.sirens[0].pos=Vector2(1380,820);s.sirens[0].band=band;s.sirens[0].transition={}
 s.command("select",{"unit":0});s._observe()
 return s
static func buffer_fixture():
 var s=Sim.new();s.start(2);s.sirens=[]
 s.units[0].pos=Vector2(550,540);s.units[0].band=2
 s.units[1].pos=Vector2(550,500);s.units[1].band=2;s.units[1].alive=false
 s.mission.objectives[0].captured=true;s.mission.blackwater_delivery.carriers[1]=[0]
 s.Depth.cargo_bands(s);s.Delivery.losses(s);s.command("select",{"unit":0})
 return s
static func run(t):
 audit_local_work(t)
 for band in [0,2]:
  var s=target_fixture(band)
  t.check(s.contacts.has(0) and s.knockdown_targets().size()==1,"same-band authored Well optical target offered in band "+str(band))
  var aims=s.knockdown_targets();var enemies=s.sirens;s.sirens=[]
  t.check(s.knockdown_targets()==aims,"preview independent of hidden live roster in band "+str(band));s.sirens=enemies
  t.check(s.command("knock",{"target":0}) and s.projectiles[0].band==band,"same-band shot physically admitted in band "+str(band))
 var s=target_fixture(2);var preview=s.knockdown_targets();var truth=s.sirens[0].duplicate(true)
 s.sirens[0].band=0;s.sirens[0].pos=Vector2(100,100);s.sirens[0].transition={"to":1,"remaining":2.};s.sirens[0].stun=4.
 t.check(s.knockdown_targets()==preview,"preview cannot consult hidden enemy position depth transition or stun")
 s.sirens[0]=truth;s.mission.depth_geometry[2].structures=[Rect2(1320,800,10,40)]
 t.check(s.knockdown_targets().is_empty(),"band-local terrain blocks the cached preview")
 s=target_fixture(2);s.sirens[0].band=1;s.units[1].alive=true;s.units[1].pos=s.units[0].pos;s.units[1].band=1;s._observe()
 t.check(s.knockdown_targets().is_empty(),"MIDDLE allied observation cannot offer an unreachable guard to DEEP Quietus")
 t.check(not s.command("knock",{"target":0}) and s.tools.knock==2 and s.projectiles.is_empty(),"cross-band rejection spends no ammunition")
 s=target_fixture(2);s.units[0].silent=true;s.sirens[0].pos=Vector2(1425,820);s.units[1].alive=true;s.units[1].band=2;s.units[1].pos=Vector2(1400,820);s.mission.darkness=true;s.mission.thermal_revision=1;s.mission.thermal_band=2;s.mission.thermal_fronts=[{"area":Rect2(1320,780,30,80),"transmission":.5,"close_range":40.}];s._observe()
 t.check(s.contacts[0].seen_by==[1] and s.knockdown_targets().size()==1 and s.command("knock",{"target":0}),"same-band ally may legitimately acquire a target through the shared fleet observation")
 for band in [1,2]:
  s=target_fixture(band);s.sirens[0].band=1;s.sirens[0].transition={"to":2,"remaining":3.};s._observe()
  t.check(s.knockdown_targets().size()==1 and s.command("knock",{"target":0}),"target transition reachable in occupied band "+str(band))
 s=target_fixture(1);s.units[0].transition={"to":2,"remaining":3.};s.sirens[0].band=2;s._observe()
 t.check(s.knockdown_targets().size()==1 and s.command("knock",{"target":0}) and s.projectiles[0].band==2,"transitioning Quietus launches into the shared occupied band")
 for invalid in ["depth","terrain","stun","range","stale"]:
  s=target_fixture(2)
  if invalid=="depth":s.sirens[0].band=0
  if invalid=="terrain":s.mission.depth_geometry[2].structures=[Rect2(1320,800,10,40)]
  if invalid=="stun":s.sirens[0].stun=3.
  if invalid=="range":s.sirens[0].pos.x+=500
  if invalid=="stale":s.contacts[0].time=-1.
  t.check(not s.command("knock",{"target":0}) and s.tools.knock==2 and s.projectiles.is_empty(),"changed "+invalid+" rejects physical launch without spend")
 s=target_fixture(2);s.contacts={0:{"pos":s.sirens[0].pos,"time":s.elapsed,"band":-1,"mode":"TRIANGULATED"}}
 t.check(s.knockdown_targets().is_empty(),"unresolved-depth triangulation cannot claim torpedo reachability")
 for selection in [0,2]:
  s=buffer_fixture();t.check(s.command("salvage",{"item":"blackwater_buffer_1"}),"DEEP Blackwater winch starts")
  s.command("select",{"unit":selection});tick(s,4.2)
  t.check(0 in s.mission.blackwater_delivery.aboard and s.mission.blackwater_delivery.wrecks.is_empty(),"DEEP Blackwater recovery survives selection "+str(selection))
 s=buffer_fixture();s.command("salvage",{"item":"blackwater_buffer_1"});s.Delivery.tick(s,1.)
 s.units[0].vel=Vector2(3,0);s.Delivery.tick(s,.1)
 t.check(s.mission.blackwater_delivery.jobs[0].elapsed==0.,"real recovery motion resets accumulated winch time")
 for invalid in ["route","loss","depth","transition","terrain","custody"]:
  s=buffer_fixture();s.command("salvage",{"item":"blackwater_buffer_1"});tick(s,.5)
  if invalid=="route":s.command("route",{"point":Vector2(550,650)})
  if invalid=="loss":s.units[0].alive=false
  if invalid=="depth":s.units[0].band=1
  if invalid=="transition":s.units[0].transition={"to":1,"remaining":4.}
  if invalid=="terrain":s.mission.depth_geometry[2].structures=[Rect2(530,515,40,10)]
  if invalid=="custody":s.mission.depth_cargo.blackwater_buffer_1=1
  tick(s,4.2)
  t.check(s.mission.blackwater_delivery.jobs[0].is_empty() and 0 not in s.mission.blackwater_delivery.aboard,"real "+invalid+" interruption cannot recover Blackwater buffer")
static func audit_local_work(t):
 # Isolated geometry exposes accidental use of another selected craft's band.
 var s=Sim.new();s.start(12);s.sirens=[]
 var pos=s.Witness.BERTH;s.units[0].pos=pos+Vector2(0,40);s.units[0].band=2
 s.mission.depth_cargo.witness_capsule=2
 for source in s.mission.signal_sources:
  if source.id=="witness_packet":source.located=true
 s.command("select",{"unit":0})
 s.mission.depth_geometry={1:{"rocks":[Rect2(pos+Vector2(-20,15),Vector2(40,10))]},2:{"rocks":[]}}
 s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 t.check(s.command("salvage",{"item":"witness_capsule"}),"witness winch starts in its custody band")
 s.command("select",{"unit":2});s.Witness.tick(s,4.2)
 t.check(s.mission.witness_evacuation.state=="carried","ongoing witness recovery ignores peer selection geometry")
 for kind in ["module","witness"]:
  s=Sim.new();s.start(12,"endurance",{"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}});s.sirens=[]
  pos=s.Witness.BERTH;s.units[0].pos=pos+Vector2(0,40)
  if kind=="module":
   s.units[1].pos=pos;s.units[1].alive=false;s.ModuleRecovery.tick(s,0.)
  else:
   for source in s.mission.signal_sources:
    if source.id=="witness_packet":source.located=true
  var item="drone_sampler" if kind=="module" else "witness_capsule"
  t.check(s.command("salvage",{"item":item}),kind+" ongoing interruption fixture starts")
  s.mission.depth_cargo[item]=2
  if kind=="module":s.ModuleRecovery.tick(s,.1)
  else:s.Witness.tick(s,.1)
  t.check(s.salvage_sites().any(func(site):return site.item==item) and s.module_recovery_status().jobs[0].is_empty() and not s.Witness.busy(s,0),kind+" custody change interrupts work")
 s=Sim.new();s.start(10);s.sirens=[];pos=s.Chain.layout(s.mission).inlet
 s.units[0].pos=pos+Vector2(0,30);s.units[0].hold="HOLD"
 s.mission.warning_chain.power="umbilical";s.mission.warning_chain.unit=0
 s.mission.depth_geometry={2:{"rocks":[Rect2(pos+Vector2(-20,10),Vector2(40,10))]}}
 s._build_navigation();s.units[2].band=2;s.command("select",{"unit":2});s.Chain.tick(s)
 t.check(s.mission.warning_chain.power=="umbilical","MIDDLE plant connection ignores selected DEEP peer terrain")
