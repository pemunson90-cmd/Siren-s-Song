#!/usr/bin/env python3
"""Exercise clipped-menu reachability through the real native evidence CLI."""
import base64,hashlib,json, pathlib, struct, subprocess, sys, tempfile, unittest
CHECKER=pathlib.Path(__file__).with_name('android-menu.py')
def chunked(value,identity='42:1'):
 raw=json.dumps(value).encode();parts=[raw[i:i+450] for i in range(0,len(raw),450)]
 return '\n'.join(f'SS_UI_METRICS_PART id={identity} part={i} parts={len(parts)} bytes={len(raw)} sha256={hashlib.sha256(raw).hexdigest()} data={base64.b64encode(part).decode()}' for i,part in enumerate(parts))+'\n'
class Tests(unittest.TestCase):
 def snapshot(self,logs,*,after=0,action='settings',baseline=None,sizes=None):
  """Run the real shell/checker; mock only unavailable ADB/log transport."""
  with tempfile.TemporaryDirectory() as temp:
   p=pathlib.Path(temp);(p/'events').touch();(p/'reads').write_text('0');(p/'captures').write_text('0')
   sizes=sizes or [(2520,1080)]
   for i,size in enumerate(sizes,1):(p/f'source-{i}.png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',*size))
   for i,log in enumerate(logs,1):(p/f'log-{i}').write_text(log)
   if baseline is not None:(p/'baseline.json').write_text(json.dumps({'settings_values':baseline}))
   script='''set -eu
source "$1"
output="$2"
export output
menu_settings_baseline="$3"
adb() {
 if [[ "$*" == 'shell wm density' ]]; then echo density >>"$output/events"; echo 'Physical density: 420';
 elif [[ "$*" == 'exec-out screencap -p' ]]; then
  local n
  n=$(cat "$output/captures"); n=$((n+1)); echo "$n" >"$output/captures"
  if ((n>PNG_LIMIT)); then n=PNG_LIMIT; fi
  echo capture >>"$output/events"; cat "$output/source-$n.png"
 else return 99; fi
}
read_logcat() {
 local n
 n=$(cat "$output/reads"); n=$((n+1)); echo "$n" >"$output/reads"
 if ((n>LOG_LIMIT)); then n=LOG_LIMIT; fi
 echo "log:$n" >>"$output/events"
 cp "$output/log-$n" "$1"
}
python3() {
 local status=0
 command python3 "$@" || status=$?
 if [[ "$1" == */android-menu.py ]]; then echo "validate:$status" >>"$output/events"; fi
 return "$status"
}
sleep() { echo retry >>"$output/events"; }
menu_snapshot cover timing menu "$4" "$5"
echo "accepted:$menu_status" >>"$output/events"
'''.replace('LOG_LIMIT',str(len(logs))).replace('PNG_LIMIT',str(len(sizes)))
   r=subprocess.run(['bash','-c',script,'test',str(CHECKER.with_name('android-menu-smoke.sh')),str(p),str(p/'baseline.json') if baseline is not None else '',action,str(after)],capture_output=True,text=True)
   report=p/'ui-metrics-menu-cover-timing.json'
   return r,(p/'events').read_text().splitlines(),json.loads(report.read_text()) if report.exists() and report.stat().st_size else None,(p/'cover-menu-timing.png').exists()
 def test_snapshot_final_capture_follows_matching_fresh_validation(self):
  old='SS_UI_METRICS '+json.dumps(self.layout())+'\n'
  current=old+old
  r,events,report,final=self.snapshot([old,current,current],after=1)
  self.assertEqual(r.returncode,0,r.stderr)
  captures=[i for i,event in enumerate(events) if event=='capture']
  validations=[i for i,event in enumerate(events) if event=='validate:0']
  self.assertGreater(captures[-1],validations[0],events)
  self.assertGreater(validations[-1],captures[-1],events)
  self.assertEqual(report['metrics_count'],2);self.assertTrue(final)
 def test_snapshot_changed_geometry_during_capture_is_retried(self):
  first=self.layout();changed=self.layout();changed['scroll_vertical']=400
  old='SS_UI_METRICS '+json.dumps(first)+'\n';new=old+'SS_UI_METRICS '+json.dumps(changed)+'\n'
  r,events,report,final=self.snapshot([old,new,new,new])
  self.assertEqual(r.returncode,0,r.stderr);self.assertIn('retry',events)
  self.assertEqual(report['scroll_vertical'],400);self.assertTrue(final)
 def test_snapshot_identical_reemission_does_not_require_serial_freeze(self):
  line='SS_UI_METRICS '+json.dumps(self.layout())+'\n'
  r,events,report,final=self.snapshot([line,line+line])
  self.assertEqual(r.returncode,0,r.stderr);self.assertNotIn('retry',events)
  self.assertEqual(report['metrics_count'],2);self.assertTrue(final)
 def test_snapshot_postcapture_settings_mutation_is_fatal_without_final_png(self):
  layout=self.layout();before=layout['settings_values'].copy();old='SS_UI_METRICS '+json.dumps(layout)+'\n'
  layout['settings_values']['mute']=True;new=old+'SS_UI_METRICS '+json.dumps(layout)+'\n'
  r,events,report,final=self.snapshot([old,new],baseline=before)
  self.assertEqual(r.returncode,1,r.stderr);self.assertIn('Settings changed',r.stderr);self.assertFalse(final)
 def test_snapshot_freshness_timeout_never_publishes_final_png(self):
  r,events,report,final=self.snapshot(['SS_UI_METRICS '+json.dumps(self.layout())+'\n'],after=1)
  self.assertNotEqual(r.returncode,0);self.assertFalse(final)
 def test_snapshot_missing_target_preserves_scrolling_exit(self):
  r,events,report,final=self.snapshot(['SS_UI_METRICS '+json.dumps(self.layout())+'\n'],action='absent')
  self.assertEqual(r.returncode,0,r.stderr);self.assertEqual(events[-1],'accepted:2');self.assertTrue(final)
 def test_snapshot_valid_other_screen_transition_retries(self):
  current='SS_UI_METRICS '+json.dumps(self.layout())+'\n'
  other=self.layout();other['screen']='settings'
  transitioning=current+'SS_UI_METRICS '+json.dumps(other)+'\n';settled=transitioning+current
  r,events,report,final=self.snapshot([current,transitioning,settled,settled])
  self.assertEqual(r.returncode,0,r.stderr);self.assertIn('validate:3',events);self.assertIn('retry',events)
  self.assertEqual(report['screen'],'menu');self.assertEqual(report['metrics_count'],3);self.assertTrue(final)
 def test_snapshot_postcapture_png_geometry_mismatch_is_fatal(self):
  r,events,report,final=self.snapshot(['SS_UI_METRICS '+json.dumps(self.layout())+'\n'],sizes=[(2520,1080),(2184,1968)])
  self.assertEqual(r.returncode,1,r.stderr);self.assertIn('actual PNG dimensions',r.stderr);self.assertFalse(final)
 def test_snapshot_continuously_changing_state_times_out(self):
  logs=[];text=''
  for i in range(20):
   d=self.layout();d['scroll_vertical']=i;text+='SS_UI_METRICS '+json.dumps(d)+'\n';logs.append(text)
  r,events,report,final=self.snapshot(logs)
  self.assertNotEqual(r.returncode,0);self.assertEqual(events.count('capture'),11);self.assertFalse(final)
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
 def test_shell_progress_requires_actual_emitted_swipe_direction(self):
  helper=CHECKER.with_name('android-menu-smoke.sh')
  for before,after,y1,y2,accepted in ((0,1254,823,304,True),(1254,600,304,540,True),(1254,1254,823,304,False),(1254,1254,304,540,False),(600,1254,304,540,False),(1254,600,823,304,False),(0,1,823,304,False),(1,0,304,540,False),(0,50,304,304,False)):
   with self.subTest(before=before,after=after,y1=y1,y2=y2):
    r=subprocess.run(['bash','-c','source "$1"; menu_assert_scroll_progress "$2" "$3" "$4" "$5"','test',str(helper),str(before),str(after),str(y1),str(y2)],capture_output=True,text=True)
    self.assertEqual(r.returncode==0,accepted,r.stderr)
 def layout(self):return {'schema':1,'screen':'menu','orders_page':'primary','viewport':[1680,720],'window':[2520,1080],'safe_rect':[0,0,2520,1080],'density_dpi':420,'density_source':'android_display_metrics_density_dpi','chart_rect':None,'scroll_rect':[100,30,1480,650],'scroll_vertical':320,'settings_values':{'music':.5,'effects':.8,'mute':False},'controls':[{'action':'settings','visual_rect':[200,200,1000,84],'hit_rect':[200,200,1000,84],'clipped':False}]}
 def invoke(self,layout,after=0,action='settings',prefix='',size=(2520,1080),screen='menu',baseline=None,transport=None,wait=False,suffix=''):
  with tempfile.TemporaryDirectory() as temp:
   p=pathlib.Path(temp);(p/'log').write_text(prefix+(transport if transport is not None else 'SS_UI_METRICS '+json.dumps(layout)+'\n')+suffix);(p/'png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',*size));(p/'density').write_text('Physical density: 420\n')
   extra=['--wait-for-screen'] if wait else []
   if baseline is not None:(p/'before').write_text(json.dumps({'settings_values':baseline}));extra+=['--unchanged-settings',str(p/'before')]
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
 def test_nonvertical_clipping_never_tapped_or_scrolled_without_correction(self):
  d=self.layout();d['controls'][0].update(hit_rect=[200,200,1000,42],clipped=True);r=self.invoke(d);self.assertEqual(r.returncode,1);self.assertIn('no vertical scroll correction',r.stderr)
 def test_offscreen_omitted_target_never_tapped(self):
  d=self.layout();d['controls'][0]['action']='mission0';r=self.invoke(d,prefix='SS_TARGET settings center=500,500 viewport=1680,720\n');self.assertEqual(r.returncode,2);self.assertIn('swipe',json.loads(r.stdout))
 def test_swipe_uses_scroll_body_and_safe_transform(self):
  r=self.invoke(self.layout(),action='absent');swipe=json.loads(r.stdout)['swipe'];self.assertEqual(swipe,[1260,825,1260,289]);self.assertLess(swipe[3],swipe[1])
 def test_native_count114_overshoot_reverses_toward_above_target(self):
  # Exact decoded last atomic report from run39276951740, sha256 db1a0994...
  # Earlier 113 record count is reconstructed; target tail and last payload are native.
  d=json.loads('{"capture_state":{"capture_unit":-1,"drawn_frame":37,"hud_visible":false,"menu_visible":true,"mission":2,"optical_visible":false,"paused":true,"phase":"post_draw","selected":1},"chart_rect":[116.667,112.0,1072.333,580.0],"controls":[{"action":"loadout","clipped":false,"hit_rect":[513.333,464.0,736.0,98.0],"visual_rect":[513.333,464.0,736.0,98.0]},{"action":"settings","clipped":false,"hit_rect":[513.333,576.0,736.0,98.0],"visual_rect":[513.333,576.0,736.0,98.0]}],"density_dpi":420.0,"density_source":"android_display_metrics_density_dpi","orders_page":"primary","safe_rect":[136.0,0.0,2384.0,1080.0],"schema":1,"screen":"menu","scroll_rect":[513.333,46.0,744.0,628.0],"scroll_vertical":1254,"settings_values":{"effects":0.8,"music":0.5,"mute":false},"viewport":[1680.0,720.0],"window":[2520.0,1080.0]}')
  text=('SS_UI_METRICS '+json.dumps(d)+'\n')*113+chunked(d,'9030-5765039:8')+'SS_TARGET evidence center=881,-81 viewport=1680,720\n'
  r=self.invoke(d,action='evidence',after=113,transport=text)
  self.assertEqual(r.returncode,2,r.stderr);report=json.loads(r.stdout)
  self.assertEqual(report['metrics_count'],114);self.assertEqual(report['scroll_vertical'],1254)
  self.assertNotIn('tap',report);self.assertGreater(report['swipe'][3],report['swipe'][1],report)
 def test_directional_hint_is_not_a_tap_or_an_older_report_fallback(self):
  d=self.layout();hint='SS_TARGET evidence center=840,-81 viewport=1680,720\n'
  r=self.invoke(d,action='evidence',prefix=hint)
  self.assertEqual(r.returncode,2,r.stderr);j=json.loads(r.stdout)
  self.assertLess(j['swipe'][3],j['swipe'][1]);self.assertNotIn('tap',j)
  # A hint after an older complete record must also be ignored.
  r=self.invoke(d,action='evidence',transport=chunked(d)+hint+chunked(d,'42:2'))
  self.assertEqual(r.returncode,2,r.stderr);j=json.loads(r.stdout);self.assertLess(j['swipe'][3],j['swipe'][1])
  self.assertEqual(self.invoke(d,action='evidence',suffix=hint,after=1).returncode,3)
  self.assertEqual(self.invoke(d,action='evidence',transport=chunked(d)+hint+chunked(d,'42:2').splitlines()[0]+'\n').returncode,3)
 def test_both_layouts_scroll_toward_offscreen_target_with_bounded_travel(self):
  for size,viewport,body in (((2520,1080),(1680,720),(100,30,1480,650)),((2184,1968),(1280,1153),(100,60,1080,1000))):
   for target_y,direction in ((-81,1),(viewport[1]+300,-1)):
    with self.subTest(size=size,target_y=target_y):
     d=self.layout();d.update(window=list(size),viewport=list(viewport),safe_rect=[0,0,*size],scroll_rect=list(body))
     hint=f'SS_TARGET evidence center={viewport[0]//2},{target_y} viewport={viewport[0]},{viewport[1]}\n'
     r=self.invoke(d,size=size,action='evidence',suffix=hint)
     self.assertEqual(r.returncode,2,r.stderr);j=json.loads(r.stdout);swipe=j['swipe']
     self.assertGreater((swipe[3]-swipe[1])*direction,0,j);self.assertNotIn('tap',j)
     self.assertLessEqual(abs(swipe[3]-swipe[1]),body[3]*size[1]/viewport[1]*.25+1)
     for x,y in ((swipe[0],swipe[1]),(swipe[2],swipe[3])):
      self.assertTrue(body[0]<x*viewport[0]/size[0]<body[0]+body[2])
      self.assertTrue(body[1]<y*viewport[1]/size[1]<body[1]+body[3])
 def test_clipped_atomic_rect_controls_direction_without_a_target_hint(self):
  for size,viewport in (((2520,1080),(1680,720)),((2184,1968),(1280,1153))):
   for target_y,hit_y,hit_h,direction in ((0,30,54,1),(650,650,30,-1)):
    d=self.layout();d.update(window=list(size),viewport=list(viewport),safe_rect=[0,0,*size],scroll_rect=[100,30,1080,650]);d['controls'][0].update(visual_rect=[200,target_y,900,84],hit_rect=[200,hit_y,900,hit_h],clipped=True)
    r=self.invoke(d,size=size);self.assertEqual(r.returncode,2,r.stderr);j=json.loads(r.stdout)
    self.assertNotIn('tap',j);self.assertGreater((j['swipe'][3]-j['swipe'][1])*direction,0)
 def test_both_layouts_only_tap_fully_exposed_atomic_target_after_recovery(self):
  for size,viewport in (((2520,1080),(1680,720)),((2184,1968),(1280,1153))):
   d=self.layout();d.update(window=list(size),viewport=list(viewport),safe_rect=[0,0,*size],scroll_rect=[100,30,1080,650],scroll_vertical=600)
   d['controls'][0].update(action='evidence',visual_rect=[200,300,900,84],hit_rect=[200,300,900,84])
   # Even a conflicting target hint cannot supply a tap coordinate.
   text=chunked(d)+f'SS_TARGET evidence center=840,-81 viewport={viewport[0]},{viewport[1]}\n'+chunked(d,'42:2')
   r=self.invoke(d,size=size,action='evidence',transport=text,after=1)
   self.assertEqual(r.returncode,0,r.stderr);j=json.loads(r.stdout)
   self.assertEqual(j['metrics_count'],2);self.assertNotIn('swipe',j)
   self.assertEqual(j['tap'],[round(650*size[0]/viewport[0]),round(342*size[1]/viewport[1])])
 def test_malformed_or_ambiguous_current_direction_hint_is_fatal(self):
  for tail in ('SS_TARGET evidence center=840,nan viewport=1680,720\n','SS_TARGET evidence center=840,-81 viewport=1280,720\n','SS_TARGET evidence center=-1,-81 viewport=1680,720\n','SS_TARGET evidence center=840,300 viewport=1680,720\n','SS_TARGET evidence center=840,-81 viewport=1680,720\n'*2):
   r=self.invoke(self.layout(),action='evidence',suffix=tail);self.assertEqual(r.returncode,1,(tail,r.stderr))
 def test_direction_at_top_limit_cannot_request_impossible_reverse(self):
  d=self.layout();d['scroll_vertical']=0
  r=self.invoke(d,action='evidence',suffix='SS_TARGET evidence center=840,-81 viewport=1680,720\n')
  self.assertEqual(r.returncode,1,r.stderr)
 def test_settings_reverse_starts_in_empty_gap_and_preserves_values(self):
  d=self.layout();d['screen']='settings';d['controls'][0].update(action='volume_music',visual_rect=[200,300,1000,84],hit_rect=[200,300,1000,84])
  r=self.invoke(d,screen='settings',action='mute',suffix='SS_TARGET mute center=840,-81 viewport=1680,720\n',baseline=d['settings_values'])
  self.assertEqual(r.returncode,2,r.stderr);j=json.loads(r.stdout);x,y,_,end=j['swipe']
  self.assertGreater(end,y);self.assertEqual(j['swipe_origin'],'measured_empty_control_gap')
  self.assertFalse(300<=y/1.5<=384);self.assertEqual(j['settings_values'],d['settings_values'])
  d['controls'][0].update(visual_rect=[100,30,1480,650],hit_rect=[100,30,1480,650])
  r=self.invoke(d,screen='settings',action='mute',suffix='SS_TARGET mute center=840,-81 viewport=1680,720\n')
  self.assertEqual(r.returncode,1);self.assertIn('No measured empty',r.stderr)
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
 def test_opt_in_valid_other_screen_retries(self):
  d=self.layout();d['screen']='settings';self.assertEqual(self.invoke(d,wait=True).returncode,3)
 def test_opt_in_malformed_other_screen_is_fatal(self):
  for key,value in [('screen','unexpected'),('safe_rect',None),('settings_values',None),('controls',[])]:
   d=self.layout();d['screen']='settings';d[key]=value
   r=self.invoke(d,wait=True);self.assertEqual(r.returncode,1,r.stderr);self.assertNotIn('unrecognized arguments',r.stderr)
 def test_opt_in_settings_mutation_on_other_screen_is_fatal(self):
  d=self.layout();before=d['settings_values'].copy();d['screen']='settings';d['settings_values']['mute']=True
  r=self.invoke(d,wait=True,baseline=before);self.assertEqual(r.returncode,1);self.assertIn('Settings changed',r.stderr)
if __name__=='__main__':unittest.main()
