---
title: "Day 2 — Model Checking with nuXmv"
subtitle: "FMAIV: Formal Methods & AI-Assisted Verification"
author: "Taylor T. Johnson"
institute: "Vanderbilt University"
date: "Day 2 of 4"
---

# Day 2 — Model Checking {.title}

## Reactive systems, temporal logic, and nuXmv {.section}

::: notes
Day 1 ended with bounded model checking in Z3: "no counterexample of length ≤ N." Today we lift that to "no counterexample, ever," for finite-state systems. Same running counter; new tool. By the end you will read an SMV file, write CTL/LTL properties, run nuXmv, and read a counterexample trace. The conceptual jump is small — a transition system plus a temporal-logic property — but the payoff is large: an exhaustive answer instead of a bounded one.
:::

---

## Where we are

Day 1, in Z3, we asked: *can the counter reach `x = 11` within `N` steps?*

- Answer: `unsat` — but only for the `N` we could afford to enumerate.
- Bounded model checking **refutes** short counterexamples; it does not **prove** safety.

**Today: ask the same question for all `N` at once**, via a model checker.

::: notes
This is the bridge slide. Reiterate the Day 1 limitation honestly: bounded SMT is a refutation tool. If a property is actually true, no finite bound proves it. The model checker closes that gap for finite-state systems by reasoning about the whole reachable set symbolically, not by unrolling step by step.
:::

---

## Today's roadmap

| Block | Topic |
|---|---|
| L1 | Reactive systems + the SMV input language |
| L2 | Temporal logic: CTL and LTL |
| L3 | Model-checking algorithms + live nuXmv |

Running example throughout: the same `counter.smv`.

::: notes
Three teaching blocks. L1 is "how do I describe the system" (SMV). L2 is "how do I describe what correct means" (temporal logic). L3 is "how does the tool actually decide it" (BDDs / SAT) plus hands-on nuXmv. The counter threads through all three.
:::

---

## Learning objectives for Day 2

By the end of today you will be able to:

- Model a reactive system as a synchronous transition system and write it in SMV.
- Read and write **CTL** and **LTL** properties, and say which can express what.
- Explain the trade-offs among explicit-state, symbolic (BDD), and bounded model checking.
- Run **nuXmv** on an SMV file and read an `INVARSPEC` / `LTLSPEC` / `CTLSPEC` verdict — including a counterexample trace.

::: notes
Four objectives mapping to L1 (model), L2 (spec), L3 (algorithms + tool). We will revisit these at the wrap.
:::

---

# L1 — Reactive systems and SMV {.section}

::: notes
First block. The goal: by the end you can read counter.smv and write your own small SMV model. We start from *why* reactive systems need a different model than ordinary programs, then the synchronous-component formalism, then SMV concretely.
:::

---

## Two kinds of computation

| Functional (transformational) | Reactive |
|---|---|
| input → compute → output → halt | runs forever, step by step |
| a compiler, `sort(list)` | a thermostat, a traffic light, a CPU |
| correctness = right output | correctness = right behavior *over time* |

Verification of reactive systems is about **infinite behaviors**, not a single answer.

::: notes
This distinction (from Week 4) is foundational. A sorting routine is functional: it takes input and terminates. A controller is reactive: it never terminates by design, and "correct" means its ongoing interaction with the environment satisfies a temporal property. Model checking is built for the reactive case — that is why temporal logic exists.
:::

---

## Synchronous reactive components

The model behind SMV: a component that, each **round**, reads its inputs and updates its state.

- **Inputs** — values the environment chooses each round (our `press`).
- **State variables** — the component's memory (`mode`, `x`).
- **Initialization** — the allowed initial states.
- **Reaction** — a relation from (current state, inputs) to next state.

Everything happens in lock-step on a global clock: read inputs, compute next state, repeat.

::: notes
The synchronous reactive component (SRC) is Alur's formalism from Principles of Cyber-Physical Systems and the spine of Week 4. It maps one-to-one onto SMV: VAR declares state + inputs, ASSIGN/init gives initialization, next gives the reaction relation. The "synchrony hypothesis" — that the reaction is instantaneous relative to the environment — is the abstraction that makes the model finite and analyzable.
:::

