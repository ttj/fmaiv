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
| L2 | Lean by example: tactics, library search, the counter, inductive invariants |
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

Automath (1967) → LCF (1970s, "tactics") → HOL, Coq, Isabelle, Agda → **Lean** (2013; the Lean 4 rewrite began ~2021, first stable release 2023).

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

Read `e : T` as "`e` has type `T`". `Nat` = the naturals 0,1,2,…; `Type` = the type of ordinary data types; `Prop` = the type of propositions (things provable); `#check` just prints a term's type.

To prove `P` is to **construct a term of type `P`**. The kernel type-checks the term.

::: notes
This is the conceptual core. A proposition like 5 = 5 is a type; a proof of it is a term inhabiting that type (here, rfl, reflexivity). "Proving a theorem" and "writing a well-typed program" are the same activity (Curry-Howard). The kernel's job is ordinary type-checking. Mathematicians find this strange at first and then load-bearing: it is why a Lean proof is checkable by a tiny program.
:::

---

## Everything has a type — even types

In Lean, **every** expression has a type — and a type is itself an expression, so it has a type too:

```lean
#check (5 : Nat)     -- 5     : Nat
#check Nat           -- Nat   : Type      (a data type lives in `Type`)
#check Type          -- Type  : Type 1    (and `Type 1 : Type 2`, …)
#check (5 = 5)       -- Prop              (a proposition)
#check Prop          -- Prop  : Type      (propositions live in `Prop`)
```

So there are **three layers**: a *value* (`5`), its *type* (`Nat`), and the type's *type* (`Type`). Reading bottom-up: `5 : Nat : Type`.

::: notes
Beginners are unsettled that "types have types." Make it ordinary: in everyday math you don't usually ask "what kind of thing is the integers?" — Lean forces an answer, and the answer is `Type`. The three-layer ladder (value : type : universe) is the whole idea. We are NOT going to dwell on universe levels; the only takeaway is that the ladder never bottoms out, so `Type : Type` is avoided (it would be paradoxical) by an infinite tower `Type 0 : Type 1 : …`. They will never type a universe level by hand in this course.
:::

---

## `Sort`, `Prop`, `Type` — the universes

The types-of-types are called **universes**. Two matter to us:

| Universe | Holds | Example members |
|---|---|---|
| `Prop` | **propositions** (things to prove) | `5 = 5`, `x ≤ 10`, `p ∧ q` |
| `Type` (`= Type 0`) | ordinary **data types** | `Nat`, `Bool`, `CounterState` |

`Type 0 : Type 1 : Type 2 : …` is an infinite tower (so nothing contains itself). `Sort` is the umbrella word covering both (`Prop = Sort 0`, `Type u = Sort (u+1)`). (You will never need to manipulate universe levels in this course — skim this.)

The key asymmetry: in `Prop`, **all proofs of one proposition are interchangeable** — Lean's *definitional proof irrelevance* for `Prop` (any two proofs of the same proposition are treated as equal). We only care *that* it's proved, not *which* proof.

::: notes
One slide on universes, kept deliberately light. The single conceptual point worth carrying: `Prop` and `Type` are different universes for a reason — `Prop` is "proof-irrelevant" (any two proofs of the same proposition are treated as equal, because a proof is evidence, not data), whereas in `Type` two values of `Nat` like 3 and 4 are genuinely different data. That distinction is why `5 = 5` lives in `Prop` and `Nat` lives in `Type`. The `Sort u` umbrella and the universe tower are mentioned only so the words aren't mysterious if they appear in an error message; nobody in this audience needs to manipulate universe levels.
:::

---

## Function types, and *dependent* function types

A function type `A → B` is read "give me an `A`, get back a `B`":

```lean
#check (Nat.succ : Nat → Nat)          -- successor: a Nat in, a Nat out
#check (fun n => n + n : Nat → Nat)    -- `fun x => …` is an anonymous function
```

A **dependent** function type lets the *result type depend on the input value* — written `(n : A) → B n`:

```lean
-- `∀ n, 0 + n = n` is a dependent function type:
--   give it a Nat `n`, get back a PROOF of `0 + n = n` (a different proposition per n)
#check (zero_add : ∀ n : Nat, 0 + n = n)
```

So `∀` ("for all") is just a dependent function type whose outputs are **proofs**. That single idea is what makes "propositions as types" powerful enough for real math.

::: notes
This is the one genuinely new piece of type theory beyond "proposition = type": dependency. Ordinary `A → B` is what everyone knows. The leap is that the codomain can mention the argument — `(n : Nat) → (0 + n = n)` is a function that, given a specific n, returns a proof tailored to that n. Then the punchline: `∀ x, P x` IS exactly that dependent function type, and a proof of a `∀` is literally a function you can apply to a witness. This demystifies why, later, applying a proof of `∀ s, …` to a particular state `s` is just function application. Keep it gentle; the `(n : A) → B n` notation is the only new symbol.
:::

---

## Curry–Howard, in full: the logic ↔ types dictionary

Every logical connective is a **type constructor**; every proof is a **term** that builds or uses it:

| Logic | Type | To **prove** it… | To **use** it… |
|---|---|---|---|
| `P → Q` (implies) | function `P → Q` | write `fun (h : P) => …` | apply it: `h pq` |
| `P ∧ Q` (and) | pair `P × Q` | `⟨hp, hq⟩` (give both) | project: `h.1`, `h.2` |
| `P ∨ Q` (or) | tagged union | `Or.inl hp` / `Or.inr hq` | `cases` on which side |
| `∃ x, P x` (exists) | dependent pair | `⟨w, hw⟩` (witness + proof) | `obtain ⟨w, hw⟩ := h` |
| `¬ P` (not) | `P → False` | assume `P`, derive `False` | feed it a `P` to get `False` |
| `True` | one-element type | `trivial` | — |
| `False` | empty type | (impossible) | `absurd` — anything follows |

A proof is a *program*; running the logic is *type-checking the program*.

::: notes
The full dictionary, the heart of the L1 deepening. Walk a few rows aloud. Implication is the deepest one for beginners: "to prove P implies Q is to write a function turning a proof of P into a proof of Q," and "to use such a proof is to apply it" — that's modus ponens as function application, which the existing tactic slide already hinted at with `exact hpq hp`. ∧ is a pair (`⟨_, _⟩` builds it, `.1/.2` take it apart — exactly the anonymous-constructor and projections the counter proof uses). ∃ is a dependent pair: a witness PLUS a proof about it. ¬P as `P → False` explains why proof-by-contradiction is "assume P, manufacture False." `False` is the empty type, so a proof of it would let you build anything (the principle of explosion / `absurd`). Every notation here recurs in Counter.lean, so this table is also a forward reference.
:::

---

## A tiny term-mode proof of each connective

No tactics — just *build the term* the dictionary prescribes. The slogan "proofs **are** programs" is *literal*:

