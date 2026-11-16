extends SceneTree
const Store=preload("res://src/persistence/settings_store.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Text=preload("res://src/campaign/onboarding_text.gd")
const Shelf=preload("res://src/campaign/shelf_signal_operation.gd")
const Senses=preload("res://src/simulation/sweeper_senses.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 8:await process_frame
# Which top corner a pause button occupies in a HUD of the given width.
func corner(g)->String:
 return "top left" if g.pause_button.position.x+g.pause_button.size.x/2.<g.mission_hud.size.x/2. else "top right"
func hint_ok(hint:String,where:String)->bool:
 return hint.contains(where) and not hint.contains("always")
func run():
 await run_pause()
 run_sweeper()
 print("BRIEFING TRUTH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func run_pause():
 var hint=Text.hint_text("pause")
 # Known-bad and known-good inputs for the matcher itself.
 check(not hint_ok("PAUSE is always at top left.","top left"),"matcher rejects the old absolute claim")
 check(hint_ok("PAUSE: top left or top right.","top right"),"matcher accepts a corner-naming hint")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="radial-hud"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false)
  for mirrored in [false,true]:
   Settings.apply(Store.sanitize({"mirrored_hud":mirrored}),g);g._layout();await settle()
   var where=corner(g)
   check(where==("top right" if mirrored else "top left"),"pause corner follows the mirrored setting "+str(dimensions)+" "+str(mirrored))
   check(hint_ok(hint,where),"PAUSE hint names the actual corner "+where+" "+str(dimensions)+" mirrored "+str(mirrored))
  Settings.apply(Store.sanitize({"mirrored_hud":false}),g)
  g.queue_free();await settle()
func run_sweeper():
 var brief:String=Shelf.build({"source_id":0,"history":false}).brief
 # Expected facts come from the sweeper role table, not from the brief text.
 var sweeper={"type":"sweeper","suspicion":0.}
 var patrol={"type":"patroller","suspicion":0.}
 check(Senses.ear(sweeper)>Senses.ear(patrol),"role table: sweeper hears farther")
 check(Senses.attention(sweeper)>Senses.attention(patrol),"role table: sweeper searches longer")
 Senses.note_heard(sweeper,Vector2(1,2),3.);Senses.note_heard(sweeper,Vector2(5,6),9.)
 check(sweeper.listen.pos==Vector2(5,6),"role table: sweeper keeps only the last heard noise")
 check(brief.contains("hears farther") and brief.contains("searches longer") and brief.contains("last noise"),"op 0 brief names the three sweeper behaviours")
 for gone in ["winding","delayed strike","old return"]:
  check(not brief.contains(gone),"op 0 brief no longer claims "+gone)
 check(not brief.contains("—"),"op 0 brief has no em dash")
