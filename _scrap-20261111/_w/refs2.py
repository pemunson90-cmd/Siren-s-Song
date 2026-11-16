import os, re
R = [l.strip() for l in open('_scrap-20261111/_w/retire.txt') if l.strip()]
rs = set(R)
hits = {}
for base in ['game', 'scripts', '.github']:
    for d, _, fs in os.walk(base):
        for f in fs:
            p = os.path.join(d, f)
            pn = p.replace(os.sep, '/')
            if not f.endswith(('.gd', '.tscn', '.tres', '.py', '.sh', '.ps1', '.yml', '.cfg')):
                continue
            if pn.startswith('game/tests/') and f[:-3] in rs:
                continue
            t = open(p, encoding='utf8', errors='ignore').read()
            for s in R:
                if re.search(r'(?<![A-Za-z0-9_])' + re.escape(s) + r'\.gd', t):
                    hits.setdefault(s, []).append(pn)
for s, v in sorted(hits.items()):
    print(s, v)
# also retired scripts referenced by other retired scripts is fine.
