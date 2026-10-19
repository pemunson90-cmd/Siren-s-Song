#!/usr/bin/env python3
"""Optional Blackwater native states; reuse strict newest post-draw/geometry gates.

Gallery state does not identify a plate's pixels: verify earned archive separately,
then inspect the actual final PNG. No compositor acknowledgment is asserted.
"""
import argparse,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('capture',Path(__file__).with_name('android-capture.py'))
capture=importlib.util.module_from_spec(spec);spec.loader.exec_module(capture)
def inspect(text,png,density,before,kind,mission):
 if mission!=2:raise ValueError('Blackwater check only supports mission2')
 status,result=capture.inspect(text,png,density,before,'camera',mission)
 if kind=='receiving':return status,result
 if 'capture_state' not in result:return status,result
 state=result['capture_state'];screen=result['screen']
 if screen not in ('mission','menu','settings','briefing','debrief','evidence'):raise ValueError('Unknown current screen')
 expected=state['phase']=='post_draw' and state['mission']==2 and state['paused'] and state['selected']==1 and state['capture_unit']==-1 and not state['optical_visible']
 if kind=='gallery':
  if screen=='evidence':
   back=[c for c in result['measurement']['controls'] if c['action']=='back' and not c['size_exempt_clipped']]
   if not back:raise ValueError('Gallery requires fully exposed BACK')
  expected=expected and screen=='evidence' and not state['hud_visible'] and state['menu_visible']
 else:expected=expected and screen=='mission' and state['hud_visible'] and not state['menu_visible']
 if not expected:result['waiting']='latest validated state is not requested Blackwater presentation';return 3,result
 result.pop('waiting',None)
 if kind=='route':
  views=[line for line in text.splitlines() if 'SS_VIEW ' in line]
  view=re.search(r'SS_VIEW zoom=([\d.]+) center=\(?([\d.]+),\s*([\d.]+)\)?',views[-1]) if views else None
  if view is None or tuple(map(float,view.groups()))!=(1.0,800.0,480.0):raise ValueError('Ordinary route requires observed FIT zoom1/center800,480')
  # Existing ChartCamera fit contract: WORLD1600x960, letterbox and centered.
  records=capture.read_records(text);raw=json.loads(records[-1][1]);x,y,w,h=raw['chart_rect'];scale=min(w/1600,h/960)
  logical=[x+w/2+(760-800)*scale,y+h/2+(390-480)*scale]
  sx,sy=result['measurement']['canvas_scale'];result['tap']=[round(logical[0]*sx),round(logical[1]*sy)]
  result['ordinary_world_route']=[760,390]
 return 0,result
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('log',type=Path);p.add_argument('png',type=Path);p.add_argument('--density',type=Path,required=True);p.add_argument('--after-log',type=Path,required=True);p.add_argument('--kind',choices=['receiving','gallery','route'],required=True);p.add_argument('--mission',type=int,required=True);a=p.parse_args()
 try:
  status,result=inspect(a.log.read_text(errors='replace'),a.png.read_bytes(),a.density.read_text(),a.after_log.read_text(errors='replace'),a.kind,a.mission);print(json.dumps(result,indent=2));return status
 except (OSError,ValueError,TypeError,KeyError,AttributeError) as error:print('Invalid Blackwater evidence: '+str(error),file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
