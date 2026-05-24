#!/usr/bin/env bash
# Execute notebooks headlessly via nbconvert, failing on the first cell error.
# The per-day runner notebooks find the checked-out repo (no clone) and run the
# real day0N/examples files, so this is a true end-to-end test of both the
# notebooks and the examples.
#
# Usage (from the repo root):
#   bash scripts/run_notebooks.sh notebooks/01_day1_logic_sat_smt.ipynb [more.ipynb ...]
#
# Works in CI (the course image, PEP 668 -> --break-system-packages) and in a
# plain venv / Codespace. Requires the relevant tools already on PATH:
#   01 -> z3 ; 02 -> NuSMV ; 03 -> lean/lake ; 04 -> cbmc/cryptol/saw ;
#   05,06 -> torch/torchvision/auto_LiRPA.
set -euo pipefail

# Install nbconvert (idempotent). Try PEP-668 override first (course image), then
# fall back to a normal install (setup-python / venv).
pip install --break-system-packages -q nbconvert nbclient ipykernel 2>/dev/null \
  || pip install -q nbconvert nbclient ipykernel
python3 -m ipykernel install --user >/dev/null 2>&1 || true

fail=0
for nb in "$@"; do
  echo "===== executing $nb ====="
  if python3 -m nbconvert --to notebook --execute --output "/tmp/$(basename "$nb")" \
       --ExecutePreprocessor.timeout=900 --ExecutePreprocessor.kernel_name=python3 "$nb"; then
    echo "  [ok] $nb"
  else
    echo "  [FAIL] $nb"; fail=1
  fi
done

[ "$fail" -eq 0 ] && echo "all notebooks executed cleanly" || { echo "one or more notebooks failed"; exit 1; }
