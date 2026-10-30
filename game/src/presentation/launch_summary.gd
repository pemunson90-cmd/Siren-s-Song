extends RefCounted
# Audit 091 F10: compact launch and retry economics on the briefing. Presentation only.
# It reads the same prices the launch charges (EconomyPanel.launch_cost and its parts) on
# copies; it never pays, refits, changes a price or writes the economy.
const Economy=preload("res://src/campaign/economy.gd")
const EconomyPanel=preload("res://src/presentation/economy_panel.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const FitModel=preload("res://src/presentation/fit_surface/fit_surface.gd")
static func _sum(a:Dictionary,b:Dictionary)->Dictionary:
 var out=a.duplicate()
 for key in b:out[key]=out.get(key,0)+b[key]
 return out
static func _tools_cost(host)->Dictionary:
 return Racks.cost(Economy.Losses.racks(host.economy,host.tool_racks),host.upgrade,host.economy)
# The refit part of a retry with this exact fit: the launch records it as the last fit.
static func retry_cost(host)->Dictionary:
 var fit=EconomyPanel.fitted(host)
 var after=host.economy.duplicate(true);after.last_fit=fit.duplicate(true)
 return _sum(Economy.refit_cost(after,fit),_tools_cost(host))
# How many further identical attempts the balance covers after this launch (capped for display).
static func retries_covered(host,cap:int=9)->int:
 var first=EconomyPanel.launch_cost(host)
 if not Economy.can_pay(host.economy,first):return -1
 var left=host.economy.stock.duplicate()
 for key in first:left[key]=left.get(key,0)-first[key]
 var each=retry_cost(host)
 if each.is_empty():return cap
 var n=cap
 for key in each:
  if each[key]>0:n=mini(n,int(left.get(key,0))/int(each[key]))
 return n
static func text(host)->String:
 var fit=EconomyPanel.fitted(host)
 var refit=Economy.refit_cost(host.economy,fit);var tools=_tools_cost(host)
 var lines=["LAUNCH SUMMARY"]
 lines.append("THIS LAUNCH · %s (fittings %s · extra tool charges %s)"%[Economy.fmt(EconomyPanel.launch_cost(host)),Economy.fmt(refit),Economy.fmt(tools)])
 var covered=retries_covered(host)
 var retry=Economy.fmt(retry_cost(host))
 if covered<0:lines.append("RETRY SAME FIT · %s · balance short for this launch by %s"%[retry,Economy.shortfall(host.economy,EconomyPanel.launch_cost(host))])
 else:lines.append("RETRY SAME FIT · %s · balance then covers %s more"%[retry,"%d+"%covered if covered>=9 else str(covered)])
 lines.append("BARE STANDARD FLEET, NO EXTRA CHARGES · FREE")
 var context=host._equipment_context() if host.has_method("_equipment_context") else {}
 if not context.is_empty():lines.append(FitModel.summary(context))
 return "\n".join(lines)
# Two lines for compact briefings: launch/retry/bare costs, then one short mount entry per craft.
static func short(host)->String:
 var covered=retries_covered(host)
 var cover="SHORT" if covered<0 else ("%d+"%covered if covered>=9 else str(covered))
 var line="LAUNCH %s · RETRY SAME FIT %s · RETRIES COVERED %s · BARE FLEET FREE"%[Economy.fmt(EconomyPanel.launch_cost(host)),Economy.fmt(retry_cost(host)),cover]
 var context=host._equipment_context() if host.has_method("_equipment_context") else {}
 if context.is_empty():return line
 var slots=FitModel.Catalog.canonical(context.get("slots",{}));var mounts=[]
 for unit in 3:
  var b=FitModel.Catalog.budget(slots,unit)
  mounts.append("%s %s %d"%[["Q","A","B"][unit],str(b.name).to_upper(),FitModel.Catalog.items_for(slots,unit).size()])
 return line+"\nMOUNTED · "+" · ".join(mounts)
