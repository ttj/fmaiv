---
title: "Day 3 — Theorem Proving with Lean 4 (and AI)"
subtitle: "FMAIV: Formal Methods & AI-Assisted Verification"
author: "Taylor T. Johnson"
institute: "Vanderbilt University"
date: "Day 3 of 4"
---

# Day 3 — Theorem Proving {.title}

## Lean 4, inductive invariants, and AI-assisted proof {.section}

::: notes
Day 2's model checker enumerated the counter's finite reachable set and proved the invariant for all behaviors. Today we prove the same invariant a different way — by induction on the transition relation, in Lean 4 — and that method works where model checking can't: unbounded data, parametric systems, and genuine mathematics. We also use AI (Claude Code) as a proof-drafting partner, with the Lean kernel as the arbiter. Same counter, new kind of guarantee: a machine-checked proof term, not an enumeration.
:::

---

## Where we are

Day 2: nuXmv proved `AG (x ≤ 10)` by exploring **all reachable states** of a finite system.

That breaks down when:

- the state space is **infinite** (unbounded integers, reals, lists), or
- the system is **parametric** ("mutual exclusion for *all* `n` processes"), or
- the property is **mathematical** ("there are infinitely many primes").

**Today: prove properties by induction**, with no enumeration — so unbounded and parametric are fine.

::: notes
Honest framing of where model checking stops. Enumerating a finite reachable set is exactly the wrong tool for an infinite or parametric system. Theorem proving reasons symbolically by induction, so "for all n" and "over all integers" cost nothing extra. The price is interactivity: you guide the proof. The counter is finite (we could model-check it), but we use it to learn the inductive method on a system we already know is correct.
:::

---

## Today's roadmap

| Block | Topic |
|---|---|
| L1 | Why theorem proving; what Lean 4 is; the current moment |
| L2 | Lean by example: tactics, Mathlib, the counter, inductive invariants |
| L3 | AI in the proof loop; Lean's industrial role |

Running example: the same counter, now a Lean `TransitionSystem`.

::: notes
L1 motivates and introduces the language. L2 is hands-on Lean on the counter. L3 is the AI workflow and where Lean is used for real. The counter from Days 1-2 becomes a Lean structure with a machine-checked invariant proof.
:::

---

## Learning objectives for Day 3

By the end of today you will be able to:

- Explain why theorem proving complements model checking, and what each is for.
- Read and write basic Lean 4 — terms, types, `def`, `theorem`, core tactics.
- State a transition system and an invariant in Lean, and prove the invariant by the **inductive-invariant + strengthening** pattern.
- Use an AI assistant to draft proof steps, and recognize when it is wrong.

::: notes
Four objectives: the why (L1), the language (L1/L2), the proof pattern (L2), the AI workflow (L3). We revisit at the wrap.
:::

---

# L1 — Why proving, and what Lean is {.section}

::: notes
First block. Motivate theorem proving against the day-2 baseline, sketch the history so Lean doesn't seem to come from nowhere, convey why *now* is a turning point, then introduce Lean's core idea (propositions as types, proofs as terms).
:::

---

## What a theorem prover is

A **theorem prover** (proof assistant) is software that:

- lets you state definitions and theorems in a formal language, and
- checks a proof against a tiny, trusted **kernel** — every step is verified.

You write the proof (often interactively); the machine guarantees it is correct. No step is taken on faith.

::: notes
The defining feature is the trusted kernel: a small, auditable core that checks every inference. Everything else — tactics, automation, libraries, even AI suggestions — only proposes steps; the kernel decides. This is the "AI proposes, kernel disposes" architecture we keep returning to. A proof that the kernel accepts is correct in the strongest sense available in mathematics or engineering.
:::

---

## A very short history

Automath (1967) → LCF (1970s, "tactics") → HOL, Coq, Isabelle, Agda → **Lean** (2013, Lean 4 in 2021).

The field converged on **dependent type theory**: a single language where

- propositions *are* types, and
- proofs *are* terms (programs) of those types.

