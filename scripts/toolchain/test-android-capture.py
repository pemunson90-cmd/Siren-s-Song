#!/usr/bin/env python3
"""Real capture CLI/shell tests with unavailable ADB transport mocked."""
import base64, hashlib, json, pathlib, struct, subprocess, sys, tempfile, unittest
CHECKER=pathlib.Path(__file__).with_name('android-capture.py')
HELPER=pathlib.Path(__file__).with_name('android-capture-smoke.sh')
def records(value,identity='42:1'):
 raw=json.dumps(value).encode();chunks=[raw[i:i+450] for i in range(0,len(raw),450)]
 return '\n'.join(f'SS_UI_METRICS_PART id={identity} part={i} parts={len(chunks)} bytes={len(raw)} sha256={hashlib.sha256(raw).hexdigest()} data={base64.b64encode(chunk).decode()}' for i,chunk in enumerate(chunks))+'\n'
def layout(kind='camera'):
 actions='pause sub droneA droneB ping camera silent queue hold emp home menu more_orders zoom_out zoom_in fit'.split()
 controls=[{'action':a,'visual_rect':[900+i%4*180,20+i//4*100,160,84],'hit_rect':[900+i%4*180,20+i//4*100,160,84],'clipped':False} for i,a in enumerate(actions)]
 return {'schema':1,'screen':'mission','orders_page':'primary','viewport':[1680,720],'window':[2520,1080],'safe_rect':[0,0,2520,1080],'density_dpi':420,'density_source':'android_display_metrics_density_dpi','chart_rect':[0,0,800,600],'controls':controls,'capture_state':{'phase':'post_draw','drawn_frame':10,'mission':0,'paused':True,'selected':1 if kind=='camera' else 0,'capture_unit':1 if kind=='camera' else -1,'hud_visible':True,'menu_visible':False,'optical_visible':kind=='camera'}}
class CaptureTests(unittest.TestCase):
 def invoke(self,text,*,kind='camera',before='',size=(2520,1080)):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder);(p/'log').write_text(text);(p/'before').write_text(before);(p/'density').write_text('Physical density: 420\n');(p/'image.png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',*size))
   return subprocess.run([sys.executable,str(CHECKER),str(p/'log'),str(p/'image.png'),'--density',str(p/'density'),'--after-log',str(p/'before'),'--kind',kind,'--mission','0'],capture_output=True,text=True)
 def test_paused_camera_postdraw_is_accepted(self):
  r=self.invoke(records(layout()));self.assertEqual(r.returncode,0,r.stderr)
 def test_paused_entered_mission_is_accepted(self):
  r=self.invoke(records(layout('restored-mission')),kind='restored-mission');self.assertEqual(r.returncode,0,r.stderr)
 def test_first_actual_postdraw_counter_zero_is_valid(self):
  d=layout();d['capture_state']['drawn_frame']=0;self.assertEqual(self.invoke(records(d)).returncode,0)
 def test_command_ack_without_render_evidence_waits(self):
  r=self.invoke('SS_ORDER camera accepted=true selected=1\n');self.assertEqual(r.returncode,3,r.stderr)
 def test_precommand_snapshot_never_reused(self):
  text=records(layout());self.assertEqual(self.invoke(text,before=text).returncode,3)
 def test_newest_incomplete_record_never_falls_back(self):
  text=records(layout())+records(layout(),'42:2').splitlines()[0]+'\n';self.assertEqual(self.invoke(text).returncode,3)
 def test_newest_missing_capture_state_waits(self):
  value=layout();del value['capture_state'];self.assertEqual(self.invoke(records(layout())+records(value,'42:2')).returncode,3)
 def test_pre_draw_headless_state_never_claims_render(self):
  value=layout();value['capture_state']['phase']='layout_only';value['capture_state']['drawn_frame']=0;self.assertEqual(self.invoke(records(value)).returncode,3)
 def test_changed_camera_presentation_waits(self):
  for key,value in [('paused',False),('selected',0),('capture_unit',-1),('optical_visible',False),('hud_visible',False),('menu_visible',True),('mission',1)]:
   d=layout();d['capture_state'][key]=value
   self.assertEqual(self.invoke(records(d)).returncode,3,key)
 def test_malformed_state_and_png_are_fatal(self):
  for key,value in [('paused',1),('selected',True),('drawn_frame',-1),('phase','presented'),('optical_visible','true')]:
   d=layout();d['capture_state'][key]=value;self.assertEqual(self.invoke(records(d)).returncode,1,key)
  self.assertEqual(self.invoke(records(layout()),size=(2184,1968)).returncode,1)
 def test_corrupt_chunk_and_bad_geometry_are_fatal(self):
  self.assertEqual(self.invoke(records(layout()).replace('sha256=','sha256=0',1)).returncode,1)
  d=layout();d['controls'][0]['hit_rect'][3]=48;self.assertEqual(self.invoke(records(d)).returncode,1)
 def test_new_screen_boundary_cannot_reuse_postdraw(self):
  self.assertEqual(self.invoke(records(layout())+'SS_SCREEN operations\n').returncode,3)
 def test_native_fatal_after_postdraw_is_not_accepted(self):
  self.assertEqual(self.invoke(records(layout())+'FATAL EXCEPTION: main\n').returncode,1)
 def shell(self,logs):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder);(p/'events').touch();(p/'reads').write_text('0');(p/'before').write_text('')
   (p/'source.png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',2520,1080))
   for i,text in enumerate(logs,1):(p/f'log-{i}').write_text(text)
   script='''set -eu
source "$1"
output="$2"
stage() { :; }
adb() { if [[ "$*" == 'shell wm density' ]]; then echo 'Physical density: 420'; elif [[ "$*" == 'exec-out screencap -p' ]]; then echo capture >>"$output/events"; cat "$output/source.png"; else return 99; fi; }
read_logcat() { local n; n=$(cat "$output/reads"); n=$((n+1)); echo "$n" >"$output/reads"; if ((n>LIMIT)); then n=LIMIT; fi; echo "log:$n" >>"$output/events"; cp "$output/log-$n" "$1"; }
sleep() { echo retry >>"$output/events"; }
capture_state_shot inner-camera-exposure camera "$output/before" 0
'''.replace('LIMIT',str(len(logs)))
   r=subprocess.run(['bash','-c',script,'test',str(HELPER),str(p)],capture_output=True,text=True)
   return r,(p/'events').read_text().splitlines(),(p/'inner-camera-exposure.png').exists()
 def test_shell_waits_after_ack_before_final_capture(self):
  d=layout();text=records(d)
  r,events,final=self.shell(['SS_ORDER camera accepted=true\n',text,text]);self.assertEqual(r.returncode,0,r.stderr)
  self.assertGreater(max(i for i,x in enumerate(events) if x=='capture'),events.index('log:2'));self.assertTrue(final)
 def test_shell_rechecks_newest_changed_state(self):
  d=layout();changed=layout();changed['capture_state']['optical_visible']=False
  a=records(d);b=a+records(changed,'42:2');c=b+records(d,'42:3')
  r,events,final=self.shell([a,b,c,c]);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('retry',events);self.assertTrue(final)
 def test_shell_missing_or_incomplete_render_times_out_without_final(self):
  for text in ['SS_ORDER camera accepted=true\n',records(layout())+records(layout(),'42:2').splitlines()[0]+'\n']:
   r,events,final=self.shell([text]);self.assertNotEqual(r.returncode,0);self.assertFalse(final)
 def test_shell_malformed_postcapture_is_fatal(self):
  d=layout();bad=layout();bad['capture_state']['paused']='yes'
  r,events,final=self.shell([records(d),records(d)+records(bad,'42:2')]);self.assertEqual(r.returncode,1,r.stderr);self.assertFalse(final)
 def test_shell_drawn_frame_can_advance_without_freezing_serial(self):
  d=layout();after=layout();after['capture_state']['drawn_frame']=11
  r,events,final=self.shell([records(d),records(d)+records(after,'42:2')]);self.assertEqual(r.returncode,0,r.stderr);self.assertNotIn('retry',events);self.assertTrue(final)
 def test_shell_drawn_frame_or_snapshot_count_regression_is_fatal(self):
  d=layout();after=layout();after['capture_state']['drawn_frame']=9
  a=records(d);b=a+records(after,'42:2')
  for logs in [[a,b],[a+records(d,'42:2'),a]]:
   r,events,final=self.shell(logs);self.assertEqual(r.returncode,1,r.stderr);self.assertFalse(final)
 def test_shell_valid_geometry_change_retries_until_stable(self):
  d=layout();after=layout()
  for field in ['visual_rect','hit_rect']:after['controls'][0][field][0]+=2
  a=records(d);b=a+records(after,'42:2')
  r,events,final=self.shell([a,b,b,b]);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('retry',events);self.assertTrue(final)
if __name__=='__main__':unittest.main()
