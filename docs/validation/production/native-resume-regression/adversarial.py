"""Independent omitted decoder/status and foreground-boundary probes; ADB mocked."""
from pathlib import Path
import importlib.util,json,subprocess,tempfile,os,hashlib
ROOT=next(p for p in Path(__file__).resolve().parents if (p/'AGENTS.md').is_file())
TOOLS=ROOT/'work/native-resume-regression/candidate/scripts/toolchain'
spec=importlib.util.spec_from_file_location('fixtures',TOOLS/'test-android-capture.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
results=[]
layout=m.layout('restored-mission');fresh='SS_LIFECYCLE foreground\n'+m.records(layout)
# Real resume checker must reject an otherwise-valid paused own-sub view with
# another craft's active capture, even when the optical child is hidden.
with tempfile.TemporaryDirectory(dir=ROOT/'work/native-resume-regression') as folder:
 p=Path(folder);d=m.layout('restored-mission');d['capture_state']['capture_unit']=1
 (p/'log').write_text('SS_LIFECYCLE foreground\n'+m.records(d));(p/'before').write_text('');(p/'density').write_text('Physical density: 420\n');(p/'png').write_bytes((TOOLS/'fixtures/native-cover-resume-black.png').read_bytes())
 command=['python3',str(TOOLS/'android-capture.py'),str(p/'log'),str(p/'png'),'--density',str(p/'density'),'--after-log',str(p/'before'),'--kind','resumed-mission','--mission','0']
 r=subprocess.run(command,capture_output=True,text=True,timeout=10);assert r.returncode==3,(r.returncode,r.stderr);results.append({'case':'resume rejects hidden other-station active capture','exit':r.returncode,'expected':3})

def shell_case(name,decoder_text,logs,expected,real_decoder=False):
 with tempfile.TemporaryDirectory(dir=ROOT/'work/native-resume-regression') as folder:
  p=Path(folder);(p/'before').write_text('');(p/'count').write_text('0');(p/'events').touch()
  # Correct dimensions but invalid chunk stream: geometry-only parser can pass
  # its PNG header; the real image decoder must fail instead of publishing it.
  (p/'image.png').write_bytes(b'\x89PNG\r\n\x1a\n'+b'\0'*8+(2520).to_bytes(4,'big')+(1080).to_bytes(4,'big'))
  for i,text in enumerate(logs,1):(p/f'log-{i}').write_text(text)
  decoder=p/'fake-godot';decoder.write_text('#!/usr/bin/env bash\n'+decoder_text+'\n');decoder.chmod(0o755)
  script='''set -euo pipefail
source "$1/android-capture-smoke.sh"
output="$2";GAME_DIR="$1/../../game";GODOT_BIN="$3"
stage() { :; }
sleep() { echo retry >>"$output/events"; }
adb() { if [[ "$*" == 'shell wm density' ]];then echo 'Physical density: 420';else cat "$output/image.png";fi; }
read_logcat() { local n; n=$(cat "$output/count");n=$((n+1));echo "$n" >"$output/count";if ((n>LIMIT));then n=LIMIT;fi;echo "log:$n" >>"$output/events";cp "$output/log-$n" "$1"; }
capture_state_shot cover-resume resumed-mission "$output/before" 0 "$1/android-capture.py" "$1/check-nonblank-frame.gd"
'''.replace('LIMIT',str(len(logs)))
  r=subprocess.run(['bash','-c',script,'probe',str(TOOLS),str(p),'godot' if real_decoder else str(decoder)],capture_output=True,text=True,timeout=20)
  rejected=sorted(p.glob('cover-resume-rejected-*.png'));final=(p/'cover-resume.png').exists();probe=(p/'cover-resume-geometry-probe.png').exists();events=(p/'events').read_text().splitlines()
  row={'case':name,'exit':r.returncode,'expected':expected,'final_exists':final,'geometry_probe_retained':probe,'rejected_count':len(rejected),'events':events,'stderr':r.stderr.strip()};results.append(row)
  assert r.returncode==expected,(name,row)
  assert probe and rejected,(name,row)
  if expected:assert not final,(name,row)
  else:assert final and 'retry' in events,(name,row)

shell_case('exit0 without explicit pixel marker is fatal','exit 0',[fresh,fresh],1)
shell_case('pixel marker cannot override decoder error','echo "SS_FRAME_PIXELS nonblank=true"\nexit 7',[fresh,fresh],7)
shell_case('real decoder rejects geometry-valid corrupt PNG','',[fresh,fresh],1,real_decoder=True)
# A second foreground notification between pre/post checks invalidates this
# candidate; only a later complete report can pass the subsequent bracket.
new=fresh+'SS_LIFECYCLE foreground\n';complete=new+m.records(layout,'42:2')
shell_case('foreground change after candidate forces a fresh bracket','echo "SS_FRAME_PIXELS nonblank=true"\nexit 0',[fresh,new,complete,complete],0)
print(json.dumps({'all_passed':True,'method':'real checker/helper; mocked ADB/logs. Three decoder-boundary probes plus real corruptPNG decoding; no screenshot identity/native claim.','results':results},indent=2))
