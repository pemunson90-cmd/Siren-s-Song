#!/usr/bin/env python3
"""Fast guidance checker regression tests; no network/working-tree mutation."""
import importlib.util
import pathlib
import unittest

CHECKER = pathlib.Path(__file__).with_name("check-gauntlet-guidance.py")
spec = importlib.util.spec_from_file_location("guidance_checker", CHECKER)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

AGENTS = (
    "## Non-negotiable feature continuity (owner directive)\n"
    "**If Pat did not explicitly authorize removing a working capability, it stays.**\n"
    "Removal rule: nothing is deleted. The user alone ends the Gauntlet. "
    "claude/integration; gauntlet/production; docs/STATUS.md; docs/USER_DIRECTIVES.md; "
    "task closeout; stale guidance; next highest-value; a chartered run follows its charter; "
    "one independent reviewer per change."
)
BASE = {
    "AGENTS.md": AGENTS,
    "CLAUDE.md": "@AGENTS.md\n",
    "README.md": "Siren's Song. AGENTS.md; docs/STATUS.md; claude/integration; gauntlet/production",
    "docs/STATUS.md": "Base: claude/integration.\n## Next action\nFinish the run.",
    "docs/WORKFLOW.md": "claude/integration; one independent reviewer; once per head.",
    "docs/USER_DIRECTIVES.md": "# Rulings copied from codex/handoffs\nyou can build the apk",
    "docs/GOVERNANCE_MIGRATION.md": "| rule | KEPT |",
    "docs/SOURCE_AUTHORITY.md": "CURRENT_GAME_SPEC.md and the design bible",
    "docs/CURRENT_GAME_SPEC.md": "The user alone may stop it.",
    "docs/V7_TO_GODOT_PARITY.md": "ledger",
    "design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md": "bible",
    "references/visual/SIRENS_SONG_VISUAL_EXPLORATION_PLAN_V3_HANDOFF.md": "Historical planning snapshot",
    "references/package/SIRENS_SONG_CONCEPT_SELECTION_LEDGER.md": "very likely candidate",
    "references/package/START_HERE.md": "Quietus and the Sirens",
}


