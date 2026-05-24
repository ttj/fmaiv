# FMAIV — Formal Methods & AI-Assisted Verification

Course materials and software setup for a short course on formal methods and AI-assisted verification. The course threads *transition systems* as a unifying behavioral model from logic and SAT/SMT through model checking, theorem proving, and program verification.

## Slides

Published online (RevealJS — arrow keys to navigate, **S** speaker notes, **F** fullscreen, **Esc** for the slide grid):

- **All decks:** <https://ttj.github.io/fmaiv/>
- Day 1 — [Foundations: logic, transition systems, SAT, SMT](https://ttj.github.io/fmaiv/day01.html)
- Day 2 — [Model checking with nuXmv](https://ttj.github.io/fmaiv/day02.html)
- Day 3 — [Theorem proving with Lean 4 (and AI)](https://ttj.github.io/fmaiv/day03.html)
- Day 4 — [Program & high-assurance verification + the frontier](https://ttj.github.io/fmaiv/day04.html)

**PDF** (to follow along or print): [Day 1](https://ttj.github.io/fmaiv/day01.pdf) · [Day 2](https://ttj.github.io/fmaiv/day02.pdf) · [Day 3](https://ttj.github.io/fmaiv/day03.pdf) · [Day 4](https://ttj.github.io/fmaiv/day04.pdf)

Markdown source is under `dayNN/slides/dayNN.md`.

## Course plan

| Day | Theme | Major content |
|---|---|---|
| 1 | Foundations: logic, transition systems, SAT, and SMT | Propositional and first-order logic; structural operational semantics and transition systems as the unifying behavioral model; decision procedures; hands-on with the Z3 SMT solver. |
| 2 | Model checking | Reactive systems modeled as transition systems; computation tree logic (CTL) and linear temporal logic (LTL); explicit-state, symbolic, and bounded model checking with nuXmv; counterexample-guided debugging. |
| 3 | Theorem proving | Lean 4 for interactive proof (Mathlib-free, so it builds offline in seconds); formalizing properties of transition systems and other mathematical structures; Claude Code for AI-assisted proof generation and checking. |
| 4 | Program and high-assurance verification | Programs as transition systems on memory states; bounded model checking of C with CBMC; Cryptol with the Software Analysis Workbench (SAW) for specifying and verifying bit-level algorithms; survey of neural-network verification and industrial deployments. |

## Run the course online — no install (recommended)

You do **not** need to install anything: every day runs in the browser, and every `dayNN/examples/` file is in the repo. Local installation is fully supported as a backup ([see below](#local-installation-backup)). The full online walkthrough — with the exact per-day run commands — is in [`notebooks/README.md`](notebooks/README.md).

- **GitHub Codespaces — full toolset, one click.** [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ttj/fmaiv) A cloud container with **everything preinstalled**: `z3` (CLI + Python), `cbmc`, `cryptol`, `saw`, `NuSMV`, `lean`, and `smvis`. Open any `notebooks/*.ipynb` and run it, or use the integrated terminal (e.g. `cbmc file.c --unwind 5`). Free within GitHub's monthly allowance (120 core-hours; 180 for verified students via GitHub Education).
- **Google Colab — per notebook, zero setup** (just a Google login): [`01_z3_python.ipynb`](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/01_z3_python.ipynb) (Day 1 — Z3 in Python) and [`02_tools_cli.ipynb`](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/02_tools_cli.ipynb) (Days 2 & 4 — CBMC and NuSMV). `z3`/`cbmc`/`NuSMV` install in seconds; `cryptol`/`saw` are large downloads — prefer Codespaces for those.
- **Browser tools (no account needed):**
  - **Day 1 (Z3)** — the interactive Z3 guide runs entirely in the browser: <https://microsoft.github.io/z3guide/>
  - **Day 2 (model checking)** — **smvis** runs NuSMV with state/BDD visualization in the browser and accepts your own `.smv` files: <https://bit.ly/fmaiv_smvis>
  - **Day 3 (Lean 4)** — the Lean web editor and the gamified Natural Number Game run in the browser: <https://live.lean-lang.org/> and <https://adam.math.hhu.de/>
- **nuXmv** is license-gated (not redistributable), so it is **not** in Codespaces/Colab. Use the **smvis** web app above, or the preinstalled **`NuSMV`** (same SMV language and `is true/false` verdicts) for finite-state models.

## AI coding assistant (recommended, either path)

Bring **at least one** AI coding assistant so we can explore AI-assisted verification in class — we use **Claude Code** throughout; the others are encouraged for comparison. In Codespaces or local VS Code, install from the Extensions panel (`Ctrl+Shift+X` / `Cmd+Shift+X`):

- **Claude Code** by Anthropic — <https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code> (sign in with an Anthropic Console or Claude.ai account).
- **OpenAI Codex** — <https://marketplace.visualstudio.com/search?term=openai%20codex&target=VSCode> (OpenAI account; some features may require an API plan).
- **Gemini Code Assist** by Google — <https://marketplace.visualstudio.com/items?itemName=Google.geminicodeassist> (Google account; the free individual tier suffices).

## Local installation (backup)

Prefer to run on your own machine? Install the following before the course begins. Estimated total setup time: 30–60 minutes; disk footprint roughly 6 GB.

### 1. Visual Studio Code

The editor used throughout the course. After installing, add the **Lean 4** (`leanprover`) and **Python** (`ms-python`) extensions from the marketplace, plus an AI assistant (see the section above).

- Download: <https://code.visualstudio.com/Download>

### 2. Python 3.10 or newer

Needed for the Z3 Python bindings used in several mini-projects. Python 3.12 is recommended.

- Download: <https://www.python.org/downloads/>
- macOS: `brew install python@3.12`
- Ubuntu / Debian: `sudo apt install python3 python3-pip`
- Verify: `python --version` or `python3 --version`

### 3. Z3

The SMT solver from Microsoft Research, used as our SAT/SMT engine. The `z3-solver` package bundles both the Python bindings and a CLI binary.

- Repository: <https://github.com/Z3Prover/z3>
- Install:
  ```
  pip install z3-solver
  ```
- Verify the bindings: `python -c "import z3; print(z3.get_version_string())"`
- A standalone binary is also available from the [Z3 releases page](https://github.com/Z3Prover/z3/releases) or via `brew install z3` on macOS.

### 4. Lean 4

The interactive theorem prover, installed via `elan`, which manages Lean versions and the `lake` build tool.

- Install instructions: <https://lean-lang.org/install/>
- macOS / Linux quick install:
  ```
  curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | sh
  ```
- Windows: download `elan-init.exe` from <https://github.com/leanprover/elan/releases>
- Verify: `lean --version` and `lake --version`

### 5. nuXmv

The symbolic model checker used on Day 2. Free for non-commercial use; a short registration form is required to obtain the binary.

- Download: <https://nuxmv.fbk.eu/>
- After download, place the `nuXmv` binary on your `PATH`.
- Verify: `nuXmv -help` (or just `nuXmv` to enter the interactive shell, then type `quit`)

### 6. CBMC, Cryptol, SAW — via Docker (recommended)

The Day 4 toolchain — [CBMC](https://github.com/diffblue/cbmc) (bounded model checker for C), [Cryptol](https://github.com/GaloisInc/cryptol) (Galois's bit-precise specification DSL), and [SAW](https://github.com/GaloisInc/saw-script) (Software Analysis Workbench, equivalence-checks C against Cryptol) — is provided as a single Docker image. SAW in particular needs a specific LLVM/clang version to parse bitcode reliably, and pinning that across Windows/macOS/Linux laptops is more friction than the rest of the course put together. Docker removes all of it.

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS) or Docker Engine (Linux).
- See [`day04/README.md`](day04/README.md) for the one-time `docker compose build` and the day-of `docker compose run --rm day04`. The image bundles CBMC, Cryptol, SAW, clang-15, and Z3.
- Verify: `docker compose run --rm day04 cbmc --version` (after the one-time build).

If you prefer native installs, CBMC is in `apt`/`brew` and Cryptol/SAW ship Linux/macOS prebuilt tarballs from their releases pages; expect to pin clang's version against SAW's bitcode parser. Docker is strongly preferred.

### Verify a local install

After installing locally, run each of the following from a fresh terminal; every command should print a version or help banner without error. (In Codespaces these are all preinstalled — the container prints a readiness banner when it attaches, and the notebooks run end-to-end.)

```
code --version
python --version
python -c "import z3; print(z3.get_version_string())"
lean --version
lake --version
nuXmv -help | head -1
docker --version
docker compose run --rm day04 cbmc --version          # from data/cs6315/fmaiv/day04/
docker compose run --rm day04 cryptol --version
docker compose run --rm day04 saw --version
```

If any of these fail, please open an issue against this repository or reach out at the email address below before the first session.

## Background references

Light reading to ground the course material. None of these are required reading; they are pointers to the canonical references for the tools and ideas covered. For the **full, annotated set** of similar courses, tutorials, summer schools, and the neural-network / agentic-coding literature — plus a provenance record of everything consulted while building this course — see [`references/EXTERNAL_RESOURCES.md`](references/EXTERNAL_RESOURCES.md).

### Foundations

- **G. D. Plotkin.** *A structural approach to operational semantics.* Technical Report DAIMI FN-19, Computer Science Department, Aarhus University, 1981. Republished in *Journal of Logic and Algebraic Programming*, 60–61: 17–139, 2004. <https://doi.org/10.1016/j.jlap.2004.05.001> (Plotkin's own freely available copy of the JLAP version: <https://homepages.inf.ed.ac.uk/gdp/publications/sos_jlap.pdf>)
  - The original "structural operational semantics" notes that introduce transition systems as the operational backbone of programming-language semantics. We use this framing on Day 1 and thread it through the rest of the course.

### Formal methods overview

- **E. M. Clarke and J. M. Wing.** *Formal Methods: State of the Art and Future Directions.* ACM Computing Surveys, 28(4): 626–643, 1996. <https://doi.org/10.1145/242223.242257> (free PDF on Jeannette Wing's Columbia page: <https://www.cs.columbia.edu/~wing/publications/ClarkeWing96.pdf>)
  - A still-standard pedagogical survey by two of the field's founders; gives the lay of the land for what formal methods is and where it's been deployed.

### Tools

- **R. Cavada, A. Cimatti, M. Dorigatti, A. Griggio, A. Mariotti, A. Micheli, S. Mover, M. Roveri, and S. Tonetta.** *The nuXmv Symbolic Model Checker.* In *Computer Aided Verification (CAV 2014)*, LNCS 8559, pp. 334–342. Springer, 2014. <https://doi.org/10.1007/978-3-319-08867-9_22>
  - The tool paper for nuXmv, the symbolic model checker we use on Day 2.

- **J. Lewis and B. Martin.** *Cryptol: High Assurance, Retargetable Crypto Development and Validation.* In *IEEE Military Communications Conference (MILCOM 2003)*, vol. 2, pp. 820–825, 2003. <https://doi.org/10.1109/MILCOM.2003.1290218>
  - The original Cryptol paper from Galois and the NSA, introducing it as a DSL for bit-precise specification and verification. We use Cryptol with SAW on Day 4.

- **smvis** — interactive SMV / NuSMV model visualizer (state graphs and BDDs). **Run it in your browser:** <https://bit.ly/fmaiv_smvis> · source: <https://github.com/verivital/smvis>
  - Used on Day 2 to run NuSMV with no install and to visualize the example models, state graphs, and BDDs interactively; the Day 2 `.smv` examples are drawn from its example set.

- **leansmv** — SMV-to-Lean translator and library for proving inductive invariants of transition systems in Lean 4. <https://github.com/ttj/leansmv>
  - The Day 3 `CounterDemo` Lean material derives from this project.

### AI-assisted verification and formalized mathematics

- **J. Alper.** *Embracing AI and formalization: Experimenting with tomorrow's mathematical tools.* Bulletin of the American Mathematical Society (New Series), 63(2): 177–197, 2026. <https://doi.org/10.1090/bull/1879>
  - A motivational Bulletin essay on how AI and proof-assistant formalization (notably Lean) are already reshaping mathematical research practice. Alper recounts standing up the eXperimental Lean Lab at the University of Washington and argues for active engagement with these tools.

- **J. Avigad.** *Mathematics and the formal turn.* Bulletin of the American Mathematical Society (New Series), 61(2): 225–240, 2024. <https://doi.org/10.1090/bull/1832> (arXiv preprint: <https://arxiv.org/abs/2311.00007>)
  - An AMS Bulletin essay framed for working mathematicians on what proof assistants are, why they matter, and how the field has moved.

- **Y. Bengio and N. Malkin.** *Machine learning and information theory concepts towards an AI mathematician.* Bulletin of the American Mathematical Society (New Series), 61(3): 457–469, 2024. <https://doi.org/10.1090/bull/1839>
  - The complementary AMS Bulletin essay on what AI for mathematics is, what it is missing, and what an "AI mathematician" would actually require.

- **J. Bayer, C. Benzmüller, K. Buzzard, M. David, L. Lamport, Y. Matiyasevich, L. Paulson, D. Schleicher, B. Stock, and E. Zelmanov.** *Mathematical Proof Between Generations.* Notices of the American Mathematical Society, 71(1): 79–92, January 2024. <https://doi.org/10.1090/noti2860>
  - A multi-author Notices article including Kevin Buzzard's section on Lean and the formalization of contemporary mathematics; useful first read for the Day 3 framing.

- **G. Gonthier.** *Formal Proof — The Four-Color Theorem.* Notices of the American Mathematical Society, 55(11): 1382–1393, December 2008. <https://www.ams.org/notices/200811/tx081101382p.pdf>
  - The classic AMS Notices writeup of a fully machine-checked landmark theorem; reads as a historical predecessor to the Lean / AI-assisted formalizations of today.

- **K. Yang, G. Poesia, J. He, W. Li, K. Lauter, S. Chaudhuri, and D. Song.** *Formal Reasoning Meets LLMs: Toward AI for Mathematics and Verification.* Communications of the ACM, 2025. <https://doi.org/10.1145/3750038>
  - The roadmap survey behind this course's cross-cutting thesis — how LLMs and formal reasoning combine, with a trusted checker arbitrating.
- **T. Tao.** *Machine-Assisted Proof.* Notices of the American Mathematical Society, 72(1), January 2025. <https://www.ams.org/notices/202501/rnoti-p6.pdf>
  - A Fields medalist's perspective on AI- and proof-assistant-assisted mathematics; pairs with the Day 1 framing and Day 3.

### Neural-network verification

Background for the Day 4 frontier segment. The two books are the best self-study on-ramps; the papers anchor the two solver families.

- **A. Albarghouthi.** *Introduction to Neural Network Verification.* 2021. Free online: <https://verifieddeeplearning.com>
  - The gentle, self-contained on-ramp; assumes no prior verification background.
- **C. Liu, T. Arnon, C. Lazarus, C. Strong, C. Barrett, and M. J. Kochenderfer.** *Algorithms for Verifying Deep Neural Networks.* Foundations and Trends in Optimization, 4(3–4), 2021. <https://arxiv.org/abs/1903.06758>
  - The comprehensive technical survey of the algorithms.
- **G. Katz, C. Barrett, D. Dill, K. Julian, and M. Kochenderfer.** *Reluplex: An Efficient SMT Solver for Verifying Deep Neural Networks.* CAV 2017. <https://arxiv.org/abs/1702.01135>
  - The origin point; proves exact ReLU robustness is NP-complete.
- **H.-D. Tran et al.** *Star-Based Reachability Analysis of Deep Neural Networks* (FM 2019), *ImageStars* (CAV 2020), and **NNV 2.0** (CAV 2023). Tool: <https://github.com/verivital/nnv>
  - Our reachability-based verifier (star sets); the basis for Day 4's reachability framing.
- **VNN-COMP** annual competition — reports for 2025 (<https://arxiv.org/abs/2512.19007>) and 2024 (<https://arxiv.org/abs/2412.19985>); hub <https://vnn-comp.github.io/>. α,β-CROWN (<https://github.com/Verified-Intelligence/alpha-beta-CROWN>) has won every year 2021–2025. Our **AAAI'26 VNN-COMP tutorial** (slides + Google Colab notebooks) is at <https://vnn-comp.github.io/#aaai2026>; the AAAI-2022 tutorial **neural-network-verification.com** is another strong hands-on companion.
- **Frontier / next directions** — T. Johnson, *Is Neural Network Verification Useful and What Is Next?* (Allerton 2025, <https://hdl.handle.net/2142/130315>): the "verify ChatGPT" grand challenge, open small-LM targets (OLMo2-1B, SmolLM2-135M), and the shift toward NLP / guardrail / vision-language-action models. Neuro-symbolic verification (NN verification composed with model checking) via **BehaVerify**: <https://github.com/verivital/behaverify>.

### Agentic coding and AI-for-verification

Background for the Day 1 thesis that cheap code generation makes verification the essential activity. (Several statistics below are from vendor/industry reports rather than peer-reviewed studies — see [`references/EXTERNAL_RESOURCES.md`](references/EXTERNAL_RESOURCES.md) Part 4 for the caveats; the peer-reviewed anchors are FormAI and the slopsquatting paper.)

- **N. Tihanyi et al.** *The FormAI Dataset: Generative AI in Software Security through the Lens of Formal Verification.* PROMISE 2023. <https://arxiv.org/abs/2307.02192>
  - 51% of 112,000 GPT-generated C programs contained at least one vulnerability (found via the ESBMC bounded model checker) — the strongest peer-reviewed evidence that AI code needs verification.
- **J. Spracklen et al.** *We Have a Package for You! A Comprehensive Analysis of Package Hallucinations by Code-Generating LLMs.* USENIX Security 2025.
  - ~20% of LLM-recommended packages were hallucinated — the basis for the "slopsquatting" supply-chain attack.
- **AWS Provable Security** (Byron Cook's group) — formal methods as a CI signal at production scale (s2n-TLS via SAW, s2n-bignum via HOL Light, Cedar specified in Lean). Blog and open repos under <https://github.com/awslabs>. AWS Bedrock's *Automated Reasoning checks* now apply this to LLM outputs (up to 99% verification accuracy): <https://aws.amazon.com/blogs/aws/minimize-ai-hallucinations-and-deliver-up-to-99-verification-accuracy-with-automated-reasoning-checks-now-available/>.
- **Anthropic, Project Glasswing** (2026) — a frontier model found *thousands* of zero-day vulnerabilities in critical software (including a 16-year-old FFmpeg bug that fuzzing had executed ~5M times and missed) — a vivid demonstration that testing shows the presence, not the absence, of bugs. <https://www.anthropic.com/glasswing>
- **OpenAI, Erdős unit-distance conjecture** (May 2026) — the first AI to autonomously settle a central open math problem; pairs with the thesis that AI now both creates and breaks at the frontier, so machine-checkable assurance is the binding constraint. <https://openai.com/index/model-disproves-discrete-geometry-conjecture/>
- **P. Belcak et al. (NVIDIA), *Small Language Models are the Future of Agentic AI*** (arXiv 2506.02153, 2025) — the economic case that small, cheaper, and (for us) more *verifiable* models suit most agent tasks. <https://research.nvidia.com/labs/lpr/slm-agents/>

### Textbooks and reference works

A small selection from the CS 6315 (Vanderbilt) syllabus. None are required reading for the four-day course — they are the long-form references behind the topics we touch.

- **R. Alur.** *Principles of Cyber-Physical Systems.* MIT Press, 2015. <https://mitpress.mit.edu/9780262029117/principles-of-cyber-physical-systems/>
  - Companion textbook for the CS 6315 semester course; covers synchronous reactive components, transition systems, temporal logic, and timed/hybrid systems — exactly the formalism thread we use on Days 1–2.

- **E. A. Lee and S. A. Seshia.** *Introduction to Embedded Systems: A Cyber-Physical Systems Approach* (2nd ed.). MIT Press, 2017. Free online: <https://leeseshia.org>
  - Companion-level introduction; useful if Alur is more terse than you'd like. Particularly strong on the modeling-and-design half.

- **M. Huth and M. Ryan.** *Logic in Computer Science: Modelling and Reasoning about Systems* (2nd ed.). Cambridge University Press, 2004. <https://www.cambridge.org/9780521543101>
  - Standard undergraduate-to-early-graduate introduction to propositional/predicate logic, CTL/LTL, and model checking. Mirrors the Day 1 + Day 2 material.

- **E. M. Clarke, O. Grumberg, D. Kroening, D. Peled, and H. Veith.** *Model Checking* (2nd ed.). MIT Press, 2018. <https://mitpress.mit.edu/9780262038836/model-checking/>
  - The canonical reference for model checking; written by the field's founders. Day 2 is built on this material.

- **A. V. Aho and J. D. Ullman.** *Foundations of Computer Science.* W. H. Freeman, 1994. Free online: <http://infolab.stanford.edu/~ullman/focs.html>
  - Background on sets, logic, induction, and the discrete-math substrate every formal-methods tool stands on. Useful if Day 1's logic refresher moves too fast.

### Verification competitions and benchmark suites

Several verification subfields run annual competitions on shared benchmarks. They are the cleanest way to see "what tools are currently state-of-the-art for class X of problem", and the benchmark repositories themselves are useful for project ideas. List adapted from the CS 6315 project proposal handout.

| Topic | Competition / benchmark | Link |
|---|---|---|
| Neural-network verification | **VNN-COMP** | <https://vnn-comp.github.io/> |
| Software verification (C, Java) | **SV-COMP** + sv-benchmarks | <https://sv-comp.sosy-lab.org/> · <https://github.com/sosy-lab/sv-benchmarks> |
| SMT solvers | **SMT-COMP** | <https://smt-comp.github.io/> |
| SAT solvers | **SAT competition** | <https://satcompetition.github.io/> |
| Reactive synthesis | **SYNT-COMP** | <https://www.syntcomp.org/> |
| Cyber-physical / hybrid systems | **ARCH-COMP** + benchmarks | <https://cps-vo.org/group/ARCH/benchmarks> · <https://gitlab.com/goranf/ARCH-COMP/> |
| Petri nets | **Model Checking Contest (MCC)** | <https://mcc.lip6.fr/models.php> |
| Deductive verification | **VerifyThis** | <https://www.pm.inf.ethz.ch/research/verifythis.html> |
| Stochastic systems | **PRISM** + **Storm** case studies | <https://www.prismmodelchecker.org/casestudies/> · <https://www.stormchecker.org/> |
| C with annotations | Frama-C / ACSL | <https://frama-c.com/wp.html> |
| Lean | Lean 4 repo | <https://github.com/leanprover/lean4> |
| Static / dynamic analysis (industrial) | Meta Infer, Polyspace, Simulink Design Verifier, VS IntelliTest | <https://fbinfer.com/> · <https://www.mathworks.com/products/polyspace.html> · <https://www.mathworks.com/products/simulink-design-verifier.html> · <https://learn.microsoft.com/en-us/visualstudio/test/intellitest-manual/> |

If you are looking for a Day-4-style mini-project of your own, picking one benchmark suite above and running 2–3 of its tools on the smallest case is a standard pattern.

## Similar courses & further reading

Where to go deeper after this intensive. These are the closest analogues we found while building the course; each goes further than four days allow on some axis. The **full annotated list** — with a *they-do / we-do* comparison for each, plus tool tutorials and a provenance record of everything consulted — is in [`references/EXTERNAL_RESOURCES.md`](references/EXTERNAL_RESOURCES.md).

**Summer / winter schools** (the closest siblings overall)

- **SRI Summer School on Formal Techniques (SSFT)** — <https://ssft-sri.github.io/> — SMT, PVS theorem proving, model checking, symbolic execution; 2026 adds Verus and crypto-protocol verification. The nearest match in spirit.
- **Marktoberdorf Summer School** — <https://sites.google.com/view/marktoberdorf2026/talks> — the most thesis-aligned: de Moura on "Lean 4 for Program Verification in the Age of AI," Mitchell on evaluating agentic AI, plus deductive/probabilistic/CHC tracks.
- **Oregon PL Summer School (OPLSS)** — <https://www.cs.uoregon.edu/research/summerschool/> — types, logic, abstract interpretation, solver-aided programming (Rosette), refinement types; recordings on YouTube.
- **SAT/SMT/AR Summer School** — <https://sat-smt-ar-school.gitlab.io/www/> — solver internals (CDCL, theory combination), hands-on, no prior expertise needed.

**University courses with public slides**

- **CMU 15-414, "Bug Catching: Automated Program Verification (and Testing)"** — <https://www.cs.cmu.edu/~15414/> — the canonical undergrad analogue (Why3 deductive verification now; the Fall-2018 edition has full LTL/CTL/BMC/BDD model-checking notes mapping onto our Day 2).
- **UC Berkeley EECS 219C, "Computer-Aided Verification"** — <https://people.eecs.berkeley.edu/~sseshia/219c/> — SAT/SMT/BDD/model-checking plus syntax-guided synthesis and UCLID5.
- **Oxford, "Computer-Aided Formal Verification"** — <https://www.cs.ox.ac.uk/teaching/courses/2025-2026/computeraidedverification/> — temporal logic, symbolic/bounded MC, interpolation, plus probabilistic model checking.
- **Stanford CS357 / CS256** (Barrett) — <https://web.stanford.edu/class/cs357/> — SAT/SMT theory with a build-your-own theory solver; CS256 covers reactive systems.
- **MIT 6.822 FRAP** (Chlipala) — <https://adam.chlipala.net/frap/> — operational semantics, model checking, abstract interpretation, program logics, all machine-checked in Coq.
- **ETH Zürich, "Program Verification"** (Müller) — <https://www.pm.inf.ethz.ch/education/courses/program-verification.html> — Hoare/separation logic and automated deductive verification via Viper.

**Conference tutorials & surveys**

- **Formal Verification of Deep Neural Networks** (AAAI 2022 tutorial) — <https://neural-network-verification.com/> — the best hands-on companion to our Day 4 NN segment (α,β-CROWN, `auto_LiRPA`, Colab demos).
- **SMT: A Beginner's Tutorial** (Distinguished Tutorial, FM 2024) — <https://link.springer.com/chapter/10.1007/978-3-031-71177-0_31> — SMT foundations with cvc5 and Z3 exercises.
- **Formal Reasoning Meets LLMs** (CACM 2025) — <https://doi.org/10.1145/3750038> — the survey behind our AI×FM thesis.

## Course materials

The four days live under [`day01/`](day01/) … [`day04/`](day04/), each containing a `README.md`, slides under `slides/`, worked examples under `examples/`, and a mini-project under `assignments/`. Browser/Colab runners are in [`notebooks/`](notebooks/) (see [`notebooks/README.md`](notebooks/README.md)), and the annotated external-resources list is in [`references/`](references/).

Each exercise example ships with a `*_starter` to complete, and every worked example is checked end-to-end by [`scripts/check_examples.sh`](scripts/check_examples.sh) (run in CI on each push). Students can self-check one exercise with `bash scripts/check_examples.sh --only <name>` (or `--list` to see them all).

- **Capstone** — [`capstone/`](capstone/) threads the running counter (`x ≤ 10`) through all four tools (Z3 → nuXmv → Lean → CBMC/Cryptol) and asks you to compare bounded vs. unbounded vs. inductive vs. bit-precise verification.
- **Frontier (Day 4)** — [`day04/examples/nn/`](day04/examples/nn/) certifies neural-network robustness with auto_LiRPA (CPU-only; Colab notebook included).

## Instructors

- **Taylor Johnson** — Associate Professor of Computer Science, Computer Engineering & Electrical Engineering; Associate Dean for Graduate Education, College of Connected Computing, Vanderbilt University — taylor.johnson@vanderbilt.edu — <https://www.taylortjohnson.com/>
- **Ben Wooding** — Postdoctoral Scholar, Institute for Software Integrated Systems, Vanderbilt University — ben.wooding@vanderbilt.edu — <https://woodingben.com/>
