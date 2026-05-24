---
title: "Day 1 — Foundations: Logic, Transition Systems, SAT, SMT"
subtitle: "FMAIV: Formal Methods & AI-Assisted Verification"
author:
  - "Taylor Johnson — Associate Professor of Computer Science, Computer Engineering & Electrical Engineering; Associate Dean for Graduate Education, College of Connected Computing · taylor.johnson@vanderbilt.edu · [taylortjohnson.com](https://www.taylortjohnson.com/)"
  - "Ben Wooding — Postdoctoral Scholar, Institute for Software Integrated Systems · ben.wooding@vanderbilt.edu · [woodingben.com](https://woodingben.com/)"
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

*A counterexample is one concrete behavior that violates the property; N is a step bound.*

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

Terence Tao has described large Lean formalization projects as a new mode of collaboration: contributors he has never met submit proof steps in a language he is still learning, and the proof assistant's kernel — not a human referee — arbitrates whether each step is correct (paraphrased; Scientific American, 2024).

::: notes
This is the framing slide for the whole week. The story is: AI is doing the easy half of verification (proposing) much faster than humans can do the hard half (checking). Formal methods is the only known way to mechanize the checking. We're not here to compete with AI; we're here to build the substrate it needs to be trustworthy. This is a paraphrase of Tao's public remarks on the PFR/Equational Theories Lean projects (e.g. his 2024 Scientific American interview and blog posts), not a verbatim quotation.
:::

---

## Why now? The economics of cheap generation

- **Compute is flooding in.** Global AI investment now runs, as an order-of-magnitude framing, at something like NASA's *entire annual budget every one-to-three weeks*; Sutton's "bitter lesson" says the methods that win are the ones that ride more compute — so generation keeps getting cheaper and better.
- **The flip side the hype skips:** for many concrete tasks a *small* or *neuro-symbolic* solution beats a frontier LLM — cheaper, faster, often more accurate (NVIDIA, *Small Language Models are the Future of Agentic AI*, arXiv 2506.02153). On **image-based string/arithmetic acceptance**, **our** neuro-symbolic finite/pushdown automata reached **70–100%** accuracy where GPT/Claude/Gemini-class VLMs scored **≤50%** (and ~0% on multi-operator arithmetic) — at roughly **1000× lower latency** and a few dollars of compute (Sasaki, Lopez & Johnson, *Neurosymbolic Finite and Pushdown Automata*, NeuS 2025).
- **Both arrows point at verification.** Cheap generation buries us in artifacts to check — and the cost-effective, *small* artifacts are exactly the ones formal methods can still scale to.

::: notes
The economic "why now," for a faculty audience. Two forces. First, raw money and compute: AI capital expenditure is at a scale where — as an order-of-magnitude framing we use — the industry spends on the order of NASA's whole yearly budget every few weeks, and Rich Sutton's *bitter lesson* (2019) predicts the compute-hungry methods keep winning, so the cost of *generating* code, proofs, and designs trends toward zero. Second, a counter-current the hype misses: you often shouldn't reach for a giant LLM at all — for narrow tasks, small or neuro-symbolic systems are cheaper, faster, and more accurate (NVIDIA's position paper, arXiv 2506.02153; our neuro-symbolic finite/pushdown automata beat GPT/Claude/Gemini-class vision-language models (VLMs) on image-based reasoning by large margins at ~$10 of compute — Sasaki, Lopez, Johnson, NeuS 2025). Crucially for this course, smaller and simpler is also *more verifiable*: fewer neurons and less ReLU branching mean tighter, faster reachability. So whichever way the economics break, the binding constraint becomes assurance — which is this week.
:::

---

## Three signals: AI is shipping verifiable math

- **Polynomial Freiman–Ruzsa conjecture** — the informal proof (Gowers, Green, Manners, Tao) was posted November 2023; a public collaboration of 20+ people, led by Tao with Yael Dillies and Bhavik Mehta, formalized it in Lean in about three weeks (mid-November to early December 2023).
- **Gemini Deep Think — IMO 2025 gold medal** — 35/42 points, solved 5 of 6 problems within the 4.5-hour window, all in natural language.
- **DeepSeek-Prover-V2 (671B) — 88.9% on miniF2F** (April 2025) at a large pass@8192 sample budget (~82% at pass@32), the standard benchmark of competition-level theorems formalized in Lean 4.

::: notes
Three things that would have been science fiction in 2020 and are now line items in 2026. PFR showed AI-assisted human-mediated Lean formalization at a research-level speed (weeks, not years). IMO 2025 showed natural-language theorem proving by LLM at the olympiad medal level. DeepSeek-Prover-V2 showed automated proof generation in Lean at a level approaching strong undergraduates. None of these existed three years ago.
:::

---

## Three counter-signals: AI is shipping broken code

- **A large fraction of LLM-generated code carries known security vulnerabilities** — studies report anywhere from ~30% to over 60% depending on language and prompt; one 2023 audit (FormAI, Tihanyi et al.) found ~51% of 112,000 C programs generated by GPT-3.5 contained at least one CWE-classified vulnerability (detected via formal verification with ESBMC).
- **~20% of LLM-recommended packages don't exist** — "slopsquatting" is now a named attack vector: an attacker registers the hallucinated package name.
- **AWS, by contrast, applies formal methods to both its crypto and its AI** — s2n-TLS's crypto kernels are checked with SAW proofs on every commit (March 2026 added a HOL Light–verified AES-XTS to s2n-bignum), and AWS Bedrock's **Automated Reasoning checks** now validate LLM outputs against formal policies with up to **99% verification accuracy** (2025).

::: notes
The same AI that hits IMO gold also writes vulnerable code. The reason is the same: LLMs optimize for plausibility, not correctness. Formal methods is what gives you the correctness side of the contract. AWS publishes the verification stack they use for s2n; you can read the SAW scripts in their open-source repo. The contrast is the whole pitch for this week: formal methods is what lets you trust an AI's output.
:::

---

## This season alone: AI crosses two thresholds

- **Finding flaws at scale.** Anthropic's **Project Glasswing** (2026) turned a frontier model loose on critical software and surfaced **thousands of zero-day vulnerabilities** across every major OS and browser — including a **27-year-old** bug in OpenBSD and a **16-year-old** bug in FFmpeg that fuzzers had executed **five million times** and still missed. (anthropic.com/glasswing)
- **Proving new theorems.** In **May 2026** an **OpenAI** reasoning model autonomously produced a proof that **rules out the long-conjectured near-linear ($n^{1+o(1)}$) form of the bound** on Erdős's 1946 unit-distance problem — a fixed polynomial improvement (exponent δ later pinned to 0.014 by **Will Sawin**) — one of the first times AI has independently advanced a central open problem in a subfield. (openai.com)
- **The lesson.** Testing ran that FFmpeg line five million times and learned nothing; *reasoning about the code* found the bug. When AI both writes and breaks software, **proof — not more testing — tells you which side you are on.**

::: notes
The "this is happening now" slide — concrete, datable, two-sided. Glasswing (Anthropic, spring 2026): a frontier model used for *defensive* security found thousands of real zero-days, the vivid examples being a 27-year-old OpenBSD flaw and a 16-year-old FFmpeg flaw that automated testing had executed about five million times without catching — a living restatement of Dijkstra's "testing shows the presence, not the absence, of bugs." OpenAI's Erdős result (May 20, 2026): a general-purpose reasoning model — not a math-specific system — produced a genuinely novel proof importing algebraic number theory into discrete geometry, ruling out the near-linear ($n^{1+o(1)}$) form long conjectured for the unit-distance problem, with Will Sawin refining the exponent to 0.014. Together they bracket the moment: AI is now superhuman at both *destroying* (finding flaws) and *creating* (new mathematics), and in both directions the scarce resource is a machine-checkable guarantee — the entire subject of this week. Sources: anthropic.com/glasswing and NPR (Apr 2026); openai.com "model disproves discrete geometry conjecture," TechCrunch and Scientific American (May 2026).
:::

---

## Coding has changed: generative → agentic

- **Generative AI** = *generating* stuff (text, code). **Agentic AI** = *generating + doing* — it plans, edits files, runs tools and tests, reads the errors, and iterates.
- Tools: **Claude Code**, Cursor, GitHub Copilot, OpenAI Codex — inside your editor (VS Code), wired to your shell and, via **MCP** (Model Context Protocol), to external tools and data.
- What that buys, from real recent use (our own, late 2025):
    - ~10,000 lines of **C# → Python** in ~3 hours; ~10k lines **MATLAB → Python**; new NNV benchmarks in ~1 hour.
    - Live lecture demos, Docker environments built during a Zoom interview, APIs learned on the fly.
- **The pattern that makes it work — *oracles*:** agentic AI iterates wherever it can *check* itself — a parser, a simulation, a differential test against a known-good artifact, or a formal proof. Verification is the highest-confidence oracle.

> The *generation* half of engineering just got cheap. That is exactly why the *validation* half — this course — becomes the bottleneck.

::: notes
Set the stage for a faculty audience. The distinction that lands: generative = it writes; agentic = it writes AND acts (runs your tests, fixes the error it sees, opens a PR). The stack is editor + shell + MCP (the emerging standard for agents to reach external tools/data). The productivity numbers are our own from late 2025 — translations, benchmarks, and demos in hours, not weeks. This isn't hype; the point is structural: when anyone can generate code/proofs/designs in seconds, the scarce, decisive skill becomes deciding whether the result is correct — verification.
:::

---

## Vibe coding → vibe engineering

Karpathy named **"vibe coding"** (Feb 2025) — "give in to the vibes, forget the code exists." A year on: **"agentic engineering"** — orchestrate agents while *acting as oversight*.

| | Vibe coding | Agentic engineering |
|---|---|---|
| Code review | skipped | rigorous (like PR review) |
| Testing | minimal / absent | comprehensive suites |
| Planning | none | design docs + specs |
| Ownership | casual acceptance | **full human responsibility** |

But AI-generated code is *often wrong*: Veracode's 2025 GenAI report found security flaws in **~45%** of AI-written samples; Apiiro reported AI assistants ship code **~4× faster but with ~10× the vulnerabilities** (2025); MIT Sloan documents the *hidden costs* — technical debt that destabilizes systems (2025) (industry/vendor reports). (Plus the ~51% vulnerable C and ~20% hallucinated packages from before.) **You own what the AI writes.**

Dijkstra warned of exactly this in *On the Foolishness of "Natural Language Programming"* (EWD667, 1978): natural language is too ambiguous to be a safe programming medium. Vibe coding is that idea *automated*.

> Generation is cheap; **correctness is the bottleneck**. That makes **verification the essential activity** — the subject of the next four days.

::: notes
The thesis slide of the workshop, in the agentic-coding frame. Vibe coding (Karpathy, Feb 2025; Collins Word of the Year 2025) = accept the output, don't read it — fine for a throwaway script, dangerous for anything that matters. "Agentic engineering" keeps the AI's speed but re-imposes discipline: review, tests, specs, ownership. The failure numbers (Veracode ~45% of AI samples flawed; Apiiro's "4× velocity, 10× vulnerabilities," Sept 2025; MIT Sloan's "Hidden Costs of Coding With Generative AI," Aug 2025; plus FormAI ~51% and slopsquatting from the previous slides) are why. For an FM course the moral is exact: when code is free to produce, the bottleneck moves to *establishing it is correct*. Spec-driven tooling (e.g., GitHub Spec Kit, AWS Kiro) is the emerging bridge between the two columns.
:::

---

## How this course was built — and why that's the point

This very deck is an agentic-engineering artifact:

