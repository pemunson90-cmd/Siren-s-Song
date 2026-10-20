#!/usr/bin/env python3
"""Raw physical-pixel input for live Godot; no game controls or winning policies."""
import argparse,fcntl,hashlib,json,os,pathlib,shutil,subprocess,time
BASE=pathlib.Path(__file__).resolve().parent
SHAPES={'cover':(2520,1080),'inner':(2184,1968)}
def atomic(path,data):
    temp=path.with_suffix('.tmp');temp.write_text(json.dumps(data));temp.replace(path)
def wait_json(path,match=None,timeout=40):
    until=time.monotonic()+timeout
    while time.monotonic()<until:
        try:
            data=json.loads(path.read_text())
            if match is None or data.get('id')==match:return data
        except (FileNotFoundError,json.JSONDecodeError):pass
        time.sleep(.08)
    raise SystemExit(f'Timed out waiting for {path}; inspect godot.log')
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--session',required=True)
    sub=p.add_subparsers(dest='action',required=True)
    start=sub.add_parser('start');start.add_argument('--shape',choices=SHAPES,default='cover');start.add_argument('--source',default='/workspace/Siren-s-Song-berth-instruments');start.add_argument('--profile');start.add_argument('--display',default=':527')
    tap=sub.add_parser('tap');tap.add_argument('point',nargs=2,type=float)
    drag=sub.add_parser('drag');drag.add_argument('points',nargs=4,type=float);drag.add_argument('--seconds',type=float,default=.5);drag.add_argument('--steps',type=int,default=20)
    pinch=sub.add_parser('pinch');pinch.add_argument('points',nargs=8,type=float,help='x1 y1 x2 y2 then end x1 y1 x2 y2');pinch.add_argument('--seconds',type=float,default=.5);pinch.add_argument('--steps',type=int,default=20)
    touch=sub.add_parser('touch');touch.add_argument('pressed',choices=['down','up']);touch.add_argument('point',nargs=2,type=float);touch.add_argument('--pointer',type=int,default=0)
    move=sub.add_parser('move');move.add_argument('point',nargs=2,type=float);move.add_argument('--pointer',type=int,default=0)
    key=sub.add_parser('key');key.add_argument('key')
    wait=sub.add_parser('wait');wait.add_argument('seconds',type=float)
    resize=sub.add_parser('resize');resize.add_argument('shape',choices=SHAPES)
    for action in ['screenshot','status','quit']:sub.add_parser(action)
    a=p.parse_args()
    if not a.session.replace('-','').replace('_','').isalnum():p.error('Session must contain letters, digits, hyphens or underscores')
    session=BASE/'sessions'/a.session
    if a.action=='start':
        if session.exists():p.error('Use a new session name to preserve previous input/evidence')
        session.mkdir(parents=True);source=pathlib.Path(a.source).resolve();xdg=session/'data'
        profile=None
        if a.profile:
            original=pathlib.Path(a.profile).resolve();target=xdg/'godot'/'app_userdata'/"Siren's Song"/'quietus.save';target.parent.mkdir(parents=True);shutil.copy2(original,target)
            profile={'original':str(original),'sha256':hashlib.sha256(original.read_bytes()).hexdigest(),'copied_to':str(target)}
        env=os.environ|{'DISPLAY':a.display,'XDG_DATA_HOME':str(xdg),'XDG_CONFIG_HOME':str(session/'config'),'XDG_CACHE_HOME':str(session/'cache'),'SS_PLAY_SESSION':str(session),'SS_PLAY_SHAPE':a.shape}
        with (BASE/'import.lock').open('w') as import_lock:
            fcntl.flock(import_lock,fcntl.LOCK_EX)
            import_command=['godot','--headless','--path',str(source/'game'),'--editor','--import','--quit']
            with (session/'import.log').open('w') as import_log:
                imported=subprocess.run(import_command,env=env,stdout=import_log,stderr=subprocess.STDOUT)
            if imported.returncode:
                raise SystemExit(f'Godot import failed; inspect {session/"import.log"}')
        command=['godot','--path' ,str(source/'game'),'--audio-driver','Dummy','--rendering-method','gl_compatibility','--script',str(BASE/'live_driver.gd')]
        log=(session/'godot.log').open('w');proc=subprocess.Popen(command,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True);log.close()
        sha=subprocess.check_output(['git','rev-parse','HEAD'],cwd=source,text=True).strip()
        atomic(session/'source.json',{'source':str(source),'sha':sha,'game_tree':subprocess.check_output(['git','rev-parse','HEAD:game'],cwd=source,text=True).strip(),'profile':profile,'pid':proc.pid,'command':command,'fixture':'420dpi recorded Android safearea; desktop rendering/input, not native/human acceptance','audio':'Dummy output; audio listening not evaluated'})
        ready=wait_json(session/'ready.json')
        if not ready.get('ready') or not ready.get('metrics'):raise SystemExit(f'Main did not load; inspect {session/"godot.log"}')
        print(json.dumps(ready,indent=2));return
    if not session.exists():p.error('Session not found; start first')
    with (session/'client.lock').open('w') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        args=vars(a).copy();args.pop('action');args.pop('session')
        if a.action=='touch':args['pressed']=a.pressed=='down'
        if a.action=='drag':args.update({'from':a.points[:2],'to':a.points[2:]});args.pop('points')
        if a.action=='pinch':args.update({'from':[a.points[:2],a.points[2:4]],'to':[a.points[4:6],a.points[6:]]});args.pop('points')
        identifier=str(time.time_ns());request={'id':identifier,'action':a.action,'args':args,'wall_time':time.time()}
        with (session/'requests.jsonl').open('a') as history:history.write(json.dumps(request)+'\n')
        atomic(session/'inbox.json',request)
        result=wait_json(session/'reply.json',identifier,timeout=max(40,args.get('seconds',0)+15))
        with (session/'responses.jsonl').open('a') as history:history.write(json.dumps(result)+'\n')
        print(json.dumps(result,indent=2))
if __name__=='__main__':main()
