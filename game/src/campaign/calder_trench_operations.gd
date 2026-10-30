extends RefCounted
# 051 additive campaign factories. Film records the reconnaissance; physical
# recovered cargo and local machinery retain their existing Reach custody rules.
const IDS=[32,33,34,35,36]
const TITLES={32:"Calder Shut-In",33:"The Human Gallery",34:"Beneath the Well",35:"Deep Keel",36:"The Guard Window"}
# 096 provisional endurance data. Revert this table to1080s to restore the earlier
# oxygen margin; no life-support, damage or sensing rules change.
const OXYGEN={32:210.,33:360.,34:420.,35:360.,36:360.}
const ITEMS=preload("res://src/campaign/recovered_items.gd").ITEMS
const WORK_KEYS={32:"calder_32_shut_in",33:"calder_33_gallery",34:"calder_34_disconnect",35:"calder_35_lift",36:"calder_36_breaker"}
const WORK_NAMES={32:"MANUAL WELL SHUT-IN",33:"SURVIVOR GALLERY EQUALIZER",34:"DRILL FEED DISCONNECT",35:"BROKEN DECK LIFT",36:"GUARD STATION BREAKER"}
const ACCOUNTS={
 32:"Okafor, aboard Brannock / Classified drilling cut into a Siren site. The strike followed the bore; photograph the breach, shut the well in by hand, and recover the seal core.",
 33:"Okafor, aboard Brannock / Human drillers and guards survived behind the gallery glass. Photograph them, equalize their service passage, and bring the loose choir reed home.",
 34:"Okafor, aboard Brannock / The bore passed through older Siren foundations. Photograph that junction. Three machines ring the casing; the last disconnects the drill feed. Bring the reconnaissance home.",
 35:"Okafor, aboard Brannock / A crushed guard keel lies below the drill deck. Photograph its contact face and recover the plate; the deck lift offers a shorter return.",
 36:"Okafor, aboard Brannock / The surviving guard station faces the strike site. Photograph its deep window account; the local breaker can silence the reporting line."}
const WORK_BRIEF="At the marked MIDDLE machinery use CAMERA for twelve audible seconds of local work, opening the way on and stopping the drill wash."
const CAPSTONE_BRIEF="Work the three marked MIDDLE machines in order with CAMERA, twelve audible seconds each; each opens the next gate. The last opens a loud west shortcut home; the quiet way is the long retrace."
const OPTIONAL_BRIEF="At the optional MIDDLE machinery use CAMERA for local work, opening a shorter return and interrupting the listening line."
const T=preload("res://src/campaign/encounters/terrain.gd")
const W=preload("res://src/campaign/encounters/work_sites.gd")
const P=preload("res://src/campaign/photo_ops.gd")
const L=preload("res://src/campaign/encounters/calder_layouts.gd")
const Capstone=preload("res://src/campaign/encounters/calder_capstone.gd")
static func supports_config(c:Dictionary)->bool:
 return c.size()==2 and c.get("history")==true and c.get("source_id",-1) in IDS
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func key(id:int)->String:return "glass_record_"+str(id)
static func entries()->Array:
 var result=[]
 for id in IDS:
  var k=key(id)
  result.append({"id":id,"factory":"res://src/campaign/calder_trench_operations.gd","config":{"source_id":id,"history":true},"behaviors":["signals_v2","history","glass_reach"]+(["thermal"] if id in [32,33,34] else []),"prerequisites":[31 if id==32 else 32 if id in [33,35,36] else 33],"facts":[k,k+"_bonus"],"records":[k,k+"_bonus",WORK_KEYS[id]]+(Capstone.keys().slice(0,2) if id==34 and L.ENABLED and Capstone.ENABLED else [])+([L.MODULE_SITES[34].key] if id==34 else []),"campaign":true,"route":"","required_facts":{}})
 return result
