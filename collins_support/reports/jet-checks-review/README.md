# Reproducible jet checks

Both bounded checks were freshly executed from the publication checkout using
their packaged inputs and an existing Python 3.10.12 / SymPy 1.14.0 environment.

| Check | Fresh result | Packaged inputs | Saved evidence |
|---|---:|---|---|
| [Jet literature](../../checks/jet_literature/README.md) | **74/74**, zero failures | Eight pinned source fixtures and selected archived ep values | [summary](literature/summary.json), [74 rows](literature/comparison.csv) |
| [Jet equivalence](../../checks/jet_equivalence/README.md) | **14/14**, zero failures | Fifteen pinned source fixtures and the local algebra helper | [summary](equivalence/summary.json), [14 rows](equivalence/checks.csv) |

During verification, project-file reads outside each packaged check and its
explicit report output were blocked, including reads from the active
`/bigTMD` checkout. No blocked access was attempted. All required project files
were read from the selected package. The existing system Python/SymPy
environment was used; no environment, native run state or archive is required
from the working repository. [Verification record](verification.json).

From the repository root, with the existing Python environment active:

```bash
python3 -B collins_support/checks/jet_literature/check_jets.py \
  --out collins_support/reports/jet-literature-replay-001
python3 -B collins_support/checks/jet_equivalence/check_equivalence.py \
  --out collins_support/reports/jet-equivalence-replay-001
```

Use a new output directory for each repetition. Generated results stay under
`reports/`, outside the check packages and the committed compact review.
Both checks verify their pinned source hashes. Their `sources/` files,
including `r07_assembly.wls`, are test fixtures, not production entrypoints.
The source manifests pin revision
`fd46f4e6b00e4166984faf0fb57bab5369503068`.

The literature suite checks source algebra and selected archived values. It
does not replay the archived native calculation. The equivalence suite checks
soft, rapidity-scale and Fourier conventions, including expected nonzero
semi-inclusive differences: **the complete jet operators are not equal**.
See the [convention and scope note](JET_EQUIVALENCE_NOTE.md).
The counts contain related identities and do not represent independent
physical predictions. Intrinsic NLO Collins matching, complete cross sections,
generic twist-three contacts and finite-radius accuracy remain outside scope.

Scripts, formulas, tolerances, expected results and fixture bytes are unchanged
from the reusable check packages; documentation now uses portable commands.
Historical results remain separately identified in [evidence origins](evidence-origins.json).
`MANIFEST.json` records this compact review and the packaged checks, excluding
itself. No Wolfram/Kira/SubTropica calculation, native campaign, dependency
probe, BigTMD or Congyue comparison was run for this publication.
