# Day 3 mini-project — Lean proofs of transition-system invariants

**Goal.** Write or finish at least one machine-checked proof of a property of a transition system, using the inductive-invariant pattern. Use Claude Code as a pair partner; report what worked and what did not.

**Time budget.** 60–90 minutes.

## Part A — Warm-up (15 min)

> **New to Lean?** Two on-ramps. First, the set-theory intro
> [`DiscreteMathStarter.lean`](../examples/CounterDemo/CounterDemo/DiscreteMathStarter.lean)
> (solution `DiscreteMath.lean`): prove subset transitivity, De Morgan, and ∩-over-∪
> distribution with the core tactics on a friendly domain. Then the counter-specific
> [`CounterLadderStarter.lean`](../examples/CounterDemo/CounterDemo/CounterLadderStarter.lean)
> (solution `CounterLadder.lean`): six rungs — `omega`, `h.1`, `constructor`, modus
> ponens, `cases`, then the counter's base case. Build either with
> `lake build CounterDemo.<Name>`. Climb both before Part B.

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

In `CounterDemo/Counter.lean`, change the counter bound from **10 to 25** — it appears as the literal `10` in a few places (the invariant `x ≤ 10`, the step guard `x < 10`, and the matching proofs; the file's comments point them out). Re-state and re-prove `CounterTS_inv1_proved` with the new bound. Most of `Counter.lean` will need small adjustments; use Claude Code to suggest them.

### B.3 — A new system from scratch

Translate a Day-2 SMV model into Lean, then prove one INVARSPEC of your choice. **Translating is one command** (run from the repo root — `cd` back out if you were in `examples/CounterDemo`):

```bash
pip install -r scripts/smv2lean/requirements.txt        # lark (once)
scripts/smv2lean/to_lean.sh day02/examples/traffic_light.smv   # -> NuXMV/Traffic_light.lean
```

The output is a `TransitionSystem` (sorry-free) with each `INVARSPEC` written as a **commented** theorem stub — uncomment one and prove it. **Worked examples of exactly this workflow ship with the course**: [`NuXMV/Gcd`](../examples/CounterDemo/CounterDemo/NuXMV/Gcd.lean), [`Mutex`](../examples/CounterDemo/CounterDemo/NuXMV/Mutex.lean), and [`Elevator`](../examples/CounterDemo/CounterDemo/NuXMV/Elevator.lean) have their proofs filled in beside them in `*Proofs.lean` (Elevator even shows a *true* safety invariant and a *deliberately false* one, like the counter). [`NuXMV/Peterson`](../examples/CounterDemo/CounterDemo/NuXMV/Peterson.lean) and [`Prodcons`](../examples/CounterDemo/CounterDemo/NuXMV/Prodcons.lean) are pre-translated stubs. Like the Day-2 samplers (and Elevator), they mix true and deliberately-false INVARSPECs: **prove** the ones that hold (e.g. Peterson's mutual exclusion `¬(pc1=4 ∧ pc2=4)`, Prodcons's `buf ≤ CAP`) and **refute** the false ones (Peterson's `pc1 ≠ 4`, Prodcons's `buf ≠ CAP`) by exhibiting the counterexample state, exactly as `ElevatorProofs.lean` does for `inv2`. Or write the translation by hand, which is more educational.

This is the most ambitious option. Plan for 60+ minutes and expect to ask Claude for help.

## Part C — Break the proof (15 min)

Days 1, 2, and 4 each end with a deliberate bug whose counterexample you read.
The Day-3 analogue is a **wrong invariant**: open
[`CounterBroken.lean`](../examples/CounterDemo/CounterDemo/CounterBroken.lean) and
try to prove the counter satisfies `x ≤ 5`. It does not. Replace the `sorry` in
`badInv_step` with the same case tree as `counterInv_step` and watch exactly
where it breaks (the increment branch leaves `s.x + 1 ≤ 5` with only `s.x ≤ 5` —
`omega` fails). Then answer, in the file's comment:

1. Which branch gets stuck (mode / press / `x < 10`)?
2. The shortest press sequence from the initial state that reaches `x = 6 > 5`.
3. Why the real invariant `counterInv` (bound 10, plus the `mode = off → x = 0`
   strengthening) goes through where `x ≤ 5` cannot.

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
| `DiscreteMath.lean` | a gentle intro: set theory in Lean (subset transitivity, De Morgan, ∩-over-∪) |
| `ArraySum.lean` | induction over a list; a loop invariant (accumulator = `acc + sum rest`) |
| `Sorting.lean` | insertion sort proved to produce a sorted list (+ length preserved) |
| `Gcd.lean` | Euclid's GCD; termination via a **ranking function** (`termination_by` / `decreasing_by`) |
| `TrafficLight.lean` | the Day-2 traffic light as a transition system; mutual-exclusion-of-green proved as an inductive invariant |
| `ProgramVerif/Imp.lean`, `Examples.lean` | the **IMP** imperative language: big-step semantics and Hoare-style reasoning about programs |
| `NuXMV/Gcd.lean`, `Mutex.lean` (+ `*Proofs.lean`) | SMV models auto-translated to Lean by `smv2lean`; each `INVARSPEC` stub proved by hand in `*Proofs.lean` |

Starters: `DiscreteMathStarter.lean`, `ArraySumStarter.lean`, `GcdStarter.lean`,
`TrafficLightStarter.lean`, `SortingStarter.lean` (and the `NuXMV/{Gcd,Mutex}.lean`
commented INVARSPEC stubs act as starters — uncomment and prove them, with `*Proofs.lean` as the answer key).

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