- **Pulled** the source CS 6315 material from the LMS — 14 weeks of slides **and** lecture-video transcripts.
- **Analyzed and repurposed** it into this 4-day arc with an AI agent; **added** new material (the AI × FM framing, the figures you're seeing, the neural-network frontier).
- **Verified everything**: every Z3 query runs, every Lean *solution* module builds with no `sorry` (the starters carry intended ones), every SMV / CBMC / Cryptol example checks — the agent *proposed*, the tools *disposed*.

That last step is the whole difference between vibe coding and engineering — and it's the muscle the next four days build.

::: notes
A short meta-slide that resonates with faculty: the course you're taking was assembled with the very workflow it teaches. Content was extracted from the CMS (Brightspace) — slides plus auto-generated lecture transcripts — restructured by an agent, with new framing, figures, and NN-frontier material added. Crucially nothing was trusted blindly: examples were executed and proofs machine-checked (Lean `#print axioms`, Z3 sat/unsat, CBMC verdicts), and the facts were audited. That is agentic engineering, not vibe coding — and it's the honest answer to "can I trust AI-generated teaching material?": only if you verify it.
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

## Verification in one picture

<svg viewBox="0 0 920 300" style="display:block;margin:0.3em auto;max-width:92%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs><marker id="vtri-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/></marker></defs>
  <rect x="24" y="46" width="206" height="62" rx="8" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="127" y="72" text-anchor="middle" font-size="17" font-weight="600" fill="#123a52">Model</text>
  <text x="127" y="93" text-anchor="middle" font-size="12.5" fill="#355466">what the system is</text>
  <rect x="24" y="168" width="206" height="62" rx="8" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="127" y="194" text-anchor="middle" font-size="17" font-weight="600" fill="#6b531f">Specification</text>
  <text x="127" y="215" text-anchor="middle" font-size="12.5" fill="#7a6334">what correct means</text>
  <rect x="384" y="104" width="168" height="84" rx="8" fill="#eef3f7" stroke="#5b6168" stroke-width="2.4"/>
  <text x="468" y="140" text-anchor="middle" font-size="18" font-weight="700" fill="#1c1c1c">Verifier</text>
  <text x="468" y="162" text-anchor="middle" font-size="11.5" fill="#5b6168">solver · model checker · prover</text>
  <rect x="690" y="40" width="208" height="64" rx="8" fill="#eef7ee" stroke="#27843f" stroke-width="2"/>
  <text x="794" y="66" text-anchor="middle" font-size="16" font-weight="600" fill="#1c6b30">&#10003; Verified</text>
  <text x="794" y="87" text-anchor="middle" font-size="12.5" fill="#2f6b40">proof / certificate</text>
  <rect x="690" y="176" width="208" height="64" rx="8" fill="#fdecea" stroke="#c0392b" stroke-width="2"/>
  <text x="794" y="202" text-anchor="middle" font-size="16" font-weight="600" fill="#922b21">&#10007; Counterexample</text>
  <text x="794" y="223" text-anchor="middle" font-size="12.5" fill="#9c4036">a concrete bug trace</text>
  <line x1="230" y1="74" x2="378" y2="128" stroke="#5b6168" stroke-width="1.8" marker-end="url(#vtri-ah)"/>
  <line x1="230" y1="200" x2="378" y2="166" stroke="#5b6168" stroke-width="1.8" marker-end="url(#vtri-ah)"/>
  <line x1="552" y1="132" x2="684" y2="74" stroke="#5b6168" stroke-width="1.8" marker-end="url(#vtri-ah)"/>
  <line x1="552" y1="160" x2="684" y2="206" stroke="#5b6168" stroke-width="1.8" marker-end="url(#vtri-ah)"/>
</svg>

A **verifier** takes a **model** (what the system *is*) and a **specification** (what *correct* means) and returns one of exactly two things: a **proof** that *every* behavior meets the spec, or a **counterexample** — one concrete behavior that breaks it. Every tool this week is an instance of this picture.

::: notes
The mental model for the entire course, as a picture before the formalism (this is the model/spec/verifier/result flow from our own slides). Two inputs — the model (the system, as a transition system, formula, or program) and the specification (the property: an assertion, a temporal-logic formula, a theorem statement) — feed a verifier, which is whatever engine the day uses (Z3 on Day 1, nuXmv on Day 2, Lean on Day 3, CBMC/SAW on Day 4). The output is binary in spirit: either a proof/certificate that the property holds over *all* behaviors, or a counterexample that exhibits a single offending behavior. Stress the "all vs one" asymmetry — it's exactly what separates verification from testing, and it sets up the Dijkstra/Knuth quotes next. Keep returning to this picture; every later tool just fills in the three boxes differently.
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

## Testing vs. proof, in two quotes

> "Program testing can be used to show the presence of bugs, but never to show their absence!"
> — **Edsger W. Dijkstra**, *Notes on Structured Programming*, 1970

> "Beware of bugs in the above code; I have only proved it correct, not tried it."
> — **Donald E. Knuth**, 1977

Testing **samples** behaviors; verification reasons about **all** of them. That gap is the whole reason this field exists — and exactly what the FFmpeg bug (run five million times by fuzzers, still missed) showed.

::: notes
The two quotes that frame the week, requested as content rather than buried in notes. Dijkstra's line (from *Notes on Structured Programming*, 1970 — also EWD249) is the field's founding aphorism: a test exercises one input; passing tells you nothing about the inputs you didn't try. Knuth's line (1977, in a memo to Peter van Emde Boas) is the witty complement — proof and testing are different activities, and even a proof rests on assumptions, so good engineers do both. The synthesis for this audience: testing samples the behavior space; verification quantifies over all of it (the "all vs one" asymmetry from the previous picture). Tie it straight back to Glasswing's FFmpeg bug — five million fuzzing executions of the affected line, and the flaw still hid, because testing cannot demonstrate absence. That is the gap formal methods fills.
:::

---

## Famous bugs that motivated FM (1)

**Therac-25** (1985–87) — radiation therapy machine, six known accidents, at least three deaths.

A race condition in operator input timing let the machine fire its high-current electron beam — the beam normally aimed at a target to generate X-rays — directly at the patient with the beam-spreading target retracted. Patients received on the order of 100× the intended dose.

- Root cause: software interlocks replaced hardware interlocks (Therac-20 had hardware safety; -25 did not).
- The same software bug existed in Therac-20 and never killed anyone because hardware caught it.
- Paper of record: Leveson & Turner, *Computer*, 1993. [sunnyday.mit.edu/papers/therac.pdf](http://sunnyday.mit.edu/papers/therac.pdf)

::: notes
Therac-25 is the founding bug-story of safety-critical software. The MIT paper by Nancy Leveson is required reading in every SE class on safety. The teaching point isn't "software is bad" — it's "removing redundancy without proof is bad." Hardware interlocks were doing the work; when removed, no one could prove the software interlocks were sufficient, and they weren't. This is the kind of question a model checker answers in seconds today. Source: Leveson & Turner, "An Investigation of the Therac-25 Accidents," IEEE Computer 26(7), 1993 — https://ieeexplore.ieee.org/document/274940 (mirror: https://www.cs.columbia.edu/~junfeng/08fa-e6998/sched/readings/therac25.pdf).
:::

---

## Famous bugs (2)

**Ariane 5, Flight 501** (1996) — roughly $370M in lost hardware (rocket and four scientific satellites); exploded ~37 seconds after launch.

A 64-bit floating-point horizontal velocity overflowed when converted to a 16-bit signed integer in the inertial reference system. The conversion was unprotected, so the overflow raised an exception that shut the system down — and the backup, running identical code, had already failed the same way. The rocket veered off course and self-destructed.

- The bug was in code reused from Ariane 4, where the upper bound on horizontal velocity was lower.
- The Ariane 4 envelope made the conversion safe; nobody re-checked it for Ariane 5.
- Verifying the conversion safety is a one-line SMT query: `(assert (<= horizontal_velocity 32767))`.

::: notes
Ariane 5 is the founding bug-story for arithmetic verification. The immediate corrective actions were range-protecting the conversions plus revised review and test processes (per the Lions inquiry board); more broadly, abstract interpretation — notably Astrée, from Patrick Cousot's group — later became the flagship static-analysis tool for Airbus fly-by-wire software (Astrée postdates Ariane 501, so it was not the 1996 remedy). The bug would have been caught by a single integer-range assertion checked at compile time — about ten seconds of an SMT solver's time today. Source: ESA Ariane 501 Inquiry Board (Lions) report, 1996 — https://www.esa.int/Newsroom/Press_Releases/Ariane_501_-_Presentation_of_Inquiry_Board_report (full report: http://sunnyday.mit.edu/nasa-class/Ariane5-report.html).
:::

---

## Famous bugs (3)

**Intel Pentium FDIV** (1994) — division returned wrong answer for ~1 in 9 billion inputs.

Five entries in the floating-point divider's SRT lookup table — 5 of the ~1066 cells that should have held a value (the table has 2048 slots) — returned 0 instead of +2. The bug cost Intel **$475M** in replacement chips and reshaped industry practice forever.

- After FDIV, Intel built an in-house formal-verification capability based on Symbolic Trajectory Evaluation and progressively made formal proof of arithmetic datapaths part of release sign-off.
- Today, Intel, AMD, Apple, ARM, and every major semiconductor company runs formal hardware verification at scale. Cadence JasperGold and Synopsys VC Formal are the products.
- Without FDIV, the modern formal-hardware industry might not exist.

::: notes
This is the bug that turned formal methods from academic curiosity into industrial practice. Intel built its hardware formal-verification capability around Symbolic Trajectory Evaluation — Carl-Johan Seger's method — with John O'Leary, Robert Jones, and Tom Melham (the Forte system), and progressively made formal proof of arithmetic datapaths part of sign-off. (Separately, Edmund Clarke's group published academic word-level model checking of SRT division in 1996, prompted by FDIV.) Formal property-checking tools like JasperGold and VC Formal are now used across the semiconductor industry. The lesson for us: one expensive incident is sometimes worth more than a thousand academic papers in changing industry practice. Sources: Ken Shirriff's die-level analysis of the FDIV bug — https://www.righto.com/2024/12/this-die-photo-of-pentium-shows.html ; Pentium FDIV overview — https://en.wikipedia.org/wiki/Pentium_FDIV_bug ; Intel's Forte/STE environment (Seger, O'Leary, Jones, Melham) — https://www.cs.ox.ac.uk/tom.melham/res/forte.html and Seger et al. (FMSD 2005) http://theory.stanford.edu/~barrett/pubs/SJO+05.pdf.
:::

---

## Famous bugs (4)

**Toyota unintended acceleration** (2007–10) — multiple fatal accidents; $1.2B U.S. Department of Justice criminal penalty (2014).

A NASA/NHTSA study (2010–11) examined the electronic throttle but could not confirm a software cause of large unintended acceleration. A separate code review by Michael Barr — expert testimony in *Bookout v. Toyota* (Oklahoma 2013) — found:

- Recursion and unbounded stack growth; stack overflow possible.
- Thousands of global variables — no encapsulation.
- A watchdog timer that could be silenced by the very task it was meant to monitor.
- The throttle could be driven open by a single bit-flip and stay there.

The jury awarded $3M and found "reckless disregard." Toyota recalled roughly 8–9 million vehicles.

::: notes
Toyota is the bug-story for embedded C software complexity. Michael Barr's code review (the most-cited expert analysis; Philip Koopman also testified in related cases) described code that today's static analyzers and bounded model checkers — Coverity, Polyspace, Frama-C, CBMC — are designed to flag. The post-2010 automotive industry adopted MISRA-C and leaned harder on formal methods; ISO 26262 strongly recommends them for the highest-criticality (ASIL-D) components. Sources: Michael Barr's *Bookout v. Toyota* testimony — https://www.safetyresearch.net/Library/Bookout_v_Toyota_Barr_REDACTED.pdf ; NASA/NHTSA study (the inconclusive one) — https://www.nhtsa.gov/sites/nhtsa.gov/files/nasa-ucr_finalreport_0.pdf ; DOJ $1.2B statement of facts (2014) — https://www.justice.gov/sites/default/files/opa/legacy/2014/03/19/toyota-stmt-facts.pdf.
:::

---

## Famous bugs (5)

**Boeing 737 MAX MCAS** (2018–19) — 346 deaths across two crashes.

The Maneuvering Characteristics Augmentation System was a software workaround for an aerodynamic change. It:

- Could push the nose down based on input from a *single* angle-of-attack sensor.
- Re-activated about 5 seconds after each pilot trim input, repeating in a cycle that fought the pilots.
- Was not documented in pilot training materials.
- Ran only with the autopilot already off, so "autopilot off" did not stop it — halting it required the stabilizer-trim cutout switches.

The fix compares *both* AoA sensors, fires MCAS only once per event, and caps its authority — plus revised training. The certification process itself failed: the FAA delegated assessment to Boeing.

::: notes
MCAS is the contemporary version of Therac-25 — same pattern: software replacing hardware redundancy without anyone proving the software was sufficient. The deeper issue is process: nobody asked "what's the inductive invariant that keeps MCAS from fighting the pilot?" The post-MAX FAA reforms (the 2020 Aircraft Certification, Safety, and Accountability Act) tightened oversight and documentation of failure modes for software with this kind of authority. Tools like TLA+ are well suited to specifying exactly this kind of sensor-voting logic. Sources: KNKT (Indonesia) Lion Air 610 final report — https://reports.aviation-safety.net/2018/20181029-0_B38M_PK-LQP.pdf ; JATR review of MCAS certification — https://www.faa.gov/sites/faa.gov/files/aircraft/air_cert/design_approvals/boeing/737max/737_MAX_TAB_Report.pdf ; U.S. House T&I Committee final report (2020).
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

- **s2n-TLS** — crypto kernels (HMAC, DRBG) verified with **SAW** against Cryptol specs, re-run on every commit; deployed across AWS services.
- **s2n-bignum** — verified integer/crypto **assembly** (P-256/384/521, X25519, Ed25519, RSA, AES-XTS), each carrying a **HOL Light** machine-checked proof, run per commit.
- **AWS Cedar** — authorization policy language, **formally specified in Lean 4** (public `cedar-spec` repo); originally verified in **Dafny**, then migrated to Lean.
- **AES-XTS storage encryption** — used by EBS/Nitro, proved in HOL Light as part of s2n-bignum (March 2026 announcement).
- **Dafny for AWS authorization** — the core authorization engine has a Dafny spec + proof, validated against quadrillions of real requests (the separate Zelkova / IAM Access Analyzer tool uses SMT directly).

> AWS's Provable Security group frames verification as a continuous-integration signal: like a test suite, a proof either passes or fails on every commit, and a failing proof blocks the change.

::: notes
AWS is the showcase deployment. AWS's automated-reasoning teams (including Byron Cook's Provable Security group) make up one of the largest industrial formal-methods efforts in the world, and they publish almost everything. For industrial-strength SAW scripts see the s2n / aws-lc-verification repos; s2n-bignum is the place for HOL Light machine-code proofs. The Cedar work is particularly relevant for Day 3 — it's Lean used as a *specification* language for production-deployed software, not just a math library. (The "verification as CI signal" framing paraphrases how the group publicly describes their workflow; it is not a verbatim quotation.)
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

## The wider landscape: what this week samples

This week goes deep on four engines — SAT/SMT, model checking, theorem proving, source-level proof. They sit inside a much larger toolbox you should know exists:

| Approach | Question it answers | Representative tools | Here? |
|---|---|---|---|
| **Static analysis** | "Any bug-shaped patterns, cheaply, at scale?" | Coverity, Clang SA, Infer, CodeQL | mentioned |
| **Abstract interpretation** | "A *sound* over-approximation of all runs?" | Astrée, IKOS, MOPSA | Day 4 kin |
| **Testing & fuzzing** | "Concrete inputs that break it?" | OSS-Fuzz, AFL++, KLEE, QuickCheck | contrast |
| **Runtime verification** | "Is *this* execution violating the spec, live?" | RV monitors, temporal-logic checkers | mentioned |
| **Model-based design** | "Generate code from a model that was checked" | Simulink/Stateflow, SCADE/Lustre | mentioned |
| **Deductive verification** | "Full functional correctness of real code" | Frama-C, Dafny, Why3, Viper | Day 3–4 kin |
| **Type & refinement systems** | "Correctness the compiler enforces for free" | Rust, LiquidHaskell, F\* | Day 3 kin |

> The axis underneath them all: **automation ↕ expressiveness**. Testing and static analysis are push-button but shallow; theorem proving is arbitrarily expressive but laborious. Choosing the lightest tool that still answers your question *is* the engineering judgment this week trains.

::: notes
A faculty audience will want the map, not just the four pins we drop on it. Each row is a real, deployed sub-field; we sample four and gesture at the rest. Anchors for the curious (all checkable): **Static analysis** — Bessey et al., "A Few Billion Lines of Code Later," CACM 2010 (the Coverity field report); Meta's Infer (separation logic), GitHub CodeQL, the Clang Static Analyzer. **Abstract interpretation** — the founding paper is Cousot & Cousot, POPL 1977; its flagship is Astrée, which proves the absence of run-time errors in Airbus A340/A380 fly-by-wire C. **Testing/fuzzing** — symbolic execution: KLEE (Cadar, Dunbar, Engler, OSDI 2008); whitebox fuzzing: SAGE (Godefroid et al., Microsoft); property-based testing: QuickCheck (Claessen & Hughes, ICFP 2000); continuous fuzzing at scale: Google OSS-Fuzz, AFL++. **Runtime verification** — Bartocci et al. (eds.), *Lectures on Runtime Verification*, Springer 2018. **Model-based design** — Simulink/Stateflow (MathWorks) and SCADE (built on the synchronous language Lustre, Halbwachs et al.); certified under DO-178C with its formal-methods (DO-333) and model-based (DO-331) supplements. **Deductive verification** — Frama-C/ACSL, Why3, Dafny (Leino), Viper (ETH). **Refinement/types** — LiquidHaskell, F\*, and Rust's ownership types as lightweight static guarantees. **Translation validation** — Pnueli, Siegel & Singerman, TACAS 1998. The agentic tie-in: the cheap, automatic end of this spectrum (static analysis, fuzzing) is the realistic first line of defense on AI-generated code, and is itself increasingly AI-augmented — but only the heavier engines give you a *proof*, which is why the bottleneck-shift argument lands on this course.
:::

---

## Live demo: Claude Code → Z3 → graph 3-coloring

We will:

1. Open Claude Code in VS Code.
2. Ask: "draft an SMT-LIB encoding for 3-coloring the complete graph $K_4$."
3. Run the resulting `.smt2` file with `z3`.
4. Observe `unsat` (4 vertices, 3 colors, every pair adjacent — impossible).
5. Change $K_4$ to the cycle $C_5$ and observe `sat` with a model.

*New notation? `sat`/`unsat`, SMT-LIB, and Z3 all get a proper treatment in the SAT/SMT block later today — here, just watch the workflow.*

**The kernel arbitrates. The LLM proposes.**

::: notes
Three minutes of live coding. The Claude Code prompt is "give me an SMT-LIB encoding for the 3-colorability of K_4". It will produce something close to right; the point is to (a) see what the LLM produces, (b) run it and trust Z3's verdict, not the LLM's narration. If Claude makes a mistake — like asserting only some edges — the Z3 verdict catches it. This is the working pattern we'll use all week: AI proposes, kernel disposes.
:::

---

## Quick check: SAT or UNSAT?

Symbol key (we define these properly next block): $\neg$ not, $\wedge$ and, $\vee$ or, $\to$ implies, $\forall$ for all, $\exists$ there exists, $\mathbb{Z}$ the integers.

For each formula, predict `sat` (some assignment makes it true) or `unsat` (none can):

1. $p \wedge \neg p$
2. $p \vee \neg p$
3. $(p \to q) \wedge (q \to r) \wedge p \wedge \neg r$
4. $\forall x.\; x + 0 = x$, in linear integer arithmetic
5. $\exists x, y \in \mathbb{Z}.\; x^2 + y^2 = 25 \wedge x > 0 \wedge y > 0$

Call out your prediction for each — then we'll run each one through Z3.

::: notes
Ask the class for each. Expected: (1) unsat — contradiction; (2) sat — tautology, every assignment satisfies; we call it "valid", which is the same as "negation is unsat"; (3) unsat — by modus ponens chain; (4) sat (and valid) — true in LIA; (5) sat with model x=3, y=4 (or 4,3). The point is to make participants realize satisfiability is the *primitive* operation; validity is "negation is unsat" and entailment is "premises ∧ ¬conclusion is unsat". Everything is satisfiability.
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

**Atomic propositions:** $p, q, r, \dots$ — variables each ranging over $\{\bot, \top\}$ (the two truth values: $\bot$ = false, $\top$ = true).

**Formulas** are built inductively:

$$\varphi ::= p \;\mid\; \neg \varphi \;\mid\; \varphi \wedge \varphi \;\mid\; \varphi \vee \varphi \;\mid\; \varphi \to \varphi \;\mid\; \varphi \leftrightarrow \varphi$$

Read this grammar as "a formula is an atom, or a negation, or two formulas joined by a connective." ($::=$ means "is one of the following forms"; $\mid$ separates the alternatives.)

**Connectives:** $\neg$ not, $\wedge$ and, $\vee$ or (inclusive), $\to$ implies (if…then), $\leftrightarrow$ if and only if.

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

Write $[\![\varphi]\!]_v$ for the **truth value (meaning) of $\varphi$ under $v$** — either $\top$ (true) or $\bot$ (false). It is defined by recursion on the structure of $\varphi$:

| $\varphi$ | $[\![\varphi]\!]_v$ (its truth value under $v$) |
|---|---|
| $p$ | $v(p)$ |
| $\neg \varphi$ | $\top$ iff $[\![\varphi]\!]_v = \bot$ |
| $\varphi \wedge \psi$ | $\top$ iff $[\![\varphi]\!]_v = [\![\psi]\!]_v = \top$ |
| $\varphi \vee \psi$ | $\top$ iff at least one is $\top$ |
| $\varphi \to \psi$ | $\top$ iff $[\![\varphi]\!]_v = \bot$ or $[\![\psi]\!]_v = \top$ |

We write $v \models \varphi$ (read "$v$ **satisfies** $\varphi$") if $[\![\varphi]\!]_v = \top$ — i.e. the assignment $v$ makes $\varphi$ come out true. The symbol $\models$ recurs all week: an assignment or model on the left, a formula on the right.

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
| **Entailment** | $\Gamma \models \varphi$ ($\Gamma$ a set of premises) — every $v$ that satisfies all of $\Gamma$ satisfies $\varphi$ | co-NP-complete (check $\Gamma \cup \{\neg\varphi\}$ unsat, for finite $\Gamma$) |

Everything reduces to satisfiability:

- $\varphi$ valid $\iff$ $\neg \varphi$ unsatisfiable.
- $\Gamma \models \varphi \iff \Gamma \cup \{\neg \varphi\}$ unsatisfiable.

($\iff$ means "exactly when / if and only if". *NP-complete* = verifiable in polynomial time given a witness; no known polynomial-time algorithm (a fast one would prove P = NP). *co-NP-complete* is the mirror image, for "always true" questions.)

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

The last row is an **entailment** check in disguise: $\{p \to q,\; p\} \models q$ holds *because* adding $\neg q$ makes the set unsatisfiable — exactly the $\Gamma \cup \{\neg\varphi\}$ trick from the previous slide.

::: notes
Work through each one orally for ten seconds. The third one is famously where physicists get confused — "weakening" feels wrong because the premise can ignore the consequent's antecedent. It's correct in classical logic; in intuitionistic logic the same formula is also valid. Lean 4 uses intuitionistic by default, with classical as an axiom available via `Classical.em`.
:::

---

## Two arrows: $\vdash$ (provable) vs $\models$ (true)

There are two completely different ways to say "$\varphi$ follows from premises $\Gamma$":

- $\Gamma \models \varphi$ — **semantic** ("entails"): *every* interpretation that makes all of $\Gamma$ true also makes $\varphi$ true. About **meaning** — defined by the truth tables.
- $\Gamma \vdash \varphi$ — **syntactic** ("derives"): there is a *finite proof* of $\varphi$ from $\Gamma$ using a fixed set of **inference rules** (e.g. *modus ponens*: from $a$ and $a \to b$, conclude $b$). About **symbol-pushing** — no truth values mentioned.

A proof system is judged by how these two line up:

- **Sound**: $\Gamma \vdash \varphi \;\Rightarrow\; \Gamma \models \varphi$ — "you can't derive anything false." Anything you *prove* really is *true*.
- **Complete**: $\Gamma \models \varphi \;\Rightarrow\; \Gamma \vdash \varphi$ — "everything true is derivable." Nothing true escapes the proof system.

::: notes
This is the single most important conceptual distinction in all of logic, and it's the hinge the whole week turns on. $\models$ (double turnstile) is about models and meaning; $\vdash$ (single turnstile) is about derivations and rules. We frame soundness as "you can't prove anything that's wrong" and completeness as "you can prove anything that's true." A solver/prover is trustworthy only if it's *sound* — when Z3 says `unsat` or Lean accepts a proof, soundness is exactly the guarantee that the verdict reflects truth, not a bug in the rules. Completeness is the nice-to-have that's often unavailable (first-order validity is only semi-decidable; richer logics lose completeness entirely — a Day-3 theme). Today's tools live on the semantic side; Day 3's Lean lives on the syntactic side, and its kernel is the thing enforcing soundness.
:::

---

## First-order logic — what's new

Adds:

- **Variables and quantifiers**: $\forall x.\; \varphi(x)$ ("for all $x$, $\varphi$ holds") and $\exists y.\; \varphi(y)$ ("there exists a $y$ for which $\varphi$ holds").
- **Function symbols and predicate symbols** of fixed arity. Constants are 0-ary functions.
- **Terms** built from variables and function applications.

A first-order **signature** $\Sigma$ lists the function and predicate symbols and their arities. A **structure** $\mathcal{M}$ for $\Sigma$ gives:

- A nonempty domain $|\mathcal{M}|$ — the set of objects the quantifiers range over (e.g. all the integers).
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

## Quantifier order changes the meaning

A **structure** (the integers $\mathbb{Z}$ with $+$, $<$, etc.) is what makes a quantified sentence true or false. The *order* of mixed quantifiers is not cosmetic — swap $\forall$ and $\exists$ and you usually change the claim:

| Sentence | Reading | Over $\mathbb{Z}$ |
|---|---|---|
| $\forall x.\,\exists y.\; y > x$ | every $x$ has *some* bigger $y$ (depends on $x$) | **true** |
| $\exists y.\,\forall x.\; y > x$ | *one* $y$ beats *every* $x$ at once | **false** |

Same atoms, opposite verdicts. The first lets $y$ depend on $x$; the second demands a single $y$ that works for all $x$.

- **Same-type swaps are safe**: $\forall x.\forall y \equiv \forall y.\forall x$, and $\exists x.\exists y \equiv \exists y.\exists x$.
- **De Morgan for quantifiers** (negation toggles the quantifier): $\neg\forall x.\,\varphi \equiv \exists x.\,\neg\varphi$ and $\neg\exists x.\,\varphi \equiv \forall x.\,\neg\varphi$.

::: notes
This is the FOL subtlety we stress with the Lyapunov-stability example: "for all $\epsilon>0$ there exists $\delta>0$ ..." means something completely different from "there exists $\delta>0$ for all $\epsilon>0$ ..." — in the first, $\delta$ may depend on $\epsilon$; swapping forces one $\delta$ to work uniformly. Engineers who have seen $\epsilon$–$\delta$ definitions in control theory or analysis already have the intuition; this slide just names it. Practical payoff for tool use: when you write a spec for Z3 or Lean, the quantifier order *is* the specification — getting it backwards is the classic way to "verify" the wrong property. The quantifier De Morgan laws are exactly what a solver uses to push a goal into the $\Gamma \cup \{\neg\varphi\}$ refutation form.
:::

---

## Decidable theories that matter

| Theory | Domain | Examples | Decidable? |
|---|---|---|---|
| **EUF** (equality + uninterpreted functions) | black-box functions | $f(a) = b \wedge f(b) \neq c$ | yes |
| **LIA** (linear integer arithmetic) | $\mathbb{Z}$, linear | $3x + 2y = 7 \wedge x > 0$ | yes |
| **LRA** (linear real arithmetic) | $\mathbb{R}$, linear | $x + y \le 1 \wedge x \ge 0$ | yes |
| **BV** (bit-vectors) | fixed-width words | $x \;\&\; (x-1) = 0$ | yes |
| **Arrays** | $A : I \to V$ | $\text{store}(a, i, v)[i] = v$ | yes |
| **NIA** (nonlinear integer arithmetic) | $\mathbb{Z}$, nonlinear | $x \cdot y = z \wedge \dots$ | **undecidable** |
| **NRA** (nonlinear real arithmetic) | $\mathbb{R}$, nonlinear | $x^2 + y^2 = 25$ | decidable (Tarski 1951); CAD (Collins 1975) is doubly-exponential |

*"Linear"* = never multiply two unknowns; *"nonlinear"* allows $x\cdot y$ or $x^2$. A *bit-vector* is an integer in a fixed number of bits (like a 32-bit machine word); $\&$ is bitwise-AND. For arrays, $\text{store}(a,i,v)$ is array $a$ with index $i$ set to $v$, and $a[i]$ reads index $i$. EUF treats each function as a black box — equal inputs give equal outputs, nothing more.

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
- $S_0 \subseteq S$ — the initial states ($\subseteq$ = "is a subset of": every initial state is a state)
- $\rightarrow \;\subseteq S \times S$ — the transition relation (write $s \rightarrow s'$ for "$s$ can step to $s'$")
- $AP$ — a set of atomic propositions
- $L : S \to 2^{AP}$ — a labeling ($2^{AP}$ is the *powerset* of $AP$ — all its subsets — so $L(s)$ is the set of propositions true in state $s$)

Heads-up: the arrow $\rightarrow$ here is the *transition* relation between states — a different use from logical "implies" $\to$ in the logic section.

A **trace** is a (finite or infinite) sequence $s_0, s_1, s_2, \dots$ with $s_0 \in S_0$ and $s_i \rightarrow s_{i+1}$ for all $i$.

A state $s$ is **reachable** if some trace contains it.

::: notes
This is the central formalism for the entire week. Every model checker, theorem prover for programs, and bounded checker we will see operates on this tuple — sometimes implicitly. SMT and BMC operate on it via unrollings; nuXmv operates on it directly; Lean encodes it as an inductive predicate; CBMC implicitly constructs it from C source. Once you understand this tuple, you understand the substrate of every tool we'll meet.
:::

---

## The running example: the counter

State and input:

- `mode ∈ {off, on}` (∈ = "is an element of"; mode is off or on)
- `x ∈ ℕ` (ℕ = the natural numbers 0, 1, 2, …; the dynamics keep it in 0–10 — exactly what we'll *prove*)
- `press : Bool` (external input — true if the button is pressed this step)

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
Same little system we'll see every day. Five tools, four pillars, one example. Pick the easiest non-trivial reactive system you can. The counter is small enough to fit on a slide, large enough that the model checker won't enumerate it instantly, and structured enough that the inductive-invariant method is illuminating on Day 3 (we bundle its three safety facts into one invariant and prove it by induction; the case where strengthening is genuinely *forced* is a separate two-counter example).
:::

---

## The counter, formally

$$S = \{\text{off}, \text{on}\} \times \mathbb{N}$$
$$S_0 = \{(\text{off}, 0)\}$$

Transition relation $\rightarrow$ (parameterized by a non-deterministic `press` at each step):

$$\begin{aligned}
(\text{off}, x) &\xrightarrow{\neg p} (\text{off}, x) \\
(\text{off}, x) &\xrightarrow{p} (\text{on}, x) \\
(\text{on}, x) &\xrightarrow{\neg p \;\wedge\; x < 10} (\text{on}, x + 1) \\
(\text{on}, x) &\xrightarrow{p \;\vee\; x \ge 10} (\text{off}, 0)
\end{aligned}$$

Atomic propositions: $\text{mode}\_\text{off}, \text{mode}\_\text{on}, x{=}0, x{=}10, \dots$ as needed.

::: notes
The four-clause case analysis is the same case analysis we'll see in C (Day 4), in Lean (Day 3, in `counterInv_step`), in Cryptol (Day 4, in `step`), and in SMV (Day 2, in `next`). Once you've stared at it in one notation, the others become drop-in.
:::

---

## The counter as a symbolic state machine

<svg viewBox="0 0 760 300" style="display:block;margin:0.3em auto;max-width:90%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs>
    <marker id="sym-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/>
    </marker>
  </defs>
  <line x1="56" y1="160" x2="124" y2="160" stroke="#5b6168" stroke-width="1.8" marker-end="url(#sym-ah)"/>
  <text x="90" y="150" text-anchor="middle" font-size="12" fill="#5b6168">init x = 0</text>
  <path d="M165,120 C152,76 228,76 215,120" fill="none" stroke="#5b6168" stroke-width="1.8" marker-end="url(#sym-ah)"/>
  <text x="190" y="66" text-anchor="middle" font-size="12.5" fill="#146a96">¬press / x′ := x</text>
  <path d="M535,120 C522,74 598,74 585,120" fill="none" stroke="#5b6168" stroke-width="1.8" marker-end="url(#sym-ah)"/>
  <text x="560" y="64" text-anchor="middle" font-size="12.5" fill="#146a96">¬press ∧ x &lt; 10 / x′ := x+1</text>
  <line x1="252" y1="160" x2="497" y2="160" stroke="#5b6168" stroke-width="1.8" marker-end="url(#sym-ah)"/>
  <text x="375" y="151" text-anchor="middle" font-size="13" fill="#146a96">press / x′ := x</text>
  <path d="M520,204 Q375,286 236,206" fill="none" stroke="#5b6168" stroke-width="1.8" marker-end="url(#sym-ah)"/>
  <text x="375" y="276" text-anchor="middle" font-size="12.5" fill="#146a96">press ∨ x = 10 / x′ := 0</text>
  <ellipse cx="190" cy="160" rx="62" ry="42" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="190" y="166" text-anchor="middle" font-size="18" fill="#1c1c1c">off</text>
  <ellipse cx="560" cy="160" rx="62" ry="42" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="560" y="166" text-anchor="middle" font-size="18" fill="#1c1c1c">on</text>
</svg>

Two control modes; the count `x` stays a **variable**. Each edge is **guard / update** — exactly the symbolic transition relation $\varphi_T$ over $(s, s')$. The *next* slide "unrolls" this into explicit states by enumerating `x = 0, 1, …, 10`.

::: notes
This is the abstract/symbolic view a model checker actually reasons about: the control graph is tiny (two modes) and `x` is carried symbolically via guard/update edge labels — an *extended* finite-state machine. The next slide unrolls it into explicit (mode, x) states; nuXmv (Day 2) instead keeps it symbolic, representing whole *sets* of states as formulas/BDDs and computing successors of the relation `x′ := x+1` directly. Same four guards as every other encoding, now drawn as a labeled graph. The primed `x′` is the standard convention for "value in the next state" — it returns on Day 2 in the symbolic transition relation.
:::

---

## The counter as an explicit state machine

<svg viewBox="0 0 960 252" style="display:block;margin:0.3em auto;max-width:95%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs>
    <marker id="ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/>
    </marker>
  </defs>
  <line x1="20" y1="150" x2="60" y2="150" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah)"/>
  <text x="40" y="142" text-anchor="middle" font-size="12" fill="#5b6168">start</text>
  <path d="M720,126 L720,64 L114,64 L114,126" fill="none" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah)"/>
  <text x="417" y="56" text-anchor="middle" font-size="13" fill="#146a96">press ∨ x = 10</text>
  <path d="M94,176 C74,232 154,232 134,176" fill="none" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah)"/>
  <text x="114" y="244" text-anchor="middle" font-size="12" fill="#146a96">¬press</text>
  <line x1="166" y1="150" x2="276" y2="150" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah)"/>
  <text x="221" y="142" text-anchor="middle" font-size="13" fill="#146a96">press</text>
  <line x1="382" y1="150" x2="450" y2="150" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah)"/>
  <text x="416" y="120" text-anchor="middle" font-size="12.5" fill="#146a96">¬press ∧ x &lt; 10</text>
  <line x1="554" y1="150" x2="668" y2="150" stroke="#5b6168" stroke-width="1.8" stroke-dasharray="5 4" marker-end="url(#ah)"/>
  <rect x="62" y="126" width="104" height="48" rx="10" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="114" y="156" text-anchor="middle" font-size="17" fill="#1c1c1c">off, 0</text>
  <rect x="278" y="126" width="104" height="48" rx="10" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="330" y="156" text-anchor="middle" font-size="17" fill="#1c1c1c">on, 0</text>
  <rect x="450" y="126" width="104" height="48" rx="10" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="502" y="156" text-anchor="middle" font-size="17" fill="#1c1c1c">on, 1</text>
  <text x="612" y="160" text-anchor="middle" font-size="26" fill="#5b6168">⋯</text>
  <rect x="668" y="126" width="104" height="48" rx="10" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="720" y="156" text-anchor="middle" font-size="17" fill="#1c1c1c">on, 10</text>
