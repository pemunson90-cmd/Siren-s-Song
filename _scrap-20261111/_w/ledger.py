import re, json
R = set(l.strip() for l in open('_scrap-20261111/_w/retire.txt') if l.strip())
MOVED = R - {'fix2_menu_ui_tests', 'status_text_ui_tests', 'density_scenarios', 'density_menu_scenarios',
             'density_scroll_scenarios', 'metrics_transport_tests'}
PHRASE = 'no game-play test (retired 15 Nov, Pat\'s rule)'
P = '.fable/PROTECTED_CAPABILITIES.md'
lines = open(P, encoding='utf8', newline='').read().split('\n')
changes = []
for i, raw in enumerate(lines):
    eol = ''
    line = raw
    if line.endswith('\r'):
        eol = '\r'
        line = line[:-1]
    if not re.match(r"^\|\s*[A-Z0-9]+-[A-Z0-9-]+\s*\|", line):
        continue
    parts = line.split('|')
    # parts[0] = '' ; parts[1]=ID ; [2]=cap ; [3]=where ; [4]=verify
    if len(parts) < 6:
        continue
    rid = parts[1].strip()
    # where-it-lives: repoint moved scripts
    where = parts[3]
    new_where = where
    for s in MOVED:
        new_where = new_where.replace('`game/tests/%s.gd`' % s, '`_scrap-20261111/retired-tests/%s.gd`' % s)
    verify = parts[4]
    toks = re.findall(r"`([a-z0-9_]+)`", verify)
    new_verify = verify
    if any(t in R for t in toks):
        for t in toks:
            if t in R:
                new_verify = re.sub(r"`%s`(?: \(render\))*" % t, '', new_verify)
        new_verify = re.sub(r"\(and the other twelve `photo_row_\*_journey_tests` suites\)", '', new_verify)
        new_verify = re.sub(r"\s+", ' ', new_verify)
        new_verify = re.sub(r"(\s*,\s*)+(?=,|\.|$)", '', new_verify)
        new_verify = re.sub(r"^\s*(\(render\)\s*,?\s*)+", ' ', new_verify)
        new_verify = re.sub(r"^\s*,\s*", ' ', new_verify)
        new_verify = re.sub(r",\s*\(render\)", '', new_verify)
        remaining = re.findall(r"`([a-z0-9_]+)`", new_verify)
        if not remaining:
            new_verify = ' ' + PHRASE + ' '
        new_verify = new_verify.rstrip() + ' '
        if not new_verify.startswith(' '):
            new_verify = ' ' + new_verify
    if new_verify != verify or new_where != where:
        parts[3] = new_where
        parts[4] = new_verify
        changes.append((rid, verify.strip(), new_verify.strip(), where != new_where))
        lines[i] = '|'.join(parts) + eol
open(P, 'w', encoding='utf8', newline='').write('\n'.join(lines))
json.dump(changes, open('_scrap-20261111/_w/ledger_changes.json', 'w'), indent=1)
print(len(changes))
