#!/usr/bin/env bash
# Run every FMAIV example through its verification tool and assert the verdict.
#
# Usage (from the repo root, or set FMAIV_ROOT):
#   bash scripts/check_examples.sh
# Requires: z3, NuSMV, lean/lake, cbmc, cryptol, saw, clang — all present in the
# course Codespace image (ghcr.io/verivital/fmaiv-autograde) and the Day-4 Docker
# image. nuXmv is license-gated; Day 2 uses NuSMV (same SMV language/verdicts).
set -u
cd "${FMAIV_ROOT:-.}"

PASS=0; FAIL=0; declare -a FAILED
ok(){ printf '  [PASS] %s\n' "$1"; PASS=$((PASS+1)); }
no(){ printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL+1)); FAILED+=("$1"); }
# expect <desc> <regex> <cmd...> : pass iff combined stdout/stderr matches regex
expect(){ local d="$1" re="$2"; shift 2; local o; o="$("$@" 2>&1)"; \
  if grep -qE -- "$re" <<<"$o"; then ok "$d"; else no "$d  [want /$re/]"; sed 's/^/        /' <<<"$o" | tail -4; fi; }
# expect_ok <desc> <cmd...> : pass iff exit code 0
expect_ok(){ local d="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else no "$d  [nonzero exit]"; fi; }

echo "===== Day 1: Z3 ====="
expect "z3_smoke.py -> sat"             "result: sat"  python3 day01/examples/z3_smoke.py
expect "z3_pigeonhole.py -> unsat"      "unsat"        python3 day01/examples/z3_pigeonhole.py
expect "z3_counter_bounded.py -> UNSAT" "UNSAT"        python3 day01/examples/z3_counter_bounded.py
expect "z3_smt_basics.smt2 -> sat"      "^sat"         z3 day01/examples/z3_smt_basics.smt2
expect "puzzles/nqueens.py"             "[Qq.]"        python3 day01/examples/puzzles/nqueens.py
expect "puzzles/sudoku.py"              "[0-9]"        python3 day01/examples/puzzles/sudoku.py
expect "puzzles/magic_square.py"        "[0-9]"        python3 day01/examples/puzzles/magic_square.py
expect "puzzles/kenken.py"              "[0-9]"        python3 day01/examples/puzzles/kenken.py

echo "===== Day 2: NuSMV (specs evaluate without error) ====="
for m in counter mutex peterson prodcons elevator traffic_light gcd_01; do
  expect "NuSMV $m.smv" "is (true|false)" NuSMV "day02/examples/$m.smv"
done

echo "===== Day 3: Lean ====="
( cd day03/examples/CounterDemo && expect_ok "lake build (CounterDemo)" lake build )
for mod in Counter TransitionSystem ArraySum Gcd TrafficLight Sorting; do
  f="day03/examples/CounterDemo/CounterDemo/$mod.lean"
  if grep -qnE '(^|[^[:alnum:]_])sorry([^[:alnum:]_]|$)' "$f"; then no "Day3 $mod.lean: contains sorry"; else ok "Day3 $mod.lean: sorry-free"; fi
done

echo "===== Day 4: CBMC ====="
expect "cbmc counter"   "VERIFICATION SUCCESSFUL" bash -c 'cd day04/examples && cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions'
expect "cbmc array_max" "VERIFICATION SUCCESSFUL" bash -c 'cd day04/examples && cbmc array_max.c array_max_check.c --unwind 6 --unwinding-assertions'
expect "cbmc binsearch" "VERIFICATION SUCCESSFUL" bash -c 'cd day04/examples && cbmc binsearch.c binsearch_check.c --unwind 10 --unwinding-assertions'

echo "===== Day 4: Cryptol (:prove every property -> Q.E.D.) ====="
cryprove(){ local f="$1"; shift; local p; for p in "$@"; do \
  expect "cryptol $f :prove $p" "Q.E.D." cryptol -c ":prove $p" "day04/examples/$f"; done; }
cryprove counter.cry   bounded_invariant inductive_invariant
cryprove popcount.cry  popcount_kernighan_eq
cryprove caesar.cry    roundtrip decrypt_inverts
cryprove xor_cipher.cry roundtrip involutive

echo "===== Day 4: SAW (C <-> Cryptol equivalence) ====="
expect "saw popcount.saw" "Proof succeeded" bash -c 'cd day04/examples && clang -c -emit-llvm -O0 -o popcount.bc popcount.c && saw popcount.saw'

echo
echo "===== SUMMARY: $PASS passed, $FAIL failed ====="
if [ "$FAIL" -gt 0 ]; then printf '  failed: %s\n' "${FAILED[@]}"; exit 1; fi
echo "  all example verifications passed"
