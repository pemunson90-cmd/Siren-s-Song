extends "res://tests/wide_menus_ui_tests.gd"
# WP-84: large text must not cost the big screen. On the unfolded inner screen (2184x1968), the cover screen
# (2520x1080) and a phone (1080x2400) at 100%, 130% and 150% text, the hub, a briefing, Settings, FITTINGS,
# SUPPLIES, LOADOUT and FIELD RECORDS keep their columns where every row still fits, show no clipped control
# and keep every button at least 48 px tall. Real screens, real controls.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const MIN_BUTTON=48.
var report:Array=[]
# Controls drawn outside the scrolling page they sit in (the page never scrolls sideways), or trimmed text.
func clipped(node)->Array:
 var out:Array=[]
 for page in node.find_children("*","ScrollContainer",true,false):
  if page.is_visible_in_tree() and page.get_child_count()>0 and page.get_child(0) is Control and page.get_child(0).get_combined_minimum_size().x>page.size.x+1.:out.append("page wider than its window "+page.name)
 for control in node.find_children("*","Control",true,false):
  if not control.is_visible_in_tree() or not (control is Label or control is Button):continue
  var page=control.get_parent()
  while page!=null and not page is ScrollContainer:page=page.get_parent()
  if page==null:continue
  var area=page.get_global_rect();var r=control.get_global_rect()
  if r.position.x<area.position.x-1. or r.end.x>area.end.x+1.:out.append("outside "+control.name+" '"+str(control.text).left(24)+"'")
  if control is Label and (control.clip_text or control.text_overrun_behavior!=TextServer.OVERRUN_NO_TRIMMING) and control.get_minimum_size().x>r.size.x+1.:out.append("trimmed '"+control.text.left(24)+"'")
  if control is Button and (control.clip_text or control.text_overrun_behavior!=TextServer.OVERRUN_NO_TRIMMING) and control.get_minimum_size().x>r.size.x+1.:out.append("trimmed '"+control.text.left(24)+"'")
 return out
# WP-93: nothing is drawn past the left or right edge of the screen, and the menu panel is never wider than it.
func off_screen(node)->Array:
 var out:Array=[];var screen:=Rect2(Vector2.ZERO,node.size)
 var panel=node.get("menu")
 if panel is Control and panel.visible and (panel.get_global_rect().position.x<-1. or panel.get_global_rect().end.x>screen.end.x+1.):out.append("menu panel "+str(panel.get_global_rect()))
 for control in node.find_children("*","Control",true,false):
  if not control.is_visible_in_tree() or not (control is Label or control is Button or control.has_meta("bar_label")):continue
  var r=control.get_global_rect()
  if r.size.x>0. and (r.position.x<-1. or r.end.x>screen.end.x+1.):out.append("off screen "+control.name+" '"+str(control.get("text")).left(24)+"' "+str(r))
 return out
