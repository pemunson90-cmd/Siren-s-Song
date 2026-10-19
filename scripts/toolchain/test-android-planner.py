#!/usr/bin/env python3
"""Real CLI tests with synthetic atomic metrics, not Android input evidence."""
import base64,copy,hashlib,json,pathlib,struct,subprocess,sys,tempfile,unittest
CHECKER=pathlib.Path(__file__).with_name('android-planner.py')
def record(value,serial=1):
 raw=json.dumps(value).encode();parts=[raw[i:i+450] for i in range(0,len(raw),450)]
 return '\n'.join(f'SS_UI_METRICS_PART id=session:{serial} part={i} parts={len(parts)} bytes={len(raw)} sha256={hashlib.sha256(raw).hexdigest()} data={base64.b64encode(p).decode()}' for i,p in enumerate(parts))+'\n'
def layout():
 controls=[]
 for i,key in enumerate(['close','craft0','craft1','craft2','planner_zoom_out','planner_zoom_in','planner_fit']):
  r=[i*210,10,200,84];controls.append(dict(action=key,visual_rect=r,hit_rect=r,clipped=False))
 units=[dict(alive=True,pos=[140,800],velocity=[0,0],battery=100,silent=True,hold='',goals=[dict(pos=[260,800],mode='inherit',stop=True,legacy=False)]) for _ in range(3)]
 return dict(schema=1,screen='program',viewport=[1680,720],window=[2520,1080],safe_rect=[0,0,2520,1080],density_dpi=420,density_source='android_display_metrics_density_dpi',chart_rect=[10,110,600,500],controls=controls,capture_state=dict(phase='post_draw',paused=True,selected=0,mission=0,drawn_frame=100,hud_visible=False,menu_visible=False,optical_visible=False),planner=dict(preview_physical=[15,165,900,750],zoom=1,center=[800,480],intent=dict(paused=True,selected=0,mission=0,elapsed=0,oxygen=120,hull=100,tools=dict(emp=2,decoy=3,recon=2,knock=2),queue=False,pass_through=True,units=units)))
