#!/usr/bin/env python3
"""Fast real-Git boundary tests; local remotes only, no hooks installed here."""
import fcntl, importlib.util, json, os, pathlib, subprocess, sys, tempfile, time, unittest
ROOT=pathlib.Path(__file__).resolve().parent
HELPER=ROOT/'gauntlet-boundary.py'
INSTALL=ROOT/'install-gauntlet-hooks.py'
FILES=('AGENTS.md','docs/CONTINUATION.md','docs/WORKBENCH.md','docs/architecture/GAUNTLET.md','docs/CURRENT_GAME_SPEC.md','docs/V7_TO_GODOT_PARITY.md')

def run(*args,cwd=None,input=None):
 return subprocess.run(args,cwd=cwd,input=input,text=True,capture_output=True,timeout=15)

def git(repo,*args):
 r=run('git',*args,cwd=repo)
 if r.returncode:raise AssertionError(r.stderr)
 return r.stdout.strip()

class BoundaryTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup)
  self.base=pathlib.Path(self.tmp.name);self.remote=self.base/'remote.git';self.seed=self.base/'seed';self.repo=self.base/'client'
  git(self.base,'init','--bare',str(self.remote));git(self.base,'init',str(self.seed))
  git(self.seed,'config','user.name','Test');git(self.seed,'config','user.email','test@example.invalid')
  git(self.seed,'checkout','-b','gauntlet/production')
  for name in FILES:
   p=self.seed/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('# '+name+'\n\n> LIVING GAME SPEC / PERPETUAL QUALITY RATCHET: read both living documents.\n\n## Current execution contract\nUser current contract.\n\n## History\nFULL TAIL\n')
  git(self.seed,'add','.');git(self.seed,'commit','-m','initial');git(self.seed,'remote','add','origin',str(self.remote));git(self.seed,'push','origin','gauntlet/production')
  git(self.base,'clone','-b','gauntlet/production',str(self.remote),str(self.repo));git(self.repo,'config','user.name','Test');git(self.repo,'config','user.email','test@example.invalid')
  self.sha=git(self.seed,'rev-parse','HEAD')
 def invoke(self,*args,input=None):return run(sys.executable,str(HELPER),*args,cwd=self.repo,input=input)
 def receipt(self):
  p=self.repo/'.git/gauntlet-boundary/receipt.json';self.assertTrue(p.exists(),'Boundary must write an actual receipt');return json.loads(p.read_text())
 def update(self,name='AGENTS.md'):
  with (self.seed/name).open('a') as f:f.write('\nNEW USER DIRECTION\n')
  git(self.seed,'commit','-am','new governance');git(self.seed,'push','origin','gauntlet/production');return git(self.seed,'rev-parse','HEAD')
 def install(self):return run(sys.executable,str(INSTALL),cwd=self.repo)
 def test_fetch_full_cache_change_and_dirty_branch_preserved(self):
  r=self.invoke('--boundary','resume');self.assertEqual(r.returncode,0,r.stderr);a=self.receipt();self.assertEqual(a['policy_sha'],self.sha)
  for name in FILES:
   self.assertIn(name,a['files']);self.assertEqual(pathlib.Path(a['files'][name]['cache_path']).read_bytes(),(self.seed/name).read_bytes())
  git(self.repo,'checkout','-b','feature');(self.repo/'AGENTS.md').write_text('DIRTY LOCAL');self.update();new=self.update('docs/CURRENT_GAME_SPEC.md')
  r=self.invoke('--boundary','review');self.assertEqual(r.returncode,0,r.stderr);self.assertEqual(self.receipt()['policy_sha'],new);self.assertIn('AGENTS.md',self.receipt()['changed_files']);self.assertIn('docs/CURRENT_GAME_SPEC.md',self.receipt()['changed_files']);self.assertEqual(git(self.repo,'branch','--show-current'),'feature');self.assertEqual((self.repo/'AGENTS.md').read_text(),'DIRTY LOCAL')
 def test_failed_fetch_marks_stale_without_advancing_last_success(self):
  self.assertEqual(self.invoke().returncode,0);git(self.repo,'remote','set-url','origin',str(self.base/'missing.git'))
  r=self.invoke();self.assertNotEqual(r.returncode,0);d=self.receipt();self.assertEqual(d['status'],'stale');self.assertIsNone(d['policy_sha']);self.assertEqual(d['last_success']['policy_sha'],self.sha);self.assertIn('fetch',d['error'])
 def test_missing_remote_document_is_stale(self):
  self.assertEqual(self.invoke().returncode,0);git(self.seed,'rm','docs/WORKBENCH.md');git(self.seed,'commit','-m','broken docs');git(self.seed,'push','origin','gauntlet/production')
  self.assertNotEqual(self.invoke().returncode,0);self.assertEqual(self.receipt()['last_success']['policy_sha'],self.sha)
 def assert_missing_required_spec_stops_dispatch(self,name):
  self.assertEqual(self.invoke().returncode,0);git(self.seed,'rm',name);git(self.seed,'commit','-m','missing required living document');git(self.seed,'push','origin','gauntlet/production')
  p=self.base/'task.json';p.write_text(json.dumps({'target':'worker','message':'Task'}))
  r=self.invoke('--boundary','dispatch','--dispatch',str(p));self.assertNotEqual(r.returncode,0);self.assertEqual(r.stdout,'');d=self.receipt();self.assertEqual(d['status'],'stale');self.assertIsNone(d['policy_sha']);self.assertEqual(d['last_success']['policy_sha'],self.sha);self.assertIn(name,d['error'])
 def test_missing_current_game_spec_is_stale_without_dispatch(self):
  self.assert_missing_required_spec_stops_dispatch('docs/CURRENT_GAME_SPEC.md')
 def test_missing_parity_ledger_is_stale_without_dispatch(self):
  self.assert_missing_required_spec_stops_dispatch('docs/V7_TO_GODOT_PARITY.md')
 def test_dispatch_uses_fetched_sha_and_contract(self):
  for name in ('docs/CURRENT_GAME_SPEC.md','docs/V7_TO_GODOT_PARITY.md'):(self.repo/name).unlink()
  new=self.update();p=self.base/'task.json';p.write_text(json.dumps({'target':'/root/worker','message':'Implement bounded change.'}))
  r=self.invoke('--boundary','dispatch','--dispatch',str(p));self.assertEqual(r.returncode,0,r.stderr);d=json.loads(r.stdout);self.assertEqual(d['tool'],'collaboration.followup_task');self.assertIn(new,d['arguments']['message']);self.assertIn('NEW USER DIRECTION',pathlib.Path(self.receipt()['files']['AGENTS.md']['cache_path']).read_text());self.assertIn('User current contract',d['arguments']['message'])
  self.assertIn('LIVING GAME SPEC / PERPETUAL QUALITY RATCHET',d['arguments']['message']);self.assertNotIn('FULL TAIL',d['arguments']['message'])
  for name in ('docs/CURRENT_GAME_SPEC.md','docs/V7_TO_GODOT_PARITY.md'):
   self.assertIn(name+': '+self.receipt()['files'][name]['cache_path'],d['arguments']['message']);self.assertEqual(pathlib.Path(self.receipt()['files'][name]['cache_path']).read_bytes(),(self.seed/name).read_bytes());self.assertFalse((self.repo/name).exists())
  p.write_text(json.dumps({'task_name':'worker','message':'Task'}));r=self.invoke('--dispatch',str(p));d=json.loads(r.stdout);self.assertEqual(d['tool'],'collaboration.spawn_agent');self.assertEqual(d['arguments']['model'],'gpt-6.1-sol');self.assertEqual(d['arguments']['fork_turns'],'none')
 def test_dispatch_failure_emits_no_tool_payload(self):
  p=self.base/'task.json';p.write_text(json.dumps({'target':'worker','message':'Task'}));git(self.repo,'remote','set-url','origin',str(self.base/'missing'))
  r=self.invoke('--dispatch',str(p));self.assertNotEqual(r.returncode,0);self.assertEqual(r.stdout,'')
 def test_installer_refuses_unmanaged_hook_and_hookspath(self):
  p=self.repo/'.git/hooks/post-commit';p.write_text('#!/bin/sh\necho mine\n');r=self.install();self.assertNotEqual(r.returncode,0);self.assertEqual(p.read_text(),'#!/bin/sh\necho mine\n');self.assertFalse((self.repo/'.git/hooks/pre-push').exists())
  p.unlink();git(self.repo,'config','core.hooksPath','custom-hooks');r=self.install();self.assertNotEqual(r.returncode,0);self.assertEqual(git(self.repo,'config','core.hooksPath'),'custom-hooks')
 def test_automatic_commit_checkout_hooks_survive_missing_feature_scripts(self):
  r=self.install();self.assertEqual(r.returncode,0,r.stderr);new=self.update();(self.repo/'local.txt').write_text('work');git(self.repo,'add','local.txt');git(self.repo,'commit','-m','local')
  self.assertEqual(self.receipt()['policy_sha'],new);self.assertEqual(self.receipt()['boundary'],'post-commit');git(self.repo,'checkout','-b','feature');self.assertEqual(self.receipt()['boundary'],'post-checkout');self.assertFalse((self.repo/'scripts/toolchain/gauntlet-boundary.py').exists());self.assertEqual(self.install().returncode,0)
 def test_subprocess_timeout_kills_process_group_promptly(self):
  spec=importlib.util.spec_from_file_location('boundary_test',HELPER);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
  start=time.monotonic()
  with self.assertRaisesRegex(RuntimeError,'timed out'):module.command([sys.executable,'-c','import subprocess,time; subprocess.Popen(["sleep","5"]); time.sleep(5)'],timeout=0.1)
  self.assertLess(time.monotonic()-start,2)
 def test_busy_refresh_lock_fails_bounded_and_retries_next_boundary(self):
  self.assertEqual(self.invoke().returncode,0)
  with (self.repo/'.git/gauntlet-boundary/refresh.lock').open('a') as lock:
   fcntl.flock(lock,fcntl.LOCK_EX);start=time.monotonic();r=self.invoke('--lock-timeout','0.1');self.assertNotEqual(r.returncode,0);self.assertLess(time.monotonic()-start,2);self.assertEqual(self.receipt()['status'],'stale')
  self.assertEqual(self.invoke().returncode,0);self.assertEqual(self.receipt()['status'],'fresh')
 def test_postcommit_failure_preserves_commit_and_records_stale(self):
  self.assertEqual(self.install().returncode,0);self.assertEqual(self.invoke().returncode,0);git(self.repo,'remote','set-url','origin',str(self.base/'missing'))
  (self.repo/'work.txt').write_text('preserved');git(self.repo,'add','work.txt');git(self.repo,'commit','-m','preserve completed work');self.assertEqual(git(self.repo,'log','-1','--format=%s'),'preserve completed work');self.assertEqual(self.receipt()['status'],'stale')
 def test_actual_pre_push_hook_rejects_stale_production(self):
  self.assertEqual(self.install().returncode,0);new=self.update();(self.repo/'local.txt').write_text('work');git(self.repo,'add','local.txt');git(self.repo,'commit','-m','divergent work')
  r=run('git','push','--force','origin','gauntlet/production',cwd=self.repo);self.assertNotEqual(r.returncode,0);self.assertIn('ancestor',r.stderr);self.assertEqual(git(self.remote,'rev-parse','refs/heads/gauntlet/production'),new)
 def test_production_push_rejects_remote_ahead_but_feature_push_can_refresh(self):
  new=self.update();updates=f'refs/heads/gauntlet/production {self.sha} refs/heads/gauntlet/production {self.sha}\n'
  r=self.invoke('--boundary','pre-push',input=updates);self.assertNotEqual(r.returncode,0);self.assertEqual(self.receipt()['policy_sha'],new);self.assertIn('ancestor',r.stderr)
  r=self.invoke('--boundary','pre-push',input=f'refs/heads/feature {self.sha} refs/heads/feature '+('0'*40)+'\n');self.assertEqual(r.returncode,0,r.stderr)
  git(self.repo,'merge','--ff-only','origin/gauntlet/production');r=self.invoke('--boundary','pre-push',input=f'refs/heads/gauntlet/production {new} refs/heads/gauntlet/production {new}\n');self.assertEqual(r.returncode,0,r.stderr)
if __name__=='__main__':unittest.main()
