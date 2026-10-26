#!/usr/bin/env python3
"""Fetch/copy current instructions at an explicit or Git-hook task boundary."""
import argparse, errno, hashlib, json, os, pathlib, re, signal, subprocess, sys, tempfile, time
if os.name=='nt':import msvcrt
else:import fcntl

FILES=('AGENTS.md','docs/USER_DIRECTIVES.md','docs/RESUME.md','docs/CONTINUATION.md','docs/WORKBENCH.md','docs/architecture/GAUNTLET.md','docs/CURRENT_GAME_SPEC.md','docs/V7_TO_GODOT_PARITY.md')
INTEGRATION='refs/heads/claude/integration'
REF='refs/remotes/origin/claude/integration'
PRODUCTION='refs/heads/gauntlet/production'
PRODUCTION_REF='refs/remotes/origin/gauntlet/production'

def command(args, timeout=30):
    env=os.environ.copy();env['GIT_TERMINAL_PROMPT']='0'
    if os.name=='nt':
        # Files avoid pipe-reader threads waiting on an already exited parent's children.
        with tempfile.TemporaryFile() as out, tempfile.TemporaryFile() as err:
            process=subprocess.Popen(args,stdout=out,stderr=err,env=env,creationflags=subprocess.CREATE_NEW_PROCESS_GROUP)
            try:process.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                cleanup=''
                try:
                    result=subprocess.run(['taskkill','/PID',str(process.pid),'/T','/F'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=1)
                    if result.returncode:cleanup='; tree termination failed'
                except (OSError,subprocess.TimeoutExpired):cleanup='; tree termination unavailable'
                try:
                    if process.poll() is None:process.kill()
                    process.wait(timeout=1)
                except (OSError,subprocess.TimeoutExpired):cleanup+='; process cleanup failed'
                raise RuntimeError(f'{args[0]} {args[1]} timed out after {timeout:g}s'+cleanup)
            # Snapshot only bytes present at parent exit; do not await descendants.
            out_size=os.fstat(out.fileno()).st_size;err_size=os.fstat(err.fileno()).st_size
            out.seek(0);err.seek(0);stdout=out.read(out_size);stderr=err.read(err_size)
    else:
        with subprocess.Popen(args,stdout=subprocess.PIPE,stderr=subprocess.PIPE,env=env,start_new_session=True) as process:
            try:stdout,stderr=process.communicate(timeout=timeout)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid,signal.SIGKILL);process.communicate()
                raise RuntimeError(f'{args[0]} {args[1]} timed out after {timeout:g}s')
    if process.returncode:
        detail=stderr.decode(errors='replace').strip()
        detail=re.sub(r'(https?://)[^/\s]*@',r'\1[redacted]@',detail)
        detail=re.sub(r'(https?://[^\s?]+)\?[^\s]+',r'\1?[redacted]',detail)
        raise RuntimeError(f'{args[0]} {args[1]} failed ({process.returncode}): {detail}')
    return stdout

def atomic(path, data):
    path.parent.mkdir(parents=True,exist_ok=True)
    fd,name=tempfile.mkstemp(prefix='.boundary-',dir=path.parent)
    try:
        with os.fdopen(fd,'wb') as stream:stream.write(data);stream.flush();os.fsync(stream.fileno())
        os.replace(name,path)
    finally:
        if os.path.exists(name):os.unlink(name)

def receipt(path, data):atomic(path,(json.dumps(data,indent=2)+'\n').encode())

def try_lock(lock):
    if os.name=='nt':
        lock.seek(0)
        try:msvcrt.locking(lock.fileno(),msvcrt.LK_NBLCK,1)
        except OSError as error:
            if error.errno in (errno.EACCES,errno.EAGAIN,errno.EDEADLK):raise BlockingIOError() from error
            raise
    else:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)

def unlock(lock):
    if os.name=='nt':
        lock.seek(0);msvcrt.locking(lock.fileno(),msvcrt.LK_UNLCK,1)
    else:fcntl.flock(lock,fcntl.LOCK_UN)

