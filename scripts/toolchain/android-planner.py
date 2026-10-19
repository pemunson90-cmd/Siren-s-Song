#!/usr/bin/env python3
"""Validate paused planner geometry and read-only navigation from atomic native metrics.

Exit 3 means a fresh post-draw snapshot is pending; 1 rejects invalid evidence.
App draw acknowledgment is not Android compositor or physical touch proof.
"""
import argparse,importlib.util,json,math,re,struct,sys
from pathlib import Path
sys.dont_write_bytecode=True
from android_metric_records import read_records
spec=importlib.util.spec_from_file_location('metrics',Path(__file__).with_name('android-ui-metrics.py'))
metrics=importlib.util.module_from_spec(spec);spec.loader.exec_module(metrics)
REQUIRED={'close','craft0','craft1','craft2','planner_zoom_out','planner_zoom_in','planner_fit'}
def unique(pairs):
 result={}
 for key,value in pairs:
  if key in result:raise ValueError('Duplicate JSON key: '+key)
  result[key]=value
 return result
def finite(value,label,low=0,high=1e12):
 if isinstance(value,bool) or not isinstance(value,(int,float)) or not math.isfinite(value) or not low<=value<=high:raise ValueError('Invalid '+label)
 return value
def integer(value,label,low,high):
 if not isinstance(value,int) or isinstance(value,bool):raise ValueError('Invalid '+label)
 return finite(value,label,low,high)
def boolean(value,label):
 if not isinstance(value,bool):raise ValueError('Invalid '+label)
def identity(text,position):
 line=text.splitlines()[position]
 match=re.search(r'SS_UI_METRICS_PART id=(\S+):(\d+) part=',line)
 if not match:raise ValueError('Planner native metrics require atomic transport identity')
 return match[1],int(match[2])
