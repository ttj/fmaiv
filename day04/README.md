# Day 4 — Program and high-assurance verification

The same counter, now in C with a CBMC harness. Then a pivot to Cryptol with the Software Analysis Workbench (SAW) for bit-precise specification and equivalence checking. We close with a survey of where the field is going — neural-network verification and industrial-scale deployments.

## Schedule

### Lecture and live demo

| Block | Approx. length | Content |
|---|---|---|
| 4.1 | ~20 min | Programs as transition systems on memory states. Connect back to Day 1; this is the same machinery, applied to source code. |
| 4.2 | ~45 min | Bounded model checking of C with CBMC. Loop unwinding, `assert` / `assume`, nondeterministic inputs. Live demo: `cbmc counter.c counter_check.c --unwind 26`. |
| 4.3 | ~40 min | Cryptol and SAW. A bit-precise functional DSL for specifying algorithms. Equivalence checking against C implementations via LLVM bitcode and SMT. Live demo: `popcount.cry` with `:prove popcount_kernighan_eq`. |
| 4.4 | ~15 min | Survey. Neural-network verification (α,β-CROWN, NNV); industrial deployments at AWS, Microsoft, Galois; what is next. |

### Hands-on

| Block | Approx. length | Activity |
|---|---|---|
| 4.5 | ~15 min | Smoke test: `cbmc --version`, `cryptol --version`, `saw --version`. |
| 4.6 | ~30 min | Walk through `counter.c` / `counter_check.c`. Run CBMC. Then weaken the assertion to `x < 10`, watch CBMC produce a counterexample, and read it. |
| 4.7 | ~30 min | Walk through `popcount.cry` and `popcount.c`. Run `cryptol popcount.cry` and try `:prove popcount_kernighan_eq` interactively. |
| 4.8 | ~45 min | Mini-project (see `assignments/day04.md`). |

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
│   └── popcount.saw           ← SAW script proving C ↔ Cryptol equivalence
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

You are now at `/work` with `cbmc`, `cryptol`, `saw`, and `clang` on `PATH`. Edit files in VS Code (or anywhere) on the host — they appear instantly inside the container, and anything the container writes (counterexamples, `.bc` files) lands on the host.

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

## Running — native (if you really want to)

If you would rather install the tools directly on the host, the parent [`README.md`](../README.md) has install pointers for CBMC, Cryptol, and SAW per OS. Docker is still strongly preferred — version drift between SAW and the host LLVM is the single most common reason verification fails.
