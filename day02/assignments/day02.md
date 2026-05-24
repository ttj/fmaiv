# Day 2 mini-project — Model check a system with nuXmv

**Goal.** Take an existing SMV model, verify its given properties, propose and verify one new property, and produce a counterexample on a deliberate variant.

**Time budget.** 60–90 minutes.

## Part A — Warm-up on the counter (15 min)

1. Run `nuXmv counter.smv` (or `NuSMV counter.smv`). This file is a deliberate *sampler*: the three core safety invariants hold (`x <= count_max`; `mode = off -> x = 0`; `x > 0 -> mode = on`), while two are intentionally false (`x < count_max` and `x <= count_max / 2`) and report a counterexample — because `x` does reach 10. Read one of those counterexamples and write a one-sentence explanation.
2. In a copy of the file, change `init(x) := 0` to `init(x) := 5`. Which properties still hold? Which fail? Read the counterexample for at least one failing property and write a one-sentence English explanation.
3. Revert the change.

## Part B — A model of your choice (45–60 min)

Choose **one**:

### B.1. Traffic light (`traffic_light.smv`)

A four-phase cyclic controller — main green, main yellow, side green, side yellow. Verify the given INVARSPECs. Then add and verify a new property of your own. Reasonable candidates:

- "If main is green, side is red." (`INVARSPEC`)
- "Every time main is green, side will eventually be green." (`LTLSPEC`)
- "It is never the case that both main and side are green at the same time." (`INVARSPEC`)

### B.2. Two-process mutex (`mutex.smv`)

Verify the given mutual-exclusion property. Then add and verify:

- A liveness property: "Whenever a process requests, it eventually enters its critical section."
- Or a fairness property: "Both processes enter their critical section infinitely often."

You will need to think about whether plain LTL is enough or whether you need an explicit fairness condition.

### B.3. GCD (`gcd_01.smv`)

Verify the given properties. Then add and verify:

- A termination property: "The program eventually reaches the final program counter."
- A correctness property: "When the program terminates, the value held is the gcd of the inputs."

Discuss in a one-paragraph note: what makes the correctness property hard for a finite-state model checker?

## Part C — Deliberate bug (15 min)

Pick one of the systems in Part B. Introduce a single, small bug in the transition relation. Re-run nuXmv. Read the counterexample. Submit:

- The diff describing your bug.
- The first few states of the counterexample.
- One or two sentences saying what the counterexample shows.

## More worked models (`examples/`)

Additional models, each with a mix of true and deliberately-false specs, plus
starters with holes. Concurrency is modeled by interleaving with a free
scheduler variable — no deprecated `process` blocks.

| Model | What it shows | Solution | Starter |
|---|---|---|---|
| Elevator | a simple safety property (doors closed while moving) | `elevator.smv` | `elevator_starter.smv` |
| Peterson's mutex | concurrent mutual exclusion + no-starvation under fairness | `peterson.smv` | `peterson_starter.smv` |
| Producer/consumer | bounded-buffer safety + liveness | `prodcons.smv` | `prodcons_starter.smv` |

```bash
nuXmv peterson.smv      # or:  NuSMV peterson.smv
```

Each solution's specs are annotated `(HOLDS)` or `DELIBERATELY FALSE`, so a
single run shows you both a proof and a counterexample. In
`peterson_starter.smv` the L3 wait conditions are missing, so mutual exclusion
*fails* — add them (and the no-starvation LTL specs) to make it pass. In
`prodcons_starter.smv` the fairness conditions and liveness specs are missing —
add them and watch the liveness specs go from `false` to `true`.

## Two more exercises (`examples/`)

- **Spec from English** — [`spec_challenge_starter.smv`](../examples/spec_challenge_starter.smv)
  (solution: [`spec_challenge.smv`](../examples/spec_challenge.smv)). A request/grant
  arbiter is given; you turn five English sentences into `INVARSPEC` / `LTLSPEC` /
  `CTLSPEC` formulas and check each verdict against the "expected" note. One uses
  `X` (next); one is deliberately false. Formalizing the property correctly is
  usually the hard part of model checking — practice it here.
- **BMC bound hunt** — [`bmc_depth.smv`](../examples/bmc_depth.smv). A bug that lives
  at exactly depth 12. Use nuXmv's bounded model checking (`go_bmc ;
  check_invar_bmc -k N`) to find the smallest `k` that exposes it. The lesson:
  a *passing* BMC run at depth `k` is not a proof unless `k` reaches the system's
  diameter — the flip side of the Day-3 induction that covers all depths at once.

## What to submit

A single zip with:

- Your modified `.smv` file from Part A.
- Your `.smv` file from Part B with one or more added properties.
- The buggy `.smv` file from Part C and the counterexample.
- A short README (3–5 sentences) describing your choices and what surprised you.

## Tips

- The `case ... esac` blocks in `next(...)` are evaluated top-to-bottom; the first matching clause wins.
- nuXmv defaults to running every `INVARSPEC` automatically. To run an `LTLSPEC` or `CTLSPEC` in interactive mode: `read_model -i file.smv ; flatten_hierarchy ; encode_variables ; build_model ; check_ltlspec`.
- When a property fails, check whether it would have failed even with the bug fixed. Sometimes the property is wrong, not the system.

## Connecting to Days 1, 3, 4

On Day 1 you asked Z3 about the counter for bounded paths. On Day 2 you asked nuXmv for all paths. On Day 3 you will prove these same invariants directly in Lean — no bound, no BDD, just an induction that says the invariant holds at every step. On Day 4 we come back to programs and use CBMC (which is, internally, the same bounded SMT idea from Day 1, applied to C source).
