#!/usr/bin/env bash
# Run every FMAIV example through its verification tool and assert the verdict.
#
# Usage (from the repo root, or set FMAIV_ROOT):
#   bash scripts/check_examples.sh
# Requires: z3, NuSMV, lean/lake, cbmc, cryptol, saw, clang — all present in the
# course Codespace image (ghcr.io/ttj/fmaiv-autograde) and the Day-4 Docker
# image. nuXmv is license-gated; Day 2 uses NuSMV (same SMV language/verdicts).
set -u

# ---- optional self-check filtering (autograder mode) ----
#   check_examples.sh                 run everything (CI default)
#   check_examples.sh --only REGEX    run only checks whose description matches
#   check_examples.sh --list          list every check's description and exit
ONLY=""; LIST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --only)   ONLY="${2:-}"; shift 2 ;;
    --only=*) ONLY="${1#--only=}"; shift ;;
    --list)   LIST=1; shift ;;
    -h|--help)
      echo "usage: check_examples.sh [--only REGEX] [--list]"
      echo "  --only REGEX  run only checks whose description matches REGEX (case-insensitive)"
      echo "  --list        list every check's description and exit"
      exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

cd "${FMAIV_ROOT:-.}"

PASS=0; FAIL=0; SKIP=0; declare -a FAILED
ok(){ printf '  [PASS] %s\n' "$1"; PASS=$((PASS+1)); }
no(){ printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL+1)); FAILED+=("$1"); }
# want <desc> : returns 0 (run this check) or 1 (skip). In --list mode it prints
# the description; with --only it skips non-matching checks.
want(){ local d="$1"
  if [ "$LIST" = 1 ]; then printf '  %s\n' "$d"; return 1; fi
  if [ -n "$ONLY" ] && ! grep -qiE -- "$ONLY" <<<"$d"; then SKIP=$((SKIP+1)); return 1; fi
  return 0; }
# expect <desc> <regex> <cmd...> : pass iff combined stdout/stderr matches regex
expect(){ local d="$1" re="$2"; shift 2; want "$d" || return 0; local o; o="$("$@" 2>&1)"; \
  if grep -qE -- "$re" <<<"$o"; then ok "$d"; else no "$d  [want /$re/]"; sed 's/^/        /' <<<"$o" | tail -4; fi; }
# expect_ok <desc> <cmd...> : pass iff exit code 0
expect_ok(){ local d="$1"; shift; want "$d" || return 0; if "$@" >/dev/null 2>&1; then ok "$d"; else no "$d  [nonzero exit]"; fi; }

echo "===== Day 1: Z3 ====="
expect "z3_smoke.py -> sat"             "result: sat"  python3 day01/examples/z3_smoke.py
expect "z3_pigeonhole.py -> unsat"      "unsat"        python3 day01/examples/z3_pigeonhole.py
expect "z3_counter_bounded.py -> UNSAT" "UNSAT"        python3 day01/examples/z3_counter_bounded.py
expect "z3_test_gen.py -> sat (GCD)"    "GCD\(.*\) = " python3 day01/examples/z3_test_gen.py
expect "z3_smt_basics.smt2 -> sat"      "^sat"         z3 day01/examples/z3_smt_basics.smt2
expect "z3_smtlib_demo.smt2 -> sat"     "^sat"         z3 day01/examples/z3_smtlib_demo.smt2
expect "z3_k4_3coloring.smt2 -> unsat"  "^unsat"       z3 day01/examples/z3_k4_3coloring.smt2
expect "z3_c5_3coloring.smt2 -> sat"    "^sat"         z3 day01/examples/z3_c5_3coloring.smt2
expect_ok "z3_entailment.py self-checks"               python3 day01/examples/z3_entailment.py
expect_ok "z3_synthesis.py self-checks"                python3 day01/examples/z3_synthesis.py
expect "puzzles/nqueens.py"             "[Qq.]"        python3 day01/examples/puzzles/nqueens.py
expect "puzzles/sudoku.py"              "[0-9]"        python3 day01/examples/puzzles/sudoku.py
expect "puzzles/magic_square.py"        "[0-9]"        python3 day01/examples/puzzles/magic_square.py
expect "puzzles/kenken.py"              "[0-9]"        python3 day01/examples/puzzles/kenken.py

