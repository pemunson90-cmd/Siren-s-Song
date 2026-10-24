from pathlib import Path
import json,re,hashlib,subprocess,collections
root=Path('../').resolve();repo=Path.cwd();base='0e927292425cc4d5914054757b15bf345119529a';prior='6ffab7289e41bbf4b96304a1c6768def99f7fc1c'
def git(*a):return subprocess.check_output(['git',*a],text=True).strip()
assert git('rev-parse','HEAD')==prior and git('rev-parse','MERGE_HEAD')==base
assert not git('diff','--name-only','--diff-filter=U')
staged=git('write-tree');game=git('rev-parse',staged+':game')
assert subprocess.run(['git','diff','--cached','--quiet',prior,'--','game/src/presentation/landmarks','game/src/presentation/feature_views.gd','game/tests/landmark_tests.gd','game/tests/landmark_ui_tests.gd']).returncode==0
assert subprocess.run(['git','diff','--cached','--quiet',base,'--','game/src/campaign','game/src/simulation']).returncode==0
checks={}
for label,name in [('import','landmarks-reconciled-import.log'),('core','landmarks-reconciled-core.log'),('data','landmarks-reconciled-data.log'),('projection','landmarks-reconciled-ui.log'),('patrol','landmarks-reconciled-patrol.log'),('five_fixtures','landmarks-reconciled-five-fixtures.log'),('runtime','landmarks-reconciled-runtime.log'),('density','landmarks-reconciled-density.log')]:
 p=root/name;text=p.read_text(encoding='utf-8-sig');assert not re.search(r'ERROR:|leaked|still in use',text,re.I),name
 footer=re.findall(r'CHECKS\s+(\d+)\s+FAILURES\s+(\d+)',text)
 if label!='import':assert footer and int(footer[-1][0])>0 and footer[-1][1]=='0',name
 checks[label]={'file':name,'checks':int(footer[-1][0]) if footer else None,'failures':0,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
core=(root/'landmarks-reconciled-core.log').read_text(encoding='utf-8-sig');assert all(re.search('CAMPAIGN '+str(n)+' outcome=won',core) for n in range(1,7))
summary=json.loads((root/'landmarks-reconciled-pressure-summary.json').read_text());assert summary['all76_full_records_equal']
def states(name):return {d['op']:d['snapshot'] for l in (root/name).read_text(encoding='utf-8-sig').splitlines() if l.startswith('SOURCE_STATE ') for d in [json.loads(l[len('SOURCE_STATE '):])]} 
old=states('landmarks-old-state.log');new=states('landmarks-current-state.log');assert len(old)==len(new)==22 and {k for k in old if old[k]!=new[k]}=={0,2,4,5,16}
assert all(old[k]==new[k] for k in [8,14,28])
receipt={'current_base':base,'feature_parent':prior,'candidate_game_tree':game,'checks':checks,'pressure':summary,'start_state_hashes':{'old':old,'current':new},'unchanged_feature_source':True,'unchanged_simulation_campaign_against_current_base':True,'capture_reuse':'Six v5 captures from7e44ec9 retained. Ops8/14/28 start states, runtime simulation code, feature adapter/data/test blobs and projection are unchanged; captures remain visual evidence, not current-base fullplay claims.','prior_archive':'7e44ec9f8617936401d7e27877e6bce3f8eb5bbe','old_exact_checks':'6ffab72 guidance/game-smoke40072498877 bothsuccess, superseded by newerbase. Newcommit requires ownexactchecks+approval.'}
(root/'landmarks-reconciled-validation.json').write_text(json.dumps(receipt,indent=2));print('Candidate game tree',game,'checks',{k:v['checks'] for k,v in checks.items()},'pressure',summary['fresh_cases'],'fresh+',summary['reused_cases'],'unchanged reuse, commands',summary['commands_per_side'])
