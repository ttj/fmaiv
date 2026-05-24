# Neural-network robustness (Day 4 frontier hands-on)

Certify whether a classifier's prediction can change inside an L-infinity ball
around an input — the same "can the bad thing happen?" question as the rest of
the week, now for a neural network. Engine: **auto_LiRPA** (the CROWN
bound-propagation library under [α,β-CROWN](https://github.com/Verified-Intelligence/alpha-beta-CROWN),
the VNN-COMP winner).

This folder holds the **script** form (`robustness.py`); the interactive **Colab
notebooks** live in [`notebooks/`](../../../notebooks/):

- [`05_day4_nn_robustness.ipynb`](../../../notebooks/05_day4_nn_robustness.ipynb) — the 2-D, 2-class toy, with the decision-boundary + eps-ball figure (global, zoom, and output-margin views). CPU-only, runs in seconds.
- [`06_day4_nn_mnist.ipynb`](../../../notebooks/06_day4_nn_mnist.ipynb) — multi-class **MNIST** (10 classes), comparing IBP vs CROWN vs α-CROWN tightness. CPU-only, about a minute.

## Run the script (Codespace / local)

```bash
# CPU wheels of PyTorch (~200 MB, not the ~2.5 GB CUDA build) + torchvision, then
# auto_LiRPA (installed from GitHub — PyPI's auto_LiRPA is an ancient 0.2/0.3):
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
python robustness.py
```

Expected: small `eps` prints `CERTIFIED ROBUST`, the certified margin shrinks as
`eps` grows (eventually below 0 — CROWN is *sound but incomplete*), and a
random-restart PGD search then finds an adversarial example.

## Files

| File | What it is |
|---|---|
| `robustness.py` | full solution: train, then certify the margin over a sweep of `eps` (+ a PGD falsifier) |
| `robustness_starter.py` | same, with the one `compute_bounds` call blanked out (the TODO) |
| `requirements.txt` | `torch` + `torchvision` (CPU) + `auto_LiRPA` |

The interactive notebooks are in [`notebooks/`](../../../notebooks/) (see the list above).

## Going bigger

The identical code applies to a trained MNIST/CIFAR network — the MNIST notebook
shows exactly that. For full-scale verification, complete verifiers, and
competition benchmarks, see our
**[AAAI'26 VNN-COMP tutorial](https://vnn-comp.github.io/#aaai2026)** (slides +
Colab notebooks).
