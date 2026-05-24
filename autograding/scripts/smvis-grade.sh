#!/usr/bin/env bash
# smvis-grade.sh — grade a Day 2 (SMV / model checking) submission.
#
# Runs the student's .smv model through NuSMV (baked into the image; or nuXmv if
# present locally) and checks that the matching specification(s) report the
# expected verdict.
#
# Usage:
#   smvis-grade [--contains] <model.smv> <expected> <spec-text>
#     <model.smv>   path to the student's SMV model
#     <expected>    "true" or "false" — the verdict you require
#     <spec-text>   the specification as nuXmv echoes it, e.g. "x <= count_max"
#                   By default this is matched EXACTLY against the spec text
#                   nuXmv prints (so "x <= count_max" does NOT also match
#                   "x <= count_max / 2"). Pass --contains for substring match.
#
# To find the exact spec text, run `nuXmv -dynamic model.smv` once and copy the
# text between "-- specification|invariant " and "  is true|false".
#
# Exit 0 = pass, non-zero = fail.
set -uo pipefail

CONTAINS=0
if [[ "${1:-}" == "--contains" ]]; then CONTAINS=1; shift; fi

MODEL="${1:?usage: smvis-grade [--contains] <model.smv> <true|false> <spec-text>}"
EXPECTED="${2:?expected verdict required: true or false}"
NEEDLE="${3:?spec text required}"

if [[ ! -f "$MODEL" ]]; then echo "FAIL: model not found: $MODEL"; exit 2; fi
case "$EXPECTED" in true|false) ;; *) echo "FAIL: expected must be 'true' or 'false'"; exit 2;; esac

# Use whichever SMV model checker is present: NuSMV (in the autograding image)
# or nuXmv (if you run this locally with nuXmv installed). Both share the SMV
# language and the "-- specification|invariant ... is true|false" output.
if command -v NuSMV >/dev/null 2>&1; then
    MC=NuSMV
elif command -v nuXmv >/dev/null 2>&1; then
    MC=nuXmv
else
    echo "FAIL: no SMV model checker (NuSMV or nuXmv) on PATH"
    exit 3
fi

OUT="$("$MC" -dynamic "$MODEL" 2>/dev/null)"

# Pull (spec_text, verdict) pairs from nuXmv's output.
#   -- specification <text>  is true|false
#   -- invariant     <text>  is true|false
matched=0
considered=0
failures=""
while IFS= read -r line; do
    [[ "$line" =~ ^--\ (specification|invariant)\ (.+)\ \ is\ (true|false)$ ]] || continue
    spec="${BASH_REMATCH[2]}"
    verdict="${BASH_REMATCH[3]}"
    if [[ $CONTAINS -eq 1 ]]; then
        [[ "$spec" == *"$NEEDLE"* ]] || continue
    else
        [[ "$spec" == "$NEEDLE" ]] || continue
    fi
    matched=$((matched+1))
    considered=$((considered+1))
    if [[ "$verdict" != "$EXPECTED" ]]; then
        failures+="  '${spec}' is ${verdict} (wanted ${EXPECTED})"$'\n'
    fi
done < <(printf '%s\n' "$OUT")

if [[ $matched -eq 0 ]]; then
    echo "FAIL: no spec matching '${NEEDLE}' was checked by nuXmv."
    echo "      Specs nuXmv reported:"
    printf '%s\n' "$OUT" | grep -E -- '-- (specification|invariant) .* is (true|false)' | sed 's/^/        /' | head -20
    exit 1
fi
if [[ -n "$failures" ]]; then
    echo "FAIL: verdict mismatch:"
    printf '%s' "$failures"
    exit 1
fi
echo "PASS: ${matched} spec(s) matching '${NEEDLE}' are '${EXPECTED}'"
exit 0
