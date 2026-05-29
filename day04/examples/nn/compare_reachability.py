"""3-input / 2-output reachability comparison (auto_LiRPA): IBP vs CROWN vs alpha-CROWN.

A small ReLU MLP (3 -> 8 -> 4 -> 2), an L-infinity *cube* input set, and three
sound over-approximations of the reachable OUTPUT set. The point: every method
here is sound (its rectangle contains every output of every input in the cube),
and the tighter the relaxation, the smaller the rectangle.

This is the auto_LiRPA analog of NNV's `compareReachability` MATLAB demo
  https://github.com/verivital/nnv/tree/master/code/nnv/examples/Tutorial/NN/compareReachability
adapted to a 3-input / 2-output network and an L-infinity *cube* input region,
per the slide pairing in the AAAI'26 VNN-COMP tutorial (https://vnn-comp.github.io/#aaai2026).

Run:   python compare_reachability.py
Deps:  pip install -r requirements.txt
"""
import torch
import torch.nn as nn
from auto_LiRPA import BoundedModule, BoundedTensor
from auto_LiRPA.perturbations import PerturbationLpNorm

torch.manual_seed(0)


# ---- 1. a small 3-input / 2-output ReLU MLP (random init, then frozen) -------
class MLP3to2(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(3, 8), nn.ReLU(),
            nn.Linear(8, 4), nn.ReLU(),
            nn.Linear(4, 2),
        )

    def forward(self, x):
        return self.net(x)


def true_output_box(model, x0, eps, k=33):
    """Brute-force ground-truth bounds: densely sample the cube and read the
    component-wise min/max of the network outputs. Cheap for a 3-D cube and a
    tiny net; gives the rectangle that every SOUND method must contain."""
    g = torch.linspace(-eps, eps, k)
    a, b, c = torch.meshgrid(g, g, g, indexing="ij")
    pts = x0 + torch.stack([a, b, c], dim=-1).reshape(-1, 3)
    with torch.no_grad():
        out = model(pts)
    return out.min(0).values.tolist(), out.max(0).values.tolist()


def crown_box(bounded, x0, eps, method):
    """auto_LiRPA bounds on the network outputs under an L-inf eps cube input."""
    ptb = PerturbationLpNorm(norm=float("inf"), eps=eps)
    lb, ub = bounded.compute_bounds(x=(BoundedTensor(x0, ptb),), method=method)
    return lb[0].tolist(), ub[0].tolist()


def area(lo, hi):
    return (hi[0] - lo[0]) * (hi[1] - lo[1])


if __name__ == "__main__":
    model = MLP3to2().eval()
    x0 = torch.tensor([[0.2, -0.1, 0.5]])
    eps = 0.20

    bounded = BoundedModule(
        model,
        torch.empty_like(x0),
        bound_opts={"optimize_bound_args": {"iteration": 5}},   # alpha-CROWN: few iters keeps it fast on CPU
    )

    true_lo, true_hi = true_output_box(model, x0, eps)
    methods = [("IBP",             "IBP (intervals)    "),
               ("CROWN",           "CROWN (linear)     "),
               ("CROWN-Optimized", "alpha-CROWN        ")]

    print(f"network: 3 -> 8 -> 4 -> 2 ReLU MLP   (x0 = {x0.tolist()[0]})")
    print(f"input set: L-inf cube of side {2 * eps} (eps = {eps})")
    print()
    print(f"{'method':<22} y0 bounds          y1 bounds          rect area")
    print(f"{'sampling (truth)':<22} [{true_lo[0]:+.3f}, {true_hi[0]:+.3f}]   "
          f"[{true_lo[1]:+.3f}, {true_hi[1]:+.3f}]   "
          f"{area(true_lo, true_hi):7.3f}")

    last_area = None
    rows = []
    for key, label in methods:
        lo, hi = crown_box(bounded, x0, eps, key)
        a = area(lo, hi)
        rows.append((key, lo, hi, a))
        print(f"{label:<22} [{lo[0]:+.3f}, {hi[0]:+.3f}]   "
              f"[{lo[1]:+.3f}, {hi[1]:+.3f}]   {a:7.3f}")

    # --- sanity / CI checks --------------------------------------------------
    # Every sound box must CONTAIN the true sample bounds.
    for key, lo, hi, _ in rows:
        for j in range(2):
            assert lo[j] <= true_lo[j] + 1e-4, f"{key} lower bound on y{j} is unsound: {lo[j]} > {true_lo[j]}"
            assert hi[j] >= true_hi[j] - 1e-4, f"{key} upper bound on y{j} is unsound: {hi[j]} < {true_hi[j]}"
    # Tightness ladder we expect for this network: CROWN no looser than IBP.
    a_ibp = next(a for k, _, _, a in rows if k == "IBP")
    a_crown = next(a for k, _, _, a in rows if k == "CROWN")
    assert a_crown <= a_ibp + 1e-4, f"CROWN box ({a_crown:.3f}) wider than IBP box ({a_ibp:.3f})"

    print()
    print("compareReachability: every method is sound (its rectangle contains")
    print("the true bbox); the tighter the relaxation, the tighter the rectangle.")