```lean
-- the simplest proof there is: P → P is the identity function
example (p : Prop) : p → p :=
  fun hp => hp                          -- given a proof of p, hand it straight back

-- implication in general: still a function (this one ignores its 2nd input)
example (p q : Prop) : p → (q → p) :=
  fun hp => fun _ => hp                 -- given p (and anything), return the p

-- and: a pair (anonymous constructor ⟨ ⟩)
example (p q : Prop) (hp : p) (hq : q) : p ∧ q :=
  ⟨hp, hq⟩

-- or: pick a side
example (p q : Prop) (hp : p) : p ∨ q :=
  Or.inl hp                            -- "left" injection

-- exists: witness + proof
example : ∃ n : Nat, n + 1 = 4 :=
  ⟨3, rfl⟩                              -- witness 3; rfl proves 3 + 1 = 4
```

These compile with **no Mathlib** — the connectives are core Lean.

::: notes
Make the dictionary concrete with four-line term-mode proofs, so students see that "a proof is a term" is literal, not metaphor. The first is the **identity** (`fun hp => hp`) — the proof of `p → p` literally *is* `id`. The second is the classic `p → q → p` (constant function), `fun hp => fun _ => hp`. The ∧ proof is the anonymous constructor `⟨hp, hq⟩` they'll see packaging `counterInv_inductive`. The ∃ proof `⟨3, rfl⟩` is the witness-plus-evidence shape. Emphasize: these are term mode (no `by`), to reinforce that tactic mode is just a convenient way to *generate* terms like these. All core Lean — reassure the Mathlib-free audience.
:::

---

## What the kernel actually checks

Everything reduces to **type-checking one term**:

- Tactics, `simp`, `omega`, library lemmas, even an AI — all only *produce* a candidate proof **term**.
- The **kernel** re-checks that term against the theorem's type, from scratch, with a small fixed set of rules.
- It is tiny, rarely changed, and the **only** thing you must trust.

So a 2-million-line library and an LLM are *equally untrusted*: whatever they emit, the kernel re-derives it.

::: notes
The deck repeats "the kernel checks every step" but never says how — this says how (grounded in TPiL). The kernel does one job: type-check the final proof term (β/δ/ι-reduction up to definitional equality). Tactics and automation are elaborate term *generators*; none is trusted. This is the architectural reason AI-assisted proof is safe: a hallucinated step yields a term the kernel rejects. It's also why proofs can be checked in parallel and why "trust" is concentrated in a few thousand lines, not millions. (The one exception is `native_decide`, which also trusts the compiler — flag it when it appears.)
:::

---

## What "re-check from scratch" means

A traditional math proof "conveys a message" — peer review checks the *ideas*, and the fiddly steps are "too cumbersome" to verify line by line. Lean is the opposite: **every** step must exist as a term, and the kernel re-derives all of them.

```lean
theorem two_plus_two : 2 + 2 = 4 := by
  rfl                                  -- tactic mode: short to WRITE
-- but what the kernel RECEIVES and re-checks is a finished term:
#print two_plus_two
-- theorem two_plus_two : 2 + 2 = 4 := Eq.refl (2 + 2)   (roughly)
```

You wrote one tactic; the kernel checked a concrete term (`Eq.refl (2 + 2)`) and confirmed both sides really compute to `4`. The tactic was just a *convenient way to produce* that term — it earns no trust of its own.

::: notes
Grounds the "re-checked from scratch" claim in something students can see, and ties directly to the transcript: math proofs are informal and "some of the formal details are too cumbersome to check," whereas in a theorem prover "all of that reasoning would have to exist." `#print` reveals the term behind a tactic proof — here `rfl` elaborates to roughly `Eq.refl (2 + 2)`, and the kernel verifies that `2 + 2` and `4` are definitionally equal (both reduce to 4). The pedagogical beat: the thing you TYPE (a tactic script) and the thing the kernel CHECKS (a proof term) are different artifacts; the script's only job is to build the term, and if it builds a bad term the kernel says no. This is the concrete version of "AI proposes, kernel disposes."
:::

---

## `def`, `theorem`, `example`

```lean
def double (n : Nat) : Nat := n + n          -- a definition

theorem double_zero : double 0 = 0 := rfl     -- a proof term

example : 2 + 2 = 4 := by rfl                  -- anonymous; `by` enters tactic mode
```

Definitions and theorems are the **same kind of thing**: named terms with a type.

- `rfl` = **reflexivity**: proves an equation that holds *by computation* — both sides reduce to the same value (here `double 0` → `0` and `2 + 2` → `4`).

::: notes
def, theorem, and example share machinery — all are (optionally named) terms of a stated type. The `by` keyword enters *tactic mode*: instead of writing the proof term directly, you build it with tactics. Most real proofs use tactics because writing the raw term by hand is impractical. double_zero := rfl is a rare case simple enough to write directly.
:::

---

## `rfl` computes; `induction` reasons

`rfl` succeeds when both sides reduce to the *same* value — **definitional equality**:

```lean
example : 2 + 2 = 4 := by rfl            -- both sides compute to 4
example (n : Nat) : n + 0 = n := by rfl  -- ✓  (+ recurses on its 2nd argument)
```

But `0 + n = n` is **not** `rfl` — `n` is a variable on the recursing side, so it needs **induction**:

```lean
theorem zero_add (n : Nat) : 0 + n = n := by
  induction n with
  | zero      => rfl                      -- base:  0 + 0 = 0
  | succ k ih => rw [Nat.add_succ, ih]  -- step:  ih : 0 + k = k  ⊢  0 + (k+1) = k+1
```

::: notes
The single most illuminating contrast for a beginner, straight from Theorem Proving in Lean 4. `rfl` is not magic equality — it succeeds exactly when Lean can *compute* both sides to the same normal form (definitional equality). `n + 0 = n` holds by `rfl` because Nat addition recurses on its *second* argument, so `n + 0` reduces to `n`. But `0 + n = n` does NOT compute (the variable `n` is on the recursing side), so it needs induction: prove it at 0, then assume it at k (the induction hypothesis `ih`) and push to k+1. Same-looking statements, different proofs — this is "how Lean works" in one slide, and it's why the counter's step proof is an induction, not an `rfl`.
:::

---

## Induction, the way you already know it

The pen-and-paper recipe for "**P** holds for *all* naturals `n`":

- **Base case** — prove `P(0)`.
- **Inductive step** — *assume* `P(k)` (the **induction hypothesis**), prove `P(k+1)`.

Classic example: $0 + 1 + \dots + n = \dfrac{n(n+1)}{2}$.

- Base $n=0$: left side $=0$, right side $=\frac{0\cdot 1}{2}=0$. ✓
- Step: assume $0+\dots+k=\frac{k(k+1)}{2}$ (the **IH**); then
$$0+\dots+k+(k{+}1)=\underbrace{\tfrac{k(k+1)}{2}}_{\text{by IH}}+(k{+}1)=\tfrac{(k+1)(k+2)}{2}.\ \checkmark$$

