extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr('FAIL: ',label)
func _initialize():call_deferred('run')
func settle():
 for n in 6:await process_frame
func click(b):
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=b.get_global_rect().get_center();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
 await settle()
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle();var g=load('res://scenes/main.tscn').instantiate();g.set_script(load('res://tests/density_main.gd'));g.capture_scenario='drone-scout-ui'
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(0);await settle();g.mission_hud.open("fleet");await settle();await click(g.unit_buttons[1]);g.sim.command('route',{'point':Vector2(400,700)});g._refresh();await settle()
  check(g.order_buttons.silent.text=='LOW\nPROFILE','drone control honestly labels visual profile rather than silent thrust')
  var stocks=g.sim.tools.duplicate();await click(g.order_buttons.silent)
  check(not g.sim.units[1].silent and g.order_buttons.silent.text=='OPEN\nPROFILE' and g.sim.tools==stocks,'profile button preserves existing effect and spends no equipment')
  g.mission_hud.open("guard");await settle();await click(g.order_buttons.contact_hold)
  check(g.sim.units[1].hold=='SCOUT' and 'SCOUT' in g.unit_buttons[1].text and 'SCOUT' in g.detail_label.text,'actual scout control arms selected drone with persistent context')
  g.sim.units[1].hold='SCOUT_STOP';g.sim.units[1].vel=Vector2(50,0);g.sim.message='Other message';g._refresh();await settle()
  check(g.ocean.ship_instrument_layout().any(func(line):return 'SCOUT braking' in line.text),'active scout state remains readable on owned drone instrument')
  check('ALERT' in g.unit_buttons[1].text and 'RESUME' in g.order_buttons.contact_hold.text and 'route kept' in g.detail_label.text and 'own contact' in g.detail_label.text and 'braking' in g.detail_label.text,'latched scout stop remains understandable after message is overwritten')
  g.mission_hud.open('guard');await settle();await click(g.order_buttons.contact_hold);check(g.sim.units[1].hold=='' and g.sim.paused,'actual RESUME releases scout without unpausing or spending')
  g.sim.units[1].hold='CONTACT';g._refresh();await settle()
  check(g.order_buttons.contact_hold.text=='FLEET\nGUARD','legacy aggregate hold is distinguished from new local scout')
  for b in [g.order_buttons.contact_hold,g.order_buttons.silent]:
   var rect=b.get_global_rect();check(rect.size.y*dimensions.y/g.get_viewport_rect().size.y>=126 and Array(b.text.split('\n')).all(func(line):return b.get_theme_font('font').get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,b.get_theme_font_size('font_size')).x<=rect.size.x-8),'contextual controls retain48dp height and full-sized lines fit')
  g.mission_hud.open("fleet");await settle();await click(g.unit_buttons[0]);check(g.order_buttons.contact_hold.text=='IF\nCONTACT' and g.order_buttons.silent.text=='SILENT ✓','Quietus keeps fleet guard and silent-running controls')
  g.queue_free();await settle()
 await create_timer(.5).timeout
 print('DRONE OPERATIONS UI CHECKS ',checks,' FAILURES ',failures);quit(1 if failures else 0)
