---
title: "Day 1 — Foundations: Logic, Transition Systems, SAT, SMT"
subtitle: "FMAIV: Formal Methods & AI-Assisted Verification"
author: "Taylor T. Johnson"
institute: "Vanderbilt University"
date: "Day 1 of 4"
---

# Day 1 — Foundations {.title}

## Logic, transition systems, SAT, SMT {.section}

::: notes
Welcome. By the end of today every participant will have typed a Z3 query, formalized a small reactive system as a transition system, and asked an SMT solver to discharge a bounded-reachability question. In a later session we'll take what you encoded today and push it through a full model checker; by the end of the course the same little system will have been encoded five times in five different tools. The point isn't the tools — it's seeing the same `(model, specification, proof)` triple from five angles.
:::

---

## Your day at a glance

| Block | Length | Topic |
|---|---|---|
| Opening | ~10 min | Recap, roadmap, learning objectives |
| L1 | ~50 min | Why now: the AI × FM asymmetry; bug stories; industrial deployment |
| Break | ~10 min | ☕ |
| L2 | ~50 min | Propositional + first-order logic; transition systems |
| Break | ~5 min | ☕ |
| L3 | ~45 min | SAT, SMT, Z3 — live coding |
| Wrap + exercise | ~10 min | One-line recaps; homework pointer |

::: notes
Three roughly-equal teaching blocks with two breaks. The first break is the longer one — coffee, hallway conversations. Each block ends with a tool you can poke at: after L1 you've seen a Z3 query, after L2 a transition system, after L3 bounded model checking work and fail.
:::

---

## The four-day arc

| Day | Theme | Tools | Question answered |
|---|---|---|---|
| **1** | Logic + SAT + SMT | Z3 | "Is there a counterexample of length ≤ N?" |
| 2 | Model checking | nuXmv | "Is there a counterexample, ever?" |
| 3 | Theorem proving | Lean 4, Claude Code | "Why is there no counterexample?" |
| 4 | Program + frontier | CBMC, Cryptol, SAW | "Does the source match the spec?" |

A single running example — a small "counter to 10" reactive system — appears in every day, in five different encodings (Day 4 has two).

::: notes
The same counter, five encodings: Z3 SMT formula in Day 1; nuXmv SMV file in Day 2; Lean inductive proof in Day 3; C with CBMC and Cryptol with `:prove` both in Day 4. Every tool says "the counter is safe" in a different mathematical language, and every tool is right in a slightly different sense.
:::

---

## Learning objectives for Day 1

By the end of today, you will be able to:

- Distinguish satisfiability, validity, and entailment in propositional and first-order logic.
- Define a transition system $T = (S, S_0, \rightarrow, AP, L)$ and write one for a small reactive system.
- Express a bounded-reachability question as an SMT formula over an appropriate theory.
- Drive Z3 from both SMT-LIB and Python; read the solver's `sat` / `unsat` / model output.
- Explain what bounded model checking does and does not prove.

::: notes
These five objectives map one-for-one to L1 → L3. We'll come back to them in the wrap slide and ask honestly: did we hit them?
:::

---

# L1 — Why now: AI × FM asymmetry {.section}

::: notes
Fifty minutes. The arc: why this workshop exists at all (the asymmetry), what the verification triple is, eight or so historical bug stories that motivated FM, the modern industrial landscape, and a quick live Claude-Code-into-Z3 demo. If we run long, the bug stories compress; if short, we go deeper on the industrial cases.
:::

---

## The bottleneck has flipped

- **Generative AI produces code, proofs, and engineering artifacts faster than any human can read.**
- The bottleneck is no longer *production*. It is *validation*.
- Formal methods is the branch of computer science designed to validate these artifacts mechanically.

> Terence Tao has described large Lean formalization projects as a new mode of collaboration: contributors he has never met submit proof steps in a language he is still learning, and the proof assistant's kernel — not a human referee — arbitrates whether each step is correct. (Scientific American interview, 2024)

::: notes
This is the framing slide for the whole week. The story is: AI is doing the easy half of verification (proposing) much faster than humans can do the hard half (checking). Formal methods is the only known way to mechanize the checking. We're not here to compete with AI; we're here to build the substrate it needs to be trustworthy. This is a paraphrase of Tao's public remarks on the PFR/Equational Theories Lean projects (e.g. his 2024 Scientific American interview and blog posts), not a verbatim quotation.
:::

---

## Three signals: AI is shipping verifiable math

- **Polynomial Freiman–Ruzsa conjecture** — the informal proof (Gowers, Green, Manners, Tao, 2023) was formalized in Lean in about three weeks by a public collaboration of ~25 people, led by Tao with Yael Dillies and Bhavik Mehta (November 2023).
- **Gemini Deep Think — IMO 2025 gold medal** — 35/42 points, solved 5 of 6 problems within the 4.5-hour window, all in natural language.
- **DeepSeek-Prover-V2 — 88.9% on miniF2F** (April 2025), the standard benchmark of olympiad-level theorems in Lean 4.

::: notes
Three things that would have been science fiction in 2020 and are now line items in 2026. PFR showed AI-assisted human-mediated Lean formalization at a research-level speed (weeks, not years). IMO 2025 showed natural-language theorem proving by LLM at the olympiad medal level. DeepSeek-Prover-V2 showed automated proof generation in Lean at a level approaching strong undergraduates. None of these existed three years ago.
:::

---

## Three counter-signals: AI is shipping broken code

- **A large fraction of LLM-generated code carries known security vulnerabilities** — studies report anywhere from ~30% to over 60% depending on language and prompt; one 2023 audit (FormAI) found ~51% of C programs generated by GPT-class models contained at least one CWE-classified vulnerability.
- **~20% of LLM-recommended packages don't exist** — "slopsquatting" is now a named attack vector: an attacker registers the hallucinated package name.
- **AWS, by contrast, continuously formally verifies its crypto** — s2n-TLS is checked with SAW proofs on every commit, and a formally verified AES-XTS implementation landed in March 2026.

::: notes
The same AI that hits IMO gold also writes vulnerable code. The reason is the same: LLMs optimize for plausibility, not correctness. Formal methods is what gives you the correctness side of the contract. AWS publishes the verification stack they use for s2n; you can read the SAW scripts in their open-source repo. The contrast is the whole pitch for this week: formal methods is what lets you trust an AI's output.
:::

---

## What this workshop teaches you to do

You should leave the course able to:

1. **Encode** a system you care about as a transition system.
2. **Specify** what "correct" means in propositional, temporal, or higher-order logic.
3. **Discharge** the specification via SAT/SMT (Day 1), model checking (Day 2), or theorem proving (Day 3).
4. **Connect** the spec back to actual code (Day 4) via CBMC and Cryptol/SAW.
5. **Use AI assistants** in this loop while keeping the kernel as the source of truth.

