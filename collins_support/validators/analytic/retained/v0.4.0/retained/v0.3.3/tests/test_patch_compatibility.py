"""Filesystem-only patch compatibility checks; no physics backend is invoked."""
import copy
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import derivation_support
from support import read, sha, snapshot, write


class PatchCompatibilityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'repo'
        self.production = self.repo / 'collins_ep_analytic'
        self.numerical = self.repo / 'collins_ep'
        self.production.mkdir(parents=True)
        self.numerical.mkdir()
        (self.production / 'original.wl').write_text('original analytical source\n')
        (self.numerical / 'original.py').write_text('# original numerical source\n')
        self.original_production = snapshot(self.production)
        self.original_numerical = snapshot(self.numerical)
        self.release = self.root / 'patch-release'
        write(self.release / 'MANIFEST.json', {'fixture': 'v0.3.3 release identity'})
        root_patch = patch.object(derivation_support, 'ROOT', self.release)
        root_patch.start()
        self.addCleanup(root_patch.stop)
        self.lock = self.root / 'original-v0.3.0-state' / 'installation.json'
        self.record = {
            'schema': 1,
            'repo': str(self.repo),
            'validator_manifest_sha256': (
                derivation_support.COMPATIBLE_PREDECESSOR_MANIFEST_SHA256
            ),
            'production_before': self.original_production,
            'numerical_before': self.original_numerical,
            'baseline': {'fixture': 'unchanged historical baseline'},
            'installed_files': {'fixture': 'original scaffold inventory'},
        }
        write(self.lock, self.record)
        self.runtime = self.production / 'derivation_runtime.json'
        write(self.runtime, {
            'schema': 1,
            'stage_timeout_seconds': 60,
            'installation_lock': str(self.lock),
            'madgraph': {},
            'madgraph_candidate_command': ['python3', 'comparison/candidate.py'],
        })

    def test_exact_predecessor_keeps_lock_and_runtime_bytes(self):
        self.assertEqual(
            derivation_support.COMPATIBLE_PREDECESSOR_MANIFEST_SHA256,
            'e87f8da47802f37d61e0e9cf7c07f75b66c374bba258d2e4044d93d50cbbed08',
        )
        before = {p: p.read_bytes() for p in (self.lock, self.runtime)}
        self.assertEqual(derivation_support.check_installation(self.production), self.record)
        runtime = derivation_support.runtime_extension(self.production)
        self.assertEqual(runtime['installation_lock_sha256'], sha(self.lock))
        self.assertEqual(before, {p: p.read_bytes() for p in before})

    def test_current_release_identity_is_supported(self):
        current = copy.deepcopy(self.record)
        current['validator_manifest_sha256'] = sha(self.release / 'MANIFEST.json')
        write(self.lock, current)
        self.assertEqual(derivation_support.check_installation(self.production), current)

    def test_unknown_release_identity_is_blocked(self):
        unknown = copy.deepcopy(self.record)
        unknown['validator_manifest_sha256'] = '0' * 64
        write(self.lock, unknown)
        with self.assertRaisesRegex(ValueError, 'another repository/release'):
            derivation_support.check_installation(self.production)

    def test_predecessor_for_wrong_repository_is_blocked(self):
        wrong = copy.deepcopy(self.record)
        wrong['repo'] = str(self.root / 'another-repository')
        write(self.lock, wrong)
        with self.assertRaisesRegex(ValueError, 'another repository/release'):
            derivation_support.check_installation(self.production)

    def test_predecessor_retains_analytical_and_numerical_protection(self):
        for target in (self.production / 'original.wl', self.numerical / 'original.py'):
            original = target.read_bytes()
            for mutation in ('edit', 'delete'):
                with self.subTest(target=target.name, mutation=mutation):
                    if mutation == 'edit':
                        target.write_text('unauthorized mutation\n')
                    else:
                        target.unlink()
                    try:
                        with self.assertRaisesRegex(ValueError, 'Protected file changed'):
                            derivation_support.check_installation(self.production)
                    finally:
                        target.write_bytes(original)

    def test_inherited_inventory_is_never_reset_to_candidate_additions(self):
        candidate = self.production / 'common' / 'd13_finite_matching.wl'
        candidate.parent.mkdir()
        candidate.write_text('candidate implementation revision one\n')
        lock_before = self.lock.read_bytes()
        result = derivation_support.check_installation(self.production)
        self.assertEqual(result['production_before'], self.original_production)
        self.assertNotIn('common/d13_finite_matching.wl', result['production_before'])
        self.assertNotIn('derivation_runtime.json', result['production_before'])
        candidate.write_text('candidate implementation revision two\n')
        self.assertEqual(derivation_support.check_installation(self.production), self.record)
        self.assertEqual(self.lock.read_bytes(), lock_before)
        self.assertEqual(read(self.lock)['installed_files'], self.record['installed_files'])

    def test_new_output_state_defaults_to_patch_release(self):
        self.assertEqual(
            derivation_support.DEFAULT_STATE, '/bigTMD/collins_support/states/runs/legacy-installation',
        )


    def test_exact_v031_installation_issuer_is_supported_without_rewrite(self):
        current=copy.deepcopy(self.record)
        current['validator_manifest_sha256']='fc169985cd5634d8c8ef3ab3faa99b1857603617f088b4897ffdc4fe9b196ffa'
        write(self.lock,current)
        before=self.lock.read_bytes()
        self.assertEqual(derivation_support.check_installation(self.production),current)
        self.assertEqual(before,self.lock.read_bytes())


    def test_exact_v032_installation_issuer_is_supported_without_rewrite(self):
        current=copy.deepcopy(self.record)
        current['validator_manifest_sha256']='4b8ef224916cae97bba765567b0ba3f565bed7b5d70f3dbb2f588c6172416ae8'
        write(self.lock,current)
        before=self.lock.read_bytes()
        self.assertEqual(derivation_support.check_installation(self.production),current)
        self.assertEqual(before,self.lock.read_bytes())


if __name__ == '__main__':
    unittest.main()