</svg>

This **unrolls** the symbolic machine above: `x` becomes part of the state. The initial state `off, 0` (gold); `on, 0 … on, 10` count up under `¬press`; `press` or `x = 10` returns to `off`. Five drawn states stand in for the twelve reachable ones.

::: notes
The same transition relation, drawn as a state machine. This is exactly what nuXmv builds internally on Day 2 and what Lean reasons about by induction on Day 3. The chain structure (count up, then reset) is the running example for the inductive-invariant method on Day 3 (here `x ≤ 10` is already inductive thanks to the `x < 10` guard; the deeper "strengthen a too-weak invariant" lesson uses a separate two-counter example).
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

The state space is infinite ($x \in \mathbb{N}$), but the reachable set is just **12 states**: $\{(\text{off}, 0)\} \cup \{(\text{on}, k) : 0 \le k \le 10\}$ — which is exactly why "is $x = 11$ ever reachable?" is a sharp safety question.

The safety property $x \le 10$ holds on all twelve. ✓

::: notes
We could verify by hand because the *reachable* state space is finite and small. Day 2's nuXmv does this enumeration automatically. Day 3's Lean does it by induction without ever enumerating. Day 1's Z3 does a *bounded* version — "is x = 11 reachable in ≤ N steps for N = 5, 10, 30?" and answers UNSAT for each. We trade completeness for not having to construct the state space.
:::

