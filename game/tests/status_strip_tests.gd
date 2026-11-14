extends SceneTree
# WP-83: the status strip says each instruction once, keeps the newest message whole, and fits two lines at every text size.
# The strip itself is MissionHud.intent; this suite checks the text it is given by VoiceFeed.strip_text.
const Feed=preload("res://src/presentation/archive/voice_feed.gd")
const OPENING="Drones aboard. Tap a craft for DEPTH AND SONAR; tap water to route or deploy."
const HINT="DEEP under the arch · MIDDLE camera/recovery · craft → DEPTH AND SONAR."
const DEFAULT_HINT="Craft → DEPTH AND SONAR · bearings need movement or a second receiver; depth costs time."
const WARNING="SIREN WARNING · patrol sweeping toward QUIETUS from the north-east · hold depth and cut engines or run for the trench before it reaches you"
const HEAD="QUIETUS · MIDDLE · REPLACE"
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func lines(text:String,width:float,font_size:int)->int:
	var label=Label.new();label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size);label.custom_minimum_size.x=width;label.size.x=width;label.text=text
	root.add_child(label);var count=label.get_line_count();label.queue_free();return count
func run():
	await process_frame
	# Chart widths for the cover canvas (1680) and the inner canvas (1080); font 22 normal, 33 at 150%.
	for shape in [[1400.,22],[1400.,33],[900.,22],[900.,33]]:
		var width:float=shape[0];var font:int=shape[1]
		var fits=func(text:String)->bool:return lines(text,width,font)<=2
		for case in [[OPENING,HINT],[OPENING,DEFAULT_HINT],[WARNING,HINT],["",HINT],[OPENING,""]]:
			var text:String=Feed.strip_text(HEAD,case[0],case[1],fits)
			var label="w%d f%d '%s'"%[width,font,str(case[0]).left(14)]
			check(lines(text,width,font)<=2 or (text==case[0] and lines(case[0],width,font)>2),label+" holds two lines, or is a message too long for two that stands alone")
			check(case[0].is_empty() or text.contains(case[0]),label+" keeps the message whole")
			check(not text.contains("..."),label+" never cuts a word")
			check(text.to_lower().count("depth and sonar")<=1,label+" says DEPTH AND SONAR once")
	var wide=func(_text):return true
	var text:String=Feed.strip_text(HEAD,OPENING,HINT,wide)
	check(text==HEAD+" · "+OPENING+"\nDEEP under the arch · MIDDLE camera/recovery","opening text keeps the facts and drops the repeated instruction: "+text)
	check(Feed.strip_text(HEAD,OPENING,DEFAULT_HINT,wide).ends_with("bearings need movement or a second receiver; depth costs time."),"the default hint keeps its facts")
	check(Feed.strip_text(HEAD,"",HINT,wide)==HEAD+"\n"+HINT,"an empty message leaves the standing hint whole")
	var narrow=func(candidate:String)->bool:return not candidate.contains("\n")
	check(Feed.strip_text(HEAD,WARNING,HINT,narrow)==HEAD+" · "+WARNING,"a long warning drops the standing hint first")
	print("STATUS STRIP CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
