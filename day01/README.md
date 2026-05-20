# Day 1 — Foundations: logic, transition systems, SAT, and SMT

This is the foundation day. By the end, every participant has typed a Z3 query, formalized a small reactive system as a transition system, and asked an SMT solver to discharge a bounded-reachability question.

## Schedule

About three hours of lecture and live, hands-on work in three blocks, plus a take-home mini-project. The slide deck (`slides/day01.md`) follows this same structure.

| Block | Approx. length | Content |
|---|---|---|
| Opening | ~10 min | Course overview. Why now: generative AI has industrialized production but not validation. The four-day arc. |
| L1 — Why now | ~50 min | The AI × formal-methods asymmetry. Famous bugs that motivated the field (Therac-25, Ariane 5, Pentium FDIV, Toyota, 737 MAX). AWS provable security. What formal methods does — and does not — give you. |
| Break | ~10 min | |
| L2 — Logic & transition systems | ~50 min | Propositional and first-order logic: syntax, semantics, satisfiability, validity. Live poll: SAT or UNSAT? Transition systems `T = (S, S₀, →, AP, L)`; traces and reachability. The running example (the counter) written as a transition system. |
| Break | ~10 min | |
| L3 — SAT, SMT, and Z3 | ~50 min | DPLL/CDCL intuition. Theories (LIA, BV, EUF). Driving Z3 from Python and SMT-LIB. Live + hands-on: `examples/z3_smoke.py`, `examples/z3_pigeonhole.py`, `examples/z3_smt_basics.smt2`, and `examples/z3_counter_bounded.py` (bounded reachability of the counter — "can `x` reach 11 in `N` steps?"). |
| Wrap | ~10 min | Recap and intro to the take-home mini-project. |

**Take-home mini-project** (see `assignments/day01.md`): write your own bounded-reachability query for the counter and a small variant.

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
