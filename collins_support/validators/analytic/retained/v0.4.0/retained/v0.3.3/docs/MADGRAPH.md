# Independent tree-amplitude checks

`madgraph_checks.py` generates fresh photon-exchange Standard Model amplitudes
with a user-supplied MG5 installation. No MadGraph runtime was available when
this validator release was prepared. Its tests establish properties of the
adapter and coherent spin algebra using explicitly synthetic fixtures; they do
**not** establish a native MadGraph pass. An absent installation, unavailable
compiler, unsupported template or incomplete native output leaves acceptance
**BLOCKED**. A candidate/reference disagreement is **FAIL**.

## Scope and normalization

The calculation's convention baseline is the pinned
`NonHermitianMatrix/SIDIS_dsigma_till_NLO` checkout. Keep its definitions in
production. The amplitude adapter must give an explicit algebraic conversion
from those definitions to this independent benchmark interface, including any
coupling stripping and initial-state averaging. Do not change production to
fit the interface and do not infer an unexplained numerical rescaling.

| Key | Generated process | Checked projections | Initial spin/color divisor |
|---|---|---|---:|
| `born_eq` | `e- u > e- u / z h QED=2 QCD=0` | UU and coherent double transverse quark spin | 12 |
| `real_eq` | `e- u > e- u g / z h QED=2 QCD=1` | UU and coherent double transverse quark spin | 12 |
| `real_eg` | `e- g > e- u u~ / z h QED=2 QCD=1` | UU | 32 |

All external particles are massless, with metric `+---` and all physical
external energies positive. The first two momenta are incoming. The remaining
momenta are outgoing electron, quark, and optional gluon/antiquark. The
comparison uses the full coupling squared amplitude, summed over final colors
and unobserved helicities, averaged over initial colors/spins, without flux or
phase-space factors. The fixed inputs are
`alpha_em = 1/137.035999084`, `alpha_s = 0.118`, and `Q_u = 2/3`.
Born amplitudes contain `e^4 Q_u^2`; real amplitudes additionally contain
`g_s^2`, where `e^2=4*pi*alpha_em` and `g_s^2=4*pi*alpha_s`.

For the quark channels, `UT` means the coefficient obtained by inserting
`slash(p) gamma5 slash(S_in)` and
`slash(p_out) gamma5 slash(S_out)` in the two quark densities, with the same
initial spin/color normalization as UU. This is the **partonic double
transverse spin-transfer coefficient**, not a hadronic Collins asymmetry or a
single-spin asymmetry. Its relation to the candidate's Collins tensor,
azimuthal harmonic and named UT convention must be derived in the adapter's
conversion record. There is no gluon transversity gate for the spin-1/2 target.

These checks do not establish dimensional `O(epsilon)` terms, integrated real
contributions, subtraction distributions, TMD matching, rapidity evolution,
fitted fragmentation inputs or the complete observable. Those belong to the
separate analytical gates. No fitted PDF/FF provider is used here.

## Native extraction and transverse interference

The verifier generates one standalone subprocess for each channel in a new
evidence directory. It preserves the original `matrix.f`, instruments the
generated `JAMP(1)` after all native amplitude statements, and records source,
build, parameter-card, input and output hashes. It supports explicitly
recognized one-dimensional color layouts: packed `CF` with scalar `DENOM`, or
square `CF(NCOLOR,NCOLOR)` with `DENOM(NCOLOR)`. Unknown color layouts and
initialization signatures are blocked; never substitute archived amplitudes.

The native driver exports `SMATRIX`, complex `JAMP` for **every helicity**,
the native incoming `IXXXXX` wavefunction, and the native outgoing `OXXXXX`
wavefunction. The outgoing spinor is reconstructed from its actual native
dual, so no relation between incoming and outgoing HELAS phases is assumed.
Both spinor bases must satisfy `sum_h u_h ubar_h = slash(p)`. The off-diagonal
helicity density must reconstruct `slash(p) gamma5 slash(S)` exactly within
the numerical tolerance. Unsupported spinor layouts remain blocked.

