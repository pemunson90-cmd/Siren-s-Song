export const meta = {
  name: 'siren-lane',
  description: 'Build one Siren\'s Song lane in its worktree: implement, preflight, PR, CI fix loop, merge',
  whenToUse: 'One Claude C-stream lane of Siren\'s Song; pass the lane config as args',
  phases: [
    { title: 'Implement', detail: 'sonnet builds the handoff in its worktree, local import/core/minimal suites, push' },
    { title: 'Preflight', detail: 'sonnet checks the diff against ownership, rules and registry before the PR' },
    { title: 'CI', detail: 'haiku watches hosted checks; sonnet fixes red or conflicted heads' },
    { title: 'Merge', detail: 'haiku merges the green exact head into claude/integration' },
  ],
}

const L = args
const CACHE = 'C:\\Users\\Archi\\.cache\\sirens-song-toolchain'
const COMMON = `You are working on Siren's Song, an Android-first 2D tactical submarine stealth and photographic reconnaissance game in Godot 4.6.3 / GDScript (Compatibility renderer). Project root is game/. GitHub repo pemunson90-cmd/Siren-s-Song.

WORKSPACE: work ONLY in the git worktree \`${L.worktree}\` on branch \`${L.branch}\`. Other agents (Codex and other Claude lanes) work in parallel in other worktrees; never open, edit or run Godot in any other directory. Never push to gauntlet/production or main, never force-push, never amend pushed commits, never delete branches.

READ ONLY what you need: docs/CONVENTIONS.md and docs/TESTING.md (short), the handoff text below, the MODULES.md rows for the systems you touch (git grep), and the source files you need found by targeted git grep. Do not scan the whole codebase or read old governance/history docs.

RULES (owner Pat, binding): finish the game, content first, minimal tests. One module per feature with a header naming its seam and a revert note, an enabled switch that restores prior behavior, tunable numbers in a data table, optional validated save fields (absent = old behavior), lines under 140 chars, match surrounding style. Touch-first: on-screen targets at least 48 dp, Android Back works, no hover-only paths. No em dashes in any text you add. Player-facing story text stays 1 to 2 line placeholders consistent with docs/STORY_BIBLE_DRAFT.md; no new plot. Never change beam lethality, the 4 s interruptible lock warning, collision/hull/damage rules, Siren sight/hearing/speed, enemy role senses, or photography design. Fair information only: the player sees only what they legitimately sensed or received. If a decision is genuinely the owner's (combat, detection, damage, story ending conditions, photography design), do not decide it: pick nothing, note it as a question.

TESTS (only what is necessary): import, core, plus a new suite only for a new save field/validator (round trip + corrupt reject), a new core operation, or outcome-deciding math. Never skip, loosen or delete a test; if an existing test asserts behavior you deliberately changed, update its expected value and say why.
Local commands (use the PowerShell tool, run from the worktree root; this lane's isolated folders keep concurrent runs apart):
  $env:ARTIFACT_DIR='${CACHE}\\artifacts\\${L.key}'; powershell -NoProfile -ExecutionPolicy Bypass -File scripts\\toolchain\\win\\headless.ps1 -Action Import -Isolate -UserDataRoot '${CACHE}\\isolated-${L.key}'
  same with -Action Core (must end CHECKS N FAILURES 0)
  same with -Action Script -Script <suite_name> -Prefix <PREFIX> for one suite
  registry check before every push: python -I scripts\\toolchain\\check-suites.py
Never run the full scenario list locally; the hosted game-smoke check is the gate.

SHARED FILES ARE INSERT-NEAR-RELATED, NOT APPEND-AT-END (so parallel lanes never collide): in game/tests/suites.txt insert your rows directly after ${L.anchor}; use local ranks ${L.ranksLocal} and CI ranks ${L.ranksCI}. In docs/MODULES.md and docs/RESUME.md insert your row/bullet next to the most related existing row/bullet, not at the end. In persistence/save_checks.gd register validators next to related ones. If CI registration in .github/workflows needs a line, insert it next to a related line.

GIT: git config user.email "272409536+pemunson90-cmd@users.noreply.github.com" (other emails are rejected). Commit messages end with a blank line then "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>". Push WIP at least every 30 minutes. Never commit untracked generated .uid files or .import line-ending churn (leave them unstaged).`

