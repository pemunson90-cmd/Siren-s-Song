#!/usr/bin/env python3
"""Guard the native navigation evidence checker against false passes."""
import pathlib
import subprocess
import struct
import sys
import tempfile
import unittest

CHECKER = pathlib.Path(__file__).with_name("android-view.py")


class ViewEvidenceTests(unittest.TestCase):
    def check_log(self, text, *args, before=None):
        with tempfile.TemporaryDirectory() as directory:
            log = pathlib.Path(directory) / "after.txt"
            log.write_text(text)
            command = [sys.executable, str(CHECKER), str(log), *args]
            if before is not None:
                prior = pathlib.Path(directory) / "before.txt"
                prior.write_text(before)
                command += ["--panned-from", str(prior)]
            return subprocess.run(command, capture_output=True, text=True)

    def test_accepts_current_numeric_zoom(self):
        result = self.check_log("SS_SCREEN mission\nSS_VIEW zoom=1.4 center=(800, 480)\n", "--zoom", "1.4")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_rejects_stale_view_from_previous_screen(self):
        result = self.check_log("SS_VIEW zoom=1.4 center=(800, 480)\nSS_SCREEN mission\n", "--zoom", "1.4")
        self.assertNotEqual(result.returncode, 0)

    def test_rejects_wrong_zoom_despite_fresh_view_marker(self):
        result = self.check_log("SS_VIEW zoom=1.0 center=(800, 480)\n", "--zoom", "1.4")
        self.assertNotEqual(result.returncode, 0)

    def test_rejects_pan_marker_without_center_change(self):
        text = "SS_VIEW zoom=1.96 center=(800, 480)\n"
        self.assertNotEqual(self.check_log(text, "--zoom", "1.96", before=text).returncode, 0)

    def test_accepts_actual_pan_toward_higher_world_x(self):
        result = self.check_log("SS_VIEW zoom=1.96 center=(920.5, 480)\n", "--zoom", "1.96", before="SS_VIEW zoom=1.96 center=(800, 480)\n")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_rejects_fit_with_shifted_world_center(self):
        result = self.check_log("SS_VIEW zoom=1.0 center=(900, 480)\n", "--zoom", "1", "--center", "800", "480")
        self.assertNotEqual(result.returncode, 0)

    def target_result(self, text):
        with tempfile.TemporaryDirectory() as directory:
            log = pathlib.Path(directory) / "target.txt"
            image = pathlib.Path(directory) / "dimensions.png"
            log.write_text(text)
            image.write_bytes(b"\x89PNG\r\n\x1a\n" + b"\0" * 8 + struct.pack(">II", 1280, 720))
            return subprocess.run([sys.executable, str(CHECKER.with_name("android-target.py")), str(log), str(image), "route"], capture_output=True, text=True)

    def test_rejects_target_from_before_latest_view_change(self):
        result = self.target_result("SS_TARGET route center=100,100 viewport=1280,720\nSS_VIEW zoom=1.4 center=(800, 480)\n")
        self.assertEqual(result.returncode, 2)

    def test_accepts_target_reported_after_view_change(self):
        result = self.target_result("SS_VIEW zoom=1.4 center=(800, 480)\nSS_TARGET route center=100,100 viewport=1280,720\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "100 100")


if __name__ == "__main__":
    unittest.main()