---

## Reachable, bounded, bad — the picture

<svg viewBox="0 0 680 330" style="display:block;margin:0.3em auto;max-width:78%;height:auto" font-family="Inter, system-ui, sans-serif">
  <ellipse cx="310" cy="180" rx="300" ry="144" fill="#f6f8fa" stroke="#9aa3ab" stroke-width="1.8"/>
  <text x="310" y="20" text-anchor="middle" font-size="15" fill="#5b6168">all states S — infinite (mode × ℕ)</text>
  <ellipse cx="252" cy="186" rx="218" ry="118" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="232" y="96" text-anchor="middle" font-size="15" fill="#146a96">reachable — 12</text>
  <ellipse cx="200" cy="200" rx="132" ry="72" fill="#cfe6f7" stroke="#146a96" stroke-width="2"/>
  <text x="200" y="190" text-anchor="middle" font-size="14" fill="#0e4f70">reachable in ≤ N steps</text>
  <text x="200" y="212" text-anchor="middle" font-size="11.5" fill="#0e4f70">(what BMC explores)</text>
  <circle cx="565" cy="150" r="9" fill="#c0392b"/>
  <text x="565" y="131" text-anchor="middle" font-size="13.5" fill="#922b21">x = 11</text>
  <text x="565" y="180" text-anchor="middle" font-size="11.5" fill="#922b21">bad &amp;</text>
  <text x="565" y="196" text-anchor="middle" font-size="11.5" fill="#922b21">unreachable</text>
