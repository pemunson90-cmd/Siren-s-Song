#!/usr/bin/env python3
"""Map only actual exposed menu hit regions; never use an offscreen SS_TARGET.

Exit 0: fully exposed target; 2: scrolling needed; 3: fresh metrics pending;
1: invalid evidence. Synthetic tests do not establish Android scrolling.
"""
import argparse, importlib.util, json, math, struct, sys
from pathlib import Path
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('metrics',Path(__file__).with_name('android-ui-metrics.py'))
metrics=importlib.util.module_from_spec(spec);spec.loader.exec_module(metrics)
def inspect(text,png,density,screen,action,after,*,expected_density_source='android_display_metrics_density_dpi'):
 lines=text.splitlines();count=sum('SS_UI_METRICS ' in line for line in lines)
 boundary=max((i for i,line in enumerate(lines) if any(x in line for x in ('SS_SCREEN ','SS_MISSION_SELECT ','SS_VIEW '))),default=-1)
 snapshots=[line.split('SS_UI_METRICS ',1)[1] for line in lines[boundary+1:] if 'SS_UI_METRICS ' in line]
 if count<=after or not snapshots:return 3,{'waiting':'fresh atomic metrics after previous input','metrics_count':count}
 layout=json.loads(snapshots[-1])
 if layout.get('screen')!=screen:raise ValueError('Current metrics screen differs from requested menu')
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
 result={'screen':screen,'action':action,'metrics_count':count,'scroll_vertical':offset,'measurement':report}
 for control in layout['controls']:
  if control['action']==action and not control.get('clipped',False):
   x,y,w,h=control['hit_rect'];result['tap']=[round((x+w/2)*sx),round((y+h/2)*sy)];return 0,result
 x,y,w,h=physical
 result['swipe']=[round(x+w*.5),round(y+h*.8),round(x+w*.5),round(y+h*.25)]
 return 2,result
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('log',type=Path);parser.add_argument('png',type=Path);parser.add_argument('--density',type=Path,required=True);parser.add_argument('--screen',required=True,choices=['menu','settings','briefing']);parser.add_argument('--action',required=True);parser.add_argument('--after-count',type=int,default=0);args=parser.parse_args()
 try:
  status,result=inspect(args.log.read_text(errors='replace'),args.png.read_bytes(),args.density.read_text(),args.screen,args.action,args.after_count);print(json.dumps(result,indent=2));return status
 except (OSError,ValueError,TypeError,KeyError) as error:print('Invalid native menu evidence: '+str(error),file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
