extends SceneTree
# R3 (RULING_TESTS.md): Pat's protected rules pinned in tests/fixtures/protected_golden.json.
# "constants" rows read live script constants; "source" rows read literals that live inline
# in rule code, by regex capture. Any difference fails with the rule name and both values.
# Changing the golden needs a commit message with `RULING:` and the dated line from
# docs/state/RULINGS.md. This test does not read commit messages; reviewers do.
const GOLDEN="res://tests/fixtures/protected_golden.json"
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var text=FileAccess.get_file_as_string(GOLDEN)
 var golden=JSON.parse_string(text)
 check(golden is Dictionary and golden.get("constants") is Array and golden.get("source") is Array,"golden file parses")
 if golden is Dictionary:
  for row in golden.get("constants",[]):constant_row(row)
  for row in golden.get("source",[]):source_row(row)
  check(golden.get("constants",[]).size()>0 and golden.get("source",[]).size()>0,"golden pins constants and source rules")
 print("PROTECTED RULES CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
# JSON shape for live values: numbers as float, Vector2 as [x,y], dictionary keys as text.
func norm(v):
 if v is int or v is float:return float(v)
 if v is Vector2:return [float(v.x),float(v.y)]
 if v is Array:return v.map(func(item):return norm(item))
 if v is Dictionary:
  var out={}
  for key in v:out[str(key)]=norm(v[key])
  return out
 return v
func constant_row(row:Dictionary):
 var script=load(row.script)
 var label="%s %s::%s"%[row.rule,row.script,row.const]
 if script==null or not script.get_script_constant_map().has(row.const):
  check(false,"%s missing (golden %s)"%[label,JSON.stringify(row.value,"",true)]);return
 var live=norm(script.get_script_constant_map()[row.const])
 if row.get("keys",false):live=live.keys();live.sort()
 var want=JSON.stringify(row.value,"",true);var got=JSON.stringify(live,"",true)
 check(want==got,"%s golden %s live %s"%[label,want,got])
func source_row(row:Dictionary):
 var label="%s %s /%s/"%[row.rule,row.file,row.pattern]
 var text=FileAccess.get_file_as_string(row.file)
 var regex=RegEx.create_from_string(row.pattern)
 if text.is_empty() or regex==null:check(false,"%s unreadable"%label);return
 var live=[]
 for m in regex.search_all(text):
  for group in range(1,m.get_group_count()+1):live.append(m.get_string(group))
 var want=JSON.stringify(row.values);var got=JSON.stringify(live)
 check(want==got,"%s golden %s live %s"%[label,want,got])
