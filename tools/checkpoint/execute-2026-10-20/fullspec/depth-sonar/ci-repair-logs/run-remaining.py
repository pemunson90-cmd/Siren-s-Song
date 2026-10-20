from pathlib import Path
import os,subprocess,time,re
root=Path('/workspace/Siren-s-Song-play-frozen');logs=Path(__file__).parent
workflow=(root/'.github/workflows/gauntlet-pr-checks.yml').read_text()
rows=[line.strip().split('|') for line in workflow.splitlines() if re.match(r'\s+[a-z0-9_]+\|',line)]
start=next(i for i,row in enumerate(rows) if row[0]=='earned_course_continuity_tests')+1
for scenario,summary in rows[start:]:
 began=time.monotonic();env=dict(os.environ,XDG_DATA_HOME='/workspace/work/depth-ci-'+scenario+'-xdg')
 with (logs/(scenario+'.log')).open('wb') as out:
  result=subprocess.run(['godot','--headless','--path','game','--script','res://tests/'+scenario+'.gd'],cwd=root,env=env,stdout=out,stderr=subprocess.STDOUT,timeout=600)
 elapsed=time.monotonic()-began;body=(logs/(scenario+'.log')).read_text()
 match=re.search('^'+re.escape(summary)+r' CHECKS [1-9][0-9]* FAILURES 0$',body,re.M)
 passed=result.returncode==0 and match and 'SCRIPT ERROR:' not in body and not re.search(r'(^|\s)ERROR:',body)
 line=f'{scenario}: {elapsed:.2f}s exit={result.returncode} '+(match.group(0) if passed else 'FAILED')
 print(line,flush=True)
 with (logs/'remaining-times.txt').open('a') as out:out.write(line+'\n')
 if not passed:
  print('\n'.join(body.splitlines()[-18:]),flush=True);raise SystemExit(1)
