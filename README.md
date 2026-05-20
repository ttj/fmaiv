# FMAIV — Formal Methods & AI-Assisted Verification

Course materials and software setup for a short course on formal methods and AI-assisted verification. The course threads *transition systems* as a unifying behavioral model from logic and SAT/SMT through model checking, theorem proving, and program verification.

## Course plan

| Day | Theme | Major content |
|---|---|---|
| 1 | Foundations: logic, transition systems, SAT, and SMT | Propositional and first-order logic; structural operational semantics and transition systems as the unifying behavioral model; decision procedures; hands-on with the Z3 SMT solver. |
| 2 | Model checking | Reactive systems modeled as transition systems; computation tree logic (CTL) and linear temporal logic (LTL); explicit-state, symbolic, and bounded model checking with nuXmv; counterexample-guided debugging. |
| 3 | Theorem proving | Lean 4 with the Mathlib library for interactive proof; formalizing properties of transition systems and other mathematical structures; Claude Code for AI-assisted proof generation and checking. |
| 4 | Program and high-assurance verification | Programs as transition systems on memory states; bounded model checking of C with CBMC; Cryptol with the Software Analysis Workbench (SAW) for specifying and verifying bit-level algorithms; survey of neural-network verification and industrial deployments. |

## Software prerequisites

Please install the following before the course begins. Estimated total setup time on a modern laptop: 30–60 minutes. Disk footprint: roughly 6 GB.

### 1. Visual Studio Code

The editor used throughout the course, with the Lean 4 extension for theorem proving.

- Download: <https://code.visualstudio.com/Download>
- Recommended extensions, installed from the marketplace once VS Code is running (open the Extensions panel with `Ctrl+Shift+X` / `Cmd+Shift+X` and search):
  - **Lean 4** by `leanprover` — Lean 4 language support and proof state display.
  - **Python** by `ms-python` — Python language support, debugging, and linting.
- AI-assisted coding extensions — install **at least one** of the following so we can explore AI-assisted verification in class. We will use Claude Code throughout, but the other two are encouraged for comparison.
  - **Claude Code** by Anthropic — Anthropic's coding agent integrated into VS Code. <https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code>
  - **OpenAI Codex** — OpenAI's coding extension. <https://marketplace.visualstudio.com/search?term=openai%20codex&target=VSCode>
  - **Gemini Code Assist** by Google — free for individuals. <https://marketplace.visualstudio.com/items?itemName=Google.geminicodeassist>

Each AI extension requires a sign-in to its provider. Accounts are free or low-cost for the level of use we need; provider-specific details:
- Claude Code: sign in with an Anthropic Console or Claude.ai account.
- OpenAI Codex: sign in with an OpenAI account; some features may require an API plan.
- Gemini Code Assist: sign in with a Google account; the free individual tier is sufficient.

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

## Verify everything is installed

Run each of the following from a fresh terminal. Every command should print a version or help banner without error.

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

Light reading to ground the course material. None of these are required reading; they are pointers to the canonical references for the tools and ideas covered.

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

## Course materials

The four days live under [`day01/`](day01/) … [`day04/`](day04/), each containing a `README.md`, slides under `slides/`, worked examples under `examples/`, and a mini-project under `assignments/`. The plan that produced the current shape is in [`PLAN.md`](PLAN.md).

## Contact

Taylor Johnson, PhD, PE — taylor.johnson@vanderbilt.edu — <https://www.taylortjohnson.com/>