::: notes
This is the deliverable. The workshop is short — four days — so we will cover canonical tools and the one running example. You leave with the toolbox installed, the workflow rehearsed once, and the literature pointers. Your real verification work happens later.
:::

---

## The verification triple

Every formal-verification effort, regardless of tool, instantiates the same triple:

$$\Big(\;\underbrace{\text{model}}_{\text{what the system is}},\;\;\underbrace{\text{specification}}_{\text{what correct means}},\;\;\underbrace{\text{proof}}_{\text{evidence}}\;\Big)$$

| Pillar | Model | Specification | Proof |
|---|---|---|---|
| SAT / SMT (Day 1) | propositional or QF-theory formula | `(check-sat)` query | unsat core, model, certificate |
| Model checking (Day 2) | finite transition system | CTL / LTL formula | invariant, BDD, or counterexample |
| Theorem proving (Day 3) | dependent type theory | a `theorem` statement | a term that inhabits the type |
| Program verification (Day 4) | imperative C program | Hoare triple / assertion | inductive invariant or refuted trace |

::: notes
Memorize this triple. It is the single most useful organizing principle in the field. Every paper, every tool, every demo will fit into it. When you read a new FM paper, your first question is "what's the model here, what's the spec, what counts as proof?" and the paper becomes much easier to read.
:::

---

## Famous bugs that motivated FM (1)

**Therac-25** (1985–87) — radiation therapy machine, six known accidents, at least three deaths.

A race condition in operator input timing let the machine deliver a 25-MeV electron beam without the beam-spreading target in place. Patients received 100× the prescribed dose.

