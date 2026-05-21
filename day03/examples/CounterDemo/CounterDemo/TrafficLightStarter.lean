/-
  Traffic-light transition system — STARTER (prove the safety invariant).

  The system is given. Prove `safe_inductive` (the init + step preservation),
  then `safe_invariant` follows from the framework. Worked solution:
  `TrafficLight.lean`.
-/
import CounterDemo.TransitionSystem

namespace TrafficLightStarter

inductive Light where
  | red | green | yellow
deriving DecidableEq

inductive Phase where
  | nsGo | nsYel | ewGo | ewYel
deriving DecidableEq

def ns : Phase → Light
  | .nsGo => .green | .nsYel => .yellow | _ => .red

def ew : Phase → Light
  | .ewGo => .green | .ewYel => .yellow | _ => .red

def step : Phase → Phase
  | .nsGo => .nsYel | .nsYel => .ewGo | .ewGo => .ewYel | .ewYel => .nsGo

def ts : TransitionSystem Phase where
  init := fun p => p = Phase.nsGo
  next := fun p p' => p' = step p

def safe (p : Phase) : Prop := ¬ (ns p = Light.green ∧ ew p = Light.green)

-- TODO: prove `safe` is an inductive invariant.
-- Hint: `constructor`, then in each part `cases p <;> simp [safe, ns, ew, step]`.
theorem safe_inductive : InductiveInvariant ts safe := by
  sorry

theorem safe_invariant : Invariant ts safe :=
  inductive_invariant_holds ts safe safe_inductive

end TrafficLightStarter
