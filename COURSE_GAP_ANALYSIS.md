# FMAIV — Course Gap Analysis & Remaining Suggestions

*Synthesis of a deep, parallel comparison of FMAIV against ~20 external courses, summer schools, and tutorials (full annotated list in [`references/EXTERNAL_RESOURCES.md`](references/EXTERNAL_RESOURCES.md)). Four independent analyses were run in parallel — (1) model-checking/SMT university courses, (2) proof/deductive/type-theory courses, (3) FM summer schools, (4) tool tutorials + NN-verification + AI×FM. This file records what they found, what I already implemented, and what's left for your call.*

*Companion to [`COURSE_TOPIC_GRAPH.md`](COURSE_TOPIC_GRAPH.md) (topic-dependency graph) and [`references/EXTERNAL_RESOURCES.md`](references/EXTERNAL_RESOURCES.md) (annotated source list).*

---

## TL;DR

The single biggest finding is **structural, not a missing topic**: FMAIV teaches SAT/SMT (Day 1) and interactive proof (Day 3) but never connected them to *program* proofs via the **invariant-based deductive paradigm** — the style most working engineers mean by "verifying my code." Five of six reference courses teach it. **I implemented that bridge** (Day 4 deductive-verification slide). The second structural finding: the course's own AI thesis lacked a **measurement** story — **I added** the bidirectional AI×FM taxonomy + benchmark culture. Everything else below is genuine value but is FM-core curriculum/pacing — your call.

---

## TIER 1 — Implemented overnight (done, pushed)

| Addition | Where | Flagged by |
|---|---|---|
| **Deductive-verification bridge** — Hoare triples, loop invariants, partial-vs-total correctness, "specify → SMT discharges" (Dafny/Verus/Frama-C/Why3/Viper) | Day 4, after CBMC | analyses 1, 2, 3 (the most-corroborated gap) |
| **Bidirectional AI×FM taxonomy + benchmark culture** — FM-for-AI vs AI-for-FM; LeanDojo/ReProver, Lean Copilot, AlphaProof, autoformalization; miniF2F/ProofNet/PutnamBench/VERINA/SV-COMP/VNN-COMP | Day 4, "Where FM meets AI" | analyses 3, 4 |
| Economics + emerging-trends motivation (Glasswing, Erdős, NVIDIA SLM, oracles) | Day 1 | your talks + news |
| NN-verification frontier (verify-ChatGPT, SLM targets, NLP/guardrails/VLAs, neuro-symbolic) | Day 4 | your talks |

---

## TIER 2 — Recommended, high value (your call — FM-core/pedagogy)

1. **k-induction + IC3/PDR on Day 2** *(analysis 1).* FMAIV's symbolic-MC story stops at BDD/BMC — exactly where modern engines begin. One slide: "BMC made complete" → k-induction, then name IC3/PDR as what nuXmv actually runs. Prevents the misconception that BMC is the state of the art. *Your domain — you'll know the right depth for a no-background crowd.*
2. **A fuller AI+FM *evaluation* segment** *(analyses 3, 4).* I added the benchmark line, but Marktoberdorf 2026 devotes a whole lecture to *evaluating* agentic AI (Mitchell) — the highest-leverage gap relative to your own thesis. Consider a short "how do we measure AI-generated proofs/code?" treatment: pass@k on proof obligations, kernel-checked acceptance rate, hallucinated-lemma detection.
3. **"Inductive invariant" as a unifying concept** *(analysis 1).* One Day 1→Day 2 hinge slide: a safety proof = find an inductive invariant; SAT/SMT *checks* it, model checking *finds* it, a loop invariant *is* one. Ties the whole transition-systems thread together (and now connects cleanly to the new deductive-verification slide).
4. **NN completeness↔scalability spectrum** *(analysis 4).* Reframe Day 4's NN tool names as one axis: IBP → CROWN (incomplete, fast) → β-CROWN/MILP branch-and-bound (complete) → Reluplex/Marabou (SMT). Your existing "two solver families" slide is close; this sharpens it into the field's actual organizing axis.
5. **Entailment-by-negation as the Day 1 hands-on centerpiece** *(analysis 4).* The SMT Beginner's Tutorial opens with Socrates: assert ¬φ, get UNSAT ⇒ entailed. This single example *is* "verification = check the negation is unsatisfiable" and motivates the entire field in one runnable demo. (Your triple table already states it; the suggestion is to make it the live demo's spine.)

