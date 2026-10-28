extends RefCounted
# Iron Choir 22-29 authored geometry and rosters. Layouts feed terrain.gd entries
# ([shape,bands]); rosters feed roster.gd guards. Work sites stay in the operation.
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
const A=T.ALL
static func box(x:float,y:float,w:float,h:float,bands:Array=A)->Array:return [Rect2(x,y,w,h),bands]
# 22 ring yard: west service lane, east shipping lane, a press pillar between.
static func _yard()->Array:
 return [box(1050,700,500,1000),box(1900,900,450,1100),box(0,500,250,1700),box(1450,0,350,200),
  box(1650,1250,200,200,[1]),box(1500,2000,500,200,[1,2]),box(1250,1800,200,150,[0])]
# 23 pressure stair: bulkheads are structures (see structures()); pillars add water.
static func _stair()->Array:
 return [box(1900,1300,200,300),box(500,1250,200,250,[1,2]),box(900,700,250,200,[0,1]),box(1500,550,200,300,[1,2]),box(2000,1400,150,150,[0])]
# 24 and 25 keep their original massing.
const ROCKS={
 24:[Rect2(1100,700,450,1400),Rect2(1850,700,400,650),Rect2(2250,1100,350,250)],
 25:[Rect2(1000,800,500,1000),Rect2(1800,650,500,750),Rect2(1900,1850,600,250)]}
# 26 deep sump: walls in every band, a lid over the basin in shallow and middle so the
# basin is entered through the west opening at depth; a deep trench spine outside.
static func _sump()->Array:
 return [box(1100,150,750,150),box(1100,300,150,50),box(1100,500,150,300),box(1700,300,150,500),box(1100,700,200,100),box(1650,700,200,100),
  box(1250,350,450,350,[0,1]),box(600,1100,300,800,[2]),box(1500,1300,400,700,[2]),box(2200,600,300,1500,[0,1]),box(2100,2000,500,300)]
# 27 counterweight grave: toppled machinery with the lane west and the cradle lane open.
static func _grave()->Array:
 return [box(1000,1000,550,450),box(1700,500,450,1400),box(2300,1350,300,350),box(1900,2100,500,250),
  box(1150,1800,300,300,[1]),box(2400,700,300,250),box(0,900,250,1000,[1])]
# 28 bell tow: staggered bulkheads force an S-shaped tow through the west gallery.
static func _bell()->Array:
 return [box(0,500,250,1800),box(300,1700,450,120),box(800,1300,500,120),box(300,900,400,120),box(800,600,500,120),
  box(1400,600,500,1500),box(2100,700,300,900),box(2300,1900,500,300,[0,1])]
# 29 plant: powered block, pipe gallery on the north, feed room on the west.
static func _plant()->Array:
 return [box(1250,1000,700,500),box(1250,450,200,550),box(2000,1300,350,500),box(300,1700,500,120,[0,1]),box(1000,2000,600,150),box(250,700,300,350,[1,2])]
static func entries(id:int)->Array:
 match id:
  22:return _yard()
  23:return _stair()
  26:return _sump()
  27:return _grave()
  28:return _bell()
  29:return _plant()
 return ROCKS.get(id,[]).map(func(r):return [r,[1]])
# Bulkheads that gate the stair in every band; each shutter site opens one gap.
static func structures(id:int)->Array:
 match id:
  23:return [Rect2(0,1750,500,70),Rect2(800,1750,2200,70),Rect2(0,1160,1180,70),Rect2(1680,1160,1320,70),Rect2(0,450,2250,70),Rect2(2650,450,350,70)]
  24:return [Rect2(1550,1400,100,600),Rect2(1700,1400,150,600)]
  25:return [Rect2(1500,1400,100,350),Rect2(1650,1400,150,350)]
 return []
static func roster(m:Dictionary,id:int,history:Dictionary)->void:
 match id:
  22:R.add(m,[R.guard("interceptor",Vector2(950,1250),1,[Vector2(950,1250),Vector2(950,1400)]),R.guard("interceptor",Vector2(2550,1500)),R.guard("warden",Vector2(1700,2300))])
  23:R.add(m,[R.guard("interceptor",Vector2(2400,1500)),R.guard("warden",Vector2(1500,850),2)])
  24:R.add(m,[R.guard("interceptor",Vector2(1600,2200),1,[Vector2(1600,2200),Vector2(1650,2300)]),R.guard("warden",Vector2(2700,1600)),R.guard("relay",Vector2(1650,550))])
  25:
   R.add(m,[R.guard("interceptor",Vector2(1600,2200),1,[Vector2(1600,2200),Vector2(1650,2300)]),R.guard("warden",Vector2(950,1100)),R.guard("relay",Vector2(1650,550))])
   if history.get("facts",{}).get("choir_choice","")=="isolate":m.sirens.pop_back()
   if history.get("facts",{}).get("choir_plant","")=="dismantle":m.sirens.remove_at(1)
  26:R.add(m,[R.guard("warden",Vector2(1600,550),2),R.guard("interceptor",Vector2(850,700),2)])
  27:R.add(m,[R.guard("interceptor",Vector2(1700,300)),R.guard("interceptor",Vector2(1100,1650)),R.guard("warden",Vector2(2000,2500))])
  28:R.add(m,[R.guard("interceptor",Vector2(1250,1550)),R.guard("interceptor",Vector2(1200,200)),R.guard("warden",Vector2(1050,1450))])
  29:R.add(m,[R.guard("warden",Vector2(2200,600)),R.guard("interceptor",Vector2(2050,950))])
