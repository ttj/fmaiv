---
title: "Day 4 — Program & High-Assurance Verification"
subtitle: "FMAIV: Formal Methods & AI-Assisted Verification"
author: "Taylor T. Johnson"
institute: "Vanderbilt University"
date: "Day 4 of 4"
---

# Day 4 — Programs & the Frontier {.title}

## CBMC, Cryptol, SAW, and where the field is going {.section}

::: notes
Days 1-3 verified models of the counter — an SMT formula, an SMV transition system, a Lean proof. Today we connect verification to *actual source code* (CBMC on C, Cryptol/SAW on C-vs-spec), and close with the research frontier: neural-network verification and how industry runs all of this at production scale. The counter appears one last time, in C and in Cryptol — its fourth and fifth encodings.
:::

---

## Where we are

Three views of the same counter so far:

| Day | Model | Guarantee |
|---|---|---|
| 1 | Z3 / SMT formula | no counterexample of length ≤ N |
| 2 | nuXmv / SMV | no counterexample, ever (finite state) |
| 3 | Lean / induction | machine-checked proof, any bound |

Today: the same ideas, applied to **real code**.

::: notes
Recap the arc as a table. Each row is a stronger or different guarantee on the *same system*. The gap we close today: all three operated on a *model* of the counter. Real engineering needs verification of the actual artifact — the C source, the deployed crypto routine. That is what CBMC and SAW do.
:::

---

## Today's roadmap

| Block | Topic |
|---|---|
| L1 | Bounded model checking of C with **CBMC** |
| L2 | Bit-precise specs with **Cryptol**; C↔spec equivalence with **SAW** |
| L3 | The frontier: neural-network verification + industrial deployments |

::: notes
L1: programs as transition systems, CBMC on the counter in C. L2: Cryptol as a spec language and SAW proving a C implementation matches it. L3: where formal methods meets AI (neural-net verification) and how AWS/Intel/etc. run this for real. The first two are hands-on; the third is a survey.
:::

---

## Learning objectives for Day 4

By the end of today you will be able to:

- Frame a C program as a transition system on memory states.
- Write a **CBMC** harness with nondeterministic inputs and read its counterexample.
- Write a small **Cryptol** spec and discharge a property with `:prove`.
- Explain how **SAW** proves a C implementation equivalent to a Cryptol spec.
- Locate the field's frontier: NN verification, and where FM is deployed in industry.

::: notes
Five objectives across the three blocks. The first four are concrete skills; the fifth is situational awareness — knowing what's at the edge and what's in production.
:::

---

# L1 — Bounded model checking of C with CBMC {.section}

::: notes
First block. Programs are transition systems on memory; CBMC builds that transition system from C automatically and bounded-model-checks it. We do the mechanics (unwinding, asserts, nondet), then the counter in C live, then what CBMC catches by default.
:::

---

## Programs are transition systems

A C program's **state** is:

$$(\text{program counter},\ \text{valuation of every variable},\ \text{heap},\ \text{stack})$$

and its **transition** is "execute one statement."

This is the same `T = (S, S₀, →)` from Day 1 — the state space is just much bigger.

::: notes
The conceptual bridge. We saw this by hand in gcd_01.smv (Day 2) — add a program counter, and a sequential program becomes a transition system. CBMC does that construction automatically for real C, including the heap and stack. So everything from Days 1-3 applies; CBMC is "Day 1's bounded SMT, but the transition system is extracted from C source instead of written by hand."
:::

---

## What CBMC actually does

```
C source → goto-program → unwound goto-program → SMT formula → Z3
```

1. Parse and simplify C into a control-flow "goto-program."
2. **Unwind** loops a fixed number of times.
3. Encode every path as one big SMT formula (bit-precise).
4. Ask the solver whether any path violates an assertion.

Same engine as Day 1 — CBMC is a front-end that turns C into the SMT query you wrote by hand.

::: notes
The pipeline. The key realization for students: CBMC is not magic, it is automation of exactly the Day-1 encoding. It compiles C to a goto-program (control flow made explicit), unwinds loops to bound the depth, bit-blasts everything to a precise SMT formula, and hands it to a solver. Bit-precise matters — it models machine integers exactly, so it catches overflow (the Ariane bug from Day 1) that integer-abstraction tools miss.
:::

---

## Loop unwinding

```bash
cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions
```

