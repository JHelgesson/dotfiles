"""Offline checks for login routing and private configuration preservation."""
import contextlib
import importlib.machinery
import importlib.util
import io
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
loader = importlib.machinery.SourceFileLoader('klogin', str(ROOT / 'tools/bin/klogin'))
spec = importlib.util.spec_from_loader(loader.name, loader)
klogin = importlib.util.module_from_spec(spec)
loader.exec_module(klogin)
EXAMPLE = ROOT / 'examples/kubernetes.example.toml'


class LoginTests(unittest.TestCase):
    def test_example_routes_to_explicit_workload_without_disabling_tls(self):
        supervisors, clusters = klogin.load_connections(EXAMPLE)
        command = klogin.login_command('example-dev', supervisors, clusters, 'example-user')
        self.assertEqual(command, [
            'kubectl', 'vsphere', 'login',
            '--server=supervisor.example.invalid',
            '--tanzu-kubernetes-cluster-namespace=example-shared-dev',
            '--tanzu-kubernetes-cluster-name=example-dev',
            '--vsphere-username=example-user',
        ])
        supervisors['example']['insecureSkipTLSVerify'] = True
        self.assertIn('--insecure-skip-tls-verify', klogin.login_command('example-dev', supervisors, clusters))

    def invoke(self, args, results):
        output = io.StringIO()
        with patch.object(sys, 'argv', ['klogin', '--config', str(EXAMPLE), *args]), \
             patch.object(klogin, 'run', side_effect=results) as run, \
             patch.object(klogin.shutil, 'which', return_value='/fake/kubectx'), \
             contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
            code = klogin.main()
        return code, run, output.getvalue()

    def test_failed_login_does_not_select_another_context(self):
        code, run, _ = self.invoke(['example-dev'], [3])
        self.assertEqual(code, 3)
        self.assertEqual(run.call_count, 1)
        self.assertEqual(run.call_args.args[0][:3], ['kubectl', 'vsphere', 'login'])

    def test_success_selects_the_requested_context(self):
        code, run, _ = self.invoke(['example-dev'], [0, 0])
        self.assertEqual(code, 0)
        self.assertEqual(run.call_args.args[0], ['kubectx', 'example-dev'])

    def test_show_and_list_do_not_connect(self):
        for args in (['example-dev', '--show'], ['--list']):
            with self.subTest(args=args):
                code, run, _ = self.invoke(args, [])
                self.assertEqual(code, 0)
                run.assert_not_called()

    def test_unknown_cluster_does_not_connect(self):
        code, run, output = self.invoke(['unknown'], [])
        self.assertEqual(code, 1)
        run.assert_not_called()
        self.assertIn('Okänt kluster', output)

    def test_invalid_destinations_are_rejected(self):
        original = EXAMPLE.read_text()
        mutations = [
            original.replace('supervisor = "example"', 'supervisor = "missing"'),
            original.replace('supervisor.example.invalid', 'http://example.invalid'),
            original.replace('supervisor.example.invalid', 'example.invalid/path'),
            original.replace('insecureSkipTLSVerify = false', 'insecureSkipTLSVerify = "false"'),
            original.replace('supervisorNamespace = "example-shared-dev"', 'supervisorNamespace = "--all-namespaces"'),
        ]
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'connections.toml'
            for text in mutations:
                with self.subTest(text=text):
                    path.write_text(text)
                    with self.assertRaises(klogin.ConfigError):
                        klogin.load_connections(path)

    @unittest.skipUnless(shutil.which('stow'), 'Requires GNU Stow')
    def test_installer_links_helper_and_preserves_private_config_on_repeat(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            private = home / '.config/vgr/kubernetes.toml'
            private.parent.mkdir(parents=True)
            private.write_text('private-local-fixture')
            bin_dir = home / 'bin'
            bin_dir.mkdir()
            previous = bin_dir / 'klogin'
            previous.write_text('previous-local-helper')
            fake_bin = home / 'fake-bin'
            fake_bin.mkdir()
            git = fake_bin / 'git'
            git.write_text('#!/bin/sh\nexit 0\n')
            git.chmod(0o755)
            env = dict(os.environ, HOME=str(home), ZSH=str(home / '.oh-my-zsh'),
                       ZSH_CUSTOM=str(home / '.oh-my-zsh/custom'),
                       PATH=str(fake_bin) + os.pathsep + os.environ['PATH'])
            for _ in range(2):
                result = subprocess.run(['bash', str(ROOT / 'install.sh'), '--dotfiles'],
                                        env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertTrue(previous.is_symlink())
                self.assertEqual(previous.resolve(), (ROOT / 'tools/bin/klogin').resolve())
                self.assertEqual(private.read_text(), 'private-local-fixture')
            backups = list(bin_dir.glob('klogin.backup.*'))
            self.assertEqual(len(backups), 1)
            self.assertEqual(backups[0].read_text(), 'previous-local-helper')


if __name__ == '__main__':
    unittest.main()