echo "===== Day 2: NuSMV (specs evaluate without error) ====="
for m in counter mutex peterson prodcons elevator traffic_light gcd_01 spec_challenge bmc_depth; do
  expect "NuSMV $m.smv" "is (true|false)" NuSMV "day02/examples/$m.smv"
done

echo "===== Day 3: Lean ====="
# Build in the parent shell (NOT a subshell) so a failed build actually fails CI;
# print the build output on failure so the Lean error is visible in CI logs.
if want "lake build (CounterDemo)"; then
  o="$( cd day03/examples/CounterDemo && lake build 2>&1 )"
  if [ $? -eq 0 ]; then ok "lake build (CounterDemo)"; else no "lake build (CounterDemo)"; sed 's/^/        /' <<<"$o" | tail -20; fi
fi
for mod in Counter CounterLadder TransitionSystem ArraySum Gcd TrafficLight Sorting SlideExamples \
           DiscreteMath ProgramVerif/Imp ProgramVerif/Examples \
           NuXMV/GcdProofs NuXMV/MutexProofs NuXMV/ElevatorProofs; do
  want "Day3 $mod.lean: sorry-free" || continue
  f="day03/examples/CounterDemo/CounterDemo/$mod.lean"
  if grep -qnE '(^|[^[:alnum:]_])sorry([^[:alnum:]_]|$)' "$f"; then no "Day3 $mod.lean: contains sorry"; else ok "Day3 $mod.lean: sorry-free"; fi
done

echo "===== Day 4: CBMC ====="
expect "cbmc counter"   "VERIFICATION SUCCESSFUL" bash -c 'cd day04/examples && cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions'
expect "cbmc array_max" "VERIFICATION SUCCESSFUL" bash -c 'cd day04/examples && cbmc array_max.c array_max_check.c --unwind 6 --unwinding-assertions'
expect "cbmc binsearch" "VERIFICATION SUCCESSFUL" bash -c 'cd day04/examples && cbmc binsearch.c binsearch_check.c --unwind 10 --unwinding-assertions'
expect "cbmc loop_invariant_demo" "VERIFICATION SUCCESSFUL" bash -c 'cd day04/examples && cbmc loop_invariant_demo.c --unwind 21 --unwinding-assertions'

echo "===== Day 4: Cryptol (:prove every property -> Q.E.D.) ====="
cryprove(){ local f="$1"; shift; local p; for p in "$@"; do \
  expect "cryptol $f :prove $p" "Q.E.D." cryptol -c ":prove $p" "day04/examples/$f"; done; }
cryprove counter.cry   bounded_invariant inductive_invariant
cryprove popcount.cry  popcount_kernighan_eq
cryprove caesar.cry    roundtrip decrypt_inverts
cryprove xor_cipher.cry roundtrip involutive

echo "===== Day 4: SAW (C <-> Cryptol equivalence) ====="
expect "saw popcount.saw" "Proof succeeded" bash -c 'cd day04/examples && clang -c -emit-llvm -O0 -o popcount.bc popcount.c && saw popcount.saw'

echo "===== Day 4 (frontier): NN robustness (auto_LiRPA, optional) ====="
# Skipped in the base grading image (no PyTorch). Runs in a Codespace (deps via
# devcontainer onCreateCommand) and in the dedicated `nn` CI job on ubuntu.
if python3 -c 'import auto_LiRPA' >/dev/null 2>&1; then
  expect "nn robustness.py" "certified up to eps" python3 day04/examples/nn/robustness.py
elif [ "$LIST" = 0 ]; then
  printf '  [SKIP] nn robustness.py (auto_LiRPA not installed in this image)\n'
fi

echo
if [ "$LIST" = 1 ]; then exit 0; fi
echo "===== SUMMARY: $PASS passed, $FAIL failed, $SKIP skipped ====="
if [ "$FAIL" -gt 0 ]; then printf '  failed: %s\n' "${FAILED[@]}"; exit 1; fi
echo "  all example verifications passed"
