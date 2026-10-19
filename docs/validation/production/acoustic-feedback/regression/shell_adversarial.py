#!/usr/bin/env python3
"""Independent bounded probes; import existing real shell/CLI transport fixture."""
import importlib.util,json,pathlib,unittest
p=pathlib.Path(__file__).resolve().parents[5]/'scripts/toolchain/test-android-menu.py'
spec=importlib.util.spec_from_file_location('fixture',p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class Independent(unittest.TestCase):
 def setUp(self):self.f=m.Tests()
 def record(self,d):return 'SS_UI_METRICS '+json.dumps(d)+'\n'
 def test_postcapture_malformed_latest_is_fatal(self):
  good=self.f.layout();bad=self.f.layout();bad['safe_rect']=None
  r,events,report,final=self.f.snapshot([self.record(good),self.record(good)+self.record(bad)])
  self.assertEqual(r.returncode,1,r.stderr);self.assertFalse(final)
 def test_postcapture_incomplete_chunk_cannot_fallback(self):
  line=self.record(self.f.layout());pending=m.chunked(self.f.layout(),'99:1').splitlines()[0]+'\n'
  r,events,report,final=self.f.snapshot([line,line+pending])
  self.assertNotEqual(r.returncode,0,r.stderr);self.assertFalse(final)
 def test_snapshot_count_regression_cannot_publish(self):
  line=self.record(self.f.layout());r,events,report,final=self.f.snapshot([line+line,line]*10)
  self.assertNotEqual(r.returncode,0,r.stderr);self.assertFalse(final)
 def test_target_exposure_change_requires_fresh_pair(self):
  first=self.f.layout();first['controls'][0]['action']='other_valid_action'
  old=self.record(first);settled=old+self.record(self.f.layout())
  r,events,report,final=self.f.snapshot([old,settled,settled,settled])
  self.assertEqual(r.returncode,0,r.stderr);self.assertIn('retry',events);self.assertTrue(final);self.assertIn('tap',report)
if __name__=='__main__':unittest.main(verbosity=2)
