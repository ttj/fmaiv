/-
  Counter — auto-generated from `counter.smv`
  ===========================================

  This file was produced by `scripts/smv2lean.py` from the SMV
  source `counter.smv`. It contains:

    • Lean encodings of the SMV variable types (enums become
      `inductive`s, booleans become `Bool`, ranges become `Nat`).
    • A `State` structure holding all variables of the model.
    • A `TransitionSystem` value (`<name>TS`) capturing the SMV
      `init` and `next` clauses. Nondeterministic SMV inputs
      become existentially-quantified variables in `next`.
    • For each `INVARSPEC` in the SMV, a Lean `theorem` STUB whose
      body is `sorry`. These stubs are placeholders — the real
      proofs (where we have them) live in `VerifDemo.NuXMV.CounterProofs`.

  Do NOT hand-edit this file: it will be overwritten by the next
  run of `smv2lean.py`. Add proofs in the corresponding
  `*Proofs.lean` file instead.
-/
import CounterDemo.TransitionSystem

inductive ModeVal where
  | off
  | on
  deriving DecidableEq, Repr

open ModeVal

structure CounterState where
  mode : ModeVal
  press : Bool
  x : Nat
  deriving DecidableEq, Repr

def CounterTS : TransitionSystem CounterState where
  init s := s.mode = .off ∧ s.x = 0
  next s s' :=
    ∃ press' : Bool,
    s'.press = press' ∧
    (if ((s.mode = .off) ∧ (s.press = false)) then s'.mode = .off
    else if ((s.mode = .off) ∧ (s.press = true)) then s'.mode = .on
    else if (((s.mode = .on) ∧ (s.press = false)) ∧ (s.x < 10)) then s'.mode = .on
    else if ((s.mode = .on) ∧ ((s.press = true) ∨ (s.x ≥ 10))) then s'.mode = .off
    else s'.mode = s.mode)
    ∧
    (if (((s.mode = .on) ∧ (s.press = false)) ∧ (s.x < 10)) then s'.x = (s.x + 1)
    else if ((s.mode = .on) ∧ ((s.press = true) ∨ (s.x ≥ 10))) then s'.x = 0
    else s'.x = s.x)

-- INVARSPEC (from counter.smv): (x <= count_max)
theorem CounterTS_inv1 :
    Invariant CounterTS (fun s => (s.x ≤ 10)) := by
  -- placeholder; real proof (if any) is in VerifDemo.NuXMV.CounterProofs.
  sorry

-- INVARSPEC (from counter.smv): ((mode = off) -> (x = 0))
theorem CounterTS_inv2 :
    Invariant CounterTS (fun s => ((s.mode = .off) → (s.x = 0))) := by
  -- placeholder; real proof (if any) is in VerifDemo.NuXMV.CounterProofs.
  sorry

-- INVARSPEC (from counter.smv): ((x > 0) -> (mode = on))
theorem CounterTS_inv3 :
    Invariant CounterTS (fun s => ((s.x > 0) → (s.mode = .on))) := by
  -- placeholder; real proof (if any) is in VerifDemo.NuXMV.CounterProofs.
  sorry

-- INVARSPEC (from counter.smv): (x < count_max)
theorem CounterTS_inv4 :
    Invariant CounterTS (fun s => (s.x < 10)) := by
  -- placeholder; real proof (if any) is in VerifDemo.NuXMV.CounterProofs.
  sorry

-- INVARSPEC (from counter.smv): (x <= (count_max / 2))
theorem CounterTS_inv5 :
    Invariant CounterTS (fun s => (s.x ≤ (10 / 2))) := by
  -- placeholder; real proof (if any) is in VerifDemo.NuXMV.CounterProofs.
  sorry

