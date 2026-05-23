# Day 2 — Model checking with nuXmv

The same counter from Day 1, but now we ask the model checker to settle the question *for all reachable states, not just a bounded prefix*.

## Schedule

About three hours of lecture and live, hands-on work in three blocks, plus a take-home mini-project. The slide deck (`slides/day02.md`) follows this same structure.

| Block | Approx. length | Content |
|---|---|---|
| Opening | ~10 min | Recap. From bounded SMT (Day 1) to full reachability. |
| L1 — Reactive systems & SMV | ~50 min | The SMV input language: `MODULE`, `VAR`, `ASSIGN`, `init`, `next`. Live read-through of `counter.smv`. Smoke test (`nuXmv -help`) and first run. |
| Break | ~10 min | |
| L2 — Temporal logic: CTL & LTL | ~50 min | Path quantifiers and modal operators. CTL (`AG`, `EF`, `AF`, `EG`) and LTL (`G`, `F`, `X`, `U`). Quick check: match the English property to the formula. |
| Break | ~10 min | |
| L3 — Algorithms & live nuXmv | ~50 min | Explicit-state, symbolic (BDD), and bounded (SAT) model checking, and when each is the right tool. Hands-on: run `nuXmv counter.smv`, read the verdicts, introduce a bug in `next(x)` and watch nuXmv produce a counterexample. Tour `traffic_light.smv`, `mutex.smv`, `gcd_01.smv`. |
| Wrap | ~10 min | Recap and intro to the take-home mini-project. |

**Take-home mini-project** (see `assignments/day02.md`).

## Learning objectives for Day 2

By the end of the day, participants will be able to:

- Read an SMV file and identify its transition relation, initial states, and properties.
- Translate an English safety or liveness statement into a CTL or LTL formula.
- Choose between explicit-state, symbolic, and bounded model checking based on the system at hand.
- Run nuXmv on a `.smv` file and interpret an `INVARSPEC` or `LTLSPEC` verdict, including reading a counterexample trace.

## Files

```
day02/
├── README.md
├── slides/day02.md
├── examples/
│   ├── counter.smv              ← running example (from verivital/smvis)
│   ├── traffic_light.smv        ← cyclic four-phase controller
│   ├── mutex.smv                ← two-process mutual exclusion
│   └── gcd_01.smv               ← Euclid's algorithm as a transition system
└── assignments/day02.md
```

All `.smv` examples are taken verbatim from <https://github.com/verivital/smvis/tree/main/examples> where they are exercised by the project's CI.

## Running an example

After installing nuXmv (see top-level `README.md`):

```bash
nuXmv counter.smv
```

`counter.smv` carries several `INVARSPEC`, `LTLSPEC`, and `CTLSPEC` clauses, all checked automatically in batch mode. They are deliberately mixed: of the five invariants, three hold (e.g. `x <= count_max`) and two fail (`x < count_max` and `x <= count_max / 2`), so a run shows both `true` verdicts and counterexample traces. For an interactive session:

```
nuXmv -int counter.smv
> go
> check_invar
> check_ltlspec
> check_ctlspec
> quit
```

## Browser fallback

If you cannot install nuXmv locally before the live nuXmv block (L3), **smvis** ([bit.ly/fmaiv_smvis](https://bit.ly/fmaiv_smvis)) runs a hosted NuSMV in your browser and renders the same models with state-graph and BDD visualizations. Source: <https://github.com/verivital/smvis>.
