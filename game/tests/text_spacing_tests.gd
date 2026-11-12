extends SceneTree
# WP-11 item I8: player-facing fitting, hull and chassis text keeps a space
# between words and numbers. A digit may be followed only by a unit (m, s, %, x)
# or by m/s; a letter is never immediately followed by a digit.
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Hulls=preload("res://src/equipment/hulls.gd")
const Chassis=preload("res://src/equipment/chassis.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
static func glued(text:String)->Array:
 var found=[]
 var letter_digit=RegEx.create_from_string("[A-Za-z][0-9]")
 var digit_letter=RegEx.create_from_string("[0-9][A-Za-z]+")
 for m in letter_digit.search_all(text):found.append(m.get_string())
 for m in digit_letter.search_all(text):
  var tail=m.get_string().substr(1)
  if tail in ["m","s","x"]:continue # m also covers m/s: the slash ends the match
  found.append(m.get_string())
 return found
func _initialize():
 # The scanner itself must catch the defects the critics reported.
 for sample in ["by45%","at112m/s instead of78m/s","remains42m/s","takes6s instead of12s"]:
  check(not glued(sample).is_empty(),"scanner flags '%s'"%sample)
 for sample in ["by 45%","at 112m/s instead of 78m/s","takes 2.5s","within 60m","3x zoom"]:
  check(glued(sample).is_empty(),"scanner accepts '%s' %s"%[sample,str(glued(sample))])
 for id in Catalog.ITEMS:
  for key in ["name","benefit","cost"]:
   var text=str(Catalog.ITEMS[id].get(key,""))
   check(glued(text).is_empty(),"fitting %s %s keeps number spacing %s"%[id,key,str(glued(text))])
 for table in [Hulls.HULLS,Chassis.CHASSIS]:
  for id in table:
   for key in ["name","summary"]:
    var text=str(table[id].get(key,""))
    check(glued(text).is_empty(),"frame %s %s keeps number spacing %s"%[id,key,str(glued(text))])
 print("TEXT SPACING CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