---

## The synchrony hypothesis

We pretend each reaction is **instantaneous**: the next state is computed before the next input arrives.

- Real hardware/software takes time; we abstract that away.
- Justified when the system is fast relative to its environment.
- Lets us model time as a sequence of discrete rounds — exactly what a model checker enumerates.

::: notes
Worth a beat: the synchrony hypothesis is an abstraction, and like all abstractions it can be wrong (if the system is too slow to keep up with the environment). For the systems we model checkk it is the standard, sound idealization. It is why "one step of the transition relation" = "one round" cleanly.
:::

---

## Where reactive components show up

- **Automobiles** — engine control, ABS, the throttle logic from the Toyota case (Day 1).
- **Avionics** — flight control loops, TCAS collision avoidance.
- **Hardware** — every synchronous digital circuit is an SRC on the clock edge.
- **Protocols** — TCP, mutual-exclusion, cache coherence.

The counter is a deliberately tiny instance of the same shape.

::: notes
Anchor the abstraction in the Day 1 bug stories: the Toyota throttle, MCAS, TCAS are all reactive components whose temporal behavior is exactly what failed. Model checking is the tool that asks "can this reactive component ever reach a bad state?" — the question nobody could answer for those systems at design time.
:::

---

## SMV: a textbook input language

```smv
MODULE main
  VAR
    mode  : {off, on};      -- enumerated state
    press : boolean;        -- nondeterministic INPUT (no init/next)
    x     : 0..25;          -- bounded integer state

  DEFINE count_max := 10;   -- a named constant
```

- `VAR` declares state variables **and** inputs.
- A variable with **no** `init`/`next` clause is a free input — nuXmv lets the environment pick any value each round (this is our `press`).
- `0..25` makes `x` finite, so the state space is finite.

::: notes
The single most important SMV idiom for newcomers: a VAR with no assignment is an unconstrained input. That is how press becomes "nondeterministic each step" without any extra syntax. The bounded range on x (0..25) is what keeps the model finite — model checking needs a finite state space (or a symbolic decision procedure for the infinite case, which nuXmv also has, but our examples are finite).
:::

---

## SMV: the transition relation

```smv
  ASSIGN
    init(mode) := off;
    init(x)    := 0;
    next(mode) := case
        mode = off & !press                  : off;
        mode = off & press                   : on;
        mode = on  & !press & x < count_max  : on;
        mode = on  & (press | x >= count_max): off;
        TRUE                                 : mode;   -- default
      esac;
    next(x) := case
        mode = on & !press & x < count_max   : x + 1;
        mode = on & (press | x >= count_max) : 0;
        TRUE                                 : x;
      esac;
```

This is the same counter, line for line — and the same four guards as the Z3 `step()` from Day 1.

::: notes
Walk the case statement: top-to-bottom, first matching guard wins, TRUE is the catch-all. Point out that this is exactly the four-clause case analysis from Day 1's z3_counter_bounded.py, just in SMV syntax. The next(mode) and next(x) clauses together define the transition relation. The same case analysis will reappear in Lean (Day 3) and C/Cryptol (Day 4) — five encodings, one system.
:::

---

## Specifications live in the same file

```smv
INVARSPEC x <= count_max;             -- safety: always true
INVARSPEC (mode = off) -> (x = 0);    -- conditional safety
CTLSPEC   AG AF (mode = off & x = 0); -- always eventually "home"
LTLSPEC   F (x = count_max);          -- eventually maximal
```

- `INVARSPEC p` — `p` holds in every reachable state (pure safety).
- `CTLSPEC` / `LTLSPEC` — richer temporal properties (next block).
- nuXmv checks **every** spec in the file when you run it.

