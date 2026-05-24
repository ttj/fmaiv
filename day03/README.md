# Day 3 — Theorem proving with Lean 4 and Claude Code

The same counter we model-checked in Day 2, now proved from first principles in Lean 4. By the end of Day 3, participants have written and built at least one Lean proof, and have used Claude Code as a proof pair partner.

## Schedule

About three hours of lecture and live, hands-on work in three blocks, plus a take-home mini-project. The slide deck (`slides/day03.md`) follows this same structure.

| Block | Approx. length | Content |
|---|---|---|
| Opening | ~10 min | Why theorem proving on top of model checking: parametric / unbounded systems, mathematical content, end-to-end correctness. |
| L1 — Why proving & what Lean is | ~50 min | Lean 4 essentials: terms, types, `def`, `theorem`; core tactics (`intro`, `exact`, `rfl`, `simp`, `omega`). The current Lean moment (PFR, Mathlib, AlphaProof, DeepSeek-Prover). Mathlib search in ten minutes: `exact?`, `apply?`, search-by-conclusion, naming conventions. |
| Break | ~10 min | |
| L2 — Lean by example: the counter | ~50 min | The Day 2 counter reincarnated as a `TransitionSystem CounterState` (`CounterDemo/TransitionSystem.lean`, `Counter.lean`). Inductive invariants and the strengthening pattern; walk through `counterInv_init` and the first case of `counterInv_step`. Smoke test: `lake build` (builds successfully and **sorry-free** — the translator-generated `NuXMV/{Gcd,Mutex}.lean` are commented stubs, with the real proofs in `*Proofs.lean`). |
| Break | ~10 min | |
| L3 — AI in the loop + Lean for real | ~50 min | Hands-on walk-through of `CounterDemo/Counter.lean`: the strengthened invariant, the init lemma, the step lemma's case split, and how each `INVARSPEC` is read off via `invariant_strengthening`. Use Claude Code as a proof pair partner; discuss where it was right and where it bluffed. |
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
│           ├── TransitionSystem.lean     ← framework: TransitionSystem, Invariant, InductiveInvariant, k-induction, ranking functions
│           ├── DiscreteMath.lean         ← gentle intro: set theory in Lean (subset, De Morgan, ∩ over ∪)
│           ├── Counter.lean              ← the counter: transition system + proved invariants (solution)
│           ├── CounterLadder.lean        ← a 6-rung tactic ladder climbing to the counter's base case
│           ├── ArraySum.lean             ← list sum + a loop invariant
│           ├── Sorting.lean              ← insertion sort proved to produce a sorted list
│           ├── Gcd.lean                  ← Euclid's GCD; termination via a ranking function
│           ├── TrafficLight.lean         ← traffic-light transition system + safety invariant
│           ├── ProgramVerif/             ← the IMP language: big-step semantics + Hoare-style examples (Imp, Examples)
│           ├── NuXMV/                     ← Day-2 SMV models translated to Lean: Gcd, Mutex, Elevator (worked, with *Proofs); Peterson, Prodcons (stubs — samplers mixing true/false INVARSPECs to prove or refute)
│           └── *Starter.lean             ← starter version of several modules (proofs stubbed with `sorry`)
└── assignments/day03.md
```

The transition-system framework, counter, set-theory intro (`DiscreteMath`), IMP program-verification language (`ProgramVerif/`), and SMV-translated proofs (`NuXMV/`) are vendored from <https://github.com/ttj/leansmv> (retargeted at the local `CounterDemo` namespace, **Mathlib-free**). The `NuXMV/*.lean` transition systems were generated from the Day-2 `.smv` models by the `smv2lean` translator (vendored in [`scripts/smv2lean/`](../../scripts/smv2lean/)); proofs are added by hand in `*Proofs.lean`. Translate any other Day-2 model into a ready-to-prove Day-3 module with one command: `scripts/smv2lean/to_lean.sh day02/examples/<model>.smv`. For the deeper upstream material — parametric N-process mutex and the ~6,000-line *Cellular Flows* research formalization (which uses Mathlib) — see the upstream project. Each concept has a solution module (`Foo.lean`, no `sorry`) and most have a starter (`FooStarter.lean`).

## Running

```bash
cd examples/CounterDemo
lake build                # whole project, builds clean (every solution module is proved)
lake build CounterDemo.CounterStarter   # a starter: builds with `sorry` until you finish it
```

Open in VS Code with the Lean 4 extension installed for the interactive proof state.