The coherent contraction is

```text
sum M(h,k) conj(M(h',k')) rho_in[h,h'] rho_out[k',k]
```

with equal unobserved helicities, the native color metric and the stated
initial average. Squared helicity amplitudes alone are insufficient. The
verifier checks every captured `JAMP` against native `MATRIX`, the full
helicity sum against native `SMATRIX`, spin reversal, simultaneous reversal
of both spins, zero polarization and compensated arbitrary helicity phase
changes. It then compares UU and coherent UT with the independent explicit
four-dimensional Clifford traces in `real_oracle.py` and with the candidate.
Agreement requires `abs(a-b) <= 2e-10 + 2e-7*max(abs(a),abs(b))`; small values
use the same declared absolute tolerance rather than an unstable relative
ratio. Six reproducible physical points per process are generated per seed.

## Runtime configuration and adapter protocol

Configure these keys in the additive
`/bigTMD/collins_ep_analytic/derivation_runtime.json` installed by v0.3.0;
retain its other scaffold keys:

```json
{
  "madgraph": {
    "root": "/absolute/path/to/MG5_aMC",
    "python": "/usr/bin/python3",
    "make": "make",
    "fortran_compiler": "gfortran",
    "timeout_seconds": 600
  },
  "madgraph_candidate_command": [
    "python3", "{repo}/collins_ep_analytic/comparison/madgraph_candidate.py",
    "--repo", "{repo}", "--run", "{run}",
    "--requests", "{requests}", "--response", "{response}"
  ]
}
```

`root` must contain the real `bin/mg5_aMC` entry point and the normal MG5
sources. `make` and the Fortran compiler must work with that installation.
The runner uses MadGraph's native compiler configuration; the scaffold's
`fortran_compiler` records and hashes the configured executable, and must
match the compiler that MadGraph actually selects. Setting this JSON field
alone does not change MadGraph's build configuration. Native generation and
build failures remain blocked until that environment is resolved.
The generation path cannot contain whitespace. `SETPARA` initialization is
recognized with one literal card argument or a literal logical second
argument. Other native APIs require a separately reviewed adapter extension.
The verifier uses single-threaded BLAS/OpenMP settings.

The request file is `{"schema":1,"seed":1729,"rows":[...]}`. Every row
contains `id`, `process`, `momenta`, PDG `incoming`/`outgoing` lists,
`spin_in`/`spin_out`, coupling values and the normalization description.
For `real_eg` the spin vectors are null. The candidate must read the current
generated derivation exports, apply its explicit SIDIS convention conversion,
and write exactly one row for each request:

```json
{"schema":1,"rows":[{"id":"born_eq.0","UU":0.01,"UT":-0.002}]}
```

The numbers above illustrate the JSON schema only. UU and the required UT
values must be finite JSON numbers, not booleans; missing, duplicate and
unexpected IDs fail. The response must not pre-exist. The verifier captures
the candidate answer **before** generating any native reference answers and
records its hash in each native build manifest. This is dependency separation
in a shared filesystem, not an adversarial security sandbox.

The Python API is
`run_checks(repo, run, runtime, evidence_dir, seed) -> list[dict]`, with each
record containing `id`, `status` and `detail`. A complete run has 62 core
records: phase space, candidate freshness, 30 native/Clifford comparisons and
30 candidate/native comparisons. The caller must require every mandatory
record to pass; a passing subset is not acceptance.

Direct invocation is also available:

```bash
python madgraph_checks.py --repo /bigTMD \
  --run /absolute/path/to/fresh/run \
  --runtime /bigTMD/collins_ep_analytic/derivation_runtime.json \
  --evidence-dir /absolute/path/to/new/madgraph-evidence --seed 1729
```

The direct CLI exits 0 only when all returned checks pass, 2 for a blocked
run, and 1 for a failed run with no blocked gate. Do not count blocked runs as
physics validation.