::: notes
Properties and model in one file is an SMV convention worth highlighting — the spec is version-controlled alongside the system. INVARSPEC is the special, fast case (a pure invariant); CTLSPEC and LTLSPEC are the general temporal cases. We will see in counter.smv that some specs are deliberately FALSE — that is intentional, so students see both verdicts.
:::

---

## counter.smv has true *and* false specs on purpose

`counter.smv` includes specs that **hold** and specs that **fail**:

- ✓ `x <= count_max` — holds.
- ✓ `(mode = off) -> (x = 0)` — holds.
- ✗ `x < count_max` — fails (x reaches exactly 10).
- ✗ `x <= count_max / 2` — fails (x reaches 10 > 5).

**Don't assume every spec is meant to pass.** Read each verdict against what you expect.

::: notes
This is a real pedagogical point and a gotcha I want students to internalize. The example file mixes passing and failing specs deliberately, so you see nuXmv say both "true" and "false" and produce counterexamples for the false ones. In general, treating a tool's output as "should be all green" is how people miss real bugs — the verdict is data, not a grade.
:::

---

## Other models you'll meet today

| File | System | Idiom it shows |
|---|---|---|
| `counter.smv` | the running counter | nondeterministic input |
| `traffic_light.smv` | four-phase intersection | timed phases, mutual exclusion of greens |
| `mutex.smv` | two-process mutual exclusion | Peterson-style flags + turn |
| `gcd_01.smv` | Euclid's GCD | explicit program counter (a *program* as a TS) |

::: notes
These four (all from verivital/smvis) show the range of SMV modeling. mutex is the classic concurrency example. gcd_01 shows the key trick for turning an ordinary sequential program into a transition system: add a program-counter variable ranging over line labels — a preview of Day 4, where CBMC does this for C automatically.
:::

---

## A program as a transition system: gcd_01.smv

```smv
-- while (a != b) { if (a > b) a = a-b; else b = b-a; }
  next(pc) := case
      pc = l1 & a != b : l2;   -- loop guard true
      pc = l1 & a  = b : l5;   -- done
      pc = l2 & a >  b : l3;   -- then-branch
      pc = l2 & a <= b : l4;   -- else-branch
      pc = l3 | pc = l4: l1;   -- back to loop head
      pc = l5          : l5;   -- terminal self-loop
    esac;
```

Add a **program counter** ranging over line labels; loops become back-edges.

::: notes
This is the "compiler view" of verification, foreshadowing Day 4. Any sequential program becomes a transition system: the state is (program counter, all variables), and the transition relation is "execute one statement." The pc variable encodes control flow; the terminal self-loop keeps infinite executions well-defined. CBMC will do exactly this construction for real C, but here you see it by hand.
:::

---

## L1 recap

- Reactive systems run forever; correctness is about **behavior over time**.
- A **synchronous reactive component** = inputs + state + init + reaction.
- **SMV** writes that directly: `VAR` (state + free inputs), `init`/`next` (the relation), `INVARSPEC`/`CTLSPEC`/`LTLSPEC` (the properties).
- Any sequential **program** becomes a transition system via a program counter.

::: notes
Block recap. Take-home: you can now read an SMV file and identify its state, inputs, transition relation, and properties. That is the "model" half of the verification triple. Next block is the "specification" half: temporal logic.
:::

---

## ☕ Break {.section}

We resume after the break with temporal logic — CTL and LTL.

---

# L2 — Temporal logic: CTL and LTL {.section}

::: notes
Second block. Propositional logic (Day 1) describes a single state. Temporal logic describes how states evolve along executions. Two dialects — LTL (linear, one future) and CTL (branching, many futures). We do operators, then the patterns that matter, then the LTL-vs-CTL distinction, then properties of the counter.
:::

---

## Why propositional logic isn't enough

Propositional logic talks about **one** state: "`x ≤ 10` here."

Reactive correctness needs claims about **executions**:

- "`x ≤ 10` in *every* reachable state" (always).
- "the system *eventually* returns to `off`" (eventually).
- "no green light *until* the other turns red" (until).

These are **temporal** modalities. Propositional logic can't say "always" or "eventually."

