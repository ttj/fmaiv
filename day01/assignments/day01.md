# Day 1 mini-project — Bounded reachability with Z3

**Goal.** Get hands on Z3 from Python and SMT-LIB by adapting the counter encoding to a small problem of your own.

**Time budget.** 60–90 minutes. Stop and ask before that if you are stuck.

## Part A — Replicate the running example (warm-up, 15 min)

1. Run `examples/z3_smoke.py`, `examples/z3_pigeonhole.py`, and `examples/z3_counter_bounded.py`. Confirm their output matches `examples/expected_output.txt`.
2. Modify `z3_counter_bounded.py` to ask whether `x = 10` is reachable instead of `x = 11`. You should now see `sat` for the smallest bound `n` that admits a counterexample. What is that bound? What does the model look like?

## Part B — Your own bounded property (45 min)

Pick **one** of the following.

### B.1. Two-counter system

Modify the counter to have two counters `x` and `y`, both bounded by the same cap. The system can choose at each step which of them to increment. Encode this as a transition system in Z3 and ask the bounded version of:

- `x + y ≤ 20` (should be `unsat` to falsify, i.e. the property holds for every bounded path)
- `x = y = 10` is reachable (try a few bounds)

Submit your modified Python file with comments explaining your encoding.

### B.2. Traffic light

Encode a traffic light with states `{red, yellow, green}` and a simple cyclic transition relation. Ask Z3:

- "Can the light be `green` followed immediately by `red` (skipping yellow)?" — bounded variant; you expect `unsat`.
- "Can the light be `green` again within `N` steps?" — should be `sat` for `N ≥ 3`.

### B.3. Pick your own

Choose any small system you can describe in a paragraph (a vending machine, a turnstile, a coffee maker with brewing/ready/empty modes). Write its transition relation in Z3, formulate one safety property, and verify it up to a chosen bound.

## What to submit

A single `.py` file with:

- A docstring describing the system in two or three sentences.
- A `step(...)` function that encodes one transition.
- A `bounded_reach(...)` function (modeled on `z3_counter_bounded.py`) that runs the bounded check at several bounds and prints results.
- A short comment block at the bottom interpreting the output ("this is what I expected because …", or "this surprised me because …").

## Tips

- If a check returns `sat` and you expected `unsat`: ask Z3 to print the model and trace the path. Usually the encoding is missing a constraint.
- If a check is slow at a large bound: cap your state variables to small finite ranges, or use bit vectors instead of unbounded integers.
- Claude Code is a fine pair partner here. Ask it to explain the model on a small example; ask it where your encoding might be missing a constraint.

## Connecting to Days 2, 3, 4

What you do today verifies a property *up to a bound*. Day 2 (nuXmv) verifies the same kind of property *for all bounds at once*. Day 3 (Lean) proves it from the transition relation directly, by induction. Day 4 (CBMC) brings the same idea back to actual program source code. Hold on to your encoding from today; you will recognize its shape in every tool the rest of the week.
