/-
  Gcd — auto-generated from `gcd.smv`
  =======================================

  This file was produced by `scripts/smv2lean.py` from the SMV
  source `gcd.smv`. It contains:

    • Lean encodings of the SMV variable types (enums become
      `inductive`s, booleans become `Bool`, ranges become `Nat`).
    • A `State` structure holding all variables of the model.
    • A `TransitionSystem` value (`<name>TS`) capturing the SMV
      `init` and `next` clauses. Nondeterministic SMV inputs
      become existentially-quantified variables in `next`.
    • For each `INVARSPEC` in the SMV, a COMMENTED Lean `theorem`
      stub (so this file stays sorry-free). Uncomment one and prove
      it; completed proofs live in `CounterDemo.NuXMV.GcdProofs`.

  Do NOT hand-edit this file: it will be overwritten by the next
  run of `smv2lean.py`. Add proofs in the corresponding
  `*Proofs.lean` file instead.
-/
import CounterDemo.TransitionSystem

inductive PcVal where
  | l1
  | l2
  | l3
  | l4
  | l5
  deriving DecidableEq, Repr

open PcVal

structure GcdState where
  a : Nat
  b : Nat
  pc : PcVal
  deriving DecidableEq, Repr

def GcdTS : TransitionSystem GcdState where
  init s := s.pc = .l1
  next s s' :=
    (if ((s.pc = .l3) ∧ (s.a > s.b)) then s'.a = (s.a - s.b)
    else s'.a = s.a)
    ∧
    (if ((s.pc = .l4) ∧ (s.b > s.a)) then s'.b = (s.b - s.a)
    else s'.b = s.b)
    ∧
    (if ((s.pc = .l1) ∧ (s.a ≠ s.b)) then s'.pc = .l2
    else if ((s.pc = .l1) ∧ (s.a = s.b)) then s'.pc = .l5
    else if ((s.pc = .l2) ∧ (s.a > s.b)) then s'.pc = .l3
    else if ((s.pc = .l2) ∧ (s.a ≤ s.b)) then s'.pc = .l4
    else if ((s.pc = .l3) ∨ (s.pc = .l4)) then s'.pc = .l1
    else if (s.pc = .l5) then s'.pc = .l5
    else s'.pc = s.pc)

-- INVARSPEC 1 (from gcd.smv): ((a > 0) & (b > 0))
--   Exercise: uncomment and prove (or, if false, prove its negation);
--   completed proofs go in CounterDemo.NuXMV.GcdProofs.
-- theorem GcdTS_inv1 :
--     Invariant GcdTS (fun s => ((s.a > 0) ∧ (s.b > 0))) := by
--   sorry

-- INVARSPEC 2 (from gcd.smv): ((a >= 0) & (b >= 0))
--   Exercise: uncomment and prove (or, if false, prove its negation);
--   completed proofs go in CounterDemo.NuXMV.GcdProofs.
-- theorem GcdTS_inv2 :
--     Invariant GcdTS (fun s => ((s.a ≥ 0) ∧ (s.b ≥ 0))) := by
--   sorry

-- INVARSPEC 3 (from gcd.smv): ((a = 0) & (b = 0))
--   Exercise: uncomment and prove (or, if false, prove its negation);
--   completed proofs go in CounterDemo.NuXMV.GcdProofs.
-- theorem GcdTS_inv3 :
--     Invariant GcdTS (fun s => ((s.a = 0) ∧ (s.b = 0))) := by
--   sorry