</svg>

- **All states** (infinite): every $(\text{mode}, x)$ pair you could write down ($x \in \mathbb{N}$).
- **Reachable** (12): what the system can actually get to from $(\text{off}, 0)$.
- **Reachable in $\le N$ steps**: what bounded model checking explores — it grows toward the reachable boundary as $N$ rises.
- **Bad** ($x = 11$): sits *outside* reachable, so no trace ever hits it — BMC keeps returning UNSAT; Day 2 *proves* it can never happen.

::: notes
This one picture is the conceptual core of the week. Bounded checking searches the innermost ring; the bug we care about sits outside the reachable set entirely. BMC can only ever certify "not in the ≤N ring." To claim "unreachable, ever" you need the full-reachability methods of Day 2 (exhaust the reachable set) or Day 3 (an inductive argument that never enumerates). The gap between the ≤N ring and the reachable boundary is exactly the gap bounded methods cannot close.
:::

---

## Quick check: which is which?

Match each English sentence to one of (a), (b), or (c).

1. "On every trajectory from any initial state, $x$ stays in $[0, 10]$."
2. "There exists some trajectory along which $x = 10$ eventually."
3. "Whenever mode is off, $x$ must be 0."

Choices (formulas in informal English):

- (a) Safety invariant
- (b) Reachability witness
- (c) Conditional invariant

::: notes
Ask the class. Expected: 1 → safety invariant; 2 → reachability witness (`EF` in CTL on Day 2); 3 → conditional invariant. The point is to teach the vocabulary of three property categories we'll meet over the week: safety (always-good), reachability (some-good-eventually), and conditional safety (implication). All three are decidable by SMT in bounded form, by model checking in unbounded form.
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

## Proving by refutation: the one move behind every solver

A SAT/SMT solver does essentially one thing: **find a model** (a satisfying assignment) — or report there is none (**UNSAT**). So how can it *prove* a property, which is a claim about *all* inputs?

**Assert the negation and check satisfiability.**

- `φ` is **valid** (always true) **iff** `¬φ` is **UNSAT**.
- `P` **entails** `Q` **iff** `P ∧ ¬Q` is **UNSAT** — nothing makes the premises true and the conclusion false.

> *Socrates:* assert `∀x. Man(x) → Mortal(x)`, `Man(socrates)`, **and** `¬Mortal(socrates)`. The solver returns **unsat** ⇒ the syllogism is valid.

This is the spine of the whole day: the live demos and bounded model checking all *assert that something bad is possible and let the solver fail to find it.*

::: notes
The conceptual key to the entire SAT/SMT day, pulled to the front — it is the opening move of every SMT tutorial (cvc5/Z3 beginners; CMU 15-414 states it as "P → Q is valid iff P ∧ ¬Q is unsatisfiable"). Students are puzzled that a tool which "looks for a satisfying assignment" can *prove* anything, since proof quantifies over all inputs. Resolve it here: to prove a universal claim you ask the solver for a single counterexample, and "unsat" — no counterexample exists — *is* the proof. Validity of φ = unsatisfiability of ¬φ; entailment of Q from P = unsatisfiability of P ∧ ¬Q. The Socrates syllogism is the canonical one-liner. Then flag the through-line: the pigeonhole and Sudoku demos are satisfiability questions, and bounded model checking asserts "a bad state is reachable in k steps" and reads UNSAT as "safe to depth k." Same move every time — and it rhymes with Day 2's `L(K) ∩ L(¬φ) = ∅` and Day 3's proof by contradiction. This is also why the verification picture from L1 had two outputs: a model = a counterexample, UNSAT = a proof.
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

## DPLL in action: a tiny trace

Solve $\varphi = (p \vee q) \wedge (\neg p \vee q) \wedge (p \vee \neg q)$. Decide a variable, propagate the forced literals, backtrack on conflict.

<svg viewBox="0 0 720 270" style="display:block;margin:0.4em auto;max-width:74%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs>
    <marker id="ah2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/>
    </marker>
  </defs>
  <line x1="360" y1="58" x2="175" y2="102" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah2)"/>
  <text x="240" y="78" text-anchor="middle" font-size="13" fill="#146a96">p = ⊥</text>
  <line x1="360" y1="58" x2="545" y2="102" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah2)"/>
  <text x="480" y="78" text-anchor="middle" font-size="13" fill="#146a96">p = ⊤</text>
  <line x1="175" y1="146" x2="175" y2="190" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah2)"/>
  <line x1="545" y1="146" x2="545" y2="190" stroke="#5b6168" stroke-width="1.8" marker-end="url(#ah2)"/>
  <rect x="300" y="14" width="120" height="44" rx="9" fill="#f6f8fa" stroke="#5b6168" stroke-width="1.8"/>
  <text x="360" y="41" text-anchor="middle" font-size="15" fill="#1c1c1c">decide p</text>
  <rect x="85" y="102" width="180" height="44" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="175" y="129" text-anchor="middle" font-size="14" fill="#1c1c1c">unit ⇒ q = ⊤</text>
  <rect x="103" y="190" width="144" height="44" rx="9" fill="#fdecea" stroke="#c0392b" stroke-width="2"/>
  <text x="175" y="217" text-anchor="middle" font-size="14" fill="#922b21">✗ conflict</text>
  <rect x="455" y="102" width="180" height="44" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="545" y="129" text-anchor="middle" font-size="14" fill="#1c1c1c">unit ⇒ q = ⊤</text>
  <rect x="463" y="190" width="164" height="44" rx="9" fill="#eef7ee" stroke="#27843f" stroke-width="2"/>
  <text x="545" y="217" text-anchor="middle" font-size="13.5" fill="#1e6b32">✓ SAT: p = q = ⊤</text>
</svg>

- $p = \bot$: clause $(p \vee q)$ forces $q = \top$ → now $(p \vee \neg q)$ has all literals false: **conflict**, backtrack.
- $p = \top$: clause $(\neg p \vee q)$ forces $q = \top$ → every clause satisfied: **SAT**, model $p = q = \top$.

::: notes
The whole DPLL loop on the smallest formula that exercises it: one decision, a unit-propagation cascade on each branch, one conflict, one backtrack, one satisfying leaf. "Unit propagation" = when a clause has exactly one unassigned literal left, that literal is forced true. CDCL's one addition: when you hit the conflict on the left, *learn* the clause that records "p = ⊥ leads to failure" so the search never revisits it. Every industrial SAT solver is this loop with better bookkeeping (watched literals, VSIDS, restarts — next slide).
:::

