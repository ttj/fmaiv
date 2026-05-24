/-
  Elevator — auto-generated from `elevator.smv`
  ============================================

  This file was produced by `scripts/smv2lean.py` from the SMV
  source `elevator.smv`. It contains:

    • Lean encodings of the SMV variable types (enums become
      `inductive`s, booleans become `Bool`, ranges become `Nat`).
    • A `State` structure holding all variables of the model.
    • A `TransitionSystem` value (`<name>TS`) capturing the SMV
      `init` and `next` clauses. Nondeterministic SMV inputs
      become existentially-quantified variables in `next`.
    • For each `INVARSPEC` in the SMV, a Lean `theorem` STUB whose
      body is `sorry`. These stubs are placeholders — the real
      proofs (where we have them) live in `CounterDemo.NuXMV.ElevatorProofs`.

  Do NOT hand-edit this file: it will be overwritten by the next
  run of `smv2lean.py`. Add proofs in the corresponding
  `*Proofs.lean` file instead.
-/
import CounterDemo.TransitionSystem

inductive DoorVal where
  | open
  | closed
  deriving DecidableEq, Repr

open DoorVal

structure ElevatorState where
  floor : Nat
  door : DoorVal
  moving : Bool
  deriving DecidableEq, Repr

def ElevatorTS : TransitionSystem ElevatorState where
  init s := s.floor = 0 ∧ s.door = .open ∧ s.moving = false
  next s s' :=
    (if ((s'.moving = true) ∧ (s.floor = 0)) then s'.floor = 1
    else if ((s'.moving = true) ∧ (s.floor = 2)) then s'.floor = 1
    else if ((s'.moving = true) ∧ (s.floor = 1)) then (s'.floor = 0 ∨ s'.floor = 2)
    else s'.floor = s.floor)
    ∧
    (if (s'.moving = true) then s'.door = .closed
    else (s'.door = .open ∨ s'.door = .closed))
    ∧
    (if (s.door = .open) then s'.moving = false
    else (s'.moving = false ∨ s'.moving = true))

-- INVARSPEC (from elevator.smv): (moving -> (door = closed))
theorem ElevatorTS_inv1 :
    Invariant ElevatorTS (fun s => ((s.moving = true) → (s.door = .closed))) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.ElevatorProofs.
  sorry

-- INVARSPEC (from elevator.smv): (door = closed)
theorem ElevatorTS_inv2 :
    Invariant ElevatorTS (fun s => (s.door = .closed)) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.ElevatorProofs.
  sorry