::: notes
Motivate the new logic. The properties we care about quantify over time / executions, which plain propositional logic cannot express. Temporal logic adds modal operators (always, eventually, next, until) that range over the states of an execution. Two flavors differ in how they treat branching.
:::

---

## LTL — linear temporal logic

LTL views the future as a **single path** (implicitly, all paths). Operators on a path:

- `X p` — **neXt**: `p` in the next state.
- `F p` — **Finally** (eventually): `p` at some future state.
- `G p` — **Globally** (always): `p` at every future state.
- `p U q` — **Until**: `p` holds until `q` becomes true (and `q` does).
- `p R q` — **Release**: dual of until.

::: notes
LTL operators, one line each. The mental model: fix a single infinite trace; each operator is a claim about that trace from the current position. "Implicitly all paths" because an LTL spec is true of a system iff it is true of *every* trace. X is the only operator that looks exactly one step; F/G are the workhorses; U is the expressive one that F and G are special cases of (F p = true U p, G p = ¬F¬p).
:::

---

## Reading LTL on a trace

A trace is a sequence of states $s_0, s_1, s_2, \dots$

$$G\,p:\quad p \text{ true at } s_0, s_1, s_2, \dots \text{ (every position)}$$
$$F\,p:\quad p \text{ true at some } s_i$$
$$X\,p:\quad p \text{ true at } s_1$$
$$p\,U\,q:\quad q \text{ true at some } s_i,\ \text{and } p \text{ true at } s_0\dots s_{i-1}$$

A finite system has infinite traces that end in a **lasso** (a cycle): a stem then a repeating loop.

::: notes
The lasso is the key intuition for why model checking infinite behaviors is decidable on finite systems: any infinite trace through finitely many states must eventually revisit a state, i.e. it is a "lasso" — a finite stem followed by a finite cycle repeated forever. So checking "G p" or "F G p" reduces to checking finitely many stems and cycles. This is the foundation of automata-theoretic LTL model checking (Büchi automata, Week 10).
:::

---

## LTL patterns you'll actually write

| Formula | English |
|---|---|
| `G p` | invariant: always `p` |
| `F p` | reachability: eventually `p` |
| `G F p` | **infinitely often** `p` |
| `F G p` | **eventually always** `p` (stabilization) |
| `G (p -> F q)` | **response**: every `p` is eventually followed by `q` |

::: notes
These five cover most real specs. G F p ("infinitely often") and F G p ("eventually always") are the two combinations people most often confuse — G F is for liveness/fairness ("the scheduler runs each process infinitely often"), F G is for stabilization ("after some point the system stays up"). G(p → F q) is the response pattern — the single most common real-world requirement ("every request eventually gets a response").
:::

---

## CTL — computation tree logic

CTL views the future as a **branching tree** of all possible paths. Each temporal operator is paired with a **path quantifier**:

- `A` — for **all** paths from this state.
- `E` — there **exists** a path from this state.

Then `AX, EX, AF, EF, AG, EG, A[p U q], E[p U q]`.

::: notes
CTL's branching view: at each state the future branches into all possible continuations (a tree). Every temporal operator must be prefixed by A (all branches) or E (some branch). That coupling is what makes CTL different from LTL — LTL has no E. The eight combinations (A/E × X/F/G/U) are the CTL operators.
:::

---

## CTL operators that matter

| Formula | English |
|---|---|
| `AG p` | invariant: `p` on all reachable states |
| `EF p` | reachability: some path reaches `p` |
| `AF p` | inevitability: every path eventually hits `p` |
| `EG p` | some path keeps `p` forever |
| `AG EF p` | from everywhere, `p` is still reachable ("recoverable") |

