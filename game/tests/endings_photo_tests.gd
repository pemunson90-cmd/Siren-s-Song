extends SceneTree
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Ending=preload("res://src/campaign/endings_photo.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 for id in [30,31]:
  var d=Catalog.definition(id)
  check(not d.is_empty(),"final operation registered "+str(id))
  if d.is_empty():continue
  check(Catalog.valid_definition(d),"final operation schema "+str(id))
  check(d.prerequisites==([25] if id==30 else [30]),"recovered prerequisite "+str(id))
  var s=Sim.new();s.start(id)
  check(Sim.valid_snapshot(s.snapshot()),"new mission active save valid "+str(id))
  var restored=Sim.new();check(restored.restore(s.snapshot()),"new mission active save restores "+str(id))
  check(s.mission.objectives.size()==2 and s.mission.objectives[1].optional,"bonus photo optional "+str(id))
  var o=s.mission.objectives[0]
  s.units[0].pos=o.pos+Vector2(-120,0);s.units[0].vel=Vector2.ZERO;s.units[0].angle=0.
  check(s.Depth.clear(s,s.units[0].pos,o.pos,1,12),"bare core viewpoint in physical water "+str(id))
  check(s.command("frame",{"mode":"tight","focus":o.optical}),"frame core with ordinary control "+str(id))
  check(s.command("camera"),"begin core exposure "+str(id))
  step(s,6.)
  check(o.captured,"bare core photo secured "+str(id))
  check(not s.mission.objectives[1].captured and s.all_records(),"optional unshot film cannot gate recovery "+str(id))
  s.units[0].pos=s.mission.extraction;s.units[0].vel=Vector2.ZERO
  step(s,1.)
  check(s.outcome=="won" and s.mission.recovered,"ordinary physical recovery "+str(id))
  check(Sim.valid_snapshot(s.snapshot()),"recovered final operation snapshot valid "+str(id))
 var path="res://src/campaign/endings_photo.gd"
 check(ResourceLoader.exists(path),"derived photo ending module exists")
 for thread in ["deep","shelf"]:
  for route in ["concealed","overt"]:
   var p=progress(thread,route)
   var old=preload("res://src/campaign/endings.gd").resolve(p)
   check(Campaign.valid(p) and not old.is_empty(),"legacy fork still valid")
   check(Ending.resolve(p,{}).is_empty(),"old flow unchanged before final pair")
   p.completed.append_array([14,15,16,17,18,19,22,23,24,25])
   check(Campaign.valid(p) and Catalog.accessible(30,p) and not Catalog.accessible(31,p),"recovered25 opens only first final operation")
   p.completed.append(30)
   check(Campaign.valid(p) and Ending.resolve(p,{}).is_empty() and Catalog.accessible(31,p),"first final recovery is not the ending")
   p.completed.append(31)
   var final=Ending.resolve(p,{})
   check(Campaign.valid(p) and final.id==old.id and final.photo_variant=="blind","all four endings retained without film gate")
   check(Ending.resolve(p,{},false).is_empty(),"wall switch restores old ending flow")
   var informed=Ending.resolve(p,{"siren_patroller":{"q":.1},"siren_hunter":{"q":.8},"siren_sentinel":{"q":.6}})
   check(informed.photo_variant=="studied" and informed.variant!=final.variant,"observed Siren keys select a film variant")
   for key in ["glass_choice","choir_choice","choir_people","choir_plant"]:
    var changed=p.duplicate(true);changed.facts[key]="recovered"
    check(Ending.resolve(changed,{}).variant!=final.variant,"choice fact contributes to variant "+key)
 var archive={"b":{"name":"B","shots":[shot(.8,true,"first"),shot(.9,false,"unusable")]},"a":{"name":"A","shots":[shot(.2,true,"old"),shot(.8,true,"best")]},"empty":{"name":"NO FILM"}}
 var before=archive.duplicate(true);var wall=Ending.frames(archive)
 check(wall.size()==2 and wall[0].key=="a" and wall[1].key=="b","deterministic best usable subject ordering")
 check(wall[0].captions==["best"] and wall[1].captions==["first"],"captions come from chosen recorded findings only")
 check(archive==before,"wall never mutates archived film")
 check(Ending.frames({}).is_empty(),"empty archive safe")
 var many={}
 for n in 20:many[str(n)]={"shots":[shot(n/20.,true,str(n))]}
 check(Ending.frames(many).size()==Ending.MAX_FRAMES,"wall rendering work bounded")
 print("PHOTO ENDINGS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func step(s,seconds):
 s.paused=false
 for n in ceili(seconds*60):s.advance(1./60.)
func progress(thread,route)->Dictionary:
 return {"version":2,"route":thread,"routes":[thread],"facts":{thread:"Recovered branch account","confluence_route":route},"completed":[6,7 if thread=="deep" else 8,9 if thread=="deep" else 10,11,12 if route=="concealed" else 13],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":thread}
func shot(q,usable,label)->Dictionary:
 return {"q":q,"usable":usable,"frame":{},"findings":[{"label":label}]}
