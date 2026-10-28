extends RefCounted
# 042 decorates the existing 027 wall, never creates a second photo renderer.
# Seams: last-recovery branch, wall header/facts/footer, Operations entry;
# optional boolean archive/restore/reset adapters. No simulation or ending rules.
# Revert Table.enabled=false; keep the optional marker for re-enabling safely.
const Table=preload("res://src/presentation/finale/finale_table.gd")
const PhotoEnding=preload("res://src/campaign/endings_photo.gd")
const LedgerView=preload("res://src/presentation/ledger/ledger_view.gd")
static func eligible(host)->bool:
 return not PhotoEnding.resolve(host.expedition,host.photo_intel).is_empty()
static func valid(data:Dictionary)->bool:
 return not data.has(Table.SEEN_FIELD) or data[Table.SEEN_FIELD] is bool
static func write(host,data:Dictionary)->void:
 if host.end_of_line_seen:data[Table.SEEN_FIELD]=true
static func restore(host,data:Dictionary)->void:
 var complete=not PhotoEnding.resolve(data.get("expedition",{}),data.get("intel",{})).is_empty()
 # Legacy complete pairs get manual access, never an automatic boot screen.
 host.end_of_line_seen=complete and (data.get(Table.SEEN_FIELD,false)==true if data.has(Table.SEEN_FIELD) else Table.enabled)
 host.set_meta(Table.SHOW_META,false)
static func clear(host)->void:
 host.end_of_line_seen=false;host.set_meta(Table.SHOW_META,false)
static func first_recovery(host,previous:Dictionary)->bool:
 if not Table.enabled or host.sim.outcome!="won" or host.sim.mission.id!=Table.LAST_ID or Table.LAST_ID in previous.get("completed",[]):return false
 return show(host)
static func show(host)->bool:
 if not Table.enabled or not eligible(host):return false
 host.set_meta(Table.SHOW_META,true);host._show_ending();return true
static func lines(facts:Dictionary)->Array:
 var result=[]
 for row in Table.LINES:
  var value=str(facts.get(row[0],"")).replace("_"," ").strip_edges().left(Table.MAX_VALUE_CHARS)
  result.append(row[1]%value if not value.is_empty() else row[2])
 return result
static func fact_line(key:String,value:String)->String:
 if not Table.enabled:return "%s / %s"%[key.replace("_"," ").to_upper(),value.to_upper()]
 return "%s / %s"%[Table.LABELS.get(key,"Recorded choice"),value.replace("_"," ")]
static func heading(host,ending:Dictionary)->bool:
 var requested=host.get_meta(Table.SHOW_META,false)==true
 host.set_meta(Table.SHOW_META,false)
 if not Table.enabled or not requested or ending.is_empty():return false
 host.end_of_line_seen=true
 host._menu_text(Table.TITLE,Table.TITLE_SIZE)
 for line in lines(ending.choices):host._menu_text(line,Table.LINE_SIZE)
 LedgerView.render(host,host.expedition,host.photo_intel)
 host._menu_text(Table.FILM_TITLE,Table.FILM_SIZE)
 return true
static func credits_button(host)->void:
 host._button(host.menu_footer,Table.CREDITS,func():
  host._show_campaign()
  load("res://src/presentation/frontend/menu_reach.gd").open(host,"credits")
 ,"finale_credits")
static func entry(host)->void:
 if Table.enabled and host.end_of_line_seen and eligible(host):host._button(host.panel_box,Table.REPLAY,func():show(host),"end_of_line")