static func make(id:int,history:Dictionary={})->Dictionary:
 return build({"source_id":id,"history":true},history)
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var id:int=c.source_id;var row=L.layout(id);var k=key(id)
 var required=[k]
 if id in [32,33,34]:required.append(WORK_KEYS[id])
 var works=row.get("works",[])
 if not works.is_empty():required=[k]+works.map(func(w):return w.key)
 var m={"id":id,"title":TITLES[id],"depth":5400,"darkness":false,"region_revision":1,"acoustic_revision":1,"expedition_revision":2,"world_size":row.world_size,"start":row.start,"extraction":row.recovery,"rocks":[],"structures":[row.gate],"sirens":row.sirens,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":required,"launch_context":history.duplicate(true),"endurance":{"oxygen_seconds":OXYGEN[id],"drone_seconds":720.},"record":ACCOUNTS[id],"corridors":[{"pos":row.recovery,"name":row.mouth,"route":"deep"}]}
 T.apply(m,row.terrain)
 var effect={"open":[row.gate],"quiet":1100.,"quiet_time":120.,"noise":{"radius":1350.,"label":WORK_NAMES[id],"duration":10.}}
 if id in [32,33,34]:effect.calm=0.
 m.objectives=[_photo(k,row.core_label,row.core,row.core_band,row.core_art,false),_photo(k+"_bonus",row.bonus_label,row.bonus,row.bonus_band,row.bonus_art,true),W.machine(WORK_KEYS[id],WORK_NAMES[id],row.work,effect,id in [35,36],12.)]
 if not works.is_empty():
  # Capstone: objectives[2] stays the final disconnect; the earlier stages follow it.
  m.objectives[2]=W.machine(works[2].key,works[2].name,works[2].pos,works[2].effect,false,12.)
  for stage in [0,1]:m.objectives.append(W.machine(works[stage].key,works[stage].name,works[stage].pos,works[stage].effect,false,12.))
  m.structures=works.map(func(w):return w.gate)
 # 065 optional interactions share CAMERA work, never required_site_ids.
 if id in L.MODULE_SITES:
  var site=L.MODULE_SITES[id]
  if id==34:
   m.objectives.append(W.machine(site.key,site.name,row.current+site.offset,site.effect.duplicate(true),true,site.duration,site.module))
  else:m.objectives[2].needs_item=site.module
 m.glass_reach={"work_pos":row.work,"job":{},"choice":"","gate_open":false,"artifact":W.cargo(ITEMS[id],row.cargo,row.cargo_band) if id in ITEMS else {},"retrieved":false}
 if id in [32,33,34]:
  m.currents=[{"center":row.current,"radius":600.,"velocity":Vector2(0,12)}]
  m.thermal_revision=1;m.thermal_fronts=[{"area":row.front,"transmission":.55,"close_range":90.}]
 m.brief=ACCOUNTS[id]+"\nPrimary photograph is in DEEP. Return Quietus to "+row.mouth+" in settled MIDDLE. "+(CAPSTONE_BRIEF if not works.is_empty() else WORK_BRIEF if id in [32,33,34] else OPTIONAL_BRIEF)
 if id in ITEMS:m.brief+=" Use REACH WORK to winch the marked physical material within60m at DEEP, then return its living carrier to the recovery mouth."
 if id in L.MODULE_SITES:
  m.brief+="\nAI-DESIGNED optional CAMERA work: seal on Quietus halves marked pump/lift time and sound; tuner on a drone silences the marked breaker. Bare work takes12s."
 return m
# 121 AI-DESIGNED record interpretations: what the archived image shows and why it
# matters. Caption text only; Pat may replace any line.
const READINGS={
 "DRILL INTO THE OLD RIBS":"A human drill string is driven into the curved Siren ribs at a fresh bright cut. The breach was drilled, not struck.",
 "GUARD SHIFT NAMEPLATE":"A watch roster plate beside the gallery hatch, its lines still legible. The guard post was manned when the strike came.",
 "DRILLERS AND GUARDS AT THE GLASS":"Four drillers in hard hats and two armed guards stand behind the lit gallery glass, palms on the pane. They are alive.",
 "SIREN REED SCORING":"Long parallel cuts in the stone above a loose choir reed. Siren work, not tool marks.",
 "HUMAN BORE THROUGH SIREN FOUNDATION":"A steel bore cuts through carved Siren courses, ending their red seams at raw stone. The drill went through, not around.",
 "FIRST STRIKE IMPACT FACE":"A cratered, glassed face with fractures running out from one point. The heaviest damage faces the bore.",
 "KEEL UNDER THE DRILL DECK":"The fallen drill deck lies across a guard boat keel, its contact face buckled inward. The deck came down on the boat.",
 "MISSING GUARD BERTHS":"Five guard berth cradles; one holds a hull, the rest hang empty with loose lines. Most of the guard boats are gone.",
 "GUARD WINDOW ON THE FIRST STRIKE":"A guard stands at the lit station window with field glasses, facing the scarred strike ground. The station watched the first strike.",
 "DRILL PERMIT ON OLD STONE":"A stamped drill permit bolted onto carved Siren stone. The bore was licensed to cut here."}
static func _photo(k:String,label:String,pos:Vector2,band:int,art:String,optional:bool)->Dictionary:
 var feature=P.F("mark",label,0.,PI,0.12,0.,{"art":art,"glow":.7,"finding":{"kind":"person" if label=="DRILLERS AND GUARDS AT THE GLASS" else "note","text":label,"off":Vector2.ZERO}})
 var subject=P.S(PI,100.,.55,["mark"],[feature],{"band":band,"bands":[band]})
 var o=W.photo(k,label,pos,READINGS.get(label,label),subject,4.,optional)
 o.band=band
 return o
