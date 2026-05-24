/-
  Prodcons — auto-generated from `prodcons.smv`
  ============================================

  This file was produced by `scripts/smv2lean.py` from the SMV
  source `prodcons.smv`. It contains:

    • Lean encodings of the SMV variable types (enums become
      `inductive`s, booleans become `Bool`, ranges become `Nat`).
    • A `State` structure holding all variables of the model.
    • A `TransitionSystem` value (`<name>TS`) capturing the SMV
      `init` and `next` clauses. Nondeterministic SMV inputs
      become existentially-quantified variables in `next`.
    • For each `INVARSPEC` in the SMV, a Lean `theorem` STUB whose
      body is `sorry`. These stubs are placeholders — the real
      proofs (where we have them) live in `CounterDemo.NuXMV.ProdconsProofs`.

  Do NOT hand-edit this file: it will be overwritten by the next
  run of `smv2lean.py`. Add proofs in the corresponding
  `*Proofs.lean` file instead.
-/
import CounterDemo.TransitionSystem

inductive ActVal where
  | prod
  | cons
  | idle
  deriving DecidableEq, Repr

open ActVal

structure ProdconsState where
  buf : Nat
  act : ActVal
  deriving DecidableEq, Repr

def ProdconsTS : TransitionSystem ProdconsState where
  init s := s.buf = 0
  next s s' :=
    ∃ act' : ActVal,
    s'.act = act' ∧
    (if ((s.act = .prod) ∧ (s.buf < 3)) then s'.buf = (s.buf + 1)
    else if ((s.act = .cons) ∧ (s.buf > 0)) then s'.buf = (s.buf - 1)
    else s'.buf = s.buf)

-- INVARSPEC (from prodcons.smv): (buf <= CAP)
theorem ProdconsTS_inv1 :
    Invariant ProdconsTS (fun s => (s.buf ≤ 3)) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.ProdconsProofs.
  sorry

-- INVARSPEC (from prodcons.smv): (buf >= 0)
theorem ProdconsTS_inv2 :
    Invariant ProdconsTS (fun s => (s.buf ≥ 0)) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.ProdconsProofs.
  sorry

-- INVARSPEC (from prodcons.smv): (buf != CAP)
theorem ProdconsTS_inv3 :
    Invariant ProdconsTS (fun s => (s.buf ≠ 3)) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.ProdconsProofs.
  sorry

