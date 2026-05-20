# Day 3 — Theorem proving with Lean 4 and Claude Code

The same counter we model-checked in Day 2, now proved from first principles in Lean 4. By the end of Day 3, participants have written and built at least one Lean proof, and have used Claude Code as a proof pair partner.

## Schedule

### Lecture and live demo

| Block | Approx. length | Content |
|---|---|---|
| 3.1 | ~15 min | Why theorem proving on top of model checking. Parametric / unbounded systems, mathematical content, end-to-end correctness. |
| 3.2 | ~40 min | Lean 4 essentials. Terms, types, `def`, `theorem`. The core tactics: `intro`, `exact`, `rfl`, `simp`, `omega`. Live: walk through Tutorial World on the Lean Game Server. |
| 3.3 | ~15 min | Mathlib in ten minutes. `exact?`, `apply?`, search-by-conclusion, name conventions. |
| 3.4 | ~25 min | Transition systems in Lean. Open `CounterDemo/TransitionSystem.lean` and `CounterDemo/Counter.lean`; see the SMV file from Day 2 reincarnated as a `TransitionSystem CounterState`. |
| 3.5 | ~25 min | Inductive invariants. The strengthening pattern. Walk through `counterInv_init` and the first case of `counterInv_step`. |

### Hands-on

| Block | Approx. length | Activity |
|---|---|---|
| 3.6 | ~15 min | Smoke test: `lake build` in `examples/CounterDemo`. The five `sorry` warnings in `Counter.lean` are expected (auto-generated stubs); the real proofs are in `CounterProofs.lean`. |
| 3.7 | ~30 min | Walk through `CounterDemo/CounterProofs.lean`. Identify (a) the strengthened invariant, (b) the init lemma, (c) the step lemma's case split, (d) how each `INVARSPEC` is read off via `invariant_strengthening`. |
| 3.8 | ~45 min | Mini-project (see `assignments/day03.md`): finish or extend a proof. Use Claude Code as a pair partner. |
| 3.9 | ~30 min | Share what worked, what surprised. Discuss where Claude was right and where it bluffed. |

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
