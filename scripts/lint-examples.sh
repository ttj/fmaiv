#!/usr/bin/env bash
# Catch "added an example, forgot to wire it" before it ships.
#
# Walk every example file we'd expect a grader / runner notebook to exercise,
# confirm it is referenced from either scripts/check_examples.sh or one of
# the runner notebooks/*.ipynb.  Fails CI if any file is unreferenced and
# isn't pure scaffolding.
#
# Scaffolding (skipped):
#   *_starter.{c,cry,py,lean}   - student fill-in-the-blanks
#   *_check.c                   - CBMC harness paired with foo.c
#   *.bc                        - generated LLVM bitcode (popcount.bc)
#   *.tmp.*                     - editor scratch files
#   README.md, requirements.txt, lakefile.toml, lake-manifest.json
#
# Lean modules in day03/examples/CounterDemo/CounterDemo/ are checked by
# module name against the explicit list in check_examples.sh (not by
# basename, since lake doesn't grade by file path).
#
# Usage:  bash scripts/lint-examples.sh
# Exit:   0 if all references found; 1 with a punch-list otherwise.

set -u

cd "${FMAIV_ROOT:-.}"

missing=()
ok_count=0
skipped=0

# Is the file referenced from either check_examples.sh or the runner notebooks?
#
# Pass either a full basename ("counter.c") OR a bare stem ("counter") -- the
# latter catches the interpolated form `for m in counter ...; do NuSMV $m.smv`
# that check_examples.sh uses for the Day-2 NuSMV files and the explicit Lean
# module list (`mod` token names like `NuXMV/ElevatorProofs` or `Counter`).
referenced() {
  local needle="$1"
  grep -RqF -- "$needle" scripts/check_examples.sh notebooks/ 2>/dev/null
}

# Should this file be skipped as scaffolding?
is_scaffolding() {
  local base="$1"
  case "$base" in
    *_starter.c|*_starter.cry|*_starter.py|*_starter.smv|*Starter.lean) return 0 ;;
    *_check.c)                                                          return 0 ;;
    *.bc|*.tmp.*)                                                       return 0 ;;
    README.md|requirements.txt|lakefile.toml|lake-manifest.json)        return 0 ;;
    .gitignore|.gitkeep)                                                return 0 ;;
  esac
  return 1
}

scan() {
  local label="$1"; shift
  for f in "$@"; do
    [ -f "$f" ] || continue
    local base stem
    base="$(basename "$f")"
    stem="${base%.*}"                       # foo.smv -> foo; popcount.cry -> popcount
    if is_scaffolding "$base"; then
      skipped=$((skipped + 1))
      continue
    fi
    # Either the full basename appears (`cbmc counter.c`) OR just the stem
    # appears (`for m in counter ... ; NuSMV $m.smv`).  Bias toward the
    # full name first so a longer match wins, then fall back to stem.
    if referenced "$base" || referenced "$stem"; then
      ok_count=$((ok_count + 1))
    else
      missing+=("$f  $label")
    fi
  done
}

# Day 1 -- Z3 + SMT-LIB.
scan "(Day 1 Z3)"        day01/examples/*.py            day01/examples/puzzles/*.py
scan "(Day 1 SMT-LIB)"   day01/examples/*.smt2

# Day 2 -- NuSMV.
scan "(Day 2 NuSMV)"     day02/examples/*.smv

# Day 4 -- CBMC / Cryptol / SAW / NN.
scan "(Day 4 CBMC)"      day04/examples/*.c
scan "(Day 4 Cryptol)"   day04/examples/*.cry
scan "(Day 4 SAW)"       day04/examples/*.saw
scan "(Day 4 NN)"        day04/examples/nn/*.py

# Day 3 Lean -- check by MODULE NAME (mod) rather than file path, since
# check_examples.sh iterates explicit module names.  We exclude *Broken.lean,
# the root CounterDemo.lean re-export, any *Starter.lean (caught earlier),
# and the auto-translated smv2lean stubs in NuXMV/ that have a sibling
# *Proofs.lean (the proofs file IS the graded artifact; the bare stub is
# the translator's pure-data output, like a *_check.c harness).
for f in day03/examples/CounterDemo/CounterDemo/*.lean \
         day03/examples/CounterDemo/CounterDemo/*/*.lean; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  if is_scaffolding "$base"; then skipped=$((skipped + 1)); continue; fi
  case "$base" in
    CounterDemo.lean|CounterBroken.lean) skipped=$((skipped + 1)); continue ;;
    # Translator-generated NuXMV/ stubs.  Peterson/Prodcons have no
    # *Proofs.lean companion -- they exist purely to demonstrate the
    # smv2lean translator round-trip on those SMV models.
    Elevator.lean|Gcd.lean|Mutex.lean|Peterson.lean|Prodcons.lean)
      [ "$(dirname "$f")" = "day03/examples/CounterDemo/CounterDemo/NuXMV" ] && {
        skipped=$((skipped + 1)); continue;
      } ;;
  esac
  mod="${base%.lean}"
  # check_examples.sh references Lean modules by NAME tokens, sometimes
  # path-qualified (e.g. `NuXMV/GcdProofs`, `ProgramVerif/Imp`).  A bare
  # substring match on the stem is enough -- module names are unique
  # enough that false-positives don't bite, and we already excluded the
  # *Starter / *Broken scaffolding.
  if referenced "$mod" || referenced "$base"; then
    ok_count=$((ok_count + 1))
  else
    missing+=("$f  (Day 3 Lean module $mod)")
  fi
done

echo "lint-examples: ${ok_count} referenced, ${skipped} scaffolding-skipped"

if [ "${#missing[@]}" -gt 0 ]; then
  echo ""
  echo "===== EXAMPLES NOT REFERENCED ====="
  printf '  %s\n' "${missing[@]}"
  echo ""
  echo "Each file above lives under day*/examples/ but neither"
  echo "scripts/check_examples.sh nor notebooks/*.ipynb mentions it"
  echo "by name -- a grader / runner notebook is NOT exercising it."
  echo ""
  echo "Fix one of:"
  echo "  (a) add an 'expect' line to scripts/check_examples.sh; OR"
  echo "  (b) add a cell to the appropriate runner notebook; OR"
  echo "  (c) rename to a *_starter.* / *_check.c scaffolding convention; OR"
  echo "  (d) if the file is intentionally not graded, add it to the"
  echo "      is_scaffolding() allowlist in this script with a comment."
  exit 1
fi

echo "all examples referenced from check_examples.sh or notebooks/."
