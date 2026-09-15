# Collins ep analytical calculation

Analytical code for unpolarized UU and Collins UT in electron scattering from a transversely polarized proton, with an identified hadron inside the jet. The implementation covers Born plus one loop at leading power and in the narrow-cone approximation, with the documented physical HF endpoint class. Hadronic distributions and fragmentation functions remain symbolic.

| Review | TODOs |
|---|---|
| Follow the derivation | [Engine stage map](collins_ep_analytic_SIDIS/README.md) and `collins_ep_analytic_SIDIS/common/` |
| Check conventions and source reuse | [Conventions](collins_ep_analytic_SIDIS/CONVENTIONS.md) and [reuse ledger](collins_ep_analytic_SIDIS/provenance/SIDIS_REUSE_MANIFEST.json) |
| Compare with analytical results | [Analytical comparison PDF](collins_ep_analytic_SIDIS_review/reverse-unitarity-002/EQUATION_COMPARISON_ANALYTICAL_RU.pdf) |
| Inspect supporting numerical comparisons | [Numerical comparison PDF](collins_ep_analytic_SIDIS_review/reverse-unitarity-002/EQUATION_COMPARISON_NUMERICAL_RU.pdf) |
| Review uncertainties | [Scientific review](collins_ep_analytic_SIDIS_review/reverse-unitarity-002/SCIENTIFIC_REVIEW.md) and [limitations](collins_ep_analytic_SIDIS_review/reverse-unitarity-002/LIMITATIONS.md) |
| Run the current code | [Runner and checks](collins_support/README.md) |
| Inspect the latest regression campaign | [Two-run verification report](collins_ep_analytic_SIDIS_review/reverse-unitarity-003/MILESTONE_REPORT.md) |

Real integration uses reverse unitarity, Kira and SubTropica; virtual integration uses ordinary loop families, Kira and SubTropica. FeynArts/FeynCalc supplies the amplitude and operator algebra. Source provenance identifies shared definitions and integration machinery.

The comparison PDFs describe the previously checked implementation. The current package retains all 167 scalar reference expressions, the current native integration checks and dependency probes. Its `reverse_unitarity_current` reports do not replay earlier validators or renew their historical acceptance. Old engine/state trees are not runtime prerequisites. Fresh runs still require the configured native tools.

Review priorities include the physical versus dimensionally regulated spin/Fourier projections, finite scheme conversions, HF normalization and endpoint contacts, and the documented literal reference discrepancies. Agreement with the earlier engine is a regression comparison, not an independent proof of every physical assumption. Generic HF contact coefficients, accuracy at R=1, unrestricted nonsingular NLO, NNLO and closed full twist-three evolution remain uncertified.

Primary references and exact recorded source details are collected in [references.json](collins_support/validators/analytic/references.json): arXiv:2007.07281, 1707.00913, 1505.05589, 1303.2129, 1012.3419, 0903.4680 and 1705.08443. Applicable conventions follow the pinned SIDIS source; additional Collins conventions and explicit conversions are documented separately.
