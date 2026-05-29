"""Adversarial perturbation generation: FGSM + PGD on a small ReLU MLP.

A *falsifier* demo (no verifier): given a trained neural network and a clean
input, generate an adversarial example -- an input close to the clean one that
the network misclassifies. Two methods, both gradient-driven:

  FGSM  (Goodfellow, Shlens, Szegedy, ICLR 2015; arXiv:1412.6572):
        one step along the sign of the loss gradient.

  PGD   (Madry et al., ICLR 2018; arXiv:1706.06083):
        many small projected gradient steps with random restarts -- a much
        stronger attack and the standard adversarial-robustness benchmark.

This is the *attack* side of the certified-robustness story built in
robustness.py / verify_fc.py: a verifier proves no adversarial example exists
inside an L-infinity ball; a falsifier looks for one. Together they are the
classic soundness <-> completeness pair from the rest of the course.

The same algorithmic family extends to "LLM jailbreaks" -- e.g. Zou, Wang,
Carlini, Nasr, Kolter, Fredrikson, "Universal and Transferable Adversarial
Attacks on Aligned Language Models", 2023 (arXiv:2307.15043), aka GCG. The
substrate (continuous pixels vs. discrete tokens), the constraint (L-inf
ball vs. fixed-length token suffix), and the property ("class doesn't flip"
vs. "guardrail isn't bypassed") change; the recipe -- gradient-driven search
inside a constrained neighborhood -- does not.

Run:   python adversarial_demo.py
Deps:  pip install -r requirements.txt    (torch only -- no auto_LiRPA needed)
"""
import torch
import torch.nn as nn

torch.manual_seed(0)


# ---- 1. the 2-D, 2-class blob dataset + small ReLU MLP (same as robustness.py)
def make_data(n=600):
    half = n // 2
    blob0 = torch.randn(half, 2) * 0.7 + torch.tensor([1.0, 1.0])    # class 0
    blob1 = torch.randn(half, 2) * 0.7 + torch.tensor([-1.0, -1.0])  # class 1
    X = torch.cat([blob0, blob1], 0)
    y = torch.cat([torch.zeros(half), torch.ones(half)]).long()
    return X, y


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
    return model.eval()


# ---- 2. FGSM: one sign-of-gradient step, clipped to the eps ball -------------
def fgsm_attack(model, x0, true_cls, eps):
    """One step along sign(grad CE-loss); clip to the L-inf eps ball."""
    if eps == 0.0:
        return x0.clone()
    x = x0.clone().requires_grad_(True)
    loss = nn.CrossEntropyLoss()(model(x), torch.tensor([true_cls]))
    grad = torch.autograd.grad(loss, x)[0]
    return (x0 + eps * grad.sign()).detach()


# ---- 3. PGD: random-restart projected gradient descent -----------------------
def pgd_attack(model, x0, true_cls, eps, steps=80, restarts=4):
    """Random-restart PGD: each restart starts at a random delta in the eps box,
    walks `steps` sign-of-gradient steps shrinking the margin to the other
    class, and re-projects into the box after every step. Returns the worst
    (lowest-margin) perturbed input across all restarts."""
    other = 1 - true_cls
    if eps == 0.0:
        return x0.clone()
    step_size = 2.5 * eps / steps
    best_x = x0.clone(); best_m = float("inf")
    for _ in range(restarts):
        delta = ((torch.rand_like(x0) * 2 - 1) * eps).requires_grad_(True)
        for _ in range(steps):
            logits = model(x0 + delta)
            margin = logits[0, true_cls] - logits[0, other]
            grad = torch.autograd.grad(margin, delta)[0]
            delta = (delta - step_size * grad.sign()).clamp(-eps, eps).detach().requires_grad_(True)
        with torch.no_grad():
            m = (model(x0 + delta)[0, true_cls] - model(x0 + delta)[0, other]).item()
        if m < best_m:
            best_m = m; best_x = (x0 + delta).detach()
    return best_x


def flips(model, x_adv, true_cls):
    with torch.no_grad():
        return model(x_adv).argmax(1).item() != true_cls


if __name__ == "__main__":
    X, y = make_data()
    model = train(MLP(), X, y)
    acc = (model(X).argmax(1) == y).float().mean().item()
    print(f"trained 2-D, 2-class ReLU MLP   accuracy = {acc:.3f}")

    # Pick a correctly-classified point with a moderate clean margin (same
    # selection as robustness.py so the eps thresholds line up).
    with torch.no_grad():
        logits = model(X)
        correct = logits.argmax(1) == y
        margins = torch.where(
            correct,
            logits.gather(1, y.view(-1, 1)).squeeze(1)
                - logits.gather(1, (1 - y).view(-1, 1)).squeeze(1),
            torch.full_like(logits[:, 0], float("inf")),
        )
        idx = int((margins - 3.5).abs().argmin())
    x0 = X[idx:idx + 1]
    true_cls = int(y[idx].item())

    print(f"\nclean input = {[round(v, 3) for v in x0.tolist()[0]]}, true class = {true_cls}")
    print(f"{'eps':>6} {'FGSM flips?':>13} {'PGD flips?':>12}")

    fgsm_n = 0
    pgd_n = 0
    trials = 0
    for eps in [0.0, 0.1, 0.3, 0.5, 0.7, 1.0]:
        adv_f = fgsm_attack(model, x0, true_cls, eps)
        adv_p = pgd_attack(model, x0, true_cls, eps)
        f = flips(model, adv_f, true_cls)
        p = flips(model, adv_p, true_cls)
        print(f"{eps:6.2f} {('yes' if f else '--'):>13} {('yes' if p else '--'):>12}")
        fgsm_n += int(f); pgd_n += int(p); trials += 1

    print(f"\nadversarial_demo: FGSM flipped {fgsm_n}/{trials}, "
          f"PGD flipped {pgd_n}/{trials} ({trials} eps values).")

    # CI sanity: PGD must be at least as strong as FGSM under the same budget;
    # any clean (eps = 0) attack must NOT flip a correctly-classified input.
    assert pgd_n >= fgsm_n, "PGD found fewer adversaries than FGSM -- attack regressed"
    assert not flips(model, fgsm_attack(model, x0, true_cls, 0.0), true_cls), \
        "FGSM at eps = 0 must not flip a clean correct prediction"
    assert not flips(model, pgd_attack(model, x0, true_cls, 0.0), true_cls), \
        "PGD at eps = 0 must not flip a clean correct prediction"

    print("adversarial_demo finished: image-attack family extends to LLM jailbreaks (GCG, Zou et al. 2023).")