<svg viewBox="0 0 720 150" style="display:block;margin:0.3em auto;max-width:86%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs><marker id="ind-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6.5" markerHeight="6.5" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/></marker></defs>
  <line x1="104" y1="78" x2="130" y2="78" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ind-ah)"/>
  <line x1="214" y1="78" x2="240" y2="78" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ind-ah)"/>
  <line x1="324" y1="78" x2="350" y2="78" stroke="#5b6168" stroke-width="1.8" stroke-dasharray="5 4" marker-end="url(#ind-ah)"/>
  <line x1="374" y1="78" x2="398" y2="78" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ind-ah)"/>
  <line x1="482" y1="78" x2="558" y2="78" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ind-ah)"/>
  <text x="520" y="124" text-anchor="middle" font-size="11.5" fill="#146a96">IH: P(k) ⟹ P(k+1)</text>
  <rect x="22" y="56" width="82" height="44" rx="9" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="63" y="83" text-anchor="middle" font-size="14" fill="#1c1c1c">P(0)</text>
  <text x="63" y="124" text-anchor="middle" font-size="11.5" fill="#8a6d2f">base case</text>
  <rect x="132" y="56" width="82" height="44" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="173" y="83" text-anchor="middle" font-size="14" fill="#1c1c1c">P(1)</text>
  <rect x="242" y="56" width="82" height="44" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="283" y="83" text-anchor="middle" font-size="14" fill="#1c1c1c">P(2)</text>
  <text x="362" y="84" text-anchor="middle" font-size="18" fill="#5b6168">⋯</text>
  <rect x="400" y="56" width="82" height="44" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="441" y="83" text-anchor="middle" font-size="14" fill="#1c1c1c">P(k)</text>
  <rect x="560" y="56" width="92" height="44" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="606" y="83" text-anchor="middle" font-size="14" fill="#1c1c1c">P(k+1)</text>
</svg>

::: notes
Ground induction in exactly our recap example before showing it in Lean, so the Lean version feels like a transcription, not a new idea. Read the dominoes metaphor aloud: base case = knock over the first domino; inductive step = guarantee each domino knocks the next; conclusion = all fall. The IH is the phrase to land — "assume it for k" is not circular, it's the engine. The sum formula is the canonical instance and it's in the lecture; we do the algebra on the slide so the audience sees the IH actually getting *used* (the underbrace). The figure is the base/step + IH diagram the brief requests.
:::

---

## The same induction, in Lean (from scratch)

```lean
theorem zero_add (n : Nat) : 0 + n = n := by
  induction n with
  | zero =>
    -- BASE.   goal:  ⊢ 0 + 0 = 0
    rfl                              -- both sides compute to 0
  | succ k ih =>
    -- STEP.   ih : 0 + k = k        (the induction hypothesis!)
    --         goal:  ⊢ 0 + (k + 1) = k + 1
    rw [Nat.add_succ]               -- 0 + (k+1)  ↦  (0 + k) + 1
    -- now goal:  ⊢ (0 + k) + 1 = k + 1
    rw [ih]                         -- rewrite 0 + k  ↦  k  using the IH
    -- now goal:  ⊢ k + 1 = k + 1   — true by rfl, rw closes it automatically
```

`induction n` splits into the two ways a `Nat` is built: `zero`, and `succ k` (= `k+1`) **plus** the hypothesis `ih` for `k`. `Nat.add_succ` and `rw` are **core** Lean — no Mathlib.