::: notes
Don't dwell, but place Lean in lineage. LCF introduced tactics (programs that build proofs). Coq/Isabelle/Agda matured dependent type theory and large libraries. Lean 4 (de Moura et al., now Lean FRO) is the current momentum leader, especially in mathematics, because of Mathlib and a fast, programmable implementation. Dependent type theory is the unifying idea — the next slide makes "propositions as types" concrete.
:::

---

## Propositions as types (Curry–Howard)

```lean
#check (5 : Nat)        -- 5 has type Nat
#check Nat              -- Nat has type Type
#check (5 = 5)          -- 5 = 5 has type Prop  (a proposition is a type)
#check (rfl : 5 = 5)    -- rfl is a *term* (proof) of that type
```

To prove `P` is to **construct a term of type `P`**. The kernel type-checks the term.

::: notes
This is the conceptual core. A proposition like 5 = 5 is a type; a proof of it is a term inhabiting that type (here, rfl, reflexivity). "Proving a theorem" and "writing a well-typed program" are the same activity (Curry-Howard). The kernel's job is ordinary type-checking. Mathematicians find this strange at first and then load-bearing: it is why a Lean proof is checkable by a tiny program.
:::

---

## `def`, `theorem`, `example`

```lean
def double (n : Nat) : Nat := n + n          -- a definition

theorem double_zero : double 0 = 0 := rfl     -- a proof term

example : 2 + 2 = 4 := by rfl                  -- anonymous; `by` enters tactic mode
```

Definitions and theorems are the **same kind of thing**: named terms with a type.

::: notes
def, theorem, and example share machinery — all are (optionally named) terms of a stated type. The `by` keyword enters *tactic mode*: instead of writing the proof term directly, you build it with tactics. Most real proofs use tactics because writing the raw term by hand is impractical. double_zero := rfl is a rare case simple enough to write directly.
:::

---

## Tactics: building the proof term

`by` opens a tactic block; each tactic transforms the **goal**.

```lean
example (p q : Prop) (hp : p) (hpq : p → q) : q := by
  exact hpq hp        -- close the goal with a term
```

The InfoView shows the current goal after each tactic, until "no goals."

::: notes
Tactics are programs that manipulate the proof state (hypotheses + goal). You watch the goal shrink in the InfoView as you apply tactics, until nothing remains. This interactive, stateful experience is what makes Lean usable — you are never staring at a blank page; you are transforming a concrete goal. This is also exactly the surface an AI assistant operates on: it reads the goal and proposes the next tactic.
:::

---

## The current Lean moment (1)

- **Polynomial Freiman–Ruzsa conjecture** — informal proof by Gowers, Green, Manners & Tao (Nov 2023); formalized in Lean in **~3 weeks** (completed Dec 2023) by a 20+-person collaboration led by Tao with Yael Dillies and Bhavik Mehta.
- **Mathlib** — the community math library, **~2M lines**, ~800 contributors.

::: notes
PFR is the cultural watershed: a recent research theorem formalized collaboratively in weeks, not years, because Lean's kernel let strangers compose work safely. Mathlib is the substrate — a ~2-million-line, continuously-checked library covering undergraduate-through-research mathematics. Together they show Lean is no longer a toy: it is where a growing slice of real mathematics is being made machine-checkable.
:::

---

## The current Lean moment (2)

- **AlphaProof + AlphaGeometry 2** (DeepMind, 2024) — **IMO 2024 silver-medal-equivalent** score (28/42); AlphaProof solved 3 problems with proofs generated and checked in Lean.
- **DeepSeek-Prover-V2** (671B, April 2025) — **88.9%** on miniF2F at a large pass@8192 budget (~82% at pass@32), the competition-Lean benchmark.

```
miniF2F-test SOTA (illustrative; sample budgets differ by year):
  2022 ~35%  →  2023 ~50%  →  2024 ~65-70%  →  2025 ~89%
```

::: notes
The AI side. AlphaProof (with AlphaGeometry 2) reached IMO silver-medal level, AlphaProof generating Lean proofs; DeepSeek-Prover-V2 pushed the standard Lean benchmark from ~35% to ~89% in roughly three years (the later figures use very large sample budgets, so read the curve as illustrative). This curve is why the course exists: AI can now draft formal proofs at a strong level, but every one is checked by the Lean kernel — the AI proposes, the kernel disposes. That combination is what makes AI-generated mathematics trustworthy.
:::