---

## TIER 3 — Pedagogy refinements (cheap, optional)

- **Curry-Howard / natural-deduction framing slide on Day 3** *(analysis 2):* "a tactic builds a proof term; a proof term is a program" — demystifies Lean tactics for beginners instead of presenting them as opaque commands. (From CMU 15-317's "harmony" angle.)
- **MiL-style live `sorry`-filling induction** *(analysis 2):* convert the core Lean demo to one small theorem with the goal window visible, walked tactic-by-tactic — depth over a shallow tactic tour. (Mathematics-in-Lean pedagogy.)
- **UNSAT cores + a proof certificate on Day 1** *(analysis 4):* `get-unsat-core` / `get-proof`, show the proof tree. Makes "AI proposes, kernel disposes" tangible at the solver level; the idea recurs in Lean (Day 3) and SAW (Day 4).
- **Automata-theoretic LTL (LTL→Büchi→emptiness) on Day 2** *(analysis 1):* explains *why* LTL model checking works, not just the operators; pairs with your existing counterexample material.
- **"Compile-to-formula → solve" unifier slide** *(analysis 4):* CBMC, SAW/Cryptol, and α,β-CROWN are all "compile artifact to a formula, hand to a solver." One slide turns three disjoint tools into one mental model.
- **Beyond-ℓ∞ NN properties** *(analysis 4):* certified NLP robustness (word substitutions), reachability/safety (ACAS-Xu), and *certified training* — corrects the "robustness = only ℓ∞" oversimplification.

---

## TIER 4 — Pointers only (reading list / one-line mention)

- **TLA+** for distributed/concurrent specs — Day 2 mention next to nuXmv *(analysis 3; VTSA double-billed it).*
- **Property-based testing** (QuickChick / Hypothesis) — Day 3 mention; cheap bridge between testing and proof *(analysis 3).*
- **Constrained Horn Clauses (CHC)** — Day 4 further-study pointer; the unifying SMT backend behind much program verification *(analyses 1, 3).*
- **Hyperproperties** (non-interference) — Day 4 frontier mention; relevant to AI/security *(analysis 1).*
- **Protocol verification (Tamarin/ProVerif)** and **probabilistic MC (PRISM)** — reading list; real specialist tracks but too far for 4 days *(analysis 3).*
- **Incremental solving (push/pop), quantifiers + triggers** ("why solvers say `unknown`") — Day 1 one-liners *(analysis 4).*

---

## DO NOT ADD (all analyses agree — out of scope for 4 days, no background)

- Solver-internals deep dive / build-a-solver (Stanford CS357 style) — one-line "solvers have rich internals" pointer is enough.
- OPLSS-style type theory / category theory / linear logic.
- Probabilistic / hybrid model-checking depth.
- Manna-Pnueli fairness depth.

---

## Cross-cutting insights

- **The two structural holes are now filled** (deductive-verification bridge; AI×FM measurement). Those were the only *structural* gaps; the rest are topic/pacing choices.
- **Marktoberdorf 2026 is FMAIV's closest peer** on the thesis — de Moura's "Lean 4 for Program Verification in the Age of AI" + Mitchell's "Evaluating Agentic AI Systems." It pairs the *tools* with an explicit *evaluation* lecture; that pairing is the direction to grow Day 4. Worth watching/citing as the course evolves.
- **MIT FRAP is striking external validation** of FMAIV's "transition-systems-as-spine" design — Chlipala threads the exact same unifying model through an entire Coq course.
- **What FMAIV uniquely does** (confirmed by the survey): no other single course spans SAT/SMT → symbolic model checking → interactive theorem proving (Lean 4) → automated program/crypto verification (CBMC/Cryptol/SAW) → **neural-network verification**, unified by an explicit *agentic-coding / verification-is-essential* thesis. That breadth-with-a-thesis is the course's distinctive value; the additions above deepen it without diluting it.
