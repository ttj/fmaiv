# Run the tools online — no install needed

These notebooks let students run the course's formal-methods tools from the
browser, in case they didn't install them locally. There are two ways in.

## Option 1 — GitHub Codespaces (full toolset, recommended)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ttj/fmaiv)

Click the badge (or **Code ▸ Codespaces ▸ Create codespace on main**). You get a
container built from the course image with **everything preinstalled**:
`z3` (CLI + Python), `cbmc`, `cryptol`, `saw`, `NuSMV`, `lean`, and `smvis`.

- Open any notebook in `notebooks/` and run it (the VS Code Jupyter extension is
  preconfigured), **or** run `jupyter lab` in the terminal for a full JupyterLab tab.
- You can also use the integrated terminal directly, e.g. `cbmc file.c --unwind 5`.
- Codespaces is free within a monthly allowance (120 core-hours; 180 for verified
  students via GitHub Education) — plenty for class use.

## Option 2 — Google Colab (per notebook, zero setup)

No GitHub account needed — just a Google login. Each notebook's first cell
installs only what's missing, so the same notebook works in both Codespaces and Colab.

| Notebook | Open in Colab |
|---|---|
| `01_z3_python.ipynb` — Z3 in Python | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/01_z3_python.ipynb) |
| `02_tools_cli.ipynb` — CBMC & NuSMV | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ttj/fmaiv/blob/main/notebooks/02_tools_cli.ipynb) |

In Colab, `z3`, `cbmc`, and `NuSMV` install in seconds. `cryptol`/`saw` are large
downloads — for those, prefer **Codespaces** (preinstalled).

## What about nuXmv?

`nuXmv` is license-gated (no public redistribution), so it is **not** in the
public Codespaces image or installed in Colab. Two options:

- **smvis web app** — run nuXmv (spec checking, state/BDD visualization) in the
  browser, and upload your own `.smv` files: <https://smvis-378135919048.us-central1.run.app>
- **In a notebook** — add nuXmv from the course's *private* teaching image (org
  members only). In the devcontainer, base a small `.devcontainer/Dockerfile` on
  the private image, or `docker cp`/mount the binary, then point `smvis` at it via
  the `SMVIS_NUXMV_PATH` env var. For finite-state models, `NuSMV` (already
  installed) accepts the same SMV language and prints the same `is true/false`
  verdicts.

> **Note:** the "Open in …" badges only work once this repo is pushed to GitHub
> (`ttj/fmaiv`, branch `main`) with these files present.
