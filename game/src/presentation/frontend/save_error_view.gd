extends RefCounted
# [AI-DESIGNED] A7 (code audit, Pat approved 2026-11-12)
# Shared layout for the save-problem notices and the RETRY SAVE button in the Career, Expedition and
# Challenge front ends and result menus. Every word shown comes from the calling mode; this file adds none.
const WARN=Color("efc28d")
# Front end: the profile's recovery notice then its save error, read from "<prefix>recovery_notice" / "<prefix>save_error".
static func notices(front,prefix:String,size:int)->void:
	var notice=str(front.host.get_meta(prefix+"recovery_notice",""))
	if not notice.is_empty():front._text(notice,size,WARN)
	var error=str(front.host.get_meta(prefix+"save_error",""))
	if not error.is_empty():front._text(error,size,WARN)
# Front end: one warning text, then the retry button.
static func front_retry(front,message:String,size:int,label:String,callback:Callable,id:String)->void:
	if not message.is_empty():front._text(message,size,WARN)
	front._button(label,callback,id)
# Result and dive menus inside a session: one menu text, then the retry button in the panel.
static func menu_retry(session,message:String,size:int,label:String,callback:Callable,id:String)->void:
	session._menu_text(message,size)
	session._button(session.panel_box,label,callback,id)
