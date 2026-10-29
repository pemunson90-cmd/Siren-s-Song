extends RefCounted
# 080 AI-DESIGNED placeholders within the provisional six-arc bible.
# Revert enabled=false: cards/headings stop; optional seen booleans remain valid.
static var enabled=true
const ARCS=[
 {"number":1,"name":"SHELF","region":"shelf","first":0,"last":[5],"ids":[0,1,2,3,4,5],"seen":"arc_1_seen","intro":"Okafor, on Brannock: Photograph Corran Bank and bring its field records home.","outro":"Corran Bank's recovered record points beyond the shelf."},
 {"number":2,"name":"DIVERGENCE","region":"divergence","first":6,"last":[9,10],"ids":[6,7,8,9,10,38,39],"seen":"arc_2_seen","intro":"Okafor, on Brannock: Tessaly and Port Ardent still answer. Recover the record along your chosen thread.","outro":"The recovered thread carries forward to Kestrel."},
 {"number":3,"name":"CONFLUENCE","region":"confluence","first":11,"last":[12,13],"ids":[11,12,13,40],"seen":"arc_3_seen","intro":"Okafor, on Brannock: Kestrel's survivors need a received route out. Bring the reconnaissance home.","outro":"The Kestrel recovery joins the record carried onward."},
 {"number":4,"name":"GLASS REACH","region":"glass","first":14,"last":[19],"ids":[14,15,16,17,18,19,20,21,37],"seen":"arc_4_seen","intro":"Okafor, on Brannock: Photograph the Varne range and recover its archive through the listening fence.","outro":"The Varne range recovery joins Quietus's field record."},
 {"number":5,"name":"IRON CHOIR","region":"iron","first":22,"last":[25],"ids":[22,23,24,25,26,27,28,29],"seen":"arc_5_seen","intro":"Okafor, on Brannock: Hollins Field still holds people. Record the plant and recover through its working machinery.","outro":"The Hollins Field recovery carries its people and plant record onward."},
 {"number":6,"name":"TRENCH","region":"calder","first":30,"last":[34],"ids":[30,31,32,33,34,35,36],"seen":"arc_6_seen","intro":"Okafor, on Brannock: Photograph Calder's drilling breach. The well must be shut in by hand.","outro":"Calder's recovered reconnaissance completes the core campaign record."}
]
static func for_operation(id:int)->Dictionary:
 for arc in ARCS:
  if id in arc.ids:return arc
 return {}
static func heading(arc:Dictionary,completed:Array)->String:
 var count=arc.ids.filter(func(id):return id in completed).size()
 return "ARC %d / %s / %d OF %d RECOVERED"%[arc.number,arc.name,count,arc.ids.size()]
static func valid(data:Dictionary)->bool:
 for arc in ARCS:
  if data.has(arc.seen) and not data[arc.seen] is bool:return false
 return true