class GuidanceTests(unittest.TestCase):
    def make_docs(self, active=True):
        self.assertEqual(set(BASE), set(module.FILES))
        d = dict(BASE)
        if not active:
            for name in module.ACTIVE_MARKERS + ("CLAUDE.md", "docs/GOVERNANCE_MIGRATION.md"):
                d.pop(name)
            d["AGENTS.md"] = "Only the user ends it; gauntlet/production"
            d["README.md"] = "Baseline; gauntlet/production"
        return d

    def scan(self, d):
        def read(p):
            if p not in d:
                raise FileNotFoundError(p)
            return d[p]
        return module.scan(read)

    def test_active_minimum_contract(self):
        self.assertEqual(self.scan(self.make_docs(True)), [])

    def test_default_branch_redirect(self):
        self.assertEqual(self.scan(self.make_docs(False)), [])

    def test_active_entry_cannot_point_only_to_frozen_production(self):
        d = self.make_docs()
        d["README.md"] = "Active production: gauntlet/production; docs/STATUS.md; AGENTS.md"
        self.assertTrue(any("README.md" in e and "integration" in e for e in self.scan(d)))

    def test_missing_status_rejected(self):
        d = self.make_docs()
        d.pop("docs/STATUS.md")
        self.assertTrue(any("STATUS.md" in e for e in self.scan(d)))

    def test_status_must_name_a_next_action_and_stay_short(self):
        d = self.make_docs()
        d["docs/STATUS.md"] = "claude/integration\n" + "line\n" * 200
        errors = self.scan(d)
        self.assertTrue(any("next action" in e for e in errors))
        self.assertTrue(any("stays short" in e for e in errors))

    def test_stale_readme_rejected(self):
        d = self.make_docs()
        d["README.md"] = "Status: Preproduction and source import. Engine selection pending."
        self.assertTrue(any("README" in e for e in self.scan(d)))

    def test_missing_user_directives_rejected(self):
        d = self.make_docs()
        d.pop("docs/USER_DIRECTIVES.md")
        self.assertTrue(any("USER_DIRECTIVES" in e for e in self.scan(d)))

    def test_rulings_must_be_consolidated(self):
        d = self.make_docs()
        d["docs/USER_DIRECTIVES.md"] = "Older rulings only."
        errors = self.scan(d)
        self.assertTrue(any("consolidated rulings" in e for e in errors))
        self.assertTrue(any("debug-package ruling" in e for e in errors))

    def test_missing_design_handoff_rejected(self):
        d = self.make_docs()
        d.pop("references/package/START_HERE.md")
        self.assertTrue(any("references/package/START_HERE.md" in e for e in self.scan(d)))

    def test_missing_workflow_rejected(self):
        d = self.make_docs()
        d.pop("docs/WORKFLOW.md")
        self.assertTrue(any("WORKFLOW" in e for e in self.scan(d)))

    def test_missing_living_spec_cannot_disguise_production(self):
        d = self.make_docs()
        d.pop("docs/CURRENT_GAME_SPEC.md")
        self.assertTrue(any("CURRENT_GAME_SPEC.md" in e for e in self.scan(d)))

    def test_completion_rule_rejected(self):
        d = self.make_docs()
        d["AGENTS.md"] = "Only the user can terminate; gauntlet/production"
        errors = self.scan(d)
        self.assertTrue(any("task-closeout" in e for e in errors))
        self.assertTrue(any("staleness" in e for e in errors))

    def test_feature_continuity_directive_cannot_be_dropped(self):
        d = self.make_docs()
        d["AGENTS.md"] = AGENTS.replace("If Pat did not explicitly authorize removing a working capability, it stays.", "Keep features.")
        self.assertTrue(any("feature-continuity directive text" in e for e in self.scan(d)))

    def test_removal_rule_and_charter_stop_required(self):
        d = self.make_docs()
        d["AGENTS.md"] = AGENTS.replace("nothing is deleted", "tidy up").replace("charter", "plan")
        errors = self.scan(d)
        self.assertTrue(any("removal rule" in e for e in errors))
        self.assertTrue(any("chartered-run" in e for e in errors))

    def test_claude_file_must_import_agents(self):
        d = self.make_docs()
        d["CLAUDE.md"] = "## A second copy of the rules\n"
        self.assertTrue(any("CLAUDE.md" in e for e in self.scan(d)))

    def test_retired_pointer_documents_cannot_return(self):
        d = self.make_docs()
        d["README.md"] += "; see docs/RESUME.md"
        d["docs/WORKFLOW.md"] += " Read GAUNTLET_ORCHESTRATION.md."
        errors = self.scan(d)
        self.assertTrue(any("README.md" in e and "RESUME.md" in e for e in errors))
        self.assertTrue(any("WORKFLOW.md" in e and "GAUNTLET_ORCHESTRATION.md" in e for e in errors))

    def test_package_start_here_is_not_the_retired_entry_page(self):
        d = self.make_docs()
        d["README.md"] += "; references/package/START_HERE.md"
        self.assertEqual(self.scan(d), [])

    def test_superseded_stop_banner_and_apk_ban_rejected(self):
        d = self.make_docs()
        d["docs/SOURCE_AUTHORITY.md"] += " Observe Pat's cloud stop."
        d["AGENTS.md"] += " Current Pat rules prohibit APK builds."
        errors = self.scan(d)
        self.assertTrue(any("SOURCE_AUTHORITY" in e and "superseded" in e for e in errors))
        self.assertTrue(any("AGENTS.md" in e and "superseded" in e for e in errors))

    def test_specification_may_keep_its_old_sentence_only_with_the_supersession_note(self):
        d = self.make_docs()
        d["docs/CURRENT_GAME_SPEC.md"] += " Current Pat rules prohibit APK builds."
        self.assertTrue(any("CURRENT_GAME_SPEC" in e and "superseded" in e for e in self.scan(d)))
        d["docs/CURRENT_GAME_SPEC.md"] += " [Superseded 1 November 2026: debug builds allowed.]"
        self.assertEqual(self.scan(d), [])

if __name__ == "__main__":
    unittest.main()
