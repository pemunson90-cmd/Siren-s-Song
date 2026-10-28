extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Gear=preload("res://src/equipment/equipment_catalog.gd")
const Cache=preload("res://src/simulation/optional_cache.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const View=preload("res://src/presentation/optional_cache_view.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var s=Sim.new();s.start(39)
 check(s.mission.has("optional_cache"),"39 authors three physical optional cache pieces")
 if s.mission.has("optional_cache"):exercise(s)
 await touch_custody()
 print("OPTIONAL CACHE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func exercise(s):
 check(Sim.valid_snapshot(s.snapshot()),"new optional cache launch validates")
 var old=s.snapshot();old.mission.erase("optional_cache")
 check(Sim.valid_snapshot(old),"legacy39 without optional fields remains loadable")
 old.mission.erase("module_recovery")
 check(Sim.valid_snapshot(old),"legacy39 without cache or recovery fields remains loadable")
 for op in [37,38]:
  var legacy=Sim.new();legacy.start(op)
  check(not legacy.mission.has("optional_cache") and Sim.valid_snapshot(legacy.snapshot()),"prior site launch unchanged "+str(op))
 s.sirens=[] # Custody fixtures below; live-threat voyages are separate.
 var item=Cache.IDS[0];var p=Cache.pieces(s)[item];var u=s.units[0]
 check(not s.command("salvage",{"item":item}),"distant winch rejected")
 u.pos=p.pos;u.band=2
 check(not s.command("salvage",{"item":item}),"wrong depth rejected")
 u.band=1;u.vel=Vector2(2,0)
 check(not s.command("salvage",{"item":item}),"moving winch rejected at2m/s")
 u.vel=Vector2.ZERO;u.transition={"to":2,"elapsed":0.}
 check(not s.command("salvage",{"item":item}),"depth transition rejected")
 u.transition={}
 s.mission.structures.append(Rect2(u.pos-Vector2(5,5),Vector2(10,10)))
 check(not s.command("salvage",{"item":item}),"terrain blocked winch rejected")
 s.mission.structures.clear()
 check(s.command("salvage",{"item":item}),"settled local winch starts")
 check(not s.command("salvage",{"item":item}) and not s.command("camera"),"single craft cannot double claim or expose during winch")
 s.Cache.tick(s,1.5)
 check(p.state=="site" and s.Cache.busy(s,0),"incomplete winch grants no cargo")
 roundtrip(s,"partial audible winch")
 var pending=s.snapshot()
 for dependency in [null,0,{}, {"modules":{},"jobs":[]}, {"modules":{},"jobs":[null,{},{}]}]:
  var invalid=pending.duplicate(true)
  if dependency==null:invalid.mission.erase("module_recovery")
  else:invalid.mission.module_recovery=dependency
  check(not Cache.valid(invalid) and not Sim.valid_snapshot(invalid),"active cache winch rejects missing or malformed recovery dependency "+str(dependency))
 u.vel=Vector2(2,0);s.Cache.tick(s,.1)
 check(s.mission.optional_cache.jobs[0].elapsed==0.,"motion resets winch progress")
 u.vel=Vector2.ZERO
 check(s.command("route",{"point":u.pos+Vector2(100,0)}) and not Cache.busy(s,0),"ordinary route releases winch")
 u.route=[];u.erase("route_plan");u.hold=""
 check(s.command("salvage",{"item":item}),"interrupted winch restarts")
 s.Cache.tick(s,4.)
 check(p.state=="cargo" and p.carrier==0 and s.ModuleRecovery.carried(s,0)==1,"completed winch assigns real shared cargo")
 check(not s.command("cache_action",{"action":"unload"}),"remote unload rejected")
 u.pos+=Vector2(40,0);u.band=2;s.Cache.tick(s,0.)
 check(p.pos==u.pos and p.band==2,"cargo follows physical carrier and depth")
 check(s.command("cache_action",{"action":"drop"}) and p.state=="wreck" and p.pos==u.pos and p.band==2,"drop preserves actual physical depth and position")
 s.mission.depth_cargo[item]=2
 check(s.command("salvage",{"item":item}),"dropped piece can be winched at recorded depth")
 s.Cache.tick(s,4.)
 check(p.state=="cargo" and p.carrier==0,"dropped piece recovered without duplicate")
 u.band=1;u.pos=s.mission.corridors[0].pos;s.Cache.tick(s,0.)
 check(s.command("cache_action",{"action":"unload"}) and p.state=="received" and s.outcome.is_empty() and not s.mission.objectives[0].captured,"first receipt frees capacity before photo/victory")
 check(s.ModuleRecovery.carried(s,0)==0 and not s.mission.expedition_facts.has(Cache.FACT),"partial receipt has no full-account reward")
 check(not s.command("cache_action",{"action":"unload"}),"repeat unload cannot receive twice")
 roundtrip(s,"one received, two at site")
 # Mixed custody and local transfer with a real occupied shared place.
 s.selected=1;s.units[1].pos=Cache.pieces(s)[Cache.IDS[1]].pos
 check(s.command("salvage",{"item":Cache.IDS[1]}),"standard drone winches next piece")
 s.Cache.tick(s,4.)
 var drone=s.units[1];u.pos=drone.pos;u.vel=Vector2.ZERO
 check(s.command("cache_action",{"action":"transfer"}) and Cache.carried(s,0)==1 and Cache.carried(s,1)==0,"local transfer moves custody to Quietus")
 check(s.command("salvage",{"item":Cache.IDS[2]}),"drone winches third piece")
 s.Cache.tick(s,4.)
 roundtrip(s,"received plus two living carriers")
 check(View.cargo(s,0).size()==1 and View.cargo(s,1).size()==1,"cargo presentation names both carriers' exact pieces")
 drone.pos+=Vector2(20,0);drone.band=2;drone.alive=false;s.Cache.tick(s,0.)
 var lost=Cache.pieces(s)[Cache.IDS[2]]
 check(lost.state=="wreck" and lost.carrier==-1 and lost.pos==drone.pos and lost.band==2,"lost carrier leaves recoverable piece at actual depth")
 roundtrip(s,"received, aboard, lost-carrier wreck")
 var base=s.snapshot()
 var malformed=base.duplicate(true);malformed.mission.optional_cache.pieces[Cache.IDS[0]].carrier=0
 check(not Sim.valid_snapshot(malformed),"receipt cannot simultaneously be aboard")
 malformed=base.duplicate(true);malformed.mission.optional_cache.pieces[Cache.IDS[2]].state="cargo";malformed.mission.optional_cache.pieces[Cache.IDS[2]].carrier=1
 check(not Sim.valid_snapshot(malformed),"archive refuses cargo on lost carrier")
 malformed=base.duplicate(true);malformed.mission.optional_cache.pieces[Cache.IDS[2]].pos=Vector2(INF,0)
 check(not Sim.valid_snapshot(malformed),"nonfinite physical custody rejected")
 malformed=base.duplicate(true);malformed.mission.optional_cache.pieces["invented"]=malformed.mission.optional_cache.pieces[Cache.IDS[2]].duplicate()
 check(not Sim.valid_snapshot(malformed),"invented fourth piece rejected")
 malformed=base.duplicate(true);malformed.mission.expedition_facts[Cache.FACT]=Cache.NOTE
 check(not Sim.valid_snapshot(malformed),"unreceived account cannot be forged")
 for fit in [{},{"hull":"fast"},{"chassis_a":"heavy"}]:
  var load=Sim.new();load.start(39,"endurance",{"fitted":Gear.canonical(fit)});load.sirens=[]
  load.selected=1 if fit.has("chassis_a") else 0
  var craft=load.units[load.selected];craft.pos=Cache.POS+Vector2(20,0)
  var room=load.ModuleRecovery.capacity(load,load.selected)
  for n in 3:
   var ok=load.command("salvage",{"item":Cache.IDS[n]})
   check(ok==(n<room),"actual free places decide pickup "+str(fit)+" / "+str(n))
   if ok:load.Cache.tick(load,4.)
  check(Cache.carried(load,load.selected)==mini(room,3),"no artificial frame gate "+str(fit))
  check(Sim.valid_snapshot(load.snapshot()),"loaded custody validates "+str(fit))
  if room>=3:
   roundtrip(load,"all pieces aboard "+str(fit))
   craft.pos=load.mission.corridors[0].pos;load.Cache.tick(load,0.)
   check(load.command("cache_action",{"action":"unload"}) and load.mission.expedition_facts.get(Cache.FACT)==Cache.NOTE,"full physical receipt earns exact account "+str(fit))
   roundtrip(load,"all pieces received "+str(fit))
 var full=Sim.new();full.start(39);full.sirens=[]
 full.units[0].pos=Cache.POS+Vector2(20,0)
 for n in 2:
  full.command("salvage",{"item":Cache.IDS[n]});full.Cache.tick(full,4.)
 var overloaded=full.snapshot();overloaded.mission.optional_cache.pieces[Cache.IDS[2]].state="cargo";overloaded.mission.optional_cache.pieces[Cache.IDS[2]].carrier=0
 check(not Sim.valid_snapshot(overloaded),"save rejects three pieces on a two-place craft")
 # Preserve ordinary one-artifact capacity and launch hardware accounting.
 var legacy=Sim.new();legacy.start(37)
 var a=legacy.mission.glass_reach.artifact;legacy.units[0].pos=a.pos;legacy.units[0].band=a.band
 check(legacy.command("glass_action",{"action":"recover"}),"legacy single material uses ordinary Reach order")
 legacy.Glass.tick(legacy,4.)
 check(a.state=="cargo" and legacy.ModuleRecovery.carried(legacy,0)==1,"legacy artifact retains one shared place")
 check(Sim.valid_snapshot(legacy.snapshot()),"legacy artifact custody validates")
 var fitted=Sim.new();fitted.start(39,"endurance",{"fitted":Gear.canonical({"chassis_a":"heavy","drone_a":"drone_sampler"})})
 check(fitted.ModuleRecovery.capacity(fitted,1)==3,"real fitted sampler consumes one Heavy cargo place")
 var mixed=Sim.new();mixed.start(39,"endurance",{"fitted":Gear.canonical({"drone_a":"drone_sampler"})})
 mixed.units[0].pos=Cache.POS+Vector2(20,0)
 mixed.command("salvage",{"item":Cache.IDS[0]});mixed.Cache.tick(mixed,4.)
 var hardware=mixed.mission.module_recovery.modules.drone_sampler
 hardware.state="salvage";hardware.unit=-1;hardware.pos=mixed.units[0].pos
 check(mixed.command("salvage",{"item":"drone_sampler"}),"actual launched hardware can share cache carriage")
 mixed.ModuleRecovery.tick(mixed,4.)
 check(mixed.ModuleRecovery.carried(mixed,0)==2 and not mixed.command("salvage",{"item":Cache.IDS[1]}),"real inactive module plus cache fills standard carriage")
 check(Sim.valid_snapshot(mixed.snapshot()),"mixed real hardware/cache custody validates")
func roundtrip(s,label):
 var store=Store.new();store.path="user://optional-cache-custody.save"
 var progress=Sim.Consequences.upgrade({"version":1,"route":"shelf","routes":["shelf"],"facts":{"shelf":"received"},"completed":[6,8]})
 var archive={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress,"active":s.snapshot()}
 check(Sim.valid_snapshot(archive.active),label+" snapshot valid")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 check(store.save(archive),label+" archive saved")
 var loaded=store.load_game();var restored=Sim.new()
 check(loaded.has("active") and restored.restore(loaded.active),label+" archive restored")
 if not restored.units.is_empty():check(restored.mission.optional_cache==s.mission.optional_cache,label+" exact pieces and jobs roundtrip")
func settle():
 for n in 6:await process_frame
func tap(button):
 var point=button.get_global_rect().get_center()
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new();event.position=point;event.index=0;event.pressed=pressed;root.push_input(event,true);await process_frame
 await settle()
func touch_custody():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://optional-cache-ui-%d.save"%dimensions.x
  g.completed=[0,1,2,3,4,5];g.unlocked=5
  g.expedition=Sim.Consequences.upgrade({"version":1,"route":"shelf","routes":["shelf"],"facts":{"shelf":"received"},"completed":[6,8]})
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(39);await settle()
  var h=g.mission_hud;var s=g.sim
  check(s.mission.id==39,"cache custody touch fixture launches actual39 "+str(dimensions))
  if s.mission.id==39:
   var p=Cache.pieces(s)[Cache.IDS[0]]
   s.units[0].pos=p.pos;s.units[0].vel=Vector2.ZERO;s.paused=true
   h.open("salvage",{"kind":"salvage","item":Cache.IDS[0],"name":"SHELF CACHE1","pos":p.pos});await settle()
   check(h.extra.salvage.visible and not h.extra.salvage.disabled and h.extra.salvage.size.y>=h.touch_height,"touch sized physical cache winch offered "+str(dimensions))
   await tap(h.extra.salvage)
   check(Cache.busy(s,0) and p.state=="site","injected touch starts actual winch without instant cargo "+str(dimensions))
   s.Cache.tick(s,4.)
   check(p.state=="cargo" and p.carrier==0,"touch winch finishes with exact carrier custody "+str(dimensions))
   s.units[0].pos=s.mission.corridors[0].pos;s.Cache.tick(s,0.);g._refresh()
   h.open("craft",{"kind":"craft","unit":0,"pos":s.units[0].pos});await settle()
   await tap(h.extra.cache_menu)
   check(h.page=="cache" and h.extra.cache_unload.visible and not h.extra.cache_unload.disabled and h.extra.cache_unload.size.y>=h.touch_height,"touch opens contextual local unload "+str(dimensions))
   await tap(h.extra.cache_unload)
   check(p.state=="received" and Cache.carried(s,0)==0 and s.outcome.is_empty(),"injected unload receives cargo and keeps photographic job running "+str(dimensions))
  g.queue_free();await settle()
