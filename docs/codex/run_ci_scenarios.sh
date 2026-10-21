#!/bin/bash
# Runs every game scenario that GitHub's game-smoke check runs. Run from the repo root.
# Each line prints ok, FAIL or ERR. Every line must be ok before you push.
export PATH=$HOME/.cache/sirens-song-toolchain/bin:$PATH
list=$(mktemp)
grep -E '^ +[a-z_0-9]+\|[A-Z0-9 ]+$' .github/workflows/gauntlet-pr-checks.yml | sed 's/^ *//' > "$list"
bad=0
while IFS='|' read -r s sum; do
  log=$(mktemp)
  timeout --kill-after=10s 480s scripts/toolchain/headless.sh --script "res://tests/$s.gd" > "$log" 2>&1
  if grep -qE 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$log"; then echo "ERR   $s"; grep -E 'SCRIPT ERROR:|ERROR:' "$log" | head -2; bad=1
  elif grep -Eq "^$sum CHECKS [1-9][0-9]* FAILURES 0$" "$log"; then echo "ok    $s"
  else echo "FAIL  $s: $(grep -E 'CHECKS' "$log" | tail -1)"; grep '^FAIL' "$log" | head -3; bad=1; fi
done < "$list"
[ $bad = 0 ] && echo "ALL SCENARIOS OK" || echo "SOME SCENARIOS FAILED"
exit $bad
