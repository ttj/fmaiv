/-
  Proofs for the elevator transition system (translated from `day02/examples/elevator.smv`
  by `scripts/smv2lean/`). The stub file `Elevator.lean` has one unproved theorem
  per INVARSPEC; here we discharge the one that holds and explain the one that does not.

  This is the Day-2 → Day-3 bridge in miniature: the same model NuSMV checks on
  Day 2, proved by induction in Lean on Day 3.
-/
import CounterDemo.TransitionSystem
import CounterDemo.NuXMV.Elevator

namespace ElevatorProofs

/-- INVARSPEC 1 (HOLDS): the door is closed whenever the car is moving.
    This is enforced *by construction* — the `next(door)` clause forces the door
    shut in any step where `moving` becomes true — so it is even directly
    invariant (the inductive hypothesis is not needed). -/
theorem ElevatorTS_inv1_proved :
    Invariant ElevatorTS (fun s => s.moving = true → s.door = .closed) := by
  apply inductive_invariant_holds
  constructor
  · -- base case: the initial state has moving = false, so the implication is vacuous
    intro s hinit hmov
    obtain ⟨_, _, hmv⟩ := hinit          -- hmv : s.moving = false
    rw [hmv] at hmov                      -- hmov : false = true
    exact absurd hmov (by decide)
  · -- inductive step: the door clause forces door' = closed when moving' = true
    intro s s' _ hstep hmov'
    obtain ⟨_hfloor, hdoor, _hmoving⟩ := hstep
    simp [hmov'] at hdoor                 -- with moving' = true, the `if` collapses to door' = closed
    exact hdoor

/-
  INVARSPEC 2 (DELIBERATELY FALSE): `door = closed` on every state. This is NOT an
  invariant — the initial state has `door = open`, and the door may open whenever
  the car is stopped. So `Invariant ElevatorTS (fun s => s.door = .closed)`
  (the `ElevatorTS_inv2` stub in Elevator.lean) is unprovable; the witness is the
  initial state itself. This is the Lean analogue of the "DELIBERATELY FALSE" spec
  NuSMV flags on Day 2 — try to prove it and watch the base case fail.
-/

end ElevatorProofs
