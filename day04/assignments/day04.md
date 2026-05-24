# Day 4 mini-project — Program and high-assurance verification

**Goal.** Write a small C program (or Cryptol spec), set up a verification harness, and discharge a property end-to-end.

**Time budget.** 60–90 minutes. Pick **one track**.

## Track A — CBMC

### A.1 Warm-up (15 min)

1. Run `cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions`. Confirm `VERIFICATION SUCCESSFUL`.
2. Weaken the assertion in `counter_check.c` from `assert(s.x <= 10)` to `assert(s.x < 10)`. Re-run. Read the counterexample. Identify the exact `press` sequence that drove `x` to 10.
3. Restore the original assertion.

### A.2 Your own program (45–60 min)

Write a small C function and a CBMC harness for one of:

- **Saturating counter.** A counter that increments on input `1` and decrements on input `-1`, clamped to `[0, 10]`. Property: the counter is always in `[0, 10]`.
- **Fixed-size queue.** A circular buffer of capacity 8. Property: after a `push` and then a `pop`, the value returned is the value pushed (FIFO discipline), and the buffer is never reported full or empty incorrectly.
- **Integer absolute value.** Write `int my_abs(int x)`. Property: for every input that does not trigger undefined behavior (so, exclude `INT_MIN`), `my_abs(x) >= 0` and `my_abs(x) == x || my_abs(x) == -x`. Use `__CPROVER_assume` to exclude `INT_MIN`.

Each harness should:

- Pull inputs from `nondet_*()` functions.
- Loop or call the function a few times.
- Assert the property you want.

### A.3 Counterexample (15 min)

Introduce a single off-by-one or sign bug. Re-run CBMC. Capture the counterexample. One paragraph: what state did the bug allow, and what specific line in your code caused it.

### Submit

A zip with: your `.c` files, the CBMC command line you used, the verdict from a clean run, and the counterexample from the buggy run.

## Track B — Cryptol + SAW

### B.1 Warm-up (15 min)

1. Run `cryptol counter.cry`. Then `:prove bounded_invariant` (mirrors the CBMC harness) and `:prove inductive_invariant` (mirrors the Lean proof). Both should report `Q.E.D.`. Same counter as Days 1–3; SMT discharges both bounded and inductive claims.
2. Run `cryptol popcount.cry`. Then `:prove popcount_kernighan_eq`. Should report `Q.E.D.`.
3. Run `:sat \(x : [8]) -> popcount_simple x != popcount_kernighan x`. Should report "Unsatisfiable" — the negation has no satisfying input.
4. Optional: if SAW is installed, run `clang -c -emit-llvm -O0 -o popcount.bc popcount.c && saw popcount.saw`. Should report `Proof succeeded! popcount_loop`.

### B.2 Your own spec (45–60 min)

Write a Cryptol spec for one of:

- **4-bit Caesar cipher.** Encryption: rotate a `[4]` left by a key `k : [2]`. Decryption: rotate right by `k`. Property: `decrypt(k, encrypt(k, x)) == x` for every input.
- **Parity bit.** A function `parity : [8] -> Bit` that returns the XOR of all eight bits. Equivalent definitions: `xor_fold` and a lookup table for nibbles XORed together. Property: the two definitions agree.
- **CRC-4 (small CRC).** Pick a CRC-4 polynomial; write the bit-shift definition. (Best for participants comfortable with the bit-level idiom.)

For each, in Cryptol:

- Write at least two definitions of the same function.
- Write a `property` stating they agree.
- Discharge it with `:prove`.

If SAW is installed and you have a C implementation handy, write an equivalent `.saw` script following `popcount.saw` as a template.

### Submit

A zip with: your `.cry` file, the REPL transcript of `:prove your_property`, and (optionally) a SAW script and verdict.

## More worked examples (`examples/`)

Cryptol specs with proved properties and C programs with CBMC harnesses, each
with a starter you complete.

**Cryptol** (`:prove` reports `Q.E.D.`):

| Spec | Property | Solution | Starter |
|---|---|---|---|
| Shift ("Caesar") cipher | decrypt inverts encrypt, for all keys/messages | `caesar.cry` | `caesar_starter.cry` |
| Repeating-key XOR cipher | round-trip + involutive | `xor_cipher.cry` | `xor_cipher_starter.cry` |