- `--unwind N` — unfold each loop `N` times.
- `--unwinding-assertions` — CBMC checks `N` was large enough and **fails loudly** if not. (CBMC 6 enables this by default; we write it explicitly to be clear.)
- Off-by-one: a loop running `BOUND = 25` times needs `--unwind 26` — one extra for the termination check.

::: notes
Unwinding is the bounded part of bounded model checking. The --unwinding-assertions flag makes CBMC add an assertion "the loop really finished within N" and fail loudly if not — converting silent incompleteness (the Day-1 BMC limitation) into a visible one. Version note that matters: from CBMC 6 onward this is part of the default "standard checks," so a plain `cbmc` run already does it; we pass the flag explicitly (and the example files do too) for clarity, and you can turn it off with `--no-unwinding-assertions`. The +1 off-by-one is a real gotcha we hit building the example: BOUND=25 needs --unwind 26 because the termination check is one more iteration.
:::

---

## The harness: nondeterminism + assertions

```c
bool nondet_bool(void);     // CBMC: returns an unconstrained value

int main(void) {
    struct state s = { .mode = MODE_OFF, .x = 0 };
    for (int i = 0; i < BOUND; ++i) {
        bool press = nondet_bool();   // environment picks each step
        counter_step(&s, press);
        assert(s.x <= 10);            // the property
    }
}
```

- `nondet_*()` = the SMV "free input" idiom, in C.
- `__CPROVER_assume(c)` constrains inputs; `assert(c)` states the property.

::: notes
The harness is how you drive a function under all inputs. nondet_bool() is CBMC's equivalent of the SMV unconstrained input or the Z3 fresh variable — CBMC explores every value. assert states what must hold; __CPROVER_assume (not shown) lets you constrain the input space (e.g. exclude INT_MIN for an abs function). This harness is the C version of the Day-1 bounded-reachability query: nondeterministic press, assert the invariant, every step.
:::

---

## Live demo: the counter in C

```c
void counter_step(struct state *s, bool press) {
    if (s->mode == MODE_OFF && !press)        { /* stay off */ }
    else if (s->mode == MODE_OFF && press)    { s->mode = MODE_ON; }
    else if (s->mode == MODE_ON && !press && s->x < COUNT_MAX) { s->x++; }
    else if (s->mode == MODE_ON && (press || s->x >= COUNT_MAX)) {
        s->mode = MODE_OFF; s->x = 0;
    }
}
```

Same four guards as SMV `next(...)`, Lean `next`, Z3 `step()`.

```text
cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions
→ VERIFICATION SUCCESSFUL
```

::: notes
Run it live. The function is the counter's fourth encoding, and the guards line up exactly with every prior day. VERIFICATION SUCCESSFUL means: across all 25 steps and all 2^25 press sequences, the assertion x ≤ 10 never fails — a bounded but exhaustive-over-inputs guarantee, proved on the real C, not a model of it.
:::

---

## Reading a CBMC counterexample

Weaken the assertion to `s.x < 10` and re-run:

```text
[main.assertion.1] line 56 assertion s.x < 10: FAILURE

State ... counter.c function counter_step
  prev_x = 9
State ... counter.c
  s.x = 10
Violated property: s.x < 10
```

CBMC prints the **exact** state sequence — and the precise `press` inputs — that drive `x` to 10.

::: notes
Same value as the nuXmv counterexample: a concrete, replayable trace, but now annotated with C source lines and variable values. You can see prev_x = 9 then s.x = 10 at the violating step. CBMC checks every assertion in the program and labels them (main.assertion.1, etc.); the trace pinpoints which one and how. This is the debugging payoff — not "a test failed" but "here is the exact execution that breaks it."
:::

---

## What CBMC catches by default

Even with no assertions you write, CBMC checks for:

- integer **overflow** (the Ariane 5 bug),
- array **out-of-bounds**,
- null / invalid **pointer** dereference,
- **division by zero**, use-after-free, uninitialized reads.

Each is a built-in assertion; the counter run shows dozens of `SUCCESS` lines for these.

::: notes
A major selling point: CBMC's default checks catch the classic memory-safety and arithmetic bugs without you writing a single assertion. The Ariane 5 overflow (Day 1), the Toyota stack issues — these are exactly CBMC's built-in checks. When you run the counter you see ~50 SUCCESS lines for pointer/overflow/bounds checks before the one assertion you wrote. This is why CBMC is used on real embedded C (automotive, AWS firmware).
:::