class PlannerCLI(unittest.TestCase):
 def shell_snapshot(self,first,second=None):
  with tempfile.TemporaryDirectory() as name:
   p=pathlib.Path(name);(p/'first').write_text('SS_SCREEN program\n'+record(first,2));(p/'second').write_text('SS_SCREEN program\n'+record(second or first,3));(p/'before').write_text('');(p/'fixture.png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',2520,1080))
   script='''set -eu
source "$1/scripts/toolchain/android-planner-smoke.sh"
TOOLCHAIN_ROOT="$1"; output="$2"; reads=0
adb() { if [[ "$*" == 'shell wm density' ]]; then echo 'Physical density: 420'; else cat "$output/fixture.png"; fi; }
read_logcat() { reads=$((reads+1)); if (( reads % 2 == 1 )); then cp "$output/first" "$1"; else cp "$output/second" "$1"; fi; }
sleep() { :; }
planner_snapshot cover initial initial "$output/before"
'''
   r=subprocess.run(['bash','-c',script,'test',str(CHECKER.parents[2]),str(p)],capture_output=True,text=True)
   return r,(p/'cover-planner-initial.png').exists(),len(list(p.glob('*rejected*.png')))
 def invoke(self,value=None,*,prefix='SS_SCREEN program\n',suffix='',before='',operation='initial',baseline=None,previous=None,density='Physical density: 420\n',size=(2520,1080),transport=None):
  with tempfile.TemporaryDirectory() as name:
   p=pathlib.Path(name);(p/'log').write_text(prefix+(record(value or layout(),2) if transport is None else transport)+suffix);(p/'before').write_text(before);(p/'density').write_text(density);(p/'png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',*size))
   cmd=[sys.executable,str(CHECKER),str(p/'log'),str(p/'png'),'--density',str(p/'density'),'--after-log',str(p/'before'),'--operation',operation]
   for key,data in [('baseline',baseline),('previous',previous)]:
    if data is not None:(p/key).write_text(json.dumps(data));cmd+=['--'+key,str(p/key)]
   return subprocess.run(cmd,capture_output=True,text=True)
 def good_report(self):
  r=self.invoke();self.assertEqual(r.returncode,0,r.stderr);return json.loads(r.stdout)
 def test_actual_geometry_and_intent_report(self):self.assertTrue(self.good_report()['measurement']['gate_passed'])
 def test_shell_preserves_only_stable_bracketed_capture(self):
  r,final,rejected=self.shell_snapshot(layout());self.assertEqual(r.returncode,0,r.stderr);self.assertTrue(final);self.assertEqual(rejected,0)
 def test_shell_retains_changed_state_candidates_without_final(self):
  changed=layout();changed['planner']['intent']['tools']['knock']=1
  r,final,rejected=self.shell_snapshot(layout(),changed);self.assertNotEqual(r.returncode,0);self.assertFalse(final);self.assertEqual(rejected,10)
 def test_chunked_latest_incomplete_never_falls_back(self):self.assertEqual(self.invoke(suffix='\n'.join(record(layout(),3).splitlines()[:-1])+'\n').returncode,3)
 def test_stale_after_screen(self):self.assertEqual(self.invoke(suffix='SS_SCREEN program\n').returncode,3)
 def test_stale_same_transport_identity(self):self.assertEqual(self.invoke(before=record(layout(),2)).returncode,3)
 def test_transport_cannot_go_backwards(self):self.assertEqual(self.invoke(transport=record(layout(),3)+record(layout(),2)).returncode,1)
 def test_malformed_latest_fails(self):self.assertEqual(self.invoke(suffix='SS_UI_METRICS {\n').returncode,1)
 def test_duplicate_part_fails(self):
  text=record(layout(),3);self.assertEqual(self.invoke(transport=text+text.splitlines()[0]+'\n').returncode,1)
 def test_native_provenance_required(self):
  v=layout();v['density_source']='test_android_density_fixture';self.assertEqual(self.invoke(v).returncode,1)
 def test_density_must_match(self):self.assertEqual(self.invoke(density='Physical density: 360\n').returncode,1)
 def test_png_dimensions_must_match(self):self.assertEqual(self.invoke(size=(2184,1968)).returncode,1)
 def test_required_controls_missing_or_small_or_clipped(self):
  for kind in ['missing','small','clipped']:
   v=layout()
   if kind=='missing':v['controls'].pop()
   elif kind=='small':v['controls'][-1]['hit_rect']=[1260,10,200,48]
   else:v['controls'][-1]['clipped']=True
   self.assertEqual(self.invoke(v).returncode,1,kind)
 def test_preview_must_equal_physical_chart(self):
  v=layout();v['planner']['preview_physical'][0]+=10;self.assertEqual(self.invoke(v).returncode,1)
 def test_unpaused_or_hidden_state_mismatch_fails(self):
  for field in ['paused','selected']:
   v=layout();v['planner']['intent'][field]=False if field=='paused' else 1;self.assertEqual(self.invoke(v).returncode,1)
 def test_layout_only_pending(self):
  v=layout();v['capture_state']['phase']='layout_only';self.assertEqual(self.invoke(v).returncode,3)
 def test_zoom_pan_fit_with_identical_intent(self):
  base=self.good_report();v=layout();v['planner']['zoom']=1.5
  r=self.invoke(v,operation='zoom-in',baseline=base,previous=base);self.assertEqual(r.returncode,0,r.stderr);zoom=json.loads(r.stdout)
  v['planner']['center']=[900,480];r=self.invoke(v,operation='pan',baseline=base,previous=zoom);self.assertEqual(r.returncode,0,r.stderr)
  r=self.invoke(operation='fit',baseline=base,previous=json.loads(r.stdout));self.assertEqual(r.returncode,0,r.stderr)
 def test_no_view_change_fails(self):
  base=self.good_report()
  for op in ['zoom-in','zoom-out','pan']:self.assertEqual(self.invoke(operation=op,baseline=base,previous=base).returncode,1,op)
 def test_fit_requires_world_center(self):
  base=self.good_report();v=layout();v['planner']['center']=[810,480];self.assertEqual(self.invoke(v,operation='fit',baseline=base,previous=base).returncode,1)
 def test_navigation_route_selection_or_resources_change_fails(self):
  base=self.good_report()
  for kind in ['goal','tool','selected','oxygen']:
   v=layout();v['planner']['zoom']=1.5
   if kind=='goal':v['planner']['intent']['units'][0]['goals'][0]['pos'][0]+=1
   elif kind=='tool':v['planner']['intent']['tools']['knock']-=1
   elif kind=='selected':v['planner']['intent']['selected']=1;v['capture_state']['selected']=1
   else:v['planner']['intent']['oxygen']-=1
   self.assertEqual(self.invoke(v,operation='zoom-in',baseline=base,previous=base).returncode,1,kind)
 def test_invalid_numeric_view_or_intent_fails(self):
  for kind in ['zoom','center','units']:
   v=layout()
   if kind=='units':v['planner']['intent']['units']=[]
   else:v['planner'][kind]=float('nan') if kind=='zoom' else [float('inf'),480]
   self.assertEqual(self.invoke(v).returncode,1)
 def test_inner_geometry_uses_its_own_axis_scale(self):
  v=layout();v.update(window=[2184,1968],viewport=[1280,1153],safe_rect=[0,0,2184,1968])
  for i,c in enumerate(v['controls']):
   r=[i*170,10,160,74];c.update(hit_rect=r,visual_rect=r)
  v['planner']['preview_physical']=[10*2184/1280,110*1968/1153,600*2184/1280,500*1968/1153]
  self.assertEqual(self.invoke(v,size=(2184,1968)).returncode,0)
if __name__=='__main__':unittest.main()
