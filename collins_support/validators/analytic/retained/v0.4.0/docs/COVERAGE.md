# Obligation coverage and review boundary

Every row below is a required new derivation obligation, not permission to replace it with a matching formula. The automatic checks provide the stated evidence; scientific review examines the producing code and the physical assumptions. A review-record presence check verifies that a record exists, not that its reasoning is correct. See `SCIENTIFIC_REVIEW.md` for the review questions.

| Contract obligation | Automatic evidence | Required scientific review |
|---|---|---|
| measurement.definition | d16 definitions, native artifacts and measurement role | Actual anti-kt/axis measurement and leading-power limit |
| operator.Hhat_HF_basis | d16 operator-basis and independent-HF fields | Complete gauge-invariant operator and chiral-odd projection |
| operator.EOM_and_boundary | d16 EOM/contact and inverse-fraction identities | EOM derivation, Wilson boundary and physical support |
| operator.reference_conversion | d16 Fourier/Jacobian identities, d17 basis-factor restriction | SIDIS spin extension and literal paper normalization map |
| matching.HF_bare | Native regulated artifacts and subtraction identities | Genuine diagrams, D-dimensional numerators, UV/IR separation |
| matching.HF_collinear_pole | All bulk/contact counterterms, mixing and RG identities | Collinear subtraction and physical operator mixing |
| matching.HF_finite | Finite-symbol restrictions, two-route equality, native reexports | Independent finite derivation, including epsilon-times-pole terms |
| matching.HF_rapidity | d17 derivative with respect to the fragment rapidity logarithm is zero | Correct rapidity subtraction and regulator order |
| matching.HF_independent_route | Distinct route artifacts; no primary finite-export ancestor | Independence of the actual computations |
| matching.HF_homogeneous_limit | Exact retained d13 diagonal and transversity packet identity | Correct operator interpretation of the limit |
| jet.measured_bare | Native measured-operator/integrand/reduction artifacts | Quark fragmenting-jet relation under the ep measurement |
| jet.overlap_subtraction | bare + counterterm - overlap = finite for UU and UT | Correct zero-bin/soft allocation and absence of double counting |
| jet.finite_UU_UT | Two-route equality, finite spin equality and symbol restrictions | Proof of the scalar reduction and its finite coefficient |
| jet.RG | Zero anomalous-dimension difference and scale-independent remainder | Derivation at the stated jet rapidity scale |
| jet.independent_route | Distinct native graph branch and finite comparison | Independent measurement/integral computation |
| radius.validity_record | Required native artifact and persistent R=1 qualification | Where R^2 terms were dropped and relation to ep A1–A3 |
| assembly.HF_consumption | All 12 bulk/contact entries, dependency hashes and fresh probes | Full two-fraction operator action and support |
| assembly.jet_consumption | Separate UU/UT first-order coefficients and fresh jet probe | Correct insertion into the measured observable |
| assembly.strict_order | Exact allowed maps and first-order polynomial identities | Full native expression uses the same expansion |
| assembly.homogeneous_paper_limit | Explicit retained-coefficient limit | Limits of its identification with the paper/author implementation |
| assembly.scheme_compensation | Arbitrary finite shifts and compensating cancellation | Derived transformations of the actual factors |
| assembly.integrated_ratio | Exact ratio after a common formal linear integration | Common physical measure, bin variables, charge/flavor sum |
| provenance.native_dependencies | Sealed sources, logs, graph files, dependency receipts | Files actually contain the claimed calculations |
| provenance.upstream_response | Both seeded numerator probes and fresh d19 propagation | Probe insertion occurs upstream, not in the final coefficient |
| reference.literal_comparisons | Both literal bulk residuals retained; supported alternative required | Operator conversion and unresolved source discrepancy |
| comparison.paper_operator_identification | Required d16 review record and native conversion evidence | Equation table with exact references and honest origin/status |

The retained 31 obligations, all retained numerical coefficient and native MadGraph checks, and the old pair comparator run unchanged. The historical 70-row equation inventory is a separate presentation of coverage: its old unresolved rows cannot be erased by adding new passing rows. The updated Markdown/TeX/PDF table is an agent deliverable and an independently reviewed document; automatic acceptance does not inspect the visual PDF or certify every sentence in it.

No fitted provider is loaded by the new machinery. Presence and preservation of historical numerical records in the retained runner do not evaluate those providers. The new tests use exact formal or synthetic functions only.
