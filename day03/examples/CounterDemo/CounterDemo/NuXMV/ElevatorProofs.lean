/-
  Proofs for the elevator transition system (translated from `day02/examples/elevator.smv`
  by `scripts/smv2lean/`). The stub file `Elevator.lean` has one commented theorem
  per INVARSPEC; here we prove the one that holds and formally refute the one that does not.

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

/-- INVARSPEC 2 (DELIBERATELY FALSE): `door = closed` on every reachable state is
    NOT an invariant — the initial state already has `door = open`. You don't fill
    the stub; you **refute** it by proving the negation, exhibiting the reachable
    witness (here, the initial state). This is the Lean analogue of the
    "DELIBERATELY FALSE" spec NuSMV flags on Day 2. -/
theorem ElevatorTS_inv2_refuted :
    ¬ Invariant ElevatorTS (fun s => s.door = .closed) := by
  intro h
  -- the initial state (floor 0, door open, stopped) is reachable...
  let s0 : ElevatorState := { floor := 0, door := .open, moving := false }
  have hreach : Reachable ElevatorTS s0 := Reachable.init s0 ⟨rfl, rfl, rfl⟩
  -- ...so the (false) invariant would force its door closed — contradiction.
  exact absurd (h s0 hreach) (by decide)

end ElevatorProofs
