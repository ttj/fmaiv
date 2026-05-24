# Run the whole course online — no install needed

Every day of the course runs in the browser, in case you didn't install the
tools locally. All four days' tools (z3, NuSMV, Lean 4, CBMC, Cryptol, SAW,
smvis) are preinstalled in the Codespace image, and every `dayNN/examples/`
file is right there in the repo. There are two ways in; see
**"Run any day in the Codespace"** below for the exact commands.

There is **one notebook per day** in this folder, named by day, plus the two
Day-4 *frontier* neural-network notebooks. Each notebook's first cell is an
idempotent setup that **finds the repo (cloning it on Colab) and then runs the
real `dayNN/examples/` files** — the same files CI checks — so the notebooks and
the repo never drift.

## Option 1 — GitHub Codespaces (full toolset, recommended)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ttj/fmaiv)

Click the badge (or **Code ▸ Codespaces ▸ Create codespace on main**). You get a
container built from the course image with **everything preinstalled**:
`z3` (command-line + Python), `cbmc`, `cryptol`, `saw`, `NuSMV`, `lean`, and `smvis`,
plus `torch`/`torchvision`/`auto_LiRPA` for the Day-4 neural-network notebooks.

- Open any notebook in `notebooks/` and run it (the VS Code Jupyter extension is
  preconfigured), **or** run `jupyter lab` in the terminal for a full JupyterLab tab.
- You can also use the integrated terminal directly, e.g. `cbmc file.c --unwind 5`.
- Codespaces is free within a monthly allowance (120 core-hours; 180 for verified
  students via GitHub Education) — plenty for class use.

## Option 2 — Google Colab (per notebook, zero setup)

No GitHub account needed — just a Google login. Each notebook's first cell clones
the repo and installs only what's missing, so the same notebook works in both
Codespaces and Colab.

| Notebook | Day | Open in Colab |
|---|---|---|
| `01_day1_logic_sat_smt.ipynb` | Day 1 — logic, SAT & SMT (Z3) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/01_day1_logic_sat_smt.ipynb) |
| `02_day2_model_checking.ipynb` | Day 2 — model checking (NuSMV) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/02_day2_model_checking.ipynb) |
| `03_day3_theorem_proving.ipynb` | Day 3 — theorem proving (Lean 4) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/03_day3_theorem_proving.ipynb) |
| `04_day4_program_verif.ipynb` | Day 4 — programs (CBMC · Cryptol · SAW) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/04_day4_program_verif.ipynb) |
| `05_day4_nn_robustness.ipynb` | Day 4 frontier — NN robustness (auto_LiRPA) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/05_day4_nn_robustness.ipynb) |
| `06_day4_nn_mnist.ipynb` | Day 4 frontier — multi-class MNIST robustness | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/06_day4_nn_mnist.ipynb) |

In Colab, `z3`, `cbmc`, and `NuSMV` install in seconds, and the NN notebooks
`pip`-install `auto_LiRPA` (CPU-only) in their first cell. **`cryptol`/`saw`** are
large downloads — the Day-4 program-verification notebook runs CBMC on Colab and
skips Cryptol/SAW unless you opt in (set `INSTALL_CRYPTOL_SAW = True`); for those,
prefer **Codespaces** (preinstalled). The **Day-3 Lean** notebook installs the
pinned toolchain on first run (a few minutes); since the project is Mathlib-free,
`lake build` then finishes in seconds.

## Run any day in the Codespace

Open a terminal in the Codespace (or `jupyter lab`) and run these — all verified
working in the image, and identical to what the notebooks run. Each day's
`assignments/dayNN.md` has the exercises, and the slides are at
<https://ttj.github.io/fmaiv/>.