---

## Why mathematicians specifically

You already have the prerequisites CS undergrads spend two years acquiring: type discipline, induction, structural reasoning.

Three payoffs:

- **Research** — formalize your own results; catch your own errors.
- **Teaching** — Lean-graded problem sets that give real feedback.
- **Public good** — a checkable gate on AI-generated mathematics.

::: notes
For a math-faculty audience this is the "why you" slide. Mathematicians are unusually well-prepared for Lean — the hard part for CS students (rigorous induction, structural reasoning) is your daily bread. The payoffs are concrete: formalizing research (Tao's workflow), auto-graded Lean coursework, and — increasingly urgent — being able to verify AI-produced proofs rather than trust them.
:::

---

## L1 recap

- A **proof assistant** checks every step against a tiny trusted **kernel**.
- Lean 4 is **dependent type theory**: propositions are types, proofs are terms.
- **Tactics** build the proof term interactively by transforming the goal.
- The moment is real: PFR, Mathlib (2M+ lines), AlphaProof, DeepSeek-Prover.

::: notes
Block recap. Take-home: you understand what Lean is (kernel-checked type theory) and why now (AI + Mathlib). Next block: actually doing it on the counter.
:::

---

## ☕ Break {.section}

We resume after the break with Lean by example — tactics, Mathlib, and the counter.

---

# L2 — Lean by example: the counter {.section}

::: notes
Second block, the hands-on core. The workhorse tactics, how to find Mathlib lemmas, then the counter as a Lean transition system and the inductive-invariant proof we will actually run. This is where the abstract "propositions as types" becomes a concrete proof you can build.
:::

---

## The workhorse tactics

| Tactic | Use |
|---|---|
| `intro h` | move a hypothesis from goal into context |
| `exact e` | close the goal with term `e` |
| `rfl` | reflexivity (`a = a`) |
| `simp` | simplify with the simp-set |
| `omega` | decide linear arithmetic over `Nat`/`Int` |
| `cases h` / `rcases` | split a hypothesis (inductive, `∧`, `∨`, `∃`) |
| `by_cases h : P` | classical case split on `P` |
| `constructor` | prove an `∧`/structure by parts |

::: notes
These eight close the vast majority of goals you will meet today. omega is the star for the counter (all the arithmetic is linear over Nat). simp normalizes the if-then-else encoded transition relation. cases/by_cases drive the case analysis on mode/press/x. constructor splits the conjunctive invariant. Every one of these appears in CounterProofs.lean.
:::

---

## Finding lemmas in Mathlib

```lean
example (a b : Nat) : a + b = b + a := by exact?   -- suggests Nat.add_comm
```

- `exact?` / `apply?` — search Mathlib for a lemma matching the goal.
- `loogle` — search by type pattern.
- **Naming convention**: `Nat.add_comm`, `List.length_append` — namespace + what it says.

::: notes
The practical skill for a 2M-line library: you do not memorize lemmas, you search. exact?/apply? read the current goal and propose library lemmas that close it. The naming convention is the other half — once you internalize "namespace.subject_property," you can guess a lemma name and confirm with autocomplete. This is also where AI assistants shine: naming the right Mathlib lemma is something they do well.
:::

---

## A transition system, in Lean

From `CounterDemo/TransitionSystem.lean`:

```lean
structure TransitionSystem (State : Type) where
  init : State → Prop
  next : State → State → Prop

inductive Reachable {S} (ts : TransitionSystem S) : S → Prop where
  | init  : ts.init s → Reachable ts s
  | step  : Reachable ts s → ts.next s s' → Reachable ts s'

def Invariant {S} (ts) (P : S → Prop) : Prop :=
  ∀ s, Reachable ts s → P s
```

`Reachable` is an **inductive predicate** — the Lean version of "states reachable in finitely many steps."

::: notes
This is the Day-1 transition-system tuple, now as Lean definitions. Reachable is defined inductively: initial states are reachable, and a step from a reachable state is reachable. That inductive definition is what gives us an induction principle to prove invariants. Invariant P means P holds on every reachable state — the same notion nuXmv checked, but here we will prove it by induction rather than enumerate.
:::

---

## The inductive-invariant method

```lean
def InductiveInvariant {S} (ts) (P : S → Prop) : Prop :=
  (∀ s, ts.init s → P s) ∧                  -- holds initially
  (∀ s s', P s → ts.next s s' → P s')        -- preserved by every step

theorem inductive_invariant_holds :
  InductiveInvariant ts P → Invariant ts P
```

If `P` holds initially and every step preserves it, then `P` holds on **all** reachable states — proved once, for any system.

::: notes
This is the workhorse theorem and it is proved generically (by induction on Reachable) once in TransitionSystem.lean, then reused for every system. The two obligations — base case (init ⇒ P) and step case (P ∧ next ⇒ P) — are the entire method. Crucially this holds for any state type, finite or infinite, which is why the same method handles unbounded and parametric systems that model checking cannot.
:::

---

## The counter as a Lean system

From `CounterDemo/Counter.lean` (auto-translated from `counter.smv`):

```lean
inductive ModeVal | off | on
structure CounterState where
  mode : ModeVal ; press : Bool ; x : Nat

def CounterTS : TransitionSystem CounterState where
  init s := s.mode = .off ∧ s.x = 0
  next s s' := ∃ p', s'.press = p' ∧
    (if s.mode = .off ∧ s.press = false then s'.mode = .off
     else if ...) ∧ (if ... then s'.x = s.x + 1 else ...)
```

Same four guards as the SMV `next(...)` and the Z3 `step()`.

::: notes
The counter, fifth-ish encoding. Note the structure mirrors SMV exactly: init is the initial predicate, next is the transition relation with the same four guards. The ∃ p' encodes the nondeterministic press input (the SMV "free variable" idiom). This file is mechanically generated from counter.smv by a translator — emphasizing that the *same* model flows through every tool; only the syntax changes.
:::

---

## Single invariants aren't inductive

We want `x ≤ 10`. But `x ≤ 10` alone is **not** preserved by every step in isolation.

The fix: **strengthen** to a conjunction that *is* inductive:

$$\Phi(s) \equiv (s.x \le 10) \ \wedge\ (s.\text{mode} = \text{off} \to s.x = 0)$$

::: notes
This is the central insight of the day, foreshadowed all week. "x ≤ 10" is true of all reachable states but is not by-itself inductive: from an arbitrary state with x = 10 you cannot conclude the successor satisfies it without also knowing the mode/x relationship. The cure is strengthening — find a stronger Φ that IS inductive and implies what you want. Discovering the right strengthening is the creative core of invariant proofs (and exactly where AI help is hit-or-miss).
:::

---

## The proof, in three parts

```lean
theorem counterInv_init  : ∀ s, CounterTS.init s → counterInv s
theorem counterInv_step  : ∀ s s', counterInv s → CounterTS.next s s' → counterInv s'
theorem counterInv_inductive : InductiveInvariant CounterTS counterInv :=
  ⟨counterInv_init, counterInv_step⟩
```

1. holds initially, 2. preserved by every step, 3. bundle into `InductiveInvariant`.

::: notes
The proof skeleton. Part 1 (init) is trivial: the initial state has mode = off and x = 0, so both conjuncts hold. Part 2 (step) is the work — the case analysis. Part 3 just packages them. Then we read off the user-facing invariants by strengthening (next slides). This is the exact shape every safety proof of a transition system takes.
:::

---

## Walk-through: `counterInv_step` case split

```lean
theorem counterInv_step : ∀ s s', counterInv s → CounterTS.next s s' → counterInv s' := by
  intro s s' ⟨hx, hmode⟩ ⟨p', hp, hmode_next, hx_next⟩
  cases hm : s.mode with
  | off => ...                          -- from off: press? → on/off, x unchanged
  | on  =>
    by_cases hp : s.press = true
    · ...                               -- on + press → off, x := 0
    · by_cases hlt : s.x < 10
      · ...                             -- on, !press, x<10 → on, x := x+1
      · ...                             -- on, !press, x≥10 → off, x := 0
```

Each leaf: `simp [hm, ...]` to reduce the if-then-else, then `omega` for the arithmetic.

::: notes
The case analysis mirrors the four guards exactly: mode off vs on, then press vs not, then x<10 vs not. Each branch reduces (via simp on the controlling hypotheses) the if-then-else transition to a concrete equation for s'.mode and s'.x, and then omega discharges the arithmetic (e.g. x < 10 ⊢ x+1 ≤ 10). About 60 lines total. Bigger systems factor leaves into helper lemmas, but the shape never changes.
:::

---

## Strengthening: read off what you wanted

```lean
theorem CounterTS_inv1_proved : Invariant CounterTS (fun s => s.x ≤ 10) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.1)

theorem CounterTS_inv2_proved : Invariant CounterTS (fun s => s.mode = .off → s.x = 0) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.2)
```

The user-facing invariants are **one-line corollaries** of the strong invariant.

::: notes
Once Φ is proved inductive, every property it implies is a one-liner: invariant_strengthening takes the inductive Φ and a pointwise implication Φ ⇒ Ψ and gives Invariant Ψ. h.1 and h.2 just project the conjunction. This is the payoff of strengthening: do the hard inductive work once on Φ, then harvest all the individual specs cheaply. Compare to nuXmv, which checked each spec independently.
:::

---

## Checking it's really proved: no `sorry`

`lake build` **succeeds even with `sorry`** (it's a warning, not an error). To be sure a theorem is genuinely proved:

```lean
#print axioms CounterTS_inv1_proved
-- 'CounterTS_inv1_proved' depends on axioms: [propext, Quot.sound]
```

If `sorryAx` appears, the proof has a hole. (This is exactly what the Day-3 autograder checks.)

::: notes
Critical gotcha. A green build is NOT proof — Lean treats sorry as a warning so you can build work-in-progress. The real check is #print axioms: a finished proof depends only on Lean's standard axioms (propext, Quot.sound, sometimes Classical.choice). If sorryAx shows up, there is a hole. Our autograder runs exactly this check, because "lake build passed" would let a student submit a sorry-filled proof and get full marks.
:::

---

## L2 recap

- A handful of tactics (`intro`, `simp`, `omega`, `cases`, `constructor`) close most goals.
- Mathlib is searchable via `exact?`/`apply?` and naming conventions.
- The counter is a Lean `TransitionSystem`; prove invariants by **induction**.
- **Strengthen** to an inductive `Φ`, then read off each spec as a corollary.
- Verify with `#print axioms` — a build is not a proof.

::: notes
Block recap. Take-home: you can state a transition system in Lean and prove a safety invariant by the inductive + strengthening pattern, and you know how to confirm there are no holes. Next: the AI workflow and where Lean is used for real.
:::

---

## ☕ Break {.section}

We resume after the break with AI in the proof loop, and Lean in industry.

---

# L3 — AI in the loop + Lean for real {.section}

::: notes
Final block. The AI-assisted proof workflow (the headline of the course), an honest account of where AI helps and where it bluffs, and the industrial/research reality of Lean so students see this is not academic.
:::

---

## What's actually new

LLMs can now **draft tactic scripts** from a goal:

- Claude Code / Copilot in the editor — suggest the next tactic.
- AlphaProof, DeepSeek-Prover — generate whole Lean proofs.

The pattern, again: **AI proposes, the kernel disposes.** A wrong suggestion fails to type-check — it cannot corrupt a proof.

::: notes
The genuinely new capability is goal-conditioned proof drafting. The safety property is structural: anything the AI writes must pass the kernel, so a hallucinated step simply fails to compile. This is why Lean + AI is trustworthy in a way that, say, an LLM writing prose mathematics is not — the verification is mechanical and total.
:::

---

## Live demo: AI-assisted repair

1. Open `CounterProofs.lean`; weaken `counterInv` to drop the second conjunct.
2. `lake build` → `counterInv_step` now **fails** (the off-case can't close).
3. Ask Claude Code to repair it.
4. Read what it proposes — does it re-add the right conjunct, or hallucinate a tactic?

::: notes
The live demo. Breaking the strengthening (dropping the mode=off → x=0 conjunct) makes the step proof fail in the off branch, because you lose the fact that keeps x at 0. Asking the AI to fix it is instructive: a good model re-discovers that you need the dropped conjunct (i.e. it re-strengthens); a weaker attempt flails with tactic tweaks that don't address the missing invariant. Either way the kernel tells you immediately whether the suggestion works.
:::

---

## Where AI is reliable — and where it bluffs

| Reliable | Bluffs |
|---|---|
| explaining what `omega`/`simp` did | "prove this" with no context |
| naming a Mathlib lemma | long multi-file proofs |
| drafting a routine tactic block | inventing the right *strengthening* |
| generating a counterexample | "looks right" but `omega` won't close |

Treat suggestions as **drafts to read**, not finished proofs.

::: notes
An honest, calibrated account — this is what students most need. AI is genuinely good at local, well-scoped tasks (name a lemma, explain a tactic, draft a routine block) and unreliable at global, creative ones (find the right strengthened invariant, carry an invariant across many files). The failure mode to watch for is plausible-but-wrong: a proof that reads fine but the elaborator rejects, or worse, one that "works" by quietly weakening the statement. The kernel catches the former; only you catch the latter.
:::

---

## How to drive the AI well

1. **Give it context** — show your `TransitionSystem` and state definitions first.
2. **Ask for structure, not magic** — "suggest a strengthening that makes this inductive, with one-line justification."
3. **Paste the elaborator error back** — Lean's error says exactly where it failed.
4. **Iterate** — the AI usually fixes its own mistakes given the error; sometimes you step in.

::: notes
Practical workflow advice. The biggest lever is context: an AI given your actual definitions and the failing goal does far better than one asked to "prove the counter is safe." Asking for a strengthening + justification (rather than a finished proof) plays to its strengths. And the elaborator error is a tight feedback signal — pasting it back closes the loop fast. This is the human-in-the-loop pattern the whole course is teaching.
:::

---

## Lean in industry and research

- **PFR** (Tao et al.) and **Liquid Tensor Experiment** (Scholze/Commelin) — research math, formalized.
- **AWS Cedar** — the IAM policy language is **specified in Lean** (public repo); the spec is the source of truth.
- **DeepMind AlphaProof**; **Lean FRO** (funded nonprofit maintaining Lean).

::: notes
Lean is not just for olympiad problems. PFR and LTE are research-level mathematics formalized to settle correctness. AWS Cedar is the standout *engineering* use: a production access-control language whose semantics live in Lean, with properties (e.g. "deny overrides allow") proved — Lean as a spec language for shipped software, like Day 4's SAW/Cryptol but at the policy layer. The Lean FRO existing at all signals institutional seriousness.
:::

---

## Where Coq / Isabelle / Rocq still lead

Lean is ascendant in mathematics, but:

- **Iris / separation logic** (Coq) — concurrent program logics.
- **CompCert** (Coq) — the verified C compiler.
- **seL4** (Isabelle) — the verified microkernel.

Different tools, same kernel-checked guarantee. Pick by ecosystem.

::: notes
Intellectual honesty: Lean did not win everything. The largest verified-systems artifacts — CompCert (a C compiler proved semantically correct) and seL4 (an OS kernel proved correct down to C) — are in Coq and Isabelle, with decades of program-logic tooling (Iris). The takeaway is not "Lean is best" but "proof assistants are a mature family; choose by ecosystem and library." For mathematics and AI-assisted proof today, Lean; for verified low-level systems, Coq/Isabelle.
:::

---

## L3 recap

- AI can draft tactic scripts; the **kernel still arbitrates**.
- AI is reliable on local tasks, unreliable on global/creative ones — read every suggestion.
- Drive it with **context + structure + the elaborator error**.
- Lean is real: PFR, Mathlib, AWS Cedar, AlphaProof; Coq/Isabelle lead in verified systems.

::: notes
Block recap. Take-home: the AI-assisted proof loop is real and useful, with the kernel as the guarantee and you as the judge of the creative steps. Combined with L1 (what Lean is) and L2 (the inductive method), you can prove a transition-system invariant with AI help and know it's genuinely proved.
:::

---

# Wrap + work {.section}

---

## Day 3 in one slide

- A proof assistant checks every step against a tiny **kernel**.
- Prove invariants by **induction** — works for infinite/parametric systems model checking can't touch.
- **Strengthen** to an inductive `Φ`; read off each spec as a corollary; verify with `#print axioms`.
- AI **drafts**, the kernel **decides**, you **judge** the creative steps.

::: notes
The throughline. Day 2 enumerated; Day 3 proves by induction with a machine-checked certificate, AI-assisted. Read aloud as the close.
:::

---

## Day 4 preview

- Leave the abstract counter; bring everything to bear on **actual code**.
- **CBMC** — bounded model checking of C source (Day 1's idea, on real programs).
- **Cryptol + SAW** — bit-precise specs, proved equivalent to C implementations.
- Then the frontier: **neural-network verification** and industrial deployments.

::: notes
The bridge: Days 1-3 worked on models of the counter; Day 4 connects specs and proofs to real source code, and surveys where the field is going. The same counter appears one last time, in C and in Cryptol.
:::

---

## In-session exercise

In `examples/CounterDemo`:

1. `lake build`; confirm the five `sorry` warnings are only on the auto-generated stubs.
2. In `CounterProofs.lean`, find the three pieces of the inductive-invariant pattern.
3. Add and prove **one** new invariant — e.g. `x > 0 → mode = on` — via strengthening; confirm with `#print axioms`.

::: notes
Self-contained, runs in the room. The deliverable is one new proved invariant plus the axiom check confirming no sorry. x > 0 → mode = on is a good target: it follows from the strengthened Φ by a short case split. This exercises the whole pattern end to end.
:::

---

## Homework (ungraded, for depth)

Pick **one** (see [`assignments/day03.md`](../assignments/day03.md)):

- Prove the **combined** invariant `(x ≤ 10) ∧ (mode = off → x = 0) ∧ (x > 0 → mode = on)` is inductive.
- Change `count_max` to 25 and re-prove `CounterTS_inv1` (use Claude Code for the edits).
- Translate `traffic_light.smv` into Lean by hand and prove one invariant.

Use Claude Code as a partner; note one thing it got right and one it got wrong.

::: notes
Three tracks of escalating ambition. The third (translate-and-prove a fresh system) is the most realistic test of the whole skill. The "note one right / one wrong from the AI" requirement makes students practice the calibration we discussed — recognizing when to trust the assistant. Not graded; compare at the start of Day 4.
:::

---

## References for Day 3

- **Avigad, de Moura, Kong, Carneiro.** *Theorem Proving in Lean 4* — <https://leanprover.github.io/theorem_proving_in_lean4/>
- **Avigad.** *Mathematics and the formal turn*, Bull. AMS 2024.
- **Alper.** *Embracing AI and formalization*, Bull. AMS 2026.
- **Bayer et al.** *Mathematical Proof Between Generations*, Notices AMS 2024 (Buzzard on Lean).
- **AlphaProof** (DeepMind, 2024); **DeepSeek-Prover-V2** (2025).
- **Lean community** — <https://leanprover-community.github.io/> · Lean Game Server (Natural Number Game).

Full list: repo [README.md](../../README.md#background-references).

::: notes
Theorem Proving in Lean 4 is the canonical tutorial; the Natural Number Game is the gentlest on-ramp (browser, no install). The AMS pieces (Avigad, Alper, Bayer et al.) are the mathematician-facing motivation. Curated to what's worth a first read.
:::

---

## Next session: Day 4

Repo: [github.com/ttj/fmaiv](https://github.com/ttj/fmaiv) — the `CounterDemo` Lake project, slides, and the assignment.

::: notes
Day 4 opens with a recap and homework check-in, then CBMC on the counter in C, Cryptol/SAW, and the neural-verification frontier.
:::
