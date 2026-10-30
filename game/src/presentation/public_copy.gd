extends RefCounted
# Player copy only. Saved keys and provisional author notes remain in source data.
static var names:Dictionary={}
const Items=preload("res://src/equipment/equipment_catalog.gd")
static func present(text:String)->String:
 text=text.replace("AI-DESIGNED placeholder crew, Pat to rewrite. Grants only; none is required.","Crew assistance is optional; every operation can launch without it.")
 text=text.replace("AI-DESIGNED placeholder ledger, Pat to rewrite. Built only from recorded outcomes.","This account contains only recovered outcomes.")
 text=text.replace("AI-DESIGNED: ","").replace("AI-DESIGNED optional ","Optional ")
 text=text.replace("Created by (to be named)","An independent reconnaissance game")
 var pattern=RegEx.new();pattern.compile("\\b[a-z]+(?:_[a-z0-9]+)+\\b")
 var out="";var cursor=0
 for found in pattern.search_all(text):
  var key=found.get_string()
  if not names.has(key):
   var words=key.split("_")
   if Items.ITEMS.has(key):names[key]=Items.ITEMS[key].name
   elif words[-1].is_valid_int() and (key.begins_with("choir_") or key.begins_with("glass_record_")):
    var mission=load("res://src/campaign/missions.gd").make(int(words[-1]))
    names[key]=str(mission.get("title","Field record"))+" observation"
   else:names[key]=key.replace("_"," ")
  out+=text.substr(cursor,found.get_start()-cursor)+str(names[key]);cursor=found.get_end()
 return (out+text.substr(cursor)).replace(String.chr(0x2014),", ")
