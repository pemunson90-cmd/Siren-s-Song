#!/usr/bin/env python3
"""Map only actual exposed menu hit regions; never use an offscreen SS_TARGET.

Exit 0: fully exposed target; 2: scrolling needed; 3: fresh metrics pending;
1: invalid evidence. Synthetic tests do not establish Android scrolling.
"""
import argparse, importlib.util, json, math, struct, sys
from pathlib import Path
sys.dont_write_bytecode=True
from android_metric_records import read_records
spec=importlib.util.spec_from_file_location('metrics',Path(__file__).with_name('android-ui-metrics.py'))
metrics=importlib.util.module_from_spec(spec);spec.loader.exec_module(metrics)
def inspect(text,png,density,screen,action,after,*,expected_density_source='android_display_metrics_density_dpi',wait_for_screen=False):
 lines=text.splitlines();records=read_records(text);count=len(records)
 boundary=max((i for i,line in enumerate(lines) if any(x in line for x in ('SS_SCREEN ','SS_MISSION_SELECT ','SS_VIEW '))),default=-1)
 snapshots=[payload for position,payload in records if position>boundary]
 if count<=after or not snapshots or snapshots[-1] is None:return 3,{'waiting':'fresh complete atomic metrics after previous input','metrics_count':count}
 layout=json.loads(snapshots[-1])
 if layout.get('screen') not in ('menu','settings','briefing','mission','debrief'):raise ValueError('Unknown current metrics screen')
 if len(png)<24 or png[:8]!=b'\x89PNG\r\n\x1a\n':raise ValueError('Invalid actual PNG header')
 size=struct.unpack('>II',png[16:24])
 reference_density=density if expected_density_source=='test_android_density_fixture' else metrics.os_density(density)
 report=metrics.evaluate(layout,size,reference_density,set(),expected_density_source=expected_density_source)
 if not report['gate_passed']:raise ValueError('; '.join(report['errors']))
 scroll=metrics.rect(layout.get('scroll_rect'),'scroll_rect');sx,sy=report['canvas_scale']
 physical=[scroll[0]*sx,scroll[1]*sy,scroll[2]*sx,scroll[3]*sy]
 if not metrics.contains(report['safe_physical'],physical):raise ValueError('Scroll body lies outside physical safe area')
 offset=layout.get('scroll_vertical')
 if isinstance(offset,bool) or not isinstance(offset,(int,float)) or not math.isfinite(offset) or offset<0:raise ValueError('Invalid actual scroll offset')
 values=layout.get('settings_values')
 if not isinstance(values,dict) or set(values)!={'music','effects','mute'} or not isinstance(values['mute'],bool) or any(isinstance(values[k],bool) or not isinstance(values[k],(int,float)) or not math.isfinite(values[k]) or not 0<=values[k]<=1 for k in ('music','effects')):raise ValueError('Invalid readonly settings_values')
 if layout['screen']!=screen:
  if wait_for_screen:return 3,{'waiting':'validated current screen has not reached requested menu','screen':layout['screen'],'metrics_count':count,'settings_values':values}
  raise ValueError('Current metrics screen differs from requested menu')
 result={'screen':screen,'action':action,'metrics_count':count,'scroll_vertical':offset,'measurement':report,'settings_values':values}
 for control in layout['controls']:
  if control['action']==action and not control.get('clipped',False):
   x,y,w,h=control['hit_rect'];result['tap']=[round((x+w/2)*sx),round((y+h/2)*sy)];return 0,result
 x,y,w,h=physical
 result['swipe']=[round(x+w*.5),round(y+h*.8),round(x+w*.5),round(y+h*.25)]
 if screen=='settings':
  # Start in measured empty content, never on a slider/button or scrollbar.
  center=scroll[0]+scroll[2]*.5; end=scroll[1]+scroll[3]*.1
  intervals=sorted((max(scroll[1],c['hit_rect'][1]),min(scroll[1]+scroll[3],c['hit_rect'][1]+c['hit_rect'][3])) for c in layout['controls'] if c['hit_rect'][0]<=center<=c['hit_rect'][0]+c['hit_rect'][2] and c['hit_rect'][1]<scroll[1]+scroll[3] and c['hit_rect'][1]+c['hit_rect'][3]>scroll[1])
  cursor=scroll[1]; gaps=[]
  for low,high in intervals:
   if low>cursor:gaps.append((cursor,low))
   cursor=max(cursor,high)
  if cursor<scroll[1]+scroll[3]:gaps.append((cursor,scroll[1]+scroll[3]))
  for low,high in reversed(gaps):
   start=(low+high)*.5; px=round(center*sx); py=round(start*sy)
   if start<=end or not low<py/sy<high:continue
   if any(c['hit_rect'][0]<=px/sx<=c['hit_rect'][0]+c['hit_rect'][2] and c['hit_rect'][1]<=py/sy<=c['hit_rect'][1]+c['hit_rect'][3] for c in layout['controls']):continue
   result['swipe']=[px,py,px,round(end*sy)];result['swipe_origin']='measured_empty_control_gap';break
  else:raise ValueError('No measured empty Settings swipe origin with upward travel')
 return 2,result
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('log',type=Path);parser.add_argument('png',type=Path);parser.add_argument('--density',type=Path,required=True);parser.add_argument('--screen',required=True,choices=['menu','settings','briefing']);parser.add_argument('--action',required=True);parser.add_argument('--after-count',type=int,default=0);parser.add_argument('--unchanged-settings',type=Path);parser.add_argument('--wait-for-screen',action='store_true',help='Retry a fully validated other screen; malformed evidence and changed settings remain fatal');args=parser.parse_args()
 try:
  status,result=inspect(args.log.read_text(errors='replace'),args.png.read_bytes(),args.density.read_text(),args.screen,args.action,args.after_count,wait_for_screen=args.wait_for_screen)
  if 'settings_values' in result and args.unchanged_settings and result['settings_values']!=json.loads(args.unchanged_settings.read_text())['settings_values']:raise ValueError('Settings changed during scroll-only navigation')
  print(json.dumps(result,indent=2));return status
 except (OSError,ValueError,TypeError,KeyError) as error:print('Invalid native menu evidence: '+str(error),file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
