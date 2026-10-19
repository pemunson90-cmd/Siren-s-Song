#!/usr/bin/env python3
"""Exercise clipped-menu reachability through the real native evidence CLI."""
import base64,hashlib,json, pathlib, struct, subprocess, sys, tempfile, unittest
CHECKER=pathlib.Path(__file__).with_name('android-menu.py')
def chunked(value,identity='42:1'):
 raw=json.dumps(value).encode();parts=[raw[i:i+450] for i in range(0,len(raw),450)]
 return '\n'.join(f'SS_UI_METRICS_PART id={identity} part={i} parts={len(parts)} bytes={len(raw)} sha256={hashlib.sha256(raw).hexdigest()} data={base64.b64encode(part).decode()}' for i,part in enumerate(parts))+'\n'
class Tests(unittest.TestCase):
 def test_menu_first_input_checks_system_ui_before_observing_or_swiping(self):
  helper=CHECKER.with_name('android-menu-smoke.sh')
  for intro_status,expected_status,expected_output in ((0,71,['intro','log','snapshot']),(37,37,['intro'])):
   script='''set -eu
source "$1"
output=/unused
stage() { :; }
ensure_system_intro() { echo intro; return "$2"; }
read_logcat() { echo log; }
menu_snapshot() { echo snapshot; exit 71; }
menu_touch_smoke cover
'''.replace('return "$2"',f'return {intro_status}')
   r=subprocess.run(['bash','-c',script,'test',str(helper)],capture_output=True,text=True)
   self.assertEqual(r.returncode,expected_status,r.stderr)
   self.assertEqual(r.stdout.splitlines(),expected_output)
 def layout(self):return {'schema':1,'screen':'menu','orders_page':'primary','viewport':[1680,720],'window':[2520,1080],'safe_rect':[0,0,2520,1080],'density_dpi':420,'density_source':'android_display_metrics_density_dpi','chart_rect':None,'scroll_rect':[100,30,1480,650],'scroll_vertical':320,'settings_values':{'music':.5,'effects':.8,'mute':False},'controls':[{'action':'settings','visual_rect':[200,200,1000,84],'hit_rect':[200,200,1000,84],'clipped':False}]}
 def invoke(self,layout,after=0,action='settings',prefix='',size=(2520,1080),screen='menu',baseline=None,transport=None):
  with tempfile.TemporaryDirectory() as temp:
   p=pathlib.Path(temp);(p/'log').write_text(prefix+(transport if transport is not None else 'SS_UI_METRICS '+json.dumps(layout)+'\n'));(p/'png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',*size));(p/'density').write_text('Physical density: 420\n')
   extra=[]
   if baseline is not None:(p/'before').write_text(json.dumps({'settings_values':baseline}));extra=['--unchanged-settings',str(p/'before')]
   return subprocess.run([sys.executable,str(CHECKER),str(p/'log'),str(p/'png'),'--density',str(p/'density'),'--screen',screen,'--action',action,'--after-count',str(after),*extra],capture_output=True,text=True)
 def test_chunk_count_tracks_snapshots_not_parts(self):
  d=self.layout();d['padding']='x'*2000;text=chunked(d)
  result=self.invoke(d,transport=text);self.assertEqual(result.returncode,0,result.stderr);self.assertEqual(json.loads(result.stdout)['metrics_count'],1)
  self.assertEqual(self.invoke(d,transport=text,after=1).returncode,3)
  self.assertEqual(self.invoke(d,transport=text+chunked(d,'42:2'),after=1).returncode,0)
 def test_incomplete_latest_menu_never_reuses_previous_target(self):
  d=self.layout();text=chunked(d)+chunked(d,'42:2').splitlines()[0]+'\n'
  self.assertEqual(self.invoke(d,transport=text).returncode,3)
 def test_navigation_rejects_changed_settings(self):
  d=self.layout();before=d['settings_values'].copy()
  self.assertEqual(self.invoke(d,baseline=before).returncode,0)
  for key,value in (('music',.55),('effects',.75),('mute',True)):
   changed=self.layout();changed['settings_values'][key]=value
   r=self.invoke(changed,baseline=before);self.assertEqual(r.returncode,1);self.assertIn('Settings changed',r.stderr)
 def test_settings_swipe_origin_avoids_slider_hit_rects(self):
  d=self.layout();d['screen']='settings';d['controls'][0]['action']='volume_music'
  r=self.invoke(d,screen='settings',action='mute');self.assertEqual(r.returncode,2,r.stderr)
  j=json.loads(r.stdout);self.assertEqual(j['swipe_origin'],'measured_empty_control_gap');self.assertGreater(j['swipe'][1],426);self.assertEqual(j['settings_values'],d['settings_values'])
 def test_settings_no_empty_origin_fails(self):
  d=self.layout();d['screen']='settings';d['controls'][0].update(action='volume_music',visual_rect=[100,30,1480,650],hit_rect=[100,30,1480,650]);r=self.invoke(d,screen='settings',action='mute');self.assertEqual(r.returncode,1);self.assertIn('No measured empty',r.stderr)
 def test_invalid_settings_state_fails(self):
  for value in (None,{'music':True,'effects':.8,'mute':False},{'music':.5,'effects':.8,'mute':0}):
   d=self.layout();d['settings_values']=value;self.assertEqual(self.invoke(d).returncode,1)
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
 def test_native_cli_rejects_local_fixture(self):
  d=self.layout();d["density_source"]="test_android_density_fixture";self.assertEqual(self.invoke(d).returncode,1)
 def test_wrong_screen_rejected(self):
  d=self.layout();d['screen']='settings';self.assertEqual(self.invoke(d).returncode,1)
if __name__=='__main__':unittest.main()
