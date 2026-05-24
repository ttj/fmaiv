# Day 4 — Program and high-assurance verification

The same counter, now in C with a CBMC harness. Then a pivot to Cryptol with the Software Analysis Workbench (SAW) for bit-precise specification and equivalence checking. We close with a survey of where the field is going — neural-network verification and industrial-scale deployments.

## Schedule

About three hours of lecture and live, hands-on work in three blocks, plus a take-home mini-project. The slide deck (`slides/day04.md`) follows this same structure.

| Block | Approx. length | Content |
|---|---|---|
| Opening | ~10 min | Programs as transition systems on memory states — the same machinery from Day 1, applied to source code. |
| L1 — CBMC | ~50 min | Bounded model checking of C with CBMC: loop unwinding, `assert` / `assume`, nondeterministic inputs. Smoke test (`cbmc --version`). Hands-on: `counter.c` / `counter_check.c`, run `cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions`; then weaken the assertion to `x < 10`, watch CBMC produce a counterexample, and read it. |
| Break | ~10 min | |
| L2 — Cryptol + SAW | ~50 min | A bit-precise functional domain-specific language (DSL) for specifying algorithms; equivalence checking against C implementations via LLVM bitcode and SMT. Hands-on: `counter.cry` (the fifth encoding of the counter), `popcount.cry` / `popcount.c` with `:prove popcount_kernighan_eq`, and the `popcount.saw` C ↔ Cryptol equivalence proof. |
| Break | ~10 min | |
| L3 — The frontier | ~50 min | Neural-network verification (α,β-CROWN, NNV) with a **hands-on** `auto_LiRPA` robustness example (`examples/nn/`, CPU-only / Colab); industrial deployments at AWS, Microsoft, Galois; what comes next. Time to start the take-home mini-project and for Q&A. |
| Wrap | ~10 min | Recap of the four days and intro to the take-home mini-project. |

**Take-home mini-project** (see `assignments/day04.md`).

## Learning objectives for Day 4

By the end of the day, participants will be able to:

- Frame a C program as a transition system on memory states.
- Write a CBMC harness that drives a function with nondeterministic inputs and discharges an assertion against the resulting model.
- Read a CBMC counterexample trace.
- Write a small Cryptol specification of a bit-level algorithm.
- Locate the field's current frontier: where formal methods touches neural networks, autonomous systems, and industrial cryptographic infrastructure.

## Files

```
day04/
├── README.md
├── Dockerfile               ← build a self-contained image with cbmc + cryptol + saw + clang
├── docker-compose.yml       ← convenience wrapper, mounts day04/ at /work
├── slides/day04.md
├── examples/
│   ├── counter.c              ← the running example, fourth encoding (C)
│   ├── counter_check.c        ← CBMC harness; asserts x <= 10 over 25 steps
│   ├── counter.cry            ← the running example, fifth encoding (Cryptol)
│   ├── popcount.cry           ← Cryptol spec (two definitions + equivalence)
│   ├── popcount.c             ← three C popcount implementations
│   ├── popcount.saw           ← SAW script proving C ↔ Cryptol equivalence
│   ├── loop_invariant_demo.c  ← bounded-loop CBMC taster (bridge to Day-3 induction) (+ _starter)
│   ├── array_max / binsearch  ← more CBMC examples (`.c` + `_check.c` + `_starter.c`)
│   ├── caesar / xor_cipher    ← more Cryptol examples (`.cry` + `_starter.cry`)
│   └── nn/                     ← FRONTIER: neural-network robustness (auto_LiRPA): robustness.py, _starter, robustness.ipynb, requirements.txt, README.md
└── assignments/day04.md
```

## Running — Docker (recommended)

CBMC, Cryptol, and SAW have different install paths on every OS (and SAW in particular needs a specific LLVM/clang version to parse bitcode). The bundled `Dockerfile` removes all of that. Everyone on the course runs the same image with the same tool versions.

**Prerequisites.** [Docker Desktop](https://www.docker.com/products/docker-desktop/) on Windows or macOS, or Docker Engine on Linux. That is the only thing you have to install on the host.

### One-time build

From this `day04/` directory:

```bash
docker compose build           # ~5-10 min; downloads CBMC, SAW (~200 MB), clang
```

### Working in the container

Open a shell inside the container with this directory mounted at `/work`:

```bash
docker compose run --rm day04
```

You are now at `/work` with `cbmc`, `cryptol`, `saw`, and `clang` on `PATH`. Edit files in VS Code (or anywhere) on the host — they appear immediately inside the container, and anything the container writes (counterexamples, `.bc` files) lands on the host.

Then run any of the demos:

```bash
cd examples
cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions   # → VERIFICATION SUCCESSFUL
cryptol counter.cry                                                 # → :prove bounded_invariant / :prove inductive_invariant → Q.E.D.
cryptol popcount.cry                                                # → :prove popcount_kernighan_eq → Q.E.D.
clang -c -emit-llvm -O0 -o popcount.bc popcount.c && saw popcount.saw  # → Proof succeeded! popcount_loop
```

### One-shot from the host

If you would rather not enter the shell, dispatch a single command:

```bash
docker compose run --rm day04 \
    bash -lc "cd examples && cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions"
```

### Per-OS notes

- **Windows.** Use either PowerShell or WSL. From PowerShell, `docker compose ...` works as written. The bind mount goes through Docker Desktop's file-sharing; the first time you build, Docker may prompt to share the parent drive — say yes.
- **macOS.** Docker Desktop on Apple Silicon emulates x86_64 for this image (CBMC and SAW publish x86_64 Linux binaries). The first run is slow under emulation; subsequent runs are fine. If you want native arm64 throughout, swap the SAW download in the `Dockerfile` for the `arm64` release once Galois ships one.
- **Linux.** Use `docker compose` or `podman-compose` interchangeably. SELinux users may need `:z` on the bind mount: `volumes: ["./:/work:z"]`.

## Running natively (optional)

If you would rather install the tools directly on the host, the parent [`README.md`](../README.md) has install pointers for CBMC, Cryptol, and SAW per OS. Docker is still strongly preferred — version drift between SAW and the host LLVM is the single most common reason verification fails.

## Frontier: neural-network robustness (`examples/nn/`)

The Day-4 "frontier" hands-on: certify whether a classifier's prediction can change within an L-infinity ball around an input — the same "can the bad thing happen?" question as the rest of the week, now for a neural network. Engine: **auto_LiRPA** (the CROWN bound-propagation library under α,β-CROWN), **CPU-only** (no GPU; runs in ~1s). This is separate from the CBMC/SAW Docker image above.

- **Zero install:** open [`examples/nn/robustness.ipynb`](examples/nn/robustness.ipynb) in Colab (badge at the top of the notebook).
- **Codespace:** the deps are preinstalled (devcontainer `onCreateCommand`) — just `python examples/nn/robustness.py`.
- **Local:**
  ```bash
  pip install -r examples/nn/requirements.txt   # torch (CPU wheel ~200 MB) + auto_LiRPA
  python examples/nn/robustness.py
  ```

You'll see a certified robustness margin (`CERTIFIED ROBUST` at small `eps`), then — past the certified band — a PGD search finding a real adversarial example: the soundness-vs-completeness story for NN verification. The `robustness_starter.py` blanks the `compute_bounds` call. See [`examples/nn/README.md`](examples/nn/README.md) for details and the link to our AAAI'26 VNN-COMP tutorial.
