# Neural-network robustness (Day 4 frontier hands-on)

Certify whether a classifier's prediction can change inside an L-infinity ball
around an input — the same "can the bad thing happen?" question as the rest of
the week, now for a neural network. Engine: **auto_LiRPA** (the CROWN
bound-propagation library under [alpha,beta-CROWN](https://github.com/Verified-Intelligence/alpha-beta-CROWN),
the VNN-COMP winner).

Everything is **CPU-only** and tiny (a 2-D, 2-class MLP) — no GPU, no dataset
download. It runs in about a second.

## Run it

**Colab (zero install):** open [`robustness.ipynb`](robustness.ipynb) via the
"Open in Colab" badge at the top of the notebook.

**Codespace / local:**

```bash
# CPU wheel of PyTorch (~200 MB, not the ~2.5 GB CUDA build), then auto_LiRPA
# (installed from GitHub — PyPI's auto_LiRPA is an ancient 0.2/0.3):
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
python robustness.py
```

Expected: small `eps` prints `CERTIFIED ROBUST`, and the certified margin shrinks
as `eps` grows (eventually below 0 — CROWN is *sound but incomplete*).

## Files

| File | What it is |
|---|---|
| `robustness.py` | full solution: train, then certify the margin over a sweep of `eps` (+ a PGD falsifier) |
| `robustness_starter.py` | same, with the one `compute_bounds` call blanked out (the TODO) |
| `robustness.ipynb` | the Colab notebook (adds a decision-boundary + eps-ball plot) |
| `requirements.txt` | `torch` (CPU) + `auto_LiRPA` |

## Going bigger

The identical code applies to a trained MNIST/CIFAR network. For full-scale
verification, complete verifiers, and competition benchmarks, see our
**[AAAI'26 VNN-COMP tutorial](https://vnn-comp.github.io/#aaai2026)** (slides +
Colab notebooks).
