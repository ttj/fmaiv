# Day 3 mini-project — Lean proofs of transition-system invariants

**Goal.** Write or finish at least one machine-checked proof of a property of a transition system, using the inductive-invariant pattern. Use Claude Code as a pair partner; report what worked and what did not.

**Time budget.** 60–90 minutes.

## Part A — Warm-up (15 min)

1. From `examples/CounterDemo`, run `lake build`. It builds cleanly — every solution module is fully proved. (The exercise files, `*Starter.lean`, build with `sorry` warnings until you complete them.)
2. Open `CounterDemo/Counter.lean` in VS Code with the Lean 4 extension installed. Place your cursor at the end of `counterInv_init` and inspect the proof state. Do the same inside one of the cases of `counterInv_step`.
3. Read the comments at the top of `Counter.lean` until you can explain the strengthening pattern to a neighbor.

## Part B — One of these (45–60 min)

### B.1 — Add a new invariant

Open `CounterDemo/Counter.lean` and prove a new invariant of the counter. Reasonable candidates:

- `s.x ≤ 5` is *not* an invariant — try to prove it, watch where the proof breaks, and produce the counterexample state.
- `s.x ≤ 10 ∧ (s.mode = .off → s.x = 0) ∧ (s.x > 0 → s.mode = .on)` is the combined invariant of all three INVARSPECs. Prove that this is inductive.
- A liveness property would require ranking functions; skip unless you finish early. The `TransitionSystem.lean` library has the scaffolding.

### B.2 — Modify the counter

In `CounterDemo/Counter.lean`, change `count_max` from 10 to 25 (it is a single integer literal repeated; see comments). Re-state and re-prove `CounterTS_inv1_proved` with the new bound. Most of `Counter.lean` will need small adjustments; use Claude Code to suggest them.

### B.3 — A new system from scratch

Translate one of the SMV files from Day 2 — `traffic_light.smv`, `mutex.smv`, or `gcd_01.smv` — into Lean by hand (the upstream `leansmv` project has a translator script you can look at for reference, but writing it by hand is more educational). Prove one INVARSPEC of your choice.

This is the most ambitious option. Plan for 60+ minutes and expect to ask Claude for help.

## Working with Claude Code

When you ask Claude for a proof:

1. Show it your `TransitionSystem.lean` definitions and your `CounterState` (or its equivalent) first. Otherwise it will guess.
2. Ask for "a strengthening that makes the invariant inductive, with a one-line justification" — that is more likely to get a usable answer than "prove this".
3. When Claude returns a proof, **paste it into Lean and see what the elaborator says**. The exact line where it fails is informative; if Claude is missing a case in `simp` or used a tactic that does not exist, the elaborator will tell you precisely where.
4. Iterate. Claude will usually fix its own mistakes if you paste the elaborator's error back at it. Sometimes you have to step in.

## More worked proofs (`examples/CounterDemo/`)

New Lean modules alongside the counter, each with a starter (`*Starter.lean`)
whose proofs are `sorry`. The solution modules build with **no** `sorry`.

| Module | What it shows |
|---|---|
| `ArraySum.lean` | induction over a list; a loop invariant (accumulator = `acc + sum rest`) |
| `Sorting.lean` | insertion sort proved to produce a sorted list (+ length preserved) |
| `Gcd.lean` | Euclid's GCD; termination via a **ranking function** (`termination_by` / `decreasing_by`) |
| `TrafficLight.lean` | the Day-2 traffic light as a transition system; mutual-exclusion-of-green proved as an inductive invariant |

Starters: `ArraySumStarter.lean`, `GcdStarter.lean`, `TrafficLightStarter.lean`,
`SortingStarter.lean`.

```bash
cd examples/CounterDemo
lake build                              # builds the solution modules clean
lake build CounterDemo.SortingStarter   # a starter: builds with `sorry` warnings until you finish it
```

Good exercise: finish `TrafficLightStarter.lean` (prove `safe_inductive` —
`cases p <;> simp [...]`) or `ArraySumStarter.lean`.

## What to submit

Your edited `.lean` files (the whole `CounterDemo/` directory is fine), plus a short note (one page) describing:

- Which track you chose and why.
- One thing Claude got right on the first try.
- One thing Claude got wrong, and how you noticed.
- Any new invariant you proved, restated in plain English.

## Connecting to Days 1, 2, 4

- Day 1 asked the same question via bounded SMT — "no counterexample of length `N`". The Lean proof handles all `N` at once because it is by induction on the step relation.
- Day 2 asked via nuXmv — "no counterexample in the BDD-encoded reachable set". The Lean proof gives a constructive certificate, not a black-box yes/no.
- Day 4: programs are transition systems on memory states; CBMC plays the Day 1 role for actual C source, and Cryptol provides the bit-precise spec layer that a tool like SAW connects back to a C implementation.
