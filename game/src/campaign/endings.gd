extends RefCounted
const STORIES={
 "silent_exodus":{"title":"UNHEARD","outcome":"Drill crews and divers out by craft. No surface ship came.","story":"Quietus carried the drill crews and divers out by craft, a few at a time. No surface ship came. The Sirens never registered Quietus, and it can keep diving."},
 "beacon_pact":{"title":"OPEN WATER","outcome":"The most people out, by surface ship on an open channel.","story":"A surface ship took the most people out on a broadcast channel. The Sirens heard it often enough to learn it: a known, unarmed voice. They leave Quietus alone."},
 "hidden_harbour":{"title":"STANDING DOWN","outcome":"The military survivors out quietly. Their weapons stay dark on the bottom.","story":"Quietus carried the military survivors out quietly. Their weapons stay dark on the bottom and the installations go silent for good. The Sirens never registered Quietus."},
 "surface_reckoning":{"title":"MARKED","outcome":"Everyone out by surface ship. The call went out from a military post.","story":"A surface ship took the most people out, but the channel came from a military post. The Sirens registered Quietus as a threat. Everyone is out, and Quietus can never dive near them again."}
}
const LATE_CHANNEL_FACTS={
 "glass_choice":{"service":"overt","sever":"concealed"},
 "choir_choice":{"bypass":"overt","isolate":"concealed"},
 "choir_plant":{"reconnect":"overt","dismantle":"concealed"}
}
# 088 AI-DESIGNED, pending Pat ratification: two matching votes and a strict
# majority among these three recovered choices. Missing/unknown facts abstain.
# The Confluence channel wins ties and sparse records. No saved fields.
# Revert campaign_resolve to resolve; expedition/fork resolution stays resolve.
static func late_channel(facts:Dictionary,seed:String)->String:
 var votes={"concealed":0,"overt":0}
 for key in LATE_CHANNEL_FACTS:
  var vote=LATE_CHANNEL_FACTS[key].get(facts.get(key,""),"")
  if not vote.is_empty():votes[vote]+=1
 for channel in votes:
  if votes[channel]>=2 and votes[channel]>votes["overt" if channel=="concealed" else "concealed"]:return channel
 return seed

static func campaign_resolve(progress:Dictionary)->Dictionary:
 var provisional=resolve(progress)
 if provisional.is_empty():return {}
 if 34 not in progress.get("completed",[]):return {}
 var facts=progress.get("facts",{})
 var seed=facts.get("confluence_route","")
 var channel=late_channel(facts,seed)
 var result=resolve(progress,channel)
 if channel!=seed:
  # Causes: glass_choice service/sever, choir_choice bypass/isolate,
  # choir_plant reconnect/dismantle vote overt/concealed in LATE_CHANNEL_FACTS.
  result.story+=" What Quietus did at the Glass and the Choir was heard. The Sirens learned its voice." if channel=="overt" else " Quietus went quiet at the Glass and the Choir. The Sirens lost its voice."
 return result

static func course_line(progress:Dictionary)->String:
 var provisional=resolve(progress)
 return "Course so far: %s (provisional)."%provisional.title if not provisional.is_empty() and 34 not in progress.get("completed",[]) else ""

static func resolve(progress:Dictionary,channel:String="")->Dictionary:
 var thread=progress.get("selected_thread",progress.get("route",""))
 var done=progress.get("completed",[])
 var route=progress.get("facts",{}).get("confluence_route","")
 # Validate the original recovered fork before applying the late channel.
 if not ((route=="concealed" and 12 in done) or (route=="overt" and 13 in done)):return {}
 if not channel.is_empty():route=channel
 var id=""
 if route=="concealed":id="silent_exodus" if thread=="deep" else "hidden_harbour" if thread=="shelf" else ""
 if route=="overt":id="beacon_pact" if thread=="deep" else "surface_reckoning" if thread=="shelf" else ""
 if id.is_empty():return {}
 var result=STORIES[id].duplicate(true);result["id"]=id
 var arrival=progress.get("facts",{}).get("witness_arrival","")
 if id in ["silent_exodus","hidden_harbour"] and arrival in ["quietus","drone_a","drone_b"]:
  var carrier={"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}[arrival]
  result.outcome="Kestrel's capsule reached the quiet lift point with the sailors alive."
  result.story=carrier+" set Kestrel's escape capsule down at the southeast lift point with the sailors still breathing inside. Quietus came home with their account and nothing broadcast behind it. Anyone else still down there, this dive did not see. "+progress.facts.get("witness_recovery","")
 var concealed=progress.get("facts",{}).get("concealed_consequence","")
 if id=="silent_exodus" and concealed=="deep_trace_severed":
  result.outcome="The trench mouth went quiet and Tessaly's bell started up."
  result.story=carrier_name(arrival)+" landed Kestrel's sonar operator alive. On her word Quietus hauled the old tracking float off the trench mouth and broke its surface trace. The bell began its slow lift. "+progress.facts.get("witness_recovery","")
 elif id=="hidden_harbour" and concealed in ["shelf_service","shelf_baffle"]:
  result.outcome="Port Ardent's six came out of the shore-end bunker."
  var mouth="The short service approach stays open: a direct route for the crew, and for sound." if concealed=="shelf_service" else "The north entrance is baffled. The crew take the longer lower turn through quieter water."
  result.story=carrier_name(arrival)+" landed Kestrel's sonar operator alive. She told Quietus how the bunker could be opened from the water. Quietus cleared the approach and cut the blast door; the cutter ran loud. "+mouth+" All six came out. "+progress.facts.get("witness_recovery","")
 var warning=progress.get("facts",{}).get("warning_arrival","")
 if id in ["beacon_pact","surface_reckoning"] and warning in ["exposed","sheltered"]:
  var passage="the sheltered service passage" if warning=="sheltered" else "the exposed eastern channel"
  var first="Brannock's launch reached the northeast pickup through "+passage+". Quietus came home after it heard the launch arrive. "
  if id=="beacon_pact":
   result.outcome="A launch on an open channel, and nothing fired on it."
   result.story=first+"Kestrel's sailors went up in the open, engines running, the call on loop. The Sirens heard it all and a patrol turned away."
  else:
   result.outcome="Everyone out. The water is closed to Quietus."
   result.story=first+"The call had gone out on a military post's channel. Brannock took every survivor aboard. The Sirens registered Quietus as a threat, and Quietus cannot dive near them again."
 return result

static func carrier_name(arrival:String)->String:return {"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}.get(arrival,"The rescue craft")
