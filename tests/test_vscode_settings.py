"""Offline checks for shared VS Code preferences and local data preservation."""

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('vscode_settings', ROOT / 'bootstrap/vscode-settings.py')
settings = importlib.util.module_from_spec(spec)
spec.loader.exec_module(settings)
SHARED = ROOT / 'vscode/settings.json'


class VSCodeSettingsTests(unittest.TestCase):
    def test_jsonc_preserves_strings_and_accepts_trailing_commas(self):
        parsed = settings.load_settings('''{
            // local comment
            "url": "https://example.invalid/*not-a-comment*/",
            "text": "a,} and // text and \\\"quotes\\\"",
            "nested": {"items": [1, 2,],}, /* another comment */
        }''')
        self.assertEqual(parsed['url'], 'https://example.invalid/*not-a-comment*/')
        self.assertEqual(parsed['text'], 'a,} and // text and "quotes"')
        self.assertEqual(parsed['nested'], {'items': [1, 2]})

    def test_preserves_other_settings_and_backs_up_only_on_change(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / 'User/settings.json'
            target.parent.mkdir()
            original = '{"editor.fontSize": 16, "local": {"path": "/local/tool"}}'
            target.write_text(original)
            target.chmod(0o600)
            for _ in range(2):
                settings.apply_settings(SHARED, target)
            result = json.loads(target.read_text())
            self.assertEqual(result['local'], {'path': '/local/tool'})
            for key, value in json.loads(SHARED.read_text()).items():
                self.assertEqual(result[key], value)
            backups = list(target.parent.glob('settings.json.backup.*'))
            self.assertEqual(len(backups), 1)
            self.assertEqual(backups[0].read_text(), original)
            self.assertEqual(target.stat().st_mode & 0o777, 0o600)

    def test_creates_settings_on_new_machine(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / 'Code/User/settings.json'
            settings.apply_settings(SHARED, target)
            self.assertEqual(json.loads(target.read_text()), json.loads(SHARED.read_text()))

    def test_invalid_settings_are_not_replaced(self):
        for original in ('{"broken":', '[]'):
            with self.subTest(original=original), tempfile.TemporaryDirectory() as directory:
                target = Path(directory) / 'settings.json'
                target.write_text(original)
                with self.assertRaises(ValueError):
                    settings.apply_settings(SHARED, target)
                self.assertEqual(target.read_text(), original)
                self.assertEqual(list(target.parent.glob('*.backup.*')), [])

    def test_existing_symlink_is_not_modified(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'local.json'
            source.write_text('{}')
            target = Path(directory) / 'settings.json'
            target.symlink_to(source)
            with self.assertRaises(ValueError):
                settings.apply_settings(SHARED, target)
            self.assertTrue(target.is_symlink())
            self.assertEqual(source.read_text(), '{}')


if __name__ == '__main__':
    unittest.main()
