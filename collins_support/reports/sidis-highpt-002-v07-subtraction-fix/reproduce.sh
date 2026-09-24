#!/bin/bash
# Reproduce the Congyue hard-coefficient comparison from this repository.
#
# Inputs it needs that are NOT part of this sync:
#   * the preserved run 20260916T095719Z-1584d7f6dd71 (reused Born, real and
#     reduction artifacts), or a rebuild of the affected stages from it;
#   * Congyue's SIDIS_HighPT_TT_HardCoefficients package, which is an
#     independent benchmark input and is never a replacement for our own
#     coefficients.
#
# Usage:
#   reproduce.sh <native-hard.wl> <congyue-package-dir> <unused-output-dir>
set -eu
HARD=${1:?path to r07 hard-basis/native-hard.wl}
PKG=${2:?path to the extracted SIDIS_HighPT_TT_HardCoefficients directory}
OUT=${3:?an unused output directory}
REPO=$(cd "$(dirname "$0")/../../.." && pwd)

export PYTHONDONTWRITEBYTECODE=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1

SIDIS_CONGYUE_PACKAGE="$PKG" \
SIDIS_NATIVE_HARD_INPUT="$HARD" \
SIDIS_COMPARE_OUT="$OUT" \
SIDIS_COMPARE_SYMBOLIC=false \
SIDIS_COMPARE_TIMEOUT=300 \
  wolframscript -file "$REPO/collins_sidis_highpt/tools/checks/compare_congyue_hard.wls"

# The comparison reads both sides only. It writes numerical-comparison.wl into
# OUT and prints one row per comparison. It applies the derived conversions
# documented in README.md to Congyue's files; it does not tune any tolerance or
# convention, and it never substitutes Congyue's values into our coefficients.
