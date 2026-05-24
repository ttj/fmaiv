---
title: "Day 2 — Model Checking with nuXmv"
subtitle: "FMAIV: Formal Methods & AI-Assisted Verification"
author:
  - "Taylor Johnson — Associate Professor of Computer Science, Computer Engineering & Electrical Engineering; Associate Dean for Graduate Education, College of Connected Computing · taylor.johnson@vanderbilt.edu · [taylortjohnson.com](https://www.taylortjohnson.com/)"
  - "Ben Wooding — Postdoctoral Scholar, Institute for Software Integrated Systems · ben.wooding@vanderbilt.edu · [woodingben.com](https://woodingben.com/)"
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

## "nuXmv" vs "NuSMV" — what you'll actually run

The slides say **nuXmv**; the course autograder runs **NuSMV 2.6.0**. They share the SMV language and the `is true / is false` verdict format, so everything here works in both.

| Capability | NuSMV 2.6.0 (what you run) | nuXmv (superset) |
|---|---|---|
| Symbolic (BDDs, binary decision diagrams) model checking | ✓ | ✓ |
| Bounded model checking (SAT) | ✓ | ✓ |
| k-induction for invariants | ✓ | ✓ |
| IC3 / PDR, infinite-state (SMT) | — | ✓ |

We *mention* the nuXmv-only features but never require them.

::: notes
Set expectations up front so nobody is confused when the tool they install is called NuSMV. The two are command-line-compatible for everything we do: same `.smv` files, same `INVARSPEC/CTLSPEC/LTLSPEC`, same verdict text. nuXmv adds IC3/PDR and infinite-state SMT-based checking on top; we point those out but the homework and autograder only use NuSMV features. Note both are symbolic-first (BDD + SAT engines); explicit-state enumeration is SPIN's domain (see the algorithms slide).
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
Worth a beat: the synchrony hypothesis is an abstraction, and like all abstractions it can be wrong (if the system is too slow to keep up with the environment). For the systems we model check it is the standard, sound idealization. It is why "one step of the transition relation" = "one round" cleanly.
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
- `0..25` makes `x` finite, so the state space is finite. The wide range is **headroom**: in the correct counter only `0–10` ever occur (12 states reachable from the initial state), and the spare range lets the off-by-one demo reach `x = 11` without overflowing the declared type.

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

In SMV, `&` = and, `|` = or, `!` = not; a `case` picks the **first** guard that matches (top to bottom), and `TRUE :` is the catch-all default.

This is the same counter, line for line — and the same four guards as the Z3 `step()` from Day 1.

::: notes
Walk the case statement: top-to-bottom, first matching guard wins, TRUE is the catch-all. Point out that this is exactly the four-clause case analysis from Day 1's z3_counter_bounded.py, just in SMV syntax. The next(mode) and next(x) clauses together define the transition relation. The same case analysis will reappear in Lean (Day 3) and C/Cryptol (Day 4) — five encodings, one system. On Day 3, `smv2lean` even auto-translates this very `.smv` into its Lean transition system.
:::

---

## Specifications live in the same file

```smv
INVARSPEC x <= count_max;             -- safety: always true
INVARSPEC (mode = off) -> (x = 0);    -- conditional safety
CTLSPEC   AG AF (mode = off & x = 0); -- always eventually "home"
LTLSPEC   F (x = count_max);          -- eventually maximal
```

- `->` reads "implies": `A -> B` says whenever `A` holds, `B` must too.
- `INVARSPEC p` — `p` holds in every reachable state (pure safety).
- `CTLSPEC` / `LTLSPEC` — richer temporal properties (next block).
- nuXmv checks **every** spec in the file when you run it.

::: notes
Properties and model in one file is an SMV convention worth highlighting — the spec is version-controlled alongside the system. INVARSPEC is the special, fast case (a pure invariant); CTLSPEC and LTLSPEC are the general temporal cases. We will see in counter.smv that some specs are deliberately FALSE — that is intentional, so students see both verdicts.
:::

---

## Four SMV modeling idioms

The whole language is small. Four idioms cover almost everything you'll write:

- **Free input** — a `VAR` with no `init`/`next`. The environment picks any value each round (`press`). This is how nondeterminism enters with *zero* extra syntax.
- **Explicit nondeterminism** — `next(s) := {idle, waiting};` means the next value is chosen from the set, nondeterministically. (Used in `mutex.smv`: `process1 = idle : {idle, waiting}`.)
- **`DEFINE`** — `DEFINE d := b | c;` is a *macro*: every use of `d` is textually replaced by `(b | c)`. No new state variable, no extra BDD variable — just a name for a sub-expression.
- **`MODULE`** — a reusable component, instantiated like an object: `proc1 : user(sem);`. Each instance gets its own copy of the local variables (`proc1.state`).

::: notes
Straight from Week 5's SMV-language slides. The free-input idiom is the one beginners miss — an unassigned VAR is not "undefined," it is "the environment's choice," which is exactly how you model an open system. The `{...}` set-expression is the second source of nondeterminism (an under-specified or abstract design). DEFINE vs VAR matters for BDD size: a DEFINE adds no BDD variable (the sub-formula is inlined wherever used), whereas an ASSIGNed VAR becomes part of the invariant relation and costs a variable. MODULE + dotted names (`proc1.state`) is how the mutex and Peterson examples build two processes from one template — preview of the concurrency examples.
:::

---

## Synchronous vs. asynchronous composition

When you compose components, *whose clock ticks?*

- **Synchronous** — every component takes a step **together**, each round. One step of the whole = one step of *each* part. (Hardware on a shared clock; our `traffic_light.smv` updates all three lights every tick.)
- **Asynchronous** — one step of the whole = a step by **exactly one** component; the others' variables stay unchanged (an *interleaving*). (Threads, distributed processes.)

