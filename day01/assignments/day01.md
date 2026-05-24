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

## More SMT puzzles (`examples/puzzles/`)

Worked solutions and matching starters that encode classic puzzles as
*constraints* — you state what a solution is and let Z3 search, never writing a
search algorithm. Each `*.py` solution prints a solution and self-checks; each
`*_starter.py` has the encoding blanked out with TODOs (run it to see an
incomplete result, then fill in the constraints).

| Puzzle | Solution | Starter |
|---|---|---|
| Sudoku (9×9 Latin square + boxes) | `sudoku.py` | `sudoku_starter.py` |
| KenKen / Calcudoku (Latin square + arithmetic cages) | `kenken.py` | `kenken_starter.py` |
| N-Queens (no two queens attack) | `nqueens.py` | `nqueens_starter.py` |
| Magic square (rows/cols/diagonals sum equal) | `magic_square.py` | `magic_square_starter.py` |

```bash
cd examples/puzzles
python sudoku.py            # prints the unique solution and verifies it
python nqueens.py 12        # any board size
python kenken_starter.py    # incomplete until you fill the TODOs
```

Good exercise: complete `kenken_starter.py` so its output matches `kenken.py`
and it reports a unique solution.

## Entailment and synthesis (`examples/`)

Two short extras that round out "what an SMT solver does":

- **Entailment as unsatisfiability** — [`z3_entailment.py`](../examples/z3_entailment.py)
  (starter: [`z3_entailment_starter.py`](../examples/z3_entailment_starter.py)).
  The key idiom behind every proof this week: `KB ⊨ G` iff `KB ∧ ¬G` is **UNSAT**.
  Run it on the Socrates syllogism; the starter asks you to add the one `Not(goal)`
  line. *Validity* (holds in all models) vs. *satisfiability* (holds in some) is
  the distinction to take away.
- **Synthesis as ∃∀ solving** — [`z3_synthesis.py`](../examples/z3_synthesis.py).
  Verification asks "does it hold?"; synthesis asks "is there a parameter that
  *makes* it hold?" Z3 finds the `k` in `∃k. ∀x∈[0,9]. x+k ∈ [10,19]`. A taster
  for the deductive-synthesis idea you will see on Day 3.

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