---

## L1 recap

- A C program is a **transition system on memory**; CBMC builds it from source.
- CBMC = C → goto-program → unwound → SMT → Z3 (Day 1's engine, automated).
- Harness with `nondet_*()` + `assert` + `__CPROVER_assume`; `--unwind N` bounds loops (CBMC 6 checks `N` is big enough by default).
- Default checks catch overflow, bounds, null deref, division-by-zero for free.

::: notes
Block recap. Take-home: you can write a CBMC harness, run it, and read the counterexample — the same bounded-MC idea from Day 1, now on real code. Next: when you want a *spec* separate from the implementation, and a proof they agree.
:::

---

## ☕ Break {.section}

We resume after the break with Cryptol and SAW.

---

# L2 — Cryptol + SAW {.section}

::: notes
Second block. CBMC checks a program against assertions. Sometimes you want a separate, executable *specification* and a proof that an optimized implementation matches it. That is Cryptol (the spec language) + SAW (the equivalence checker). The classic use is cryptography, but the idea is general.
:::

---

## Why a separate specification language

CBMC checks code against inline assertions. But often you want:

- a **reference spec** independent of any implementation, and
- a proof that a fast/tricky implementation **equals** the spec on all inputs.

"Spec once, verify many implementations." This is **Cryptol** (Galois, first published 2003) + **SAW**.

::: notes
The motivation for the spec-vs-implementation split. In crypto especially, you have a clean mathematical spec (the standard) and a heavily optimized implementation (assembly, bit-twiddling). You want to prove they compute the same function on every input. Cryptol expresses the spec at the bit level; SAW (the Software Analysis Workbench) extracts a model of the C/LLVM implementation and proves equivalence via SMT. The Pentium FDIV bug (Day 1) is exactly an implementation-vs-spec mismatch.
:::

---

## What is Cryptol?

A small functional language for writing **executable specifications** of algorithms that work on bits and bytes — built by Galois, first published 2003, originally for cryptography.

- You write *what* the algorithm computes, at the bit level — not *how* to make it fast.
- The same file is both **runnable** (test it) and **provable** (`:prove` checks it for *all* inputs).
- Think "executable math for bit-vectors": if you can write AES on a whiteboard, you can write it in Cryptol almost line-for-line.

Why it matters today: it's the cleanest place to see "spec = proof target," and it's how AWS verifies real crypto (later this block).

::: notes
Motivation before notation — the instructor's explicit fix, since students hit the type table cold and got lost. The single framing that lands: "executable math for bit-vectors." It's a spec language, so the whole file is the thing you prove things about; there's no separate "implementation" to wrestle with until SAW. Keep this slide light and reassuring — the scary-looking types come next, but now they have a purpose.
:::

---

## Cryptol types are sizes — read `[n]T` as "n of T"

Every type carries a size, checked at compile time. That bit-exactness is why Cryptol is the language for crypto and hardware specs.

| You write | You say | It means |
|---|---|---|
| `Bit` | "bit" | one bit (a Boolean) |
| `[8]` | "8 bits" | an 8-bit word (= `[8]Bit`) |
| `[16][8]` | "16 of 8-bit" | 16 bytes (a 16-byte buffer) |
| `[4][8]` | "4 of 8-bit" | 4 bytes |
| `(A, B)` | "a pair" | a tuple of an `A` and a `B` |
| `A -> B -> C` | "a function" | takes an `A` **and** a `B`, returns a `C` |

- The **number is the length**, and it's **part of the type** — so the compiler always knows every size.
- That's why `[8] + [8]` type-checks but `[8] + [4]` is a compile error.
- Multiple arrows = multiple arguments: `[8] -> [N][8] -> [N][8]` takes a key byte **and** a message.

::: notes
The one thing to internalize before reading any Cryptol — the instructor flagged that `[n]T` was never really explained. Read it left-to-right as "n of T": `[16][8]` = "16 of (8-bit word)" = 16 bytes. The number is the length and it lives in the type, so widths are always known and checked — that's the bit-exactness crypto needs. The `A -> B -> C` "two arrows = two arguments" row heads off the most common beginner confusion when they meet `[8] -> [N][8] -> [N][8]` (it's currying, but you don't need that word).
:::

---

## Cryptol by example: a shift cipher

```cryptol
type N = 16                           // message length, in bytes ([N][8] = N bytes)
encrypt : [8] -> [N][8] -> [N][8]     // key byte -> 16 bytes -> 16 bytes
encrypt k msg = [ c + k | c <- msg ]  // add the key to every byte (+ is mod 256)

decrypt : [8] -> [N][8] -> [N][8]
decrypt k ct  = [ c - k | c <- ct ]

property roundtrip k msg = decrypt k (encrypt k msg) == msg
```

- `type N = 16` names a compile-time size — usable anywhere a length is needed.
- `[ c + k | c <- msg ]` is a **comprehension**: "for each byte `c` *drawn from* `msg` (`<-`), produce `c + k`" — like building a new array by transforming each element.
- `+` / `-` on `[8]` are arithmetic **mod 256** — the width lives in the type.
- a `property` is a claim to check for **all** inputs.   *(this is `examples/caesar.cry`)*

::: notes
A complete, readable Cryptol program. `[N][8]` is "N bytes" — there is the `[n]T` shape with T = `[8]`. The comprehension `[ c + k | c <- msg ]` maps over the message, adding the key byte to each (mod 256, because the element type is 8 bits). `decrypt` subtracts. The property says decrypt undoes encrypt for every key and message — which we prove next. No implementation tricks: this IS the spec.
:::

---

## `:check`, `:prove`, `:sat`

```text
caesar> :check roundtrip          -- fast: random testing, no solver
Using random testing.
passed 100 tests.
caesar> :prove roundtrip          -- exhaustive: ALL keys × ALL 16-byte messages
Q.E.D.
caesar> :sat \k msg -> decrypt k (encrypt k msg) != msg
Unsatisfiable
```

- `:check p` — quick random sanity test (no solver), great before the real proof.
- `:prove p` — "`p` holds for **all** inputs"; `Q.E.D.` = proved exhaustively.
- `:sat e` — find inputs making `e` true; `Unsatisfiable` = none exist. (`\k msg -> e` is an anonymous function of `k` and `msg`.)

`:prove p` is exactly "`¬p` is unsatisfiable" — Day 1's validity ↔ unsat-of-negation, now over fixed-width bit vectors. Cryptol talks to **Z3** by default (through its SBV backend). *(Run the `caesar_starter.cry` stub and `:prove roundtrip` returns a `Counterexample` instead.)*

::: notes
Three commands, easiest to strongest. `:check` randomly samples inputs (no solver) — instant confidence while drafting. `:prove` hands the property to an SMT solver and checks it over the *entire* input space — every key and every 16-byte message, astronomically large but decidable because everything is finite-width; `Q.E.D.` = proved exhaustively. `:sat` of the negation is the dual "find a counterexample"; `Unsatisfiable` (the real Cryptol word) means none exists. Same validity = unsat-of-negation idea from Day 1, now in Cryptol — no inductive argument needed for fixed-width bit vectors. Default solver is Z3 via the SBV backend; What4 is a selectable alternative.
:::

---

## The counter in Cryptol (fifth encoding)

```cryptol
type State = (Bit, [4])           // (mode, x): False=OFF, True=ON

step : State -> Bit -> State
step s press = ...                 // four guards, mirrors counter.c

property bounded_invariant (presses : [25]Bit) =
    foldl (&&) True [ inv s | s <- states ]           // states = the 25-step trajectory

property inductive_invariant (s : State) (press : Bit) =
    if inv s then inv (step s press) else True          // mirrors Lean step
```

```text
:prove bounded_invariant    → Q.E.D.   (~0.2s)
:prove inductive_invariant  → Q.E.D.   (~0.02s)
```

(`foldl (&&) True xs` folds "and" across a list — "are all of `xs` true?"; `states` is the trajectory the file builds from `presses`.)

::: notes
The counter, one last time. Cryptol lets us express *both* prior styles: bounded_invariant is the Day-1/CBMC bounded check (every 25-press trajectory), and inductive_invariant is the Day-3 Lean step (one step preserves the invariant) — both discharged by SMT in milliseconds. Same system, both kinds of guarantee, in one tiny file. This is the satisfying closure of the running example: five encodings, and Cryptol re-expresses two of them.
:::

---

## SAW: tying Cryptol to a C implementation

The SAW example is **popcount** (count the set bits in a word): a clean Cryptol spec plus an optimized C implementation. SAW proves they compute the same function.

```bash
clang -c -emit-llvm -O0 -o popcount.bc popcount.c   # C → LLVM bitcode
saw popcount.saw                                     # prove C == Cryptol spec
```

```text
Proof succeeded! popcount_loop
```

SAW extracts a symbolic model of each C function from LLVM bitcode and proves it **equivalent** to the Cryptol spec, over all inputs, via SMT.

::: notes
SAW is the bridge from spec to real code. You compile the C to LLVM bitcode, and the .saw script tells SAW to symbolically execute each C function and prove it equals the Cryptol spec on all inputs. "Proof succeeded" means the C implementation and the spec are the same function — bit for bit, every input. This is end-to-end: a clean spec, an optimized implementation, and a machine-checked proof they agree. It is exactly the workflow behind AWS's verified crypto.
:::

---

## Where SAW shines — and where it struggles

- **Shines**: crypto (AES, SHA, P-256), parsers, format validators, fixed-shape loops.
- **Struggles**: data-dependent loops (e.g. Kernighan's `while (x != 0)`) need explicit bounds — symbolic execution can't always tell when to stop.

**We grade only the counted-loop variant in SAW**; the two Cryptol definitions are linked by `:prove`. A clean architecture beats fighting the tool.

::: notes
Honest limits. SAW symbolically executes the implementation, so a loop whose trip count depends on the data (Kernighan's popcount: while x != 0) can hang because the symbolic executor doesn't know a static bound. The pragmatic fix we used: verify the fixed-trip-count implementation against the spec with SAW, and link the two implementations via Cryptol's :prove. The lesson generalizes: when a tool struggles, restructure the obligation rather than brute-forcing it.
:::

---

## L2 recap

- **Cryptol** = bit-precise spec language; `:prove`/`:sat` discharge properties over all inputs via SMT.
- **SAW** proves a C/LLVM implementation **equivalent** to a Cryptol spec.
- The counter's bounded *and* inductive invariants both fall to Cryptol `:prove`.
- Match the obligation to the tool — fixed loops for SAW, `:prove` to chain implementations.

::: notes
Block recap. Take-home: spec-vs-implementation verification — write a clean Cryptol spec, prove an implementation matches it with SAW. This is how production crypto is verified. Next: the frontier and the industrial reality.
:::

---

## ☕ Break {.section}

We resume after the break with the frontier — neural-network verification and industrial FM.

---

# L3 — The frontier {.section}

::: notes
Final block, a survey. Where formal methods meets AI (neural-network verification — the verification of the systems generating today's code/proofs) and where classical FM is deployed at scale. This is the "what's next and who's doing it" tour.
:::

---

## Verifying neural networks

The problem: given a trained network `f` and an input region `R`,

$$\forall x \in R,\ f(x)\ \text{still classifies correctly (robustness)}.$$

Here `R` is usually an **ℓ∞ ball** — every input within ε of a sample (each coordinate nudged by ≤ ε). *Robustness* = small input changes never flip the output class. Hard because `f` is **non-convex** (the safe region isn't a simple shape), **non-linear**, and has millions–billions of activations.

::: notes
Neural-network verification flips the script: now the *AI itself* is the artifact to verify. The canonical property is local robustness — for every input within an ℓ_∞ ball around a sample, the network gives the same class. This is genuinely hard: a ReLU network is a piecewise-linear function with exponentially many pieces, so exact verification is NP-complete (Katz et al., Reluplex, CAV 2017). This is Taylor's research area (NNV), so there's deep local expertise.
:::

---

## α,β-CROWN and NNV

- **α,β-CROWN** — *branch-and-bound* (split the input region into cases, bound each) with linear bounds on activations; multi-year **VNN-COMP** winner.
- **NNV** (Vanderbilt/verivital) — set-based reachability with *star sets* (a compact representation of a whole set of inputs/states), including cyber-physical systems.
- **UNSAT certifies robustness**: no input in `R` flips the class.

::: notes
The two leading approaches. α,β-CROWN computes linear lower/upper bounds on the network output and branches when bounds are too loose — it has won VNN-COMP (the annual neural-net verification competition) for years. NNV (our group) uses reachability: propagate a set (a "star set") through the layers and check the output set stays in the safe region — and extends to closed-loop cyber-physical systems (network + plant). Same UNSAT-certifies-safety logic as everything else this week.
:::

---

## VNN-COMP: the state of the art

The annual competition tracks what's in routine reach:

- **In reach now**: ReLU MLPs, CNNs, ResNets, small transformers; ℓ_∞ robustness, reachability.
- **Still hard**: large transformers/LLMs, recurrent nets, high-dimensional inputs, non-ℓ_∞ specs.

(See VNN-COMP results; benchmarks at <https://vnn-comp.github.io/>.)

::: notes
VNN-COMP (like SAT-COMP/SMT-COMP) is the honest scoreboard. Feed-forward ReLU networks up to ResNet scale are now routinely verifiable for ℓ_∞ robustness; the frontier — large transformers, LLMs, realistic perturbation models — is still open. This is the cleanest way to answer "can we verify neural networks yet?": yes for these classes, not yet for those. Good survey-discussion fodder for the assignment.
:::

---

## Classical FM in production: AWS

AWS **Provable Security** runs formal methods at production scale:

- **s2n-TLS** — crypto kernels (HMAC, DRBG) verified with **SAW** against Cryptol specs (the L2 workflow), every commit.
- **s2n-bignum** — verified **assembly** (P-256/384/521, X25519, Ed25519, RSA, AES-XTS), each with a **HOL Light** proof, per commit.
- **Cedar** — authorization policy language **specified in Lean** (Day 3; originally Dafny).

::: notes
The flagship industrial deployment, and it ties together the whole week: SAW (today) verifies s2n's crypto, Lean (Day 3) specifies Cedar's policy semantics, and SMT (Day 1) underlies all of it. AWS treats verification as a CI signal — every commit re-runs the proofs. This is the existence proof that formal methods scales to the largest, most cost-sensitive systems: at AWS scale, one crypto bug costs more than a decade of verification engineering.
:::

---

## Classical FM in production: everyone else

- **Semiconductors** — Cadence JasperGold, Synopsys VC Formal (Apple, Intel, AMD, ARM).
- **Verified systems** — seL4 (microkernel, Isabelle), CompCert (C compiler, Coq).
- **Avionics / space** — SCADE & Astrée (Airbus fly-by-wire), SPARK/Ada (Ariane 6).
- **Microsoft** — Dafny, Boogie, Z3 across Azure and Windows components.

::: notes
The breadth slide. Formal methods is mandatory-by-economics in chips (post-FDIV), mandatory-by-regulation in avionics (DO-178C), and load-bearing in verified systems (seL4, CompCert) and cloud infrastructure (Microsoft's Dafny/Z3). The point for students: this is not a research curiosity — it is the assurance backbone of the highest-stakes computing systems on earth, using the exact tools and ideas from this week.
:::

---

## Where formal methods meets AI

The convergence, both directions:

- **FM for AI** — verify neural networks (α,β-CROWN, NNV); the systems generating code/proofs.
- **AI for FM** — LLMs draft Lean proofs (AlphaProof, DeepSeek-Prover), SAW scripts, CBMC harnesses.
- The constant: a **trusted checker** (SMT kernel, Lean kernel) arbitrates. AI proposes; the kernel disposes.

::: notes
The synthesis of the entire course. Two arrows: formal methods verifies AI systems (NN verification), and AI accelerates formal methods (proof/harness drafting). The invariant across both — and across all four days — is that a small trusted checker has the final say. That is the architecture that makes AI-generated artifacts trustworthy, which is the thesis the workshop opened with on Day 1.
:::

---

## The week in one table

| Day | Tool | Question answered |
|---|---|---|
| 1 | Z3 + SMT-LIB | counterexample of length ≤ N? — bounded refutation |
| 2 | nuXmv | counterexample ever? — full model checking |
| 3 | Lean 4 | why no counterexample? — inductive proof |
| 4 | CBMC + Cryptol/SAW | does the source match the spec? — implementation-level |

Same counter, **five encodings**, four kinds of guarantee.

::: notes
The capstone summary. Each day answered a sharper question about the *same* system, with a different power/generality trade-off. Day 4's Cryptol re-expresses both the bounded (Day 1) and inductive (Day 3) views, closing the loop. This table is the single thing to remember from the week: the verification triple (model, spec, proof) instantiated five ways.
:::

---

## L3 recap

- **Neural-network verification** (α,β-CROWN, NNV) verifies the AI systems themselves; VNN-COMP tracks the frontier.
- **Industry runs FM at scale** — AWS (SAW/Lean/Z3), chips (JasperGold), verified systems (seL4, CompCert).
- **FM ↔ AI converge**, with a trusted checker always arbitrating.

::: notes
Block recap. Take-home: the field is alive at the frontier (verifying AI) and load-bearing in production (verifying everything else), and the human-plus-AI-plus-kernel loop is the through-line. Students leave knowing both the toolbox and the landscape.
:::

---

# Wrap + work {.section}

---

## Day 4 — and the week — in one slide

- Programs are transition systems; **CBMC** verifies real C with Day-1's engine.
- **Cryptol** specs + **SAW** prove implementations equal their specs, over all inputs.
- The frontier: **verifying neural networks**; the reality: **FM in production everywhere**.
- The constant across four days: **AI proposes, the kernel disposes.**

::: notes
The closing throughline for both the day and the course. Read aloud. The single sentence to leave with is the last bullet — it is the workshop's thesis, demonstrated five ways.
:::

---

## What you can do now

You can:

1. **Encode** a system as a transition system.
2. **Specify** correctness in propositional, temporal, or higher-order logic.
3. **Discharge** it via SAT/SMT, model checking, or theorem proving.
4. **Connect** the spec to real code via CBMC and Cryptol/SAW.
5. **Drive** AI assistants in the loop, with the kernel as truth.

::: notes
The deliverables promised on Day 1, now realized. This is the checklist students should be able to apply to their own systems after the workshop. The workshop was a single pass through each; the real work is applying it to their research/teaching.
:::

---

## In-session exercise

Pick a track (see [`assignments/day04.md`](../assignments/day04.md)):

- **CBMC**: write a small C function + harness (saturating counter, queue, `my_abs`); verify a property; introduce a bug and capture the counterexample.
- **Cryptol/SAW**: write a small spec (4-bit cipher, parity, CRC-4) with two definitions; `:prove` they agree.

Each topic ships a `_starter` stub (which produces a counterexample) plus a worked solution — start from the starter and fix it until the verdict is clean.

::: notes
Self-contained tracks. CBMC track: the abs-value one is a great overflow lesson (INT_MIN needs __CPROVER_assume). Cryptol track: two definitions + :prove is the core skill. Either is a complete exercise; the bug-and-counterexample step (CBMC) is the most instructive part.
:::

---

## Homework + survey (ungraded, for depth)

- Finish your chosen track to a clean verdict; capture one counterexample.
- **Survey paragraph** — pick one: latest VNN-COMP (what's in reach for α,β-CROWN?), AWS Provable Security s2n (what's continuously verified, with what stack?), or one thing in *your* research that is / isn't a fit for FM.

::: notes
The survey paragraph makes students connect the frontier to their own work — the most valuable take-away for a research audience. Reading the VNN-COMP results or the AWS Provable Security page is a concrete way to see the state of the art. Not graded; it is for them.
:::

---

## References for Day 4

- **Clarke, Kroening, Lerda.** *A Tool for Checking ANSI-C Programs*, TACAS 2004 (the original CBMC paper; lead/maintainer Daniel Kroening).
- **Lewis, Martin.** *Cryptol: High Assurance, Retargetable Crypto Development*, MILCOM 2003.
- **Galois** — Cryptol & SAW docs/tutorials; **AWS Provable Security** blog.
- **VNN-COMP** — <https://vnn-comp.github.io/>; **α,β-CROWN**; **NNV** (verivital).
- **AWS Cedar** (Lean spec); **seL4**, **CompCert** (verified systems).

Full list + competitions table: repo [README.md](../../README.md#background-references).

::: notes
Curated to the day's tools plus the frontier. The repo's competitions table (VNN-COMP, SV-COMP, SMT-COMP, etc.) is the best single resource for "what's the state of the art for problem class X." That's the note to end on for a research audience.
:::

---

## Thank you

Four days, four pillars, one counter, five encodings.

Repo: [github.com/ttj/fmaiv](https://github.com/ttj/fmaiv) — all slides, examples, the Docker toolchain, and references.

Questions, and where to go next: the reading list and communities in the README.

::: notes
Close the workshop. Thank the participants. Point them at the repo (everything reproducible) and the references/communities for continuing. The emotional close is the running counter: one tiny system, seen from every angle the field offers — that's the mental model they take home.
:::
