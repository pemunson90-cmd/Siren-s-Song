extends RefCounted
# BRANNOCK CREW (handoff 082): rescued groups give one small practical grant on later play.
# Seams (one line each): PhotoIntel.apply_effects (chart mark), Economy.after_recover (one-time credit),
# Ledger.build (people lines), presentation/crew/crew_view.gd from the briefing and SUPPLIES screens.
# Revert: Table.enabled=false, or remove those lines. No save field: every effect reads facts already saved
# (expedition facts), a credit fires only when its fact first appears, and empty facts change nothing.
# Never touches sensing, lock timing, beam, collision, damage or photography; no effect is required.
const Table=preload("res://src/campaign/crew/crew_table.gd")
const Voices=preload("res://src/campaign/voices/voices_table.gd")
static func matches(row:Dictionary,facts)->bool:
 if not Table.enabled or not facts is Dictionary:return false
 var value=facts.get(row.when.fact,facts.get(row.when.get("legacy_fact","")))
 return value is String and value in row.when.is
# Rows whose rescued group is recorded in these facts, in table order.
static func present(facts)->Array:
 var result=[]
 for row in Table.ROWS:
  if matches(row,facts):result.append(row)
 return result
static func _facts(history)->Dictionary:
 return history.get("facts",{}) if history is Dictionary and history.get("facts",{}) is Dictionary else {}
static func speaker(row:Dictionary)->String:
 return Voices.SPEAKERS.get(row.speaker,"")
# A chart mark on the matching later operation, once. Marks inform only; no world rule changes.
static func apply(m:Dictionary,id:int,history)->void:
 for row in present(_facts(history)):
  if row.kind!="mark" or row.op!=id:continue
  var mark=row.mark.duplicate(true)
  mark.merge({"id":"crew_"+row.id,"label":mark.text})
  if not m.has("photo_marks"):m["photo_marks"]=[]
  if not m.photo_marks.any(func(x):return x.get("id","")==mark.id):m.photo_marks.append(mark)
# One-time supply credit when a credit row's fact is first recorded by a recovery. previous and current are
# expedition dictionaries; a fact already present before this recovery grants nothing again.
static func credit(e:Dictionary,previous:Dictionary,current:Dictionary)->void:
 var before=_facts(previous)
 for row in present(_facts(current)):
  if row.kind!="credit" or matches(row,before) or not e.get("stock") is Dictionary:continue
  var parts=[]
  for key in row.credit:
   var n:int=clampi(int(row.credit[key]),0,Table.MAX_CREDIT)
   if n<=0 or not e.stock.has(key) or not e.stock[key] is int:continue
   e.stock[key]=mini(99,e.stock[key]+n);parts.append("%d %s"%[n,str(key).to_upper()])
  if not parts.is_empty():e.report=str(e.get("report",""))+"\nCREW / %s %s Credited %s."%[row.name.to_upper(),row.roster,", ".join(parts)]
# Briefing lines for one operation: the received line of each mark or line row aimed at that op.
static func briefing_lines(facts,op:int)->Array:
 var result=[]
 for row in present(facts):
  if row.kind in ["mark","line"] and row.op==op:
   var who=speaker(row)
   result.append(("%s: %s"%[who,row.line]) if not who.is_empty() else row.line)
 return result
# Crew roster for the briefing and SUPPLIES panels.
static func roster(facts)->Array:
 var result=[]
 for row in present(facts):result.append("%s %s"%[row.name,row.roster])
 return result
# Archive/ledger people lines.
static func ledger_lines(facts)->Array:
 var result=[]
 for row in present(facts):result.append("Brannock crew, %s: %s"%[row.name,row.roster])
 return result
# Adds the crew lines to a ledger rows dictionary; no crew leaves the rows untouched.
static func add_people(rows:Dictionary,facts)->void:
 var lines=ledger_lines(facts)
 if not lines.is_empty():rows["people"]=rows.get("people",[])+lines
