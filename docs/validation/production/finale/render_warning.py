"""Original decoded-carrier schematic. Rasterize labels for Godot's SVG importer."""
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.path import Path as MPath
from matplotlib.patches import PathPatch
fig=plt.figure(figsize=(12.8,7.2),dpi=100,facecolor='#081b25')
ax=fig.add_axes((0,0,1,1)); ax.set(xlim=(0,1280),ylim=(720,0)); ax.axis('off')
for x in range(60,1220,80):ax.plot([x,x],[120,635],color='#234047',lw=.6)
for y in range(155,640,80):ax.plot([60,1220],[y,y],color='#234047',lw=.6)
for points in [[(60,292),(190,280),(300,313),(410,292),(540,345),(660,325),(750,360),(840,335),(970,385),(1100,362),(1220,390)],[(60,360),(200,355),(320,380),(420,370),(550,414),(670,390),(770,435),(870,410),(980,445),(1100,420),(1220,452)]]:
 ax.plot(*zip(*points),color='#708c91',lw=2.5)
ax.plot(*zip(*[(360,180),(460,286),(425,343),(590,475),(560,550),(650,640)]),color='#db9f70',lw=7)
ax.plot(*zip(*[(460,286),(610,260),(700,290)]),color='#db9f70',lw=3)
ax.add_patch(PathPatch(MPath([(1050,310),(1070,500),(840,560),(740,585)],[MPath.MOVETO,MPath.CURVE4,MPath.CURVE4,MPath.CURVE4]),facecolor='none',edgecolor='#83d7ce',lw=8))
ax.plot([805,740,825],[525,585,600],color='#83d7ce',lw=8)
for x,y,label,size,color in [(60,73,'QUIETUS / RESOLVED CARRIER',23,'#8adbd3'),(60,118,'CROWN + OUTBOUND WAKES + HYDROPHONES',17,'#b7cccc'),(80,216,'DEEP FRACTURE',21,'#edb58d'),(795,230,'EVACUATION VECTOR',18,'#a5e0d7'),(60,682,'WARNING, NOT A FIRING SOLUTION',22,'#c5d9d8')]:
 ax.text(x,y,label,color=color,fontsize=size,fontfamily='DejaVu Sans')
fig.savefig(Path(__file__).resolve().parents[4]/'game/assets/evidence/finale_warning.png',dpi=100,facecolor=fig.get_facecolor())
