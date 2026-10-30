extends RefCounted
# Optional reconnaissance in already charted regions. No new simulation rules.
const IDS=[37,38,39,40]
const TITLES={37:"OPTIONAL / Sorley's Trawler",38:"OPTIONAL / Deep Thread",39:"OPTIONAL / Shelf Thread",40:"OPTIONAL / Confluence Survey"}
const T=preload("res://src/campaign/encounters/terrain.gd")
const W=preload("res://src/campaign/encounters/work_sites.gd")
const P=preload("res://src/campaign/photo_ops.gd")
const Layouts=preload("res://src/campaign/encounters/optional_layouts.gd")
const Resolution=preload("res://src/campaign/resolution_missions.gd")
const FleetSites=preload("res://src/campaign/encounters/fleet_sites.gd")
static func supports_config(c:Dictionary)->bool:
 return c.size()==2 and c.get("history")==true and c.get("source_id",-1) in IDS
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func key(id:int)->String:return "glass_record_"+str(id)
static func entries()->Array:
 var result=[]
 for id in IDS:
  var k=key(id)
  result.append({"id":id,"factory":"res://src/campaign/optional_operations.gd","config":{"source_id":id,"history":true},"behaviors":["signals_v2","history","glass_reach"]+(["thermal"] if id==39 else []),"prerequisites":[{37:15,38:7,39:8,40:11}[id]],"facts":[k,k+"_bonus"],"records":[k,k+"_bonus"]+(["optional_40_sluice"] if id==40 else (["optional_38_sluice"] if id==38 else [])),"campaign":true,"route":{38:"deep",39:"shelf"}.get(id,""),"required_facts":{}})
 for entry in result:
  var work_key={37:"optional_37_wellhead_pump",39:"optional_39_service_reed"}.get(entry.id,"")
  if not work_key.is_empty():entry.facts.append(work_key);entry.records.append(work_key)
  entry.facts.append_array(FleetSites.records(entry.id));entry.records.append_array(FleetSites.records(entry.id))
 return result
