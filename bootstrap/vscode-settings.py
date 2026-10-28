"""Merge shared preferences without importing private VS Code settings into Git."""

from datetime import datetime
import json
import os
from pathlib import Path
import re
import shutil
import stat
import sys
import tempfile


def load_settings(text):
    # Match strings first so URLs and comment-like text inside them stay intact.
    tokens = r'"(?:\\.|[^"\\])*"|//[^\r\n]*|/\*[\s\S]*?\*/'
    text = re.sub(tokens, lambda m: m[0] if m[0].startswith('"') else
                  re.sub(r'[^\r\n]', ' ', m[0]), text)
    text = re.sub(r'"(?:\\.|[^"\\])*"|,(?=\s*[}\]])',
                  lambda m: '' if m[0] == ',' else m[0], text)
    settings = json.loads(text.lstrip('\ufeff'))
    if not isinstance(settings, dict):
        raise ValueError('VS Code settings must be a JSON object')
    return settings


def apply_settings(shared_path, target):
    if target.is_symlink():
        raise ValueError(f'Refusing to overwrite symlink: {target}')

    shared = load_settings(shared_path.read_text(encoding='utf-8'))
    original = target.read_bytes() if target.exists() else None
    current = load_settings(original.decode('utf-8')) if original is not None else {}
    merged = {**current, **shared}
    if merged == current:
        print('VS Code settings already up to date')
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(target.stat().st_mode) if original is not None else 0o600
    if original is not None:
        stamp = datetime.now().strftime('%Y%m%d%H%M%S%f')
        backup = target.with_name(f'{target.name}.backup.{stamp}')
        shutil.copy2(target, backup)
        print(f'Backed up VS Code settings -> {backup}')

    descriptor, temporary = tempfile.mkstemp(prefix='.dotfiles-', dir=target.parent)
    try:
        with os.fdopen(descriptor, 'w', encoding='utf-8') as output:
            json.dump(merged, output, indent=4, ensure_ascii=False)
            output.write('\n')
        os.chmod(temporary, mode)
        latest = target.read_bytes() if target.exists() else None
        if target.is_symlink() or latest != original:
            raise ValueError('VS Code settings changed during installation; retry')
        os.replace(temporary, target)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    print('Applied shared VS Code settings (other local preferences preserved)')


def main():
    root = Path(__file__).resolve().parents[1]
    target = Path.home() / 'Library/Application Support/Code/User/settings.json'
    try:
        apply_settings(root / 'vscode/settings.json', target)
    except (OSError, ValueError) as error:
        print(f'Error applying VS Code settings: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
