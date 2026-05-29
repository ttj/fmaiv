"""MNIST FC robustness: the output-set-before-argmax view (auto_LiRPA).

Python / auto_LiRPA analog of NNV's verify_fc.m:
  https://github.com/verivital/nnv/blob/master/code/nnv/examples/Tutorial/NN/MNIST/verify_fc.m

For a single test image x0 and an L-infinity eps-perturbation, compute CROWN's
sound lower/upper bounds on EVERY output logit z[j] for j = 0..9 -- the
"output reachable set, projected per neuron." Robustness then reduces to a
single inequality on those intervals:

    lo[true_class] > max_{j != true_class} hi[j]    =>  CERTIFIED ROBUST

i.e. the true class's WORST score still beats every rival's BEST score.

Run:   python verify_fc.py
Deps:  pip install -r requirements.txt   (also needs torchvision for MNIST;
       falls back to a synthetic stand-in dataset if torchvision is absent)
"""
import os
import torch
import torch.nn as nn
from auto_LiRPA import BoundedModule, BoundedTensor
from auto_LiRPA.perturbations import PerturbationLpNorm

torch.manual_seed(0)


def get_mnist():
    """Real MNIST via torchvision if available; otherwise a tiny synthetic
    stand-in (deterministic noise) so the script still runs in restricted CI
    images. Returns (X_train, y_train, X_test, y_test) with X in [0,1] and
    shape (N, 1, 28, 28)."""
    try:
        import torchvision
        root = os.environ.get("FMAIV_MNIST_ROOT", "/tmp/mnist")
        tr = torchvision.datasets.MNIST(root, train=True,  download=True)
        te = torchvision.datasets.MNIST(root, train=False, download=True)
        Xtr = tr.data.float().div(255).unsqueeze(1)
        ytr = tr.targets
        Xte = te.data.float().div(255).unsqueeze(1)
        yte = te.targets
        return Xtr, ytr, Xte, yte, True
    except Exception:
        Xtr = torch.rand(2000, 1, 28, 28)
        ytr = torch.randint(0, 10, (2000,))
        Xte = torch.rand(200, 1, 28, 28)
        yte = torch.randint(0, 10, (200,))
        return Xtr, ytr, Xte, yte, False


class Net(nn.Module):
    """Compact MNIST FC classifier (784 -> 64 -> 32 -> 10, ReLU)."""
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Flatten(),
            nn.Linear(784, 64), nn.ReLU(),
            nn.Linear(64, 32), nn.ReLU(),
            nn.Linear(32, 10),
        )

    def forward(self, x):
        return self.net(x)


def train(model, X, y, epochs=1, batch=256, lr=1e-3):
    opt = torch.optim.Adam(model.parameters(), lr=lr)
    lossf = nn.CrossEntropyLoss()
    for _ in range(epochs):
        perm = torch.randperm(X.shape[0])
        for i in range(0, X.shape[0], batch):
            idx = perm[i:i + batch]
            opt.zero_grad()
            lossf(model(X[idx]), y[idx]).backward()
            opt.step()
    return model.eval()


def output_intervals(bounded, x0, eps, method="CROWN"):
    """Sound (lower, upper) bounds on every output logit z[j] under the
    L-inf eps-ball around x0. This is the 'output set before argmax,
    projected to each neuron' view."""
    ptb = PerturbationLpNorm(norm=float("inf"), eps=eps)
    lb, ub = bounded.compute_bounds(x=(BoundedTensor(x0, ptb),), method=method)
    return lb[0].tolist(), ub[0].tolist()


if __name__ == "__main__":
    Xtr, ytr, Xte, yte, have_mnist = get_mnist()
    src = "MNIST" if have_mnist else "synthetic (torchvision not available)"
    print(f"dataset: {src}")

    model = train(Net(), Xtr, ytr)

    # Pick the first correctly-classified test image we find.
    with torch.no_grad():
        preds = model(Xte[:200]).argmax(1)
        good = (preds == yte[:200]).nonzero(as_tuple=False).squeeze(1)
    if good.numel() == 0:
        # Without real MNIST the random labels rarely line up; fall back to
        # using the predicted class as the 'true' class so the demo continues.
        idx = 0
        true_c = int(model(Xte[idx:idx + 1]).argmax(1).item())
        print(f"(no test image classified correctly under random labels; "
              f"using predicted class {true_c} as the demo's 'true' class)")
    else:
        idx = int(good[0].item())
        true_c = int(yte[idx].item())

    x0 = Xte[idx:idx + 1]
    assert model(x0).argmax(1).item() == true_c, "demo x0 must classify as the chosen true class"

    bounded = BoundedModule(model, torch.empty_like(x0))

    eps = 0.005
    lo, hi = output_intervals(bounded, x0, eps)

    print(f"\nverify_fc analog: image #{idx} (true class = {true_c}), eps = {eps}")
    print(f"{'class':>6} {'lo':>10} {'hi':>10} {'width':>9}")
    for j in range(10):
        mark = "  <-- true class" if j == true_c else ""
        print(f"{j:>6} {lo[j]:+10.3f} {hi[j]:+10.3f} {hi[j] - lo[j]:9.3f}{mark}")

    true_lo = lo[true_c]
    rival_hi = max(hi[j] for j in range(10) if j != true_c)
    rival_arg = max(
        (j for j in range(10) if j != true_c),
        key=lambda j: hi[j],
    )
    robust = true_lo > rival_hi

    print(f"\ntrue-class lower bound : lo[{true_c}] = {true_lo:+.3f}")
    print(f"nearest-rival upper bnd: hi[{rival_arg}] = {rival_hi:+.3f}")
    verdict = "CERTIFIED ROBUST  (lo[true] > max_j hi[rival])" if robust else "not certified by CROWN"
    print(f"verdict at eps = {eps}: {verdict}")

    # --- CI sanity: at eps = 0 the bounds collapse to the clean logits, so the
    # clean (correctly-classified) image MUST certify trivially.
    lo0, hi0 = output_intervals(bounded, x0, 0.0)
    rival_hi0 = max(hi0[j] for j in range(10) if j != true_c)
    assert lo0[true_c] > rival_hi0, "clean image must certify at eps = 0"

    print("\nverify_fc demo finished: output-set-before-argmax printed above.")
