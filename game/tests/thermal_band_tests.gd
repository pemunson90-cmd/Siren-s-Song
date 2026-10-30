extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Sonar=preload("res://src/simulation/advanced_sonar.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture():
 var s=Sim.new();s.start(3)
 s.mission.rocks=[];s.mission.structures=[];s.mission.depth_geometry={}
 s._build_navigation()
 return s
func _initialize():
 var s=fixture()
 var a=Vector2(860,840);var b=Vector2(1080,840)
 for band in [0,1,2]:
  var paths=s.band_acoustics[band].arrivals(a,b,350.)
  check(paths.is_empty()==(band==1),"default layer masks MIDDLE only, band %d"%band)
 # Exercise actual Siren hearing, not just propagation geometry.
 s.units[0].pos=b;s.units[0].vel=Vector2.ZERO;s.units[1].alive=false;s.units[2].alive=false
 var guard=s.sirens[0];guard.pos=a;guard.patrol=0
 for depth in [0,1,2]:
  guard.band=depth;s.noises=[];s._noise(b,350.,"DECOY",2.,depth)
  check(s._heard_arrival(guard).is_empty()==(depth==1),"Siren hears outside default layer, band %d"%depth)
 # A MIDDLE listener must not grant its thermal cover to an off-layer craft.
 guard.band=1;guard.transition={};guard.pos=Vector2(960,840)
 for source_band in [0,1,2]:
  s.noises=[];s._noise(Vector2(1360,840),1100.,"CAMERA",2.,source_band)
  check(s._heard_arrival(guard).is_empty()==(source_band==1),"Siren hearing uses emitter band too, band %d"%source_band)
 guard.pos=a;s.noises=[];s._noise(b,900.,"CAMERA",2.,1)
 s.units[0].band=1;s.units[0].transition={"to":2,"remaining":2.}
 var emitter=s.units[0]
 check(not Sim.Thermal.arrivals(s,guard,b,350.,emitter).is_empty(),"emitter crossing out of layer remains exposed")
 emitter.band=2;emitter.transition={"to":1,"remaining":2.}
 check(not Sim.Thermal.arrivals(s,guard,b,350.,emitter).is_empty(),"emitter entering layer stays exposed until settled")
 emitter.transition={};emitter.band=1
 guard.band=1;guard.transition={"to":0,"remaining":2.};s.noises=[];s._noise(b,350.,"DECOY",2.,1)
 check(not s._heard_arrival(guard).is_empty(),"Siren leaving layer hears in both occupied bands")
 guard.band=0;guard.transition={"to":1,"remaining":2.}
 check(not s._heard_arrival(guard).is_empty(),"Siren entering layer remains exposed")
 guard.transition={}
 s.mission["thermal_band"]=2;s._build_navigation()
 for depth in [0,1,2]:
  guard.band=depth;s.noises=[];s._noise(b,350.,"DECOY",2.,depth)
  check(s._heard_arrival(guard).is_empty()==(depth==2),"Siren hearing follows custom layer, band %d"%depth)
 for band in [0,1,2]:
  check(s.band_acoustics[band].arrivals(a,b,350.).is_empty()==(band==2),"explicit DEEP layer masks only DEEP, band %d"%band)
 var receiver={"pos":a,"band":2,"transition":{}}
 var source={"pos":b,"band":2,"transition":{}}
 check(Sonar.water_path(s,receiver,source,350.).is_empty(),"settled receiver pays its layer masking cost")
 receiver.transition={"to":1,"remaining":2.}
 check(not Sonar.water_path(s,receiver,source,350.).is_empty(),"transition uses its exposed receiving band too")
 receiver.band=1;receiver.transition={"to":2,"remaining":2.}
 check(not Sonar.water_path(s,receiver,source,350.).is_empty(),"entering a layer does not grant cover until settled")
 s=fixture();s.units[1].alive=false;s.units[2].alive=false
 var u=s.units[0];var enemy=s.sirens[0]
 u.pos=a;enemy.pos=b;enemy.lock=0.;enemy.target=-1;enemy.stun=0.
 for band in [0,1,2]:
  u.band=band;enemy.band=band
  check(s.contact_visible(enemy)==(band!=1),"passive contact follows the layer band %d"%band)
  check(s.passive_receivers(b,band).has(0)==(band!=1),"scout provenance follows the layer band %d"%band)
 u.band=1;enemy.band=1;u.transition={"to":0,"remaining":2.};enemy.transition={"to":0,"remaining":2.}
 check(s.contact_visible(enemy),"passive contact uses unmasked shared band during transition")
 check(s.passive_receivers(b,0).has(0),"transition receiver can receive outside layer")
 s.mission.depth_geometry={0:{"structures":[Rect2(960,810,40,60)]}};s._build_navigation()
 check(not s.contact_visible(enemy),"occluded unmasked band cannot lend reception to a clear masked band")
 s.mission.depth_geometry={};s._build_navigation()
 var sender={"pos":a,"band":1,"transition":{}}
 var peer={"pos":b,"band":0,"transition":{}}
 var network=preload("res://src/simulation/acoustic_network.gd")
 check(network.link(s,sender,peer),"network sender uses unmasked peer receiving band")
 check(network.link(s,peer,sender),"off-layer sender cannot borrow the peer receiving layer")
 # Buoy hearing retains the moving emitter's exposed transition occupancy.
 s=fixture();s.units[1].alive=false;s.units[2].alive=false
 var mover=s.units[0];mover.pos=Vector2(1360,840);mover.band=1
 mover.vel=Vector2(78,0);mover["water_velocity"]=Vector2(78,0)
 var buoy=s.sirens[0];buoy.pos=Vector2(960,840);buoy.band=1
 check(network.heard(s,buoy).is_empty(),"settled moving emitter pays thermal masking at buoy")
 mover.transition={"to":2,"remaining":2.}
 check(not network.heard(s,buoy).is_empty(),"buoy hears exposed moving emitter transition")
 # A newly earned transitioning contact must reach its actual scout receiver.
 for origin in [0,1]:
  s=fixture();s.units[0].alive=false;s.units[1].alive=true;s.units[2].alive=false
  var drone=s.units[1];drone.pos=a;drone.band=origin;drone.transition={"to":1-origin,"remaining":2.}
  enemy=s.sirens[0];enemy.pos=b;enemy.band=origin;enemy.transition={"to":1-origin,"remaining":2.};enemy.lock=0.;enemy.target=-1;enemy.stun=0.
  s._observe()
  check(s.contacts.has(0) and s.contacts[0].seen_by==[1],"transition contact attributed once to actual drone receiver from band %d"%origin)
  check(preload("res://src/simulation/drone_operations.gd").local_contact(s.contacts,1,s.elapsed)==0,"scout consumes newly earned transition contact from band %d"%origin)
 # New-region carrier reception previously hardwired the MIDDLE graph.
 s=fixture();s.units[1].alive=false;s.units[2].alive=false;s.units[0].pos=a
 s.mission.expedition_revision=2;s.mission.signal_observations=[]
 s.mission.signal_sources=[{"pos":b,"id":"probe","label":"PROBE","located":true,"range":350.,"cadence":[]}]
 s.mission.next_signal_time=0.
 s.units[0].band=0
 preload("res://src/campaign/campaign_consequences.gd").observe(s,true)
 check(s.mission.signal_observations.size()==1,"carrier reception uses the unmasked receiver band")
 s.units[0].band=1;s.mission.signal_observations=[]
 preload("res://src/campaign/campaign_consequences.gd").observe(s,true)
 check(s.mission.signal_observations.is_empty(),"carrier reception still pays the MIDDLE layer loss")
 # The op8 watch reply likewise follows its actual receiving craft's band.
 s=Sim.new();s.start(8);s.mission.rocks=[];s.mission.structures=[];s.mission.depth_geometry={};s._build_navigation()
 s.units[1].alive=false;s.units[2].alive=false;s.units[0].pos=Vector2(800,1800);s.units[0].band=1
 s.elapsed=3.;s.mission.shelf_habitat.warned_at={"west":0.}
 preload("res://src/simulation/shelf_habitat.gd").tick(s)
 check(s.mission.shelf_habitat.receipts.is_empty(),"MIDDLE watch reply cannot bypass its layer")
 s.units[0].band=0;s.mission.shelf_habitat.next_reply=0.
 preload("res://src/simulation/shelf_habitat.gd").tick(s)
 check(s.mission.shelf_habitat.receipts==["west"],"SHALLOW watch reply uses the unmasked receiver path")
 s=fixture();var state=s.snapshot()
 state.mission["thermal_band"]=2
 var restored=Sim.new()
 check(restored.restore(state) and restored.snapshot()==state,"explicit band round-trips through existing mission state")
 state=s.snapshot();state.mission["thermal_band"]=-1
 check(not Sim.valid_snapshot(state),"negative layer band rejected")
 state.mission.thermal_band=3
 check(not Sim.valid_snapshot(state),"out-of-range layer band rejected")
 state.mission.thermal_band=1.0
 check(not Sim.valid_snapshot(state),"noninteger layer band rejected")
 state.mission.erase("thermal_revision");state.mission.erase("thermal_fronts");state.mission.thermal_band=1
 check(not Sim.valid_snapshot(state),"orphan layer band rejected")
 print("THERMAL BAND CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