# WP-93: a button that wraps its text breaks only between words, never inside one.
func word_breaks(node)->Array:
 var out:Array=[]
 for b in node.find_children("*","Button",true,false):
  if not b.is_visible_in_tree() or b.text.is_empty() or b is CheckBox or b is OptionButton:continue
  var room:float=b.size.x-b.get_theme_stylebox("normal").get_minimum_size().x
  var font:Font=b.get_theme_font("font");var size:int=b.get_theme_font_size("font_size")
  for word in b.text.replace("\n"," ").split(" ",false):
   if font.get_string_size(word,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>room+1.:out.append("word '"+word+"' broken in '"+b.text.left(24).replace("\n"," ")+"'");break
 return out
func short_buttons(node)->Array:
 var out:Array=[]
 for b in node.find_children("*","Button",true,false):
  if b.is_visible_in_tree() and b.get_global_rect().size.y<MIN_BUTTON-.5 and not (b is CheckBox or b is OptionButton):out.append("short '"+b.text.left(20)+"' "+str(b.get_global_rect().size.y))
 return out
# `columns` is 2 when the screen must keep two columns at this text size, 1 when it must stay one, 0 when either will do.
func audit(node,label:String,columns_wanted:int=0)->void:
 var problems:Array=clipped(node);problems.append_array(short_buttons(node));problems.append_array(off_screen(node));problems.append_array(word_breaks(node))
 var width=0.
 var panel=node.get("panel_box") if node.get("panel_box")!=null else null
 if panel!=null:width=panel.get_global_rect().size.x
 var columns=int(node.get_meta("hub_wide",false) or node.get_meta("prep_wide",false))+1
 var need=0.
 for page in node.find_children("*","ScrollContainer",true,false):
  if page.is_visible_in_tree() and page.get_child_count()>0 and page.get_child(0) is Control:need=maxf(need,page.get_child(0).get_combined_minimum_size().x)
 var mins:Array=[]
 for row in node.find_children("*","HBoxContainer",true,false):
  if row.is_visible_in_tree() and row.get_child_count()==2 and row.get_child(0) is VBoxContainer and row.get_child(1) is Control and row.get_child(0).size_flags_horizontal&Control.SIZE_EXPAND:mins.append("%d/%d"%[roundi(row.get_child(0).get_combined_minimum_size().x),roundi(row.get_child(0).size.x)])
 var canvas=node.size.x if node is Control else 0.
 if columns_wanted>0:check(columns==columns_wanted,label+" uses "+str(columns_wanted)+" column(s), not "+str(columns))
 if columns==1 and canvas>=node.size.y and width>0.:check(width>=minf(Metrics.MENU_COLUMN,canvas-Metrics.MENU_MARGIN)-1.,label+" single column is at least 800 wide or the whole screen")
 report.append("%s | columns min/actual %s | %d column(s) | panel %d px | content needs %d px | %s"%[label,str(mins.slice(0,3)),columns,roundi(width),roundi(need),"ok" if problems.is_empty() else str(problems.slice(0,4))])
 check(problems.is_empty(),label+" shows no clipped text and no short button "+str(problems.slice(0,4)))
func game_screens(shape:Vector2i,scale:float,two:bool)->void:
 root.size=shape;await settle()
 Settings.current["text_scale"]=scale
 var path="user://large-text-%d.save"%shape.x
 var game=await make_game(path)
 game.size=Vector2(game.get_viewport_rect().size);game._layout();await settle()
 var tag="%dx%d at %d%%"%[shape.x,shape.y,roundi(scale*100)]
 report.append("-- %s: canvas %s touch %d"%[tag,str(game.size),roundi(game.ui_touch_height)])
 game._show_campaign();await settle();await audit(game,"hub "+tag,2 if two else 1)
 if two:check(game.panel_box.get_global_rect().size.x>=.8*game.size.x,"the hub uses at least 80% of the width at "+tag)
 game.set_meta("ops_home_details_open",true);game._show_campaign();await settle();await audit(game,"hub with LOADOUT open "+tag,2 if two else 1)
 game.set_meta("ops_home_details_open",false)
 for index in [0,1]:
  game._briefing(index);await settle();await audit(game,"briefing %02d %s"%[index+1,tag],2 if two else 1)
  # WP-93: the briefing with LOADOUT DETAILS open (HIDE LOADOUT DETAILS showing) stays inside the screen.
  var fold=game.menu.find_children("*","Button",true,false).filter(func(b):return b.get_meta("action","")=="fit_fold")
  if not fold.is_empty():
   if fold[0].text.begins_with("SHOW"):fold[0].pressed.emit();await settle();await settle()
   var opened=game.menu.find_children("*","Button",true,false).any(func(b):return b.text.begins_with("HIDE LOADOUT"))
   check(opened,"briefing %02d %s LOADOUT DETAILS opens"%[index+1,tag])
   await audit(game,"briefing %02d LOADOUT DETAILS open %s"%[index+1,tag],2 if two else 1)
 game._show_fittings();await settle();await audit(game,"FITTINGS "+tag,2 if two else 1)
 game._show_economy();await settle();await audit(game,"SUPPLIES "+tag,2 if two else 1)
 game._show_campaign();await settle()
 await press(game,"archive");await settle();await audit(game,"FIELD RECORDS "+tag)
 await finish(game,path)
func settings_screens(shape:Vector2i,scale:float)->void:
 root.size=shape;await settle()
 Settings.current["text_scale"]=scale
 var path="user://large-text-front-%d.save"%shape.x
 var game=await make_game(path)
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game);await settle()
 var tag="%dx%d at %d%%"%[shape.x,shape.y,roundi(scale*100)]
 for page in ["audio","display","controls"]:
  front.settings_page=page;front._settings_screen();await settle()
  var problems:Array=clipped(front);problems.append_array(short_buttons(front))
  var first=front.find_children("*","HSlider",true,false)
  report.append("Settings %s %s | %s"%[page,tag,"ok" if problems.is_empty() else str(problems.slice(0,4))])
  check(problems.is_empty(),"Settings "+page+" "+tag+" shows no clipped text and no short button "+str(problems.slice(0,4)))
 await finish(game,path)
func run():
 for shape in [Vector2i(2184,1968),Vector2i(2520,1080),Vector2i(1080,2400)]:
  for scale in [1.,1.3,1.5]:
   await game_screens(shape,scale,shape.x>shape.y)
   await settings_screens(shape,scale)
 Settings.current["text_scale"]=1.
 for line in report:print("LT ",line)
 print("LARGE TEXT SCREEN UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