SMV models asynchrony *inside* the synchronous framework: add a scheduler that picks who moves (this is `peterson.smv`'s scheduler variable).

::: notes
Week 5's composition slides. The distinction is the single biggest modeling decision for concurrency. Synchronous = lock-step (every assignment fires each round); asynchronous = pick-one-and-step, leaving the rest frozen — which is what generates the interleaving explosion. The classic gotcha: asynchronous composition has many more reachable states for the same components, because every interleaving order is a distinct path. SMV's old `process` keyword did this automatically but is deprecated; our examples (peterson) instead add an explicit scheduler input — a free VAR that nondeterministically names which process moves — which is both clearer and not deprecated. This is also why a frame condition (`y' = y` for the non-moving process) matters: in asynchronous steps you must say the others don't change.
:::

---

## counter.smv has true *and* false specs on purpose

[`counter.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/counter.smv) includes specs that **hold** and specs that **fail**:

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
| [`counter.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/counter.smv) | the running counter | nondeterministic input |
| [`traffic_light.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/traffic_light.smv) | four-phase intersection | timed phases, mutual exclusion of greens |
| [`mutex.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/mutex.smv) | two-process mutual exclusion | flags + turn (idle/waiting/critical) |
| [`peterson.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/peterson.smv) | Peterson's algorithm | interleaving scheduler + fairness |
| [`elevator.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/elevator.smv) | single-car elevator | request handling, safety |
| [`gcd_01.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/gcd_01.smv) | Euclid's GCD | explicit program counter (a *program* as a TS) |

::: notes
These show the range of SMV modeling. The four original files (counter, traffic_light, mutex, gcd_01) come from verivital/smvis; peterson and elevator are course-specific examples that avoid the deprecated `process` keyword. mutex and peterson are the classic concurrency examples (peterson is the genuinely-Peterson one). gcd_01 shows the key trick for turning an ordinary sequential program into a transition system: add a program-counter variable ranging over line labels — a preview of Day 4, where CBMC does this for C automatically.
:::

---

## [traffic_light.smv](https://github.com/ttj/fmaiv/blob/main/day02/examples/traffic_light.smv) as a state machine

<svg viewBox="0 0 960 210" style="display:block;margin:0.3em auto;max-width:96%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs>
    <marker id="tl-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/>
    </marker>
  </defs>
  <line x1="200" y1="129" x2="268" y2="129" stroke="#5b6168" stroke-width="1.8" marker-end="url(#tl-ah)"/>
  <text x="234" y="120" text-anchor="middle" font-size="12.5" fill="#946E24">timer = 4</text>
  <line x1="440" y1="129" x2="508" y2="129" stroke="#5b6168" stroke-width="1.8" marker-end="url(#tl-ah)"/>
  <text x="474" y="120" text-anchor="middle" font-size="12.5" fill="#946E24">1 tick</text>
  <line x1="680" y1="129" x2="748" y2="129" stroke="#5b6168" stroke-width="1.8" marker-end="url(#tl-ah)"/>
  <text x="714" y="120" text-anchor="middle" font-size="12.5" fill="#946E24">timer = 2</text>
  <path d="M835,100 L835,50 L115,50 L115,100" fill="none" stroke="#5b6168" stroke-width="1.8" marker-end="url(#tl-ah)"/>
  <text x="475" y="42" text-anchor="middle" font-size="12.5" fill="#946E24">1 tick (cycle repeats)</text>
  <rect x="30" y="100" width="170" height="58" rx="10" fill="#e7f6ec" stroke="#27843f" stroke-width="2"/>
  <text x="115" y="124" text-anchor="middle" font-size="14.5" fill="#1c1c1c">main: green</text>
  <text x="115" y="145" text-anchor="middle" font-size="14.5" fill="#1c1c1c">side: red</text>
  <rect x="270" y="100" width="170" height="58" rx="10" fill="#fbf3df" stroke="#B49248" stroke-width="2"/>
  <text x="355" y="124" text-anchor="middle" font-size="14.5" fill="#1c1c1c">main: yellow</text>
  <text x="355" y="145" text-anchor="middle" font-size="14.5" fill="#1c1c1c">side: red</text>
  <rect x="510" y="100" width="170" height="58" rx="10" fill="#e7f6ec" stroke="#27843f" stroke-width="2"/>
  <text x="595" y="124" text-anchor="middle" font-size="14.5" fill="#1c1c1c">main: red</text>
  <text x="595" y="145" text-anchor="middle" font-size="14.5" fill="#1c1c1c">side: green</text>
  <rect x="750" y="100" width="170" height="58" rx="10" fill="#fbf3df" stroke="#B49248" stroke-width="2"/>
  <text x="835" y="124" text-anchor="middle" font-size="14.5" fill="#1c1c1c">main: red</text>
  <text x="835" y="145" text-anchor="middle" font-size="14.5" fill="#1c1c1c">side: yellow</text>
  <text x="115" y="182" text-anchor="middle" font-size="11.5" fill="#5b6168">▲ initial</text>
</svg>

Four phases cycle in order; the `timer` counts ticks within each phase. Exactly one direction is ever non-red, so the safety invariants — never two greens, never two yellows — are intended to hold; we confirm them with nuXmv.

::: notes
The same SMV file (`traffic_light.smv`), drawn as the state machine it describes. The three `next(...)` case statements jointly walk this 4-cycle: green→yellow→red on the main side, interleaved with the side road. This is the picture students should sketch before writing any temporal property: once you can see the cycle, "never two greens" (`AG !(main=green & side=green)`) and "main always eventually green" (`AG AF main=green`) are obvious. Note both yellow phases are gold-tinted, both green phases green-tinted — color carries meaning here.
:::

---

## A program as a transition system: [gcd_01.smv](https://github.com/ttj/fmaiv/blob/main/day02/examples/gcd_01.smv)

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

## Two property shapes: safety and liveness

Almost every requirement is one of these (or a combination):

- **Safety** — *"something bad never happens."* A counterexample is a **finite path** to the bad state. *(e.g. `x` never exceeds 10; two greens never lit together.)*
- **Liveness** — *"something good eventually happens."* A counterexample is an **infinite run** (a lasso) where the good thing never occurs. *(e.g. every waiting process eventually enters its critical section.)*

::: notes
This vocabulary is the backbone of the whole day, so name it explicitly before the operators. The rule of thumb: safety is refuted by a finite trace you can point at; liveness is refuted by an infinite trace (a loop) where the promised good event never arrives. Invariants (`G`/`AG`) are the canonical safety properties; "eventually"/"infinitely often" (`F`, `G F`) are the canonical liveness ones. Lamport's original framing (1977) is exactly this two-way split.
:::

---

## LTL — linear temporal logic

LTL views the future as a **single path** (implicitly, all paths). Operators on a path:

- `X p` — **neXt**: `p` in the next state.
- `F p` — **Finally** (eventually): `p` at some future state.
- `G p` — **Globally** (always): `p` at every future state.
- `p U q` — **Until**: `p` holds until `q` becomes true (and `q` does eventually become true).
- `p R q` — **Release** (the dual of *until*): `q` must stay true up to and including the moment `p` first becomes true — and forever if `p` never does.

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

## One trace, marked up

Fix one counter run and mark where `mode = on` holds (●) vs not (○):

```text
position:  s0   s1   s2   s3   s4   s5   s6  ...
mode=on:   ○    ●    ●    ●    ●    ○    ●   ...
            (off) (on)(on)(on)(on)(off)(on)
```

We'll read each LTL operator against **this one trace**, from position `s0`. The valuation function gives each proposition a 0/1 at each position; an operator is a claim about the rest of the trace from where you stand.

Notation on the next slides: `(ρ, n) ⊨ φ` reads "trace `ρ` at position `n` **satisfies** `φ`"; `∃` = "there exists", `∀` = "for all".

<svg viewBox="0 0 760 140" style="display:block;margin:0.3em auto;max-width:94%;height:auto" font-family="Inter, system-ui, sans-serif">
  <circle cx="57"  cy="30" r="7" fill="#ffffff" stroke="#5b6168" stroke-width="1.6"/>
  <circle cx="163" cy="30" r="7" fill="#B49248"/>
  <circle cx="269" cy="30" r="7" fill="#B49248"/>
  <circle cx="375" cy="30" r="7" fill="#B49248"/>
  <circle cx="481" cy="30" r="7" fill="#B49248"/>
  <circle cx="587" cy="30" r="7" fill="#ffffff" stroke="#5b6168" stroke-width="1.6"/>
  <circle cx="693" cy="30" r="7" fill="#B49248"/>
  <rect x="16"  y="46" width="82" height="34" rx="8" fill="#faf7f0" stroke="#B49248" stroke-width="2"/><text x="57"  y="68" text-anchor="middle" font-size="13.5" fill="#1c1c1c">off</text>
  <rect x="122" y="46" width="82" height="34" rx="8" fill="#f6eeda" stroke="#B49248" stroke-width="2"/><text x="163" y="68" text-anchor="middle" font-size="13.5" fill="#1c1c1c">on</text>
  <rect x="228" y="46" width="82" height="34" rx="8" fill="#f6eeda" stroke="#B49248" stroke-width="2"/><text x="269" y="68" text-anchor="middle" font-size="13.5" fill="#1c1c1c">on</text>
  <rect x="334" y="46" width="82" height="34" rx="8" fill="#f6eeda" stroke="#B49248" stroke-width="2"/><text x="375" y="68" text-anchor="middle" font-size="13.5" fill="#1c1c1c">on</text>
  <rect x="440" y="46" width="82" height="34" rx="8" fill="#f6eeda" stroke="#B49248" stroke-width="2"/><text x="481" y="68" text-anchor="middle" font-size="13.5" fill="#1c1c1c">on</text>
  <rect x="546" y="46" width="82" height="34" rx="8" fill="#faf7f0" stroke="#B49248" stroke-width="2"/><text x="587" y="68" text-anchor="middle" font-size="13.5" fill="#1c1c1c">off</text>
  <rect x="652" y="46" width="82" height="34" rx="8" fill="#f6eeda" stroke="#B49248" stroke-width="2"/><text x="693" y="68" text-anchor="middle" font-size="13.5" fill="#1c1c1c">on</text>
  <text x="57"  y="100" text-anchor="middle" font-size="12" fill="#5b6168">s₀</text>
  <text x="163" y="100" text-anchor="middle" font-size="12" fill="#5b6168">s₁</text>
  <text x="269" y="100" text-anchor="middle" font-size="12" fill="#5b6168">s₂</text>
  <text x="375" y="100" text-anchor="middle" font-size="12" fill="#5b6168">s₃</text>
  <text x="481" y="100" text-anchor="middle" font-size="12" fill="#5b6168">s₄</text>
  <text x="587" y="100" text-anchor="middle" font-size="12" fill="#5b6168">s₅</text>
  <text x="693" y="100" text-anchor="middle" font-size="12" fill="#5b6168">s₆ ⋯</text>
  <text x="57"  y="124" text-anchor="middle" font-size="11.5" fill="#946E24">▲ you are here</text>
</svg>

Caption: the same run, drawn as a timeline — every LTL operator below is read off this picture.

::: notes
Establish ONE concrete trace before walking the operators, so each operator slide refers to the same picture (we do exactly this in the LTL-semantics video: "everything we define will be with respect to a trace"). The marking ●/○ for on/off lets students literally point. From the counter's structure this run is realistic: off, then a press flips it on (s1), it counts s1..s4, resets to off at s5, on again at s6. Position numbering starts at s0 = time 0 (the video's "if we omit n we mean time zero").
:::

---

## `X p` — neXt, on the trace

`X p` ("in the next state, `p`") looks **exactly one step** forward.

- At `s0`: `X (mode = on)` asks "is `mode = on` at `s1`?" — `s1` is ● → **true**.
- At `s4`: `X (mode = on)` asks about `s5` — `s5` is ○ → **false**.

$$(\rho, n) \models X\,p \quad\text{iff}\quad (\rho, n{+}1) \models p$$

`X` is the only operator that pins down a single, exact position. Everything else quantifies over a *range* of future positions.

::: notes
X is the simplest semantics — shift by one. Glossing: ρ is the trace, n the position, ⊨ "satisfies." Emphasize "exactly one step": beginners conflate X ("the very next state") with F ("some later state"). The counter makes the difference visible — X(on) at s0 is true but is a different claim from F(on). nuXmv supports X in LTLSPEC; note CTL's analogue needs a path quantifier (AX/EX), the subject of the CTL slides.
:::

---

## `F p` — Finally / eventually, on the trace

`F p` ("at some position now or later, `p`") is an **existential** over future positions.

- `F (x = count_max)` on the counter: is there *any* position where `x = 10`? On a counting run, yes → **true**.
- `F (mode = on)` at `s0`: `s1` is already ● → **true** (the witness can be the current state or any later one).

$$(\rho, n) \models F\,p \quad\text{iff}\quad \exists\, m \ge n.\ (\rho, m) \models p$$

One witnessing position is enough. `F` is how you say "reachable along this run."

::: notes
F = "there exists a future position." The existential is the key word — one witness suffices, which is why F is the liveness/reachability workhorse. Note m ≥ n (not m > n): p at the current position counts. Tie to Day 1: "F (x=10)" is the LTL way to ask the bounded-reachability question Z3 asked, but now over the whole infinite run, not length ≤ N.
:::

---

## `G p` — Globally / always, on the trace

`G p` ("at every position from here on, `p`") is the **universal** dual of `F`.

- `G (x <= count_max)` on the counter: every reachable state has `x ≤ 10` → **true** (this is the safety invariant).
- `G (mode = on)` at `s0`: `s0` is ○ → **false** (one bad position kills it).

$$(\rho, n) \models G\,p \quad\text{iff}\quad \forall\, m \ge n.\ (\rho, m) \models p \qquad G\,p \equiv \neg F \neg p$$

A single position where `p` fails refutes `G p`. `G`/`F` are De Morgan duals: "always" = "never not."

::: notes
G = "for all future positions." Contrast sharply with F: F needs one good position, G needs all positions good; one bad one is a counterexample (finite prefix!). The duality G p ≡ ¬F¬p is the temporal De Morgan — worth saying aloud because it is the bridge to "a safety violation is a reachable ¬p state." This G is exactly INVARSPEC's meaning, and the canonical safety property.
:::

---

## `p U q` — Until, on the trace

`p U q` ("`p` holds until `q` does, and `q` *does* eventually") bundles a deadline with an obligation.

- `(mode = on) U (mode = off)` at `s1`: `mode = on` at `s1..s4`, then `mode = off` at `s5` → **true**.
- It would be **false** if `mode` never returned to off (the obligation "`q` eventually" is unmet) — even though `p` held the whole time.

$$(\rho, n) \models p\,U\,q \;\;\text{iff}\;\; \exists\, m \ge n.\ (\rho, m)\models q \ \wedge\ \forall\, i,\ n \le i < m.\ (\rho, i)\models p$$

`F` and `G` are special cases: $F\,q \equiv \text{true}\,U\,q$, and `U` is the most expressive basic operator.

::: notes
Until is the expressive one — strong until here (the textbook/Alur default): q is REQUIRED to happen, and p must hold strictly before it (positions i with n ≤ i < m; p need not hold AT m). The two failure modes: (1) q never comes, (2) p drops before q arrives. Show both on the trace. F q = true U q makes F a derived operator; this is why a minimal LTL is just X and U. nuXmv writes it `p U q` in LTLSPEC.
:::

---

## `p R q` — Release (the dual of Until)

`p R q` ("`q` must hold up to **and including** the step where `p` first becomes true — and forever if `p` never does"):

$$p\,R\,q \;\equiv\; \neg(\neg p\,U\,\neg q)$$

- `q` is the **guarantee**; `p` is the event that **releases** it.
- If `p` never happens, `q` must hold forever — so $G\,q \equiv \text{false}\,R\,q$.

Example: `(mode = off) R (x <= count_max)` — "`x ≤ 10` stays true at least until the counter is off." Since `x ≤ 10` always holds, this is **true** whether or not `mode` ever turns off.

::: notes
Release is the De Morgan dual of Until and the operator students find slipperiest. The intuition: q is a promise that holds continuously until p "releases" it from holding; if p never fires, the promise holds forever — which is why G q = false R q. Defining it via the dual ¬(¬p U ¬q) ties it back to Until and the duality theme. It is rarely written by hand but appears constantly as the result of pushing negations inward (e.g., negating p U q for a counterexample automaton), so it earns one slide.
:::

---

## Why finite-state ⇒ decidable: the lasso

A trace is infinite, but a finite system has only finitely many states — so any infinite run must **revisit** a state, then it can repeat that loop forever.

- Every infinite behavior = a **stem** (finite prefix) + a **cycle** (repeated forever) = a **lasso**.
- There are only finitely many distinct stems and cycles.
- So "does *some* infinite run violate the property?" becomes a **finite** search over lassos.

That is why model checking decides $G\,p$, $F\,G\,p$, "infinitely often," etc., even though they quantify over infinite time.

<svg viewBox="0 0 540 214" style="display:block;margin:0.3em auto;max-width:60%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs><marker id="lasso-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6.5" markerHeight="6.5" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/></marker></defs>
  <line x1="63" y1="110" x2="100" y2="110" stroke="#5b6168" stroke-width="1.8" marker-end="url(#lasso-ah)"/>
  <line x1="138" y1="110" x2="175" y2="110" stroke="#5b6168" stroke-width="1.8" marker-end="url(#lasso-ah)"/>
  <line x1="212" y1="104" x2="284" y2="78" stroke="#5b6168" stroke-width="1.8" marker-end="url(#lasso-ah)"/>
  <line x1="318" y1="70" x2="422" y2="70" stroke="#5b6168" stroke-width="1.8" marker-end="url(#lasso-ah)"/>
  <line x1="440" y1="88" x2="440" y2="132" stroke="#5b6168" stroke-width="1.8" marker-end="url(#lasso-ah)"/>
  <line x1="422" y1="150" x2="318" y2="150" stroke="#5b6168" stroke-width="1.8" marker-end="url(#lasso-ah)"/>
  <line x1="300" y1="132" x2="300" y2="88" stroke="#5b6168" stroke-width="1.8" marker-end="url(#lasso-ah)"/>
  <circle cx="45" cy="110" r="18" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <circle cx="120" cy="110" r="18" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <circle cx="195" cy="110" r="18" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <circle cx="300" cy="70" r="18" fill="#efe1c0" stroke="#946E24" stroke-width="2"/>
  <circle cx="440" cy="70" r="18" fill="#efe1c0" stroke="#946E24" stroke-width="2"/>
  <circle cx="440" cy="150" r="18" fill="#efe1c0" stroke="#946E24" stroke-width="2"/>
  <circle cx="300" cy="150" r="18" fill="#efe1c0" stroke="#946E24" stroke-width="2"/>
  <text x="120" y="170" text-anchor="middle" font-size="12.5" fill="#5b6168">stem</text>
  <text x="370" y="200" text-anchor="middle" font-size="12.5" fill="#946E24">cycle (repeats forever)</text>
</svg>

Caption: every infinite run through finitely many states is a lasso — a stem into a repeating cycle — which is what makes infinite-time properties decidable.

::: notes
This is the conceptual keystone for the whole liveness story (Week 10) and answers the student question logged in week10 ("how are these eventual questions decidable but not the halting problem?"): the halting problem has unboundedly many states (a tape), but a FINITE-state system's runs are lassos, so checking "is there an accepting cycle?" is a finite graph search (the pigeonhole argument: finitely many states ⇒ some state recurs). This is the bridge to Büchi-automata model checking — an LTL property becomes "is there a reachable cycle satisfying the negation?" Keep it intuitive; the automata machinery is Week 10, not needed here.
:::

---

## How the check works: LTL → Büchi → emptiness

The lasso is the *what*; here is the *how* — the classic algorithm (SPIN's **explicit-state** engine; nuXmv reaches the same verdict *symbolically*, next block):

1. **Negate & translate.** Build a **Büchi automaton** for **¬φ** — it accepts exactly the *bad* runs (those violating φ).
2. **System as automaton.** View the model `K` as an automaton whose language is all its executions.
3. **Product.** Form `K × B₍¬φ₎`; its language is the runs of `K` that are *also* bad = `L(K) ∩ L(¬φ)`.
4. **Emptiness.** Is that language empty? **Empty ⇒ no bad run ⇒ K ⊨ φ.** Non-empty ⇒ an accepting **lasso** — your counterexample.

It is valid because `L(K) ⊆ L(φ)` **iff** `L(K) ∩ L(¬φ) = ∅` — the same "assert the negation, hunt for a witness" move as SAT/SMT. Emptiness = a linear-time search for a reachable accepting cycle (nested depth-first search).

::: notes
The machinery behind the lasso, made explicit (the automata-theoretic approach of Vardi & Wolper, as taught in CMU 15-414 lectures 17/20 and Oxford's CAV course). Keep it to the four steps. The deep idea worth landing: model checking is *language containment* — the system's behaviors should all be "good" behaviors, i.e. L(K) ⊆ L(φ). That containment holds exactly when there's no behavior that is both a real run AND a violation, i.e. L(K) ∩ L(¬φ) = ∅ — which is why we translate the *negation* into a Büchi automaton (it recognizes violations) and intersect. The product's language is empty iff no reachable accepting cycle exists, decided in linear time by nested DFS (SPIN's algorithm) or SCC detection. Two callbacks: (1) it's the exact "assert ¬φ, look for a model" move from SAT/SMT entailment, now over infinite words; (2) the witness is precisely the lasso from the previous slide. This is the explicit-state counterpart to the symbolic methods coming up.
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

## `G F p` — infinitely often, worked

`G F p` = "at **every** position, `p` happens **again** later" = `p` recurs forever (the **recurrence** pattern).

- Counter: `G F (mode = off & x = 0)` is **true** — every fair run keeps returning home. (This is a *shipped* `counter.smv` spec that passes.)
- Traffic light: `G F (main_light = green)` is **true** — the cycle relights main green forever.

**Violating trace** looks like: `p` happens a *last* time and then never again — e.g. a run that gets stuck `mode = on` would falsify `G F (mode = off)`.

::: notes
G F = "infinitely often" = Repeatedly (Alur's name, Week 9). The reading we use: "at whatever step we're talking about, there is always a p in the future." This is THE liveness/fairness shape (a fair scheduler runs each process infinitely often). The violating shape is a lasso whose cycle has no p — connect to the lasso slide. Both examples here are real shipped specs that pass, so students can run them.
:::

---

## `F G p` — stabilization, worked

`F G p` = "from **some** position on, `p` holds **forever** after" = the system settles (the **persistence** pattern).

- Counter: `F G (mode = on)` is **false** — reaching `x = 10` always forces `off`, so `on` can never become permanent. (Shipped failing spec.)
- A thermostat reaching and holding setpoint: `F G (|temp - target| < 1)` — **true** if it eventually stops oscillating.

`F G p` and `G F p` are the two most-confused combinations: `G F` = "comes back forever," `F G` = "stays put eventually." `F G p` is **stronger** ($F G\,p \Rightarrow G F\,p$).

::: notes
F G = "eventually always" = Persistently. The duality (Week 9): Repeatedly p ≡ ¬Persistently ¬p, and Persistently is strictly stronger than Repeatedly. The counter example is shipped and FALSE — a great contrast with the previous slide's true G F. Hammer the confusion pair: students should be able to say which of G F / F G a plain-English requirement needs. "Eventually the server stays up" = F G; "the server is up infinitely often" = G F.
:::

---

## `G (p -> F q)` — response, worked

`G (p -> F q)` = "**every** time `p` happens, `q` happens **at or after** it" — the single most common real requirement.

- Mutex: `G (process1 = waiting -> F (process1 = critical))` — "every request is eventually served" (no starvation). Shipped `mutex.smv` spec.
- `request -> F grant`, `press -> F door_opens`, `alarm -> F shutdown`.

**Violating trace**: a `p` with no later `q` — e.g. `process1` waits, but a cycle keeps letting `process2` in forever while `process1` never enters. That stuck cycle is the counterexample.

::: notes
The response pattern — G(p → F q) — is the workhorse of real specs (Dwyer's specification patterns put "response" at the top by frequency). Our phrasing: "if p has occurred then eventually q has occurred, and this should occur infinitely often." Tie the violation to the lasso AND to fairness: without fairness, the no-starvation property genuinely fails (the mutex file even warns about this in its comments), because an unfair run can starve process1 — exactly the cycle counterexample. This motivates the fairness slide later.
:::

---

## Quick warning: `F p & F q` ≠ `F (p & q)`

Splitting a temporal operator across a connective changes the meaning.

- `F p & F q` — `p` happens *sometime*, `q` happens *sometime* — possibly at **different** positions.
- `F (p & q)` — `p` and `q` true at the **same** position.

On the trace `x = 0,1,0,1,0,1,\dots`: `F(x=0) & F(x=1)` holds, but `F(x=0 & x=1)` is impossible. The first is **strictly weaker**.

::: notes
This is our own worked counterexample (Week 9, repeated twice in the videos and the robot-goals example): Eventually(p)&Eventually(q) does NOT distribute into Eventually(p&q). The 0,1,0,1 trace is exactly the disproof we give. Useful because it generalizes: F distributes over ∨ but not ∧; G distributes over ∧ but not ∨. A frequent real bug — writing F a & F b when you meant the events to coincide.
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

## The computation tree

Unfold the transition system from the initial state: each branch is a nondeterministic choice. The result is the **computation tree** — *all* possible futures at once.

```text
                (off,0)
                /      \         <- press? two choices
           (off,0)    (on,0)
            /  \        /  \
        (off,0)(on,0)(on,1)(off,0)
          ...    ...   ...   ...
```

- An **LTL** formula is read along **one path** (one root-to-leaf branch).
- A **CTL** formula is read at **nodes**, with `A` (all branches from here) / `E` (some branch from here).

<svg viewBox="0 0 620 248" style="display:block;margin:0.3em auto;max-width:74%;height:auto" font-family="Inter, system-ui, sans-serif">
  <line x1="296" y1="46" x2="196" y2="86" stroke="#9aa3ab" stroke-width="1.6"/>
  <text x="232" y="60" text-anchor="middle" font-size="11" fill="#5b6168">¬p</text>
  <line x1="326" y1="46" x2="424" y2="86" stroke="#B49248" stroke-width="2.8"/>
  <text x="392" y="60" text-anchor="middle" font-size="11" fill="#8a6d2f">p</text>
  <line x1="170" y1="114" x2="118" y2="156" stroke="#9aa3ab" stroke-width="1.6"/>
  <line x1="190" y1="116" x2="242" y2="156" stroke="#9aa3ab" stroke-width="1.6"/>
  <line x1="432" y1="116" x2="388" y2="156" stroke="#B49248" stroke-width="2.8"/>
  <line x1="450" y1="116" x2="512" y2="156" stroke="#9aa3ab" stroke-width="1.6"/>
  <line x1="380" y1="186" x2="380" y2="206" stroke="#B49248" stroke-width="2.8"/>
  <circle cx="310" cy="30" r="20" fill="#faf7f0" stroke="#B49248" stroke-width="2.6"/>
  <text x="310" y="35" text-anchor="middle" font-size="11.5" fill="#1c1c1c">off,0</text>
  <circle cx="180" cy="100" r="18" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="180" y="105" text-anchor="middle" font-size="11" fill="#1c1c1c">off,0</text>
  <circle cx="440" cy="100" r="18" fill="#faf7f0" stroke="#B49248" stroke-width="2.6"/>
  <text x="440" y="105" text-anchor="middle" font-size="11" fill="#1c1c1c">on,0</text>
  <circle cx="110" cy="170" r="15" fill="#f6eeda" stroke="#B49248" stroke-width="1.8"/>
  <circle cx="250" cy="170" r="15" fill="#f6eeda" stroke="#B49248" stroke-width="1.8"/>
  <circle cx="380" cy="170" r="16" fill="#faf7f0" stroke="#B49248" stroke-width="2.6"/>
  <text x="380" y="175" text-anchor="middle" font-size="10.5" fill="#1c1c1c">on,1</text>
  <circle cx="520" cy="170" r="15" fill="#f6eeda" stroke="#B49248" stroke-width="1.8"/>
  <text x="110" y="226" text-anchor="middle" font-size="15" fill="#9aa3ab">⋯</text>
  <text x="250" y="226" text-anchor="middle" font-size="15" fill="#9aa3ab">⋯</text>
  <text x="380" y="228" text-anchor="middle" font-size="15" fill="#8a6d2f">⋯</text>
  <text x="520" y="226" text-anchor="middle" font-size="15" fill="#9aa3ab">⋯</text>
  <text x="585" y="36" text-anchor="end" font-size="11" fill="#8a6d2f">gold = one path (LTL)</text>
  <text x="585" y="52" text-anchor="end" font-size="11" fill="#5b6168">whole tree = CTL</text>
</svg>

Caption: the counter's computation tree — LTL talks about one highlighted path; CTL quantifies over the branches with A/E.

::: notes
The computation tree is THE mental model for CTL (Week 9 builds it explicitly from the counter's nondeterministic `press`). The branching comes from the free input: at every (off,·) and (on,·) node press can be TRUE or FALSE, so each node has two children. The single most important contrast for the expressiveness slide: LTL is a property of a path (one branch), CTL is a property of a node in the tree (so it can say "from this node SOME branch does X" — the E quantifier LTL lacks). Draw it once; refer back when explaining AG EF.
:::

---

## CTL operators, one at a time

Each pairs a path quantifier (`A` all / `E` some) with a temporal operator, read at the **current node**:

| | `X` (next) | `F` (eventually) | `G` (always) |
|---|---|---|---|
| **`A`** (all paths) | `AX p`: `p` at *every* next state | `AF p`: *every* path hits `p` | `AG p`: `p` on *every* reachable state |
| **`E`** (some path) | `EX p`: `p` at *some* next state | `EF p`: *some* path reaches `p` | `EG p`: *some* path keeps `p` forever |

Plus `A[p U q]` / `E[p U q]`. Counter readings:

- `EF (x = 10)` — **true**: some path counts up to 10.
- `AF (x = 10)` — **false**: the path that keeps pressing never lets `x` climb.
- `EG (mode = on)` — **false**: every on-run is forced off at `x = 10`.

::: notes
The 2×3 table is the whole of CTL's core (plus until). Walk the A/E split with the counter: EF(x=10) true but AF(x=10) false is the cleanest demonstration that the quantifier matters — same temporal operator F, opposite verdicts, because of the toggling path. EX/AX need the tree (one step = children of the current node). This mirrors our CTL "semantics through examples" videos. Note CTL syntax REQUIRES the pairing — you cannot write bare `F p` in CTLSPEC, every temporal op needs an A or E.
:::

---

## `AG EF p` — recoverability

`AG EF p` nests two quantifiers: "**on every** reachable state (`AG`), **some** path gets back to `p` (`EF`)."

- "No matter where the system wanders, it can **always still return** to `p`."
- Counter: `AG EF (mode = off)` — **true**: from any reachable state, some run returns home. (The **reset** property.)
- Mutex: `AG EF (process1 = critical)` — "process 1 can always eventually get in (on *some* schedule)." Shipped, passes.

This is the canonical property **CTL can express and LTL cannot** — the next slide says why.

::: notes
AG EF is recoverability / the reset property — our headline example of "expressible in CTL, not LTL: from every state there is an execution back to the initial state." The nesting reads outside-in: AG = at all reachable states, EF = there exists a path reaching p. The "some path" is the crux — it is an existential over futures, which LTL (all-paths-only) structurally cannot state. Both shipped examples (counter return-home, mutex can-still-enter) pass, so they are runnable. Distinguish from AG AF p (every path returns — a much stronger, often-false claim).
:::

---

## LTL vs CTL — incomparable

Neither subsumes the other:

- **CTL-only**: `AG EF p` — "from every reachable state, `p` is still reachable." LTL cannot say this (no existential path quantifier).
- **LTL-only**: `F G p` — "eventually `p` holds forever." CTL's `AF AG p` is *not* equivalent.

Most tools (NuSMV/nuXmv included) support both. **CTL\*** is the larger logic that freely mixes path quantifiers (`A`/`E`) with temporal operators — it contains both LTL and CTL.

::: notes
This is the classic theorem (Week 10): LTL and CTL have incomparable expressive power. The two canonical witnesses: AG EF p (CTL, not LTL) and FG p (LTL, not CTL — AFAG p is strictly stronger). Don't belabor the proof; the practical point is "pick the logic that can express your property, and know that some tools/algorithms are faster for one than the other." CTL* unifies them but is rarely needed in practice.
:::

---

## *Why* the two are incomparable

The argument is about **paths vs. nodes**, not difficulty:

- **`AG EF p` is CTL-only.** `EF` says "*some* future path reaches `p`." LTL only ever quantifies over *all* paths of the system — it has **no existential path quantifier**, so it cannot say "from here, a path back to `p` exists." Branching is essential.
- **`F G p` is LTL-only.** It means "on this path, `p` eventually stays on." The natural CTL translation `AF AG p` is **strictly stronger**: `AF AG p` demands a *single* moment after which *all* branches keep `p`, but `F G p` only constrains each path on its own. Two trees can agree on every path's `F G p` yet differ on `AF AG p`.

**CTL\*** drops the "one quantifier per operator" rule (e.g. `A F G p`) and contains both.

::: notes
This is the deepening the task asks for — the branching ARGUMENT, not the bare assertion. Ground it in Week 10's slide 6: "EX(p) is CTL not in LTL — need to talk about all paths in LTL"; "AFG(p) is LTL not in CTL — CTL requires path quantifiers before temporal; closest is AFAG(p)." Key intuition for AG EF vs LTL: LTL's semantics is "true of the system iff true of every trace," and a single trace cannot mention OTHER branches, so EF is unreachable. For F G p vs AF AG p: AF AG p forces a common stabilization point across all paths; F G p lets each path stabilize at its own time — strictly weaker. The Emerson-Halpern / Vardi references in week10 are the formal source. Don't prove it; the path-vs-node picture (previous tree slide) is enough.
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

## Quick check: match the English to the formula

1. Every reachable state has `x ≤ 10`.
2. Every reachable state can return to `mode = off`.
3. The system eventually settles in `mode = on` forever.
4. From every state, some path reaches `x = 10`.

**Choices** (not in order):  A. `F G (mode = on)` · B. `AG EF (x = 10)` · C. `AG (x ≤ 10)` · D. `AG EF (mode = off)`

::: {.fragment}
**Answers:** 1 → C,  2 → D,  3 → A,  4 → B.
:::

::: notes
Ask the class first; reveal the answer fragment after discussion. Matching: 1→C, 2→D, 3→A, 4→B (the choices are deliberately shuffled, so the mapping isn't just "in order"). The discriminating skill is recognizing AG EF (recoverability, CTL) vs F G (stabilization, LTL). Then run each formula through nuXmv for its verdict: B, C, D are true; A (`F G (mode = on)`) is false — the counter always leaves the on mode.
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

## Worked safety counterexample (finite path)

Suppose we *broke* mutex so both processes could enter together and checked `INVARSPEC !(process1 = critical & process2 = critical)`. A safety violation is a **finite path** to the bad state:

```text
-- specification is false; as demonstrated by:
 -> State 1.1 <- process1=idle,    process2=idle,    flag1=F, flag2=F
 -> State 1.2 <- process1=waiting, process2=waiting, flag1=T, flag2=T
 -> State 1.3 <- process1=critical,process2=critical            <-- BOTH in critical
```

You can **point at** the bad state and replay the exact 3-step sequence that reached it. That is the whole counterexample — finite, concrete, replayable.

::: notes
Safety counterexample = finite path (Week 9 "violation of a safety property is demonstrated by a finite execution"). Use the shipped mutex's mutual-exclusion spec as the running example, hypothetically broken so it actually fails (the real file passes it). Three states is enough to show the shape: init → both waiting → both critical. The teaching point repeated from L3 but pitched at the property level: safety = reachable bad state = finite witness. Contrast immediately with the next slide's lasso.
:::

---

## Worked liveness counterexample (a lasso)

Real `counter.smv` spec `G F (mode = on & x = count_max)` ("infinitely often we're on with x=10") is **false**. A liveness violation is a **lasso** — a stem into a repeating cycle where the good event never recurs:

```text
-- specification G F (mode = on & x = count_max) is false
 -> State 1.1 <- mode=off, press=FALSE, x=0     <-- stem
 -- Loop starts here
 -> State 1.2 <- mode=off, press=FALSE, x=0
 -> State 1.2 <- mode=off, press=FALSE, x=0     <-- cycle: repeat forever
```

The cycle stays `off` forever (the environment simply never presses), so `(mode = on & x = 10)` *never* happens — the promised event is absent on an infinite run.

::: notes
This is our ACTUAL nuXmv demo counterexample (Week 9 temporal-specs screencast), verbatim in shape: the lasso is "mode off, press false, x=0, then repeat." The point we make: press is a free input, so a perfectly legal run never presses, the counter sits in off forever, and "infinitely often on&x=10" is falsified. The "Loop starts here" / repeated-state notation is exactly nuXmv's. This is the canonical liveness counterexample: not a finite path but an infinite run shown as stem+cycle. Connect to the lasso slide from earlier and to fairness (FAIRNESS mode != off rules out exactly this degenerate run — which is why the home-recurrence spec passes but this one fails).
:::

---

## L2 recap

- **Temporal logic** expresses claims about executions, not single states.
- **LTL** (linear, one path) — `X`, `F`, `G`, `U`, `R`; patterns `G F` (∞-often), `F G` (stabilize), `G(p→F q)` (response).
- **CTL** (branching, `A`/`E` on the computation tree) — `AG`, `EF`, `AF`, `EG`, `AG EF` (recoverable).
- They are **incomparable** *because* LTL reads paths and CTL reads tree nodes: `AG EF p` needs `E` (CTL-only); `F G p` ≠ `AF AG p` (LTL-only).
- A **safety** violation is a finite path; a **liveness** violation is a **lasso** (stem + cycle).
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

NuSMV/nuXmv run the **symbolic** and **bounded** engines; explicit-state enumeration is the SPIN family (a different tool).

::: notes
The three families, the same ones Week 6/7 cover. Explicit-state (SPIN-style) enumerates states one at a time — simplest, but dies on big state spaces. Symbolic (the classic SMV/NuSMV/nuXmv approach) represents whole *sets* of states as boolean functions via BDDs, so it can handle astronomically many states if they compress well. Bounded (Day 1's approach) skips the state space entirely and unrolls — great for finding bugs, but only complete with extra work (k-induction, interpolation). NuSMV and nuXmv implement the symbolic (BDD) and bounded (SAT) engines and let you pick per problem; explicit-state enumeration is SPIN's domain, not these tools'.
:::

---

## How hard is model checking? (1) the infinite-state wall

Ask: "is `p` an invariant of transition system `T`?" The answer depends entirely on whether `T` is finite-state.

- **Infinite state (e.g. unbounded `int` variables): UNDECIDABLE.** With mathematical integers, `T` can encode an arbitrary program / Turing machine — so invariant verification is as hard as the halting problem. The standard proof reduces from **Minsky two-counter machines**.
- Intuition: there is **no a-priori bound** on the reachable states, so "examine them all" never terminates.

This is why our SMV models bound every variable (`x : 0..25`) — and why **Day 3 (Lean)** needs *induction*, not enumeration, for unbounded systems.

::: notes
Straight from Week 7's "complexity of model checking" video. The headline beginners must take away: model checking is not magic — for genuinely infinite-state systems (real integers/reals) invariant verification is undecidable, by reduction from Minsky 2-counter machines (a Turing-complete model). The reason finite ranges appear everywhere in our .smv files is precisely to stay decidable. This also motivates Day 3: theorem proving handles the infinite/parametric case by induction on the transition relation, sidestepping undecidability of the exact reachable set. Connect to the student question in week10 (halting problem vs eventual truth).
:::

---

## How hard is model checking? (2) finite-state = PSPACE

Make every variable finite and the problem becomes **decidable** — but not cheap:

- `k` boolean variables ⇒ up to $2^k$ states. A verifier *can* search them all, so it terminates.
- Invariant / reachability checking for finite-state systems is **PSPACE-complete**. Since PSPACE ⊇ NP, it is at least as hard as NP-complete SAT; whether that containment is *strict* (PSPACE ≠ NP) is a famous open question.
- The practical face of that exponent is the **state-explosion problem**: state count blows up with variables, components, and interleavings.

| Property logic | Model-checking complexity |
|---|---|
| **CTL** | $O(|S| \cdot |\varphi|)$ — linear in states × formula |
| **LTL** | $O(|S| \cdot 2^{|\varphi|})$ — linear in states, exponential in *formula* size |

*(As a decision problem, LTL model checking is PSPACE-complete in the formula; the bound shown is for the standard Büchi-automaton construction.)*

::: notes
Week 7 again: finite-state invariant verification is in PSPACE (the video says "a bit harder than NP-complete problems such as SAT"), and the exponential blow-up in the state space IS state explosion — the central engineering challenge the whole symbolic/BDD machinery exists to fight. The CTL-vs-LTL table is the standard textbook result (Clarke/Baier-Katoen): CTL model checking is linear in both the model and the formula; LTL is linear in the model but exponential in the FORMULA length (because you build the Büchi automaton from the earlier LTL→Büchi slide, which can be of size 2^|φ|). Caveat worth stating: formulas are usually tiny, so LTL's formula-exponential is rarely the bottleneck — the STATE space is. This is also a reason tools historically favored CTL for raw speed, even though LTL is more used in practice.
:::

---

## Symbolic model checking: sets as formulas

Represent a **set of states** by a boolean formula true exactly on that set.

- Reachable set $R_0 = \text{init}$ (the initial states).
- $R_{k+1} = R_k \cup \text{Image}(R_k)$ — add the one-step successors ($\text{Image}(R)$ = all states reachable in one step from $R$; $\cup$ = set union).
- Stop when $R_{k+1} = R_k$ (a **fixpoint** — nothing new appears): that's all reachable states.
- Safety check: is $R_\infty \cap \text{Bad} = \varnothing$? ($\cap$ = states in both sets; $\varnothing$ = empty set — so no bad state is reachable.)

The whole computation is boolean-formula manipulation — no state is ever enumerated individually.

::: notes
This is the heart of symbolic model checking (Week 6/7). Instead of visiting states, you compute with their *characteristic functions*. Image computation (the set of one-step successors of a set) and union are operations on formulas. Iterating to a fixpoint gives the entire reachable set as one formula. Then safety is an emptiness check. The reason this scales: a formula over n boolean variables can describe up to 2^n states compactly — if it compresses. The data structure that makes the compression and the operations efficient is the BDD.
:::

---

## The symbolic transition relation

A model checker never lists states — it computes with **formulas over the variables**.

- **Initial states** → a formula $\varphi_I$. For the counter: $\varphi_I \equiv (\text{mode} = \text{off}) \wedge (x = 0)$.
- **Transitions** → a formula $\varphi_T$ over the variables **and their primed (next-state) copies** ($x'$ = value of $x$ *after* the step).

The counter's increment edge is one disjunct of $\varphi_T$:
$$(\text{mode}=\text{on}) \wedge \neg p \wedge (x < 10)\ \wedge\ (\text{mode}'=\text{on}) \wedge (x' = x + 1)$$

If $T$ has $k$ variables, a *set of states* is a formula over $k$ variables and the *transition relation* is a formula over $2k$ variables. Variables a step doesn't touch need an explicit $y' = y$ (a **frame condition**).

::: notes
The symbolic representation from Week 6 — the spine of symbolic model checking: represent both state sets and the transition relation as logical formulas, then do reachability by manipulating formulas. Primed variables are the standard "next state" convention (nuXmv's `next(x)`, TLA+'s `x'`, Lean's two-state relation). The frame condition (`y' = y` for untouched variables) is the classic gotcha: in code an untouched variable just stays; in a relation you must *say so*, or the solver may change it. This `φ_T` is exactly the symbolic state machine from Day 1, written as one big formula over (s, s').
:::

---

## Computing successors: the image Post(A)

Given a region $A$ (a set of states), its **image** is the set of one-step successors:
$$\text{Post}(A) = \{\, t \mid \exists s \in A,\ (s, t) \in \varphi_T \,\}$$

Three mechanical steps — the heart of symbolic search:

1. **Conjoin**: $A(\mathbf{s}) \wedge \varphi_T(\mathbf{s}, \mathbf{s}')$ — all transitions starting in $A$.
2. **Project**: $\exists \mathbf{s}.\ (A \wedge \varphi_T)$ — quantify away the *current*-state variables, keeping only reachable next-states $\mathbf{s}'$.
3. **Rename** $\mathbf{s}' \to \mathbf{s}$ — so the result is again a region over the ordinary variables.

$$\text{Post}(A) = \text{Rename}\big(\,\exists \mathbf{s}.\ (A \wedge \varphi_T),\ \ \mathbf{s}' \to \mathbf{s}\,\big)$$

::: notes
This is THE core operation of symbolic model checking, straight from Week 6. The reachable-set fixpoint and invariant checking are all built on Post. Intuition for the three steps: intersect the start region with the transition relation (all (s,s') transitions leaving A), existentially project away the old state (leaving a predicate on s' meaning "some predecessor in A reaches me"), then rename primes off so you can iterate. Step 2 — existential quantifier elimination — is the computational workhorse; the next two slides drill into it.
:::

---

## Worked image computation (with Z3)

One real variable; transition $\varphi_T : x' = 2x + 1$; region $A : 0 \le x \le 10$. Compute $\text{Post}(A)$:

1. **Conjoin**: $(0 \le x \le 10) \wedge (x' = 2x + 1)$
2. **Project out $x$**: $\exists x.\ (0 \le x \le 10) \wedge (x' = 2x + 1)$ — simplifies to $1 \le x' \le 21$
3. **Rename** $x' \to x$: $\;1 \le x \le 21$ — exactly the image of $[0,10]$ under $x \mapsto 2x+1$. ✓

```smt2
(declare-fun xP () Real)
(assert (exists ((x Real)) (and (<= 0 x) (<= x 10) (= xP (+ (* 2 x) 1)))))
(apply qe)          ; quantifier elimination  →  (and (>= xP 1) (<= xP 21))
```

::: notes
Image computation made concrete, with Z3 doing the quantifier elimination (Week 6). `(apply qe)` is Z3's QE tactic: it turns the existentially-quantified formula into an equivalent quantifier-free one over x' alone. Linear real/integer arithmetic admits quantifier elimination, which is *why* symbolic reachability over LRA/LIA is mechanizable. Check by hand: x ∈ [0,10] ⇒ 2x+1 ∈ [1,21]; the solver did the same reasoning symbolically, for the whole interval at once instead of point by point.
:::

---

## Projection is existential quantifier elimination

"Project out $x$" = "$\exists x$" = drop $x$ but keep what it still forces on the rest.

- **Booleans** (BDD-friendly): $\exists x.\ \varphi \;=\; \varphi[x \mapsto 0]\ \vee\ \varphi[x \mapsto 1]$ — substitute both values, OR the results.
- **Linear arithmetic**: Fourier–Motzkin elimination, or Z3's `qe` (as above).

A symbolic model checker needs just **six region operations**:

| Op | Set meaning | On formulas |
|---|---|---|
| `Conj(A,B)` | $A \cap B$ | $A \wedge B$ |
| `Disj(A,B)` | $A \cup B$ | $A \vee B$ |
| `Diff(A,B)` | $A \setminus B$ | $A \wedge \neg B$ |
| `IsEmpty(A)` | $A = \varnothing$? | a **SAT** test (unsat = empty) |
| `Exists(A,X)` | project out $X$ | quantifier elimination |
| `Rename(A,X,Y)` | rename vars | substitution |

::: notes
The Boolean cofactor identity ∃x.φ = φ[x→0] ∨ φ[x→1] is exactly how BDDs do existential projection — cheap, because substituting a constant and OR-ing are linear-time BDD operations. For arithmetic you need real QE (Fourier–Motzkin for linear; CAD for nonlinear reals). These six operations are the *entire* interface a symbolic model checker needs: implement them on ROBDDs (Booleans) or polyhedra (reals) and the reachability algorithm is unchanged. `IsEmpty` being a SAT test is why "is the bad set reachable?" reduces to satisfiability — the direct line back to Day 1.
:::

---

## The fixpoint, on the counter

Run the reachable-set iteration by hand — it lands on the **same 12 states** as Day 1's BFS:

$$R_0 = \{(\text{off},0)\}$$
$$R_1 = R_0 \cup \{(\text{on},0)\}, \quad R_2 = R_1 \cup \{(\text{on},1)\}, \quad \dots$$
$$R_{11} = R_{10} \cup \{(\text{on},10)\}, \qquad R_{12} = R_{11}\ \text{(fixpoint)}$$

Now $R_{12} \cap \{x > 10\} = \varnothing$ — the safety invariant holds, and **no individual state was ever enumerated**: each $R_k$ is one boolean formula (one BDD).

::: notes
This makes "sets as formulas" concrete and ties straight back to Day 1's hand-BFS. Each $R_k$ is the characteristic function of a set of states, stored as a BDD; `Image` and `∪` are BDD operations; the fixpoint test $R_{12} = R_{11}$ is a constant-time BDD pointer comparison thanks to canonicity. The counter is tiny so the sets are small, but the same loop runs on systems with $10^{100}$ states — as long as the BDDs compress.
:::

---

## The frontier: symbolic BFS

Don't re-expand the whole set each step — push only the **frontier** (the newly-found states):

```text
Reach := Init;   New := Init               # New = the frontier
while New ≠ ∅:
    if New ∩ Bad ≠ ∅:  return REACHABLE     # property violated → counterexample
    New   := Post(New) \ Reach              # successors not seen before
    Reach := Reach ∪ New
return UNREACHABLE                          # fixpoint: nothing new ⇒ invariant holds
```

<svg viewBox="0 0 600 330" style="display:block;margin:0.2em auto;max-width:52%;height:auto" font-family="Inter, system-ui, sans-serif">
  <rect x="30" y="46" width="540" height="250" rx="18" fill="#fcf5e6" stroke="#B49248" stroke-width="2.5" stroke-dasharray="7 4"/>
  <rect x="98" y="86" width="404" height="170" rx="14" fill="#efe1c0" stroke="#B49248" stroke-width="2"/>
  <rect x="170" y="120" width="260" height="102" rx="12" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <rect x="242" y="150" width="116" height="42" rx="10" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="300" y="68" text-anchor="middle" font-size="13.5" fill="#8a6d2f">reach₃ = frontier (New)</text>
  <text x="300" y="106" text-anchor="middle" font-size="13.5" fill="#946E24">reach₂</text>
  <text x="300" y="139" text-anchor="middle" font-size="13" fill="#946E24">reach₁</text>
  <text x="300" y="176" text-anchor="middle" font-size="12.5" fill="#1c1c1c">reach₀ = Init</text>
</svg>

Each ring is one BFS layer `reachᵢ`; the dashed gold band is the frontier `New` that `Post` pushes outward. It stops after the reachable graph's **diameter** (for the counter, 11 steps — then `New = ∅`).

::: notes
This is the symbolic BFS from Week 6 — what nuXmv actually runs. The efficiency: only the *frontier* (New) is expanded each iteration, via Diff(Post(New), Reach), not the whole Reach set. Two ways it stops: (1) the frontier meets Bad → the property is violated and the path through the layers is your counterexample; (2) the frontier goes empty → fixpoint reached, invariant holds. Termination is governed by the diameter (longest shortest-path); for the counter that's 11. Each region (Reach, New, Bad, Post output) is a formula/BDD, so the whole loop is formula manipulation — no state ever enumerated.
:::

---

## BDDs — binary decision diagrams

A **BDD** is a canonical, compressed decision tree for a boolean function.

- **Shannon expansion**: $f = (x \wedge f|_{x=1}) \vee (\neg x \wedge f|_{x=0})$ — split on one variable ($\wedge$ and, $\vee$ or, $\neg$ not; $f|_{x=1}$ is $f$ with $x$ fixed true).
- Apply recursively over a **fixed variable order** → a **DAG** (directed acyclic graph — a decision tree with identical subgraphs shared).
- Reduce: merge identical subgraphs, drop redundant nodes.
- Result is **canonical**: two functions are equal iff their BDDs are identical.

::: notes
BDDs (Bryant 1986) are why symbolic model checking works. Shannon expansion splits a function on one variable; doing it over a fixed order and sharing common substructure yields a compact DAG. Canonicity is the magic property: equality of boolean functions becomes pointer equality of BDDs, so the fixpoint test (R_{k+1} = R_k) is cheap. The catch is on the next slide.
:::

---

## A BDD, drawn

The function $f = \text{ite}(a,b,c) = (a \wedge b) \vee (\neg a \wedge c)$ — "if `a` then `b` else `c`" — as a BDD:

<svg viewBox="0 0 460 330" style="display:block;margin:0.3em auto;max-width:42%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs>
    <marker id="bdd-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/>
    </marker>
  </defs>
  <line x1="248" y1="62" x2="318" y2="132" stroke="#5b6168" stroke-width="1.6" marker-end="url(#bdd-ah)"/>
  <line x1="212" y1="62" x2="142" y2="132" stroke="#5b6168" stroke-width="1.6" stroke-dasharray="5 4" marker-end="url(#bdd-ah)"/>
  <line x1="340" y1="172" x2="352" y2="262" stroke="#5b6168" stroke-width="1.6" marker-end="url(#bdd-ah)"/>
  <line x1="318" y1="168" x2="124" y2="266" stroke="#5b6168" stroke-width="1.6" stroke-dasharray="5 4" marker-end="url(#bdd-ah)"/>
  <line x1="142" y1="168" x2="336" y2="266" stroke="#5b6168" stroke-width="1.6" marker-end="url(#bdd-ah)"/>
  <line x1="120" y1="172" x2="108" y2="262" stroke="#5b6168" stroke-width="1.6" stroke-dasharray="5 4" marker-end="url(#bdd-ah)"/>
  <circle cx="230" cy="46" r="24" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="230" y="52" text-anchor="middle" font-size="18" fill="#1c1c1c">a</text>
  <circle cx="330" cy="152" r="24" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="330" y="158" text-anchor="middle" font-size="18" fill="#1c1c1c">b</text>
  <circle cx="130" cy="152" r="24" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="130" y="158" text-anchor="middle" font-size="18" fill="#1c1c1c">c</text>
  <rect x="330" y="262" width="42" height="38" rx="5" fill="#eef7ee" stroke="#27843f" stroke-width="2"/>
  <text x="351" y="287" text-anchor="middle" font-size="17" fill="#1e6b32">1</text>
  <rect x="88" y="262" width="42" height="38" rx="5" fill="#f4f4f4" stroke="#9aa3ab" stroke-width="2"/>
  <text x="109" y="287" text-anchor="middle" font-size="17" fill="#5b6168">0</text>
</svg>

Solid edge = that variable is **1**; dashed = **0**. Follow your path of choices down to a terminal box (the output). The single shared `0` and `1` are what make it a **DAG**, not a tree — and why function equality becomes pointer-equality of BDDs.

Build and reduce BDDs yourself in the browser: [bit.ly/fmaiv_smvis](https://bit.ly/fmaiv_smvis).

::: notes
This is the picture behind the previous slide's Shannon expansion: the root splits on `a`, the solid (a=1) branch is `f|a=1 = b`, the dashed (a=0) branch is `f|a=0 = c`. Trace an input: a=0, c=1 → follow dashed from a to c, solid from c to 1 → output 1. The two crossing edges in the middle are the two ways to reach the shared terminals — that sharing is the whole point of "reduced" BDDs and is why canonicity holds. Variable order here is a, then b/c; the next slide shows why that choice can make or break the size.
:::

---

## Building and reducing a BDD

Start from the Shannon-expansion **decision tree** for $f = x \vee y$, then apply two rules until none apply:

<svg viewBox="0 0 820 285" style="display:block;margin:0.2em auto;max-width:80%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs>
    <marker id="bddr-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/>
    </marker>
  </defs>
  <!-- panel A: decision tree -->
  <line x1="196" y1="60" x2="158" y2="113" stroke="#5b6168" stroke-width="1.5" stroke-dasharray="5 4" marker-end="url(#bddr-ah)"/>
  <line x1="224" y1="60" x2="267" y2="113" stroke="#5b6168" stroke-width="1.5" marker-end="url(#bddr-ah)"/>
  <line x1="140" y1="148" x2="119" y2="206" stroke="#5b6168" stroke-width="1.5" stroke-dasharray="5 4" marker-end="url(#bddr-ah)"/>
  <line x1="160" y1="148" x2="172" y2="206" stroke="#5b6168" stroke-width="1.5" marker-end="url(#bddr-ah)"/>
  <line x1="266" y1="148" x2="256" y2="206" stroke="#5b6168" stroke-width="1.5" stroke-dasharray="5 4" marker-end="url(#bddr-ah)"/>
  <line x1="284" y1="148" x2="315" y2="206" stroke="#5b6168" stroke-width="1.5" marker-end="url(#bddr-ah)"/>
  <ellipse cx="210" cy="44" rx="22" ry="20" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="210" y="50" text-anchor="middle" font-size="16" fill="#1c1c1c">x</text>
  <ellipse cx="150" cy="130" rx="20" ry="18" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="150" y="135" text-anchor="middle" font-size="15" fill="#1c1c1c">y</text>
  <ellipse cx="275" cy="130" rx="20" ry="18" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="275" y="135" text-anchor="middle" font-size="15" fill="#1c1c1c">y</text>
  <rect x="98" y="208" width="26" height="30" rx="4" fill="#f4f4f4" stroke="#9aa3ab" stroke-width="1.6"/>
  <text x="111" y="229" text-anchor="middle" font-size="14" fill="#5b6168">0</text>
  <rect x="163" y="208" width="26" height="30" rx="4" fill="#eef7ee" stroke="#27843f" stroke-width="1.6"/>
  <text x="176" y="229" text-anchor="middle" font-size="14" fill="#1e6b32">1</text>
  <rect x="242" y="208" width="26" height="30" rx="4" fill="#eef7ee" stroke="#27843f" stroke-width="1.6"/>
  <text x="255" y="229" text-anchor="middle" font-size="14" fill="#1e6b32">1</text>
  <rect x="307" y="208" width="26" height="30" rx="4" fill="#eef7ee" stroke="#27843f" stroke-width="1.6"/>
  <text x="320" y="229" text-anchor="middle" font-size="14" fill="#1e6b32">1</text>
  <text x="210" y="266" text-anchor="middle" font-size="13" fill="#5b6168">decision tree</text>
  <!-- reduce arrow -->
  <line x1="392" y1="130" x2="498" y2="130" stroke="#5b6168" stroke-width="2" marker-end="url(#bddr-ah)"/>
  <text x="445" y="118" text-anchor="middle" font-size="13" fill="#946E24">reduce</text>
  <text x="445" y="150" text-anchor="middle" font-size="11" fill="#5b6168">Rules 1 &amp; 2</text>
  <!-- panel B: ROBDD -->
  <line x1="666" y1="60" x2="650" y2="116" stroke="#5b6168" stroke-width="1.5" stroke-dasharray="5 4" marker-end="url(#bddr-ah)"/>
  <line x1="697" y1="58" x2="745" y2="202" stroke="#5b6168" stroke-width="1.5" marker-end="url(#bddr-ah)"/>
  <line x1="633" y1="151" x2="617" y2="204" stroke="#5b6168" stroke-width="1.5" stroke-dasharray="5 4" marker-end="url(#bddr-ah)"/>
  <line x1="660" y1="149" x2="742" y2="204" stroke="#5b6168" stroke-width="1.5" marker-end="url(#bddr-ah)"/>
  <ellipse cx="680" cy="44" rx="22" ry="20" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="680" y="50" text-anchor="middle" font-size="16" fill="#1c1c1c">x</text>
  <ellipse cx="645" cy="133" rx="20" ry="18" fill="#f6eeda" stroke="#B49248" stroke-width="2"/>
  <text x="645" y="138" text-anchor="middle" font-size="15" fill="#1c1c1c">y</text>
  <rect x="599" y="206" width="26" height="30" rx="4" fill="#f4f4f4" stroke="#9aa3ab" stroke-width="1.6"/>
  <text x="612" y="227" text-anchor="middle" font-size="14" fill="#5b6168">0</text>
  <rect x="739" y="206" width="26" height="30" rx="4" fill="#eef7ee" stroke="#27843f" stroke-width="1.6"/>
  <text x="752" y="227" text-anchor="middle" font-size="14" fill="#1e6b32">1</text>
  <text x="680" y="266" text-anchor="middle" font-size="13" fill="#5b6168">ROBDD (canonical)</text>
</svg>

- **Rule 1 — merge** isomorphic subgraphs (identical nodes/leaves become one): the three `1`-leaves collapse to one.
- **Rule 2 — eliminate** any node whose two children are identical (a redundant test): the `y` on the `x = 1` branch disappears — `x = 1` already forces `1`.

The result is **canonical** for a fixed order, so equality is pointer-equality and `IsEmpty`/validity are just "is it the `0` / `1` terminal?" Build them yourself: [bit.ly/fmaiv_smvis](https://bit.ly/fmaiv_smvis).

::: notes
The construction/reduction process from Week 7, on f = x ∨ y. Build the binary decision tree by Shannon-expanding on x then y. Then Rule 2 removes the y-test on the x=1 branch (x=1 forces 1 regardless of y, so both children are equal); Rule 1 merges the now-duplicate 1-leaves (and any isomorphic subgraphs). What remains is the reduced, ordered BDD. The order in which the reductions are applied doesn't matter — the ROBDD is unique for a given function and variable ordering (canonicity), the property that makes the fixpoint test R_{k+1} = R_k a cheap pointer comparison. Solid edge = variable is 1, dashed = 0.
:::

---

## BDDs: variable ordering is everything

The same function can be **tiny or exponential** depending on variable order.

- Good order → linear-size BDD.
- Bad order → exponential blow-up.
- Finding the optimal order is itself **NP-complete** (Bollig & Wegener, 1996); tools use heuristics + dynamic reordering.

Arithmetic (multipliers) has **no** good order — BDDs are bad at it. That's where SAT/SMT (Day 1, Day 4) wins.

::: notes
The Achilles' heel of BDDs: variable ordering. A classic example is the middle output bit of a multiplier circuit, whose BDD is exponential under every variable order (Bryant 1991) — which is exactly why hardware multipliers are verified with SAT-based methods, not BDDs. NuSMV and nuXmv both support dynamic reordering (the `-dynamic` flag). The practical lesson: BDDs are spectacular for control-dominated logic and poor for data-path arithmetic; know which tool to reach for.
:::

---

## Bounded model checking, revisited

Day 1's idea, now in context:

- Unroll the transition relation `k` times into one big SAT/SMT formula.
- Ask: is there a length-`k` path to a bad state?
- **SAT** → bug found (a real counterexample). **UNSAT** → no bug *of length ≤ k*.

To make BMC **complete**, add *k-induction* or compute a *completeness threshold* (the state graph's diameter) — both unpacked in the next two slides.

::: notes
Tie back to Day 1. BMC is unbeatable at finding shallow bugs fast and gives a concrete counterexample. Its weakness is completeness — UNSAT at depth k says nothing about depth k+1. The fixes (k-induction, interpolation, IC3/PDR) turn BMC into a complete method; nuXmv implements several. For this course the message is: BMC refutes cheaply, symbolic/BDD proves exhaustively, and modern tools blend them.
:::

---

## Inductive invariants: a safety proof in two checks

To prove a safety property `P` ("nothing bad ever happens") you rarely compute the exact reachable set. Instead find an **inductive invariant** `J`:

- **Initiation:** every initial state satisfies it — `Init ⇒ J`.
- **Consecution:** every step from a `J`-state stays in `J` — `J ∧ R ⇒ J′`.
- **Strength:** it implies what you wanted — `J ⇒ P`.

All three ⇒ `P` holds for **every** reachable state — no unrolling, no bound.

- **Checking** a candidate is two SMT queries: consecution fails *iff* `J ∧ R ∧ ¬J′` is **SAT** — the solver hands back the offending step.
- **The catch:** `P` itself is usually *not* inductive (e.g. `y ≥ 1` under `y′ = y + x` needs the helper `x ≥ 1`). Model checking's job is to **find** an inductive `J`; on **Day 3** you'll **supply** one by hand and prove it in Lean.

::: notes
The single most unifying concept in the field, and a deliberate Day-2→Day-3 bridge (grounded in Berkeley EECS 219C's scribed notes). Safety = the reachable states never leave the "good" set P. You almost never compute the reachable set exactly; instead you exhibit *any* set J that (i) contains the initial states, (ii) is closed under the transition relation, and (iii) sits inside P. That J certifies safety — "a safety proof = find an inductive invariant." Stress the asymmetry that trips everyone up: a property P you care about is frequently NOT inductive on its own — the classic example is y ≥ 1 under y′ = y + x, where the step breaks unless you also know x ≥ 1, so you *strengthen* P to P ∧ (x ≥ 1). Checking a candidate is mechanical (two SMT queries; consecution is exactly J ∧ R ∧ ¬J′ unsat — the entailment-by-negation move again). The hard, creative part is *finding* J: that's what k-induction and IC3 automate (next), and what you'll do by hand in Lean on Day 3 (the inductive-invariant method). Same idea, three vantage points: SMT checks it, model checking finds it, Lean lets you supply and prove it.
:::

---

## From bounded to complete: k-induction and IC3

Two ways to turn BMC's *bug-finding* into an unbounded *proof*:

- **k-induction = BMC made complete.** *Base:* no counterexample in the first `k` steps (a BMC query). *Step:* whenever `P` holds along `k` consecutive states, it holds at the next — with a "no repeated state" (simple-path) constraint so it terminates. Pass both ⇒ `P` holds forever. Looking back `k` steps succeeds where 1-step induction fails.
- **IC3 / PDR** (Property-Directed Reachability). Builds an inductive invariant *incrementally* as a chain of **frames** (over-approximations of "reachable in ≤ i steps"), learning a small clause from each *counterexample-to-induction* — **without ever unrolling** the transition relation. Often the fastest engine.

**nuXmv runs both** (its `check_invar_ic3` uses IC3) — so when nuXmv proves your `G`-property, this is what's happening under the hood.

::: notes
The "BMC is not the end of the line" slide — the gap a comparison against Berkeley 219C and the modern symbolic-MC literature flagged. Plain BMC only refutes up to depth k ("some early on called it just a good testing strategy, not verification"). k-induction reuses the *same* unrolled SAT/SMT encoding but adds an inductive step: if any k consecutive good states force the (k+1)-th to be good, and there's no short counterexample, the property holds at every depth; the simple-path constraint (the k states are distinct) guarantees a large-enough k terminates. IC3/PDR is the other workhorse and the conceptual payoff of the previous slide: it constructs an inductive invariant frame by frame, generalizing each counterexample-to-induction into a clause, never unrolling — Bradley's 2011 method, "one of the fastest SAT-based model-checking algorithms." The takeaway for this audience is not the internals but the landscape: nuXmv's invariant checking is k-induction + IC3 (per its CAV 2014 tool paper), so the "proof" half of model checking — not just the BMC "bug-finding" half — is exactly these algorithms searching for the inductive invariant from the previous slide.
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

**No install? Run it in your browser:** [bit.ly/fmaiv_smvis](https://bit.ly/fmaiv_smvis) — the **smvis** tool runs NuSMV and visualizes state graphs and BDDs interactively.

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
  -> State: 1.1  <- mode = off, x = 0,  press = TRUE    (off → on)
  -> State: 1.2  <- mode = on,  x = 0,  press = FALSE
  -> State: 1.3  <- mode = on,  x = 1,  press = FALSE
  ...
  -> State: 1.12 <- mode = on,  x = 10, press = FALSE
  -> State: 1.13 <- mode = on,  x = 11, press = FALSE   <-- x > count_max
```

The trace is a **witness** — the exact input sequence that breaks the property. (13 states: one press to flip on, then 11 increments; the violation shows at `1.13`.)

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
- **Intel** post-FDIV — formal datapath verification (via Symbolic Trajectory Evaluation, a cousin of these methods) as a release gate.

The counter is a toy; the engine is production-grade.

::: notes
Close the loop to Day 1's industrial framing. The student should leave knowing that "model checking" is not academic — it is the verification backbone of the semiconductor industry. Tools like JasperGold are used across the largest SoCs; the FDIV bug (Day 1) is precisely what motivated formal datapath verification (Intel built that around Symbolic Trajectory Evaluation, consistent with the Day 1 slide). Same family of BDD/SAT/STE engines and temporal specs, just at billions-of-states scale with heavy engineering.
:::

---

## L3 recap

- **Complexity**: invariant checking is **undecidable** for infinite-state (int vars ⇒ Turing-complete), **PSPACE** for finite-state — i.e. state explosion. CTL MC is linear; LTL is exponential in formula size.
- **Symbolic / bounded** — the two engines NuSMV/nuXmv run (explicit-state is SPIN's domain).
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

With `nuXmv` (or **smvis** in your browser — [bit.ly/fmaiv_smvis](https://bit.ly/fmaiv_smvis)) on [`counter.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/counter.smv):

1. Confirm the passing `INVARSPEC`s are `true` and the deliberately-false ones are `false`.
2. Introduce the off-by-one bug in `next(x)`; read the counterexample; identify the exact press sequence.
3. Revert. Write **one new** CTL or LTL property of your own and check it.

::: notes
Self-contained, runs in the room. The deliverable is a counterexample you can read plus one original property. The third part forces translating an English idea into temporal logic and getting a verdict — the core Day 2 skill.
:::

---

## Homework (ungraded, for depth)

Pick **one** of [`traffic_light.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/traffic_light.smv), [`mutex.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/mutex.smv), [`gcd_01.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/gcd_01.smv):

- Verify the two given properties; explain each verdict.
- Add and verify **one safety** and **one liveness** property of your own.
- For `mutex`: state mutual exclusion (`AG !(process1 = critical & process2 = critical)`) and no-starvation (`AG(process1 = waiting -> AF process1 = critical)`).

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
- **smvis** (browser NuSMV + BDD/state-graph visualizer) — **run it:** <https://bit.ly/fmaiv_smvis> · source: <https://github.com/verivital/smvis>

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
