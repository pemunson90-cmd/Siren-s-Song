#!/usr/bin/env python3
"""Exercise signing configuration in disposable trees; never generate keys or run Godot."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent
CERTIFICATE = '32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c'
KEY_NAME = 'sirens-song-debug.keystore'
FINGERPRINT_NAME = 'sirens-song-debug.certificate.sha256'

class ConfigureSigningTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.tools = self.root / 'scripts/toolchain'
        self.signing = self.tools / 'signing'
        self.signing.mkdir(parents=True)
        for name in ('configure.sh', 'common.sh'):
            shutil.copy2(ROOT / name, self.tools / name)
        self.key = self.signing / KEY_NAME
        canonical = ROOT / 'signing' / KEY_NAME
        if canonical.exists():
            shutil.copy2(canonical, self.key)
        self.fingerprint = self.signing / FINGERPRINT_NAME
        self.fingerprint.write_text(CERTIFICATE + '\n')
        self.game = self.root / 'game'
        self.game.mkdir()
        (self.game / 'project.godot').write_text('config_version=5\n')
        self.calls = self.root / 'godot-calls.txt'
        fake_godot = self.root / 'godot'
        fake_godot.write_text('#!/bin/sh\nset -eu\necho called >> "$CONFIG_TEST_GODOT_CALLS"\nmkdir -p "$XDG_CONFIG_HOME/godot"\nprintf "[gd_resource type=\\\"EditorSettings\\\" format=3]\\n[resource]\\n" > "$XDG_CONFIG_HOME/godot/editor_settings-4.6.tres"\n')
        fake_godot.chmod(0o755)
        real_keytool = shutil.which('keytool')
        self.assertIsNotNone(real_keytool, 'JDK keytool required for certificate verification')
        jdk = self.root / 'jdk'
        (jdk / 'bin').mkdir(parents=True)
        guarded_keytool = jdk / 'bin/keytool'
        guarded_keytool.write_text('#!/bin/sh\nif [ "$1" != "-exportcert" ]; then echo "Test forbids key generation/mutation" >&2; exit 97; fi\nexec "$CONFIG_TEST_REAL_KEYTOOL" "$@"\n')
        guarded_keytool.chmod(0o755)
        self.cache = self.root / 'cache'
        self.cache.mkdir()
        self.env = os.environ | {
            'GAME_DIR': str(self.game), 'TOOLCHAIN_CACHE': str(self.cache),
            'ARTIFACT_DIR': str(self.root / 'artifacts'), 'GODOT_BIN': str(fake_godot),
            'XDG_CONFIG_HOME': str(self.root / 'config'), 'CONFIG_TEST_GODOT_CALLS': str(self.calls),
            'JAVA_HOME': str(jdk), 'CONFIG_TEST_REAL_KEYTOOL': real_keytool,
        }

    def configure(self):
        return subprocess.run(['bash', str(self.tools / 'configure.sh')], env=self.env, text=True, capture_output=True, timeout=15)

    def assert_stopped_before_godot(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse(self.calls.exists(), 'Bad signing identity must stop before editor startup')
        self.assertFalse((self.root / 'config/godot/editor_settings-4.6.tres').exists())

    def test_missing_canonical_fails_without_using_or_replacing_cache(self):
        self.key.unlink(missing_ok=True)
        cached = self.cache / 'debug.keystore'
        cached.write_bytes(b'existing external identity must stay untouched')
        result = self.configure()
        self.assert_stopped_before_godot(result)
        self.assertIn('canonical', result.stderr.lower())
        self.assertEqual(cached.read_bytes(), b'existing external identity must stay untouched')
        self.assertFalse(self.key.exists())

    def test_invalid_canonical_fails_without_generation(self):
        self.key.write_bytes(b'invalid keystore')
        result = self.configure()
        self.assert_stopped_before_godot(result)
        self.assertEqual(self.key.read_bytes(), b'invalid keystore')
        self.assertFalse((self.cache / 'debug.keystore').exists())

    def test_missing_certificate_fingerprint_fails_before_editor(self):
        self.fingerprint.unlink()
        self.assert_stopped_before_godot(self.configure())

    def test_established_key_reused_with_empty_and_conflicting_cache(self):
        self.assertTrue(self.key.exists(), 'Verified recovered key must be versioned before this test can pass')
        original = self.key.read_bytes()
        for conflicting in (False, True):
            with self.subTest(conflicting_cache=conflicting):
                if conflicting:
                    (self.cache / 'debug.keystore').write_bytes(b'wrong external identity')
                result = self.configure()
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn(CERTIFICATE, result.stdout)
                text = (self.root / 'config/godot/editor_settings-4.6.tres').read_text()
                self.assertIn('export/android/debug_keystore = ' + json.dumps(str(self.key)), text)
                self.assertNotIn(str(self.cache / 'debug.keystore'), text)
                self.assertEqual(self.key.read_bytes(), original)
                if conflicting:
                    self.assertEqual((self.cache / 'debug.keystore').read_bytes(), b'wrong external identity')
                else:
                    self.assertFalse((self.cache / 'debug.keystore').exists())

    def test_fingerprint_mismatch_rejected_before_editor(self):
        self.assertTrue(self.key.exists(), 'Verified recovered key required')
        self.fingerprint.write_text('0' * 64 + '\n')
        result = self.configure()
        self.assert_stopped_before_godot(result)
        self.assertIn('certificate', result.stderr.lower())

if __name__ == '__main__':
    unittest.main()
