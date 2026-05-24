/-
  Peterson — auto-generated from `peterson.smv`
  ============================================

  This file was produced by `scripts/smv2lean.py` from the SMV
  source `peterson.smv`. It contains:

    • Lean encodings of the SMV variable types (enums become
      `inductive`s, booleans become `Bool`, ranges become `Nat`).
    • A `State` structure holding all variables of the model.
    • A `TransitionSystem` value (`<name>TS`) capturing the SMV
      `init` and `next` clauses. Nondeterministic SMV inputs
      become existentially-quantified variables in `next`.
    • For each `INVARSPEC` in the SMV, a Lean `theorem` STUB whose
      body is `sorry`. These stubs are placeholders — the real
      proofs (where we have them) live in `CounterDemo.NuXMV.PetersonProofs`.

  Do NOT hand-edit this file: it will be overwritten by the next
  run of `smv2lean.py`. Add proofs in the corresponding
  `*Proofs.lean` file instead.
-/
import CounterDemo.TransitionSystem

structure PetersonState where
  pc1 : Nat
  pc2 : Nat
  flag1 : Bool
  flag2 : Bool
  turn : Nat
  run : Nat
  deriving DecidableEq, Repr

def PetersonTS : TransitionSystem PetersonState where
  init s := s.pc1 = 0 ∧ s.pc2 = 0 ∧ s.flag1 = false ∧ s.flag2 = false ∧ s.turn = 1
  next s s' :=
    ∃ run' : Nat,
    s'.run = run' ∧
    (if (s.run ≠ 1) then s'.pc1 = s.pc1
    else if (s.pc1 = 0) then (s'.pc1 = 0 ∨ s'.pc1 = 1)
    else if (s.pc1 = 1) then s'.pc1 = 2
    else if (s.pc1 = 2) then s'.pc1 = 3
    else if ((s.pc1 = 3) ∧ ((s.flag2 = false) ∨ (s.turn = 1))) then s'.pc1 = 4
    else if (s.pc1 = 3) then s'.pc1 = 3
    else if (s.pc1 = 4) then s'.pc1 = 5
    else if (s.pc1 = 5) then s'.pc1 = 0
    else s'.pc1 = s.pc1)
    ∧
    (if (s.run ≠ 2) then s'.pc2 = s.pc2
    else if (s.pc2 = 0) then (s'.pc2 = 0 ∨ s'.pc2 = 1)
    else if (s.pc2 = 1) then s'.pc2 = 2
    else if (s.pc2 = 2) then s'.pc2 = 3
    else if ((s.pc2 = 3) ∧ ((s.flag1 = false) ∨ (s.turn = 2))) then s'.pc2 = 4
    else if (s.pc2 = 3) then s'.pc2 = 3
    else if (s.pc2 = 4) then s'.pc2 = 5
    else if (s.pc2 = 5) then s'.pc2 = 0
    else s'.pc2 = s.pc2)
    ∧
    (if ((s.run = 1) ∧ (s.pc1 = 1)) then s'.flag1 = true
    else if ((s.run = 1) ∧ (s.pc1 = 5)) then s'.flag1 = false
    else s'.flag1 = s.flag1)
    ∧
    (if ((s.run = 2) ∧ (s.pc2 = 1)) then s'.flag2 = true
    else if ((s.run = 2) ∧ (s.pc2 = 5)) then s'.flag2 = false
    else s'.flag2 = s.flag2)
    ∧
    (if ((s.run = 1) ∧ (s.pc1 = 2)) then s'.turn = 2
    else if ((s.run = 2) ∧ (s.pc2 = 2)) then s'.turn = 1
    else s'.turn = s.turn)

-- INVARSPEC (from peterson.smv): !(((pc1 = 4) & (pc2 = 4)))
theorem PetersonTS_inv1 :
    Invariant PetersonTS (fun s => (¬((s.pc1 = 4) ∧ (s.pc2 = 4)))) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.PetersonProofs.
  sorry

-- INVARSPEC (from peterson.smv): ((pc1 = 4) -> flag1)
theorem PetersonTS_inv2 :
    Invariant PetersonTS (fun s => ((s.pc1 = 4) → (s.flag1 = true))) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.PetersonProofs.
  sorry

-- INVARSPEC (from peterson.smv): ((pc2 = 4) -> flag2)
theorem PetersonTS_inv3 :
    Invariant PetersonTS (fun s => ((s.pc2 = 4) → (s.flag2 = true))) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.PetersonProofs.
  sorry

-- INVARSPEC (from peterson.smv): (pc1 != 4)
theorem PetersonTS_inv4 :
    Invariant PetersonTS (fun s => (s.pc1 ≠ 4)) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.PetersonProofs.
  sorry

