"""Verify the documented grouping correction without treating old/new hashes as equal."""
import hashlib
import json
from pathlib import Path

MANIFEST = Path(__file__).with_name("source-correction.json")
SOURCE = "collins_sidis_highpt/common/jet_matching.wl"
OLD_DEFINITION = b'''HSJetDistributionAction[c_,test_,z_]:=c["delta"](test/.z->1)
 +Inactive[Integrate][c["plus0"](test-(test/.z->1))/(1-z)
 +c["plus1"]Log[1-z](test-(test/.z->1))/(1-z)+c["regular"]test,{z,0,1}];'''
NEW_DEFINITION = OLD_DEFINITION.replace(b":=", b":=(", 1)[:-1] + b");"


def verify_correction(root, path, historical_hash):
    """Reject every mismatch except the exact documented two-parenthesis edit.

    Both full source hashes must match the explicit correction record, and
    removing just those two parentheses must recover the historical full hash.
    Historical receipts are never changed, nor is matches_recorded set true.
    """
    if path != root / SOURCE:
        raise RuntimeError(f"Undocumented source mismatch: {path}")
    correction = json.loads(MANIFEST.read_text())
    current = path.read_bytes()
    actual = hashlib.sha256(current).hexdigest()
    if (correction["path"] != SOURCE or historical_hash != correction["historical_sha256"]
            or actual != correction["corrected_sha256"]):
        raise RuntimeError(f"Source differs from the explicit old/new correction identities: {path}")
    if current.count(NEW_DEFINITION) != 1:
        raise RuntimeError("Expected exactly one explicitly grouped distribution definition")
    original = current.replace(NEW_DEFINITION, OLD_DEFINITION, 1)
    reconstructed = hashlib.sha256(original).hexdigest()
    if reconstructed != historical_hash:
        raise RuntimeError("Source changes extend beyond the two grouping parentheses")
    return {
        "classification": "EXPLICIT_GROUPING_CORRECTION; HISTORICAL_HASH_MISMATCH_RETAINED",
        "historical_sha256": historical_hash, "corrected_sha256": actual,
        "reconstructed_historical_sha256": reconstructed,
        "manifest": str(MANIFEST.relative_to(root)),
        "manifest_sha256": hashlib.sha256(MANIFEST.read_bytes()).hexdigest(),
        "relation": correction["change"],
        "historical_acceptance_renewed": False,
    }
