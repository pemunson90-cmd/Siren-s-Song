from pathlib import Path
import json, hashlib, re, subprocess, collections
from datetime import datetime, timezone
ROOT=Path(__file__).resolve().parent
repo=ROOT/'integration'
BASE='8c13f5be841ab71ad41b5a4dd1ea3c030b370e8c'
HEAD='0cf00531e209312b60beaa0272fd3a9ccc573870'
def git(*args):return subprocess.check_output(['git',*args],cwd=repo,text=True).strip()
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert git('rev-parse','HEAD')==HEAD,'candidate head moved'
assert subprocess.run(['git','merge-base','--is-ancestor',BASE,HEAD],cwd=repo).returncode==0
changed=git('diff','--name-only',BASE,HEAD).splitlines()
assert not any(p.startswith(('game/src/simulation/','game/src/campaign/')) for p in changed)
checks={}
for name,label in [('landmark-0cf-core.log','core'),('landmark-final-runtime.log','runtime'),('landmark-final-density.log','density'),('landmark-repair-data.log','landmark_data'),('landmark-repair-ui.log','landmark_projection'),('landmark-five-fixtures.log','five_authored_depth_fixtures')]:
 p=ROOT/name;text=p.read_text(encoding='utf-8-sig')
 result=re.findall(r'(?:[A-Z0-9 /]+ )?CHECKS\s+(\d+)\s+FAILURES\s+(\d+)',text)
 assert result and int(result[-1][0])>0 and result[-1][1]=='0',name+' has no positive passing footer'
 assert not re.search(r'ERROR:|leaked|still in use',text,re.I),name+' engine error'
 checks[label]={'file':name,'checks':int(result[-1][0]),'failures':0,'sha256':digest(p)}
core=(ROOT/'landmark-0cf-core.log').read_text(encoding='utf-8-sig')
assert all(re.search(r'CAMPAIGN '+str(n)+r' outcome=won',core) for n in range(1,7))
before=json.loads((ROOT/'landmarks-probe-before/rows.json').read_text(encoding='utf-8-sig'))
after=json.loads((ROOT/'landmarks-probe-after/rows.json').read_text(encoding='utf-8-sig'))
key=lambda r:(r['operation'],r['policy'])
assert len(before)==len(after)==76 and len(set(map(key,before)))==76
b={key(r):r for r in before};a={key(r):r for r in after}
assert a==b,'pressure records differ'
assert all(r['snapshot_valid'] for r in before+after)
assert (ROOT/'landmark-capture-v5-error.log').read_bytes()==b''
assert 'FAILURES 1' in (ROOT/'landmark-backedge-red.log').read_text(encoding='utf-8-sig')
captures=[]
for op in [8,14,28]:
 for phase in ['before','after']:
  p=ROOT/'landmarks-captures'/('op_%02d_%s.png'%(op,phase));assert p.stat().st_size>10000
  captures.append({'operation':op,'phase':phase,'file':'landmarks-captures/'+p.name,'sha256':digest(p)})
receipt={'created_utc':datetime.now(timezone.utc).isoformat(),'source_head':HEAD,'integration_base':BASE,'game_tree':git('rev-parse',HEAD+':game'),'engine':'official Windows Godot4.6.3 stable console','source_changes':changed,'checks':checks,'pressure':{'wrapper':'landmark_pressure_bounded.gd','wrapper_sha256':digest(ROOT/'landmark_pressure_bounded.gd'),'label':'epsilon-bounded external probe comparison, not an unmodified tracked-probe run','cases_per_side':76,'commands_per_side':sum(len(r['commands']) for r in before),'all_fields_and_commands_equal':True,'all_snapshots_valid':True,'outcomes_each':dict(collections.Counter(r['outcome'] for r in before))},'captures':captures,'review':'Independent /root/review_photo preliminary source/visual PASS on0cf00531; final evidence and own exact-head guidance/game-smoke still required.','limits':['Source-known technical routes, not blind human play.','One early unprotected op8 capture lost Quietus; preserved in rejected v2 evidence.','Actual current captures use ordinary finite EMP defense and retain real outcomes.','Restrained landmark accents; no wholesale environment/silhouette or new art-direction claim.','No APK, physical phone, full local matrix or enjoyment claim.']}
(ROOT/'landmarks-validation-receipt.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
print('VALIDATED',checks,'pressure pairs76 commands',receipt['pressure']['commands_per_side'],'all fields equal')
