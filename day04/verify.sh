#!/usr/bin/env bash
# Day 4 — smoke test. Runs the three reference checks the slides + assignment
# walk through, in order. Designed to be run inside the Docker container.
#
#     docker compose run --rm day04 ./verify.sh
#
# Exits non-zero on the first failure so a participant can tell at a glance
# whether their container is set up correctly. These checks mirror the Day-4
# section of scripts/check_examples.sh (the CI source of truth) — keep the flags
# (e.g. cbmc --unwind 26) in sync if you change them there.

set -euo pipefail

cd "$(dirname "$0")/examples"

banner() { printf '\n=== %s ===\n' "$1"; }

banner "CBMC: counter.c with --unwind 26 (expect VERIFICATION SUCCESSFUL)"
cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions | tail -20
echo

banner "Cryptol: :prove bounded_invariant on counter.cry (expect Q.E.D.)"
cryptol -c ":prove bounded_invariant" counter.cry | tail -10
echo

banner "Cryptol: :prove inductive_invariant on counter.cry (expect Q.E.D.)"
cryptol -c ":prove inductive_invariant" counter.cry | tail -10
echo

banner "Cryptol: :prove popcount_kernighan_eq (expect Q.E.D.)"
cryptol -c ":prove popcount_kernighan_eq" popcount.cry | tail -10
echo

banner "SAW: C ↔ Cryptol popcount equivalence (expect 'Proof succeeded! popcount_loop')"
clang -c -emit-llvm -O0 -o popcount.bc popcount.c
saw popcount.saw | tail -10
echo

banner "All Day 4 checks passed."
