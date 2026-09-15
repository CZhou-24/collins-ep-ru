#!/usr/bin/env python3
"""Copy the authorized, unchanged inputs for the new integral workflow."""
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT.parent
CHANNELS = {
    "Hqq": {
        "source": "Hqq_v4", "stages": ["s01", "s02", "s03", "s08"],
        "required": ["s01_result.wl", "s02_result.wl", "s03_result.wl", "s08_result.wl"],
        "references": ["s04_virtual_integrals.wl", "s07_renormalize_virtual.wl", "s10_final_hats.wl"],
        "process": "Incoming quark p, observed same-flavor quark k1. Born/virtual recoil is gluon k2. Real sectors are qgg, same-flavor qq qbar, and distinct-flavor q qprime qbarprime, always with the observed quark at k1.",
        "bookkeeping": "Use the generated incoming-quark average, photon-vertex charge normalization and real tag/factorial weights. Preserve separate real sectors, the distinct-flavor charge polynomial, OtherChargeMomentDefinitions and FlavorWeight. The allowed integer flavor domain and observed-flavor identity must accompany the result. S08 contains the independently selected PDF/FF routes and their D-dimensional Born contributions.",
        "caveat": "The corrected S03 amplitude/tensor boundary is reused. No superseded angular merge or downstream angular cache is imported."
    },
    "Hqg": {
        "source": "Hqg_v3", "stages": ["s02", "s04", "s05", "s10"],
        "required": ["s02_result.wl", "s04_result.wl", "s05_result.wl", "s10_result.wl"],
        "references": ["s06_virtual_integrals.wl", "s09_renormalize_virtual.wl", "s12_final_hats.wl"],
        "process": "Incoming quark p, observed gluon k1. Born/virtual recoil is quark k2. Real recoil is quark k2 and gluon k3.",
        "bookkeeping": "Use the generated quark average, measured model-charge removal and tagged-real weight from S02/S04/S05. The real tensors have eq^2 gs^4 removed. S10 preserves the PDF and gluon/quark-parent fragmentation routes, their D-dimensional Born terms and explicit distribution convention. Nf remains the closed massless-flavor count.",
        "caveat": "The old finite Delta coefficients disagree with the authors in the recorded comparison. Neither side sets a new integration coefficient."
    },
    "Hgq": {
        "source": "Hgq_v4", "stages": ["s01", "s02", "s03", "s08"],
        "required": ["s01_result.wl", "s02_result.wl", "s03_result.wl", "s08_result.wl"],
        "references": ["s04_virtual_integrals.wl", "s07_renormalize_virtual.wl", "s10_final_hats.wl"],
        "process": "Incoming gluon p, observed fixed-flavor quark k1. Born/virtual recoil is antiquark k2. Real recoil is antiquark k2 and gluon k3.",
        "bookkeeping": "Use the generated D-dimensional physical incoming-gluon average, measured color/charge normalization and tag weight. The observed quark charge remains fixed; Nf counts closed massless flavors. S08 records PDF routes Hgq_LO with Pgg and Hqq_LO with Pqg, and FF route Hgq_LO with Pqq. Preserve the per-flavor Pqg convention, Born D dependence and Ppp rescaling.",
        "caveat": "The source README records an unresolved MadGraph real-emission sign comparison. Retain that limitation until its originating comparison/tensor convention is resolved; do not fit a sign from final hats."
    },
    "Hgg": {
        "source": "Hgg_v2", "stages": ["s01", "s02"],
        "required": ["s01_result/manifest.wl", "s02_result/kinematics.wl", "s02_result/real.wl"],
        "references": ["s05_factorize.wls"],
        "process": "Incoming gluon p, observed gluon k1, unobserved quark k2 and antiquark k3. This channel has no virtual contribution at the order calculated.",
        "bookkeeping": "The unobserved quark/antiquark pair is integrated once. Preserve the generated gluon average and Born subtraction tensors. chargeSum denotes the sum of squared massless-flavor charges. The incoming/outgoing quark and antiquark factorization terms are separate from real spectator counting.",
        "caveat": "The old public numerical driver omits finite terms present in its coefficient files; a driver output is not a production input."
    },
    "Hqqbar": {
        "source": "Hqqbar_v2", "stages": ["s01", "s02"],
        "required": ["s01_result/manifest.wl", "s02_result/kinematics.wl", "s02_result/real.wl"],
        "references": ["s05_factorize.wls"],
        "process": "Incoming quark p, observed same-flavor antiquark k1, unobserved identical quarks k2 and k3. There is no virtual contribution at this order.",
        "bookkeeping": "The flavor is fixed and eq2 denotes its squared charge. The real tensor has no spectator symmetry weight; use the generated spectator count and apply the weight once in assembly. Initial subtraction uses q to g with gamma* g to qbar q; final subtraction uses gamma* q to g q with g to qbar, once each for the fixed flavor.",
        "caveat": "No old angular pole/finite vector or endpoint result is imported. The new cut integral stage must establish its own endpoint behavior."
    },
    "Hqqprime": {
        "source": "Hqqprime_v2", "stages": ["s01", "s02"],
        "required": ["s01_result/manifest.wl", "s02_result/kinematics.wl", "s02_result/real.wl"],
        "references": ["s05_factorize.wls"],
        "process": "Incoming quark p, observed distinct-flavor quark k1, unobserved incoming-flavor quark k2 and observed-flavor antiquark k3. There is no virtual contribution at this order.",
        "bookkeeping": "Keep independent incoming/observed charges eq and eqp and all three terms eq^2, eq eqp, eqp^2. Model charges, spectator counts and spin/color averages come from the generated inputs. Initial subtraction uses q to g and the Born tensor carrying eqp^2; final subtraction uses g to qprime and the Born tensor carrying eq^2.",
        "caveat": "Do not discard a charge sector or endpoint term without an exact identity from the new cut calculation."
    }
}


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def preserve(source, target):
    expected = digest(source)
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        if digest(target) != expected:
            raise RuntimeError("Existing input differs: " + str(target))
    else:
        shutil.copy2(source, target)
    if digest(target) != expected:
        raise RuntimeError("Copy hash mismatch: " + str(target))
    return {"source": str(source.relative_to(SCRIPTS)),
            "path": str(target.relative_to(ROOT)),
            "bytes": target.stat().st_size, "sha256": expected}