def inspect(text,png,density,before,operation,baseline,previous):
 if re.search(r'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:|[Ee] godot.*ERROR:',text):raise ValueError('Native runtime error')
 records=read_records(text);old=read_records(before);lines=text.splitlines()
 boundary=max((i for i,line in enumerate(lines) if any(x in line for x in ('SS_SCREEN ','SS_MISSION_SELECT ','SS_VIEW '))),default=-1)
 if len(records)<=len(old) or not records or records[-1][0]<=boundary or records[-1][1] is None:return 3,{'waiting':'fresh complete latest planner snapshot','metrics_count':len(records)}
 session,serial=identity(text,records[-1][0])
 previous_identity=None
 for position,payload in records:
  current_identity=identity(text,position)
  if previous_identity is not None and current_identity[0]==previous_identity[0] and current_identity[1]<=previous_identity[1]:raise ValueError('Nonmonotonic planner transport')
  previous_identity=current_identity
 if old:
  old_session,old_serial=identity(before,old[-1][0])
  if session!=old_session or serial<=old_serial:raise ValueError('Planner transport did not advance in the same app session')
 layout=json.loads(records[-1][1],object_pairs_hook=unique)
 if not isinstance(layout,dict) or layout.get('screen')!='program':raise ValueError('Current snapshot is not planner')
 if len(png)<24 or png[:8]!=b'\x89PNG\r\n\x1a\n':raise ValueError('Invalid actual PNG header')
 measured=metrics.evaluate(layout,struct.unpack('>II',png[16:24]),metrics.os_density(density),REQUIRED)
 if not measured['gate_passed']:raise ValueError('; '.join(measured['errors']))
 planner=layout.get('planner');state=layout.get('capture_state')
 if not isinstance(planner,dict) or not isinstance(state,dict):raise ValueError('Missing planner/capture state')
 intent=planner.get('intent')
 if not isinstance(intent,dict):raise ValueError('Missing own intent')
 for key in ('paused','queue','pass_through'):boolean(intent.get(key),key)
 if not intent['paused']:raise ValueError('Planner must remain paused')
 integer(intent.get('selected'),'selected',0,2);integer(intent.get('mission'),'mission',0,5)
 for key in ('elapsed','oxygen','hull'):finite(intent.get(key),key)
 tools=intent.get('tools')
 if not isinstance(tools,dict) or set(tools)!={'emp','decoy','recon','knock'}:raise ValueError('Invalid finite tool identity')
 for key,value in tools.items():integer(value,key,0,1000)
 units=intent.get('units')
 if not isinstance(units,list) or len(units)!=3:raise ValueError('Expected three own craft identities')
 for unit in units:
  if not isinstance(unit,dict):raise ValueError('Invalid own craft')
  for key in ('alive','silent'):boolean(unit.get(key),key)
  if not isinstance(unit.get('hold'),str):raise ValueError('Invalid hold identity')
  metrics.numbers(unit.get('pos'),2,'own position');metrics.numbers(unit.get('velocity'),2,'own velocity');finite(unit.get('battery'),'battery')
  goals=unit.get('goals')
  if not isinstance(goals,list):raise ValueError('Invalid own route goals')
  for goal in goals:
   if not isinstance(goal,dict) or goal.get('mode') not in ('inherit','cruise','silent'):raise ValueError('Invalid own goal mode')
   metrics.numbers(goal.get('pos'),2,'goal position')
   for key in ('stop','legacy'):boolean(goal.get(key),key)
 for key in ('paused','hud_visible','menu_visible','optical_visible'):boolean(state.get(key),key)
 if not state['paused'] or state['hud_visible'] or state['menu_visible'] or state['selected']!=intent['selected'] or state['mission']!=intent['mission']:raise ValueError('Planner state and own intent disagree')
 integer(state.get('drawn_frame'),'drawn frame',0,2**63-1)
 if state.get('phase') not in ('layout_only','post_draw'):raise ValueError('Invalid draw phase')
 zoom=finite(planner.get('zoom'),'zoom',1,4);center=metrics.numbers(planner.get('center'),2,'view center')
 if not 0<=center[0]<=1600 or not 0<=center[1]<=960:raise ValueError('View center lies outside world')
 physical=metrics.rect(planner.get('preview_physical'),'preview_physical');chart=metrics.rect(layout.get('chart_rect'),'chart_rect');sx,sy=measured['canvas_scale']
 expected=[chart[0]*sx,chart[1]*sy,chart[2]*sx,chart[3]*sy]
 if any(abs(a-b)>.01 for a,b in zip(physical,expected)):raise ValueError('Preview physical rectangle disagrees with chart transform')
 if not metrics.contains(measured['safe_physical'],physical):raise ValueError('Preview outside safe area')
 result={'metrics_count':len(records),'transport':[session,serial],'planner':planner,'capture_state':state,'measurement':measured}
 if state['phase']!='post_draw':result['waiting']='planner post-draw acknowledgment';return 3,result
 if baseline is not None and intent!=baseline['planner']['intent']:raise ValueError('Own paused route/selection/resources changed during view navigation')
 if operation!='initial':
  if baseline is None or previous is None:raise ValueError('Navigation comparison requires baseline and previous reports')
  old_view=previous['planner']
  if operation=='zoom-in' and zoom<=old_view['zoom']+.01:raise ValueError('Zoom-in did not increase view zoom')
  if operation=='zoom-out' and zoom>=old_view['zoom']-.01:raise ValueError('Zoom-out did not decrease view zoom')
  if operation=='pan' and (abs(zoom-old_view['zoom'])>.001 or math.dist(center,old_view['center'])<=5):raise ValueError('Pan did not change center at unchanged zoom')
  if operation=='fit' and (abs(zoom-1)>.001 or math.dist(center,[800,480])>1):raise ValueError('FIT did not restore world view')
 # A drag stays below toolbar and inside the physical preview. No tap on water.
 x,y,w,h=physical
 toolbar_bottom=max(c['hit_physical'][1]+c['hit_physical'][3] for c in measured['controls'] if c['action'].startswith('planner_'))
 top=max(y,toolbar_bottom)+12
 if y+h-top<30 or w<60:raise ValueError('No measured drag area clear of planner toolbar')
 result['swipe']=[round(x+w*.7),round((top+y+h)/2),round(x+w*.3),round((top+y+h)/2)]
 result['taps']={c['action']:[round(c['hit_physical'][0]+c['hit_physical'][2]/2),round(c['hit_physical'][1]+c['hit_physical'][3]/2)] for c in measured['controls'] if c['action'] in REQUIRED}
 result['limits']='App post-draw and geometry only; no compositor, OS multitouch, finger comfort, mission or performance claim.'
 return 0,result
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('log',type=Path);p.add_argument('png',type=Path);p.add_argument('--density',type=Path,required=True);p.add_argument('--after-log',type=Path,required=True);p.add_argument('--operation',choices=['initial','zoom-in','zoom-out','pan','fit'],default='initial');p.add_argument('--baseline',type=Path);p.add_argument('--previous',type=Path);a=p.parse_args()
 try:
  status,result=inspect(a.log.read_text(errors='replace'),a.png.read_bytes(),a.density.read_text(),a.after_log.read_text(errors='replace'),a.operation,json.loads(a.baseline.read_text()) if a.baseline else None,json.loads(a.previous.read_text()) if a.previous else None);print(json.dumps(result,indent=2,allow_nan=False));return status
 except (OSError,ValueError,TypeError,KeyError,AttributeError) as error:print('Invalid native planner evidence: '+str(error),file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
