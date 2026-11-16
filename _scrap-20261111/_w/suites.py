R = set(l.strip() for l in open('_scrap-20261111/_w/retire.txt') if l.strip())
keep, gone = [], []
for line in open('game/tests/suites.txt', encoding='utf8', newline='').read().split('\n'):
    name = line.split('|')[0].strip()
    if name in R:
        gone.append(line)
    else:
        keep.append(line)
open('game/tests/suites.txt', 'w', encoding='utf8', newline='').write('\n'.join(keep))
hdr = ("# Retired suites. Pat's ruling of 15 Nov 2026 (docs/USER_DIRECTIVES.md): tests must justify their existence; the only test that matters is that the APK runs and the game works.\n"
       "# Classification: .fable/audit/suite_classification_20261115.tsv. Entry scripts moved to _scrap-20261111/retired-tests/ (six stay in game/tests/ because a kept suite or tool still loads them).\n"
       "# Format as in suites.txt: name|PREFIX|local rank|ci rank[|render]\n")
open('game/tests/retired_suites.txt', 'w', encoding='utf8', newline='').write(hdr + '\n'.join(gone) + '\n')
print(len(gone), len(keep))
missing = R - set(l.split('|')[0] for l in gone)
print('not found in suites.txt:', sorted(missing))
