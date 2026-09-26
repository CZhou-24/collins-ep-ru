"""Focused identity-gate tests; never modify production sources or historical hashes."""
import hashlib
import json
from pathlib import Path
import unittest
from unittest.mock import patch, Mock

import source_correction as sc

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / sc.SOURCE
RECORD = json.loads(sc.MANIFEST.read_text())


class SourceCorrectionTests(unittest.TestCase):
    def test_actual_correction_recovers_exact_historical_hash(self):
        evidence = sc.verify_correction(ROOT, SOURCE, RECORD["historical_sha256"])
        self.assertEqual(evidence["reconstructed_historical_sha256"], RECORD["historical_sha256"])
        self.assertNotEqual(evidence["historical_sha256"], evidence["corrected_sha256"])

    def test_unrelated_path_is_not_exempted(self):
        with self.assertRaisesRegex(RuntimeError, "Undocumented source mismatch"):
            sc.verify_correction(ROOT, SOURCE.with_name("fragmentation.wl"), RECORD["historical_sha256"])

    def test_unrecognized_historical_identity_is_rejected(self):
        with self.assertRaisesRegex(RuntimeError, "explicit old/new correction identities"):
            sc.verify_correction(ROOT, SOURCE, "0" * 64)

    def test_further_source_edit_is_rejected(self):
        changed = SOURCE.read_bytes().replace(b"Pi^2/12", b"Pi^2/13", 1)
        with patch.object(Path, "read_bytes", return_value=changed):
            with self.assertRaisesRegex(RuntimeError, "explicit old/new correction identities"):
                sc.verify_correction(ROOT, SOURCE, RECORD["historical_sha256"])

    def test_recording_a_new_hash_cannot_waive_a_formula_edit(self):
        changed = SOURCE.read_bytes().replace(b"Pi^2/12", b"Pi^2/13", 1)
        altered = dict(RECORD, corrected_sha256=hashlib.sha256(changed).hexdigest())
        manifest = Mock()
        manifest.read_text.return_value = json.dumps(altered)
        with patch.object(sc, "MANIFEST", manifest), patch.object(Path, "read_bytes", return_value=changed):
            with self.assertRaisesRegex(RuntimeError, "extend beyond the two grouping parentheses"):
                sc.verify_correction(ROOT, SOURCE, RECORD["historical_sha256"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
