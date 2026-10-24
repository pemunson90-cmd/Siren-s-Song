# 029 read-ahead only, no claim or implementation

027 is still CLAIMED, waiting on own exact-head hosted game-smoke. Do not start
029 code until027 publication/completion.029 is OPEN; precondition017 is DONE.
Branch requested: claude/lane-onboard2, fresh integration checkout after027.

Read handoff029 with cold-review F7 addendum. Existing OnboardingText.GOALS has
0..5; MAX_OPERATION4 controls first-play hints, not the unconditional goal lookup.
Do not extend hint behavior blindly. Add accurate GOAL/DANGER/NEW THIS DIVE data
for the requested later briefings, preserve old operation tables and photo modules.
Existing goal3..5 already supplies concise facts. Clarify indexing through actual
visible operation labels: addendum explicitly covers ids6..29 (display7..30).

CampaignFlow.briefing currently renders goal+photo line if goal exists, otherwise
full brief plus ExpeditionOperations.briefing. FIELD MANUAL currently contains
reference_text(brief) and special Blackwater orders only. Preserve all removed
expedition machinery/arrival/transfer/depth instructions in the manual by reusing
the existing emitter there, rather than deleting rules or duplicating an engine.

Fittings are currently initially expanded and existing fold_fit toggles them.
Use the existing fold machinery, default closed under the feature flag. Consider
transient open state across equipment-selection rebuilds so one selection does
not repeatedly hide the remaining controls. No new persistent state is needed.
Keep one narrow flow seam and table-owned off switch/revert note.

Before code: write plan, RED appropriate model/layout tests, verify exact factual
summaries from named operation briefs and existing machinery. Large-text cover/
inner captures of three representative operations must show the useful short
briefing above the fold; manual preserves full text, controls stay48dp and Back
works. Run import/core plus affected suites only, no full local list. Own exact
head hosted gate and independent integration review before merge. Publish claim
on handoffs before implementation; board and done029 together after actual merge.
