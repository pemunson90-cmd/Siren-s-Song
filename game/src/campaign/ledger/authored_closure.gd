extends RefCounted
# 125 AI-DESIGNED story placeholders, Pat may replace each short consequence.
# Read-only interpretation of recovered facts. No new save or ending rules.
const Endings=preload("res://src/campaign/endings.gd")
const CLOSURES={
 "silent_exodus":"The deep course ended with Quietus still able to return. What came home stays with the recovered crews and film, beyond a surface broadcast.",
 "hidden_harbour":"The shelf course ended with the installations silent and Quietus still able to dive. The people recorded here carry their account out of that silence.",
 "beacon_pact":"The deep course ended on an open channel the Sirens recognise as unarmed. Quietus can return; the recovered accounts have a voice above the water.",
 "surface_reckoning":"The shelf course ended on a military channel the Sirens recognise as a threat. The account survives, but these waters are closed to Quietus."
}
const EVIDENCE={
 "glass_record_32":"Calder evidence: the bright drill cut identifies a human breach into older Siren ribs. The strike ground is also a drilling site.",
 "glass_record_33":"Gallery evidence: drillers and armed guards share the same sealed refuge. Their presence ties the industrial and military accounts to one occupied site.",
 "glass_record_34":"Beneath evidence: the bore interrupts older Siren foundation seams. Human drilling crossed an existing structure rather than an empty seabed."
}
static func recorded(facts:Dictionary,key:String)->bool:
 return facts.get(key,"") is String and not facts.get(key,"").strip_edges().is_empty()
static func add(rows:Dictionary,progress:Dictionary)->void:
 var facts=progress.get("facts",{}) if progress.get("facts",{}) is Dictionary else {}
 var knowledge=[]
 for key in EVIDENCE:
  if recorded(facts,key):knowledge.append(EVIDENCE[key])
 if recorded(facts,"glass_record_32") and recorded(facts,"glass_record_34"):
  knowledge.append("Comparison: Calder and Beneath show the fresh cut above and the interrupted foundations below. Together they trace the bore through the older site.")
 if recorded(facts,"glass_record_33") and recorded(facts,"glass_record_34"):
  knowledge.append("Comparison: Gallery and Beneath put living people beside the breached foundations. The damage record alone could not establish who remained below.")
 if not knowledge.is_empty():rows["knowledge"]=rows.get("knowledge",[])+knowledge
 # The ledger accepts partial/malformed old records; the ending resolver expects
 # validated campaign containers. Keep that tolerance at this read-only seam.
 if not progress.get("facts",{}) is Dictionary or not progress.get("completed",[]) is Array:return
 var ending=Endings.campaign_resolve(progress)
 if ending.is_empty():return
 var closure=["FINAL ACCOUNT / "+ending.title,CLOSURES[ending.id]]
 if knowledge.is_empty():closure.append("No Calder, Gallery or Beneath photograph is recorded here. The final account cannot fill those gaps.")
 else:closure.append("The late photographs above remain part of this account. They establish what was seen, while a missing recovery remains missing.")
 rows["disclosure"]=closure+rows.get("disclosure",[])
