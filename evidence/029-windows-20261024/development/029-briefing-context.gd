extends SceneTree
# Read-only context export for queued029. No simulation, saves or product edits.
const Catalog=preload("res://src/campaign/operation_catalog.gd")
func _initialize():
 var rows=[]
 for id in range(3,30):
  var m=Catalog.make(id)
  var objectives=[]
  for o in m.objectives:objectives.append({"name":o.name,"kind":o.get("kind",""),"optional":o.get("optional",false)})
  rows.append({"id":id,"title":m.title,"brief":m.brief,"record":m.record,"objectives":objectives})
 var path="C:/Users/Archi/Documents/Codex/2026-10-23/continue-as-codex-on-the-siren/work/029-briefing-context.json"
 var file=FileAccess.open(path,FileAccess.WRITE)
 if file==null:push_error("Cannot write queued briefing context");quit(1);return
 file.store_string(JSON.stringify(rows,"  "));file.close()
 print("READ-ONLY BRIEFING CONTEXT ROWS ",rows.size());quit()