---

## DPLL's two free moves: unit propagation + pure literals

Before DPLL ever *guesses*, it applies two rules that force assignments for free:

- **Unit propagation** — a clause with one unassigned literal left *forces* that literal true (it's the only way to satisfy the clause). One forced literal often shrinks other clauses to units → a **cascade**.
- **Pure literal** — a variable that appears with only *one* polarity (always $x$, or always $\neg x$) in the remaining clauses can be set to satisfy all of them. It can never cause a conflict, so set it and drop those clauses.

Worked run on
$$\varphi = (\neg a \vee b)\,(\,\neg b \vee c)\,(a \vee c)\,(d \vee \neg c)\,(e).$$

| Step | Rule | Action | Result |
|---|---|---|---|
| 1 | unit | clause $(e)$ is a unit | $e = \top$ |
| 2 | pure | $d$ appears only positively | $d = \top$, drop $(d \vee \neg c)$ |
| 3 | decide | guess on $a$ | $a = \top$ |
| 4 | unit | $(\neg a \vee b)$ now forces $b$ | $b = \top$ |
| 5 | unit | $(\neg b \vee c)$ now forces $c$ | $c = \top$ |
| 6 | done | $(a\vee c)$ already true | **SAT**: $a{=}b{=}c{=}d{=}e{=}\top$ |

::: notes
This is the deeper companion to the tiny-trace slide: it exercises *both* free rules plus one decision, exactly the components we call out in Week 8 ("early termination, pure literals, unit clauses"). Talk through the intuition we give for pure literals: if a variable only ever shows up positive, making it true can only *help* — it satisfies clauses and can never falsify one — so there's no risk in setting it without a decision. Unit propagation is the workhorse; on industrial instances the solver spends ~90% of its time here. Note we got all the way to SAT with a *single* decision (step 3) — the two free rules did the rest. That ratio (lots of propagation, few decisions) is why DPLL beats the 2^n truth table so badly in practice, even though no one can prove a good average-case bound (our honest "probably no one knows").
:::

---

## Boolean resolution: a proof of UNSAT

When a formula is unsatisfiable, DPLL's failure is itself a **proof** — and the proof rule is **resolution**:

$$\frac{(A \vee \ell)\qquad (B \vee \neg \ell)}{(A \vee B)}$$

Two clauses sharing a variable $\ell$ with *opposite* signs resolve into a new clause that drops $\ell$ (the **resolvent**). Keep resolving; if you ever derive the **empty clause** $\square$ (a clause with no literals — unsatisfiable by definition), the original formula is UNSAT.

Refute $\varphi = (p)\,(\neg p \vee q)\,(\neg q)$:

| # | Clauses resolved | On | Resolvent |
|---|---|---|---|
| 1 | $(p)$, $(\neg p \vee q)$ | $p$ | $(q)$ |
| 2 | $(q)$, $(\neg q)$ | $q$ | $\square$ |

Empty clause derived $\Rightarrow$ **UNSAT**. This is a checkable certificate: a referee re-runs the two steps without trusting the solver.

<svg viewBox="0 0 560 256" style="display:block;margin:0.3em auto;max-width:62%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs><marker id="res-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6.5" markerHeight="6.5" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/></marker></defs>
  <line x1="92" y1="62" x2="188" y2="116" stroke="#5b6168" stroke-width="1.6" marker-end="url(#res-ah)"/>
  <line x1="240" y1="62" x2="222" y2="116" stroke="#5b6168" stroke-width="1.6" marker-end="url(#res-ah)"/>
  <text x="128" y="96" text-anchor="middle" font-size="11.5" fill="#146a96">resolve p</text>
  <line x1="210" y1="158" x2="318" y2="202" stroke="#5b6168" stroke-width="1.6" marker-end="url(#res-ah)"/>
  <line x1="446" y1="62" x2="364" y2="202" stroke="#5b6168" stroke-width="1.6" marker-end="url(#res-ah)"/>
  <text x="300" y="186" text-anchor="middle" font-size="11.5" fill="#146a96">resolve q</text>
  <rect x="52" y="24" width="78" height="38" rx="8" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="91" y="48" text-anchor="middle" font-size="14" fill="#1c1c1c">(p)</text>
  <rect x="180" y="24" width="120" height="38" rx="8" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="240" y="48" text-anchor="middle" font-size="14" fill="#1c1c1c">(¬p ∨ q)</text>
  <rect x="400" y="24" width="92" height="38" rx="8" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="446" y="48" text-anchor="middle" font-size="14" fill="#1c1c1c">(¬q)</text>
  <rect x="170" y="118" width="80" height="38" rx="8" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="210" y="142" text-anchor="middle" font-size="14" fill="#1c1c1c">(q)</text>
  <rect x="296" y="204" width="92" height="40" rx="8" fill="#fdecea" stroke="#c0392b" stroke-width="2"/>
  <text x="342" y="230" text-anchor="middle" font-size="13.5" fill="#922b21">▢ empty</text>
</svg>

*A resolution derivation: each node is a clause; the two parents resolve away one variable; reaching the empty clause $\square$ certifies UNSAT.*

::: notes
Resolution is our "another way to implement a SAT solver" and, crucially, the source of UNSAT *certificates*. The teaching point: SAT answers are asymmetric. A `sat` answer comes with a model anyone can plug in and check; an `unsat` answer needs a *proof*, and resolution is that proof — a sequence of clauses ending in the empty clause. Modern CDCL solvers emit exactly this (in the DRAT proof format) so the result can be independently verified; this matters enormously in verification, where you must trust the "no counterexample" verdict. Tie it back: resolution is the same inference rule from the Week 3 propositional-logic section (from $a\vee b$ and $\neg b\vee c$ derive $a\vee c$) — here aimed at deriving falsehood to prove unsatisfiability. The empty clause is "the disjunction of nothing," which is false, so deriving it from the premises means the premises entail false, i.e. are contradictory.
:::

---

## Cores and certificates: trust a tiny checker

The resolution proof above is a **certificate** — a small, independent checker re-validates "UNSAT" without trusting the solver. Solvers expose two practical handles (SMT-LIB commands):

- **`(get-proof)`** — the full derivation of `⊥`. A ~hundred-line checker can validate a solver that is hundreds of thousands of lines. *This is "AI proposes, the kernel disposes" at the solver level.*
- **`(get-unsat-core)`** — a *minimal* subset of your assertions that is already contradictory. It pinpoints **which** assumptions clashed — invaluable when a spec comes back `unsat` and you don't know why.

> A `sat` answer ships a **model** you can plug in and check. An `unsat` answer ships a **proof** you can re-check. Either way, you never have to trust the solver itself.

::: notes
The complement to the resolution slide, and a Day-1 landing of the course's central thesis. Both artifacts are SMT-LIB 2 standard commands. `get-proof` returns a machine-checkable proof object; the point a faculty audience appreciates is the *trust asymmetry* — the solver may be 300k lines of C++, but the proof checker is tiny and auditable, so the trusted computing base shrinks to that checker (a DRAT checker for SAT, cvc5's Ethos checker for SMT, the Lean kernel on Day 3). That is exactly the "trusted kernel" architecture the course keeps returning to: a giant solver (or an AI) proposes, a small checker disposes. `get-unsat-core` returns a minimal contradictory subset of your assertions — if you encode a spec and it unexpectedly comes back unsat, the core tells you which handful of constraints are fighting, the standard way to debug an over-constrained model (CMU 15-414 defines the minimal unsat core; cvc5 and Z3 implement both commands). The closing line restates the sat/unsat asymmetry from the resolution slide: both verdicts are independently checkable, which is the whole reason formal methods can be trusted even when the tools themselves are enormous.
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

## Inside a theory solver: equality + uninterpreted functions

How does the **EUF** theory solver decide a conjunction of equalities? **Congruence closure**:

1. Put each term in its own class; **merge** classes joined by an `=`.
2. **Congruence rule**: if $x_1 = y_1, \dots, x_n = y_n$ then $f(x_1,\dots) = f(y_1,\dots)$ — merge those too.
3. A disequality $u \ne v$ with $u, v$ in the **same** class $\Rightarrow$ **UNSAT**.

Decide $\;a=b,\ b=c,\ d=e,\ b=s,\ d=t,\ f(a, g(d)) \ne f(b, g(e))$:

<svg viewBox="0 0 780 300" style="display:block;margin:0.2em auto;max-width:82%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs>
    <marker id="euf-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/>
    </marker>
  </defs>
  <line x1="625" y1="88" x2="625" y2="130" stroke="#5b6168" stroke-width="1.6" marker-end="url(#euf-ah)"/>
  <text x="700" y="114" text-anchor="middle" font-size="11.5" fill="#146a96">congruence: d = e</text>
  <line x1="160" y1="88" x2="320" y2="228" stroke="#5b6168" stroke-width="1.6" marker-end="url(#euf-ah)"/>
  <line x1="560" y1="178" x2="450" y2="228" stroke="#5b6168" stroke-width="1.6" marker-end="url(#euf-ah)"/>
  <text x="300" y="200" text-anchor="middle" font-size="11.5" fill="#146a96">congruence: a = b, g(d) = g(e)</text>
  <rect x="50" y="44" width="200" height="44" rx="10" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="150" y="71" text-anchor="middle" font-size="15" fill="#1c1c1c">{ a, b, c, s }</text>
  <text x="150" y="34" text-anchor="middle" font-size="11" fill="#5b6168">a=b, b=c, b=s</text>
  <rect x="540" y="44" width="170" height="44" rx="10" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="625" y="71" text-anchor="middle" font-size="15" fill="#1c1c1c">{ d, e, t }</text>
  <text x="625" y="34" text-anchor="middle" font-size="11" fill="#5b6168">d=e, d=t</text>
  <rect x="540" y="134" width="170" height="44" rx="10" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="625" y="161" text-anchor="middle" font-size="15" fill="#1c1c1c">{ g(d), g(e) }</text>
  <rect x="225" y="228" width="310" height="44" rx="10" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="380" y="255" text-anchor="middle" font-size="14.5" fill="#1c1c1c">{ f(a,g(d)), f(b,g(e)) }</text>
  <text x="690" y="255" text-anchor="middle" font-size="14" fill="#922b21" font-weight="bold">⇒ UNSAT</text>
</svg>

The asserted $f(a,g(d)) \ne f(b,g(e))$ lands *inside* the gold class — contradiction.

::: notes
The EUF (equality + uninterpreted functions) decision procedure from Week 8 — congruence closure, the theory solver Z3 plugs into DPLL(T) for QF_UF. Walk it: the equalities merge {a,b,c,s} and {d,e,t}. The congruence rule fires twice: d=e ⇒ g(d)=g(e); then a=b together with g(d)=g(e) ⇒ f(a,g(d))=f(b,g(e)). But the input asserts f(a,g(d)) ≠ f(b,g(e)) — a disequality inside one class — so the conjunction is unsatisfiable. "Uninterpreted" means we know nothing about f and g except that equal inputs give equal outputs (congruence); that one axiom suffices to refute. This is how SMT reasons about opaque functions/APIs without modeling their internals — and it's the theory solver half of the DPLL(T) loop from the previous slide.
:::

---

## The DPLL(T) loop: SAT engine ⇄ theory solver

The congruence-closure procedure (previous slide) is one **theory solver**. DPLL(T) wires it to the SAT engine in a loop. First, **abstract** each theory atom to a fresh Boolean:

