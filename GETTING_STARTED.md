# Getting started — running the FMAIV examples

New to Codespaces, notebooks, or command-line verification tools? This is the
hand-holding guide. **You do not need to install anything** — everything runs in
your browser. (Local installation is supported too; see the main
[README](README.md#local-installation-backup).)

There are three ways in, easiest first:

| Way | What you get | Best for |
|---|---|---|
| **GitHub Codespaces** | a full Linux machine in the browser with *every* tool preinstalled | running everything, the terminal, Lean/CBMC/Cryptol/SAW |
| **Google Colab** | one notebook at a time, zero setup (just a Google login) | Z3, model checking, the neural-network demos |
| **Browser apps** | no account at all | quick one-off experiments |

---

## 1. GitHub Codespaces (recommended)

A **Codespace** is a complete Linux computer running in the cloud that you use
through your browser (or VS Code). Ours comes with `z3`, `NuSMV`, `lean`, `cbmc`,
`cryptol`, `saw`, and `smvis` already installed — nothing to set up.

### Open it
1. Sign in to GitHub (a free account is fine; verified students get more hours via [GitHub Education](https://education.github.com/)).
2. Go to **<https://github.com/ttj/fmaiv>** and click **Code ▸ Codespaces ▸ Create codespace on main** — or just click this badge: [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ttj/fmaiv)
3. Wait ~1–2 minutes the first time while it builds. When it's ready you'll see a banner listing the tools.

### What you're looking at
- **Left:** the file explorer (folders `day01/` … `day04/`, `notebooks/`, etc.).
- **Middle:** the editor.
- **Bottom:** the **terminal** — this is where you type commands. Open one with **Terminal ▸ New Terminal** (or `` Ctrl+` ``).

### Terminal basics (if this is new)
The terminal runs one command per line; press **Enter** to run.
```bash
pwd                       # "print working directory" — where you are
ls                        # list files here
ls day01/examples         # list a folder's contents
python3 day01/examples/z3_smoke.py   # run a Python file
```
You start in the repository root, so the `dayNN/...` paths below work as-is.

---

## 2. Run each day's examples (in the Codespace terminal)

Every command below is copy-paste-ready. Each day also has a notebook
([section 3](#3-run-the-notebooks)) that runs these for you.

### Day 1 — SAT/SMT with Z3
```bash
python3 day01/examples/z3_smoke.py          # a first sat/unsat query
python3 day01/examples/z3_pigeonhole.py     # an UNSAT proof
python3 day01/examples/z3_counter_bounded.py
python3 day01/examples/z3_entailment.py     # "prove by refuting the negation"
python3 day01/examples/z3_synthesis.py
python3 day01/examples/puzzles/sudoku.py    # also: nqueens.py, magic_square.py, kenken.py
z3 day01/examples/z3_smt_basics.smt2        # the SMT-LIB text format
```
Each puzzle ships a `*_starter.py` to fill in yourself.

### Day 2 — Model checking with NuSMV
The command is **`NuSMV`** (capital N-u-S-M-V; Linux is case-sensitive). The
slides say *nuXmv* — that's license-gated, so the Codespace ships **NuSMV**, the
open drop-in (same SMV language, same `is true/false` verdicts).
```bash
NuSMV day02/examples/counter.smv            # prints "-- specification ... is true/false"
NuSMV day02/examples/mutex.smv              # also: peterson, prodcons, elevator,
NuSMV day02/examples/traffic_light.smv      #       gcd_01, spec_challenge
NuSMV -bmc -bmc_length 12 day02/examples/bmc_depth.smv   # bounded model checking to depth 12
```
**Interactive console** (step through a model, simulate, inspect):
```bash
NuSMV -int
```
then at the `NuSMV >` prompt:
```
read_model -i day02/examples/counter.smv
go                       # build the model (flatten + encode + build)
check_property           # check every SPEC / LTLSPEC / INVARSPEC
pick_state -r            # pick a random start state
simulate -r -k 5         # take 5 random steps
show_traces              # print the trace
quit
```
Type `help` for all commands, or `help <command>` for one. To visualize states
and BDDs in the browser, use the **smvis** app: <https://bit.ly/fmaiv_smvis>.

### Day 3 — Theorem proving with Lean 4
```bash
cd day03/examples/CounterDemo
lake build                                  # checks every proof; green = all proofs pass
lake build CounterDemo.Counter              # build one module
lake build CounterDemo.CounterStarter       # the exercise to fill in
cd -                                        # go back to the repo root
```
Open any `.lean` file in the editor to see the proof state live (the **Lean 4**
extension is preinstalled). It's Mathlib-free, so builds take seconds.

### Day 4 — Programs: CBMC, Cryptol, SAW
```bash
cd day04/examples
cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions   # → VERIFICATION SUCCESSFUL
cryptol -c ":prove bounded_invariant" counter.cry                   # → Q.E.D.
cryptol -c ":prove inductive_invariant" counter.cry                 # → Q.E.D.
cryptol -c ":prove popcount_kernighan_eq" popcount.cry             # → Q.E.D.
clang -c -emit-llvm -O0 -o popcount.bc popcount.c && saw popcount.saw   # → Proof succeeded!
cd -
```
`cryptol counter.cry` (no `-c`) opens the interactive Cryptol shell; type
`:prove bounded_invariant`, `:help`, or `:quit`.

### Day 4 — Frontier: neural-network robustness
These are notebooks (they need PyTorch). Open
[`notebooks/05_day4_nn_robustness.ipynb`](notebooks/05_day4_nn_robustness.ipynb)
and [`notebooks/06_day4_nn_mnist.ipynb`](notebooks/06_day4_nn_mnist.ipynb) and
**Run All** (see the next section). The script form is
`python3 day04/examples/nn/robustness.py`.

### Capstone — one property, four tools
[`capstone/`](capstone/) walks the running counter (`x ≤ 10`) through Z3 → NuSMV
→ Lean → CBMC → Cryptol. Run each tool's command above on the counter files and
compare what each style of verification buys you.

---

## 3. Run the notebooks

There's **one notebook per day** in [`notebooks/`](notebooks/). In the Codespace:

- Click a notebook in the file explorer (e.g. `notebooks/01_day1_logic_sat_smt.ipynb`). It opens in the editor.
- Click **Run All** at the top (or run cells one at a time with **Shift+Enter**). The first cell sets things up; the rest run the day's real examples.
- Prefer a full Jupyter tab? Run `jupyter lab` in the terminal and open the forwarded port.

The runner notebooks (01–04) execute the same `dayNN/examples/` files you'd run
by hand. The Day-4 frontier notebooks (05, 06) install PyTorch + auto_LiRPA in
their first cell (a minute or so) and then certify a neural network.

---

## 4. Google Colab (no Codespace needed)

Each notebook also opens in **Colab** with just a Google login — the first cell
installs only what's missing. Open them from the table in
[`notebooks/README.md`](notebooks/README.md#option-2--google-colab-per-notebook-zero-setup),
or click the **"Open in Colab"** badge at the top of any notebook on GitHub.

`z3`, `cbmc`, and `NuSMV` install in seconds on Colab; `cryptol`/`saw` are large
downloads (prefer Codespaces for those), and the Day-4 program notebook skips
them by default unless you set `INSTALL_CRYPTOL_SAW = True`.

---

## 5. Browser apps (no account)

- **Z3 (Day 1)** — the interactive guide: <https://microsoft.github.io/z3guide/>
- **Model checking (Day 2)** — **smvis** runs NuSMV with state-graph/BDD visualization and accepts your own `.smv` files: <https://bit.ly/fmaiv_smvis>
- **Lean (Day 3)** — the web editor <https://live.lean-lang.org/> and the gamified [Natural Number Game](https://adam.math.hhu.de/)

---

## 6. An AI coding assistant (recommended)

We use AI-assisted verification throughout. Bring at least one assistant — in the
Codespace or local VS Code, install from the Extensions panel (`Ctrl+Shift+X`):
**Claude Code** (Anthropic), **OpenAI Codex**, or **Gemini Code Assist**. See the
main [README](README.md#ai-coding-assistant-recommended-either-path) for links.

---

## 7. Troubleshooting

- **`nusmv: command not found`** — it's **`NuSMV`** (capital letters).
- **`cryptol`/`saw: command not found` on Colab** — they're not installed there by default; use the Codespace, or set `INSTALL_CRYPTOL_SAW = True` in `04_day4_program_verif.ipynb`.
- **A `bash` script "works on my machine" but not in Git Bash on Windows** — run it in the Codespace, WSL, or Git Bash; the repo's `*.sh` are Linux scripts.
- **"Where am I?"** — `pwd`. The example paths assume you're at the repo root; `cd -` returns you there.
- **Codespace stopped / changes gone?** — Codespaces pause when idle and resume where you left off; your files persist. Manage them at <https://github.com/codespaces>.
- **nuXmv specifically** — license-gated, so not in Codespaces/Colab. Use the smvis web app, or the preinstalled `NuSMV` (same language and verdicts) for finite-state models.

Still stuck? Open an issue at <https://github.com/ttj/fmaiv/issues> or email the instructors (bottom of the [README](README.md#instructors)).
