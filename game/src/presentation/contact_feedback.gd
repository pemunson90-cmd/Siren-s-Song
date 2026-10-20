extends RefCounted
# Only cached observations enter this readout. A stale mode is never live truth.
static func entries(contacts: Dictionary,elapsed: float,units: Array,clear_view: Callable=Callable(),target_lookup:Callable=Callable()) -> Array:
	var result: Array=[]
	for id in contacts:
		var c=contacts[id];var age=maxf(0,elapsed-float(c.time))
		if age>20:continue
		var tag="S%d"%(int(id)+1)
		var role={"hunter":"HUNTER","sentinel":"GUARD","sweeper":"SWEEPER","unknown":"UNCLASSIFIED"}.get(c.get("type","patroller"),"PATROL")
		var fresh=age<0.3;var urgent=false
		var text="%s %s · %s"%[tag,role,c.mode] if fresh else "%s %s · LAST SEEN %ds"%[tag,role,int(age)]
		if c.get("source","") in ["active","triangulation"]:text+=" · %d%%"%roundi(c.get("confidence",0.)*100)
		if c.get("band",-1)>=0:text+=" · "+["SHALLOW","MIDDLE","DEEP"][c.band]
		var target=int(c.get("target",-1))
		var victim=target_lookup.call(c) if target_lookup.is_valid() else units[target] if target>=0 and target<units.size() else {}
		if fresh and c.lock>0 and not victim.is_empty() and victim.alive and (not clear_view.is_valid() or clear_view.call(c.pos,victim.pos)):
			urgent=true
			text="%s %s → %s · %s"%[tag,role,victim.name,"FIRING" if c.lock>=4 else "BEAM %.1fs"%(4-c.lock)]
		if fresh and c.get("report_remaining",0)>0:text+=" · REPORT %.1fs"%c.report_remaining
		elif fresh and c.get("report_sent",false):text+=" · REPORT SENT"
		result.append({"key":id,"tag":tag,"text":text,"pos":c.pos,"fresh":fresh,"urgent":urgent,"order":result.size()})
	result.sort_custom(func(a,b):return a.urgent if a.urgent!=b.urgent else a.order<b.order)
	return result
