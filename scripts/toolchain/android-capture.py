#!/usr/bin/env python3
"""Require fresh app post-draw state; PNG dimensions are not compositor proof.

Exit0: requested state and strict native geometry;3: pending;1: invalid evidence.
"""
import argparse,importlib.util,json,re,struct,sys
from pathlib import Path
sys.dont_write_bytecode=True
from android_metric_records import read_records
spec=importlib.util.spec_from_file_location('metrics',Path(__file__).with_name('android-ui-metrics.py'))
metrics=importlib.util.module_from_spec(spec);spec.loader.exec_module(metrics)
def inspect(text,png,density,before,kind,mission):
 if re.search(r'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR:|Parse Error:|[Ee] godot.*ERROR:',text):raise ValueError('Native runtime error while waiting for capture')
 records=read_records(text);after_count=len(read_records(before));lines=text.splitlines()
 boundary=max((i for i,line in enumerate(lines) if any(x in line for x in ('SS_SCREEN ','SS_MISSION_SELECT ','SS_VIEW '))),default=-1)
 if len(records)<=after_count or not records or records[-1][0]<=boundary or records[-1][1] is None:return 3,{'waiting':'fresh complete latest post-input snapshot','metrics_count':len(records)}
 layout=json.loads(records[-1][1])
 if len(png)<24 or png[:8]!=b'\x89PNG\r\n\x1a\n':raise ValueError('Invalid actual PNG header')
 size=struct.unpack('>II',png[16:24])
 required=set((metrics.SECONDARY_ACTIONS if layout.get('orders_page')=='secondary' else metrics.MISSION_ACTIONS).split(',')) if layout.get('screen')=='mission' else set()
 measured=metrics.evaluate(layout,size,metrics.os_density(density),required)
 if not measured['gate_passed']:raise ValueError('; '.join(measured['errors']))
 state=layout.get('capture_state')
 if state is None:return 3,{'waiting':'latest snapshot has no capture-state acknowledgment','metrics_count':len(records)}
 if not isinstance(state,dict):raise ValueError('capture_state must be an object')
 for key in ['paused','hud_visible','menu_visible','optical_visible']:
  if not isinstance(state.get(key),bool):raise ValueError('Invalid capture_state '+key)
 for key,low,high in [('drawn_frame',0,2**63-1),('mission',0,5),('selected',0,2),('capture_unit',-1,2)]:
  value=state.get(key)
  if isinstance(value,bool) or not isinstance(value,int) or not low<=value<=high:raise ValueError('Invalid capture_state '+key)
 if state.get('phase') not in ['layout_only','post_draw']:raise ValueError('Invalid capture_state phase')
 result={'metrics_count':len(records),'screen':layout['screen'],'capture_state':state,'measurement':measured}
 expected=layout['screen']=='mission' and state['phase']=='post_draw' and state['mission']==mission and state['paused'] and state['hud_visible'] and not state['menu_visible']
 if kind=='camera':expected=expected and state['selected']==1 and state['capture_unit']==1 and state['optical_visible']
 else:expected=expected and state['selected']==0 and not state['optical_visible']
 if not expected:result['waiting']='latest validated state is not the requested paused presentation';return 3,result
 return 0,result
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('log',type=Path);p.add_argument('png',type=Path);p.add_argument('--density',type=Path,required=True);p.add_argument('--after-log',type=Path,required=True);p.add_argument('--kind',choices=['camera','restored-mission'],required=True);p.add_argument('--mission',type=int,required=True);args=p.parse_args()
 try:
  status,result=inspect(args.log.read_text(errors='replace'),args.png.read_bytes(),args.density.read_text(),args.after_log.read_text(errors='replace'),args.kind,args.mission)
  print(json.dumps(result,indent=2));return status
 except (OSError,ValueError,TypeError,KeyError,AttributeError) as error:print('Invalid capture evidence: '+str(error),file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