- Root cause: software interlocks replaced hardware interlocks (Therac-20 had hardware safety; -25 did not).
- The same software bug existed in Therac-20 and never killed anyone because hardware caught it.
- Paper of record: Leveson & Turner, *Computer*, 1993. [sunnyday.mit.edu/papers/therac.pdf](http://sunnyday.mit.edu/papers/therac.pdf)

::: notes
Therac-25 is the founding bug-story of safety-critical software. The MIT paper by Nancy Leveson is required reading in every SE class on safety. The teaching point isn't "software is bad" — it's "removing redundancy without proof is bad." Hardware interlocks were doing the work; when removed, no one could prove the software interlocks were sufficient, and they weren't. This is the kind of question a model checker answers in seconds today.
:::

---

## Famous bugs (2)

**Ariane 5, Flight 501** (1996) — roughly $370M in lost hardware (rocket and four scientific satellites); exploded ~37 seconds after launch.

A 64-bit floating-point horizontal velocity overflowed when converted to a 16-bit signed integer in the inertial reference system. The exception was unhandled. The IRS shut down. So did the backup, which had the same code. The rocket veered off course and self-destructed.

- The bug was in code reused from Ariane 4, where the upper bound on horizontal velocity was lower.
- The Ariane 4 envelope made the conversion safe; nobody re-checked it for Ariane 5.
- Verifying the conversion safety is a one-line SMT query: `(assert (<= horizontal_velocity 32767))`.

::: notes
Ariane 5 is the founding bug-story for arithmetic verification. The fix the European Space Agency adopted afterwards was static analysis (Astrée, abstract interpretation) for the avionics software of every subsequent Ariane and Airbus. The bug would have been caught by a single integer-range assertion checked at compile time — about ten seconds of an SMT solver's time today.
:::

---

## Famous bugs (3)

**Intel Pentium FDIV** (1994) — division returned wrong answer for ~1 in 9 billion inputs.

A lookup table in the floating-point divider was missing five entries (out of 2048). The bug cost Intel **$475M** in replacement chips and reshaped industry practice forever.

- After FDIV, Intel hired the Symbolic Trajectory Evaluation group and made *formal verification of every arithmetic unit* a release gate.
- Today, Intel, AMD, Apple, ARM, and every major semiconductor company runs formal hardware verification at scale. Cadence JasperGold and Synopsys VC Formal are the products.
- Without FDIV, the modern formal-hardware industry might not exist.

::: notes
This is the bug that turned formal methods from academic curiosity into industrial practice. Intel's response was the most consequential single hire in FM history — they brought in Bob Brayton, Ed Clarke's collaborators, and made formal proof a CI gate. JasperGold is now used on every chip Apple ships. The lesson for us: one expensive incident is sometimes worth more than a thousand academic papers in changing industry practice.
:::

---

## Famous bugs (4)

**Toyota unintended acceleration** (2007–10) — multiple fatal accidents; $1.2B U.S. Department of Justice criminal penalty (2014).

NASA's Software Assurance Research Program audited the engine control software and found:

- Recursion limits exceeded; stack overflow possible.
- Thousands of global variables — no encapsulation.
- The watchdog timer could be silenced by the very task it was supposed to monitor.
- Throttle could become "wide open" via a single bit-flip and stay there.

Expert testimony in *Bookout v. Toyota* (Oklahoma 2013) cited these in a $3M jury award. Toyota recalled ~9 million vehicles.

::: notes
Toyota is the bug-story for embedded C software complexity. The NASA audit (Phil Koopman's testimony is the most-cited version) found code that any of today's static analyzers would flag immediately. CBMC, Frama-C, Coverity, Polyspace — all of them would have caught the recursion overflow. The post-2010 automotive industry adopted MISRA-C and started using formal methods more seriously; ISO 26262 mandates it for highest-criticality components.
:::

---

## Famous bugs (5)

**Boeing 737 MAX MCAS** (2018–19) — 346 deaths across two crashes.

The Maneuvering Characteristics Augmentation System was a software workaround for an aerodynamic change. It:

- Could push the nose down based on input from a *single* angle-of-attack sensor.
- Could re-trigger every 5 seconds, fighting pilot input.
- Was not documented in pilot training materials.
- Could not be disabled by the obvious means (autopilot off).

The fix was a software update plus hardware redundancy in the sensor. The certification process itself failed: the FAA delegated assessment to Boeing.

::: notes
MCAS is the contemporary version of Therac-25 — same pattern: software replacing hardware redundancy without anyone proving the software was sufficient. The deeper issue is process: nobody asked "what's the inductive invariant that keeps MCAS from fighting the pilot?" The post-MAX FAA reforms now require formal documentation of failure modes for software with this kind of authority. Some of the resulting work is being done with Dafny and TLA+.
:::

---

## The point is not that humans are bad

The point is that **certain classes of question** — overflow, race, deadlock, off-by-one, missing case in a switch — are exactly the questions a machine can answer mechanically.

- Therac-25 → race conditions → CTL liveness properties checked by a model checker.
- Ariane 5 → integer overflow → CBMC's default overflow check.
- Pentium FDIV → arithmetic correctness → SAW + Cryptol equivalence proof.
- Toyota → stack/recursion → CBMC + abstract interpretation.
- MCAS → input redundancy → TLA+ specification of sensor voting.

This week's tools can answer all five.

::: notes
Pivot slide. We've established the historical motivation; now we name the modern tools that handle each class of bug. This is also the implicit promise to the participants: by the end of the course you will have used four of these tools and know what each is for. The point of the bug stories is not to scare people but to anchor each tool in a real problem.
:::

---

## Industrial deployment today (overview)

| Domain | Tools in production | Example |
|---|---|---|
| Cloud crypto | SAW, Cryptol, Dafny, Lean | AWS s2n-TLS, s2n-bignum, Cedar policy language |
| Semiconductors | JasperGold, VC Formal, SymbiYosys | Apple Silicon, Intel, AMD, ARM |
| Avionics | SCADE, Astrée, SPARK/Ada | Airbus A380, Rafale, NASA |
| Automotive | CBMC, Polyspace, AbsInt | ISO 26262 ASIL-D components |
| Space | SPARK/Ada, Frama-C | SPARK powers Ariane 6 IRS |
| Verified OS | Coq, Isabelle | seL4 microkernel |
| Verified compilers | Coq | CompCert |

::: notes
This table is the answer to "is formal methods used in industry?" — emphatically yes, at the most cost-sensitive scales, in the highest-criticality systems. The reason is simple: at AWS scale, a single security bug costs more than a decade of verification engineering. The cost-benefit math has finally tipped.
:::

---

## AWS Provable Security in detail

AWS publishes their verification stack:

- **s2n-TLS** — TLS handshake and crypto kernels verified with SAW, runs on every AWS service.
- **s2n-bignum** — arbitrary-precision integer math (P-256, P-384, X25519, Ed25519, RSA), verified per commit.
- **AWS Cedar** — policy language for IAM/access control, **formally specified in Lean 4**, public Lean repo.
- **AES-XTS storage encryption** — used by EBS, verified at the implementation level (March 2026 announcement).
- **Dafny in IAM** — internal verification of authorization logic; AWS Dafny team open-sources methodology.

> AWS's Provable Security group frames verification as a continuous-integration signal: like a test suite, a proof either passes or fails on every commit, and a failing proof blocks the change.

::: notes
AWS is the showcase deployment. Byron Cook's group at AWS Provable Security is one of the largest industrial formal methods groups in the world, and they publish almost everything. If you want to read industrial-strength SAW scripts, the s2n-bignum repo is the place. The Cedar work is particularly relevant for Day 3 — it's Lean used as a *specification* language for production-deployed software, not just a math library. (The "verification as CI signal" framing paraphrases how the group publicly describes their workflow; it is not a verbatim quotation.)
:::

---

## What formal methods does *not* give you

Honesty about the limits:

- **"Verified" means "matches the spec"** — a wrong spec, verified, is still wrong.
- **The model is not the system** — overflow, timing, hardware faults live outside most models.
- **Cost is real** — proofs and harnesses take effort; reserve them for what matters.
- **Undecidability/scale** bite — not everything is provable, and not everything that is, is fast.

::: notes
Every honest FM course needs this slide. The deepest failure mode is the wrong specification: if you prove the code matches a spec that doesn't capture the real requirement, you've proved nothing useful — garbage in, verified garbage out. The model-vs-reality gap is the second trap (the model abstracts away timing, hardware faults, the environment). And FM has a cost: you spend it where a bug is expensive (crypto, avionics, kernels), not everywhere. This calibration — what to verify, against what spec, with what tool — is the judgment the whole week is teaching.
:::

---

## When to reach for which tool

| Situation | Reach for |
|---|---|
| "Is there a bug in the next N steps?" | SAT/SMT, bounded MC (Day 1, CBMC) |
| "Is this finite system ever wrong?" | model checking (Day 2) |
| "Unbounded / parametric / mathematical" | theorem proving (Day 3) |
| "Does this *code* match a spec?" | CBMC, SAW (Day 4) |

No single tool dominates — match the question to the method.

::: notes
A practical decision aid that also previews the week. The point: these tools are complementary, not competing. Bounded methods find bugs fast; model checking proves finite systems exhaustively; theorem proving handles the infinite/parametric/mathematical; source-level tools tie it to real code. A working verification engineer reaches for different ones depending on the question — which is exactly the menu we'll work through over four days.
:::

---

## Live demo: Claude Code → Z3 → graph 3-coloring

We will:

1. Open Claude Code in VS Code.
2. Ask: "draft an SMT-LIB encoding for 3-coloring the complete graph $K_4$."
3. Run the resulting `.smt2` file with `z3`.
4. Observe `unsat` (4 vertices, 3 colors, every pair adjacent — impossible).
5. Change $K_4$ to the cycle $C_5$ and observe `sat` with a model.

**The kernel arbitrates. The LLM proposes.**

::: notes
Three minutes of live coding. The Claude Code prompt is "give me an SMT-LIB encoding for the 3-colorability of K_4". It will produce something close to right; the point is to (a) see what the LLM produces, (b) run it and trust Z3's verdict, not the LLM's narration. If Claude makes a mistake — like asserting only some edges — the Z3 verdict catches it. This is the working pattern we'll use all week: AI proposes, kernel disposes.
:::

---

## Poll: SAT or UNSAT?

For each formula, predict `sat` or `unsat`:

1. $p \wedge \neg p$
2. $p \vee \neg p$
3. $(p \to q) \wedge (q \to r) \wedge p \wedge \neg r$
4. $\forall x.\; x + 0 = x$, in linear integer arithmetic
5. $\exists x, y \in \mathbb{Z}.\; x^2 + y^2 = 25 \wedge x > 0 \wedge y > 0$

Open the Top Hat poll on screen. We'll run each one through Z3 after the vote.

::: notes
Top Hat poll. Expected: (1) unsat — contradiction; (2) sat — tautology, every assignment satisfies; we call it "valid", which is the same as "negation is unsat"; (3) unsat — by modus ponens chain; (4) sat (and valid) — true in LIA; (5) sat with model x=3, y=4 (or 4,3). The point is to make participants realize satisfiability is the *primitive* operation; validity is "negation is unsat" and entailment is "premises ∧ ¬conclusion is unsat". Everything is satisfiability.
:::

---

## L1 recap

- Formal methods exists because the AI × human asymmetry has tipped: AI generates faster than humans can read.
- Every FM tool fits the **(model, specification, proof)** triple.
- Real bugs (Therac, Ariane, Pentium, Toyota, MAX) anchor each tool we'll see this week.
- Industry runs FM at scale: AWS, Intel, Apple, Airbus, NASA, the verified OS / compiler community.
- Pattern: **AI proposes, kernel disposes.**

::: notes
One-slide summary of L1. Mid-block recap so participants who lost the thread can catch up at the break.
:::

---

## ☕ Break — 10 minutes {.section}

Coffee, restroom, hallway questions.

We resume after the break with propositional and first-order logic.

::: notes
Stay near the room — if anyone has a question about an install or wants to look at the slides early, this is the slot for it.
:::

---

# L2 — Propositional + first-order logic; transition systems {.section}

::: notes
Fifty minutes. The math substrate everything else stands on. Three sub-blocks: propositional logic (syntax, semantics, sat/valid/entailment), first-order logic (quantifiers, structures, decidable fragments), and transition systems (the tuple, the counter). Audience is mostly mathematically literate, so we go briskly through the basics and dwell on the parts that matter for tool use.
:::

---

## What logic actually is (for our purposes)

A **logic** is a triple:

- **Syntax** — a grammar that decides which strings are formulas.
- **Semantics** — a function from formulas to truth-values, parametric in an *interpretation*.
- **Proof system** — rules for deriving formulas from formulas, sound and (ideally) complete w.r.t. the semantics.

For today: syntax + semantics. Proof systems return on Day 3.

::: notes
Mathematicians know this; computer scientists sometimes don't. The proof-system view is what Day 3 builds on (Lean is a proof system for dependent type theory). Today we live in the syntax/semantics half: we describe the system, the spec, and let an algorithm decide whether they fit.
:::

---

## Propositional logic — syntax

**Atomic propositions:** $p, q, r, \dots$ — variables ranging over $\{\bot, \top\}$.

**Formulas** are built inductively:

$$\varphi ::= p \;\mid\; \neg \varphi \;\mid\; \varphi \wedge \varphi \;\mid\; \varphi \vee \varphi \;\mid\; \varphi \to \varphi \;\mid\; \varphi \leftrightarrow \varphi$$

Examples:

- $p \wedge q$ — both
- $\neg p \vee q$ — equivalent to $p \to q$
- $(p \to q) \wedge (q \to p)$ — equivalent to $p \leftrightarrow q$

::: notes
The grammar is the foundation. Note that we treat $\to$ as primitive, not derived; SMT-LIB and Lean both do this. It also matches mathematician intuition (implication is a connective in its own right).
:::

---

## Propositional logic — semantics

A **valuation** $v$ is a function $\text{Var} \to \{\bot, \top\}$.

The semantics extends $v$ to all formulas:

| $\varphi$ | $[\![\varphi]\!]_v$ |
|---|---|
| $p$ | $v(p)$ |
| $\neg \varphi$ | $\top$ iff $[\![\varphi]\!]_v = \bot$ |
| $\varphi \wedge \psi$ | $\top$ iff $[\![\varphi]\!]_v = [\![\psi]\!]_v = \top$ |
| $\varphi \vee \psi$ | $\top$ iff at least one is $\top$ |
| $\varphi \to \psi$ | $\top$ iff $[\![\varphi]\!]_v = \bot$ or $[\![\psi]\!]_v = \top$ |

We write $v \models \varphi$ if $[\![\varphi]\!]_v = \top$.

::: notes
Standard Tarskian semantics. The implication row is the one that bites — "false implies anything" surprises mathematicians the first time. The convention is universal across SMT, model checking, and proof assistants.
:::

---

## The three questions

For a propositional formula $\varphi$:

| Question | Definition | Decision problem |
|---|---|---|
| **Satisfiability** | exists $v$ with $v \models \varphi$ | NP-complete (Cook 1971) |
| **Validity** | every $v$ satisfies $\varphi$ | co-NP-complete |
| **Entailment** | $\Gamma \models \varphi$ — every $v$ that satisfies all of $\Gamma$ satisfies $\varphi$ | reducible to (un)satisfiability |

Everything reduces to satisfiability:

- $\varphi$ valid $\iff$ $\neg \varphi$ unsatisfiable.
- $\Gamma \models \varphi \iff \Gamma \cup \{\neg \varphi\}$ unsatisfiable.

::: notes
This is the single most important slide in the propositional-logic block. Every FM tool reduces its question to satisfiability. When you want to check "is this property always true?" the tool asks "is the negation satisfiable?" If unsat, you've proved validity. This is the whole strategy of bounded model checking, of `:prove` in Cryptol, of `simp` closure checks in Lean — every time.
:::

---

## Worked examples

| Formula | Verdict | Witness |
|---|---|---|
| $p \wedge \neg p$ | unsatisfiable | none — contradiction |
| $p \vee \neg p$ | valid | every $v$; classical tautology |
| $p \to (q \to p)$ | valid | every $v$; "weakening" |
| $(p \to q) \wedge (q \to r) \wedge (p \to r)$ | satisfiable | $v(p) = v(q) = v(r) = \top$ |
| $(p \to q) \wedge p \wedge \neg q$ | unsatisfiable | modus ponens contradiction |

::: notes
Work through each one orally for ten seconds. The third one is famously where physicists get confused — "weakening" feels wrong because the premise can ignore the consequent's antecedent. It's correct in classical logic; in intuitionistic logic the same formula is also valid. Lean 4 uses intuitionistic by default, with classical as an axiom available via `Classical.em`.
:::

---

## First-order logic — what's new

Adds:

- **Variables and quantifiers**: $\forall x.\; \varphi(x)$, $\exists y.\; \varphi(y)$.
- **Function symbols and predicate symbols** of fixed arity. Constants are 0-ary functions.
- **Terms** built from variables and function applications.

A first-order **signature** $\Sigma$ lists the function and predicate symbols and their arities. A **structure** $\mathcal{M}$ for $\Sigma$ gives:

- A nonempty domain $|\mathcal{M}|$.
- An interpretation of each function symbol as an actual function on $|\mathcal{M}|$.
- An interpretation of each predicate symbol as an actual relation on $|\mathcal{M}|$.

::: notes
Quick refresher; mathematician audience will already know this. The point of restating it carefully is that SMT-LIB's logic declarations (`(set-logic QF_LIA)` etc.) parameterize over which signatures and structures the solver knows how to handle.
:::

---

## First-order satisfiability

$$\mathcal{M} \models \varphi$$

means "formula $\varphi$ is true in structure $\mathcal{M}$".

- **Satisfiable**: exists $\mathcal{M}$ with $\mathcal{M} \models \varphi$.
- **Valid**: every $\mathcal{M}$ models $\varphi$.

**First-order satisfiability is undecidable** in general (Church, Turing, 1936). No algorithm decides it for every formula.

What saves us: **decidable fragments**.

::: notes
The undecidability result is what motivates the move to SMT — instead of trying to decide satisfiability over arbitrary structures, we fix the structure (the integers, the real numbers, bit-vectors of fixed width) and decide satisfiability *over that one structure*. That's the trick.
:::

---

## Decidable theories that matter

| Theory | Domain | Examples | Decidable? |
|---|---|---|---|
| **EUF** | uninterpreted | $f(a) = b \wedge f(b) \neq c$ | yes |
| **LIA** | $\mathbb{Z}$, linear | $3x + 2y = 7 \wedge x > 0$ | yes |
| **LRA** | $\mathbb{R}$, linear | $x + y \le 1 \wedge x \ge 0$ | yes |
| **BV** | $[2^n]$, bit-wise | $x \;\&\; (x-1) = 0$ | yes |
| **Arrays** | $A : I \to V$ | $\text{store}(a, i, v)[i] = v$ | yes |
| **NIA** | $\mathbb{Z}$, nonlinear | $x \cdot y = z \wedge \dots$ | **undecidable** |
| **NRA** | $\mathbb{R}$, nonlinear | $x^2 + y^2 = 25$ | decidable (Tarski 1948); exponential |

Z3 supports all of these. The `(set-logic …)` directive tells it which fragment to assume.

::: notes
SMT solvers combine SAT with one or more decidable theories via the DPLL(T) framework — we'll come back to this in L3. For our purposes today: LIA covers the counter ($x \le 10$, $x + 1$), BV covers Day 4's popcount, EUF covers any "abstract function" reasoning. The undecidability of NIA is why every solver chokes on $x \cdot y = z$ with arbitrary $x, y$.
:::

---

## Sets, relations, functions (one-slide refresher)

A **set** is a collection. We write $a \in A$.

A **relation** $R$ from $A$ to $B$ is a subset of $A \times B$.

A **function** $f : A \to B$ is a special relation: every $a \in A$ relates to exactly one $b \in B$.

For Day 1 specifically:

- A transition system's state space $S$ is a set.
- The transition relation $\rightarrow$ is a binary relation on $S$.
- A labeling function $L : S \to 2^{AP}$ takes states to sets of true atomic propositions.

::: notes
Skim. Mathematicians know this. The point is to fix notation: $\rightarrow$ for the transition relation, $2^{AP}$ for the powerset of atomic propositions. We'll use both heavily in L2 part 3.
:::

---

## Transition systems

A **transition system** is a tuple

$$T = (S, S_0, \rightarrow, AP, L)$$

where:

- $S$ — the set of states (possibly infinite)
- $S_0 \subseteq S$ — the initial states
- $\rightarrow \;\subseteq S \times S$ — the transition relation (write $s \rightarrow s'$)
- $AP$ — a set of atomic propositions
- $L : S \to 2^{AP}$ — a labeling

A **trace** is a (finite or infinite) sequence $s_0, s_1, s_2, \dots$ with $s_0 \in S_0$ and $s_i \rightarrow s_{i+1}$ for all $i$.

A state $s$ is **reachable** if some trace contains it.

::: notes
This is the central formalism for the entire week. Every model checker, theorem prover for programs, and bounded checker we will see operates on this tuple — sometimes implicitly. SMT and BMC operate on it via unrollings; nuXmv operates on it directly; Lean encodes it as an inductive predicate; CBMC implicitly constructs it from C source. Once you understand this tuple, you understand the substrate of every tool we'll meet.
:::

---

## The running example: the counter

State and input:

- `mode ∈ {off, on}`
- `x ∈ ℕ`
- `press : Bool` (external input)

Behavior:

- Initially $(mode, x) = (\text{off}, 0)$.
- From off, a press flips to on.
- In on, each step with `!press` increments $x$ while $x < 10$.
- In on with press or $x \ge 10$, return to $(\text{off}, 0)$.

What we will verify, all week:

- $x \le 10$ (safety)
- $\text{mode} = \text{off} \to x = 0$ (consistency)
- $x > 0 \to \text{mode} = \text{on}$ (consistency)

::: notes
Same little system we'll see every day. Five tools, four pillars, one example. Pick the easiest non-trivial reactive system you can. The counter is small enough to fit on a slide, large enough that the model checker won't enumerate it instantly, and structured enough that the inductive invariant is illuminating (you have to strengthen "x ≤ 10" with "mode = off → x = 0" to make it inductive — that's the Day 3 insight, foreshadowed today).
:::

---

## The counter, formally

$$S = \{\text{off}, \text{on}\} \times \{0, 1, \dots, 10\}$$
$$S_0 = \{(\text{off}, 0)\}$$

Transition relation $\rightarrow$ (parameterized by a non-deterministic `press` at each step):

$$\begin{aligned}
(\text{off}, x) &\xrightarrow{\neg p} (\text{off}, x) \\
(\text{off}, x) &\xrightarrow{p} (\text{on}, x) \\
(\text{on}, x) &\xrightarrow{\neg p, \; x < 10} (\text{on}, x + 1) \\
(\text{on}, x) &\xrightarrow{p \;\vee\; x = 10} (\text{off}, 0)
\end{aligned}$$

Atomic propositions: $\text{mode}\_\text{off}, \text{mode}\_\text{on}, x{=}0, x{=}10, \dots$ as needed.

::: notes
The four-clause case analysis is the same case analysis we'll see in C (Day 4), in Lean (Day 3, in `counterInv_step`), in Cryptol (Day 4, in `step`), and in SMV (Day 2, in `next`). Once you've stared at it in one notation, the others become drop-in.
:::

---

## Reachable states: BFS by hand

Starting from $(\text{off}, 0)$:

```
(off, 0)                            ← initial
  ↓ press
(on, 0)
  ↓ !press
(on, 1) (on, 2) (on, 3) ... (on, 10)
  ↓ press (or x=10)
(off, 0)                            ← back to initial
```

The reachable set is **12 states**: $\{(\text{off}, 0)\} \cup \{(\text{on}, k) : 0 \le k \le 10\}$.

The safety property $x \le 10$ holds on all twelve. ✓

::: notes
We could verify by hand because the state space is finite and small. Day 2's nuXmv does this enumeration automatically. Day 3's Lean does it by induction without ever enumerating. Day 1's Z3 does a *bounded* version — "is x = 11 reachable in ≤ N steps for N = 5, 10, 30?" and answers UNSAT for each. We trade completeness for not having to construct the state space.
:::

---

## Poll: which is which?

Match each English sentence to one of (a), (b), or (c).

1. "On every trajectory from any initial state, $x$ stays in $[0, 10]$."
2. "There exists some trajectory along which $x = 10$ eventually."
3. "Whenever mode is off, $x$ must be 0."

Choices (formulas in informal English):

- (a) Safety invariant
- (b) Reachability witness
- (c) Conditional invariant

::: notes
Top Hat poll. Expected: 1 → safety invariant; 2 → reachability witness (`EF` in CTL on Day 2); 3 → conditional invariant. The point is to teach the vocabulary of three property categories we'll meet over the week: safety (always-good), reachability (some-good-eventually), and conditional safety (implication). All three are decidable by SMT in bounded form, by model checking in unbounded form.
:::

---

## L2 recap

- Logic = syntax + semantics. We live mostly in the SAT/SMT slice today.
- The three questions — satisfiability, validity, entailment — all reduce to satisfiability.
- First-order logic is undecidable in general; **decidable theories** (LIA, BV, EUF, Arrays, LRA) are what SMT solvers actually handle.
- A **transition system** $T = (S, S_0, \rightarrow, AP, L)$ is the substrate every tool this week operates on.
- The running example — the counter to 10 — has 12 reachable states; we'll verify "$x \le 10$" in five different ways.

::: notes
Block recap. The transition-system tuple is the *take-home* item from L2; participants should be able to write the tuple for their own pet system by the end of the course.
:::

---

## ☕ Break — 5 minutes {.section}

We resume after the break with SAT, SMT, and live Z3.

---

# L3 — SAT, SMT, and Z3 {.section}

::: notes
Forty-five minutes. The most hands-on block of the day. Three sub-blocks: SAT (DPLL, Cook-Levin, CDCL); SMT (DPLL(T), the theories you'll see this week); live Z3 (smoke, pigeonhole, bounded counter). Pace: keep the algorithm slides tight, give the live Z3 most of the time.
:::

---

## SAT — the canonical NP-complete problem

**SAT**: given a propositional formula $\varphi$, is there a valuation $v$ with $v \models \varphi$?

**Cook–Levin theorem** (Cook 1971, Levin 1973, independently): SAT is NP-complete.

Two consequences:

1. Every problem in NP reduces (in polynomial time) to a SAT instance.
2. If SAT had a polynomial-time algorithm, P = NP.

In practice: SAT solvers handle millions of variables and clauses on industrial instances. The theoretical worst case is unreachable on real workloads.

::: notes
The "theoretically hard, practically easy" pattern is the central surprise of modern SAT. Industrial SAT solvers (MiniSAT, Glucose, CaDiCaL, Kissat) routinely dispatch instances that would have been unthinkable in 1995. The reason is CDCL, watched literals, and clause learning — we'll touch each in two slides.
:::

---

## CNF: the canonical input form

A **literal** is an atom or its negation: $p$ or $\neg p$.

A **clause** is a disjunction of literals: $(p \vee \neg q \vee r)$.

A formula in **conjunctive normal form (CNF)** is a conjunction of clauses:

$$(p \vee \neg q) \wedge (\neg p \vee r) \wedge (q \vee \neg r)$$

Every propositional formula can be converted to CNF (Tseytin transformation, linear blow-up).

SAT solvers consume CNF.

::: notes
CNF is the universal input format. The Tseytin transformation is the technical trick: instead of distributing ∧ over ∨ (which can blow up exponentially), introduce fresh propositional variables for sub-formulas and assert their equivalences. Linear in the size of the input. Every modern SAT solver has a CNF preprocessor built in; you can hand it almost anything.
:::

---

## DPLL — the first complete SAT algorithm

**Davis–Putnam–Logemann–Loveland** (1962):

```
DPLL(φ):
  if φ is empty:       return SAT
  if φ has empty clause: return UNSAT
  apply unit propagation
  apply pure literal elimination
  choose unassigned literal ℓ
  if DPLL(φ ∧ ℓ):  return SAT
  if DPLL(φ ∧ ¬ℓ): return SAT
  return UNSAT
```

The kernel of every modern SAT solver. **CDCL** (Conflict-Driven Clause Learning, late 1990s) keeps the DPLL skeleton but adds clause learning from each backtrack — turning each conflict into a permanent constraint.

::: notes
DPLL is the algorithm participants need to know. CDCL is what they use; the only differences operationally are clause learning (a conflict produces a learned clause that prunes the search forever after) and non-chronological backjumping (you don't have to undo one assignment at a time; you can leap back to the actual cause of the conflict).
:::

---

## What makes modern SAT solvers actually fast

Four key engineering choices, each circa 1996–2003:

1. **CDCL** — learn from every conflict; the search shrinks as you go.
2. **Watched literals** — propagate without scanning every clause.
3. **VSIDS branching** — prefer literals that recently appeared in conflicts.
4. **Restart policies** — abandon the search tree periodically, keep learned clauses.

Result: SAT competition benchmarks went from "100 variables, sometimes" in 1990 to "millions of variables, routinely" in 2025.

::: notes
This is the slide that says "industrial SAT works because of engineering, not theory." None of these were known when Cook proved NP-completeness. The lesson for verification engineers: SAT solver choice matters less than you think for small problems; it can change the answer from "10 minutes" to "forever" on large ones. CaDiCaL and Kissat are current champions; CryptoMiniSat for crypto-heavy benchmarks.
:::

---

## SMT — SAT + theories

**SMT** = Satisfiability Modulo Theories.

Take a SAT solver. Bolt onto it a **theory solver** that can decide formulas over a specific structure (integers, reals, bit-vectors). When the SAT layer guesses a propositional assignment, the theory solver checks whether that assignment is consistent over the theory.

**DPLL(T) framework** (Ganzinger, Hagen, Nieuwenhuis, Oliveras, Tinelli, 2004):

```
SAT solver guesses literal assignments → theory solver checks consistency
                                       → if inconsistent, return T-conflict
                                       → SAT learns the negation of the
                                          inconsistent partial assignment
```

The SAT engine drives; the theories arbitrate.

::: notes
DPLL(T) is the architectural pattern of every modern SMT solver (Z3, CVC5, Yices, MathSAT). The point is: you don't need a new search algorithm for each theory; you reuse the SAT engine and add a theory-specific consistency check. This is what makes Z3 modular — it can handle LIA + BV + arrays + EUF all at once by combining theory solvers.
:::

---

## SMT-LIB: the standard input language

```smt2
(set-logic QF_LIA)               ; quantifier-free LIA
(declare-const x Int)            ; declare integer x
(declare-const y Int)
(assert (= (+ x y) 7))           ; x + y = 7
(assert (> x 0))                 ; x > 0
(assert (> y 0))                 ; y > 0
(check-sat)                      ; → sat
(get-model)                      ; → ((x 1) (y 6))   or similar
```

- `set-logic` declares which theories you'll use.
- `declare-const` introduces a free constant.
- `assert` adds a constraint.
- `check-sat` returns `sat`, `unsat`, or `unknown`.

::: notes
SMT-LIB is the lingua franca; every SMT solver in the last 15 years reads it. The `(set-logic …)` line is important — it tells the solver "use only LIA reasoning, don't try to be clever". Without it, Z3 picks a logic; sometimes the wrong one. Common logics: QF_LIA, QF_LRA, QF_BV, QF_UF, QF_AUFLIA. The "QF_" prefix means "quantifier-free" — much faster than the quantified variants.
:::

---

## Common Z3 logics worth knowing

| Logic | Theory | Common use |
|---|---|---|
| `QF_LIA` | Linear integer arithmetic | counter steps, loop bounds, simple invariants |
| `QF_LRA` | Linear real arithmetic | hybrid systems, neural network bounds |
| `QF_BV` | Bit vectors of fixed width | crypto, hardware, popcount |
| `QF_UF` | Uninterpreted functions | abstract data types, reasoning about opaque APIs |
| `QF_AUFLIA` | Arrays + uninterpreted functions + LIA | memory safety, heap reasoning |
| `LIA` | LIA + quantifiers | induction-style reasoning |
| `ALL` | "Z3, pick" | exploration; never for production |

::: notes
Pick the most restrictive logic that fits your problem; the solver will be faster. `QF_LIA` is what most Day 1 examples use. `QF_BV` is what Day 4's Cryptol/SAW work compiles to. `QF_AUFLIA` is what CBMC compiles to for memory-safety checks. The `ALL` logic is convenient for prototyping; never use it in production because the solver has to figure out what theories to bring in.
:::

---

## Z3 from Python (live demo)

```python
import z3

x = z3.Int("x")
y = z3.Int("y")
s = z3.Solver()
s.add(x + y == 7, x > 0, y > 0)
print(s.check())   # sat
print(s.model())   # [y = 1, x = 6]  (or similar)
```

The Python binding gives you:

- Same expressive power as SMT-LIB.
- Easy quantifier and array support.
- Iterative use (incremental solving with `push`/`pop`).
- Programmatic model extraction.

We'll run [`day01/examples/z3_smoke.py`](../examples/z3_smoke.py) live.

::: notes
The Python interface is what we'll use for the rest of the day. Open `examples/z3_smoke.py`, run it on screen, watch it print Z3 version + sat + model. Then `z3_pigeonhole.py`, watch all five cases come back unsat. Then the main event: `z3_counter_bounded.py`. The point is to physically demonstrate that Z3 is a couple of `pip install` commands away.
:::

---

## Live: pigeonhole in SAT

[`day01/examples/z3_pigeonhole.py`](../examples/z3_pigeonhole.py) — encode "$n+1$ pigeons into $n$ holes" as SAT.

```python
def pigeonhole(num_pigeons: int, num_holes: int):
    s = z3.Solver()
    p = [[z3.Bool(f"p_{i}_{j}") for j in range(num_holes)]
         for i in range(num_pigeons)]
    for i in range(num_pigeons):
        s.add(z3.Or(p[i]))                       # each pigeon in ≥ 1 hole
    for j in range(num_holes):
        for i1 in range(num_pigeons):
            for i2 in range(i1 + 1, num_pigeons):
                s.add(z3.Not(z3.And(p[i1][j], p[i2][j])))   # no sharing
    return s.check()                             # → unsat for all n ≥ 1
```

For $n = 1, 2, 3, 4, 5$: every answer is `unsat`. The pigeonhole principle, verified by machine.

::: notes
Pigeonhole is the classical SAT teaching example. Notice the structure: we encode the problem (each pigeon in some hole; no two pigeons in the same hole), call check-sat, and trust the verdict. The encoding is exactly what mathematics says; Z3 mechanizes the search. Industrial verification problems have the same structure, just at million-variable scale.
:::

---

## Bounded model checking: from SAT to system verification

The pattern for asking "can the counter reach $x = 11$ in $\le N$ steps?":

1. Introduce state variables for each step $k = 0, \dots, N$:
   $$\text{mode}_0, x_0, \text{mode}_1, x_1, \dots, \text{mode}_N, x_N$$
2. Assert the initial constraint: $\text{mode}_0 = \text{off} \wedge x_0 = 0$.
3. For each $k$, assert the transition relation: $T(\text{mode}_k, x_k, \text{press}_k, \text{mode}_{k+1}, x_{k+1})$.
4. Assert the property's negation at step $N$: $x_N = 11$.
5. `check-sat`. SAT $\Rightarrow$ counterexample of length $\le N$. UNSAT $\Rightarrow$ no counterexample of length $\le N$ (says nothing about longer paths).

::: notes
This is the BMC pattern, and it's the same pattern Day 4's CBMC implements on actual C code. The key insight: bounded model checking trades completeness for not needing to construct the state space. It's a refutation tool. If you want to *prove* the property, you need either an unbounded model checker (Day 2) or an inductive argument (Day 3).
:::

---

## Live: bounded counter in Z3

[`day01/examples/z3_counter_bounded.py`](../examples/z3_counter_bounded.py)

```python
def bounded_reach_to(forbidden_x: int, num_steps: int):
    s = z3.Solver()
    mode = [z3.Int(f"mode_{k}") for k in range(num_steps + 1)]
    x    = [z3.Int(f"x_{k}")    for k in range(num_steps + 1)]
    press = [z3.Bool(f"press_{k}") for k in range(num_steps)]

    s.add(mode[0] == MODE_OFF, x[0] == 0)
    for k in range(num_steps):
        s.add(step(mode[k], x[k], press[k], mode[k+1], x[k+1]))
    s.add(x[num_steps] == forbidden_x)
    return s.check()
```

For `forbidden_x = 11`: UNSAT for every bound we try (5, 10, 15, 20, 30).

::: notes
This is the headline demo of Day 1. Run it live; show all five bounds returning UNSAT. The point: bounded model checking *refutes* (no counterexample of length ≤ N) but does not *prove* (there might be one at N+1). Day 2's nuXmv lifts this restriction. Day 1's Z3 is the substrate. The same code structure scales — change "counter" to "TCP handshake" and you have a real-world BMC harness.
:::

---

## Bounded vs full verification — the gap

```
                 No counterexample
                       ↓
Bounded BMC (Day 1):    of length ≤ N      ← does not generalize to all N
Full model check (Day 2): ever              ← Day 2 closes this gap
Inductive proof (Day 3):  ever, by induction ← Day 3 also closes it
```

**Day 1 to Day 2:** lift "$\le N$ steps" to "all steps".

**Day 1 to Day 3:** drop the finite state requirement.

**Day 1 to Day 4:** apply the same idea to C source code.

::: notes
This is the conceptual ladder for the week. Day 1's bounded SMT is the simplest, most flexible, least powerful tool. Day 2 gets full reachability on finite systems. Day 3 gets inductive proofs on arbitrary structures. Day 4 brings the same engine back to actual code. Same triple (model, spec, proof); different power-vs-generality trade-off in each tool.
:::

---

## Poll: predict the verdict

For each, predict SAT / UNSAT *before* I run it.

1. `(check-sat)` with `(x + y = 7) ∧ (x > 0) ∧ (y > 0)` in LIA — single step.
2. The counter, asking "can $x = 11$ in $\le 5$ steps?"
3. The counter, asking "can $x = 10$ in $\le 11$ steps?"
4. The pigeonhole with 100 pigeons into 99 holes.
5. The counter, asking "can $\text{mode} = \text{on} \wedge x = 0$ in $\le 1$ step?"

Open Top Hat on screen. We'll run each.

::: notes
Expected: (1) SAT with model x=1, y=6 (or 2,5, etc); (2) UNSAT — counter can only increment x by 1 per step and needs to flip to on first, so x=11 unreachable; (3) SAT — 11 steps is enough (1 to flip on, 10 to count up); (4) UNSAT — pigeonhole at scale; (5) SAT — single press goes off→on with x unchanged. The point is to make participants *think* about the encoding before trusting the verdict.
:::

---

## L3 recap

- **SAT** = boolean satisfiability; NP-complete; industrially routine for $10^6$+ variables.
- **CDCL + watched literals + restarts** is what makes SAT solvers actually fast.
- **SMT** = SAT + decidable theories, via the DPLL(T) framework.
- **Z3** is the canonical SMT solver; SMT-LIB and Python both work.
- **Bounded model checking** is a one-pattern application: unroll the transition relation, assert bad-state at the end, check sat.
- BMC **refutes** counterexamples of length $\le N$. It does *not* prove the property.

::: notes
Block recap. The take-home from L3: Z3 + the bounded-reachability encoding is the workhorse pattern. Variations of this pattern run in CBMC, Cryptol, even Lean's `decide` tactic. Master it once today.
:::

---

# Wrap + post-session work {.section}

---

## Day 1 in one slide

- The bottleneck has flipped from production to validation; FM is the substrate.
- Every FM tool fits **(model, specification, proof)**.
- Logic gives us the language for specs; transition systems give us the model.
- SAT and SMT make logical questions about transition systems mechanically decidable.
- Bounded SAT refutes short counterexamples but does *not* prove safety; Day 2's nuXmv lifts that limit.

::: notes
Read this slide aloud as the closing summary. It's the throughline for the whole day.
:::

---

## Day 2 preview

- Same transition system. New tool: **nuXmv**.
- The bounded SMT formula we wrote today turns into an unrolling inside nuXmv's bounded model checker — but nuXmv *also* does full reachability via BDDs.
- **CTL and LTL** — temporal logic for properties that talk about "always", "eventually", "until".
- Live counterexamples on broken specifications.

::: notes
The bridge from Day 1 to Day 2 is "what if N could be infinity?" That's literally what model checking is. The cost is a stronger commitment to a finite state space; the payoff is "verified for all paths, not just $\le N$".
:::

---

## In-session exercise (15 min, your laptop)

Adapt [`day01/examples/z3_counter_bounded.py`](../examples/z3_counter_bounded.py):

1. **Find the smallest $N$ for which $x = 10$ is reachable.** Iterate from $N = 1$.
2. When you hit `sat`, ask Z3 for the model. Print the `press` sequence that gets $x = 10$.
3. Confirm the sequence makes sense by reading it off.

You should land on $N = 11$. The first press flips off → on; the next 10 are `press = False`, each incrementing $x$ by 1.

::: notes
A self-contained exercise that runs in the room. The deliverable is a model that you can read off and explain. If anyone finishes early, the bonus is: "modify the system to have two presses required to flip on, and find the new smallest N." Should be 12.
:::

---

## Homework (not graded; for depth)

Pick **one**:

**(a) Two-counter system.** Two counters $x$ and $y$, each independently bounded by 10. Each step, the system chooses which to increment. Verify `(x + y) ≤ 20` is reachable but not exceeded.

**(b) Traffic light.** Three states red/yellow/green. Bounded check that "green directly to red, skipping yellow" is *not* reachable in $\le 20$ steps.

**(c) Your own.** Any small reactive system: vending machine, turnstile, coffee maker. One safety property, encoded in Z3.

Submit (or just bring along to Day 2): the `.py` file, the verdicts at $N = 5, 10, 20$, and a one-paragraph note on what surprised you.

::: notes
Three tracks of identical pedagogical depth. (a) practices the encoding pattern with a small twist; (b) introduces an explicit state machine; (c) is open-ended. We'll informally compare results at the start of Day 2 — not graded, just shared.
:::

---

## References for Day 1

- **Cook, S.** *The complexity of theorem-proving procedures*. STOC 1971. The original SAT-is-NP-complete paper.
- **Davis, Logemann, Loveland.** *A machine program for theorem-proving*. CACM 1962. The DPLL paper.
- **de Moura, Bjørner.** *Z3: An efficient SMT solver*. TACAS 2008. The Z3 tool paper.
- **Plotkin.** *A structural approach to operational semantics*. JLAP 60–61 (2004). The transition-systems-as-the-substrate-of-everything paper.
- **Clarke, Henzinger, Veith, Bloem (eds.).** *Handbook of Model Checking*. Springer 2018. Chapters 1–3 cover today's material in depth.
- **Z3 Guide** (Microsoft): [microsoft.github.io/z3guide](https://microsoft.github.io/z3guide/) — interactive Z3 in the browser.

Full reference list at the end of the repo [README.md](../../README.md#background-references).

::: notes
References slide. Each one is on the curated repo-level reference list; we won't go through them in class. The Z3 Guide is the most useful single artifact for someone who wants to play more after class.
:::

---

## Next session: Day 2

GitHub repo: [github.com/ttj/fmaiv](https://github.com/ttj/fmaiv) (private; ask for access if you don't have it).

Slack / Discord / email for questions between sessions.

::: notes
Logistics. The repo has all of today's `.py` files, the slides, and the next session's pre-class materials. Day 2 opens with a short recap and a "did anyone get stuck on homework?" check-in, then dives into nuXmv.
:::
