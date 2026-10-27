extends RefCounted
# Presentation only. Mapping remains available to audio with either art switch off.
static var enabled=true
const ArtTable=preload("res://src/presentation/art/art_table.gd")
# Water modulation, upper/lower light, suspended material, measured floor and stone.
const STYLES={
 "shelf":{"water":Color("8fc8b2"),"light":Color(.23,.43,.32,.13),"falloff":.11,"dust":Color(.48,.68,.51,.19),"drift":Vector2(1.8,.35),"floor":Color("183e39"),"stone":Color("53675b"),"edge":Color("93aaa0")},
 "divergence_deep":{"water":Color("777bb5"),"light":Color(.22,.22,.43,.07),"falloff":.32,"dust":Color(.49,.48,.72,.13),"drift":Vector2(.3,-.6),"floor":Color("202936"),"stone":Color("404958"),"edge":Color("8996af")},
 "divergence_shelf":{"water":Color("a5bda0"),"light":Color(.39,.43,.26,.12),"falloff":.17,"dust":Color(.66,.66,.43,.22),"drift":Vector2(2.2,.5),"floor":Color("303c32"),"stone":Color("626653"),"edge":Color("b0b19a")},
 "confluence":{"water":Color("8fb8b8"),"light":Color(.27,.39,.37,.10),"falloff":.20,"dust":Color(.49,.63,.61,.18),"drift":Vector2(-1.6,.7),"floor":Color("253b3e"),"stone":Color("536661"),"edge":Color("91a59b")},
 "glass":{"water":Color("8ab5d2"),"light":Color(.28,.41,.57,.14),"falloff":.18,"dust":Color(.59,.73,.83,.17),"drift":Vector2(.7,-1.0),"floor":Color("1e394a"),"stone":Color("4c6576"),"edge":Color("a2bfcd")},
 "iron":{"water":Color("b29589"),"light":Color(.44,.27,.17,.10),"falloff":.26,"dust":Color(.68,.43,.29,.23),"drift":Vector2(-.8,1.2),"floor":Color("382e2c"),"stone":Color("67514a"),"edge":Color("b39b83")},
 "calder":{"water":Color("8cab94"),"light":Color(.31,.40,.24,.10),"falloff":.29,"dust":Color(.59,.61,.42,.23),"drift":Vector2(1.0,-1.5),"floor":Color("293b30"),"stone":Color("4e6150"),"edge":Color("a3b092")}
}
static func key(mission:Dictionary)->String:
 var id=int(mission.get("id",0))
 if id==6:return "divergence_shelf" if str(mission.get("chosen_route","deep"))=="shelf" else "divergence_deep"
 if id in [7,9,38]:return "divergence_deep"
 if id in [8,10,39]:return "divergence_shelf"
 if id in [11,12,13,40]:return "confluence"
 if (id>=14 and id<=21) or id==37:return "glass"
 if id>=22 and id<=31:return "iron"
 if id>=32 and id<=36:return "calder"
 return "shelf"
static func style(mission:Dictionary)->Dictionary:
 return STYLES[key(mission)] if enabled and ArtTable.enabled else {}
