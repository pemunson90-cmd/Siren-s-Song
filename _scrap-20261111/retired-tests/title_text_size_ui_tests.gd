extends "res://tests/wide_menus_ui_tests.gd"
# WP-105: the text-size setting reaches the title screen. At 130% the heading, the tagline and every button on the
# title are larger than at 100%, on the cover screen (2520x1080) and the inner screen (2184x1968). The text size
# is read from the saved settings, as a launch reads it.
const SettingsStore=preload("res://src/persistence/settings_store.gd")
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
var report:Array=[]
func title_sizes(shape:Vector2i,scale:float)->Dictionary:
 root.size=shape;await settle()
 var path="user://title-text-%d.save"%shape.x
 var game=await make_game(path)
 var store=SettingsStore.new();store.path=path+".settings"
 var values=SettingsStore.DEFAULTS.duplicate(true);values.text_scale=scale;store.save_settings(values)
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game);await settle()
 var out={"heading":front.title_label.get_theme_font_size("font_size"),"scale":Settings.text_scale()}
 var buttons:Array=[]
 for b in front.find_children("*","Button",true,false):
  if b.is_visible_in_tree():buttons.append(b.get_theme_font_size("font_size"))
 out["buttons"]=buttons
 out["hub"]=Metrics.button_font(game.ui_touch_height,scale)
 out["heights"]=front.find_children("*","Button",true,false).filter(func(b):return b.is_visible_in_tree()).map(func(b):return b.get_global_rect().size.y)
 await finish(game,path)
 return out
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  var one=await title_sizes(shape,1.)
  var big=await title_sizes(shape,1.3)
  var tag=" at "+str(shape)
  report.append("%s heading %d -> %d buttons %s -> %s heights %s -> %s"%[str(shape),one.heading,big.heading,str(one.buttons),str(big.buttons),str(one.heights),str(big.heights)])
  check(is_equal_approx(big.scale,1.3),"the saved 130% text size is live on the title"+tag)
  check(big.heading>=roundi(one.heading*1.25),"the title heading is larger at 130%"+tag)
  check(big.buttons.all(func(px):return px==big.hub) and one.buttons.all(func(px):return px==one.hub),"the title buttons use the hub font at both sizes"+tag)
  check(not big.buttons.is_empty() and big.buttons.size()==one.buttons.size(),"the title has its buttons"+tag)
  for i in mini(one.buttons.size(),big.buttons.size()):
   check(big.buttons[i]>=roundi(one.buttons[i]*1.25),"title button %d text is larger at 130%%%s"%[i,tag])
 Settings.current["text_scale"]=1.
 for line in report:print("TT ",line)
 print("TITLE TEXT SIZE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
