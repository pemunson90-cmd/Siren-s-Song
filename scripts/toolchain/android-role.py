#!/usr/bin/env python3
"""Check observed native hunter response; this never writes gameplay state."""
import argparse,json,math,re
from pathlib import Path
NUMBER=r'-?\d+(?:\.\d+)?'
PAIR=rf'({NUMBER}),({NUMBER})'
PATTERN=re.compile(rf'SS_ROLE mission=4 index=1 type=hunter mode=(\w+) pos={PAIR} home={PAIR} target=(-?\d+) lock=({NUMBER}) time=({NUMBER})')
def evaluate(text):
 rows=[]
 for match in PATTERN.finditer(text):
  mode,x,y,hx,hy,target,lock,time=match.groups()
  rows.append(dict(mode=mode,pos=(float(x),float(y)),home=(float(hx),float(hy)),target=int(target),lock=float(lock),time=float(time)))
 if not rows:raise ValueError('No matching actual Well hunter observations')
 def distance(row):return math.dist(row['pos'],row['home'])
 first=rows[0]
 if first['time']>0.1 or first['mode'] not in ('PATROL','DORMANT') or distance(first)>0.1:raise ValueError('Fixture did not enter a fresh hunter at its authored home')
 if any(r['home']!=first['home'] or r['target']!=-1 or r['lock']!=0 for r in rows):raise ValueError('Hunter home changed or visual contact occurred during the noise-only path')
 if any(b['time']<a['time'] for a,b in zip(rows,rows[1:])):raise ValueError('Hunter observation times are not monotonic')
 modes=[r['mode'] for r in rows]
 if 'INVESTIGATE' not in modes or 'SEARCH' not in modes or 'RETURN' not in modes:raise ValueError('Actual investigation/search/return transitions missing')
 investigation=modes.index('INVESTIGATE')
 search=modes.index('SEARCH',investigation+1)
 returning=modes.index('RETURN',search+1)
 if returning>=len(rows)-1:raise ValueError('No final home arrival after return')
 maximum=max(map(distance,rows))
 if maximum<=190:raise ValueError('No observed physical hunter excursion beyond 190 world units')
 final=rows[-1]
 if final['mode']!='DORMANT' or distance(final)>=15 or final['time']>65:raise ValueError('Bounded physical home return not observed')
 return {'mission':4,'hunter':1,'entry':'fixture-assisted fresh dive','observations':len(rows),'max_observed_home_distance':maximum,'return_simulated_time':final['time'],'final_home_error':distance(final),'modes':modes}
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('log',type=Path);args=parser.parse_args()
 try:print(json.dumps(evaluate(args.log.read_text()),indent=2))
 except ValueError as error:parser.exit(1,str(error)+'\n')
if __name__=='__main__':main()