for name, config in CHANNELS.items():
    source = SCRIPTS / config["source"]
    channel = ROOT / name
    inputs = channel / "s01_result" / "s01_inputs"
    for required in config["required"]:
        if not (source / required).is_file():
            raise RuntimeError("Missing required input: " + str(source / required))
    paths = [source / "README.md"]
    for stage in config["stages"]:
        paths.extend(p for p in source.iterdir() if p.is_file()
                     and p.name.startswith(stage + "_")
                     and "previous" not in p.name and "failed" not in p.name.lower()
                     and p.suffix in {".wl", ".wls", ".json", ".log"})
        for directory in [source / (stage + "_result"), source / (stage + "_cache")]:
            if directory.is_dir():
                paths.extend(p for p in directory.rglob("*") if p.is_file()
                             and p.suffix in {".wl", ".wls", ".json", ".log"})
    entries = [preserve(p, inputs / p.relative_to(source)) for p in sorted(set(paths))]
    refs = [preserve(source / p, channel / "s01_result" / "s01_reference_sources" / p)
            for p in config["references"]]
    manifest = {"channel": name, "source_channel": config["source"],
                "required": config["required"], "files": entries,
                "reference_sources_only": refs,
                "evaluated_loop_results_imported": False,
                "evaluated_real_integrals_imported": False,
                "old_final_hats_imported": False,
                "accepted": True}
    (channel / "s01_result" / "s01_result.json").write_text(json.dumps(manifest, indent=2) + "\n")
    readme = f"""# {name}: SIDIS through NLO using reverse unitarity

## Process and inherited bookkeeping

{config['process']}

{config['bookkeeping']}

All partons are massless. The photon is spacelike. The source payload's
invariant definitions, scalar-product rules, dimension, tensor-projector
signs, model-charge removal, color symbols and scale convention are kept
verbatim in `s01_inputs/`. They must be converted by explicit, checked maps
before combining with a common family basis. No other channel's weight or
charge factor substitutes for this channel's measured quantities.

{config['caveat']}

## Stage 1: preserved inputs

Run `../s01_import_inputs.py` locally. `s01_result.json` records every
copied file, its origin, size and SHA256. The unchanged source channel is
`../../{config['source']}`. Its complete convention ledger is preserved in
`s01_inputs/README.md`; its historical angular/Package-X stages are outside
the new integration workflow. `s01_reference_sources/` holds source code
for adapting interference, renormalization or assembly only; these sources
are not executed unchanged and their evaluated results are not imported.

Stage 1 accepts byte-preserved inputs only. It is not acceptance of a new
integral, pole cancellation or final F hat. The new scalar-family stage
must check its source identities and exact input reconstruction.

## New integration contracts

The real map replaces the unobserved on-shell phase-space constraints by
positive-energy cuts. Both cuts remain present in Kira targets and
reductions. Family definitions, momentum routing, signs, loop measures,
normalization and reconstructing coefficient maps must be saved with the
generated targets. Any removal of dependent propagators is an algebraic
family construction, not the paper's angular integration.

Kira supplies the reduction rules and actual master inventory. SubTropica
evaluates every required real and virtual master to the regulator depth
determined by its coefficient and endpoint requirements. Raw engine output
is saved before normalization or physical continuation. Cut conventions,
branches and source/input hashes remain explicit. Neither the paper's
angular tables nor PaVe/Package-X evaluations enter this calculation.

After inserting the new masters, assemble UV renormalization, regulated
real distributions and the channel's factorization terms. Require exact
pole cancellation for each independent projector/charge component before
projecting and exporting symbolic F1hat/F2hat. Establish endpoint support,
distribution definitions and physical branch limits from the new result.
Old integrated hats may be read only as a subsequent comparison.

## Execution and artifacts

Run physics stages on Hoffman2 compute nodes under the shared SIDIS
execution contract. Main sources, inputs, results, logs and resumable
caches are retained locally. Shared loop-family/master artifacts are in
`../common/` and are referenced by hash. This folder owns its independent
channel coefficients, stage outputs and final hats. Job allocations and
process-tree memory guards bound concurrent work before algebra starts.

Append accepted stage contracts and exact artifact identities here as the
new calculation advances. `../../progress.md` is the only live status
record. No new integrated result is asserted by this initial ledger.
"""
    readme_path = channel / "README.md"
    if not readme_path.exists():
        readme_path.write_text(readme)
    print(name, "preserved", len(entries), "inputs and", len(refs), "reference sources;",
          sum(x["bytes"] for x in entries), "bytes", flush=True)
print("S01_SUCCESS", flush=True)