def refresh(boundary, timeout, lock_timeout):
    common=pathlib.Path(command(['git','rev-parse','--path-format=absolute','--git-common-dir']).decode().strip())
    state=common/'gauntlet-boundary';state.mkdir(exist_ok=True);current=state/'receipt.json'
    with (state/'refresh.lock').open('a+b') as lock:
        locked=False
        try:
            deadline=time.monotonic()+lock_timeout
            while not locked:
                try:try_lock(lock);locked=True
                except BlockingIOError:
                    if time.monotonic()>=deadline:raise RuntimeError('refresh lock busy; retry at next boundary')
                    time.sleep(0.05)
            previous=json.loads(current.read_text()) if current.exists() else {}
            last=previous if previous.get('status')=='fresh' else previous.get('last_success',{})
            command(['git','fetch','--no-tags','--no-recurse-submodules','origin','+'+INTEGRATION+':'+REF],timeout)
            sha=command(['git','rev-parse',REF]).decode().strip();cache=state/'policies'/sha
            contents={name:command(['git','show',sha+':'+name]) for name in FILES}
            info={}
            for name,data in contents.items():
                data.decode('utf-8') # Reject unreadable governance; never truncate full bytes.
                dest=cache/name
                if dest.exists() and dest.read_bytes()!=data:raise RuntimeError('immutable instruction cache mismatch: '+name)
                info[name]={'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data),'cache_path':str(dest)}
            for name,data in contents.items():atomic(cache/name,data)
            changed=[name for name in FILES if info[name]['sha256']!=last.get('files',{}).get(name,{}).get('sha256')]
            result={'status':'fresh','boundary':boundary,'observed_utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),'policy_sha':sha,'previous_sha':last.get('policy_sha'),'changed_files':changed,'files':info}
            receipt(current,result)
            print('Gauntlet policy '+sha+'; changed: '+(', '.join(changed) or 'none'),file=sys.stderr)
            for name in FILES:print('  '+name+': '+info[name]['cache_path'],file=sys.stderr)
            return result
        except (RuntimeError,OSError,ValueError) as error:
            previous=json.loads(current.read_text()) if current.exists() else {}
            last=previous if previous.get('status')=='fresh' else previous.get('last_success',{})
            receipt(current,{'status':'stale','boundary':boundary,'observed_utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),'policy_sha':None,'last_success':last,'error':str(error)})
            raise
        finally:
            if locked:unlock(lock)

def dispatch(path, policy):
    task=json.loads(pathlib.Path(path).read_text())
    if not isinstance(task,dict) or not isinstance(task.get('message'),str) or not task['message'].strip():raise ValueError('dispatch requires a JSON object with message')
    follow='target' in task
    allowed={'target','message'} if follow else {'task_name','message','model','reasoning_effort','fork_turns'}
    if set(task)-allowed or not isinstance(task.get('target' if follow else 'task_name'),str):raise ValueError('invalid followup_task/spawn_agent arguments')
    agents=pathlib.Path(policy['files']['AGENTS.md']['cache_path']).read_text(encoding='utf-8')
    match=re.search(r'^## Current execution contract[^\n]*\n(.*?)(?=^## |\Z)',agents,re.M|re.S)
    contract=agents[:match.end()].strip() if match else agents
    prefix='Current fetched policy SHA: '+policy['policy_sha']+'\n'+contract+'\n\nCached governing files (root reconciles the full set; worker reads USER_DIRECTIVES plus task-relevant guidance named in the brief):\n'
    prefix+='\n'.join(name+': '+policy['files'][name]['cache_path'] for name in FILES)
    prefix+='\nFor design or gameplay implementation, apply the relevant cached CURRENT_GAME_SPEC.md and V7_TO_GODOT_PARITY.md sections alongside source authority; historical specifications remain provenance. Inherit docs/AGENT_BRIEF.md and docs/SOURCE_AUTHORITY.md; current explicit user direction has priority. Imported originals remain immutable. Sol6.1 Medium is the substantial-work default; one implementation worker and one independent integration reviewer; record requested routing separately from unavailable backend/cost telemetry. Preserve assigned ownership and strongest verified baseline.\n\nAssigned task:\n'
    task['message']=prefix+task['message']
    if not follow:task.setdefault('model','gpt-6.1-sol');task.setdefault('reasoning_effort','medium');task.setdefault('fork_turns','none')
    return {'tool':'collaboration.followup_task' if follow else 'collaboration.spawn_agent','arguments':task}


def check_completion_guidance(policy):
    """Execute current canonical linter, even from an older active feature branch."""
    path='scripts/toolchain/check-gauntlet-guidance.py'
    try:
        script=command(['git','show',policy['policy_sha']+':'+path])
    except RuntimeError:
        # Older test fixtures and historical commits predate the linter.
        # Once current production mandates it, absence is a hard stale-governance failure.
        agents=pathlib.Path(policy['files']['AGENTS.md']['cache_path']).read_text(encoding='utf-8')
        if 'check-gauntlet-guidance.py' in agents:
            raise RuntimeError('required completion-time guidance checker missing from fetched production')
        print('Historical policy has no guidance checker; semantic closeout still required',file=sys.stderr)
        return
    p=subprocess.run([sys.executable,'-','--ref',policy['policy_sha']],
                     input=script,stdout=subprocess.PIPE,stderr=subprocess.PIPE,
                     timeout=30)
    if p.stdout:print(p.stdout.decode(errors='replace').rstrip(),file=sys.stderr)
    if p.stderr:print(p.stderr.decode(errors='replace').rstrip(),file=sys.stderr)
    if p.returncode:
        raise RuntimeError('guidance is stale at fetched production SHA; assign a repair branch and reviewer before next closeout')


def guard_push(policy, updates):
    for line in updates.splitlines():
        fields=line.split()
        if len(fields)!=4:raise ValueError('malformed pre-push update')
        local_ref,tip,remote_ref,old=fields
        if remote_ref not in (INTEGRATION,PRODUCTION):continue
        if set(tip)=={'0'}:raise ValueError('integration/production deletion refused')
        required=[('integration',policy['policy_sha'])]
        if remote_ref==PRODUCTION:
            command(['git','fetch','--no-tags','--no-recurse-submodules','origin','+'+PRODUCTION+':'+PRODUCTION_REF])
            required.append(('production',command(['git','rev-parse',PRODUCTION_REF]).decode().strip()))
        for role,sha in required:
            r=subprocess.run(['git','merge-base','--is-ancestor',sha,tip],capture_output=True,timeout=10)
            if r.returncode:raise ValueError('newly fetched '+role+' must be an ancestor of proposed pushed tip; reconcile before push')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--boundary',default='resume',choices=['complete','dispatch','review','merge','resume','post-commit','post-checkout','pre-merge-commit','pre-push'])
    parser.add_argument('--dispatch',metavar='TASK_JSON');parser.add_argument('--timeout',type=float,default=30);parser.add_argument('--lock-timeout',type=float,default=3)
    parser.add_argument('hook_args',nargs='*');args=parser.parse_args()
    try:
        if not 0<args.timeout<=60 or not 0<=args.lock_timeout<=10:raise ValueError('timeout must be (0,60], lock-timeout [0,10] seconds')
        policy=refresh(args.boundary,args.timeout,args.lock_timeout)
        if args.boundary=='complete':check_completion_guidance(policy)
        if args.boundary=='pre-push':guard_push(policy,sys.stdin.read())
        if args.dispatch:print(json.dumps(dispatch(args.dispatch,policy),indent=2))
        return 0
    except (RuntimeError,OSError,ValueError,subprocess.TimeoutExpired) as error:
        print('Gauntlet boundary failed; no fresh dispatch: '+str(error),file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
