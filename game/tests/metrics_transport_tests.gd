extends SceneTree
const Transport=preload("res://src/diagnostics/metrics_transport.gd")
var checks=0
var failures=0
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",message)
func _initialize() -> void:call_deferred("run")
func same_values(expected: Variant,actual: Variant) -> bool:
 if typeof(expected) in [TYPE_INT,TYPE_FLOAT] and typeof(actual) in [TYPE_INT,TYPE_FLOAT]:return is_equal_approx(float(expected),float(actual))
 if expected is Dictionary:
  if not actual is Dictionary or expected.size()!=actual.size():return false
  for key in expected:
   if not actual.has(key) or not same_values(expected[key],actual[key]):return false
  return true
 if expected is Array:
  if not actual is Array or expected.size()!=actual.size():return false
  for index in expected.size():
   if not same_values(expected[index],actual[index]):return false
  return true
 return expected==actual
func verify(snapshot: Dictionary,session: String,serial: int) -> Array:
 var before=snapshot.duplicate(true);var payload=JSON.stringify(snapshot)
 var records=Transport.encode(snapshot,session,serial);var bytes=PackedByteArray()
 check(not records.is_empty(),"complete snapshot has transport records")
 for n in records.size():
  var record=records[n];var body=Marshalls.base64_to_raw(record.get_slice(" data=",1))
  check(record.to_utf8_buffer().size()<800,"record stays safely below observed 1023-byte logger limit")
  check(body.size()<=450,"raw UTF8 chunk obeys agreed bound")
  check(record.begins_with("SS_UI_METRICS_PART id=%s:%d part=%d parts=%d bytes=%d sha256=%s data="%[session,serial,n,records.size(),payload.to_utf8_buffer().size(),payload.sha256_text()]),"every record repeats snapshot identity/count/byte length/full hash")
  bytes.append_array(body)
 check(bytes==payload.to_utf8_buffer(),"reassembled bytes match full canonical JSON exactly")
 var parsed=JSON.parse_string(bytes.get_string_from_utf8())
 check(parsed==JSON.parse_string(payload),"decoded JSON equals the full canonical serialized snapshot")
 check(same_values(snapshot,parsed),"all keys, arrays, strings, booleans and numeric values survive JSON normalization")
 check(snapshot==before,"encoding never mutates source snapshot")
 return records
func run() -> void:
 verify({"text":"潜航 μ 🫧".repeat(400),"nested":{"values":[false,17,0.5]}},"unicode-fixture",2)
 root.size=Vector2i(2520,1080);await process_frame;await process_frame
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(preload("res://tests/density_main.gd"));game.capture_scenario="transport-fixture";root.add_child(game)
 await process_frame;await process_frame;game._start_mission(0);await process_frame;await process_frame;await process_frame
 var snapshot=game._ui_metrics();var payload=JSON.stringify(snapshot)
 var actions=snapshot.controls.map(func(control):return control.action)
 var visible=game.mission_hud.action_controls()
 check(payload.to_utf8_buffer().size()>1023 and ["pause","focus","fit","more_orders"].all(func(action):return action in actions) and visible.keys().all(func(action):return action in actions) and actions.size()==visible.size(),"actual minimal water HUD exceeds old boundary and transports every visible safety/view/fleet action")
 var records=verify(snapshot,"hud-fixture",1)
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--fixture-log="):
   var f=FileAccess.open(arg.trim_prefix("--fixture-log="),FileAccess.WRITE);f.store_string("\n".join(records)+"\n");f.close()
  if arg.begins_with("--fixture-json="):
   var f=FileAccess.open(arg.trim_prefix("--fixture-json="),FileAccess.WRITE);f.store_string(payload);f.close()
 game.queue_free();await process_frame;await create_timer(0.5).timeout
 print("METRIC TRANSPORT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
