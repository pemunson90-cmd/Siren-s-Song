#!/usr/bin/env python3
"""Exercise the real CLI with synthetic geometry; these are not native runtime claims."""
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest
import base64,hashlib

CHECKER = Path(__file__).with_name('android-ui-metrics.py')
def chunked(value,identity='42:1'):
    raw=json.dumps(value).encode();parts=[raw[i:i+450] for i in range(0,len(raw),450)]
    return '\n'.join(f'SS_UI_METRICS_PART id={identity} part={i} parts={len(parts)} bytes={len(raw)} sha256={hashlib.sha256(raw).hexdigest()} data={base64.b64encode(part).decode()}' for i,part in enumerate(parts))+'\n'


class TouchMetricsTests(unittest.TestCase):
    def invoke(self, payload, *, size=(2520, 1080), density='Physical density: 420\n', prefix='SS_SCREEN mission\n', suffix='', required='pause', page='primary', transport=None):
        with tempfile.TemporaryDirectory() as folder:
            folder = Path(folder)
            (folder / 'log').write_text(prefix + (transport if transport is not None else 'SS_UI_METRICS ' + json.dumps(payload) + '\n') + suffix)
            (folder / 'image.png').write_bytes(b'\x89PNG\r\n\x1a\n' + b'\0' * 8 + struct.pack('>II', *size))
            (folder / 'density').write_text(density)
            command = [sys.executable, str(CHECKER), str(folder / 'log'), str(folder / 'image.png'), '--density', str(folder / 'density'), '--screen', prefix.split('SS_SCREEN ', 1)[1].split()[0], '--orders-page', page]
            if required is not None:
                command += ['--required-actions', required]
            return subprocess.run(command, capture_output=True, text=True)

    def layout(self, *, logical_height=84, screen='mission'):
        return {'schema': 1, 'screen': screen, 'orders_page': 'primary', 'viewport': [1680, 720], 'window': [2520, 1080], 'safe_rect': [0, 0, 2520, 1080], 'density_dpi': 420, 'density_source': 'android_display_metrics_density_dpi', 'chart_rect': [0, 0, 800, 600], 'controls': [{'action': 'pause', 'visual_rect': [900, 100, 200, logical_height], 'hit_rect': [900, 100, 200, logical_height], 'clipped': False}]}

    def test_radial_page_contract_uses_actual_persistent_and_context_controls(self):
        pages = {
            'water': 'pause,focus,fit,more_orders',
            'craft': 'pause,radial_back,camera,ping,silent,program,route_menu,tools_menu,guard_menu,inspect',
            'tools': 'pause,radial_back,decoy,emp,recon,knock',
            'fleet': 'pause,radial_back,sub,droneA,droneB,menu',
            'signals': 'pause,radial_back',
        }
        for page, actions in pages.items():
            layout = self.layout()
            layout.update(hud_layout='radial', context_page=page, orders_page='primary' if page=='water' else 'secondary')
            layout['controls'] = [dict(layout['controls'][0], action=action, visual_rect=[20+i%5*230, 20+i//5*100, 200, 84], hit_rect=[20+i%5*230, 20+i//5*100, 200, 84]) for i, action in enumerate(actions.split(','))]
            result = self.invoke(layout, required=None, page=layout['orders_page'])
            self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
            layout['controls'].pop()
            self.assertEqual(self.invoke(layout, required=None, page=layout['orders_page']).returncode, 1)
        layout['context_page']='unknown'
        self.assertIn('Unknown radial', self.invoke(layout, required=None, page='secondary').stderr)

    def test_charted_corridor_and_withdrawal_context_do_not_require_camera(self):
        for kind in ['corridor', 'withdrawal']:
            layout=self.layout()
            layout.update(hud_layout='radial', context_page='object', context_subject_kind=kind, orders_page='secondary')
            actions='pause,radial_back,route_here,inspect,program,queue'.split(',')
            layout['controls']=[dict(layout['controls'][0], action=action, visual_rect=[20+i%5*230,20+i//5*100,200,84], hit_rect=[20+i%5*230,20+i//5*100,200,84]) for i,action in enumerate(actions)]
            result=self.invoke(layout,required=None,page='secondary')
            self.assertEqual(result.returncode,0,result.stderr+result.stdout)
            layout['controls'].pop()
            self.assertEqual(self.invoke(layout,required=None,page='secondary').returncode,1)

    def test_transmission_context_requires_explicit_action_without_fake_route_anchor(self):
        layout=self.layout()
        layout.update(hud_layout='radial',context_page='object',context_subject_kind='transmission',orders_page='secondary')
        actions='pause,radial_back,camera,inspect,program,queue'.split(',')
        layout['controls']=[dict(layout['controls'][0],action=action,visual_rect=[20+i%5*230,20+i//5*100,200,84],hit_rect=[20+i%5*230,20+i//5*100,200,84]) for i,action in enumerate(actions)]
        result=self.invoke(layout,required=None,page='secondary')
        self.assertEqual(result.returncode,0,result.stderr+result.stdout)
        layout['controls']=[control for control in layout['controls'] if control['action']!='camera']
        result=self.invoke(layout,required=None,page='secondary')
        self.assertEqual(result.returncode,1,result.stderr+result.stdout)
        self.assertIn('camera',result.stdout)

    def test_site_unknown_and_missing_context_kind_keep_camera_mandatory(self):
        for kind in ['site', 'unknown', None]:
            layout=self.layout()
            layout.update(hud_layout='radial',context_page='object',orders_page='secondary')
            if kind is not None:layout['context_subject_kind']=kind
            actions='pause,radial_back,route_here,inspect,program,queue'.split(',')
            layout['controls']=[dict(layout['controls'][0],action=action,visual_rect=[20+i%5*230,20+i//5*100,200,84],hit_rect=[20+i%5*230,20+i//5*100,200,84]) for i,action in enumerate(actions)]
            result=self.invoke(layout,required=None,page='secondary')
            self.assertEqual(result.returncode,1,result.stderr+result.stdout)
            self.assertIn('camera',result.stdout)
            layout['controls'].append(dict(layout['controls'][0],action='camera',visual_rect=[250,120,200,84],hit_rect=[250,120,200,84]))
            self.assertEqual(self.invoke(layout,required=None,page='secondary').returncode,0)

    def test_complete_chunked_geometry_uses_same_gate(self):
        value=self.layout();value['padding']='x'*5000
        result=self.invoke(value,transport=chunked(value));self.assertEqual(result.returncode,0,result.stderr)
        value['controls'][0]['hit_rect'][3]=48
        self.assertEqual(self.invoke(value,transport=chunked(value)).returncode,1)

    def test_incomplete_latest_chunk_cannot_reuse_old_geometry(self):
        value=self.layout();value['padding']='x'*2000
        incomplete='\n'.join(chunked(value,'42:2').splitlines()[:-1])+'\n'
        self.assertEqual(self.invoke(self.layout(),suffix=incomplete).returncode,2)

    def test_chunk_start_before_view_boundary_stays_stale(self):
        value=self.layout()
        self.assertEqual(self.invoke(value,transport=chunked(value)+'SS_VIEW changed\n').returncode,2)

    def test_retained_truncated_native_record_is_rejected(self):
        raw=(CHECKER.parent/'fixtures/truncated-native-ui-metrics.log').read_text()
        line=next(x for x in raw.splitlines() if 'I godot' in x and 'SS_UI_METRICS ' in x)
        self.assertEqual(len(line.split('SS_UI_METRICS ')[1]),1009)
        result=self.invoke(self.layout(),suffix=line+'\n')
        self.assertEqual(result.returncode,1);self.assertIn('Unterminated string',result.stderr)

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

    def test_accepts_actual_integer_inner_viewport_and_axis_scales(self):
        layout = self.layout(logical_height=74)
        layout.update(viewport=[1280, 1153], window=[2184, 1968], safe_rect=[0, 0, 2184, 1968])
        result = self.invoke(layout, size=(2184, 1968))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["canvas_scale"], [2184 / 1280, 1968 / 1153])

    def test_rejects_fabricated_fractional_viewport(self):
        layout = self.layout(logical_height=84)
        layout.update(viewport=[1280, 1968 / (2184 / 1280)], window=[2184, 1968], safe_rect=[0, 0, 2184, 1968])
        self.assertNotEqual(self.invoke(layout, size=(2184, 1968)).returncode, 0)

    def test_rejects_wrong_integer_quantization(self):
        for height in [1152, 1154]:
            layout = self.layout(logical_height=84)
            layout.update(viewport=[1280, height], window=[2184, 1968], safe_rect=[0, 0, 2184, 1968])
            self.assertNotEqual(self.invoke(layout, size=(2184, 1968)).returncode, 0)

    def test_accepts_exact_wider_axis_floor(self):
        layout = self.layout()
        layout.update(viewport=[1893, 720], window=[2840, 1080], safe_rect=[0, 0, 2840, 1080])
        self.assertEqual(self.invoke(layout, size=(2840, 1080)).returncode, 0)

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

    def test_native_cli_rejects_local_fixture_provenance(self):
        layout = self.layout(); layout["density_source"] = "test_android_density_fixture"
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_rejects_unknown_density_provenance(self):
        layout = self.layout(); layout['density_source'] = 'nominal_panel_ppi'
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_secondary_page_requires_its_explicit_full_action_set(self):
        layout = self.mission_page('secondary')
        result = self.invoke(layout, required=None, page='secondary')
        self.assertEqual(result.returncode, 0, result.stderr)
        layout['controls'] = [control for control in layout['controls'] if control['action'] != 'recon']
        self.assertNotEqual(self.invoke(layout, required=None, page='secondary').returncode, 0)

    def mission_page(self, page):
        actions = ('pause,sub,droneA,droneB,ping,camera,silent,queue,hold,emp,home,menu,more_orders,zoom_out,zoom_in,fit' if page == 'primary' else
                   'pause,sub,droneA,droneB,recon,decoy,contact_hold,wait_drone,waypoint_mode,program,knock,home,more_orders,zoom_out,zoom_in,fit').split(',')
        layout = self.layout(); layout['orders_page'] = page
        layout['controls'] = [{'action': action, 'visual_rect': [100 + (i % 4) * 220, 100 + (i // 4) * 100, 200, 84], 'hit_rect': [100 + (i % 4) * 220, 100 + (i // 4) * 100, 200, 84]} for i, action in enumerate(actions)]
        return layout

    def test_legacy_secondary_camera_emp_cannot_replace_new_tactical_controls(self):
        layout = self.mission_page('secondary')
        for control in layout['controls']:
            if control['action'] in ('program', 'knock'):
                control['action'] = {'program': 'camera', 'knock': 'emp'}[control['action']]
        result = self.invoke(layout, required=None, page='secondary')
        self.assertEqual(result.returncode, 1)
        self.assertIn('Missing required fully exposed control: program', result.stdout)
        self.assertIn('Missing required fully exposed control: knock', result.stdout)

    def test_secondary_tactical_controls_must_be_present_unclipped_and_48dp(self):
        for action in ('program', 'knock'):
            for defect in ('missing', 'clipped', 'small'):
                with self.subTest(action=action, defect=defect):
                    layout = self.mission_page('secondary')
                    control = next(c for c in layout['controls'] if c['action'] == action)
                    if defect == 'missing':
                        layout['controls'].remove(control)
                    else:
                        control['hit_rect'][3] = 48
                        control['clipped'] = defect == 'clipped'
                    result = self.invoke(layout, required=None, page='secondary')
                    self.assertEqual(result.returncode, 1)
                    errors = json.loads(result.stdout)['errors']
                    if defect == 'missing':
                        self.assertIn('Missing required fully exposed control: ' + action, errors)
                    else:
                        self.assertTrue(any(error.startswith(action + ':') for error in errors), errors)

    def test_primary_still_requires_camera_and_emp(self):
        self.assertEqual(self.invoke(self.mission_page('primary'), required=None).returncode, 0)
        for action in ('camera', 'emp'):
            with self.subTest(missing=action):
                layout = self.mission_page('primary')
                layout['controls'] = [c for c in layout['controls'] if c['action'] != action]
                result = self.invoke(layout, required=None)
                self.assertEqual(result.returncode, 1)
                self.assertIn('Missing required fully exposed control: ' + action, result.stdout)

    def test_cannot_use_wrong_page_snapshot(self):
        layout = self.layout(); layout['orders_page'] = 'secondary'
        self.assertNotEqual(self.invoke(layout).returncode, 0)

    def test_mission_cannot_hide_chart_fit_by_omitting_it(self):
        layout = self.layout(); layout['chart_rect'] = None
        self.assertNotEqual(self.invoke(layout).returncode, 0)


if __name__ == '__main__':
    unittest.main()
