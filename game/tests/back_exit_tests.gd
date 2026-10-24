extends SceneTree
# BACK1 (handoff 041): quit_on_go_back is off; double-Back exits from Operations only.
# The quit hook and clock are replaced, so the test run never really quits.
const Confirm=preload("res://src/presentation/back_exit/back_exit_confirm.gd")
var checks=0
var failures=0
var now=100000
var quits=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func back():
 root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST);await settle()
func on_quit():quits+=1
func fresh():
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false);game._show_campaign();await settle()
 game.back_exit=Confirm.new();game.add_child(game.back_exit)
 game.back_exit.quit_hook=on_quit;game.back_exit.clock=func():return now
 return game
func run():
 var text=FileAccess.get_file_as_string("res://project.godot")
 check(ProjectSettings.get_setting("application/config/quit_on_go_back",true)==false,"quit_on_go_back is false at runtime")
 check(text.contains("config/quit_on_go_back=false"),"project.godot sets quit_on_go_back=false")
 check(Confirm.TABLE.window_ms>=2000 and Confirm.TABLE.window_ms<=3000 and not Confirm.TABLE.toast_text.is_empty(),"timing and text come from the data table")
 var game=await fresh();var c=game.back_exit
 check(game.screen=="menu","starts on Operations")
 await back()
 check(quits==0 and c.armed and c.toast!=null and c.toast.visible and c.toast.text==Confirm.TABLE.toast_text,"first Back shows the toast and does not quit")
 now+=Confirm.TABLE.window_ms-100
 await back()
 check(quits==1 and c.quit_requests==1 and not c.armed and not c.toast.visible,"second Back inside the window quits through the hook")
 await back()
 check(quits==1 and c.armed,"after exit the next Back starts a new confirm")
 now+=Confirm.TABLE.window_ms+500
 await back()
 check(quits==1 and c.armed and c.toast.visible,"a second Back after the window re-arms instead of quitting")
 c._expire();await settle()
 check(not c.armed and not c.toast.visible,"toast expiry disarms")
 now+=10
 await back()
 check(quits==1,"Back after expiry does not quit")
 # Other screens keep one-level-back and never reach the exit confirm.
 c._expire();var armed_before=c.quit_requests
 game._briefing(0);await settle()
 check(game.screen=="briefing","briefing reached")
 await back()
 check(game.screen=="menu" and not c.armed and c.quit_requests==armed_before and quits==1,"Back from a briefing returns to Operations without quitting")
 game._show_fittings();await settle()
 await back()
 check(game.screen=="menu" and not c.armed and quits==1,"Back from Fittings returns to Operations without quitting")
 game.screen="mission";c.armed=false
 await back()
 check(quits==1 and not c.armed and game.screen=="menu","Back during a dive keeps its existing return and never reaches the exit confirm")
 game.queue_free();await settle()
 print("BACK EXIT CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