These snippets (and the term-mode proofs earlier) are collected, compiled, and checked in [`SlideExamples.lean`](https://github.com/ttj/fmaiv/blob/main/day03/examples/CounterDemo/CounterDemo/SlideExamples.lean).

::: notes
The from-scratch induction walkthrough the brief asks for, with the goal state annotated at every line so students watch the IH appear and get consumed. The crucial moment is `| succ k ih =>`: Lean hands you `k`, the goal at `k+1`, AND `ih : 0 + k = k` for free — that `ih` is the induction hypothesis, materialized as a named hypothesis you can `rw` with. The two rewrites are the whole proof: unfold `add_succ` to expose `0 + k`, then rewrite by the IH. End by noting `rw` auto-closes a goal that becomes `x = x`. Everything is core Lean — repeat for the Mathlib-free audience. This is the template the counter's reachability induction follows.
:::

---

## Why `succ k ih` has that shape

`induction` gives one case per **constructor** of the type, and a hypothesis for each recursive argument:

```lean
inductive Nat where
  | zero : Nat            -- ⟶ case `zero`  (no IH: nothing recursive)
  | succ (k : Nat) : Nat  -- ⟶ case `succ k ih`  (IH because `k : Nat` is recursive)
```

The induction principle is *generated from the type's definition*. That's the bridge to the counter: because `Reachable` is an **inductive** predicate (next block), it comes with its own induction principle — and that principle is exactly what proves an invariant.

::: notes
Demystify where `zero` / `succ k ih` come from: they are not magic tactic names, they are read straight off `Nat`'s two constructors. `zero` is non-recursive so it gets no IH; `succ` takes a `Nat` argument (recursive) so that argument's case carries an IH. State the general rule once — "one case per constructor, an IH per recursive field" — because it's the rule that will explain the shape of the `Reachable` induction (init case vs. step case) when we hit the inductive-invariant theorem. This is the conceptual hinge between the Nat warm-up and the real proof.
:::

---

## Tactics: building the proof term

`by` opens a tactic block; each tactic transforms the **goal state** — the hypotheses, a turnstile `⊢`, and the target to prove.

```lean
example (p q : Prop) (hp : p) (hpq : p → q) : q := by
  -- goal state:   hp : p,  hpq : p → q   ⊢   q
  exact hpq hp        -- applies hpq to hp — this is modus ponens; "no goals"
```

The InfoView (Lean's live panel) shows this state after each tactic, until "no goals." Read `⊢ q` as "we still must prove `q`"; applying a proof of `p → q` to a proof of `p` *is* function application.

- Editor setup: install the **Lean 4 VS Code extension** (`leanprover.lean4`) for this live InfoView, and keep **Claude Code** open in the same window (integrated terminal or a side panel) — goal state and AI partner side by side.

::: notes
Tactics are programs that manipulate the proof state (hypotheses + goal). You watch the goal shrink in the InfoView as you apply tactics, until nothing remains. This interactive, stateful experience is what makes Lean usable — you are never staring at a blank page; you are transforming a concrete goal. This is also exactly the surface an AI assistant operates on: it reads the goal and proposes the next tactic.
:::

---

## Reading a goal state (the `⊢` turnstile)

The InfoView shows, at every moment: the **hypotheses** (what you know) above a line, the **turnstile** `⊢`, and the **goal** (what's left to prove):

```text
p q : Prop          -- two propositions are in scope
hp : p              -- we have a proof of p, named hp
hpq : p → q         -- we have a proof of p → q, named hpq
⊢ q                 -- GOAL: we still must prove q
```

- Read `⊢ q` as "**turnstile** q" = "under the hypotheses above, prove `q`."
- Each tactic *rewrites this whole picture*. The proof is done when the goal becomes **"no goals."**

A tactic either **closes** the goal, **transforms** it, or **splits** it into several subgoals (each with its own `⊢`).

::: notes
Spend real time here — reading the goal state is THE core skill, and the deck never explicitly decodes the turnstile. The mental model: above the line is your toolbox (named hypotheses), below is the job. Three things a tactic can do — close (zero goals left), transform (same goal, different shape, e.g. `simp`), or split (several new goals, e.g. `cases` or `constructor`). When several goals are open you work them one at a time; the `·` bullet or `<;>` combinator manage that. Everything else today is just watching this picture evolve.
:::

---

## Proof-state evolution, step by step

Watch the state change as each tactic fires:

```lean
example (p q : Prop) (hpq : p → q) (hp : p) : q := by
  -- ⊢ q                      (hyps: hpq : p → q,  hp : p)
  apply hpq
  -- ⊢ p                      (apply turned goal q into its premise p)
  exact hp
  -- no goals                 ✓ done
```

| After tactic | Goal | Why it changed |
|---|---|---|
| *(start)* | `⊢ q` | the theorem's claim |
| `apply hpq` | `⊢ p` | to get `q` via `p → q`, now prove `p` |
| `exact hp` | *no goals* | `hp` is exactly a proof of `p` |

<svg viewBox="0 0 760 180" style="display:block;margin:0.3em auto;max-width:92%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs><marker id="ps-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6.5" markerHeight="6.5" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/></marker></defs>
  <line x1="234" y1="92" x2="284" y2="92" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ps-ah)"/>
  <text x="259" y="82" text-anchor="middle" font-size="11" fill="#146a96">apply hpq</text>
  <line x1="506" y1="92" x2="556" y2="92" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ps-ah)"/>
  <text x="531" y="82" text-anchor="middle" font-size="11" fill="#146a96">exact hp</text>
  <rect x="18" y="32" width="216" height="120" rx="9" fill="#f6f8fa" stroke="#9aa3ab" stroke-width="1.6"/>
  <text x="34" y="58" font-size="12.5" fill="#1c1c1c" font-family="JetBrains Mono, monospace">hp  : p</text>
  <text x="34" y="80" font-size="12.5" fill="#1c1c1c" font-family="JetBrains Mono, monospace">hpq : p → q</text>
  <line x1="30" y1="94" x2="222" y2="94" stroke="#cdd5db" stroke-width="1.2"/>
  <text x="34" y="120" font-size="13" fill="#146a96" font-family="JetBrains Mono, monospace">⊢ q</text>
  <rect x="290" y="32" width="216" height="120" rx="9" fill="#f6f8fa" stroke="#9aa3ab" stroke-width="1.6"/>
  <text x="306" y="58" font-size="12.5" fill="#1c1c1c" font-family="JetBrains Mono, monospace">hp  : p</text>
  <text x="306" y="80" font-size="12.5" fill="#1c1c1c" font-family="JetBrains Mono, monospace">hpq : p → q</text>
  <line x1="302" y1="94" x2="494" y2="94" stroke="#cdd5db" stroke-width="1.2"/>
  <text x="306" y="120" font-size="13" fill="#146a96" font-family="JetBrains Mono, monospace">⊢ p</text>
  <rect x="562" y="32" width="184" height="120" rx="9" fill="#eef7ee" stroke="#27843f" stroke-width="1.8"/>
  <text x="654" y="98" text-anchor="middle" font-size="14" fill="#1e6b32">no goals ✓</text>
</svg>

::: notes
This is the proof-state-evolution diagram the brief asks for, rendered first as code + table so it reads even before the figure exists. The key teaching move: `apply hpq` does *backward* reasoning — "I want `q`; `hpq` produces `q` from `p`; so it suffices to prove `p`," and the goal literally becomes `⊢ p`. Then `exact hp` matches. Contrast with the earlier slide's `exact hpq hp`, which does it in ONE forward step — same proof term, two ways to drive there. Beginners find `apply` (work backward from the goal) more intuitive than composing the term forward, so showing both is worth it.
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
These eight close the vast majority of goals you will meet today. omega is the star for the counter (all the arithmetic is linear over Nat). simp normalizes the if-then-else encoded transition relation. cases/by_cases drive the case analysis on mode/press/x. constructor splits the conjunctive invariant. Every one of these appears in Counter.lean.
:::

---

## More tactics you'll meet in the files

The example files use a few beyond the workhorse set — terse meanings:

| Tactic | What it does |
|---|---|
| `induction h with \| …` | prove a goal by cases on how `h` was built; the recursive case gets an **induction hypothesis** |
| `rw [h]` | rewrite the goal left-to-right using an equation `h : a = b` |
| `subst h` | use `h : a = b` to replace `a` by `b` everywhere |
| `refine ⟨?_, ?_⟩` | like `exact`, but leave holes `?_` to fill as new goals |
| `obtain ⟨a, b⟩ := h` | destructure an `∧` / `∃` / structure into named pieces |
| `decide` | close a *decidable* goal by computing the answer (e.g. `off ≠ on`) |
| `native_decide` | `decide` compiled to native code — faster, but adds a compiler-trust axiom |
| `absurd h hn` | derive anything from contradictory `h : P` and `hn : ¬P` |
| `t <;> s` | run tactic `s` on **every** subgoal that `t` produced |

::: notes
These are the tactics a student meets the moment they open Counter.lean / TransitionSystem.lean / Gcd.lean, so each gets a one-line gloss (our explicit request). induction is the engine — it's how inductive_invariant_holds is proved. refine/obtain/⟨⟩ (de)construct conjunctions and existentials. decide/native_decide compute decidable facts; native_decide is the one tactic that *enlarges* the trusted base (it trusts the compiler), so mention that caveat. `<;>` is the "do the same thing to all cases" combinator that collapses the four counter branches into one line.
:::

---

## "Batteries-included": `decide` and `Decidable`

Some propositions can be **settled by computation** — Lean has an algorithm that returns `true`/`false`. Those are **`Decidable`**, and `decide` just runs the algorithm:

```lean
example : (2 + 2 = 4) := by decide        -- compute: yes
example : (3 < 10)    := by decide        -- compute: yes
example : ModeVal.off ≠ ModeVal.on := by decide   -- compare constructors: yes
example : ∀ n, n < 5 → n < 100 := by decide       -- ✗ can't: range of n is infinite
```

- A goal is `decide`-able only when the search is **finite** (equality of concrete values, small bounded checks). "For all naturals" is *not* finite, so `decide` declines.
- `decide` is **core** Lean — no Mathlib. The kernel re-runs the computation, so it stays trusted (unlike `native_decide`, which compiles it and trusts the compiler).

::: notes
"Batteries-included automation" framing the brief wants. The concept under `decide` is `Decidable`: a proposition for which Lean can mechanically compute a yes/no. Concrete-value equalities (`2+2=4`), strict inequalities on literals (`3<10`), and constructor disequality (`off ≠ on`, used in the counter) are all decidable — `decide` evaluates and produces the proof. The boundary is finiteness: the moment a quantifier ranges over infinitely many naturals, there's no algorithm to run, so `decide` fails and you need induction/`omega`. Reiterate the trust caveat: plain `decide` is kernel-rechecked and safe; `native_decide` is the same idea compiled for speed but it bolts the compiler onto the trusted base — only reach for it when `decide` is too slow.
:::

---

## `omega`: the linear-arithmetic workhorse

`omega` is a **decision procedure** for linear arithmetic over `Nat`/`Int` — it *decides* goals built from `+`, `-`, `≤`, `<`, `=` and integer constants, with no lemmas from you:

```lean
example (x : Nat) (h : x < 10) : x + 1 ≤ 10 := by omega   -- ✓
example (a b : Nat) (h : a + b = 10) (hb : b ≤ 3) : 7 ≤ a := by omega   -- ✓
example (x : Nat) : x * x ≥ 0 := by omega   -- ✗ `x*x` is NON-linear — omega declines
```

- **Linear** = variables only added/subtracted and compared, never multiplied together. `x + 1`, `2*x` are fine; `x*y` is not.
- `omega` is **core** Lean. It closes essentially *every* arithmetic leaf in the counter proof — e.g. from `x < 10` conclude `x + 1 ≤ 10`.

::: notes
`omega` earns its own slide because it does the heavy lifting in the counter and it's the cleanest example of "automation you can lean on without understanding its internals." The one literacy point: linear vs. non-linear. omega is complete for *linear* integer/Nat arithmetic (Presburger arithmetic) — give it any tangle of `+ - ≤ < =` over Nat/Int and it decides, including using hypotheses in context. It cannot do genuine multiplication of variables (`x*y`, `x²`), which is undecidable in general — so `x*x ≥ 0` is out (even though true). Tie it to the proof: every counter leaf ends in `omega` because each guard reduces to a linear fact like `x < 10 ⊢ x+1 ≤ 10`. Core Lean, no Mathlib.
:::

---

## Finding lemmas (library search)

```lean
example (a b : Nat) : a + b = b + a := by exact?   -- suggests Nat.add_comm
```

- `exact?` / `apply?` — **core Lean** tactics; they search every *imported* declaration for a lemma that closes/advances the goal.
- **Naming convention**: `Nat.add_comm`, `List.length_append` — namespace + what it says.
- `#loogle` / the Loogle website search by *type pattern* (a separate tool, not a tactic).

Our `CounterDemo` project is **Mathlib-free**, so `exact?` searches Lean's *core* library (where `Nat.add_comm` lives). Big math projects add **Mathlib** (~2M lines) for everything else.

::: notes
The practical skill for a big library: you do not memorize lemmas, you search. exact?/apply? are core Lean tactics (no Mathlib needed) that read the current goal and propose imported lemmas that close it — here Nat.add_comm, which is in core. The naming convention is the other half — once you internalize "namespace.subject_property," you can guess a name and confirm with autocomplete. Important for this course: the autograder project imports no Mathlib, so only core lemmas + your own are in scope; you'd add Mathlib in a larger project. loogle is a type-pattern search engine (web + a #loogle command), not a bare tactic. AI assistants are genuinely good at naming the right lemma.
:::

---

## Inductive types: data built one way at a time

An **inductive type** lists the *only* ways to construct its values (its **constructors**). You've already seen one — `Nat` is `zero` and `succ`:

```lean
inductive ModeVal | off | on          -- exactly two values; nothing else
inductive Bool    | false | true      -- the same shape
```

The payoff: because the constructors are the *complete* list, Lean derives a matching **induction / recursion principle** automatically — "to handle any value, handle each constructor." That principle is what `cases` and `induction` run on.

```lean
example (m : ModeVal) : m = .off ∨ m = .on := by
  cases m              -- splits into the off case and the on case — no others possible
  · exact Or.inl rfl
  · exact Or.inr rfl
```

::: notes
Inductive types are the one structural idea the counter rests on, so give them a slide before `Reachable` arrives. The mental model: an inductive declaration is an *exhaustive* recipe list — `ModeVal` is off or on and there is no third option, which is precisely why `cases m` produces exactly two subgoals and why the proof is complete after handling both. Connect back: `Nat` from the induction slides is the same machinery with a recursive constructor. The deep point — "Lean auto-generates the induction principle from the constructor list" — is what makes the next slide's `Reachable` immediately give us a proof method. Don't define "recursor" formally; "the induction principle Lean builds for you" is enough for this audience.
:::

---

## The recursor: an induction principle per type

For every inductive type, Lean generates a **recursor** (`.rec`) — the formal statement of its induction principle. You rarely call it directly; `induction`/`cases` use it under the hood.

```lean
#check @Nat.rec
-- to prove `motive n` for all n, supply:
--   • a proof of `motive 0`                       (base case)
--   • for each k, `motive k → motive (k+1)`        (step, given the IH)
```

So `induction n` is just `Nat.rec` with the base case and step filled in — *exactly* the base/step recipe from the warm-up. **Key idea:** define a thing inductively and you get its proof-by-induction principle **for free**.

::: notes
Name the recursor so the word isn't mysterious if it surfaces, but keep it light. The single takeaway: `Nat.rec` is the machine form of "prove P(0), prove P(k)⟹P(k+1)" — the dominoes slide, formalized — and the `induction` tactic is sugar over it. The `motive` is just "the property you're proving, as a function of the value." Why this matters NOW: it sets up the argument that `Reachable`, being inductive, automatically yields a principle whose two cases are "init states satisfy P" and "a step preserves P" — i.e. the inductive-invariant method is literally `Reachable.rec`. We won't prove that on a slide, but students should feel it's not a coincidence.
:::

---

## A transition system, in Lean

From [`CounterDemo/TransitionSystem.lean`](https://github.com/ttj/fmaiv/blob/main/day03/examples/CounterDemo/CounterDemo/TransitionSystem.lean):

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

`structure` bundles named fields (a record); `inductive` defines a type by listing the only ways to build its values; `→` is "function / implies"; `∀ s` is "for all states `s`". (Snippets elide some explicit type binders — see the file.)

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

## Why those two obligations? `Reachable`'s induction

`Reachable` was defined with **two constructors** — so its induction principle has **two cases**, and they *are* the two proof obligations:

```lean
inductive Reachable (ts) : S → Prop where
  | init : ts.init s → Reachable ts s              -- ⟶ base case
  | step : Reachable ts s → ts.next s s' → Reachable ts s'  -- ⟶ step case (with IH)
```

To prove `∀ s, Reachable ts s → P s`, run `induction` on the `Reachable` proof:

- **`init` case** — `s` is initial ⟹ show `P s`. *(This is the base obligation.)*
- **`step` case** — `s'` follows a step from a reachable `s`, with **IH** `P s` ⟹ show `P s'`. *(This is the step obligation.)*

That's it — the method isn't a separate trick, it's the recursor of `Reachable`. Finite or infinite state space, the induction is the same.

::: notes
This is the conceptual capstone of the bridge built over the last several slides: the inductive-invariant method is not an axiom we postulate, it's what falls out of `induction` on the `Reachable` proof, because `Reachable` has exactly two constructors. The `init` constructor becomes the base obligation (initial states satisfy P); the `step` constructor — which recursively references a `Reachable` proof — becomes the step obligation and *hands you the IH* `P s` for the predecessor, exactly like `succ k ih` handed you `ih`. So `inductive_invariant_holds` is proved once by `induction` on Reachable, and the two halves of `InductiveInvariant` are precisely the two cases. Emphasize the independence from state-space size: nothing here counts states, so infinite/parametric systems cost nothing — the payoff promised on the opening "Where we are" slide.
:::

---

## The counter as a Lean system

From [`CounterDemo/Counter.lean`](https://github.com/ttj/fmaiv/blob/main/day03/examples/CounterDemo/CounterDemo/Counter.lean) (auto-translated from [`counter.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/counter.smv)):

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

($\Phi$ — capital "phi" — names the strengthened invariant; $\equiv$ means "is defined as"; $\wedge$ is "and".)

::: notes
This is the central insight of the day, foreshadowed all week. "x ≤ 10" is true of all reachable states but is not by-itself inductive: from an arbitrary state with x = 10 you cannot conclude the successor satisfies it without also knowing the mode/x relationship. The cure is strengthening — find a stronger Φ that IS inductive and implies what you want. Discovering the right strengthening is the creative core of invariant proofs (and exactly where AI help is hit-or-miss).
:::

---

## Why a too-weak invariant fails (worked)

A cleaner illustration. Two counters: `x` starts 0 and counts **up**, `y` starts `m` and counts **down**, in lockstep:

```text
init:  x = 0,  y = m
step:  if x < m then  x := x + 1 ;  y := y − 1
```

Claim: `0 ≤ y ≤ m` is an invariant. **Try to prove it inductive — and watch it fail:**

- Step case: assume only `0 ≤ y ≤ m`. Take a state with `y = 0` but (say) `x = 0`. The guard `x < m` is **enabled**, so we step: `y := y − 1` → `y` underflows below 0. ✗ *so `0 ≤ y ≤ m` fails to be **inductive**.*
- The catch: that state (`x = 0, y = 0` with `m > 0`) is **not actually reachable** — so `0 ≤ y ≤ m` really *is* an invariant; it just isn't inductive. The weak invariant can't *see* unreachability: it never tied `x` and `y` together.

::: notes
This is our two-variable example from the lecture, and it's pedagogically sharper than the counter for *seeing* why strengthening is needed, because the failure is a concrete underflow rather than an abstract gap. Walk it slowly: with only `0 ≤ y ≤ m` in hand, the inductive step must cope with ANY state satisfying it — including the bogus `x=0, y=0` state — and there the decrement breaks the bound. The whole point (straight from the transcript): the proof fails on an UNREACHABLE state, because the invariant didn't capture the relationship between the variables. Model checking would never visit that state; induction, reasoning locally about one step, has no such protection unless we encode the relationship. Sets up the fix on the next slide.
:::

---

## The fix: strengthen with the missing relationship

The repair I use: add the conserved quantity the program maintains — **`x + y = m`**:

$$\Psi(s)\ \equiv\ (0 \le y \le m)\ \wedge\ (x + y = m)$$

($\Psi$ — capital "psi" — the strengthened invariant; it **implies** the original `0 ≤ y ≤ m`.)

Now the step case goes through: if `x < m`, then since `x + y = m` we get `y ≥ 1`, so `y − 1 ≥ 0` — no underflow. The conjunct we added is exactly the fact that rules out the bogus state.

**General proof rule** (sound, but *incomplete* — you must find $\Psi$ yourself):

> To prove $\Phi$ is an invariant: find $\Psi$ with $\Psi \Rightarrow \Phi$, and show $\Psi$ is **inductive**. The strongest possible $\Psi$ is "the reachable states themselves."

::: notes
The payoff half of the worked example, again from the transcript. The added conjunct `x + y = m` is a *conserved quantity* (an "energy" the loop preserves) — and it's precisely the relationship whose absence let the proof fail. With it, `x < m` plus `x + y = m` forces `y ≥ 1`, so the decrement is safe; the bad state `x=0,y=0` is excluded because it violates `x+y=m`. Then state the general rule I give: strengthening is SOUND (if you find a Ψ⟹Φ that's inductive, Φ really is invariant) but INCOMPLETE in the sense that finding Ψ is on you — there's no algorithm, though the strongest valid Ψ is always "the exact reachable set." This is the same shape as the counter's Φ, and the reason the next slides' creative step (and the AI's hit-or-miss help) matters.
:::

---

## The proof, in three parts

```lean
theorem counterInv_init  : ∀ s, CounterTS.init s → counterInv s
theorem counterInv_step  : ∀ s s', counterInv s → CounterTS.next s s' → counterInv s'
theorem counterInv_inductive : InductiveInvariant CounterTS counterInv :=
  ⟨counterInv_init, counterInv_step⟩
```

1. holds initially, 2. preserved by every step, 3. bundle into `InductiveInvariant` (the `⟨…, …⟩` is Lean's *anonymous constructor* — here it packages the two proofs into the `∧`).

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

## One leaf, fully worked: `on, ¬press, x < 10`

Take the branch where `mode = on`, the button is **not** pressed, and `x < 10`. The counter ticks: `x := x + 1`, mode stays `on`. We must re-establish $\Phi(s') = (s'.x \le 10) \wedge (s'.\text{mode} = \text{off} \to s'.x = 0)$.

```lean
· -- context here:
  --   hx    : s.x ≤ 10                       (from Φ s)
  --   hmode : s.mode = .off → s.x = 0        (from Φ s)
  --   hm    : s.mode = .on                   (this branch)
  --   hp    : ¬ (s.press = true)             (this branch)
  --   hlt   : s.x < 10                       (this branch)
  --   hx_next, hmode_next : s'.mode/s'.x via the if-then-else
  simp [hm, hp, hlt] at hx_next hmode_next
  -- simp used the three guards to collapse the if-then-else:
  --   hx_next    : s'.x = s.x + 1
  --   hmode_next : s'.mode = .on
  refine ⟨?_, ?_⟩          -- split Φ s' into its two conjuncts
  · omega                  -- ⊢ s'.x ≤ 10 :  from s'.x = s.x+1 and s.x < 10  ✓
  · intro hoff             -- ⊢ s'.mode = .off → s'.x = 0
    simp [hmode_next] at hoff   -- hoff : .on = .off — impossible, closes goal
```

::: notes
The fully-worked leaf the brief asks for — the `on / ¬press / x<10` case, annotated so students see exactly how `simp` then `omega` discharge it. Beat by beat: (1) the context shows the two inherited conjuncts of Φ s plus the three branch facts; (2) `simp [hm, hp, hlt]` feeds the guards INTO the transition's if-then-else so it reduces to concrete equations `s'.x = s.x+1`, `s'.mode = .on` — this is the "simp normalizes the encoded transition" claim made concrete; (3) `refine ⟨?_, ?_⟩` splits the goal Φ s' into two subgoals; (4) first conjunct `s'.x ≤ 10` is pure linear arithmetic from `s'.x = s.x+1` and `s.x < 10`, so `omega`; (5) second conjunct is vacuous because `s'.mode = .on`, so the antecedent `s'.mode = .off` is `.on = .off`, which `simp` refutes. This single leaf is the whole method in miniature; the other three leaves differ only in which guard reduces and whether the off-implication is vacuous or forces x=0.
:::

---

## Why one blanket tactic is *not* enough

Tempting: split all the cases, then close them uniformly —

```lean
  cases hm : s.mode <;> by_cases hpr : s.press = true <;>
    by_cases hlt : s.x < 10 <;> simp_all <;> omega   -- ✗ doesn't close every leaf
```

`t <;> s` runs `s` on **every** subgoal `t` produced — perfect for the shared work. But the leaves are **not** uniform:

- **on-branches** end in *arithmetic* (`x < 10 ⊢ x + 1 ≤ 10`) — `omega` closes these.
- **off-branches** end in a *constructor fact* (the goal reduces to `on ≠ off`) — not arithmetic, so `omega` fails; you need `decide` / `absurd`.

So the shipped proof closes each leaf with the *right* tool — `simp` + `omega` on the counting leaves, `absurd … (by decide)` on the impossible-mode leaves — rather than one blanket tactic.

::: notes
A deliberately honest slide. The `<;>` combinator collapses the *shared* work, but a single `simp_all <;> omega` does NOT finish the proof — omega even prints a counterexample on the off-mode leaves, because their goal is a constructor disequality (`on ≠ off`), not an arithmetic fact. That's exactly why the shipped counterInv_step in Counter.lean closes the impossible-mode leaves with `absurd … (by decide)` and the counting leaves with `omega`. Teaching point: match the closer to the goal's *kind* — arithmetic → omega, decidable equality → decide. This is also where an AI assistant bluffs: it'll happily propose a tidy one-liner the elaborator (Lean's engine that turns your tactic script into a proof term) then rejects (ties to L3).
:::

---

## The same proof, as a tree

<svg viewBox="0 0 880 372" style="display:block;margin:0.3em auto;max-width:94%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs>
    <marker id="pt-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6.5" markerHeight="6.5" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/>
    </marker>
  </defs>
  <line x1="395" y1="60" x2="150" y2="116" stroke="#5b6168" stroke-width="1.6" marker-end="url(#pt-ah)"/>
  <text x="238" y="84" text-anchor="middle" font-size="12.5" fill="#146a96">mode = off</text>
  <line x1="448" y1="60" x2="578" y2="98" stroke="#5b6168" stroke-width="1.6" marker-end="url(#pt-ah)"/>
  <text x="540" y="78" text-anchor="middle" font-size="12.5" fill="#146a96">mode = on</text>
  <line x1="568" y1="140" x2="430" y2="213" stroke="#5b6168" stroke-width="1.6" marker-end="url(#pt-ah)"/>
  <text x="470" y="172" text-anchor="middle" font-size="12.5" fill="#146a96">press</text>
  <line x1="612" y1="140" x2="690" y2="203" stroke="#5b6168" stroke-width="1.6" marker-end="url(#pt-ah)"/>
  <text x="676" y="172" text-anchor="middle" font-size="12.5" fill="#146a96">¬press</text>
  <line x1="688" y1="245" x2="612" y2="310" stroke="#5b6168" stroke-width="1.6" marker-end="url(#pt-ah)"/>
  <text x="618" y="284" text-anchor="middle" font-size="12.5" fill="#146a96">x &lt; 10</text>
  <line x1="715" y1="245" x2="792" y2="310" stroke="#5b6168" stroke-width="1.6" marker-end="url(#pt-ah)"/>
  <text x="772" y="284" text-anchor="middle" font-size="12.5" fill="#146a96">x ≥ 10</text>
  <rect x="345" y="18" width="158" height="42" rx="9" fill="#f6f8fa" stroke="#5b6168" stroke-width="1.8"/>
  <text x="424" y="44" text-anchor="middle" font-size="14" fill="#1c1c1c">counterInv s′ ?</text>
  <rect x="50" y="116" width="150" height="42" rx="9" fill="#eef7ee" stroke="#27843f" stroke-width="2"/>
  <text x="125" y="142" text-anchor="middle" font-size="12.5" fill="#1e6b32">x unchanged ✓</text>
  <rect x="528" y="98" width="120" height="42" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="588" y="124" text-anchor="middle" font-size="14" fill="#1c1c1c">mode = on</text>
  <rect x="345" y="213" width="150" height="42" rx="9" fill="#eef7ee" stroke="#27843f" stroke-width="2"/>
  <text x="420" y="239" text-anchor="middle" font-size="12.5" fill="#1e6b32">x := 0 ✓</text>
  <rect x="648" y="203" width="104" height="42" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="700" y="229" text-anchor="middle" font-size="14" fill="#1c1c1c">¬press</text>
  <rect x="512" y="310" width="178" height="42" rx="9" fill="#eef7ee" stroke="#27843f" stroke-width="2"/>
  <text x="601" y="336" text-anchor="middle" font-size="12" fill="#1e6b32">x := x+1 ≤ 10 ✓ omega</text>
  <rect x="730" y="310" width="130" height="42" rx="9" fill="#eef7ee" stroke="#27843f" stroke-width="2"/>
  <text x="795" y="336" text-anchor="middle" font-size="12.5" fill="#1e6b32">x := 0 ✓</text>
</svg>

Three nested case splits (mode → press → `x < 10`); each of the four leaves closes by `simp` + `omega`. `cases … <;> simp … <;> omega` collapses the whole tree into a couple of lines.

::: notes
The exact structure of `counterInv_step`, drawn. This is the "proof tree" view: the root is the goal (the invariant holds in the successor), each branch is a `cases`/`by_cases` split on a guard, and each green leaf is a closed subgoal. Mapping it back to the four SMV/Z3 guards makes the proof feel inevitable rather than mysterious — and shows why the `<;>` combinator is so useful: it applies the same closer (`simp` then `omega`) to every leaf at once.
:::

---

## Strengthening: read off what you wanted

```lean
theorem CounterTS_inv1_proved : Invariant CounterTS (fun s => s.x ≤ 10) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.1)

theorem CounterTS_inv2_proved : Invariant CounterTS (fun s => s.mode = .off → s.x = 0) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.2)
```

The user-facing invariants are **one-line corollaries** of the strong invariant. (`fun _ h => h.1` is an anonymous function that projects the first half of the `∧`; `h.2` takes the second.)

::: notes
Once Φ is proved inductive, every property it implies is a one-liner: invariant_strengthening takes the inductive Φ and a pointwise implication Φ ⇒ Ψ and gives Invariant Ψ. h.1 and h.2 just project the conjunction. This is the payoff of strengthening: do the hard inductive work once on Φ, then harvest all the individual specs cheaply. Compare to nuXmv, which checked each spec independently.
:::

---

## Checking it's really proved: no `sorry`

`lake build` **succeeds even with `sorry`** (it's a warning, not an error). To be sure a theorem is genuinely proved:

```lean
#print axioms CounterTS_inv1_proved
-- 'CounterTS_inv1_proved' depends on axioms: [propext, Quot.sound, Classical.choice]
```

Those three — `propext`, `Quot.sound`, `Classical.choice` — are the standard Lean axioms; seeing only them is the healthy result. If `sorryAx` appears, the proof has a hole. (This is exactly what the Day-3 autograder checks.)

::: notes
Critical gotcha. A green build is NOT proof — Lean treats sorry as a warning so you can build work-in-progress. The real check is #print axioms: a finished proof depends only on Lean's standard axioms (propext, Quot.sound, sometimes Classical.choice). If sorryAx shows up, there is a hole. Our autograder runs exactly this check, because "lake build passed" would let a student submit a sorry-filled proof and get full marks.
:::

---

## Beyond safety: termination via ranking functions

Safety = "nothing bad happens" (what we just proved). **Liveness** = "something good *eventually* happens" — proved with a **ranking function**: a `Nat`-valued measure that strictly *decreases* every step.

```lean
-- Gcd.lean: Euclid's algorithm terminates because (a + b) strictly drops
def gcd (a b : Nat) : Nat := ...
  termination_by a + b      -- the measure that must shrink
  decreasing_by omega       -- proof that it shrinks on each recursive call
```

A measure bounded below by 0 can't decrease forever ⇒ the loop must stop. (This is the discrete cousin of a Lyapunov function.)

::: notes
The example project ships ranking-function machinery (TransitionSystem.lean's IsRankingFunction; Gcd.lean's terminating Euclid) but no slide mentions it — this closes that gap and rounds out the safety-vs-liveness story from Day 2. `termination_by` names the measure; `decreasing_by` proves it drops; because Nat is well-founded (no infinite descending chain), termination follows. The same idea proves *progress*/liveness of a reactive system: exhibit a measure that strictly decreases until the good thing happens.
:::

---

## A second worked invariant: GCD correctness

Euclid's algorithm subtracts the smaller from the larger until they meet:

```text
init:  x := m,  y := n
step:  while x > 0 ∧ y > 0:  if x > y then x := x − y  else  y := y − x
```

What makes it *correct*? The **conserved quantity**: `gcd(x, y)` never changes across a step.

$$\text{Inv}(x,y)\ \equiv\ \gcd(x, y) = \gcd(m, n)$$

This is an **inductive** invariant: `gcd(x−y, y) = gcd(x, y)` (and symmetrically), so each step preserves it. When the loop ends (one variable hits 0), `gcd(x,0)=x` reads off the answer. Same recipe as the counter — find the relationship the program *maintains*, prove it's preserved.

::: notes
I close the inductive-invariants lecture on exactly this GCD example, so include it as a second, non-counter instance — and note it's the *invariant* (correctness) angle, complementary to the previous slide's *termination* (ranking-function) angle on the very same algorithm. The core lesson, in the transcript's words: even though x and y change every step, the running gcd stays fixed, and that conserved quantity IS the inductive invariant — it "captures the core logic of the program." This reinforces the strengthening mindset (find the maintained relationship) on a system students recognize as genuinely useful, and it pairs naturally with the termination slide: invariant ⇒ partial correctness, ranking function ⇒ termination, together ⇒ total correctness.
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

## Two kinds of prover: automated vs. interactive

The lecture draws the line we've been living on both sides of:

| | **Automated** (ATP / SMT) | **Interactive** (ITP) |
|---|---|---|
| Input | a formula | a theorem **+ a proof script** |
| You do | press the button | guide the proof |
| Output | yes / no / *time-out* | a checked **proof** (or failure) |
| Logic | mostly first-order, decidable fragments | higher-order, full dependent types |
| Examples | nuXmv, Z3 (Days 1–2) | Lean, Coq, Isabelle, PVS |

- **Automation buys ease; expressiveness costs interaction.** Some specs (e.g. CompCert's compiler-correctness) simply *can't be stated* in the first-order language an SMT solver decides — you need the higher-order logic of an ITP.
- The deep asymmetry behind all of it: **finding a proof is hard; checking one is easy.**

::: notes
This is the SMT-vs-ITP contrast the brief asks for, framed exactly as I frame it across the Q&A and history transcripts. The table is the whole idea: an automated prover (SMT solver like Z3 under nuXmv) takes a formula and pushes a button, but is confined to decidable, mostly first-order fragments and may time out; an interactive prover takes a theorem AND your proof and checks it, at the price of your effort, but can express higher-order/dependent statements. The transcript's expressiveness point is the load-bearing one: things like CompCert's translation-correctness "can't necessarily be specified in first-order logic," which is *why* ITPs exist despite being harder. And the line that makes AI relevant — "finding proofs is hard, checking them is easy" — is the asymmetry the next slide builds the AI landscape on.
:::

---

## The AI-proving landscape

Because checking is cheap, the field has thrown search and learning at the *hard* half — finding proofs:

- **Classic ATP / benchmarks** — TPTP problem sets; "Formalizing 100 Theorems"; competitions long predate LLMs.
- **LLMs for math** — Minerva (Google, quantitative reasoning), tool-augmented models (LLM + Wolfram/SMT), and Gowers' "automatic theorem proving project" all asked: can models *find* proofs?
- **Neural provers in Lean** — AlphaProof (IMO-silver level), DeepSeek-Prover-V2 (≈89% on miniF2F) — generate Lean scripts, then the **kernel checks every one**.
- **Programs, not just papers** — DARPA's **PROVERS** program targets affordable formally-verified software at scale.

The unifying bet: let AI *search* for the proof, let the *kernel* certify it. Hard-to-find, easy-to-check is the ideal shape for an AI + verifier loop.

::: notes
The AI-proving landscape the brief requests, assembled from the transcript's own references (TPTP, Formalizing 100 Theorems, Minerva, MathPrompter/tool-use, Gowers' project, DARPA PROVERS — I name all of these) plus the two flagship Lean systems the existing deck already cites. Organize it as a progression: symbolic ATP and benchmarks (pre-LLM), then LLMs aimed at math, then neural provers that specifically emit *Lean* and get kernel-checked, then the engineering push (PROVERS) toward verified software at scale. The thesis to land — and it's the course's whole premise — is that the proof-search/proof-check asymmetry makes formal math the *ideal* arena for AI: a domain where a fallible generator is made trustworthy by an infallible checker. This is "AI proposes, kernel disposes" at field scale.
:::

---

## Live demo: AI-assisted repair

1. Open [`Counter.lean`](https://github.com/ttj/fmaiv/blob/main/day03/examples/CounterDemo/CounterDemo/Counter.lean); weaken `counterInv` to drop the second conjunct.
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

1. `lake build` — the solution files compile clean (no `sorry`); open a `*Starter.lean` to see the fill-in-the-blank `sorry` holes you'd complete.
2. In [`Counter.lean`](https://github.com/ttj/fmaiv/blob/main/day03/examples/CounterDemo/CounterDemo/Counter.lean), find the three pieces of the inductive-invariant pattern (`counterInv_init`, `counterInv_step`, `counterInv_inductive`).
3. Prove **one** new corollary from the strengthened `Φ` — e.g. `mode = off → x < 10` — via `invariant_strengthening`, and confirm with `#print axioms` (no `sorryAx`).

::: notes
Self-contained, runs in the room. The deliverable is one new proved corollary plus the axiom check confirming no sorry. The solution files (imported by the root `CounterDemo.lean`) are sorry-free; the `*Starter.lean` scaffolds hold the holes. `Counter.lean` already proves x ≤ 10, mode = off → x = 0, AND x > 0 → mode = on, so pick a genuinely new target like `mode = off → x < 10` (immediate from the second conjunct + omega) to practice the strengthening pattern end to end.
:::

---

## Homework (ungraded, for depth)

Pick **one** (see [`assignments/day03.md`](../assignments/day03.md)):

- Prove the **combined** invariant `(x ≤ 10) ∧ (mode = off → x = 0) ∧ (x > 0 → mode = on)` is inductive.
- Change the bound `10` to `25` (it appears in the `next` guards and in `counterInv`) and re-prove `CounterTS_inv1` (use Claude Code for the edits).
- Translate [`traffic_light.smv`](https://github.com/ttj/fmaiv/blob/main/day02/examples/traffic_light.smv) into Lean by hand and prove one invariant.

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