$$\underbrace{x \ge 0}_{p_1}\quad \underbrace{y \ge 0}_{p_2}\quad \underbrace{x + y < 0}_{p_3}$$

Now the SAT engine sees only $p_1 \wedge p_2 \wedge p_3$ and reasons Boolean-only. The cycle:

1. **SAT proposes** a Boolean assignment: $p_1 = p_2 = p_3 = \top$.
2. **Theory solver checks** the *concrete* meaning for $T$-consistency: is $x \ge 0 \wedge y \ge 0 \wedge x + y < 0$ satisfiable over the reals? **No.**
3. Theory solver returns one of:
   - **$T$-conflict** — the assignment is theory-inconsistent. Hand back a **theory lemma** $\neg(p_1 \wedge p_2 \wedge p_3)$, i.e. $\neg p_1 \vee \neg p_2 \vee \neg p_3$.
4. **SAT learns** that lemma as a new clause and **backjumps** — it will never propose all three together again.

Loop until the SAT engine finds a theory-consistent model (**sat**) or runs out of assignments (**unsat**).

::: notes
This is the loop we describe in the "Adding the Theory Solvers" slide: theory atoms map to Boolean atoms, the SAT solver builds a partial assignment, the theory solver checks T-consistency and can report conflicts, propagate literals, or learn clauses. The linear-arithmetic conflict here is our own example ("a > 0, c > 0, a + c < 0 — theory conflict, backtrack"); I've renamed to x, y for the running counter's variable style. The key mental model: the SAT engine is colorblind — it only sees p1, p2, p3 and has no idea that p3 contradicts p1 ∧ p2. The theory solver supplies that missing knowledge as a *clause*, in the SAT engine's own language, and the two keep talking until they agree. That hand-off (theory lemma expressed as a Boolean clause) is the entire trick that lets one SAT engine drive any theory — LIA via simplex, EUF via congruence closure, bit-vectors via bit-blasting. It's why Z3 is modular.
:::

---

## DPLL(T) round, drawn

<svg viewBox="0 0 720 210" style="display:block;margin:0.3em auto;max-width:84%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs><marker id="dpllt-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6.5" markerHeight="6.5" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/></marker></defs>
  <line x1="284" y1="84" x2="436" y2="84" stroke="#5b6168" stroke-width="1.8" marker-end="url(#dpllt-ah)"/>
  <text x="360" y="74" text-anchor="middle" font-size="11.5" fill="#146a96">propose: p₁ = p₂ = p₃ = ⊤</text>
  <line x1="436" y1="132" x2="284" y2="132" stroke="#5b6168" stroke-width="1.8" marker-end="url(#dpllt-ah)"/>
  <text x="360" y="150" text-anchor="middle" font-size="11.5" fill="#922b21">T-conflict: learn ¬p₁ ∨ ¬p₂ ∨ ¬p₃</text>
  <rect x="40" y="68" width="244" height="80" rx="10" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="162" y="96" text-anchor="middle" font-size="14" fill="#1c1c1c">SAT engine (Boolean DPLL)</text>
  <text x="162" y="120" text-anchor="middle" font-size="12" fill="#5b6168">clauses { p₁, p₂, p₃ }</text>
  <rect x="436" y="68" width="244" height="80" rx="10" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="558" y="96" text-anchor="middle" font-size="14" fill="#1c1c1c">theory solver</text>
  <text x="558" y="118" text-anchor="middle" font-size="12" fill="#5b6168">linear real arithmetic (simplex)</text>
  <text x="558" y="186" text-anchor="middle" font-size="11.5" fill="#922b21">x ≥ 0 ∧ y ≥ 0 ∧ x+y &lt; 0 : UNSAT over ℝ</text>
</svg>

The SAT engine and the theory solver pass messages until they agree:

- **propose** → SAT sends a candidate Boolean assignment.
- **check** → theory solver tests it over the real structure ($\mathbb{Z}$, $\mathbb{R}$, bit-vectors, …).
- **respond** → `T`-conflict (learn a clause), `T`-propagate (force a literal), or `T`-consistent (accept).

When the theory solver finally says *consistent*, that Boolean model **plus** the theory witness is the SMT model.

::: notes
The companion figure slide for the DPLL(T) loop, requested in the brief. Keep narration tight on delivery — the previous slide carries the worked numbers; this one is the picture to point at. Emphasize the three possible theory-solver responses (our T-conflict / T-propagate / T-learn) and that the loop is *exactly* the SAT loop from L3's DPLL slides with one extra participant. T-propagate is the optimization we're glossing: the theory solver can sometimes tell the SAT engine "given what you've committed to, this other literal is forced" before a full assignment, pruning the search early. Mention that this is live every time they run Z3 today — when z3_counter_bounded.py comes back sat/unsat, this loop ran underneath, with LIA as the theory.
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

