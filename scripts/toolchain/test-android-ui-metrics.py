#!/usr/bin/env python3
"""Exercise the real CLI with synthetic geometry; these are not native runtime claims."""
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest

CHECKER = Path(__file__).with_name('android-ui-metrics.py')


class TouchMetricsTests(unittest.TestCase):
    def invoke(self, payload, *, size=(2520, 1080), density='Physical density: 420\n', prefix='SS_SCREEN mission\n', suffix='', required='pause', page='primary'):
        with tempfile.TemporaryDirectory() as folder:
            folder = Path(folder)
            (folder / 'log').write_text(prefix + 'SS_UI_METRICS ' + json.dumps(payload) + '\n' + suffix)
            (folder / 'image.png').write_bytes(b'\x89PNG\r\n\x1a\n' + b'\0' * 8 + struct.pack('>II', *size))
            (folder / 'density').write_text(density)
            command = [sys.executable, str(CHECKER), str(folder / 'log'), str(folder / 'image.png'), '--density', str(folder / 'density'), '--screen', prefix.split('SS_SCREEN ', 1)[1].split()[0], '--orders-page', page]
            if required is not None:
                command += ['--required-actions', required]
            return subprocess.run(command, capture_output=True, text=True)

    def layout(self, *, logical_height=84, screen='mission'):
        return {'schema': 1, 'screen': screen, 'orders_page': 'primary', 'viewport': [1680, 720], 'window': [2520, 1080], 'safe_rect': [0, 0, 2520, 1080], 'density_dpi': 420, 'density_source': 'android_display_metrics_density_dpi', 'chart_rect': [0, 0, 800, 600], 'controls': [{'action': 'pause', 'visual_rect': [900, 100, 200, logical_height], 'hit_rect': [900, 100, 200, logical_height], 'clipped': False}]}

    def test_accepts_actual_48dp_cover_hit_region(self):
        result = self.invoke(self.layout())
        self.assertEqual(result.returncode, 0, result.stderr)
        report = json.loads(result.stdout)
        self.assertTrue(report['gate_passed'])
        self.assertAlmostEqual(report['controls'][0]['hit_dp'][1], 48)

    def test_rejects_baseline_48logical_pixel_target(self):
        result = self.invoke(self.layout(logical_height=48))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('48 dp', result.stdout)

    def test_accepts_inner_fractional_canvas_scale(self):
        layout = self.layout(logical_height=74)
        layout.update(viewport=[1280, 1968 / (2184 / 1280)], window=[2184, 1968], safe_rect=[0, 0, 2184, 1968])
        self.assertEqual(self.invoke(layout, size=(2184, 1968)).returncode, 0)

    def test_uses_android_density_override_and_checks_agreement(self):
        self.assertEqual(self.invoke(self.layout(), density='Physical density: 560\nOverride density: 420\n').returncode, 0)
        result = self.invoke(self.layout(), density='Physical density: 560\n')
        self.assertNotEqual(result.returncode, 0)

    def test_rejects_layout_from_before_latest_view_change(self):
        self.assertNotEqual(self.invoke(self.layout(), suffix='SS_VIEW zoom=1 center=(800,480)\n').returncode, 0)

    def test_rejects_missing_required_control(self):
        self.assertNotEqual(self.invoke(self.layout(), required='pause,camera').returncode, 0)

    def test_rejects_screenshot_window_mismatch(self):
        self.assertNotEqual(self.invoke(self.layout(), size=(2184, 1968)).returncode, 0)

    def test_rejects_overlapping_hit_regions(self):
        layout = self.layout()
        layout['controls'].append({'action': 'camera', 'visual_rect': [950, 110, 200, 84], 'hit_rect': [950, 110, 200, 84]})
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_rejects_control_outside_actual_safe_area(self):
        layout = self.layout(); layout['safe_rect'] = [1700, 0, 820, 1080]
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_measures_clipped_menu_row_without_inventing_full_hit_size(self):
        layout = self.layout(screen='operations')
        layout['controls'][0]['action'] = 'mission0'
        layout['controls'][0]['clipped'] = True
        layout['controls'][0]['hit_rect'][3] = 20
        result = self.invoke(layout, prefix='SS_SCREEN operations\n', required='')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)['controls'][0]['size_exempt_clipped'])

    def test_cannot_exempt_clipped_required_or_hud_control(self):
        layout = self.layout(); layout['controls'][0].update(clipped=True, hit_rect=[900, 100, 200, 20])
        self.assertNotEqual(self.invoke(layout).returncode, 0)
        layout['screen'] = 'operations'
        self.assertNotEqual(self.invoke(layout, prefix='SS_SCREEN operations\n').returncode, 0)

    def test_cannot_exempt_full_rectangle_as_clipped(self):
        layout = self.layout(screen='operations'); layout['controls'][0]['clipped'] = True
        self.assertNotEqual(self.invoke(layout, prefix='SS_SCREEN operations\n', required='').returncode, 0)

    def test_uses_hit_rect_rather_than_larger_visual_rect(self):
        layout = self.layout(); layout['controls'][0]['hit_rect'][3] = 48
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_rejects_invalid_density_and_nonfinite_geometry(self):
        for key, value in [('density_dpi', 0), ('viewport', [float('nan'), 720])]:
            layout = self.layout(); layout[key] = value
            self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_rejects_snapshot_that_mislabels_current_screen(self):
        layout = self.layout(screen='operations')
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_rejects_unknown_density_provenance(self):
        layout = self.layout(); layout['density_source'] = 'nominal_panel_ppi'
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_secondary_page_requires_its_explicit_full_action_set(self):
        layout = self.layout(); layout['orders_page'] = 'secondary'
        actions = 'pause,sub,droneA,droneB,zoom_out,zoom_in,fit,more_orders,camera,emp,home,recon,decoy,contact_hold,wait_drone,waypoint_mode'.split(',')
        layout['controls'] = [{'action': action, 'visual_rect': [100 + (i % 4) * 220, 100 + (i // 4) * 100, 200, 84], 'hit_rect': [100 + (i % 4) * 220, 100 + (i // 4) * 100, 200, 84]} for i, action in enumerate(actions)]
        result = self.invoke(layout, required=None, page='secondary')
        self.assertEqual(result.returncode, 0, result.stderr)
        layout['controls'] = [control for control in layout['controls'] if control['action'] != 'recon']
        self.assertNotEqual(self.invoke(layout, required=None, page='secondary').returncode, 0)

    def test_cannot_use_wrong_page_snapshot(self):
        layout = self.layout(); layout['orders_page'] = 'secondary'
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_mission_cannot_hide_chart_fit_by_omitting_it(self):
        layout = self.layout(); layout['chart_rect'] = None
        self.assertNotEqual(self.invoke(layout).returncode, 0)


if __name__ == '__main__':
    unittest.main()
