# smv2lean — SMV → Lean 4 translator

Vendored from [ttj/leansmv](https://github.com/ttj/leansmv). Parses a NuXMV/NuSMV
`.smv` model and emits a Lean 4 transition system that instantiates the
`TransitionSystem` framework (the same one in `day03/examples/CounterDemo/CounterDemo/TransitionSystem.lean`),
with a `sorry` stub theorem for each `INVARSPEC`. You then prove the stubs by hand.

This is exactly how the Day-3 examples `NuXMV/Gcd.lean` and `NuXMV/Mutex.lean`
were produced (the completed proofs live in `*Proofs.lean`).

## Run

```bash
pip install -r requirements.txt          # lark
python smv2lean.py path/to/model.smv [out.lean]
```

For example, translate a Day-2 model:

```bash
python smv2lean.py ../../day02/examples/mutex.smv Mutex.lean
```

The generated file imports `VerifDemo.TransitionSystem`; if you drop it into the
course's `CounterDemo` project, change that import to `CounterDemo.TransitionSystem`
(as the vendored `NuXMV/*.lean` examples do). This tool is the reference for the
Day-3 assignment's "translate an SMV model into Lean" track (B.3).

Files: `smv2lean.py` (generator), `smv_parser.py` + `smv_grammar.lark` (Lark
parser), `smv_model.py` (AST). For the full translator project, larger models,
and the parametric / cellular-flows formalizations, see
[ttj/leansmv](https://github.com/ttj/leansmv).
