"""Actual MG link patterns and tamper/failure cases; no native physics run."""
import os
import tempfile
import unittest
from pathlib import Path

from native_evidence import snapshot_derivation_evidence, snapshot_native_tree
from support import snapshot


class NativeEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.evidence = self.root/'evidence'
        self.native = self.evidence/'madgraph/born_eq/standalone'
        (self.native/'Source/MODEL').mkdir(parents=True)
        (self.native/'SubProcesses/P1').mkdir(parents=True)
        self.target = self.native/'Source/MODEL/coupl.inc'
        self.target.write_text('      REAL*8 COUPLING\n')
        self.link = self.native/'Source/coupl.inc'
        self.link.symlink_to('MODEL/coupl.inc')

    def capture(self):
        return snapshot_derivation_evidence(self.evidence)

    def test_native_link_chain_and_optional_dangling_include(self):
        (self.native/'SubProcesses/coupl.inc').symlink_to('../Source/MODEL/coupl.inc')
        (self.native/'SubProcesses/P1/coupl.inc').symlink_to('../coupl.inc')
        missing = self.native/'SubProcesses/run_config.inc'
        missing.symlink_to('../Source/run_config.inc')
        records = self.capture()['files']
        links = [v for v in records.values() if v['kind']=='symlink']
        self.assertEqual(len(links),4)
        self.assertEqual(sum(v['target_kind']=='missing' for v in links),1)
        self.assertEqual(len({v['target_sha256'] for v in links if v['target_kind']=='file'}),1)
        self.assertTrue(missing.is_symlink())
        self.assertFalse(missing.exists())

    def test_retargeting_to_identical_bytes_changes_identity(self):
        original = self.capture()
        (self.target.parent/'other.inc').write_bytes(self.target.read_bytes())
        before = self.capture()
        self.link.unlink();self.link.symlink_to('MODEL/other.inc')
        self.assertNotEqual(before,self.capture())
        self.assertNotEqual(original,self.capture())

    def test_target_contents_and_executable_state_are_sealed(self):
        original = self.capture()
        self.target.write_text('changed')
        self.assertNotEqual(original,self.capture())
        before = self.capture();self.target.chmod(0o755)
        self.assertNotEqual(before,self.capture())

    def test_missing_to_present_transition_changes_identity(self):
        p = self.native/'SubProcesses/optional.inc';p.symlink_to('../Source/optional.inc')
        before = self.capture();(self.native/'Source/optional.inc').write_text('new')
        self.assertNotEqual(before,self.capture())

    def test_removed_link_changes_identity(self):
        before = self.capture();self.link.unlink()
        self.assertNotEqual(before,self.capture())

    def test_source_snapshot_still_rejects_native_links(self):
        with self.assertRaisesRegex(ValueError,'Symlink in source tree'):
            snapshot(self.evidence)

    def test_non_native_evidence_link_is_rejected(self):
        (self.evidence/'bad').symlink_to('madgraph/born_eq/standalone/Source/MODEL/coupl.inc')
        with self.assertRaisesRegex(ValueError,'outside native evidence scope'):
            self.capture()

    def test_unknown_process_link_is_rejected(self):
        p = self.evidence/'madgraph/unknown/standalone';p.mkdir(parents=True)
        (p/'data').write_text('x');(p/'link').symlink_to('data')
        with self.assertRaisesRegex(ValueError,'outside native evidence scope'):
            self.capture()

    def test_absolute_target_is_rejected_even_inside_tree(self):
        self.link.unlink();self.link.symlink_to(self.target)
        with self.assertRaisesRegex(ValueError,'Absolute'):
            self.capture()

    def test_escape_and_cross_process_targets_are_rejected(self):
        for text in ('../../../outside','../../../../real_eq/standalone/data'):
            with self.subTest(text=text):
                self.link.unlink();self.link.symlink_to(text)
                with self.assertRaisesRegex(ValueError,'escapes'):
                    self.capture()

    def test_directory_links_are_rejected(self):
        p = self.native/'SubProcesses/dir';p.symlink_to('../Source',target_is_directory=True)
        with self.assertRaisesRegex(ValueError,'regular file or missing leaf'):
            self.capture()

    def test_directory_link_is_rejected_in_target_chain(self):
        p = self.native/'Source/alias';p.symlink_to('MODEL',target_is_directory=True)
        self.link.unlink();self.link.symlink_to('alias/coupl.inc')
        with self.assertRaises(ValueError):
            self.capture()

    def test_cyclic_links_are_rejected(self):
        self.link.unlink();self.link.symlink_to('cycle')
        (self.native/'Source/cycle').symlink_to('coupl.inc')
        with self.assertRaisesRegex(ValueError,'Cyclic'):
            self.capture()

    def test_escape_then_return_does_not_follow_external_link(self):
        outside = self.root/'outside';outside.symlink_to(self.target)
        self.link.unlink();self.link.symlink_to('../../../../../outside')
        with self.assertRaisesRegex(ValueError,'escapes'):
            self.capture()

    def test_special_node_is_rejected_without_reading(self):
        os.mkfifo(self.evidence/'pipe')
        with self.assertRaisesRegex(ValueError,'Special node'):
            self.capture()

    def test_root_link_is_rejected(self):
        p=self.root/'alias';p.symlink_to(self.evidence,target_is_directory=True)
        with self.assertRaisesRegex(ValueError,'Symlink evidence root'):
            snapshot_derivation_evidence(p)

    def test_snapshot_is_read_only_and_repeatable(self):
        before = (self.link.lstat().st_ino,os.readlink(self.link),self.target.read_bytes())
        self.assertEqual(self.capture(),self.capture())
        self.assertEqual(before,(self.link.lstat().st_ino,os.readlink(self.link),self.target.read_bytes()))

    def test_standalone_tree_replay_has_same_scoped_link_rules(self):
        result=snapshot_native_tree(self.native)
        self.assertEqual(result['files']['Source/coupl.inc']['target_kind'],'file')
        self.link.unlink();self.link.symlink_to('/tmp/forbidden')
        with self.assertRaises(ValueError):snapshot_native_tree(self.native)


if __name__=='__main__':
    unittest.main()
