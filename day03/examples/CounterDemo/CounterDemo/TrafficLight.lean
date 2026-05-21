/-
  A traffic-light intersection as a transition system.
  ====================================================

  The Day-2 model checker proved `!(main = green & side = green)` for the
  traffic_light.smv model. Here is the same system as a Lean transition system
  (using the framework in TransitionSystem.lean), with the same safety property
  proved as an inductive invariant — the count example's pattern, applied to a
  second machine.
-/
import CounterDemo.TransitionSystem

namespace TrafficLight

inductive Light where
  | red | green | yellow
deriving DecidableEq

/-- The controller cycles through four phases. -/
inductive Phase where
  | nsGo | nsYel | ewGo | ewYel
deriving DecidableEq

/-- North–south light in each phase. -/
def ns : Phase → Light
  | .nsGo  => .green
  | .nsYel => .yellow
  | _      => .red

/-- East–west light in each phase. -/
def ew : Phase → Light
  | .ewGo  => .green
  | .ewYel => .yellow
  | _      => .red

/-- The deterministic phase cycle. -/
def step : Phase → Phase
  | .nsGo  => .nsYel
  | .nsYel => .ewGo
  | .ewGo  => .ewYel
  | .ewYel => .nsGo

/-- The transition system: start in `nsGo`, advance by `step`. -/
def ts : TransitionSystem Phase where
  init := fun p => p = Phase.nsGo
  next := fun p p' => p' = step p

/-- Safety property: the two directions are never both green. -/
def safe (p : Phase) : Prop := ¬ (ns p = Light.green ∧ ew p = Light.green)

/-- `safe` is an inductive invariant: it holds initially and is preserved by
    every transition. Both parts are immediate by case analysis on the phase
    (at most one direction is green in any phase). -/
theorem safe_inductive : InductiveInvariant ts safe := by
  constructor
  · intro p _hp
    cases p <;> simp [safe, ns, ew]
  · intro p p' _hp hn
    subst hn
    cases p <;> simp [safe, ns, ew, step]

/-- Therefore mutual exclusion of green holds on every reachable state. -/
theorem safe_invariant : Invariant ts safe :=
  inductive_invariant_holds ts safe safe_inductive

end TrafficLight
