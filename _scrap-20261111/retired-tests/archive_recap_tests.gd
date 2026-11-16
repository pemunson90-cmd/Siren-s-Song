extends SceneTree
const Recap=preload("res://src/campaign/archive_recap.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;print("FAIL ",label)
	else:print("PASS ",label)
func _initialize():
	check(Recap.summary({})=="No chapter records are retained.","empty or old archive explicitly has no retained chapter records")
	check(Recap.summary({"unknown":{}})==Recap.summary({}),"unknown keys cannot fabricate discoveries")
	var text=Recap.summary({"blackwater_request":{}})
	check(text=="Blackwater · a relay asks for its lost log.","request alone records the relay request without fabricating its reply")
	check(Recap.summary({"blackwater_reply":{}})=="Blackwater · the driller's last log.","actual reply key earns the retained driller log")
	text=Recap.summary({"furnace":{}})
	check(text=="Foundry · a vent on a feed line.","furnace alone does not fabricate a cradle observation")
	text=Recap.summary({"cradle":{}})
	check(text=="Foundry · open frames on rails to the trench edge.","cradle alone reports its observed frames and rails")
	text=Recap.summary({"well_pattern":{}})
	check("unverified" in text and not "matches" in text,"pattern-only archive preserves the unverified comparison")
	text=Recap.summary({"well_signature":{}})
	check("matches Quietus" in text and "speaker and intent unresolved" in text and not "pilot" in text,"earned Well match preserves unresolved speaker and intent")
	check(not "evacuation" in Recap.summary({"transmitter":{}}) and not "fracture" in Recap.summary({"departure":{}}),"partial finale optics cannot fabricate the decoded warning")
	check(Recap.summary({"warning":{}})=="Finale · bearings to every loud site; two still answer.","retained warning key earns its decoded fact")
	var full={}
	for key in ["blackwater_request","blackwater_reply","furnace","cradle","well_pattern","well_signature","transmitter","departure","warning"]:full[key]={"name":"retained","caption":"original","optical":key}
	var before=var_to_bytes(full);text=Recap.summary(full)
	check(text.split("\n").size()==4 and ["Blackwater","Foundry","Well","Finale"].all(func(chapter):return chapter in text),"full archive connects one fact per retained chapter")
	check(text.length()<=330,"full recap stays a short summary rather than repeating every caption")
	check(var_to_bytes(full)==before,"recap reads existing archive without changing entries or schema")
	var reverse={};var keys=full.keys();keys.reverse()
	for key in keys:reverse[key]=full[key]
	check(Recap.summary(reverse)==text,"recap narrative order is stable across archive insertion order")
	print("ARCHIVE RECAP CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
