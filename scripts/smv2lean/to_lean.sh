#!/usr/bin/env bash
# Translate a Day-2 SMV model into a Day-3 (CounterDemo) Lean transition system.
#
#   Usage:  scripts/smv2lean/to_lean.sh <model.smv> [ModuleName]
#
# Writes  day03/examples/CounterDemo/CounterDemo/NuXMV/<ModuleName>.lean  with the
# framework import retargeted to `CounterDemo.TransitionSystem`. ModuleName
# defaults to the capitalized model basename (elevator.smv -> Elevator).
#
# The result is a transition system with one `sorry`-stub theorem per INVARSPEC:
# a ready-made "translate-then-prove" exercise that ties a Day-2 model to a Day-3
# Lean proof. Put the completed proofs in a sibling `<ModuleName>Proofs.lean`.
#
# Requires `lark` (pip install -r scripts/smv2lean/requirements.txt).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
smv="${1:?usage: to_lean.sh <model.smv> [ModuleName]}"
name="${2:-$(python -c "import os,sys;print(os.path.splitext(os.path.basename(sys.argv[1]))[0].capitalize())" "$smv")}"
dest="$root/day03/examples/CounterDemo/CounterDemo/NuXMV/$name.lean"
python "$here/smv2lean.py" "$smv" "$dest"
sed -i 's/VerifDemo\./CounterDemo./g' "$dest"
echo "wrote $dest  (module CounterDemo.NuXMV.$name)"
