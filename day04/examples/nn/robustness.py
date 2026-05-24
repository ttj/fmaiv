"""Neural-network robustness certification with auto_LiRPA (CPU) — full solution.

This is the Day-4 "frontier" hands-on: the same *verification* question as the
rest of the week ("can the bad thing happen?"), now for a neural network.

  Question:  within an L-infinity ball of radius eps around an input x0, can the
             classifier's prediction change?
  Tool:      auto_LiRPA (the CROWN bound-propagation engine under alpha,beta-CROWN,
             the VNN-COMP winner). It computes a CERTIFIED lower bound on the
             margin  z[true] - z[other]  over the whole ball. If that bound is
             > 0, NO input in the ball is misclassified — a proof, not a sample.

Everything here is deterministic, tiny, and CPU-only (a 2-D, 2-class MLP), so it
runs in ~1s on a free Colab or a standard Codespace — no GPU, no dataset
download. The same code applies unchanged to a trained MNIST/CIFAR network; see
our AAAI'26 VNN-COMP tutorial (https://vnn-comp.github.io/#aaai2026) for that.

Run:   python robustness.py
Deps:  pip install -r requirements.txt   (torch CPU wheel + auto_LiRPA)
Starter: robustness_starter.py
"""
import torch
import torch.nn as nn
from auto_LiRPA import BoundedModule, BoundedTensor
from auto_LiRPA.perturbations import PerturbationLpNorm

torch.manual_seed(0)            # reproducible: same data, weights, verdicts every run


# ---- 1. a tiny 2-D, 2-class dataset: two slightly-overlapping Gaussian blobs --
# (Some overlap on purpose, so a near-boundary point exists where robustness
# actually breaks down — that transition is the whole lesson.)
def make_data(n=600):
    half = n // 2
    blob0 = torch.randn(half, 2) * 0.7 + torch.tensor([1.0, 1.0])    # class 0
    blob1 = torch.randn(half, 2) * 0.7 + torch.tensor([-1.0, -1.0])  # class 1
    X = torch.cat([blob0, blob1], 0)
    y = torch.cat([torch.zeros(half), torch.ones(half)]).long()
    return X, y


# ---- 2. a small ReLU MLP (2 -> 16 -> 16 -> 2) --------------------------------
class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(2, 16), nn.ReLU(),
            nn.Linear(16, 16), nn.ReLU(),
            nn.Linear(16, 2),
        )

    def forward(self, x):
        return self.net(x)


def train(model, X, y, steps=300):
    opt = torch.optim.Adam(model.parameters(), lr=0.05)
    lossf = nn.CrossEntropyLoss()
    for _ in range(steps):
        opt.zero_grad()
        lossf(model(X), y).backward()
        opt.step()
    return model


# ---- 3. certified margin via auto_LiRPA --------------------------------------
def certified_margin(lirpa_model, x0, true_cls, eps):
    """Lower bound on  z[true_cls] - z[other]  over the L-inf eps-ball at x0.
    > 0  means CERTIFIED robust (no input in the ball flips the prediction)."""
    other = 1 - true_cls
    # C is the linear specification matrix picking out the margin we care about.
    C = torch.zeros(1, 1, 2)
    C[0, 0, true_cls] = 1.0
    C[0, 0, other] = -1.0
    ptb = PerturbationLpNorm(norm=float("inf"), eps=eps)
    bounded_x = BoundedTensor(x0, ptb)
    lb, _ub = lirpa_model.compute_bounds(x=(bounded_x,), C=C, method="CROWN")
    return lb.item()


# ---- 4. PGD: actually try to FIND an adversarial example (a falsifier) --------
def pgd_finds_adversary(model, x0, true_cls, eps, steps=100, lr=0.02):
    other = 1 - true_cls
    delta = torch.zeros_like(x0, requires_grad=True)
    for _ in range(steps):
        margin = (model(x0 + delta)[0, true_cls] - model(x0 + delta)[0, other])
        grad = torch.autograd.grad(margin, delta)[0]
        delta = (delta - lr * grad.sign()).clamp(-eps, eps).detach().requires_grad_(True)
    with torch.no_grad():
        return model(x0 + delta).argmax(1).item() != true_cls


if __name__ == "__main__":
    X, y = make_data()
    model = train(MLP(), X, y).eval()

    # Pick a NEAR-boundary correctly-classified point: small (but not razor-thin)
    # clean margin, so it certifies for a band of small eps and then breaks — that
    # transition from "certified" to "adversarial found" is the whole lesson.
    with torch.no_grad():
        logits = model(X)
        correct = logits.argmax(1) == y
        true_logit = logits.gather(1, y.view(-1, 1)).squeeze(1)
        other_logit = logits.gather(1, (1 - y).view(-1, 1)).squeeze(1)
        margins = torch.where(correct, true_logit - other_logit,
                              torch.full_like(true_logit, float("inf")))
        target = 1.5   # aim for a modest margin, not the absolute closest point
        idx = int((margins - target).abs().argmin())
    x0 = X[idx:idx + 1]
    true_cls = y[idx].item()
    assert model(x0).argmax(1).item() == true_cls, "x0 must be classified correctly"

    lirpa_model = BoundedModule(model, torch.empty_like(x0))

    print(f"input = {[round(v, 3) for v in x0.tolist()[0]]}, true class = {true_cls}")
    print(f"{'eps':>6} {'cert. margin':>13}  verdict")
    clean_margin = None
    certified_upto = 0.0
    adv_at = None
    for eps in [0.0, 0.05, 0.1, 0.2, 0.3, 0.5]:
        m = certified_margin(lirpa_model, x0, true_cls, eps)
        if clean_margin is None:
            clean_margin = m
        robust = m > 0
        verdict = "CERTIFIED ROBUST" if robust else "not certified by CROWN"
        if robust:
            certified_upto = eps
        elif adv_at is None:
            try:
                if pgd_finds_adversary(model, x0, true_cls, eps):
                    adv_at = eps
                    verdict += "  <-- adversarial example FOUND"
            except Exception:
                pass   # PGD is illustrative; never let it break the demo
        print(f"{eps:6.2f} {m:13.4f}  {verdict}")

    print(
        f"\nNN robustness demo: clean margin {clean_margin:.4f}, "
        f"certified up to eps={certified_upto}, adversarial found at eps={adv_at}"
    )
    # Sanity check for CI: a correctly-classified point is certified at eps = 0.
    assert clean_margin is not None and clean_margin > 0, "clean point must certify"
