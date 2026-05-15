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

### 6. CBMC

The bounded model checker for C used on Day 4.

- Repository: <https://github.com/diffblue/cbmc>
- macOS: `brew install cbmc`
- Ubuntu / Debian: `sudo apt install cbmc`
- Windows: install from the [CBMC releases page](https://github.com/diffblue/cbmc/releases)
- Verify: `cbmc --version`

A Docker image will be provided as a fallback closer to the course date for participants who cannot install CBMC locally.

### 7. Cryptol

The Galois domain-specific language used on Day 4 for specifying and verifying bit-level algorithms, together with the Software Analysis Workbench (SAW) it integrates with.

- Repository: <https://github.com/GaloisInc/cryptol>
- Download a release binary from <https://github.com/GaloisInc/cryptol/releases> and place `cryptol` on your `PATH`.
- Alternative: build from source following the instructions in the repository.
- Verify: `cryptol --version`

## Verify everything is installed

Run each of the following from a fresh terminal. Every command should print a version or help banner without error.

```
code --version
python --version
python -c "import z3; print(z3.get_version_string())"
lean --version
lake --version
nuXmv -help | head -1
cbmc --version
cryptol --version
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

- **J. Avigad.** *Mathematics and the formal turn.* Bulletin of the American Mathematical Society (New Series), 61(2): 225–240, 2024. <https://doi.org/10.1090/bull/1832> (arXiv preprint: <https://arxiv.org/abs/2311.00007>)
  - An AMS Bulletin essay framed for working mathematicians on what proof assistants are, why they matter, and how the field has moved.

- **Y. Bengio and N. Malkin.** *Machine learning and information theory concepts towards an AI mathematician.* Bulletin of the American Mathematical Society (New Series), 61(3): 457–469, 2024. <https://doi.org/10.1090/bull/1839>
  - The complementary AMS Bulletin essay on what AI for mathematics is, what it is missing, and what an "AI mathematician" would actually require.

- **J. Bayer, C. Benzmüller, K. Buzzard, M. David, L. Lamport, Y. Matiyasevich, L. Paulson, D. Schleicher, B. Stock, and E. Zelmanov.** *Mathematical Proof Between Generations.* Notices of the American Mathematical Society, 71(1): 79–92, January 2024. <https://doi.org/10.1090/noti2860>
  - A multi-author Notices article including Kevin Buzzard's section on Lean and the formalization of contemporary mathematics; useful first read for the Day 3 framing.

- **G. Gonthier.** *Formal Proof — The Four-Color Theorem.* Notices of the American Mathematical Society, 55(11): 1382–1393, December 2008. <https://www.ams.org/notices/200811/tx081101382p.pdf>
  - The classic AMS Notices writeup of a fully machine-checked landmark theorem; reads as a historical predecessor to the Lean / AI-assisted formalizations of today.

## Course materials

This repository will hold the course materials (slides, mini-project scaffolds, worked examples, and reference scripts) once the course is finalized. For now, only the setup README is included here.

## Contact

Taylor Johnson, PhD, PE — taylor.johnson@vanderbilt.edu — <https://www.taylortjohnson.com/>
