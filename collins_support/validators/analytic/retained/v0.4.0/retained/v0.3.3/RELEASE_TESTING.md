# Release verification scope

The complete self-test runs in an isolated build and again after extracting the final ZIP. Its exact result is in the delivered receipt. It checks arithmetic, coherent spin, source-format fixtures, preservation, replay and mocked orchestration; self-tests do not execute native physics tools.

Four new tests exercise actual MG5 reader/card fixtures: original truncation, all five exact benchmark round trips, idempotence and preservation of unrelated lines. One additional test preserves original lock bytes while accepting the exact v0.3.2 issuer.

Separate review verifies all 9,903 archive entries including 216 symlinks, and re-executes copies of six compiled official drivers. Every original card fails; every corrected card succeeds. All 60 amplitude comparisons per seed pass, with maximum candidate residual 1.942890293094024e-16. This is archived-binary execution at recorded kinematics, not fresh generation, compilation or candidate extraction.

Ordinary exact Python-3.10 archive replay fails under Python 3.12 because a few seeded request components differ in the last bits. An explicit pre-3.12 summation diagnostic independently reconstructs the original requests and replays all 62 native checks per seed. This retrospective diagnostic is outside official acceptance and never changes source, tolerance or identity requirements. Keep a consistent interpreter through new acceptance runs.

`review/review_received_v032.py` and its receipt reproduce these supplementary checks, optionally executing copies of the supplied binaries. No Fortran compiler, WolframKernel, Kira or MadGraph generator is available here; the installed Fortran runtime can execute archived binaries. No fresh analytical derivation or native compilation was performed here.
