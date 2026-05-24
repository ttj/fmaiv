# Capstone — one property, four tools

The single thread running through FMAIV is the **bounded counter**: a counter
that turns on, increments while a button is not pressed, and resets — and never
exceeds 10. Every day verified *the same safety property* with a different tool:

> **P:** the counter value `x` never exceeds 10.

This capstone asks you to verify **P** with all four tools in one sitting and
write up what each style of verification actually buys you. The code already
exists and is CI-tested — your job is to run it, read it side by side, and
compare.

**Time budget.** 60–90 minutes.

## Part A — Verify P four ways (40 min)

Run each and confirm the verdict. Each links to the worked example.

| Day | Tool | Style | File | Command | Verdict |
|---|---|---|---|---|---|
| 1 | Z3 | bounded (SMT, up to depth N) | [`z3_counter_bounded.py`](../day01/examples/z3_counter_bounded.py) | `python z3_counter_bounded.py` | `UNSAT` (no counterexample ≤ N) |
| 2 | nuXmv / NuSMV | unbounded (BDD reachability) | [`counter.smv`](../day02/examples/counter.smv) | `NuSMV counter.smv` | `x <= 10` is `true` |
| 3 | Lean 4 | inductive proof (all N at once) | [`Counter.lean`](../day03/examples/CounterDemo/CounterDemo/Counter.lean) | `lake build` (in `examples/CounterDemo`) | builds; `CounterTS_inv1_proved` |
| 4 | CBMC | bounded on real C source | [`counter.c`](../day04/examples/counter.c) + [`counter_check.c`](../day04/examples/counter_check.c) | `cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions` | `VERIFICATION SUCCESSFUL` |
| 4 | Cryptol | bit-precise (SMT on fixed-width) | [`counter.cry`](../day04/examples/counter.cry) | `cryptol -c ":prove bounded_invariant" counter.cry` | `Q.E.D.` |

## Part B — The comparison writeup (30 min)

In one page, answer:

1. **Bounded vs. unbounded.** Z3 (Day 1) and CBMC (Day 4) only check up to a
   depth/unwind bound; nuXmv (Day 2) and Lean (Day 3) cover *all* reachable
   states. For the counter, what bound makes the Day-1/Day-4 checks trustworthy,
   and *why that number*? (Hint: how many steps to drive `x` from 0 to 10, and
   what does `--unwind 26` give you?)

2. **The inductive insight.** In Lean, `x ≤ 10` is **not** inductive on its own —
   you must strengthen it with `mode = off → x = 0`. Where do the *other* three
   tools get away **without** that strengthening? (Hint: who reasons about
   single transitions, and who explores concrete reachable states?)

3. **Soundness vs. completeness.** Which of the five verdicts above is a proof
   for all inputs, and which could miss a bug that appears just past the bound?

4. **One property, five encodings.** List one thing each encoding makes easy that
   the others make hard (e.g. Cryptol's bit-precision, Lean's "for all N",
   nuXmv's counterexample traces, CBMC's "runs on the actual C").

## Part C — Stretch: change the bound to 25 (optional)

Re-do the counter with the cap raised from 10 to 25 in **all** tools, and
re-verify P (now `x ≤ 25`). This is the Day-3 assignment's B.2 task, generalized:
update the literal in each encoding and re-run. Which tool needed the most
human help to follow the change, and which the least?

## What to submit

- A transcript (or screenshots) of all five verdicts from Part A.
- Your one-page comparison from Part B.
- (If attempted) the Part C edits and re-verification.

## Where this goes next

You have just exercised the 2026 formal-methods toolchain end to end: SMT for
foundations, model checking for finite reactive systems, theorem proving for the
"for all N" content, and source-level checkers for the actual code. The Day-4
[neural-network robustness](../day04/examples/nn/) example points at where this
is heading — the same verification questions, asked of learned models.
