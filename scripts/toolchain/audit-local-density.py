#!/usr/bin/env python3
"""Inspect settled local fixture PNG/JSON pairs without relabeling them Android."""
import argparse,importlib.util,json,re,struct,sys,hashlib
from pathlib import Path
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('metrics',Path(__file__).with_name('android-ui-metrics.py'))
metrics=importlib.util.module_from_spec(spec);spec.loader.exec_module(metrics)
spec=importlib.util.spec_from_file_location('menu',Path(__file__).with_name('android-menu.py'))
menu=importlib.util.module_from_spec(spec);spec.loader.exec_module(menu)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('captures',type=Path);a=p.parse_args();reports=[]
 for filename in sorted(a.captures.glob('*/layout.json')):
  layout=json.loads(filename.read_text());png=(filename.parent/'full.png').read_bytes()
  inputs={name:hashlib.sha256((filename.parent/name).read_bytes()).hexdigest() for name in ('layout.json','full.png','godot.log')}
  if png[:8]!=b'\x89PNG\r\n\x1a\n':raise ValueError('Invalid capture '+str(filename))
  size=struct.unpack('>II',png[16:24]);screen=layout['screen']
  required=set()
  if screen=='mission':required=metrics.required_actions(layout)
  elif screen=='briefing':required={'begin','back'}
  elif screen=='settings':required={'back'}
  try:report=metrics.evaluate(layout,size,layout['density_dpi'],required,expected_density_source='test_android_density_fixture')
  except ValueError as error:
   reports.append({'capture':str(filename.parent),'rejected_capture':'rejected' in filename.parent.name,'gate_passed':False,'errors':[str(error)],'native_measurement':False,'input_sha256':inputs});continue
  if screen!='mission':
   body=metrics.rect(layout.get('scroll_rect'),'scroll_rect');sx,sy=report['canvas_scale']
   if not metrics.contains(report['safe_physical'],[body[0]*sx,body[1]*sy,body[2]*sx,body[3]*sy]):report['errors'].append('Menu scroll body outside physical safe area')
   if not isinstance(layout.get('scroll_vertical'),(int,float)):report['errors'].append('Missing actual menu scroll offset')
   action='settings' if screen=='menu' else 'back'
   status,reachability=menu.inspect('SS_UI_METRICS '+json.dumps(layout),png,layout['density_dpi'],screen,action,0,expected_density_source='test_android_density_fixture')
   report['menu_contract_status']=status;report['menu_contract_action']=action;report['menu_contract_tap']=reachability.get('tap');report['menu_contract_swipe']=reachability.get('swipe')
   if screen in ('briefing','settings') and status!=0:report['errors'].append('Sticky action not fully exposed')
  report['gate_passed']=not report['errors'];report['capture']=str(filename.parent);report['rejected_capture']='rejected' in filename.parent.name;report['input_sha256']=inputs
  transforms=[line for line in (filename.parent/'godot.log').read_text().splitlines() if line.startswith('DENSITY_TRANSFORMS ')]
  report['engine_transform_diagnostic']=transforms[-1] if transforms else None
  reports.append(report)
 print(json.dumps({'native_measurement':False,'provenance':'unchanged local test_android_density_fixture JSON with same-frame actual PNG','reports':reports},indent=2))
 return 0 if reports and all(r['gate_passed'] for r in reports if not r['rejected_capture']) else 1
if __name__=='__main__':raise SystemExit(main())
