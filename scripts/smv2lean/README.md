# smv2lean — SMV → Lean 4 translator

Vendored from [ttj/leansmv](https://github.com/ttj/leansmv). Parses a NuXMV/NuSMV
`.smv` model and emits a Lean 4 transition system that instantiates the
`TransitionSystem` framework (the same one in `day03/examples/CounterDemo/CounterDemo/TransitionSystem.lean`),
with a `sorry` stub theorem for each `INVARSPEC`. You then prove the stubs by hand.

This is exactly how the Day-3 examples `NuXMV/Gcd.lean` and `NuXMV/Mutex.lean`
were produced (the completed proofs live in `*Proofs.lean`).

## Translate a Day-2 model into the course (one command)

`to_lean.sh` runs the translator and drops a ready-to-build module into the Day-3
project — it retargets the import to `CounterDemo.TransitionSystem` for you:

```bash
pip install -r requirements.txt          # lark (once)
scripts/smv2lean/to_lean.sh day02/examples/peterson.smv     # -> day03/.../NuXMV/Peterson.lean
```

The result is a transition system with one `sorry`-stub theorem per `INVARSPEC`:
a ready-made "translate-then-prove" exercise. Add the proofs in a sibling
`NuXMV/<Name>Proofs.lean` (see `NuXMV/Gcd.lean`+`GcdProofs.lean`, `Mutex`+`MutexProofs`,
and `Elevator`+`ElevatorProofs` for worked examples). This is the engine behind the
Day-3 assignment's "translate an SMV model into Lean" track (B.3).

## Run the translator directly

```bash
python smv2lean.py path/to/model.smv [out.lean]
```

The raw output imports `VerifDemo.TransitionSystem` (the upstream namespace); the
`to_lean.sh` wrapper rewrites that to `CounterDemo.TransitionSystem`. Do that by
hand if you call `smv2lean.py` directly and drop the result into `CounterDemo`.

Files: `smv2lean.py` (generator), `smv_parser.py` + `smv_grammar.lark` (Lark
parser), `smv_model.py` (AST). For the full translator project, larger models,
and the parametric / cellular-flows formalizations, see
[ttj/leansmv](https://github.com/ttj/leansmv).
