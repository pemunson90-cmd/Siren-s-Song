extends SceneTree
# WP-06 (survey S-02). Pat 2026-10-30: one-press travel shortcuts "are fine for
# testing but they will absolutely have to be stripped for release play". A DEV
# mark travels inside saved and exported profiles, so the dev-only rows also need
# a debug build. The build seam (Release.build_override) simulates a release
# build headlessly; the DEV mark itself is unchanged by the seam.
const Release=preload("res://src/presentation/release_controls.gd")
const DevState=preload("res://src/debug/dev_state.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")

func dev_keys()->Array:
 return Release.TRAVEL_SHORTCUTS.keys().filter(func(k):return Release.TRAVEL_SHORTCUTS[k].dev_only)
func release_keys()->Array:
 return Release.TRAVEL_SHORTCUTS.keys().filter(func(k):return not Release.TRAVEL_SHORTCUTS[k].dev_only)

func host(marked:bool)->Node:
 var h=Node.new();h.set_meta("dev_profile",marked);root.add_child(h);return h

func run():
 check(dev_keys().size()==6,"six dev-only travel rows: "+str(dev_keys()))
 check(release_keys()==["water_leg","water_leg_confirm"],"two release travel rows: "+str(release_keys()))
 var marked=host(true);var plain=host(false)

 # Default seam follows the running build; the headless runner is a debug build.
 Release.build_override=null
 check(Release.debug_build()==OS.is_debug_build(),"default seam follows OS.is_debug_build()")
 check(OS.is_debug_build(),"headless test runner is a debug build")
 for key in dev_keys():
  check(Release.allowed(marked,key),"debug build: DEV-marked profile allows "+key)
  check(not Release.allowed(plain,key),"debug build: unmarked profile refuses "+key)
 for key in release_keys():
  check(Release.allowed(marked,key) and Release.allowed(plain,key),"debug build: placed-leg row allowed "+key)
 check(Release.dev(marked) and not Release.dev(plain),"debug build: dev() follows the DEV mark")
 check(not Release.dev(null) and not Release.allowed(null,"route_here") and Release.allowed(null,"water_leg"),"debug build: null host has no dev rows")

 # Simulated release build: the DEV mark no longer opens any dev-only row.
 Release.build_override=false
 check(not Release.debug_build(),"seam simulates a release build")
 for key in dev_keys():
  check(not Release.allowed(marked,key),"release build: DEV-marked profile refuses "+key)
  check(not Release.allowed(plain,key),"release build: unmarked profile refuses "+key)
 for key in release_keys():
  check(Release.allowed(marked,key) and Release.allowed(plain,key),"release build: placed-leg row allowed "+key)
 check(not Release.dev(marked),"release build: dev() is false for a DEV-marked profile")
 # The DEV taint survives: still marked, still excluded from records.
 check(DevState.marked(marked) and not DevState.eligible(marked),"release build: DEV mark and record exclusion unchanged")
 check(not DevState.marked(plain) and DevState.eligible(plain),"release build: unmarked profile stays eligible")
 var saved={};DevState.write(marked,saved)
 check(saved.get("dev",false)==true and saved.has("dev_setup"),"release build: a DEV profile still writes its mark into the save")
 var reloaded=host(false);DevState.restore(reloaded,saved,true)
 check(DevState.marked(reloaded) and not Release.allowed(reloaded,"route_here"),"release build: reloaded DEV save stays marked and has no shortcut")
 Release.debug_print(["SS_GATE_PROBE release"]) # prints nothing; must not error

 # Explicit debug override equals the default behaviour.
 Release.build_override=true
 for key in Release.TRAVEL_SHORTCUTS:
  check(Release.allowed(marked,key),"forced debug: DEV-marked allows "+key)
  check(Release.allowed(plain,key)==(key in release_keys()),"forced debug: unmarked matches today's rule "+key)
 check(DevState.marked(marked) and DevState.marked(reloaded) and not DevState.marked(plain),"DevState.marked unaffected by the seam")

 Release.build_override=null
 check(Release.debug_build()==OS.is_debug_build(),"seam restored to the running build")
 for h in [marked,plain,reloaded]:h.free()
 print("RELEASE BUILD GATE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