```bash
cryptol caesar.cry
caesar> :prove roundtrip          # Q.E.D.
```

**CBMC** (the `*_check.c` harness is the spec; verify a `.c` against it):

| Program | Property checked | Solution | Starter |
|---|---|---|---|
| Array maximum | result ≥ every element, and equals some element | `array_max.c` + `array_max_check.c` | `array_max_starter.c` |
| Binary search (sorted input) | found ⇒ `a[r] == key`; not found ⇒ key absent | `binsearch.c` + `binsearch_check.c` | `binsearch_starter.c` |

```bash
cbmc array_max.c  array_max_check.c  --unwind 6  --unwinding-assertions   # SUCCESSFUL
cbmc binsearch.c  binsearch_check.c  --unwind 10 --unwinding-assertions   # SUCCESSFUL
```

The `*_starter.{cry,c}` files are stubs: Cryptol returns a **Counterexample**
and CBMC reports **VERIFICATION FAILED** until you implement them (verify your
version against the same property/harness).

### Bounded loops, and why "for all `n`" needs induction (bridge to Day 3)

CBMC is a *bounded* checker. See [`loop_invariant_demo.c`](../examples/loop_invariant_demo.c)
(starter: [`loop_invariant_demo_starter.c`](../examples/loop_invariant_demo_starter.c)):

```bash
cbmc loop_invariant_demo.c --unwind 21 --unwinding-assertions   # SUCCESSFUL (n in 0..20)
```

The loop invariant `x == i` is the inductive fact that makes `x == n` true. CBMC
confirms it for every `n` *up to* the bound `N` (we `__CPROVER_assume(n <= N)`
and unwind `N+1`). The starter omits that bound — `--unwinding-assertions` then
*fails*, because `n` is unbounded. Proving the same fact for **all** `n` at once,
with no bound, is exactly what the Day-3 Lean proof does by induction.

## Frontier: neural-network robustness (`examples/nn/`)

The same verification question — "can the bad thing happen?" — for a neural
network: within an L-infinity ball of radius `eps` around an input, can the
prediction change? [`examples/nn/`](../examples/nn/) certifies it with
**auto_LiRPA** (the CROWN engine under α,β-CROWN, the VNN-COMP winner), CPU-only:

- Zero-install: open [`robustness.ipynb`](../examples/nn/robustness.ipynb) in Colab.
- Codespace/local: `pip install -r examples/nn/requirements.txt; python examples/nn/robustness.py`
  (the starter `robustness_starter.py` blanks the `compute_bounds` call).

You will see a *certified* band of small `eps`, then a region where CROWN cannot
certify and a PGD search finds a real adversarial example — the soundness vs.
completeness story, now for learned models. For full-scale MNIST/CIFAR
verification, see our [AAAI'26 VNN-COMP tutorial](https://vnn-comp.github.io/#aaai2026).

## Capstone — one property, four tools

To tie the week together, the [capstone](../../capstone/) walks the running
counter (`x ≤ 10`) through Z3, nuXmv, Lean, and CBMC/Cryptol and asks you to
compare what each style of verification buys you (bounded vs. unbounded vs.
inductive vs. bit-precise).

## Survey discussion (optional, 10 min plenary)

If time allows, pick one of the following and write a single paragraph:

- Look up the most recent VNN-COMP results. Which neural-network architectures are now in routine reach of α,β-CROWN, and which still aren't?
- Read the AWS Provable Security s2n page. Which property is continuously verified, and what tool stack underpins it?
- For your own research area: name one thing in your daily work that would be a candidate for formal verification, and one thing that would be the wrong fit.

## Connecting to Days 1–3

- Day 1's bounded SMT was running implicitly inside CBMC the whole time today.
- Day 2's transition systems are programs once you let the program counter be part of the state.
- Day 3's inductive invariants are exactly what Cryptol's `:prove` discharges, but for finite-width bit vectors and via SMT instead of by hand.

The week you have just had is approximately the toolchain of any formal-methods engineer working in 2026: SMT for foundations, model checking for finite reactive systems, theorem proving for the mathematical and parametric content, source-level checkers for the actual code.