phase('Implement')
const IMPL_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['pushed', 'blocked'] },
    head: { type: 'string', description: 'last pushed commit SHA' },
    summary: { type: 'string', description: '5-8 plain bullets of what was built' },
    tunables: { type: 'string', description: 'AI-DESIGNED numbers/choices the owner may tune' },
    outside_ownership: { type: 'string' },
    questions: { type: 'string', description: 'owner decisions left undecided, or empty' },
    suites: { type: 'string', description: 'new suites name|PREFIX and local results' },
  },
  required: ['status', 'head', 'summary'],
}
const impl = await agent(`${COMMON}

YOUR TASK (lane ${L.key}): build these handoffs from branch codex/handoffs: ${L.handoffs.join(', ')}. Read each with: git fetch origin codex/handoffs; git show origin/codex/handoffs:docs/codex/<file>. They are already CLAIMED by Claude for you; do not edit codex/handoffs.

Lane notes from the orchestrator (these refine the handoffs):
${L.notes}

Files you may edit: ${L.files}
Files you must not touch: ${L.avoid}

First merge fresh origin/claude/integration into your branch (git fetch origin claude/integration; git merge origin/claude/integration). Build the whole task, run the local checks above, commit and push to origin ${L.branch}. Do NOT open a pull request; the next stage does. Return the structured result.`, { label: `impl:${L.key}`, phase: 'Implement', model: 'sonnet', effort: 'medium', schema: IMPL_SCHEMA })

if (!impl || impl.status !== 'pushed') {
  return { lane: L.key, stage: 'implement', result: impl }
}

phase('Preflight')
const PRE_SCHEMA = {
  type: 'object',
  properties: {
    blocking: { type: 'array', items: { type: 'string' }, description: 'issues that would break CI, the game, saves, ownership or protected rules; empty if none' },
    minor: { type: 'array', items: { type: 'string' } },
  },
  required: ['blocking'],
}
const pre = await agent(`Read-only preflight of a pushed branch before its pull request. Repo worktree: \`${L.worktree}\` (do not edit anything; do not run Godot). Run: git fetch origin claude/integration ${L.branch}; git diff origin/claude/integration...origin/${L.branch} (and --stat).

Check ONLY for things that would actually break: (1) GDScript errors you can see (undefined names, wrong signatures vs the callee's definition, typos in preload paths, tabs/spaces mixing in an indented block), (2) a save field added without a validator or that would make old saves fail to load, (3) edits outside the allowed files [${L.files}] beyond tiny registration lines, (4) any change to protected rules (beam, 4 s lock warning, collision/hull/damage, Siren senses, photography design), (5) suites.txt rows not matching name|PREFIX|local|CI, rank collisions (run python -I scripts\\toolchain\\check-suites.py from the worktree), a new *_tests.gd not registered, (6) committed .uid or .import churn, (7) em dashes in added player-facing text. Ignore style preferences. Return blocking issues with file:line and the fix, and minor ones separately.`, { label: `preflight:${L.key}`, phase: 'Preflight', model: 'sonnet', effort: 'medium', schema: PRE_SCHEMA })

const FIX_SCHEMA = {
  type: 'object',
  properties: { pushed: { type: 'boolean' }, head: { type: 'string' }, what: { type: 'string' } },
  required: ['pushed', 'head', 'what'],
}
let head = impl.head
if (pre && pre.blocking && pre.blocking.length) {
  const fx = await agent(`${COMMON}

Fix these preflight findings on your branch (verify each first; fix only the real ones), rerun the affected local checks, commit and push:
${pre.blocking.map((b, i) => `${i + 1}. ${b}`).join('\n')}`, { label: `prefix:${L.key}`, phase: 'Preflight', model: 'sonnet', effort: 'medium', schema: FIX_SCHEMA })
  if (fx && fx.head) head = fx.head
}

const PR_SCHEMA = { type: 'object', properties: { pr: { type: 'number' }, url: { type: 'string' } }, required: ['pr'] }
const pr = await agent(`In \`${L.worktree}\` run: gh pr list --head ${L.branch} --state open --json number,url. If a PR exists return it. Otherwise create one: gh pr create --base claude/integration --head ${L.branch} --title "${L.title}" --body "<body>" where the body is 3-6 plain lines summarizing this (do not invent results):
${impl.summary}
and ends with a blank line then "🤖 Generated with [Claude Code](https://claude.com/claude-code)". Return the PR number and url.`, { label: `pr:${L.key}`, phase: 'Preflight', model: 'haiku', effort: 'low', schema: PR_SCHEMA })
if (!pr || !pr.pr) return { lane: L.key, stage: 'pr', impl, pre }

