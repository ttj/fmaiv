"""NN robustness certification with auto_LiRPA — STARTER (fill in the one TODO).

The model, training, and the eps sweep are all done. The one missing piece is
the heart of the method: the auto_LiRPA call that computes a CERTIFIED lower
bound on the margin  z[true] - z[other]  over the L-infinity eps-ball.

When you complete `certified_margin`, small eps prints CERTIFIED ROBUST and the
margin shrinks (eventually below 0) as eps grows. Worked solution: robustness.py
Deps:  pip install -r requirements.txt
"""
import torch
import torch.nn as nn
from auto_LiRPA import BoundedModule, BoundedTensor
from auto_LiRPA.perturbations import PerturbationLpNorm

torch.manual_seed(0)


def make_data(n=600):
    half = n // 2
    blob0 = torch.randn(half, 2) * 0.7 + torch.tensor([1.0, 1.0])
    blob1 = torch.randn(half, 2) * 0.7 + torch.tensor([-1.0, -1.0])
    return torch.cat([blob0, blob1], 0), torch.cat([torch.zeros(half), torch.ones(half)]).long()


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


def certified_margin(lirpa_model, x0, true_cls, eps):
    """Lower bound on z[true_cls] - z[other] over the L-inf eps-ball at x0."""
    other = 1 - true_cls
    C = torch.zeros(1, 1, 2)
    C[0, 0, true_cls] = 1.0
    C[0, 0, other] = -1.0
    ptb = PerturbationLpNorm(norm=float("inf"), eps=eps)
    bounded_x = BoundedTensor(x0, ptb)
    # TODO: ask auto_LiRPA for certified bounds on the margin under `ptb`:
    #     lb, ub = lirpa_model.compute_bounds(x=(bounded_x,), C=C, method="CROWN")
    # Return lb (the certified LOWER bound); > 0 means certified robust.
    lb = torch.zeros(1, 1)   # placeholder: always 0, so nothing is ever certified
    return lb.item()


if __name__ == "__main__":
    X, y = make_data()
    model = train(MLP(), X, y).eval()

    # near-boundary correctly-classified point (small margin) — robustness breaks here
    with torch.no_grad():
        logits = model(X)
        correct = logits.argmax(1) == y
        margins = torch.where(
            correct,
            logits.gather(1, y.view(-1, 1)).squeeze(1) - logits.gather(1, (1 - y).view(-1, 1)).squeeze(1),
            torch.full_like(logits[:, 0], float("inf")),
        )
        idx = int((margins - 1.5).abs().argmin())
    x0 = X[idx:idx + 1]
    true_cls = y[idx].item()
    lirpa_model = BoundedModule(model, torch.empty_like(x0))

    print(f"input = {[round(v, 3) for v in x0.tolist()[0]]}, true class = {true_cls}")
    print(f"{'eps':>6} {'cert. margin':>13}  verdict")
    for eps in [0.0, 0.05, 0.1, 0.2, 0.3, 0.5]:
        m = certified_margin(lirpa_model, x0, true_cls, eps)
        verdict = "CERTIFIED ROBUST" if m > 0 else "not certified"
        print(f"{eps:6.2f} {m:13.4f}  {verdict}")
    print("\n(once the TODO is filled in, small eps should be CERTIFIED ROBUST)")
