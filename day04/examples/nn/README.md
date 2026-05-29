# Neural-network robustness (Day 4 frontier hands-on)

Certify whether a classifier's prediction can change inside an L-infinity ball
around an input — the same "can the bad thing happen?" question as the rest of
the week, now for a neural network. Engine: **auto_LiRPA** (the CROWN
bound-propagation library under [α,β-CROWN](https://github.com/Verified-Intelligence/alpha-beta-CROWN),
the VNN-COMP winner).

This folder holds the **script** forms; the interactive **Colab notebooks** live in [`notebooks/`](../../../notebooks/):

- [`05_day4_nn_robustness.ipynb`](../../../notebooks/05_day4_nn_robustness.ipynb) — the 2-D, 2-class toy + a 3-input / 2-output **compare-reachability** demo (IBP vs CROWN vs α-CROWN over an L∞ cube). CPU-only, runs in seconds.
- [`06_day4_nn_mnist.ipynb`](../../../notebooks/06_day4_nn_mnist.ipynb) — multi-class **MNIST** (10 classes), the IBP vs CROWN vs α-CROWN certified-accuracy comparison, the **output-set-before-argmax** (verify_fc-style) per-class interval plot, and a PGD adversarial example. CPU-only, about a minute.

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
| `compare_reachability.py` | 3-in / 2-out ReLU MLP + an L∞ cube; reports IBP / CROWN / α-CROWN output-bounding-box areas vs sampling truth (the NNV [`compareReachability`](https://github.com/verivital/nnv/tree/master/code/nnv/examples/Tutorial/NN/compareReachability) MATLAB demo, in Python) |
| `verify_fc.py` | MNIST FC classifier; prints CROWN's `[lo_j, hi_j]` per output neuron for a chosen test image — the **output set before argmax** — and decides robustness from one inequality on those intervals (Python analog of NNV's [`verify_fc.m`](https://github.com/verivital/nnv/blob/master/code/nnv/examples/Tutorial/NN/MNIST/verify_fc.m)) |
| `adversarial_demo.py` | the *attack* side: FGSM (Goodfellow et al., ICLR 2015) + PGD (Madry et al., ICLR 2018) on the same 2-D MLP. Image-attack family extends to LLM jailbreaks — GCG (Zou et al., 2023; arXiv:2307.15043). `torch` only, no auto_LiRPA needed |
| `requirements.txt` | `torch` + `torchvision` (CPU) + `auto_LiRPA` |

The interactive notebooks are in [`notebooks/`](../../../notebooks/) (see the list above).

## Going bigger

The identical code applies to a trained MNIST/CIFAR network — the MNIST notebook
shows exactly that. For full-scale verification, complete verifiers, and
competition benchmarks, see our
**[AAAI'26 VNN-COMP tutorial](https://vnn-comp.github.io/#aaai2026)** (slides +
Colab notebooks).