**Day 1 — SAT/SMT with Z3** (or the interactive `notebooks/01_day1_logic_sat_smt.ipynb`)
```bash
python3 day01/examples/z3_smoke.py
python3 day01/examples/z3_pigeonhole.py
python3 day01/examples/z3_counter_bounded.py
python3 day01/examples/z3_entailment.py       # validity vs. satisfiability (the assert-not idiom)
python3 day01/examples/z3_synthesis.py        # synthesis as exists-forall solving
python3 day01/examples/puzzles/nqueens.py     # also: sudoku.py, magic_square.py, kenken.py (each + a *_starter.py)
```

**Day 2 — Model checking with NuSMV** (or `notebooks/02_day2_model_checking.ipynb`; for nuXmv + visualization use the smvis web app below)
```bash
NuSMV day02/examples/counter.smv              # also: mutex, peterson, elevator, prodcons, traffic_light, gcd_01
NuSMV day02/examples/spec_challenge.smv       # formalize-English-into-specs exercise (+ _starter)
NuSMV day02/examples/bmc_depth.smv            # a bug at depth 12 — a BMC bound hunt
```

**Day 3 — Theorem proving with Lean 4** (or `notebooks/03_day3_theorem_proving.ipynb`; toolchain v4.29.0 preinstalled, Mathlib-free → builds offline)
```bash
cd day03/examples/CounterDemo
lake build                                    # solution modules build clean (sorry-free)
lake build CounterDemo.DiscreteMathStarter    # gentle set-theory intro for Lean newcomers
lake build CounterDemo.CounterStarter         # the counter proof to fill in
```
Translate any Day-2 model into a ready-to-prove Lean exercise (from the repo root):
`bash scripts/smv2lean/to_lean.sh day02/examples/mutex.smv` — see `CounterDemo/NuXMV/` for worked examples (`Gcd`, `Mutex`, `Elevator` + `*Proofs`).

**Day 4 — CBMC / Cryptol / SAW** (or `notebooks/04_day4_program_verif.ipynb`)
```bash
cd day04/examples
cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions   # → VERIFICATION SUCCESSFUL
cryptol counter.cry        # then  :prove bounded_invariant   :prove inductive_invariant   → Q.E.D.
cryptol popcount.cry       # then  :prove popcount_kernighan_eq                            → Q.E.D.
clang -c -emit-llvm -O0 -o popcount.bc popcount.c && saw popcount.saw   # → Proof succeeded!
```

**Day 4 (frontier) — neural networks** (CPU-only; deps preinstalled in the Codespace, or use the [`05_day4_nn_robustness.ipynb`](#option-2--google-colab-per-notebook-zero-setup) and [`06_day4_nn_mnist.ipynb`](#option-2--google-colab-per-notebook-zero-setup) Colabs above)
```bash
pip install -r day04/examples/nn/requirements.txt     # torch + torchvision (CPU) + auto_LiRPA — already in the Codespace
python3 day04/examples/nn/robustness.py               # certifies an L-inf robustness margin, then finds an adversarial example
```

**Capstone — one property, four tools.** [`capstone/`](../capstone/) walks the counter through Z3 → nuXmv → Lean → CBMC/Cryptol; run each tool's command above on the counter files.

## What about nuXmv?

`nuXmv` is license-gated (no public redistribution), so it is **not** in the
public Codespaces image or installed in Colab. Two options:

- **smvis web app** — run nuXmv (spec checking, state/BDD visualization) in the
  browser, and upload your own `.smv` files: <https://bit.ly/fmaiv_smvis>
- **In a notebook** — add nuXmv from the course's *private* teaching image (org
  members only). In the devcontainer, base a small `.devcontainer/Dockerfile` on
  the private image, or `docker cp`/mount the binary, then point `smvis` at it via
  the `SMVIS_NUXMV_PATH` env var. For finite-state models, `NuSMV` (already
  installed) accepts the same SMV language and prints the same `is true/false`
  verdicts.

> **Note:** the "Open in …" badges only work once this repo is pushed to GitHub
> (`ttj/fmaiv`, branch `main`) with these files present.
