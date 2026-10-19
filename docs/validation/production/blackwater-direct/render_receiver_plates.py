"""Original human-decoded receiver evidence; maintained Matplotlib raster pipeline.

Not optical photography, measured audio, or enemy telemetry. Fictional archive
content is authored for Siren's Song. Deterministic output; no external images.
"""
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Rectangle
ROOT=Path(__file__).resolve().parents[4]
BG='#081b25'; GRID='#234047'; CYAN='#8adbd3'; AMBER='#e0b67a'; WHITE='#c5d9d8'
def plate(title,subtitle):
 fig=plt.figure(figsize=(12.8,7.2),dpi=100,facecolor=BG)
 ax=fig.add_axes((0,0,1,1));ax.set(xlim=(0,1280),ylim=(720,0));ax.axis('off')
 for x in range(48,1240,64):ax.plot([x,x],[150,650],color=GRID,lw=.5)
 for y in range(150,651,50):ax.plot([48,1232],[y,y],color=GRID,lw=.5)
 ax.text(48,67,'QUIETUS / DECODED HYDROPHONES',color=CYAN,fontsize=18)
 ax.text(48,122,title,color=WHITE,fontsize=31,weight='bold')
 ax.text(48,691,subtitle,color=AMBER,fontsize=17)
 return fig,ax
def wave(ax,x0,y0,color,scale=1):
 x=np.linspace(0,460,1000)
 envelope=sum(np.exp(-((x-v)/13)**2) for v in [45,90,170,215,260,370,415])
 y=y0+28*np.sin(x*.35)*envelope*scale
 ax.plot(x+x0,y,color=color,lw=2.5)
fig,ax=plate('REQUEST / ARCHIVE INDEX','EARNED PACKET: THE OTHER RELAY ACCEPTS THE SAME REPLAY HANDSHAKE')
wave(ax,64,245,CYAN);wave(ax,750,245,AMBER)
ax.text(64,182,'REQUEST HEADER',color=CYAN,fontsize=19)
ax.text(750,182,'PAIRED REPLY',color=AMBER,fontsize=19)
ax.add_patch(FancyArrowPatch((560,245),(700,245),arrowstyle='-|>',mutation_scale=35,lw=4,color=WHITE))
ax.text(64,330,'Asks its partner for an ocean-temperature archive',color=WHITE,fontsize=23)
for x,title,color in [(48,'QUIET / CLOSE',CYAN),(680,'REPLAY / AUDIBLE',AMBER)]:
 ax.add_patch(Rectangle((x,380),552,245,facecolor=BG,edgecolor=color,lw=1.5))
 ax.text(x+24,425,title,color=color,fontsize=23,weight='bold')
ax.text(72,478,'Quietus <156m',color=WHITE,fontsize=23)
ax.text(72,524,'Drone <214.5m',color=WHITE,fontsize=23)
ax.text(72,582,'Settle + SAMPLE 2s',color=CYAN,fontsize=23)
ax.text(704,478,'SONAR <240m / clear line',color=WHITE,fontsize=21)
ax.text(704,524,'Local reply lasts 3s',color=WHITE,fontsize=23)
ax.text(704,582,'Settle + SAMPLE 2s',color=AMBER,fontsize=23)
fig.savefig(ROOT/'game/assets/evidence/blackwater_request.png',dpi=100,facecolor=BG);plt.close(fig)
fig,ax=plate('REPLY / ANCIENT OCEAN','THE NETWORK IS EXCHANGING A CLIMATE ARCHIVE, NOT A FIRING COMMAND')
ax.text(64,182,'TEMPERATURE STRATA / ARCHIVE TIME',color=CYAN,fontsize=20)
x=np.linspace(80,1200,600)
for n in range(5):
 y=250+n*53+18*np.sin(x/90+n*.7)+9*np.sin(x/23+n)
 ax.plot(x,y,color=CYAN if n%2==0 else AMBER,lw=2.4,alpha=.9)
ax.plot([80,1200],[548,548],color=WHITE,lw=1.2)
ax.add_patch(FancyArrowPatch((80,548),(1210,548),arrowstyle='-|>',mutation_scale=25,color=WHITE,lw=2))
ax.text(80,590,'RECENT',color=WHITE,fontsize=19)
ax.text(770,590,'OLDER THAN HUMANITY',color=AMBER,fontsize=23)
ax.text(64,645,'Reply header names the matching archive request',color=WHITE,fontsize=23)
fig.savefig(ROOT/'game/assets/evidence/blackwater_reply.png',dpi=100,facecolor=BG);plt.close(fig)
