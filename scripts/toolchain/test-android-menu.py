#!/usr/bin/env python3
"""Exercise clipped-menu reachability through the real native evidence CLI."""
import json, pathlib, struct, subprocess, sys, tempfile, unittest
CHECKER=pathlib.Path(__file__).with_name('android-menu.py')
class Tests(unittest.TestCase):
 def layout(self):return {'schema':1,'screen':'menu','orders_page':'primary','viewport':[1680,720],'window':[2520,1080],'safe_rect':[0,0,2520,1080],'density_dpi':420,'density_source':'android_display_metrics_density_dpi','chart_rect':None,'scroll_rect':[100,30,1480,650],'scroll_vertical':320,'controls':[{'action':'settings','visual_rect':[200,200,1000,84],'hit_rect':[200,200,1000,84],'clipped':False}]}
 def invoke(self,layout,after=0,action='settings',prefix='',size=(2520,1080)):
  with tempfile.TemporaryDirectory() as temp:
   p=pathlib.Path(temp);(p/'log').write_text(prefix+'SS_UI_METRICS '+json.dumps(layout)+'\n');(p/'png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',*size));(p/'density').write_text('Physical density: 420\n')
   return subprocess.run([sys.executable,str(CHECKER),str(p/'log'),str(p/'png'),'--density',str(p/'density'),'--screen','menu','--action',action,'--after-count',str(after)],capture_output=True,text=True)
 def test_full_target_maps_actual_hit_center(self):
  r=self.invoke(self.layout());self.assertEqual(r.returncode,0,r.stderr);self.assertEqual(json.loads(r.stdout)['tap'],[1050,363])
 def test_clipped_center_never_tapped(self):
  d=self.layout();d['controls'][0].update(hit_rect=[200,200,1000,42],clipped=True);r=self.invoke(d);self.assertEqual(r.returncode,2);self.assertNotIn('tap',json.loads(r.stdout))
 def test_offscreen_omitted_target_never_tapped(self):
  d=self.layout();d['controls'][0]['action']='mission0';r=self.invoke(d,prefix='SS_TARGET settings center=500,500 viewport=1680,720\n');self.assertEqual(r.returncode,2);self.assertIn('swipe',json.loads(r.stdout))
 def test_swipe_uses_scroll_body_and_safe_transform(self):
  r=self.invoke(self.layout(),action='absent');swipe=json.loads(r.stdout)['swipe'];self.assertEqual(swipe,[1260,825,1260,289]);self.assertLess(swipe[3],swipe[1])
 def test_stale_snapshot_rejected(self):self.assertEqual(self.invoke(self.layout(),after=1).returncode,3)
 def test_wrong_window_rejected(self):self.assertEqual(self.invoke(self.layout(),size=(2184,1968)).returncode,1)
 def test_undersized_exposed_control_rejected(self):
  d=self.layout();d['controls'][0]['visual_rect'][3]=48;d['controls'][0]['hit_rect'][3]=48;self.assertEqual(self.invoke(d).returncode,1)
 def test_scroll_body_outside_safe_rejected(self):
  d=self.layout();d['scroll_rect']=[-100,0,1000,600];self.assertEqual(self.invoke(d).returncode,1)
 def test_missing_scroll_contract_rejected(self):
  d=self.layout();del d['scroll_rect'];self.assertEqual(self.invoke(d).returncode,1)
 def test_wrong_screen_rejected(self):
  d=self.layout();d['screen']='settings';self.assertEqual(self.invoke(d).returncode,1)
if __name__=='__main__':unittest.main()
