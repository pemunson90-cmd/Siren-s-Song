import os, sys
R = [l.strip() for l in open('_scrap-20261111/_w/retire.txt') if l.strip()]
rs = set(R)
missing = [s for s in R if not os.path.exists('game/tests/%s.gd' % s)]
print("missing entry scripts:", missing)
out = {}
for base in ['game', 'scripts', '.github', 'docs', '.fable', 'project.godot']:
    paths = []
    if os.path.isfile(base):
        paths = [base]
    else:
        for d, _, fs in os.walk(base):
            for f in fs:
                paths.append(os.path.join(d, f))
    for p in paths:
        pn = p.replace(os.sep, '/')
        if pn.startswith('.fable/audit') or pn == 'game/tests/suites.txt':
            continue
        if pn.startswith('game/tests/') and os.path.basename(pn).split('.')[0] in rs:
            continue
        if pn.endswith(('.png', '.import', '.wav', '.ogg', '.jpg', '.apk', '.keystore')):
            continue
        try:
            t = open(p, encoding='utf8', errors='ignore').read()
        except Exception:
            continue
        for s in R:
            if s in t:
                out.setdefault(pn, []).append(s)
for p, v in sorted(out.items()):
    print(p, len(v), v[:6])
