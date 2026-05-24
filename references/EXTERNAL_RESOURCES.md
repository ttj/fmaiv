# FMAIV — External Resources & Provenance

**Purpose.** This file is the citation-grade record of *everything consulted* while building and benchmarking the FMAIV short course: similar courses, conference tutorials, summer schools, tool tutorials, the neural-network-verification literature, the broader verification-techniques landscape, and the agentic-coding / AI-for-FM sources behind the Day 1 framing. It exists so the course can (a) credit its influences, (b) point participants at deeper material, and (c) be honest about what a 4-day intensive deliberately scopes out.

**How it was assembled.** Sources were gathered with web search and direct fetches; every URL in Part 6 was checked to resolve (HTTP 200) at the time of writing unless explicitly marked. Venues/years for the academic citations were verified against the publishers or the canonical tool repositories. This is itself an instance of the course's own thesis (agentic research, human-verified) — see Day 1, "How this course was built."

A condensed version of Part 1 and the key readings appears in the repo [`README.md`](../README.md#similar-courses--further-reading); this file is the full annotated set.

---

## Part 1 — Similar courses, tutorials & summer schools

Annotations use a *they do / we do* convention: what the other resource emphasizes vs. how FMAIV differs.

### 1a. Conference tutorials with public slides

- **Formal Verification of Deep Neural Networks: Theory and Practice** — Huan Zhang, Kaidi Xu, Shiqi Wang, Cho-Jui Hsieh. AAAI 2022 tutorial (updated as UIUC ECE598HZ, 2024). <https://neural-network-verification.com/>
  - 3-part slide deck + Colab demos using `auto_LiRPA` and the VNN-COMP-winning α,β-CROWN; bound propagation (CROWN), branch-and-bound complete verification, certified defense. *They do:* deep, hands-on NN verification with current SOTA tooling. *We do:* connect NN verification to the broader SAT/SMT/MC/TP stack and the AI-coding thesis; they treat it standalone. **This is the strongest true "conference tutorial with public slides + code" in the field and the closest analogue to our Day 4 NN segment.**
- **VNN-COMP / AAAI'26 lab on neural-network verification** (ours — Johnson et al.). <https://vnn-comp.github.io/#aaai2026>
  - Our own AAAI-2026 hands-on tutorial/lab: slides + Google Colab notebooks for benchmark proposers, verification-tool participants, and the broader AI community; ties directly to Day 4's NN-verification segment and the VNN-COMP material. The primary "extra materials" pointer for participants who want hands-on NN verification.
- **Satisfiability Modulo Theories: A Beginner's Tutorial** — Barrett, Tinelli, Barbosa, Niemetz, Preiner, Reynolds, Zohar. *Distinguished Tutorial*, FM 2024 (Milan). <https://link.springer.com/chapter/10.1007/978-3-031-71177-0_31> (open mirror: <https://par.nsf.gov/servlets/purl/10584608>)
  - SMT foundations, theory catalog, models and proofs, exercises in **both cvc5 and Z3**. *They do:* rigorous theory catalog + careful proofs/models. *We do:* situate Z3 in a 4-day arc (Day 1) and thread it forward to model checking and SAW.
- **An Overview of SMT and Its Applications** — Cesare Tinelli. ETAPS 2019 invited talk. <https://homepage.cs.uiowa.edu/~tinelli/talks/ETAPS-19.pdf>
  - Survey-grade "why SMT matters" deck; good Day 1 framing. *We do:* hands-on Z3 labs vs. their survey format.

### 1b. Summer / winter schools

- **SRI Summer School on Formal Techniques (SSFT)** — SRI CSL (Shankar, Graham-Lengrand, et al.). Annual; 15th edition May 23–29, 2026. <https://ssft-sri.github.io/>
  - **The closest sibling overall.** "Speaking Logic" background course + multi-day lectures on SMT, PVS theorem proving, model checking, symbolic execution, probabilistic reasoning; slides + videos archived. 2026 lineup includes Verus (Rust verification), Tamarin (crypto protocols), PVS, and LLM-driven compilation. *They do:* PVS, crypto-protocol and distributed-systems verification, week-long depth. *We do:* Lean 4 (vs PVS/Coq), an integrated CBMC+Cryptol+SAW Day 4, explicit AI-agentic thesis; 4 days vs 1–2 weeks.
- **Marktoberdorf Summer School 2026** — TU München / international faculty. Aug 2026. <https://sites.google.com/view/marktoberdorf2026/talks>
  - **Most thesis-aligned program found.** Includes Leonardo de Moura, "Lean 4 for Program Verification in the Age of AI"; John Mitchell, "Evaluating Agentic AI Systems"; Filliâtre (deductive verification), Grumberg (CHC), Müller (Viper/separation logic), Barthe (probabilistic), Protzenko (Rust). *They do:* probabilistic verification, CHC, separation logic, **agentic-AI evaluation methodology** (where this school is arguably ahead of our own thesis). *We do:* the full SAT→SMT→MC→TP→program-verification pipeline hands-on plus NN verification, as one integrated arc.
- **Oregon PL Summer School (OPLSS) 2025 — "Types, Logic, and Formal Methods."** June 23–Jul 5, 2025. <https://www.cs.uoregon.edu/research/summerschool/summer25/> · videos <https://www.youtube.com/@OPLSS>
  - Pientka (proof theory), de Paiva (categorical logic), Torlak (**Rosette** solver-aided programming), Urban (abstract interpretation), Vazou (LiquidHaskell). *They do:* deep type theory, abstract interpretation, solver-aided programming, refinement types. *We do:* model checking + automated tool verification (CBMC/SAW) + NN verification, which OPLSS largely omits.
- **SAT/SMT/AR Summer School 2025** — St Andrews, co-located with SAT/SMT/CP. Aug 6–8, 2025. <https://sat-smt-ar-school.gitlab.io/www/2025/> (series: <https://sat-smt-ar-school.gitlab.io/www/>)
  - Solver internals depth (DPLL/CDCL, theory combination), no prior expertise required. *We do:* use solvers as means to verification ends and extend into MC, TP, AI.
- **VTSA — Verification Technology, Systems & Applications** — MPI-INF / Liège / Nancy / Luxembourg. Annual. <https://resources.mpi-inf.mpg.de/departments/rg1/conferences/vtsa25/>
  - Past topics: verified compilation, runtime verification, TLA+/Quint, BIP, building deductive verifiers; videos on YouTube.
- **DeepSpec Summer School on Verified Systems** — Penn/MIT/Yale/Princeton. 2017/2018/2020 (archived). <https://deepspec.org/events/> · materials <https://github.com/DeepSpec/dsss17>
  - Coq-intensive end-to-end verified stacks (CompCert, CertiKOS, VST). *We do:* Lean 4 (not Coq), automated/bounded tools, AI-assisted proof — DeepSpec predates the LLM era.

### 1c. University courses with public slide decks

- **CMU 15-414 "Bug Catching: Automated Program Verification (and Testing)"** — Fredrikson / Martins (current, Why3); classic model-checking version Fall 2018. <https://www.cs.cmu.edu/~15414/> · MC notes <https://www.cs.cmu.edu/~15414/f18/index.html> (e.g. CTL checking <https://www.cs.cmu.edu/~15414/f18/lectures/22-ctl-checking.pdf>)
  - The canonical undergrad analogue. Recent semesters pivoted to **Why3 deductive verification**; the **Fall 2018** edition has the full LTL/CTL/Büchi/BMC/BDD notes that map onto our Day 2.
- **UC Berkeley EECS 219C "Computer-Aided Verification"** — Sanjit A. Seshia. <https://people.eecs.berkeley.edu/~sseshia/219c/>
  - SAT/CDCL, BDDs, SMT (theory combination, eager/lazy), model checking (Kripke, temporal logic, symbolic, BMC, interpolation, abstraction), plus **syntax-guided synthesis** and UCLID5. *They do:* synthesis (SyGuS), abstraction-refinement, UCLID5. *We do:* interactive theorem proving (Lean) + NN/program verification.
  - Companion: **UCLID5 tutorial** (SSFT'22 / SAT-SMT Winter School 2022) <https://people.eecs.berkeley.edu/~sseshia/uclid5-tutorial/>
- **Oxford "Computer-Aided Formal Verification"** — Marta Kwiatkowska (text: Kroening & Strichman, *Decision Procedures*). 2025–26. <https://www.cs.ox.ac.uk/teaching/courses/2025-2026/computeraidedverification/>
  - LTS, LTL/CTL/CTL*, symbolic + bounded MC via SAT, symbolic execution, Craig interpolation. *They do:* probabilistic model checking (PRISM), interpolation depth. *We do:* SMT-first Day 1, theorem proving, the AI angle.
- **Stanford CS357 "Advanced Topics in Formal Methods" / CS357S** — Clark Barrett. <https://web.stanford.edu/class/cs357/> (Winter 2026: <https://web.stanford.edu/class/cs357s/>)
  - SAT/SMT theory + students implement a small theory solver. Companion **CS256 "Formal Methods for Reactive Systems"** (temporal logic, ω-automata): <http://web.stanford.edu/class/cs256/>.
- **CMU 15-317 / 15-657 "Constructive Logic"** — Frank Pfenning. <https://www.cs.cmu.edu/~fp/courses/15317-f17/>
  - Intuitionistic & linear logic, proofs-as-programs — the foundations under our Day 1 (logic) and Day 3 (type-theoretic theorem proving).
- **MIT 6.822 "Formal Reasoning About Programs" (FRAP)** — Adam Chlipala. Book + course. <https://adam.chlipala.net/frap/> · repo <https://github.com/achlipala/frap>
  - Coq-based: operational semantics, model checking, abstract interpretation, type systems, program logics, concurrency — all machine-checked. *They do:* unify many techniques inside one proof assistant. *We do:* Lean 4 + standalone automated tools + NN verification + AI.
- **ETH Zürich "Program Verification"** — Peter Müller. <https://www.pm.inf.ethz.ch/education/courses/program-verification.html>
  - Hoare/separation logic and automated deductive verification via **Viper** (Z3-backed). *They do:* deep-but-narrow deductive verification of real languages. *We do:* MC + SMT + TP + NN breadth.

### 1d. Tool tutorials (the day-of lab companions)

- **Online Z3 Guide** (official, Microsoft Research) — <https://microsoft.github.io/z3guide/> (intro <https://microsoft.github.io/z3guide/docs/logic/intro/>). Browser-runnable; SMT-LIB, theories, quantifiers, optimization. The Day 1 lab companion.
- **Programming Z3** — Bjørner, de Moura, Nachmanson, Wintersteiger. <https://theory.stanford.edu/~nikolaj/programmingz3.html>. Python-binding tutorial + the algorithms inside Z3.
- **Theorem Proving in Lean 4 / Mathematics in Lean / Natural Number Game** — TPIL <https://leanprover.github.io/theorem_proving_in_lean4/> · MIL <https://leanprover-community.github.io/mathematics_in_lean/> · NNG4 <https://adam.math.hhu.de/> · hub <https://leanprover-community.github.io/learn.html>. The Day 3 Lean 4 onramp.
- **CBMC** (official, Diffblue/CProver, Kroening et al.) — <https://www.cprover.org/cbmc/> · repo <https://github.com/diffblue/cbmc> · community walkthrough <https://www.philipzucker.com/cbmc_tut/>. Our Day 4 bounded model checker.
- **Cryptol & SAW** (Galois, official) — Cryptol docs <https://tools.galois.com/cryptol> · *Programming Cryptol* book <https://cryptol.net/files/ProgrammingCryptol.pdf> · SAW docs <https://tools.galois.com/saw> and <https://saw.galois.com/intro/> · hands-on **cryptol-course** (incl. SAW labs) <https://github.com/weaversa/cryptol-course>. Our Day 4 spec + equivalence segment; the cryptol-course repo is the best structured lab set.
- **NuSMV / nuXmv** (official, FBK) — NuSMV <https://nusmv.fbk.eu/> · nuXmv <https://nuxmv.fbk.eu/>. The Day 2 symbolic model checker.

### 1e. Notable MOOCs / videos / surveys

- **OPLSS YouTube channel** — full multi-year lecture recordings. <https://www.youtube.com/@OPLSS>
- **"Formal Reasoning Meets LLMs: Toward AI for Mathematics and Verification"** — Yang, Poesia, He, Li, Lauter, Chaudhuri, Song. *Communications of the ACM*, 2025. <https://cacm.acm.org/research/formal-reasoning-meets-llms-toward-ai-for-mathematics-and-verification/> (DOI <https://dl.acm.org/doi/10.1145/3750038>). **The survey that most directly underpins our cross-cutting thesis.**
- **"Lean: Machine-Checked Mathematics and Verified Programming, Past and Future"** — de Moura, PLDI 2025 keynote. <https://pldi25.sigplan.org/details/pldi-2025-papers/98/>
- **Lean for the Curious Mathematician** tutorial series — 2023 <https://lftcm2023.github.io/tutorial/> · 2026 <https://amosturchet.github.io/lftcm26/>

---

## Part 2 — Neural-network verification literature

Fact-checked spine of the field; this is the source list behind Day 4's "Neural-network verification: the literature" slide. (Venues verified against publishers / arXiv / the VNN-COMP reports.)

**Hardness & SMT-style solving**
- Katz, Barrett, Dill, Julian, Kochenderfer. *Reluplex: An Efficient SMT Solver for Verifying Deep Neural Networks.* CAV 2017. <https://arxiv.org/abs/1702.01135> — proves exact ReLU robustness is NP-complete; the field's origin point.
- Wu, Isac, Zeljić, et al. *Marabou 2.0: A Versatile Formal Analyzer of Neural Networks.* CAV 2024 — the modern successor to Reluplex/Marabou.

**Family (a): bound propagation + branch-and-bound** (the α,β-CROWN lineage)
- Zhang, Weng, Chen, Hsieh, Daniel. *Efficient Neural Network Robustness Certification with General Activation Functions* (**CROWN**). NeurIPS 2018.
- Xu, Zhang, Wang, et al. *Fast and Complete: Enabling Complete Neural Network Verification…* (**α-CROWN**). ICLR 2021.
- Wang, Zhang, Xu, et al. *Beta-CROWN: Efficient Bound Propagation with Per-neuron Split Constraints…* (**β-CROWN**). NeurIPS 2021.
- Zhang, Wang, Xu, et al. *General Cutting Planes for Bound-Propagation-Based Neural Network Verification* (**GCP-CROWN**). NeurIPS 2022.
- Tool + library: α,β-CROWN <https://github.com/Verified-Intelligence/alpha-beta-CROWN>; `auto_LiRPA`.

**Family (b): reachability / abstract domains** (incl. our NNV)
- Gehr, Mirman, Drachsler-Cohen, Tsankov, Chaudhuri, Vechev. *AI2: Safety and Robustness Certification of Neural Networks with Abstract Interpretation.* IEEE S&P 2018 — the abstract-interpretation breakthrough.
- Singh, Gehr, Mirman, Püschel, Vechev. *Fast and Effective Robustness Certification* (**DeepZ**). NeurIPS 2018.
- Singh, Gehr, Püschel, Vechev. *An Abstract Domain for Certifying Neural Networks* (**DeepPoly**). POPL 2019. (Both ship in the ETH **ERAN** toolkit.)
- Tran, Manzanas Lopez, Musau, Yang, Nguyen, Xiang, Johnson. *Star-Based Reachability Analysis of Deep Neural Networks.* FM 2019 — **NNV star sets**.
- Tran, Bak, Xiang, Johnson. *Verification of Deep Convolutional Neural Networks Using ImageStars.* CAV 2020.
- Lopez, Choi, Tran, Johnson. *NNV 2.0: The Neural Network Verification Tool.* CAV 2023. Tool: <https://github.com/verivital/nnv>.
- Ivanov, Weimer, Alur, Pappas, Lee. *Verisig: verifying safety properties of hybrid systems with neural network controllers.* HSCC 2019 (Verisig 2.0, CAV 2021) — NN-in-the-loop CPS.

**Books / surveys**
- Albarghouthi. *Introduction to Neural Network Verification.* 2021. Free: <https://verifieddeeplearning.com> — the gentle on-ramp.
- Liu, Arnon, Lazarus, Strong, Barrett, Kochenderfer. *Algorithms for Verifying Deep Neural Networks.* Foundations and Trends in Optimization 4(3–4), 2021. <https://arxiv.org/abs/1903.06758> — the comprehensive technical reference.

**Frontier (transformers / LLMs)**
- Shi, Zhang, Chang, Huang, Hsieh. *Robustness Verification for Transformers.* ICLR 2020. <https://arxiv.org/abs/2002.06622> — the standing formal anchor; as of 2026 there is no mature, *sound* formal verifier for full-scale LLMs.
- Johnson. *Is Neural Network Verification Useful and What Is Next?* Allerton 2025. <https://hdl.handle.net/2142/130315> — position paper; the "Let's verify ChatGPT" grand challenge, open-SLM targets (OLMo2-1B, SmolLM2-135M), and the shift to NLP/guardrails/VLAs.
- **Neuro-symbolic verification** — Serbinowska & Johnson, *BehaVerify* (SEFM 2022); *Formalizing Stateful Behavior Trees* (FMAS 2024, best paper); *Neuro-Symbolic Behavior Trees and Their Verification* (NeuS 2025); Sasaki, Lopez, Johnson, *Neurosymbolic Finite and Pushdown Automata* (NeuS 2025). Tool: <https://github.com/verivital/behaverify>. Composes NN verification with classical model checking.

**Competition & standards**
- VNN-COMP reports: 2025 (6th, at SAIV/CAV) <https://arxiv.org/abs/2512.19007>; 2024 (5th) <https://arxiv.org/abs/2412.19985>. Hub: <https://vnn-comp.github.io/>. Hands-on **AAAI'26 VNN-COMP tutorial/lab** (slides + Colab): <https://vnn-comp.github.io/#aaai2026>.
- α,β-CROWN won VNN-COMP **2021, 2022, 2023, 2024, 2025** (five consecutive years). The reports note the best tools have converged on GPU-accelerated linear bound propagation with branch-and-bound.
- Standards: **ONNX** (network interchange) <https://onnx.ai>; **VNN-LIB** (property spec) <https://www.vnnlib.org/>.
- Benchmark: **ACAS Xu** collision-avoidance networks (the field's standard small-but-safety-critical benchmark, introduced with Reluplex).

---

## Part 3 — Other verification approaches (the wider landscape)

Source list behind Day 1's "The wider landscape: what this week samples" slide. These are the approaches a 4-day intensive can only *mention*; each is a deployed sub-field.

- **Static analysis** — Bessey, Block, Chelf, et al. *A Few Billion Lines of Code Later: Using Static Analysis to Find Bugs in the Real World* (the Coverity field report). CACM 53(2), 2010. Tools: Coverity; Clang Static Analyzer <https://clang-analyzer.llvm.org/>; Meta **Infer** (separation logic) <https://fbinfer.com/>; GitHub **CodeQL**; **Astrée** (sound, for embedded C).
- **Abstract interpretation** — Cousot & Cousot. *Abstract Interpretation: A Unified Lattice Model…* POPL 1977 (the founding paper). Flagship: **Astrée**, which proves absence of run-time errors in Airbus A340/A380 fly-by-wire C <https://www.absint.com/astree/>. Also IKOS, MOPSA.
- **Testing & fuzzing** — symbolic execution: **KLEE** (Cadar, Dunbar, Engler, OSDI 2008); whitebox fuzzing: **SAGE** (Godefroid, Levin, Molnar — Microsoft); property-based testing: **QuickCheck** (Claessen & Hughes, ICFP 2000); continuous fuzzing at scale: Google **OSS-Fuzz**, **AFL++** (Fioraldi et al., WOOT 2020).
- **Runtime verification** — Bartocci, Falcone, Francalanza, Reger (eds.). *Lectures on Runtime Verification.* LNCS 10457, Springer 2018.
- **Model-based design** — **Simulink/Stateflow** (MathWorks); **SCADE** (ANSYS/Esterel), built on the synchronous language **Lustre** (Halbwachs, Caspi, Raymond, Pilaud, *Proc. IEEE* 1991). Certified under **DO-178C** with its formal-methods (**DO-333**) and model-based (**DO-331**) supplements.
- **Deductive verification** — **Frama-C/ACSL** <https://frama-c.com/>; **Why3** <https://why3.org/>; **Dafny** (Leino, LPAR 2010); **Viper** (Müller, Schwerhoff, Summers, VMCAI 2016); **Verus** (verifies Rust).
- **Type & refinement systems** — **LiquidHaskell** (Vazou et al.); **F\*** <https://www.fstar-lang.org/>; **Rust** ownership types as lightweight static guarantees.
- **Translation validation / equivalence checking** — Pnueli, Siegel, Singerman. *Translation Validation.* TACAS 1998.
- **Program synthesis** (the dual of verification) — **SyGuS** (Syntax-Guided Synthesis) <https://sygus.org/>; **Rosette** (Torlak & Bodik) solver-aided programming.

The axis underneath all of these is **automation ↕ expressiveness**: testing and static analysis are push-button but shallow; theorem proving is arbitrarily expressive but laborious. Choosing the lightest tool that still answers your question is the engineering judgment the course trains.

---

## Part 4 — Agentic coding & AI-for-formal-methods

Source list behind Day 1's three agentic-coding slides and the "verification is the essential activity" thesis. **Caveat on statistics:** several figures below are from vendor / industry reports (Veracode, Sonar, MIT Sloan), not peer-reviewed studies; they are cited as such and the slides hedge them accordingly. The peer-reviewed anchors are FormAI and the slopsquatting paper.

**Agentic-coding tools** — Claude Code (Anthropic); Cursor; GitHub Copilot **coding agent** (GA May 2025); Devin (Cognition); OpenAI Codex; Windsurf; Aider. Editor + shell + **MCP** (Model Context Protocol) is the emerging stack for agents reaching external tools/data.

**Evidence AI-generated code is often wrong**
- Tihanyi, Bisztray, Jain, Ferrag, Cordeiro, Mavroeidis. *The FormAI Dataset: Generative AI in Software Security through the Lens of Formal Verification.* PROMISE 2023. <https://arxiv.org/abs/2307.02192> — **51.24%** of 112,000 GPT-generated C programs contained at least one vulnerability (detected via the ESBMC bounded model checker). *(Peer-reviewed; this is the strongest single anchor.)*
- Spracklen, et al. *We Have a Package for You! A Comprehensive Analysis of Package Hallucinations by Code-Generating LLMs.* USENIX Security 2025 — ~**19.7%** of recommended packages were hallucinated; basis for the "slopsquatting" supply-chain attack. *(Peer-reviewed.)*
- **Veracode** 2025 GenAI Code Security report — security flaws in ~**45%** of AI-written samples. *(Vendor report.)*
- **Sonar** 2026 developer survey — ~**42%** of committed code is AI-written; **96%** of developers don't fully trust it; only **48%** always verify ("verification debt"). *(Vendor report.)*
- **Apiiro.** *4× Velocity, 10× Vulnerabilities: AI Coding Assistants Are Shipping More Risks* (Sept 4 2025). <https://apiiro.com/blog/4x-velocity-10x-vulnerabilities-ai-coding-assistants-are-shipping-more-risks/> *(Vendor research; the source for the "4×/10×" figures on the Day 1 vibe slide.)*
- **MIT Sloan Management Review.** Anderson, Parker & Tan, *The Hidden Costs of Coding With Generative AI* (Aug 18 2025). <https://doi.org/10.63383/hadW7619> — productivity gains vs. technical debt that destabilizes systems. *(Practitioner research.)*
- **AWS** (Amazon Bedrock). *Minimize AI hallucinations and deliver up to 99% verification accuracy with Automated Reasoning checks* (Aug 6 2025). <https://aws.amazon.com/blogs/aws/minimize-ai-hallucinations-and-deliver-up-to-99-verification-accuracy-with-automated-reasoning-checks-now-available/> — formal methods applied directly to LLM outputs in production.

**Framing & the "vibe coding → engineering" arc**
- Andrej **Karpathy** — coined "vibe coding," Feb 2 2025 ("give in to the vibes… forget that the code even exists"). "Vibe coding" was Collins Dictionary's Word of the Year 2025.
- **Spec-driven development** — GitHub **Spec Kit**; AWS **Kiro** — the emerging bridge from vibe coding to disciplined agentic engineering (specs + tests + review + ownership).
- Instructor's own Gamma decks (private, used to source the framing): *From Vibe Coding to Vibe Engineering*; *Agentic Engineering for Autonomous CPS* (drone case study: ~52,800 LOC, 7 disciplines, ~5 days, with FMEA/FTA/GSN safety case).

**AI for formal methods / formal methods for AI**
- Yang, Poesia, He, Li, Lauter, Chaudhuri, Song. *Formal Reasoning Meets LLMs…* CACM 2025 (see Part 1e) — the roadmap survey.
- FM ↔ AI roadmap — Zhang et al. <https://arxiv.org/abs/2412.06512>.
- AWS **Automated Reasoning** / Provable Security (Byron Cook) — verification as a CI signal at production scale (s2n-TLS, s2n-bignum, Cedar in Lean).
- **DARPA PROVERS** program — formal methods at scale for defense software.
- Terence **Tao**. *Machine-Assisted Proof.* Notices of the AMS, January 2025 — a Fields medalist on AI/proof-assistant collaboration.
- AlphaProof / AlphaGeometry (DeepMind, IMO 2024 silver-medal level); DeepSeek-Prover — LLMs drafting Lean/formal proofs with a kernel as arbiter.

**Spring 2026 milestones (Day 1 "this season" slide)**
- **Anthropic — Project Glasswing** (2026). A frontier model ("Claude Mythos") used for *defensive* security surfaced **thousands of zero-day vulnerabilities** across every major OS and browser — incl. a 27-year-old OpenBSD bug and a 16-year-old FFmpeg bug that fuzzing had executed ~5M times and missed. <https://www.anthropic.com/glasswing> · NPR (Apr 11 2026). Pedagogical point: testing shows the *presence*, not the *absence*, of bugs (Dijkstra).
- **OpenAI — Erdős unit-distance conjecture** (May 20 2026). A general-purpose reasoning model autonomously *disproved* the 1946 conjecture (a fixed polynomial improvement; Will Sawin later pinned δ = 0.014) — the first AI-settled central open problem in a subfield. <https://openai.com/index/model-disproves-discrete-geometry-conjecture/> · TechCrunch, Scientific American (May 2026).

**Economics / small models (Day 1 economics slide)**
- R. Sutton, *The Bitter Lesson* (2019) — methods that ride more compute win; underwrites "generation keeps getting cheaper." <http://www.incompleteideas.net/IncIdeas/BitterLesson.html>
- Belcak, Heinrich, Fu, Dong, Muralidharan, Lin, Molchanov (NVIDIA + Georgia Tech), *Small Language Models are the Future of Agentic AI* (arXiv 2506.02153, June 2025) — SLMs (<10B) are often 10–30× cheaper per token and "good enough" for most agent nodes. <https://research.nvidia.com/labs/lpr/slm-agents/>
- Sasaki, Lopez, Johnson, *Neurosymbolic Finite and Pushdown Automata: Improved Multimodal Reasoning versus VLMs* (NeuS 2025) — neuro-symbolic automata beat GPT/Claude/Gemini-class VLMs on image-based string/arithmetic reasoning by large margins, ~1000× faster, for ~$10 of compute. (The "AI capex ≈ NASA's annual budget every few weeks" line is our order-of-magnitude framing from these talks.)

**The thesis.** When generation (of code, proofs, designs) becomes cheap and ubiquitous, the scarce and decisive activity becomes *establishing that the result is correct* — i.e., verification. That is the reason this course exists, stated in the language of the agentic-coding moment.

---

## Part 5 — Provenance appendix (every URL examined)

Recorded for citation completeness. "Used" = cited above or in slides/README; "examined" = consulted and judged; "discarded" = checked but not used (reason noted).

### Verified resolving and used / examined
- SSFT: <https://ssft-sri.github.io/> · SSFT16/17/19/20/21 archives under fm.csl.sri.com
- Marktoberdorf: <https://sites.google.com/view/marktoberdorf2026/talks> · 2024 talks · <https://events.model.in.tum.de/mod23/lectures.html> · <https://eapls.org/news/events/marktoberdorf-summer-school-2026-hj5qk/>
- OPLSS: <https://www.cs.uoregon.edu/research/summerschool/summer25/> (+ schedule, topics) · <https://www.youtube.com/@OPLSS>
- SAT/SMT/AR school: <https://sat-smt-ar-school.gitlab.io/www/> · <https://sat-smt-ar-school.gitlab.io/www/2025/> · <https://sicsa.ac.uk/event/sat-smt-ar-summer-school-2025/>
- VTSA: <https://resources.mpi-inf.mpg.de/departments/rg1/conferences/vtsa25/> (+ vtsa15–24)
- DeepSpec: <https://deepspec.org/events/> · dsss18/dsss20 · <https://github.com/DeepSpec/dsss17>
- CMU 15-414: <https://www.cs.cmu.edu/~15414/> · s24 · f18 (+ lecture PDFs 22-ctl-checking, 19-ctl, 05-semantics, 18-buchi; f17 19-software)
- CMU 15-317 Constructive Logic: <https://www.cs.cmu.edu/~fp/courses/15317-f17/> (+ 15317-f09, 15-816 modck, 15-820A Clarke lecture)
- Berkeley 219C: <https://people.eecs.berkeley.edu/~sseshia/219c/> (+ spr11/fa12/spr16 lectures, SyGuS) · UCLID5 tutorial <https://people.eecs.berkeley.edu/~sseshia/uclid5-tutorial/> · SSFT2022
- Oxford CAV: <https://www.cs.ox.ac.uk/teaching/courses/2025-2026/computeraidedverification/> (+ 2009/2013/2019/2022/2023/2024 archives)
- Stanford: <https://web.stanford.edu/class/cs357/> · <https://web.stanford.edu/class/cs357s/> · <http://web.stanford.edu/class/cs256/> · Barrett <https://theory.stanford.edu/~barrett/>
- MIT FRAP: <https://adam.chlipala.net/frap/> (+ book PDF) · <https://github.com/achlipala/frap> · <https://github.com/mit-frap/spring21>
- ETH Program Verification: <https://www.pm.inf.ethz.ch/education/courses/program-verification.html> · Viper <https://www.pm.inf.ethz.ch/research/viper.html>
- Z3: <https://microsoft.github.io/z3guide/> (+ logic/intro) · <https://github.com/microsoft/z3guide> · Programming Z3 <https://theory.stanford.edu/~nikolaj/programmingz3.html>
- Lean: TPIL · MIL · learn hub · NNG4 <https://adam.math.hhu.de/> · <https://github.com/leanprover-community/NNG4>
- CBMC: <https://www.cprover.org/cbmc/> · <https://github.com/diffblue/cbmc> · manual.pdf · cbmc-slides.pdf · <https://www.philipzucker.com/cbmc_tut/>
- Cryptol/SAW: <https://tools.galois.com/cryptol> · <https://tools.galois.com/saw> · <https://saw.galois.com/intro/> · <https://cryptol.net/files/ProgrammingCryptol.pdf> · <https://github.com/weaversa/cryptol-course> (+ labs/SAW/SAW.md) · <https://github.com/GaloisInc/saw-script> · <https://github.com/GaloisInc/cryptol>
- NuSMV/nuXmv: <https://nusmv.fbk.eu/> (+ overview, faq) · <https://nuxmv.fbk.eu/> · <https://es-static.fbk.eu/tools/nuxmv/>
- NN verification: <https://neural-network-verification.com/> (+ practice.html) · <https://github.com/Verified-Intelligence/alpha-beta-CROWN> · <https://arxiv.org/abs/2512.19007> (VNN-COMP 2025) · <https://arxiv.org/abs/2412.19985> (VNN-COMP 2024) · <https://vnn-comp.github.io/>
- SMT tutorial: <https://link.springer.com/chapter/10.1007/978-3-031-71177-0_31> · <https://par.nsf.gov/servlets/purl/10584608> · <https://homepage.cs.uiowa.edu/~tinelli/talks/ETAPS-19.pdf>
- AI/FM/math: <https://cacm.acm.org/research/formal-reasoning-meets-llms-toward-ai-for-mathematics-and-verification/> · <https://dl.acm.org/doi/10.1145/3750038> · <https://pldi25.sigplan.org/details/pldi-2025-papers/98/> · <https://lftcm2023.github.io/tutorial/> · <https://amosturchet.github.io/lftcm26/>
- Spring-2026 milestones & economics: <https://www.anthropic.com/glasswing> · <https://www.npr.org/2026/04/11/nx-s1-5778508/anthropic-project-glasswing-ai-cybersecurity-mythos-preview> · <https://openai.com/index/model-disproves-discrete-geometry-conjecture/> · <https://research.nvidia.com/labs/lpr/slm-agents/> (arXiv 2506.02153) · <http://www.incompleteideas.net/IncIdeas/BitterLesson.html> · MIT Sloan <https://doi.org/10.63383/hadW7619> · Apiiro <https://apiiro.com/blog/4x-velocity-10x-vulnerabilities-ai-coding-assistants-are-shipping-more-risks/> · AWS Automated Reasoning <https://aws.amazon.com/blogs/aws/minimize-ai-hallucinations-and-deliver-up-to-99-verification-accuracy-with-automated-reasoning-checks-now-available/>

### Primary sources: our talks (Dropbox/Research/talks)
Consulted directly for the Day 1 motivation and Day 4 frontier; these are the authoritative source for our framing:
- **Liverpool** (CS seminar, 2025-12-12) — *NN Verification for Formally Verifying Neuro-Symbolic AI*: economics/cost of neuro-symbolic vs. LLM, the news-article risk slides (MIT Sloan, Apiiro, AWS Automated Reasoning, VentureBeat), NNV / NNV 2.0, neuro-symbolic automata and behavior trees, VNN-COMP.
- **Dagstuhl** (2025-09-24), **RMIT** (2026-04-08), **Shonan** (2026-03-10) — *Let's Verify ChatGPT* / *Agentic Engineering is Coming*: the "program synthesis is solved, engineering synthesis is next" thesis, the *oracles* pattern, the verify-ChatGPT grand challenge and open-SLM targets, and the AI-capex/Sutton economic framing.

### Examined but discarded
- `fm.csl.sri.com/SSFT24/` and `/SSFT25/` — **404** (path guesses; use the ssft-sri.github.io hub).
- Old nuXmv wiki paths (`…?n=Documentation.Home`, `…Documentation.Tutorials`) — **404** (use nuxmv.fbk.eu root).
- `saw.galois.com/tutorial.html`, `galois.com/services/cryptol/`, `galois.com/blog/2021/02/learning-cryptol/` — **404** (superseded by tools.galois.com).
- `i-cav.org` / CAV conference pages — CAV runs no standalone public slide-deck tutorial series; its educational content surfaces via co-located schools and distinguished-tutorial papers (captured above). `icav.ca` is an unrelated Montreal academy.
- Conference-listing aggregators (myhuiban, wikicfp, 10times, easychair CFP) — no teaching content.
- ResearchGate / Academia.edu / archive.org mirrors — secondary; preferred primary sources used instead.
- Grant/patent/clinical-trial/biorxiv hits from broad queries — irrelevant noise.
- Third-party Z3 material (jfmc z3-play, philzook58 z3_tutorial) — fine but redundant with the official guide.
- EUTypes summer schools (2017/2018) — type theory; tangential and older.

---

## Part 6 — Gap analysis: what longer courses cover that we under-cover

Honest scoping, to set expectations and to seed "where to go next" (Day 4 has a slide on this). For each gap: the established courses that cover it.

1. **Deductive program verification / separation logic** (Hoare, Why3, Viper, Dafny, **Verus**). Central to CMU 15-414 (current), ETH Program Verification, Marktoberdorf, SSFT 2026. We jump to bounded model checking (CBMC) and equivalence proofs (SAW) but skip contract/loop-invariant deductive verification. Verus is especially on-thesis (it verifies *Rust*, an LLM-favored target).
2. **Program synthesis / solver-aided programming** (SyGuS, Rosette, UCLID5). Berkeley 219C, OPLSS. Given our "generation is cheap, verification is essential" thesis, *synthesis vs. verification* is a conspicuous omission.
3. **Constrained Horn Clauses (CHC)** as the unifying SMT back-end (Grumberg @ Marktoberdorf; Spacer/Z3). Would tie Days 1, 2, and 4 together.
4. **Abstract interpretation** as a paradigm (widening/narrowing). OPLSS, Oxford, FRAP, Berkeley. We cover BDD/symbolic reachability but not abstraction/widening — Day 1's landscape slide now names it.
5. **Probabilistic & hybrid/CPS model checking** (PRISM; nuXmv hybrid/IC3; Barthe probabilistic). Oxford, Marktoberdorf. nuXmv (already on Day 2) supports infinite-state/hybrid — worth surfacing as "beyond finite-state."
6. **Coq/Rocq & the verified-stack tradition** (CompCert, seL4, CertiKOS). DeepSpec, FRAP, OPLSS. We chose Lean 4 (more AI-current); students should know Coq/Rocq holds the largest verified-systems artifacts.
7. **Crypto-protocol verification** (Tamarin, ProVerif). SSFT 2026. Distinct from SAW's crypto-*implementation* verification — a useful "symbolic protocol vs. computational implementation" contrast.
8. **Runtime verification / testing-as-verification** (VTSA; the "and Testing" half of CMU 15-414). Fits the AI thesis: LLM code + runtime monitors / property-based testing as a lightweight tier below full proof.
9. **Solver/proof internals** (CDCL, DPLL(T), proof certificates / UNSAT cores). SAT/SMT/AR school, Stanford CS357 (build-a-solver). Our Z3 use is appropriately black-box; a "how the oracle works" slide would strengthen Day 1.
10. **Rigorous evaluation of agentic/LLM systems** (Mitchell @ Marktoberdorf 2026; the CACM survey). **Highest-value gap relative to our own thesis:** how to *evaluate* AI+FM pipelines (miniF2F, VNN-COMP, SV-COMP; pass@k vs. verified-correct). Day 4's "where to go next" slide flags this.

**Conversely — what FMAIV does that this set rarely combines in one offering:** a single intensive spanning SAT/SMT → symbolic model checking → interactive theorem proving (Lean 4) → automated program/crypto verification (CBMC/Cryptol/SAW) → **neural-network verification**, unified by an explicit *AI-assisted / agentic-coding* thesis. No single course in the survey covers NN verification alongside the classical stack, and almost none foreground "verification is the essential activity in the age of cheap code generation." Only Marktoberdorf 2026 comes close — and it does so as separate specialist tracks rather than one integrated arc.
