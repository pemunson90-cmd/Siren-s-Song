extends RefCounted
# 027 off switch restores the original ending presentation. Keep these factories and
# catalog registrations for existing active/completed saves. Full revert: remove
# the PR's hooks/UI while retaining these compatibility definitions, not save data.
const ENABLED=true
const IDS=[30,31]
const ART={"SCOUR EDGE":"scoring","SPINDLE WEAR":"scoring","HUMAN SURVIVOR MARKS":"count","FEED TERMINALS":"array"}
const T=preload("res://src/campaign/encounters/terrain.gd")
const W=preload("res://src/campaign/encounters/work_sites.gd")
const P=preload("res://src/campaign/photo_ops.gd")
const LISTEN_BRIEF="\nOptional local work: LISTEN in settled MIDDLE at the marked receiver point."
const LAYOUTS={30:preload("res://src/campaign/encounters/final_survey.gd"),31:preload("res://src/campaign/encounters/final_marks.gd")}
static func supports_config(c:Dictionary)->bool:
 return c.size()==2 and c.get("history")==true and c.get("source_id",-1) in IDS
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func entries()->Array:
 var result=[]
 for id in IDS:
  result.append({"id":id,"factory":"res://src/campaign/final_pair_operations.gd","config":{"source_id":id,"history":true},"behaviors":["signals_v2","history"],"prerequisites":[25 if id==30 else 30],"facts":[],"records":[key(id),key(id)+"_bonus"],"campaign":true,"route":"","required_facts":{}})
 return result
static func key(id:int)->String:return "final_photo_"+str(id)
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var id:int=c.source_id;var row=LAYOUTS[id].layout();var k=key(id)
 var m={"id":id,"title":"FINAL SURVEY / %d"%(id-29),"depth":4100,"darkness":false,"region_revision":1,"acoustic_revision":1,"world_size":row.world_size,"start":row.start,"rocks":[],"structures":[],"sirens":row.sirens,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[k],"launch_context":history.duplicate(true),"endurance":{"oxygen_seconds":720.,"drone_seconds":480.},"record":row.core_label,"brief":"Photograph %s in MIDDLE, then recover Quietus.\nThe second marked photograph is optional; keep film for the core job."%row.core_label+(LISTEN_BRIEF if row.has("listen") else "")}
 T.apply(m,row.terrain)
 m.structures=row.structures.duplicate()
 m.corridors=[{"pos":row.recovery,"name":row.get("mouth","SURVEY RECOVERY"),"route":"deep"}];m.extraction=row.recovery
 m.objectives=[_photo(k,row.core_label,row.core,row.core_band,false),_photo(k+"_bonus",row.bonus_label,row.bonus,row.bonus_band,true)]
 if row.has("listen"):
  # Optional local work: passive hydrophone reception in settled MIDDLE (Quietus only).
  var listen=W.listen(row.listen.key,row.listen.name,row.listen.pos,row.listen.evidence)
  listen.optional=true;m.objectives.append(listen)
 return m
static func _photo(k:String,label:String,pos:Vector2,band:int,optional:bool)->Dictionary:
 var subject=P.S(PI,100.,0.55,["mark"],[P.F("mark",label,0.,PI,0.12,0.,{"art":ART[label],"glow":0.7,"finding":{"kind":"person" if label=="HUMAN SURVIVOR MARKS" else "note","text":label,"off":Vector2.ZERO}})])
 subject["band"]=band
 var o=W.photo(k,label,pos,label,subject,4.,optional)
 o["band"]=band
 return o
