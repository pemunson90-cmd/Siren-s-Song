"""Independent edge probes of real capture CLI/shell; transport/PNG headers mocked."""
import importlib.util,json,pathlib,sys
root=pathlib.Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('capture_test_helpers',root/'scripts/toolchain/test-android-capture.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
t=m.CaptureTests();results=[]
def case(name,text,expected,**kwargs):
 r=t.invoke(text,**kwargs);results.append({'case':name,'actual':r.returncode,'expected':expected,'stderr':r.stderr.strip()});assert r.returncode==expected,(name,r.returncode,r.stderr)
a=m.records(m.layout())
# A later invalid snapshot can never reuse the earlier valid camera record.
case('newest-malformed-json',a+'SS_UI_METRICS {malformed}\n',1)
v=m.layout();v['capture_state'].pop('mission');case('newest-missing-mission',a+m.records(v,'new:1'),1)
v=m.layout();v['capture_state']['mission']=5;case('newest-valid-wrong-mission',a+m.records(v,'new:1'),3)
v=m.layout();v['capture_state']['phase']='layout_only';case('newest-layout-only-after-postdraw',a+m.records(v,'new:1'),3)
case('log-session-replaced-with-same-record-count',m.records(m.layout(),'new:1'),3,before=a)
case('new-view-boundary-with-no-later-snapshot',a+'SS_VIEW zoom=2\n',3)
case('script-error-following-valid-postdraw',a+'SCRIPT ERROR: Invalid call\n',1)
# Incomplete state appearing only AFTER candidate PNG must not publish it.
v=m.layout();v['capture_state']['drawn_frame']=11
incomplete=a+m.records(v,'new:1').splitlines()[0]+'\n';complete=a+m.records(v,'new:1')
r,events,final=t.shell([a,incomplete,complete,complete])
results.append({'case':'postcapture-incomplete-latest-retries','actual':r.returncode,'expected':0,'events':events,'final_exists':final,'stderr':r.stderr.strip()})
assert r.returncode==0 and final and 'retry' in events,(r.returncode,events,final)
print(json.dumps({'checks':len(results),'all_passed':True,'method':'real CLI and shell; mocked ADB/log transport and PNG header; no native pixel claim','results':results},indent=2))
