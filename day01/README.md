# Day 1 — Foundations: logic, transition systems, SAT, and SMT

This is the foundation day. By the end, every participant has typed a Z3 query, formalized a small reactive system as a transition system, and asked an SMT solver to discharge a bounded-reachability question.

## Schedule

### Lecture and demo with interactive segments

| Block | Approx. length | Content |
|---|---|---|
| 1.1 | ~15 min | Course overview. Why now: generative AI has industrialized production but not validation. The four-day arc. |
| 1.2 | ~30 min | Propositional and first-order logic refresher. Syntax, semantics, satisfiability, validity. Live poll: SAT or UNSAT? |
| 1.3 | ~40 min | Transition systems. The tuple `T = (S, S₀, →, AP, L)`. Traces and reachability. Introduce the running example (the counter) and write it as a transition system on paper. |
| 1.4 | ~30 min | SAT and SMT. DPLL intuition. Theories (LIA, BV, EUF). Live demo: solve `x² + y² = 25 ∧ x > 0 ∧ y > 0` in Z3. |
| 1.5 | ~5 min | Wrap-up + assignment intro. |

### Hands-on

| Block | Approx. length | Activity |
|---|---|---|
| 1.6 | ~15 min | Smoke test: run `examples/z3_smoke.py`. Confirm `pip install z3-solver` worked. |
| 1.7 | ~30 min | Walk through `examples/z3_pigeonhole.py` and `examples/z3_smt_basics.smt2`. Each contains explanatory comments. |
| 1.8 | ~45 min | Walk through `examples/z3_counter_bounded.py`. Bounded reachability of the counter: "can `x` reach 11 in `N` steps?" |
| 1.9 | ~30 min | Mini-project (see `assignments/day01.md`): write your own bounded-reachability query for the counter and a small variant. |

## Learning objectives for Day 1

By the end of the day, participants will be able to:

- Write the syntax and semantics of propositional and first-order logic, and distinguish satisfiability from validity.
- Define a transition system `T = (S, S₀, →, AP, L)` and write one for a small reactive system.
- Express a bounded-reachability question as an SMT formula over a suitable theory.
- Drive Z3 from Python and from SMT-LIB, and read the solver's output (sat / unsat, model).

## Files

```
day01/
├── README.md            ← this file
├── slides/day01.md      ← lecture slides (markdown)
├── examples/
│   ├── z3_smoke.py              ← smoke test
│   ├── z3_smt_basics.smt2       ← SMT-LIB syntax intro
│   ├── z3_pigeonhole.py         ← classic SAT encoding
│   ├── z3_counter_bounded.py    ← bounded reachability of the counter
│   └── expected_output.txt      ← reference output for verification
└── assignments/day01.md
```