## Evidence replay

`replay_checks(evidence_dir, seed)` reconstructs the same successful-run core
records from archived **raw evidence**, without reading stored PASS flags.
It regenerates the requests, validates the response, checks all recorded
source/build/input/output hashes, verifies the source instrumentation and
driver, validates coupling/mass settings, reparses every helicity and spinor,
recomputes independent traces and candidate residuals, and requires
`native-values.json` to equal the raw-output reconstruction. Missing native
evidence is blocked; inconsistencies fail.

The archive must retain `requests.json`, `candidate-response.json`,
`native-values.json`, and the three process directories, including their
`standalone/` builds, `matrix.original.f`, logs, `momenta.txt`,
`native-output.txt` and `build-identities.json`. Retain MG5 version metadata
and its entry-point hash in the latter. Replay checks archive consistency;
it does **not** replace a fresh native run or authenticate a maliciously
fabricated archive.

## Release self-tests

```bash
python -m unittest discover -s tests -p 'test_madgraph*.py' -v
```

The tests cover independent analytic Weyl helicity currents versus Dirac
traces at Born level, off-diagonal interference, outgoing spinor phases,
rephasing and reversal controls, finite/complete native parsing, guarded
Fortran instrumentation, benchmark inputs and missing-runtime gates. The
`.f` files under `madgraph_templates/` are labeled synthetic parser fixtures;
they are not stored MadGraph reference answers and cannot satisfy acceptance.


## v0.3.1 native-template repair

The literal `SETPARA` parser accepts legal trailing `!` comments outside quoted strings in fixed-form MG5 drivers. It retains exactly one active initialization and the supported literal filename/optional literal logical argument. Unsupported API changes, duplicates and continuations remain blocked. The patch was checked against the six supplied MG5 3.7.0 sources; native compilation and amplitudes are still live-run requirements. Do not strip comments from the MG installation or replace generated amplitudes to evade a checker.


## v0.3.2 generated tree and mass includes

The audit driver declares `REAL*8 ZERO` and `PARAMETER (ZERO=0D0)` before
model initialization, matching the original generated driver. This satisfies
the actual massless `pmass.inc` assignments under `IMPLICIT NONE`.

`native_evidence.py` records native links without replacing them or changing
generated code. Link text, resolved target location, target bytes and
executable state are part of the evidence. Internal missing final leaves are
recorded explicitly: MG5 supplies optional dangling include links in these
standalone trees. Such a record is not a successful compilation or a substitute
for any required native artifact. Compile failure, missing output, unsupported
interfaces, and amplitude discrepancies retain their original outcomes.

Only `madgraph/{born_eq,real_eq,real_eg}/standalone` can contain these links in
the outer acceptance evidence. Links cannot escape their individual standalone
tree or point to a directory. Production-source snapshots still reject links.
Both final report sealing and comparator replay use the same policy. Each
native build identity also seals its generated tree, so direct native replay
checks link identity as well as file contents.

The release tests include actual generated mass includes and synthetic build
fixtures. They do not compile MadGraph here; run the direct native CLI early
on the implementation machine before final full acceptance.


## v0.3.3 reader-width correction

MG5 3.7.0 stores numeric parameter tokens in `character*20` fields. The former `.17e` encoding truncates the exponent; `.17g` fits all five fixed benchmark values and preserves their binary values. Amplitudes, normalizations and tolerances are unchanged.

Review re-executed copies of six compiled official drivers with original then corrected cards: every original run fails in the reader and every corrected run passes, including all 60 native/Clifford and candidate/native comparisons per seed. These are archived executables, not fresh compilation or official acceptance.

Use the same Python interpreter throughout acceptance. Historical Python-3.10 seeded requests differ slightly under Python 3.12's altered float summation. A separately labelled retrospective diagnostic reconstructs the original points and all 62 native checks. Official generation and exact identity checks remain unchanged. Do not rewrite request files or apply that diagnostic adapter to official checks.
