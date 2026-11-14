extends RefCounted
const Names=preload("res://src/names.gd")
const TrialRules=preload("res://src/trial_rules.gd")
# Only cached observations enter this readout. A stale mode is never live truth.
# lock_seconds: the dive's lock length, sim.lock_seconds() (the caller passes it; the default is the standard length).
static func entries(contacts: Dictionary,elapsed: float,units: Array,clear_view: Callable=Callable(),target_lookup:Callable=Callable(),lock_seconds:float=TrialRules.STANDARD_LOCK_SECONDS) -> Array:
	var result: Array=[]
	for id in contacts:
		var c=contacts[id];var age=maxf(0,elapsed-float(c.time))
		if age>20:continue
		var tag="S%d"%(int(id)+1)
		var role={Names.ROLE_HUNTER:"HUNTER",Names.ROLE_SENTINEL:"GUARD",Names.ROLE_SWEEPER:"SWEEPER",Names.ROLE_BUOY:"LISTENER",Names.ROLE_RELAY:"RELAY",Names.ROLE_INTERCEPTOR:"INTERCEPTOR",Names.ROLE_WARDEN:"WARDEN","unknown":"UNCLASSIFIED","STATIC":"STATIC","PATROLLER":"PATROLLER","UNCLASSIFIED":"UNCLASSIFIED"}.get(preload("res://src/simulation/contact_identity.gd").contact_type(c),"PATROL")
		var fresh=age<0.3;var urgent=false
		var text="%s %s · %s"%[tag,role,preload("res://src/simulation/contact_identity.gd").contact_mode(c)] if fresh else "%s %s · LAST SEEN %ds"%[tag,role,int(age)]
		if c.get("source","") in ["active","triangulation"]:text+=" · %d%%"%roundi(c.get("confidence",0.)*100)
		if c.get("band",-1)>=0:text+=" · "+Names.BANDS[c.band]
		var target=int(c.get("target",-1));var plain=""
		var victim=target_lookup.call(c) if target_lookup.is_valid() else units[target] if target>=0 and target<units.size() else {}
		if fresh and c.lock>0 and not victim.is_empty() and victim.alive and (not clear_view.is_valid() or clear_view.call(c.pos,victim.pos)):
			urgent=true;plain=text
			text="%s %s → %s · %s"%[tag,role,victim.name,"FIRING" if c.lock>=lock_seconds else "BEAM %.1fs"%(lock_seconds-c.lock)]
		var stun=preload("res://src/simulation/observed_stun.gd").remaining(c,elapsed)
		if fresh and stun>0:
			urgent=false;text="%s %s · STUNNED %.1fs"%[tag,role,stun]
		var report=""
		if fresh and c.get("report_remaining",0)>0:report=" · REPORT %.1fs"%c.report_remaining
		elif fresh and c.get("report_sent",false):report=" · REPORT SENT"
		text+=report
		# locking: a lock countdown the warning card also states. ocean_view.unstated_entries drops it while the card
		# shows, keeping "plain" (the same row without the lock sentence) when it also carries a report.
		result.append({"key":id,"tag":tag,"text":text,"pos":c.pos,"fresh":fresh,"urgent":urgent,"locking":urgent and c.lock<lock_seconds,"report":report,"plain":plain+report,"order":result.size()})
	result.sort_custom(func(a,b):return a.urgent if a.urgent!=b.urgent else a.order<b.order)
	return result
