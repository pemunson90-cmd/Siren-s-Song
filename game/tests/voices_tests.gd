extends SceneTree
# Recurring voices: data coverage, received log rules, optional "voices" save field, credits content.
const Voices=preload("res://src/campaign/voices/voices.gd")
const Table=preload("res://src/campaign/voices/voices_table.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Credits=preload("res://src/presentation/frontend/credits_text.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var dash_a=String.chr(0x2014);var dash_b=String.chr(0x2013)
 # Every core operation (0 to 36) has all three lines; optional ones share generic lines.
 for id in range(0,37):
  for slot in Table.SLOTS:check(not Voices.row(id,slot).is_empty(),"line exists %d %s"%[id,slot])
 for id in Table.GENERIC_IDS:check(not Voices.row(id,"mid").is_empty(),"optional operation has a line %d"%id)
 check(not Voices.row(37,"brief").is_empty() and Voices.row(99,"brief").is_empty(),"unknown operation has no line")
 for id in Catalog.registered_ids():check(id<=41,"every registered operation id is within the voice id range")
 for slot in Table.SLOTS:
  var rescue_line=Voices.row(41,slot)
  check(not rescue_line.is_empty() and rescue_line.get("speaker","")==Table.SPEAKERS.sorley,"hidden rescue has its authored Sorley "+slot+" line")
 var unheard=[]
 check(41 not in Voices.operations(unheard) and Table.SLOTS.all(func(slot):return not Voices.heard(unheard,41,slot)),"authored hidden lines are absent from an unearned received log")
 check(not Voices.progress(Catalog.make(41)),"unstarted rescue has no own progress to trigger a mid-dive voice")
 var rescue=preload("res://src/campaign/sorley_rescue.gd")
 rescue.enabled=false
 check(Table.SLOTS.all(func(slot):return Voices.row(41,slot).is_empty() and not Voices.hear(unheard,41,slot)) and unheard.is_empty(),"experiment switch hides all rescue lines and prevents new received entries")
 rescue.enabled=true
 var speakers=[]
 for id in Table.LINES:
  for line in Table.LINES[id]:
   check(Table.SPEAKERS.has(line[0]) and line[1].length()<=140 and line[1].length()>12,"line shape %d"%id)
   check(not line[1].contains(dash_a) and not line[1].contains(dash_b),"no dashes in line %d"%id)
   if line[0] not in speakers:speakers.append(line[0])
 for who in ["okafor","rill","ash","vey","kade","sorley"]:check(who in speakers,"recurring voice used: "+who)
 # Received log.
 var log=[]
 check(Voices.hear(log,0,"brief") and not Voices.hear(log,0,"brief") and Voices.heard(log,0,"brief"),"a line is logged once")
 check(not Voices.hear(log,99,"brief") and not Voices.hear(log,0,"bogus"),"no line, no log entry")
 Voices.hear(log,3,"mid");Voices.hear(log,3,"debrief")
 check(Voices.operations(log)==[0,3],"log lists operations in order")
 # Progress is the player's own: objective captured, carrier recovered or a site job done.
 check(not Voices.progress({}) and not Voices.progress({"objectives":[{"captured":false}]}),"no progress, no message")
 check(Voices.progress({"objectives":[{"captured":true}]}),"captured objective counts")
 check(Voices.progress({"recovered":true}),"recovered carrier counts")
 check(Voices.progress({"iron_choir":{"sites":[{"done":false},{"done":true}]}}) and not Voices.progress({"iron_choir":{"sites":[{}]}}),"site job counts")
 check(Voices.progress({"glass_reach":{"retrieved":true}}),"retrieved reach material counts")
 # Save field: optional, validated, round trips; corrupt values are rejected.
 check(Voices.valid_archive({}) and Voices.valid([]) and Voices.valid(["0:brief","12:mid","36:debrief"]),"valid shapes accepted")
 for bad in [["0:bogus"],["x:brief"],["007:brief"],["-1:brief"],["100:brief"],[3],["0:brief","0:brief"],"0:brief",{},["0"],["0:brief:mid"]]:
  check(not Voices.valid(bad),"corrupt voices rejected: "+var_to_str(bad))
 var many=[]
 for n in Voices.MAX_ENTRIES+1:many.append("%d:brief"%n)
 check(not Voices.valid(many),"oversize voices rejected")
 var store=Store.new();store.path="user://voices_roundtrip.save"
 var data={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","voices":["0:brief","5:debrief"]}
 check(store.valid(data),"archive with voices validates")
 check(store.save(data) and store.load_game().get("voices",[])==["0:brief","5:debrief"],"voices round trip through the checksummed archive")
 var plain=data.duplicate(true);plain.erase("voices")
 check(store.valid(plain),"an archive without the voices field still loads")
 var broken=data.duplicate(true);broken.voices=["0:brief","0:brief"]
 check(not store.valid(broken),"archive with corrupt voices is rejected")
 DirAccess.remove_absolute(store.path);DirAccess.remove_absolute(store.path+".bak")
 # Credits: public creator line with source placeholder, engine, tools and audio attribution.
 var text=""
 for line in Credits.credits(load("res://src/audio/soundscape.gd").ATTRIBUTION):text+=line.text+"\n"
 check(text.contains("An independent reconnaissance game") and not text.contains("(to be named)") and text.contains("Godot Engine 4.6.3") and text.contains("MIT License") and Credits.CREATOR=="Created by (to be named)","credits name engine, show public copy and retain the source creator placeholder")
 check(text.contains("Creative Commons Attribution 3.0") and text.contains("TOOLS"),"credits keep CC-BY audio credits and list tools")
 print("VOICES CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
