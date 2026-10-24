extends SceneTree
# Handoff 039: placeholder consequence lines for operation ids 14 to 29.
const Lines=preload("res://src/presentation/consequence_lines.gd")
const Missions=preload("res://src/campaign/missions.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var prior:String=""
 for id in range(14,30):
  var mission=Missions.make(id,{})
  check(mission.id==id,"op %d builds"%id)
  check(Lines.LINES.has(id),"table covers op %d"%id)
  var text=Lines.line(mission)
  check(not text.is_empty() and "\n" not in text and text.length()<=80,"op %d has one short line"%id)
  check(text!=prior,"op %d differs from the adjacent op"%id)
  var base=Lines.LINES[id]
  check(not (base.to_lower() in str(mission.brief).to_lower()) and not (text.to_lower() in str(mission.brief).to_lower()),"op %d line is not contained in its brief"%id)
  check(not (base.to_lower() in str(mission.record).to_lower()),"op %d line is not contained in its record"%id)
  check("\u2014" not in text and "\u2013" not in text,"op %d line has no dash glyphs"%id)
  prior=text
 check(Lines.LINES.size()==16,"table has exactly the 16 expected ids")
 # A recorded recovery mouth adds one fact clause for the mouth actually used.
 var m=Missions.make(22,{})
 m.chosen_route="deep"
 var named=Lines.line(m)
 check(named.begins_with(Lines.LINES[22]) and named!=Lines.LINES[22] and " Out by " in named and "\n" not in named,"recorded recovery mouth appears in the line")
 m.chosen_route="";check(Lines.line(m)==Lines.LINES[22],"no recorded mouth gives the fixed line")
 # Ids outside 14..29 never get a line.
 for id in [0,1,5,6,9,10,11,12,13,30,31]:
  var other=Missions.make(id,{})
  check(Lines.line({"id":id,"chosen_route":other.get("chosen_route","")}).is_empty(),"op %d is untouched"%id)
 # Flag off restores today's text.
 Lines.enabled=false
 for id in range(14,30):check(Lines.line(Missions.make(id,{})).is_empty(),"flag off hides op %d"%id)
 Lines.enabled=true
 check(not Lines.line(Missions.make(14,{})).is_empty(),"flag on restores the line")
 print("CONSEQUENCE LINES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
