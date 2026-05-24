#!/usr/bin/env bash
# check-no-sorry.sh — grade a Day 3 (Lean) submission.
#
# `lake build` succeeds even when a proof still contains `sorry` (it is a
# warning, not an error), so a green build is NOT enough. This script (1) runs
# `lake build`, then (2) confirms the named theorems are axiom-clean — i.e.
# `#print axioms <thm>` does not list `sorryAx`.
#
# Usage:
#   check-no-sorry <lake-project-dir> <Module.Path> <thm1> [thm2 ...]
#     <lake-project-dir>  directory containing lakefile.toml / lakefile.lean
#     <Module.Path>       Lean module that imports the theorems (e.g. CounterDemo.Counter)
#     <thmN>              fully-qualified theorem names to verify are sorry-free
#
# Exit 0 = pass.
set -uo pipefail

PROJ="${1:?usage: check-no-sorry <project-dir> <Module.Path> <thm...>}"
MODULE="${2:?Lean module path required}"
shift 2
THMS=("$@")
if [[ ${#THMS[@]} -eq 0 ]]; then echo "FAIL: name at least one theorem to check"; exit 2; fi

cd "$PROJ" || { echo "FAIL: cannot cd to $PROJ"; exit 2; }

echo "== lake build =="
if ! lake build 2>&1 | tee /tmp/lake.log; then
    echo "FAIL: lake build did not succeed"
    exit 1
fi

# Build a throwaway checker module that prints axioms for each theorem.
CHK=/tmp/AxiomCheck.lean
{
    echo "import ${MODULE}"
    for t in "${THMS[@]}"; do echo "#print axioms ${t}"; done
} > "$CHK"

echo "== axiom check =="
# `lake env lean` runs lean with the project's build path available.
AXOUT="$(lake env lean "$CHK" 2>&1)"
printf '%s\n' "$AXOUT"

if printf '%s\n' "$AXOUT" | grep -qi "sorryAx"; then
    echo "FAIL: one or more theorems depend on 'sorry' (sorryAx present)"
    exit 1
fi
if printf '%s\n' "$AXOUT" | grep -qiE "error|unknown (identifier|constant)"; then
    echo "FAIL: a named theorem does not exist or did not elaborate"
    exit 1
fi

echo "PASS: ${#THMS[@]} theorem(s) build and are sorry-free"
exit 0