::: notes
AG = invariant (same intent as LTL's G but branching). EF = "can we reach it" — the existential reachability that LTL literally cannot express. AG EF p is the recoverability pattern: no matter where you are, you can always get back to p (e.g. AG EF (mode = off): the counter can always return home). This formula is the canonical example of something CTL can say and LTL cannot.
:::

---

## LTL vs CTL — incomparable

Neither subsumes the other:

- **CTL-only**: `AG EF p` — "from every reachable state, `p` is still reachable." LTL cannot say this (no existential path quantifier).
- **LTL-only**: `F G p` — "eventually `p` holds forever." CTL's `AF AG p` is *not* equivalent.

Most tools (nuXmv included) support both. **CTL\*** is the superset.

::: notes
This is the classic theorem (Week 10): LTL and CTL have incomparable expressive power. The two canonical witnesses: AG EF p (CTL, not LTL) and FG p (LTL, not CTL — AFAG p is strictly stronger). Don't belabor the proof; the practical point is "pick the logic that can express your property, and know that some tools/algorithms are faster for one than the other." CTL* unifies them but is rarely needed in practice.
:::

---

## Properties of the counter

| Property | Formula | Holds? |
|---|---|---|
| `x` never exceeds 10 | `AG (x <= 10)` | ✓ |
| can always get home | `AG EF (mode = off)` | ✓ |
| eventually stuck on | `F G (mode = on)` | ✗ |
| `x = 10` reachable from anywhere | `AG EF (x = 10)` | ✓ |

::: notes
Concrete specs on the running system. The first is the safety invariant we have proved every which way. The second and fourth are recoverability/reachability (CTL EF). The third is false — the counter does not get stuck in on; it always returns to off. Showing a false one keeps students honest about reading verdicts.
:::

---

## Live poll: match the English to the formula

1. Every reachable state has `x ≤ 10`.
2. Every reachable state can return to `mode = off`.
3. The system eventually settles in `mode = on` forever.
4. From every state, some path reaches `x = 10`.

**Choices:** A. `AG (x ≤ 10)` · B. `AG EF (mode = off)` · C. `F G (mode = on)` · D. `AG EF (x = 10)`

::: notes
Top Hat poll. 1→A, 2→B, 3→C, 4→D. The discriminating skill is recognizing AG EF (recoverability, CTL) vs F G (stabilization, LTL). After the vote, run each through nuXmv and show the verdicts: A, B, D are true; C is false (counter always leaves on).
:::

---

## A note on fairness

`counter.smv` has `FAIRNESS mode != off;` — restrict attention to executions where `mode != off` holds **infinitely often**.

- Fairness rules out "unrealistic" runs (e.g. the environment never pressing).
- It changes which liveness properties hold.
- Use it carefully: it is an assumption about the environment, not the system.

::: notes
Fairness is the subtle part of liveness verification. Without it, many liveness properties are trivially false because of degenerate runs (the environment refuses to ever press, so the counter sits in off forever). FAIRNESS conditions tell the model checker "only consider runs where this holds infinitely often." This is exactly how you model "a fair scheduler" or "an active environment." It is powerful and easy to misuse — a too-strong fairness assumption can make a buggy system look correct.
:::

---

## L2 recap

- **Temporal logic** expresses claims about executions, not single states.
- **LTL** (linear, all-paths) — `G`, `F`, `X`, `U`; patterns `G F`, `F G`, `G(p→F q)`.
- **CTL** (branching, `A`/`E`) — `AG`, `EF`, `AF`, `AG EF`.
- They are **incomparable**; `AG EF p` is CTL-only, `F G p` is LTL-only.
- **Fairness** restricts to realistic executions for liveness.

::: notes
Block recap. Take-home: you can translate an English requirement into CTL or LTL and know which logic can express it. That is the "specification" half of the triple. Next block: how nuXmv actually decides these, and hands-on.
:::

---

## ☕ Break {.section}

We resume after the break with model-checking algorithms and live nuXmv.

---

# L3 — Algorithms and live nuXmv {.section}

::: notes
Final block. Three algorithm families, the BDD machinery that makes symbolic model checking work, then hands-on nuXmv including reading a counterexample. Keep the algorithm slides crisp; spend the time on the live tool.
:::

---

## Three model-checking algorithms

| Algorithm | Stores | Strength | Limitation |
|---|---|---|---|
| **Explicit-state** | visited-state set (BFS/DFS) | simple, rich properties | state explosion |
| **Symbolic (BDD)** | boolean encoding of state *sets* | >100 state bits | variable-order sensitive; weak on arithmetic |
| **Bounded (SAT/SMT)** | length-`N` unrolling | no state space at all | refutes only; needs completeness arg |

nuXmv supports all three.

::: notes
The three families, the same ones Week 6/7 cover. Explicit-state (SPIN-style) enumerates states one at a time — simplest, but dies on big state spaces. Symbolic (the classic SMV/nuXmv approach) represents whole *sets* of states as boolean functions via BDDs, so it can handle astronomically many states if they compress well. Bounded (Day 1's approach) skips the state space entirely and unrolls — great for finding bugs, but only complete with extra work (k-induction, interpolation). nuXmv can do all three; you pick per problem.
:::

---

## Symbolic model checking: sets as formulas

Represent a **set of states** by a boolean formula true exactly on that set.

- Reachable set $R_0 = \text{init}$.
- $R_{k+1} = R_k \cup \text{Image}(R_k)$ — states reachable in one more step.
- Stop when $R_{k+1} = R_k$ (a **fixpoint**): that's all reachable states.
- Safety check: is $R_\infty \cap \text{Bad} = \varnothing$?

The whole computation is boolean-formula manipulation — no state is ever enumerated individually.

::: notes
This is the heart of symbolic model checking (Week 6/7). Instead of visiting states, you compute with their *characteristic functions*. Image computation (the set of one-step successors of a set) and union are operations on formulas. Iterating to a fixpoint gives the entire reachable set as one formula. Then safety is an emptiness check. The reason this scales: a formula over n boolean variables can describe up to 2^n states compactly — if it compresses. The data structure that makes the compression and the operations efficient is the BDD.
:::

---

## BDDs — binary decision diagrams

A **BDD** is a canonical, compressed decision tree for a boolean function.

- **Shannon expansion**: $f = (x \wedge f|_{x=1}) \vee (\neg x \wedge f|_{x=0})$.
- Apply recursively over a **fixed variable order** → a DAG.
- Reduce: merge identical subgraphs, drop redundant nodes.
- Result is **canonical**: two functions are equal iff their BDDs are identical.

::: notes
BDDs (Bryant 1986) are why symbolic model checking works. Shannon expansion splits a function on one variable; doing it over a fixed order and sharing common substructure yields a compact DAG. Canonicity is the magic property: equality of boolean functions becomes pointer equality of BDDs, so the fixpoint test (R_{k+1} = R_k) is cheap. The catch is on the next slide.
:::

---

## BDDs: variable ordering is everything

The same function can be **tiny or exponential** depending on variable order.

- Good order → linear-size BDD.
- Bad order → exponential blow-up.
- Finding the optimal order is itself NP-hard; tools use heuristics + dynamic reordering.

Arithmetic (multipliers) has **no** good order — BDDs are bad at it. That's where SAT/SMT (Day 1, Day 4) wins.

::: notes
The Achilles' heel of BDDs: variable ordering. A classic example is a multiplier circuit, whose BDD is exponential under every order — which is exactly why hardware multipliers are verified with SAT-based methods, not BDDs. nuXmv has dynamic reordering heuristics (the -dynamic flag we use in the autograder). The practical lesson: BDDs are spectacular for control-dominated logic and poor for data-path arithmetic; know which tool to reach for.
:::

---

## Bounded model checking, revisited

Day 1's idea, now in context:

- Unroll the transition relation `k` times into one big SAT/SMT formula.
- Ask: is there a length-`k` path to a bad state?
- **SAT** → bug found (a real counterexample). **UNSAT** → no bug *of length ≤ k*.

To make BMC **complete**: add k-induction or compute a completeness threshold (the diameter of the state graph).

::: notes
Tie back to Day 1. BMC is unbeatable at finding shallow bugs fast and gives a concrete counterexample. Its weakness is completeness — UNSAT at depth k says nothing about depth k+1. The fixes (k-induction, interpolation, IC3/PDR) turn BMC into a complete method; nuXmv implements several. For this course the message is: BMC refutes cheaply, symbolic/BDD proves exhaustively, and modern tools blend them.
:::

---

## Running nuXmv

```bash
nuXmv counter.smv          # batch: check every spec in the file
```

Interactive session:

```text
nuXmv -int counter.smv
> go                       # build the model
> check_invar              # all INVARSPECs
> check_ctlspec            # all CTLSPECs
> check_ltlspec            # all LTLSPECs
> quit
```

::: notes
Two modes. Batch (just `nuXmv file.smv`) checks every spec and prints verdicts — what the autograder uses. Interactive (`-int`) lets you build the model once with `go` and then run individual check commands, inspect the BDDs, simulate traces, etc. For class we mostly use batch; interactive is for exploration. (In our autograding image this is NuSMV, which shares the SMV language and verdict format.)
:::

---

## What a passing run looks like

```text
-- specification x <= count_max  is true
-- specification (mode = off) -> (x = 0)  is true
-- specification AG (AF (mode = off & x = 0))  is true
```

Each `INVARSPEC` / `CTLSPEC` / `LTLSPEC` prints `is true` or `is false`.

::: notes
The verdict line format is what every grader and human reads: "-- specification <text> is true|false". For invariants nuXmv prints "-- invariant ... is true". This exact format is what the Day-2 autograder greps for. Show students that "true" means "proved for all reachable states / all paths," not "no counterexample found up to some bound" — this is the full guarantee Day 1 couldn't give.
:::

---

## Reading a counterexample

Weaken `next(x)` (off-by-one: allow `x < count_max + 1`) and re-run:

```text
-- specification x <= count_max  is false
-- as demonstrated by the following execution sequence
  -> State: 1.1 <-  mode = off, x = 0,  press = FALSE
  -> State: 1.2 <-  mode = on,  x = 0,  press = FALSE
  ...
  -> State: 1.12 <- mode = on,  x = 11, press = FALSE
```

The trace is a **witness** — the exact input sequence that breaks the property.

::: notes
The counterexample is the single most useful output of a model checker. It is not "something failed" — it is a concrete, replayable execution: the precise sequence of inputs (press values) and the resulting states, ending at the violating state (x = 11). This is debugging gold: you can step through it, reproduce it, and fix the exact transition. Contrast with a failed test, which tells you *that* something broke; the counterexample tells you *how*.
:::

---

## Counterexamples for different property types

- **Invariant / `AG` false** → a finite path to a bad state.
- **`EF p` true** → a finite witness path that reaches `p`.
- **`F p` false / liveness** → a **lasso**: a stem plus a cycle where `p` never happens.

::: notes
The shape of the counterexample depends on the property. Safety violations are finite paths. Existential properties (EF) come with a witness path. Liveness violations are lassos — the model checker shows a cycle the system can get stuck in where the "good thing" never occurs. Recognizing the lasso is how you debug a stuck-system liveness bug.
:::

---

## Same algorithms, industrial scale

The exact methods on these slides run on the largest chips and systems:

- **Cadence JasperGold**, **Synopsys VC Formal** — symbolic + BMC on every modern SoC.
- **SymbiYosys** (open-source) — SAT-based on Verilog.
- **Intel** post-FDIV — formal hardware verification as a release gate.

The counter is a toy; the engine is production-grade.

::: notes
Close the loop to Day 1's industrial framing. The student should leave knowing that "model checking" is not academic — it is the verification backbone of the semiconductor industry. JasperGold runs on Apple Silicon; the FDIV bug (Day 1) is precisely why. Same BDD/SAT engines, same temporal-logic specs, just at billions-of-states scale with heavy engineering.
:::

---

## L3 recap

- **Explicit / symbolic / bounded** — three engines; nuXmv has all.
- **Symbolic MC** computes the reachable set as a fixpoint over **BDDs**; ordering is everything.
- **BMC** refutes cheaply; k-induction makes it complete.
- A **counterexample** is a concrete, replayable witness — finite path or lasso.

::: notes
Block recap. Take-home: you can run nuXmv, read a verdict, and read a counterexample. Combined with L1 (model) and L2 (spec), you have the whole model-checking workflow. The mini-project is where you do it on your own system.
:::

---

# Wrap + work {.section}

---

## Day 2 in one slide

- A reactive system is a transition system; **SMV** writes it directly.
- **Temporal logic** (CTL/LTL) expresses correctness over executions.
- A **model checker** decides those properties exhaustively for finite state.
- Output is a **true/false verdict** plus, on failure, a **counterexample**.
- Same counter as Day 1 — but now verified for **all** behaviors, not just length ≤ N.

::: notes
The throughline. Day 1 refuted bounded; Day 2 proves unbounded for finite systems. Read this aloud as the closing summary.
:::

---

## Day 3 preview

- Same counter. New tool: **Lean 4**.
- When finite state isn't enough — parametric `n`, unbounded integers, real mathematics.
- Prove the invariant **by induction on the transition relation**, not by enumeration.
- AI (Claude Code) as a proof-drafting partner.

::: notes
The bridge: model checking enumerates a finite reachable set; theorem proving proves properties of *infinite* or *parametric* systems by induction. The counter's invariant, proved in Lean, holds for any bound and any trace length, with a machine-checked certificate. That is Day 3.
:::

---

## In-session exercise

With `nuXmv` (or the smvis tool) on `counter.smv`:

1. Confirm the passing `INVARSPEC`s are `true` and the deliberately-false ones are `false`.
2. Introduce the off-by-one bug in `next(x)`; read the counterexample; identify the exact press sequence.
3. Revert. Write **one new** CTL or LTL property of your own and check it.

::: notes
Self-contained, runs in the room. The deliverable is a counterexample you can read plus one original property. The third part forces translating an English idea into temporal logic and getting a verdict — the core Day 2 skill.
:::

---

## Homework (ungraded, for depth)

Pick **one** of `traffic_light.smv`, `mutex.smv`, `gcd_01.smv`:

- Verify the two given properties; explain each verdict.
- Add and verify **one safety** and **one liveness** property of your own.
- For `mutex`: state mutual exclusion (`AG !(p1=crit & p2=crit)`) and no-starvation (`AG(p1=wait -> AF p1=crit)`).

See [`assignments/day02.md`](../assignments/day02.md).

::: notes
The homework deepens the model-checking workflow on a non-counter system. Mutex is the richest: mutual exclusion (safety) and no-starvation (liveness, needs fairness) are the two canonical concurrency properties and a great test of the CTL/LTL skill. Not graded; we compare notes at the start of Day 3.
:::

---

## References for Day 2

- **Clarke, Grumberg, Kroening, Peled, Veith.** *Model Checking* (2nd ed.), MIT Press 2018 — the canonical reference.
- **Baier, Katoen.** *Principles of Model Checking*, MIT Press 2008 — CTL/LTL chapters.
- **Cavada et al.** *The nuXmv Symbolic Model Checker*, CAV 2014.
- **Bryant.** *Graph-Based Algorithms for Boolean Function Manipulation*, IEEE TC 1986 — BDDs.
- **nuXmv user manual** — <https://nuxmv.fbk.eu/>
- **smvis** (browser nuXmv + visualizations) — <https://github.com/verivital/smvis>

Full list: repo [README.md](../../README.md#background-references).

::: notes
Curated to the essentials. Baier/Katoen is the most readable modern textbook; the Clarke et al. Model Checking is the reference. smvis is the in-house tool that visualizes state graphs and BDDs — great for building intuition about what the model checker is actually doing.
:::

---

## Next session: Day 3

Repo: [github.com/ttj/fmaiv](https://github.com/ttj/fmaiv) — slides, the four `.smv` examples, and the assignment.

::: notes
Day 3 opens with a short recap and a check-in on the homework, then moves to Lean 4 and proof by induction.
:::
