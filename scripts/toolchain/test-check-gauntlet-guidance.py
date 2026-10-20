#!/usr/bin/env python3
"""Fast guidance checker regression tests; no network/working-tree mutation."""
import importlib.util
import pathlib
import unittest

CHECKER = pathlib.Path(__file__).with_name("check-gauntlet-guidance.py")
spec = importlib.util.spec_from_file_location("guidance_checker", CHECKER)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class GuidanceTests(unittest.TestCase):
    def make_docs(self, active):
        d = {p: "Historical handoff; user alone; gauntlet/production; current next task; "
             "staleness; task closeout; next highest-value; bible; CURRENT_GAME_SPEC.md; "
             "likely candidate; Quietus; Sirens" for p in module.FILES}
        d["README.md"] = "Active game development on gauntlet/production"
        if not active:
            for name in (
                "docs/CURRENT_GAME_SPEC.md", "docs/CONTINUATION.md",
                "docs/WORKBENCH.md", "docs/GAUNTLET_ORCHESTRATION.md",
            ):
                d.pop(name)
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

    def test_stale_readme_rejected(self):
        d = self.make_docs(True)
        d["README.md"] = "Status: Preproduction and source import. Engine selection pending."
        self.assertTrue(any("README" in e for e in self.scan(d)))

    def test_missing_user_directives_rejected(self):
        d = self.make_docs(True)
        d.pop("docs/USER_DIRECTIVES.md")
        self.assertTrue(any("USER_DIRECTIVES" in e for e in self.scan(d)))

    def test_missing_design_handoff_rejected(self):
        d = self.make_docs(True)
        d.pop("references/package/START_HERE.md")
        self.assertTrue(any("references/package/START_HERE.md" in e for e in self.scan(d)))

    def test_missing_continuation_rejected(self):
        d = self.make_docs(True)
        d.pop("docs/CONTINUATION.md")
        self.assertTrue(any("CONTINUATION" in e for e in self.scan(d)))

    def test_missing_living_spec_cannot_disguise_production(self):
        d = self.make_docs(True)
        d.pop("docs/CURRENT_GAME_SPEC.md")
        self.assertTrue(any("CURRENT_GAME_SPEC.md" in e for e in self.scan(d)))

    def test_completion_rule_rejected(self):
        d = self.make_docs(True)
        d["AGENTS.md"] = "Only the user can terminate; gauntlet/production"
        errors = self.scan(d)
        self.assertTrue(any("task-closeout" in e for e in errors))
        self.assertTrue(any("staleness" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
