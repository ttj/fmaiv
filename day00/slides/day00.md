---
title: "Day 0 — Setup & Running the Tools"
subtitle: "FMAIV: Formal Methods & AI-Assisted Verification"
author:
  - "Taylor Johnson — Associate Professor of Computer Science, Computer Engineering & Electrical Engineering; Associate Dean for Graduate Education, College of Connected Computing · taylor.johnson@vanderbilt.edu · [taylortjohnson.com](https://www.taylortjohnson.com/)"
  - "Ben Wooding — Postdoctoral Scholar, Institute for Software Integrated Systems · ben.wooding@vanderbilt.edu · [woodingben.com](https://woodingben.com/)"
institute: "Vanderbilt University"
date: "Setup & Tools"
---

# Day 0 — Setup {.title}

## Running everything in the browser — no install {.section}

**Run it live:** [GitHub Codespaces](https://codespaces.new/ttj/fmaiv) · per-day [Colab notebooks](https://github.com/ttj/fmaiv/tree/main/notebooks) · full reference: [`GETTING_STARTED.md`](https://github.com/ttj/fmaiv/blob/main/GETTING_STARTED.md)

::: notes
The goal of this short "Day 0" is that nobody loses time on setup. By the end every participant has the full toolchain open in their browser and has run one example from each day. We never require a local install — Codespaces gives everyone the identical environment. Walk through this live; have students open their own Codespace as you go. The companion reference is GETTING_STARTED.md (everything here, copy-paste).
:::

---

## Three ways to run — pick one, no install needed

| Way | What you get | Best for |
|---|---|---|
| **GitHub Codespaces** | a full Linux box in the browser, every tool preinstalled | running *everything* |
| **Google Colab** | one notebook at a time, just a Google login | Z3, model checking, the NN demos |
| **Browser apps** | no account at all | quick one-off experiments |

Local installation is fully supported as a backup — see the repo README.

::: notes
Codespaces is the recommended path because it gives the whole class an identical machine with z3, NuSMV, Lean, CBMC, Cryptol, SAW all present — no "works on my laptop" problems, especially for the Day-4 Galois tools (SAW pins a specific clang). Colab is the fallback for anyone who can't use Codespaces. The browser apps are nice for a quick taste with zero friction.
:::

---

## GitHub Codespaces — open it

1. Sign in to GitHub (free; students get more hours via GitHub Education).
2. **github.com/ttj/fmaiv → Code ▸ Codespaces ▸ Create codespace on main**
   (or the **Open in Codespaces** badge in the README).
3. Wait ~1–2 min the first time; a banner lists the ready tools.

Preinstalled: `z3` · `NuSMV` · `lean`/`lake` · `cbmc` · `cryptol` · `saw` · `smvis`, plus `torch`/`auto_LiRPA` for the Day-4 neural-network notebooks.

::: notes
The first build is a minute or two (it pulls our prebuilt image, ghcr.io/ttj/fmaiv-autograde, which has the whole toolchain). After that, resuming is instant. Free tier: 120 core-hours/month, 180 for verified students — plenty for the course. Tell students the Codespace pauses when idle and their files persist.
:::

---

## The layout & the terminal

- **Left:** file explorer (`day01/` … `day04/`, `notebooks/`).
- **Middle:** the editor.
- **Bottom:** the **terminal** — where you type commands (**Terminal ▸ New Terminal**, or `` Ctrl+` ``).

```bash
pwd                          # where am I? (the repo root)
ls day01/examples            # list a folder
python3 day01/examples/z3_smoke.py    # run a file
```

::: notes
For students new to a command line: one command per line, Enter to run. You always start at the repo root, so all the dayNN/... paths just work. `pwd` answers "where am I", `ls` lists, and you run a program by naming the tool and the file. That's 90% of what they need today.
:::

---

## Day 1 — SAT/SMT with Z3

```bash
python3 day01/examples/z3_smoke.py        # first sat/unsat query
python3 day01/examples/z3_pigeonhole.py   # an UNSAT proof
python3 day01/examples/z3_entailment.py   # prove by refuting the negation
python3 day01/examples/puzzles/sudoku.py  # also: nqueens, magic_square, kenken
z3 day01/examples/z3_smt_basics.smt2      # the SMT-LIB text format
```

Each puzzle ships a `*_starter.py` to complete yourself.

::: notes
Z3 is the gentlest on-ramp — pure Python, instant. The pigeonhole / entailment examples preview Day 1's big idea: prove a property by asking the solver to refute its negation (UNSAT = proof). The puzzles are the fun hook; the starters are the homework.
:::

---

## Day 2 — Model checking with NuSMV

Command is **`NuSMV`** (capital letters). The slides say *nuXmv*; the open **NuSMV** is the drop-in — same language, same verdicts.

```bash
NuSMV day02/examples/counter.smv          # "-- specification ... is true/false"
NuSMV -bmc -bmc_length 12 day02/examples/bmc_depth.smv
```

Interactive console: `NuSMV -int`, then `read_model -i <file>` → `go` → `check_property` → `pick_state -r` → `simulate -r -k 5` → `show_traces` → `quit`.

::: notes
Stress the capitalization — `nusmv` won't be found. nuXmv is license-gated so it's not in the cloud image; NuSMV speaks the identical SMV language and prints the same "is true/false". The interactive console is worth a live demo: read the model, build it, check properties, then pick a state and simulate to watch a trace / counterexample. For BDD and state-graph pictures, point them at the smvis web app.
:::

---

## Day 3 — Theorem proving with Lean 4

```bash
cd day03/examples/CounterDemo
lake build                       # checks every proof; green = all pass
lake build CounterDemo.Counter   # one module
cd -
```

Open any `.lean` file in the editor to see the **proof state live** (Lean 4 extension preinstalled). Mathlib-free → builds in seconds.

::: notes
The magic moment is opening a .lean file and watching the goal state update as you move the cursor through the proof — that's interactive theorem proving. Because we're Mathlib-free, `lake build` is seconds, not the usual multi-gigabyte wait. The *Starter modules are the exercises.
:::

---

## Day 4 — Programs: CBMC, Cryptol, SAW

```bash
cd day04/examples
cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions   # VERIFICATION SUCCESSFUL
cryptol -c ":prove bounded_invariant" counter.cry                  # Q.E.D.
clang -c -emit-llvm -O0 -o popcount.bc popcount.c && saw popcount.saw   # Proof succeeded!
cd -
```

::: notes
This is where Codespaces really pays off: CBMC, Cryptol, and SAW all preinstalled with a compatible clang — the exact pinning that's painful on laptops. CBMC checks the actual C; Cryptol :prove discharges bit-precise specs; SAW proves the C matches the Cryptol spec. `cryptol counter.cry` (no -c) opens the interactive shell.
:::

---

## Day 4 — Frontier: neural-network robustness

Two notebooks (they use PyTorch). In the Codespace, open and **Run All**:

- [`notebooks/05_day4_nn_robustness.ipynb`](https://github.com/ttj/fmaiv/blob/main/notebooks/05_day4_nn_robustness.ipynb) — a 2-D toy: certify a robustness margin, see the decision boundary.
- [`notebooks/06_day4_nn_mnist.ipynb`](https://github.com/ttj/fmaiv/blob/main/notebooks/06_day4_nn_mnist.ipynb) — multi-class MNIST: IBP vs CROWN vs α-CROWN.

CPU-only; the script form is `python3 day04/examples/nn/robustness.py`.

::: notes
The NN notebooks pin a CPU PyTorch + auto_LiRPA in their first cell, so they run anywhere (Codespaces, Colab, locally) — no GPU. The 2-D toy makes "what does a certified robustness box mean" visual; MNIST shows why the set representation (interval vs linear-bound vs star) decides how much you can certify.
:::

---

## The notebooks — one per day

In the Codespace: click a notebook in `notebooks/`, then **Run All** (or Shift+Enter per cell). Or run `jupyter lab` for a full tab.

| | |
|---|---|
| `01_day1_logic_sat_smt` | Z3 |
| `02_day2_model_checking` | NuSMV |
| `03_day3_theorem_proving` | Lean |
| `04_day4_program_verif` | CBMC · Cryptol · SAW |
| `05/06_day4_nn_*` | NN robustness · MNIST |

::: notes
The runner notebooks (01–04) just execute the same dayNN/examples files you'd run by hand — they're a guided, click-to-run version of the terminal commands, so students can choose whichever they're comfortable with. Everything is the same single source of truth.
:::

---

## No Codespace? Colab & browser apps

- **Colab** (just a Google login): each notebook has an **Open in Colab** badge; the first cell installs what's missing. Table in [`notebooks/README`](https://github.com/ttj/fmaiv/blob/main/notebooks/README.md).
- **Z3 in the browser:** <https://microsoft.github.io/z3guide/>
- **smvis** (NuSMV + state/BDD pictures): <https://bit.ly/fmaiv_smvis>
- **Lean web editor:** <https://live.lean-lang.org/> · [Natural Number Game](https://adam.math.hhu.de/)

::: notes
For anyone who can't open a Codespace, Colab covers Z3, model checking, and the NN demos with zero setup. The browser apps are great for a 30-second taste — the z3guide is genuinely good for self-study, and smvis gives the BDD/state-graph visuals that the command line doesn't.
:::

---

## Bring an AI assistant + where to go next

- **AI coding assistant** (we use it throughout): install **Claude Code**, **OpenAI Codex**, or **Gemini Code Assist** from the Extensions panel (`Ctrl+Shift+X`).
- **Capstone:** [`capstone/`](https://github.com/ttj/fmaiv/tree/main/capstone) — one property, all four tools.
- **Full reference:** [`GETTING_STARTED.md`](https://github.com/ttj/fmaiv/blob/main/GETTING_STARTED.md) — every command here, plus troubleshooting.

**Cheat sheet:** `pwd` / `ls` to look around · `NuSMV` is capitalized · `cd -` returns to the repo root · `help` inside a tool's console.

::: notes
End by having everyone install an AI assistant — Day 1's thesis is that cheap code generation makes verification the essential skill, so we want them using AI + a checker from the start. Point them to GETTING_STARTED.md as the thing to keep open all week, and the capstone as the synthesis. Then we're ready for Day 1.
:::
