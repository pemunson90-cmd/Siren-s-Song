#!/usr/bin/env python3
"""Bounded disclosure planning tests; no native interaction/comfort claim."""
import base64,importlib.util,json,pathlib,subprocess,sys,tempfile,unittest
sys.dont_write_bytecode=True
path=pathlib.Path(__file__).with_name('android-radial.py')
spec=importlib.util.spec_from_file_location('radial',path);radial=importlib.util.module_from_spec(spec);spec.loader.exec_module(radial)
def state(page, controls=(), selected=1):
 return {'screen':'mission','hud_layout':'radial','context_page':page,'controls':[{'action':a} for a in controls],'capture_state':{'selected':selected}}
class Tests(unittest.TestCase):
 def test_visible_control_needs_no_disclosure(self):self.assertIsNone(radial.next_action(state('tools',['decoy']),'decoy'))
 def test_water_opens_fleet_before_hidden_action(self):self.assertEqual(radial.next_action(state('water'),'emp'),'more_orders')
 def test_fleet_chooses_explicit_selected_station(self):self.assertEqual(radial.next_action(state('fleet'),'emp'),'droneA')
 def test_each_craft_submenu(self):
  for target,page in [('emp','tools_menu'),('home','route_menu'),('contact_hold','guard_menu')]:self.assertEqual(radial.next_action(state('craft'),target),page)
 def test_other_page_goes_back_before_new_action(self):self.assertEqual(radial.next_action(state('tools'),'camera'),'radial_back')
 def test_world_targets_wait_for_water(self):
  self.assertEqual(radial.next_action(state('craft'),'objective0'),'radial_back');self.assertIsNone(radial.next_action(state('water'),'objective0'))
 def test_legacy_and_menu_have_no_new_navigation(self):
  self.assertIsNone(radial.next_action({'screen':'mission'},'emp'));self.assertIsNone(radial.next_action({'screen':'menu'},'emp'))
 def test_invalid_state_fails_closed(self):
  self.assertRaises(ValueError,radial.next_action,state('unknown'),'emp');self.assertRaises(ValueError,radial.next_action,state('fleet',selected=True),'emp')
 def test_disclosure_steps_never_fire_a_tool(self):
  for page in ['water','fleet','craft','tools','route','guard','inspect']:
   for action in ['decoy','emp','recon','knock','camera','home','contact_hold','route']:
    self.assertIn(radial.next_action(state(page),action),[None,'more_orders','sub','droneA','droneB','radial_back','tools_menu','route_menu','guard_menu'])
 def test_cli_requires_latest_complete_current_layout(self):
  with tempfile.TemporaryDirectory() as folder:
   log=pathlib.Path(folder)/'log'
   for suffix,status in [('',0),('SS_VIEW changed\n',2),('SS_UI_METRICS_PART id=1:2 part=0 parts=2 bytes=500 sha256='+'0'*64+' data='+base64.b64encode(b'x'*450).decode()+'\n',2)]:
    log.write_text('SS_SCREEN mission\nSS_UI_METRICS '+json.dumps(state('water'))+'\n'+suffix)
    r=subprocess.run([sys.executable,str(path),str(log),'emp'],capture_output=True,text=True);self.assertEqual(r.returncode,status,r.stderr)
if __name__=='__main__':unittest.main()
