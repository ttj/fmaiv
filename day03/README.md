# Day 3 — Theorem proving with Lean 4 and Claude Code

The same counter we model-checked in Day 2, now proved from first principles in Lean 4. By the end of Day 3, participants have written and built at least one Lean proof, and have used Claude Code as a proof pair partner.

## Schedule

About three hours of lecture and live, hands-on work in three blocks, plus a take-home mini-project. The slide deck (`slides/day03.md`) follows this same structure.

| Block | Approx. length | Content |
|---|---|---|
| Opening | ~10 min | Why theorem proving on top of model checking: parametric / unbounded systems, mathematical content, end-to-end correctness. |
| L1 — Why proving & what Lean is | ~50 min | Lean 4 essentials: terms, types, `def`, `theorem`; core tactics (`intro`, `exact`, `rfl`, `simp`, `omega`). The current Lean moment (PFR, Mathlib, AlphaProof, DeepSeek-Prover). Mathlib search in ten minutes: `exact?`, `apply?`, search-by-conclusion, naming conventions. |
| Break | ~10 min | |
| L2 — Lean by example: the counter | ~50 min | The Day 2 counter reincarnated as a `TransitionSystem CounterState` (`CounterDemo/TransitionSystem.lean`, `Counter.lean`). Inductive invariants and the strengthening pattern; walk through `counterInv_init` and the first case of `counterInv_step`. Smoke test: `lake build` (five expected `sorry` warnings). |
| Break | ~10 min | |
| L3 — AI in the loop + Lean for real | ~50 min | Hands-on walk-through of `CounterDemo/CounterProofs.lean`: the strengthened invariant, the init lemma, the step lemma's case split, and how each `INVARSPEC` is read off via `invariant_strengthening`. Use Claude Code as a proof pair partner; discuss where it was right and where it bluffed. |
| Wrap | ~10 min | Recap and intro to the take-home mini-project. |

**Take-home mini-project** (see `assignments/day03.md`): finish or extend a proof, using Claude Code as a pair partner.

## Learning objectives for Day 3

By the end of the day, participants will be able to:

- Read and write basic Lean 4 syntax and run a Lean proof to completion.
- Define a transition system in Lean and state an invariant property of it.
- Apply the inductive-invariant pattern: prove the invariant holds initially, prove it is preserved by each transition, derive the user-facing property by strengthening.
- Use Claude Code as a pair partner for proof construction, and recognize when its suggested step is wrong.

## Files

```
day03/
├── README.md
├── slides/day03.md
├── examples/
│   └── CounterDemo/
│       ├── lakefile.toml
│       ├── lean-toolchain
│       ├── CounterDemo.lean              ← root module
│       └── CounterDemo/
│           ├── TransitionSystem.lean     ← T = (S, S0, →) + Invariant + InductiveInvariant
│           ├── Counter.lean              ← the counter, mechanically translated from counter.smv
│           └── CounterProofs.lean        ← the three INVARSPEC theorems, proved
└── assignments/day03.md
```

The Lean files in `examples/CounterDemo/` are clones from <https://github.com/ttj/leansmv>, edited only to retarget the `import` statements at the local `CounterDemo` namespace. The repo is Mathlib-free for the counter material (Mathlib is needed only for the continuous models used elsewhere in that project).

## Running

```bash
cd examples/CounterDemo
lake build                # full project, builds clean with five expected sorry warnings
lake build CounterDemo.CounterProofs   # just the proofs file, much faster
```

Open in VS Code with the Lean 4 extension installed for the interactive proof state.