Run it: [`z3_smtlib_demo.smt2`](https://github.com/ttj/fmaiv/blob/main/day01/examples/z3_smtlib_demo.smt2).

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

## SMT in the wild: generating a test case

We don't only ask "is this safe?" — we can ask the solver to **build an input** that drives code down a chosen path. Take Euclid's GCD:

```c
unsigned GCD(unsigned x, unsigned y) {   // requires y > 0
  while (true) {
    unsigned m = x % y;
    if (m == 0) return y;
    x = y;
    y = m;
  }
}
```

**Goal:** find inputs that make the loop run *exactly twice*. We can't know the trip count by hand — so we ask Z3.

::: notes
This is our Week-8 test-case-generation example, verbatim down to the GCD function. The framing: a `while(true)` loop whose iteration count depends on the inputs in a way that's painful to reason about by hand. Generating "an input that runs the loop exactly twice" (or ten times, or that hits a specific branch) is exactly what symbolic execution and tools like KLEE/CBMC do under the hood, and it's a different *use* of the same solver — synthesis of a witness rather than refutation. Tie it to the verification triple: here the "spec" is a path condition (loop runs twice), and the model Z3 returns is the test input. Next slide shows the encoding trick that makes the loop body into a flat formula.
:::

---

## The trick: single static assignment (SSA)

A variable is reassigned each iteration, but a formula can't reassign anything. **SSA** fixes this: give each write a **fresh subscripted name** ($x_0, x_1, \dots$), then conjoin one equation per statement. Unroll two iterations:

$$
\begin{aligned}
&\;(y_0 > 0) && \text{precondition}\\
\wedge\;&\;(m_0 = x_0 \bmod y_0)\;\wedge\;\neg(m_0 = 0) && \text{iter 1: didn't return}\\
\wedge\;&\;(x_1 = y_0)\;\wedge\;(y_1 = m_0) && \text{iter 1: updates}\\
\wedge\;&\;(m_1 = x_1 \bmod y_1)\;\wedge\;(m_1 = 0) && \text{iter 2: returned}
\end{aligned}
$$

`check-sat` → **sat**, with model $x_0 = 2,\; y_0 = 4$ (then $m_0=2,\ x_1=4,\ y_1=2,\ m_1=0$). So `GCD(2, 4)` runs the loop exactly twice. ($a \bmod b$ = remainder; the subscripts are *versions*, not array indices.)

::: notes
SSA is the encoding backbone of every program-level verification tool we'll meet — and it returns explicitly in Day 4 with CBMC, which SSA-converts and unrolls C automatically. Our note nails it: "conversion is to single static assignment (SSA) form prior to asserting." Spell out *why* it's needed: logic is timeless — `x = y; y = m` can't be two assignments to one `x`, so we mint x_0, x_1, ... and turn assignment (a command) into equality (a constraint). The two-iteration unrolling is structurally identical to the BMC unrolling we're about to do for the counter: same idea — replace state-over-time with subscripted copies and conjoin a transition per step. Worth saying out loud: this is the *same* solver, same SMT-LIB, just pointed at a path condition instead of a safety property. The model x0=2, y0=4 is our own answer.
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

We'll run [`day01/examples/z3_smoke.py`](https://github.com/ttj/fmaiv/blob/main/day01/examples/z3_smoke.py) live.

::: notes
The Python interface is what we'll use for the rest of the day. Open `examples/z3_smoke.py`, run it on screen, watch it print Z3 version + sat + model. Then `z3_pigeonhole.py`, watch all five cases come back unsat. Then the main event: `z3_counter_bounded.py`. The point is to physically demonstrate that Z3 is a couple of `pip install` commands away.
:::

---

## Live: pigeonhole in SAT

[`day01/examples/z3_pigeonhole.py`](https://github.com/ttj/fmaiv/blob/main/day01/examples/z3_pigeonhole.py) — encode "$n+1$ pigeons into $n$ holes" as SAT.

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

## Live: Sudoku as constraints, not search

[`day01/examples/puzzles/sudoku.py`](https://github.com/ttj/fmaiv/blob/main/day01/examples/puzzles/sudoku.py) — one integer per cell, three "all-different" rules, plus the clues.

```python
cells = [[z3.Int(f"c_{r}_{c}") for c in range(9)] for r in range(9)]
for r in range(9):
    for c in range(9):
        s.add(cells[r][c] >= 1, cells[r][c] <= 9)        # each cell holds a digit 1–9
for r in range(9):
    s.add(z3.Distinct(cells[r]))                          # each row: all 9 different
for c in range(9):
    s.add(z3.Distinct([cells[r][c] for r in range(9)]))  # each column: all different
for br in range(3):
    for bc in range(3):                                   # each 3×3 box: all different
        s.add(z3.Distinct([cells[3*br+dr][3*bc+dc]
                           for dr in range(3) for dc in range(3)]))
# pin the given clues, then s.check() / s.model()
```

We never write a backtracking search — we *state what a solution is* and let Z3 find one. (`z3.Distinct(xs)` = "these values are pairwise unequal".)

Same shape, more puzzles in `examples/puzzles/`: [**N-Queens**](https://github.com/ttj/fmaiv/blob/main/day01/examples/puzzles/nqueens.py), [**KenKen**](https://github.com/ttj/fmaiv/blob/main/day01/examples/puzzles/kenken.py), [**magic squares**](https://github.com/ttj/fmaiv/blob/main/day01/examples/puzzles/magic_square.py).

::: notes
This is the single most important idea in the SMT half of the day: declarative, not imperative. The Sudoku rules are three families of Distinct constraints plus the clues; Z3 does all the search. Run it live — it solves the classic puzzle instantly and even verifies uniqueness with a blocking clause (assert the found grid is forbidden; if still sat, a second solution exists). Then point at the other puzzles as the take-home menu: KenKen adds arithmetic "cage" constraints, N-Queens adds diagonal constraints, magic squares add row/column/diagonal sum constraints — all the same "constraints, not search" shape.
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

## BMC, written as one formula

The five steps collapse into a single formula. Let $I(s)$ mean "$s$ is initial", $T(s, s')$ mean "$s$ can step to $s'$", and $p(s)$ be the safety property. The **bounded unrolling** to depth $k$:

$$
W(k)\;=\;\underbrace{I(s_0)}_{\text{start legal}}\;\wedge\;\underbrace{\bigwedge_{i=0}^{k-1} T(s_i, s_{i+1})}_{\text{a real }k\text{-step path}}\;\wedge\;\underbrace{\bigvee_{i=0}^{k}\neg p(s_i)}_{p\text{ fails somewhere}}
$$

Read it as three demands at once: *begin in an initial state*, *follow the transition relation for $k$ steps*, *and break $p$ at some step*.

$$\boxed{\;p \text{ holds on all paths of length} \le k \;\iff\; W(k) \text{ is UNSAT}\;}$$

- **SAT** → the model *is* a concrete counterexample trace $s_0 \to s_1 \to \dots$ that reaches a bad state.
- **UNSAT** → no violation within $k$ steps (says **nothing** about step $k{+}1$).

::: notes
This is the heart of the Week-8 "BMC as a SAT/SMT problem" slides, made explicit. The three conjuncts map one-to-one onto our encoding: initial-state constraint, the conjunction of transition relations joining step i to i+1, and the disjunction of ¬p over all steps. The boxed equivalence is the whole theory of BMC: "valid up to k iff the unrolling is unsatisfiable" — and it's just the $\Gamma \models \varphi \iff \Gamma \cup \{\neg\varphi\}$ unsat principle from L2, applied to a transition system. The big_or over ¬p is what makes this catch a violation at *any* step ≤ k, not just the last — matching the z3_counter_bounded.py code that ORs x[k]==forbidden over all k. Stress the asymmetry one more time: SAT hands you a trace you can replay; UNSAT is only a bounded guarantee. de Moura's Z3 runs the DPLL(T) loop on exactly this W(k).
:::

---

## The unrolling, drawn

<svg viewBox="0 0 620 184" style="display:block;margin:0.3em auto;max-width:76%;height:auto" font-family="Inter, system-ui, sans-serif">
  <defs><marker id="bmc1-ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6.5" markerHeight="6.5" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#5b6168"/></marker></defs>
  <line x1="8" y1="46" x2="32" y2="46" stroke="#5b6168" stroke-width="1.8" marker-end="url(#bmc1-ah)"/>
  <text x="20" y="37" text-anchor="middle" font-size="11.5" fill="#5b6168">I</text>
  <line x1="116" y1="46" x2="154" y2="46" stroke="#5b6168" stroke-width="1.8" marker-end="url(#bmc1-ah)"/>
  <text x="135" y="37" text-anchor="middle" font-size="12" fill="#146a96">T</text>
  <line x1="238" y1="46" x2="276" y2="46" stroke="#5b6168" stroke-width="1.8" marker-end="url(#bmc1-ah)"/>
  <text x="257" y="37" text-anchor="middle" font-size="12" fill="#146a96">T</text>
  <line x1="360" y1="46" x2="438" y2="46" stroke="#5b6168" stroke-width="1.8" stroke-dasharray="5 4" marker-end="url(#bmc1-ah)"/>
  <text x="399" y="38" text-anchor="middle" font-size="16" fill="#5b6168">⋯</text>
  <rect x="34" y="26" width="82" height="40" rx="9" fill="#faf7f0" stroke="#B49248" stroke-width="2"/>
  <text x="75" y="52" text-anchor="middle" font-size="14" fill="#1c1c1c">s₀</text>
  <rect x="156" y="26" width="82" height="40" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="197" y="52" text-anchor="middle" font-size="14" fill="#1c1c1c">s₁</text>
  <rect x="278" y="26" width="82" height="40" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="319" y="52" text-anchor="middle" font-size="14" fill="#1c1c1c">s₂</text>
  <rect x="440" y="26" width="82" height="40" rx="9" fill="#e7f3fb" stroke="#2b9fd4" stroke-width="2"/>
  <text x="481" y="52" text-anchor="middle" font-size="14" fill="#1c1c1c">s_k</text>
  <line x1="75" y1="66" x2="75" y2="98" stroke="#9aa3ab" stroke-width="1.4" stroke-dasharray="4 3"/>
  <line x1="197" y1="66" x2="197" y2="98" stroke="#9aa3ab" stroke-width="1.4" stroke-dasharray="4 3"/>
  <line x1="319" y1="66" x2="319" y2="98" stroke="#9aa3ab" stroke-width="1.4" stroke-dasharray="4 3"/>
  <line x1="481" y1="66" x2="481" y2="98" stroke="#9aa3ab" stroke-width="1.4" stroke-dasharray="4 3"/>
  <text x="75" y="112" text-anchor="middle" font-size="11" fill="#146a96">¬p?</text>
  <text x="197" y="112" text-anchor="middle" font-size="11" fill="#146a96">¬p?</text>
  <text x="319" y="112" text-anchor="middle" font-size="11" fill="#146a96">¬p?</text>
  <text x="481" y="112" text-anchor="middle" font-size="11" fill="#146a96">¬p?</text>
  <line x1="75" y1="120" x2="481" y2="120" stroke="#5b6168" stroke-width="1.4"/>
  <line x1="278" y1="120" x2="278" y2="142" stroke="#5b6168" stroke-width="1.6" marker-end="url(#bmc1-ah)"/>
  <rect x="150" y="142" width="256" height="32" rx="8" fill="#fdecea" stroke="#c0392b" stroke-width="2"/>
  <text x="278" y="163" text-anchor="middle" font-size="12.5" fill="#922b21">⋁ ¬p(sᵢ)?  →  SAT = a real bad path</text>
</svg>

*Every step is a fresh copy of the state variables; $T$ chains them; the property $p$ is tested at each copy, and the $\bigvee$ asks "did it fail anywhere?"*

::: notes
The requested BMC-unrolling figure: s0 → … → sk with ¬p checked at each step. This is the picture to leave on screen while running the live demo. The single most important thing to convey: "unrolling" literally means making k+1 timestamped copies of the state variables and wiring consecutive copies together with the transition relation — the exact same move as SSA on the GCD loop two slides back, just for a reactive system instead of straight-line code. Point out that the width of this picture (k) is the only knob; widen it and you search deeper. Day 2's nuXmv draws the same picture but can also stop widening once it proves a fixpoint — the completeness threshold, next slide.
:::

---

## When does bounded become complete?

BMC is a bug-finder: UNSAT at depth $k$ only certifies "safe for $\le k$ steps." When can we stop and claim "safe, **ever**"?

- **Completeness threshold (CT)** — a depth such that UNSAT up to $CT$ implies the property holds at *every* depth. If you check that far and still get UNSAT, you've actually proved it.
- One sound (if loose) value of $CT$ is the **diameter**: the longest shortest-path between any two reachable states — once you've unrolled past it, every reachable state has already appeared.

The catch (our own caveat): **computing the exact $CT$ is as hard as model checking itself.** In practice we use an over-approximation, and often just run out of resources first.

- Good case: systems *without counters* (e.g. some hardware) have small diameters — BMC closes quickly.
- Bad case: a counter to $N$ has diameter $\sim N$; deep bugs hide past any practical $k$.

::: notes
This is the Week-8 "completeness threshold" and "complexity of BMC" material, kept gentle. The honest story: BMC is fundamentally a refutation engine, and turning it into a proof requires knowing you've gone deep enough — the CT. We stress that finding the exact CT is itself as hard as the model-checking problem you were trying to avoid, so real tools over-approximate (via graph structure / diameter). Connect to the running example: our counter literally counts, so its diameter grows with the bound — which is *exactly* why Day 1's bounded check can never prove "x ≤ 10 forever" no matter how large we make k, and why we need Day 2 (fixpoint/BDD reachability) or Day 3 (induction). This is the precise mechanism behind the "reachable vs reachable-in-≤N" Euler picture from L2. The complexity punchline we give — SAT-based BMC is worst-case doubly exponential because k can reach the diameter (exponential in state vars) and each SAT call is exponential — is optional depth if time allows.
:::

---

## Worked BMC: the two-bit counter

The smallest system where the bound *matters*. Two bits $\ell, r$ count $00 \to 01 \to 10 \to 11 \to 00$; property $p = \neg(\ell \wedge r)$ ("never both bits set"):

$$
I:\;\neg \ell \wedge \neg r \qquad
T:\; \ell' = (\ell \oplus r) \;\wedge\; r' = \neg r
$$

($\oplus$ = exclusive-or; primes = next state.) Unroll and ask $W(k)$:

| $k$ | states reached | $\neg p$ hit? | $W(k)$ |
|---|---|---|---|
| 2 | $00, 01, 10$ | no | **UNSAT** — safe so far |
| 3 | $00, 01, 10, 11$ | **yes** at $s_3$ | **SAT** — counterexample! |

The model at $k=3$ is the trace $00 \to 01 \to 10 \to 11$ — the solver hands you the exact path to the bug.

::: notes
This is our own two-bit-counter BMC example ("for k = 2, W(k) is unsatisfiable; for k = 3, W(k) is satisfiable"). It's the perfect closing example because it shows *both* verdicts on one tiny system: at depth 2 the bad state 11 simply isn't reachable yet (UNSAT, false comfort), and at depth 3 it appears and BMC produces the trace (SAT). That jump from UNSAT to SAT as k crosses the depth of the bug is the entire personality of bounded model checking in one table. Contrast with our counter-to-10, where the *good* property holds and BMC keeps saying UNSAT forever — here the property is genuinely violated, so deeper search finds it. The transition relation ℓ' = ℓ⊕r, r' = ¬r is worth checking by hand on delivery: from 10, r flips to 1 and ℓ becomes 1⊕0=1, giving 11 — the violating state. Then Day 2 will verify the *fixed* counter (or prove this one violates G¬(ℓ∧r)) without picking any k.
:::

---

## Live: bounded counter in Z3

[`day01/examples/z3_counter_bounded.py`](https://github.com/ttj/fmaiv/blob/main/day01/examples/z3_counter_bounded.py)

```python
def bounded_reach_to(forbidden_x: int, num_steps: int):
    s = z3.Solver()
    mode = [z3.Int(f"mode_{k}") for k in range(num_steps + 1)]
    x    = [z3.Int(f"x_{k}")    for k in range(num_steps + 1)]
    press = [z3.Bool(f"press_{k}") for k in range(num_steps)]

    s.add(mode[0] == MODE_OFF, x[0] == 0)
    for k in range(num_steps):
        s.add(step(mode[k], x[k], press[k], mode[k+1], x[k+1]))
    # bad state reachable at ANY step k ≤ N  (the "≤ N" of BMC)
    s.add(z3.Or([x[k] == forbidden_x for k in range(num_steps+1)]))
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

## Quick check: predict the verdict

For each, predict SAT / UNSAT *before* I run it.

1. `(check-sat)` with `(x + y = 7) ∧ (x > 0) ∧ (y > 0)` in LIA — single step.
2. The counter, asking "can $x = 11$ in $\le 5$ steps?"
3. The counter, asking "can $x = 10$ in $\le 11$ steps?"
4. The pigeonhole with 100 pigeons into 99 holes.
5. The counter, asking "can $\text{mode} = \text{on} \wedge x = 0$ in $\le 1$ step?"

Take a guess for each — then we run each.

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

Adapt [`day01/examples/z3_counter_bounded.py`](https://github.com/ttj/fmaiv/blob/main/day01/examples/z3_counter_bounded.py):

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
- **Plotkin.** *A structural approach to operational semantics*. JLAP 60–61 (2004). Structural operational semantics — defining program behavior via labelled transition systems.
- **Clarke, Henzinger, Veith, Bloem (eds.).** *Handbook of Model Checking*. Springer 2018. Chapters 1–3 cover today's material in depth.
- **Z3 Guide** (Microsoft): [microsoft.github.io/z3guide](https://microsoft.github.io/z3guide/) — interactive Z3 in the browser.

Full reference list at the end of the repo [README.md](../../README.md#background-references).

::: notes
References slide. Each one is on the curated repo-level reference list; we won't go through them in class. The Z3 Guide is the most useful single artifact for someone who wants to play more after class.
:::

---

## Next session: Day 2

GitHub repo: [github.com/ttj/fmaiv](https://github.com/ttj/fmaiv) (public). Slides also published at [ttj.github.io/fmaiv](https://ttj.github.io/fmaiv/).

Slack / Discord / email for questions between sessions.

::: notes
Logistics. The repo has all of today's `.py` files, the slides, and the next session's pre-class materials. Day 2 opens with a short recap and a "did anyone get stuck on homework?" check-in, then dives into nuXmv.
:::
