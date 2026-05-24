#!/usr/bin/env bash
# expect-output.sh — generic "run a command, require a substring (or regex) in
# its output" grader. Covers Day 1 (Z3), Day 4 (CBMC / Cryptol / SAW), and any
# tool whose verdict is a recognizable line of stdout/stderr.
#
# Usage:
#   expect-output [--regex] [--absent] [--timeout SECONDS] "<needle>" -- <cmd> [args...]
#     --regex           treat <needle> as an extended regex (default: literal)
#     --absent          PASS when the needle is NOT found (e.g. forbid "FAILURE")
#     --timeout N       kill the command after N seconds (default 120)
#     <needle>          the text/pattern to look for
#     -- <cmd> ...      the command to run
#
# Examples:
#   expect-output "VERIFICATION SUCCESSFUL" -- cbmc sol.c harness.c --unwind 26 --unwinding-assertions
#   expect-output "Q.E.D." -- cryptol -c ":prove my_prop" sol.cry
#   expect-output --regex "^sat$" -- z3 sol.smt2
#   expect-output --absent "FAILURE" -- cbmc sol.c harness.c --unwind 26
set -uo pipefail

REGEX=0; ABSENT=0; TIMEOUT=120
while [[ "${1:-}" == --* ]]; do
    case "$1" in
        --regex)   REGEX=1; shift ;;
        --absent)  ABSENT=1; shift ;;
        --timeout) TIMEOUT="${2:?}"; shift 2 ;;
        *) echo "FAIL: unknown flag $1"; exit 2 ;;
    esac
done
NEEDLE="${1:?usage: expect-output [flags] <needle> -- <cmd...>}"; shift
[[ "${1:-}" == "--" ]] && shift || { echo "FAIL: expected -- before command"; exit 2; }
if [[ $# -eq 0 ]]; then echo "FAIL: no command given"; exit 2; fi

echo "== running (timeout ${TIMEOUT}s): $* =="
OUT="$(timeout "${TIMEOUT}" "$@" 2>&1)"; RC=$?
printf '%s\n' "$OUT" | tail -40
if [[ $RC -eq 124 ]]; then echo "FAIL: command timed out after ${TIMEOUT}s"; exit 1; fi

if [[ $REGEX -eq 1 ]]; then
    if printf '%s\n' "$OUT" | grep -Eq -- "$NEEDLE"; then FOUND=1; else FOUND=0; fi
else
    if printf '%s\n' "$OUT" | grep -Fq -- "$NEEDLE"; then FOUND=1; else FOUND=0; fi
fi

if [[ $ABSENT -eq 1 ]]; then
    if [[ $FOUND -eq 1 ]]; then echo "FAIL: forbidden text present: '$NEEDLE'"; exit 1; fi
    echo "PASS: '$NEEDLE' absent"; exit 0
else
    if [[ $FOUND -eq 0 ]]; then echo "FAIL: expected text not found: '$NEEDLE'"; exit 1; fi
    echo "PASS: '$NEEDLE' found"; exit 0
fi
