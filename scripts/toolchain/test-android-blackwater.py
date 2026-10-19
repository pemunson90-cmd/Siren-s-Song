#!/usr/bin/env python3
"""Scoped protocol/geometry and unavailable-device archive isolation tests."""
import importlib.util,json,os,pathlib,shlex,struct,subprocess,sys,tempfile,unittest
ROOT=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('capture_fixtures',ROOT/'test-android-capture.py')
fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
CHECKER=ROOT/'android-blackwater.py'
def layout(kind='receiving'):
 d=fixture.layout();d['capture_state']['mission']=2
 if kind in ('gallery','route'):
  d['capture_state'].update(capture_unit=-1,optical_visible=False)
 if kind=='gallery':
  d['screen']='evidence';d['capture_state'].update(hud_visible=False,menu_visible=True)
  d['controls']=[{'action':'back','hit_rect':[900,600,400,84],'visual_rect':[900,600,400,84],'clipped':False}]
 return d
class BlackwaterTests(unittest.TestCase):
 def test_actual_fresh_fixture_and_ordinary_earned_archive_verifier(self):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder);archive=p/'fixture.save'
   command=[os.environ.get('GODOT_BIN','godot'),'--headless','--path',str(ROOT.parent.parent/'game'),'--script',str(ROOT/'native-blackwater-fixture.gd'),'--']
   r=subprocess.run(command+['--output='+str(archive)],capture_output=True,text=True)
   self.assertEqual(r.returncode,0,r.stderr);self.assertIn('fresh_snapshot_equal=true',r.stdout);self.assertTrue(archive.is_file())
   # Real production simulation and SaveStore, ordinary commands only. No poses,
   # enemy stun/lock injection or record/evidence fixture until actually earned.
   script=p/'earn.gd';script.write_text('''extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
func _initialize():
 var store=Store.new();store.path="ARCHIVE";var data=store.load_game();var s=Simulation.new();s.restore(data.active)
 s.command("select",{"unit":1});s.command("route",{"point":Vector2(760,390)});s.paused=false
 for n in 1500:
  s.advance(1.0/60)
  if s.camera_context().ready:break
 s.paused=true;s.command("emp");s.command("camera");s.paused=false
 for n in 600:
  s.advance(1.0/60)
  if s.mission.objectives[0].captured:break
 s.paused=true;data.active=s.snapshot();var o=s.mission.objectives[0]
 if not o.captured:push_error("ordinary request was not earned");quit(1);return
 data.evidence={o.optical:{"name":o.name,"caption":o.evidence,"optical":o.optical}}
 if not store.save(data):quit(1);return
 print("ORDINARY_REQUEST_EARNED");quit()
'''.replace('ARCHIVE',str(archive)))
   r=subprocess.run(command[:-3]+['--script',str(script)],capture_output=True,text=True)
   self.assertEqual(r.returncode,0,r.stderr);self.assertIn('ORDINARY_REQUEST_EARNED',r.stdout)
   r=subprocess.run(command+['--verify-earned='+str(archive)],capture_output=True,text=True)
   self.assertEqual(r.returncode,0,r.stderr);self.assertIn('earned_request_verified=true',r.stdout)
   archive.write_bytes(b'corrupt primary')
   # A valid .bak must not hide a corrupt primary in downloaded byte evidence.
   r=subprocess.run(command+['--verify-earned='+str(archive)],capture_output=True,text=True)
   self.assertNotEqual(r.returncode,0);self.assertNotIn('earned_request_verified=true',r.stdout)
 def invoke(self,text,kind='receiving',before=''):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder)
   for name,value in [('log',text),('before',before),('density','Physical density: 420\n')]: (p/name).write_text(value)
   (p/'image.png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',2520,1080))
   return subprocess.run([sys.executable,str(CHECKER),str(p/'log'),str(p/'image.png'),'--density',str(p/'density'),'--after-log',str(p/'before'),'--kind',kind,'--mission','2'],capture_output=True,text=True)
 def test_receiving_reuses_strict_paused_camera_contract(self):
  r=self.invoke(fixture.records(layout()));self.assertEqual(r.returncode,0,r.stderr)
 def test_gallery_requires_fresh_postdraw_and_exposed_back(self):
  r=self.invoke(fixture.records(layout('gallery')),'gallery');self.assertEqual(r.returncode,0,r.stderr)
 def test_gallery_does_not_accept_receiving_or_wrong_mission(self):
  for d in [layout(),layout('gallery')]:
   d['capture_state']['mission']=0
   self.assertEqual(self.invoke(fixture.records(d),'gallery').returncode,3)
 def test_gallery_missing_or_clipped_back_is_fatal(self):
  for change in ('missing','clipped'):
   d=layout('gallery')
   if change=='missing':d['controls'][0]['action']='next_record'
   else:d['controls'][0].update(clipped=True,hit_rect=[900,600,400,80])
   self.assertEqual(self.invoke(fixture.records(d),'gallery').returncode,1)
 def test_stale_incomplete_and_headless_never_become_final(self):
  for kind in ('receiving','gallery'):
   d=layout(kind);text=fixture.records(d)
   self.assertEqual(self.invoke(text,kind,text).returncode,3)
   self.assertEqual(self.invoke(text+fixture.records(d,'42:2').splitlines()[0]+'\n',kind).returncode,3)
   d['capture_state']['phase']='layout_only';self.assertEqual(self.invoke(fixture.records(d),kind).returncode,3)
 def test_malformed_other_screen_and_under48_remain_fatal(self):
  for change in ('state','geometry'):
   d=layout('gallery');d['screen']='menu'
   if change=='state':d['capture_state']['paused']='yes'
   else:d['controls'][0]['hit_rect'][3]=40
   self.assertEqual(self.invoke(fixture.records(d),'gallery').returncode,1)
 def test_latest_missing_capture_state_never_uses_old_record(self):
  d=layout('gallery');del d['capture_state']
  self.assertEqual(self.invoke(fixture.records(layout('gallery'))+fixture.records(d,'42:2'),'gallery').returncode,3)
 def test_route_maps_ordinary_world_point_from_validated_fresh_fit(self):
  text='SS_VIEW zoom=1.0 center=(800.0, 480.0)\n'+fixture.records(layout('route'))
  r=self.invoke(text,'route');self.assertEqual(r.returncode,0,r.stderr);self.assertEqual(json.loads(r.stdout)['tap'],[570,382])
 def test_route_rejects_unknown_view_and_waits_for_fresh_metrics(self):
  self.assertEqual(self.invoke(fixture.records(layout('route')),'route').returncode,1)
  self.assertEqual(self.invoke('SS_VIEW zoom=1.4 center=(800, 480)\n'+fixture.records(layout('route')),'route').returncode,1)
  self.assertEqual(self.invoke(fixture.records(layout('route'))+'SS_VIEW zoom=1 center=(800,480)\n','route').returncode,3)
 def test_route_does_not_fall_back_to_older_valid_fit(self):
  text='SS_VIEW zoom=1 center=(800,480)\nSS_VIEW zoom=nan center=(800,480)\n'+fixture.records(layout('route'))
  self.assertEqual(self.invoke(text,'route').returncode,1)
 def test_existing_capture_helper_accepts_optional_gallery_checker(self):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder);(p/'before').write_text('');(p/'log').write_text(fixture.records(layout('gallery')))
   (p/'png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+struct.pack('>II',2520,1080))
   script='''set -eu
source "$1/android-capture-smoke.sh"
output="$2"
stage() { :; }
adb() { if [[ "$*" == 'shell wm density' ]]; then echo 'Physical density: 420'; else cat "$output/png"; fi; }
read_logcat() { cp "$output/log" "$1"; }
sleep() { :; }
capture_state_shot cover-blackwater-gallery gallery "$output/before" 2 "$1/android-blackwater.py"
'''
   r=subprocess.run(['bash','-c',script,'test',str(ROOT),str(p)],capture_output=True,text=True)
   self.assertEqual(r.returncode,0,r.stderr);self.assertTrue((p/'cover-blackwater-gallery.png').exists())
 def archive_case(self,launch='return 17',temporary=False,restored=True,relative_real_entry=False):
  with tempfile.TemporaryDirectory() as folder:
   p=pathlib.Path(folder);(p/'remote/files').mkdir(parents=True);(p/'evidence').mkdir()
   primary=b'genuine\0\xff\r\n';backup=b'backup\0\xfe\r\n';(p/'remote/files/quietus.save').write_bytes(primary);(p/'remote/files/quietus.save.bak').write_bytes(backup)
   if temporary:(p/'remote/files/quietus.save.tmp').write_bytes(b'temporary\0\xfd\r\n')
   (p/'evidence/role-archive-primary.save').write_bytes(b'older-well-proof')
   script='''set -euo pipefail
source "$1/android-role-smoke.sh"
source "$1/android-blackwater-smoke.sh"
output="$2/evidence"; package=test.package; GAME_DIR="$2"; TOOLCHAIN_ROOT="$1/../.."
GODOT_BIN="$2/godot-mock"
mock_restore_fail=false
stage() { :; }
launch() { LAUNCH; }
adb() {
 local name="${@: -1}"; name="${name//$'\\r'/}"
 if [[ "$*" == 'shell run-as test.package find '* ]]; then echo files/quietus.save
 elif [[ "$*" == 'shell run-as test.package test -f '* ]]; then test -f "$2/remote/$name"
 elif [[ "$*" == 'exec-out run-as test.package cat '* ]]; then cat "$2/remote/$name"
 elif [[ "$*" == 'shell -T run-as '* ]]; then if "$mock_restore_fail"; then return 12; fi; cat >"$2/remote/$name"
 elif [[ "$*" == 'shell run-as test.package rm -f '* ]]; then local a; for a in "$@"; do [[ "$a" == files/* ]] && rm -f "$2/remote/$a"; done; return 0
 else return 0; fi
}
native_blackwater_smoke
'''.replace('$2/remote',str(p)+'/remote').replace('LAUNCH',launch)
   (p/'godot-mock').write_text('#!/bin/bash\nfor arg; do if [[ "$arg" == --output=* ]]; then echo fixture >"${arg#--output=}"; fi; done\necho SS_NATIVE_BLACKWATER fresh_snapshot_equal=true\n');(p/'godot-mock').chmod(0o755)
   source_root=str(ROOT)
   if relative_real_entry:
    source_root='scripts/toolchain'
    script=script.replace('GAME_DIR="$2"','GAME_DIR=game').replace('GODOT_BIN="$2/godot-mock"','GODOT_BIN='+shlex.quote(os.environ.get('GODOT_BIN','godot')))
   r=subprocess.run(['bash','-c',script,'test',source_root,str(p)],cwd=ROOT.parent.parent,capture_output=True,text=True)
   if relative_real_entry:
    proof=p/'evidence/blackwater/fixture-generation.txt'
    self.assertEqual(r.returncode,17,r.stderr+(proof.read_text() if proof.exists() else 'fixture output missing'))
    self.assertIn('fresh_snapshot_equal=true',proof.read_text())
   self.assertEqual((p/'evidence/blackwater/role-archive-primary.save').read_bytes(),primary)
   if restored:
    self.assertEqual((p/'remote/files/quietus.save').read_bytes(),primary,r.stderr);self.assertEqual((p/'remote/files/quietus.save.bak').read_bytes(),backup,r.stderr)
    if temporary:self.assertEqual((p/'remote/files/quietus.save.tmp').read_bytes(),b'temporary\0\xfd\r\n',r.stderr)
    else:self.assertFalse((p/'remote/files/quietus.save.tmp').exists(),r.stderr)
   self.assertEqual((p/'evidence/role-archive-primary.save').read_bytes(),b'older-well-proof',r.stderr)
   return r
 def test_failed_fixture_launch_restores_private_genuine_bytes(self):
  r=self.archive_case();self.assertEqual(r.returncode,17,r.stderr)
 def test_relative_source_real_godot_entry_restores_after_later_launch_failure(self):
  r=self.archive_case(temporary=True,relative_real_entry=True);self.assertEqual(r.returncode,17,r.stderr)
 def test_normal_exit_restores_existing_primary_backup_and_temporary(self):
  r=self.archive_case('exit 0',True);self.assertEqual(r.returncode,0,r.stderr)
 def test_term_restores_private_archive_and_propagates_signal_status(self):
  r=self.archive_case('kill -TERM "$BASHPID"');self.assertEqual(r.returncode,143,r.stderr)
 def test_restore_failure_is_fatal_and_preserves_local_genuine_backup(self):
  r=self.archive_case('mock_restore_fail=true; return 17',restored=False);self.assertEqual(r.returncode,1,r.stderr);self.assertIn('genuine archive restoration failed',r.stderr)
if __name__=='__main__':unittest.main()
