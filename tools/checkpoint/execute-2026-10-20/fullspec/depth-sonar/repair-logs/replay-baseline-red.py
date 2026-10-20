from pathlib import Path
import os, subprocess
root=Path('/workspace/Siren-s-Song-play-frozen')
files=['simulation.gd','blackwater_delivery.gd','module_recovery.gd','witness_evacuation.gd','warning_chain.gd']
paths=[root/'game/src/simulation'/name for name in files]
saved={p:p.read_bytes() for p in paths}
try:
 for p in paths:p.write_bytes(subprocess.check_output(['git','show','d73b9fa0aa539ea86f81b65f44c25df675138ea4:'+str(p.relative_to(root))],cwd=root))
 env=dict(os.environ,XDG_DATA_HOME='/workspace/work/depth-repair-xdg')
 with open(Path(__file__).parent/'final-baseline-red.log','wb') as log:
  result=subprocess.run(['godot','--headless','--path','game','--script','res://tests/depth_sonar_tests.gd'],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=120)
 print('baseline exit',result.returncode)
finally:
 for p,data in saved.items():p.write_bytes(data)
 print('all five repaired source files restored byte-for-byte')