static func make(id:int,history:Dictionary={})->Dictionary:
 return build({"source_id":id,"history":true},history)
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var id:int=c.source_id;var k=key(id)
 var m={"id":id,"title":TITLES[id],"depth":{37:4100,38:4860,39:2900,40:4720}[id],"darkness":false,"region_revision":1,"acoustic_revision":1,"expedition_revision":2,"rocks":[],"structures":[],"sirens":[],"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[k],"launch_context":history.duplicate(true),"endurance":{"oxygen_seconds":720.,"drone_seconds":480.}}
 m.glass_reach={"work_pos":Vector2.ZERO,"job":{},"choice":"","gate_open":false,"artifact":{},"retrieved":false}
 match id:
  37:_trawler(m,k)
  38:_deep(m,k)
  39:_shelf(m,k)
  40:_confluence(m,k,history)
 FleetSites.apply(m)
 _module_work(m)
 m.extraction=m.corridors[0].pos
 if m.glass_reach.work_pos==Vector2.ZERO:m.glass_reach.work_pos=m.objectives[0].pos
 return m
# AI-DESIGNED optional module consumers. Keep FleetSites' long endurance pump,
# tools and cache untouched. No new required records; bare work remains available.
static func _module_work(m:Dictionary)->void:
 match m.id:
  37:
   var pump=W.machine("optional_37_wellhead_pump","WELLHEAD RETURN PUMP",Vector2(650,1450),{"calm":0.,"noise":{"radius":1200.,"label":"WELLHEAD RETURN PUMP","duration":6.}},true,12.,"quietus_wellhead_seal")
   m.objectives.append(pump)
   m.currents=[{"center":Vector2(1450,1050),"radius":260.,"velocity":Vector2(0,20)}]
   m.brief+="\nAI-DESIGNED optional WELLHEAD RETURN PUMP stops the southern return current. CAMERA / WORK takes12s; Quietus with the wellhead seal takes6s with half the sound radius and audible time. The western approach stays open."
  38:
   m.objectives[2].duration=12.;m.objectives[2].needs_item="quietus_wellhead_seal"
   m.brief+="\nAI-DESIGNED: Quietus with the wellhead seal works THREAD SLUICE RELEASE in6s with half the sound radius and audible time; bare work takes12s. The separate620s counterflow pump keeps its endurance requirement."
  39:
   # Reclassify the existing lower comb rectangle as operable machinery;
   # launch geometry stays identical in all three bands.
   var gate=Rect2(170,640,230,120)
   m.rocks.erase(gate)
   for band in [0,2]:m.depth_geometry[band].rocks.erase(gate)
   m.structures.append(gate)
   var reed=W.machine("optional_39_service_reed","EXHAUST SERVICE REED",Vector2(300,850),W.sluice(gate,"EXHAUST SERVICE REED",1200.),true,12.,"drone_choir_tuner")
   m.objectives.append(reed)
   m.brief+="\nAI-DESIGNED optional EXHAUST SERVICE REED opens the lower exhaust comb for a direct western passage. CAMERA / WORK takes12s; a drone carrying the Choir reed tuner works silently from its own position. Bare craft work audibly; the eastern approach stays open."
  40:
   m.objectives[2].duration=12.;m.objectives[2].needs_item="drone_choir_tuner"
   m.brief+="\nAI-DESIGNED: a drone carrying the Choir reed tuner works SURVEY SLUICE RELEASE silently from its own position. Bare craft retain audible12s work and the western detour."
static func _photo(k:String,label:String,pos:Vector2,band:int,evidence:String,optional:bool=false,duration:float=4.,person:bool=false)->Dictionary:
 var feature=P.F("mark",label,0.,PI,.12,0.,{"art":"count" if person else "scoring","glow":.6,"finding":{"kind":"person" if person else "note","text":evidence,"off":Vector2.ZERO}})
 var subject=P.S(PI,90.,.5,["mark"],[feature],{"band":band,"bands":[band]})
 var o=W.photo(k,label,pos,evidence,subject,duration,optional);o.band=band
 return o
static func _water(m:Dictionary,source:Dictionary)->void:
 # Copy geographic and patrol data only; original operation tasks stay there.
 for field in ["world_size","start","rocks","structures","sirens","currents","depth_geometry","thermal_revision","thermal_fronts"]:
  if source.has(field):m[field]=source[field].duplicate(true) if source[field] is Array or source[field] is Dictionary else source[field]
static func _trawler(m:Dictionary,k:String)->void:
 m.world_size=Vector2(1800,1800);m.start=Vector2(300,1500)
 T.apply(m,[[T.ridge([Vector2(800,350),Vector2(900,650),Vector2(880,1050)],170,70),T.ALL],[Rect2(1050,450,450,420),[0,1]],[T.shard(Vector2(450,700),100,7,71),T.ALL],[T.shard(Vector2(1300,1300),110,7,72),T.ALL]])
 m.objectives=[_photo(k,"TRAWLER ON THE WELLHEAD",Vector2(1250,650),2,"Sorley's fishing boat lies across the wellhead. Its fishing gear posed no actual threat; the Sirens struck it anyway."),_photo(k+"_bonus","BOY AT THE AIR-POCKET WINDOW",Vector2(1450,980),0,"One human boy signals from the trawler's air pocket. This photograph confirms a survivor; it does not evacuate him.",true,8.,true)]
 m.glass_reach.artifact=W.cargo("trawler_screw",Vector2(1310,700),2)
 m.glass_reach.work_pos=m.glass_reach.artifact.pos
 m.corridors=[{"pos":m.start,"name":"TRAWLER SOUTH RECOVERY","route":"deep"}]
 m.endurance={"oxygen_seconds":480.,"drone_seconds":360.}
 m.record="Iain Sorley's pilotage notes honestly chart the shoals. His fishing boat was no threat to the wellhead; the Sirens hit it anyway. One boy remains in an air pocket, awaiting physical rescue."
 m.brief="Photograph Sorley's trawler at DEEP and winch its physical screw within60m using REACH WORK, then recover its living carrier in MIDDLE at SOUTH.\nThe optional SHALLOW window photograph confirms the boy alive but costs another depth crossing and does not rescue him."
static func _deep(m:Dictionary,k:String)->void:
 Layouts.deep(m)
 m.objectives=[_photo(k,"SADDLE UNDERSIDE",Vector2(1500,1000),2,"The deep saddle has a continuous underside seam below the tender's approach."),_photo(k+"_bonus","TENDER PILOTAGE PLATE",Vector2(480,950),1,"The tender's pilotage plate records the western mooring approach.",true),W.machine("optional_38_sluice","THREAD SLUICE RELEASE",Vector2(800,2070),W.sluice(Layouts.DEEP_GATE,"THREAD SLUICE MOTOR",1400.),true)]
 m.corridors=[{"pos":Vector2(1650,2480),"name":"DEEP THREAD SOUTHEAST RECOVERY","route":"deep"}]
 m.record="A photographic underside survey of the deep rendezvous saddle, separate from the bell-line account."
 m.brief="Photograph the saddle underside in DEEP; recover in MIDDLE at the southeast mouth. The split tooth marks the southwest launch, the broad roof the central crossing, and the mooring ribs the western plate.\nStay west of the roof for the long quiet contour, or use CAMERA / WORK at THREAD SLUICE RELEASE: its1400m motor opens the short DEEP crossing under the MIDDLE roof. The optional MIDDLE plate adds a depth change beside the northern patrol."
static func _shelf(m:Dictionary,k:String)->void:
 Layouts.shelf(m)
 # 097 / patterns 1,5: the separate terrace image and physical cache compete
 # for return air. Parallel carriers can bring the complete service account.
 m.endurance={"oxygen_seconds":185.,"drone_seconds":480.}
 m.objectives=[_photo(k,"BUNKER EXHAUST JOINT",Vector2(650,700),1,"A photographed joint joins the shelf bunker exhaust to its terrace wall."),_photo(k+"_bonus","OUTER TERRACE NUMBERS",Vector2(1550,300),1,"The outer terrace carries the same service numbers as the exhaust joint.",true)]
 m.corridors=[{"pos":Vector2(2650,1450),"name":"SHELF THREAD SOUTHEAST RECOVERY","route":"shelf"}]
 m.record="A shelf bunker exhaust survey. The film records infrastructure; it makes no new claim about the watch crew's evacuation."
 m.brief="Photograph the exhaust joint in MIDDLE, then recover at the southeast mouth. The exhaust comb splits the west basin, a hooked terrace divides the crossings, and the numbered northern spur marks the outer route.\nThe short central gap crosses a narrow exhaust front in MIDDLE only. A deep watch holds west of the joint. A louder flash exposure can draw it across the comb; keep the return in MIDDLE after the exhaust photograph. Plain exposures and the outer contour remain alternatives. The long northern contour preserves passive information and passes the optional terrace numbers; leave time for the journey back. A low breakwater screens the cache basin southwest of recovery; round its northern tip. A MIDDLE watch patrols south of southeast recovery: approach from the east and keep moving. The vector drive can shorten the open contour; return to SILENT before the recovery approach."
 m.brief+=" Full cache recovery and the outer numbers compete for return air. Share the three physical cache pieces across the fleet while Quietus photographs."
static func _confluence(m:Dictionary,k:String,history:Dictionary)->void:
 var context=history.duplicate(true)
 context.thread=history.get("thread","");context.completed=history.get("completed",[]);context.facts=history.get("facts",{})
 var source=Resolution.make(11,context);_water(m,source)
 var gate=Rect2(1300,2150,1100,300)
 m.objectives=[_photo(k,"CONFLUENCE DIVIDE SCORING",Vector2(1100,1840),1,"Fresh scoring runs along the western face of the Confluence divide."),_photo(k+"_bonus","EASTERN SCOUR SEQUENCE",Vector2(2860,1870),1,"A held sequence resolves repeated scour on the exposed eastern face.",true,16.),W.machine("optional_40_sluice","SURVEY SLUICE RELEASE",Vector2(2960,2460),W.sluice(gate,"SURVEY SLUICE MOTOR",1400.),true)]
 m.corridors=[{"pos":Vector2(440,4510),"name":"CONFLUENCE SURVEY WEST RECOVERY","route":"deep"},{"pos":Vector2(3160,4200),"name":"CONFLUENCE SURVEY EAST RECOVERY","route":"shelf"}]
 m.endurance={"oxygen_seconds":1080.,"drone_seconds":720.}
 m.record="The divide's scored faces are on recovered film. This survey does not choose or repeat Kestrel's resolution."
 m.brief="Photograph the western divide in MIDDLE and return to either southern survey recovery.\nThe optional sluice motor opens the short cross-ridge return audibly; the western detour stays open. A sixteen-second eastern photograph gambles time near the hunter for extra evidence."
