# v0.5.1 SIDIS reuse instructions for the Collins ep agent

**Status:** source-reuse instructions incorporated into the v0.5.1 validator release. Read this file together with AGENT_PROMPT.md and docs/INTERFACE.md. The executable acceptance contract is contract.json.

## Mission and locations

Implement the Collins ep reverse-unitarity route by adapting the existing SIDIS machinery wherever the mathematical operation applies. Work under `/bigTMD/collins_ep_analytic_SIDIS`. Keep `/bigTMD/collins_ep_analytic` as the existing analytical comparison engine. Preserve the upstream SIDIS checkout, accepted sources, validators, baselines and historical evidence.

Use the same applicable conventions as the pinned SIDIS workflow. Record additional conventions required for transverse spin, TMD operators, fragmentation and rapidity subtraction explicitly. Compare with the literature through documented conversions; do not change the calculation merely to force agreement with a printed equation.

Source repository: [NonHermitianMatrix/SIDIS_dsigma_till_NLO](https://github.com/NonHermitianMatrix/SIDIS_dsigma_till_NLO/tree/5062dcb2407594dafcc2f9f72800e96ff9e6d957/SIDIS).

**Approved revision:** `5062dcb2407594dafcc2f9f72800e96ff9e6d957`. Use this revision, not moving `main`. Verify the source identities against the machine-readable inventory below. A different local revision must be recorded separately; obtain the pinned files in an isolated location without resetting the user's checkout.

## Explicit approved source list

The following **20 files** may be copied, extracted into helpers, or modified in the new implementation. Approval applies to source algorithms and the specified roles, not to all physics assumptions inside each driver. No file is certified as a drop-in Collins implementation. Prefer adapting these files over duplicating applicable machinery. If a listed file is unnecessary, record the concrete reason in the reuse ledger.

Paths in the first column are relative to the upstream repository. The default destination is the same path with `SIDIS/` replaced by `/bigTMD/collins_ep_analytic_SIDIS/`. If code is split or renamed, record every destination in the ledger.

| Approved source file | Reuse | Required Collins adaptation |
|---|---|---|
| `SIDIS/common/s01_import_inputs.py` | Input staging, hashes and source manifests. | Replace the fixed SIDIS channel list and historical result loaders with the declared Collins amplitude/operator inputs. Imported results must never be represented as fresh derivations. |
| `SIDIS/common/s02_definitions.wl` | Invariant algebra, on-shell relations and cut-geometry construction. | Derive the ep kinematics, UU/UT projectors, measurement definitions and cut set. Do not inherit the original geometry or two-cut assumption without proof. |
| `SIDIS/common/s03_real_families.wl` | Mapping real-interference expressions to cut-integral families; reconstruction checks. | Supply the Collins numerator, denominators, cut routing and measurement support. Reconstruct the actual input expression, including spin-dependent terms. |
| `SIDIS/common/s04_reduce_real.wl` | Kira job generation, target reduction, Fermat handling and reduction checks. | Generate jobs from the new families and actual targets. Adapt cut positions, sector restrictions, bounds and runtime paths. |
| `SIDIS/common/s05_virtual_families.wl` | FeynCalc scalarization and reconstruction of loop-interference integrands. | Replace SIDIS photon projectors, coupling stripping, channels and momentum relations with the correct ep UU/UT definitions. |
| `SIDIS/common/s08_cut_master_inputs.wl` | Derivation of positive-energy cut phase space and Euler representations. | Derive the new Jacobians, phase-space normalization and measurement boundaries. Its existing scalar classes and unit-index restrictions are limited; extend them when needed instead of forcing unsupported masters into them. |
| `SIDIS/common/s09_reduce_virtual.wl` | Virtual-family canonicalization and actual Kira reduction. | Supply the new virtual families, coefficient targets, required orders and runtime paths. |
| `SIDIS/common/s10_evaluate_cut_masters.wl` | Executable SubTropica evaluation of cut-master Euler inputs, with prefactors and provenance. | Evaluate the newly derived cut inputs to the required regulator orders. Include every measure and normalization factor in the consumed result. |
| `SIDIS/common/s11_real_master_coefficients.wl` | Combining real numerator maps with Kira rules and determining expansion orders. | Replace fixed channel bindings with the new UU/UT sector identities; determine orders from the actual coefficient poles. |
| `SIDIS/common/s12_virtual_master_inputs.wl` | Constructing Feynman/Euler parameters for the masters found by virtual reduction. | Derive the new topology invariants and required regulator depth; state the physical continuation. |
| `SIDIS/common/s13_evaluate_virtual_masters.wl` | SubTropica evaluation and recording of virtual master inputs and outputs. | Use the new inputs, expansion orders and physical continuation. Keep the evaluated masters connected to the final coefficients. |
| `SIDIS/common/s14_uv_residues.wl` | Auxiliary-mass UV rearrangement, amplitude projections and Kira/SubTropica machinery. | Adapt field content, projectors and coupling normalization. Disable the inherited historical UV-map shortcut for fresh acceptance; regenerate current inputs, maps and reductions. |
| `SIDIS/common/s15_cut_soft_regions.wl` | Deriving endpoint regions from actual cut-master inputs; Taylor and regulator-order bookkeeping. | Derive regions appropriate to the Collins measurement and regulators. The SIDIS recoil endpoint is not automatically the Collins soft or rapidity subtraction. |
| `SIDIS/common/s16_collinear_inputs.wl` | Counterterm input validation and staging pattern. | Replace extraction from historical SIDIS factorization scripts with explicit Collins counterterm/operator inputs. Its imported subtraction formulas do not constitute a new derivation. |
| `SIDIS/common/s17_assemble_real.wl` | Regulated real assembly and delta/plus/regular distribution expansion. | Derive the appropriate variables, support interval, endpoint contacts and subtraction prescription. Retain all regulator terms that contribute to finite coefficients. |
| `SIDIS/common/s18_virtual_coefficients.wl` | Combining rational virtual coefficients with Kira reductions and determining master orders. | Bind the current ep interference expressions and UU/UT projections; remove original channel assumptions. |
| `SIDIS/common/s19_assemble_virtual.wl` | Master expansion, loop measure, continuation and UV/IR bookkeeping. | Use the correct ep coupling powers, field factors, renormalization and regulator conventions. Account explicitly for scaleless-integral UV/IR separation where relevant. |
| `SIDIS/common/s20_final_hats.wl` | Final real/virtual/subtraction assembly, pole checks and export pattern. | Replace the original six channels, F1/F2 projections and subtraction inputs with symbolic Collins ep UU/UT assembly. Generate the finite coefficients from the new results; preserve the declared perturbative truncation. |
| `SIDIS/common/s21_organize_layout.py` | Layout manifests, shared-stage links and relocation bookkeeping as a template. | Replace its hard-coded six-channel migration with the new engine's sector map. Confine every write and move to the new implementation; do not run the original migration against either existing engine. |
| `SIDIS/common/s22_paths.wl` | Path resolution, source aliases and provenance helpers. | Bind all writable paths to the new implementation/state. Record adapted source hashes separately from upstream snapshots; an upstream hash is not the identity of newly executed code. |

## Reuse rules and provenance

1. Preserve the exact upstream bytes and existing attribution for the files actually used, under `provenance/sidis/5062dcb2407594dafcc2f9f72800e96ff9e6d957/`. Execute adapted copies, with their own identities. Existing tool installations remain runtime dependencies; this list does not authorize replacing them.
2. Write `provenance/SIDIS_REUSE_MANIFEST.json` with one entry for each approved file: used or unused, upstream path and blob identity, local SHA-256, functions reused, destination files and SHA-256 values, reason for edits, and consuming stages. Enumerate additional internal source dependencies explicitly. Read-only inspection of the wider repository is allowed; this list does not silently approve recursive copying of it.
3. Routine adaptations and new Collins-specific helpers within the new engine are authorized. An unlisted SIDIS source is outside this particular reuse list: record any proposed addition by exact path, revision and purpose, and continue work that does not depend on that addition. Do not replace missing inputs with historical answers.
4. Regenerate the relevant amplitudes/operator projections, integral maps, Kira jobs and reductions, master representations, SubTropica evaluations, subtractions and final coefficients in fresh acceptance runs. Reusing a source program is compatible with a fresh derivation. Loading a previous final expression is a replay or comparison, not a fresh derivation of that expression.
5. Share applicable source machinery openly. State which amplitudes, projectors, conventions and algorithms are shared with the existing Collins engine. Describe the comparison as an independently executed integration route to the extent supported; a second directory does not establish complete independence.

## Explicitly excluded as the new derivation backend

- `SIDIS/common/s06_cut_parent_inputs.wl` and `SIDIS/common/s07_evaluate_cut_parents.wl`: the older uncut-parent route is not the approved replacement for evaluating the physical cut masters.
- Historical result directories, evaluated masters, Kira caches, final F-hats and acceptance receipts: these may be read for comparison and debugging, but cannot serve as newly derived Collins outputs or substitute for fresh required runs.
- PaVe/Package-X evaluated integrals and copied angular-master answers: ordinary virtual integration must proceed through Kira and SubTropica; real sectors assigned to reverse unitarity must actually use the cut-integral route. FeynCalc remains appropriate for algebra.
- SIDIS numerical/fit drivers and original six-channel result symlinks: they are not needed as analytical inputs. Build the new channel/sector views from the new dependency map.

## Conventions must be established, not assumed

Create `CONVENTIONS.md` before final assembly. For every applicable item, give the precise pinned SIDIS source definition, the new implementation definition and the equality check or explicit conversion. Cover dimensional regularization and epsilon-dependent spin algebra; metric and momentum routing; color and spin sums/averages; electromagnetic and strong-coupling stripping; loop/phase-space measures and factors of 2 pi; MS-bar factors and scale definitions; cut signs, positive-energy support and i0 prescriptions; and endpoint distributions with their integration intervals.

For quantities the SIDIS implementation does not define, state the additional Collins convention and its source: transverse-spin projectors, fragmentation moments, signs, hadron masses, powers of z, Fourier measures, rapidity regulator and soft subtraction, and finite TMD/hard scheme allocation. Do not label these as inherited SIDIS conventions without a corresponding implementation there.

Keep the applicable SIDIS conventions as the new engine's baseline. If the old Collins engine or a paper uses another convention, transform expressions explicitly for comparison. Do not alter the old engine's accepted files or force either literal paper discrepancy into the new calculation. Keep unresolved convention and literature discrepancies visible in the reports.

## Requirements for the v0.5.1 mission

The separate frozen validator checks more than matching final values; the implementation must supply the following evidence: derive the positive-energy cut replacement and any measurement constraints; verify integrand reconstruction and correct cut-sector reduction; establish that actual Kira outputs and actual SubTropica master evaluations are consumed; retain sufficient regulator orders, finite terms and endpoint contributions; and test selected upstream changes through the downstream assembly in disposable copies. Merely invoking Kira or SubTropica is insufficient evidence of a working route.

Keep fitted PDFs/FFs outside analytical acceptance. Retain the qualified leading-power/narrow-cone physics scope, the documented endpoint qualifications, and the uncertified R=1 status. Reverse unitarity does not by itself add unrestricted nonsingular NLO terms or prove a wider range of validity.

Use the old engine and literature as comparisons after the new expressions are generated. Produce the analytical equation comparison separately from supporting numerical checks, retaining derivation provenance, exact/conversion/mismatch/unverified statuses and all unresolved rows. Run official acceptance only against the separately released v0.5.1 contract; do not infer acceptance from this source-reuse list or invent missing validator commands.

## Machine-readable source identities

`git_blob_sha1` is the upstream Git blob identity, not a SHA-256 checksum. For a materialized source file in a Git repository using SHA-1 objects, `git hash-object --no-filters <file>` must reproduce it. Record the new local SHA-256 independently. Destination paths below are relative to `implementation_root`; they are defaults that may be replaced by an explicit ledger mapping.

```json
{
  "repository": "https://github.com/NonHermitianMatrix/SIDIS_dsigma_till_NLO",
  "commit": "5062dcb2407594dafcc2f9f72800e96ff9e6d957",
  "implementation_root": "/bigTMD/collins_ep_analytic_SIDIS",
  "files": [
    {
      "source": "SIDIS/common/s01_import_inputs.py",
      "git_blob_sha1": "a834850aaa05de65824c4b933ff30f846cdbf5c7",
      "destination": "common/s01_import_inputs.py"
    },
    {
      "source": "SIDIS/common/s02_definitions.wl",
      "git_blob_sha1": "2f865a5f8336cfc2f3e6c74b61f2308c3b92a1a8",
      "destination": "common/s02_definitions.wl"
    },
    {
      "source": "SIDIS/common/s03_real_families.wl",
      "git_blob_sha1": "a7d1fa1dc7fda0f9fda2372231f44df074cbaeb5",
      "destination": "common/s03_real_families.wl"
    },
    {
      "source": "SIDIS/common/s04_reduce_real.wl",
      "git_blob_sha1": "24349b5a685d6d591aa86e8fc66794588d1965e5",
      "destination": "common/s04_reduce_real.wl"
    },
    {
      "source": "SIDIS/common/s05_virtual_families.wl",
      "git_blob_sha1": "72432a45dc652f0b67b2f1ffe578a9b791b8d3c1",
      "destination": "common/s05_virtual_families.wl"
    },
    {
      "source": "SIDIS/common/s08_cut_master_inputs.wl",
      "git_blob_sha1": "67a45d4c23b208fd39498dc0d7c6a6f1a5868f97",
      "destination": "common/s08_cut_master_inputs.wl"
    },
    {
      "source": "SIDIS/common/s09_reduce_virtual.wl",
      "git_blob_sha1": "487fbe2a4d7d7b547c1f0c72fd0787c7046bb563",
      "destination": "common/s09_reduce_virtual.wl"
    },
    {
      "source": "SIDIS/common/s10_evaluate_cut_masters.wl",
      "git_blob_sha1": "5ca4d022939731e188ef1226002521e2c31c450b",
      "destination": "common/s10_evaluate_cut_masters.wl"
    },
    {
      "source": "SIDIS/common/s11_real_master_coefficients.wl",
      "git_blob_sha1": "90f26d635c2647366d7d6ae3fc9b11bfe171d6c5",
      "destination": "common/s11_real_master_coefficients.wl"
    },
    {
      "source": "SIDIS/common/s12_virtual_master_inputs.wl",
      "git_blob_sha1": "32daf5e4a54698346affbd4fa4557ec44a5e3c4f",
      "destination": "common/s12_virtual_master_inputs.wl"
    },
    {
      "source": "SIDIS/common/s13_evaluate_virtual_masters.wl",
      "git_blob_sha1": "a4b39dbacdf933fd56e91633258530fc641fb4c8",
      "destination": "common/s13_evaluate_virtual_masters.wl"
    },
    {
      "source": "SIDIS/common/s14_uv_residues.wl",
      "git_blob_sha1": "8960a2a583e308cf9ef8264f6e9973cc8bbc1e34",
      "destination": "common/s14_uv_residues.wl"
    },
    {
      "source": "SIDIS/common/s15_cut_soft_regions.wl",
      "git_blob_sha1": "d19ac75d76721353a823c61df898e3c29278f18a",
      "destination": "common/s15_cut_soft_regions.wl"
    },
    {
      "source": "SIDIS/common/s16_collinear_inputs.wl",
      "git_blob_sha1": "a0ee6765708a25be2b8664aeda06b413cc52804e",
      "destination": "common/s16_collinear_inputs.wl"
    },
    {
      "source": "SIDIS/common/s17_assemble_real.wl",
      "git_blob_sha1": "0ae660d2e17c2da98a7eab5bd125d51f306ef2ab",
      "destination": "common/s17_assemble_real.wl"
    },
    {
      "source": "SIDIS/common/s18_virtual_coefficients.wl",
      "git_blob_sha1": "fab7274ad498a3fc2055b623d784a80cff4e3399",
      "destination": "common/s18_virtual_coefficients.wl"
    },
    {
      "source": "SIDIS/common/s19_assemble_virtual.wl",
      "git_blob_sha1": "08d10b15469c9eedcd89dbfd2308609bda200b8e",
      "destination": "common/s19_assemble_virtual.wl"
    },
    {
      "source": "SIDIS/common/s20_final_hats.wl",
      "git_blob_sha1": "8ea8a26d8bbb54c75926c7fb9f407ce039d06526",
      "destination": "common/s20_final_hats.wl"
    },
    {
      "source": "SIDIS/common/s21_organize_layout.py",
      "git_blob_sha1": "0eaad5b3c99306aff9ef176a1fa6d1592c50a47b",
      "destination": "common/s21_organize_layout.py"
    },
    {
      "source": "SIDIS/common/s22_paths.wl",
      "git_blob_sha1": "c01e2487535df6bd821272912170eda0ed65d065",
      "destination": "common/s22_paths.wl"
    }
  ]
}
```

