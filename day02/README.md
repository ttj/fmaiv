# Day 2 — Model checking with nuXmv

The same counter from Day 1, but now we ask the model checker to settle the question *for all reachable states, not just a bounded prefix*.

## Schedule

### Lecture and live demo

| Block | Approx. length | Content |
|---|---|---|
| 2.1 | ~15 min | Recap. From bounded SMT (Day 1) to full reachability. |
| 2.2 | ~25 min | The SMV input language. `MODULE`, `VAR`, `ASSIGN`, `init`, `next`. Live read-through of `counter.smv`. |
| 2.3 | ~40 min | Temporal logic. Path quantifiers; modal operators. CTL: `AG`, `EF`, `AF`, `EG`. LTL: `G`, `F`, `X`, `U`. Live poll: match the English property to the formula. |
| 2.4 | ~35 min | Model-checking algorithms. Explicit-state, symbolic (BDD), bounded (SAT). When each is the right tool. |
| 2.5 | ~5 min | Wrap-up + assignment intro. |

### Hands-on with nuXmv

| Block | Approx. length | Activity |
|---|---|---|
| 2.6 | ~15 min | Smoke test: `nuXmv -help`. Load `counter.smv`. |
| 2.7 | ~30 min | Walk through `counter.smv`. Run `nuXmv counter.smv` to verify the four INVARSPECs and one LTLSPEC. Introduce a bug in `next(x)` and watch nuXmv produce a counterexample. |
| 2.8 | ~45 min | Walk through `traffic_light.smv`, `mutex.smv`, `gcd_01.smv`. Each has slightly different idioms (boolean encoding, explicit program-counter, structured records). |
| 2.9 | ~30 min | Mini-project (see `assignments/day02.md`). |

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

The default interactive prompt is fine; the file's `INVARSPEC`, `LTLSPEC`, and `CTLSPEC` clauses are checked automatically when nuXmv runs in batch mode. For an interactive session:

```
nuXmv -int counter.smv
> go
> check_invar
> check_ltlspec
> check_ctlspec
> quit
```

## Browser fallback

If you cannot install nuXmv locally before the afternoon block, [smvis](https://github.com/verivital/smvis) runs a hosted nuXmv on Hugging Face Spaces and renders the same models with state-graph and BDD visualizations.