phase('CI')
const CI_SCHEMA = {
  type: 'object',
  properties: {
    state: { type: 'string', enum: ['green', 'red', 'conflict', 'timeout', 'error'] },
    head: { type: 'string' },
    failing_check: { type: 'string' },
    log_excerpt: { type: 'string', description: 'up to ~3000 chars: failing suite name, FAIL lines, script errors' },
  },
  required: ['state', 'head'],
}
let rounds = 0, last = null, merged = false
while (rounds < 6) {
  rounds++
  last = await agent(`Watch the hosted checks of PR #${pr.pr} in repo pemunson90-cmd/Siren-s-Song until they finish, then report. Use the Bash tool from \`${L.worktree}\`.
1. gh pr view ${pr.pr} --json headRefOid,mergeable,mergeStateStatus . If mergeable is CONFLICTING return state "conflict" with the head.
2. Wait until no check is pending on the current head, using foreground loops of at most 9 minutes each, for example: until s=$(gh pr checks ${pr.pr} 2>/dev/null) && [ -n "$s" ] && ! echo "$s" | grep -qE "pending|queued|in_progress"; do sleep 45; done; echo "$s"   (call it with timeout 560000 and repeat the call until finished; game-smoke takes about 60-75 minutes; give up after 150 minutes total and return "timeout").
3. Re-read headRefOid; if it changed while waiting, start over at step 2 for the new head.
4. If guidance and game-smoke both pass: return state "green" with the head.
5. If one failed: find the run id from the check URL, run gh run view <run-id> --log-failed | tail -n 250, and return state "red" with failing_check and a log_excerpt containing the failing suite name, FAIL lines and any SCRIPT ERROR / ERROR lines.
Do not modify anything.`, { label: `ci:${L.key}#${rounds}`, phase: 'CI', model: 'haiku', effort: 'low', schema: CI_SCHEMA })
  if (!last) break
  if (last.state === 'green') {
    const m = await agent(`Merge PR #${pr.pr} in pemunson90-cmd/Siren-s-Song (from \`${L.worktree}\`, Bash). First: gh pr view ${pr.pr} --json headRefOid,mergeable,state . Only if headRefOid equals ${last.head} and mergeable is MERGEABLE: gh pr merge ${pr.pr} --merge . Then confirm with gh pr view ${pr.pr} --json state,mergeCommit . Return merged true/false, the merge commit SHA, and if not merged, why.`, { label: `merge:${L.key}`, phase: 'Merge', model: 'haiku', effort: 'low', schema: { type: 'object', properties: { merged: { type: 'boolean' }, merge_commit: { type: 'string' }, why: { type: 'string' } }, required: ['merged'] } })
    if (m && m.merged) { merged = m.merge_commit || true; break }
    if (m && m.why && /conflict|CONFLICT|behind|head/i.test(m.why)) continue
    break
  }
  if (last.state === 'timeout' || last.state === 'error') break
  const task = last.state === 'conflict'
    ? `Your PR #${pr.pr} conflicts with claude/integration. git fetch origin claude/integration; git merge origin/claude/integration; resolve conflicts keeping BOTH sides for shared registration files (suites.txt rows, MODULES/RESUME rows, validator registrations, workflow lines), and keeping the other side's content intact elsewhere while preserving your feature. Run import + core + your suites locally, python -I scripts\\toolchain\\check-suites.py, commit the merge and push.`
    : `Hosted check "${last.failing_check}" FAILED on head ${last.head} of PR #${pr.pr}. Log excerpt:\n${last.log_excerpt}\n\nFind the root cause (reproduce the failing suite locally with the Script action if possible). Fix the cause in your code; never loosen, skip or delete a test (if a test asserts behavior you deliberately changed, update only its expected value and say why). If the failure is clearly in code your branch does not touch and also fails on claude/integration, say so and change nothing. Rerun the failing suite + core locally, commit, push.`
  const fx = await agent(`${COMMON}\n\n${task}`, { label: `fix:${L.key}#${rounds}`, phase: 'CI', model: 'sonnet', effort: 'medium', schema: FIX_SCHEMA })
  if (!fx || !fx.pushed) { last = { ...last, fix: fx }; break }
}

return { lane: L.key, pr: pr.pr, merged, rounds, ci: last, summary: impl.summary, tunables: impl.tunables || '', questions: impl.questions || '', outside: impl.outside_ownership || '', suites: impl.suites || '', preflight_minor: (pre && pre.minor) || [] }
