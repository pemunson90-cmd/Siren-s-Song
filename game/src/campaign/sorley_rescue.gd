extends RefCounted
# Experiment switch owns visibility, local finds and rewards; saved keys stay registered.
static var enabled=true
const ID=41
const FACT="sorley_boy"
const W=preload("res://src/campaign/encounters/work_sites.gd")
# Optional lockers are beyond the required crossing lanes. No required geometry changes.
const LOGS={
 9:{"pos":Vector2(1840,1820),"text":"Sorley: The boy knows the stern locker. There is air above its window."},
 14:{"pos":Vector2(3400,1320),"text":"Sorley: My trawler lies on the wellhead. Look for the stern window, above the screws."},
 16:{"pos":Vector2(2600,2600),"text":"Sorley: A sealed pod will fit that window. Bring him back to the south boat."}}
const RESCUED="Sorley's boy came home in the sealed pod. His father waited beside the lift."
const LEFT="Sorley's boy was not brought home. No recovered landing is recorded."
static func rescued(p:Dictionary)->bool:return (p.get("facts",{}) is Dictionary and p.get("facts",{}).get(FACT,"") in ["rescued","rescued_quiet"])
static func logs(p:Dictionary)->String:return str(p.get("notes",{}).get(FACT,"000"))
static func unlocked(p:Dictionary)->bool:
 if not enabled:return false
 if rescued(p) or p.get("facts",{}).has("glass_record_37_bonus") or p.get("notes",{}).has("glass_record_37_bonus"):return true
 var bits=logs(p)
 return bits in ["110","101","011","111"]
static func visible(id:int,p:Dictionary)->bool:return id!=ID or unlocked(p)
static func log_record(id:int)->String:return "sorley_log_"+str(id)
static func register(entry:Dictionary)->void:
 if not LOGS.has(entry.id):return
 if FACT not in entry.facts:entry.facts.append(FACT)
 entry.records.append(log_record(entry.id))
static func apply(m:Dictionary)->void:
 if not enabled or not LOGS.has(m.id):return
 var row=LOGS[m.id]
 var site=W.listen(log_record(m.id),"SORLEY'S RECORDER LOCKER",row.pos,row.text,6.)
 site.optional=true;site["sorley_log"]=true
 m.objectives.append(site)
# Optional local finds do not replace the host's primary camera guidance remotely.
# The shared capture path still owns range, settling, operator and clear-water rules.
static func camera_candidate(sim,o:Dictionary)->bool:
 return not o.get("sorley_log",false) or (enabled and sim.units[sim.selected].pos.distance_to(o.pos)<sim.Photo.reach(sim,sim.selected))
static func camera_facts(m:Dictionary)->Array:
 # Finding a side locker is not exact acquisition of the host's required source.
 return m.expedition_facts.keys().filter(func(key):return key!=FACT or m.id not in LOGS)
static func recorded(sim,o:Dictionary)->void:
 if not enabled or not LOGS.has(sim.mission.id) or o.get("site_id","")!=log_record(sim.mission.id):return
 var bits="000";var index=LOGS.keys().find(sim.mission.id)
 bits=bits.substr(0,index)+"1"+bits.substr(index+1)
 sim.mission.expedition_facts[FACT]=bits
static func retain(p:Dictionary,m:Dictionary)->void:
 if not m.get("expedition_facts",{}).has(FACT) or m.id==ID:return
 var old=logs(p);var found=str(m.expedition_facts[FACT]);var merged=""
 if old.length()!=3:old="000"
 for i in 3:merged+="1" if old[i]=="1" or found[i]=="1" else "0"
 p.notes[FACT]=merged
static func valid_progress(p:Dictionary)->bool:
 if not p.get("notes",{}) is Dictionary or not p.get("facts",{}) is Dictionary:return false
 return (not p.get("notes",{}).has(FACT) or p.notes[FACT] in ["000","001","010","011","100","101","110","111"]) and (not p.get("facts",{}).has(FACT) or p.facts[FACT] in ["rescued","rescued_quiet"])
static func line(p:Dictionary)->String:return (RESCUED if rescued(p) else LEFT) if enabled else ""
static func credit(e:Dictionary,before:Dictionary,after:Dictionary)->void:
 if not enabled or rescued(before) or not rescued(after) or not e.get("stock") is Dictionary:return
 # Quiet, intact drone landing repays preparation; bare winch always remains possible.
 var quiet=after.facts[FACT]=="rescued_quiet"
 e.stock.scrap=mini(99,e.stock.scrap+(4 if quiet else 2));e.stock.cells=mini(99,e.stock.cells+(2 if quiet else 0))
 e.report=str(e.get("report",""))+"\nSORLEY / Supplies aboard: "+("4 SCRAP, 2 CELLS for a quiet, intact drone landing." if quiet else "2 SCRAP for bringing the boy home.")
static func entries()->Array:
 return [{"id":ID,"factory":"res://src/campaign/sorley_operation.gd","config":{"source_id":ID,"history":true},"behaviors":["signals_v2","history","witness"],"prerequisites":[],"facts":[FACT],"records":[FACT],"campaign":true,"route":"","required_facts":{}}]

static func valid(data:Dictionary)->bool:
 var m=data.mission
 if m.id not in LOGS:return true
 var value=m.get("expedition_facts",{}).get(FACT,"")
 if value=="":return true
 var index=LOGS.keys().find(m.id);var expected="000"
 expected=expected.substr(0,index)+"1"+expected.substr(index+1)
 return value==expected and m.objectives.any(func(o):return o.get("site_id","")==log_record(m.id) and o.get("captured",false))
