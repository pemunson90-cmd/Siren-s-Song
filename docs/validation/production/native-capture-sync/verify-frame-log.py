"""Verify actual isolated GL/headless diagnostic transitions, not native pixels."""
import json,pathlib,re,sys
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[4]/'scripts/toolchain'))
from android_metric_records import read_records
text=pathlib.Path(sys.argv[1]).read_text();headless='display=headless' in text
start=text.index('SYNC_TEST camera_before');end=text.index('SYNC_TEST camera_settled')
camera=[json.loads(raw) for _,raw in read_records(text[start:end]) if raw is not None]
matches=[x['capture_state'] for x in camera if 'capture_state' in x]
assert matches,'Camera command accepted before render, but no fresh capture-state diagnostic followed'
expected='layout_only' if headless else 'post_draw'
assert any(x['phase']==expected and x['paused'] and x['selected']==1 and x['capture_unit']==1 and x['optical_visible'] for x in matches),matches
ack=re.search(r'SYNC_TEST ack capture=1 optical=false drawn=(\d+)',text)
assert ack,'Expected actual accepted command before optical child update'
if not headless:assert any(x['phase']=='post_draw' and x['optical_visible'] and x['drawn_frame']>int(ack[1]) for x in matches)
start=text.index('SYNC_TEST restore_before');end=text.index('SYNC_TEST restore_settled')
restored=[json.loads(raw) for _,raw in read_records(text[start:end]) if raw is not None]
assert any(x.get('capture_state',{}).get('phase')==expected and x['screen']=='mission' and x['capture_state']['paused'] and x['capture_state']['hud_visible'] and not x['capture_state']['menu_visible'] for x in restored)
if headless:assert all(x.get('capture_state',{}).get('phase')!='post_draw' for _,raw in read_records(text) if raw is not None for x in [json.loads(raw)])
print('PASS actual',expected,'camera and entered-mission diagnostic transitions; no compositor claim')
