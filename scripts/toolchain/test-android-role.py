#!/usr/bin/env python3
"""False-positive guards for native role observation, not gameplay substitutes."""
import importlib.util, pathlib, unittest, sys
sys.dont_write_bytecode=True
path=pathlib.Path(__file__).with_name('android-role.py')
spec=importlib.util.spec_from_file_location('role',path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
BASE='SS_ROLE mission=4 index=1 type=hunter mode={mode} pos={pos} home=800,600 target={target} lock=0 time={time}'
def row(mode,pos,time,target=-1): return BASE.format(mode=mode,pos=pos,time=time,target=target)
GOOD='\n'.join([row('DORMANT','800,600',0),row('INVESTIGATE','800,610',2),row('SEARCH','800,830',7),row('RETURN','800,820',20),row('DORMANT','800,605',28)])
class Tests(unittest.TestCase):
 def test_fresh_pre_tick_patrol_mode(self):self.assertGreater(module.evaluate(GOOD.replace("mode=DORMANT","mode=PATROL",1))["max_observed_home_distance"],190)
 def test_real_response(self):self.assertGreater(module.evaluate(GOOD)['max_observed_home_distance'],190)
 def test_stationary_rejected(self):self.assertRaises(ValueError,module.evaluate,GOOD.replace('800,830','800,600').replace('800,820','800,600'))
 def test_visual_contact_rejected(self):self.assertRaises(ValueError,module.evaluate,GOOD.replace('target=-1','target=0',1))
 def test_missing_return_rejected(self):self.assertRaises(ValueError,module.evaluate,'\n'.join(GOOD.splitlines()[:-1]))
 def test_wrong_mode_order_rejected(self):
  lines=GOOD.splitlines();lines[2]=row("RETURN","800,830",7);lines[3]=row("SEARCH","800,820",20);self.assertRaises(ValueError,module.evaluate,"\n".join(lines))
 def test_missing_search_rejected(self):self.assertRaises(ValueError,module.evaluate,GOOD.replace('mode=SEARCH','mode=INVESTIGATE'))
 def test_teleported_fixture_rejected(self):self.assertRaises(ValueError,module.evaluate,GOOD.replace('pos=800,600','pos=800,650',1))
 def test_unbounded_return_rejected(self):self.assertRaises(ValueError,module.evaluate,GOOD.replace('time=28','time=90'))
 def test_reordered_time_rejected(self):self.assertRaises(ValueError,module.evaluate,GOOD.replace('time=20','time=5'))
if __name__=='__main__':unittest.main()
